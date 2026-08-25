import '../models/enums.dart';
import '../models/item.dart';
import '../models/sale_record.dart';
import 'item_calculator.dart';

/// 物品列表筛选与排序。筛选条件可序列化持久化（退出页面保留）。
class ItemFilter {
  ItemFilter({
    this.search = '',
    this.categoryIds = const [],
    this.statuses = const [],
    this.locationIds = const [],
    this.dateStart,
    this.dateEnd,
    this.priceMin,
    this.priceMax,
    this.favoriteOnly = false,
    this.soldOnly = false,
    this.expiringWarrantyOnly = false,
    this.idleOnly = false,
    this.sort = ItemSort.newestAdded,
  });

  String search;
  List<String> categoryIds;
  List<ItemStatus> statuses;
  List<String> locationIds;
  DateTime? dateStart;
  DateTime? dateEnd;
  int? priceMin;
  int? priceMax;
  bool favoriteOnly;
  bool soldOnly;
  bool expiringWarrantyOnly;
  bool idleOnly;
  ItemSort sort;

  bool get hasActiveFilter =>
      search.isNotEmpty ||
      categoryIds.isNotEmpty ||
      statuses.isNotEmpty ||
      locationIds.isNotEmpty ||
      dateStart != null ||
      dateEnd != null ||
      priceMin != null ||
      priceMax != null ||
      favoriteOnly ||
      soldOnly ||
      expiringWarrantyOnly ||
      idleOnly;

  ItemFilter copy() => ItemFilter(
        search: search,
        categoryIds: List.of(categoryIds),
        statuses: List.of(statuses),
        locationIds: List.of(locationIds),
        dateStart: dateStart,
        dateEnd: dateEnd,
        priceMin: priceMin,
        priceMax: priceMax,
        favoriteOnly: favoriteOnly,
        soldOnly: soldOnly,
        expiringWarrantyOnly: expiringWarrantyOnly,
        idleOnly: idleOnly,
        sort: sort,
      );

