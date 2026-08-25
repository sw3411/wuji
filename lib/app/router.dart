import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/ai/ai_chat_page.dart';
import '../features/ai/insights_page.dart';
import '../features/ai/ai_quick_add_page.dart';
import '../features/ai/purchase_eval_page.dart';
import '../features/ai/weekly_report_page.dart';
import '../features/home/home_page.dart';
import '../features/items/item_detail_page.dart';
import '../features/items/item_form_page.dart';
import '../features/items/items_page.dart';
import '../features/locations/inventory_check_page.dart';
import '../features/locations/location_detail_page.dart';
import '../features/locations/locations_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/settings/about_page.dart';
import '../features/settings/ai_settings_page.dart';
import '../features/settings/category_manage_page.dart';
import '../features/settings/settings_page.dart';
import '../features/settings/trash_page.dart';
import '../features/statistics/statistics_page.dart';
import '../features/statistics/yearly_report_page.dart';
import 'app_shell.dart';
import 'providers.dart';

/// 路由集中配置。
final routerProvider = Provider<GoRouter>((ref) {
  final repo = ref.read(settingsRepoProvider);
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) async {
      final onboarded = await repo.getBool('onboarded') ?? false;
      final isOnboarding = state.matchedLocation == '/onboarding';
      if (!onboarded && !isOnboarding) return '/onboarding';
      if (onboarded && isOnboarding) return '/home';
      return null;
    },
    routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/item/new',
      builder: (context, state) {
        final extra = state.extra;
        return ItemFormPage(
          initialLocationId: extra is String ? extra : null,
        );
      },
    ),
    GoRoute(
      path: '/item/:id',
      builder: (context, state) =>
          ItemDetailPage(state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/item/:id/edit',
      builder: (context, state) =>
          ItemFormPage(existingId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/locations',
      builder: (context, state) {
        final selectMode = state.uri.queryParameters['select'] == '1';
        return LocationsPage(selectMode: selectMode);
      },
    ),
    GoRoute(
      path: '/locations/:id',
      builder: (context, state) =>
          LocationDetailPage(state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings/categories',
      builder: (context, state) => const CategoryManagePage(),
    ),
    GoRoute(
      path: '/settings/ai',
      builder: (context, state) => const AiSettingsPage(),
    ),
    GoRoute(
      path: '/settings/trash',
      builder: (context, state) => const TrashPage(),
    ),
    GoRoute(
      path: '/settings/about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/stats/yearly',
      builder: (context, state) => const YearlyReportPage(),
    ),
    GoRoute(
      path: '/inventory',
      builder: (context, state) => const InventoryCheckPage(),
    ),
    GoRoute(
      path: '/ai/quick-add',
      builder: (context, state) => const AiQuickAddPage(),
    ),
    GoRoute(
      path: '/ai/purchase-eval',
      builder: (context, state) => const PurchaseEvalPage(),
    ),
    GoRoute(
      path: '/ai/chat',
      builder: (context, state) => const AiChatPage(),
    ),
    GoRoute(
      path: '/ai/insights',
      builder: (context, state) => const AiInsightsPage(),
    ),
    GoRoute(
      path: '/ai/weekly',
      builder: (context, state) => const WeeklyReportPage(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomePage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/items',
            builder: (context, state) => const ItemsPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/stats',
            builder: (context, state) => const StatisticsPage(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const SettingsPage(),
          ),
        ]),
      ],
    ),
    ],
  );
});