import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 「物迹」现代私人档案视觉体系。
///
/// 视觉关键词：滴滴出行式「橙 × 黑白灰」——唯一彩色是活力橙，
/// 其余只有墨字、白卡与冷灰画布（经用户指定）。
/// 橙色双层：图形/按钮级 #FF7E33（白字，品牌保真）、
/// 文字级 #C2540A（白底 5.0:1，AA 达标）；系统默认字体。
class AppTheme {
  AppTheme._();

  // ---------- 品牌与语义色 ----------

  /// 鲜薄荷双层（浅色）：#21A36B 图形 / #17724B 文字（白底 5.9:1）。
  static const Color green = Color(0xFF21A36B);
  static const Color greenLight = Color(0xFF3FBF82);
  static const Color greenDark = Color(0xFF17724B);

  /// 深色主题强调：#3FBF82 图形 / #57CF97 文字（深底 6.2:1）。
  static const Color accentDark = Color(0xFF3FBF82);
  static const Color accentTextDark = Color(0xFF57CF97);

  static const Color lime = green;
  static const Color limeInk = greenDark;
  static const Color buttonGreen = Color(0xFF17724B);
  static const Color buttonGreenDark = Color(0xFF1C7E56);
  static const Color inkOnLime = Colors.white;
  static const List<Color> primaryGradient = [
    Color(0xFF2EB878),
    Color(0xFF178455),
  ];

  /// 场景卡渐变（浅/深）。
  static const List<Color> sceneGradientLight = [
    Color(0xFF35B47E),
    Color(0xFF178455),
  ];
  static const List<Color> sceneGradientDark = [
    Color(0xFF1E4435),
    Color(0xFF153328),
  ];

  /// AI 对话气泡：我方 / 对方。
  static const Color aiBubbleMe = Color(0xFF274A3B);
  static const Color aiBubbleOther = Color(0xFFE6F5EE);

  /// 次级强调：石板墨（克制，避免双色打架）。
  static const Color terracotta = Color(0xFF3D4552);
  static const Color terracottaInk = Color(0xFF2F3641);
  static const Color sage = Color(0xFF658A70);
  static const Color ochre = Color(0xFFA8752D);
  static const Color mauve = Color(0xFF816F91);
  static const Color steel = Color(0xFF5E7D8C);
  static const Color rose = Color(0xFFA8625D);
  static const Color olive = Color(0xFF78804E);
  static const Color taupe = Color(0xFF77736E);

  static const Color warnRed = Color(0xFFE5484D);
  static const Color warnAmber = Color(0xFFD97706);
  static const Color okGreen = Color(0xFF30A46C);
  static const Color infoBlue = Color(0xFF3E77C2);

  // ---------- 亮色基础色（兼容旧调用点） ----------

  /// 全局画布渐变：右上纯白 → 左下浅橙灰（“高级感”低饱和过渡）。
  static const List<Color> canvasGradientLight = [
    Color(0xFFFFFFFF),
    Color(0xFFFCFAF7),
    Color(0xFFF8F3EC),
  ];
  static const List<Color> canvasGradientDark = [
    Color(0xFF464040),
    Color(0xFF3B3535),
  ];

  static const Color canvas = Color(0xFFFFFFFF);
  static const Color panel = Color(0xFFF7F5F2);
  static const Color raised = Color(0xFFEFF2F6);
  static const Color hairline = Color(0xFFECE8E1);
  static const Color textPrimary = Color(0xFF20242A);
  static const Color textSecondary = Color(0xFF5D6772);
  static const Color textTertiary = Color(0xFF68727D);

  static const Color darkBg = Color(0xFF3B3535);
  static const Color darkSurface = Color(0xFF453E3E);
  static const Color darkSurfaceAlt = Color(0xFF4C4545);
  static const Color darkDivider = Color(0xFF4A4343);
  static const Color darkOnSurface = Color(0xFFF5F1ED);
  static const Color darkOnSurfaceVariant = Color(0xFFB8AFA6);

  static const Color lightBg = canvas;
  static const Color lightSurface = panel;
  static const Color lightDivider = hairline;
  static const Color ink = textPrimary;
  static const Color inkSecondary = textSecondary;
  static const Color inkTertiary = textTertiary;

  // ---------- 形状与动效 ----------

  static const double cardRadius = 16;
  static const double sheetRadius = 24;
  static const double controlRadius = 12;
  static const double stampRadius = 6;

  static const Duration motionFast = Duration(milliseconds: 140);
  static const Duration motionBase = Duration(milliseconds: 220);
  static const Duration motionSlow = Duration(milliseconds: 320);
  static const Curve motionIn = Curves.easeOutCubic;
  static const Curve motionOut = Curves.easeInCubic;

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final surface = dark ? darkSurface : panel;
    final surfaceAlt = dark ? darkSurfaceAlt : raised;
    final divider = dark ? darkDivider : hairline;
    final onSurface = dark ? darkOnSurface : textPrimary;
    final onSurfaceVariant = dark ? darkOnSurfaceVariant : textSecondary;
    final primary = dark ? accentTextDark : greenDark;
    final primaryContainer = dark
        ? const Color(0xFF2C4A3C)
        : const Color(0xCCE3F2EA);

