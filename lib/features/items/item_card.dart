import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/image_store.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/constants/default_categories.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../domain/models/item.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/item_calculator.dart';
import '../../shared/widgets/common.dart';

/// 档案卡片：突出物品身份、位置和一个价值结论。
class ItemCard extends ConsumerWidget {
  const ItemCard({
    super.key,
    required this.item,
    this.sale,
    this.currency = 'CNY',
    this.compact = false,
    this.selected = false,
    this.selectMode = false,
    this.onSelectChanged,
  });

  final Item item;
  final SaleRecord? sale;
  final String currency;
  final bool compact;
  final bool selected;
  final bool selectMode;
  final ValueChanged<bool>? onSelectChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesProvider).valueOrNull;
    final category = categories
        ?.where((entry) => entry.id == item.categoryId)
        .firstOrNull;
    final icon = CategoryIcons.of(category?.icon ?? 'category');
    final daily = ItemCalculator.dailyCost(item, sale);
    final days = ItemCalculator.usedDays(item, sale);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        onTap: selectMode
            ? () => onSelectChanged?.call(!selected)
            : () => context.push('/item/${item.id}'),
        radius: AppTheme.cardRadius,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (selectMode) ...[
                Checkbox(
                  value: selected,
                  onChanged: (value) => onSelectChanged?.call(value ?? false),
                ),
                const SizedBox(width: 4),
              ],
              ItemImage(
                item.coverImagePath,
                icon: icon,
                size: compact ? 52 : 72,
                borderRadius: 13,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.cardTitle(cs.onSurface),
                          ),
                        ),
                        if (item.isFavorite)
                          Icon(
                            Icons.favorite_rounded,
                            size: 16,
                            color: cs.secondary,
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 15,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.locationName ?? '未设置位置',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.caption(cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        StatusChip(item.status, compact: true),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            item.categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.caption(cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          Money.formatCompact(
                            item.purchasePrice,
                            currency: item.currency,
                          ),
                          style: AppTheme.bigNumber(cs.onSurface, size: 19),
                        ),
                        const Spacer(),
                        Flexible(
                          child: Text(
                            daily < 0
                                ? '日均收益 ${Money.formatCompact(daily.abs(), currency: item.currency)}'
                                : '$days 天 · 日均 ${Money.formatCompact(daily, currency: item.currency)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                AppTheme.caption(
                                  daily < 0
                                      ? AppTheme.sage
                                      : cs.onSurfaceVariant,
                                ).copyWith(
                                  fontWeight: daily < 0
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 高密度清单行。embedded=true 时用于其他卡片内部，不重复绘制外框。
class ItemListTile extends ConsumerWidget {
  const ItemListTile({
    super.key,
    required this.item,
    this.sale,
    this.selected = false,
    this.selectMode = false,
    this.onSelectChanged,
    this.embedded = false,
  });

  final Item item;
  final SaleRecord? sale;
  final bool selected;
  final bool selectMode;
  final ValueChanged<bool>? onSelectChanged;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesProvider).valueOrNull;
    final category = categories
        ?.where((entry) => entry.id == item.categoryId)
        .firstOrNull;
    final icon = CategoryIcons.of(category?.icon ?? 'category');
    final daily = ItemCalculator.dailyCost(item, sale);

    final content = InkWell(
      onTap: selectMode
          ? () => onSelectChanged?.call(!selected)
          : () => context.push('/item/${item.id}'),
      borderRadius: BorderRadius.circular(AppTheme.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            if (selectMode) ...[
              Checkbox(
                value: selected,
                onChanged: (value) => onSelectChanged?.call(value ?? false),
              ),
              const SizedBox(width: 2),
            ],
            ItemImage(
              item.coverImagePath,
              icon: icon,
              size: 50,
              borderRadius: 12,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.cardTitle(cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    [
                      item.locationName ?? '未设置位置',
                      item.status.label,
                      Fmt.monthCn(item.purchaseDate),
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption(cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Money.formatCompact(
                    item.purchasePrice,
                    currency: item.currency,
                  ),
                  style: AppTheme.bigNumber(cs.onSurface, size: 16),
                ),
                const SizedBox(height: 3),
                Text(
                  daily < 0
                      ? '收益 ${Money.formatCompact(daily.abs(), currency: item.currency)}/天'
                      : '${Money.formatCompact(daily, currency: item.currency)}/天',
                  style: AppTheme.caption(
                    daily < 0 ? AppTheme.sage : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (embedded) return content;
    return Card(margin: const EdgeInsets.only(bottom: 8), child: content);
  }
}

/// 照片优先的收藏册视图。
class ShowcaseCard extends ConsumerWidget {
  const ShowcaseCard({
    super.key,
    required this.item,
    this.sale,
    this.selected = false,
    this.selectMode = false,
    this.onSelectChanged,
  });

  final Item item;
  final SaleRecord? sale;
  final bool selected;
  final bool selectMode;
  final ValueChanged<bool>? onSelectChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesProvider).valueOrNull;
    final category = categories
        ?.where((entry) => entry.id == item.categoryId)
        .firstOrNull;
    final icon = CategoryIcons.of(category?.icon ?? 'category');
    final categoryColor = category?.color ?? cs.outline;
    final daily = ItemCalculator.dailyCost(item, sale);
    final hasImage = ImageStore.exists(item.coverImagePath);

    return Card(
      child: InkWell(
        onTap: selectMode
            ? () => onSelectChanged?.call(!selected)
            : () => context.push('/item/${item.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: hasImage
                      ? ItemImage(item.coverImagePath, icon: icon)
                      : ColoredBox(
                          color: categoryColor.withValues(alpha: 0.10),
                          child: Center(
                            child: Icon(
                              icon,
                              size: 42,
                              color: categoryColor.withValues(alpha: 0.72),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: StatusChip(item.status, compact: true),
                ),
                if (selectMode)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Material(
                      color: cs.surface.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: Checkbox(
                        value: selected,
                        onChanged: (value) =>
                            onSelectChanged?.call(value ?? false),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 10, 11, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.cardTitle(cs.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.locationName ?? item.categoryName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.caption(cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Money.formatCompact(
                            item.purchasePrice,
                            currency: item.currency,
                          ),
                          style: AppTheme.bigNumber(cs.onSurface, size: 17),
                        ),
                      ),
                      if (daily < 0)
                        Icon(
                          Icons.trending_up_rounded,
                          size: 17,
                          color: AppTheme.sage,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
