import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/models/category.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/models/item_event.dart';
import 'package:wuji/domain/models/location.dart';
import 'package:wuji/domain/models/sale_record.dart';

void main() {
  test('Item 序列化往返', () {
    final item = Item(
      id: 'i1',
      name: 'iPhone 15',
      coverImagePath: '/img/cover.jpg',
      additionalImagePaths: const ['/img/1.jpg', '/img/2.jpg'],
      categoryId: 'cat_phone',
      categoryName: '手机数码',
      purchasePrice: 599900,
      currency: 'CNY',
      purchaseDate: DateTime(2026, 1, 15),
      purchaseChannel: '京东',
      merchantName: '京东自营',
      orderNumber: 'JD123',
      brand: 'Apple',
      model: 'A3090',
      quantity: 1,
      status: ItemStatus.sold,
      locationId: 'loc1',
      locationName: '卧室',
      locationDetail: '抽屉',
      notes: '备注',
      tags: const ['数码', '主力机'],
      isFavorite: true,
      scoreValue: 8,
      scoreUsage: 6,
      scoreFavorite: 9,
      scoreUtilization: 7,
      scoreCost: 8,
      scoreRetention: 5,
      overallScore: 87,
      warrantyMonths: 12,
      createdAt: DateTime(2026, 1, 15),
      updatedAt: DateTime(2026, 1, 15),
      deletedAt: DateTime(2026, 8, 1),
    );
    final restored = Item.fromJson(item.toJson());
    expect(restored.id, item.id);
    expect(restored.name, item.name);
    expect(restored.purchasePrice, 599900);
    expect(restored.status, ItemStatus.sold);
    expect(restored.tags, ['数码', '主力机']);
    expect(restored.additionalImagePaths.length, 2);
    expect(restored.deletedAt, isNotNull);
    expect(restored.isFavorite, true);
    expect(restored.scoreValue, 8);
    expect(restored.scoreFavorite, 9);
    expect(restored.overallScore, 87);
    expect(restored.scoreUtilization, 7);
    expect(restored.scoreRetention, 5);
  });

  test('Location 序列化往返', () {
    final loc = Location(
      id: 'l1',
      name: '衣柜',
      parentId: 'home',
      description: '第二层',
      imagePath: '/img/loc.jpg',
      sortOrder: 2,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final restored = Location.fromJson(loc.toJson());
    expect(restored.parentId, 'home');
    expect(restored.description, '第二层');
    expect(restored.sortOrder, 2);
  });

  test('SaleRecord 序列化往返与净收入', () {
    final sale = SaleRecord(
      id: 's1',
      itemId: 'i1',
      salePrice: 80000,
      saleDate: DateTime(2026, 6, 1),
      platform: '闲鱼',
      buyerNote: '同城',
      shippingCost: 1000,
      platformFee: 500,
      otherCost: 250,
      createdAt: DateTime(2026, 6, 1),
      updatedAt: DateTime(2026, 6, 1),
    );
    final restored = SaleRecord.fromJson(sale.toJson());
    expect(restored.salePrice, 80000);
    expect(restored.netIncome, 80000 - 1750);
    expect(restored.platform, '闲鱼');
  });

  test('ItemEvent 序列化往返', () {
    final event = ItemEvent(
      id: 'e1',
      itemId: 'i1',
      eventType: ItemEventType.repaired,
      eventDate: DateTime(2026, 5, 1),
      title: '换电池',
      description: '官方售后',
      amount: 59900,
      imagePaths: const ['/img/r.jpg'],
      createdAt: DateTime(2026, 5, 1),
      updatedAt: DateTime(2026, 5, 1),
    );
    final restored = ItemEvent.fromJson(event.toJson());
    expect(restored.eventType, ItemEventType.repaired);
    expect(restored.amount, 59900);
    expect(restored.imagePaths, ['/img/r.jpg']);
  });

  test('Category 序列化往返', () {
    final c = Category(
      id: 'c1',
      name: '手办',
      icon: 'collection',
      colorValue: 0xFF2E6E5C,
      sortOrder: 5,
      isSystem: false,
      isHidden: true,
    );
    final restored = Category.fromJson(c.toJson());
    expect(restored.isHidden, true);
    expect(restored.isSystem, false);
    expect(restored.colorValue, 0xFF2E6E5C);
  });
}
