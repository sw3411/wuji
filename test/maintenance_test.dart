import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/services/item_calculator.dart';
import 'package:wuji/domain/services/item_insights.dart';

Item _item(
  String id, {
  DateTime? purchaseDate,
  int? maintenanceMonths,
  ItemStatus status = ItemStatus.inUse,
}) =>
    Item(
      id: id,
      name: '物品$id',
      categoryId: 'c',
      categoryName: '其他',
      purchasePrice: 100,
      purchaseDate: purchaseDate ?? DateTime(2026, 8, 1),
      status: status,
      maintenanceMonths: maintenanceMonths,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

void main() {
  final now = DateTime(2026, 8, 21);

  group('nextMaintenanceDate', () {
    test('未设周期返回 null', () {
      expect(ItemCalculator.nextMaintenanceDate(_item('a'), now: now),
          isNull);
      expect(
          ItemCalculator.nextMaintenanceDate(_item('a', maintenanceMonths: 0),
              now: now),
          isNull);
    });

    test('购买日在未来：下次 = 购买日 + 周期', () {
      final item = _item('a',
          purchaseDate: DateTime(2026, 8, 10), maintenanceMonths: 3);
      expect(ItemCalculator.nextMaintenanceDate(item, now: now),
          DateTime(2026, 11, 10));
    });

    test('周期已过一轮：推进到未来最近的周期点', () {
      final item = _item('a',
          purchaseDate: DateTime(2026, 1, 15), maintenanceMonths: 3);
      // 1/15 → 4/15 → 7/15 → 10/15（8/21 时下一个是 10/15）
      expect(ItemCalculator.nextMaintenanceDate(item, now: now),
          DateTime(2026, 10, 15));
    });

    test('月末截断：1月31日 + 1个月 = 2月28日', () {
      final item = _item('a',
          purchaseDate: DateTime(2026, 1, 31), maintenanceMonths: 1);
      expect(ItemCalculator.nextMaintenanceDate(item, now: DateTime(2026, 1, 5)),
          DateTime(2026, 2, 28));
    });

    test('锚定购买日：多次循环不漂移', () {
      // 购买 1/31，周期 1 个月，now 是 5 月 → 下次应是 5/31 而非漂移后的日子
      final item = _item('a',
          purchaseDate: DateTime(2026, 1, 31), maintenanceMonths: 1);
      expect(
          ItemCalculator.nextMaintenanceDate(item, now: DateTime(2026, 5, 1)),
          DateTime(2026, 5, 31));
    });
  });

  group('体检：保养/耗材到期', () {
    test('30 天内到期计入 maintenanceDue', () {
      final items = [
        _item('due',
            purchaseDate: DateTime(2026, 5, 25), maintenanceMonths: 3),
        _item('far',
            purchaseDate: DateTime(2026, 8, 1), maintenanceMonths: 12),
        _item('none', purchaseDate: DateTime(2026, 1, 1)),
      ];
      final r = ItemInsightService.analyze(items, const {}, now: now);
      expect(r.maintenanceDue.map((i) => i.id), ['due']);
      // 5/25 + 3 月 = 8/25，距 8/21 仅 4 天
    });

    test('非持有状态不计入', () {
      final items = [
        _item('sold',
            purchaseDate: DateTime(2026, 5, 25),
            maintenanceMonths: 3,
            status: ItemStatus.sold),
      ];
      final r = ItemInsightService.analyze(items, const {}, now: now);
      expect(r.maintenanceDue, isEmpty);
    });

    test('isClean 含保养维度', () {
      final r = ItemInsightService.analyze(
        [_item('due',
            purchaseDate: DateTime(2026, 5, 25), maintenanceMonths: 3)],
        const {},
        now: now,
      );
      expect(r.isClean, isFalse);
      expect(r.entries().any((e) => e.id == 'maintenance_due'), isTrue);
    });
  });
}
