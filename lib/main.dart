import 'dart:async';

import 'package:flutter/material.dart';
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
  unawaited(
      ItemRepository(db).purgeExpired(30).catchError((_) => <String>[]));

  runApp(ProviderScope(
    overrides: [dbProvider.overrideWithValue(db)],
    child: const WujiApp(),
  ));
}

class WujiApp extends ConsumerWidget {
  const WujiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appSettingsProvider).themeMode;
    return MaterialApp.router(
      title: AppInfo.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'CN'),
        Locale('en', 'US'),
      ],
      builder: (context, child) => LockGate(child: child ?? const SizedBox()),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
