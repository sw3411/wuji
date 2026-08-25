import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/services/budget.dart';
import 'package:wuji/domain/services/duplicate_finder.dart';

Item _item(
  String id,
  String name, {
  int price = 100,
  ItemStatus status = ItemStatus.inUse,
  String? brand,
  bool deleted = false,
}) =>
    Item(
      id: id,
      name: name,
      categoryId: 'c',
      categoryName: '其他',
      purchasePrice: price,
      purchaseDate: DateTime(2026, 8, 1),
      status: status,
      brand: brand,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
      deletedAt: deleted ? DateTime(2026, 8, 2) : null,
    );

void main() {
  group('BudgetStatus', () {
    test('预算为 0 时返回 null', () {
      expect(BudgetStatus.evaluate(50000, 0), isNull);
      expect(BudgetStatus.evaluate(0, 0), isNull);
    });

    test('三档预警级别与剩余额度', () {
      final ok = BudgetStatus.evaluate(10000, 30000)!;
      expect(ok.level, BudgetLevel.ok);
      expect(ok.remainingCents, 20000);

      final warning = BudgetStatus.evaluate(26000, 30000)!;
      expect(warning.level, BudgetLevel.warning);

      final exceeded = BudgetStatus.evaluate(35000, 30000)!;
      expect(exceeded.level, BudgetLevel.exceeded);
      expect(exceeded.remainingCents, -5000);
    });

    test('恰好 80% 属于警示档', () {
      final b = BudgetStatus.evaluate(8000, 10000)!;
      expect(b.level, BudgetLevel.warning);
    });
  });

  group('DuplicateFinder', () {
    test('完全同名匹配最高分', () {
      final items = [_item('a', '吹风机')];
      final r = DuplicateFinder.findSimilar('吹风机', items);
      expect(r.length, 1);
      expect(r.first.score, 100);
    });

    test('包含关系匹配（大小写与空格归一）', () {
      final items = [_item('a', 'Dyson 吹风机')];
      final r = DuplicateFinder.findSimilar('吹风机', items);
      expect(r, isNotEmpty);
      expect(r.first.item.id, 'a');
    });

    test('二元组重合：中文名近似匹配', () {
      final items = [_item('a', '戴森吹风机')];
      final r = DuplicateFinder.findSimilar('松下吹风机', items);
      expect(r, isNotEmpty); // “吹风机”三字重叠
    });

    test('无关物品不误报', () {
      final items = [_item('a', ' iPhone 15'), _item('b', '乐高积木')];
      expect(DuplicateFinder.findSimilar('洗地机', items), isEmpty);
    });

    test('同品牌加分、排除自身、跳过已删除与已转卖', () {
      final items = [
        _item('self', '耳机'),
        _item('sold', '耳机 Pro', status: ItemStatus.sold),
        _item('gone', '耳机 Max', deleted: true),
        _item('same', '耳机 Air', brand: 'Apple'),
        _item('other', '耳机 Mini'),
      ];
      final r = DuplicateFinder.findSimilar('耳机',
          items,
          excludeId: 'self',
          brand: 'Apple');
      expect(r.first.item.id, 'same'); // 同品牌排最前
      expect(r.map((m) => m.item.id), isNot(contains('sold')));
      expect(r.map((m) => m.item.id), isNot(contains('gone')));
      expect(r.map((m) => m.item.id), isNot(contains('self')));
    });

    test('名称过短或为空不检测', () {
      final items = [_item('a', '手机')];
      expect(DuplicateFinder.findSimilar('', items), isEmpty);
      expect(DuplicateFinder.findSimilar('手', items), isEmpty);
    });
  });
}
