import '../models/enums.dart';
import '../models/item.dart';
import '../models/sale_record.dart';
import 'item_calculator.dart';

/// 单项体检结果。
class InsightEntry {
  const InsightEntry({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
  });

  /// 稳定 id，用于路由/埋点。
  final String id;

  /// 展示标题，例如“缺少存放位置”。
  final String title;

  /// 建议文案，例如“补全后找东西更快”。
  final String description;
  final List<Item> items;
}

/// 物品体检结果：全部本地规则计算，不依赖 AI。
class ItemInsights {
  const ItemInsights({
    required this.missingPrice,
    required this.missingLocation,
    required this.missingImage,
    required this.longIdle,
    required this.expiringWarranty,
    required this.highDailyCost,
    required this.maintenanceDue,
  });

  /// 价格为 0 且不是礼物/赠送的物品（价格信息缺失）。
  final List<Item> missingPrice;

  /// 未设置存放位置。
  final List<Item> missingLocation;

  /// 没有任何照片。
  final List<Item> missingImage;

  /// 长期闲置（超过阈值天数）。
  final List<Item> longIdle;

  /// 即将过保或已过保。
  final List<Item> expiringWarranty;

  /// 当前持有中日均成本最高的物品（前 3）。
  final List<Item> highDailyCost;

  /// 保养/耗材 30 天内到期或已过期。
  final List<Item> maintenanceDue;

  bool get isClean =>
      missingPrice.isEmpty &&
      missingLocation.isEmpty &&
      missingImage.isEmpty &&
      longIdle.isEmpty &&
      expiringWarranty.isEmpty &&
      maintenanceDue.isEmpty;

  List<InsightEntry> entries() => [
        InsightEntry(
          id: 'missing_price',
          title: '价格缺失',
          description: '非礼物但价格为 0，日均成本会失真',
          items: missingPrice,
        ),
        InsightEntry(
          id: 'missing_location',
          title: '未设存放位置',
          description: '补全位置，找东西更快',
          items: missingLocation,
        ),
        InsightEntry(
          id: 'missing_image',
          title: '没有照片',
          description: '拍照留档，转卖和保修更方便',
          items: missingImage,
        ),
        InsightEntry(
          id: 'long_idle',
          title: '长期闲置',
          description: '考虑转卖回血或重新利用',
          items: longIdle,
        ),
        InsightEntry(
          id: 'expiring_warranty',
          title: '保修将到期',
          description: '到期前检查或送保',
          items: expiringWarranty,
        ),
        InsightEntry(
          id: 'maintenance_due',
          title: '保养/耗材到期',
          description: '滤芯、机油等周期件该换了',
          items: maintenanceDue,
        ),
      ].where((e) => e.items.isNotEmpty).toList();
}

/// 体检计算：全部纯函数。
class ItemInsightService {
  const ItemInsightService._();

  static ItemInsights analyze(
    List<Item> items,
    Map<String, SaleRecord> sales, {
    int idleThresholdDays = 90,
    DateTime? now,
  }) {
    final now_ = now ?? DateTime.now();
    final active = items.where((i) => !i.isDeleted).toList();

    final missingPrice = active.where((i) =>
        i.purchasePrice == 0 &&
        i.status != ItemStatus.gifted &&
        i.purchaseChannel != '礼物');

    final missingLocation = active.where((i) => i.locationId == null);
    final missingImage =
        active.where((i) => i.coverImagePath == null);

    final longIdle = active.where((i) =>
        i.status == ItemStatus.idle &&
        ItemCalculator.usedDays(i, sales[i.id], now: now_) >=
            idleThresholdDays);

    final expiringWarranty = active.where((i) {
      final state = ItemCalculator.warrantyState(i, now: now_);
      return state == WarrantyState.expiringSoon ||
          state == WarrantyState.expired;
    });

    final owned = active.where((i) => i.status.isOwned).toList()
      ..sort((a, b) => ItemCalculator.dailyCost(b, sales[b.id], now: now_)
          .compareTo(
              ItemCalculator.dailyCost(a, sales[a.id], now: now_)));

    final maintenanceDue = active.where((i) {
      if (!i.status.isOwned) return false;
      final next = ItemCalculator.nextMaintenanceDate(i, now: now_);
      if (next == null) return false;
      return next.isBefore(now_.add(const Duration(days: 31)));
    });

    return ItemInsights(
      missingPrice: missingPrice.toList(),
      missingLocation: missingLocation.toList(),
      missingImage: missingImage.toList(),
      longIdle: longIdle.toList(),
      expiringWarranty: expiringWarranty.toList(),
      highDailyCost: owned.take(3).toList(),
      maintenanceDue: maintenanceDue.toList(),
    );
  }
}
