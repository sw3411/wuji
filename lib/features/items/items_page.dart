import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app_settings.dart';
import '../../app/providers.dart';
import '../../core/utils/money.dart';
import '../../domain/models/category.dart';
import '../../domain/models/enums.dart';
import '../../domain/services/item_filter.dart';
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
    _viewMode = ref.read(appSettingsProvider).defaultViewMode;
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

    return Scaffold(
      appBar: AppBar(
        title: _selectMode ? Text('已选 ${_selected.length} 项') : const Text('物品'),
        actions: [
          if (_selectMode) ...[
            IconButton(
              tooltip: '全选',
              icon: const Icon(Icons.select_all_outlined),
              onPressed: () => setState(
                  () => _selected.addAll(items.map((i) => i.id))),
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
          ],
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: '搜索名称、品牌、标签、位置…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      fillColor:
                          Theme.of(context).colorScheme.surface,
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchCtrl.clear();
                                _onSearch('');
                              },
                            )
                          : null,
                    ),
                    onSubmitted: _onSearch,
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<ViewMode>(
                  tooltip: '切换视图',
                  icon: Icon(switch (_viewMode) {
                    ViewMode.card => Icons.dashboard_outlined,
                    ViewMode.compact => Icons.view_list_outlined,
                    ViewMode.showcase => Icons.grid_view_outlined,
                  }),
                  initialValue: _viewMode,
                  onSelected: (v) => setState(() => _viewMode = v),
                  itemBuilder: (context) => ViewMode.values
                      .map((v) => PopupMenuItem(
                            value: v,
                            child: Row(
                              children: [
                                Icon(
                                  switch (v) {
                                    ViewMode.card => Icons.dashboard_outlined,
                                    ViewMode.compact => Icons.view_list_outlined,
                                    ViewMode.showcase => Icons.grid_view_outlined,
                                  },
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(v.label),
                                if (v == _viewMode) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check, size: 16),
                                ],
                              ],
                            ),
                          ))
                      .toList(),
                ),
                IconButton(
                  tooltip: '筛选',
                  icon: Badge(
                    isLabelVisible: filter.hasActiveFilter,
                    child: const Icon(Icons.tune)),
                  onPressed: () => _openFilterSheet(categories),
                ),
              ],
            ),
          ),
          if (filter.hasActiveFilter)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        ..._activeChips(filter, categories),
                      ],
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
                        : '点击下方 + 添加物品',
                  )
                : RefreshIndicator(
                    onRefresh: () async => ref.invalidate(itemsProvider),
                    child: _viewMode == ViewMode.showcase
                        ? GridView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 88),
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
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 88),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final item = items[index];
                              if (_viewMode == ViewMode.compact) {
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
                              }
                              return ItemCard(
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
      chips.add(Chip(
          label: Text(
              '${filter.priceMin == null ? '' : Money.format(filter.priceMin!)} ~ '
              '${filter.priceMax == null ? '' : Money.format(filter.priceMax!)}')));
    }
    if (filter.dateStart != null) {
      chips.add(Chip(label: Text('${filter.dateStart!.year}-${filter.dateStart!.month} 起')));
    }
    if (filter.dateEnd != null) {
      chips.add(Chip(label: Text('至 ${filter.dateEnd!.year}-${filter.dateEnd!.month}')));
    }
    return chips;
  }

  void _openFilterSheet(List<Category> categories) {
    showModalBottomSheet(
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
                  color: Theme.of(context).colorScheme.outlineVariant)),
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
                      icon: const Icon(Icons.drive_file_move_outlined, size: 18),
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
    await ref.read(itemRepoProvider).batchMoveLocation(
        _selected.toList(), loc.id, loc.name);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('已移动到 ${loc.name}')));
      _exitSelectMode();
    }
  }

  Future<void> _batchChangeCategory() async {
    final categories =
        ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
    final visible = categories.where((c) => !c.isHidden).toList();
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          children: visible
              .map((c) => ListTile(
                    leading: Icon(Icons.category_outlined,
                        color: c.color),
                    title: Text(c.name),
                    onTap: () => Navigator.pop(context, '${c.id}|${c.name}'),
                  ))
              .toList(),
        ),
      ),
    );
    if (result == null) return;
    final parts = result.split('|');
    await ref.read(itemRepoProvider).batchChangeCategory(
        _selected.toList(), parts[0], parts[1]);
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('批量修改分类完成')));
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
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('移入')),
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
      padding: EdgeInsets.only(
        left: 16, right: 16, top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
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
                  .map((s) => ChoiceChip(
                        label: Text(s.label),
                        selected: _draft.sort == s,
                        onSelected: (_) => setState(() => _draft.sort = s),
                      ))
                  .toList(),
            ),
            const Divider(height: 24),
            Text('分类', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: widget.categories
                  .where((c) => !c.isHidden)
                  .map((c) => FilterChip(
                        label: Text(c.name),
                        selected: _draft.categoryIds.contains(c.id),
                        onSelected: (_) => _toggle(_draft.categoryIds, c.id),
                      ))
                  .toList(),
            ),
            const Divider(height: 24),
            Text('状态', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: ItemStatus.values
                  .map((s) => FilterChip(
                        label: Text(s.label),
                        selected: _draft.statuses.contains(s),
                        onSelected: (_) => _toggle(_draft.statuses, s),
                      ))
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
                  onSelected: (v) => setState(() => _draft.expiringWarrantyOnly = v),
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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
