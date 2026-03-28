import 'package:flutter/material.dart';
import '../models/messaging/conversation.dart';
import '../models/messaging/message.dart';
import '../services/messaging_service.dart';

class MessagingProvider with ChangeNotifier {
  final MessagingService _service = MessagingService();

  List<Conversation> _conversations = [];
  List<Conversation> _archivedConversations = [];
  Conversation? _currentConversation;
  List<Message> _messages = [];
  int _unreadMessagesCount = 0;
  bool _isLoading = false;
  String? _error;

  List<Conversation> get conversations => _conversations;
  List<Conversation> get archivedConversations => _archivedConversations;
  Conversation? get currentConversation => _currentConversation;
  List<Message> get messages => _messages;
  int get unreadMessagesCount => _unreadMessagesCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations({int page = 1, bool unreadOnly = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations =
          await _service.getConversations(page: page, unreadOnly: unreadOnly);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _errorMessage(e);
      _conversations = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadArchivedConversations({int page = 1}) async {
    try {
      _archivedConversations =
          await _service.getArchivedConversations(page: page);
      notifyListeners();
    } catch (_) {
      _archivedConversations = [];
      notifyListeners();
    }
  }

  Future<void> loadConversationDetails(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentConversation = await _service.getConversationDetails(id);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _errorMessage(e);
      _currentConversation = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String conversationId, {int page = 1}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _service.getMessages(conversationId, page: page);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _errorMessage(e);
      _messages = [];
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Message?> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    _error = null;
    try {
      final message = await _service.sendMessage(
        conversationId: conversationId,
        senderId: senderId,
        content: content,
      );
      _messages.insert(0, message);
      notifyListeners();
      return message;
    } catch (e) {
      _error = _errorMessage(e);
      notifyListeners();
      return null;
    }
  }

  Future<Conversation?> startConversationOnProperty(String propertyId,
      {String? message}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversation =
          await _service.startConversationOnProperty(propertyId, message: message);
      _currentConversation = conversation;
      _isLoading = false;
      notifyListeners();
      return conversation;
    } catch (e) {
      _error = _errorMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  static String _errorMessage(dynamic e) {
    final s = e.toString();
    return s.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  Future<Conversation?> startConversationWithUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversation = await _service.startConversationWithUser(userId);
      _currentConversation = conversation;
      _isLoading = false;
      notifyListeners();
      return conversation;
    } catch (e) {
      _error = _errorMessage(e);
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<bool> contactOwner(
    String propertyId, {
    required String name,
    required String email,
    required String message,
    String? phone,
  }) async {
    _error = null;
    try {
      await _service.contactOwner(propertyId,
          name: name, email: email, message: message, phone: phone);
      notifyListeners();
      return true;
    } catch (e) {
      _error = _errorMessage(e);
      notifyListeners();
      return false;
    }
  }

  Future<void> loadUnreadMessagesCount() async {
    try {
      _unreadMessagesCount = await _service.getUnreadMessagesCount();
      notifyListeners();
    } catch (_) {
      _unreadMessagesCount = 0;
      notifyListeners();
    }
  }

  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _service.markMessageAsRead(messageId);
      final index = _messages.indexWhere((m) => m.id == messageId);
      if (index != -1) {
        final m = _messages[index];
        _messages[index] = Message(
          id: m.id,
          conversationId: m.conversationId,
          senderId: m.senderId,
          senderName: m.senderName,
          content: m.content,
          type: m.type,
          attachments: m.attachments,
          isRead: true,
          readAt: DateTime.now(),
          createdAt: m.createdAt,
        );
      }
      notifyListeners();
    } catch (_) {
      notifyListeners();
    }
  }

  Future<void> archiveConversation(String id) async {
    try {
      await _service.archiveConversation(id);
      _conversations.removeWhere((c) => c.id == id);
      if (_currentConversation?.id == id) _currentConversation = null;
      notifyListeners();
    } catch (e) {
      _error = _errorMessage(e);
      notifyListeners();
    }
  }

  Future<void> deleteConversation(String id) async {
    try {
      await _service.deleteConversation(id);
      _conversations.removeWhere((c) => c.id == id);
      if (_currentConversation?.id == id) {
        _currentConversation = null;
        _messages = [];
      }
      notifyListeners();
    } catch (e) {
      _error = _errorMessage(e);
      notifyListeners();
    }
  }

  void setCurrentConversation(Conversation? c) {
    _currentConversation = c;
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
