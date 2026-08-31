import 'package:drift/drift.dart';

import '../../domain/models/category.dart';
import '../db/app_database.dart';

/// 分类仓库。
class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<Category>> watchAll() =>
      _db.select(_db.categories).watch().map((rows) {
        final list = rows.map(AppDatabase.toCategory).toList();
        list.sort(
          (a, b) => a.sortOrder.compareTo(b.sortOrder) == 0
              ? a.name.compareTo(b.name)
              : a.sortOrder.compareTo(b.sortOrder),
        );
        return list;
      });

  Future<List<Category>> getAll() async {
    final rows = await _db.select(_db.categories).get();
    final list = rows.map(AppDatabase.toCategory).toList();
    list.sort(
      (a, b) => a.sortOrder.compareTo(b.sortOrder) == 0
          ? a.name.compareTo(b.name)
          : a.sortOrder.compareTo(b.sortOrder),
    );
    return list;
  }

  Future<void> upsert(Category c) async {
    await _db
        .into(_db.categories)
        .insertOnConflictUpdate(
          CategoriesCompanion(
            id: Value(c.id),
            name: Value(c.name),
            icon: Value(c.icon),
            colorValue: Value(c.colorValue),
            sortOrder: Value(c.sortOrder),
            isSystem: Value(c.isSystem),
            isHidden: Value(c.isHidden),
          ),
        );
  }

  /// 系统分类不允许删除，只能隐藏。
  Future<bool> delete(String id) async {
    final rows = await (_db.select(
      _db.categories,
    )..where((t) => t.id.equals(id))).get();
    if (rows.isEmpty || rows.first.isSystem) return false;
    await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
    return true;
  }

  Future<void> setHidden(String id, bool hidden) async {
    await (_db.update(_db.categories)..where((t) => t.id.equals(id))).write(
      CategoriesCompanion(isHidden: Value(hidden)),
    );
  }

  Future<void> reorder(List<Category> ordered) async {
    for (int i = 0; i < ordered.length; i++) {
      await (_db.update(_db.categories)
            ..where((t) => t.id.equals(ordered[i].id)))
          .write(CategoriesCompanion(sortOrder: Value(i)));
    }
  }
}
