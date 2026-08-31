import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../core/ai/ai_prompts.dart';
import '../../domain/models/item.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/budget.dart';
import '../../domain/services/item_insights.dart';

/// 首页每日诊断的数据。
class DailyDigest {
  const DailyDigest(this.text, this.generatedAt);

  final String text;
  final DateTime? generatedAt;
}

/// 读取缓存的每日诊断。
final dailyDigestProvider = FutureProvider<DailyDigest?>((ref) async {
  final json = await ref
      .watch(settingsRepoProvider)
      .getJson('ai_daily_summary');
  if (json == null) return null;
  final text = json['text'] as String?;
  if (text == null || text.isEmpty) return null;
  final at = json['at'] as String?;
  return DailyDigest(text, at == null ? null : DateTime.tryParse(at));
});

/// 刷新进行中标记。
final digestRefreshingProvider = StateProvider<bool>((ref) => false);

/// 刷新进度文本，例如“3/9 · 剁手预警”。
final digestProgressProvider = StateProvider<String?>((ref) => null);

/// 最近一次刷新失败的原因（null=无失败）。
final digestErrorProvider = StateProvider<String?>((ref) => null);

/// 防并发锁：后台首刷与手动刷新互斥。
bool _refreshing = false;

/// 预算状态行（未设置预算时为空串）。
String _budgetLine(List<Item> items, WidgetRef ref) {
  final budgetCents = ref.read(appSettingsProvider).monthlyBudgetCents;
  if (budgetCents <= 0) return '';
  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month);
  final spent = items
      .where((i) => !i.isDeleted && !i.purchaseDate.isBefore(monthStart))
      .fold<int>(0, (sum, i) => sum + i.purchasePrice);
  final pct = (spent / budgetCents * 100).toStringAsFixed(0);
  return '月度预算：本月已花费 ${(spent / 100).toStringAsFixed(0)} 元 / '
      '预算 ${(budgetCents / 100).toStringAsFixed(0)} 元（$pct%）。';
}

/// 每日刷新：3 路并发重跑九个维度，再汇总生成首页诊断。
/// [force]=true 跳过“今天已跑过”检查（手动立即更新）。
Future<void> runDailyAiRefresh(WidgetRef ref, {bool force = false}) async {
  if (_refreshing) return;
  final repo = ref.read(settingsRepoProvider);
  final config = ref.read(aiConfigProvider);
  if (!config.isReady) return;

  final now = DateTime.now();
  final today =
      '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  if (!force) {
    final last = await repo.get('ai_daily_last_run');
    if (last == today) return;
  }
  await repo.set('ai_daily_last_run', today);

  final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
  final sales =
      ref.read(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
  if (items.where((i) => !i.isDeleted).isEmpty) return;
  final insights = ItemInsightService.analyze(
    items.where((i) => !i.isDeleted).toList(),
    sales,
  );

  // 月度预算：所有洞察维度都能感知（未设置时为 null）。
  final monthStart = DateTime(now.year, now.month);
  final monthSpend = items
      .where((i) => !i.isDeleted && !i.purchaseDate.isBefore(monthStart))
      .fold<int>(0, (sum, i) => sum + i.purchasePrice);
  final budget = BudgetStatus.evaluate(
    monthSpend,
    ref.read(appSettingsProvider).monthlyBudgetCents,
  );

  _refreshing = true;
  ref.read(digestRefreshingProvider.notifier).state = true;
  ref.read(digestErrorProvider.notifier).state = null;

  final service = ref.read(aiServiceProvider);
  final texts = <String, String>{};
  var done = 0;

  // 第一步：AI 打标（未打标或改名过的物品），失败不阻断诊断。
  await _refreshAiTags(ref, items);

  Future<void> runOne(dim) async {
    try {
      final text = await service.insightByDimension(
        dim.id,
        items,
        sales,
        insights,
        budget: budget,
      );
      texts[dim.title] = text;
      await repo.setJson('ai_insight_v2_${dim.id}', {
        'text': text,
        'at': now.toIso8601String(),
      });
    } catch (_) {
      // 单个维度失败不阻断整体。
    } finally {
      done++;
      ref.read(digestProgressProvider.notifier).state =
          '$done/${kInsightDimensions.length} · ${dim.title}';
    }
  }

  // 3 路并发：整体耗时约降为串行的 1/3。
  const concurrency = 3;
  for (var i = 0; i < kInsightDimensions.length; i += concurrency) {
    final chunk = kInsightDimensions.skip(i).take(concurrency).toList();
    await Future.wait(chunk.map(runOne));
  }

  try {
    if (texts.length < 2) {
      ref.read(digestErrorProvider.notifier).state =
          '维度生成失败（仅成功 ${texts.length} 个），请检查 AI 配置后重试';
      return;
    }
    // 附上数据体检，供“保修提醒/信息补充提醒”要点使用。
    final warrantyNames = insights.expiringWarranty
        .take(4)
        .map((i) {
          final d = i.effectiveWarrantyEndDate;
          return d == null ? i.name : '${i.name}(${d.month}/${d.day})';
        })
        .join('、');
    texts['数据体检'] =
        '价格缺失 ${insights.missingPrice.length} 件；'
        '未设位置 ${insights.missingLocation.length} 件；'
        '无照片 ${insights.missingImage.length} 件；'
        '长期闲置 ${insights.longIdle.length} 件；'
        '保修临期/过期 ${insights.expiringWarranty.length} 件'
        '${warrantyNames.isEmpty ? '' : '（$warrantyNames）'}；'
        '保养/耗材到期 ${insights.maintenanceDue.length} 件'
        '${insights.maintenanceDue.isEmpty ? '' : '（${insights.maintenanceDue.take(4).map((i) => i.name).join('、')}）'}。'
        '${_budgetLine(items, ref)}';
    final digest = await service.dailyDigest(texts);
    await repo.setJson('ai_daily_summary', {
      'text': digest,
      'at': now.toIso8601String(),
    });
  } catch (e) {
    ref.read(digestErrorProvider.notifier).state = '汇总失败：$e';
  } finally {
    _refreshing = false;
    ref.read(digestProgressProvider.notifier).state = null;
    ref.read(digestRefreshingProvider.notifier).state = false;
    ref.invalidate(dailyDigestProvider);
  }
}

