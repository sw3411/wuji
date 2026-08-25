import '../models/item.dart';
import '../models/sale_record.dart';
import 'item_calculator.dart';

/// 统计口径的数据结构。
class StatsOverview {
  StatsOverview({
    required this.totalCount,
    required this.ownedCount,
    required this.historyPurchaseTotal,
    required this.ownedPurchaseTotal,
    required this.saleNetIncomeTotal,
    required this.historyDepreciationTotal,
    required this.avgDailyCost,
  });

  /// 历史记录物品数量（含已转卖/丢弃等）。
  final int totalCount;

  /// 当前拥有物品数量。
  final int ownedCount;

  /// 历史购买总额（分）。
  final int historyPurchaseTotal;

  /// 当前持有物品购买总额（分）。
  final int ownedPurchaseTotal;

  /// 已转卖回收净收入（分）。
  final int saleNetIncomeTotal;

  /// 历史实际损耗（分）：仅统计已转卖物品的损耗。
  final int historyDepreciationTotal;

  /// 当前持有物品的平均日均成本（分/天）。
  final double avgDailyCost;
}

class CategoryStats {
  CategoryStats({
    required this.categoryId,
    required this.categoryName,
    required this.count,
    required this.purchaseTotal,
    required this.avgDailyCost,
  });

  final String categoryId;
  final String categoryName;
  final int count;
  final int purchaseTotal;

  /// 平均日均成本（分/天）。
  final double avgDailyCost;

  double get share => 0; // 由调用方根据总额计算后覆盖
}

class MonthlyStats {
  MonthlyStats(this.monthKey, this.newCount, this.purchaseTotal,
      this.saleIncome, this.depreciation);

  final String monthKey; // yyyy-MM
  final int newCount;
  final int purchaseTotal;
  final int saleIncome;
  final int depreciation;
}

class ValueRanking {
  ValueRanking(this.item, this.sale, this.dailyCost, this.value);

  final Item item;
  final SaleRecord? sale;

  /// 日均成本（分/天），用于日均榜。
  final int dailyCost;

  /// 榜单值：使用天数 / 保值率(0~1) 等，按榜单含义使用。
  final double value;
}

/// 统计服务。所有统计口径集中在此，页面不自行计算。
class StatisticsService {
  StatisticsService._();

  static bool isOwned(Item item) => item.status.isOwned && !item.isDeleted;

  /// 是否计入历史口径（未删除的都算）。
  static bool inHistory(Item item) => !item.isDeleted;

