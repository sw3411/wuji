import 'package:flutter/material.dart';


/// 位置预设图标库：键存入数据库（中文标签），渲染时映射为 IconData。
class LocationIconSet {
  LocationIconSet._();

  static const Map<String, IconData> presets = {
    '家': Icons.home_outlined,
    '卧室': Icons.bed_outlined,
    '客厅': Icons.weekend_outlined,
    '厨房': Icons.kitchen_outlined,
    '餐桌': Icons.table_bar_outlined,
    '橱柜': Icons.kitchen_outlined,
    '衣柜': Icons.checkroom_outlined,
    '抽屉': Icons.inventory_2_outlined,
    '书架': Icons.video_library_outlined,
    '书房': Icons.menu_book_outlined,
    '卫生间': Icons.bathtub_outlined,
    '阳台': Icons.balcony_outlined,
    '玄关': Icons.sensor_door_outlined,
    '储物间': Icons.warehouse_outlined,
    '冰箱': Icons.kitchen,
    '洗衣机': Icons.local_laundry_service_outlined,
    '公司': Icons.apartment_outlined,
    '办公室': Icons.business_center_outlined,
    '车上': Icons.directions_car_outlined,
    '随身': Icons.person_outline,
    '包内': Icons.shopping_bag_outlined,
    '行李箱': Icons.luggage_outlined,
    '其他': Icons.category_outlined,
  };

  static IconData of(String? key) => presets[key] ?? Icons.place_outlined;

  /// 名称自动匹配：位置名含关键词时推荐图标（卧室→卧室）。
  static String? suggest(String name) {
    for (final k in presets.keys) {
      if (k != '其他' && name.contains(k)) return k;
    }
    return null;
  }
}

/// 位置图标徽章：薄荷 tint 渐变底 + 主题色 icon（与物品默认图标同语言）。
class LocationIconBadge extends StatelessWidget {
  const LocationIconBadge(this.icon, {super.key, this.size = 38});

  final String? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.16),
            cs.primary.withValues(alpha: 0.07),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
      ),
      child: Icon(
        LocationIconSet.of(icon),
        size: size * 0.5,
        color: cs.primary,
      ),
    );
  }
}
