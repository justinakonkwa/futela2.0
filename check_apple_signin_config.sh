#!/bin/bash

# Script de vérification de la configuration Apple Sign-In
# Usage: ./check_apple_signin_config.sh

echo "🍎 Vérification de la configuration Apple Sign-In pour Futela"
echo "=============================================================="
echo ""

# Vérifier que nous sommes dans le bon répertoire
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ Erreur: Ce script doit être exécuté depuis la racine du projet Flutter"
    exit 1
fi

# 1. Vérifier le package sign_in_with_apple
echo "1️⃣ Vérification du package sign_in_with_apple..."
if grep -q "sign_in_with_apple:" pubspec.yaml; then
    VERSION=$(grep "sign_in_with_apple:" pubspec.yaml | awk '{print $2}')
    echo "   ✅ Package sign_in_with_apple trouvé (version: $VERSION)"
else
    echo "   ❌ Package sign_in_with_apple manquant dans pubspec.yaml"
    echo "      Ajoutez: sign_in_with_apple: ^6.1.1"
fi

# 2. Vérifier la configuration Info.plist
echo ""
echo "2️⃣ Vérification de la configuration iOS Info.plist..."
if [ -f "ios/Runner/Info.plist" ]; then
    if grep -q "com.apple.developer.applesignin" ios/Runner/Info.plist; then
        echo "   ✅ Configuration Apple Sign-In trouvée dans Info.plist"
    else
        echo "   ❌ Configuration Apple Sign-In manquante dans Info.plist"
        echo "      Ajoutez la clé com.apple.developer.applesignin"
    fi
else
    echo "   ❌ Fichier Info.plist non trouvé"
fi

# 3. Vérifier les fichiers de configuration
echo ""
echo "3️⃣ Vérification des fichiers de configuration..."
if [ -f "lib/config/apple_signin_config.dart" ]; then
    echo "   ✅ Fichier apple_signin_config.dart trouvé"
else
    echo "   ❌ Fichier apple_signin_config.dart manquant"
fi

# 4. Vérifier l'AuthService
echo ""
echo "4️⃣ Vérification de l'AuthService..."
if [ -f "lib/services/auth_service.dart" ]; then
    if grep -q "signInWithApple" lib/services/auth_service.dart; then
        echo "   ✅ Méthode signInWithApple trouvée dans AuthService"
    else
        echo "   ❌ Méthode signInWithApple manquante dans AuthService"
    fi
    
    if grep -q "sign_in_with_apple" lib/services/auth_service.dart; then
        echo "   ✅ Import sign_in_with_apple trouvé dans AuthService"
    else
        echo "   ❌ Import sign_in_with_apple manquant dans AuthService"
    fi
else
    echo "   ❌ Fichier AuthService non trouvé"
fi

# 5. Vérifier l'AuthProvider
echo ""
echo "5️⃣ Vérification de l'AuthProvider..."
if [ -f "lib/providers/auth_provider.dart" ]; then
    if grep -q "signInWithApple" lib/providers/auth_provider.dart; then
        echo "   ✅ Méthode signInWithApple trouvée dans AuthProvider"
    else
        echo "   ❌ Méthode signInWithApple manquante dans AuthProvider"
    fi
else
    echo "   ❌ Fichier AuthProvider non trouvé"
fi

# 6. Vérifier les écrans d'authentification
echo ""
echo "6️⃣ Vérification des écrans d'authentification..."
if [ -f "lib/screens/auth/login_screen.dart" ]; then
    if grep -q "signInWithApple" lib/screens/auth/login_screen.dart; then
        echo "   ✅ Bouton Apple Sign-In trouvé dans login_screen.dart"
    else
        echo "   ❌ Bouton Apple Sign-In manquant dans login_screen.dart"
    fi
else
    echo "   ❌ Fichier login_screen.dart non trouvé"
fi

if [ -f "lib/screens/auth/register_screen.dart" ]; then
    if grep -q "signInWithApple" lib/screens/auth/register_screen.dart; then
        echo "   ✅ Bouton Apple Sign-In trouvé dans register_screen.dart"
    else
        echo "   ❌ Bouton Apple Sign-In manquant dans register_screen.dart"
    fi
else
    echo "   ❌ Fichier register_screen.dart non trouvé"
fi

# 7. Vérifier le Bundle ID
echo ""
echo "7️⃣ Vérification du Bundle ID..."
if [ -f "ios/Runner.xcodeproj/project.pbxproj" ]; then
    if grep -q "com.futelaapp.mobile" ios/Runner.xcodeproj/project.pbxproj; then
        echo "   ✅ Bundle ID com.futelaapp.mobile trouvé"
    else
        echo "   ❌ Bundle ID com.futelaapp.mobile non trouvé"
        echo "      Vérifiez la configuration Xcode"
    fi
else
    echo "   ❌ Fichier project.pbxproj non trouvé"
fi

echo ""
echo "=============================================================="
echo "🔍 Résumé de la vérification terminé"
echo ""
echo "📋 Prochaines étapes si tout est ✅ :"
echo "   1. Ouvrir ios/Runner.xcodeproj dans Xcode"
echo "   2. Ajouter la capability 'Sign In with Apple'"
echo "   3. Activer Apple Sign-In dans Apple Developer Console"
echo "   4. Configurer l'endpoint backend /api/auth/apple"
echo "   5. Tester sur un appareil iOS physique (iOS 13+)"
echo ""
echo "📚 Consultez APPLE_SIGNIN_SETUP.md pour les instructions détaillées"