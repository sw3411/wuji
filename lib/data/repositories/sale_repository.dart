import 'package:drift/drift.dart';

import '../../domain/models/sale_record.dart';
import '../db/app_database.dart';

/// 转卖记录仓库。
class SaleRepository {
  SaleRepository(this._db);

  final AppDatabase _db;

  Future<Map<String, SaleRecord>> getAllByItemId() async {
    final rows = await _db.select(_db.saleRecords).get();
    return {
      for (final r in rows) r.itemId: AppDatabase.toSaleRecord(r),
    };
  }

  Stream<Map<String, SaleRecord>> watchAllByItemId() {
    return _db.select(_db.saleRecords).watch().map((rows) {
      return {
        for (final r in rows) r.itemId: AppDatabase.toSaleRecord(r),
      };
    });
  }

  Future<SaleRecord?> getByItemId(String itemId) async {
    final rows = await (_db.select(_db.saleRecords)
          ..where((t) => t.itemId.equals(itemId)))
        .get();
    return rows.isEmpty ? null : AppDatabase.toSaleRecord(rows.first);
  }

  Future<void> upsert(SaleRecord s) async {
    await _db.into(_db.saleRecords).insertOnConflictUpdate(SaleRecordsCompanion(
          id: Value(s.id),
          itemId: Value(s.itemId),
          salePrice: Value(s.salePrice),
          saleDate: Value(s.saleDate),
          platform: Value(s.platform),
          buyerNote: Value(s.buyerNote),
          shippingCost: Value(s.shippingCost),
          platformFee: Value(s.platformFee),
          otherCost: Value(s.otherCost),
          notes: Value(s.notes),
          createdAt: Value(s.createdAt),
          updatedAt: Value(DateTime.now()),
        ));
  }

  Future<void> deleteByItemId(String itemId) async {
    await (_db.delete(_db.saleRecords)..where((t) => t.itemId.equals(itemId))).go();
  }
}
