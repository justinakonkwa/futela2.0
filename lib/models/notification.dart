class AppNotification {
  final String id;
  final String userId;
  final String type; // reservation, payment, message, system
  final String title;
  final String content;
  final Map<String, dynamic>? data;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final String? status;
  final String? channel;
  final bool isRead;
  final DateTime? readAt;
  final List<String>? sentVia;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    this.data,
    this.relatedEntityId,
    this.relatedEntityType,
    this.status,
    this.channel,
    required this.isRead,
    this.readAt,
    this.sentVia,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'system',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic> ? json['data'] as Map<String, dynamic> : null,
      relatedEntityId: json['relatedEntityId']?.toString(),
      relatedEntityType: json['relatedEntityType']?.toString(),
      status: json['status']?.toString(),
      channel: json['channel']?.toString(),
      isRead: json['isRead'] == true,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt'].toString()) : null,
      sentVia: json['sentVia'] is List ? (json['sentVia'] as List).map((e) => e.toString()).toList() : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'content': content,
      'data': data,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'status': status,
      'channel': channel,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'sentVia': sentVia,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
