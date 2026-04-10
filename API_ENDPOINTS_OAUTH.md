# 📡 Endpoints API OAuth - Spécifications

## Configuration actuelle du client

### Base URL
Le client utilise la configuration définie dans `ApiClient` pour la base URL de l'API.

### Endpoints OAuth implémentés

## 1. Google OAuth

### POST /api/auth/google
**Description :** S'authentifier via Google OAuth. Crée un compte si l'utilisateur n'existe pas, sinon connecte l'utilisateur existant.

#### Corps de la requête
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| idToken | string | Oui | Google ID token from OAuth flow |

#### Réponse 200 - Authentication successful
```json
{
  "accessToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "def50200a8b9c7d6e5f4...",
  "sessionId": "550e8400-e29b-41d4-a716-446655440002",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

#### Implémentation client
- **Méthode :** `AuthService.signInWithGoogle()`
- **Configuration :** `kGoogleLoginPath` dans `google_oauth_config.dart`
- **Gestion :** Automatique via `GoogleSignIn.signIn()`

## 2. Apple Sign In

### POST /api/auth/apple
**Description :** Authentifier via Apple Sign In. Crée le compte à la première connexion.

#### Corps de la requête
```json
{
  "idToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
  "authorizationCode": "c1234567890abcdef...",
  "firstName": "John",
  "lastName": "Doe"
}
```

| Champ | Type | Requis | Description |
|-------|------|--------|-------------|
| idToken | string | Oui | Token d'identité Apple (JWT) obtenu via Sign In with Apple |
| authorizationCode | string | Oui | Code d'autorisation Apple |
| firstName | string | Non | Prénom (requis uniquement à la première connexion) |
| lastName | string | Non | Nom (requis uniquement à la première connexion) |

#### Réponse 201 - Authentification réussie
```json
{
  "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
  "refreshToken": "abc123def456...",
  "sessionId": "019d6900-1111-7aef-bcf2-f6c19eb05379",
  "expiresIn": 3600,
  "refreshExpiresIn": 2592000,
  "tokenType": "Bearer"
}
```

#### Implémentation client
- **Méthode :** `AuthService.signInWithApple()`
- **Configuration :** `kAppleLoginPath` dans `apple_signin_config.dart`
- **Gestion :** Automatique via `SignInWithApple.getAppleIDCredential()`

## Modèle de réponse partagé

### AuthResponse
```dart
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String sessionId;
  final int expiresIn;
  final String tokenType;
  // refreshExpiresIn est optionnel (Apple uniquement)
}
```

## Gestion des erreurs

### Erreurs communes
- **400 Bad Request :** Données invalides
- **401 Unauthorized :** Token invalide ou expiré
- **403 Forbidden :** Accès refusé
- **500 Internal Server Error :** Erreur serveur

### Gestion côté client
```dart
try {
  final authResponse = await _authService.signInWithGoogle();
  // Succès
} catch (e) {
  // Erreur gérée automatiquement avec message localisé
  print('Erreur: ${e.toString()}');
}
```

## Configuration des tokens

### Stockage sécurisé
- **AccessToken :** Stocké dans `SharedPreferences`
- **RefreshToken :** Stocké dans `SharedPreferences`
- **SessionId :** Stocké pour la déconnexion

### Utilisation
- **Authorization Header :** `Bearer ${accessToken}`
- **Refresh automatique :** Géré par `AuthProvider`
- **Expiration :** Basée sur `expiresIn` (secondes)

## Validation côté serveur

### Google OAuth
Le serveur doit :
1. Valider l'`idToken` avec les clés publiques Google
2. Vérifier l'audience (`aud`) = Client ID Web
3. Extraire les informations utilisateur du token
4. Créer ou connecter l'utilisateur

### Apple Sign In
Le serveur doit :
1. Valider l'`identityToken` avec les clés publiques Apple
2. Vérifier l'audience (`aud`) = Bundle ID de l'app
3. Utiliser l'`authorizationCode` pour les requêtes serveur-à-serveur
4. Gérer les informations utilisateur (première connexion uniquement)

## Sécurité

### Côté client
- ✅ Validation de disponibilité des services
- ✅ Gestion des erreurs d'autorisation
- ✅ Stockage sécurisé des tokens
- ✅ Nettoyage automatique à la déconnexion

### Côté serveur (requis)
- ⚠️ **Obligatoire :** Validation des tokens avec les clés publiques
- ⚠️ **Obligatoire :** Vérification de l'audience
- ⚠️ **Recommandé :** Rate limiting sur les endpoints
- ⚠️ **Recommandé :** Logs de sécurité

## Test des endpoints

### Outils recommandés
- **Postman :** Pour tester les endpoints manuellement
- **curl :** Pour les tests en ligne de commande
- **App mobile :** Pour les tests d'intégration complets

### Exemples de test

#### Test Google OAuth
```bash
curl -X POST https://your-api.com/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"idToken": "GOOGLE_ID_TOKEN_HERE"}'
```

#### Test Apple Sign In
```bash
curl -X POST https://your-api.com/api/auth/apple \
  -H "Content-Type: application/json" \
  -d '{
    "idToken": "APPLE_IDENTITY_TOKEN_HERE",
    "authorizationCode": "APPLE_AUTH_CODE_HERE",
    "firstName": "John",
    "lastName": "Doe"
  }'
```

Le client Flutter est maintenant parfaitement aligné avec ces spécifications API ! 🎯