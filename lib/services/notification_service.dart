import 'package:dio/dio.dart';
import 'api_client.dart';

class NotificationService {
  final Dio _dio;

  NotificationService() : _dio = ApiClient().dio;

  Future<List<Map<String, dynamic>>> getNotifications(
      {int page = 1, String? type}) async {
    final Map<String, dynamic> params = {'page': page};
    if (type != null) params['type'] = type;

    final response =
        await _dio.get('/api/notifications', queryParameters: params);

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(
          response.data['notifications'] ?? []);
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<int> getUnreadCount() async {
    final response = await _dio.get('/api/notifications/unread-count');
    if (response.statusCode == 200) {
      return response.data['count'] ?? 0;
    }
    return 0;
  }

  Future<void> markAllAsRead() async {
    await _dio.put('/api/notifications/mark-all-read');
  }

  Future<void> markAsRead(String id) async {
    await _dio.put('/api/notifications/$id/read');
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete('/api/notifications/$id');
  }
}
