import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/image_store.dart';
import '../../app/providers.dart';
import '../../core/constants/default_categories.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/item.dart';
import '../../shared/widgets/common.dart';

/// 回收站。软删除物品默认保留 30 天。
class TrashPage extends ConsumerStatefulWidget {
  const TrashPage({super.key});

  @override
  ConsumerState<TrashPage> createState() => _TrashPageState();
}

class _TrashPageState extends ConsumerState<TrashPage> {
  static const retainDays = 30;

  Future<List<Item>>? _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(itemRepoProvider).getDeleted();
  }

  void _reload() {
    setState(() {
      _future = ref.read(itemRepoProvider).getDeleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('回收站'),
        actions: [
          TextButton(
            onPressed: () => _empty(context),
            child: const Text('清空'),
          ),
        ],
      ),
      body: FutureBuilder<List<Item>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return loadingView;
          final items = snap.data ?? const <Item>[];
          if (items.isEmpty) {
            return const EmptyView(
              icon: Icons.delete_outline,
              title: '回收站是空的',
              subtitle: '删除的物品会在这里保留 $retainDays 天',
            );
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: items.map((item) {
              final leftDays = retainDays -
                  DateTime.now().difference(item.deletedAt!).inDays;
              return Card(
                child: ListTile(
                  leading: ItemImage(
                    item.coverImagePath,
                    icon: CategoryIcons.of('category'),
                    size: 46,
                    borderRadius: 8,
                  ),
                  title: Text(item.name),
                  subtitle: Text(
                    '${Fmt.date(item.purchaseDate)} 购买 · 删除于 ${Fmt.date(item.deletedAt!)}'
                    '${leftDays > 0 ? ' · 约 $leftDays 天后自动清除' : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  isThreeLine: false,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: '恢复',
                        icon: const Icon(Icons.restore, size: 20),
                        onPressed: () async {
                          await ref.read(itemRepoProvider).restore(item.id);
                          _reload();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('已恢复')));
                          }
                        },
                      ),
                      IconButton(
                        tooltip: '永久删除',
                        icon: Icon(Icons.delete_forever,
                            size: 20, color: Theme.of(context).colorScheme.error),
                        onPressed: () => _hardDelete(context, item.id),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<void> _hardDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('永久删除'),
        content: const Text('永久删除后无法恢复，确定继续？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('永久删除')),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(itemRepoProvider).hardDelete(id);
    unawaited(NotificationService.cancelItemNotifications(id));
    _reload();
  }

  Future<void> _empty(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清空回收站'),
        content: const Text('将永久删除回收站中的所有物品，无法恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('清空')),
        ],
      ),
    );
    if (ok != true) return;
    final repo = ref.read(itemRepoProvider);
    final deleted = await repo.getDeleted();
    for (final item in deleted) {
      await repo.hardDelete(item.id);
      unawaited(NotificationService.cancelItemNotifications(item.id));
    }
    _reload();
  }
}