  factory ItemFilter.fromJson(Map<String, dynamic> json) => ItemFilter(
        search: json['search'] as String? ?? '',
        categoryIds: (json['categoryIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        statuses: (json['statuses'] as List<dynamic>? ?? const [])
            .map((e) => ItemStatus.fromName(e.toString()))
            .toList(),
        locationIds: (json['locationIds'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        dateStart: json['dateStart'] == null
            ? null
            : DateTime.parse(json['dateStart'] as String),
        dateEnd: json['dateEnd'] == null
            ? null
            : DateTime.parse(json['dateEnd'] as String),
        priceMin: (json['priceMin'] as num?)?.toInt(),
        priceMax: (json['priceMax'] as num?)?.toInt(),
        favoriteOnly: json['favoriteOnly'] as bool? ?? false,
        soldOnly: json['soldOnly'] as bool? ?? false,
        expiringWarrantyOnly: json['expiringWarrantyOnly'] as bool? ?? false,
        idleOnly: json['idleOnly'] as bool? ?? false,
        sort: ItemSort.values.firstWhere(
          (s) => s.name == json['sort'],
          orElse: () => ItemSort.newestAdded,
        ),
      );

  Map<String, dynamic> toJson() => {
        'search': search,
        'categoryIds': categoryIds,
        'statuses': statuses.map((s) => s.name).toList(),
        'locationIds': locationIds,
        'dateStart': dateStart?.toIso8601String(),
        'dateEnd': dateEnd?.toIso8601String(),
        'priceMin': priceMin,
        'priceMax': priceMax,
        'favoriteOnly': favoriteOnly,
        'soldOnly': soldOnly,
        'expiringWarrantyOnly': expiringWarrantyOnly,
        'idleOnly': idleOnly,
        'sort': sort.name,
      };
}

enum ItemSort {
  newestAdded('最近添加'),
  oldestAdded('最早添加'),
  purchaseDateDesc('购买日期最新'),
  purchaseDateAsc('购买日期最早'),
  priceDesc('价格从高到低'),
  priceAsc('价格从低到高'),
  dailyCostDesc('日均成本从高到低'),
  dailyCostAsc('日均成本从低到高'),
  usedDaysDesc('使用天数从长到短');

  const ItemSort(this.label);
  final String label;
}

/// 对未删除物品应用筛选与排序。
List<Item> applyItemFilter(
  List<Item> items,
  ItemFilter filter,
  Map<String, SaleRecord> salesByItemId, {
  Set<String> descendantLocationIds = const {},
  DateTime? now,
}) {
  final now_ = now ?? DateTime.now();
  final q = filter.search.trim().toLowerCase();
  var result = items.where((i) => !i.isDeleted).toList();

  if (q.isNotEmpty) {
    result = result.where((i) {
      final haystack = [
        i.name,
        i.brand ?? '',
        i.model ?? '',
        i.notes ?? '',
        i.locationName ?? '',
        i.tags.join(' '),
      ].join(' ').toLowerCase();
      return haystack.contains(q);
    }).toList();
  }
  if (filter.categoryIds.isNotEmpty) {
    result = result.where((i) => filter.categoryIds.contains(i.categoryId)).toList();
  }
  if (filter.statuses.isNotEmpty) {
    result = result.where((i) => filter.statuses.contains(i.status)).toList();
  }
  if (filter.locationIds.isNotEmpty || descendantLocationIds.isNotEmpty) {
    final ids = {...filter.locationIds, ...descendantLocationIds};
    result = result.where((i) => i.locationId != null && ids.contains(i.locationId)).toList();
  }
  if (filter.dateStart != null) {
    result = result.where((i) => !i.purchaseDate.isBefore(filter.dateStart!)).toList();
  }
  if (filter.dateEnd != null) {
    final end = DateTime(filter.dateEnd!.year, filter.dateEnd!.month, filter.dateEnd!.day, 23, 59, 59);
    result = result.where((i) => !i.purchaseDate.isAfter(end)).toList();
  }
  if (filter.priceMin != null) {
    result = result.where((i) => i.purchasePrice >= filter.priceMin!).toList();
  }
  if (filter.priceMax != null) {
    result = result.where((i) => i.purchasePrice <= filter.priceMax!).toList();
  }
  if (filter.favoriteOnly) {
    result = result.where((i) => i.isFavorite).toList();
  }
  if (filter.soldOnly) {
    result = result.where((i) => i.status == ItemStatus.sold).toList();
  }
  if (filter.expiringWarrantyOnly) {
    result = result.where((i) {
      final s = ItemCalculator.warrantyState(i, now: now_);
      return s == WarrantyState.expiringSoon || s == WarrantyState.expired;
    }).toList();
  }
  if (filter.idleOnly) {
    result = result.where((i) => i.status == ItemStatus.idle).toList();
  }

  int cmpDaily(Item a, Item b) => ItemCalculator.dailyCost(a, salesByItemId[a.id], now: now_)
      .compareTo(ItemCalculator.dailyCost(b, salesByItemId[b.id], now: now_));
  int cmpUsed(Item a, Item b) => ItemCalculator.usedDays(a, salesByItemId[a.id], now: now_)
      .compareTo(ItemCalculator.usedDays(b, salesByItemId[b.id], now: now_));

  switch (filter.sort) {
    case ItemSort.newestAdded:
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case ItemSort.oldestAdded:
      result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    case ItemSort.purchaseDateDesc:
      result.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
    case ItemSort.purchaseDateAsc:
      result.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
    case ItemSort.priceDesc:
      result.sort((a, b) => b.purchasePrice.compareTo(a.purchasePrice));
    case ItemSort.priceAsc:
      result.sort((a, b) => a.purchasePrice.compareTo(b.purchasePrice));
    case ItemSort.dailyCostDesc:
      result.sort((a, b) => cmpDaily(a, b));
    case ItemSort.dailyCostAsc:
      result.sort((a, b) => -cmpDaily(a, b));
    case ItemSort.usedDaysDesc:
      result.sort((a, b) => cmpUsed(a, b));
  }
  return result;
}
