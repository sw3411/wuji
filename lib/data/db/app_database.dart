import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../core/constants/default_categories.dart';
import '../../domain/models/category.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_event.dart';
import '../../domain/models/location.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/models/enums.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// 主数据库。表结构见 tables.dart，行对象命名为 *Row。
@DriftDatabase(
  tables: [Items, Locations, Categories, SaleRecords, ItemEvents, Settings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'wuji'));

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
      await _seedDefaults();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // 数据库升级入口：按 schemaVersion 逐级迁移，保证老数据不丢。
      if (from == 1) {
        // v2：六维评分 + 总评分。
        await m.addColumn(items, items.scoreValue);
        await m.addColumn(items, items.scoreUsage);
        await m.addColumn(items, items.scoreFavorite);
        await m.addColumn(items, items.scoreUtilization);
        await m.addColumn(items, items.scoreCost);
        await m.addColumn(items, items.scoreRetention);
        await m.addColumn(items, items.overallScore);
      }
      if (from <= 2) {
        // v3：耗材保养周期（月）。
        await m.addColumn(items, items.maintenanceMonths);
      }
      if (from <= 3) {
        // v4：使用频次。
        await m.addColumn(items, items.usageFrequency);
      }
      if (from <= 4) {
        // v5：AI 检索标签。
        await m.addColumn(items, items.aiTags);
      }
      if (from <= 5) {
        // v6：位置预设图标。
        await m.addColumn(locations, locations.icon);
      }
    },
  );

  Future<void> _seedDefaults() async {
    for (final c in kDefaultCategories) {
      await into(categories).insert(
        CategoryRow(
          id: c.id,
          name: c.name,
          icon: c.icon,
          colorValue: c.colorValue,
          sortOrder: c.sortOrder,
          isSystem: c.isSystem,
          isHidden: false,
        ),
      );
    }
  }

  // ---------- 行 → 领域对象 ----------

  static Item toItem(ItemRow r) {
    final (aiTags, aiTagsName) = _decodeAiTags(r.aiTags);
    return Item(
      id: r.id,
      name: r.name,
      coverImagePath: r.coverImagePath,
      additionalImagePaths: _decodeList(r.additionalImagePaths),
      categoryId: r.categoryId,
      categoryName: r.categoryName,
      purchasePrice: r.purchasePrice,
      currency: r.currency,
      purchaseDate: r.purchaseDate,
      purchaseChannel: r.purchaseChannel,
      merchantName: r.merchantName,
      orderNumber: r.orderNumber,
      brand: r.brand,
      model: r.model,
      quantity: r.quantity,
      status: ItemStatus.fromName(r.status),
      locationId: r.locationId,
      locationName: r.locationName,
      locationDetail: r.locationDetail,
      locationImagePath: r.locationImagePath,
      notes: r.notes,
      tags: _decodeList(r.tags),
      isFavorite: r.isFavorite,
      scoreValue: r.scoreValue,
      scoreUsage: r.scoreUsage,
      scoreFavorite: r.scoreFavorite,
      scoreUtilization: r.scoreUtilization,
      scoreCost: r.scoreCost,
      scoreRetention: r.scoreRetention,
      overallScore: r.overallScore,
      warrantyMonths: r.warrantyMonths,
      warrantyEndDate: r.warrantyEndDate,
      maintenanceMonths: r.maintenanceMonths,
      usageFrequency: UsageFrequency.fromName(r.usageFrequency),
      aiTags: aiTags,
      aiTagsSourceName: aiTagsName,
      invoiceImagePaths: _decodeList(r.invoiceImagePaths),
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      deletedAt: r.deletedAt,
    );
  }

  static ItemsCompanion toItemsCompanion(Item i) => ItemsCompanion(
    id: Value(i.id),
    name: Value(i.name),
    coverImagePath: Value(i.coverImagePath),
    additionalImagePaths: Value(jsonEncode(i.additionalImagePaths)),
    categoryId: Value(i.categoryId),
    categoryName: Value(i.categoryName),
    purchasePrice: Value(i.purchasePrice),
    currency: Value(i.currency),
    purchaseDate: Value(i.purchaseDate),
    purchaseChannel: Value(i.purchaseChannel),
    merchantName: Value(i.merchantName),
    orderNumber: Value(i.orderNumber),
    brand: Value(i.brand),
    model: Value(i.model),
    quantity: Value(i.quantity),
    status: Value(i.status.name),
    locationId: Value(i.locationId),
    locationName: Value(i.locationName),
    locationDetail: Value(i.locationDetail),
    locationImagePath: Value(i.locationImagePath),
    notes: Value(i.notes),
    tags: Value(jsonEncode(i.tags)),
    isFavorite: Value(i.isFavorite),
    scoreValue: Value(i.scoreValue),
    scoreUsage: Value(i.scoreUsage),
    scoreFavorite: Value(i.scoreFavorite),
    scoreUtilization: Value(i.scoreUtilization),
    scoreCost: Value(i.scoreCost),
    scoreRetention: Value(i.scoreRetention),
    overallScore: Value(i.overallScore),
    warrantyMonths: Value(i.warrantyMonths),
    warrantyEndDate: Value(i.warrantyEndDate),
    maintenanceMonths: Value(i.maintenanceMonths),
    usageFrequency: Value(i.usageFrequency?.name),
    aiTags: Value(
      i.aiTags == null
          ? null
          : jsonEncode({'name': i.aiTagsSourceName, 'tags': i.aiTags}),
    ),
    invoiceImagePaths: Value(jsonEncode(i.invoiceImagePaths)),
    createdAt: Value(i.createdAt),
    updatedAt: Value(DateTime.now()),
    deletedAt: Value(i.deletedAt),
  );

  static Location toLocation(LocationRow r) => Location(
    id: r.id,
    name: r.name,
    parentId: r.parentId,
    description: r.description,
    imagePath: r.imagePath,
    icon: r.icon,
    sortOrder: r.sortOrder,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );

  static Category toCategory(CategoryRow r) => Category(
    id: r.id,
    name: r.name,
    icon: r.icon,
    colorValue: r.colorValue,
    sortOrder: r.sortOrder,
    isSystem: r.isSystem,
    isHidden: r.isHidden,
  );

  static SaleRecord toSaleRecord(SaleRecordRow r) => SaleRecord(
    id: r.id,
    itemId: r.itemId,
    salePrice: r.salePrice,
    saleDate: r.saleDate,
    platform: r.platform,
    buyerNote: r.buyerNote,
    shippingCost: r.shippingCost,
    platformFee: r.platformFee,
    otherCost: r.otherCost,
    notes: r.notes,
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );

  static ItemEvent toItemEvent(ItemEventRow r) => ItemEvent(
    id: r.id,
    itemId: r.itemId,
    eventType: ItemEventType.fromName(r.eventType),
    eventDate: r.eventDate,
    title: r.title,
    description: r.description,
    amount: r.amount,
    imagePaths: _decodeList(r.imagePaths),
    createdAt: r.createdAt,
    updatedAt: r.updatedAt,
  );

  /// 解析 AI 标签列：{"name":"打标时名称","tags":[...]}。
  static (List<String>?, String?) _decodeAiTags(String? raw) {
    if (raw == null || raw.isEmpty) return (null, null);
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      final tags = (m['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .where((t) => t.trim().isNotEmpty)
          .toList();
      if (tags.isEmpty) return (null, null);
      return (tags, m['name'] as String?);
    } catch (_) {
      return (null, null);
    }
  }

  static List<String> _decodeList(String json) {
    if (json.isEmpty) return const [];
    try {
      final l = jsonDecode(json) as List<dynamic>;
      return l.map((e) => e.toString()).toList();
    } catch (_) {
      return const [];
    }
  }
}
