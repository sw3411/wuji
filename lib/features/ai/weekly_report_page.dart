import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/sale_record.dart';
import '../../core/utils/money.dart';
import '../../shared/widgets/common.dart';
import 'daily_refresh.dart';

/// AI 周报：近 7 天物品变化 + AI 总结。
class WeeklyReportPage extends ConsumerWidget {
  const WeeklyReportPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 每周首次打开自动生成（内部有本周去重）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(aiConfigProvider).isReady) {
        runWeeklyAiReport(ref);
      }
    });

    final cs = Theme.of(context).colorScheme;
    final config = ref.watch(aiConfigProvider);
    final currency = ref.watch(appSettingsProvider).currency;
    final report = ref.watch(weeklyReportProvider).valueOrNull;
    final refreshing = ref.watch(weeklyRefreshingProvider);
    final error = ref.watch(weeklyErrorProvider);

    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final sales =
        ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final stats = _WeekStats.of(items, sales);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 周报'),
        actions: [
          if (report != null)
            IconButton(
              tooltip: '分享',
              icon: const Icon(Icons.share_outlined),
              onPressed: () => Share.share(
                '【物迹周报 ${stats.newCount > 0 ? '· 新增${stats.newCount}件' : '· 本周无新增'}】\n'
                '本周新增 ${stats.newCount} 件（${Money.formatCompact(stats.newSpendCents, currency: currency)}），'
                '转卖 ${stats.soldCount} 件'
                '${stats.soldCount > 0 ? '（净回收 ${Money.formatCompact(stats.saleIncomeCents, currency: currency)}）' : ''}\n\n'
                '${report.text.replaceAll('**', '')}',
              ),
            ),
          IconButton(
            tooltip: '重新生成',
            onPressed: refreshing
                ? null
                : () => runWeeklyAiReport(ref, force: true),
            icon: refreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !config.isReady
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '配置 AI 后自动生成每周报告',
                    style: AppTheme.caption(cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => context.push('/settings/ai'),
                    child: const Text('去配置'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _statsCard(context, stats, currency),
                const SizedBox(height: 12),
                if (refreshing && report == null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          const AiTypingDots(),
                          const SizedBox(height: 12),
                          Text(
                            '正在生成本周报告…',
                            style: AppTheme.caption(cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (error != null && report == null)
                  _hintCard(context, '生成失败：$error', Icons.error_outline)
                else if (report == null)
                  _hintCard(
                    context,
                    '本周报告将在这里生成，也可立即生成',
                    Icons.insights_outlined,
                    action: FilledButton.tonal(
                      onPressed: refreshing
                          ? null
                          : () => runWeeklyAiReport(ref, force: true),
                      child: const Text('立即生成'),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: cs.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '本周总结',
                                style: AppTheme.cardTitle(cs.onSurface),
                              ),
                              const Spacer(),
                              if (report.generatedAt != null)
                                Text(
                                  '${report.generatedAt!.month}/${report.generatedAt!.day}',
                                  style: AppTheme.caption(cs.onSurfaceVariant),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          MarkdownBody(
                            data: report.text,
                            styleSheet: digestMarkdownStyle(context),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _hintCard(
    BuildContext context,
    String text,
    IconData icon, {
    Widget? action,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: AppTheme.caption(cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }

  Widget _statsCard(BuildContext context, _WeekStats stats, String currency) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('本周新增', style: AppTheme.label(cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(
                    '${stats.newCount} 件',
                    style: AppTheme.bigNumber(cs.onSurface, size: 24),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Money.formatCompact(
                      stats.newSpendCents,
                      currency: currency,
                    ),
                    style: AppTheme.caption(cs.primary),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 44, color: cs.outlineVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('本周转卖', style: AppTheme.label(cs.onSurfaceVariant)),
                  const SizedBox(height: 6),
                  Text(
                    '${stats.soldCount} 件',
                    style: AppTheme.bigNumber(cs.onSurface, size: 24),
                  ),
                  const SizedBox(height: 2),
                  if (stats.soldCount > 0)
                    Text(
                      '净回收 ${Money.formatCompact(stats.saleIncomeCents, currency: currency)}',
                      style: AppTheme.caption(AppTheme.sage),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 近 7 天本地统计（不经 AI，秒出）。
class _WeekStats {
  const _WeekStats(
    this.newCount,
    this.newSpendCents,
    this.soldCount,
    this.saleIncomeCents,
  );

  final int newCount;
  final int newSpendCents;
  final int soldCount;
  final int saleIncomeCents;

  static _WeekStats of(
    List<Item> items,
    Map<String, SaleRecord> sales, [
    DateTime? now,
  ]) {
    final n = now ?? DateTime.now();
    final weekAgo = n.subtract(const Duration(days: 7));
    final active = items.where((i) => !i.isDeleted).toList();
    final newItems = active
        .where((i) => !i.purchaseDate.isBefore(weekAgo))
        .toList();
    final sold = active
        .where(
          (i) =>
              i.status == ItemStatus.sold &&
              sales[i.id] != null &&
              !sales[i.id]!.saleDate.isBefore(weekAgo),
        )
        .toList();
    return _WeekStats(
      newItems.length,
      newItems.fold<int>(0, (s, i) => s + i.purchasePrice),
      sold.length,
      sold.fold<int>(0, (s, i) => s + (sales[i.id]?.netIncome ?? 0)),
    );
  }
}
