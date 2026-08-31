/// 存放位置，支持树状层级（parentId 为空表示顶级位置）。
class Location {
  Location({
    required this.id,
    required this.name,
    this.parentId,
    this.description,
    this.imagePath,
    this.icon,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? parentId;
  final String? description;
  final String? imagePath;

  /// 预设图标键（见 LocationIconSet）。null = 未选择。
  final String? icon;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  Location copyWith({
    String? name,
    String? parentId,
    bool clearParent = false,
    String? description,
    String? imagePath,
    String? icon,
    int? sortOrder,
  }) => Location(
    id: id,
    name: name ?? this.name,
    parentId: clearParent ? null : (parentId ?? this.parentId),
    description: description ?? this.description,
    imagePath: imagePath ?? this.imagePath,
    icon: icon ?? this.icon,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    id: json['id'] as String,
    name: json['name'] as String,
    parentId: json['parentId'] as String?,
    description: json['description'] as String?,
    imagePath: json['imagePath'] as String?,
    icon: json['icon'] as String?,
    sortOrder: (json['sortOrder'] as num).toInt(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'parentId': parentId,
    'description': description,
    'imagePath': imagePath,
    'icon': icon,
    'sortOrder': sortOrder,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
