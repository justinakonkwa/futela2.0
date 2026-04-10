#!/bin/bash

echo "🔧 Fix Apple Sign-In Error 1000"
echo "==============================="
echo ""

echo "1️⃣ Nettoyage complet du projet..."
flutter clean
cd ios
rm -rf build/
rm -rf DerivedData/
rm -rf Pods/
rm Podfile.lock
cd ..

echo "2️⃣ Réinstallation des dépendances..."
flutter pub get
cd ios
pod install --repo-update
cd ..

echo "3️⃣ Nettoyage des caches Xcode..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

echo ""
echo "✅ Nettoyage terminé !"
echo ""
echo "📋 Prochaines étapes dans Xcode :"
echo "   1. Ouvrir ios/Runner.xcodeproj"
echo "   2. Aller dans Signing & Capabilities"
echo "   3. Décocher 'Automatically manage signing'"
echo "   4. Recocher 'Automatically manage signing'"
echo "   5. Attendre la régénération du provisioning profile"
echo "   6. Compiler sur appareil physique"
echo ""
echo "⚠️  Si l'erreur persiste :"
echo "   - Vérifier que le Bundle ID est exactement 'com.naara.futela'"
echo "   - Vérifier que le bon Team est sélectionné"
echo "   - Essayer sur un autre appareil iOS"
echo "   - Redémarrer Xcode"