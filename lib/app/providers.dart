import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/ai/ai_client.dart';
import '../core/ai/ai_config.dart';
import '../core/ai/ai_service.dart';
import '../data/db/app_database.dart';
import '../data/repositories/backup_service.dart';
import '../data/repositories/category_repository.dart';
import '../data/repositories/item_repository.dart';
import '../data/repositories/location_repository.dart';
import '../data/repositories/sale_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../domain/models/category.dart';
import '../domain/models/item.dart';
import '../domain/models/location.dart';
import '../domain/models/sale_record.dart';
import '../domain/services/item_filter.dart';
import 'app_settings.dart';

final dbProvider = Provider<AppDatabase>((ref) => AppDatabase());

final itemRepoProvider = Provider<ItemRepository>(
  (ref) => ItemRepository(ref.read(dbProvider)),
);
final locationRepoProvider = Provider<LocationRepository>(
  (ref) => LocationRepository(ref.read(dbProvider)),
);
final categoryRepoProvider = Provider<CategoryRepository>(
  (ref) => CategoryRepository(ref.read(dbProvider)),
);
final saleRepoProvider = Provider<SaleRepository>(
  (ref) => SaleRepository(ref.read(dbProvider)),
);
final settingsRepoProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.read(dbProvider)),
);

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(
    ref.read(dbProvider),
    ref.read(itemRepoProvider),
    ref.read(locationRepoProvider),
    ref.read(categoryRepoProvider),
    ref.read(saleRepoProvider),
    ref.read(settingsRepoProvider),
  ),
);

// ---------- 设置 ----------

final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>(
      (ref) => AppSettingsNotifier(ref.read(settingsRepoProvider)),
    );

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier(this._repo) : super(AppSettings()) {
    _load();
  }

  final SettingsRepository _repo;

  Future<void> _load() async {
    final controller = AppSettingsController(_repo);
    state = await controller.load();
  }

  Future<void> update(AppSettings settings) async {
    state = settings;
    await AppSettingsController(_repo).save(settings);
  }

  Future<void> Function(AppSettings) get persist =>
      (s) => AppSettingsController(_repo).save(s);
}

// ---------- 基础数据流 ----------

final itemsProvider = StreamProvider<List<Item>>(
  (ref) => ref.read(itemRepoProvider).watchAll(),
);

final locationsProvider = StreamProvider<List<Location>>(
  (ref) => ref.read(locationRepoProvider).watchAll(),
);

final categoriesProvider = StreamProvider<List<Category>>(
  (ref) => ref.read(categoryRepoProvider).watchAll(),
);

final salesMapProvider = StreamProvider<Map<String, SaleRecord>>(
  (ref) => ref.read(saleRepoProvider).watchAllByItemId(),
);

/// 可见（未隐藏）分类。
final visibleCategoriesProvider = Provider<List<Category>>((ref) {
  final cats = ref.watch(categoriesProvider).valueOrNull ?? const <Category>[];
  return cats.where((c) => !c.isHidden).toList();
});

/// 物品筛选状态（退出页面保留，持久化）。
final itemFilterProvider =
    StateNotifierProvider<ItemFilterController, ItemFilter>(
      (ref) => ItemFilterController(ref.read(settingsRepoProvider)),
    );

class ItemFilterController extends StateNotifier<ItemFilter> {
  ItemFilterController(this._repo) : super(ItemFilter()) {
    _load();
  }

  final SettingsRepository _repo;

  Future<void> _load() async {
    final json = await _repo.getJson(SettingsRepository.keyItemFilter);
    if (json != null) state = ItemFilter.fromJson(json);
  }

  Future<void> update(ItemFilter filter) async {
    state = filter;
    await _repo.setJson(SettingsRepository.keyItemFilter, filter.toJson());
  }

  Future<void> clear() async {
    state = ItemFilter();
    await _repo.setJson(
      SettingsRepository.keyItemFilter,
      ItemFilter().toJson(),
    );
  }
}

/// 应用筛选后的物品列表。
final filteredItemsProvider = Provider<List<Item>>((ref) {
  final items = ref.watch(itemsProvider).valueOrNull ?? const <Item>[];
  final sales =
      ref.watch(salesMapProvider).valueOrNull ?? const <String, SaleRecord>{};
  final filter = ref.watch(itemFilterProvider);
  final locations =
      ref.watch(locationsProvider).valueOrNull ?? const <Location>[];

  Set<String> descendants = {};
  if (filter.locationIds.isNotEmpty) {
    final tree = LocationTree(locations);
    for (final id in filter.locationIds) {
      descendants.addAll(tree.descendantIds(id));
    }
  }
  return applyItemFilter(
    items,
    filter,
    sales,
    descendantLocationIds: descendants,
  );
});

// ---------- AI ----------

final aiConfigProvider = StateNotifierProvider<AiConfigNotifier, AiConfig>(
  (ref) => AiConfigNotifier(ref.read(settingsRepoProvider)),
);

class AiConfigNotifier extends StateNotifier<AiConfig> {
  AiConfigNotifier(this._repo) : super(AiConfig()) {
    _load();
  }

  final SettingsRepository _repo;
  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> _load() async {
    final json = await _repo.getJson(SettingsRepository.keyAiConfig);
    var config = json == null ? AiConfig() : AiConfig.fromJson(json);

    // 旧版本把 apiKey 明文存在设置表，这里迁移到安全存储。
    var key = await _secure.read(key: _keyApiKey);
    if ((key == null || key.isEmpty) && config.apiKey.trim().isNotEmpty) {
      key = config.apiKey;
      await _secure.write(key: _keyApiKey, value: key);
    }
    if (config.apiKey.isNotEmpty) {
      await _repo.setJson(SettingsRepository.keyAiConfig, {
        ...config.toJson(),
        'apiKey': '',
      });
    }
    state = AiConfig(
      enabled: config.enabled,
      baseUrl: config.baseUrl,
      apiKey: key ?? '',
      model: config.model,
      temperature: config.temperature,
    );
  }

  static const String _keyApiKey = 'wuji.ai.apiKey';

  Future<void> save(AiConfig config) async {
    state = config;
    // 密钥只进安全存储（钥匙串/Keystore），设置表不落明文。
    await _secure.write(key: _keyApiKey, value: config.apiKey);
    await _repo.setJson(SettingsRepository.keyAiConfig, {
      ...config.toJson(),
      'apiKey': '',
    });
  }
}

final aiClientProvider = Provider<AiClient>((ref) {
  final config = ref.watch(aiConfigProvider);
  return AiClient(config);
});

final aiServiceProvider = Provider<AiService>(
  (ref) => AiService(ref.read(aiClientProvider)),
);

// ---------- 备份提醒 ----------

/// 上次备份时间（备份导出成功后更新）。
final lastBackupAtProvider = FutureProvider<DateTime?>((ref) async {
  final v = await ref
      .watch(settingsRepoProvider)
      .get(SettingsRepository.keyLastBackupAt);
  return v == null ? null : DateTime.tryParse(v);
});

/// 本次启动内是否忽略备份提醒。
final backupReminderDismissedProvider = StateProvider<bool>((ref) => false);

// ---------- 事件 ----------

/// 数据变化计数：批量操作后调用，触发依赖刷新。
final dataVersionProvider = StateProvider<int>((ref) => 0);

/// 调试日志开关。
final debugLogProvider = StateProvider<bool>((ref) => kDebugMode);
