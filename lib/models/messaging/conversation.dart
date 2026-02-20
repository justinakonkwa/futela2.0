class ConversationParticipant {
  final String id;
  final String name;

  ConversationParticipant({required this.id, required this.name});

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class Conversation {
  final String id;
  final String subject;
  final List<ConversationParticipant> participants;
  final String? propertyId;
  final String? propertyTitle;
  final DateTime? lastMessageAt;
  final bool isArchived;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.subject,
    required this.participants,
    this.propertyId,
    this.propertyTitle,
    this.lastMessageAt,
    required this.isArchived,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      subject: json['subject'],
      participants: (json['participants'] as List)
          .map((e) => ConversationParticipant.fromJson(e))
          .toList(),
      propertyId: json['propertyId'],
      propertyTitle: json['propertyTitle'],
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.parse(json['lastMessageAt'])
          : null,
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'participants': participants.map((e) => e.toJson()).toList(),
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
