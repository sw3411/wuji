import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/core/ai/ai_service.dart';
import 'package:wuji/domain/models/item.dart';

Item _item({
  String name = '吹风机',
  DateTime? purchaseDate,
  int? warrantyMonths,
  String? notes,
}) =>
    Item(
      id: '1',
      name: name,
      categoryId: 'c',
      categoryName: '家用电器',
      purchasePrice: 299000,
      purchaseDate: purchaseDate ?? DateTime(2026, 1, 15),
      warrantyMonths: warrantyMonths,
      notes: notes,
      createdAt: DateTime(2026, 1, 15),
      updatedAt: DateTime(2026, 1, 15),
    );

void main() {
  test('数据集包含保修截止日期，可支持保修类追问', () {
    final data = AiService.buildDataset([_item(warrantyMonths: 24)]);
    expect(data, contains('吹风机'));
    expect(data, contains('保修至 2028-01-15'));
  });

  test('无保修信息显示“无保修”', () {
    final data = AiService.buildDataset([_item()]);
    expect(data, contains('无保修'));
  });

  test('数据集包含购买日期、品牌、型号与备注', () {
    final data = AiService.buildDataset([
      _item(
        purchaseDate: DateTime(2026, 8, 23),
        notes: '放卧室抽屉，附发票',
      ).copyWith(brand: '戴森', model: 'HD16'),
    ]);
    expect(data, contains('购买日:2026-08-23'));
    expect(data, contains('品牌:戴森'));
    expect(data, contains('型号:HD16'));
    expect(data, contains('备注:放卧室抽屉，附发票'));
  });

  test('位置路径拆分：斜杠/顿号/箭头分隔', () {
    expect(AiItemDraft.splitLocationPath('家/卧室/衣柜'),
        ['家', '卧室', '衣柜']);
    expect(AiItemDraft.splitLocationPath('家、卧室、衣柜'),
        ['家', '卧室', '衣柜']);
    expect(AiItemDraft.splitLocationPath(' 客厅 > 电视柜 '),
        ['客厅', '电视柜']);
    expect(AiItemDraft.splitLocationPath('  '), isEmpty);
    expect(AiItemDraft.splitLocationPath('单一位置'), ['单一位置']);
  });

  test('回收站物品不进入数据集；空数据显示提示', () {
    final deleted =
        _item().copyWith(deletedAt: DateTime.now());
    expect(AiService.buildDataset([deleted]), contains('（暂无物品）'));
  });
}
