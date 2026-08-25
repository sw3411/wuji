// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ItemsTable extends Items with TableInfo<$ItemsTable, ItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverImagePathMeta = const VerificationMeta(
    'coverImagePath',
  );
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
    'cover_image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _additionalImagePathsMeta =
      const VerificationMeta('additionalImagePaths');
  @override
  late final GeneratedColumn<String> additionalImagePaths =
      GeneratedColumn<String>(
        'additional_image_paths',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryNameMeta = const VerificationMeta(
    'categoryName',
  );
  @override
  late final GeneratedColumn<String> categoryName = GeneratedColumn<String>(
    'category_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<int> purchasePrice = GeneratedColumn<int>(
    'purchase_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CNY'),
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseChannelMeta = const VerificationMeta(
    'purchaseChannel',
  );
  @override
  late final GeneratedColumn<String> purchaseChannel = GeneratedColumn<String>(
    'purchase_channel',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _merchantNameMeta = const VerificationMeta(
    'merchantName',
  );
  @override
  late final GeneratedColumn<String> merchantName = GeneratedColumn<String>(
    'merchant_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderNumberMeta = const VerificationMeta(
    'orderNumber',
  );
  @override
  late final GeneratedColumn<String> orderNumber = GeneratedColumn<String>(
    'order_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationNameMeta = const VerificationMeta(
    'locationName',
  );
  @override
  late final GeneratedColumn<String> locationName = GeneratedColumn<String>(
    'location_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationDetailMeta = const VerificationMeta(
    'locationDetail',
  );
  @override
  late final GeneratedColumn<String> locationDetail = GeneratedColumn<String>(
    'location_detail',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationImagePathMeta = const VerificationMeta(
    'locationImagePath',
  );
  @override
  late final GeneratedColumn<String> locationImagePath =
      GeneratedColumn<String>(
        'location_image_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _scoreValueMeta = const VerificationMeta(
    'scoreValue',
  );
  @override
  late final GeneratedColumn<int> scoreValue = GeneratedColumn<int>(
    'score_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreUsageMeta = const VerificationMeta(
    'scoreUsage',
  );
  @override
  late final GeneratedColumn<int> scoreUsage = GeneratedColumn<int>(
    'score_usage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreFavoriteMeta = const VerificationMeta(
    'scoreFavorite',
  );
  @override
  late final GeneratedColumn<int> scoreFavorite = GeneratedColumn<int>(
    'score_favorite',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreUtilizationMeta = const VerificationMeta(
    'scoreUtilization',
  );
  @override
  late final GeneratedColumn<int> scoreUtilization = GeneratedColumn<int>(
    'score_utilization',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreCostMeta = const VerificationMeta(
    'scoreCost',
  );
  @override
  late final GeneratedColumn<int> scoreCost = GeneratedColumn<int>(
    'score_cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _scoreRetentionMeta = const VerificationMeta(
    'scoreRetention',
  );
  @override
  late final GeneratedColumn<int> scoreRetention = GeneratedColumn<int>(
    'score_retention',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overallScoreMeta = const VerificationMeta(
    'overallScore',
  );
  @override
  late final GeneratedColumn<int> overallScore = GeneratedColumn<int>(
    'overall_score',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warrantyMonthsMeta = const VerificationMeta(
    'warrantyMonths',
  );
  @override
  late final GeneratedColumn<int> warrantyMonths = GeneratedColumn<int>(
    'warranty_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warrantyEndDateMeta = const VerificationMeta(
    'warrantyEndDate',
  );
  @override
  late final GeneratedColumn<DateTime> warrantyEndDate =
      GeneratedColumn<DateTime>(
        'warranty_end_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _maintenanceMonthsMeta = const VerificationMeta(
    'maintenanceMonths',
  );
  @override
  late final GeneratedColumn<int> maintenanceMonths = GeneratedColumn<int>(
    'maintenance_months',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageFrequencyMeta = const VerificationMeta(
    'usageFrequency',
  );
  @override
  late final GeneratedColumn<String> usageFrequency = GeneratedColumn<String>(
    'usage_frequency',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _aiTagsMeta = const VerificationMeta('aiTags');
  @override
  late final GeneratedColumn<String> aiTags = GeneratedColumn<String>(
    'ai_tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceImagePathsMeta = const VerificationMeta(
    'invoiceImagePaths',
  );
  @override
  late final GeneratedColumn<String> invoiceImagePaths =
      GeneratedColumn<String>(
        'invoice_image_paths',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    coverImagePath,
    additionalImagePaths,
    categoryId,
    categoryName,
    purchasePrice,
    currency,
    purchaseDate,
    purchaseChannel,
    merchantName,
    orderNumber,
    brand,
    model,
    quantity,
    status,
    locationId,
    locationName,
    locationDetail,
    locationImagePath,
    notes,
    tags,
    isFavorite,
    scoreValue,
    scoreUsage,
    scoreFavorite,
    scoreUtilization,
    scoreCost,
    scoreRetention,
    overallScore,
    warrantyMonths,
    warrantyEndDate,
    maintenanceMonths,
    usageFrequency,
    aiTags,
    invoiceImagePaths,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
        _coverImagePathMeta,
        coverImagePath.isAcceptableOrUnknown(
          data['cover_image_path']!,
          _coverImagePathMeta,
        ),
      );
    }
    if (data.containsKey('additional_image_paths')) {
      context.handle(
        _additionalImagePathsMeta,
        additionalImagePaths.isAcceptableOrUnknown(
          data['additional_image_paths']!,
          _additionalImagePathsMeta,
        ),
      );
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('category_name')) {
      context.handle(
        _categoryNameMeta,
        categoryName.isAcceptableOrUnknown(
          data['category_name']!,
          _categoryNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_categoryNameMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchasePriceMeta);
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_purchaseDateMeta);
    }
    if (data.containsKey('purchase_channel')) {
      context.handle(
        _purchaseChannelMeta,
        purchaseChannel.isAcceptableOrUnknown(
          data['purchase_channel']!,
          _purchaseChannelMeta,
        ),
      );
    }
    if (data.containsKey('merchant_name')) {
      context.handle(
        _merchantNameMeta,
        merchantName.isAcceptableOrUnknown(
          data['merchant_name']!,
          _merchantNameMeta,
        ),
      );
    }
    if (data.containsKey('order_number')) {
      context.handle(
        _orderNumberMeta,
        orderNumber.isAcceptableOrUnknown(
          data['order_number']!,
          _orderNumberMeta,
        ),
      );
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('location_name')) {
      context.handle(
        _locationNameMeta,
        locationName.isAcceptableOrUnknown(
          data['location_name']!,
          _locationNameMeta,
        ),
      );
    }
    if (data.containsKey('location_detail')) {
      context.handle(
        _locationDetailMeta,
        locationDetail.isAcceptableOrUnknown(
          data['location_detail']!,
          _locationDetailMeta,
        ),
      );
    }
    if (data.containsKey('location_image_path')) {
      context.handle(
        _locationImagePathMeta,
        locationImagePath.isAcceptableOrUnknown(
          data['location_image_path']!,
          _locationImagePathMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('score_value')) {
      context.handle(
        _scoreValueMeta,
        scoreValue.isAcceptableOrUnknown(data['score_value']!, _scoreValueMeta),
      );
    }
    if (data.containsKey('score_usage')) {
      context.handle(
        _scoreUsageMeta,
        scoreUsage.isAcceptableOrUnknown(data['score_usage']!, _scoreUsageMeta),
      );
    }
    if (data.containsKey('score_favorite')) {
      context.handle(
        _scoreFavoriteMeta,
        scoreFavorite.isAcceptableOrUnknown(
          data['score_favorite']!,
          _scoreFavoriteMeta,
        ),
      );
    }
    if (data.containsKey('score_utilization')) {
      context.handle(
        _scoreUtilizationMeta,
        scoreUtilization.isAcceptableOrUnknown(
          data['score_utilization']!,
          _scoreUtilizationMeta,
        ),
      );
    }
    if (data.containsKey('score_cost')) {
      context.handle(
        _scoreCostMeta,
        scoreCost.isAcceptableOrUnknown(data['score_cost']!, _scoreCostMeta),
      );
    }
    if (data.containsKey('score_retention')) {
      context.handle(
        _scoreRetentionMeta,
        scoreRetention.isAcceptableOrUnknown(
          data['score_retention']!,
          _scoreRetentionMeta,
        ),
      );
    }
    if (data.containsKey('overall_score')) {
      context.handle(
        _overallScoreMeta,
        overallScore.isAcceptableOrUnknown(
          data['overall_score']!,
          _overallScoreMeta,
        ),
      );
    }
    if (data.containsKey('warranty_months')) {
      context.handle(
        _warrantyMonthsMeta,
        warrantyMonths.isAcceptableOrUnknown(
          data['warranty_months']!,
          _warrantyMonthsMeta,
        ),
      );
    }
    if (data.containsKey('warranty_end_date')) {
      context.handle(
        _warrantyEndDateMeta,
        warrantyEndDate.isAcceptableOrUnknown(
          data['warranty_end_date']!,
          _warrantyEndDateMeta,
        ),
      );
    }
    if (data.containsKey('maintenance_months')) {
      context.handle(
        _maintenanceMonthsMeta,
        maintenanceMonths.isAcceptableOrUnknown(
          data['maintenance_months']!,
          _maintenanceMonthsMeta,
        ),
      );
    }
    if (data.containsKey('usage_frequency')) {
      context.handle(
        _usageFrequencyMeta,
        usageFrequency.isAcceptableOrUnknown(
          data['usage_frequency']!,
          _usageFrequencyMeta,
        ),
      );
    }
    if (data.containsKey('ai_tags')) {
      context.handle(
        _aiTagsMeta,
        aiTags.isAcceptableOrUnknown(data['ai_tags']!, _aiTagsMeta),
      );
    }
    if (data.containsKey('invoice_image_paths')) {
      context.handle(
        _invoiceImagePathsMeta,
        invoiceImagePaths.isAcceptableOrUnknown(
          data['invoice_image_paths']!,
          _invoiceImagePathsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      coverImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_image_path'],
      ),
      additionalImagePaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}additional_image_paths'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      categoryName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_name'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}purchase_price'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      purchaseChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}purchase_channel'],
      ),
      merchantName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}merchant_name'],
      ),
      orderNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_number'],
      ),
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      ),
      locationName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_name'],
      ),
      locationDetail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_detail'],
      ),
      locationImagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_image_path'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      scoreValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_value'],
      ),
      scoreUsage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_usage'],
      ),
      scoreFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_favorite'],
      ),
      scoreUtilization: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_utilization'],
      ),
      scoreCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_cost'],
      ),
      scoreRetention: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score_retention'],
      ),
      overallScore: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}overall_score'],
      ),
      warrantyMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warranty_months'],
      ),
      warrantyEndDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}warranty_end_date'],
      ),
      maintenanceMonths: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}maintenance_months'],
      ),
      usageFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_frequency'],
      ),
      aiTags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ai_tags'],
      ),
      invoiceImagePaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_image_paths'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class ItemRow extends DataClass implements Insertable<ItemRow> {
  final String id;
  final String name;
  final String? coverImagePath;
  final String additionalImagePaths;
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
  final String status;
  final String? locationId;
  final String? locationName;
  final String? locationDetail;
  final String? locationImagePath;
  final String? notes;
  final String tags;
  final bool isFavorite;
  final int? scoreValue;
  final int? scoreUsage;
  final int? scoreFavorite;
  final int? scoreUtilization;
  final int? scoreCost;
  final int? scoreRetention;
  final int? overallScore;
  final int? warrantyMonths;
  final DateTime? warrantyEndDate;
  final int? maintenanceMonths;
  final String? usageFrequency;
  final String? aiTags;
  final String invoiceImagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const ItemRow({
    required this.id,
    required this.name,
    this.coverImagePath,
    required this.additionalImagePaths,
    required this.categoryId,
    required this.categoryName,
    required this.purchasePrice,
    required this.currency,
    required this.purchaseDate,
    this.purchaseChannel,
    this.merchantName,
    this.orderNumber,
    this.brand,
    this.model,
    required this.quantity,
    required this.status,
    this.locationId,
    this.locationName,
    this.locationDetail,
    this.locationImagePath,
    this.notes,
    required this.tags,
    required this.isFavorite,
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
    required this.invoiceImagePaths,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    map['additional_image_paths'] = Variable<String>(additionalImagePaths);
    map['category_id'] = Variable<String>(categoryId);
    map['category_name'] = Variable<String>(categoryName);
    map['purchase_price'] = Variable<int>(purchasePrice);
    map['currency'] = Variable<String>(currency);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    if (!nullToAbsent || purchaseChannel != null) {
      map['purchase_channel'] = Variable<String>(purchaseChannel);
    }
    if (!nullToAbsent || merchantName != null) {
      map['merchant_name'] = Variable<String>(merchantName);
    }
    if (!nullToAbsent || orderNumber != null) {
      map['order_number'] = Variable<String>(orderNumber);
    }
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    map['quantity'] = Variable<int>(quantity);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || locationName != null) {
      map['location_name'] = Variable<String>(locationName);
    }
    if (!nullToAbsent || locationDetail != null) {
      map['location_detail'] = Variable<String>(locationDetail);
    }
    if (!nullToAbsent || locationImagePath != null) {
      map['location_image_path'] = Variable<String>(locationImagePath);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['tags'] = Variable<String>(tags);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || scoreValue != null) {
      map['score_value'] = Variable<int>(scoreValue);
    }
    if (!nullToAbsent || scoreUsage != null) {
      map['score_usage'] = Variable<int>(scoreUsage);
    }
    if (!nullToAbsent || scoreFavorite != null) {
      map['score_favorite'] = Variable<int>(scoreFavorite);
    }
    if (!nullToAbsent || scoreUtilization != null) {
      map['score_utilization'] = Variable<int>(scoreUtilization);
    }
    if (!nullToAbsent || scoreCost != null) {
      map['score_cost'] = Variable<int>(scoreCost);
    }
    if (!nullToAbsent || scoreRetention != null) {
      map['score_retention'] = Variable<int>(scoreRetention);
    }
    if (!nullToAbsent || overallScore != null) {
      map['overall_score'] = Variable<int>(overallScore);
    }
    if (!nullToAbsent || warrantyMonths != null) {
      map['warranty_months'] = Variable<int>(warrantyMonths);
    }
    if (!nullToAbsent || warrantyEndDate != null) {
      map['warranty_end_date'] = Variable<DateTime>(warrantyEndDate);
    }
    if (!nullToAbsent || maintenanceMonths != null) {
      map['maintenance_months'] = Variable<int>(maintenanceMonths);
    }
    if (!nullToAbsent || usageFrequency != null) {
      map['usage_frequency'] = Variable<String>(usageFrequency);
    }
    if (!nullToAbsent || aiTags != null) {
      map['ai_tags'] = Variable<String>(aiTags);
    }
    map['invoice_image_paths'] = Variable<String>(invoiceImagePaths);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      name: Value(name),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
      additionalImagePaths: Value(additionalImagePaths),
      categoryId: Value(categoryId),
      categoryName: Value(categoryName),
      purchasePrice: Value(purchasePrice),
      currency: Value(currency),
      purchaseDate: Value(purchaseDate),
      purchaseChannel: purchaseChannel == null && nullToAbsent
          ? const Value.absent()
          : Value(purchaseChannel),
      merchantName: merchantName == null && nullToAbsent
          ? const Value.absent()
          : Value(merchantName),
      orderNumber: orderNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(orderNumber),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      quantity: Value(quantity),
      status: Value(status),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      locationName: locationName == null && nullToAbsent
          ? const Value.absent()
          : Value(locationName),
      locationDetail: locationDetail == null && nullToAbsent
          ? const Value.absent()
          : Value(locationDetail),
      locationImagePath: locationImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(locationImagePath),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      tags: Value(tags),
      isFavorite: Value(isFavorite),
      scoreValue: scoreValue == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreValue),
      scoreUsage: scoreUsage == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreUsage),
      scoreFavorite: scoreFavorite == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreFavorite),
      scoreUtilization: scoreUtilization == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreUtilization),
      scoreCost: scoreCost == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreCost),
      scoreRetention: scoreRetention == null && nullToAbsent
          ? const Value.absent()
          : Value(scoreRetention),
      overallScore: overallScore == null && nullToAbsent
          ? const Value.absent()
          : Value(overallScore),
      warrantyMonths: warrantyMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyMonths),
      warrantyEndDate: warrantyEndDate == null && nullToAbsent
          ? const Value.absent()
          : Value(warrantyEndDate),
      maintenanceMonths: maintenanceMonths == null && nullToAbsent
          ? const Value.absent()
          : Value(maintenanceMonths),
      usageFrequency: usageFrequency == null && nullToAbsent
          ? const Value.absent()
          : Value(usageFrequency),
      aiTags: aiTags == null && nullToAbsent
          ? const Value.absent()
          : Value(aiTags),
      invoiceImagePaths: Value(invoiceImagePaths),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory ItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
      additionalImagePaths: serializer.fromJson<String>(
        json['additionalImagePaths'],
      ),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      categoryName: serializer.fromJson<String>(json['categoryName']),
      purchasePrice: serializer.fromJson<int>(json['purchasePrice']),
      currency: serializer.fromJson<String>(json['currency']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      purchaseChannel: serializer.fromJson<String?>(json['purchaseChannel']),
      merchantName: serializer.fromJson<String?>(json['merchantName']),
      orderNumber: serializer.fromJson<String?>(json['orderNumber']),
      brand: serializer.fromJson<String?>(json['brand']),
      model: serializer.fromJson<String?>(json['model']),
      quantity: serializer.fromJson<int>(json['quantity']),
      status: serializer.fromJson<String>(json['status']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      locationName: serializer.fromJson<String?>(json['locationName']),
      locationDetail: serializer.fromJson<String?>(json['locationDetail']),
      locationImagePath: serializer.fromJson<String?>(
        json['locationImagePath'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      tags: serializer.fromJson<String>(json['tags']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      scoreValue: serializer.fromJson<int?>(json['scoreValue']),
      scoreUsage: serializer.fromJson<int?>(json['scoreUsage']),
      scoreFavorite: serializer.fromJson<int?>(json['scoreFavorite']),
      scoreUtilization: serializer.fromJson<int?>(json['scoreUtilization']),
      scoreCost: serializer.fromJson<int?>(json['scoreCost']),
      scoreRetention: serializer.fromJson<int?>(json['scoreRetention']),
      overallScore: serializer.fromJson<int?>(json['overallScore']),
      warrantyMonths: serializer.fromJson<int?>(json['warrantyMonths']),
      warrantyEndDate: serializer.fromJson<DateTime?>(json['warrantyEndDate']),
      maintenanceMonths: serializer.fromJson<int?>(json['maintenanceMonths']),
      usageFrequency: serializer.fromJson<String?>(json['usageFrequency']),
      aiTags: serializer.fromJson<String?>(json['aiTags']),
      invoiceImagePaths: serializer.fromJson<String>(json['invoiceImagePaths']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
      'additionalImagePaths': serializer.toJson<String>(additionalImagePaths),
      'categoryId': serializer.toJson<String>(categoryId),
      'categoryName': serializer.toJson<String>(categoryName),
      'purchasePrice': serializer.toJson<int>(purchasePrice),
      'currency': serializer.toJson<String>(currency),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'purchaseChannel': serializer.toJson<String?>(purchaseChannel),
      'merchantName': serializer.toJson<String?>(merchantName),
      'orderNumber': serializer.toJson<String?>(orderNumber),
      'brand': serializer.toJson<String?>(brand),
      'model': serializer.toJson<String?>(model),
      'quantity': serializer.toJson<int>(quantity),
      'status': serializer.toJson<String>(status),
      'locationId': serializer.toJson<String?>(locationId),
      'locationName': serializer.toJson<String?>(locationName),
      'locationDetail': serializer.toJson<String?>(locationDetail),
      'locationImagePath': serializer.toJson<String?>(locationImagePath),
      'notes': serializer.toJson<String?>(notes),
      'tags': serializer.toJson<String>(tags),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'scoreValue': serializer.toJson<int?>(scoreValue),
      'scoreUsage': serializer.toJson<int?>(scoreUsage),
      'scoreFavorite': serializer.toJson<int?>(scoreFavorite),
      'scoreUtilization': serializer.toJson<int?>(scoreUtilization),
      'scoreCost': serializer.toJson<int?>(scoreCost),
      'scoreRetention': serializer.toJson<int?>(scoreRetention),
      'overallScore': serializer.toJson<int?>(overallScore),
      'warrantyMonths': serializer.toJson<int?>(warrantyMonths),
      'warrantyEndDate': serializer.toJson<DateTime?>(warrantyEndDate),
      'maintenanceMonths': serializer.toJson<int?>(maintenanceMonths),
      'usageFrequency': serializer.toJson<String?>(usageFrequency),
      'aiTags': serializer.toJson<String?>(aiTags),
      'invoiceImagePaths': serializer.toJson<String>(invoiceImagePaths),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  ItemRow copyWith({
    String? id,
    String? name,
    Value<String?> coverImagePath = const Value.absent(),
    String? additionalImagePaths,
    String? categoryId,
    String? categoryName,
    int? purchasePrice,
    String? currency,
    DateTime? purchaseDate,
    Value<String?> purchaseChannel = const Value.absent(),
    Value<String?> merchantName = const Value.absent(),
    Value<String?> orderNumber = const Value.absent(),
    Value<String?> brand = const Value.absent(),
    Value<String?> model = const Value.absent(),
    int? quantity,
    String? status,
    Value<String?> locationId = const Value.absent(),
    Value<String?> locationName = const Value.absent(),
    Value<String?> locationDetail = const Value.absent(),
    Value<String?> locationImagePath = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? tags,
    bool? isFavorite,
    Value<int?> scoreValue = const Value.absent(),
    Value<int?> scoreUsage = const Value.absent(),
    Value<int?> scoreFavorite = const Value.absent(),
    Value<int?> scoreUtilization = const Value.absent(),
    Value<int?> scoreCost = const Value.absent(),
    Value<int?> scoreRetention = const Value.absent(),
    Value<int?> overallScore = const Value.absent(),
    Value<int?> warrantyMonths = const Value.absent(),
    Value<DateTime?> warrantyEndDate = const Value.absent(),
    Value<int?> maintenanceMonths = const Value.absent(),
    Value<String?> usageFrequency = const Value.absent(),
    Value<String?> aiTags = const Value.absent(),
    String? invoiceImagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => ItemRow(
    id: id ?? this.id,
    name: name ?? this.name,
    coverImagePath: coverImagePath.present
        ? coverImagePath.value
        : this.coverImagePath,
    additionalImagePaths: additionalImagePaths ?? this.additionalImagePaths,
    categoryId: categoryId ?? this.categoryId,
    categoryName: categoryName ?? this.categoryName,
    purchasePrice: purchasePrice ?? this.purchasePrice,
    currency: currency ?? this.currency,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    purchaseChannel: purchaseChannel.present
        ? purchaseChannel.value
        : this.purchaseChannel,
    merchantName: merchantName.present ? merchantName.value : this.merchantName,
    orderNumber: orderNumber.present ? orderNumber.value : this.orderNumber,
    brand: brand.present ? brand.value : this.brand,
    model: model.present ? model.value : this.model,
    quantity: quantity ?? this.quantity,
    status: status ?? this.status,
    locationId: locationId.present ? locationId.value : this.locationId,
    locationName: locationName.present ? locationName.value : this.locationName,
    locationDetail: locationDetail.present
        ? locationDetail.value
        : this.locationDetail,
    locationImagePath: locationImagePath.present
        ? locationImagePath.value
        : this.locationImagePath,
    notes: notes.present ? notes.value : this.notes,
    tags: tags ?? this.tags,
    isFavorite: isFavorite ?? this.isFavorite,
    scoreValue: scoreValue.present ? scoreValue.value : this.scoreValue,
    scoreUsage: scoreUsage.present ? scoreUsage.value : this.scoreUsage,
    scoreFavorite: scoreFavorite.present
        ? scoreFavorite.value
        : this.scoreFavorite,
    scoreUtilization: scoreUtilization.present
        ? scoreUtilization.value
        : this.scoreUtilization,
    scoreCost: scoreCost.present ? scoreCost.value : this.scoreCost,
    scoreRetention: scoreRetention.present
        ? scoreRetention.value
        : this.scoreRetention,
    overallScore: overallScore.present ? overallScore.value : this.overallScore,
    warrantyMonths: warrantyMonths.present
        ? warrantyMonths.value
        : this.warrantyMonths,
    warrantyEndDate: warrantyEndDate.present
        ? warrantyEndDate.value
        : this.warrantyEndDate,
    maintenanceMonths: maintenanceMonths.present
        ? maintenanceMonths.value
        : this.maintenanceMonths,
    usageFrequency: usageFrequency.present
        ? usageFrequency.value
        : this.usageFrequency,
    aiTags: aiTags.present ? aiTags.value : this.aiTags,
    invoiceImagePaths: invoiceImagePaths ?? this.invoiceImagePaths,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  ItemRow copyWithCompanion(ItemsCompanion data) {
    return ItemRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
      additionalImagePaths: data.additionalImagePaths.present
          ? data.additionalImagePaths.value
          : this.additionalImagePaths,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryName: data.categoryName.present
          ? data.categoryName.value
          : this.categoryName,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      currency: data.currency.present ? data.currency.value : this.currency,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      purchaseChannel: data.purchaseChannel.present
          ? data.purchaseChannel.value
          : this.purchaseChannel,
      merchantName: data.merchantName.present
          ? data.merchantName.value
          : this.merchantName,
      orderNumber: data.orderNumber.present
          ? data.orderNumber.value
          : this.orderNumber,
      brand: data.brand.present ? data.brand.value : this.brand,
      model: data.model.present ? data.model.value : this.model,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      status: data.status.present ? data.status.value : this.status,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      locationName: data.locationName.present
          ? data.locationName.value
          : this.locationName,
      locationDetail: data.locationDetail.present
          ? data.locationDetail.value
          : this.locationDetail,
      locationImagePath: data.locationImagePath.present
          ? data.locationImagePath.value
          : this.locationImagePath,
      notes: data.notes.present ? data.notes.value : this.notes,
      tags: data.tags.present ? data.tags.value : this.tags,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      scoreValue: data.scoreValue.present
          ? data.scoreValue.value
          : this.scoreValue,
      scoreUsage: data.scoreUsage.present
          ? data.scoreUsage.value
          : this.scoreUsage,
      scoreFavorite: data.scoreFavorite.present
          ? data.scoreFavorite.value
          : this.scoreFavorite,
      scoreUtilization: data.scoreUtilization.present
          ? data.scoreUtilization.value
          : this.scoreUtilization,
      scoreCost: data.scoreCost.present ? data.scoreCost.value : this.scoreCost,
      scoreRetention: data.scoreRetention.present
          ? data.scoreRetention.value
          : this.scoreRetention,
      overallScore: data.overallScore.present
          ? data.overallScore.value
          : this.overallScore,
      warrantyMonths: data.warrantyMonths.present
          ? data.warrantyMonths.value
          : this.warrantyMonths,
      warrantyEndDate: data.warrantyEndDate.present
          ? data.warrantyEndDate.value
          : this.warrantyEndDate,
      maintenanceMonths: data.maintenanceMonths.present
          ? data.maintenanceMonths.value
          : this.maintenanceMonths,
      usageFrequency: data.usageFrequency.present
          ? data.usageFrequency.value
          : this.usageFrequency,
      aiTags: data.aiTags.present ? data.aiTags.value : this.aiTags,
      invoiceImagePaths: data.invoiceImagePaths.present
          ? data.invoiceImagePaths.value
          : this.invoiceImagePaths,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('additionalImagePaths: $additionalImagePaths, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currency: $currency, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchaseChannel: $purchaseChannel, ')
          ..write('merchantName: $merchantName, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('locationDetail: $locationDetail, ')
          ..write('locationImagePath: $locationImagePath, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('scoreValue: $scoreValue, ')
          ..write('scoreUsage: $scoreUsage, ')
          ..write('scoreFavorite: $scoreFavorite, ')
          ..write('scoreUtilization: $scoreUtilization, ')
          ..write('scoreCost: $scoreCost, ')
          ..write('scoreRetention: $scoreRetention, ')
          ..write('overallScore: $overallScore, ')
          ..write('warrantyMonths: $warrantyMonths, ')
          ..write('warrantyEndDate: $warrantyEndDate, ')
          ..write('maintenanceMonths: $maintenanceMonths, ')
          ..write('usageFrequency: $usageFrequency, ')
          ..write('aiTags: $aiTags, ')
          ..write('invoiceImagePaths: $invoiceImagePaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    coverImagePath,
    additionalImagePaths,
    categoryId,
    categoryName,
    purchasePrice,
    currency,
    purchaseDate,
    purchaseChannel,
    merchantName,
    orderNumber,
    brand,
    model,
    quantity,
    status,
    locationId,
    locationName,
    locationDetail,
    locationImagePath,
    notes,
    tags,
    isFavorite,
    scoreValue,
    scoreUsage,
    scoreFavorite,
    scoreUtilization,
    scoreCost,
    scoreRetention,
    overallScore,
    warrantyMonths,
    warrantyEndDate,
    maintenanceMonths,
    usageFrequency,
    aiTags,
    invoiceImagePaths,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.coverImagePath == this.coverImagePath &&
          other.additionalImagePaths == this.additionalImagePaths &&
          other.categoryId == this.categoryId &&
          other.categoryName == this.categoryName &&
          other.purchasePrice == this.purchasePrice &&
          other.currency == this.currency &&
          other.purchaseDate == this.purchaseDate &&
          other.purchaseChannel == this.purchaseChannel &&
          other.merchantName == this.merchantName &&
          other.orderNumber == this.orderNumber &&
          other.brand == this.brand &&
          other.model == this.model &&
          other.quantity == this.quantity &&
          other.status == this.status &&
          other.locationId == this.locationId &&
          other.locationName == this.locationName &&
          other.locationDetail == this.locationDetail &&
          other.locationImagePath == this.locationImagePath &&
          other.notes == this.notes &&
          other.tags == this.tags &&
          other.isFavorite == this.isFavorite &&
          other.scoreValue == this.scoreValue &&
          other.scoreUsage == this.scoreUsage &&
          other.scoreFavorite == this.scoreFavorite &&
          other.scoreUtilization == this.scoreUtilization &&
          other.scoreCost == this.scoreCost &&
          other.scoreRetention == this.scoreRetention &&
          other.overallScore == this.overallScore &&
          other.warrantyMonths == this.warrantyMonths &&
          other.warrantyEndDate == this.warrantyEndDate &&
          other.maintenanceMonths == this.maintenanceMonths &&
          other.usageFrequency == this.usageFrequency &&
          other.aiTags == this.aiTags &&
          other.invoiceImagePaths == this.invoiceImagePaths &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class ItemsCompanion extends UpdateCompanion<ItemRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> coverImagePath;
  final Value<String> additionalImagePaths;
  final Value<String> categoryId;
  final Value<String> categoryName;
  final Value<int> purchasePrice;
  final Value<String> currency;
  final Value<DateTime> purchaseDate;
  final Value<String?> purchaseChannel;
  final Value<String?> merchantName;
  final Value<String?> orderNumber;
  final Value<String?> brand;
  final Value<String?> model;
  final Value<int> quantity;
  final Value<String> status;
  final Value<String?> locationId;
  final Value<String?> locationName;
  final Value<String?> locationDetail;
  final Value<String?> locationImagePath;
  final Value<String?> notes;
  final Value<String> tags;
  final Value<bool> isFavorite;
  final Value<int?> scoreValue;
  final Value<int?> scoreUsage;
  final Value<int?> scoreFavorite;
  final Value<int?> scoreUtilization;
  final Value<int?> scoreCost;
  final Value<int?> scoreRetention;
  final Value<int?> overallScore;
  final Value<int?> warrantyMonths;
  final Value<DateTime?> warrantyEndDate;
  final Value<int?> maintenanceMonths;
  final Value<String?> usageFrequency;
  final Value<String?> aiTags;
  final Value<String> invoiceImagePaths;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.additionalImagePaths = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryName = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.currency = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.purchaseChannel = const Value.absent(),
    this.merchantName = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.quantity = const Value.absent(),
    this.status = const Value.absent(),
    this.locationId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.locationDetail = const Value.absent(),
    this.locationImagePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.scoreValue = const Value.absent(),
    this.scoreUsage = const Value.absent(),
    this.scoreFavorite = const Value.absent(),
    this.scoreUtilization = const Value.absent(),
    this.scoreCost = const Value.absent(),
    this.scoreRetention = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.warrantyMonths = const Value.absent(),
    this.warrantyEndDate = const Value.absent(),
    this.maintenanceMonths = const Value.absent(),
    this.usageFrequency = const Value.absent(),
    this.aiTags = const Value.absent(),
    this.invoiceImagePaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String name,
    this.coverImagePath = const Value.absent(),
    this.additionalImagePaths = const Value.absent(),
    required String categoryId,
    required String categoryName,
    required int purchasePrice,
    this.currency = const Value.absent(),
    required DateTime purchaseDate,
    this.purchaseChannel = const Value.absent(),
    this.merchantName = const Value.absent(),
    this.orderNumber = const Value.absent(),
    this.brand = const Value.absent(),
    this.model = const Value.absent(),
    this.quantity = const Value.absent(),
    required String status,
    this.locationId = const Value.absent(),
    this.locationName = const Value.absent(),
    this.locationDetail = const Value.absent(),
    this.locationImagePath = const Value.absent(),
    this.notes = const Value.absent(),
    this.tags = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.scoreValue = const Value.absent(),
    this.scoreUsage = const Value.absent(),
    this.scoreFavorite = const Value.absent(),
    this.scoreUtilization = const Value.absent(),
    this.scoreCost = const Value.absent(),
    this.scoreRetention = const Value.absent(),
    this.overallScore = const Value.absent(),
    this.warrantyMonths = const Value.absent(),
    this.warrantyEndDate = const Value.absent(),
    this.maintenanceMonths = const Value.absent(),
    this.usageFrequency = const Value.absent(),
    this.aiTags = const Value.absent(),
    this.invoiceImagePaths = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       categoryId = Value(categoryId),
       categoryName = Value(categoryName),
       purchasePrice = Value(purchasePrice),
       purchaseDate = Value(purchaseDate),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ItemRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? coverImagePath,
    Expression<String>? additionalImagePaths,
    Expression<String>? categoryId,
    Expression<String>? categoryName,
    Expression<int>? purchasePrice,
    Expression<String>? currency,
    Expression<DateTime>? purchaseDate,
    Expression<String>? purchaseChannel,
    Expression<String>? merchantName,
    Expression<String>? orderNumber,
    Expression<String>? brand,
    Expression<String>? model,
    Expression<int>? quantity,
    Expression<String>? status,
    Expression<String>? locationId,
    Expression<String>? locationName,
    Expression<String>? locationDetail,
    Expression<String>? locationImagePath,
    Expression<String>? notes,
    Expression<String>? tags,
    Expression<bool>? isFavorite,
    Expression<int>? scoreValue,
    Expression<int>? scoreUsage,
    Expression<int>? scoreFavorite,
    Expression<int>? scoreUtilization,
    Expression<int>? scoreCost,
    Expression<int>? scoreRetention,
    Expression<int>? overallScore,
    Expression<int>? warrantyMonths,
    Expression<DateTime>? warrantyEndDate,
    Expression<int>? maintenanceMonths,
    Expression<String>? usageFrequency,
    Expression<String>? aiTags,
    Expression<String>? invoiceImagePaths,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (additionalImagePaths != null)
        'additional_image_paths': additionalImagePaths,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryName != null) 'category_name': categoryName,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (currency != null) 'currency': currency,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (purchaseChannel != null) 'purchase_channel': purchaseChannel,
      if (merchantName != null) 'merchant_name': merchantName,
      if (orderNumber != null) 'order_number': orderNumber,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (quantity != null) 'quantity': quantity,
      if (status != null) 'status': status,
      if (locationId != null) 'location_id': locationId,
      if (locationName != null) 'location_name': locationName,
      if (locationDetail != null) 'location_detail': locationDetail,
      if (locationImagePath != null) 'location_image_path': locationImagePath,
      if (notes != null) 'notes': notes,
      if (tags != null) 'tags': tags,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (scoreValue != null) 'score_value': scoreValue,
      if (scoreUsage != null) 'score_usage': scoreUsage,
      if (scoreFavorite != null) 'score_favorite': scoreFavorite,
      if (scoreUtilization != null) 'score_utilization': scoreUtilization,
      if (scoreCost != null) 'score_cost': scoreCost,
      if (scoreRetention != null) 'score_retention': scoreRetention,
      if (overallScore != null) 'overall_score': overallScore,
      if (warrantyMonths != null) 'warranty_months': warrantyMonths,
      if (warrantyEndDate != null) 'warranty_end_date': warrantyEndDate,
      if (maintenanceMonths != null) 'maintenance_months': maintenanceMonths,
      if (usageFrequency != null) 'usage_frequency': usageFrequency,
      if (aiTags != null) 'ai_tags': aiTags,
      if (invoiceImagePaths != null) 'invoice_image_paths': invoiceImagePaths,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? coverImagePath,
    Value<String>? additionalImagePaths,
    Value<String>? categoryId,
    Value<String>? categoryName,
    Value<int>? purchasePrice,
    Value<String>? currency,
    Value<DateTime>? purchaseDate,
    Value<String?>? purchaseChannel,
    Value<String?>? merchantName,
    Value<String?>? orderNumber,
    Value<String?>? brand,
    Value<String?>? model,
    Value<int>? quantity,
    Value<String>? status,
    Value<String?>? locationId,
    Value<String?>? locationName,
    Value<String?>? locationDetail,
    Value<String?>? locationImagePath,
    Value<String?>? notes,
    Value<String>? tags,
    Value<bool>? isFavorite,
    Value<int?>? scoreValue,
    Value<int?>? scoreUsage,
    Value<int?>? scoreFavorite,
    Value<int?>? scoreUtilization,
    Value<int?>? scoreCost,
    Value<int?>? scoreRetention,
    Value<int?>? overallScore,
    Value<int?>? warrantyMonths,
    Value<DateTime?>? warrantyEndDate,
    Value<int?>? maintenanceMonths,
    Value<String?>? usageFrequency,
    Value<String?>? aiTags,
    Value<String>? invoiceImagePaths,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return ItemsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      coverImagePath: coverImagePath ?? this.coverImagePath,
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
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
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
      invoiceImagePaths: invoiceImagePaths ?? this.invoiceImagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (additionalImagePaths.present) {
      map['additional_image_paths'] = Variable<String>(
        additionalImagePaths.value,
      );
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryName.present) {
      map['category_name'] = Variable<String>(categoryName.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<int>(purchasePrice.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (purchaseChannel.present) {
      map['purchase_channel'] = Variable<String>(purchaseChannel.value);
    }
    if (merchantName.present) {
      map['merchant_name'] = Variable<String>(merchantName.value);
    }
    if (orderNumber.present) {
      map['order_number'] = Variable<String>(orderNumber.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (locationName.present) {
      map['location_name'] = Variable<String>(locationName.value);
    }
    if (locationDetail.present) {
      map['location_detail'] = Variable<String>(locationDetail.value);
    }
    if (locationImagePath.present) {
      map['location_image_path'] = Variable<String>(locationImagePath.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (scoreValue.present) {
      map['score_value'] = Variable<int>(scoreValue.value);
    }
    if (scoreUsage.present) {
      map['score_usage'] = Variable<int>(scoreUsage.value);
    }
    if (scoreFavorite.present) {
      map['score_favorite'] = Variable<int>(scoreFavorite.value);
    }
    if (scoreUtilization.present) {
      map['score_utilization'] = Variable<int>(scoreUtilization.value);
    }
    if (scoreCost.present) {
      map['score_cost'] = Variable<int>(scoreCost.value);
    }
    if (scoreRetention.present) {
      map['score_retention'] = Variable<int>(scoreRetention.value);
    }
    if (overallScore.present) {
      map['overall_score'] = Variable<int>(overallScore.value);
    }
    if (warrantyMonths.present) {
      map['warranty_months'] = Variable<int>(warrantyMonths.value);
    }
    if (warrantyEndDate.present) {
      map['warranty_end_date'] = Variable<DateTime>(warrantyEndDate.value);
    }
    if (maintenanceMonths.present) {
      map['maintenance_months'] = Variable<int>(maintenanceMonths.value);
    }
    if (usageFrequency.present) {
      map['usage_frequency'] = Variable<String>(usageFrequency.value);
    }
    if (aiTags.present) {
      map['ai_tags'] = Variable<String>(aiTags.value);
    }
    if (invoiceImagePaths.present) {
      map['invoice_image_paths'] = Variable<String>(invoiceImagePaths.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('additionalImagePaths: $additionalImagePaths, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryName: $categoryName, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('currency: $currency, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('purchaseChannel: $purchaseChannel, ')
          ..write('merchantName: $merchantName, ')
          ..write('orderNumber: $orderNumber, ')
          ..write('brand: $brand, ')
          ..write('model: $model, ')
          ..write('quantity: $quantity, ')
          ..write('status: $status, ')
          ..write('locationId: $locationId, ')
          ..write('locationName: $locationName, ')
          ..write('locationDetail: $locationDetail, ')
          ..write('locationImagePath: $locationImagePath, ')
          ..write('notes: $notes, ')
          ..write('tags: $tags, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('scoreValue: $scoreValue, ')
          ..write('scoreUsage: $scoreUsage, ')
          ..write('scoreFavorite: $scoreFavorite, ')
          ..write('scoreUtilization: $scoreUtilization, ')
          ..write('scoreCost: $scoreCost, ')
          ..write('scoreRetention: $scoreRetention, ')
          ..write('overallScore: $overallScore, ')
          ..write('warrantyMonths: $warrantyMonths, ')
          ..write('warrantyEndDate: $warrantyEndDate, ')
          ..write('maintenanceMonths: $maintenanceMonths, ')
          ..write('usageFrequency: $usageFrequency, ')
          ..write('aiTags: $aiTags, ')
          ..write('invoiceImagePaths: $invoiceImagePaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, LocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    parentId,
    description,
    imagePath,
    sortOrder,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class LocationRow extends DataClass implements Insertable<LocationRow> {
  final String id;
  final String name;
  final String? parentId;
  final String? description;
  final String? imagePath;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const LocationRow({
    required this.id,
    required this.name,
    this.parentId,
    this.description,
    this.imagePath,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      sortOrder: Value(sortOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory LocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      description: serializer.fromJson<String?>(json['description']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'description': serializer.toJson<String?>(description),
      'imagePath': serializer.toJson<String?>(imagePath),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  LocationRow copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => LocationRow(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    description: description.present ? description.value : this.description,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  LocationRow copyWithCompanion(LocationsCompanion data) {
    return LocationRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      description: data.description.present
          ? data.description.value
          : this.description,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    parentId,
    description,
    imagePath,
    sortOrder,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.description == this.description &&
          other.imagePath == this.imagePath &&
          other.sortOrder == this.sortOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class LocationsCompanion extends UpdateCompanion<LocationRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<String?> description;
  final Value<String?> imagePath;
  final Value<int> sortOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.description = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.sortOrder = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<LocationRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<String>? description,
    Expression<String>? imagePath,
    Expression<int>? sortOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (description != null) 'description': description,
      if (imagePath != null) 'image_path': imagePath,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<String?>? description,
    Value<String?>? imagePath,
    Value<int>? sortOrder,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return LocationsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      description: description ?? this.description,
      imagePath: imagePath ?? this.imagePath,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('description: $description, ')
          ..write('imagePath: $imagePath, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorValueMeta = const VerificationMeta(
    'colorValue',
  );
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
    'color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    icon,
    colorValue,
    sortOrder,
    isSystem,
    isHidden,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
        _colorValueMeta,
        colorValue.isAcceptableOrUnknown(data['color_value']!, _colorValueMeta),
      );
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    } else if (isInserting) {
      context.missing(_isSystemMeta);
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      )!,
      colorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_value'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String name;
  final String icon;
  final int colorValue;
  final int sortOrder;
  final bool isSystem;
  final bool isHidden;
  const CategoryRow({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.sortOrder,
    required this.isSystem,
    required this.isHidden,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['icon'] = Variable<String>(icon);
    map['color_value'] = Variable<int>(colorValue);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_hidden'] = Variable<bool>(isHidden);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: Value(icon),
      colorValue: Value(colorValue),
      sortOrder: Value(sortOrder),
      isSystem: Value(isSystem),
      isHidden: Value(isHidden),
    );
  }

  factory CategoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String>(json['icon']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String>(icon),
      'colorValue': serializer.toJson<int>(colorValue),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isHidden': serializer.toJson<bool>(isHidden),
    };
  }

  CategoryRow copyWith({
    String? id,
    String? name,
    String? icon,
    int? colorValue,
    int? sortOrder,
    bool? isSystem,
    bool? isHidden,
  }) => CategoryRow(
    id: id ?? this.id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    colorValue: colorValue ?? this.colorValue,
    sortOrder: sortOrder ?? this.sortOrder,
    isSystem: isSystem ?? this.isSystem,
    isHidden: isHidden ?? this.isHidden,
  );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      colorValue: data.colorValue.present
          ? data.colorValue.value
          : this.colorValue,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('isHidden: $isHidden')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, icon, colorValue, sortOrder, isSystem, isHidden);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.colorValue == this.colorValue &&
          other.sortOrder == this.sortOrder &&
          other.isSystem == this.isSystem &&
          other.isHidden == this.isHidden);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> icon;
  final Value<int> colorValue;
  final Value<int> sortOrder;
  final Value<bool> isSystem;
  final Value<bool> isHidden;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    required String icon,
    required int colorValue,
    required int sortOrder,
    required bool isSystem,
    this.isHidden = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       icon = Value(icon),
       colorValue = Value(colorValue),
       sortOrder = Value(sortOrder),
       isSystem = Value(isSystem);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? colorValue,
    Expression<int>? sortOrder,
    Expression<bool>? isSystem,
    Expression<bool>? isHidden,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorValue != null) 'color_value': colorValue,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isSystem != null) 'is_system': isSystem,
      if (isHidden != null) 'is_hidden': isHidden,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? icon,
    Value<int>? colorValue,
    Value<int>? sortOrder,
    Value<bool>? isSystem,
    Value<bool>? isHidden,
    Value<int>? rowid,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorValue: colorValue ?? this.colorValue,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      isHidden: isHidden ?? this.isHidden,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorValue: $colorValue, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('isHidden: $isHidden, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleRecordsTable extends SaleRecords
    with TableInfo<$SaleRecordsTable, SaleRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<int> salePrice = GeneratedColumn<int>(
    'sale_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _saleDateMeta = const VerificationMeta(
    'saleDate',
  );
  @override
  late final GeneratedColumn<DateTime> saleDate = GeneratedColumn<DateTime>(
    'sale_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _buyerNoteMeta = const VerificationMeta(
    'buyerNote',
  );
  @override
  late final GeneratedColumn<String> buyerNote = GeneratedColumn<String>(
    'buyer_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shippingCostMeta = const VerificationMeta(
    'shippingCost',
  );
  @override
  late final GeneratedColumn<int> shippingCost = GeneratedColumn<int>(
    'shipping_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _platformFeeMeta = const VerificationMeta(
    'platformFee',
  );
  @override
  late final GeneratedColumn<int> platformFee = GeneratedColumn<int>(
    'platform_fee',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _otherCostMeta = const VerificationMeta(
    'otherCost',
  );
  @override
  late final GeneratedColumn<int> otherCost = GeneratedColumn<int>(
    'other_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    salePrice,
    saleDate,
    platform,
    buyerNote,
    shippingCost,
    platformFee,
    otherCost,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SaleRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    } else if (isInserting) {
      context.missing(_salePriceMeta);
    }
    if (data.containsKey('sale_date')) {
      context.handle(
        _saleDateMeta,
        saleDate.isAcceptableOrUnknown(data['sale_date']!, _saleDateMeta),
      );
    } else if (isInserting) {
      context.missing(_saleDateMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('buyer_note')) {
      context.handle(
        _buyerNoteMeta,
        buyerNote.isAcceptableOrUnknown(data['buyer_note']!, _buyerNoteMeta),
      );
    }
    if (data.containsKey('shipping_cost')) {
      context.handle(
        _shippingCostMeta,
        shippingCost.isAcceptableOrUnknown(
          data['shipping_cost']!,
          _shippingCostMeta,
        ),
      );
    }
    if (data.containsKey('platform_fee')) {
      context.handle(
        _platformFeeMeta,
        platformFee.isAcceptableOrUnknown(
          data['platform_fee']!,
          _platformFeeMeta,
        ),
      );
    }
    if (data.containsKey('other_cost')) {
      context.handle(
        _otherCostMeta,
        otherCost.isAcceptableOrUnknown(data['other_cost']!, _otherCostMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sale_price'],
      )!,
      saleDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sale_date'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      ),
      buyerNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}buyer_note'],
      ),
      shippingCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shipping_cost'],
      )!,
      platformFee: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}platform_fee'],
      )!,
      otherCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}other_cost'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SaleRecordsTable createAlias(String alias) {
    return $SaleRecordsTable(attachedDatabase, alias);
  }
}

class SaleRecordRow extends DataClass implements Insertable<SaleRecordRow> {
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
  const SaleRecordRow({
    required this.id,
    required this.itemId,
    required this.salePrice,
    required this.saleDate,
    this.platform,
    this.buyerNote,
    required this.shippingCost,
    required this.platformFee,
    required this.otherCost,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['sale_price'] = Variable<int>(salePrice);
    map['sale_date'] = Variable<DateTime>(saleDate);
    if (!nullToAbsent || platform != null) {
      map['platform'] = Variable<String>(platform);
    }
    if (!nullToAbsent || buyerNote != null) {
      map['buyer_note'] = Variable<String>(buyerNote);
    }
    map['shipping_cost'] = Variable<int>(shippingCost);
    map['platform_fee'] = Variable<int>(platformFee);
    map['other_cost'] = Variable<int>(otherCost);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SaleRecordsCompanion toCompanion(bool nullToAbsent) {
    return SaleRecordsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      salePrice: Value(salePrice),
      saleDate: Value(saleDate),
      platform: platform == null && nullToAbsent
          ? const Value.absent()
          : Value(platform),
      buyerNote: buyerNote == null && nullToAbsent
          ? const Value.absent()
          : Value(buyerNote),
      shippingCost: Value(shippingCost),
      platformFee: Value(platformFee),
      otherCost: Value(otherCost),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SaleRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleRecordRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      salePrice: serializer.fromJson<int>(json['salePrice']),
      saleDate: serializer.fromJson<DateTime>(json['saleDate']),
      platform: serializer.fromJson<String?>(json['platform']),
      buyerNote: serializer.fromJson<String?>(json['buyerNote']),
      shippingCost: serializer.fromJson<int>(json['shippingCost']),
      platformFee: serializer.fromJson<int>(json['platformFee']),
      otherCost: serializer.fromJson<int>(json['otherCost']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'salePrice': serializer.toJson<int>(salePrice),
      'saleDate': serializer.toJson<DateTime>(saleDate),
      'platform': serializer.toJson<String?>(platform),
      'buyerNote': serializer.toJson<String?>(buyerNote),
      'shippingCost': serializer.toJson<int>(shippingCost),
      'platformFee': serializer.toJson<int>(platformFee),
      'otherCost': serializer.toJson<int>(otherCost),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SaleRecordRow copyWith({
    String? id,
    String? itemId,
    int? salePrice,
    DateTime? saleDate,
    Value<String?> platform = const Value.absent(),
    Value<String?> buyerNote = const Value.absent(),
    int? shippingCost,
    int? platformFee,
    int? otherCost,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => SaleRecordRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    salePrice: salePrice ?? this.salePrice,
    saleDate: saleDate ?? this.saleDate,
    platform: platform.present ? platform.value : this.platform,
    buyerNote: buyerNote.present ? buyerNote.value : this.buyerNote,
    shippingCost: shippingCost ?? this.shippingCost,
    platformFee: platformFee ?? this.platformFee,
    otherCost: otherCost ?? this.otherCost,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SaleRecordRow copyWithCompanion(SaleRecordsCompanion data) {
    return SaleRecordRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      saleDate: data.saleDate.present ? data.saleDate.value : this.saleDate,
      platform: data.platform.present ? data.platform.value : this.platform,
      buyerNote: data.buyerNote.present ? data.buyerNote.value : this.buyerNote,
      shippingCost: data.shippingCost.present
          ? data.shippingCost.value
          : this.shippingCost,
      platformFee: data.platformFee.present
          ? data.platformFee.value
          : this.platformFee,
      otherCost: data.otherCost.present ? data.otherCost.value : this.otherCost,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleRecordRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('salePrice: $salePrice, ')
          ..write('saleDate: $saleDate, ')
          ..write('platform: $platform, ')
          ..write('buyerNote: $buyerNote, ')
          ..write('shippingCost: $shippingCost, ')
          ..write('platformFee: $platformFee, ')
          ..write('otherCost: $otherCost, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    salePrice,
    saleDate,
    platform,
    buyerNote,
    shippingCost,
    platformFee,
    otherCost,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleRecordRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.salePrice == this.salePrice &&
          other.saleDate == this.saleDate &&
          other.platform == this.platform &&
          other.buyerNote == this.buyerNote &&
          other.shippingCost == this.shippingCost &&
          other.platformFee == this.platformFee &&
          other.otherCost == this.otherCost &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SaleRecordsCompanion extends UpdateCompanion<SaleRecordRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<int> salePrice;
  final Value<DateTime> saleDate;
  final Value<String?> platform;
  final Value<String?> buyerNote;
  final Value<int> shippingCost;
  final Value<int> platformFee;
  final Value<int> otherCost;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SaleRecordsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.saleDate = const Value.absent(),
    this.platform = const Value.absent(),
    this.buyerNote = const Value.absent(),
    this.shippingCost = const Value.absent(),
    this.platformFee = const Value.absent(),
    this.otherCost = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SaleRecordsCompanion.insert({
    required String id,
    required String itemId,
    required int salePrice,
    required DateTime saleDate,
    this.platform = const Value.absent(),
    this.buyerNote = const Value.absent(),
    this.shippingCost = const Value.absent(),
    this.platformFee = const Value.absent(),
    this.otherCost = const Value.absent(),
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       salePrice = Value(salePrice),
       saleDate = Value(saleDate),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<SaleRecordRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<int>? salePrice,
    Expression<DateTime>? saleDate,
    Expression<String>? platform,
    Expression<String>? buyerNote,
    Expression<int>? shippingCost,
    Expression<int>? platformFee,
    Expression<int>? otherCost,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (salePrice != null) 'sale_price': salePrice,
      if (saleDate != null) 'sale_date': saleDate,
      if (platform != null) 'platform': platform,
      if (buyerNote != null) 'buyer_note': buyerNote,
      if (shippingCost != null) 'shipping_cost': shippingCost,
      if (platformFee != null) 'platform_fee': platformFee,
      if (otherCost != null) 'other_cost': otherCost,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SaleRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<int>? salePrice,
    Value<DateTime>? saleDate,
    Value<String?>? platform,
    Value<String?>? buyerNote,
    Value<int>? shippingCost,
    Value<int>? platformFee,
    Value<int>? otherCost,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SaleRecordsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      salePrice: salePrice ?? this.salePrice,
      saleDate: saleDate ?? this.saleDate,
      platform: platform ?? this.platform,
      buyerNote: buyerNote ?? this.buyerNote,
      shippingCost: shippingCost ?? this.shippingCost,
      platformFee: platformFee ?? this.platformFee,
      otherCost: otherCost ?? this.otherCost,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<int>(salePrice.value);
    }
    if (saleDate.present) {
      map['sale_date'] = Variable<DateTime>(saleDate.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (buyerNote.present) {
      map['buyer_note'] = Variable<String>(buyerNote.value);
    }
    if (shippingCost.present) {
      map['shipping_cost'] = Variable<int>(shippingCost.value);
    }
    if (platformFee.present) {
      map['platform_fee'] = Variable<int>(platformFee.value);
    }
    if (otherCost.present) {
      map['other_cost'] = Variable<int>(otherCost.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleRecordsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('salePrice: $salePrice, ')
          ..write('saleDate: $saleDate, ')
          ..write('platform: $platform, ')
          ..write('buyerNote: $buyerNote, ')
          ..write('shippingCost: $shippingCost, ')
          ..write('platformFee: $platformFee, ')
          ..write('otherCost: $otherCost, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemEventsTable extends ItemEvents
    with TableInfo<$ItemEventsTable, ItemEventRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathsMeta = const VerificationMeta(
    'imagePaths',
  );
  @override
  late final GeneratedColumn<String> imagePaths = GeneratedColumn<String>(
    'image_paths',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    itemId,
    eventType,
    eventDate,
    title,
    description,
    amount,
    imagePaths,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemEventRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    } else if (isInserting) {
      context.missing(_eventDateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    }
    if (data.containsKey('image_paths')) {
      context.handle(
        _imagePathsMeta,
        imagePaths.isAcceptableOrUnknown(data['image_paths']!, _imagePathsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ItemEventRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemEventRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      ),
      imagePaths: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_paths'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ItemEventsTable createAlias(String alias) {
    return $ItemEventsTable(attachedDatabase, alias);
  }
}

class ItemEventRow extends DataClass implements Insertable<ItemEventRow> {
  final String id;
  final String itemId;
  final String eventType;
  final DateTime eventDate;
  final String title;
  final String? description;
  final int? amount;
  final String imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ItemEventRow({
    required this.id,
    required this.itemId,
    required this.eventType,
    required this.eventDate,
    required this.title,
    this.description,
    this.amount,
    required this.imagePaths,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['event_type'] = Variable<String>(eventType);
    map['event_date'] = Variable<DateTime>(eventDate);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || amount != null) {
      map['amount'] = Variable<int>(amount);
    }
    map['image_paths'] = Variable<String>(imagePaths);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ItemEventsCompanion toCompanion(bool nullToAbsent) {
    return ItemEventsCompanion(
      id: Value(id),
      itemId: Value(itemId),
      eventType: Value(eventType),
      eventDate: Value(eventDate),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      amount: amount == null && nullToAbsent
          ? const Value.absent()
          : Value(amount),
      imagePaths: Value(imagePaths),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ItemEventRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemEventRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      eventDate: serializer.fromJson<DateTime>(json['eventDate']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      amount: serializer.fromJson<int?>(json['amount']),
      imagePaths: serializer.fromJson<String>(json['imagePaths']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'eventType': serializer.toJson<String>(eventType),
      'eventDate': serializer.toJson<DateTime>(eventDate),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'amount': serializer.toJson<int?>(amount),
      'imagePaths': serializer.toJson<String>(imagePaths),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ItemEventRow copyWith({
    String? id,
    String? itemId,
    String? eventType,
    DateTime? eventDate,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<int?> amount = const Value.absent(),
    String? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ItemEventRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    eventType: eventType ?? this.eventType,
    eventDate: eventDate ?? this.eventDate,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    amount: amount.present ? amount.value : this.amount,
    imagePaths: imagePaths ?? this.imagePaths,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ItemEventRow copyWithCompanion(ItemEventsCompanion data) {
    return ItemEventRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      amount: data.amount.present ? data.amount.value : this.amount,
      imagePaths: data.imagePaths.present
          ? data.imagePaths.value
          : this.imagePaths,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemEventRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('eventType: $eventType, ')
          ..write('eventDate: $eventDate, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    eventType,
    eventDate,
    title,
    description,
    amount,
    imagePaths,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemEventRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.eventType == this.eventType &&
          other.eventDate == this.eventDate &&
          other.title == this.title &&
          other.description == this.description &&
          other.amount == this.amount &&
          other.imagePaths == this.imagePaths &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ItemEventsCompanion extends UpdateCompanion<ItemEventRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<String> eventType;
  final Value<DateTime> eventDate;
  final Value<String> title;
  final Value<String?> description;
  final Value<int?> amount;
  final Value<String> imagePaths;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ItemEventsCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.imagePaths = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemEventsCompanion.insert({
    required String id,
    required String itemId,
    required String eventType,
    required DateTime eventDate,
    required String title,
    this.description = const Value.absent(),
    this.amount = const Value.absent(),
    this.imagePaths = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       eventType = Value(eventType),
       eventDate = Value(eventDate),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<ItemEventRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<String>? eventType,
    Expression<DateTime>? eventDate,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? amount,
    Expression<String>? imagePaths,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (eventType != null) 'event_type': eventType,
      if (eventDate != null) 'event_date': eventDate,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (amount != null) 'amount': amount,
      if (imagePaths != null) 'image_paths': imagePaths,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<String>? eventType,
    Value<DateTime>? eventDate,
    Value<String>? title,
    Value<String?>? description,
    Value<int?>? amount,
    Value<String>? imagePaths,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ItemEventsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      eventType: eventType ?? this.eventType,
      eventDate: eventDate ?? this.eventDate,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (imagePaths.present) {
      map['image_paths'] = Variable<String>(imagePaths.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemEventsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('eventType: $eventType, ')
          ..write('eventDate: $eventDate, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('amount: $amount, ')
          ..write('imagePaths: $imagePaths, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $SaleRecordsTable saleRecords = $SaleRecordsTable(this);
  late final $ItemEventsTable itemEvents = $ItemEventsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    items,
    locations,
    categories,
    saleRecords,
    itemEvents,
    settings,
  ];
}

typedef $$ItemsTableCreateCompanionBuilder =
    ItemsCompanion Function({
      required String id,
      required String name,
      Value<String?> coverImagePath,
      Value<String> additionalImagePaths,
      required String categoryId,
      required String categoryName,
      required int purchasePrice,
      Value<String> currency,
      required DateTime purchaseDate,
      Value<String?> purchaseChannel,
      Value<String?> merchantName,
      Value<String?> orderNumber,
      Value<String?> brand,
      Value<String?> model,
      Value<int> quantity,
      required String status,
      Value<String?> locationId,
      Value<String?> locationName,
      Value<String?> locationDetail,
      Value<String?> locationImagePath,
      Value<String?> notes,
      Value<String> tags,
      Value<bool> isFavorite,
      Value<int?> scoreValue,
      Value<int?> scoreUsage,
      Value<int?> scoreFavorite,
      Value<int?> scoreUtilization,
      Value<int?> scoreCost,
      Value<int?> scoreRetention,
      Value<int?> overallScore,
      Value<int?> warrantyMonths,
      Value<DateTime?> warrantyEndDate,
      Value<int?> maintenanceMonths,
      Value<String?> usageFrequency,
      Value<String?> aiTags,
      Value<String> invoiceImagePaths,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$ItemsTableUpdateCompanionBuilder =
    ItemsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> coverImagePath,
      Value<String> additionalImagePaths,
      Value<String> categoryId,
      Value<String> categoryName,
      Value<int> purchasePrice,
      Value<String> currency,
      Value<DateTime> purchaseDate,
      Value<String?> purchaseChannel,
      Value<String?> merchantName,
      Value<String?> orderNumber,
      Value<String?> brand,
      Value<String?> model,
      Value<int> quantity,
      Value<String> status,
      Value<String?> locationId,
      Value<String?> locationName,
      Value<String?> locationDetail,
      Value<String?> locationImagePath,
      Value<String?> notes,
      Value<String> tags,
      Value<bool> isFavorite,
      Value<int?> scoreValue,
      Value<int?> scoreUsage,
      Value<int?> scoreFavorite,
      Value<int?> scoreUtilization,
      Value<int?> scoreCost,
      Value<int?> scoreRetention,
      Value<int?> overallScore,
      Value<int?> warrantyMonths,
      Value<DateTime?> warrantyEndDate,
      Value<int?> maintenanceMonths,
      Value<String?> usageFrequency,
      Value<String?> aiTags,
      Value<String> invoiceImagePaths,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$ItemsTableFilterComposer extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get additionalImagePaths => $composableBuilder(
    column: $table.additionalImagePaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get purchaseChannel => $composableBuilder(
    column: $table.purchaseChannel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationDetail => $composableBuilder(
    column: $table.locationDetail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get locationImagePath => $composableBuilder(
    column: $table.locationImagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreUsage => $composableBuilder(
    column: $table.scoreUsage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreFavorite => $composableBuilder(
    column: $table.scoreFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreUtilization => $composableBuilder(
    column: $table.scoreUtilization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreCost => $composableBuilder(
    column: $table.scoreCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get scoreRetention => $composableBuilder(
    column: $table.scoreRetention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get warrantyEndDate => $composableBuilder(
    column: $table.warrantyEndDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maintenanceMonths => $composableBuilder(
    column: $table.maintenanceMonths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aiTags => $composableBuilder(
    column: $table.aiTags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceImagePaths => $composableBuilder(
    column: $table.invoiceImagePaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get additionalImagePaths => $composableBuilder(
    column: $table.additionalImagePaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get purchaseChannel => $composableBuilder(
    column: $table.purchaseChannel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationDetail => $composableBuilder(
    column: $table.locationDetail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get locationImagePath => $composableBuilder(
    column: $table.locationImagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreUsage => $composableBuilder(
    column: $table.scoreUsage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreFavorite => $composableBuilder(
    column: $table.scoreFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreUtilization => $composableBuilder(
    column: $table.scoreUtilization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreCost => $composableBuilder(
    column: $table.scoreCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scoreRetention => $composableBuilder(
    column: $table.scoreRetention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get warrantyEndDate => $composableBuilder(
    column: $table.warrantyEndDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maintenanceMonths => $composableBuilder(
    column: $table.maintenanceMonths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aiTags => $composableBuilder(
    column: $table.aiTags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceImagePaths => $composableBuilder(
    column: $table.invoiceImagePaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemsTable> {
  $$ItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
    column: $table.coverImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get additionalImagePaths => $composableBuilder(
    column: $table.additionalImagePaths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryName => $composableBuilder(
    column: $table.categoryName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get purchaseChannel => $composableBuilder(
    column: $table.purchaseChannel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get merchantName => $composableBuilder(
    column: $table.merchantName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get orderNumber => $composableBuilder(
    column: $table.orderNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get locationId => $composableBuilder(
    column: $table.locationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationName => $composableBuilder(
    column: $table.locationName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationDetail => $composableBuilder(
    column: $table.locationDetail,
    builder: (column) => column,
  );

  GeneratedColumn<String> get locationImagePath => $composableBuilder(
    column: $table.locationImagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreValue => $composableBuilder(
    column: $table.scoreValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreUsage => $composableBuilder(
    column: $table.scoreUsage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreFavorite => $composableBuilder(
    column: $table.scoreFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreUtilization => $composableBuilder(
    column: $table.scoreUtilization,
    builder: (column) => column,
  );

  GeneratedColumn<int> get scoreCost =>
      $composableBuilder(column: $table.scoreCost, builder: (column) => column);

  GeneratedColumn<int> get scoreRetention => $composableBuilder(
    column: $table.scoreRetention,
    builder: (column) => column,
  );

  GeneratedColumn<int> get overallScore => $composableBuilder(
    column: $table.overallScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warrantyMonths => $composableBuilder(
    column: $table.warrantyMonths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get warrantyEndDate => $composableBuilder(
    column: $table.warrantyEndDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maintenanceMonths => $composableBuilder(
    column: $table.maintenanceMonths,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usageFrequency => $composableBuilder(
    column: $table.usageFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aiTags =>
      $composableBuilder(column: $table.aiTags, builder: (column) => column);

  GeneratedColumn<String> get invoiceImagePaths => $composableBuilder(
    column: $table.invoiceImagePaths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$ItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemsTable,
          ItemRow,
          $$ItemsTableFilterComposer,
          $$ItemsTableOrderingComposer,
          $$ItemsTableAnnotationComposer,
          $$ItemsTableCreateCompanionBuilder,
          $$ItemsTableUpdateCompanionBuilder,
          (ItemRow, BaseReferences<_$AppDatabase, $ItemsTable, ItemRow>),
          ItemRow,
          PrefetchHooks Function()
        > {
  $$ItemsTableTableManager(_$AppDatabase db, $ItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> coverImagePath = const Value.absent(),
                Value<String> additionalImagePaths = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> categoryName = const Value.absent(),
                Value<int> purchasePrice = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<String?> purchaseChannel = const Value.absent(),
                Value<String?> merchantName = const Value.absent(),
                Value<String?> orderNumber = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> locationDetail = const Value.absent(),
                Value<String?> locationImagePath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> scoreValue = const Value.absent(),
                Value<int?> scoreUsage = const Value.absent(),
                Value<int?> scoreFavorite = const Value.absent(),
                Value<int?> scoreUtilization = const Value.absent(),
                Value<int?> scoreCost = const Value.absent(),
                Value<int?> scoreRetention = const Value.absent(),
                Value<int?> overallScore = const Value.absent(),
                Value<int?> warrantyMonths = const Value.absent(),
                Value<DateTime?> warrantyEndDate = const Value.absent(),
                Value<int?> maintenanceMonths = const Value.absent(),
                Value<String?> usageFrequency = const Value.absent(),
                Value<String?> aiTags = const Value.absent(),
                Value<String> invoiceImagePaths = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion(
                id: id,
                name: name,
                coverImagePath: coverImagePath,
                additionalImagePaths: additionalImagePaths,
                categoryId: categoryId,
                categoryName: categoryName,
                purchasePrice: purchasePrice,
                currency: currency,
                purchaseDate: purchaseDate,
                purchaseChannel: purchaseChannel,
                merchantName: merchantName,
                orderNumber: orderNumber,
                brand: brand,
                model: model,
                quantity: quantity,
                status: status,
                locationId: locationId,
                locationName: locationName,
                locationDetail: locationDetail,
                locationImagePath: locationImagePath,
                notes: notes,
                tags: tags,
                isFavorite: isFavorite,
                scoreValue: scoreValue,
                scoreUsage: scoreUsage,
                scoreFavorite: scoreFavorite,
                scoreUtilization: scoreUtilization,
                scoreCost: scoreCost,
                scoreRetention: scoreRetention,
                overallScore: overallScore,
                warrantyMonths: warrantyMonths,
                warrantyEndDate: warrantyEndDate,
                maintenanceMonths: maintenanceMonths,
                usageFrequency: usageFrequency,
                aiTags: aiTags,
                invoiceImagePaths: invoiceImagePaths,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> coverImagePath = const Value.absent(),
                Value<String> additionalImagePaths = const Value.absent(),
                required String categoryId,
                required String categoryName,
                required int purchasePrice,
                Value<String> currency = const Value.absent(),
                required DateTime purchaseDate,
                Value<String?> purchaseChannel = const Value.absent(),
                Value<String?> merchantName = const Value.absent(),
                Value<String?> orderNumber = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                required String status,
                Value<String?> locationId = const Value.absent(),
                Value<String?> locationName = const Value.absent(),
                Value<String?> locationDetail = const Value.absent(),
                Value<String?> locationImagePath = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> tags = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int?> scoreValue = const Value.absent(),
                Value<int?> scoreUsage = const Value.absent(),
                Value<int?> scoreFavorite = const Value.absent(),
                Value<int?> scoreUtilization = const Value.absent(),
                Value<int?> scoreCost = const Value.absent(),
                Value<int?> scoreRetention = const Value.absent(),
                Value<int?> overallScore = const Value.absent(),
                Value<int?> warrantyMonths = const Value.absent(),
                Value<DateTime?> warrantyEndDate = const Value.absent(),
                Value<int?> maintenanceMonths = const Value.absent(),
                Value<String?> usageFrequency = const Value.absent(),
                Value<String?> aiTags = const Value.absent(),
                Value<String> invoiceImagePaths = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemsCompanion.insert(
                id: id,
                name: name,
                coverImagePath: coverImagePath,
                additionalImagePaths: additionalImagePaths,
                categoryId: categoryId,
                categoryName: categoryName,
                purchasePrice: purchasePrice,
                currency: currency,
                purchaseDate: purchaseDate,
                purchaseChannel: purchaseChannel,
                merchantName: merchantName,
                orderNumber: orderNumber,
                brand: brand,
                model: model,
                quantity: quantity,
                status: status,
                locationId: locationId,
                locationName: locationName,
                locationDetail: locationDetail,
                locationImagePath: locationImagePath,
                notes: notes,
                tags: tags,
                isFavorite: isFavorite,
                scoreValue: scoreValue,
                scoreUsage: scoreUsage,
                scoreFavorite: scoreFavorite,
                scoreUtilization: scoreUtilization,
                scoreCost: scoreCost,
                scoreRetention: scoreRetention,
                overallScore: overallScore,
                warrantyMonths: warrantyMonths,
                warrantyEndDate: warrantyEndDate,
                maintenanceMonths: maintenanceMonths,
                usageFrequency: usageFrequency,
                aiTags: aiTags,
                invoiceImagePaths: invoiceImagePaths,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemsTable,
      ItemRow,
      $$ItemsTableFilterComposer,
      $$ItemsTableOrderingComposer,
      $$ItemsTableAnnotationComposer,
      $$ItemsTableCreateCompanionBuilder,
      $$ItemsTableUpdateCompanionBuilder,
      (ItemRow, BaseReferences<_$AppDatabase, $ItemsTable, ItemRow>),
      ItemRow,
      PrefetchHooks Function()
    >;
typedef $$LocationsTableCreateCompanionBuilder =
    LocationsCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      Value<String?> description,
      Value<String?> imagePath,
      Value<int> sortOrder,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$LocationsTableUpdateCompanionBuilder =
    LocationsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<String?> description,
      Value<String?> imagePath,
      Value<int> sortOrder,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          LocationRow,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (
            LocationRow,
            BaseReferences<_$AppDatabase, $LocationsTable, LocationRow>,
          ),
          LocationRow,
          PrefetchHooks Function()
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion(
                id: id,
                name: name,
                parentId: parentId,
                description: description,
                imagePath: imagePath,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                description: description,
                imagePath: imagePath,
                sortOrder: sortOrder,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      LocationRow,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (
        LocationRow,
        BaseReferences<_$AppDatabase, $LocationsTable, LocationRow>,
      ),
      LocationRow,
      PrefetchHooks Function()
    >;
typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      required String id,
      required String name,
      required String icon,
      required int colorValue,
      required int sortOrder,
      required bool isSystem,
      Value<bool> isHidden,
      Value<int> rowid,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> icon,
      Value<int> colorValue,
      Value<int> sortOrder,
      Value<bool> isSystem,
      Value<bool> isHidden,
      Value<int> rowid,
    });

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
    column: $table.colorValue,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryRow,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (
            CategoryRow,
            BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
          ),
          CategoryRow,
          PrefetchHooks Function()
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<int> colorValue = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                icon: icon,
                colorValue: colorValue,
                sortOrder: sortOrder,
                isSystem: isSystem,
                isHidden: isHidden,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String icon,
                required int colorValue,
                required int sortOrder,
                required bool isSystem,
                Value<bool> isHidden = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                icon: icon,
                colorValue: colorValue,
                sortOrder: sortOrder,
                isSystem: isSystem,
                isHidden: isHidden,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryRow,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (
        CategoryRow,
        BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow>,
      ),
      CategoryRow,
      PrefetchHooks Function()
    >;
typedef $$SaleRecordsTableCreateCompanionBuilder =
    SaleRecordsCompanion Function({
      required String id,
      required String itemId,
      required int salePrice,
      required DateTime saleDate,
      Value<String?> platform,
      Value<String?> buyerNote,
      Value<int> shippingCost,
      Value<int> platformFee,
      Value<int> otherCost,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SaleRecordsTableUpdateCompanionBuilder =
    SaleRecordsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<int> salePrice,
      Value<DateTime> saleDate,
      Value<String?> platform,
      Value<String?> buyerNote,
      Value<int> shippingCost,
      Value<int> platformFee,
      Value<int> otherCost,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SaleRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleRecordsTable> {
  $$SaleRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get buyerNote => $composableBuilder(
    column: $table.buyerNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shippingCost => $composableBuilder(
    column: $table.shippingCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get platformFee => $composableBuilder(
    column: $table.platformFee,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get otherCost => $composableBuilder(
    column: $table.otherCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SaleRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleRecordsTable> {
  $$SaleRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get saleDate => $composableBuilder(
    column: $table.saleDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get buyerNote => $composableBuilder(
    column: $table.buyerNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shippingCost => $composableBuilder(
    column: $table.shippingCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get platformFee => $composableBuilder(
    column: $table.platformFee,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get otherCost => $composableBuilder(
    column: $table.otherCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SaleRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleRecordsTable> {
  $$SaleRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<int> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<DateTime> get saleDate =>
      $composableBuilder(column: $table.saleDate, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get buyerNote =>
      $composableBuilder(column: $table.buyerNote, builder: (column) => column);

  GeneratedColumn<int> get shippingCost => $composableBuilder(
    column: $table.shippingCost,
    builder: (column) => column,
  );

  GeneratedColumn<int> get platformFee => $composableBuilder(
    column: $table.platformFee,
    builder: (column) => column,
  );

  GeneratedColumn<int> get otherCost =>
      $composableBuilder(column: $table.otherCost, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SaleRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SaleRecordsTable,
          SaleRecordRow,
          $$SaleRecordsTableFilterComposer,
          $$SaleRecordsTableOrderingComposer,
          $$SaleRecordsTableAnnotationComposer,
          $$SaleRecordsTableCreateCompanionBuilder,
          $$SaleRecordsTableUpdateCompanionBuilder,
          (
            SaleRecordRow,
            BaseReferences<_$AppDatabase, $SaleRecordsTable, SaleRecordRow>,
          ),
          SaleRecordRow,
          PrefetchHooks Function()
        > {
  $$SaleRecordsTableTableManager(_$AppDatabase db, $SaleRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> salePrice = const Value.absent(),
                Value<DateTime> saleDate = const Value.absent(),
                Value<String?> platform = const Value.absent(),
                Value<String?> buyerNote = const Value.absent(),
                Value<int> shippingCost = const Value.absent(),
                Value<int> platformFee = const Value.absent(),
                Value<int> otherCost = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SaleRecordsCompanion(
                id: id,
                itemId: itemId,
                salePrice: salePrice,
                saleDate: saleDate,
                platform: platform,
                buyerNote: buyerNote,
                shippingCost: shippingCost,
                platformFee: platformFee,
                otherCost: otherCost,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required int salePrice,
                required DateTime saleDate,
                Value<String?> platform = const Value.absent(),
                Value<String?> buyerNote = const Value.absent(),
                Value<int> shippingCost = const Value.absent(),
                Value<int> platformFee = const Value.absent(),
                Value<int> otherCost = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SaleRecordsCompanion.insert(
                id: id,
                itemId: itemId,
                salePrice: salePrice,
                saleDate: saleDate,
                platform: platform,
                buyerNote: buyerNote,
                shippingCost: shippingCost,
                platformFee: platformFee,
                otherCost: otherCost,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SaleRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SaleRecordsTable,
      SaleRecordRow,
      $$SaleRecordsTableFilterComposer,
      $$SaleRecordsTableOrderingComposer,
      $$SaleRecordsTableAnnotationComposer,
      $$SaleRecordsTableCreateCompanionBuilder,
      $$SaleRecordsTableUpdateCompanionBuilder,
      (
        SaleRecordRow,
        BaseReferences<_$AppDatabase, $SaleRecordsTable, SaleRecordRow>,
      ),
      SaleRecordRow,
      PrefetchHooks Function()
    >;
typedef $$ItemEventsTableCreateCompanionBuilder =
    ItemEventsCompanion Function({
      required String id,
      required String itemId,
      required String eventType,
      required DateTime eventDate,
      required String title,
      Value<String?> description,
      Value<int?> amount,
      Value<String> imagePaths,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ItemEventsTableUpdateCompanionBuilder =
    ItemEventsCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<String> eventType,
      Value<DateTime> eventDate,
      Value<String> title,
      Value<String?> description,
      Value<int?> amount,
      Value<String> imagePaths,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ItemEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemEventsTable> {
  $$ItemEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItemEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemEventsTable> {
  $$ItemEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemId => $composableBuilder(
    column: $table.itemId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItemEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemEventsTable> {
  $$ItemEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get imagePaths => $composableBuilder(
    column: $table.imagePaths,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ItemEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemEventsTable,
          ItemEventRow,
          $$ItemEventsTableFilterComposer,
          $$ItemEventsTableOrderingComposer,
          $$ItemEventsTableAnnotationComposer,
          $$ItemEventsTableCreateCompanionBuilder,
          $$ItemEventsTableUpdateCompanionBuilder,
          (
            ItemEventRow,
            BaseReferences<_$AppDatabase, $ItemEventsTable, ItemEventRow>,
          ),
          ItemEventRow,
          PrefetchHooks Function()
        > {
  $$ItemEventsTableTableManager(_$AppDatabase db, $ItemEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> eventDate = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<String> imagePaths = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ItemEventsCompanion(
                id: id,
                itemId: itemId,
                eventType: eventType,
                eventDate: eventDate,
                title: title,
                description: description,
                amount: amount,
                imagePaths: imagePaths,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required String eventType,
                required DateTime eventDate,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<int?> amount = const Value.absent(),
                Value<String> imagePaths = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ItemEventsCompanion.insert(
                id: id,
                itemId: itemId,
                eventType: eventType,
                eventDate: eventDate,
                title: title,
                description: description,
                amount: amount,
                imagePaths: imagePaths,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItemEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemEventsTable,
      ItemEventRow,
      $$ItemEventsTableFilterComposer,
      $$ItemEventsTableOrderingComposer,
      $$ItemEventsTableAnnotationComposer,
      $$ItemEventsTableCreateCompanionBuilder,
      $$ItemEventsTableUpdateCompanionBuilder,
      (
        ItemEventRow,
        BaseReferences<_$AppDatabase, $ItemEventsTable, ItemEventRow>,
      ),
      ItemEventRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$SaleRecordsTableTableManager get saleRecords =>
      $$SaleRecordsTableTableManager(_db, _db.saleRecords);
  $$ItemEventsTableTableManager get itemEvents =>
      $$ItemEventsTableTableManager(_db, _db.itemEvents);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
