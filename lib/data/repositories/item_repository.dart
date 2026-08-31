import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/item_event.dart';
import '../db/app_database.dart';

/// 物品数据仓库。
class ItemRepository {
  ItemRepository(this._db);

  final AppDatabase _db;

  /// 监听所有物品（含回收站），筛选在内存中做。
  Stream<List<Item>> watchAll() {
    return _db
        .select(_db.items)
        .watch()
        .map((rows) => rows.map(AppDatabase.toItem).toList());
  }

  Stream<Item?> watchById(String id) {
    return (_db.select(_db.items)..where((t) => t.id.equals(id))).watch().map(
      (rows) => rows.isEmpty ? null : AppDatabase.toItem(rows.first),
    );
  }

  Future<Item?> getById(String id) async {
    final rows = await (_db.select(
      _db.items,
    )..where((t) => t.id.equals(id))).get();
    return rows.isEmpty ? null : AppDatabase.toItem(rows.first);
  }

  Future<List<Item>> getAll() async {
    final rows = await _db.select(_db.items).get();
    return rows.map(AppDatabase.toItem).toList();
  }

  Future<void> upsert(Item item) async {
    await _db
        .into(_db.items)
        .insertOnConflictUpdate(AppDatabase.toItemsCompanion(item));
  }

  Future<void> updateItem(Item item) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(item.id))).write(
      AppDatabase.toItemsCompanion(item),
    );
  }

  /// 软删除：进入回收站。
  Future<void> softDelete(String id) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      ItemsCompanion(deletedAt: Value(DateTime.now())),
    );
  }

  Future<void> restore(String id) async {
    await (_db.update(_db.items)..where((t) => t.id.equals(id))).write(
      const ItemsCompanion(deletedAt: Value(null)),
    );
  }

  /// 永久删除。
  Future<void> hardDelete(String id) async {
    await (_db.delete(_db.items)..where((t) => t.id.equals(id))).go();
    await (_db.delete(_db.itemEvents)..where((t) => t.itemId.equals(id))).go();
    await (_db.delete(_db.saleRecords)..where((t) => t.itemId.equals(id))).go();
  }

  Future<List<Item>> getDeleted() async {
    final rows = await (_db.select(
      _db.items,
    )..where((t) => t.deletedAt.isNotNull())).get();
    return rows.map(AppDatabase.toItem).toList();
  }

  /// 清理回收站中超过保留天数的物品，返回被删除的 id。
  Future<List<String>> purgeExpired(int retainDays) async {
    final deadline = DateTime.now().subtract(Duration(days: retainDays));
    final deleted = await getDeleted();
    final expired = deleted
        .where((i) => i.deletedAt!.isBefore(deadline))
        .map((i) => i.id)
        .toList();
    for (final id in expired) {
      await hardDelete(id);
    }
    return expired;
  }

  // ---------- 批量操作 ----------

  Future<void> batchMoveLocation(
    List<String> ids,
    String? locationId,
    String? locationName,
  ) async {
    for (final id in ids) {
      final item = await getById(id);
      if (item == null) continue;
      await updateItem(
        locationId == null
            ? item.copyWith(clearLocation: true)
            : item.copyWith(locationId: locationId, locationName: locationName),
      );
      if (locationId != null) {
        await addEvent(
          ItemEvent(
            id: '',
            itemId: id,
            eventType: ItemEventType.moved,
            eventDate: DateTime.now(),
            title: '批量移动到 $locationName',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }
    }
  }

  Future<void> batchChangeCategory(
    List<String> ids,
    String categoryId,
    String categoryName,
  ) async {
    for (final id in ids) {
      final item = await getById(id);
      if (item == null) continue;
      await updateItem(
        item.copyWith(categoryId: categoryId, categoryName: categoryName),
      );
    }
  }

  Future<void> batchSoftDelete(List<String> ids) async {
    for (final id in ids) {
      await softDelete(id);
    }
  }

  Future<void> toggleFavorite(String id) async {
    final item = await getById(id);
    if (item == null) return;
    await updateItem(item.copyWith(isFavorite: !item.isFavorite));
  }

  /// 更新已有事件（转卖联动：金额/日期变更同步到事件）。
  Future<void> updateEvent(ItemEvent event) async {
    await (_db.update(_db.itemEvents)..where((t) => t.id.equals(event.id)))
        .write(ItemEventsCompanion(
      eventDate: Value(event.eventDate),
      title: Value(event.title),
      description: Value(event.description),
      amount: Value(event.amount),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Future<void> addEvent(ItemEvent event) async {
    await _db
        .into(_db.itemEvents)
        .insert(
          ItemEventsCompanion.insert(
            id: event.id.isEmpty
                ? DateTime.now().microsecondsSinceEpoch.toString()
                : event.id,
            itemId: event.itemId,
            eventType: event.eventType.name,
            eventDate: event.eventDate,
            title: event.title,
            description: Value(event.description),
            amount: Value(event.amount),
            imagePaths: Value(jsonEncode(event.imagePaths)),
            createdAt: event.createdAt,
            updatedAt: event.updatedAt,
          ),
        );
  }

  Stream<List<ItemEvent>> watchEvents(String itemId) {
    return (_db.select(_db.itemEvents)
          ..where((t) => t.itemId.equals(itemId))
          ..orderBy([(t) => OrderingTerm.desc(t.eventDate)]))
        .watch()
        .map((rows) => rows.map(AppDatabase.toItemEvent).toList());
  }
}
