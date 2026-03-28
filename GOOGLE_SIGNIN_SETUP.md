# Connexion Google (Futela)

L’app suit le flux **SuperApp** : `google_sign_in` → JWT **`id_token`** → **POST `/api/auth/google`**.

- **Constantes** : `lib/config/google_oauth_config.dart` (`kGoogleWebClientId`, `kGoogleIosClientId`, `kGoogleLoginPath`).
- **Corps API** : **`{ "idToken": "<jwt>" }`** (requis par l’API Futela).
- **iOS** : détails `GOOGLE_SIGNIN_IOS.md` · **Play Store / SHA-1** : `GOOGLE_SIGNIN_PLAYSTORE.md`.

Le **client secret** Web reste uniquement côté serveur (jamais dans l’app).

## Fichier `ANDROIDclient_secret_*.json` (téléchargé depuis Google Cloud)

Ce JSON décrit un client OAuth **Android / application installée** (`installed` dans le fichier). Exemple de contenu utile :

| Champ | Rôle |
|--------|------|
| `project_id` | Projet Google Cloud (ex. `futela`) |
| `installed.client_id` | ID client **Android** — lié au **package** `com.futelaapp.mobile` et aux empreintes **SHA-1** dans la console |

**Ce qu’il ne faut pas faire**

- Ne **pas** remplacer `default_web_client_id` (Android) ni `_googleServerClientId` (Dart) par ce `client_id` Android : pour l’`idToken` serveur, il faut le client **Web**.
- Ne **pas** commiter ce JSON s’il contient un `client_secret` (certaines fiches « client OAuth » en ont un) — le dépôt ignore les motifs `ANDROIDclient_secret*.json` et `*client_secret*.json`.

**Ce qu’il faut faire**

1. Dans [Credentials](https://console.cloud.google.com/apis/credentials), ouvrir le client **Android** dont l’ID correspond à ton JSON.
2. Vérifier le nom de package **`com.futelaapp.mobile`** et ajouter le **SHA-1** debug (et release) : `cd android && ./gradlew signingReport`.
3. Garder un client **Web** dans le **même** projet, et utiliser **son** ID dans le code (`AuthService` + `strings.xml`) — c’est celui utilisé pour signer l’`idToken` côté API.

Les deux clients (Web + Android) coexistent : Android pour le flux natif sur l’appareil, Web pour le jeton envoyé au backend.

## Déjà côté code

| Fichier | Rôle |
|--------|------|
| `lib/services/auth_service.dart` | `GoogleSignIn(clientId` iOS si défini, `serverClientId` Web), POST `{ "idToken" }` |
| `lib/config/google_oauth_config.dart` | IDs Web / iOS + chemin API |
| `lib/providers/auth_provider.dart` | `signInWithGoogle()`, déconnexion Google au `logout()` |
| `lib/screens/auth/login_screen.dart` | Bouton **Continuer avec Google** |
| `lib/screens/auth/register_screen.dart` | Bouton **S’inscrire avec Google** (après acceptation des CGU) |
| `android/app/src/main/res/values/strings.xml` | `default_web_client_id` (aligné sur le client Web) |
| `ios/Runner/Info.plist` | `GIDServerClientID` (Web) + `CFBundleURLTypes` (idéalement schéma client **iOS**) |

## 1. Google Cloud Console

1. [APIs & Services → Credentials](https://console.cloud.google.com/apis/credentials)
2. **Écran de consentement OAuth** configuré (type externe ou interne).

### Client de type **Application Web** (obligatoire pour l’`idToken` serveur)

- Créer un ID client **Web**.
- Copier le **ID client** → c’est `kGoogleWebClientId` dans `google_oauth_config.dart`, `serverClientId` dans `GoogleSignIn`, `GIDServerClientID` (iOS), **et** `default_web_client_id` dans `strings.xml`.
- Le backend vérifie ce jeton avec ce même projet Google.

### Client **Android**

- Type **Android**, nom du package : `com.futelaapp.mobile`
- Empreinte **SHA-1** du keystore :
  - Debug : `cd android && ./gradlew signingReport` (ou `keytool -list -v -keystore ~/.android/debug.keystore`)
  - Release : SHA-1 du keystore défini dans `android/key.properties`

### Client **iOS**

- Type **iOS**, Bundle ID : `com.futelaapp.mobile`
- Dans **Info.plist**, remplacer le schéma d’URL par le **REVERSED_CLIENT_ID** de **ce** client iOS (pas forcément le même que pour le client Web) :

  Si l’ID client iOS est `123456789-abcdef.apps.googleusercontent.com`, le schéma est :

  `com.googleusercontent.apps.123456789-abcdef`

Mettre à jour la valeur dans :

```xml
<key>CFBundleURLSchemes</key>
<array>
  <string>com.googleusercontent.apps.VOTRE-ID-IOS-INVERSÉ</string>
</array>
```

Si tu utilises le **même** identifiant que le client Web (peu courant), le schéma actuel du projet peut suffire ; en cas d’erreur « wrong client » ou échec sur iOS, crée bien un client **iOS** dédié et mets son schéma inversé.

## 2. Backend

- Endpoint : **POST `/api/auth/google`** — body JSON **`{ "idToken": "..." }`** (champ requis).
- Réponse attendue (alignée avec `AuthResponse`) : `accessToken`, `refreshToken`, etc.

## 3. Vérifications rapides

- **Android** : SHA-1 enregistré pour le bon keystore (debug vs release).
- **iOS** : après changement de `Info.plist`, `cd ios && pod install`, rebuild Xcode.
- **idToken null** : presque toujours `serverClientId` (client Web) manquant / faux, ou config Android/iOS incomplète.

## 4. Synchroniser les IDs après rotation

Si tu changes le client Web dans la console, mets à jour :

1. `lib/config/google_oauth_config.dart` → `kGoogleWebClientId`
2. `ios/Runner/Info.plist` → `GIDServerClientID`
3. `android/app/src/main/res/values/strings.xml` → `default_web_client_id`
