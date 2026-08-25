import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/services/item_calculator.dart';

Item _item(
  String id, {
  int price = 10000,
  String category = '家用电器',
  DateTime? purchaseDate,
  UsageFrequency? frequency,
}) =>
    Item(
      id: id,
      name: '物品$id',
      categoryId: 'c',
      categoryName: category,
      purchasePrice: price,
      purchaseDate: purchaseDate ?? DateTime(2025, 8, 21),
      usageFrequency: frequency,
      createdAt: DateTime(2025, 8, 21),
      updatedAt: DateTime(2025, 8, 21),
    );

void main() {
  final now = DateTime(2026, 8, 21); // 持有约 12 个月

  group('品类刚需度', () {
    test('关键词映射：家电/汽车刚需，珠宝收藏悦己，其余改善', () {
      expect(ItemCalculator.necessityOf('家用电器'),
          NecessityLevel.necessary);
      expect(ItemCalculator.necessityOf('汽车用品'),
          NecessityLevel.necessary);
      expect(ItemCalculator.necessityOf('收藏品'),
          NecessityLevel.enjoyment);
      expect(ItemCalculator.necessityOf('服装'), NecessityLevel.improved);
    });
  });

  group('单次使用成本', () {
    test('频次 × 时长折算', () {
      // 每天 1 元用一年：100 元 / 365 次 ≈ 0.27 元/次
      final i = _item('a', price: 10000, frequency: UsageFrequency.daily);
      final cpu = ItemCalculator.costPerUse(i, now: now);
      expect(cpu, lessThan(30)); // < 0.3 元
      expect(cpu, greaterThan(20)); // > 0.2 元
    });

    test('未填频次按状态兜底（闲置 ≈ 几乎不用）', () {
      final idle = _item('a', price: 10000);
      // 默认状态 inUse → 每周一次估算
      final used = ItemCalculator.frequencyPerMonth(
          _item('b', price: 10000));
      expect(used, 4);
      expect(idle.purchasePrice, 10000);
    });
  });

  group('价值评估 assessValue', () {
    test('高频低价刚需 > 低频高价悦己', () {
      final good = ItemCalculator.assessValue(
        _item('good', price: 10000, frequency: UsageFrequency.daily,
            category: '家用电器'),
        now: now,
      );
      final bad = ItemCalculator.assessValue(
        _item('bad', price: 500000, frequency: UsageFrequency.rarely,
            category: '收藏品'),
        now: now,
      );
      expect(good.score, greaterThan(bad.score));
      expect(good.score, greaterThan(70));
      expect(bad.score, lessThan(50));
    });

    test('车贵但是刚需：同价同频次，刚需品类得分更高', () {
      final car = ItemCalculator.assessValue(
        _item('car', price: 1000000, frequency: UsageFrequency.often,
            category: '汽车用品'),
        now: now,
      );
      final jewelry = ItemCalculator.assessValue(
        _item('jewel', price: 1000000, frequency: UsageFrequency.often,
            category: '珠宝饰品'),
        now: now,
      );
      expect(car.score, greaterThan(jewelry.score));
    });

    test('礼物（价格 0）成本项满分', () {
      final gift = ItemCalculator.assessValue(
        _item('gift', price: 0, frequency: UsageFrequency.weekly,
            category: '玩具乐器'),
        now: now,
      );
      expect(gift.score, greaterThan(50));
    });

    test('等级分档', () {
      final great = ItemCalculator.assessValue(
        _item('g', price: 5000, frequency: UsageFrequency.daily,
            category: '厨房用品'),
        now: now,
      );
      expect(great.grade, ValueGrade.great);
    });
  });

  group('UsageFrequency', () {
    test('fromName 往返', () {
      expect(UsageFrequency.fromName('daily'), UsageFrequency.daily);
      expect(UsageFrequency.fromName(null), isNull);
      expect(UsageFrequency.fromName('不存在'), isNull);
      expect(UsageFrequency.daily.perMonth, 30);
    });
  });
}
