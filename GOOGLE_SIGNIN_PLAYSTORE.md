# Google Sign-In — Play Store (SHA-1)

En **production**, les utilisateurs installent une APK/AAB signée avec la clé **Play App Signing**. Le **SHA-1** du keystore **local** (upload key) n’est pas toujours celui que Google Play utilise pour signer l’app vue par les utilisateurs.

## Où trouver le bon SHA-1

1. [Play Console](https://play.google.com/console) → ton application.
2. **Configuration** → **Signature de l’application** (ou *App integrity* / *App signing*).
3. Copier l’empreinte **SHA-1** du certificat **App signing key** (clé de signature de l’app).

## Google Cloud Console

1. [Credentials](https://console.cloud.google.com/apis/credentials) → ton client OAuth **Android** (package `com.futelaapp.mobile`).
2. Ajouter cette empreinte **SHA-1** (en plus du SHA-1 **debug** pour le développement).

Sans ce SHA-1, la connexion Google peut fonctionner en debug mais échouer avec **DEVELOPER_ERROR** / code **10** pour les builds installés via le Play Store.

## Debug vs release

| Contexte | SHA-1 à enregistrer |
|----------|---------------------|
| `flutter run` (debug) | Keystore debug (`~/.android/debug.keystore`) — `cd android && ./gradlew signingReport` |
| APK/AAB signé upload | Selon ta `key.properties` / keystore upload |
| Utilisateurs finaux (Play) | **App signing key** dans Play Console |
