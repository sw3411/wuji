import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/image_store.dart';
import '../../app/theme.dart';
import '../../app/providers.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_event.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/item_calculator.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/radar_view.dart';
import '../locations/location_picker_sheet.dart';
import 'event_form_sheet.dart';
import 'sale_form_sheet.dart';

/// 物品详情页。
class ItemDetailPage extends ConsumerWidget {
  const ItemDetailPage(this.itemId, {super.key});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(itemsProvider).valueOrNull;
    final sales = ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final locationsAsync =
        ref.watch(locationsProvider).valueOrNull ?? const [];
    final eventsAsync = ref.watch(itemEventsProvider(itemId));

    final item = itemAsync?.where((i) => i.id == itemId).firstOrNull;
    if (item == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const EmptyView(icon: Icons.search_off, title: '物品不存在'),
      );
    }

    final sale = sales[itemId];
    final tree = LocationTree(locationsAsync);
    final events = eventsAsync.valueOrNull ?? const <ItemEvent>[];
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: ItemImage(
                item.coverImagePath,
                icon: Icons.inventory_2_outlined,
                size: double.infinity,
              ),
            ),
            actions: [
              IconButton(
                tooltip: item.isFavorite ? '取消收藏' : '收藏',
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite ? Colors.redAccent : null,
                ),
                onPressed: () =>
                    ref.read(itemRepoProvider).toggleFavorite(item.id),
              ),
              PopupMenuButton<String>(
                onSelected: (v) => _onMenu(context, ref, v, item, sale),
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('编辑')),
                  const PopupMenuItem(value: 'move', child: Text('移动位置')),
                  const PopupMenuItem(value: 'event', child: Text('添加事件')),
                  const PopupMenuItem(value: 'delete', child: Text('删除')),
                ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题行
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      StatusChip(item.status),
                      PillChip(item.categoryName, icon: Icons.category_outlined),
                      if (item.quantity > 1)
                        PillChip('数量 ${item.quantity}'),
                      if (item.usageFrequency != null)
                        PillChip(item.usageFrequency!.label,
                            icon: Icons.speed_outlined),
                      ...(item.aiTags ?? const <String>[])
                          .take(8)
                          .map((t) => PillChip(
                                t,
                                color: cs.onSurfaceVariant,
                              )),
                      ...item.tags.map((t) => PillChip('#$t')),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 核心数据卡片：价格为主视觉，次级指标大数字分层。
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    Money.formatCompact(item.purchasePrice,
                                        currency: item.currency),
                                    style: AppTheme.bigNumber(cs.onSurface,
                                        size: 30),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 3),
                                child: Text(
                                  '购买于 ${Fmt.date(item.purchaseDate)}'
                                  '${item.quantity > 1 ? ' · ${item.quantity} 件' : ''}',
                                  style: TextStyle(
                                      fontSize: 12, color: cs.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          _dailyLine(context, item, sale),
                          const Divider(height: 22),
                          Row(
                            children: [
                              Expanded(
                                child: _metric(
                                  context,
                                  '持有时间',
                                  '${ItemCalculator.usedDays(item, sale)} 天',
                                ),
                              ),
                              Expanded(
                                child: _metric(
                                  context,
                                  item.status == ItemStatus.sold ? '转卖后日均' : '当前日均',
                                  ItemCalculator.dailyCost(item, sale) < 0
                                      ? Money.formatCompact(
                                          ItemCalculator.dailyCost(item, sale).abs(),
                                          currency: item.currency)
                                      : Money.formatDaily(
                                          ItemCalculator.dailyCost(item, sale), 1,
                                          currency: item.currency),
                                  color: ItemCalculator.dailyCost(item, sale) < 0
                                      ? const Color(0xFF6B8F87)
                                      : null,
                                  income: ItemCalculator.dailyCost(item, sale) < 0,
                                ),
                              ),
                              if (item.status == ItemStatus.sold && sale != null)
                                Expanded(
                                  child: _metric(
                                    context,
                                    '保值率',
                                    _retentionText(
                                        ItemCalculator.retentionRate(item, sale)),
                                  ),
                                ),
                            ],
                          ),
                          if (item.status == ItemStatus.sold && sale != null) ...[
                            const Divider(height: 22),
                            Row(
                              children: [
                                Expanded(
                                  child: _metric(
                                    context,
                                    '转卖净收入',
                                    Money.formatCompact(sale.netIncome,
                                        currency: item.currency),
                                    color: cs.primary,
                                  ),
                                ),
                                Expanded(
                                  child: _metric(
                                    context,
                                    '实际损耗',
                                    Money.formatCompact(
                                        ItemCalculator.actualDepreciation(
                                            item, sale),
                                        currency: item.currency),
                                    color: ItemCalculator.actualDepreciation(
                                                item, sale) <
                                            0
                                        ? const Color(0xFF6B8F87)
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          if (item.warrantyMonths != null ||
                              item.warrantyEndDate != null) ...[
                            const Divider(height: 20),
                            Builder(builder: (context) {
                              final state =
                                  ItemCalculator.warrantyState(item);
                              final end = item.effectiveWarrantyEndDate!;
                              final color = switch (state) {
                                WarrantyState.expired => cs.error,
                                WarrantyState.expiringSoon => const Color(0xFFE65100),
                                _ => cs.primary,
                              };
                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '保修至 ${Fmt.date(end)}'
                                      '${switch (state) {
                                        WarrantyState.expired => '（已过保）',
                                        WarrantyState.expiringSoon => '（即将过保）',
                                        _ => '',
                                      }}',
                                      style: TextStyle(color: color, fontSize: 13),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                          if (item.maintenanceMonths != null &&
                              item.status.isOwned)
                            Builder(builder: (context) {
                              final next = ItemCalculator
                                  .nextMaintenanceDate(item);
                              if (next == null) return const SizedBox.shrink();
                              final daysLeft =
                                  Fmt.daysBetween(DateTime.now(), next);
                              final overdue = daysLeft < 0;
                              final color = overdue
                                  ? cs.error
                                  : daysLeft <= 7
                                      ? const Color(0xFFE65100)
                                      : cs.primary;
                              return Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '每 ${item.maintenanceMonths} 个月保养 · 下次 '
                                      '${Fmt.date(next)}'
                                      '${overdue ? '（已过期 ${-daysLeft} 天）' : '（还有 $daysLeft 天）'}',
                                      style:
                                          TextStyle(color: color, fontSize: 13),
                                    ),
                                  ),
                                ],
                              );
                            }),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 价值评估：成本 × 时长 × 频次 × 品类刚需度
                  if (item.purchasePrice > 0) _ValueCard(item: item),
                  const SizedBox(height: 16),

                  // AI 二手估价：持有中的物品可一键估值。
                  if (ref.watch(aiConfigProvider).isReady && item.status.isOwned)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FilledButton.tonalIcon(
                        onPressed: () =>
                            _showResaleEstimate(context, ref, item, sale),
                        icon: const Icon(Icons.sell_outlined, size: 18),
                        label: const Text('AI 估价'),
                      ),
                    ),
                  const SizedBox(height: 12),

                  // 物品画像：六维雷达 + 总评分
                  if (item.overallScore != null ||
                      item.scoreValue != null ||
                      item.scoreUsage != null ||
                      item.scoreFavorite != null ||
                      item.scoreUtilization != null ||
                      item.scoreCost != null ||
                      item.scoreRetention != null) ...[
                    _section(context, '物品画像', Icons.radar_outlined,
                        trailing: item.overallScore == null
                            ? null
                            : PillChip('评分 ${item.overallScore}',
                                solid: true),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: RadarView(
                              labels: const [
                                '物品价值',
                                '使用时间',
                                '喜爱程度',
                                '有效利用率',
                                '性价比',
                                '保值度',
                              ],
                              values: [
                                item.scoreValue?.toDouble(),
                                item.scoreUsage?.toDouble(),
                                item.scoreFavorite?.toDouble(),
                                item.scoreUtilization?.toDouble(),
                                item.scoreCost?.toDouble(),
                                item.scoreRetention?.toDouble(),
                              ],
                              height: 210,
                            ),
                          ),
                        )),
                  ],

                  // 位置模块
                  _section(context, '存放位置', Icons.place_outlined, child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          if (item.locationImagePath != null) ...[
                            ItemImage(item.locationImagePath,
                                icon: Icons.photo_library_outlined,
                                size: 56, borderRadius: 8),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.locationId != null
                                      ? tree.fullPath(item.locationId)
                                      : '未设置位置',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                if (item.locationDetail != null &&
                                    item.locationDetail!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      item.locationDetail!,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: cs.onSurfaceVariant),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => _moveItem(context, ref, item),
                            icon: const Icon(Icons.drive_file_move_outlined, size: 18),
                            label: const Text('移动'),
                          ),
                        ],
                      ),
                    ),
                  )),

                  // 其他信息
                  _section(context, '其他信息', Icons.info_outline, child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          InfoRow('品牌', item.brand, icon: Icons.branding_watermark),
                          InfoRow('型号', item.model, icon: Icons.tag),
                          InfoRow('渠道', item.purchaseChannel, icon: Icons.storefront_outlined),
                          InfoRow('商家', item.merchantName, icon: Icons.shop_outlined),
                          InfoRow('订单号', item.orderNumber, icon: Icons.receipt_long_outlined),
                          InfoRow('备注', item.notes, icon: Icons.notes),
                        ],
                      ),
                    ),
                  )),

                  if (item.additionalImagePaths.isNotEmpty ||
                      item.invoiceImagePaths.isNotEmpty)
                    _section(context, '图片与票据', Icons.photo_outlined,
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                ...item.additionalImagePaths.map((p) => ItemImage(p,
                                    size: 72, borderRadius: 8)),
                                ...item.invoiceImagePaths.map((p) => Stack(
                                      children: [
                                        ItemImage(p, size: 72, borderRadius: 8),
                                        Positioned(
                                          right: 4,
                                          bottom: 4,
                                          child: Container(
                                            padding: const EdgeInsets.all(3),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Icon(Icons.receipt,
                                                size: 12, color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        )),

                  // 生命周期时间线
                  _section(context, '生命周期', Icons.timeline_outlined,
                      trailing: TextButton.icon(
                        onPressed: () => _addEvent(context, ref, item),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('事件'),
                      ),
                      child: Card(
                        child: events.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('暂无事件记录'),
                              )
                            : Column(
                                children: events.map((e) {
                                  final color = switch (e.eventType) {
                                    ItemEventType.purchased => cs.primary,
                                    ItemEventType.sold => const Color(0xFF7E93AC),
                                    ItemEventType.repaired => const Color(0xFFE65100),
                                    ItemEventType.lent => const Color(0xFF8D6E9C),
                                    _ => cs.outline,
                                  };
                                  return ListTile(
                                    leading: CircleAvatar(
                                      radius: 6,
                                      backgroundColor: color,
                                    ),
                                    title: Text(e.title,
                                        style: const TextStyle(fontSize: 14)),
                                    subtitle: Text(
                                      '${e.eventType.label} · ${Fmt.date(e.eventDate)}'
                                      '${e.amount != null ? ' · ${Money.format(e.amount!, currency: item.currency)}' : ''}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                    dense: true,
                                  );
                                }).toList(),
                              ),
                      )),
                  const SizedBox(height: 88),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _actionsBar(context, ref, item, sale),
    );
  }

  /// AI 二手估价：底部面板展示估算结果。
  Future<void> _showResaleEstimate(
      BuildContext context, WidgetRef ref, Item item, SaleRecord? sale) async {
    // Future 在打开面板前创建，避免面板 builder 重建时重复发起请求。
    final estimateFuture =
        ref.read(aiServiceProvider).estimateResale(item, sale);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: FutureBuilder<String>(
            future: estimateFuture,
            builder: (context, snap) {
              final cs = Theme.of(sheetContext).colorScheme;
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sell_outlined, size: 18, color: cs.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('${item.name} · 二手估值',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.cardTitle(cs.onSurface)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (snap.connectionState != ConnectionState.done)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    else if (snap.hasError)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('估价失败：${snap.error}',
                            style: AppTheme.caption(cs.error)),
                      )
                    else
                      MarkdownBody(
                        data: snap.data ?? '',
                        styleSheet: digestMarkdownStyle(sheetContext),
                      ),
                    if (snap.connectionState == ConnectionState.done &&
                        !snap.hasError) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.tonalIcon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _sell(context, ref, item, sale);
                          },
                          icon: const Icon(Icons.sell_outlined, size: 18),
                          label: const Text('去登记转卖'),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _metric(BuildContext context, String label, String value,
      {Color? color, bool income = false}) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(
          income ? '收益 $value' : value,
          style: AppTheme.bigNumber(color ?? cs.onSurface, size: 17),
        ),
      ],
    );
  }

  Widget _dailyLine(BuildContext context, Item item, SaleRecord? sale) {
    final daily = ItemCalculator.dailyCost(item, sale);
    final cs = Theme.of(context).colorScheme;
    if (daily < 0) {
      return Row(
        children: [
          Icon(Icons.trending_up, size: 14, color: const Color(0xFF6B8F87)),
          const SizedBox(width: 4),
          Text(
            '转卖产生了收益，日均收益 ${Money.formatCompact(daily.abs(), currency: item.currency)}',
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF2F6E75)),
          ),
        ],
      );
    }
    return Row(
      children: [
        Icon(Icons.timelapse, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '${ItemCalculator.holdingText(item, sale)} · 每天约 ${Money.formatCompact(daily, currency: item.currency)}',
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  String _retentionText(double? rate) {
    if (rate == null) return '—';
    return '${(rate * 100).toStringAsFixed(1)}%';
  }

  Widget _section(BuildContext context, String title, IconData icon,
      {Widget? trailing, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title, trailing: trailing),
        child,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _actionsBar(BuildContext context, WidgetRef ref, Item item, SaleRecord? sale) {
    final sold = item.status == ItemStatus.sold;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
              top: BorderSide(
                  color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.edit_outlined, size: 16),
                      label: const Text('编辑'),
                      onPressed: () => context.push('/item/${item.id}/edit'),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.drive_file_move_outlined, size: 16),
                      label: const Text('移动'),
                      onPressed: () => _moveItem(context, ref, item),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.pause_circle_outline, size: 16),
                      label: Text(item.status == ItemStatus.idle ? '取消闲置' : '标记闲置'),
                      onPressed: () => _setStatus(
                          ref, item,
                          item.status == ItemStatus.idle
                              ? ItemStatus.inUse
                              : ItemStatus.idle),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.logout, size: 16),
                      label: Text(item.status == ItemStatus.lent ? '已归还' : '借出'),
                      onPressed: () => _setStatus(
                          ref, item,
                          item.status == ItemStatus.lent
                              ? ItemStatus.inUse
                              : ItemStatus.lent),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.currency_exchange, size: 16),
                      label: Text(sold ? '编辑转卖' : '转卖'),
                      onPressed: () => _sell(context, ref, item, sale),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('删除'),
                      onPressed: () => _delete(context, ref, item),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onMenu(BuildContext context, WidgetRef ref, String action, Item item,
      SaleRecord? sale) {
    switch (action) {
      case 'edit':
        context.push('/item/${item.id}/edit');
      case 'move':
        _moveItem(context, ref, item);
      case 'event':
        _addEvent(context, ref, item);
      case 'delete':
        _delete(context, ref, item);
    }
  }

  Future<void> _moveItem(BuildContext context, WidgetRef ref, Item item) async {
    final loc = await showLocationPickerSheet(context);
    if (loc == null) return;
    await ref.read(itemRepoProvider).updateItem(
          item.copyWith(
              locationId: loc.id,
              locationName: loc.name,
              locationImagePath: loc.imagePath),
        );
    await ref.read(itemRepoProvider).addEvent(ItemEvent(
          id: '',
          itemId: item.id,
          eventType: ItemEventType.moved,
          eventDate: DateTime.now(),
          title: '移动到 ${loc.name}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('已移动到 ${loc.name}')));
    }
  }

  Future<void> _addEvent(BuildContext context, WidgetRef ref, Item item) async {
    final event = await showEventFormSheet(context, item.id);
    if (event == null) return;
    await ref.read(itemRepoProvider).addEvent(event);
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('事件已添加')));
    }
  }

  Future<void> _setStatus(WidgetRef ref, Item item, ItemStatus status) async {
    final repo = ref.read(itemRepoProvider);
    await repo.updateItem(item.copyWith(status: status));
    await repo.addEvent(ItemEvent(
          id: '',
          itemId: item.id,
          eventType: switch (status) {
            ItemStatus.idle => ItemEventType.custom,
            ItemStatus.lent => ItemEventType.lent,
            ItemStatus.inUse => ItemEventType.returned,
            _ => ItemEventType.custom,
          },
          eventDate: DateTime.now(),
          title: status == ItemStatus.idle
              ? '标记为闲置'
              : status == ItemStatus.lent
                  ? '借出物品'
                  : '状态改为${status.label}',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
  }

  /// 转卖流程。已转卖状态下再点可编辑转卖信息。
  Future<void> _sell(
      BuildContext context, WidgetRef ref, Item item, SaleRecord? sale) async {
    final result = await showSaleFormSheet(context,
        existing: sale, itemId: item.id);
    if (result == null) return;
    final repo = ref.read(itemRepoProvider);
    final saleRepo = ref.read(saleRepoProvider);
    await saleRepo.upsert(result);
    if (item.status != ItemStatus.sold) {
      await repo.updateItem(item.copyWith(status: ItemStatus.sold));
    }
    if (sale == null) {
      await repo.addEvent(ItemEvent(
        id: '',
        itemId: item.id,
        eventType: ItemEventType.sold,
        eventDate: result.saleDate,
        title: '转卖给${result.platform ?? '他人'}',
        description: result.buyerNote,
        amount: result.salePrice,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '转卖净收入 ${Money.format(result.netIncome, currency: item.currency)}')));
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Item item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除物品'),
        content: Text('「${item.name}」将移入回收站，默认保留 30 天，可随时恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('移入回收站')),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(itemRepoProvider).softDelete(item.id);
    if (context.mounted) {
      showAutoToast(
        context,
        '「${item.name}」已移入回收站',
        actionLabel: '撤销',
        onAction: () async {
          await ref.read(itemRepoProvider).restore(item.id);
        },
      );
      context.pop();
    }
  }
}

/// 单个物品的事件流。
final itemEventsProvider = StreamProvider.family<List<ItemEvent>, String>(
    (ref, itemId) => ref.read(itemRepoProvider).watchEvents(itemId));

/// 价值评估卡：综合成本、使用时长、频次、品类刚需度的本地评分。
class _ValueCard extends StatelessWidget {
  const _ValueCard({required this.item});

  final Item item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final v = ItemCalculator.assessValue(item);
    final gradeColor = switch (v.grade) {
      ValueGrade.great => cs.primary,
      ValueGrade.fair => const Color(0xFF7D8F66),
      ValueGrade.ok => const Color(0xFF9C8A52),
      ValueGrade.poor => const Color(0xFFAD6A63),
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.workspace_premium_outlined,
                    size: 16, color: gradeColor),
                const SizedBox(width: 6),
                Text('价值评估', style: AppTheme.label(cs.onSurfaceVariant)),
                const Spacer(),
                PillChip(v.grade.label, solid: true, color: gradeColor),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${v.score}',
                    style: AppTheme.bigNumber(gradeColor, size: 34)),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 2),
                  child: Text('/100',
                      style: AppTheme.caption(cs.onSurfaceVariant)),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('单次使用约', style: AppTheme.caption(cs.onSurfaceVariant)),
                    Text(
                      Money.formatCompact(v.costPerUseCents,
                          currency: item.currency),
                      style: AppTheme.bigNumber(cs.onSurface, size: 18),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _vm(context, '频次',
                        item.usageFrequency?.label ?? '按状态估算')),
                Expanded(
                    child: _vm(context, '品类属性', v.necessity.label)),
                Expanded(
                    child: _vm(context, '估算已用',
                        '${v.estimatedUses.toStringAsFixed(0)} 次')),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '综合成本、使用时长、频次与品类刚需度估算；持有越久、用得越勤，评分越高。',
              style: AppTheme.caption(cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vm(BuildContext context, String label, String value) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.label(cs.onSurfaceVariant)),
        const SizedBox(height: 3),
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
