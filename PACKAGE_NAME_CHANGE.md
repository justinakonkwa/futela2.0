# Changement du Nom de Package - Résolution des Conflits

## Problème Résolu

L'application avait des conflits de nom de package avec Google Play Store :
- **Ancien package** : `com.naara.futela`
- **Nouveau package** : `com.futelaapp.mobile`

## Fichiers Modifiés

### Android
- `android/app/build.gradle.kts` : Mise à jour du `namespace` et `applicationId`
- `android/app/src/main/kotlin/com/futelaapp/mobile/MainActivity.kt` : Nouveau package et structure de dossiers
- Suppression de l'ancienne structure : `android/app/src/main/kotlin/com/naara/`

### iOS
- `ios/Runner.xcodeproj/project.pbxproj` : Mise à jour du `PRODUCT_BUNDLE_IDENTIFIER`

### Documentation
- `lib/config/google_oauth_config.dart`
- `GOOGLE_SIGNIN_SETUP.md`
- `android/GOOGLE_PLAY_SOLUTIONS.md`
- `android/get-sha-fingerprints.sh`
- `GOOGLE_SIGNIN_PLAYSTORE.md`
- `GOOGLE_SIGNIN_IOS.md`
- `android/create-keystore.sh`

## Actions Requises Après le Changement

### 1. Google Cloud Console
Mettre à jour les clients OAuth avec le nouveau package :
- **Android** : `com.futelaapp.mobile`
- **iOS** : `com.futelaapp.mobile`

### 2. Keystore Android
Si vous utilisez un keystore existant, aucune action requise.
Si vous créez un nouveau keystore, utilisez le script mis à jour.

### 3. Google Play Console
Créer une nouvelle application avec le nouveau nom de package `com.futelaapp.mobile`.

### 4. Tests
Tester l'application sur les deux plateformes pour s'assurer que :
- L'authentification Google fonctionne
- Les permissions sont correctement demandées
- L'application se lance sans erreur

## Commandes de Vérification

```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get

# Vérifier la compilation Android
flutter build apk --debug

# Vérifier la compilation iOS (sur macOS)
flutter build ios --debug --no-codesign
```

## Notes Importantes

- Le changement de package nécessite une nouvelle soumission sur Google Play
- Les utilisateurs existants ne pourront pas mettre à jour automatiquement
- Tous les services Google (Maps, Sign-In) doivent être reconfigurés
- Les certificats de signature doivent correspondre au nouveau package