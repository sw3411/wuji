import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models/category.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/pivot_stats.dart';
import '../../shared/widgets/common.dart';

/// 洞察 · 统计透视表：
/// 行=分类/位置/状态（可切换），列=8 项指标，环比红涨绿跌；
/// 首行首列冻结、表体双向滚动；表头点按排序（维度/任意指标）。
class PivotTableCard extends ConsumerStatefulWidget {
  const PivotTableCard({super.key});

  @override
  ConsumerState<PivotTableCard> createState() => _PivotTableCardState();
}

class _PivotTableCardState extends ConsumerState<PivotTableCard> {
  PivotDim _dim = PivotDim.category;
  int _anchorYear = DateTime.now().year;
  DateTime _anchorMonth = DateTime.now();
  Set<String>? _categoryIds;
  Set<String>? _locationIds;

  // 排序：-1=维度名，0..7=指标列；null=默认（总成本降序）。
  int? _sortCol;
  bool _sortAsc = false;

  final _hCtrl = ScrollController();
  final _bodyHCtrl = ScrollController();
  final _bodyVCtrl = ScrollController();
  final _frozenVCtrl = ScrollController();
  bool _syncing = false;

  static const _rowHeight = 46.0;
  static const _firstColWidth = 92.0;
  static const _cellWidth = 84.0;

  @override
  void initState() {
    super.initState();
    _bodyHCtrl.addListener(_syncHeader);
    _bodyVCtrl.addListener(_syncFrozen);
    _frozenVCtrl.addListener(_syncBody);
  }

  void _syncHeader() {
    if (_syncing || !_hCtrl.hasClients) return;
    _syncing = true;
    _hCtrl.jumpTo(_bodyHCtrl.offset);
    _syncing = false;
  }

  void _syncFrozen() {
    if (_syncing || !_frozenVCtrl.hasClients) return;
    _syncing = true;
    _frozenVCtrl.jumpTo(_bodyVCtrl.offset);
    _syncing = false;
  }

  void _syncBody() {
    if (_syncing || !_bodyVCtrl.hasClients) return;
    _syncing = true;
    _bodyVCtrl.jumpTo(_frozenVCtrl.offset);
    _syncing = false;
  }

  @override
  void dispose() {
    _hCtrl.dispose();
    _bodyHCtrl.dispose();
    _bodyVCtrl.dispose();
    _frozenVCtrl.dispose();
    super.dispose();
  }

