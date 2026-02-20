import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/user.dart';
import '../models/auth/device.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio;

  /// Client ID OAuth 2.0 (type Web) depuis Google Cloud Console.
  /// Utilisé pour obtenir l'idToken à envoyer au backend (POST /api/auth/google).
  /// Le GOOGLE_CLIENT_SECRET reste côté backend uniquement.
  static const String _googleServerClientId =
      '474613582555-etdekl4un7r2r11u08h1jv2jelg3br0q.apps.googleusercontent.com';

  AuthService() : _dio = ApiClient().dio;

  // --- Registration & OAuth ---

  Future<AuthResponse> register({
    required String password,
    required String firstName,
    required String lastName,
    String? email,
    String? phoneNumber,
  }) async {
    final response = await _dio.post('/api/auth/register', data: {
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
    });

    if (response.statusCode == 201) {
      return AuthResponse.fromJson(response.data);
    } else {
      throw Exception('Registration failed: ${response.data}');
    }
  }

  /// Connexion Google : affiche le flux Google Sign-In, récupère l'idToken, appelle POST /api/auth/google.
  Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      serverClientId: _googleServerClientId.isEmpty ? null : _googleServerClientId,
    );
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Connexion Google annulée');
    }
    final GoogleSignInAuthentication auth = await account.authentication;
    final String? idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('Impossible d\'obtenir l\'idToken Google. Vérifiez le serverClientId (OAuth 2.0 Web) dans Google Cloud.');
    }
    return googleLogin(idToken);
  }

  Future<AuthResponse> googleLogin(String idToken) async {
    final response = await _dio.post('/api/auth/google', data: {
      'idToken': idToken,
    });

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(response.data);
    } else {
      throw Exception('Google login failed: ${response.data}');
    }
  }

  // --- Login & Session Management ---

  /// Extrait le message d'erreur depuis la réponse API (format { "error": { "message": "...", "code": 401 } }).
  static String _messageFromResponse(dynamic data, String fallback) {
    if (data is Map) {
      final map = data as Map<String, dynamic>;
      final error = map['error'];
      if (error is Map) {
        final msg = error['message']?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
      }
      final msg = map['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return fallback;
  }

  Future<AuthResponse> login(String username, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      }
      final message = _messageFromResponse(response.data, 'Identifiants invalides');
      throw Exception(message);
    } on DioException catch (e) {
      // Dio peut renvoyer une erreur avec response (ex. 401)
      final message = e.response?.data != null
          ? _messageFromResponse(e.response!.data, 'Identifiants invalides')
          : (e.message ?? 'Erreur de connexion');
      throw Exception(message);
    }
  }

  Future<User> getCurrentUser() async {
    final response = await _dio.get('/api/auth/me');

    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    } else {
      throw Exception('Failed to get current user: ${response.data}');
    }
  }

  Future<AuthResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post('/api/auth/refresh', data: {
      'refreshToken': refreshToken,
    });

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(response.data);
    } else {
      throw Exception('Failed to refresh token: ${response.data}');
    }
  }

  Future<void> logout(String sessionId) async {
    final response = await _dio.post('/api/auth/logout', data: {
      'sessionId': sessionId,
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to logout: ${response.data}');
    }
  }

  Future<void> revokeAllSessions() async {
    await _dio.post('/api/auth/revoke-all');
  }

  Future<List<Device>> getConnectedDevices() async {
    final response = await _dio.get('/api/auth/devices');
    if (response.statusCode == 200) {
      return (response.data['devices'] as List)
          .map((e) => Device.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to get devices: ${response.data}');
    }
  }

  // --- Verification ---

  Future<void> sendEmailVerification() async {
    await _dio.post('/api/auth/send-email-code');
  }

  Future<void> sendPhoneVerification() async {
    await _dio.post('/api/auth/send-phone-code');
  }

  Future<bool> confirmEmail(String code) async {
    final response = await _dio.post('/api/auth/confirm-email', data: {
      'code': code,
    });
    return response.statusCode == 200;
  }

  Future<bool> confirmPhone(String code) async {
    final response = await _dio.post('/api/auth/confirm-phone', data: {
      'code': code,
    });
    return response.statusCode == 200;
  }
}
