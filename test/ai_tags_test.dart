import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/core/ai/ai_service.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/services/duplicate_finder.dart';

Item _item(
  String id,
  String name, {
  List<String>? aiTags,
  ItemStatus status = ItemStatus.inUse,
}) =>
    Item(
      id: id,
      name: name,
      categoryId: 'c',
      categoryName: '手机数码',
      purchasePrice: 100,
      purchaseDate: DateTime(2026, 8, 1),
      status: status,
      aiTags: aiTags,
      createdAt: DateTime(2026, 8, 1),
      updatedAt: DateTime(2026, 8, 1),
    );

void main() {
  group('DuplicateFinder AI 标签匹配', () {
    test('“华为手机”命中标签为“手机”的 oppo find x8', () {
      final items = [
        _item('a', 'oppo find x8',
            aiTags: ['手机', 'OPPO', 'Find 系列', '安卓旗舰', '通讯']),
      ];
      final r = DuplicateFinder.findSimilar('华为手机', items);
      expect(r, isNotEmpty);
      expect(r.first.item.id, 'a');
      expect(r.first.score, greaterThanOrEqualTo(90));
    });

    test('泛词“手机”命中；“吹风机”命中戴森标签', () {
      final items = [
        _item('phone', 'oppo find x8', aiTags: ['手机', 'OPPO']),
        _item('dryer', '戴森 HD16',
            aiTags: ['吹风机', '戴森', '个护电器', '干发']),
      ];
      expect(DuplicateFinder.findSimilar('手机', items).first.item.id,
          'phone');
      expect(
          DuplicateFinder.findSimilar('吹风机', items).first.item.id, 'dryer');
    });

    test('标签不相关不误报', () {
      final items = [
        _item('a', 'oppo find x8', aiTags: ['手机', 'OPPO']),
      ];
      expect(DuplicateFinder.findSimilar('洗地机', items), isEmpty);
    });

    test('无标签物品退回名称匹配', () {
      final items = [_item('a', '吹风机')];
      final r = DuplicateFinder.findSimilar('戴森吹风机', items);
      expect(r, isNotEmpty);
    });
  });

  group('parseTagsResponse', () {
    test('标准形态 {"tags":[...]}', () {
      final r = AiService.parseTagsResponse(
          '{"tags":[{"id":"a","tags":["手机","OPPO"]},{"id":"b","tags":["吹风机"]}]}');
      expect(r['a'], ['手机', 'OPPO']);
      expect(r['b'], ['吹风机']);
    });

    test('裸数组与 markdown 包裹', () {
      final r = AiService.parseTagsResponse(
          '```json\n[{"id":"a","tags":["手机"]}]\n```');
      expect(r['a'], ['手机']);
    });

    test('空标签与缺 id 被过滤', () {
      final r = AiService.parseTagsResponse(
          '{"tags":[{"id":"a","tags":["","  "]},{"tags":["x"]}]}');
      expect(r.containsKey('a'), isFalse);
      expect(r.isEmpty, isTrue);
    });
  });
}
