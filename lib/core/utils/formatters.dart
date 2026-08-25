import 'package:intl/intl.dart';

/// 日期与文本格式化工具。
class Fmt {
  Fmt._();

  static String date(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  static String month(DateTime d) => DateFormat('yyyy-MM').format(d);

  static String dateCn(DateTime d) => DateFormat('yyyy年M月d日').format(d);

  /// 简短月份：25年3月。
  static String monthCn(DateTime d) => '${d.year % 100}年${d.month}月';

  static String dateTime(DateTime d) => DateFormat('yyyy-MM-dd HH:mm').format(d);

  /// 仅日期部分（去掉时分秒）。
  static DateTime dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static int daysBetween(DateTime from, DateTime to) {
    final a = dayOnly(from);
    final b = dayOnly(to);
    return b.difference(a).inDays;
  }

  static String ellipsis(String s, int max) =>
      s.length <= max ? s : '${s.substring(0, max)}…';
}
