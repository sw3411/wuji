import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/image_store.dart';
import '../../app/providers.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../shared/widgets/common.dart';

/// 位置管理页：树状展示、新增、编辑、搜索。
class LocationsPage extends ConsumerStatefulWidget {
  const LocationsPage({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  ConsumerState<LocationsPage> createState() => _LocationsPageState();
}

class _LocationsPageState extends ConsumerState<LocationsPage> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final locations =
        ref.watch(locationsProvider).valueOrNull ?? const <Location>[];
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final tree = LocationTree(locations);
    final counts = <String, int>{};
    for (final item in items.where((i) => !i.isDeleted)) {
      if (item.locationId != null) {
        counts[item.locationId!] = (counts[item.locationId!] ?? 0) + 1;
      }
    }

    final rows = <_Row>[];
    void walk(List<Location> children, int depth) {
      for (final loc in children) {
        rows.add(_Row(loc, depth));
        walk(tree.childrenOf(loc.id), depth + 1);
      }
    }

    final filtered = _search.isEmpty ? locations : tree.search(_search);
    if (_search.isEmpty) {
      walk(tree.roots, 0);
    } else {
      walk(filtered, 0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('存放位置'),
        actions: [
          IconButton(
            tooltip: '盘点',
            icon: const Icon(Icons.fact_check_outlined),
            onPressed: () => context.push('/inventory'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editLocation(null),
        icon: const Icon(Icons.add),
        label: const Text('新增位置'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              decoration: const InputDecoration(
                hintText: '搜索位置',
                prefixIcon: Icon(Icons.search, size: 20),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: rows.isEmpty
                ? const EmptyView(
                    icon: Icons.folder_off_outlined,
                    title: '还没有位置',
                    subtitle: '先创建“家”、“办公室”等位置，再逐步细化',
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 88),
                    children: rows.map((r) {
                      final childCount =
                          tree.childrenOf(r.loc.id).length;
                      final itemCount = counts[r.loc.id] ?? 0;
                      return Padding(
                        padding: EdgeInsets.only(left: 18.0 * r.depth),
                        child: Card(
                          child: ListTile(
                            leading: r.loc.imagePath != null
                                ? ItemImage(r.loc.imagePath,
                                    icon: Icons.folder_outlined,
                                    size: 40,
                                    borderRadius: 8)
                                : Icon(
                                    childCount > 0
                                        ? Icons.folder_outlined
                                        : Icons.folder_open_outlined,
                                    size: 28,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                            title: Text(r.loc.name),
                            subtitle: Text(
                              '$itemCount 件物品'
                              '${childCount > 0 ? ' · $childCount 个子位置' : ''}'
                              '${r.loc.description != null && r.loc.description!.isNotEmpty ? '\n${r.loc.description}' : ''}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                            isThreeLine:
                                r.loc.description?.isNotEmpty == true,
                            trailing: PopupMenuButton<String>(
                              onSelected: (v) => _onMenu(context, v, r.loc),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                    value: 'edit', child: Text('编辑')),
                                const PopupMenuItem(
                                    value: 'addChild', child: Text('添加子位置')),
                                const PopupMenuItem(
                                    value: 'delete', child: Text('删除')),
                              ],
                            ),
                            onTap: () => context.push('/locations/${r.loc.id}'),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  void _onMenu(BuildContext context, String action, Location loc) {
    switch (action) {
      case 'edit':
        _editLocation(loc);
      case 'addChild':
        _editLocation(null, parentId: loc.id);
      case 'delete':
        _deleteLocation(loc);
    }
  }

  Future<void> _editLocation(Location? existing, {String? parentId}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String? imagePath = existing?.imagePath;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheet) => Padding(
          padding: EdgeInsets.only(
            left: 16, right: 16, top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(existing == null ? '新增位置' : '编辑位置',
                  style: Theme.of(context).textTheme.titleMedium),
              if (parentId != null) ...[
                const SizedBox(height: 4),
                Text('父位置：${LocationTree(ref.read(locationsProvider).valueOrNull ?? const []).fullPath(parentId)}',
                    style: const TextStyle(fontSize: 12)),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                autofocus: existing == null,
                decoration: const InputDecoration(labelText: '位置名称 *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: '位置说明'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () async {
                      final path = await ImageStore.pickFromGallery(
                          maxCount: 1);
                      if (path.isNotEmpty) {
                        setSheet(() => imagePath = path.first);
                      }
                    },
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                        size: 18),
                    label: Text(imagePath == null ? '设置照片' : '已设置照片'),
                  ),
                  if (imagePath != null)
                    TextButton(
                      onPressed: () => setSheet(() => imagePath = null),
                      child: const Text('移除'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('保存'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (saved != true) return;

    await ref.read(locationRepoProvider).upsert(Location(
          id: existing?.id ??
              DateTime.now().microsecondsSinceEpoch.toString(),
          name: nameCtrl.text.trim(),
          parentId: existing?.parentId ?? parentId,
          description:
              descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
          imagePath: imagePath,
          sortOrder: existing?.sortOrder ?? 0,
          createdAt: existing?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(existing == null ? '位置已创建' : '位置已更新')));
    }
  }

  Future<void> _deleteLocation(Location loc) async {
    final locations =
        ref.read(locationsProvider).valueOrNull ?? const <Location>[];
    final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
    final tree = LocationTree(locations);

    final childLocations = tree.childrenOf(loc.id);
    final childItems =
        items.where((i) => !i.isDeleted && i.locationId == loc.id).toList();

    if (childLocations.isEmpty && childItems.isEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('删除位置'),
          content: Text('确定删除「${loc.name}」？'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('取消')),
            FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('删除')),
          ],
        ),
      );
      if (ok == true) {
        await ref.read(locationRepoProvider).delete(loc.id);
      }
      return;
    }

    // 有内容：二次确认 + 迁移。
    final migrateTo = await showDialog<String>(
      context: context,
      builder: (context) => _MigrateDialog(
        loc: loc,
        childCount: childItems.length,
        subCount: childLocations.length,
        locations: locations,
        excludeId: loc.id,
      ),
    );
    if (migrateTo == null) return;

    if (migrateTo == '__delete_all__') {
      // 删除位置及其子位置，物品归为无位置。
      final ids = tree.descendantIds(loc.id);
      for (final id in ids) {
        await ref.read(locationRepoProvider).delete(id);
      }
      for (final item in childItems) {
        await ref.read(itemRepoProvider).updateItem(
            item.copyWith(clearLocation: true));
      }
    } else if (migrateTo == '__none__') {
      await ref.read(locationRepoProvider).delete(loc.id);
      for (final item in childItems) {
        await ref
            .read(itemRepoProvider)
            .updateItem(item.copyWith(clearLocation: true));
      }
      for (final child in childLocations) {
        await ref.read(locationRepoProvider).upsert(
            child.copyWith(parentId: loc.parentId, clearParent: loc.parentId == null));
      }
    } else {
      // 迁移到目标位置。
      final target =
          locations.where((l) => l.id == migrateTo).firstOrNull!;
      for (final item in childItems) {
        await ref.read(itemRepoProvider).updateItem(item.copyWith(
            locationId: target.id, locationName: target.name));
      }
      for (final child in childLocations) {
        await ref.read(locationRepoProvider).upsert(child.copyWith(parentId: target.id));
      }
      await ref.read(locationRepoProvider).delete(loc.id);
    }
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('位置已删除')));
    }
  }
}

class _Row {
  const _Row(this.loc, this.depth);

  final Location loc;
  final int depth;
}

/// 删除含内容位置时的迁移选择对话框。
class _MigrateDialog extends StatelessWidget {
  const _MigrateDialog({
    required this.loc,
    required this.childCount,
    required this.subCount,
    required this.locations,
    required this.excludeId,
  });

  final Location loc;
  final int childCount;
  final int subCount;
  final List<Location> locations;
  final String excludeId;

  @override
  Widget build(BuildContext context) {
    final tree = LocationTree(locations);
    final candidates = locations
        .where((l) => !tree.descendantIds(excludeId).contains(l.id))
        .toList();

    return AlertDialog(
      title: Text('删除「${loc.name}」'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('该位置包含 $childCount 件物品'
              '${subCount > 0 ? '、$subCount 个子位置' : ''}，'
              '删除前需要处理这些内容。'),
          const SizedBox(height: 12),
          const Text('迁移到：', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          ...candidates.map((l) => RadioListTile<String>(
                value: l.id,
                groupValue: null,
                dense: true,
                title: Text(tree.fullPath(l.id)),
                onChanged: (v) => Navigator.pop(context, v),
              )),
          RadioListTile<String>(
            value: '__none__',
            groupValue: null,
            dense: true,
            title: const Text('归为“无位置”（子位置升级为顶级）'),
            onChanged: (v) => Navigator.pop(context, v),
          ),
          RadioListTile<String>(
            value: '__delete_all__',
            groupValue: null,
            dense: true,
            title: const Text('连子位置一起删除，物品归为无位置'),
            onChanged: (v) => Navigator.pop(context, v),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消删除'),
          ),
        ],
      ),
    );
  }
}
