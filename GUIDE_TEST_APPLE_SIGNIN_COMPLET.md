# 🧪 Guide de Test Apple Sign-In Complet

## Implémentation terminée selon votre guide

### ✅ Ce qui a été implémenté

1. **Modèle AppleSignInCredential** - Selon vos spécifications
2. **Service AppleSignInService** - Avec logging détaillé et gestion d'erreurs
3. **Widget AppleSignInButton** - Bouton officiel Apple + fallback
4. **Intégration AuthService** - Authentification backend selon vos endpoints
5. **Mise à jour des écrans** - Login et Register avec nouveaux boutons
6. **Gestion des erreurs** - Exceptions typées et messages localisés

### 📱 Configuration requise

#### Apple Developer Console ✅
- [x] App ID créé : `com.naara.futela`
- [x] Sign In with Apple activé
- [x] Clé Sign In with Apple créée (Key ID: 3UWP52AHCF)

#### Xcode (à finaliser)
- [ ] Capability "Sign In with Apple" ajoutée au target Runner
- [ ] Bundle ID vérifié : `com.naara.futela`
- [ ] Provisioning profile mis à jour

#### Backend (à implémenter)
- [ ] Endpoint `POST /auth/apple/signin`
- [ ] Validation JWT avec clé Apple
- [ ] Gestion des utilisateurs Apple

## Test étape par étape

### 1. Préparation
```bash
# Nettoyer et rebuilder
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### 2. Compilation iOS
```bash
# Compiler sur appareil physique
flutter run --release --verbose
```

### 3. Test de l'interface

#### Écran de connexion
1. Ouvrir l'écran de connexion
2. Vérifier que le bouton "Continuer avec Apple" est visible (iOS uniquement)
3. Le bouton doit utiliser le style officiel Apple

#### Écran d'inscription  
1. Ouvrir l'écran d'inscription
2. Vérifier que le bouton "S'inscrire avec Apple" est visible (iOS uniquement)
3. Accepter les conditions d'utilisation

### 4. Test du flux d'authentification

#### Clic sur le bouton Apple
```
🖱️ [UI] Bouton Apple Sign-In cliqué
🔄 [AuthProvider] Début signInWithApple
🔄 [AuthProvider] Appel AuthService.signInWithApple()
🍎 [AuthService] Début de l'authentification Apple
🍎 [Apple Sign In] Tentative de connexion
🍎 [Apple Sign In] Disponibilité: true
🍎 [Apple Sign In] Demande des credentials...
```

#### Succès attendu
```
🍎 [Apple Sign In] Credentials reçus:
   - userIdentifier: 001234.567890abcdef
   - email: user@privaterelay.appleid.com
   - givenName: John
   - familyName: Doe
   - identityToken: présent
   - authorizationCode: présent
✅ [Apple Sign In] Succès pour 001234.567890abcdef
💾 [Apple Sign In] Identifiant utilisateur sauvegardé
🌐 [AuthService] Authentification backend avec Apple credentials
```

### 5. Diagnostic des erreurs

#### Erreur 1000 (Capability manquante)
```
❌ [Apple Sign In] SignInWithAppleAuthorizationException: AuthorizationErrorCode.unknown - The operation couldn't be completed. (com.apple.AuthenticationServices.AuthorizationError error 1000.)
```
**Solution :** Ajouter la capability dans Xcode

#### Service non disponible
```
❌ [Apple Sign In] Service non disponible sur cet appareil
```
**Solution :** Tester sur appareil physique iOS 13+

#### Tokens manquants
```
❌ [AuthService] Tokens Apple manquants - vérifiez la configuration Apple Developer
```
**Solution :** Vérifier la configuration Apple Developer Console

#### Erreur backend
```
❌ [AuthService] Erreur réseau: DioException
   - Status: 404
   - Data: {"error": "Endpoint not found"}
```
**Solution :** Implémenter l'endpoint `/auth/apple/signin`

## Endpoints backend à implémenter

### POST /auth/apple/signin
```json
{
  "identity_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
  "authorization_code": "c1234567890abcdef...",
  "user_identifier": "001234.567890abcdef...",
  "email": "user@privaterelay.appleid.com",
  "given_name": "John",
  "family_name": "Doe"
}
```

### Réponse attendue
```json
{
  "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
  "refreshToken": "abc123def456...",
  "sessionId": "019d6900-1111-7aef-bcf2-f6c19eb05379",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

## Validation côté serveur

### Étapes requises
1. **Décoder l'identity_token** (JWT Apple)
2. **Vérifier la signature** avec les clés publiques Apple
3. **Valider l'audience** (doit être votre Bundle ID)
4. **Vérifier l'expiration** du token
5. **Créer/mettre à jour l'utilisateur** avec user_identifier
6. **Retourner les tokens** de votre application

### Clés publiques Apple
- URL : `https://appleid.apple.com/auth/keys`
- Algorithme : RS256
- Audience : `com.naara.futela`

## Checklist de validation finale

### Configuration ✅
- [x] Modèles de données implémentés
- [x] Service Apple Sign-In créé
- [x] Widget bouton Apple créé
- [x] Intégration dans les écrans
- [x] Logging détaillé ajouté
- [x] Gestion d'erreurs complète

### Tests à effectuer
- [ ] Compilation sans erreurs
- [ ] Bouton visible sur iOS uniquement
- [ ] Flux d'authentification Apple
- [ ] Gestion des erreurs utilisateur
- [ ] Sauvegarde des credentials
- [ ] Déconnexion Apple

### Backend requis
- [ ] Endpoint `/auth/apple/signin`
- [ ] Validation JWT Apple
- [ ] Gestion utilisateurs Apple
- [ ] Tests avec Postman/curl

Une fois la capability ajoutée dans Xcode et le backend implémenté, Apple Sign-In fonctionnera parfaitement selon votre guide ! 🍎✨

## Commandes de test

```bash
# Voir les logs détaillés
flutter run --verbose | grep -E "(Apple|🍎|🌐|🔄|🖱️)"

# Test sur appareil iOS
flutter run --release

# Debug des erreurs
flutter logs | grep -i error
```