/// AI 打标：只处理「未打标」或「打标后改过名」的物品，每批 40 个。
/// 标签用于购买评估/重复提醒的模糊匹配（“华为手机”命中“oppo find x8”）。
Future<void> _refreshAiTags(WidgetRef ref, List<Item> allItems) async {
  final service = ref.read(aiServiceProvider);
  final repo = ref.read(itemRepoProvider);
  final pending = allItems.where((i) {
    if (i.isDeleted) return false;
    if (i.aiTags == null || i.aiTags!.isEmpty) return true;
    return i.aiTagsSourceName != i.name;
  }).toList();
  for (var start = 0; start < pending.length; start += 40) {
    final batch = pending.skip(start).take(40).toList();
    try {
      final tagsById = await service.generateItemTags(batch);
      for (final item in batch) {
        final tags = tagsById[item.id];
        if (tags == null) continue;
        await repo.updateItem(
          item.copyWith(aiTags: tags, aiTagsSourceName: item.name),
        );
      }
    } catch (_) {
      // 打标失败不影响诊断流程。
      return;
    }
  }
}

// ---------------- AI 周报 ----------------

/// AI 周报的数据。
class WeeklyReportData {
  const WeeklyReportData(this.text, this.generatedAt, this.weekKey);

  final String text;
  final DateTime? generatedAt;

  /// 生成时的周一日期（yyyy-MM-dd），用于判断是否为本周。
  final String weekKey;
}

/// 当前周的周一日期键。
String currentWeekKey([DateTime? now]) {
  final n = now ?? DateTime.now();
  final monday = n.subtract(Duration(days: n.weekday - 1));
  return '${monday.year}-${monday.month.toString().padLeft(2, '0')}'
      '-${monday.day.toString().padLeft(2, '0')}';
}

/// 读取缓存的周报（非本周返回 null）。
final weeklyReportProvider = FutureProvider<WeeklyReportData?>((ref) async {
  final json = await ref
      .watch(settingsRepoProvider)
      .getJson('ai_weekly_summary');
  if (json == null) return null;
  final text = json['text'] as String?;
  if (text == null || text.isEmpty) return null;
  if (json['week'] != currentWeekKey()) return null;
  final at = json['at'] as String?;
  return WeeklyReportData(
    text,
    at == null ? null : DateTime.tryParse(at),
    json['week'] as String,
  );
});

final weeklyRefreshingProvider = StateProvider<bool>((ref) => false);
final weeklyErrorProvider = StateProvider<String?>((ref) => null);
bool _weeklyBusy = false;

/// 生成本周周报：每周首次打开自动跑，[force]=true 立即重新生成。
Future<void> runWeeklyAiReport(WidgetRef ref, {bool force = false}) async {
  if (_weeklyBusy) return;
  final config = ref.read(aiConfigProvider);
  if (!config.isReady) return;
  final repo = ref.read(settingsRepoProvider);
  final week = currentWeekKey();
  if (!force) {
    final cached = await repo.getJson('ai_weekly_summary');
    if (cached != null && cached['week'] == week) return;
  }

  final items = ref.read(itemsProvider).valueOrNull ?? const <Item>[];
  final sales =
      ref.read(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
  if (items.where((i) => !i.isDeleted).isEmpty) return;

  _weeklyBusy = true;
  ref.read(weeklyRefreshingProvider.notifier).state = true;
  ref.read(weeklyErrorProvider.notifier).state = null;
  try {
    final text = await ref.read(aiServiceProvider).weeklyReport(items, sales);
    await repo.setJson('ai_weekly_summary', {
      'text': text,
      'at': DateTime.now().toIso8601String(),
      'week': week,
    });
  } catch (e) {
    ref.read(weeklyErrorProvider.notifier).state = '$e';
  } finally {
    _weeklyBusy = false;
    ref.read(weeklyRefreshingProvider.notifier).state = false;
    ref.invalidate(weeklyReportProvider);
  }
}
