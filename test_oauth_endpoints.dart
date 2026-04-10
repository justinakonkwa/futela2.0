// Test de validation des endpoints OAuth
// Ce fichier peut être utilisé pour tester la conformité des réponses API

import 'dart:convert';

/// Modèle de test pour valider les réponses Google OAuth
class GoogleOAuthTestResponse {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final int expiresIn;
  final String tokenType;

  GoogleOAuthTestResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.expiresIn,
    required this.tokenType,
  });

  factory GoogleOAuthTestResponse.fromJson(Map<String, dynamic> json) {
    return GoogleOAuthTestResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      sessionId: json['sessionId'] as String,
      expiresIn: json['expiresIn'] as int,
      tokenType: json['tokenType'] as String,
    );
  }

  /// Valide que la réponse contient tous les champs requis
  bool isValid() {
    return accessToken.isNotEmpty &&
           refreshToken.isNotEmpty &&
           sessionId.isNotEmpty &&
           expiresIn > 0 &&
           tokenType == 'Bearer';
  }
}

/// Modèle de test pour valider les réponses Apple Sign-In
class AppleSignInTestResponse {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final int expiresIn;
  final int? refreshExpiresIn;
  final String tokenType;

  AppleSignInTestResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.sessionId,
    required this.expiresIn,
    this.refreshExpiresIn,
    required this.tokenType,
  });

  factory AppleSignInTestResponse.fromJson(Map<String, dynamic> json) {
    return AppleSignInTestResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      sessionId: json['sessionId'] as String,
      expiresIn: json['expiresIn'] as int,
      refreshExpiresIn: json['refreshExpiresIn'] as int?,
      tokenType: json['tokenType'] as String,
    );
  }

  /// Valide que la réponse contient tous les champs requis
  bool isValid() {
    return accessToken.isNotEmpty &&
           refreshToken.isNotEmpty &&
           sessionId.isNotEmpty &&
           expiresIn > 0 &&
           tokenType == 'Bearer';
  }
}

/// Exemples de réponses pour validation
class OAuthTestData {
  
  /// Exemple de réponse Google OAuth valide
  static const String googleResponseExample = '''
  {
    "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "def50200a8b9c7d6e5f4...",
    "sessionId": "550e8400-e29b-41d4-a716-446655440002",
    "expiresIn": 3600,
    "tokenType": "Bearer"
  }
  ''';

  /// Exemple de réponse Apple Sign-In valide
  static const String appleResponseExample = '''
  {
    "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
    "refreshToken": "abc123def456...",
    "sessionId": "019d6900-1111-7aef-bcf2-f6c19eb05379",
    "expiresIn": 3600,
    "refreshExpiresIn": 2592000,
    "tokenType": "Bearer"
  }
  ''';

  /// Exemple de requête Google OAuth
  static const String googleRequestExample = '''
  {
    "idToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
  ''';

  /// Exemple de requête Apple Sign-In (première connexion)
  static const String appleRequestExample = '''
  {
    "identityToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
    "authorizationCode": "c1234567890abcdef...",
    "firstName": "John",
    "lastName": "Doe"
  }
  ''';

  /// Exemple de requête Apple Sign-In (connexion existante)
  static const String appleRequestExistingExample = '''
  {
    "identityToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
    "authorizationCode": "c1234567890abcdef..."
  }
  ''';

  /// Teste la validité d'une réponse Google OAuth
  static bool testGoogleResponse(String jsonResponse) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonResponse);
      final response = GoogleOAuthTestResponse.fromJson(data);
      return response.isValid();
    } catch (e) {
      print('Erreur de validation Google OAuth: $e');
      return false;
    }
  }

  /// Teste la validité d'une réponse Apple Sign-In
  static bool testAppleResponse(String jsonResponse) {
    try {
      final Map<String, dynamic> data = jsonDecode(jsonResponse);
      final response = AppleSignInTestResponse.fromJson(data);
      return response.isValid();
    } catch (e) {
      print('Erreur de validation Apple Sign-In: $e');
      return false;
    }
  }

  /// Exécute tous les tests de validation
  static void runAllTests() {
    print('🧪 Tests de validation des endpoints OAuth');
    print('==========================================');
    
    // Test Google OAuth
    final googleValid = testGoogleResponse(googleResponseExample);
    print('✅ Google OAuth Response: ${googleValid ? "VALIDE" : "INVALIDE"}');
    
    // Test Apple Sign-In
    final appleValid = testAppleResponse(appleResponseExample);
    print('✅ Apple Sign-In Response: ${appleValid ? "VALIDE" : "INVALIDE"}');
    
    print('');
    print('📋 Exemples de requêtes:');
    print('Google OAuth: $googleRequestExample');
    print('Apple Sign-In: $appleRequestExample');
  }
}

/// Fonction principale pour exécuter les tests
void main() {
  OAuthTestData.runAllTests();
}