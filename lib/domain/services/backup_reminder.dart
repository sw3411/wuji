/// 备份提醒判定（纯函数，便于测试）。
class BackupReminder {
  const BackupReminder._();

  static const int defaultThresholdDays = 14;
  static const int defaultMinItems = 3;

  /// 数据量达到 [minItems] 且距上次备份超过 [thresholdDays] 天（或从未备份）时提醒。
  static bool shouldRemind(
    DateTime? lastBackupAt,
    int itemCount, {
    DateTime? now,
    int thresholdDays = defaultThresholdDays,
    int minItems = defaultMinItems,
  }) {
    if (itemCount < minItems) return false;
    final now_ = now ?? DateTime.now();
    if (lastBackupAt == null) return true;
    return now_.difference(lastBackupAt).inDays >= thresholdDays;
  }
}
