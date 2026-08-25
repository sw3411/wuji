import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/item.dart';
import '../../domain/services/item_calculator.dart';

/// 本地通知：保修到期 + 保养/耗材到期提醒。
/// 权限只在用户开启提醒开关时请求，保存物品时只做免打扰检查。
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<bool> initialize() async {
    if (_initialized) return true;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    final ok = await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios));
    _initialized = ok ?? false;
    return _initialized;
  }

  /// 请求权限（仅在用户开启提醒开关时调用，会弹系统授权框）。
  static Future<bool> requestPermission() async {
    final ready = await initialize();
    if (!ready) return false;
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(alert: true, badge: true);
      return granted ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  /// 检查通知是否已授权（不弹框，用于保存物品时静默调度）。
  static Future<bool> isPermissionGranted() async {
    final ready = await initialize();
    if (!ready) return false;
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final permissions = await ios.checkPermissions();
      return permissions?.isEnabled ?? false;
    }
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.areNotificationsEnabled() ?? false;
    }
    return true;
  }

  /// 安排保修到期提醒（提前 N 天的早上 10 点）。
  static Future<void> scheduleWarrantyReminder(
    int itemId,
    String itemName,
    DateTime warrantyEnd,
    int daysBefore,
  ) async {
    await initialize();
    final when = tz.TZDateTime.from(
      DateTime(warrantyEnd.year, warrantyEnd.month, warrantyEnd.day, 10)
          .subtract(Duration(days: daysBefore)),
      tz.local,
    );
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      itemId.hashCode,
      '保修即将到期',
      '「$itemName」将在 $daysBefore 天后过保',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'warranty',
          '保修提醒',
          channelDescription: '物品保修即将到期提醒',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 安排保养/耗材到期提醒（到期日早上 10 点）。
  static Future<void> scheduleMaintenanceReminder(
    int notifyId,
    String itemName,
    DateTime dueDate,
    int cycleMonths,
  ) async {
    await initialize();
    final when = tz.TZDateTime.from(
      DateTime(dueDate.year, dueDate.month, dueDate.day, 10),
      tz.local,
    );
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;
    await _plugin.zonedSchedule(
      notifyId,
      '保养/耗材到期',
      '「$itemName」已到 $cycleMonths 个月保养周期',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'maintenance',
          '保养提醒',
          channelDescription: '耗材保养周期到期提醒',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// 同步单个物品的保修提醒：有保修且开关开启则调度，否则取消。
  static Future<void> syncItemReminder(
    Item item, {
    required bool enabled,
    required int daysBefore,
  }) async {
    if (!enabled) {
      await cancelItem(item.id.hashCode);
      return;
    }
    final end = item.effectiveWarrantyEndDate;
    if (end == null || item.isDeleted) {
      await cancelItem(item.id.hashCode);
      return;
    }
    if (!await isPermissionGranted()) return;
    await scheduleWarrantyReminder(
        item.id.hashCode, item.name, end, daysBefore);
  }

  /// 保养提醒通知 id：与保修 id 区分开。
  static int maintenanceNotifyId(String itemId) =>
      '${itemId}_m'.hashCode;

  /// 同步单个物品的保养提醒：设了周期则调度下次到期日，否则取消。
  static Future<void> syncMaintenanceReminder(Item item) async {
    final notifyId = maintenanceNotifyId(item.id);
    final next = item.isDeleted || !item.status.isOwned
        ? null
        : ItemCalculator.nextMaintenanceDate(item);
    if (next == null || item.maintenanceMonths == null) {
      await _plugin.cancel(notifyId);
      return;
    }
    if (!await isPermissionGranted()) return;
    await scheduleMaintenanceReminder(
        notifyId, item.name, next, item.maintenanceMonths!);
  }

  /// 取消某个物品的全部提醒（保修 + 保养）。
  static Future<void> cancelItemNotifications(String itemId) async {
    await initialize();
    await _plugin.cancel(itemId.hashCode);
    await _plugin.cancel(maintenanceNotifyId(itemId));
  }

  /// 恢复备份等场景：按当前设置重排全部物品的提醒。
  static Future<void> rescheduleAll(
    List<Item> items, {
    required bool enabled,
    required int daysBefore,
  }) async {
    for (final item in items.where((i) => !i.isDeleted)) {
      if (enabled) {
        await syncItemReminder(item, enabled: enabled, daysBefore: daysBefore);
      }
      await syncMaintenanceReminder(item);
    }
  }

  /// 取消某个物品的全部提醒。
  static Future<void> cancelItem(int itemId) async {
    await initialize();
    await _plugin.cancel(itemId.hashCode);
  }

  /// 取消全部提醒（关闭提醒开关时调用）。
  static Future<void> cancelAll() async {
    await initialize();
    await _plugin.cancelAll();
  }
}
