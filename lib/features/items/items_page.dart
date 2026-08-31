import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_settings.dart';
import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/money.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../domain/models/category.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/item_filter.dart';
import '../../domain/services/statistics_service.dart';
import '../../shared/widgets/common.dart';
import '../locations/location_picker_sheet.dart';
import 'item_card.dart';

/// 物品列表页：搜索、筛选、排序、批量操作。
class ItemsPage extends ConsumerStatefulWidget {
  const ItemsPage({super.key});

  @override
  ConsumerState<ItemsPage> createState() => _ItemsPageState();
}

class _ItemsPageState extends ConsumerState<ItemsPage> {
  final _searchCtrl = TextEditingController();
  bool _selectMode = false;
  final Set<String> _selected = {};
  late ViewMode _viewMode;

  @override
  void initState() {
    super.initState();
    final f = ref.read(itemFilterProvider);
    _searchCtrl.text = f.search;
    final saved = ref.read(appSettingsProvider).defaultViewMode;
    _viewMode = saved == ViewMode.showcase
        ? ViewMode.showcase
        : ViewMode.compact;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selected.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(filteredItemsProvider);
    final sales = ref.watch(salesMapProvider).valueOrNull ?? const {};
    final filter = ref.watch(itemFilterProvider);
    final categories =
        ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final allItems = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final locations =
        ref.watch(locationsProvider).valueOrNull ?? const <Location>[];
    final currency = ref.watch(appSettingsProvider).currency;
    final stats = StatisticsService.overview(items, sales);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _selectMode
            ? Text('已选 ${_selected.length} 项')
            : const Text('物品档案'),
        actions: [
          if (_selectMode) ...[
            IconButton(
              tooltip: '全选',
              icon: const Icon(Icons.select_all_outlined),
              onPressed: () =>
                  setState(() => _selected.addAll(items.map((i) => i.id))),
            ),
            IconButton(
              tooltip: '取消',
              icon: const Icon(Icons.close),
              onPressed: _exitSelectMode,
            ),
          ] else ...[
            IconButton(
              tooltip: '批量操作',
              icon: const Icon(Icons.checklist),
              onPressed: items.isEmpty
                  ? null
                  : () => setState(() => _selectMode = true),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索名称、品牌、标签或位置',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: '清除搜索',
                        icon: const Icon(Icons.close_rounded, size: 19),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearch('');
                          setState(() {});
                        },
                      ),
              ),
              onSubmitted: _onSearch,
              onChanged: (value) => setState(() {}),
            ),
          ),
          // 五维下拉筛选：分类 / 状态 / 价格 / 标签 / 位置。
          SizedBox(
            height: 38,
            child: _FilterBar(
              filter: filter,
              categories: categories,
              locations: locations,
              allItems: allItems,
              onApply: (f) =>
                  ref.read(itemFilterProvider.notifier).update(f),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${items.length} 件物品',
                        style: AppTheme.cardTitle(cs.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '持有 ${Money.formatCompact(stats.ownedPurchaseTotal, currency: currency)} · 日均 ${stats.sumDailyCost.toStringAsFixed(1)} 元',
                        style: AppTheme.caption(cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: _viewMode == ViewMode.showcase ? '切换到清单' : '切换到收藏册',
                  onPressed: () => setState(() {
                    _viewMode = _viewMode == ViewMode.showcase
                        ? ViewMode.compact
                        : ViewMode.showcase;
                  }),
                  icon: Icon(
                    _viewMode == ViewMode.showcase
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                  ),
                ),
                IconButton(
                  tooltip: '筛选',
                  icon: Badge(
                    isLabelVisible: filter.hasActiveFilter,
                    child: const Icon(Icons.tune),
                  ),
                  onPressed: () => _openFilterSheet(categories),
                ),
              ],
            ),
          ),
          if (filter.hasActiveFilter)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [..._activeChips(filter, categories)],
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(itemFilterProvider.notifier).clear(),
                    child: const Text('清除'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: items.isEmpty
                ? EmptyView(
                    icon: Icons.search_off,
                    title: filter.hasActiveFilter ? '没有符合筛选条件的物品' : '还没有物品',
                    subtitle: filter.hasActiveFilter
                        ? '试试调整筛选条件'
                        : '从一件常用物品开始建立你的档案',
                    action: filter.hasActiveFilter
                        ? TextButton(
                            onPressed: () => ref
                                .read(itemFilterProvider.notifier)
                                .update(ItemFilter()),
                            child: const Text('清除筛选'),
                          )
                        : FilledButton.tonal(
                            onPressed: () => context.push('/item/new'),
                            child: const Text('记录第一件物品'),
                          ),
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(itemsProvider),
                    child: _viewMode == ViewMode.showcase
                        ? GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 0.72,
                                ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ShowcaseCard(
                                item: item,
                                sale: sales[item.id],
                                selectMode: _selectMode,
                                selected: _selected.contains(item.id),
                                onSelectChanged: (v) => setState(() {
                                  v
                                      ? _selected.add(item.id)
                                      : _selected.remove(item.id);
                                }),
                              );
                            },
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              return ItemListTile(
                                item: item,
                                sale: sales[item.id],
                                selectMode: _selectMode,
                                selected: _selected.contains(item.id),
                                onSelectChanged: (v) => setState(() {
                                  v
                                      ? _selected.add(item.id)
                                      : _selected.remove(item.id);
                                }),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
      bottomSheet: _selectMode && _selected.isNotEmpty ? _batchBar() : null,
    );
  }

  void _onSearch(String v) {
    final f = ref.read(itemFilterProvider).copy();
    f.search = v;
    ref.read(itemFilterProvider.notifier).update(f);
  }

  List<Widget> _activeChips(ItemFilter filter, List<Category> categories) {
    final chips = <Widget>[];
    if (filter.categoryIds.isNotEmpty) {
      for (final id in filter.categoryIds) {
        final c = categories.where((x) => x.id == id).firstOrNull;
        if (c != null) chips.add(Chip(label: Text(c.name)));
      }
    }
    for (final s in filter.statuses) {
      chips.add(Chip(label: Text(s.label)));
    }
    if (filter.favoriteOnly) chips.add(const Chip(label: Text('收藏')));
    if (filter.soldOnly) chips.add(const Chip(label: Text('已转卖')));
    if (filter.expiringWarrantyOnly) chips.add(const Chip(label: Text('即将过保')));
    if (filter.priceMin != null || filter.priceMax != null) {
      chips.add(
        Chip(
          label: Text(
            '${filter.priceMin == null ? '' : Money.format(filter.priceMin!)} ~ '
            '${filter.priceMax == null ? '' : Money.format(filter.priceMax!)}',
          ),
        ),
      );
    }
    if (filter.dateStart != null) {
      chips.add(
        Chip(
          label: Text('${filter.dateStart!.year}-${filter.dateStart!.month} 起'),
        ),
      );
    }
    if (filter.dateEnd != null) {
      chips.add(
        Chip(label: Text('至 ${filter.dateEnd!.year}-${filter.dateEnd!.month}')),
      );
    }
    return chips;
  }

  void _openFilterSheet(List<Category> categories) {
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(categories: categories),
    );
  }

  Widget _batchBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    TextButton.icon(
                      onPressed: _batchMoveLocation,
                      icon: const Icon(
                        Icons.drive_file_move_outlined,
                        size: 18,
                      ),
                      label: const Text('移动'),
                    ),
                    TextButton.icon(
                      onPressed: _batchChangeCategory,
                      icon: const Icon(Icons.category_outlined, size: 18),
                      label: const Text('分类'),
                    ),
                    TextButton.icon(
                      onPressed: _batchDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('删除'),
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

  Future<void> _batchMoveLocation() async {
    final loc = await showLocationPickerSheet(context);
    if (loc == null) return;
    await ref
        .read(itemRepoProvider)
        .batchMoveLocation(_selected.toList(), loc.id, loc.name);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已移动到 ${loc.name}')));
      _exitSelectMode();
    }
  }

  Future<void> _batchChangeCategory() async {
    final categories =
        ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
    final visible = categories.where((c) => !c.isHidden).toList();
    final result = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: visible
              .map(
                (c) => ListTile(
                  leading: Icon(Icons.category_outlined, color: c.color),
                  title: Text(c.name),
                  onTap: () => Navigator.pop(context, '${c.id}|${c.name}'),
                ),
              )
              .toList(),
        ),
      ),
    );
    if (result == null) return;
    final parts = result.split('|');
    await ref
        .read(itemRepoProvider)
        .batchChangeCategory(_selected.toList(), parts[0], parts[1]);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('批量修改分类完成')));
      _exitSelectMode();
    }
  }

  Future<void> _batchDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('移入回收站'),
        content: Text('将 ${_selected.length} 件物品移入回收站？回收站默认保留 30 天。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('移入'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ids = _selected.toList();
    await ref.read(itemRepoProvider).batchSoftDelete(ids);
    if (mounted) {
      _exitSelectMode();
      showAutoToast(
        context,
        '已将 ${ids.length} 件物品移入回收站',
        actionLabel: '撤销',
        onAction: () async {
          final repo = ref.read(itemRepoProvider);
          for (final id in ids) {
            await repo.restore(id);
          }
        },
      );
    }
  }
}

