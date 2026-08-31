import 'package:intl/intl.dart';

/// 金额工具。所有金额以最小货币单位（分）的 int 存储。
class Money {
  Money._();

  static final Map<String, NumberFormat> _formatters = {};

  /// 常用货币符号。
  static const Map<String, String> symbols = {
    'CNY': '¥',
    'USD': r'$',
    'EUR': '€',
    'JPY': r'JP¥',
    'GBP': '£',
    'HKD': r'HK$',
    'TWD': r'NT$',
  };

  static String symbolOf(String currency) => symbols[currency] ?? currency;

  /// 分 → 元的字符串，例如 599900 -> "5999.00"。
  static String toDecimalString(int minorUnits) {
    final negative = minorUnits < 0;
    final abs = minorUnits.abs();
    final yuan = abs ~/ 100;
    final fen = abs % 100;
    final base = fen == 0 ? '$yuan' : '$yuan.${fen.toString().padLeft(2, '0')}';
    return negative ? '-$base' : base;
  }

  /// 展示格式：带货币符号、千分位，小数保留 1 位（整数不带 .0）。
  static String format(int minorUnits, {String currency = 'CNY'}) {
    final symbol = symbolOf(currency);
    // 四舍五入到角，避免 0.999 之类的进位抖动。
    final tenths = (minorUnits / 10).round();
    final yuan = tenths ~/ 10;
    final tenth = tenths % 10;
    final dec = tenth == 0 ? '$yuan' : '$yuan.$tenth';
    final dot = dec.indexOf('.');
    String text;
    if (dot == -1) {
      text = _group(dec);
    } else {
      text = '${_group(dec.substring(0, dot))}${dec.substring(dot)}';
    }
    final neg = text.startsWith('-');
    if (neg) text = text.substring(1);
    return '${neg ? '-' : ''}$symbol$text';
  }

  static String _group(String digits) {
    if (digits.length <= 3) return digits;
    final sb = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      final posFromEnd = digits.length - i;
      sb.write(digits[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) sb.write(',');
    }
    return sb.toString();
  }

  /// 紧凑格式：大金额自动转万/亿，小数保留 1 位。
  /// 例如 1234567.89 元 → ¥123.5万；123 元 → ¥123；12.5 元 → ¥12.5。
  static String formatCompact(int minorUnits, {String currency = 'CNY'}) {
    final symbol = symbolOf(currency);
    final yuan = minorUnits.abs() / 100;
    final negative = minorUnits < 0;
    String text;
    if (yuan >= 100000000) {
      text = '${_trim1(yuan / 100000000)}亿';
    } else if (yuan >= 10000) {
      text = '${_trim1(yuan / 10000)}万';
    } else if (yuan >= 100) {
      text = yuan.round().toString();
    } else {
      text = _trim1(yuan);
    }
    return '${negative ? '-' : ''}$symbol$text';
  }

  /// 保留 1 位小数并去掉多余的 .0。
  static String _trim1(double v) {
    final s = v.toStringAsFixed(1);
    return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
  }

  /// 用户输入的十进制字符串 → 分。非法输入返回 null。
  static int? parse(String input) {
    final s = input.trim().replaceAll(',', '').replaceAll('，', '');
    if (s.isEmpty) return null;
    final v = double.tryParse(s);
    if (v == null || v < 0) return null;
    final rounded = (v * 100).round();
    return rounded;
  }

  /// 日均成本等场景：金额/天数。
  static String formatDaily(
    int totalMinor,
    int days, {
    String currency = 'CNY',
  }) {
    if (days <= 0) return format(0, currency: currency);
    final perDay = (totalMinor / days).round();
    return format(perDay, currency: currency);
  }

  static NumberFormat formatter(String currency) => _formatters.putIfAbsent(
    currency,
    () => NumberFormat.currency(name: currency),
  );
}
