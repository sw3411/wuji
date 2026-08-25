import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/services/item_retrieval.dart';

Item _item(
  String name, {
  int price = 100000,
  ItemStatus status = ItemStatus.inUse,
  String? brand,
  String category = '手机数码',
  int? warrantyMonths,
  DateTime? purchaseDate,
}) =>
    Item(
      id: name,
      name: name,
      categoryId: category == '手机数码' ? 'c1' : 'c2',
      categoryName: category,
      purchasePrice: price,
      purchaseDate: purchaseDate ?? DateTime(2026, 8, 1),
      status: status,
      brand: brand,
      warrantyMonths: warrantyMonths,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

void main() {
  final now = DateTime(2026, 8, 24);

  test('实体命中：问题里出现物品名，相关物品排最前', () {
    final items = [
      _item('iPhone 15'),
      _item('吹风机', category: '家用电器', brand: '戴森'),
      _item('山地车', category: '运动户外'),
    ];
    final r = ItemRetrieval.retrieve('吹风机保修到哪天', items, const {}, now: now);
    expect(r.matched.first.name, '吹风机');
    expect(r.matched.length, 1);
  });

  test('品牌命中：问题里出现品牌也能召回', () {
    final items = [
      _item('吹风机', brand: '戴森'),
      _item('手机'),
    ];
    final r = ItemRetrieval.retrieve('戴森那件多少钱', items, const {}, now: now);
    expect(r.matched.first.name, '吹风机');
  });

  test('话题延续：上一轮话题物品即使问题无实体也进入候选', () {
    final items = [
      _item('山地车'),
      _item('手机'),
    ];
    final r = ItemRetrieval.retrieve('它是哪天买的', items, const {},
        subjectHints: ['山地车'], now: now);
    expect(r.matched.map((i) => i.name), contains('山地车'));
    expect(r.hints, contains('山地车'));
  });

  test('统计摘要：包含最贵榜、分类分布、闲置与保修', () {
    final items = [
      _item('手机', price: 599900),
      _item('吹风机', price: 299000, category: '家用电器',
          warrantyMonths: 1, purchaseDate: DateTime(2026, 7, 20)),
      _item('旧显示器', price: 10000, status: ItemStatus.idle),
    ];
    final digest = ItemRetrieval.buildDigest(items, const {}, now: now);
    expect(digest, contains('最贵前5：手机'));
    expect(digest, contains('手机数码'));
    expect(digest, contains('闲置1件：旧显示器'));
    expect(digest, contains('保修将到期'));
  });

  test('无实体问题时明细为空，摘要兜底', () {
    final items = [_item('手机')];
    final r = ItemRetrieval.retrieve('我最贵的是什么', items, const {}, now: now);
    expect(r.matched, isEmpty);
    expect(r.digest, contains('最贵前5：手机'));
  });

  test('空数据返回摘要提示', () {
    final r = ItemRetrieval.retrieve('有什么', const [], const {}, now: now);
    expect(r.digest, '（暂无物品）');
  });
}
