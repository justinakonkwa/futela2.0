class Visit {
  final String id;
  final String propertyId;
  final String propertyTitle;
  final String visitorId;
  final String visitorName;
  final DateTime scheduledAt;
  final String status; // scheduled, confirmed, completed, cancelled
  final String? notes;
  final DateTime? confirmedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  Visit({
    required this.id,
    required this.propertyId,
    required this.propertyTitle,
    required this.visitorId,
    required this.visitorName,
    required this.scheduledAt,
    required this.status,
    this.notes,
    this.confirmedAt,
    this.completedAt,
    required this.createdAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      propertyId: json['propertyId'],
      propertyTitle: json['propertyTitle'],
      visitorId: json['visitorId'],
      visitorName: json['visitorName'],
      scheduledAt: DateTime.parse(json['scheduledAt']),
      status: json['status'],
      notes: json['notes'],
      confirmedAt: json['confirmedAt'] != null
          ? DateTime.parse(json['confirmedAt'])
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'visitorId': visitorId,
      'visitorName': visitorName,
      'scheduledAt': scheduledAt.toIso8601String(),
      'status': status,
      'notes': notes,
      'confirmedAt': confirmedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
