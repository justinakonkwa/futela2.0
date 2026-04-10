import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/user.dart';
import '../models/auth/auth_response.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = false;
  String? _error;

  final AuthService _authService = AuthService();

  User? get user => _user;
  String? get accessToken => _accessToken;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated =>
      _accessToken != null; // On pourrait vérifier l'expiration aussi

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAccessToken = prefs.getString('access_token');
      final savedRefreshToken = prefs.getString('refresh_token');

      if (savedAccessToken != null) {
        _accessToken = savedAccessToken;
        _refreshToken = savedRefreshToken;

        // Configurer le client API avec le token sauvegardé
        ApiClient().setAccessToken(_accessToken);

        // Tenter de récupérer le profil utilisateur
        try {
          _user = await _authService.getCurrentUser();
        } catch (e) {
          // Si le token est invalide ou expiré, on pourrait essayer de refresh ici
          if (savedRefreshToken != null) {
            try {
              await refreshToken();
              _user = await _authService.getCurrentUser();
            } catch (refreshError) {
              await logout();
            }
          } else {
            await logout();
          }
        }
      }
    } catch (e) {
      _error = _cleanErrorMessage(e);
      await logout();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshToken() async {
    if (_refreshToken == null) throw Exception('No refresh token available');

    final response = await _authService.refreshToken(_refreshToken!);
    await _saveTokens(response);
  }

  Future<void> _saveTokens(AuthResponse response) async {
    _accessToken = response.accessToken;
    _refreshToken = response.refreshToken;

    ApiClient().setAccessToken(_accessToken);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _accessToken!);
    await prefs.setString('refresh_token', _refreshToken!);
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.login(username, password);
      await _saveTokens(authResponse);

      // Récupérer les détails de l'utilisateur après connexion réussie
      _user = await _authService.getCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Affiche le message d'erreur sans le préfixe "Exception: ".
  static String _cleanErrorMessage(dynamic e) {
    final s = e.toString();
    return s.replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  }

  Future<bool> register({
    required String password,
    required String firstName,
    required String lastName,
    String? email,
    String? phoneNumber,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.register(
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phoneNumber: phoneNumber,
      );

      await _saveTokens(authResponse);
      _user = await _authService.getCurrentUser();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      // On tente de prévenir le serveur si on a une session, mais on nettoie localement quoiqu'il arrive
      // Note: Le sessionId devrait être stocké si on veut utiliser l'endpoint logout correctement,
      // ou on peut ignorer l'appel serveur si on n'a pas l'ID.
      // Pour l'instant on nettoie juste localement et on révoque token si possible.
    } catch (e) {
      print("Logout error: $e");
    }

    await _authService.signOutGoogleSilently();
    await _authService.signOutApple();

    _user = null;
    _accessToken = null;
    _refreshToken = null;
    _error = null;

    ApiClient().setAccessToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    notifyListeners();
  }

  // Compatibility Aliases
  String? get token => _accessToken;

  Future<bool> signIn(String login, String password) async {
    return this.login(login, password);
  }

  /// Connexion via Google OAuth (POST /api/auth/google — corps `{ "idToken": "..." }`).
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authResponse = await _authService.signInWithGoogle();
      await _saveTokens(authResponse);
      _user = await _authService.getCurrentUser();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _cleanErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Connexion via Apple Sign-In (POST /api/auth/apple).
  Future<bool> signInWithApple() async {
    print('🔄 [AuthProvider] Début signInWithApple');
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔄 [AuthProvider] Appel AuthService.signInWithApple()');
      final authResponse = await _authService.signInWithApple();
      
      print('🔄 [AuthProvider] Réponse reçue, sauvegarde des tokens...');
      await _saveTokens(authResponse);
      
      print('🔄 [AuthProvider] Récupération du profil utilisateur...');
      _user = await _authService.getCurrentUser();
      
      print('✅ [AuthProvider] Connexion Apple réussie');
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('❌ [AuthProvider] Erreur signInWithApple: $e');
      print('❌ [AuthProvider] Type d\'erreur: ${e.runtimeType}');
      
      _error = _cleanErrorMessage(e);
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
    return this.register(
      password: password,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phone,
    );
  }

  Future<bool> updateProfile(Map<String, dynamic> userData) async {
    // TODO: Implement update profile in AuthService
    print('Update profile not implemented yet');
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> updatePassword(String oldPassword, String newPassword) async {
    // TODO: Implement update password in AuthService
    print('Update password not implemented yet');
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(seconds: 1));
    _isLoading = false;
    notifyListeners();
    return true;
  }
}
