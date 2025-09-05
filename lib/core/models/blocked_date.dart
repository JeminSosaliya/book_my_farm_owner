class BlockedDate {
  final String id;
  final String farmId;
  final String farmName;
  final List<String> dates;
  final String reason;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  BlockedDate({
    required this.id,
    required this.farmId,
    required this.farmName,
    required this.dates,
    required this.reason,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlockedDate.fromJson(Map<String, dynamic> json) {
    return BlockedDate(
      id: json['_id'] ?? '',
      farmId: json['farmId'] ?? '',
      farmName: json['farmName'] ?? '',
      dates: List<String>.from(json['dates'] ?? []),
      reason: json['reason'] ?? '',
      createdBy: json['createdBy'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }
} 