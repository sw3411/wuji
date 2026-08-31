import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/providers.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'core/constants/app_info.dart';
import 'data/db/app_database.dart';
import 'data/repositories/item_repository.dart';
import 'shared/widgets/lock_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  // 启动即清理回收站中超期物品（默认保留 30 天）。
  unawaited(ItemRepository(db).purgeExpired(30).catchError((_) => <String>[]));

  runApp(
    ProviderScope(
      overrides: [dbProvider.overrideWithValue(db)],
      child: const WujiApp(),
    ),
  );
}

class WujiApp extends ConsumerWidget {
  const WujiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    return MaterialApp.router(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: settings.themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
      builder: (context, child) {
        final dark = Theme.of(context).brightness == Brightness.dark;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
          child: Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              // 全局渐变画布：右上纯白 → 左下微暖。
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: dark
                          ? AppTheme.canvasGradientDark
                          : AppTheme.canvasGradientLight,
                    ),
                  ),
                ),
              ),
              // 环境色斑：给毛玻璃提供可折射的底（无则模糊不可见）。
              Positioned.fill(
                child: IgnorePointer(
                  child: Stack(children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(-0.55, -0.35),
                            radius: 0.9,
                            colors: [
                              dark
                                  ? const Color(0x143FBF82)
                                  : const Color(0x1F21A36B),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: const Alignment(0.7, 0.62),
                            radius: 0.85,
                            colors: [
                              dark
                                  ? const Color(0x1057CF97)
                                  : const Color(0x1DE6F5EE),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              LockGate(child: child ?? const SizedBox()),
            ],
          ),
          ),
        );
      },
      routerConfig: ref.watch(routerProvider),
    );
  }
}
