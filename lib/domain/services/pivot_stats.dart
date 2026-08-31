import '../models/item.dart';
import '../models/sale_record.dart';
import 'item_calculator.dart';

/// 透视表维度。
enum PivotDim { category, location, status }

/// 透视表一行：某个维度值下的全部指标。
class PivotRow {
  const PivotRow({
    required this.label,
    required this.count,
    required this.totalCostCents,
    required this.dailySum,
    required this.yearNewCount,
    required this.yearNewAmountCents,
    this.yoyDelta,
    required this.monthNewCount,
    required this.monthNewAmountCents,
    this.momDelta,
  });

  final String label;

  /// 当前持有件数（维度内）。
  final int count;

  /// 当前持有总成本（分）。
  final int totalCostCents;

  /// 日总成本（元/天，逐件日均之和）。
  final double dailySum;

  /// 年新增 件数 / 金额（分）。
  final int yearNewCount;
  final int yearNewAmountCents;

  /// 年环比：本年新增金额 - 上年新增金额（分，null=无基数）。
  final int? yoyDelta;

  /// 月新增 件数 / 金额（分）。
  final int monthNewCount;
  final int monthNewAmountCents;

  /// 月环比：本月新增金额 - 上月（分，null=无基数）。
  final int? momDelta;
}

/// 透视表计算（纯函数，便于测试）。
class PivotStats {
  const PivotStats._();

  /// [anchorYear]：年锚点；[anchorMonth]：月锚点（取任意该月内日期）。
  /// [categoryIds]/[locationIds]：非空时只统计命中物品。
  /// 返回按总成本降序的行列表，末尾附「汇总」行。
  static List<PivotRow> compute(
    List<Item> items,
    Map<String, SaleRecord> sales, {
    required PivotDim dim,
    required int anchorYear,
    required DateTime anchorMonth,
    Set<String>? categoryIds,
    Set<String>? locationIds,
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final pool = items.where((i) {
      if (i.isDeleted) return false;
      if (categoryIds != null && categoryIds.isNotEmpty &&
          !categoryIds.contains(i.categoryId)) {
        return false;
      }
      if (locationIds != null && locationIds.isNotEmpty &&
          (i.locationId == null || !locationIds.contains(i.locationId))) {
        return false;
      }
      return true;
    }).toList();

    final yearStart = DateTime(anchorYear);
    final yearEnd = DateTime(anchorYear + 1);
    final prevYearStart = DateTime(anchorYear - 1);
    final mStart = DateTime(anchorMonth.year, anchorMonth.month);
    final mEnd = DateTime(anchorMonth.year, anchorMonth.month + 1);
    final prevMStart = DateTime(anchorMonth.year, anchorMonth.month - 1);

    String keyOf(Item i) => switch (dim) {
          PivotDim.category => i.categoryName,
          PivotDim.location => i.locationName ?? '未设位置',
          PivotDim.status => i.status.label,
        };

    // 分桶。
    final buckets = <String, List<Item>>{};
    for (final i in pool) {
      buckets.putIfAbsent(keyOf(i), () => []).add(i);
    }

    PivotRow rowOf(String label, List<Item> list) {
      var count = 0, total = 0;
      double daily = 0;
      var yNew = 0, yAmt = 0, prevYAmt = 0;
      var mNew = 0, mAmt = 0, prevMAmt = 0;
      for (final i in list) {
        if (i.status.isOwned) {
          count++;
          total += i.purchasePrice;
          daily += ItemCalculator.dailyCost(i, sales[i.id], now: now_) / 100;
        }
        final d = i.purchaseDate;
        if (!d.isBefore(yearStart) && d.isBefore(yearEnd)) {
          yNew++;
          yAmt += i.purchasePrice;
        } else if (!d.isBefore(prevYearStart) && d.isBefore(yearStart)) {
          prevYAmt += i.purchasePrice;
        }
        if (!d.isBefore(mStart) && d.isBefore(mEnd)) {
          mNew++;
          mAmt += i.purchasePrice;
        } else if (!d.isBefore(prevMStart) && d.isBefore(mStart)) {
          prevMAmt += i.purchasePrice;
        }
      }
      return PivotRow(
        label: label,
        count: count,
        totalCostCents: total,
        dailySum: daily,
        yearNewCount: yNew,
        yearNewAmountCents: yAmt,
        yoyDelta: _delta(yAmt, prevYAmt),
        monthNewCount: mNew,
        monthNewAmountCents: mAmt,
        momDelta: _delta(mAmt, prevMAmt),
      );
    }

    final rows = [
      for (final e in buckets.entries) rowOf(e.key, e.value),
    ]..sort((a, b) => b.totalCostCents.compareTo(a.totalCostCents));

    rows.add(rowOf('汇总', pool));
    return rows;
  }

  /// 绝对差：cur - prev。双零 → null（—）；上年无基数但本期有 → 视为全额上涨。
  static int? _delta(int cur, int prev) {
    if (prev <= 0) return cur > 0 ? cur : null;
    return cur - prev;
  }
}
