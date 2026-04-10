// Configuration Apple Sign-In pour Futela
// Voir APPLE_SIGNIN_SETUP.md pour les instructions de configuration

/// Endpoint pour l'authentification Apple côté backend
const String kAppleLoginPath = '/api/auth/apple';

/// Endpoint pour la vérification Apple côté backend  
const String kAppleVerifyPath = '/auth/apple/verify';

/// Endpoint pour la révocation Apple côté backend
const String kAppleRevokePath = '/auth/apple/revoke';

/// Scopes demandés lors de l'authentification Apple
const List<String> kAppleSignInScopes = ['email', 'fullName'];

/// Configuration des redirects Apple Sign-In
class AppleSignInConfig {
  /// Bundle ID de l'application (doit correspondre à celui configuré dans Apple Developer)
  static const String bundleId = 'com.naara.futela';
  
  /// Service ID pour Apple Sign-In (optionnel, pour le web)
  /// À configurer dans Apple Developer Console si support web nécessaire
  static const String? serviceId = null; // 'com.futelaapp.mobile.signin';
  
  /// Redirect URI pour le web (optionnel)
  static const String? redirectUri = null; // 'https://your-domain.com/auth/apple/callback';
}