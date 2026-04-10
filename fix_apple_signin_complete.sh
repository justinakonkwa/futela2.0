#!/bin/bash

echo "🍎 Solution complète pour Apple Sign-In Error 1000"
echo "=================================================="
echo ""

echo "📋 Diagnostic de l'erreur 1000:"
echo "   L'erreur 1000 indique un problème de configuration Xcode/provisioning"
echo "   malgré que la capability soit présente dans Runner.entitlements"
echo ""

echo "🔧 Étape 1: Nettoyage complet du projet"
echo "======================================="
flutter clean
cd ios
rm -rf build/
rm -rf DerivedData/
rm -rf Pods/
rm -f Podfile.lock
cd ..

echo ""
echo "🔧 Étape 2: Réinstallation des dépendances"
echo "=========================================="
flutter pub get
cd ios
pod install --repo-update
cd ..

echo ""
echo "🔧 Étape 3: Nettoyage des caches Xcode"
echo "======================================"
rm -rf ~/Library/Developer/Xcode/DerivedData/*
rm -rf ~/Library/Caches/com.apple.dt.Xcode/*

echo ""
echo "✅ Nettoyage terminé !"
echo ""
echo "📱 ÉTAPES CRITIQUES À SUIVRE DANS XCODE:"
echo "========================================"
echo ""
echo "1️⃣ Ouvrir le projet:"
echo "   open ios/Runner.xcworkspace"
echo ""
echo "2️⃣ Vérifier le Bundle ID:"
echo "   - Sélectionner le target 'Runner'"
echo "   - Onglet 'General'"
echo "   - Bundle Identifier DOIT être: com.naara.futela"
echo ""
echo "3️⃣ Configurer Signing & Capabilities:"
echo "   - Onglet 'Signing & Capabilities'"
echo "   - Décocher 'Automatically manage signing'"
echo "   - Attendre 2-3 secondes"
echo "   - Recocher 'Automatically manage signing'"
echo "   - Sélectionner votre Team Apple Developer"
echo "   - Attendre la régénération du provisioning profile"
echo ""
echo "4️⃣ Vérifier la capability Sign In with Apple:"
echo "   - Dans 'Signing & Capabilities'"
echo "   - Vérifier que 'Sign In with Apple' est présente"
echo "   - Si absente, cliquer '+ Capability' et l'ajouter"
echo ""
echo "5️⃣ Nettoyer et rebuilder dans Xcode:"
echo "   - Product → Clean Build Folder (Cmd+Shift+K)"
echo "   - Product → Build (Cmd+B)"
echo ""
echo "6️⃣ Tester sur appareil physique:"
echo "   - Connecter un iPhone/iPad avec iOS 13+"
echo "   - Compiler et installer l'app"
echo "   - Tester Apple Sign-In"
echo ""
echo "⚠️  POINTS CRITIQUES:"
echo "==================="
echo "• Bundle ID doit être EXACTEMENT: com.naara.futela"
echo "• Tester UNIQUEMENT sur appareil physique (pas simulateur)"
echo "• Vérifier que votre Apple Developer Account a bien:"
echo "  - App ID configuré avec Sign In with Apple"
echo "  - Provisioning profile à jour"
echo "• Si l'erreur persiste, essayer sur un autre appareil iOS"
echo ""
echo "🔍 Commandes de diagnostic:"
echo "=========================="
echo "# Voir les logs Apple Sign-In:"
echo "flutter run --verbose | grep -E '(Apple|🍎|AuthorizationError)'"
echo ""
echo "# Vérifier la configuration:"
echo "cat ios/Runner/Runner.entitlements"
echo "cat ios/Runner/Info.plist | grep -A5 apple"
echo ""
echo "🚀 Une fois ces étapes terminées, relancer:"
echo "flutter run --release"
echo ""
echo "Si l'erreur 1000 persiste après ces étapes, le problème"
echo "vient probablement de la configuration Apple Developer Console."