  List<PivotRow> _sorted(List<PivotRow> rows) {
    final total = rows.last; // 汇总行始终置底
    final body = rows.sublist(0, rows.length - 1);
    int cmp(PivotRow a, PivotRow b) {
      int v;
      switch (_sortCol) {
        case -1:
          v = a.label.compareTo(b.label);
        case 0:
          v = a.count.compareTo(b.count);
        case 1:
          v = a.totalCostCents.compareTo(b.totalCostCents);
        case 2:
          v = a.dailySum.compareTo(b.dailySum);
        case 3:
          v = a.yearNewCount.compareTo(b.yearNewCount);
        case 4:
          v = a.yearNewAmountCents.compareTo(b.yearNewAmountCents);
        case 5:
          v = (a.yoyDelta ?? -1 << 40).compareTo(b.yoyDelta ?? -1 << 40);
        case 6:
          v = a.monthNewCount.compareTo(b.monthNewCount);
        case 7:
          v = a.monthNewAmountCents.compareTo(b.monthNewAmountCents);
        case 8:
          v = (a.momDelta ?? -1 << 40).compareTo(b.momDelta ?? -1 << 40);
        default:
          v = a.count.compareTo(b.count);
      }
      return _sortAsc ? v : -v;
    }

    body.sort(cmp);
    return [...body, total];
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final sales =
        ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final rows = _sorted(PivotStats.compute(
      items,
      sales,
      dim: _dim,
      anchorYear: _anchorYear,
      anchorMonth: _anchorMonth,
      categoryIds: _categoryIds,
      locationIds: _locationIds,
    ));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 紧凑标题：紧贴上方概览网格，避免双重间距。
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 14, 4, 10),
          child: Text('统计透视',
              style: AppTheme.title(cs.onSurface)),
        ),
        GlassCard(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 6),
          radius: AppTheme.cardRadius,
          child: Column(
            children: [
              _controls(context, cs),
              const Divider(height: 1),
              _table(context, cs, rows),
            ],
          ),
        ),
      ],
    );
  }

  // ---------- 控制区 ----------

  Widget _controls(BuildContext context, ColorScheme cs) {
    Widget seg(String label, PivotDim d) => GestureDetector(
          onTap: () => setState(() => _dim = d),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _dim == d
                  ? cs.primary.withValues(alpha: 0.14)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _dim == d ? cs.primary : cs.outlineVariant),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: _dim == d ? FontWeight.w700 : FontWeight.w500,
                    color: _dim == d ? cs.primary : cs.onSurfaceVariant)),
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              seg('分类', PivotDim.category),
              const SizedBox(width: 8),
              seg('位置', PivotDim.location),
              const SizedBox(width: 8),
              seg('状态', PivotDim.status),
              const Spacer(),
              _timeChip(context, cs),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _filterChip(
                context,
                label: '品类·${_categoryLabel(context)}',
                onTap: () => _pickFilter(context, category: true),
              ),
              const SizedBox(width: 8),
              _filterChip(
                context,
                label: '位置·${_locationLabel(context)}',
                onTap: () => _pickFilter(context, category: false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _categoryLabel(BuildContext context) {
    if (_categoryIds == null || _categoryIds!.isEmpty) return '全部';
    final cs = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
    final first =
        cs.where((c) => _categoryIds!.contains(c.id)).firstOrNull?.name;
    return first == null ? '全部' : (_categoryIds!.length > 1 ? '$first等' : first);
  }

  String _locationLabel(BuildContext context) {
    if (_locationIds == null || _locationIds!.isEmpty) return '全部';
    final ls = ref.watch(locationsProvider).valueOrNull ?? const <Location>[];
    final first =
        ls.where((l) => _locationIds!.contains(l.id)).firstOrNull?.name;
    return first == null ? '全部' : (_locationIds!.length > 1 ? '$first等' : first);
  }

  Widget _timeChip(BuildContext context, ColorScheme cs) {
    final now = DateTime.now();
    final isMonth = _anchorYear == now.year &&
        _anchorMonth.year == now.year &&
        _anchorMonth.month == now.month;
    final isYear = _anchorMonth.month == 12 &&
        _anchorMonth.year == _anchorYear &&
        !isMonth;
    final label = isMonth
        ? '${_anchorMonth.year}年${_anchorMonth.month}月'
        : isYear
            ? '$_anchorYear年'
            : '区间~${_anchorMonth.year}.${_anchorMonth.month}';
    return GestureDetector(
      onTap: () => _pickTime(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: cs.outlineVariant),
          color: Theme.of(context).colorScheme.surface,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_outlined, size: 12),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12)),
            const Icon(Icons.expand_more, size: 13),
          ],
        ),
      ),
    );
  }

  Future<void> _pickTime(BuildContext context) async {
    final mode = await showModalBottomSheet<String>(
      useRootNavigator: true,
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_view_day_outlined),
              title: const Text('按年'),
              onTap: () => Navigator.pop(context, 'y'),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_view_month_outlined),
              title: const Text('按月'),
              onTap: () => Navigator.pop(context, 'm'),
            ),
          ],
        ),
      ),
    );
    if (mode == null || !context.mounted) return;

    if (mode == 'y') {
      final years = List<int>.generate(6, (i) => DateTime.now().year - i);
      final y = await showModalBottomSheet<int>(
        useRootNavigator: true,
        context: context,
        builder: (context) => SafeArea(
          child: ListView(
            children: [
              for (final y in years)
                ListTile(
                  title: Text('$y 年'),
                  trailing: _anchorYear == y && _anchorMonth.month == 12
                      ? const Icon(Icons.check, size: 18)
                      : null,
                  onTap: () => Navigator.pop(context, y),
                ),
            ],
          ),
        ),
      );
      if (y == null || !context.mounted) return;
      setState(() {
        _anchorYear = y;
        // 年模式：当年取当前月，往年取 12 月。
        final now = DateTime.now();
        _anchorMonth = DateTime(y, y == now.year ? now.month : 12);
      });
    } else {
      final now = DateTime.now();
      final months = <DateTime>[
        for (var i = 0; i < 18; i++)
          DateTime(now.year, now.month - i),
      ];
      final m = await showModalBottomSheet<DateTime>(
        useRootNavigator: true,
        context: context,
        builder: (context) => SafeArea(
          child: ListView(
            children: [
              for (final m in months)
                ListTile(
                  title: Text('${m.year}年${m.month}月'),
                  trailing: _anchorMonth.year == m.year &&
                          _anchorMonth.month == m.month
                      ? const Icon(Icons.check, size: 18)
                      : null,
                  onTap: () => Navigator.pop(context, m),
                ),
            ],
          ),
        ),
      );
      if (m == null || !context.mounted) return;
      setState(() {
        _anchorMonth = m;
        _anchorYear = m.year;
      });
    }
  }

  Widget _filterChip(BuildContext context,
      {required String label, required VoidCallback onTap}) {
    final cs = Theme.of(context).colorScheme;
    final active = !label.endsWith('全部');
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: active ? cs.primary.withValues(alpha: 0.12) : cs.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? cs.primary : cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active ? cs.primary : cs.onSurfaceVariant)),
            const Icon(Icons.expand_more, size: 13),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFilter(BuildContext context,
      {required bool category}) async {
    if (category) {
      final cs =
          ref.read(categoriesProvider).valueOrNull ?? const <Category>[];
      await showModalBottomSheet<void>(
        useRootNavigator: true,
        context: context,
        builder: (context) => SafeArea(
          child: StatefulBuilder(builder: (context, setSheet) {
            final sel = {...?_categoryIds};
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView(
                  shrinkWrap: true,
                  children: [
                    _filterOption('全部', null, sel, setSheet,
                        () => setState(() => _categoryIds = null)),
                    for (final c in cs)
                      _filterOption(
                        c.name,
                        c.id,
                        sel,
                        setSheet,
                        () => setState(() =>
                            _categoryIds = sel.isEmpty ? null : {...sel}),
                      ),
                  ],
                ),
              ],
            );
          }),
        ),
      );
    } else {
      final ls = ref.read(locationsProvider).valueOrNull ?? const <Location>[];
      await showModalBottomSheet<void>(
        useRootNavigator: true,
        context: context,
        builder: (context) => SafeArea(
          child: StatefulBuilder(builder: (context, setSheet) {
            final sel = {...?_locationIds};
            return ListView(
              shrinkWrap: true,
              children: [
                _filterOption('全部', null, sel, setSheet,
                    () => setState(() => _locationIds = null)),
                for (final l in ls)
                  _filterOption(
                    l.name,
                    l.id,
                    sel,
                    setSheet,
                    () => setState(() =>
                        _locationIds = sel.isEmpty ? null : {...sel}),
                  ),
              ],
            );
          }),
        ),
      );
    }
  }

  Widget _filterOption(String label, String? id, Set<String> sel,
      StateSetter setSheet, VoidCallback onDone) {
    final selected = id == null ? sel.isEmpty : sel.contains(id);
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: selected ? const Icon(Icons.check, size: 18) : null,
      onTap: () {
        setSheet(() {
          if (id == null) {
            sel.clear();
          } else {
            sel.contains(id) ? sel.remove(id) : sel.add(id);
          }
        });
        onDone();
        Navigator.pop(context);
      },
    );
  }

  // ---------- 表体（首行首列冻结） ----------

  static const _headers = [
    ('总件数', '(件)'),
    ('总成本', '(万)'),
    ('日总成本', '(元)'),
    ('今年新增', '(件)'),
    ('新增金额', '(万)'),
    ('年环比', '(万)'),
    ('当月新增', '(件)'),
    ('新增金额', '(万)'),
    ('月环比', '(万)'),
  ];

  Widget _table(BuildContext context, ColorScheme cs, List<PivotRow> rows) {
    final dimName = switch (_dim) {
      PivotDim.category => '分类',
      PivotDim.location => '位置',
      PivotDim.status => '状态',
    };

    Widget headCell(String text, int col,
        {double? width, String? unit}) {
      final active = _sortCol == col;
      return GestureDetector(
        onTap: () => setState(() {
          if (_sortCol == col) {
            _sortAsc = !_sortAsc;
          } else {
            _sortCol = col;
            _sortAsc = col == -1; // 维度名默认升序，指标默认降序
          }
        }),
        child: Container(
          width: width ?? _cellWidth,
          height: _rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.center,
          color: active ? cs.primary.withValues(alpha: 0.08) : null,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.label(active ? cs.primary : cs.onSurfaceVariant)),
              ),
              // 单位后缀：独立小字，永不省略。
              if (unit != null)
                Text(unit,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.72))),
              if (active) ...[
                const SizedBox(width: 2),
                Icon(_sortAsc ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 10, color: cs.primary),
              ],
            ],
          ),
        ),
      );
    }

    final headerRow = Row(
      children: [
        // 冻结的左上角格
        Container(
          width: _firstColWidth,
          height: _rowHeight,
          padding: const EdgeInsets.only(left: 14),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: cs.outlineVariant),
              bottom: BorderSide(color: cs.outlineVariant),
            ),
          ),
          child: headCell(dimName, -1, width: _firstColWidth - 14),
        ),
        Expanded(
          child: SingleChildScrollView(
            controller: _hCtrl,
            scrollDirection: Axis.horizontal,
            physics: const NeverScrollableScrollPhysics(),
            child: Row(
              children: [
                for (var i = 0; i < _headers.length; i++)
                  Container(
                    height: _rowHeight,
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: cs.outlineVariant),
                        right: i == _headers.length - 1
                            ? BorderSide.none
                            : BorderSide(
                                color: cs.outlineVariant.withValues(alpha: 0.4)),
                      ),
                    ),
                    child: headCell(_headers[i].$1, i, unit: _headers[i].$2),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    Widget dataCell(String text, {Color? color, bool bold = false}) =>
        Container(
          width: _cellWidth,
          height: _rowHeight,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          alignment: Alignment.centerRight,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        );

    // 万元紧凑数（无单位，1 位小数）。
    String wan(int cents) => (cents / 1000000).toStringAsFixed(1);

    // 环比绝对差：±万（1 位小数），红涨绿跌，≥0.5 万加双箭头。
    Widget rateCell(int? delta, {bool bold = false}) {
      if (delta == null) {
        return dataCell('—',
            color: cs.onSurfaceVariant.withValues(alpha: 0.5), bold: bold);
      }
      if (delta == 0) {
        return dataCell('0.0',
            color: cs.onSurfaceVariant.withValues(alpha: 0.6), bold: bold);
      }
      final up = delta > 0;
      final color = up ? AppTheme.warnRed : AppTheme.okGreen;
      final absWan = delta.abs() / 1000000;
      final arrow = up ? '↑' : '↓';
      final strong = absWan >= 0.5 ? arrow : '';
      return dataCell(
          '$strong${up ? '+' : '-'}${absWan.toStringAsFixed(1)}',
          color: color,
          bold: bold || absWan >= 0.5);
    }

    List<Widget> bodyCells(PivotRow r, bool isTotal) => [
          dataCell('${r.count}', bold: isTotal),
          dataCell(wan(r.totalCostCents), bold: isTotal),
          dataCell(r.dailySum.toStringAsFixed(1), bold: isTotal),
          dataCell('${r.yearNewCount}', bold: isTotal),
          dataCell(wan(r.yearNewAmountCents), bold: isTotal),
          rateCell(r.yoyDelta, bold: isTotal),
          dataCell('${r.monthNewCount}', bold: isTotal),
          dataCell(wan(r.monthNewAmountCents), bold: isTotal),
          rateCell(r.momDelta, bold: isTotal),
        ];

    Widget frozenCell(PivotRow r, bool isTotal) => Container(
          width: _firstColWidth,
          height: _rowHeight,
          padding: const EdgeInsets.only(left: 14, right: 6),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: isTotal ? cs.primary.withValues(alpha: 0.07) : null,
            border: Border(
              right: BorderSide(color: cs.outlineVariant),
              bottom:
                  BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
            ),
          ),
          child: Text(
            r.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        );

    final body = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 冻结首列
        SingleChildScrollView(
          controller: _frozenVCtrl,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++)
                frozenCell(rows[i], i == rows.length - 1),
            ],
          ),
        ),
        // 滚动表体
        Expanded(
          child: SingleChildScrollView(
            controller: _bodyVCtrl,
            child: SingleChildScrollView(
              controller: _bodyHCtrl,
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++)
                    Container(
                      height: _rowHeight,
                      color: i == rows.length - 1
                          ? cs.primary.withValues(alpha: 0.07)
                          : null,
                      child: Row(
                        children: bodyCells(rows[i], i == rows.length - 1)
                            .map((c) => c)
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return Column(
      children: [
        headerRow,
        SizedBox(
          height: (rows.length * _rowHeight).clamp(0, 7 * _rowHeight),
          child: body,
        ),
      ],
    );
  }
}
