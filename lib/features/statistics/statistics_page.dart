import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/money.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/budget.dart';
import '../../domain/services/item_insights.dart';
import '../../domain/services/statistics_service.dart';
import '../ai/insights_page.dart';
import '../items/item_card.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/treemap_view.dart';

/// 统计页：总览、分类、趋势、使用价值。
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final sales =
        ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final currency = ref.watch(appSettingsProvider).currency;

    final cs = Theme.of(context).colorScheme;
    final active = items.where((i) => !i.isDeleted).toList();
    if (active.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('统计')),
        body: const EmptyView(
          icon: Icons.bar_chart_outlined,
          title: '暂无统计数据',
          subtitle: '添加物品后这里会展示消费结构和使用价值分析',
        ),
      );
    }

    final overview = StatisticsService.overview(active, sales);
    final idle =
        active.where((i) => i.status == ItemStatus.idle).toList();
    final insights = ItemInsightService.analyze(active, sales,
        idleThresholdDays: ref.watch(appSettingsProvider).idleThresholdDays);
    final categories = StatisticsService.byCategory(active, sales)
      ..sort((a, b) => b.purchaseTotal.compareTo(a.purchaseTotal));
    final trend = StatisticsService.monthlyTrend(active, sales, months: 6);
    final highestDaily =
        StatisticsService.dailyCostRanking(active, sales, descending: true, limit: 5);
    final lowestDaily =
        StatisticsService.dailyCostRanking(active, sales, descending: false, limit: 5);
    final longest =
        StatisticsService.longestUsedRanking(active, sales, limit: 5);
    final retention = StatisticsService.retentionRanking(active, sales, limit: 5);

    // 月度预算进度（未设置预算时不显示）。
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthSpend = active
        .where((i) => !i.purchaseDate.isBefore(monthStart))
        .fold<int>(0, (sum, i) => sum + i.purchasePrice);
    final budget = BudgetStatus.evaluate(
        monthSpend, ref.watch(appSettingsProvider).monthlyBudgetCents);

    // 状态分布与渠道分布。
    final byStatus = <ItemStatus, int>{};
    for (final i in active) {
      byStatus[i.status] = (byStatus[i.status] ?? 0) + 1;
    }
    final statusRows = byStatus.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final byChannel = <String, (int, int)>{};
    for (final i in active) {
      final key = i.purchaseChannel ?? '未记录';
      final prev = byChannel[key] ?? (0, 0);
      byChannel[key] = (prev.$1 + 1, prev.$2 + i.purchasePrice);
    }
    final channelRows = byChannel.entries.toList()
      ..sort((a, b) => b.value.$2.compareTo(a.value.$2));

    return Scaffold(
      appBar: AppBar(title: const Text('统计')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          _section(context, '总览'),
          // 主数字英雄卡：页面第一视觉。
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('当前拥有', style: AppTheme.label(cs.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Text(
                          '${overview.ownedCount}',
                          style: AppTheme.bigNumber(cs.onSurface, size: 40),
                        ),
                        const SizedBox(height: 2),
                        Text('件物品',
                            style: AppTheme.caption(cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 56, color: cs.outlineVariant),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('持有购买总额',
                            style: AppTheme.label(cs.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Money.format(overview.ownedPurchaseTotal,
                                currency: currency),
                            style: AppTheme.bigNumber(cs.onSurface, size: 30),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                            '历史购买 ${Money.formatCompact(overview.historyPurchaseTotal, currency: currency)}',
                            style: AppTheme.caption(cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (budget != null) ...[
            _BudgetCard(budget: budget, currency: currency),
            const SizedBox(height: 10),
          ],
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.9,
            children: [
              MetricTile(
                  label: '转卖回收净收入',
                  value: Money.formatCompact(overview.saleNetIncomeTotal,
                      currency: currency)),
              MetricTile(
                  label: '历史实际损耗',
                  value: Money.formatCompact(overview.historyDepreciationTotal,
                      currency: currency)),
              MetricTile(
                  label: '平均日均成本',
                  value: '${overview.avgDailyCost.toStringAsFixed(1)} 元'),
              MetricTile(label: '长期闲置', value: '${idle.length} 件'),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: Icon(Icons.workspace_premium_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('年度账单'),
              subtitle: const Text('全年花费 · 最贵一笔 · 转卖回收 · AI 年度总结',
                  style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/stats/yearly'),
            ),
          ),

          AiInsightGrid(insights: insights),

          _section(context, '物品体检'),
          _InsightBoard(insights: insights),

          if (categories.isNotEmpty) ...[
            _section(context, '分类分布'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    TreemapView(
                      height: 230,
                      tiles: categories
                          .take(8)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) => TreemapTile(
                                label: e.value.categoryName,
                                value: e.value.purchaseTotal,
                                subtitle:
                                    '${Money.formatCompact(e.value.purchaseTotal, currency: currency)} · ${((e.value.purchaseTotal / (overview.ownedPurchaseTotal == 0 ? 1 : overview.ownedPurchaseTotal)) * 100).toStringAsFixed(0)}%',
                                color: treemapPalette(
                                        Theme.of(context).brightness)[e.key %
                                    treemapPalette(
                                        Theme.of(context).brightness).length],
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    ...categories.take(8).map((c) {
                      final idx = categories.indexOf(c);
                      final palette =
                          treemapPalette(Theme.of(context).brightness);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: palette[idx % palette.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                                child:
                                    Text('${c.categoryName} · ${c.count}件')),
                            Text(
                              Money.formatCompact(c.purchaseTotal,
                                  currency: currency),
                              style: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],

          // 状态分布：物品在生命周期各阶段的件数。
          if (statusRows.length > 1) ...[
            _section(context, '状态分布'),
            _distCard(
              context,
              [
                for (final e in statusRows)
                  _DistRow(e.key.label, e.value / statusRows.first.value,
                      '${e.value} 件'),
              ],
            ),
          ],

          // 渠道分布：钱都花在了哪个渠道。
          if (channelRows.length > 1) ...[
            _section(context, '购买渠道'),
            _distCard(
              context,
              [
                for (final e in channelRows)
                  _DistRow(
                      e.key,
                      e.value.$2 / channelRows.first.value.$2,
                      '${Money.formatCompact(e.value.$2, currency: currency)}'
                      ' · ${e.value.$1}件'),
              ],
            ),
          ],

          _section(context, '月度趋势'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('购买金额（元）',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 160,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        lineTouchData: LineTouchData(
                          enabled: true,
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (spots) => spots
                                .map((e) => LineTooltipItem(
                                      Money.formatCompact(
                                          (e.y * 100).round()),
                                      const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: trend
                                .asMap()
                                .entries
                                .map((e) => FlSpot(
                                    e.key.toDouble(),
                                    (e.value.purchaseTotal / 100)
                                        .toDouble()))
                                .toList(),
                            isCurved: true,
                            curveSmoothness: 0.3,
                            preventCurveOverShooting: true,
                            barWidth: 2.5,
                            color: AppTheme.green,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, _, __, ___) =>
                                  FlDotCirclePainter(
                                radius: 3.5,
                                color: AppTheme.green,
                                strokeWidth: 0,
                              ),
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.green.withValues(alpha: 0.10),
                            ),
                          ),
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 44,
                              interval: _niceInterval(trend),
                              getTitlesWidget: (v, _) => Text(
                                Money.formatCompact((v * 100).round()),
                                style: const TextStyle(fontSize: 9.5),
                              ),
                            ),
                          ),
                          rightTitles: const AxisTitles(),
                          topTitles: const AxisTitles(),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  trend[v.toInt().clamp(0, trend.length - 1)]
                                      .monthKey
                                      .substring(5),
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: _niceInterval(trend),
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: cs.outlineVariant,
                            strokeWidth: 0.8,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            children: trend
                                .map((m) => Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Column(
                                        children: [
                                          Text(m.monthKey.substring(5),
                                              style:
                                                  const TextStyle(fontSize: 10)),
                                          Text('${m.newCount}件/${m.saleIncome == 0 ? '—' : '${(m.saleIncome / 100).toStringAsFixed(0)}元'}',
                                              style: const TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          _section(context, '使用价值'),
          Card(
            child: Column(
              children: [
                _rankTile(context, '日均成本最高', Icons.trending_up,
                    highestDaily, (r) => '${(r.dailyCost / 100).toStringAsFixed(1)} 元/天'),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _rankTile(context, '日均成本最低', Icons.trending_down,
                    lowestDaily, (r) => '${(r.dailyCost / 100).toStringAsFixed(1)} 元/天'),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _rankTile(context, '使用时间最长', Icons.schedule, longest,
                    (r) => '${r.value.toInt()} 天'),
                if (retention.isNotEmpty) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _rankTile(context, '转卖保值率最高', Icons.currency_exchange,
                      retention, (r) => '${(r.value * 100).toStringAsFixed(0)}%'),
                ],
                if (idle.isNotEmpty) ...[
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.pause_circle_outline,
                            size: 18, color: Color(0xFFB8860B)),
                        const SizedBox(width: 8),
                        Text('闲置物品 ${idle.length} 件',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            final f = ref.read(itemFilterProvider).copy();
                            f.idleOnly = true;
                            ref.read(itemFilterProvider.notifier).update(f);
                            context.push('/items');
                          },
                          child: const Text('查看'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 折线图 y 轴的整洁刻度间隔（元）。
  double _niceInterval(List<MonthlyStats> trend) {
    final maxY = trend.fold<double>(
        0, (m, t) => m > t.purchaseTotal / 100 ? m : t.purchaseTotal / 100);
    if (maxY <= 0) return 1;
    final raw = maxY / 3;
    final mag = math.pow(10, (math.log(raw) / math.ln10).floor()).toDouble();
    final norm = raw / mag;
    final nice = norm <= 1
        ? 1
        : norm <= 2
            ? 2
            : norm <= 5
                ? 5
                : 10;
    return nice * mag;
  }

  Widget _section(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 8),
      child: Text(title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600)),
    );
  }

  Widget _rankTile(BuildContext context, String title, IconData icon,
      List<ValueRanking> ranking, String Function(ValueRanking) valueText) {
    if (ranking.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 13)),
            const Spacer(),
            Text('暂无数据',
                style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 6),
          ...ranking.take(3).map((r) => ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                visualDensity: VisualDensity.compact,
                title: Text(r.item.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(valueText(r),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600)),
                onTap: () => context.push('/item/${r.item.id}'),
              )),
        ],
      ),
    );
  }
}


/// 本地物品体检看板：不依赖 AI，逐项可点开清单。
class _InsightBoard extends StatelessWidget {
  const _InsightBoard({required this.insights});

  final ItemInsights insights;

  static const Map<String, IconData> _icons = {
    'missing_price': Icons.payments_outlined,
    'missing_location': Icons.place_outlined,
    'missing_image': Icons.image_not_supported_outlined,
    'long_idle': Icons.pause_circle_outline,
    'expiring_warranty': Icons.shield_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final entries = insights.entries();
    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.verified_outlined, color: AppTheme.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text('数据很健康：价格、位置、照片完整，无长期闲置',
                    style: AppTheme.caption(cs.onSurface)),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Column(
        children: [
          for (final e in entries)
            ListTile(
              leading: Icon(_icons[e.id], color: AppTheme.greenDark),
              title: Text('${e.title} · ${e.items.length} 件',
                  style: AppTheme.cardTitle(cs.onSurface)),
              subtitle:
                  Text(e.description, style: AppTheme.caption(cs.onSurfaceVariant)),
              trailing: const Icon(Icons.chevron_right, size: 18),
              onTap: () => _openItems(context, e),
            ),
        ],
      ),
    );
  }

  void _openItems(BuildContext context, InsightEntry entry) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${entry.title}（${entry.items.length} 件）',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: entry.items
                    .map((i) => ItemCard(item: i))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 月度预算进度卡：本月已花费 / 预算，80% 转警示色，100% 转超支色。
class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.currency});

  final BudgetStatus budget;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = switch (budget.level) {
      BudgetLevel.ok => cs.primary,
      BudgetLevel.warning => const Color(0xFF9C8A52),
      BudgetLevel.exceeded => const Color(0xFFAD6A63),
    };
    final statusText = switch (budget.level) {
      BudgetLevel.ok => '剩余 ${Money.format(budget.remainingCents, currency: currency)}',
      BudgetLevel.warning => '仅剩 ${Money.format(budget.remainingCents, currency: currency)}，接近预算',
      BudgetLevel.exceeded => '已超支 ${Money.format(-budget.remainingCents, currency: currency)}',
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.savings_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                Text('本月预算', style: AppTheme.label(cs.onSurfaceVariant)),
                const Spacer(),
                Text(statusText,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  Money.formatCompact(budget.spentCents, currency: currency),
                  style: AppTheme.bigNumber(color, size: 26),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2, left: 6),
                  child: Text(
                    '/ ${Money.formatCompact(budget.budgetCents, currency: currency)}',
                    style: AppTheme.caption(cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: budget.ratio.clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: cs.surfaceContainerHighest,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 分布卡中的一行数据。
class _DistRow {
  const _DistRow(this.label, this.ratio, this.trailing);

  final String label;
  final double ratio;
  final String trailing;
}

/// 通用分布卡：标签 + 比例条 + 尾注，用于状态/渠道分布。
Widget _distCard(BuildContext context, List<_DistRow> rows) {
  final cs = Theme.of(context).colorScheme;
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var idx = 0; idx < rows.length; idx++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 68,
                    child: Text(
                      rows[idx].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: rows[idx].ratio.clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: cs.surfaceContainerHighest,
                        color: idx == 0
                            ? cs.primary
                            : cs.primary.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 96,
                    child: Text(
                      rows[idx].trailing,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
