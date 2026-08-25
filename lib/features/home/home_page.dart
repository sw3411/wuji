import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/constants/app_info.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/money.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/models/enums.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/backup_reminder.dart';
import '../../domain/services/item_calculator.dart';
import '../../domain/services/statistics_service.dart';
import '../../shared/widgets/common.dart';
import '../ai/daily_refresh.dart';

/// 首页：总览 + 最近添加 + 常用位置 + 过保提醒 + 闲置提醒。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 每天首次打开：后台重跑九维洞察并生成今日诊断（内部有当日去重）。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(aiConfigProvider).isReady) {
        runDailyAiRefresh(ref);
      }
    });
    final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
    final sales = ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final locations =
        ref.watch(locationsProvider).valueOrNull ?? const <Location>[];
    final settings = ref.watch(appSettingsProvider);
    final loading = ref.watch(itemsProvider).isLoading;

    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        tooltip: 'AI 助手',
        onPressed: () => _openAiMenu(context),
        child: const Icon(Icons.auto_awesome),
      ),
      body: loading
          ? loadingView
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(itemsProvider),
              child: _buildBody(context, ref, items, sales, locations,
                  settings.idleThresholdDays, settings.currency),
            ),
    );
  }

  /// AI 入口菜单：对话 / 消费洞察 / 一句话添加。
  void _openAiMenu(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text('AI 助手',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('AI 对话'),
              subtitle: const Text('问物品、总结开支，支持多轮追问',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/chat');
              },
            ),
            ListTile(
              leading: Icon(Icons.insights_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('AI 消费洞察'),
              subtitle: const Text('画像 / 剁手预警 / 闲置建议 / 物品价值等 9 个维度',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/insights');
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_view_week_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('AI 周报'),
              subtitle: Text('近 7 天物品变化与下周建议',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/weekly');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart_checkout_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('AI 购买评估'),
              subtitle: Text('下单前问一句：值不值得买',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/purchase-eval');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('AI 一句话添加'),
              subtitle: const Text('说说物品，AI 帮你填表',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/quick-add');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 6) return '夜深了';
    if (h < 12) return '早上好';
    if (h < 14) return '中午好';
    if (h < 18) return '下午好';
    return '晚上好';
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<Item> items,
    Map<String, SaleRecord> sales,
    List<Location> locations,
    int idleThresholdDays,
    String currency,
  ) {
    final cs = Theme.of(context).colorScheme;
    final active = items.where((i) => !i.isDeleted).toList();
    if (active.isEmpty) {
      return ListView(children: const [
        SizedBox(height: 120),
        EmptyView(
          icon: Icons.inventory_2_outlined,
          title: '还没有记录任何物品',
          subtitle: '点击下方的 + 按钮，或让 AI 帮你一句话添加',
        ),
      ]);
    }

    final overview = StatisticsService.overview(active, sales);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthNew = active.where((i) => !i.purchaseDate.isBefore(monthStart)).toList();
    final monthPurchaseTotal =
        monthNew.fold<int>(0, (sum, i) => sum + i.purchasePrice);

    final expiring = active.where((i) {
      final s = ItemCalculator.warrantyState(i, now: now);
      return s == WarrantyState.expiringSoon || s == WarrantyState.expired;
    }).toList()
      ..sort((a, b) => (a.effectiveWarrantyEndDate ?? now)
          .compareTo(b.effectiveWarrantyEndDate ?? now));

    final idle = active
        .where((i) => i.status == ItemStatus.idle)
        .where((i) => ItemCalculator.usedDays(i, sales[i.id], now: now) >= idleThresholdDays)
        .toList();

    final tree = LocationTree(locations);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        // 页面头部：大问候语 + 品牌副语（AppBar 放不下 34px，放到正文区）。
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_greeting(),
                  style: AppTheme.display(cs.onSurface, size: 34)),
              const SizedBox(height: 6),
              Text(
                AppInfo.appTagline,
                style: AppTheme.caption(cs.onSurfaceVariant).copyWith(
                    fontFamily: AppTheme.serifFamily,
                    fontSize: 13,
                    height: 1.5,
                    letterSpacing: 0.2),
              ),
            ],
          ),
        ),
        _BackupReminderCard(
          itemCount: active.length,
          onBackedUp: () => ref.invalidate(lastBackupAtProvider),
        ),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            Expanded(
              child: MetricTile(
                label: '当前拥有',
                value: '${overview.ownedCount} 件',
                subValue:
                    '总额 ${Money.formatCompact(overview.ownedPurchaseTotal, currency: currency)}',
                accent: true,
                onTap: () {
                  final f = ref.read(itemFilterProvider).copy();
                  f.statuses = [
                    ItemStatus.inUse,
                    ItemStatus.idle,
                    ItemStatus.stored,
                    ItemStatus.lent,
                    ItemStatus.repairing,
                  ];
                  ref.read(itemFilterProvider.notifier).update(f);
                  context.push('/items');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: '本月新增',
                value: '${monthNew.length} 件',
                subValue: '花费 ${Money.formatCompact(monthPurchaseTotal, currency: currency)}',
                onTap: () {
                  final f = ref.read(itemFilterProvider).copy();
                  f.dateStart = monthStart;
                  f.dateEnd = now;
                  ref.read(itemFilterProvider.notifier).update(f);
                  context.push('/items');
                },
              ),
            ),
          ],
          ),
        ),
        if (expiring.isNotEmpty) ...[
          SectionTitle('即将过保 / 已过保',
              trailing: TextButton(
                  onPressed: () {
                    final f = ref.read(itemFilterProvider).copy();
                    f.expiringWarrantyOnly = true;
                    ref.read(itemFilterProvider.notifier).update(f);
                    context.push('/items');
                  },
                  child: const Text('全部'))),
          ...expiring.take(3).map((i) => _warnTile(
                context,
                icon: Icons.shield_outlined,
                color: const Color(0xFFE65100),
                title: i.name,
                subtitle: ItemCalculator.warrantyState(i, now: now) ==
                        WarrantyState.expired
                    ? '已过保（${Fmt.date(i.effectiveWarrantyEndDate!)}）'
                    : '还有 ${Fmt.daysBetween(now, i.effectiveWarrantyEndDate!)} 天过保',
                onTap: () => context.push('/item/${i.id}'),
              )),
        ],
        if (idle.isNotEmpty) ...[
          SectionTitle('长期闲置（超过 $idleThresholdDays 天）'),
          ...idle.take(3).map((i) => _warnTile(
                context,
                icon: Icons.pause_circle_outline,
                color: const Color(0xFFB8860B),
                title: i.name,
                subtitle:
                    '持有 ${ItemCalculator.usedDays(i, sales[i.id], now: now)} 天，仍在闲置',
                onTap: () => context.push('/item/${i.id}'),
              )),
        ],
        // 卡片主题 margin 为零，与上方指标卡/提醒行之间需显式留白。
        const SizedBox(height: 12),
        _DailyDigestCard(),
        const SizedBox(height: 4),
        SectionTitle('常用位置',
            trailing: TextButton(
                onPressed: () => context.push('/locations'),
                child: const Text('管理'))),
        ...tree.roots.take(4).map((loc) {
          final count = active
              .where((i) =>
                  i.locationId != null &&
                  tree.descendantIds(loc.id).contains(i.locationId))
              .length;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: Text(loc.name),
              trailing: Text('$count 件',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
              onTap: () => context.push('/locations/${loc.id}'),
            ),
          );
        }),
      ],
    );
  }

  Widget _warnTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        onTap: onTap,
      ),
    );
  }
}


