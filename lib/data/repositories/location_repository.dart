import 'package:drift/drift.dart';

import '../../domain/models/location.dart';
import '../db/app_database.dart';

/// 存放位置仓库（树状层级）。
class LocationRepository {
  LocationRepository(this._db);

  final AppDatabase _db;

  Stream<List<Location>> watchAll() => _db
      .select(_db.locations)
      .watch()
      .map((rows) => rows.map(AppDatabase.toLocation).toList());

  Future<List<Location>> getAll() async {
    final rows = await _db.select(_db.locations).get();
    return rows.map(AppDatabase.toLocation).toList();
  }

  Future<Location?> getById(String id) async {
    final rows = await (_db.select(
      _db.locations,
    )..where((t) => t.id.equals(id))).get();
    return rows.isEmpty ? null : AppDatabase.toLocation(rows.first);
  }

  Future<void> upsert(Location loc) async {
    await _db
        .into(_db.locations)
        .insertOnConflictUpdate(
          LocationsCompanion(
            id: Value(loc.id),
            name: Value(loc.name),
            parentId: Value(loc.parentId),
            description: Value(loc.description),
            imagePath: Value(loc.imagePath),
            icon: Value(loc.icon),
            sortOrder: Value(loc.sortOrder),
            createdAt: Value(loc.createdAt),
            updatedAt: Value(loc.updatedAt),
          ),
        );
  }

  Future<void> delete(String id) async {
    await (_db.delete(_db.locations)..where((t) => t.id.equals(id))).go();
  }

  /// 判断位置是否仍包含物品或子位置。
  Future<bool> hasChildren(
    String id,
    List<Location> all,
    List<String> usedLocationIds,
  ) async {
    return all.any((l) => l.parentId == id) || usedLocationIds.contains(id);
  }
}

/// 位置树构建与路径查询。
class LocationTree {
  LocationTree(this.all) {
    byId = {for (final l in all) l.id: l};
  }

  final List<Location> all;
  late final Map<String, Location> byId;

  /// 完整路径，例如“家 / 卧室 / 衣柜”。
  String fullPath(String? id) {
    if (id == null) return '';
    final parts = <String>[];
    String? cur = id;
    int guard = 0;
    while (cur != null && byId.containsKey(cur) && guard < 20) {
      final loc = byId[cur]!;
      parts.insert(0, loc.name);
      cur = loc.parentId;
      guard++;
    }
    return parts.join(' / ');
  }

  /// 某位置及其所有后代 id。
  Set<String> descendantIds(String id) {
    final result = <String>{id};
    bool changed = true;
    while (changed) {
      changed = false;
      for (final l in all) {
        if (l.parentId != null &&
            result.contains(l.parentId) &&
            !result.contains(l.id)) {
          result.add(l.id);
          changed = true;
        }
      }
    }
    return result;
  }

  /// 直接子位置。
  List<Location> childrenOf(String? parentId) =>
      all.where((l) => l.parentId == parentId).toList()..sort(
        (a, b) => a.sortOrder.compareTo(b.sortOrder) == 0
            ? a.createdAt.compareTo(b.createdAt)
            : a.sortOrder.compareTo(b.sortOrder),
      );

  /// 顶级位置。
  List<Location> get roots => childrenOf(null);

  /// 搜索。
  List<Location> search(String query) {
    final q = query.trim();
    if (q.isEmpty) return all;
    return all
        .where((l) => l.name.contains(q) || (l.description ?? '').contains(q))
        .toList();
  }
}
