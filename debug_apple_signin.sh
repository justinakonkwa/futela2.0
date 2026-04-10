#!/bin/bash

# Script de diagnostic Apple Sign-In
# Usage: ./debug_apple_signin.sh

echo "🍎 Diagnostic Apple Sign-In - Erreur 1000"
echo "=========================================="
echo ""

# Vérifier le Bundle ID dans le projet
echo "1️⃣ Vérification du Bundle ID..."
if grep -q "com.naara.futela" ios/Runner.xcodeproj/project.pbxproj; then
    echo "   ✅ Bundle ID: com.naara.futela (correct)"
else
    echo "   ❌ Bundle ID incorrect dans le projet iOS"
fi

# Vérifier la configuration Info.plist
echo ""
echo "2️⃣ Vérification Info.plist..."
if grep -q "com.apple.developer.applesignin" ios/Runner/Info.plist; then
    echo "   ✅ Configuration Apple Sign-In trouvée dans Info.plist"
else
    echo "   ❌ Configuration Apple Sign-In manquante dans Info.plist"
fi

# Vérifier les entitlements
echo ""
echo "3️⃣ Vérification des entitlements..."
if [ -f "ios/Runner/Runner.entitlements" ]; then
    if grep -q "com.apple.developer.applesignin" ios/Runner/Runner.entitlements; then
        echo "   ✅ Entitlements Apple Sign-In configurés"
    else
        echo "   ❌ Entitlements Apple Sign-In manquants"
    fi
else
    echo "   ❌ Fichier Runner.entitlements manquant"
fi

echo ""
echo "🔧 Solutions pour l'erreur 1000:"
echo ""
echo "📱 Dans Xcode (OBLIGATOIRE):"
echo "   1. Ouvrir ios/Runner.xcodeproj"
echo "   2. Sélectionner le target 'Runner'"
echo "   3. Aller dans 'Signing & Capabilities'"
echo "   4. Cliquer '+ Capability'"
echo "   5. Ajouter 'Sign In with Apple'"
echo "   6. Vérifier que Bundle ID = com.naara.futela"
echo ""
echo "🌐 Dans Apple Developer Console:"
echo "   1. Aller sur developer.apple.com"
echo "   2. Certificates, Identifiers & Profiles"
echo "   3. Identifiers > App IDs"
echo "   4. Chercher 'com.naara.futela'"
echo "   5. Si n'existe pas, créer un nouvel App ID"
echo "   6. Activer 'Sign In with Apple'"
echo "   7. Sauvegarder"
echo ""
echo "📋 Vérifications supplémentaires:"
echo "   - Tester uniquement sur appareil physique (iOS 13+)"
echo "   - Vérifier que l'Apple ID est configuré sur l'appareil"
echo "   - S'assurer d'avoir un compte Apple Developer actif"
echo ""
echo "⚠️  IMPORTANT: L'erreur 1000 indique généralement que:"
echo "   - La capability n'est pas ajoutée dans Xcode"
echo "   - L'App ID n'existe pas dans Apple Developer Console"
echo "   - Le Bundle ID ne correspond pas"