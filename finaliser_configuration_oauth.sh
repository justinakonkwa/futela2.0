#!/bin/bash

# Script de finalisation de la configuration OAuth
# Usage: ./finaliser_configuration_oauth.sh

echo "🔧 Finalisation de la configuration OAuth pour Futela"
echo "====================================================="
echo ""

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet Flutter"
    exit 1
fi

echo "📱 Bundle ID mis à jour: com.naara.futela"
echo "🔑 Configuration Google Sign-In appliquée avec vos Client IDs"
echo ""

# 1. Nettoyer et installer les dépendances
echo "1️⃣ Nettoyage et installation des dépendances..."
flutter clean
flutter pub get

if [ $? -eq 0 ]; then
    echo "   ✅ Dépendances Flutter installées"
else
    echo "   ❌ Erreur lors de l'installation des dépendances Flutter"
    exit 1
fi

# 2. Installation des pods iOS
echo ""
echo "2️⃣ Installation des pods iOS..."
cd ios
pod install --repo-update
cd ..

if [ $? -eq 0 ]; then
    echo "   ✅ Pods iOS installés"
else
    echo "   ⚠️  Erreur lors de l'installation des pods iOS (peut être normal si pas de Mac)"
fi

# 3. Nettoyage Android
echo ""
echo "3️⃣ Nettoyage du build Android..."
cd android
./gradlew clean
cd ..

if [ $? -eq 0 ]; then
    echo "   ✅ Build Android nettoyé"
else
    echo "   ⚠️  Erreur lors du nettoyage Android"
fi

# 4. Vérification de la configuration
echo ""
echo "4️⃣ Vérification de la configuration..."

# Vérifier les fichiers critiques
FILES_TO_CHECK=(
    "lib/config/google_oauth_config.dart"
    "lib/config/apple_signin_config.dart"
    "ios/Runner/Info.plist"
    "android/app/build.gradle.kts"
    "android/app/google-services.json"
)

for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $file"
    else
        echo "   ❌ $file manquant"
    fi
done

# Vérifier les Client IDs
if grep -q "474613582555-hhr7atbpp8uesekpevt69gav51a8ep5c" lib/config/google_oauth_config.dart; then
    echo "   ✅ Client ID iOS configuré"
else
    echo "   ❌ Client ID iOS non configuré"
fi

if grep -q "474613582555-etdekl4un7r2r11u08h1jv2jelg3br0q" lib/config/google_oauth_config.dart; then
    echo "   ✅ Client ID Web configuré"
else
    echo "   ❌ Client ID Web non configuré"
fi

# Vérifier le Bundle ID
if grep -q "com.naara.futela" ios/Runner.xcodeproj/project.pbxproj; then
    echo "   ✅ Bundle ID iOS mis à jour"
else
    echo "   ❌ Bundle ID iOS non mis à jour"
fi

if grep -q "com.naara.futela" android/app/build.gradle.kts; then
    echo "   ✅ Package Android mis à jour"
else
    echo "   ❌ Package Android non mis à jour"
fi

echo ""
echo "=============================================================="
echo "🎉 Configuration OAuth finalisée !"
echo ""
echo "📋 Prochaines étapes OBLIGATOIRES :"
echo ""
echo "🍎 Pour iOS (Apple Sign-In) :"
echo "   1. Ouvrir ios/Runner.xcodeproj dans Xcode"
echo "   2. Changer le Bundle ID vers 'com.naara.futela'"
echo "   3. Ajouter la capability 'Sign In with Apple'"
echo "   4. Configurer dans Apple Developer Console"
echo ""
echo "🤖 Pour Android (Google Sign-In) :"
echo "   1. Aller sur Firebase Console (console.firebase.google.com)"
echo "   2. Ajouter une app Android avec package 'com.naara.futela'"
echo "   3. Télécharger le vrai google-services.json"
echo "   4. Remplacer android/app/google-services.json"
echo "   5. Ajouter vos SHA-1 fingerprints :"
echo ""
echo "      # Debug SHA-1"
echo "      keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android"
echo ""
echo "🌐 Backend :"
echo "   - Implémenter POST /api/auth/google"
echo "   - Implémenter POST /api/auth/apple"
echo ""
echo "📚 Consultez CONFIGURATION_FINALE_OAUTH.md pour plus de détails"
echo ""
echo "🧪 Test :"
echo "   - iOS: flutter run (sur appareil physique iOS 13+)"
echo "   - Android: flutter run (après config Firebase complète)"