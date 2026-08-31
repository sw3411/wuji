import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/image_store.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/item_calculator.dart';
import '../../domain/models/item_event.dart';
import '../items/sale_form_sheet.dart';
import '../../shared/widgets/common.dart';

/// 盘点模式：按范围逐件核对物品“还在吗”，顺手处置丢失/丢弃/送人的物品。
class InventoryCheckPage extends ConsumerStatefulWidget {
  const InventoryCheckPage({super.key});

  @override
  ConsumerState<InventoryCheckPage> createState() => _InventoryCheckPageState();
}

class _InventoryCheckPageState extends ConsumerState<InventoryCheckPage> {
  /// 盘点范围名称（标题展示用）。
  String _scopeName = '全部物品';

  List<Item>? _queue;
  int _index = 0;
  int _kept = 0;
  int _disposed = 0;
  final _dispositions = <String, ItemStatus>{};

  bool get _finished => _queue != null && _index >= _queue!.length;

  void _start(String? scopeId, String scopeName) {
    final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
    final locations =
        ref.read(locationsProvider).valueOrNull ?? const <Location>[];
    var list = items.where((i) => !i.isDeleted && i.status.isOwned).toList();
    if (scopeId == '@unassigned') {
      list = list.where((i) => i.locationId == null).toList();
    } else if (scopeId != null) {
      final tree = LocationTree(locations);
      final ids = tree.descendantIds(scopeId);
      list = list.where((i) => ids.contains(i.locationId)).toList();
    }
    setState(() {
      _scopeName = scopeName;
      _queue = list;
      _index = 0;
      _kept = 0;
      _disposed = 0;
      _dispositions.clear();
    });
  }

  Future<void> _confirmKeep() async {
    setState(() {
      _kept++;
      _index++;
    });
  }

