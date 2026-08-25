import 'package:drift/drift.dart';

/// 物品表。金额以分（int）存储；列表字段以 JSON 文本存储。
@DataClassName('ItemRow')
class Items extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get coverImagePath => text().nullable()();
  TextColumn get additionalImagePaths => text().withDefault(const Constant('[]'))();
  TextColumn get categoryId => text()();
  TextColumn get categoryName => text()();
  IntColumn get purchasePrice => integer()();
  TextColumn get currency => text().withDefault(const Constant('CNY'))();
  DateTimeColumn get purchaseDate => dateTime()();
  TextColumn get purchaseChannel => text().nullable()();
  TextColumn get merchantName => text().nullable()();
  TextColumn get orderNumber => text().nullable()();
  TextColumn get brand => text().nullable()();
  TextColumn get model => text().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  TextColumn get status => text()();
  TextColumn get locationId => text().nullable()();
  TextColumn get locationName => text().nullable()();
  TextColumn get locationDetail => text().nullable()();
  TextColumn get locationImagePath => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text().withDefault(const Constant('[]'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  // 六维评分（0-10，可空=未评分）与总评分（0-100）。
  IntColumn get scoreValue => integer().nullable()();
  IntColumn get scoreUsage => integer().nullable()();
  IntColumn get scoreFavorite => integer().nullable()();
  IntColumn get scoreUtilization => integer().nullable()();
  IntColumn get scoreCost => integer().nullable()();
  IntColumn get scoreRetention => integer().nullable()();
  IntColumn get overallScore => integer().nullable()();
  IntColumn get warrantyMonths => integer().nullable()();
  DateTimeColumn get warrantyEndDate => dateTime().nullable()();
  IntColumn get maintenanceMonths => integer().nullable()();
  TextColumn get usageFrequency => text().nullable()();
  TextColumn get aiTags => text().nullable()();
  TextColumn get invoiceImagePaths => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

}

/// 存放位置表（树状层级）。
@DataClassName('LocationRow')
class Locations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

}

/// 分类表。
@DataClassName('CategoryRow')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text()();
  IntColumn get colorValue => integer()();
  IntColumn get sortOrder => integer()();
  BoolColumn get isSystem => boolean()();
  BoolColumn get isHidden => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

}

/// 转卖记录表。
@DataClassName('SaleRecordRow')
class SaleRecords extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  IntColumn get salePrice => integer()();
  DateTimeColumn get saleDate => dateTime()();
  TextColumn get platform => text().nullable()();
  TextColumn get buyerNote => text().nullable()();
  IntColumn get shippingCost => integer().withDefault(const Constant(0))();
  IntColumn get platformFee => integer().withDefault(const Constant(0))();
  IntColumn get otherCost => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

}

/// 物品事件表。
@DataClassName('ItemEventRow')
class ItemEvents extends Table {
  TextColumn get id => text()();
  TextColumn get itemId => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get eventDate => dateTime()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get amount => integer().nullable()();
  TextColumn get imagePaths => text().withDefault(const Constant('[]'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

}

/// 键值设置表。
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};

}
