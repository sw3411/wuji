import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../domain/models/sale_record.dart';
import '../../shared/widgets/common.dart';
import '../items/item_card.dart';

/// 位置详情页。
class LocationDetailPage extends ConsumerWidget {
  const LocationDetailPage(this.locationId, {super.key});

  final String locationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locations =
        ref.watch(locationsProvider).valueOrNull ?? const <Location>[];
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final sales =
        ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};

    final loc = locations.where((l) => l.id == locationId).firstOrNull;
    if (loc == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(icon: Icons.folder_off_outlined, title: '位置不存在'),
      );
    }

    final tree = LocationTree(locations);
    final scope = tree.descendantIds(loc.id);
    final here = items
        .where((i) => !i.isDeleted && i.locationId == locationId)
        .toList();
    final children = tree.childrenOf(loc.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: loc.imagePath != null ? 200 : 120,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loc.name),
              background: loc.imagePath != null
                  ? Image.file(
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      File(loc.imagePath!),
                    )
                  : Container(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.4),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place_outlined, size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  tree.fullPath(loc.parentId).isEmpty
                                      ? '顶级位置'
                                      : tree.fullPath(loc.id),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (loc.description != null &&
                              loc.description!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              loc.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          Text(
                            '此处存放 ${here.length} 件物品'
                            '${children.isNotEmpty ? ' · ${children.length} 个子位置' : ''}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.push('/item/new', extra: loc.id),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('新增物品到此位置'),
                        ),
                      ),
                    ],
                  ),
                  if (children.isNotEmpty) ...[
                    SectionTitle('子位置'),
                    ...children.map((c) {
                      final cnt = items
                          .where(
                            (i) =>
                                !i.isDeleted &&
                                i.locationId != null &&
                                scope.contains(i.locationId) &&
                                tree.descendantIds(c.id).contains(i.locationId),
                          )
                          .length;
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.folder_outlined),
                          title: Text(c.name),
                          trailing: Text(
                            '$cnt 件',
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => context.push('/locations/${c.id}'),
                        ),
                      );
                    }),
                  ],
                  SectionTitle('存放的物品（${here.length}）'),
                  ...here.map(
                    (i) => ItemCard(
                      item: i,
                      sale: sales[i.id],
                      currency: i.currency,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
          // 悬浮底导避让。,
          const SliverToBoxAdapter(
            child: SizedBox(height: 110),
          ),
        ],
      ),
    );
  }
}
