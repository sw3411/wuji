import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/app_database.dart';

/// 键值设置仓库。
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const String keyOnboarded = 'onboarded';
  static const String keyCurrency = 'currency';
  static const String keyDefaultChannel = 'defaultChannel';
  static const String keyDefaultViewMode = 'defaultViewMode';
  static const String keyIdleThresholdDays = 'idleThresholdDays';
  static const String keyWarrantyReminderEnabled = 'warrantyReminderEnabled';
  static const String keyWarrantyReminderDays = 'warrantyReminderDays';
  static const String keyIdleReminderEnabled = 'idleReminderEnabled';
  static const String keyMonthlyBudget = 'monthlyBudget';
  static const String keyAppLockEnabled = 'appLockEnabled';
  static const String keyThemeMode = 'themeMode';
  static const String keyItemFilter = 'itemFilter';
  static const String keyAiConfig = 'aiConfig';
  static const String keyLastBackupAt = 'lastBackupAt';

  Future<String?> get(String key) async {
    final rows = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(key))).get();
    return rows.isEmpty ? null : rows.first.value;
  }

  Future<void> set(String key, String value) async {
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion(key: Value(key), value: Value(value)),
        );
  }

  Future<bool?> getBool(String key) async {
    final v = await get(key);
    if (v == null) return null;
    return v == 'true';
  }

  Future<void> setBool(String key, bool value) => set(key, value.toString());

  Future<int?> getInt(String key) async {
    final v = await get(key);
    return v == null ? null : int.tryParse(v);
  }

  Future<void> setInt(String key, int value) => set(key, value.toString());

  Future<Map<String, dynamic>?> getJson(String key) async {
    final v = await get(key);
    if (v == null) return null;
    try {
      return jsonDecode(v) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<void> setJson(String key, Map<String, dynamic> value) =>
      set(key, jsonEncode(value));

  /// 导出全部设置。
  Future<Map<String, String>> exportAll() async {
    final rows = await _db.select(_db.settings).get();
    return {for (final r in rows) r.key: r.value};
  }

  /// 恢复设置。
  Future<void> importAll(
    Map<String, String> data, {
    bool overwrite = false,
  }) async {
    if (overwrite) {
      await (_db.delete(_db.settings)).go();
    }
    for (final e in data.entries) {
      await set(e.key, e.value);
    }
  }
}
