# Configuration pour la Release Android

Ce guide vous explique comment configurer votre application Futela pour une build de release Android.

## 📋 Étapes de configuration

### 1. Créer un keystore pour la signature

Pour publier sur le Google Play Store, vous devez signer votre application avec un certificat numérique.

#### Option A : Utiliser le script automatique (recommandé)

```bash
cd android
./create-keystore.sh
```

Le script vous guidera à travers la création du keystore et vous donnera les informations nécessaires pour créer le fichier `key.properties`.

#### Option B : Créer manuellement

Sur macOS ou Linux :

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
    -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 \
    -alias upload
```

Sur Windows (PowerShell) :

```powershell
keytool -genkey -v -keystore $env:USERPROFILE\upload-keystore.jks `
    -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 `
    -alias upload
```

**⚠️ IMPORTANT :** Gardez le fichier keystore privé et ne le commitez JAMAIS dans le contrôle de version !

### 2. Créer le fichier key.properties

Créez un fichier `android/key.properties` avec le contenu suivant :

```properties
storePassword=<votre-mot-de-passe-keystore>
keyPassword=<votre-mot-de-passe-cle>
keyAlias=upload
storeFile=<chemin-vers-votre-keystore.jks>
```

**Exemples de chemins :**
- macOS/Linux : `storeFile=/Users/votre-nom/upload-keystore.jks`
- Windows : `storeFile=C:\\Users\\votre-nom\\upload-keystore.jks`

**⚠️ IMPORTANT :** Ne commitez JAMAIS `key.properties` dans le contrôle de version ! Ce fichier est déjà dans `.gitignore`.

### 3. Vérifier la configuration

La configuration de signature est déjà configurée dans `android/app/build.gradle.kts`. Si le fichier `key.properties` existe, il sera automatiquement utilisé pour signer les builds de release.

## 🏗️ Construire l'application pour la release

### Construire un App Bundle (recommandé pour Google Play)

```bash
flutter build appbundle
```

Le fichier `.aab` sera créé dans `build/app/outputs/bundle/release/app.aab`.

### Construire un APK (pour d'autres stores ou tests)

Pour créer des APKs séparés par architecture (recommandé) :

```bash
flutter build apk --split-per-abi
```

Cela créera trois fichiers APK :
- `build/app/outputs/apk/release/app-armeabi-v7a-release.apk` (ARM 32-bit)
- `build/app/outputs/apk/release/app-arm64-v8a-release.apk` (ARM 64-bit)
- `build/app/outputs/apk/release/app-x86_64-release.apk` (x86 64-bit)

Pour créer un APK "fat" (toutes les architectures) :

```bash
flutter build apk
```

## 📱 Installer l'APK sur un appareil

```bash
flutter install
```

## 📦 Publier sur Google Play Store

Pour des instructions détaillées sur la publication, consultez la [documentation Google Play](https://developer.android.com/studio/publish).

## ✅ Vérifications avant la publication

- [ ] L'icône de lanceur est configurée (déjà fait via `flutter_launcher_icons`)
- [ ] Material Components est activé (déjà configuré)
- [ ] Le keystore est créé et sécurisé
- [ ] Le fichier `key.properties` est créé (et non commité)
- [ ] Le numéro de version est mis à jour dans `pubspec.yaml`
- [ ] L'application a été testée en mode release
- [ ] Les permissions dans `AndroidManifest.xml` sont correctes

## 🔄 Mettre à jour le numéro de version

Pour mettre à jour le numéro de version, modifiez `pubspec.yaml` :

```yaml
version: 1.0.0+1
```

Le format est `version+buildNumber` :
- `version` : version visible par l'utilisateur (ex: 1.0.0)
- `buildNumber` : numéro de build interne (ex: 1)

## 🛠️ Dépannage

### Erreur : "key.properties not found"
- Assurez-vous que le fichier `android/key.properties` existe
- Vérifiez que le chemin vers le keystore est correct

### Erreur : "Keystore was tampered with, or password was incorrect"
- Vérifiez que les mots de passe dans `key.properties` sont corrects
- Vérifiez que le chemin vers le keystore est correct

### L'application n'est pas signée
- Vérifiez que `key.properties` existe et contient les bonnes valeurs
- Exécutez `flutter clean` puis reconstruisez

## 📚 Ressources

- [Documentation Flutter - Build and release an Android app](https://docs.flutter.dev/deployment/android)
- [Documentation Android - Sign your app](https://developer.android.com/studio/publish/app-signing)
- [Google Play Console](https://play.google.com/console)

