# Configuration Google Sign-In pour iOS - Guide Complet

## Étapes à suivre pour activer la connexion Gmail sur iOS

### 1. Créer un client OAuth iOS dans Google Cloud Console

1. **Accédez à Google Cloud Console** : https://console.cloud.google.com/
2. **Sélectionnez votre projet** Futela
3. **Naviguez vers** : APIs & Services > Credentials
4. **Cliquez sur** "Create Credentials" > "OAuth 2.0 Client IDs"
5. **Sélectionnez** "iOS" comme type d'application
6. **Entrez le Bundle ID** : `com.futelaapp.mobile`
7. **Notez le Client ID iOS** généré (format : `XXXXXXXXX-XXXXXXX.apps.googleusercontent.com`)

### 2. Mettre à jour la configuration Dart

Dans le fichier `lib/config/google_oauth_config.dart`, remplacez :

```dart
const String kGoogleIosClientId = 'VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com';
```

Par votre vrai Client ID iOS obtenu à l'étape 1.

### 3. Mettre à jour le fichier Info.plist iOS

Dans le fichier `ios/Runner/Info.plist`, vous devez :

#### A. Ajouter le GIDClientID
Remplacez :
```xml
<key>GIDClientID</key>
<string>VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com</string>
```

Par votre vrai Client ID iOS.

#### B. Mettre à jour le CFBundleURLSchemes
Remplacez :
```xml
<string>com.googleusercontent.apps.VOTRE_CLIENT_ID_IOS_SANS_SUFFIX</string>
```

Par le REVERSED_CLIENT_ID de votre client iOS.

**Exemple** : Si votre Client ID iOS est `123456789-abc123def.apps.googleusercontent.com`
Alors le scheme sera : `com.googleusercontent.apps.123456789-abc123def`

### 4. Tester la configuration

1. **Nettoyez et rebuilder** le projet iOS :
   ```bash
   cd ios
   rm -rf Pods Podfile.lock
   pod install
   cd ..
   flutter clean
   flutter pub get
   ```

2. **Lancez l'app** sur un simulateur iOS ou un appareil physique

3. **Testez la connexion Google** depuis l'écran de connexion

### 5. Vérification des erreurs communes

| Erreur | Solution |
|--------|----------|
| "Custom scheme URIs are not allowed for WEB client" | Vérifiez que vous utilisez le Client ID **iOS** et non Web dans `GIDClientID` |
| "Audience JWT incorrecte côté API" | Vérifiez que `GIDServerClientID` utilise bien le Client ID **Web** |
| "Problème de redirect / scheme" | Vérifiez que le `CFBundleURLSchemes` correspond au REVERSED_CLIENT_ID du client **iOS** |
| "idToken null ou vide" | Vérifiez que tous les Client IDs sont corrects et que le Bundle ID correspond |

### 6. Configuration actuelle

- **Bundle ID iOS** : `com.futelaapp.mobile`
- **Client Web ID** (déjà configuré) : `474613582555-etdekl4un7r2r11u08h1jv2jelg3br0q.apps.googleusercontent.com`
- **Client iOS ID** : À configurer après création
- **Package Google Sign-In** : ✅ Déjà installé (`google_sign_in: ^6.2.2`)

### 7. Fichiers modifiés

- ✅ `lib/config/google_oauth_config.dart` - Placeholder ajouté pour Client ID iOS
- ✅ `ios/Runner/Info.plist` - Configuration GIDClientID et CFBundleURLSchemes préparée
- ✅ `lib/services/auth_service.dart` - Logique déjà implémentée pour iOS

### Notes importantes

- Le Client ID **Web** (`GIDServerClientID`) est utilisé pour valider l'`id_token` côté backend
- Le Client ID **iOS** (`GIDClientID`) est utilisé pour l'authentification native iOS
- Les deux sont nécessaires pour un fonctionnement optimal
- Le Bundle ID doit correspondre exactement à celui configuré dans Xcode : `com.futelaapp.mobile`

Une fois ces étapes complétées, la connexion Gmail fonctionnera parfaitement sur iOS !