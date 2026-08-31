import 'enums.dart';

/// 物品生命周期事件。
class ItemEvent {
  ItemEvent({
    required this.id,
    required this.itemId,
    required this.eventType,
    required this.eventDate,
    required this.title,
    this.description,
    this.amount,
    this.imagePaths = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String itemId;
  final ItemEventType eventType;
  final DateTime eventDate;
  final String title;
  final String? description;

  /// 事件关联金额（分），例如维修费用。可为空。
  final int? amount;
  final List<String> imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  ItemEvent copyWith({
    ItemEventType? eventType,
    DateTime? eventDate,
    String? title,
    String? description,
    int? amount,
    List<String>? imagePaths,
  }) => ItemEvent(
    id: id,
    itemId: itemId,
    eventType: eventType ?? this.eventType,
    eventDate: eventDate ?? this.eventDate,
    title: title ?? this.title,
    description: description ?? this.description,
    amount: amount ?? this.amount,
    imagePaths: imagePaths ?? this.imagePaths,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  factory ItemEvent.fromJson(Map<String, dynamic> json) => ItemEvent(
    id: json['id'] as String,
    itemId: json['itemId'] as String,
    eventType: ItemEventType.fromName(json['eventType'] as String),
    eventDate: DateTime.parse(json['eventDate'] as String),
    title: json['title'] as String,
    description: json['description'] as String?,
    amount: (json['amount'] as num?)?.toInt(),
    imagePaths: (json['imagePaths'] as List<dynamic>? ?? const [])
        .map((e) => e as String)
        .toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'itemId': itemId,
    'eventType': eventType.name,
    'eventDate': eventDate.toIso8601String(),
    'title': title,
    'description': description,
    'amount': amount,
    'imagePaths': imagePaths,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
