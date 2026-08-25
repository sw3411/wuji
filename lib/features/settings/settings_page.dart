import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_settings.dart';
import '../../app/image_store.dart';
import '../../app/providers.dart';
import '../../core/constants/app_info.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/security/app_lock.dart';
import '../../core/utils/money.dart';
import '../../domain/models/enums.dart';

/// 我的 / 设置页。
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final ai = ref.watch(aiConfigProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('${AppInfo.appName} · 我的')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _header(context, ai.isReady),
          _group(context, '偏好', [
            _dropTile(
              context,
              '货币',
              settings.currency,
              kCurrencies,
              (v) => ref
                  .read(appSettingsProvider.notifier)
                  .update(settings.copy()..currency = v),
            ),
            _dropTile(
              context,
              '默认购买渠道',
              settings.defaultChannel,
              PurchaseChannel.values.map((c) => c.label).toList(),
              (v) => ref
                  .read(appSettingsProvider.notifier)
                  .update(settings.copy()..defaultChannel = v),
            ),
            _dropTile(
              context,
              '默认视图模式',
              settings.defaultViewMode.label,
              ViewMode.values.map((v) => v.label).toList(),
              (v) => ref.read(appSettingsProvider.notifier).update(
                    settings.copy()
                      ..defaultViewMode = ViewMode.values
                          .firstWhere((m) => m.label == v),
                  ),
            ),
            _stepperTile(
              context,
              '闲置判定天数',
              settings.idleThresholdDays,
              (v) => ref
                  .read(appSettingsProvider.notifier)
                  .update(settings.copy()..idleThresholdDays = v),
            ),
            ListTile(
              leading: const Icon(Icons.savings_outlined),
              title: const Text('月度购物预算'),
              subtitle: Text(
                settings.monthlyBudgetCents > 0
                    ? '每月 ${Money.format(settings.monthlyBudgetCents)} 元'
                    : '未设置，设置后统计页显示预算进度',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _editBudget(context, ref, settings),
            ),
            SwitchListTile(
              secondary: const Icon(Icons.lock_outline),
              title: const Text('应用锁'),
              subtitle: const Text('启动与回到前台需人脸 / 指纹解锁',
                  style: TextStyle(fontSize: 12)),
              value: settings.appLockEnabled,
              onChanged: (v) => _toggleAppLock(context, ref, settings, v),
            ),
          ]),
          _group(context, 'AI 助手', [
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('AI 助手设置'),
              subtitle: Text(
                ai.isReady ? '已配置（${ai.model}）' : '未配置，点击填写 API 信息',
                style: TextStyle(
                    fontSize: 12,
                    color: ai.isReady ? cs.primary : cs.onSurfaceVariant),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/ai'),
            ),
          ]),
          _group(context, '提醒', [
            SwitchListTile(
              secondary: const Icon(Icons.shield_outlined),
              title: const Text('保修到期提醒'),
              subtitle: Text('提前 ${settings.warrantyReminderDays} 天提醒',
                  style: const TextStyle(fontSize: 12)),
              value: settings.warrantyReminderEnabled,
              onChanged: (v) async {
                if (v) {
                  final ok = await NotificationService.requestPermission();
                  if (!ok) {
                    if (context.mounted) {
                      _toast(context, '未获得通知权限，请在系统设置中开启');
                    }
                    return;
                  }
                } else {
                  unawaited(NotificationService.cancelAll());
                }
                await ref
                    .read(appSettingsProvider.notifier)
                    .update(settings.copy()..warrantyReminderEnabled = v);
                if (v) {
                  final items =
                      await ref.read(itemRepoProvider).getAll();
                  unawaited(NotificationService.rescheduleAll(items,
                      enabled: true,
                      daysBefore: settings.warrantyReminderDays));
                }
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.pause_circle_outline),
              title: const Text('长期闲置提醒'),
              value: settings.idleReminderEnabled,
              onChanged: (v) async {
                if (v) {
                  final ok = await NotificationService.requestPermission();
                  if (!ok) {
                    if (context.mounted) {
                      _toast(context, '未获得通知权限，请在系统设置中开启');
                    }
                    return;
                  }
                }
                await ref
                    .read(appSettingsProvider.notifier)
                    .update(settings.copy()..idleReminderEnabled = v);
              },
            ),
          ]),
          _group(context, '外观', [
            _dropTile(
              context,
              '深色模式',
              switch (settings.themeMode) {
                ThemeMode.system => '跟随系统',
                ThemeMode.light => '浅色',
                ThemeMode.dark => '深色',
              },
              ['跟随系统', '浅色', '深色'],
              (v) => ref.read(appSettingsProvider.notifier).update(
                    settings.copy()
                      ..themeMode = switch (v) {
                        '浅色' => ThemeMode.light,
                        '深色' => ThemeMode.dark,
                        _ => ThemeMode.system,
                      },
                  ),
            ),
          ]),
          _group(context, '数据管理', [
            ListTile(
              leading: const Icon(Icons.category_outlined),
              title: const Text('分类管理'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/categories'),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('回收站'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/trash'),
            ),
            ListTile(
              leading: const Icon(Icons.backup_outlined),
              title: const Text('数据备份'),
              subtitle: Text(_lastBackupText(ref),
                  style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _backup(ref),
            ),
            ListTile(
              leading: const Icon(Icons.restore),
              title: const Text('数据恢复'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _restore(context, ref),
            ),
            ListTile(
              leading: const Icon(Icons.table_view_outlined),
              title: const Text('导出 CSV'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                try {
                  await ref.read(backupServiceProvider).exportCsv();
                } catch (e) {
                  if (context.mounted) {
                    _toast(context, '导出失败：$e');
                  }
                }
              },
            ),
            _storageTile(context, ref),
          ]),
          _group(context, '关于', [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于 ${AppInfo.appName}'),
              subtitle: Text('v${AppInfo.version}',
                  style: const TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/settings/about'),
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: const Text('隐私说明'),
              subtitle: const Text('数据仅保存在本机', style: TextStyle(fontSize: 12)),
              onTap: () => _showPrivacy(context),
            ),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  /// 开关应用锁：先验证一次生物识别，防止他人关闭。
  Future<void> _toggleAppLock(
      BuildContext context, WidgetRef ref, AppSettings settings, bool v) async {
    final available = await AppLock.isAvailable();
    if (!available) {
      if (context.mounted) {
        _toast(context, '此设备未设置指纹 / 面容或屏幕锁，请先在系统设置中开启');
      }
      return;
    }
    bool ok;
    try {
      ok = await AppLock.authenticate(v ? '开启应用锁' : '关闭应用锁');
    } catch (e) {
      if (context.mounted) _toast(context, '验证出错：$e');
      return;
    }
    if (!ok) {
      if (context.mounted) _toast(context, '验证未通过');
      return;
    }
    await ref
        .read(appSettingsProvider.notifier)
        .update(settings.copy()..appLockEnabled = v);
    if (v) {
      // 开启后当前会话立即视为已解锁，避免开关一开就被锁住。
      ref.read(appUnlockedProvider.notifier).state = true;
    }
  }

  String _lastBackupText(WidgetRef ref) {
    return '导出包含图片的完整备份';
  }

  /// 编辑月度购物预算（元）。留空或 0 = 关闭预算。
  Future<void> _editBudget(
      BuildContext context, WidgetRef ref, AppSettings settings) async {
    final ctrl = TextEditingController(
        text: settings.monthlyBudgetCents > 0
            ? (settings.monthlyBudgetCents / 100).toStringAsFixed(0)
            : '');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('月度购物预算'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '预算金额（元 / 月）',
                hintText: '例如 3000',
              ),
            ),
            const SizedBox(height: 8),
            Text('留空表示关闭预算功能。统计页与 AI 诊断会跟踪本月花费进度。',
                style: TextStyle(
                    fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('取消')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('保存')),
        ],
      ),
    );
    final cents = Money.parse(ctrl.text);
    ctrl.dispose();
    if (confirmed != true) return;
    await ref
        .read(appSettingsProvider.notifier)
        .update(settings.copy()..monthlyBudgetCents = (cents ?? 0).clamp(0, 100 * 100 * 10000));
  }

  Widget _header(BuildContext context, bool aiReady) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('本地用户',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                Text(AppInfo.appTagline,
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Text(title,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _dropTile(BuildContext context, String title, String value,
      List<String> options, ValueChanged<String> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        items: options
            .map((o) => DropdownMenuItem(value: o, child: Text(o, style: const TextStyle(fontSize: 14))))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }

  Widget _stepperTile(BuildContext context, String title, int value,
      ValueChanged<int> onChanged) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value > 7 ? () => onChanged(value - 7) : null,
          ),
          Text('$value 天'),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 7),
          ),
        ],
      ),
    );
  }

  Widget _storageTile(BuildContext context, WidgetRef ref) {
    return FutureBuilder<int>(
      future: ImageStore.storageUsage(),
      builder: (context, snap) {
        final bytes = snap.data ?? 0;
        final mb = bytes / 1024 / 1024;
        return ListTile(
          leading: const Icon(Icons.image_outlined),
          title: const Text('图片存储占用'),
          subtitle:
              Text('${mb.toStringAsFixed(1)} MB', style: const TextStyle(fontSize: 12)),
          trailing: TextButton(
            onPressed: () => _cleanImages(context, ref),
            child: const Text('清理'),
          ),
        );
      },
    );
  }

  Future<void> _cleanImages(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('清理无引用图片'),
        content: const Text('将删除没有被任何物品、位置或事件引用的图片文件，此操作不可恢复。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('清理')),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;

    final items = await ref.read(itemRepoProvider).getAll();
    final locations = await ref.read(locationRepoProvider).getAll();
    final referenced = <String>{};
    for (final i in items) {
      if (i.coverImagePath != null) referenced.add(i.coverImagePath!);
      referenced.addAll(i.additionalImagePaths);
      referenced.addAll(i.invoiceImagePaths);
    }
    for (final l in locations) {
      if (l.imagePath != null) referenced.add(l.imagePath!);
    }
    final count = await ImageStore.cleanUnreferenced(referenced);
    if (context.mounted) {
      _toast(context, count == 0 ? '没有需要清理的图片' : '已清理 $count 张图片');
    }
  }

  Future<void> _backup(WidgetRef ref) async {
    try {
      await ref.read(backupServiceProvider).export();
    } catch (e) {
      // 分享取消不算失败。
    }
  }

  Future<void> _restore(BuildContext context, WidgetRef ref) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: false,
    );
    if (picked == null || picked.files.single.path == null) return;
    final file = File(picked.files.single.path!);

    final service = ref.read(backupServiceProvider);
    Map<String, dynamic> data;
    try {
      data = await service.validate(file);
    } catch (e) {
      if (context.mounted) _toast(context, e.toString());
      return;
    }
    if (!context.mounted) return;

    final mode = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('恢复备份'),
        content: const Text(
            '选择恢复方式：\n\n覆盖：清空现有数据后恢复\n合并：与现有数据合并（备份优先）\n\n恢复前会自动创建当前数据的临时备份。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          OutlinedButton(
              onPressed: () => Navigator.pop(context, 'merge'),
              child: const Text('合并')),
          FilledButton(
              onPressed: () => Navigator.pop(context, 'overwrite'),
              child: const Text('覆盖')),
        ],
      ),
    );
    if (mode == null) return;
    if (!context.mounted) return;

    try {
      final count =
          await service.restore(data, overwrite: mode == 'overwrite');
      if (context.mounted) {
        _toast(context, '已恢复 $count 件物品');
      }
      final restoredItems = await ref.read(itemRepoProvider).getAll();
      final s = ref.read(appSettingsProvider);
      if (s.warrantyReminderEnabled) {
        unawaited(NotificationService.rescheduleAll(restoredItems,
            enabled: true, daysBefore: s.warrantyReminderDays));
      }
    } catch (e) {
      if (context.mounted) _toast(context, e.toString());
    }
  }

  void _showPrivacy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私说明'),
        content: const Text(
          '${AppInfo.appName} 是本地优先的应用：\n\n'
          '· 所有物品数据保存在本机数据库\n'
          '· 图片保存在 App 私有目录\n'
          '· 不强制登录，不采集个人信息\n'
          '· 备份文件由你自己保管\n'
          '· AI 功能会把相关数据发送到你配置的 API 服务商，未配置时不发送任何数据',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('知道了')),
        ],
      ),
    );
  }

  void _toast(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
