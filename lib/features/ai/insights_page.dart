import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/ai/ai_prompts.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/item.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/budget.dart';
import '../../domain/services/item_insights.dart';
import '../../shared/widgets/common.dart';

/// AI 消费洞察独立页：九维度卡片矩阵。
class AiInsightsPage extends ConsumerWidget {
  const AiInsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final sales =
        ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final insights = ItemInsightService.analyze(
      items.where((i) => !i.isDeleted).toList(),
      sales,
    );
    return Scaffold(
      appBar: AppBar(title: const Text('AI 消费洞察')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [AiInsightGrid(insights: insights, showHeader: false)],
      ),
    );
  }
}

/// AI 消费洞察：八维度卡片矩阵，点开面板生成/查看对应洞察。
class AiInsightGrid extends ConsumerStatefulWidget {
  const AiInsightGrid({
    super.key,
    required this.insights,
    this.showHeader = true,
  });

  final ItemInsights insights;

  /// 是否显示区块标题（独立页可不显示）。
  final bool showHeader;

  @override
  ConsumerState<AiInsightGrid> createState() => AiInsightGridState();
}

class AiInsightGridState extends ConsumerState<AiInsightGrid> {
  /// 各维度缓存：id → (文本, 生成时间)。
  final Map<String, String> _texts = {};
  final Map<String, DateTime> _times = {};
  bool _loading = false;

  static const Map<String, IconData> _icons = {
    'profile': Icons.person_outline,
    'style': Icons.palette_outlined,
    'impulse': Icons.local_fire_department_outlined,
    'idle': Icons.pause_circle_outline,
    'optimize': Icons.savings_outlined,
    'retention': Icons.trending_up_outlined,
    'warranty': Icons.shield_outlined,
    'trend': Icons.show_chart_outlined,
  };

  String _key(String id) => 'ai_insight_v2_$id';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final repo = ref.read(settingsRepoProvider);
    for (final d in kInsightDimensions) {
      final json = await repo.getJson(_key(d.id));
      if (json != null && mounted) {
        setState(() {
          _texts[d.id] = json['text'] as String? ?? '';
          final at = json['at'] as String?;
          final time = at == null ? null : DateTime.tryParse(at);
          if (time != null) _times[d.id] = time;
        });
      }
    }
  }

  Future<void> _save(String id, String text) async {
    await ref.read(settingsRepoProvider).setJson(_key(id), {
      'text': text,
      'at': DateTime.now().toIso8601String(),
    });
  }

  String _stripMd(String src) => src
      .replaceAll('**', '')
      .replaceAll('*', '')
      .replaceAll(RegExp(r'^#+\s*', multiLine: true), '');

  Future<void> _generate(String id, StateSetter setSheet) async {
    final config = ref.read(aiConfigProvider);
    if (!config.isReady) {
      final go = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('AI 未配置'),
          content: const Text('填写 API 信息后即可生成洞察。数据只会发送到你配置的服务商。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('去配置'),
            ),
          ],
        ),
      );
      if (go == true && mounted) context.push('/settings/ai');
      return;
    }
    setState(() => _loading = true);
    setSheet(() {});
    try {
      final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
      final sales =
          ref.read(salesMapProvider).valueOrNull ??
          const <String, SaleRecord>{};
      // 月度预算进度（未设置为 null）。
      final now = DateTime.now();
      final monthSpend = items
          .where(
            (i) =>
                !i.isDeleted &&
                !i.purchaseDate.isBefore(DateTime(now.year, now.month)),
          )
          .fold<int>(0, (sum, i) => sum + i.purchasePrice);
      final budget = BudgetStatus.evaluate(
        monthSpend,
        ref.read(appSettingsProvider).monthlyBudgetCents,
      );
      final text = await ref
          .read(aiServiceProvider)
          .insightByDimension(
            id,
            items,
            sales,
            widget.insights,
            budget: budget,
          );
      await _save(id, text);
      if (mounted) {
        setState(() {
          _texts[id] = text;
          _times[id] = DateTime.now();
          _loading = false;
        });
        setSheet(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        setSheet(() {});
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('生成失败：$e')));
      }
    }
  }

  Future<void> _openSheet(InsightDimension dim) async {
    await showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheet) {
          final cs = Theme.of(sheetContext).colorScheme;
          final text = _texts[dim.id];
          final time = _times[dim.id];
          return SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  child: Row(
                    children: [
                      Icon(
                        _icons[dim.id],
                        size: 20,
                        color: AppTheme.greenLight,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI 洞察 · ${dim.title}',
                          style: AppTheme.cardTitle(cs.onSurface),
                        ),
                      ),
                      if (time != null)
                        Text(
                          '${time.month}月${time.day}日 ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                          style: AppTheme.caption(cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : text == null
                        ? Text(
                            '点击下方按钮，基于你的真实物品数据生成「${dim.title}」洞察。',
                            style: AppTheme.caption(cs.onSurfaceVariant),
                          )
                        : MarkdownBody(
                            data: text,
                            styleSheet: digestMarkdownStyle(sheetContext),
                          ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                    child: SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _loading
                            ? null
                            : () => _generate(dim.id, setSheet),
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: Text(text == null ? '生成洞察' : '重新生成'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showHeader)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
            child: Text(
              'AI 消费洞察',
              style: AppTheme.label(
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.6,
          children: [
            for (final d in kInsightDimensions)
              Card(
                child: InkWell(
                  onTap: () => _openSheet(d),
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _icons[d.id],
                              size: 18,
                              color: _texts[d.id] == null
                                  ? AppTheme.greenLight
                                  : AppTheme.green,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                d.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (_texts[d.id] != null)
                              const Icon(
                                Icons.check_circle_outline,
                                size: 14,
                                color: AppTheme.green,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _texts[d.id] == null
                              ? '点击生成'
                              : Fmt.ellipsis(
                                  _stripMd(_texts[d.id]!).replaceAll('\n', ' '),
                                  24,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.caption(cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
