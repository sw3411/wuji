import 'package:flutter_test/flutter_test.dart';
import 'package:wuji/core/ai/ai_prompts.dart';

void main() {
  test('一句话解析 Prompt 注入今天日期与星期', () {
    final now = DateTime(2026, 8, 24); // 周一
    final prompt = AiPrompts.itemParseSystem(['手机数码', '其他'], now: now);
    expect(prompt, contains('2026-08-24'));
    expect(prompt, contains('星期一'));
    expect(prompt, contains('换算成具体日期'));
  });

  test('默认使用当前日期', () {
    final prompt = AiPrompts.itemParseSystem(['其他']);
    final now = DateTime.now();
    final today =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    expect(prompt, contains(today));
  });
}
