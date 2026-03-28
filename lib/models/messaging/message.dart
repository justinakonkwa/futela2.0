class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderName;
  final String content;
  final String type; // text, image, file
  final List<Map<String, dynamic>> attachments;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.type,
    required this.attachments,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> attachments = [];
    if (json['attachments'] is List) {
      for (final e in json['attachments'] as List) {
        if (e is Map<String, dynamic>) attachments.add(e);
      }
    }
    return Message(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversationId']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderName: json['senderName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'text',
      attachments: attachments,
      isRead: json['isRead'] == true,
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt'].toString()) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'type': type,
      'attachments': attachments,
      'isRead': isRead,
      'readAt': readAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
