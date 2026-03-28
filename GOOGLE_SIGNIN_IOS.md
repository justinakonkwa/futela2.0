# Google Sign-In — iOS (Futela)

Complément du flux décrit dans `GOOGLE_SIGNIN_SETUP.md` (aligné SuperApp).

## 1. Prérequis Google Cloud

- Créer un client OAuth **iOS** avec le **Bundle ID** : `com.futelaapp.mobile` (identique à Xcode).
- Noter le **Client ID iOS** (forme `xxxx.apps.googleusercontent.com`).

## 2. `ios/Runner/Info.plist`

### Obligatoire (déjà présent dans le projet)

- **`GIDServerClientID`** : le **Client ID Web** (identique à `kGoogleWebClientId` dans `lib/config/google_oauth_config.dart`).

### Après création du client iOS

- **`GIDClientID`** : le **Client ID iOS** (pas le Web — sinon erreurs du type *« Custom scheme URIs are not allowed for WEB client »*).

- **`CFBundleURLTypes` → CFBundleURLSchemes** : schéma **inversé du Client ID iOS**  
  Ex. si Client ID iOS = `123456789-abc.apps.googleusercontent.com`  
  → scheme = `com.googleusercontent.apps.123456789-abc`

## 3. Code Dart

Dans `lib/config/google_oauth_config.dart`, renseigner :

```dart
const String kGoogleIosClientId = 'VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com';
```

`AuthService` passe `clientId: kGoogleIosClientId` à `GoogleSignIn` **uniquement sur iOS** lorsque cette constante est non vide.

## 4. Erreurs fréquentes

| Symptôme | Piste |
|----------|--------|
| Audience JWT incorrecte côté API | Vérifier `serverClientId` / Web client + `GIDServerClientID`. |
| Problème de redirect / scheme | Client **iOS** + `GIDClientID` + URL scheme **iOS** (pas Web). |
