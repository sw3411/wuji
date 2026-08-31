import 'package:flutter/material.dart';

import '../data/repositories/settings_repository.dart';

/// 全局应用设置（持久化）。
class AppSettings {
  AppSettings({
    this.currency = 'CNY',
    this.defaultChannel = '淘宝',
    this.defaultViewMode = ViewMode.card,
    this.idleThresholdDays = 90,
    this.warrantyReminderEnabled = true,
    this.warrantyReminderDays = 30,
    this.idleReminderEnabled = false,
    this.themeMode = ThemeMode.system,
    this.monthlyBudgetCents = 0,
    this.appLockEnabled = false,
  });

  String currency;
  String defaultChannel;
  ViewMode defaultViewMode;
  int idleThresholdDays;
  bool warrantyReminderEnabled;
  int warrantyReminderDays;
  bool idleReminderEnabled;
  ThemeMode themeMode;

  /// 月度购物预算（分）。0 = 未设置。
  int monthlyBudgetCents;

  /// 启动需要生物识别解锁。
  bool appLockEnabled;

  AppSettings copy() => AppSettings(
    currency: currency,
    defaultChannel: defaultChannel,
    defaultViewMode: defaultViewMode,
    idleThresholdDays: idleThresholdDays,
    warrantyReminderEnabled: warrantyReminderEnabled,
    warrantyReminderDays: warrantyReminderDays,
    idleReminderEnabled: idleReminderEnabled,
    themeMode: themeMode,
    monthlyBudgetCents: monthlyBudgetCents,
    appLockEnabled: appLockEnabled,
  );
}

enum ViewMode { card, compact, showcase }

extension ViewModeX on ViewMode {
  String get label => switch (this) {
    ViewMode.card => '卡片',
    ViewMode.compact => '紧凑',
    ViewMode.showcase => '橱窗',
  };
}

/// 设置加载/保存。
class AppSettingsController {
  AppSettingsController(this._repo);

  final SettingsRepository _repo;

  Future<AppSettings> load() async {
    final s = AppSettings();
    s.currency = await _repo.get(SettingsRepository.keyCurrency) ?? 'CNY';
    s.defaultChannel =
        await _repo.get(SettingsRepository.keyDefaultChannel) ?? '淘宝';
    s.defaultViewMode = switch (await _repo.get(
      SettingsRepository.keyDefaultViewMode,
    )) {
      'compact' => ViewMode.compact,
      'showcase' => ViewMode.showcase,
      _ => ViewMode.card,
    };
    s.idleThresholdDays =
        await _repo.getInt(SettingsRepository.keyIdleThresholdDays) ?? 90;
    s.warrantyReminderEnabled =
        await _repo.getBool(SettingsRepository.keyWarrantyReminderEnabled) ??
        true;
    s.warrantyReminderDays =
        await _repo.getInt(SettingsRepository.keyWarrantyReminderDays) ?? 30;
    s.idleReminderEnabled =
        await _repo.getBool(SettingsRepository.keyIdleReminderEnabled) ?? false;
    s.monthlyBudgetCents =
        await _repo.getInt(SettingsRepository.keyMonthlyBudget) ?? 0;
    s.appLockEnabled =
        await _repo.getBool(SettingsRepository.keyAppLockEnabled) ?? false;
    final theme = await _repo.get(SettingsRepository.keyThemeMode);
    s.themeMode = switch (theme) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    return s;
  }

  Future<void> save(AppSettings s) async {
    await _repo.set(SettingsRepository.keyCurrency, s.currency);
    await _repo.set(SettingsRepository.keyDefaultChannel, s.defaultChannel);
    await _repo.set(
      SettingsRepository.keyDefaultViewMode,
      s.defaultViewMode.name,
    );
    await _repo.setInt(
      SettingsRepository.keyIdleThresholdDays,
      s.idleThresholdDays,
    );
    await _repo.setBool(
      SettingsRepository.keyWarrantyReminderEnabled,
      s.warrantyReminderEnabled,
    );
    await _repo.setInt(
      SettingsRepository.keyWarrantyReminderDays,
      s.warrantyReminderDays,
    );
    await _repo.setBool(
      SettingsRepository.keyIdleReminderEnabled,
      s.idleReminderEnabled,
    );
    await _repo.setInt(
      SettingsRepository.keyMonthlyBudget,
      s.monthlyBudgetCents,
    );
    await _repo.setBool(SettingsRepository.keyAppLockEnabled, s.appLockEnabled);
    await _repo.set(SettingsRepository.keyThemeMode, switch (s.themeMode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    });
  }
}

/// 内置货币选项。
const List<String> kCurrencies = [
  'CNY',
  'USD',
  'EUR',
  'JPY',
  'GBP',
  'HKD',
  'TWD',
];
