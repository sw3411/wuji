import 'enums.dart';

/// 物品。金额均以最小货币单位（分）整数存储，避免浮点精度问题。
class Item {
  Item({
    required this.id,
    required this.name,
    this.coverImagePath,
    this.additionalImagePaths = const [],
    required this.categoryId,
    required this.categoryName,
    required this.purchasePrice,
    this.currency = 'CNY',
    required this.purchaseDate,
    this.purchaseChannel,
    this.merchantName,
    this.orderNumber,
    this.brand,
    this.model,
    this.quantity = 1,
    this.status = ItemStatus.inUse,
    this.locationId,
    this.locationName,
    this.locationDetail,
    this.locationImagePath,
    this.notes,
    this.tags = const [],
    this.isFavorite = false,
    this.scoreValue,
    this.scoreUsage,
    this.scoreFavorite,
    this.scoreUtilization,
    this.scoreCost,
    this.scoreRetention,
    this.overallScore,
    this.warrantyMonths,
    this.warrantyEndDate,
    this.maintenanceMonths,
    this.usageFrequency,
    this.aiTags,
    this.aiTagsSourceName,
    this.invoiceImagePaths = const [],
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final String id;
  final String name;
  final String? coverImagePath;
  final List<String> additionalImagePaths;
  final String categoryId;
  final String categoryName;
  final int purchasePrice;
  final String currency;
  final DateTime purchaseDate;
  final String? purchaseChannel;
  final String? merchantName;
  final String? orderNumber;
  final String? brand;
  final String? model;
  final int quantity;
  final ItemStatus status;
  final String? locationId;
  final String? locationName;
  final String? locationDetail;
  final String? locationImagePath;
  final String? notes;
  final List<String> tags;
  final bool isFavorite;

  /// 六维评分（0-10，null=未评分）。
  final int? scoreValue;
  final int? scoreUsage;
  final int? scoreFavorite;
  final int? scoreUtilization;
  final int? scoreCost;
  final int? scoreRetention;

  /// 总评分（0-100）。
  final int? overallScore;
  final int? warrantyMonths;
  final DateTime? warrantyEndDate;

  /// 耗材保养周期（月）。null = 不提醒。
  final int? maintenanceMonths;

  /// 使用频次。null = 未填写。
  final UsageFrequency? usageFrequency;

  /// AI 生成的检索标签（每天后台更新）。null = 尚未打标。
  final List<String>? aiTags;

  /// 打标时的物品名称，名称变更后视为标签过时需重打。
  final String? aiTagsSourceName;
  final List<String> invoiceImagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  bool get isDeleted => deletedAt != null;

  /// 保修截止日期：优先使用显式日期，否则按购买日期 + 保修月数推导。
  DateTime? get effectiveWarrantyEndDate {
    if (warrantyEndDate != null) return warrantyEndDate;
    if (warrantyMonths != null) {
      return DateTime(
        purchaseDate.year,
        purchaseDate.month + warrantyMonths!,
        purchaseDate.day,
      );
    }
    return null;
  }

  Item copyWith({
    String? name,
    String? coverImagePath,
    bool clearCover = false,
    List<String>? additionalImagePaths,
    String? categoryId,
    String? categoryName,
    int? purchasePrice,
    String? currency,
    DateTime? purchaseDate,
    String? purchaseChannel,
    String? merchantName,
    String? orderNumber,
    String? brand,
    String? model,
    int? quantity,
    ItemStatus? status,
    String? locationId,
    bool clearLocation = false,
    String? locationName,
    String? locationDetail,
    String? locationImagePath,
    String? notes,
    List<String>? tags,
    bool? isFavorite,
    int? scoreValue,
    int? scoreUsage,
    int? scoreFavorite,
    int? scoreUtilization,
    int? scoreCost,
    int? scoreRetention,
    int? overallScore,
    int? warrantyMonths,
    DateTime? warrantyEndDate,
    int? maintenanceMonths,
    UsageFrequency? usageFrequency,
    List<String>? aiTags,
    String? aiTagsSourceName,
    List<String>? invoiceImagePaths,
    DateTime? deletedAt,
  }) =>
      Item(
        id: id,
        name: name ?? this.name,
        coverImagePath: clearCover ? null : (coverImagePath ?? this.coverImagePath),
        additionalImagePaths: additionalImagePaths ?? this.additionalImagePaths,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        currency: currency ?? this.currency,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        purchaseChannel: purchaseChannel ?? this.purchaseChannel,
        merchantName: merchantName ?? this.merchantName,
        orderNumber: orderNumber ?? this.orderNumber,
        brand: brand ?? this.brand,
        model: model ?? this.model,
        quantity: quantity ?? this.quantity,
        status: status ?? this.status,
        locationId:
            clearLocation ? null : (locationId ?? this.locationId),
        locationName: clearLocation ? null : (locationName ?? this.locationName),
        locationDetail: locationDetail ?? this.locationDetail,
        locationImagePath: locationImagePath ?? this.locationImagePath,
        notes: notes ?? this.notes,
        tags: tags ?? this.tags,
        isFavorite: isFavorite ?? this.isFavorite,
        scoreValue: scoreValue ?? this.scoreValue,
        scoreUsage: scoreUsage ?? this.scoreUsage,
        scoreFavorite: scoreFavorite ?? this.scoreFavorite,
        scoreUtilization: scoreUtilization ?? this.scoreUtilization,
        scoreCost: scoreCost ?? this.scoreCost,
        scoreRetention: scoreRetention ?? this.scoreRetention,
        overallScore: overallScore ?? this.overallScore,
        warrantyMonths: warrantyMonths ?? this.warrantyMonths,
        warrantyEndDate: warrantyEndDate ?? this.warrantyEndDate,
        maintenanceMonths: maintenanceMonths ?? this.maintenanceMonths,
        usageFrequency: usageFrequency ?? this.usageFrequency,
        aiTags: aiTags ?? this.aiTags,
        aiTagsSourceName: aiTagsSourceName ?? this.aiTagsSourceName,
        invoiceImagePaths: invoiceImagePaths ?? this.invoiceImagePaths,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
        deletedAt: deletedAt,
      );

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'] as String,
        name: json['name'] as String,
        coverImagePath: json['coverImagePath'] as String?,
        additionalImagePaths:
            (json['additionalImagePaths'] as List<dynamic>? ?? const [])
                .map((e) => e as String)
                .toList(),
        categoryId: json['categoryId'] as String,
        categoryName: json['categoryName'] as String,
        purchasePrice: (json['purchasePrice'] as num).toInt(),
        currency: json['currency'] as String? ?? 'CNY',
        purchaseDate: DateTime.parse(json['purchaseDate'] as String),
        purchaseChannel: json['purchaseChannel'] as String?,
        merchantName: json['merchantName'] as String?,
        orderNumber: json['orderNumber'] as String?,
        brand: json['brand'] as String?,
        model: json['model'] as String?,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        status: ItemStatus.fromName(json['status'] as String),
        locationId: json['locationId'] as String?,
        locationName: json['locationName'] as String?,
        locationDetail: json['locationDetail'] as String?,
        locationImagePath: json['locationImagePath'] as String?,
        notes: json['notes'] as String?,
        tags: (json['tags'] as List<dynamic>? ?? const [])
            .map((e) => e as String)
            .toList(),
        isFavorite: json['isFavorite'] as bool? ?? false,
        scoreValue: (json['scoreValue'] as num?)?.toInt(),
        scoreUsage: (json['scoreUsage'] as num?)?.toInt(),
        scoreFavorite: (json['scoreFavorite'] as num?)?.toInt(),
        scoreUtilization: (json['scoreUtilization'] as num?)?.toInt(),
        scoreCost: (json['scoreCost'] as num?)?.toInt(),
        scoreRetention: (json['scoreRetention'] as num?)?.toInt(),
        overallScore: (json['overallScore'] as num?)?.toInt(),
        maintenanceMonths: (json['maintenanceMonths'] as num?)?.toInt(),
        usageFrequency: UsageFrequency.fromName(json['usageFrequency'] as String?),
        aiTags: (json['aiTags'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList(),
        aiTagsSourceName: json['aiTagsSourceName'] as String?,
        warrantyMonths: (json['warrantyMonths'] as num?)?.toInt(),
        warrantyEndDate: json['warrantyEndDate'] == null
            ? null
            : DateTime.parse(json['warrantyEndDate'] as String),
        invoiceImagePaths:
            (json['invoiceImagePaths'] as List<dynamic>? ?? const [])
                .map((e) => e as String)
                .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        deletedAt: json['deletedAt'] == null
            ? null
            : DateTime.parse(json['deletedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'coverImagePath': coverImagePath,
        'additionalImagePaths': additionalImagePaths,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'purchasePrice': purchasePrice,
        'currency': currency,
        'purchaseDate': purchaseDate.toIso8601String(),
        'purchaseChannel': purchaseChannel,
        'merchantName': merchantName,
        'orderNumber': orderNumber,
        'brand': brand,
        'model': model,
        'quantity': quantity,
        'status': status.name,
        'locationId': locationId,
        'locationName': locationName,
        'locationDetail': locationDetail,
        'locationImagePath': locationImagePath,
        'notes': notes,
        'tags': tags,
        'isFavorite': isFavorite,
        'scoreValue': scoreValue,
        'scoreUsage': scoreUsage,
        'scoreFavorite': scoreFavorite,
        'scoreUtilization': scoreUtilization,
        'scoreCost': scoreCost,
        'scoreRetention': scoreRetention,
        'overallScore': overallScore,
        'warrantyMonths': warrantyMonths,
        'maintenanceMonths': maintenanceMonths,
        'usageFrequency': usageFrequency?.name,
        'aiTags': aiTags,
        'aiTagsSourceName': aiTagsSourceName,
        'warrantyEndDate': warrantyEndDate?.toIso8601String(),
        'invoiceImagePaths': invoiceImagePaths,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };
}
