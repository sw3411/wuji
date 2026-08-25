import 'package:flutter/material.dart';

/// 主题：对齐 WhatsApp 官方配色。
///
/// - 主绿 Primary   #008069（浅色模式操作绿 / 深色 #00A884）
/// - 亮绿 Accent    #25D366（FAB、发送、AI 唤起）
/// - 浅色底         #F0F2F5，卡片白
/// - 深色底         #0B141A，面板 #202C33（WhatsApp 暗色）
/// - 文字           #111B21 / 次要 #667781（WhatsApp 灰阶）
class AppTheme {
  AppTheme._();

  // ---------- WhatsApp 官方色 ----------

  static const Color green = Color(0xFF008069);
  static const Color greenLight = Color(0xFF25D366);
  static const Color greenDark = Color(0xFF00A884);
  static const Color greenBubble = Color(0xFF005C4B);

  static const Color ink = Color(0xFF111B21);
  static const Color inkSecondary = Color(0xFF667781);

  static const Color lightBg = Color(0xFFF0F2F5);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE9EDEF);

  static const Color darkBg = Color(0xFF0B141A);
  static const Color darkSurface = Color(0xFF202C33);
  static const Color darkSurfaceAlt = Color(0xFF2A3942);
  static const Color darkDivider = Color(0xFF313D45);

  static const double cardRadius = 18;

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: green,
      primary: green,
      onPrimary: Colors.white,
      secondary: greenLight,
      onSecondary: Colors.white,
      tertiary: greenDark,
      brightness: Brightness.light,
      surface: lightSurface,
      onSurface: ink,
      surfaceContainerHighest: lightDivider,
      onSurfaceVariant: inkSecondary,
      outlineVariant: lightDivider,
    );
    return _common(ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightBg,
    ));
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: greenDark,
      primary: greenDark,
      onPrimary: Colors.white,
      secondary: greenLight,
      onSecondary: Colors.white,
      tertiary: greenLight,
      brightness: Brightness.dark,
      surface: darkSurface,
      onSurface: const Color(0xFFE9EDEF),
      surfaceContainerHighest: darkSurfaceAlt,
      onSurfaceVariant: const Color(0xFF8696A0),
      outlineVariant: darkDivider,
    );
    return _common(ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkBg,
    ));
  }

  static ThemeData _common(ThemeData base) {
    final cs = base.colorScheme;
    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: base.scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
          color: cs.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          minimumSize: const Size(48, 46),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary, width: 1),
          shape: const StadiumBorder(),
          minimumSize: const Size(48, 46),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.secondary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        // 输入框用浅灰底，与白色卡片/面板形成区分。
        fillColor: base.brightness == Brightness.light
            ? lightBg
            : darkSurfaceAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 1.6),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: cs.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.onSurface,
        contentTextStyle: TextStyle(color: cs.surface),
        shape: const StadiumBorder(),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        shape: const StadiumBorder(),
        side: BorderSide(color: cs.outlineVariant),
      ),
      dividerTheme: DividerThemeData(
        color: cs.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      // 正文行高 1.45~1.55：全局可读性基调（列表、详情、对话）。
      textTheme: base.textTheme
          .apply(
            bodyColor: cs.onSurface,
            displayColor: cs.onSurface,
          )
          .copyWith(
            bodyLarge: base.textTheme.bodyLarge?.copyWith(height: 1.55),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.5),
            bodySmall:
                base.textTheme.bodySmall?.copyWith(height: 1.45, fontSize: 12.5),
            titleMedium: base.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w600, height: 1.35),
            titleSmall:
                base.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
    );
  }

  /// 衬线展示样式：仅用于页面大标题与问候语。
  static String get serifFamily => 'serif';

  static TextStyle display(Color color, {double size = 28}) => TextStyle(
        fontFamily: serifFamily,
        fontSize: size,
        fontWeight: FontWeight.w600,
        letterSpacing: -1.0,
        height: 1.15,
        color: color,
      );

  /// 大数字文本样式：等宽数字 + 加粗，用于核心数据展示。
  static TextStyle bigNumber(Color color, {double size = 24}) => TextStyle(
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        height: 1.1,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  // ---------- 字号阶梯 ----------

  static TextStyle label(Color color) => TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: color,
      );

  static TextStyle caption(Color color) => TextStyle(
        fontSize: 12,
        height: 1.4,
        color: color,
      );

  static TextStyle cardTitle(Color color) => TextStyle(
        fontSize: 17.5,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      );
}
