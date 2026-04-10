import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../config/google_oauth_config.dart';
import '../config/apple_signin_config.dart';
import '../models/auth/auth_response.dart';
import '../models/auth/user.dart';
import '../models/auth/device.dart';
import '../models/auth/apple_signin_credential.dart';
import '../services/apple_signin_service.dart';
import 'api_client.dart';

class AuthService {
  final Dio _dio;
  final AppleSignInService _appleSignInService = AppleSignInService();

  GoogleSignIn? _googleSignIn;

  /// Aligné SuperApp : sur iOS, `clientId` = client OAuth **iOS** si renseigné ;
  /// `serverClientId` = client **Web** (audience `aud` du JWT pour le backend).
  GoogleSignIn _createGoogleSignIn() {
    final isIos = !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    final iosId = kGoogleIosClientId.trim();
    return GoogleSignIn(
      clientId: (isIos && iosId.isNotEmpty) ? iosId : null,
      serverClientId:
          kGoogleWebClientId.isEmpty ? null : kGoogleWebClientId,
      scopes: const <String>['email', 'profile'],
    );
  }

  GoogleSignIn get _googleSignInInstance {
    _googleSignIn ??= _createGoogleSignIn();
    return _googleSignIn!;
  }

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
    final googleSignIn = _googleSignInInstance;
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    if (account == null) {
      throw Exception('Connexion Google annulée');
    }
    final GoogleSignInAuthentication auth = await account.authentication;
    final String? idToken = auth.idToken;
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Impossible d\'obtenir l\'idToken Google. Vérifiez le client Web (serverClientId), '
        'le SHA-1 Android, et sur iOS le client iOS + Info.plist — '
        'voir GOOGLE_SIGNIN_SETUP.md et GOOGLE_SIGNIN_IOS.md.',
      );
    }
    return googleLogin(idToken);
  }

  /// À appeler au logout pour permettre de choisir un autre compte Google ensuite.
  Future<void> signOutGoogleSilently() async {
    try {
      await _googleSignInInstance.signOut();
    } catch (_) {
      // Ignorer si jamais connecté avec Google
    }
  }

  /// Connexion Apple : utilise le service AppleSignInService selon le guide
  Future<AuthResponse> signInWithApple() async {
    print('🍎 [AuthService] Début de l\'authentification Apple');
    
    try {
      // Vérifier la disponibilité
      if (!await _appleSignInService.isAvailable()) {
        throw Exception('Apple Sign-In n\'est pas disponible sur cet appareil');
      }

      // Obtenir les credentials Apple
      final credential = await _appleSignInService.signIn();
      if (credential == null) {
        throw Exception('Impossible d\'obtenir les credentials Apple');
      }

      // Vérifier que nous avons les données essentielles
      if (credential.identityToken == null || credential.authorizationCode == null) {
        throw Exception('Tokens Apple manquants - vérifiez la configuration Apple Developer');
      }

      // Authentifier avec le backend
      return await _authenticateWithBackend(credential);
    } on AppleSignInException catch (e) {
      print('❌ [AuthService] AppleSignInException: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('❌ [AuthService] Erreur Apple Sign-In: $e');
      rethrow;
    }
  }

  /// Authentifier avec le backend selon les spécifications API
  Future<AuthResponse> _authenticateWithBackend(AppleSignInCredential credential) async {
    print('🌐 [AuthService] Authentification backend avec Apple credentials');
    
    try {
      // Préparer les données selon les spécifications backend réelles
      final Map<String, dynamic> requestData = {
        'idToken': credential.identityToken,  // Backend attend 'idToken' comme Google
        'authorizationCode': credential.authorizationCode,
        'userIdentifier': credential.userIdentifier,
        'email': credential.email,
        'firstName': credential.givenName,  // Maintenant inclut les noms sauvegardés
        'lastName': credential.familyName,
      };

      // Nettoyer les valeurs nulles
      requestData.removeWhere((key, value) => value == null);

      print('🌐 [AuthService] Données envoyées au backend:');
      requestData.forEach((key, value) {
        if (key.contains('token') || key.contains('code')) {
          print('   - $key: ${value != null ? "présent" : "null"}');
        } else {
          print('   - $key: $value');
        }
      });

      // Appel API selon vos spécifications
      final response = await _dio.post(kAppleLoginPath, data: requestData);

      print('🌐 [AuthService] Réponse backend:');
      print('   - Status: ${response.statusCode}');
      print('   - Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      }

      final message = _messageFromResponse(response.data, 'Authentification Apple refusée');
      throw Exception(message);
    } on DioException catch (e) {
      print('❌ [AuthService] Erreur réseau: ${e.message}');
      print('   - Status: ${e.response?.statusCode}');
      print('   - Data: ${e.response?.data}');
      
      final message = e.response?.data != null
          ? _messageFromResponse(e.response!.data, 'Erreur serveur Apple Sign-In')
          : (e.message ?? 'Erreur réseau');
      throw Exception(message);
    }
  }

  /// Vérifier l'état des credentials Apple
  Future<bool> checkAppleCredentialState() async {
    return await _appleSignInService.checkCredentialState();
  }

  /// Déconnexion Apple Sign-In
  Future<void> signOutApple() async {
    await _appleSignInService.signOut();
  }

  Future<AuthResponse> googleLogin(String idToken) async {
    try {
      // API Futela : POST /api/auth/google — corps { "idToken": "<jwt>" }
      final response = await _dio.post(kGoogleLoginPath, data: {
        'idToken': idToken,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse.fromJson(response.data);
      }
      final message =
          _messageFromResponse(response.data, 'Connexion Google refusée');
      throw Exception(message);
    } on DioException catch (e) {
      final message = e.response?.data != null
          ? _messageFromResponse(e.response!.data, 'Connexion Google refusée')
          : (e.message ?? 'Erreur réseau');
      throw Exception(message);
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

    print('👤 GET PROFILE RESPONSE:');
    print('  Status: ${response.statusCode}');
    print('  Data: ${response.data is Map ? const JsonEncoder.withIndent('  ').convert(response.data) : response.data}');

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
