import 'package:dio/dio.dart';
import '../models/messaging/conversation.dart';
import '../models/messaging/message.dart';
import 'api_client.dart';

class MessagingService {
  final Dio _dio;

  MessagingService() : _dio = ApiClient().dio;

  // --- Conversations ---

  Future<List<Conversation>> getConversations(
      {int page = 1, bool unreadOnly = false}) async {
    final response = await _dio.get('/api/conversations', queryParameters: {
      'page': page,
      'unreadOnly': unreadOnly,
    });

    if (response.statusCode == 200 && response.data is Map) {
      final List<dynamic> data = response.data['conversations'] ?? [];
      return data
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Failed to load conversations');
  }

  Future<List<Conversation>> getArchivedConversations({int page = 1}) async {
    final response = await _dio.get('/api/conversations/archived',
        queryParameters: {'page': page});

    if (response.statusCode == 200 && response.data is Map) {
      final List<dynamic> data = response.data['conversations'] ?? [];
      return data
          .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<Conversation> getConversationDetails(String id) async {
    final response = await _dio.get('/api/conversations/$id');
    if (response.statusCode == 200 && response.data is Map) {
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to load conversation details');
  }

  Future<Conversation> createConversation({
    required String subject,
    required List<String> participantIds,
    String? propertyId,
  }) async {
    final response = await _dio.post('/api/conversations', data: {
      'subject': subject,
      'participantIds': participantIds,
      if (propertyId != null) 'propertyId': propertyId,
    });

    if (response.statusCode == 201 && response.data is Map) {
      return Conversation.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to create conversation');
  }

  static String _conversationErrorMessage(int? statusCode) {
    if (statusCode == null) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion et réessayez.';
    }
    if (statusCode >= 500 && statusCode < 600) {
      return 'Le serveur est temporairement indisponible. Veuillez réessayer dans quelques instants.';
    }
    if (statusCode == 404) {
      return 'Impossible de contacter pour le moment. Réessayez plus tard.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'Accès refusé. Connectez-vous pour contacter.';
    }
    if (statusCode == 400 || statusCode == 422) {
      return 'Requête invalide. Réessayez.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  Future<Conversation> startConversationWithUser(String userId) async {
    print('--> POST /api/users/$userId/conversations');
    print('    payload: (none)');
    try {
      final response = await _dio.post('/api/users/$userId/conversations');
      if (response.statusCode == 200 && response.data is Map) {
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception(_conversationErrorMessage(response.statusCode));
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('La requête a pris trop de temps. Réessayez.');
      }
      throw Exception(_conversationErrorMessage(statusCode));
    }
  }

  Future<Conversation> startConversationOnProperty(String propertyId,
      {String? message}) async {
    final payload = message != null && message.isNotEmpty ? {'message': message} : null;
    print('--> POST /api/properties/$propertyId/conversations');
    print('    payload: $payload');
    try {
      final response = await _dio.post(
        '/api/properties/$propertyId/conversations',
        data: payload,
      );
      if (response.statusCode == 200 && response.data is Map) {
        return Conversation.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception(_conversationErrorMessage(response.statusCode));
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('La requête a pris trop de temps. Réessayez.');
      }
      throw Exception(_conversationErrorMessage(statusCode));
    }
  }

  /// Public endpoint: contact owner without auth (no Bearer).
  Future<void> contactOwner(
    String propertyId, {
    required String name,
    required String email,
    required String message,
    String? phone,
  }) async {
    final dio = Dio(BaseOptions(
      baseUrl: ApiClient.baseUrl,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ));
    final response = await dio.post(
      '/api/properties/$propertyId/contact-owner',
      data: {
        'name': name,
        'email': email,
        'message': message,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    if (response.statusCode != 200) {
      throw Exception(
          response.data is Map && response.data['message'] != null
              ? response.data['message'].toString()
              : 'Failed to send contact request');
    }
  }

  Future<void> archiveConversation(String id) async {
    await _dio.post('/api/conversations/$id/archive');
  }

  Future<void> deleteConversation(String id) async {
    await _dio.delete('/api/conversations/$id');
  }

  // --- Messages ---

  Future<List<Message>> getMessages(String conversationId, {int page = 1}) async {
    final response = await _dio.get(
      '/api/conversations/$conversationId/messages',
      queryParameters: {'page': page, 'order[createdAt]': 'desc'},
    );

    if (response.statusCode == 200 && response.data is Map) {
      final list = response.data['messages'];
      if (list is List) {
        return list
            .map((e) => Message.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  Future<Message> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final response = await _dio.post('/api/messages', data: {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      if (attachments != null && attachments.isNotEmpty) 'attachments': attachments,
    });

    if (response.statusCode == 201 && response.data is Map) {
      return Message.fromJson(response.data as Map<String, dynamic>);
    }
    throw Exception('Failed to send message');
  }

  Future<void> markMessageAsRead(String messageId) async {
    await _dio.put('/api/messages/$messageId/read');
  }

  Future<int> getUnreadMessagesCount() async {
    try {
      final response = await _dio.get('/api/me/messages/unread');
      if (response.statusCode == 200 && response.data is Map) {
        return (response.data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } on DioException {
      return 0;
    }
  }
}
