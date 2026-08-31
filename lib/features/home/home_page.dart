import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../app/theme.dart';
import '../../core/utils/money.dart';
import '../../data/repositories/location_repository.dart';
import '../../domain/models/item.dart';
import '../../domain/models/location.dart';
import '../../domain/models/sale_record.dart';
import '../../domain/services/backup_reminder.dart';
import '../../domain/services/item_filter.dart';
import '../../domain/services/item_insights.dart';
import '../../core/constants/location_icons.dart';
import '../../domain/services/statistics_service.dart';
import '../../shared/widgets/common.dart';
import '../ai/daily_refresh.dart';
import '../items/item_card.dart';

/// 今日页：搜索、资产摘要、待处理事项与最近变化。
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    final items = itemsAsync.valueOrNull ?? const <Item>[];
    final sales =
        ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
    final locations =
        ref.watch(locationsProvider).valueOrNull ?? const <Location>[];
    final settings = ref.watch(appSettingsProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('今日'),
            Text(_dateText(), style: AppTheme.caption(cs.onSurfaceVariant)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: '设置',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: Padding(
        // 内层 Scaffold 的 FAB 会沉到外壳悬浮玻璃底导后面，抬高避开。
        padding: const EdgeInsets.only(bottom: 88),
        child: FloatingActionButton(
          tooltip: 'AI 助手',
          onPressed: () => _openAiMenu(context),
          child: const Icon(Icons.auto_awesome),
        ),
      ),
      body: itemsAsync.isLoading
          ? loadingView
          : RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(itemsProvider);
                ref.invalidate(locationsProvider);
              },
              child: _body(
                context,
                ref,
                items,
                sales,
                locations,
                settings.currency,
                settings.idleThresholdDays,
              ),
            ),
    );
  }

  Widget _body(
    BuildContext context,
    WidgetRef ref,
    List<Item> items,
    Map<String, SaleRecord> sales,
    List<Location> locations,
    String currency,
    int idleThresholdDays,
  ) {
    final active = items.where((item) => !item.isDeleted).toList();
    if (active.isEmpty) return _emptyHome(context);

    final overview = StatisticsService.overview(active, sales);
    final insights = ItemInsightService.analyze(
      active,
      sales,
      idleThresholdDays: idleThresholdDays,
    );
    final recent = [...active]
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final tree = LocationTree(locations);
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final monthSpend = active
        .where((item) => !item.purchaseDate.isBefore(monthStart))
        .fold<int>(0, (sum, item) => sum + item.purchasePrice);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 120),
      children: [
        _SearchEntry(onSubmit: (value) => _search(context, ref, value)),
        const SizedBox(height: 16),
        _AssetOverviewCard(
          count: overview.ownedCount,
          valueText: Money.formatCompact(
            overview.ownedPurchaseTotal,
            currency: currency,
          ),
          monthText: Money.formatCompact(monthSpend, currency: currency),
          avgDailyText:
              '${overview.sumDailyCost.toStringAsFixed(1)} 元',
          onTap: () {
            ref.read(itemFilterProvider.notifier).update(ItemFilter());
            context.push('/items');
          },
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.edit_note_rounded,
                label: '记录物品',
                tint: const Color(0xFF21A36B),
                onTap: () => context.push('/item/new'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.travel_explore_rounded,
                label: '找东西',
                tint: AppTheme.infoBlue,
                onTap: () => context.go('/items'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _QuickAction(
                icon: Icons.checklist_rounded,
                label: '开始盘点',
                tint: AppTheme.okGreen,
                onTap: () => context.push('/inventory'),
              ),
            ),
          ],
        ),
        _BackupReminderCard(itemCount: active.length),
        SectionTitle(
          '待处理',
          trailing: Text(
            '${insights.entries().fold<int>(0, (sum, entry) => sum + entry.items.length)} 项',
            style: AppTheme.caption(
              Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        _AttentionPanel(
          insights: insights,
          onIdle: () {
            final filter = ItemFilter()..idleOnly = true;
            ref.read(itemFilterProvider.notifier).update(filter);
            context.push('/items');
          },
          onWarranty: () {
            final filter = ItemFilter()..expiringWarrantyOnly = true;
            ref.read(itemFilterProvider.notifier).update(filter);
            context.push('/items');
          },
          onMissingLocation: () => context.go('/locations'),
          onMaintenance: () {
            final item = insights.maintenanceDue.firstOrNull;
            if (item != null) context.push('/item/${item.id}');
          },
        ),
        const _SmartBriefCard(),
        SectionTitle(
          '最近更新',
          trailing: TextButton(
            onPressed: () => context.go('/items'),
            child: const Text('查看全部'),
          ),
        ),
        Card(
          child: Column(
            children: [
              for (var index = 0; index < recent.take(4).length; index++) ...[
                ItemListTile(
                  item: recent[index],
                  sale: sales[recent[index].id],
                  embedded: true,
                ),
                if (index != recent.take(4).length - 1)
                  const Divider(indent: 76),
              ],
            ],
          ),
        ),
        if (tree.roots.isNotEmpty) ...[
          SectionTitle(
            '常用位置',
            trailing: TextButton(
              onPressed: () => context.go('/locations'),
              child: const Text('管理'),
            ),
          ),
          Card(
            child: Column(
              children: [
                for (
                  var index = 0;
                  index < tree.roots.take(4).length;
                  index++
                ) ...[
                  _LocationRow(
                    location: tree.roots[index],
                    count: active.where((item) {
                      if (item.locationId == null) return false;
                      return tree
                          .descendantIds(tree.roots[index].id)
                          .contains(item.locationId);
                    }).length,
                    onTap: () =>
                        context.push('/locations/${tree.roots[index].id}'),
                  ),
                  if (index != tree.roots.take(4).length - 1)
                    const Divider(indent: 56),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _emptyHome(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 32),
      children: [
        Container(
          width: 84,
          height: 84,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Icon(
            Icons.inventory_2_outlined,
            size: 40,
            color: cs.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 26),
        Text('从第一件物品开始', style: AppTheme.display(cs.onSurface, size: 28)),
        const SizedBox(height: 10),
        Text(
          '记下它是什么、放在哪里、花了多少钱。以后找东西、看保修和判断是否值得留下都会更轻松。',
          style: AppTheme.body(cs.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: () => context.push('/item/new'),
          icon: const Icon(Icons.add_rounded),
          label: const Text('记录第一件物品'),
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: () => context.push('/ai/quick-add'),
          icon: const Icon(Icons.auto_awesome_outlined),
          label: const Text('用一句话快速添加'),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Icon(Icons.lock_outline, size: 17, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '无需注册，数据优先保存在本机。',
                style: AppTheme.caption(cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _search(BuildContext context, WidgetRef ref, String value) {
    final query = value.trim();
    if (query.isEmpty) return;
    final filter = ItemFilter()..search = query;
    ref.read(itemFilterProvider.notifier).update(filter);
    context.go('/items');
  }

  /// AI 入口菜单：购买决策 / 一键添加 / 对话 / 总结。
  void _openAiMenu(BuildContext context) {
    showModalBottomSheet<void>(
      useRootNavigator: true,
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 6, bottom: 4),
              child: Text('AI 助手',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart_checkout_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('购买决策建议'),
              subtitle: const Text('值不值得买？先问一句',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/purchase-eval');
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle_outline,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('一键添加物品'),
              subtitle: const Text('一句话或拍照，AI 帮你填表',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/quick-add');
              },
            ),
            ListTile(
              leading: Icon(Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('对话'),
              subtitle: const Text('问物品、查信息，支持多轮追问',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/chat');
              },
            ),
            ListTile(
              leading: Icon(Icons.insights_outlined,
                  color: Theme.of(context).colorScheme.primary),
              title: const Text('总结'),
              subtitle: const Text('九维消费洞察与诊断',
                  style: TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                context.push('/ai/insights');
              },
            ),
          ],
        ),
      ),
    );
  }

  String _dateText() {
    const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
    final now = DateTime.now();
    return '${now.month}月${now.day}日 · 星期${weekdays[now.weekday - 1]}';
  }
}

class _SearchEntry extends StatelessWidget {
  const _SearchEntry({required this.onSubmit});

  final ValueChanged<String> onSubmit;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      onSubmitted: onSubmit,
      decoration: const InputDecoration(
        hintText: '搜索物品、品牌或存放位置',
        prefixIcon: Icon(Icons.search_rounded),
        suffixIcon: Icon(Icons.arrow_forward_rounded, size: 19),
      ),
    );
  }
}

class _AssetOverviewCard extends StatelessWidget {
  const _AssetOverviewCard({
    required this.count,
    required this.valueText,
    required this.monthText,
    required this.avgDailyText,
    required this.onTap,
  });

  final int count;
  final String valueText;
  final String monthText;
  final String avgDailyText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final accent = cs.primary;
    // 深色底毛玻璃：薄荷染色面（比白玻璃深一档）+ 模糊 + 悬浮投影。
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withValues(alpha: 0.24)
                  : const Color(0x16202A24),
              blurRadius: 20,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: dark
                      ? [
                          const Color(0x592C4A3C),
                          const Color(0x3D1E4435),
                        ]
                      : [
                          const Color(0xCCD9EEE4),
                          const Color(0xB8C4E4D4),
                        ],
                ),
                border: Border.all(
                  color: dark
                      ? Colors.white.withValues(alpha: 0.14)
                      : Colors.white.withValues(alpha: 0.85),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.archive_outlined, size: 17, color: accent),
                      const SizedBox(width: 7),
                      Text('我的物品档案', style: AppTheme.label(accent)),
                      const Spacer(),
                      Icon(Icons.arrow_forward_rounded,
                          size: 17, color: accent),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // 数字居中：件数独占一行，水平居中放大。
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('$count',
                            style: AppTheme.bigNumber(accent, size: 44)),
                        Padding(
                          padding: const EdgeInsets.only(left: 5, bottom: 5),
                          child: Text('件在册',
                              style: AppTheme.subhead(
                                  dark ? AppTheme.darkOnSurfaceVariant
                                      : AppTheme.textSecondary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _InlineMetric(
                            label: '总成本', value: valueText, center: true),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: accent.withValues(alpha: 0.22),
                      ),
                      Expanded(
                        child: _InlineMetric(
                            label: '本月新增', value: monthText, center: true),
                      ),
                      Container(
                        width: 1,
                        height: 30,
                        color: accent.withValues(alpha: 0.22),
                      ),
                      Expanded(
                        child: _InlineMetric(
                            label: '日均成本',
                            value: avgDailyText,
                            center: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.label,
    required this.value,
    this.center = false,
  });

  final String label;
  final String value;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.darkOnSurface : AppTheme.textPrimary;
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: AppTheme.caption(cs.primary)),
        const SizedBox(height: 3),
        Text(value,
            textAlign: center ? TextAlign.center : TextAlign.start,
            style: AppTheme.cardTitle(ink)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.tint = const Color(0xFF21A36B),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// 每格独立的柔色（图标徽章染色）。
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.darkOnSurface : AppTheme.textPrimary;
    final accent = Theme.of(context).colorScheme.primary;
    return GlassCard(
      onTap: onTap,
      radius: 16,
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 6),
      child: Column(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: 0.26),
                  tint.withValues(alpha: 0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: tint.withValues(alpha: 0.32)),
            ),
            child: Icon(icon, size: 19, color: accent),
          ),
          const SizedBox(height: 7),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              color: ink,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttentionPanel extends StatelessWidget {
  const _AttentionPanel({
    required this.insights,
    required this.onIdle,
    required this.onWarranty,
    required this.onMissingLocation,
    required this.onMaintenance,
  });

  final ItemInsights insights;
  final VoidCallback onIdle;
  final VoidCallback onWarranty;
  final VoidCallback onMissingLocation;
  final VoidCallback onMaintenance;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    void addRow(Widget row) {
      if (rows.isNotEmpty) rows.add(const Divider(indent: 54));
      rows.add(row);
    }

    if (insights.longIdle.isNotEmpty) {
      addRow(
        _AttentionRow(
          icon: Icons.pause_circle_outline,
          title: '${insights.longIdle.length} 件物品长期闲置',
          subtitle: '可以重新利用、转卖或归档',
          tone: AppTheme.ochre,
          onTap: onIdle,
        ),
      );
    }
    if (insights.expiringWarranty.isNotEmpty) {
      addRow(
        _AttentionRow(
          icon: Icons.shield_outlined,
          title: '${insights.expiringWarranty.length} 件物品保修临近',
          subtitle: '到期前检查状态或安排送保',
          tone: AppTheme.terracottaInk,
          onTap: onWarranty,
        ),
      );
    }
    if (insights.missingLocation.isNotEmpty) {
      addRow(
        _AttentionRow(
          icon: Icons.location_off_outlined,
          title: '${insights.missingLocation.length} 件物品没有位置',
          subtitle: '补全后，下次找东西会更快',
          tone: AppTheme.steel,
          onTap: onMissingLocation,
        ),
      );
    }
    if (insights.maintenanceDue.isNotEmpty) {
      addRow(
        _AttentionRow(
          icon: Icons.build_circle_outlined,
          title: '${insights.maintenanceDue.length} 件物品需要保养',
          subtitle: '查看最近到期的保养或耗材',
          tone: AppTheme.mauve,
          onTap: onMaintenance,
        ),
      );
    }

    if (rows.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '当前没有紧急事项，物品档案状态良好。',
                  style: AppTheme.subhead(
                    Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(child: Column(children: rows));
  }
}

class _AttentionRow extends StatelessWidget {
  const _AttentionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tone,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tone;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 20, color: tone),
      ),
      title: Text(title, style: AppTheme.cardTitle(cs.onSurface)),
      subtitle: Text(subtitle, style: AppTheme.caption(cs.onSurfaceVariant)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
    );
  }
}

class _BackupReminderCard extends ConsumerWidget {
  const _BackupReminderCard({required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dismissed = ref.watch(backupReminderDismissedProvider);
    final lastBackup = ref.watch(lastBackupAtProvider).valueOrNull;
    if (dismissed || !BackupReminder.shouldRemind(lastBackup, itemCount)) {
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Material(
        color: cs.secondaryContainer,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
          child: Row(
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 20,
                color: cs.onSecondaryContainer,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lastBackup == null ? '建议为当前档案创建一次备份' : '距上次备份已超过 14 天',
                  style: AppTheme.caption(cs.onSecondaryContainer),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    await ref.read(backupServiceProvider).export();
                    ref.invalidate(lastBackupAtProvider);
                  } catch (_) {}
                },
                child: const Text('备份'),
              ),
              IconButton(
                tooltip: '本次忽略',
                onPressed: () =>
                    ref.read(backupReminderDismissedProvider.notifier).state =
                        true,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmartBriefCard extends ConsumerWidget {
  const _SmartBriefCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = ref.watch(aiConfigProvider);
    if (!config.isReady) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final digest = ref.watch(dailyDigestProvider).valueOrNull;
    final refreshing = ref.watch(digestRefreshingProvider);
    final error = ref.watch(digestErrorProvider);

    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    size: 18,
                    color: cs.secondary,
                  ),
                  const SizedBox(width: 8),
                  Text('智能简报', style: AppTheme.cardTitle(cs.onSurface)),
                  const Spacer(),
                  TextButton(
                    onPressed: refreshing
                        ? null
                        : () => runDailyAiRefresh(ref, force: true),
                    child: Text(digest == null ? '生成' : '更新'),
                  ),
                ],
              ),
              if (refreshing)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: AiTypingDots()),
                )
              else if (error != null)
                Text(error, style: AppTheme.caption(cs.error))
              else if (digest == null)
                Text(
                  '需要时再生成，物品数据只会发送到你配置的 AI 服务。',
                  style: AppTheme.caption(cs.onSurfaceVariant),
                )
              else
                MarkdownBody(
                  data: digest.text,
                  styleSheet: digestMarkdownStyle(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.location,
    required this.count,
    required this.onTap,
  });

  final Location location;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      visualDensity: VisualDensity.compact,
      leading: LocationIconBadge(location.icon, size: 36),
      title: Text(location.name, style: AppTheme.cardTitle(cs.onSurface)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$count 件', style: AppTheme.caption(cs.onSurfaceVariant)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded, size: 20),
        ],
      ),
    );
  }
}
