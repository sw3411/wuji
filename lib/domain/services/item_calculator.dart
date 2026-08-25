import '../../core/utils/formatters.dart';
import '../models/enums.dart';
import '../models/item.dart';
import '../models/sale_record.dart';

/// 物品使用天数、日均成本、实际损耗、保值率的核心计算。
/// 全部为纯函数，便于单元测试。
class ItemCalculator {
  ItemCalculator._();

  /// 使用/持有天数。
  /// 未转卖：当前日期 - 购买日期 + 1。
  /// 已转卖：转卖日期 - 购买日期 + 1。
  /// 当天购买则为 1，避免除以 0。
  static int usedDays(Item item, SaleRecord? sale, {DateTime? now}) {
    final end = (item.status.isSoldForCalc && sale != null)
        ? sale.saleDate
        : (now ?? DateTime.now());
    final days = Fmt.daysBetween(item.purchaseDate, end) + 1;
    return days < 1 ? 1 : days;
  }

  /// 实际损耗成本（分）= 购买价格 - 转卖净收入。
  /// 为负表示转卖产生了收益。
  static int actualDepreciation(Item item, SaleRecord? sale) {
    if (sale == null) return item.purchasePrice;
    return item.purchasePrice - sale.netIncome;
  }

  /// 当前日均成本（分/天）。
  /// 未转卖：购买价格 / 使用天数。
  /// 已转卖：实际损耗成本 / 使用天数。
  /// 结果可能为负，表示“日均收益”，由展示层决定文案。
  static int dailyCost(Item item, SaleRecord? sale, {DateTime? now}) {
    final days = usedDays(item, sale, now: now);
    final base = (item.status.isSoldForCalc && sale != null)
        ? actualDepreciation(item, sale)
        : item.purchasePrice;
    return (base / days).round();
  }

  /// 保值率（0~1 或更高）。仅对已转卖物品有意义，未转卖返回 null。
  static double? retentionRate(Item item, SaleRecord? sale) {
    if (sale == null || item.purchasePrice <= 0) return null;
    return sale.netIncome / item.purchasePrice;
  }

  /// 持有时间描述。
  static String holdingText(Item item, SaleRecord? sale, {DateTime? now}) {
    final days = usedDays(item, sale, now: now);
    switch (item.status) {
      case ItemStatus.discarded:
      case ItemStatus.consumed:
      case ItemStatus.lost:
        return '共使用 $days 天';
      case ItemStatus.sold:
      case ItemStatus.gifted:
        return '共持有 $days 天';
      default:
        return '已持有 $days 天';
    }
  }

  /// 是否即将过保（含已过保）。
  /// 返回 null 表示无保修信息。
  static WarrantyState? warrantyState(Item item, {DateTime? now}) {
    final end = item.effectiveWarrantyEndDate;
    if (end == null) return null;
    final today = Fmt.dayOnly(now ?? DateTime.now());
    final endDay = Fmt.dayOnly(end);
    if (today.isAfter(endDay)) return WarrantyState.expired;
    final daysLeft = Fmt.daysBetween(today, endDay);
    if (daysLeft <= 30) return WarrantyState.expiringSoon;
    return WarrantyState.active;
  }

  /// 下次保养/耗材更换日：从购买日按周期循环推进，
  /// 返回不早于当前的第一个周期点。未设周期返回 null。
  /// 每次都从购买日按整数倍推算，避免月末（如 31 日）循环漂移。
  static DateTime? nextMaintenanceDate(Item item, {DateTime? now}) {
    final months = item.maintenanceMonths;
    if (months == null || months <= 0) return null;
    final n = now ?? DateTime.now();
    for (var k = 1; k <= 1200; k++) {
      final candidate = _addMonthsClamped(item.purchaseDate, k * months);
      if (!candidate.isBefore(n)) return candidate;
    }
    return null;
  }

  /// 加月数，日期按目标月天数截断（1月31日 + 1月 = 2月28日）。
  static DateTime _addMonthsClamped(DateTime d, int months) {
    final total = d.month - 1 + months;
    final year = d.year + total ~/ 12;
    final month = total % 12 + 1;
    final lastDay = DateTime(year, month + 1, 0).day;
    return DateTime(year, month, d.day < lastDay ? d.day : lastDay);
  }