/// 备份提醒卡片：数据量达到阈值且超过 14 天未备份时展示。
class _BackupReminderCard extends ConsumerWidget {
  const _BackupReminderCard({required this.itemCount, this.onBackedUp});

  final int itemCount;
  final VoidCallback? onBackedUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissed = ref.watch(backupReminderDismissedProvider);
    final lastBackup = ref.watch(lastBackupAtProvider).valueOrNull;
    if (dismissed) return const SizedBox.shrink();
    if (!BackupReminder.shouldRemind(lastBackup, itemCount)) {
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.cloud_upload_outlined, color: cs.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                lastBackup == null
                    ? '已有 $itemCount 件物品，建议先做一次完整备份'
                    : '距上次备份已超过 ${BackupReminder.defaultThresholdDays} 天，建议再次备份',
                style: AppTheme.caption(
                    Theme.of(context).colorScheme.onSurface),
              ),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await ref.read(backupServiceProvider).export();
                  onBackedUp?.call();
                } catch (_) {
                  // 用户取消分享不算失败。
                }
              },
              child: const Text('备份'),
            ),
            IconButton(
              tooltip: '本次启动不再提醒',
              icon: const Icon(Icons.close, size: 16),
              onPressed: () =>
                  ref.read(backupReminderDismissedProvider.notifier).state = true,
            ),
          ],
        ),
      ),
    );
  }
}


