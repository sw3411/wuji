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

/// 物品卡片（卡片视图）：图片 + 两行信息 + 底部数字行。
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
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <dynamic>[];
    final cat = categories.where((c) => c.id == item.categoryId).firstOrNull;
    final icon = CategoryIcons.of((cat?.icon as String?) ?? 'category');
    final catColor = cat?.color as Color? ?? cs.outline;

    final days = ItemCalculator.usedDays(item, sale);
    final daily = ItemCalculator.dailyCost(item, sale);

    final body = Row(
      children: [
        ItemImage(
          item.coverImagePath,
          icon: icon,
          size: compact ? 46 : 64,
          borderRadius: 12,
        ),
        const SizedBox(width: 12),
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
                  if (item.overallScore != null) ...[
                    const SizedBox(width: 6),
                    PillChip('评分 ${item.overallScore}',
                        solid: true, compact: true),
                  ],
                  if (item.isFavorite)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Icon(Icons.favorite,
                          size: 14, color: AppTheme.green),
                    ),
                ],
              ),
              // 次行：分类 + 购买时间（到月）…… 使用天数徽章右对齐（与评分徽章同边）。
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(icon, size: 12, color: catColor),
                  const SizedBox(width: 3),
                  Flexible(
                    child: Text(item.categoryName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 8),
                  Text(Fmt.monthCn(item.purchaseDate),
                      style:
                          TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  const Spacer(),
                  PillChip('$days 天', solid: true, compact: true),
                ],
              ),
              // 三行：使用状态 + 保修状态（三色标注）
              const SizedBox(height: 6),
              Row(
                children: [
                  StatusChip(item.status, compact: true),
                  const SizedBox(width: 8),
                  Flexible(
                    child: WarrantyChip(item, compact: true),
                  ),
                ],
              ),
              // 末行：购买价格 + 日均成本
              const SizedBox(height: 6),
              Row(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      Money.formatCompact(item.purchasePrice,
                          currency: item.currency),
                      style: AppTheme.bigNumber(cs.onSurface, size: 18),
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: DailyCostText(
                        dailyCostMinor: daily,
                        currency: item.currency,
                        style: TextStyle(fontSize: 12.5, color: cs.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: selectMode
            ? () => onSelectChanged?.call(!selected)
            : () => context.push('/item/${item.id}'),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: EdgeInsets.all(compact ? 8 : 12),
          child: Row(
            children: [
              if (selectMode) ...[
                Checkbox(
                  value: selected,
                  onChanged: (v) => onSelectChanged?.call(v ?? false),
                ),
                const SizedBox(width: 4),
              ],
              Expanded(child: body),
            ],
          ),
        ),
      ),
    );
  }
}

/// WhatsApp 式紧凑行：头像 + 标题/副标题 + 右侧数字列。
class ItemListTile extends ConsumerWidget {
  const ItemListTile({
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
    final cat = categories?.where((c) => c.id == item.categoryId).firstOrNull;
    final icon = CategoryIcons.of(cat?.icon ?? 'category');

    final days = ItemCalculator.usedDays(item, sale);
    final daily = ItemCalculator.dailyCost(item, sale);

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: selectMode
            ? () => onSelectChanged?.call(!selected)
            : () => context.push('/item/${item.id}'),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              if (selectMode)
                Checkbox(
                  value: selected,
                  onChanged: (v) => onSelectChanged?.call(v ?? false),
                ),
              ItemImage(item.coverImagePath,
                  icon: icon, size: 46, borderRadius: 12),
              const SizedBox(width: 10),
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
                        if (item.overallScore != null) ...[
                          const SizedBox(width: 5),
                          PillChip('${item.overallScore}',
                              solid: true, compact: true),
                        ],
                        if (item.isFavorite)
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(Icons.favorite,
                                size: 13, color: AppTheme.green),
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        StatusChip(item.status, compact: true),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            [
                              item.locationName ?? '未设置位置',
                              Fmt.monthCn(item.purchaseDate),
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11.5, color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      Money.formatCompact(item.purchasePrice,
                          currency: item.currency),
                      style: AppTheme.bigNumber(cs.onSurface, size: 16),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      daily < 0
                          ? '日均赚 ${Money.formatCompact(daily.abs(), currency: item.currency)}'
                          : '$days 天 · 日均 ${Money.formatCompact(daily, currency: item.currency)}',
                      style:
                          TextStyle(fontSize: 10.5, color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 小红书式橱窗格：大图 + 名称 + 价格，双列展示。
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
    final cat = categories?.where((c) => c.id == item.categoryId).firstOrNull;
    final icon = CategoryIcons.of(cat?.icon ?? 'category');
    final catColor = cat?.color ?? cs.outline;

    final days = ItemCalculator.usedDays(item, sale);
    final daily = ItemCalculator.dailyCost(item, sale);
    final hasImage = ImageStore.exists(item.coverImagePath);

    return Card(
      clipBehavior: Clip.antiAlias,
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
                      : Container(
                          color: catColor.withValues(alpha: 0.10),
                          child: Center(
                            child: Icon(icon,
                                size: 40,
                                color: catColor.withValues(alpha: 0.6)),
                          ),
                        ),
                ),
                if (selectMode)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black38,
                        shape: BoxShape.circle,
                      ),
                      child: Checkbox(
                        value: selected,
                        onChanged: (v) => onSelectChanged?.call(v ?? false),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: StatusChip(item.status, compact: true),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
                        Icon(Icons.favorite,
                            size: 13, color: AppTheme.green),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          Money.formatCompact(item.purchasePrice,
                              currency: item.currency),
                          style: AppTheme.bigNumber(cs.primary, size: 18),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        daily < 0 ? '转卖赚了' : '$days 天',
                        style: TextStyle(
                            fontSize: 11, color: cs.onSurfaceVariant),
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
