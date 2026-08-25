import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/services/item_insights.dart';

Item _item(
  String id, {
  int price = 100,
  ItemStatus status = ItemStatus.inUse,
  String? locationId,
  String? cover,
  int? warrantyMonths,
  DateTime? purchaseDate,
  String? channel,
}) =>
    Item(
      id: id,
      name: '物品$id',
      categoryId: 'c',
      categoryName: '其他',
      purchasePrice: price,
      purchaseDate: purchaseDate ?? DateTime(2026, 8, 1),
      status: status,
      locationId: locationId,
      coverImagePath: cover,
      warrantyMonths: warrantyMonths,
      purchaseChannel: channel,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

void main() {
  final now = DateTime(2026, 8, 24);

  test('价格缺失：0 元且非礼物才计入', () {
    final items = [
      _item('a', price: 0),
      _item('gift', price: 0, status: ItemStatus.gifted),
      _item('gift2', price: 0, channel: '礼物'),
      _item('ok', price: 100),
    ];
    final r = ItemInsightService.analyze(items, const {}, now: now);
    expect(r.missingPrice.map((i) => i.id), ['a']);
  });

  test('位置与照片缺失检测', () {
    final items = [
      _item('noLoc'),
      _item('noImg', locationId: 'L', cover: null),
      _item('full', locationId: 'L', cover: 'x.jpg'),
    ];
    final r = ItemInsightService.analyze(items, const {}, now: now);
    expect(r.missingLocation.map((i) => i.id), ['noLoc']);
    expect(r.missingImage.map((i) => i.id), ['noLoc', 'noImg']);
  });

  test('长期闲置：状态闲置且超过阈值天数', () {
    final items = [
      _item('oldIdle',
          status: ItemStatus.idle, purchaseDate: DateTime(2026, 1, 1)),
      _item('newIdle',
          status: ItemStatus.idle, purchaseDate: DateTime(2026, 8, 20)),
      _item('inUseOld', purchaseDate: DateTime(2026, 1, 1)),
    ];
    final r = ItemInsightService.analyze(items, const {},
        idleThresholdDays: 90, now: now);
    expect(r.longIdle.map((i) => i.id), ['oldIdle']);
  });

  test('保修将到期检测', () {
    final items = [
      _item('soon', warrantyMonths: 1, purchaseDate: DateTime(2026, 7, 20)),
      _item('long', warrantyMonths: 24),
    ];
    final r = ItemInsightService.analyze(items, const {}, now: now);
    expect(r.expiringWarranty.map((i) => i.id), ['soon']);
  });

  test('高日均成本榜：持有物品取前 3 按降序', () {
    final items = [
      _item('cheap', price: 100, purchaseDate: DateTime(2026, 1, 1)),
      _item('mid', price: 10000, purchaseDate: DateTime(2026, 8, 20)),
      _item('high', price: 1000000, purchaseDate: DateTime(2026, 8, 20)),
      _item('soldOut', price: 999999, status: ItemStatus.sold),
    ];
    final r = ItemInsightService.analyze(items, const {}, now: now);
    expect(r.highDailyCost.first.id, 'high');
    expect(r.highDailyCost.length, 3);
    expect(r.highDailyCost.map((i) => i.id), isNot(contains('soldOut')));
  });

  test('数据健康时 isClean 为真', () {
    final items = [
      _item('ok', price: 100, locationId: 'L', cover: 'x.jpg'),
    ];
    final r = ItemInsightService.analyze(items, const {}, now: now);
    expect(r.isClean, isTrue);
    expect(r.entries(), isEmpty);
  });

  test('回收站物品不参与体检', () {
    final items = [
      _item('deleted', price: 0)
          .copyWith(deletedAt: now),
    ];
    final r = ItemInsightService.analyze(items, const {}, now: now);
    expect(r.missingPrice, isEmpty);
  });
}
