/// 物品状态。受控枚举，禁止在业务代码中使用散乱字符串。
enum ItemStatus {
  inUse('使用中'),
  idle('闲置'),
  stored('收纳中'),
  lent('已借出'),
  repairing('维修中'),
  consumed('已消耗'),
  lost('已丢失'),
  discarded('已丢弃'),
  sold('已转卖'),
  gifted('已赠送');

  const ItemStatus(this.label);
  final String label;

  /// 该状态下物品是否仍属于用户（计入当前持有资产）。
  bool get isOwned =>
      this == ItemStatus.inUse ||
      this == ItemStatus.idle ||
      this == ItemStatus.stored ||
      this == ItemStatus.lent ||
      this == ItemStatus.repairing;

  static ItemStatus fromName(String name) => ItemStatus.values.firstWhere(
    (e) => e.name == name,
    orElse: () => ItemStatus.inUse,
  );
}

/// 物品生命周期事件类型。
enum ItemEventType {
  purchased('购买'),
  moved('移动'),
  maintained('保养'),
  repaired('维修'),
  lent('借出'),
  returned('归还'),
  sold('转卖'),
  gifted('赠送'),
  discarded('丢弃'),
  lost('丢失'),
  custom('其他');

  const ItemEventType(this.label);
  final String label;

  static ItemEventType fromName(String name) => ItemEventType.values.firstWhere(
    (e) => e.name == name,
    orElse: () => ItemEventType.custom,
  );
}

/// 购买渠道。首个为默认值。
enum PurchaseChannel {
  taobao('淘宝'),
  jd('京东'),
  pdd('拼多多'),
  offline('线下门店'),
  friendTransfer('朋友转让'),
  gift('礼物'),
  other('其他');

  const PurchaseChannel(this.label);
  final String label;

  static PurchaseChannel? fromLabel(String? label) {
    if (label == null) return null;
    for (final c in PurchaseChannel.values) {
      if (c.label == label) return c;
    }
    return null;
  }
}

/// 使用频次：价值评估的输入之一。
enum UsageFrequency {
  daily('每天用', 30),
  often('每周 3 次以上', 12),
  weekly('每周一次', 4),
  sometimes('每月几次', 2.5),
  monthly('每月一次', 1),
  rarely('几乎不用', 0.25);

  const UsageFrequency(this.label, this.perMonth);

  final String label;

  /// 折算的每月使用次数，用于估算单次使用成本。
  final double perMonth;

  static UsageFrequency? fromName(String? name) {
    if (name == null) return null;
    for (final e in UsageFrequency.values) {
      if (e.name == name) return e;
    }
    return null;
  }
}

/// 品类刚需度：高成本不等于不值（如车是刚需）。
enum NecessityLevel {
  necessary('刚需', 1.0),
  improved('改善型', 0.6),
  enjoyment('悦己型', 0.3);

  const NecessityLevel(this.label, this.factor);

  final String label;

  /// 价值评分权重系数。
  final double factor;
}