  static StatsOverview overview(
    List<Item> items,
    Map<String, SaleRecord> salesByItemId, {
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final active = items.where(inHistory).toList();
    final owned = active.where(isOwned).toList();

    int historyTotal = 0;
    int ownedTotal = 0;
    int saleIncome = 0;
    int soldDepreciation = 0;
    double dailySum = 0;
    int dailyCount = 0;

    for (final item in active) {
      historyTotal += item.purchasePrice;
      final sale = salesByItemId[item.id];
      if (isOwned(item)) {
        ownedTotal += item.purchasePrice;
        dailySum += ItemCalculator.dailyCost(item, sale, now: now_) / 100;
        dailyCount++;
      } else if (sale != null) {
        saleIncome += sale.netIncome;
        soldDepreciation += ItemCalculator.actualDepreciation(item, sale);
      }
    }

    return StatsOverview(
      totalCount: active.length,
      ownedCount: owned.length,
      historyPurchaseTotal: historyTotal,
      ownedPurchaseTotal: ownedTotal,
      saleNetIncomeTotal: saleIncome,
      historyDepreciationTotal: soldDepreciation,
      avgDailyCost: dailyCount == 0 ? 0 : dailySum / dailyCount,
    );
  }

  /// 分类统计（仅当前持有物品）。
  static List<CategoryStats> byCategory(
    List<Item> items,
    Map<String, SaleRecord> salesByItemId, {
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final groups = <String, List<Item>>{};
    for (final item in items.where(inHistory).where(isOwned)) {
      groups.putIfAbsent(item.categoryId, () => []).add(item);
    }
    final result = <CategoryStats>[];
    for (final e in groups.entries) {
      double dailySum = 0;
      int total = 0;
      for (final item in e.value) {
        total += item.purchasePrice;
        dailySum +=
            ItemCalculator.dailyCost(item, salesByItemId[item.id], now: now_) /
                100;
      }
      result.add(CategoryStats(
        categoryId: e.key,
        categoryName: e.value.first.categoryName,
        count: e.value.length,
        purchaseTotal: total,
        avgDailyCost: dailySum / e.value.length,
      ));
    }
    return result;
  }

  /// 月度趋势，返回按月升序、最近 [months] 个月的数据（含无数据的月份）。
  static List<MonthlyStats> monthlyTrend(
    List<Item> items,
    Map<String, SaleRecord> salesByItemId, {
    int months = 12,
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final keys = <String>[];
    for (int i = months - 1; i >= 0; i--) {
      final d = DateTime(now_.year, now_.month - i);
      keys.add('${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}');
    }
    final byMonth = {for (final k in keys) k: MonthlyStats(k, 0, 0, 0, 0)};

    String keyOf(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}';

    for (final item in items.where(inHistory)) {
      final k = keyOf(item.purchaseDate);
      final m = byMonth[k];
      if (m != null) byMonth[k] = MonthlyStats(k, m.newCount + 1, m.purchaseTotal + item.purchasePrice, m.saleIncome, m.depreciation);
    }
    for (final sale in salesByItemId.values) {
      final k = keyOf(sale.saleDate);
      final m = byMonth[k];
      if (m != null) {
        final item = items.where((i) => i.id == sale.itemId).firstOrNull;
        final dep = item == null
            ? 0
            : ItemCalculator.actualDepreciation(item, sale);
        byMonth[k] = MonthlyStats(k, m.newCount, m.purchaseTotal, m.saleIncome + sale.netIncome, m.depreciation + dep);
      }
    }
    return keys.map((k) => byMonth[k]!).toList();
  }

  /// 日均成本最高/最低（当前持有物品）。
  static List<ValueRanking> dailyCostRanking(
    List<Item> items,
    Map<String, SaleRecord> salesByItemId, {
    bool descending = true,
    int limit = 10,
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final list = items
        .where(inHistory)
        .where(isOwned)
        .map((item) => ValueRanking(
              item,
              salesByItemId[item.id],
              ItemCalculator.dailyCost(item, salesByItemId[item.id], now: now_),
              0,
            ))
        .toList();
    list.sort((a, b) => descending ? b.dailyCost.compareTo(a.dailyCost) : a.dailyCost.compareTo(b.dailyCost));
    return list.take(limit).toList();
  }

  /// 使用时间最长的物品（当前持有）。
  static List<ValueRanking> longestUsedRanking(
    List<Item> items,
    Map<String, SaleRecord> salesByItemId, {
    int limit = 10,
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final list = items.where(inHistory).where(isOwned).map((item) {
      final days =
          ItemCalculator.usedDays(item, salesByItemId[item.id], now: now_);
      return ValueRanking(item, salesByItemId[item.id], 0, days.toDouble());
    }).toList();
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(limit).toList();
  }

  /// 保值率最高的已转卖物品。
  static List<ValueRanking> retentionRanking(
    List<Item> items,
    Map<String, SaleRecord> salesByItemId, {
    int limit = 10,
  }) {
    final list = <ValueRanking>[];
    for (final item in items.where(inHistory)) {
      final sale = salesByItemId[item.id];
      if (sale == null) continue;
      final rate = ItemCalculator.retentionRate(item, sale);
      if (rate == null) continue;
      list.add(ValueRanking(item, sale, 0, rate));
    }
    list.sort((a, b) => b.value.compareTo(a.value));
    return list.take(limit).toList();
  }
}
