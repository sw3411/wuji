import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import 'package:collection/collection.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../../core/ai/ai_client.dart' show AiMessage;
import '../../app/theme.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../domain/models/sale_record.dart';

/// AI 助手：物品总结 + 自然语言问答。
class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _ChatMsg {
  _ChatMsg.user(this.text) : isUser = true, time = DateTime.now();

  _ChatMsg.assistant(this.text) : isUser = false, time = DateTime.now();

  _ChatMsg._(this.text, this.isUser, this.time);

  final String text;
  final bool isUser;
  final DateTime time;

  Map<String, dynamic> toJson() => {
    't': text,
    'u': isUser,
    'at': time.toIso8601String(),
  };

  static _ChatMsg? fromJson(Map<String, dynamic> json) {
    final text = json['t'] as String?;
    if (text == null) return null;
    final at = DateTime.tryParse(json['at'] as String? ?? '');
    return _ChatMsg._(
      text,
      json['u'] as bool? ?? false,
      at ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <_ChatMsg>[];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  static const _historyKey = 'ai_chat_history';

  Future<void> _loadHistory() async {
    final json = await ref.read(settingsRepoProvider).getJson(_historyKey);
    if (json == null || !mounted) return;
    final list = (json['messages'] as List<dynamic>? ?? const [])
        .map((e) => _ChatMsg.fromJson(e as Map<String, dynamic>))
        .whereType<_ChatMsg>()
        .toList();
    if (list.isNotEmpty) {
      setState(() => _messages.addAll(list));
      _scrollToBottom();
    }
  }

  /// 最多持久化最近 60 条。
  Future<void> _saveHistory() async {
    final tail = _messages.length > 60
        ? _messages.sublist(_messages.length - 60)
        : _messages;
    await ref.read(settingsRepoProvider).setJson(_historyKey, {
      'messages': tail.map((m) => m.toJson()).toList(),
    });
  }

  Future<void> _newSession() async {
    final confirmed = _messages.isEmpty
        ? true
        : await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('新会话'),
              content: const Text('当前对话将被清空，开始新的会话。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('取消'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('开始新会话'),
                ),
              ],
            ),
          );
    if (confirmed != true) return;
    await ref.read(settingsRepoProvider).set(_historyKey, '');
    setState(_messages.clear);
  }

  static const _quickQuestions = [
    '我最贵的物品是什么？',
    '哪些物品在闲置？',
    '最近一个月买了什么？',
    '把闲置的吹风机标记为收纳中',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _summarize() async {
    final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
    final sales =
        ref.read(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    await _run(
      '总结一下我的物品和开支',
      () => ref.read(aiServiceProvider).summarize(items, sales),
    );
  }

  Future<void> _ask(String question) async {
    final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
    final history = _messages
        .map((m) => AiMessage(m.isUser ? 'user' : 'assistant', m.text))
        .toList();
    final sales =
        ref.read(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    await _run(
      question,
      () => ref
          .read(aiServiceProvider)
          .chatQuery(
            question,
            items,
            history: history,
            sales: sales,
            // 本地话题追踪：上一轮 AI 回答中点名的物品 = 指代候选。
            subjectHints: _subjectHints(items),
            // 写操作工具：AI 调用 → 这里弹确认框 → 执行本地写入。
            actionHandler: _executeAction,
          ),
    );
  }

  /// AI 写操作工具的本地执行：确认弹窗 → 仓库写入 → 返回结果文本给 AI。
  Future<String> _executeAction(
    String toolName,
    Map<String, dynamic> args,
  ) async {
    final repo = ref.read(itemRepoProvider);
    final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
    final id = args['itemId']?.toString();
    final item = items.where((i) => i.id == id).firstOrNull;
    if (item == null) {
      return '未找到该物品（itemId=$id），请使用数据中列出的 id。';
    }

    if (toolName == 'delete_item') {
      if (!mounted) return '页面已退出，操作中断。';
      final ok = await _confirmAction('移入回收站', '把「${item.name}」移入回收站？');
      if (!mounted) return '页面已退出，操作未执行。';
      if (ok != true) return '用户取消了删除操作。';
      await repo.softDelete(item.id);
      return '已把「${item.name}」移入回收站（30 天内可恢复）。';
    }

    // update_item
    final status = _parseStatus(args['status']?.toString());
    final locationName = args['locationName']?.toString();
    final notes = args['notes']?.toString();
    if (status == null && locationName == null && notes == null) {
      return '未提供可修改的字段（status/locationName/notes 至少一个）。';
    }
    if (args['status'] != null && status == null) {
      return '无法识别的状态：${args['status']}。'
          '可用：${ItemStatus.values.where((s) => s != ItemStatus.sold).map((s) => s.label).join('/')}';
    }
    Location? loc;
    if (locationName != null) {
      final locations =
          ref.read(locationsProvider).valueOrNull ?? const <Location>[];
      loc = locations.where((l) => l.name == locationName.trim()).firstOrNull;
      if (loc == null) {
        return '位置「$locationName」不存在，请先在位置管理中创建，或使用已有位置名。';
      }
    }
    final changes = <String>[
      if (status != null) '状态 → ${status.label}',
      if (loc != null) '位置 → ${loc.name}',
      if (notes != null) '备注更新',
    ].join('，');
    if (!mounted) return '页面已退出，操作中断。';
    final ok = await _confirmAction('修改物品', '把「${item.name}」$changes？');
    if (!mounted) return '页面已退出，操作未执行。';
    if (ok != true) return '用户取消了修改操作。';

    await repo.updateItem(
      item.copyWith(
        status: status,
        locationId: loc?.id,
        locationName: loc?.name,
        notes: notes,
      ),
    );
    return '已修改「${item.name}」：$changes。';
  }

  ItemStatus? _parseStatus(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    final t = text.trim();
    for (final s in ItemStatus.values) {
      if (s.label == t || s.name == t) return s == ItemStatus.sold ? null : s;
    }
    return null;
  }

  Future<bool?> _confirmAction(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  /// 从最近一条 AI 回答里找出被点名的物品名（按名称长度降序匹配，避免子串误命中）。
  List<String> _subjectHints(List<Item> items) {
    final lastAssistant = _messages.lastWhereOrNull((m) => !m.isUser)?.text;
    if (lastAssistant == null) return const [];
    final names =
        items
            .where((i) => !i.isDeleted && i.name.length >= 2)
            .map((i) => i.name)
            .toList()
          ..sort((a, b) => b.length.compareTo(a.length));
    final hits = <String>[];
    for (final name in names) {
      if (hits.length >= 3) break;
      if (lastAssistant.contains(name) && !hits.any((h) => h.contains(name))) {
        hits.add(name);
      }
    }
    return hits;
  }

  Future<void> _run(String userText, Future<String> Function() task) async {
    setState(() {
      _loading = true;
      _messages.add(_ChatMsg.user(userText));
    });
    _ctrl.clear();
    _scrollToBottom();
    try {
      final reply = await task();
      setState(() => _messages.add(_ChatMsg.assistant(reply)));
      await _saveHistory();
    } catch (e) {
      setState(
        () => _messages.add(
          _ChatMsg.assistant('出错了：$e\n\n如果是未配置，请先到「我的 → AI 助手设置」完成配置。'),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(aiConfigProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 助手'),
        actions: [
          IconButton(
            tooltip: '新会话',
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: _newSession,
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'clear') _newSession();
              if (v == 'settings') context.push('/settings/ai');
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'clear', child: Text('清空会话')),
              PopupMenuItem(value: 'settings', child: Text('AI 设置')),
            ],
          ),
        ],
      ),
      body: !config.isReady
          ? _unconfigured(context)
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? _emptyState(context)
                      : ListView.builder(
                          controller: _scrollCtrl,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_loading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length) {
                              return const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: _TypingDots(),
                                ),
                              );
                            }
                            final m = _messages[index];
                            return Align(
                              alignment: m.isUser
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: m.isUser
                                  ? Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 10,
                                      ),
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                            0.8,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppTheme.aiBubbleOther
                                            : AppTheme.aiBubbleOther,
                                        // 尾角收小：消息流的方向感。
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(18),
                                          topRight: Radius.circular(18),
                                          bottomLeft: Radius.circular(6),
                                          bottomRight: Radius.circular(18),
                                        ),
                                      ),
                                      child: Text(
                                        m.text,
                                        style: TextStyle(
                                          fontSize: 14,
                                          height: 1.5,
                                          // 深色气泡配浅字，修复深底深字不可读。
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? AppTheme.ink
                                              : AppTheme.darkOnSurface,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      child: MarkdownBody(
                                        data: m.text,
                                        selectable: true,
                                        styleSheet:
                                            MarkdownStyleSheet.fromTheme(
                                              Theme.of(context),
                                            ).copyWith(
                                              p: TextStyle(
                                                fontSize: 14.5,
                                                height: 1.7,
                                                color: cs.onSurface,
                                              ),
                                              listBullet: TextStyle(
                                                fontSize: 14.5,
                                                color: cs.onSurface,
                                              ),
                                              h2: TextStyle(
                                                fontSize: 15.5,
                                                fontWeight: FontWeight.w700,
                                                color: cs.onSurface,
                                              ),
                                              code: TextStyle(
                                                fontSize: 13,
                                                backgroundColor: cs
                                                    .surfaceContainerHighest
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                      ),
                                    ),
                            );
                          },
                        ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                    child: Column(
                      children: [
                        if (_messages.isEmpty)
                          SizedBox(
                            height: 36,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: _quickQuestions
                                  .map(
                                    (q) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ActionChip(
                                        label: Text(
                                          q,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        onPressed: () {
                                          _ctrl.text = q;
                                          _ask(q);
                                        },
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        Row(
                          children: [
                            IconButton(
                              tooltip: '总结物品与开支',
                              icon: const Icon(Icons.summarize_outlined),
                              onPressed: _loading ? null : _summarize,
                            ),
                            Expanded(
                              child: TextField(
                                controller: _ctrl,
                                enabled: !_loading,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _ask(_ctrl.text),
                                decoration: InputDecoration(
                                  hintText: '问问你的物品，例如：我最近买了什么？',
                                  isDense: true,
                                  fillColor: Theme.of(
                                    context,
                                  ).colorScheme.surface,
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.send_outlined),
                                    onPressed: _loading
                                        ? null
                                        : () => _ask(_ctrl.text),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              '问我任何关于物品的问题',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '总结开支 · 查找物品 · 分析消费习惯',
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unconfigured(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_outlined, size: 56),
            const SizedBox(height: 16),
            const Text(
              'AI 功能未配置',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              '配置 API 后可以总结物品开支、用自然语言查询物品',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.push('/settings/ai'),
              child: const Text('去配置'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 生成中的三点跳动动效。
class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final t = (_ctrl.value * 3 - i).clamp(0.0, 1.0);
            final bounce = (t < 0.5 ? t : 1 - t) * 2;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Transform.translate(
                offset: Offset(0, -4 * bounce),
                child: Icon(
                  Icons.circle,
                  size: 8,
                  color: color.withValues(alpha: 0.4 + 0.6 * bounce),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
