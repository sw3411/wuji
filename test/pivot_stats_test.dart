import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/services/pivot_stats.dart';

Item _item(
  String id,
  String category, {
  int price = 10000,
  DateTime? purchaseDate,
  ItemStatus status = ItemStatus.inUse,
  String? locationName,
}) =>
    Item(
      id: id,
      name: '物品$id',
      categoryId: 'c-$category',
      categoryName: category,
      purchasePrice: price,
      purchaseDate: purchaseDate ?? DateTime(2026, 8, 1),
      status: status,
      locationName: locationName,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

void main() {
  final now = DateTime(2026, 8, 21);

  test('分类维度：持有指标 + 新增窗口 + 汇总行', () {
    final items = [
      // 手机数码：持有 2 件 1500 元；2026 新增 1 件 500；8 月新增 1 件 500。
      _item('a', '手机数码', price: 100000,
          purchaseDate: DateTime(2025, 1, 10)),
      _item('b', '手机数码', price: 50000, purchaseDate: DateTime(2026, 8, 5)),
      // 家用电器：持有 1 件；2025 新增（构成上年基数）。
      _item('c', '家用电器', price: 80000,
          purchaseDate: DateTime(2025, 6, 1)),
      // 已转卖：不计入持有件数/总成本。
      _item('d', '手机数码',
          price: 30000,
          status: ItemStatus.sold,
          purchaseDate: DateTime(2024, 1, 1)),
    ];
    final rows = PivotStats.compute(
      items,
      const {},
      dim: PivotDim.category,
      anchorYear: 2026,
      anchorMonth: DateTime(2026, 8),
      now: now,
    );
    expect(rows.last.label, '汇总');
    expect(rows.last.count, 3); // a b c
    expect(rows.last.totalCostCents, 230000);
    final phone = rows.firstWhere((r) => r.label == '手机数码');
    expect(phone.count, 2);
    expect(phone.totalCostCents, 150000);
    expect(phone.yearNewCount, 1);
    expect(phone.yearNewAmountCents, 50000);
    expect(phone.monthNewCount, 1);
    // 家电 2026 新增 0、2025 新增 800 → 绝对差 -800 元。
    final appliance = rows.firstWhere((r) => r.label == '家用电器');
    expect(appliance.yoyDelta, -80000);
  });

  test('年环比绝对差：本年 500 - 上年 800 = -300 元', () {
    final items = [
      _item('a', '手机数码', price: 50000, purchaseDate: DateTime(2026, 3, 1)),
      _item('b', '手机数码', price: 80000, purchaseDate: DateTime(2025, 3, 1)),
    ];
    final rows = PivotStats.compute(items, const {},
        dim: PivotDim.category,
        anchorYear: 2026,
        anchorMonth: DateTime(2026, 8),
        now: now);
    final r = rows.firstWhere((x) => x.label == '手机数码');
    expect(r.yoyDelta, -30000);
  });

  test('上年无基数但今年有新增：环比=全额（红涨）', () {
    final items = [
      _item('a', '服装', price: 45000, purchaseDate: DateTime(2026, 2, 1)),
    ];
    final rows = PivotStats.compute(items, const {},
        dim: PivotDim.category,
        anchorYear: 2026,
        anchorMonth: DateTime(2026, 8),
        now: now);
    final r = rows.firstWhere((x) => x.label == '服装');
    expect(r.yoyDelta, 45000);
    // 双零 → null。
    final empty = PivotStats.compute(const [], const {},
        dim: PivotDim.category,
        anchorYear: 2026,
        anchorMonth: DateTime(2026, 8),
        now: now);
    expect(empty.firstWhere((x) => x.label == '汇总').yoyDelta, isNull);
  });

  test('月环比绝对差：本月 300 - 上月 200 = +100 元', () {
    final items = [
      _item('a', '服装', price: 30000, purchaseDate: DateTime(2026, 8, 2)),
      _item('b', '服装', price: 20000, purchaseDate: DateTime(2026, 7, 15)),
    ];
    final rows = PivotStats.compute(items, const {},
        dim: PivotDim.category,
        anchorYear: 2026,
        anchorMonth: DateTime(2026, 8),
        now: now);
    final r = rows.firstWhere((x) => x.label == '服装');
    expect(r.momDelta, 10000);
    expect(r.monthNewCount, 1);
  });

  test('位置维度与筛选过滤', () {
    final items = [
      _item('a', '手机数码', locationName: '卧室', price: 10000),
      _item('b', '家用电器', locationName: '客厅', price: 20000),
      _item('c', '服装', locationName: null, price: 5000),
    ];
    final rows = PivotStats.compute(items, const {},
        dim: PivotDim.location,
        anchorYear: 2026,
        anchorMonth: DateTime(2026, 8),
        now: now);
    expect(rows.map((r) => r.label), containsAll(['卧室', '客厅', '未设位置']));

    // 只看卧室。
    final filtered = PivotStats.compute(items, const {},
        dim: PivotDim.location,
        anchorYear: 2026,
        anchorMonth: DateTime(2026, 8),
        locationIds: {'L1'},
        now: now);
    // locationIds 过滤基于 locationId（本例未设 id），全部被排除 → 仅汇总行。
    expect(filtered.length, 1);
    expect(filtered.first.label, '汇总');
    expect(filtered.first.count, 0);
  });

  test('状态维度：闲置/使用中分桶，默认按总成本降序', () {
    final items = [
      _item('a', '手机数码', price: 90000),
      _item('b', '家用电器', price: 10000, status: ItemStatus.idle),
    ];
    final rows = PivotStats.compute(items, const {},
        dim: PivotDim.status,
        anchorYear: 2026,
        anchorMonth: DateTime(2026, 8),
        now: now);
    expect(rows.first.label, '使用中');
    expect(rows[1].label, '闲置');
    expect(rows.last.label, '汇总');
  });
}
