import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/app/theme.dart';
import 'package:wuji/domain/models/enums.dart';
import 'package:wuji/domain/models/item.dart';
import 'package:wuji/shared/widgets/common.dart';

void main() {
  testWidgets('深色模式下核心组件正常渲染', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(),
      home: const Scaffold(
        body: Column(
          children: [
            StatusChip(ItemStatus.sold),
            MetricTile(label: '当前拥有', value: '10 件', subValue: '总额 ¥9,999'),
          ],
        ),
      ),
    ));
    expect(find.text('已转卖'), findsOneWidget);
    expect(find.text('当前拥有'), findsOneWidget);
    expect(find.text('10 件'), findsOneWidget);
  });

  testWidgets('浅色模式组件渲染', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light(),
      home: const Scaffold(
        body: StatusChip(ItemStatus.idle),
      ),
    ));
    expect(find.text('闲置'), findsOneWidget);
  });

  testWidgets('InfoRow 空值不渲染', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: const Scaffold(body: InfoRow('品牌', null)),
    ));
    expect(find.byType(InfoRow), findsOneWidget);
    expect(find.text('品牌'), findsNothing);
  });

  testWidgets('DailyCostText 负数显示为日均收益', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: DailyCostText(dailyCostMinor: -250)),
    ));
    expect(find.text('日均收益 ¥2.5'), findsOneWidget);
  });

  testWidgets('DailyCostText 正数显示为日均成本', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: DailyCostText(dailyCostMinor: 9091)),
    ));
    expect(find.text('日均 ¥90.9'), findsOneWidget);
  });

  testWidgets('EmptyView 展示标题与副标题', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: EmptyView(
          icon: Icons.inbox,
          title: '还没有物品',
          subtitle: '点击 + 添加',
        ),
      ),
    ));
    expect(find.text('还没有物品'), findsOneWidget);
    expect(find.text('点击 + 添加'), findsOneWidget);
  });

  test('Item copyWith 清空位置', () {
    final item = Item(
      id: '1',
      name: 'x',
      categoryId: 'c',
      categoryName: '其他',
      purchasePrice: 100,
      purchaseDate: DateTime(2026, 1, 1),
      locationId: 'loc',
      locationName: '家',
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );
    final cleared = item.copyWith(clearLocation: true);
    expect(cleared.locationId, isNull);
    expect(cleared.locationName, isNull);
  });

  test('状态枚举受控且中文标签正确', () {
    expect(ItemStatus.values.length, 10);
    expect(ItemStatus.fromName('sold'), ItemStatus.sold);
    expect(ItemStatus.fromName('不存在的值'), ItemStatus.inUse);
    expect(ItemStatus.sold.isOwned, isFalse);
    expect(ItemStatus.lent.isOwned, isTrue);
  });
}
