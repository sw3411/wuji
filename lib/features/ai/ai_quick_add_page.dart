import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/ai/ai_service.dart';
import 'package:collection/collection.dart';

import '../../domain/models/category.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item_event.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/dup_warning.dart';

/// AI 一句话添加物品：解析 → 表单确认 → 保存。
class AiQuickAddPage extends ConsumerStatefulWidget {
  const AiQuickAddPage({super.key});

  @override
  ConsumerState<AiQuickAddPage> createState() => _AiQuickAddPageState();
}

class _AiQuickAddPageState extends ConsumerState<AiQuickAddPage> {
  final _ctrl = TextEditingController();
  bool _loading = false;
  List<AiItemDraft> _drafts = [];
  bool _saving = false;

  /// 拍照识别：选中照片的路径与 base64（传给多模态接口）。
  String? _photoPath;
  String? _photoBase64;

  static const _examples = [
    '昨天在京东花 5999 买了个 iPhone 15，放在卧室抽屉',
    '上个月淘宝买的戴森吹风机 2990 元，保修两年',
    '朋友送的乐高积木，放客厅电视柜',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _parse() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty && _photoBase64 == null) return;
    setState(() {
      _loading = true;
      _drafts = [];
    });
    try {
      final categories =
          ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
      final drafts = await ref
          .read(aiServiceProvider)
          .parseItems(text, categories, imageBase64: _photoBase64);
      setState(() => _drafts = drafts);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('解析失败：$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 选照片（拍照 / 相册），压缩到 1024px、质量 80，转 base64 供视觉接口使用。
  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    if (!mounted) return;
    setState(() {
      _photoPath = picked.path;
      _photoBase64 = base64Encode(bytes);
      _drafts = [];
    });
  }

  Future<void> _choosePhotoSource() async {
    await showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍照识别'),
              subtitle: const Text(
                '对准物品拍一张，AI 自动识别名称和品牌',
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(aiConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('AI 一句话添加')),
      body: !config.isReady
          ? _unconfigured(context)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_photoPath != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(_photoPath!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 6,
                        top: 6,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.black.withValues(alpha: 0.55),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                            onPressed: () => setState(() {
                              _photoPath = null;
                              _photoBase64 = null;
                              _drafts = [];
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
                TextField(
                  controller: _ctrl,
                  maxLines: 3,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _parse(),
                  decoration: const InputDecoration(
                    hintText: '一句话描述，支持多件：风衣8999、短袖399、羽绒服2万',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.photo_camera_outlined, size: 16),
                      label: const Text('拍照识别', style: TextStyle(fontSize: 12)),
                      onPressed: _choosePhotoSource,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: _examples
                            .map(
                              (e) => ActionChip(
                                label: Text(Fmt3.ellipsis(e, 14)),
                                onPressed: () {
                                  _ctrl.text = e;
                                  _parse();
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loading ? null : _parse,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(_photoBase64 != null ? '识别照片并解析' : '解析'),
                ),
                if (_drafts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    _drafts.length == 1
                        ? 'AI 已识别以下信息，确认后保存'
                        : 'AI 识别出 ${_drafts.length} 件物品',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final d in _drafts.take(8)) ...[
                    if (d.name != null)
                      DupWarningCard(name: d.name!, brand: d.brand),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            _kv('名称', d.name),
                            _kv('分类', d.categoryName),
                            _kv(
                              '价格',
                              d.price == null ? null : '${d.price} 元',
                            ),
                            _kv(
                              '购买日期',
                              d.purchaseDate == null
                                  ? null
                                  : '${d.purchaseDate!.year}-${d.purchaseDate!.month}-${d.purchaseDate!.day}',
                            ),
                            _kv('渠道', d.channel),
                            _kv('品牌', d.brand),
                            _kv('数量', d.quantity?.toString()),
                            _kv('位置', d.locationText),
                            _kv(
                              '保修',
                              d.warrantyMonths == null
                                  ? null
                                  : '${d.warrantyMonths} 个月',
                            ),
                            if (d.tags.isNotEmpty)
                              _kv('标签', d.tags.join('、')),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _drafts = []),
                          child: const Text('重新解析'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _saving ? null : _saveAll,
                          icon: _saving
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2))
                              : const Icon(Icons.save_outlined),
                          label: Text(_drafts.length == 1
                              ? '保存'
                              : '一键保存 ${_drafts.length} 件'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  /// 逐件落库：物品 + 购买事件 + 位置解析 + 保修提醒。
  Future<void> _saveAll() async {
    if (_saving || _drafts.isEmpty) return;
    setState(() => _saving = true);
    final repo = ref.read(itemRepoProvider);
    final categories =
        ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
    final settings = ref.read(appSettingsProvider);
    var saved = 0;
    try {
      for (final d in _drafts) {
        final name = d.name?.trim();
        if (name == null || name.isEmpty) continue;
        final now = DateTime.now();
        var category = _matchCategory(d.categoryName, categories);
        category ??= categories.isNotEmpty ? categories.first : null;
        final location = await _resolveLocation(d.locationText);
        final item = Item(
          id: '${now.microsecondsSinceEpoch}${saved.toString().padLeft(3, '0')}',
          name: name,
          categoryId: category!.id,
          categoryName: category.name,
          purchasePrice: ((d.price ?? 0) * 100).round(),
          currency: settings.currency,
          purchaseDate: d.purchaseDate ?? now,
          purchaseChannel: d.channel,
          brand: d.brand,
          model: d.model,
          quantity: d.quantity ?? 1,
          status: ItemStatus.inUse,
          locationId: location?.id,
          locationName: location?.name,
          merchantName: d.merchantName,
          orderNumber: d.orderNumber,
          notes: d.notes,
          tags: d.tags,
          warrantyMonths: d.warrantyMonths,
          createdAt: now,
          updatedAt: now,
        );
        await repo.upsert(item);
        await repo.addEvent(ItemEvent(
          id: '',
          itemId: item.id,
          eventType: ItemEventType.purchased,
          eventDate: item.purchaseDate,
          title: '购买「${item.name}」',
          amount: item.purchasePrice,
          createdAt: now,
          updatedAt: now,
        ));
        if (item.warrantyMonths != null) {
          unawaited(NotificationService.syncItemReminder(item,
              enabled: settings.warrantyReminderEnabled,
              daysBefore: settings.warrantyReminderDays));
        }
        saved++;
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
    if (!mounted) return;
    if (saved > 0) {
      showAutoToast(context, '已保存 $saved 件物品');
      setState(() => _drafts = []);
      _ctrl.clear();
      ref.invalidate(itemsProvider);
    }
  }

  Category? _matchCategory(
      String? categoryName, List<Category> categories) {
    if (categoryName == null) return null;
    for (final c in categories) {
      if (c.name == categoryName || c.name.contains(categoryName) || categoryName.contains(c.name)) {
        return c;
      }
    }
    return null;
  }


  /// 位置路径解析：逐级匹配已有位置，缺失的层级自动创建。
  /// 例如“家/卧室/衣柜”→ 若无则依次创建三个层级，返回最深层。
  Future<Location?> _resolveLocation(String? locationText) async {
    if (locationText == null || locationText.trim().isEmpty) return null;
    final segments = AiItemDraft.splitLocationPath(locationText);
    if (segments.isEmpty) return null;

    final repo = ref.read(locationRepoProvider);
    String? parentId;
    Location? current;
    for (final segment in segments) {
      final existing = await repo.getAll();
      final match = existing
          .where((l) => l.name == segment && l.parentId == parentId)
          .firstOrNull;
      if (match != null) {
        current = match;
        parentId = match.id;
      } else {
        final created = Location(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: segment,
          parentId: parentId,
          sortOrder: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repo.upsert(created);
        current = created;
        parentId = created.id;
      }
    }
    return current;
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
            Text(
              '填写 API 信息后，即可用一句话快速添加物品',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
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

  Widget _kv(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 68,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}

class Fmt3 {
  Fmt3._();

  static String ellipsis(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}…';
}