/// 首页 AI 诊断卡：九维洞察的每日综合提炼。
class _DailyDigestCard extends ConsumerWidget {
  /// 内容区固定高度：加载/占位/正文任何状态都不改变卡片高度，
  /// 避免异步加载完成时推挤上方的统计卡。
  static const double _bodyHeight = 196;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final digest = ref.watch(dailyDigestProvider).valueOrNull;
    final refreshing = ref.watch(digestRefreshingProvider);
    final progress = ref.watch(digestProgressProvider);
    final error = ref.watch(digestErrorProvider);

    // 未配置态与正常态同规格：配置是异步加载的，
    // 若未配置时用矮卡片，ready 翻转后卡片长高会推挤上方布局。
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: cs.primary),
                const SizedBox(width: 6),
                const Text('AI 诊断',
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                const Spacer(),
                if (digest?.generatedAt != null && !refreshing)
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${digest!.generatedAt!.month}/${digest.generatedAt!.day} ${digest.generatedAt!.hour.toString().padLeft(2, '0')}:${digest.generatedAt!.minute.toString().padLeft(2, '0')}',
                      style: AppTheme.caption(cs.onSurfaceVariant),
                    ),
                  ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: '立即更新',
                  onPressed: refreshing ? null : () => runDailyAiRefresh(ref, force: true),
                  icon: refreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, size: 20),
                ),
              ],
            ),
          ),
          SizedBox(
            height: _bodyHeight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: _body(context, ref,
                  digest: digest,
                  refreshing: refreshing,
                  progress: progress,
                  error: error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref, {
    required DailyDigest? digest,
    required bool refreshing,
    required String? progress,
    required String? error,
  }) {
    final cs = Theme.of(context).colorScheme;
    if (!ref.watch(aiConfigProvider).isReady) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('配置 AI 后，每天自动生成消费诊断',
                style: AppTheme.caption(cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            FilledButton.tonal(
              onPressed: () => context.push('/settings/ai'),
              child: const Text('去配置'),
            ),
          ],
        ),
      );
    }
    if (refreshing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  progress == null ? '正在更新九维洞察…' : '正在生成 $progress',
                  style: AppTheme.caption(cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          if (digest != null) ...[
            const SizedBox(height: 12),
            Text('当前仍显示上一次的诊断结果',
                style: AppTheme.caption(cs.onSurfaceVariant)),
          ],
        ],
      );
    }
    if (error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: cs.error, size: 22),
          const SizedBox(height: 8),
          Text(error,
              textAlign: TextAlign.center,
              style: AppTheme.caption(cs.onSurfaceVariant)),
        ],
      );
    }
    if (digest == null) {
      return Center(
        child: Text(
          '每天首次打开自动更新九维洞察并生成诊断，也可点右上角立即更新',
          style: AppTheme.caption(cs.onSurfaceVariant),
        ),
      );
    }
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: MarkdownBody(
        data: digest.text,
        styleSheet: digestMarkdownStyle(context),
      ),
    );
  }
}