    final scheme =
        ColorScheme.fromSeed(seedColor: green, brightness: brightness).copyWith(
          primary: primary,
          onPrimary: dark ? const Color(0xFF0E2B1F) : Colors.white,
          secondary: dark ? const Color(0xFFB9C1CC) : terracottaInk,
          onSecondary: dark ? const Color(0xFF1B2027) : Colors.white,
          tertiary: dark ? accentDark : greenLight,
          surface: surface,
          onSurface: onSurface,
          surfaceContainerHighest: surfaceAlt,
          onSurfaceVariant: onSurfaceVariant,
          outline: dark ? const Color(0xFF575E69) : const Color(0xFF8A919C),
          outlineVariant: divider,
          primaryContainer: primaryContainer,
          onPrimaryContainer: dark ? const Color(0xFFFFDDC2) : greenDark,
          secondaryContainer: dark
              ? const Color(0x33FFFFFF)
              : const Color(0x99FFFFFF),
          onSecondaryContainer: dark ? const Color(0xFFD3D9E2) : terracottaInk,
          error: dark ? const Color(0xFFFFB4AB) : warnRed,
          onError: dark ? const Color(0xFF690005) : Colors.white,
        );

    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
    );

    return base.copyWith(
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        // 显式系统栏样式：浅色主题深图标 / 深色主题浅图标。
        systemOverlayStyle: dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        foregroundColor: onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
          color: onSurface,
        ),
        iconTheme: IconThemeData(color: onSurfaceVariant, size: 22),
      ),
      cardTheme: CardThemeData(
        // 毛玻璃悬浮瓷片：微暖半透明 + 白发丝 + 微投影（悬浮感）。
        color: dark
            ? const Color(0xCC453E3E)
            : const Color(0xBCF7F5F2),
        elevation: 0.5,
        shadowColor: dark
            ? Colors.black.withValues(alpha: 0.20)
            : const Color(0x0D20242A),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: BorderSide(
            color: dark
                ? Colors.white.withValues(alpha: 0.10)
                : Colors.white.withValues(alpha: 0.65),
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: dark ? buttonGreenDark : buttonGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          minimumSize: const Size(44, 46),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurface,
          backgroundColor: dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.55),
          side: BorderSide(color: divider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(controlRadius),
          ),
          minimumSize: const Size(44, 46),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size(44, 44),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: dark ? buttonGreenDark : buttonGreen,
        foregroundColor: Colors.white,
        elevation: 1,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? surfaceAlt : const Color(0xCCF0F2F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(controlRadius),
          borderSide: BorderSide(color: scheme.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: TextStyle(color: onSurfaceVariant, fontSize: 14),
        hintStyle: TextStyle(
          color: dark ? const Color(0xFF9DA7A1) : textTertiary,
          fontSize: 14,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sheetRadius),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? darkOnSurface : textPrimary,
        contentTextStyle: TextStyle(color: dark ? darkBg : panel),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: Colors.transparent,
        selectedColor: primaryContainer,
        side: BorderSide(color: divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(stampRadius),
        ),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: onSurfaceVariant,
        ),
        secondaryLabelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimaryContainer,
        ),
        checkmarkColor: scheme.onPrimaryContainer,
        showCheckmark: false,
      ),
      dividerTheme: DividerThemeData(color: divider, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : surface,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? primary : divider,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primary
              : onSurfaceVariant,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceAlt,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        inactiveTrackColor: surfaceAlt,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: onSurfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        minVerticalPadding: 12,
      ),
      textTheme: base.textTheme
          .apply(bodyColor: onSurface, displayColor: onSurface)
          .copyWith(
            bodyLarge: base.textTheme.bodyLarge?.copyWith(
              fontSize: 16,
              height: 1.5,
            ),
            bodyMedium: base.textTheme.bodyMedium?.copyWith(
              fontSize: 14.5,
              height: 1.5,
            ),
            bodySmall: base.textTheme.bodySmall?.copyWith(
              fontSize: 13,
              height: 1.45,
              color: onSurfaceVariant,
            ),
            titleLarge: base.textTheme.titleLarge?.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
            titleMedium: base.textTheme.titleMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.35,
            ),
            titleSmall: base.textTheme.titleSmall?.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
    );
  }

  // ---------- 内容字号阶梯 ----------

  static TextStyle display(Color color, {double size = 26}) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.7,
    height: 1.08,
    color: color,
  );

  static TextStyle bigNumber(Color color, {double size = 20}) => TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.45,
    height: 1.08,
    color: color,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  static TextStyle label(Color color) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.7,
    height: 1.3,
    color: color,
  );

  static TextStyle title(Color color) => TextStyle(
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
    color: color,
  );

  static TextStyle cardTitle(Color color) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.35,
    color: color,
  );

  static TextStyle body(Color color) => TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: color,
  );

  static TextStyle subhead(Color color) => TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: color,
  );

  static TextStyle caption(Color color) => TextStyle(
    fontSize: 11.5,
    fontWeight: FontWeight.w400,
    height: 1.45,
    color: color,
  );
}
