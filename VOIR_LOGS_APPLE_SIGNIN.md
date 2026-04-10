# 📊 Voir les logs Apple Sign-In dans le terminal

## Logs ajoutés

J'ai ajouté des logs détaillés à tous les niveaux :

### 🖱️ Interface utilisateur
- Clic sur le bouton Apple Sign-In
- Vérification des conditions d'utilisation
- Résultat de l'authentification

### 🔄 AuthProvider
- Début et fin du processus d'authentification
- Sauvegarde des tokens
- Récupération du profil utilisateur

### 🍎 AuthService (Apple Sign-In)
- Vérification de la disponibilité d'Apple Sign-In
- Demande des credentials Apple
- Détails des credentials reçus
- Erreurs spécifiques Apple

### 🌐 API Backend
- Préparation de la requête
- Données envoyées au backend
- Réponse du serveur
- Erreurs réseau

## Comment voir les logs

### 1. Lancer l'app avec logs détaillés
```bash
flutter run --verbose
```

### 2. Ou utiliser flutter logs
```bash
# Dans un terminal séparé
flutter logs
```

### 3. Filtrer les logs Apple
```bash
flutter logs | grep -E "(Apple|🍎|🌐|🔄|🖱️)"
```

## Types de logs à surveiller

### ✅ Logs de succès
```
🖱️ [UI] Bouton Apple Sign-In cliqué
🔄 [AuthProvider] Début signInWithApple
🍎 [Apple Sign-In] Début de l'authentification
🍎 [Apple Sign-In] Vérification de la disponibilité...
🍎 [Apple Sign-In] Disponible: true
🍎 [Apple Sign-In] Demande des credentials Apple...
🍎 [Apple Sign-In] Credentials reçus:
🌐 [Apple API] Préparation de la requête backend...
✅ [Apple API] Authentification réussie
✅ [AuthProvider] Connexion Apple réussie
```

### ❌ Logs d'erreur à analyser
```
❌ [Apple Sign-In] Service non disponible sur cet appareil
❌ [Apple Sign-In] identityToken manquant
❌ [Apple Sign-In] SignInWithAppleAuthorizationException:
❌ [Apple API] DioException:
❌ [AuthProvider] Erreur signInWithApple:
```

## Diagnostic selon les logs

### Si vous voyez "Service non disponible"
- Tester sur appareil physique iOS 13+
- Vérifier qu'un Apple ID est configuré

### Si vous voyez "SignInWithAppleAuthorizationException"
- Code 1000 = Capability manquante ou App ID incorrect
- Code 1001 = Utilisateur a annulé
- Code 1004 = Réponse invalide

### Si vous voyez "identityToken manquant"
- Problème de configuration Apple Developer Console
- Bundle ID incorrect

### Si vous voyez "DioException"
- Problème de connexion réseau
- Endpoint backend non implémenté
- Erreur serveur

## Test avec logs

1. **Compiler l'app :**
   ```bash
   flutter run --verbose
   ```

2. **Cliquer sur "Continuer avec Apple"**

3. **Observer les logs dans le terminal**

4. **Copier les logs d'erreur** pour diagnostic

## Exemple de logs complets

### Succès complet
```
🖱️ [Login UI] Bouton Apple Sign-In cliqué
🔄 [AuthProvider] Début signInWithApple
🔄 [AuthProvider] Appel AuthService.signInWithApple()
🍎 [Apple Sign-In] Début de l'authentification
🍎 [Apple Sign-In] Vérification de la disponibilité...
🍎 [Apple Sign-In] Disponible: true
🍎 [Apple Sign-In] Demande des credentials Apple...
🍎 [Apple Sign-In] Credentials reçus:
   - userIdentifier: 001234.567890abcdef
   - email: user@privaterelay.appleid.com
   - givenName: John
   - familyName: Doe
   - identityToken: présent (1234 chars)
   - authorizationCode: présent (567 chars)
🍎 [Apple Sign-In] Appel de l'API backend...
🌐 [Apple API] Préparation de la requête backend...
🌐 [Apple API] Données de la requête:
   - identityToken: présent
   - authorizationCode: présent
   - firstName: John
   - lastName: Doe
🌐 [Apple API] Envoi de la requête POST /api/auth/apple...
🌐 [Apple API] Réponse reçue:
   - Status Code: 201
   - Data: {accessToken: ..., refreshToken: ...}
✅ [Apple API] Authentification réussie
🔄 [AuthProvider] Réponse reçue, sauvegarde des tokens...
🔄 [AuthProvider] Récupération du profil utilisateur...
✅ [AuthProvider] Connexion Apple réussie
✅ [Login UI] Connexion Apple réussie, navigation vers MainNavigation
```

Maintenant, lancez l'app et testez Apple Sign-In. Les logs détaillés vous diront exactement où est le problème ! 🔍