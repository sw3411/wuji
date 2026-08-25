import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/data/db/app_database.dart';
import 'package:wuji/data/repositories/item_repository.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/models/item_event.dart';

void main() {
  late AppDatabase db;
  late ItemRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = ItemRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Item buildItem(String id) => Item(
        id: id,
        name: '测试物品 $id',
        categoryId: 'cat_phone',
        categoryName: '手机数码',
        purchasePrice: 599900,
        purchaseDate: DateTime(2026, 1, 1),
        status: ItemStatus.inUse,
        tags: const ['数码'],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

  test('首次建库自动写入内置分类', () async {
    final cats = await db.select(db.categories).get();
    expect(cats.length, greaterThanOrEqualTo(22));
    expect(cats.every((c) => c.isSystem), isTrue);
  });

  test('物品新增、查询、编辑', () async {
    await repo.upsert(buildItem('a1'));
    var item = await repo.getById('a1');
    expect(item, isNotNull);
    expect(item!.name, '测试物品 a1');
    expect(item.purchasePrice, 599900);

    await repo.updateItem(item.copyWith(name: '改名了', status: ItemStatus.idle));
    item = await repo.getById('a1');
    expect(item!.name, '改名了');
    expect(item.status, ItemStatus.idle);
  });

  test('软删除进入回收站，可恢复，可永久删除', () async {
    await repo.upsert(buildItem('a2'));

    await repo.softDelete('a2');
    var deleted = await repo.getDeleted();
    expect(deleted.length, 1);
    var all = await repo.getAll();
    expect(all.firstWhere((i) => i.id == 'a2').isDeleted, isTrue);

    await repo.restore('a2');
    deleted = await repo.getDeleted();
    expect(deleted, isEmpty);

    await repo.hardDelete('a2');
    expect(await repo.getById('a2'), isNull);
  });

  test('watch 流在数据变化时推送', () async {
    final expectation = expectLater(
      repo.watchAll(),
      emitsThrough(predicate<List<Item>>((items) => items.length == 2)),
    );
    await repo.upsert(buildItem('b1'));
    await repo.upsert(buildItem('b2'));
    await expectation;
  });

  test('事件写入与查询', () async {
    await repo.upsert(buildItem('a3'));
    await repo.addEvent(ItemEvent(
      id: '',
      itemId: 'a3',
      eventType: ItemEventType.purchased,
      eventDate: DateTime(2026, 1, 1),
      title: '购买「测试物品 a3」',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ));
    final events = await repo.watchEvents('a3').first;
    expect(events.length, 1);
    expect(events.first.title, contains('购买'));
  });
}
