import 'package:flutter/material.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationService _service = NotificationService();

  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications({int page = 1, String? type}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notifications = await _service.getNotifications(page: page, type: type);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _notifications = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      _unreadCount = await _service.getUnreadCount();
      _updateAppBadge(_unreadCount);
      notifyListeners();
    } catch (_) {
      _unreadCount = 0;
      notifyListeners();
    }
  }

  void _updateAppBadge(int count) {
    try {
      AppBadgePlus.updateBadge(count);
    } catch (_) {
      // Badge non supporté sur cet appareil
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _service.markAsRead(id);
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index] = AppNotification(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          type: _notifications[index].type,
          title: _notifications[index].title,
          content: _notifications[index].content,
          data: _notifications[index].data,
          relatedEntityId: _notifications[index].relatedEntityId,
          relatedEntityType: _notifications[index].relatedEntityType,
          status: _notifications[index].status,
          channel: _notifications[index].channel,
          isRead: true,
          readAt: DateTime.now(),
          sentVia: _notifications[index].sentVia,
          createdAt: _notifications[index].createdAt,
        );
      }
      await loadUnreadCount();
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _service.markAllAsRead();
      _notifications = _notifications
          .map((n) => AppNotification(
                id: n.id,
                userId: n.userId,
                type: n.type,
                title: n.title,
                content: n.content,
                data: n.data,
                relatedEntityId: n.relatedEntityId,
                relatedEntityType: n.relatedEntityType,
                status: n.status,
                channel: n.channel,
                isRead: true,
                readAt: DateTime.now(),
                sentVia: n.sentVia,
                createdAt: n.createdAt,
              ))
          .toList();
      _unreadCount = 0;
      _updateAppBadge(0);
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> delete(String id) async {
    try {
      await _service.deleteNotification(id);
      _notifications.removeWhere((n) => n.id == id);
      await loadUnreadCount();
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
