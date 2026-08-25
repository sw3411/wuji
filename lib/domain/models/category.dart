import 'package:flutter/material.dart';

/// 物品分类。
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.sortOrder,
    required this.isSystem,
    this.isHidden = false,
  });

  final String id;
  final String name;

  /// Material 图标名，见 CategoryIcons。
  final String icon;
  final int colorValue;
  final int sortOrder;
  final bool isSystem;
  final bool isHidden;

  Color get color => Color(colorValue);

  Category copyWith({
    String? name,
    String? icon,
    int? colorValue,
    int? sortOrder,
    bool? isHidden,
  }) =>
      Category(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        colorValue: colorValue ?? this.colorValue,
        sortOrder: sortOrder ?? this.sortOrder,
        isSystem: isSystem,
        isHidden: isHidden ?? this.isHidden,
      );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        icon: json['icon'] as String,
        colorValue: (json['colorValue'] as num).toInt(),
        sortOrder: (json['sortOrder'] as num).toInt(),
        isSystem: json['isSystem'] as bool? ?? false,
        isHidden: json['isHidden'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'colorValue': colorValue,
        'sortOrder': sortOrder,
        'isSystem': isSystem,
        'isHidden': isHidden,
      };
}
