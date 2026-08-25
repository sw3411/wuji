import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/models/sale_record.dart';
import 'package:wuji/domain/services/item_calculator.dart';

Item _item({
  int price = 100000, // 1000.00 元
  DateTime? purchaseDate,
  ItemStatus status = ItemStatus.inUse,
}) =>
    Item(
      id: 'i1',
      name: '测试物品',
      categoryId: 'cat_phone',
      categoryName: '手机数码',
      purchasePrice: price,
      purchaseDate: purchaseDate ?? DateTime(2026, 1, 1),
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

SaleRecord _sale({
  int price = 60000, // 600 元
  DateTime? saleDate,
  int shipping = 1000, // 10 元
  int fee = 0,
  int other = 0,
}) =>
    SaleRecord(
      id: 's1',
      itemId: 'i1',
      salePrice: price,
      saleDate: saleDate ?? DateTime(2026, 1, 11),
      shippingCost: shipping,
      platformFee: fee,
      otherCost: other,
      createdAt: DateTime(2026, 1, 11),
      updatedAt: DateTime(2026, 1, 11),
    );

void main() {
  final now = DateTime(2026, 8, 21);

  group('使用天数', () {
    test('未转卖：当前日期 - 购买日期 + 1', () {
      final item = _item(purchaseDate: DateTime(2026, 8, 1));
      // 8/21 - 8/1 + 1 = 21
      expect(ItemCalculator.usedDays(item, null, now: now), 21);
    });

    test('已转卖：转卖日期 - 购买日期 + 1', () {
      final item = _item(purchaseDate: DateTime(2026, 1, 1), status: ItemStatus.sold);
      final sale = _sale(saleDate: DateTime(2026, 1, 11));
      // 1/11 - 1/1 + 1 = 11
      expect(ItemCalculator.usedDays(item, sale, now: now), 11);
    });

    test('当天购买使用天数为 1，不除以 0', () {
      final item = _item(purchaseDate: DateTime(2026, 8, 21));
      expect(ItemCalculator.usedDays(item, null, now: now), 1);
    });

    test('转卖当天与购买同一天，使用天数为 1', () {
      final item = _item(purchaseDate: DateTime(2026, 8, 21), status: ItemStatus.sold);
      final sale = _sale(saleDate: DateTime(2026, 8, 21));
      expect(ItemCalculator.usedDays(item, sale, now: now), 1);
    });
  });

  group('日均成本', () {
    test('未转卖：购买价格 / 使用天数', () {
      final item = _item(price: 100000, purchaseDate: DateTime(2026, 8, 11));
      // 1000 元 / 11 天 = 90.909... 元
      expect(ItemCalculator.dailyCost(item, null, now: now), 9091);
    });

    test('已转卖：实际损耗 / 使用天数', () {
      final item = _item(price: 100000, purchaseDate: DateTime(2026, 1, 1), status: ItemStatus.sold);
      final sale = _sale(price: 60000, shipping: 1000);
      // 实际损耗 = 1000 - (600 - 10) = 410 元；410 / 11 天 = 37.27 元
      expect(ItemCalculator.actualDepreciation(item, sale), 41000);
      expect(ItemCalculator.dailyCost(item, sale, now: now), 3727);
    });

    test('价格为 0 的礼物日均成本为 0', () {
      final item = _item(price: 0, purchaseDate: DateTime(2026, 8, 1));
      expect(ItemCalculator.dailyCost(item, null, now: now), 0);
    });
  });

  group('转卖计算', () {
    test('净收入 = 转卖价 - 运费 - 手续费 - 其他成本', () {
      final sale = _sale(price: 60000, shipping: 1000, fee: 500, other: 250);
      expect(sale.netIncome, 60000 - 1000 - 500 - 250);
    });

    test('转卖盈利：实际损耗为负', () {
      final item = _item(price: 100000, status: ItemStatus.sold);
      final sale = _sale(price: 150000, shipping: 1000, fee: 500);
      final dep = ItemCalculator.actualDepreciation(item, sale);
      expect(dep, lessThan(0));
      expect(dep, 100000 - (150000 - 1500));
    });

    test('转卖盈利时日均成本为负数（日均收益）', () {
      final item = _item(price: 100000, purchaseDate: DateTime(2026, 8, 20), status: ItemStatus.sold);
      final sale = _sale(price: 150000, saleDate: DateTime(2026, 8, 21));
      final daily = ItemCalculator.dailyCost(item, sale, now: now);
      expect(daily, lessThan(0));
      // 赚 490 元（含 10 元运费）/ 2 天 = 日均收益 245 元
      expect(daily, -24500);
    });
  });

  group('保值率', () {
    test('已转卖：净收入 / 购买价格', () {
      final item = _item(price: 100000, status: ItemStatus.sold);
      final sale = _sale(price: 60000, shipping: 0, fee: 0);
      expect(ItemCalculator.retentionRate(item, sale), closeTo(0.6, 0.001));
    });

    test('未转卖不计算保值率', () {
      final item = _item();
      expect(ItemCalculator.retentionRate(item, null), isNull);
    });

    test('购买价格为 0 时不计算保值率（避免除零）', () {
      final item = _item(price: 0, status: ItemStatus.sold);
      final sale = _sale(price: 100);
      expect(ItemCalculator.retentionRate(item, sale), isNull);
    });
  });

  group('持有时间文案', () {
    test('未转卖显示已持有', () {
      final text = ItemCalculator.holdingText(
          _item(purchaseDate: DateTime(2026, 8, 20)), null, now: now);
      expect(text, contains('已持有 2 天'));
    });

    test('已转卖显示共持有', () {
      final text = ItemCalculator.holdingText(
          _item(status: ItemStatus.sold), _sale(), now: now);
      expect(text, contains('共持有 11 天'));
    });

    test('已丢弃显示共使用', () {
      final text = ItemCalculator.holdingText(
          _item(status: ItemStatus.discarded), null, now: now);
      expect(text, contains('共使用'));
    });
  });

  group('保修状态', () {
    test('无保修信息返回 null', () {
      expect(ItemCalculator.warrantyState(_item(), now: now), isNull);
    });

    test('按保修月数推导截止日期', () {
      final item = _item(purchaseDate: DateTime(2026, 1, 1))
          .copyWith(warrantyMonths: 12);
      expect(item.effectiveWarrantyEndDate, DateTime(2027, 1, 1));
      expect(ItemCalculator.warrantyState(item, now: now),
          WarrantyState.active);
    });

    test('30 天内到期判定为即将过保', () {
      final item = _item().copyWith(
          warrantyEndDate: now.add(const Duration(days: 10)));
      expect(ItemCalculator.warrantyState(item, now: now),
          WarrantyState.expiringSoon);
    });

    test('已过期', () {
      final item = _item()
          .copyWith(warrantyEndDate: DateTime(2026, 1, 2));
      expect(
          ItemCalculator.warrantyState(item, now: now), WarrantyState.expired);
    });
  });
}
