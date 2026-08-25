import 'package:flutter/material.dart';

import '../../domain/models/category.dart';

/// 分类图标键名 → Material 图标的映射。
class CategoryIcons {
  CategoryIcons._();

  static const Map<String, IconData> map = {
    'phone_android': Icons.phone_android,
    'computer': Icons.computer,
    'home_appliance': Icons.kitchen,
    'furniture': Icons.chair,
    'kitchen': Icons.blender,
    'clothes': Icons.checkroom,
    'shoes': Icons.hiking,
    'bag': Icons.work,
    'beauty': Icons.face_retouching_natural,
    'jewelry': Icons.diamond,
    'sports': Icons.sports_soccer,
    'car': Icons.directions_car,
    'book': Icons.menu_book,
    'toy': Icons.toys,
    'baby': Icons.child_care,
    'food': Icons.fastfood,
    'health': Icons.medical_services,
    'pet': Icons.pets,
    'tools': Icons.construction,
    'collection': Icons.collections,
    'ticket': Icons.confirmation_number,
    'category': Icons.category,
  };

  static IconData of(String key) => map[key] ?? Icons.category;
}

/// 内置系统分类，首次启动时写入数据库。
const List<Category> kDefaultCategories = [
  Category(id: 'cat_phone', name: '手机数码', icon: 'phone_android', colorValue: 0xFF2E7D6B, sortOrder: 1, isSystem: true),
  Category(id: 'cat_computer', name: '电脑办公', icon: 'computer', colorValue: 0xFF4A6FA5, sortOrder: 2, isSystem: true),
  Category(id: 'cat_appliance', name: '家用电器', icon: 'home_appliance', colorValue: 0xFF7B8D6E, sortOrder: 3, isSystem: true),
  Category(id: 'cat_furniture', name: '家具家装', icon: 'furniture', colorValue: 0xFF8D6E63, sortOrder: 4, isSystem: true),
  Category(id: 'cat_kitchen', name: '厨房用品', icon: 'kitchen', colorValue: 0xFF9C6B4F, sortOrder: 5, isSystem: true),
  Category(id: 'cat_clothes', name: '服装', icon: 'clothes', colorValue: 0xFF7986CB, sortOrder: 6, isSystem: true),
  Category(id: 'cat_shoes', name: '鞋靴', icon: 'shoes', colorValue: 0xFF6D4C41, sortOrder: 7, isSystem: true),
  Category(id: 'cat_bag', name: '箱包', icon: 'bag', colorValue: 0xFF8D6E9C, sortOrder: 8, isSystem: true),
  Category(id: 'cat_beauty', name: '美妆个护', icon: 'beauty', colorValue: 0xFFD81B60, sortOrder: 9, isSystem: true),
  Category(id: 'cat_jewelry', name: '珠宝饰品', icon: 'jewelry', colorValue: 0xFF00838F, sortOrder: 10, isSystem: true),
  Category(id: 'cat_sports', name: '运动户外', icon: 'sports', colorValue: 0xFF2E8B57, sortOrder: 11, isSystem: true),
  Category(id: 'cat_car', name: '汽车用品', icon: 'car', colorValue: 0xFF455A64, sortOrder: 12, isSystem: true),
  Category(id: 'cat_book', name: '图书音像', icon: 'book', colorValue: 0xFF5D4037, sortOrder: 13, isSystem: true),
  Category(id: 'cat_toy', name: '玩具乐器', icon: 'toy', colorValue: 0xFFF06292, sortOrder: 14, isSystem: true),
  Category(id: 'cat_baby', name: '母婴用品', icon: 'baby', colorValue: 0xFF64B5F6, sortOrder: 15, isSystem: true),
  Category(id: 'cat_food', name: '食品饮料', icon: 'food', colorValue: 0xFF7CB342, sortOrder: 16, isSystem: true),
  Category(id: 'cat_health', name: '医疗健康', icon: 'health', colorValue: 0xFFE53935, sortOrder: 17, isSystem: true),
  Category(id: 'cat_pet', name: '宠物用品', icon: 'pet', colorValue: 0xFF8D6E63, sortOrder: 18, isSystem: true),
  Category(id: 'cat_tools', name: '工具', icon: 'tools', colorValue: 0xFF607D8B, sortOrder: 19, isSystem: true),
  Category(id: 'cat_collection', name: '收藏品', icon: 'collection', colorValue: 0xFFB8860B, sortOrder: 20, isSystem: true),
  Category(id: 'cat_ticket', name: '票券会员', icon: 'ticket', colorValue: 0xFF9575CD, sortOrder: 21, isSystem: true),
  Category(id: 'cat_other', name: '其他', icon: 'category', colorValue: 0xFF78909C, sortOrder: 22, isSystem: true),
];
