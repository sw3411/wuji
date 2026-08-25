import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/image_store.dart';
import '../../app/providers.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/models/location.dart';

/// 位置选择底部弹窗。返回选中的 Location；选择“无位置”返回 null。
Future<Location?> showLocationPickerSheet(BuildContext context) {
  return showModalBottomSheet<Location>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _LocationPickerSheet(),
  );
}

class _LocationPickerSheet extends ConsumerWidget {
  const _LocationPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations =
        ref.watch(locationsProvider).valueOrNull ?? const <Location>[];
    final tree = LocationTree(locations);
    final rows = <_Row>[];

    void walk(List<Location> children, int depth) {
      for (final loc in children) {
        rows.add(_Row(loc, depth));
        walk(tree.childrenOf(loc.id), depth + 1);
      }
    }

    walk(tree.roots, 0);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('选择存放位置',
                    style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                ListTile(
                  leading: Icon(Icons.add_location_alt_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text('新建位置',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('例如：家 / 卧室 / 衣柜',
                      style: const TextStyle(fontSize: 11)),
                  onTap: () => _createLocation(context, ref),
                ),
                ListTile(
                  leading: const Icon(Icons.block_outlined),
                  title: const Text('不设置位置'),
                  onTap: () => Navigator.pop(context),
                ),
                ...rows.map((r) => Padding(
                      padding: EdgeInsets.only(left: 16.0 * r.depth),
                      child: ListTile(
                        leading: r.loc.imagePath != null
                            ? ItemImage(r.loc.imagePath,
                                icon: Icons.folder_outlined,
                                size: 36,
                                borderRadius: 8)
                            : const Icon(Icons.folder_outlined),
                        title: Text(r.loc.name),
                        subtitle: r.depth > 0
                            ? Text(tree.fullPath(r.loc.parentId),
                                style: const TextStyle(fontSize: 11))
                            : null,
                        onTap: () => Navigator.pop(context, r.loc),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Row {
  const _Row(this.loc, this.depth);

  final Location loc;
  final int depth;
}


/// 就地新建位置并直接选中返回。
Future<void> _createLocation(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新建位置'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '位置名称，例如：卧室'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('创建')),
        ],
      ),
    );
    if (confirmed != true || ctrl.text.trim().isEmpty) return;
    final loc = Location(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: ctrl.text.trim(),
      sortOrder: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await ref.read(locationRepoProvider).upsert(loc);
    if (context.mounted) Navigator.pop(context, loc);
}