/// 筛选面板。
class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet({required this.categories});

  final List<Category> categories;

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late ItemFilter _draft;
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _draft = ref.read(itemFilterProvider).copy();
    if (_draft.priceMin != null) {
      _minCtrl.text = Money.toDecimalString(_draft.priceMin!);
    }
    if (_draft.priceMax != null) {
      _maxCtrl.text = Money.toDecimalString(_draft.priceMax!);
    }
  }

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  void _toggle<T>(List<T> list, T value) {
    setState(() {
      list.contains(value) ? list.remove(value) : list.add(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      // 底部预留悬浮底导高度，避免「应用」按钮被玻璃条压住。
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 92,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('排序', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 6,
              children: ItemSort.values
                  .map(
                    (s) => ChoiceChip(
                      label: Text(s.label),
                      selected: _draft.sort == s,
                      onSelected: (_) => setState(() => _draft.sort = s),
                    ),
                  )
                  .toList(),
            ),
            const Divider(height: 24),
            Text('分类', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: widget.categories
                  .where((c) => !c.isHidden)
                  .map(
                    (c) => FilterChip(
                      label: Text(c.name),
                      selected: _draft.categoryIds.contains(c.id),
                      onSelected: (_) => _toggle(_draft.categoryIds, c.id),
                    ),
                  )
                  .toList(),
            ),
            const Divider(height: 24),
            Text('状态', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: ItemStatus.values
                  .map(
                    (s) => FilterChip(
                      label: Text(s.label),
                      selected: _draft.statuses.contains(s),
                      onSelected: (_) => _toggle(_draft.statuses, s),
                    ),
                  )
                  .toList(),
            ),
            const Divider(height: 24),
            Text('快速筛选', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 6,
              children: [
                FilterChip(
                  label: const Text('收藏'),
                  selected: _draft.favoriteOnly,
                  onSelected: (v) => setState(() => _draft.favoriteOnly = v),
                ),
                FilterChip(
                  label: const Text('已转卖'),
                  selected: _draft.soldOnly,
                  onSelected: (v) => setState(() {
                    _draft.soldOnly = v;
                    if (v) _draft.favoriteOnly = false;
                  }),
                ),
                FilterChip(
                  label: const Text('即将过保'),
                  selected: _draft.expiringWarrantyOnly,
                  onSelected: (v) =>
                      setState(() => _draft.expiringWarrantyOnly = v),
                ),
                FilterChip(
                  label: const Text('闲置'),
                  selected: _draft.idleOnly,
                  onSelected: (v) => setState(() => _draft.idleOnly = v),
                ),
              ],
            ),
            const Divider(height: 24),
            Text('价格区间（元）', style: Theme.of(context).textTheme.titleSmall),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '最低'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—', style: TextStyle(color: cs.outline)),
                ),
                Expanded(
                  child: TextField(
                    controller: _maxCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(hintText: '最高'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                OutlinedButton(
                  onPressed: () {
                    ref.read(itemFilterProvider.notifier).clear();
                    Navigator.pop(context);
                  },
                  child: const Text('重置'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      _draft.priceMin = Money.parse(_minCtrl.text);
                      _draft.priceMax = Money.parse(_maxCtrl.text);
                      ref.read(itemFilterProvider.notifier).update(_draft);
                      Navigator.pop(context);
                    },
                    child: const Text('应用'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 五维快捷筛选条：分类/状态/价格/标签/位置，默认「全部」，
/// 点击弹底部面板选择对应维度的值（单选，可清除）。
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filter,
    required this.categories,
    required this.locations,
    required this.allItems,
    required this.onApply,
  });

  final ItemFilter filter;
  final List<Category> categories;
  final List<dynamic> locations;
  final List<Item> allItems;
  final ValueChanged<ItemFilter> onApply;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // 各维度当前显示值。
    final categoryLabel = filter.categoryIds.length == 1
        ? categories
                .where((c) => c.id == filter.categoryIds.first)
                .firstOrNull
                ?.name ??
            '全部'
        : '全部';
    final statusLabel = filter.statuses.length == 1
        ? filter.statuses.first.label
        : '全部';
    final priceLabel = _priceLabel();
    final tagLabel = (filter.tag?.isNotEmpty ?? false) ? filter.tag! : '全部';
    final locationLabel = filter.locationIds.length == 1
        ? (locations
                .where((l) => l.id == filter.locationIds.first)
                .firstOrNull
                ?.name ??
            '全部')
        : '全部';

    Widget pill({
      required String dim,
      required String value,
      required VoidCallback onTap,
    }) {
      final active = value != '全部';
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Semantics(
          label: '$dim 筛选，当前 $value',
          button: true,
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: active
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.14)
                    : cs.surface,
                borderRadius: BorderRadius.circular(9),
                border: Border.all(
                    color: active ? cs.primary : cs.outlineVariant),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('$dim·$value',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active
                              ? cs.primary
                              : cs.onSurfaceVariant)),
                  const SizedBox(width: 3),
                  Icon(Icons.expand_more,
                      size: 13,
                      color: active ? cs.primary : cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        pill(
            dim: '分类', value: categoryLabel, onTap: () => _pickCategory(context)),
        pill(dim: '状态', value: statusLabel, onTap: () => _pickStatus(context)),
        pill(dim: '价格', value: priceLabel, onTap: () => _pickPrice(context)),
        pill(dim: '标签', value: tagLabel, onTap: () => _pickTag(context)),
        pill(
            dim: '位置',
            value: locationLabel,
            onTap: () => _pickLocation(context)),
      ],
    );
  }

  String _priceLabel() {
    if (filter.priceMin == null && filter.priceMax == null) return '全部';
    if (filter.priceMax == null) return '${filter.priceMin! ~/ 100}以上';
    if (filter.priceMin == null) return '${filter.priceMax! ~/ 100}以下';
    return '${filter.priceMin! ~/ 100}-${filter.priceMax! ~/ 100}';
  }

  // ---------- 选项面板 ----------

  Future<void> _pickCategory(BuildContext context) async {
    final counts = <String, int>{};
    for (final i in allItems) {
      if (i.isDeleted) continue;
      counts[i.categoryId] = (counts[i.categoryId] ?? 0) + 1;
    }
    final sorted = categories.toList()
      ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
    await _sheet(
      context,
      '分类',
      [
        _Opt(null, '全部', filter.categoryIds.isEmpty),
        for (final c in sorted)
          _Opt(c.id, '${c.name}（${counts[c.id] ?? 0}）',
              filter.categoryIds.length == 1 && filter.categoryIds.first == c.id),
      ],
      (id) {
        final f = filter.copy()..categoryIds = id == null ? [] : [id!];
        onApply(f);
      },
    );
  }

  Future<void> _pickStatus(BuildContext context) async {
    await _sheet(
      context,
      '状态',
      [
        _Opt(null, '全部', filter.statuses.isEmpty),
        for (final s in ItemStatus.values)
          _Opt(s, s.label,
              filter.statuses.length == 1 && filter.statuses.first == s),
      ],
      (v) {
        final f = filter.copy();
        f.statuses = v == null ? [] : [v as ItemStatus];
        onApply(f);
      },
    );
  }

  Future<void> _pickPrice(BuildContext context) async {
    const presets = <(int?, int?, String)>[
      (null, null, '全部'),
      (null, 10000, '100元以下'),
      (10000, 50000, '100-500元'),
      (50000, 200000, '500-2000元'),
      (200000, 1000000, '2000-1万'),
      (1000000, null, '1万以上'),
    ];
    await _sheet(
      context,
      '价格',
      [
        for (final (min, max, label) in presets)
          _Opt((min, max), label, filter.priceMin == min && filter.priceMax == max),
      ],
      (v) {
        final f = filter.copy();
        if (v == null) {
          f.priceMin = null;
          f.priceMax = null;
        } else {
          final (min, max) = v as (int?, int?);
          f.priceMin = min;
          f.priceMax = max;
        }
        onApply(f);
      },
    );
  }

  Future<void> _pickTag(BuildContext context) async {
    final tagCounts = <String, int>{};
    for (final i in allItems) {
      if (i.isDeleted) continue;
      for (final t in {...i.tags, ...?i.aiTags}) {
        tagCounts[t] = (tagCounts[t] ?? 0) + 1;
      }
    }
    final sorted = tagCounts.keys.toList()
      ..sort((a, b) => tagCounts[b]!.compareTo(tagCounts[a]!));
    await _sheet(
      context,
      '标签',
      [
        _Opt(null, '全部', filter.tag == null),
        for (final t in sorted.take(30))
          _Opt(t, '$t（${tagCounts[t]}）', filter.tag == t),
      ],
      (v) {
        final f = filter.copy()..tag = v as String?;
        onApply(f);
      },
    );
  }

  Future<void> _pickLocation(BuildContext context) async {
    final counts = <String, int>{};
    for (final i in allItems) {
      if (i.isDeleted || i.locationId == null) continue;
      counts[i.locationId!] = (counts[i.locationId!] ?? 0) + 1;
    }
    final sorted = locations.toList()
      ..sort((a, b) => (counts[b.id] ?? 0).compareTo(counts[a.id] ?? 0));
    await _sheet(
      context,
      '位置',
      [
        _Opt(null, '全部', filter.locationIds.isEmpty),
        for (final l in sorted)
          _Opt(l.id, '${l.name}（${counts[l.id] ?? 0}）',
              filter.locationIds.length == 1 && filter.locationIds.first == l.id),
      ],
      (id) {
        final f = filter.copy()..locationIds = id == null ? [] : [id!];
        onApply(f);
      },
    );
  }

  Future<void> _sheet(
    BuildContext context,
    String title,
    List<_Opt> options,
    ValueChanged<dynamic> onPick,
  ) {
    return showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.6),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Center(
                  child: Text('选择$title',
                      style:
                          const TextStyle(fontWeight: FontWeight.w700))),
            ),
            for (final o in options)
              ListTile(
                dense: true,
                title: Text(o.label),
                trailing: o.selected
                    ? const Icon(Icons.check, size: 18)
                    : null,
                onTap: () {
                  Navigator.pop(context);
                  onPick(o.value);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _Opt {
  const _Opt(this.value, this.label, this.selected);
  final dynamic value;
  final String label;
  final bool selected;
}
