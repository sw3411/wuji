/// 月度预算使用状态（纯函数，便于测试）。
class BudgetStatus {
  const BudgetStatus(this.spentCents, this.budgetCents);

  /// 本月已花费（分）。
  final int spentCents;

  /// 月度预算（分）。0 = 未设置。
  final int budgetCents;

  /// 预算未设置时返回 null，调用方据此隐藏预算 UI。
  static BudgetStatus? evaluate(int spentCents, int budgetCents) {
    if (budgetCents <= 0) return null;
    return BudgetStatus(spentCents, budgetCents);
  }

  double get ratio => spentCents / budgetCents;

  /// 剩余额度（分），可为负（超支）。
  int get remainingCents => budgetCents - spentCents;

  BudgetLevel get level {
    if (ratio >= 1) return BudgetLevel.exceeded;
    if (ratio >= 0.8) return BudgetLevel.warning;
    return BudgetLevel.ok;
  }
}

enum BudgetLevel {
  /// 使用正常（<80%）。
  ok,

  /// 接近预算（80%~100%）。
  warning,

  /// 已超支（≥100%）。
  exceeded,
}
