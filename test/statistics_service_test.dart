import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/models/sale_record.dart';
import 'package:wuji/domain/services/statistics_service.dart';

Item _item(
  String id,
  ItemStatus status, {
  int price = 100000,
  DateTime? purchaseDate,
}) =>
    Item(
      id: id,
      name: '物品$id',
      categoryId: 'c1',
      categoryName: '手机数码',
      purchasePrice: price,
      purchaseDate: purchaseDate ?? DateTime(2026, 1, 1),
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  final now = DateTime(2026, 8, 21);

  test('当前资产统计范围：仅持有状态计入', () {
    final items = [
      _item('a', ItemStatus.inUse),
      _item('b', ItemStatus.idle),
      _item('c', ItemStatus.stored),
      _item('d', ItemStatus.lent),
      _item('e', ItemStatus.repairing),
      _item('f', ItemStatus.sold),
      _item('g', ItemStatus.gifted),
      _item('h', ItemStatus.discarded),
      _item('i', ItemStatus.lost),
      _item('j', ItemStatus.consumed),
    ];
    final overview = StatisticsService.overview(items, const {}, now: now);
    expect(overview.ownedCount, 5);
    expect(overview.totalCount, 10);
    expect(overview.ownedPurchaseTotal, 500000);
    expect(overview.historyPurchaseTotal, 1000000);
  });

  test('回收站物品不计入任何统计', () {
    final items = [
      _item('a', ItemStatus.inUse),
      _item('deleted', ItemStatus.inUse).copyWith(deletedAt: now),
    ];
    final overview = StatisticsService.overview(items, const {}, now: now);
    expect(overview.ownedCount, 1);
    expect(overview.totalCount, 1);
  });

  test('转卖回收净收入与历史损耗', () {
    final items = [
      _item('a', ItemStatus.sold, price: 100000), // 1000 元
      _item('b', ItemStatus.inUse, price: 50000),
    ];
    final sales = {
      'a': SaleRecord(
        id: 's1',
        itemId: 'a',
        salePrice: 80000,
        saleDate: DateTime(2026, 6, 1),
        shippingCost: 1000,
        platformFee: 500,
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      ),
    };
    final overview = StatisticsService.overview(items, sales, now: now);
    // 净收入 = 800 - 10 - 5 = 785 元
    expect(overview.saleNetIncomeTotal, 78500);
    // 损耗 = 1000 - 785 = 215 元
    expect(overview.historyDepreciationTotal, 21500);
    // 当前持有 = b
    expect(overview.ownedPurchaseTotal, 50000);
  });

  test('分类统计仅统计当前持有物品', () {
    final items = [
      _item('a', ItemStatus.inUse, price: 100),
      _item('b', ItemStatus.idle, price: 200),
      _item('c', ItemStatus.sold, price: 999999),
    ];
    final stats = StatisticsService.byCategory(items, const {}, now: now);
    expect(stats.single.count, 2);
    expect(stats.single.purchaseTotal, 300);
  });

  test('月度趋势包含空月份', () {
    final items = [
      _item('a', ItemStatus.inUse, purchaseDate: DateTime(2026, 8, 5)),
    ];
    final trend =
        StatisticsService.monthlyTrend(items, const {}, months: 3, now: now);
    expect(trend.length, 3);
    expect(trend.last.monthKey, '2026-08');
    expect(trend.last.newCount, 1);
    expect(trend.first.newCount, 0);
  });

  test('空数据时统计不抛异常', () {
    final overview =
        StatisticsService.overview(const [], const {}, now: now);
    expect(overview.ownedCount, 0);
    expect(overview.avgDailyCost, 0);
    expect(
        StatisticsService.byCategory(const [], const {}, now: now), isEmpty);
    expect(
        StatisticsService.dailyCostRanking(const [], const {}, now: now),
        isEmpty);
  });

  test('日均成本之和与均值口径区分', () {
    // 两件持有物品：a 购于 100 天前 1000 元（10 元/天），
    // b 购于 100 天前 100 元（1 元/天）。
    final items = [
      _item('a', ItemStatus.inUse, price: 100000,
          purchaseDate: now.subtract(const Duration(days: 100))),
      _item('b', ItemStatus.inUse, price: 10000,
          purchaseDate: now.subtract(const Duration(days: 100))),
    ];
    final overview = StatisticsService.overview(items, const {}, now: now);
    // usedDays 含首日共 101 天：件均 9.90 + 0.99 元/天。
    // 之和 = 10.89 → 10.9；均值 = 5.445 → 5.4（口径互不相同）。
    expect(overview.sumDailyCost.toStringAsFixed(1), '10.9');
    expect(overview.avgDailyCost.toStringAsFixed(1), '5.4');
  });

  test('日均成本榜单排序', () {
    final items = [
      _item('cheap', ItemStatus.inUse, price: 100, purchaseDate: DateTime(2026, 1, 1)),
      _item('expensive', ItemStatus.inUse, price: 10000000, purchaseDate: DateTime(2026, 8, 20)),
    ];
    final desc = StatisticsService.dailyCostRanking(items, const {},
        descending: true, now: now);
    expect(desc.first.item.id, 'expensive');
    final asc = StatisticsService.dailyCostRanking(items, const {},
        descending: false, now: now);
    expect(asc.first.item.id, 'cheap');
  });

  test('保值率榜单只含已转卖物品', () {
    final items = [
      _item('a', ItemStatus.sold, price: 100000),
      _item('b', ItemStatus.inUse, price: 100000),
    ];
    final sales = {
      'a': SaleRecord(
        id: 's',
        itemId: 'a',
        salePrice: 90000,
        saleDate: DateTime(2026, 6, 1),
        createdAt: DateTime(2026, 6, 1),
        updatedAt: DateTime(2026, 6, 1),
      ),
    };
    final rank = StatisticsService.retentionRanking(items, sales);
    expect(rank.length, 1);
    expect(rank.first.value, closeTo(0.9, 0.001));
  });
}
