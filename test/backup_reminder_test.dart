import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/domain/services/backup_reminder.dart';

void main() {
  final now = DateTime(2026, 8, 24);

  test('数据量不足时不提醒', () {
    expect(
        BackupReminder.shouldRemind(null, 2, now: now), isFalse);
    expect(
        BackupReminder.shouldRemind(null, 3, now: now), isTrue);
  });

  test('从未备份且数据足够时提醒', () {
    expect(BackupReminder.shouldRemind(null, 10, now: now), isTrue);
  });

  test('距上次备份不足阈值时不提醒', () {
    expect(
        BackupReminder.shouldRemind(
            now.subtract(const Duration(days: 13)), 10,
            now: now),
        isFalse);
  });

  test('距上次备份达到阈值时提醒', () {
    expect(
        BackupReminder.shouldRemind(
            now.subtract(const Duration(days: 14)), 10,
            now: now),
        isTrue);
    expect(
        BackupReminder.shouldRemind(
            now.subtract(const Duration(days: 40)), 10,
            now: now),
        isTrue);
  });

  test('阈值可自定义', () {
    expect(
        BackupReminder.shouldRemind(
            now.subtract(const Duration(days: 7)), 10,
            now: now,
            thresholdDays: 7),
        isTrue);
    expect(
        BackupReminder.shouldRemind(
            now.subtract(const Duration(days: 6)), 10,
            now: now,
            thresholdDays: 7),
        isFalse);
  });
}
