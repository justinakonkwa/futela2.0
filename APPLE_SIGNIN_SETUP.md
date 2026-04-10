# Configuration Apple Sign-In pour iOS - Guide Complet

## Prérequis

### 1. Apple Developer Account
- Compte Apple Developer actif (99$/an)
- Accès à l'Apple Developer Console

### 2. Bundle ID configuré
- Bundle ID : `com.futelaapp.mobile`
- Doit correspondre exactement à celui dans Xcode

## Configuration Apple Developer Console

### Étape 1 : Activer Apple Sign-In pour votre App ID

1. **Connectez-vous** à [Apple Developer Console](https://developer.apple.com/)
2. **Allez dans** : Certificates, Identifiers & Profiles > Identifiers
3. **Sélectionnez** votre App ID (`com.futelaapp.mobile`)
4. **Activez** "Sign In with Apple" dans les capabilities
5. **Sauvegardez** les modifications

### Étape 2 : Configurer Xcode

1. **Ouvrez** le projet iOS dans Xcode : `ios/Runner.xcodeproj`
2. **Sélectionnez** le target "Runner"
3. **Allez dans** l'onglet "Signing & Capabilities"
4. **Cliquez** sur "+ Capability"
5. **Ajoutez** "Sign In with Apple"
6. **Vérifiez** que le Bundle Identifier est `com.futelaapp.mobile`

### Étape 3 : Provisioning Profile (si nécessaire)

Si vous utilisez un provisioning profile manuel :
1. **Régénérez** le provisioning profile dans Apple Developer Console
2. **Téléchargez** et installez le nouveau profile
3. **Sélectionnez** le nouveau profile dans Xcode

## Configuration Backend (côté serveur)

### Endpoint requis : POST /api/auth/apple

Le backend doit accepter les données suivantes :

```json
{
  "identityToken": "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...",
  "authorizationCode": "c1234567890abcdef...",
  "userIdentifier": "001234.567890abcdef...",
  "user": {
    "firstName": "John",
    "lastName": "Doe", 
    "email": "john.doe@privaterelay.appleid.com"
  }
}
```

**Notes importantes :**
- `identityToken` : JWT signé par Apple contenant les infos utilisateur
- `authorizationCode` : Code d'autorisation pour les requêtes serveur-à-serveur
- `userIdentifier` : Identifiant unique Apple pour cet utilisateur
- `user` : Informations utilisateur (seulement à la première connexion)

### Validation côté serveur

Le serveur doit :
1. **Valider** l'`identityToken` avec les clés publiques Apple
2. **Vérifier** l'audience (`aud`) = votre Bundle ID
3. **Créer ou connecter** l'utilisateur avec l'`userIdentifier`
4. **Retourner** les tokens d'authentification de votre app

## Configuration actuelle du projet

### ✅ Déjà configuré
- Package `sign_in_with_apple: ^6.1.1` ajouté
- Configuration dans `lib/config/apple_signin_config.dart`
- Méthodes d'authentification dans `AuthService` et `AuthProvider`
- Boutons Apple Sign-In dans les écrans de connexion/inscription (iOS uniquement)
- Configuration Info.plist avec `com.apple.developer.applesignin`

### 🔄 À configurer
- Capability "Sign In with Apple" dans Xcode
- Activation dans Apple Developer Console
- Endpoint backend `/api/auth/apple`

## Test de fonctionnement

### Prérequis pour tester
1. **Appareil iOS physique** (ne fonctionne pas sur simulateur)
2. **iOS 13+** minimum
3. **Compte Apple ID** configuré sur l'appareil
4. **Configuration Apple Developer** terminée

### Étapes de test
1. **Compilez** l'app sur un appareil iOS physique
2. **Ouvrez** l'écran de connexion ou d'inscription
3. **Cliquez** sur "Continuer avec Apple" (visible uniquement sur iOS)
4. **Suivez** le flux d'authentification Apple
5. **Vérifiez** que l'utilisateur est connecté dans l'app

## Erreurs communes

| Erreur | Solution |
|--------|----------|
| "Sign In with Apple is not available" | Vérifiez iOS 13+, appareil physique, capability activée |
| "Invalid client" | Vérifiez Bundle ID dans Apple Developer Console |
| "Invalid request" | Vérifiez la configuration Xcode et le provisioning profile |
| Erreur backend | Vérifiez l'endpoint `/api/auth/apple` et la validation du token |

## Sécurité et bonnes pratiques

### Côté client
- ✅ Validation de disponibilité avant d'afficher le bouton
- ✅ Gestion des erreurs utilisateur
- ✅ Interface conditionnelle (iOS uniquement)

### Côté serveur
- ⚠️ **Obligatoire** : Validation de l'`identityToken` avec les clés Apple
- ⚠️ **Obligatoire** : Vérification de l'audience (Bundle ID)
- ⚠️ **Recommandé** : Stockage sécurisé de l'`userIdentifier`
- ⚠️ **Recommandé** : Gestion des emails Apple Private Relay

## Ressources utiles

- [Apple Sign-In Documentation](https://developer.apple.com/sign-in-with-apple/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/sign-in-with-apple)
- [Package Flutter sign_in_with_apple](https://pub.dev/packages/sign_in_with_apple)

La configuration Apple Sign-In est maintenant prête côté client ! 🍎