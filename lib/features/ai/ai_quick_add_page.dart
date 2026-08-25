import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../app/providers.dart';
import '../../core/ai/ai_service.dart';
import 'package:collection/collection.dart';

import '../../domain/models/category.dart';
import '../../domain/models/location.dart';
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
  AiItemDraft? _draft;

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
      _draft = null;
    });
    try {
      final categories =
          ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
      final draft = await ref
          .read(aiServiceProvider)
          .parseItem(text, categories, imageBase64: _photoBase64);
      setState(() => _draft = draft);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('解析失败：$e')));
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
      _draft = null;
    });
  }

  Future<void> _choosePhotoSource() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('拍照识别'),
              subtitle: const Text('对准物品拍一张，AI 自动识别名称和品牌',
                  style: TextStyle(fontSize: 12)),
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
                          backgroundColor:
                              Colors.black.withValues(alpha: 0.55),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.close,
                                size: 16, color: Colors.white),
                            onPressed: () => setState(() {
                              _photoPath = null;
                              _photoBase64 = null;
                              _draft = null;
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
                    hintText: '用一句话描述物品，例如：昨天在京东花 5999 买了个 iPhone 15，放在卧室抽屉',
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.photo_camera_outlined, size: 16),
                      label: const Text('拍照识别',
                          style: TextStyle(fontSize: 12)),
                      onPressed: _choosePhotoSource,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: _examples
                            .map((e) => ActionChip(
                                  label: Text(Fmt3.ellipsis(e, 14)),
                                  onPressed: () {
                                    _ctrl.text = e;
                                    _parse();
                                  },
                                ))
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
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome),
                  label: Text(_photoBase64 != null ? '识别照片并解析' : '解析'),
                ),
                if (_draft != null) ...[
                  const SizedBox(height: 16),
                  Text('AI 已识别以下信息，确认后保存',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DupWarningCard(
                    name: _draft!.name ?? '',
                    brand: _draft!.brand,
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          _kv('名称', _draft!.name),
                          _kv('分类', _draft!.categoryName),
                          _kv('价格', _draft!.price == null
                              ? null
                              : '${_draft!.price} 元'),
                          _kv('购买日期', _draft!.purchaseDate == null
                              ? null
                              : '${_draft!.purchaseDate!.year}-${_draft!.purchaseDate!.month}-${_draft!.purchaseDate!.day}'),
                          _kv('渠道', _draft!.channel),
                          _kv('品牌', _draft!.brand),
                          _kv('数量', _draft!.quantity?.toString()),
                          _kv('位置', _draft!.locationText),
                          _kv('保修', _draft!.warrantyMonths == null
                              ? null
                              : '${_draft!.warrantyMonths} 个月'),
                          if (_draft!.tags.isNotEmpty)
                            _kv('标签', _draft!.tags.join('、')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _draft = null),
                          child: const Text('重新解析'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _save,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('去确认保存'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }

  /// 跳转到表单页，通过草稿机制预填全部字段。
  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    final location = await _resolveLocation(draft.locationText);
    await ref.read(settingsRepoProvider).setJson('draft_item', {
      'source': 'ai',
      'name': draft.name ?? '',
      'price': draft.price == null ? '' : draft.price!.toStringAsFixed(2),
      'categoryId': _matchCategoryId(draft.categoryName),
      'channel': draft.channel,
      'brand': draft.brand ?? '',
      'model': draft.model ?? '',
      'quantity': draft.quantity ?? 1,
      'merchantName': draft.merchantName ?? '',
      'orderNumber': draft.orderNumber ?? '',
      'notes': draft.notes ?? '',
      'tags': draft.tags,
      'warrantyMonths': draft.warrantyMonths,
      'locationId': location?.id,
      'locationName': location?.name,
      'purchaseDate':
          (draft.purchaseDate ?? DateTime.now()).toIso8601String(),
    });
    if (mounted) context.push('/item/new');
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

  String? _matchCategoryId(String? categoryName) {
    if (categoryName == null) return null;
    final categories =
        ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
    for (final c in categories) {
      if (c.name == categoryName ||
          c.name.contains(categoryName) ||
          categoryName.contains(c.name)) {
        return c.id;
      }
    }
    return null;
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
            const Text('AI 功能未配置',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(
              '填写 API 信息后，即可用一句话快速添加物品',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
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
            child: Text(label,
                style: const TextStyle(fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
              child: Text(value, style: const TextStyle(fontSize: 14))),
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
