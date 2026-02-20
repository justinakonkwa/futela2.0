import 'package:dio/dio.dart';
import '../models/messaging/conversation.dart';
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

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['conversations'] ?? [];
      return data.map((json) => Conversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<Conversation> getConversationDetails(String id) async {
    final response = await _dio.get('/api/conversations/$id');
    if (response.statusCode == 200) {
      return Conversation.fromJson(response.data);
    } else {
      throw Exception('Failed to load conversation details');
    }
  }

  Future<Conversation> createConversation({
    required String subject,
    required List<String> participantIds,
    String? propertyId,
  }) async {
    final response = await _dio.post('/api/conversations', data: {
      'subject': subject,
      'participantIds': participantIds,
      'propertyId': propertyId,
    });

    if (response.statusCode == 201) {
      return Conversation.fromJson(response.data);
    } else {
      throw Exception('Failed to create conversation');
    }
  }

  Future<void> archiveConversation(String id) async {
    await _dio.post('/api/conversations/$id/archive');
  }

  Future<void> deleteConversation(String id) async {
    await _dio.delete('/api/conversations/$id');
  }

  // --- Messages ---

  Future<List<Map<String, dynamic>>> getMessages(String conversationId,
      {int page = 1}) async {
    final response = await _dio
        .get('/api/conversations/$conversationId/messages', queryParameters: {
      'page': page,
      'order[createdAt]': 'desc',
    });

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data['messages'] ?? []);
    } else {
      throw Exception('Failed to load messages');
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
    List<Map<String, dynamic>>? attachments,
  }) async {
    final response = await _dio.post('/api/messages', data: {
      'conversationId': conversationId,
      'senderId': senderId,
      'content': content,
      'attachments': attachments,
    });

    if (response.statusCode == 201) {
      return response.data;
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    await _dio.put('/api/messages/$messageId/read');
  }

  Future<int> getUnreadMessagesCount() async {
    final response = await _dio.get('/api/me/messages/unread');
    if (response.statusCode == 200) {
      return response.data['count'] ?? 0;
    }
    return 0;
  }
}
