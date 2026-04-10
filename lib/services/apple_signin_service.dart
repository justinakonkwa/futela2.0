import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/auth/apple_signin_credential.dart';

enum AppleSignInError {
  canceled,
  failed,
  invalidResponse,
  notHandled,
  unknown,
}

class AppleSignInException implements Exception {
  final AppleSignInError error;
  final String message;

  AppleSignInException(this.error, this.message);

  @override
  String toString() => 'AppleSignInException: $message';
}

class AppleSignInLogger {
  static void logSignInAttempt() {
    print('🍎 [Apple Sign In] Tentative de connexion');
  }

  static void logSignInSuccess(String userIdentifier) {
    print('✅ [Apple Sign In] Succès pour $userIdentifier');
  }

  static void logSignInError(String error) {
    print('❌ [Apple Sign In] Erreur - $error');
  }

  static void logCredentialState(String userIdentifier, CredentialState state) {
    print('🔍 [Apple Sign In] État des credentials pour $userIdentifier: $state');
  }
}

class AppleSignInService {
  static const String _keyUserIdentifier = 'apple_user_identifier';
  static const String _keyFirstName = 'apple_first_name';
  static const String _keyLastName = 'apple_last_name';

  /// Vérifier la disponibilité de Sign in with Apple
  Future<bool> isAvailable() async {
    try {
      AppleSignInLogger.logSignInAttempt();
      final available = await SignInWithApple.isAvailable();
      print('🍎 [Apple Sign In] Disponibilité: $available');
      return available;
    } catch (e) {
      AppleSignInLogger.logSignInError('Erreur vérification disponibilité: $e');
      return false;
    }
  }

  /// Processus de connexion principal
  Future<AppleSignInCredential?> signIn() async {
    try {
      AppleSignInLogger.logSignInAttempt();
      
      print('🍎 [Apple Sign In] Demande des credentials...');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('🍎 [Apple Sign In] Credentials reçus:');
      print('   - userIdentifier: ${credential.userIdentifier}');
      print('   - email: ${credential.email}');
      print('   - givenName: ${credential.givenName}');
      print('   - familyName: ${credential.familyName}');
      print('   - identityToken: ${credential.identityToken != null ? "présent" : "null"}');
      print('   - authorizationCode: ${credential.authorizationCode != null ? "présent" : "null"}');

      // Sauvegarder les noms si disponibles (première connexion uniquement)
      if (credential.givenName != null && credential.givenName!.isNotEmpty) {
        await _saveUserNames(
          credential.givenName!,
          credential.familyName ?? '',
        );
        print('💾 [Apple Sign In] Noms sauvegardés: ${credential.givenName} ${credential.familyName ?? ""}');
      }

      // Récupérer les noms sauvegardés pour les inclure dans les credentials
      final savedNames = await _getSavedUserNames();
      
      final appleCredential = AppleSignInCredential.fromAppleIDCredential(
        credential,
        savedFirstName: savedNames['firstName'],
        savedLastName: savedNames['lastName'],
      );
      
      final userIdentifier = credential.userIdentifier;
      if (userIdentifier != null) {
        AppleSignInLogger.logSignInSuccess(userIdentifier);
        await saveUserIdentifier(userIdentifier);
      }

      return appleCredential;
    } on SignInWithAppleAuthorizationException catch (e) {
      AppleSignInLogger.logSignInError('SignInWithAppleAuthorizationException: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case AuthorizationErrorCode.canceled:
          throw AppleSignInException(AppleSignInError.canceled, 'Connexion annulée par l\'utilisateur');
        case AuthorizationErrorCode.failed:
          throw AppleSignInException(AppleSignInError.failed, 'Échec de l\'authentification Apple');
        case AuthorizationErrorCode.invalidResponse:
          throw AppleSignInException(AppleSignInError.invalidResponse, 'Réponse Apple invalide');
        case AuthorizationErrorCode.notHandled:
          throw AppleSignInException(AppleSignInError.notHandled, 'Authentification non gérée');
        case AuthorizationErrorCode.unknown:
        default:
          throw AppleSignInException(AppleSignInError.unknown, 'Erreur Apple inconnue: ${e.message}');
      }
    } catch (e) {
      AppleSignInLogger.logSignInError('Erreur inattendue: $e');
      throw AppleSignInException(AppleSignInError.unknown, 'Erreur inattendue: $e');
    }
  }

  /// Sauvegarder les noms utilisateur (première connexion uniquement)
  Future<void> _saveUserNames(String firstName, String lastName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyFirstName, firstName);
      await prefs.setString(_keyLastName, lastName);
    } catch (e) {
      AppleSignInLogger.logSignInError('Erreur sauvegarde noms: $e');
    }
  }

  /// Récupérer les noms sauvegardés
  Future<Map<String, String?>> _getSavedUserNames() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return {
        'firstName': prefs.getString(_keyFirstName),
        'lastName': prefs.getString(_keyLastName),
      };
    } catch (e) {
      AppleSignInLogger.logSignInError('Erreur récupération noms: $e');
      return {'firstName': null, 'lastName': null};
    }
  }

  /// Sauvegarder l'identifiant utilisateur
  Future<void> saveUserIdentifier(String identifier) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUserIdentifier, identifier);
      print('💾 [Apple Sign In] Identifiant utilisateur sauvegardé: $identifier');
    } catch (e) {
      AppleSignInLogger.logSignInError('Erreur sauvegarde identifiant: $e');
    }
  }

  /// Récupérer l'identifiant sauvegardé
  Future<String?> getSavedUserIdentifier() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final identifier = prefs.getString(_keyUserIdentifier);
      print('📱 [Apple Sign In] Identifiant récupéré: ${identifier ?? "aucun"}');
      return identifier;
    } catch (e) {
      AppleSignInLogger.logSignInError('Erreur récupération identifiant: $e');
      return null;
    }
  }

  /// Vérifier le statut de l'authentification
  Future<bool> checkCredentialState() async {
    try {
      final userIdentifier = await getSavedUserIdentifier();
      if (userIdentifier == null) {
        print('🔍 [Apple Sign In] Aucun identifiant sauvegardé');
        return false;
      }

      print('🔍 [Apple Sign In] Vérification de l\'état des credentials...');
      final state = await SignInWithApple.getCredentialState(userIdentifier);
      AppleSignInLogger.logCredentialState(userIdentifier, state);
      
      return state == CredentialState.authorized;
    } catch (e) {
      AppleSignInLogger.logSignInError('Erreur vérification état: $e');
      return false;
    }
  }

  /// Nettoyer les données Apple Sign-In (déconnexion)
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserIdentifier);
      await prefs.remove(_keyFirstName);
      await prefs.remove(_keyLastName);
      print('🚪 [Apple Sign In] Données de connexion supprimées');
    } catch (e) {
      AppleSignInLogger.logSignInError('Erreur déconnexion: $e');
    }
  }

  /// Vérifier si l'utilisateur est connecté avec Apple
  Future<bool> isSignedIn() async {
    final identifier = await getSavedUserIdentifier();
    if (identifier == null) return false;
    
    return await checkCredentialState();
  }
}