#!/bin/bash

# Script de configuration Google Sign-In pour iOS
# Usage: ./configure_ios_google_signin.sh "VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com"

if [ $# -eq 0 ]; then
    echo "❌ Erreur: Veuillez fournir le Client ID iOS"
    echo "Usage: $0 \"VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com\""
    echo ""
    echo "Exemple: $0 \"123456789-abc123def.apps.googleusercontent.com\""
    exit 1
fi

CLIENT_ID_IOS="$1"

# Vérifier le format du Client ID
if [[ ! "$CLIENT_ID_IOS" =~ ^[0-9]+-[a-zA-Z0-9]+\.apps\.googleusercontent\.com$ ]]; then
    echo "❌ Erreur: Format de Client ID invalide"
    echo "Le Client ID doit être au format: XXXXXXXXX-XXXXXXX.apps.googleusercontent.com"
    exit 1
fi

# Extraire la partie avant .apps.googleusercontent.com pour le scheme
CLIENT_ID_PREFIX=$(echo "$CLIENT_ID_IOS" | sed 's/\.apps\.googleusercontent\.com$//')
REVERSED_CLIENT_ID="com.googleusercontent.apps.$CLIENT_ID_PREFIX"

echo "🔧 Configuration Google Sign-In pour iOS..."
echo "📱 Client ID iOS: $CLIENT_ID_IOS"
echo "🔗 Reversed Client ID: $REVERSED_CLIENT_ID"
echo ""

# 1. Mettre à jour le fichier Dart
echo "1️⃣ Mise à jour de lib/config/google_oauth_config.dart..."
sed -i.bak "s/const String kGoogleIosClientId = 'VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com';/const String kGoogleIosClientId = '$CLIENT_ID_IOS';/" lib/config/google_oauth_config.dart

if [ $? -eq 0 ]; then
    echo "   ✅ Fichier Dart mis à jour"
    rm lib/config/google_oauth_config.dart.bak
else
    echo "   ❌ Erreur lors de la mise à jour du fichier Dart"
    exit 1
fi

# 2. Mettre à jour le fichier Info.plist
echo "2️⃣ Mise à jour de ios/Runner/Info.plist..."

# Remplacer GIDClientID
sed -i.bak "s/<string>VOTRE_CLIENT_ID_IOS.apps.googleusercontent.com<\/string>/<string>$CLIENT_ID_IOS<\/string>/" ios/Runner/Info.plist

# Remplacer CFBundleURLSchemes
sed -i.bak2 "s/<string>com.googleusercontent.apps.VOTRE_CLIENT_ID_IOS_SANS_SUFFIX<\/string>/<string>$REVERSED_CLIENT_ID<\/string>/" ios/Runner/Info.plist

if [ $? -eq 0 ]; then
    echo "   ✅ Fichier Info.plist mis à jour"
    rm ios/Runner/Info.plist.bak ios/Runner/Info.plist.bak2 2>/dev/null
else
    echo "   ❌ Erreur lors de la mise à jour du fichier Info.plist"
    exit 1
fi

echo ""
echo "🎉 Configuration terminée avec succès !"
echo ""
echo "📋 Prochaines étapes :"
echo "   1. Nettoyez et rebuilder le projet :"
echo "      cd ios && rm -rf Pods Podfile.lock && pod install && cd .."
echo "      flutter clean && flutter pub get"
echo "   2. Testez la connexion Google sur un simulateur iOS ou appareil physique"
echo ""
echo "📚 Pour plus d'informations, consultez CONFIGURATION_GOOGLE_SIGNIN_IOS.md"