  // ---------- 价值评估：成本 × 时长 × 频次 × 品类刚需度 ----------

  /// 品类刚需度：高成本 ≠ 不值（车贵但是刚需）。
  static NecessityLevel necessityOf(String categoryName) {
    const necessary = ['家用', '电器', '厨房', '家具', '家装', '医疗', '健康',
        '母婴', '食品', '手机', '电脑', '办公', '汽车', '工具', '宠物'];
    const enjoyment = ['珠宝', '收藏', '玩具', '乐器'];
    for (final k in necessary) {
      if (categoryName.contains(k)) return NecessityLevel.necessary;
    }
    for (final k in enjoyment) {
      if (categoryName.contains(k)) return NecessityLevel.enjoyment;
    }
    return NecessityLevel.improved;
  }

  /// 月均使用次数：未填频次时按状态粗估（闲置 ≈ 几乎不用，其余按每周一次）。
  static double frequencyPerMonth(Item item) =>
      item.usageFrequency?.perMonth ??
      (item.status == ItemStatus.idle ? 0.25 : 4);

  /// 估算累计使用次数（频次 × 持有月数）。
  static double estimatedUseCount(Item item, {DateTime? now}) {
    final days = usedDays(item, null, now: now).clamp(0, 36500);
    return frequencyPerMonth(item) * days / 30;
  }

  /// 单次使用成本（分）。使用次数不足 1 次时等于总价。
  static int costPerUse(Item item, {DateTime? now}) {
    final count = estimatedUseCount(item, now: now);
    if (count < 1) return item.purchasePrice;
    return (item.purchasePrice / count).round();
  }

  /// 综合价值评分（0-100）。
  ///
  /// 构成：成本性价比 35 + 频次 30 + 持有时长 20 + 品类刚需度 15。
  /// 成本性价比按“多少次使用回本”计算：50 次以上回本为满分。
  static ValueAssessment assessValue(Item item, {DateTime? now}) {
    final necessity = necessityOf(item.categoryName);
    final freq = frequencyPerMonth(item);
    final months = usedDays(item, null, now: now) / 30;
    final uses = estimatedUseCount(item, now: now);
    // uses 次使用后回本 → 每次摊薄 1/uses；50 次回本（2%）为满分线。
    final costScore = item.purchasePrice == 0
        ? 1.0
        : (1.0 - 2.0 / (uses < 1 ? 1 : uses)).clamp(0.0, 1.0);
    final freqScore = (freq / 8).clamp(0.0, 1.0);
    final durationScore = (months / 12).clamp(0.0, 1.0);
    final necessityScore = necessity.factor;
    final score = (costScore * 35 +
            freqScore * 30 +
            durationScore * 20 +
            necessityScore * 15)
        .round()
        .clamp(0, 100);
    return ValueAssessment(
      score: score,
      costPerUseCents: costPerUse(item, now: now),
      necessity: necessity,
      estimatedUses: uses,
    );
  }
}

/// 一次价值评估的结果。
class ValueAssessment {
  const ValueAssessment({
    required this.score,
    required this.costPerUseCents,
    required this.necessity,
    required this.estimatedUses,
  });

  final int score;
  final int costPerUseCents;
  final NecessityLevel necessity;

  /// 估算的累计使用次数。
  final double estimatedUses;

  ValueGrade get grade {
    if (score >= 80) return ValueGrade.great;
    if (score >= 60) return ValueGrade.fair;
    if (score >= 40) return ValueGrade.ok;
    return ValueGrade.poor;
  }
}

enum ValueGrade {
  great('超值'),
  fair('物有所值'),
  ok('一般'),
  poor('不划算');

  const ValueGrade(this.label);
  final String label;
}

extension ItemStatusCalc on ItemStatus {
  /// 计算口径上是否按“已转卖”处理。
  bool get isSoldForCalc => this == ItemStatus.sold;
}

enum WarrantyState { active, expiringSoon, expired }
