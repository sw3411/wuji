import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/core/utils/money.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/services/item_filter.dart';

Item _item(
  String id, {
  String name = '物品',
  int price = 10000,
  DateTime? purchaseDate,
  ItemStatus status = ItemStatus.inUse,
  bool favorite = false,
  List<String> tags = const [],
  String? brand,
}) =>
    Item(
      id: id,
      name: name,
      categoryId: 'c1',
      categoryName: '手机数码',
      purchasePrice: price,
      purchaseDate: purchaseDate ?? DateTime(2026, 1, 1),
      status: status,
      isFavorite: favorite,
      tags: tags,
      brand: brand,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

void main() {
  group('Money 金额工具', () {
    test('整数金额精度：以分存储无浮点误差', () {
      expect(Money.parse('0.1'), 10);
      expect(Money.parse('5999'), 599900);
      expect(Money.parse('0.1')! + Money.parse('0.2')!, 30); // 0.3 元
    });

    test('格式化带千分位与货币符号', () {
      expect(Money.format(599900), '¥5,999');
      expect(Money.format(599950), '¥5,999.5');
      expect(Money.format(5, currency: 'USD'), r'$0.1'); // 保留 1 位小数（四舍五入到角）
    });

    test('紧凑格式：万/亿单位与小数位', () {
      expect(Money.formatCompact(12300), '¥123'); // 123 元
      expect(Money.formatCompact(1250), '¥12.5'); // 12.5 元
      expect(Money.formatCompact(123456789), '¥123.5万'); // 1234567.89 元
      expect(Money.formatCompact(12300000000), '¥1.2亿'); // 1.23 亿元
      expect(Money.formatCompact(-123456789), '-¥123.5万'); // 负数（日均收益）
    });

    test('解析非法输入返回 null', () {
      expect(Money.parse('abc'), isNull);
      expect(Money.parse(''), isNull);
      expect(Money.parse('-5'), isNull);
    });

    test('大金额与小数位', () {
      expect(Money.parse('12345678.99'), 1234567899);
      expect(Money.format(1234567899), '¥12,345,679'); // .99 四舍五入到角后进位
    });
  });

  group('物品筛选', () {
    final items = [
      _item('a', price: 10000, favorite: true, tags: ['数码'], brand: 'Apple'),
      _item('b', price: 500000, status: ItemStatus.sold),
      _item('c', price: 20000, purchaseDate: DateTime(2026, 8, 1)),
      _item('d', price: 100, status: ItemStatus.idle),
      _item('recycled', price: 1)
          .copyWith(deletedAt: DateTime(2026, 8, 1)),
    ];

    test('回收站物品始终被过滤', () {
      final result = applyItemFilter(items, ItemFilter(), const {});
      expect(result.length, 4);
      expect(result.where((i) => i.id == 'recycled'), isEmpty);
    });

    test('搜索命中名称、品牌、标签', () {
      expect(
          applyItemFilter(
              items, ItemFilter()..search = 'apple', const {},
              now: DateTime(2026, 8, 21)),
          isNotEmpty);
      expect(
          applyItemFilter(
              items, ItemFilter()..search = '数码', const {},
              now: DateTime(2026, 8, 21)),
          isNotEmpty);
      expect(
          applyItemFilter(
              items, ItemFilter()..search = '不存在', const {},
              now: DateTime(2026, 8, 21)),
          isEmpty);
    });

    test('价格区间筛选', () {
      final f = ItemFilter()
        ..priceMin = 5000
        ..priceMax = 600000;
      final result = applyItemFilter(items, f, const {},
          now: DateTime(2026, 8, 21));
      expect(result.map((i) => i.id), containsAll(['a', 'b', 'c']));
      expect(result.map((i) => i.id), isNot(contains('d')));
    });

    test('收藏与转卖筛选', () {
      expect(
          applyItemFilter(
              items, ItemFilter()..favoriteOnly = true, const {},
              now: DateTime(2026, 8, 21))
              .map((i) => i.id),
          ['a']);
      expect(
          applyItemFilter(
              items, ItemFilter()..soldOnly = true, const {},
              now: DateTime(2026, 8, 21))
              .map((i) => i.id),
          ['b']);
    });

    test('购买日期筛选', () {
      final f = ItemFilter()
        ..dateStart = DateTime(2026, 7, 1)
        ..dateEnd = DateTime(2026, 8, 31);
      expect(
          applyItemFilter(items, f, const {}, now: DateTime(2026, 8, 21))
              .map((i) => i.id),
          ['c']);
    });

    test('排序：价格降序', () {
      final result = applyItemFilter(
          items, ItemFilter()..sort = ItemSort.priceDesc, const {},
          now: DateTime(2026, 8, 21));
      expect(result.first.id, 'b');
      expect(result.last.id, 'd');
    });

    test('筛选条件序列化往返', () {
      final f = ItemFilter()
        ..search = 'test'
        ..categoryIds = ['c1']
        ..statuses = [ItemStatus.inUse]
        ..priceMin = 100
        ..sort = ItemSort.priceAsc;
      final restored = ItemFilter.fromJson(f.toJson());
      expect(restored.search, 'test');
      expect(restored.categoryIds, ['c1']);
      expect(restored.statuses, [ItemStatus.inUse]);
      expect(restored.priceMin, 100);
      expect(restored.sort, ItemSort.priceAsc);
    });
  });
}
