import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/app/providers.dart';
import 'package:wuji/data/db/app_database.dart';
import 'package:wuji/domain/models/category.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/domain/models/sale_record.dart';
import 'package:wuji/domain/models/location.dart';
import 'package:wuji/features/items/item_form_page.dart';
import 'package:wuji/features/items/sale_form_sheet.dart';

/// widget test 在 fake-async 下运行，drift 的 watch 流会留下悬挂 Timer，
/// 因此用静态流覆盖分类与位置 Provider；数据库仍用内存库支撑保存路径。
final _staticCategories = Stream.value(const [
  Category(
      id: 'cat_phone',
      name: '手机数码',
      icon: 'phone_android',
      colorValue: 0xFF2E7D6B,
      sortOrder: 1,
      isSystem: true),
  Category(
      id: 'cat_other',
      name: '其他',
      icon: 'category',
      colorValue: 0xFF78909C,
      sortOrder: 2,
      isSystem: true),
]);

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> pumpForm(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dbProvider.overrideWithValue(db),
          categoriesProvider.overrideWith((ref) => _staticCategories),
          locationsProvider.overrideWith((ref) => Stream.value(const <Location>[])),
          itemsProvider.overrideWith((ref) => Stream.value(const <Item>[])),
          salesMapProvider.overrideWith((ref) => Stream.value(const <String, SaleRecord>{})),
        ],
        child: const MaterialApp(home: ItemFormPage()),
      ),
    );
    // 等待默认分类加载与首帧后处理。
    await tester.pumpAndSettle(const Duration(seconds: 1));
  }

  /// 让草稿防抖定时器在假异步中触发完毕，避免 teardown 时 Timer 悬挂。
  Future<void> flushTimers(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  }

  testWidgets('添加物品表单校验：空名称与空金额报错', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextField).first, '');
    await tester.tap(find.text('保存'));
    await flushTimers(tester);

    expect(find.text('名称不能为空'), findsOneWidget);
    expect(find.text('金额不能为空'), findsOneWidget);
  });

  testWidgets('添加物品表单校验：负数金额被拒绝', (tester) async {
    await pumpForm(tester);

    await tester.enterText(find.byType(TextField).first, '手机');
    final priceField = find.byType(TextField).at(1);
    await tester.enterText(priceField, '-100');
    await tester.tap(find.text('保存'));
    await flushTimers(tester);

    expect(find.text('金额不能为空'), findsOneWidget);
  });

  testWidgets('表单包含基础与更多信息的字段', (tester) async {
    await pumpForm(tester);
    expect(find.text('物品名称 *'), findsOneWidget);
    expect(find.text('购买价格（元）*'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('更多信息'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('更多信息'), findsOneWidget);
    await flushTimers(tester);
  });

  testWidgets('已转卖表单弹出并校验价格', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () =>
                    showSaleFormSheet(context, itemId: 'i1'),
                child: const Text('打开转卖'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('打开转卖'));
    await tester.pumpAndSettle();

    expect(find.text('转卖信息'), findsOneWidget);
    expect(find.text('转卖平台'), findsOneWidget);
    expect(find.text('平台手续费（元）'), findsOneWidget);

    // 价格为空时保存报错。
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();
    expect(find.text('请输入有效的转卖价格'), findsOneWidget);
  });
}
