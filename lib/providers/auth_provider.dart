import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_response.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      
      if (savedToken != null) {
        _token = savedToken;
        _user = await ApiService.getProfile();
      }
    } catch (e) {
      _error = e.toString();
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String login, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await ApiService.signIn(login, password);
      _user = authResponse.user;
      _token = authResponse.token;

      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp({
    required String phone,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await ApiService.signUp(
        phone: phone,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        middleName: middleName,
      );
      
      _user = authResponse.user;
      _token = authResponse.token;

      // Sauvegarder le token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', _token!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _error = null;

    // Supprimer le token sauvegardé
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    notifyListeners();
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.updateUserInfo(userData);
      _user = await ApiService.getProfile();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.updatePassword(oldPassword, newPassword);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
