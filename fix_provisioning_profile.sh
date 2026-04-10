#!/bin/bash

# Script pour régénérer le provisioning profile
echo "🔄 Régénération du Provisioning Profile"
echo "======================================"
echo ""

echo "1️⃣ Nettoyage des builds précédents..."
cd ios
rm -rf build/
rm -rf DerivedData/
cd ..

echo "2️⃣ Nettoyage Flutter..."
flutter clean
flutter pub get

echo "3️⃣ Réinstallation des pods..."
cd ios
pod deintegrate
pod install --repo-update
cd ..

echo ""
echo "✅ Nettoyage terminé !"
echo ""
echo "📋 Prochaines étapes dans Xcode :"
echo "   1. Ouvrir ios/Runner.xcodeproj"
echo "   2. Aller dans Signing & Capabilities"
echo "   3. Décocher puis recocher 'Automatically manage signing'"
echo "   4. Ou sélectionner manuellement un provisioning profile mis à jour"
echo "   5. Compiler sur appareil physique"