#!/bin/bash

echo "🔍 Diagnostic Apple Sign-In Configuration"
echo "========================================"
echo ""

echo "📱 1. Vérification des fichiers de configuration"
echo "==============================================="

echo ""
echo "🔸 Runner.entitlements:"
if [ -f "ios/Runner/Runner.entitlements" ]; then
    cat ios/Runner/Runner.entitlements
    echo ""
    if grep -q "com.apple.developer.applesignin" ios/Runner/Runner.entitlements; then
        echo "✅ Apple Sign-In entitlement trouvé"
    else
        echo "❌ Apple Sign-In entitlement MANQUANT"
    fi
else
    echo "❌ Fichier Runner.entitlements MANQUANT"
fi

echo ""
echo "🔸 Info.plist (Apple Sign-In):"
if [ -f "ios/Runner/Info.plist" ]; then
    if grep -q "com.apple.developer.applesignin" ios/Runner/Info.plist; then
        echo "✅ Configuration Apple Sign-In trouvée dans Info.plist"
        grep -A3 "com.apple.developer.applesignin" ios/Runner/Info.plist
    else
        echo "⚠️  Pas de configuration Apple Sign-In dans Info.plist (normal)"
    fi
else
    echo "❌ Fichier Info.plist MANQUANT"
fi

echo ""
echo "📦 2. Vérification des dépendances"
echo "================================="

echo ""
echo "🔸 pubspec.yaml - sign_in_with_apple:"
if grep -q "sign_in_with_apple" pubspec.yaml; then
    echo "✅ Dépendance sign_in_with_apple trouvée"
    grep -A1 "sign_in_with_apple" pubspec.yaml
else
    echo "❌ Dépendance sign_in_with_apple MANQUANTE"
fi

echo ""
echo "🔸 Podfile.lock - sign_in_with_apple:"
if [ -f "ios/Podfile.lock" ]; then
    if grep -q "sign_in_with_apple" ios/Podfile.lock; then
        echo "✅ Pod sign_in_with_apple installé"
        grep -A2 "sign_in_with_apple" ios/Podfile.lock
    else
        echo "❌ Pod sign_in_with_apple NON INSTALLÉ"
    fi
else
    echo "⚠️  Podfile.lock non trouvé - lancer 'pod install'"
fi

echo ""
echo "🏗️  3. État du projet"
echo "==================="

echo ""
echo "🔸 Dossiers de build:"
if [ -d "ios/build" ]; then
    echo "⚠️  Dossier ios/build existe (à nettoyer)"
else
    echo "✅ Dossier ios/build propre"
fi

if [ -d "ios/DerivedData" ]; then
    echo "⚠️  Dossier ios/DerivedData existe (à nettoyer)"
else
    echo "✅ Dossier ios/DerivedData propre"
fi

echo ""
echo "🔸 Cache Flutter:"
if [ -d ".dart_tool/flutter_build" ]; then
    echo "⚠️  Cache Flutter existe (à nettoyer avec flutter clean)"
else
    echo "✅ Cache Flutter propre"
fi

echo ""
echo "📋 4. Résumé et recommandations"
echo "==============================="

echo ""
echo "🔧 Actions recommandées:"
echo "1. Lancer: ./fix_apple_signin_complete.sh"
echo "2. Ouvrir Xcode: open ios/Runner.xcworkspace"
echo "3. Vérifier Bundle ID: com.naara.futela"
echo "4. Régénérer provisioning profile (décocher/recocher signing)"
echo "5. Tester sur appareil physique iOS 13+"
echo ""
echo "⚠️  L'erreur 1000 est généralement due à:"
echo "   • Provisioning profile obsolète"
echo "   • Bundle ID incorrect dans Xcode"
echo "   • Capability manquante dans le target Xcode"
echo "   • Test sur simulateur (utiliser appareil physique)"
echo ""
echo "🆘 Si le problème persiste:"
echo "   • Vérifier Apple Developer Console"
echo "   • Créer un nouveau provisioning profile"
echo "   • Essayer sur un autre appareil iOS"
echo "   • Redémarrer Xcode complètement"