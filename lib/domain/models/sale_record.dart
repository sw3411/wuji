/// 转卖记录。金额均以最小货币单位（分）整数存储。
class SaleRecord {
  SaleRecord({
    required this.id,
    required this.itemId,
    required this.salePrice,
    required this.saleDate,
    this.platform,
    this.buyerNote,
    this.shippingCost = 0,
    this.platformFee = 0,
    this.otherCost = 0,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String itemId;
  final int salePrice;
  final DateTime saleDate;
  final String? platform;
  final String? buyerNote;
  final int shippingCost;
  final int platformFee;
  final int otherCost;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// 转卖总成本 = 运费 + 平台手续费 + 其他成本。
  int get totalCost => shippingCost + platformFee + otherCost;

  /// 转卖净收入 = 转卖价格 - 运费 - 平台手续费 - 其他转卖成本。
  int get netIncome => salePrice - totalCost;

  SaleRecord copyWith({
    int? salePrice,
    DateTime? saleDate,
    String? platform,
    String? buyerNote,
    int? shippingCost,
    int? platformFee,
    int? otherCost,
    String? notes,
  }) =>
      SaleRecord(
        id: id,
        itemId: itemId,
        salePrice: salePrice ?? this.salePrice,
        saleDate: saleDate ?? this.saleDate,
        platform: platform ?? this.platform,
        buyerNote: buyerNote ?? this.buyerNote,
        shippingCost: shippingCost ?? this.shippingCost,
        platformFee: platformFee ?? this.platformFee,
        otherCost: otherCost ?? this.otherCost,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );

  factory SaleRecord.fromJson(Map<String, dynamic> json) => SaleRecord(
        id: json['id'] as String,
        itemId: json['itemId'] as String,
        salePrice: (json['salePrice'] as num).toInt(),
        saleDate: DateTime.parse(json['saleDate'] as String),
        platform: json['platform'] as String?,
        buyerNote: json['buyerNote'] as String?,
        shippingCost: (json['shippingCost'] as num?)?.toInt() ?? 0,
        platformFee: (json['platformFee'] as num?)?.toInt() ?? 0,
        otherCost: (json['otherCost'] as num?)?.toInt() ?? 0,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'salePrice': salePrice,
        'saleDate': saleDate.toIso8601String(),
        'platform': platform,
        'buyerNote': buyerNote,
        'shippingCost': shippingCost,
        'platformFee': platformFee,
        'otherCost': otherCost,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

/// 转卖常用平台。
const List<String> kSalePlatforms = [
  '闲鱼',
  '转转',
  '爱回收',
  '线下交易',
  '其他',
];
