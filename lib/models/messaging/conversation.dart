class ConversationParticipant {
  final String id;
  final String name;

  ConversationParticipant({required this.id, required this.name});

  factory ConversationParticipant.fromJson(Map<String, dynamic> json) {
    return ConversationParticipant(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
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
  final List<String>? participantIds;
  final String? propertyId;
  final String? propertyTitle;
  final DateTime? lastMessageAt;
  final bool isArchived;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.subject,
    required this.participants,
    this.participantIds,
    this.propertyId,
    this.propertyTitle,
    this.lastMessageAt,
    required this.isArchived,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    final participantsList = json['participants'];
    final participants = participantsList is List
        ? (participantsList)
            .map((e) => ConversationParticipant.fromJson(
                e is Map<String, dynamic> ? e : <String, dynamic>{}))
            .toList()
        : <ConversationParticipant>[];
    final participantIdsList = json['participantIds'];
    final participantIds = participantIdsList is List
        ? (participantIdsList).map((e) => e.toString()).toList()
        : null;
    return Conversation(
      id: json['id']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
      participants: participants,
      participantIds: participantIds,
      propertyId: json['propertyId']?.toString(),
      propertyTitle: json['propertyTitle']?.toString(),
      lastMessageAt: json['lastMessageAt'] != null
          ? DateTime.tryParse(json['lastMessageAt'].toString())
          : null,
      isArchived: json['isArchived'] == true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'participants': participants.map((e) => e.toJson()).toList(),
      'participantIds': participantIds,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'lastMessageAt': lastMessageAt?.toIso8601String(),
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