  Future<void> _dispose() async {
    final item = _queue![_index];
    final status = await showModalBottomSheet<ItemStatus>(
      useRootNavigator: true,
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                '「${item.name}」现在……',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            for (final s in [
              ItemStatus.discarded,
              ItemStatus.lost,
              ItemStatus.gifted,
              ItemStatus.consumed,
              ItemStatus.sold,
            ])
              ListTile(
                leading: Icon(switch (s) {
                  ItemStatus.discarded => Icons.delete_outline,
                  ItemStatus.lost => Icons.help_outline,
                  ItemStatus.gifted => Icons.card_giftcard,
                  ItemStatus.sold => Icons.currency_exchange,
                  _ => Icons.local_fire_department_outlined,
                }),
                title: Text(s.label),
                subtitle: s == ItemStatus.sold
                    ? const Text('需填写金额与日期',
                        style: TextStyle(fontSize: 11))
                    : null,
                onTap: () => Navigator.pop(context, s),
              ),
          ],
        ),
      ),
    );
    if (status == null || !mounted) return;

    final repo = ref.read(itemRepoProvider);
    final now = DateTime.now();

    // 转卖：走完整转卖表单（金额/日期/平台），取消则停留当前物品。
    if (status == ItemStatus.sold) {
      final sale = await showSaleFormSheet(context, itemId: item.id);
      if (sale == null) return;
      if (!mounted) return;
      await ref.read(saleRepoProvider).upsert(sale);
      await repo.updateItem(item.copyWith(status: ItemStatus.sold));
      await repo.addEvent(ItemEvent(
        id: '',
        itemId: item.id,
        eventType: ItemEventType.sold,
        eventDate: sale.saleDate,
        title: '盘点时转卖给${sale.platform ?? '他人'}',
        amount: sale.salePrice,
        createdAt: now,
        updatedAt: now,
      ));
    } else {
      // 其余处置：改状态 + 按事件类型落一条生命周期事件。
      await repo.updateItem(item.copyWith(status: status));
      final type = switch (status) {
        ItemStatus.discarded => ItemEventType.discarded,
        ItemStatus.lost => ItemEventType.lost,
        ItemStatus.gifted => ItemEventType.gifted,
        _ => ItemEventType.custom,
      };
      await repo.addEvent(ItemEvent(
        id: '',
        itemId: item.id,
        eventType: type,
        eventDate: now,
        title: '盘点确认：${status.label}',
        createdAt: now,
        updatedAt: now,
      ));
    }

    setState(() {
      _disposed++;
      _dispositions[item.id] = status;
      _index++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: _queue == null || _finished,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final quit = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('结束盘点？'),
            content: Text(
              '已核对 $_index 件（确认 $_kept、处置 $_disposed），'
              '退出后本次进度不会保存。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('继续盘点'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('结束'),
              ),
            ],
          ),
        );
        if (quit == true && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('盘点')),
        body: _queue == null
            ? _scopePicker(context)
            : _finished
            ? _summary(context)
            : _checkView(context, cs),
      ),
    );
  }

  /// 第一步：选择盘点范围。
  Widget _scopePicker(BuildContext context) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final locations =
        ref.watch(locationsProvider).valueOrNull ?? const <Location>[];
    final owned = items.where((i) => !i.isDeleted && i.status.isOwned).toList();

    final counts = <String, int>{};
    for (final i in owned) {
      if (i.locationId != null) {
        counts[i.locationId!] = (counts[i.locationId!] ?? 0) + 1;
      }
    }
    final unassigned = owned.where((i) => i.locationId == null).length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          '选择盘点范围',
          style: AppTheme.cardTitle(Theme.of(context).colorScheme.onSurface),
        ),
        const SizedBox(height: 4),
        Text(
          '逐件确认物品是否还在，顺手处置已丢失 / 丢弃 / 送人的物品。',
          style: AppTheme.caption(
            Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: Icon(
              Icons.all_inbox_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: const Text('全部持有物品'),
            subtitle: Text(
              '${owned.length} 件待核对',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _start(null, '全部物品'),
          ),
        ),
        for (final loc in locations)
          if ((counts[loc.id] ?? 0) > 0)
            Card(
              margin: const EdgeInsets.only(top: 8),
              child: ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: Text(loc.name),
                subtitle: Text(
                  '${counts[loc.id]} 件待核对',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _start(loc.id, loc.name),
              ),
            ),
        if (unassigned > 0)
          Card(
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              leading: const Icon(Icons.question_mark_outlined),
              title: const Text('未设位置的物品'),
              subtitle: Text(
                '$unassigned 件待核对',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _start('@unassigned', '未设位置'),
            ),
          ),
      ],
    );
  }

  /// 第二步：逐件核对。
  Widget _checkView(BuildContext context, ColorScheme cs) {
    final queue = _queue!;
    final sales =
        ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final item = queue[_index];
    final total = queue.length;
    return Column(
      children: [
        // 进度头
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    '$_scopeName · ${_index + 1}/$total',
                    style: AppTheme.cardTitle(cs.onSurface),
                  ),
                  const Spacer(),
                  Text(
                    '确认 $_kept · 处置 $_disposed',
                    style: AppTheme.caption(cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: (_index) / total,
                minHeight: 4,
                backgroundColor: cs.surfaceContainerHighest,
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: ItemImage(
                                item.coverImagePath,
                                icon: Icons.inventory_2_outlined,
                                size: 150,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.cardTitle(
                                cs.onSurface,
                              ).copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                StatusChip(item.status),
                                PillChip(
                                  item.categoryName,
                                  icon: Icons.category_outlined,
                                ),
                                PillChip(
                                  item.locationName ?? '未设位置',
                                  icon: Icons.folder_outlined,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '购买于 ${Fmt.date(item.purchaseDate)} · '
                              '${Money.formatCompact(item.purchasePrice)} · '
                              '持有 ${ItemCalculator.usedDays(item, sales[item.id])} 天',
                              style: AppTheme.caption(cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => setState(() => _index++),
                      child: const Text('跳过'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _dispose,
                        icon: const Icon(Icons.outbox_outlined, size: 18),
                        label: const Text('不在了'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _confirmKeep,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('还在'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 第三步：盘点总结。
  Widget _summary(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final skipped = _queue!.length - _kept - _disposed;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 52, color: cs.primary),
            const SizedBox(height: 16),
            Text('盘点完成', style: AppTheme.display(cs.onSurface, size: 26)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _sumTile(cs, '$_kept', '确认还在', cs.primary),
                const SizedBox(width: 12),
                _sumTile(cs, '$_disposed', '已处置', AppTheme.warnRed),
                if (skipped > 0) ...[
                  const SizedBox(width: 12),
                  _sumTile(cs, '$skipped', '跳过', cs.onSurfaceVariant),
                ],
              ],
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => context.pop(),
              child: const Text('完成'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sumTile(ColorScheme cs, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(value, style: AppTheme.bigNumber(color, size: 26)),
          const SizedBox(height: 2),
          Text(label, style: AppTheme.caption(cs.onSurfaceVariant)),
        ],
      ),
    );
  }
}
