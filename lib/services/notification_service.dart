import 'package:dio/dio.dart';
import '../models/notification.dart';
import 'api_client.dart';

class NotificationService {
  final Dio _dio;

  NotificationService() : _dio = ApiClient().dio;

  Future<List<AppNotification>> getNotifications(
      {int page = 1, String? type}) async {
    try {
      final Map<String, dynamic> params = {'page': page};
      if (type != null && type.isNotEmpty) params['type'] = type;

      final response =
          await _dio.get('/api/notifications', queryParameters: params);

      if (response.statusCode == 200 && response.data is Map) {
        final list = response.data['member'] ?? response.data['notifications'];
        if (list is List) {
          return list
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException {
      rethrow;
    }
  }

  Future<List<AppNotification>> getUnread() async {
    try {
      final response = await _dio.get('/api/notifications/unread');
      if (response.statusCode == 200 && response.data is Map) {
        final list = response.data['member'] ?? response.data['notifications'];
        if (list is List) {
          return list
              .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return [];
    } on DioException {
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get('/api/notifications/unread-count');
      if (response.statusCode == 200 && response.data is Map) {
        return (response.data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } on DioException {
      return 0;
    }
  }

  Future<void> markAllAsRead() async {
    await _dio.put('/api/notifications/mark-all-read');
  }

  Future<void> markAsRead(String id) async {
    try {
      await _dio.put('/api/notifications/$id/read');
    } on DioException {
      // Silently ignore — server-side issue
    }
  }

  Future<void> deleteNotification(String id) async {
    await _dio.delete('/api/notifications/$id');
  }
}
