#!/bin/bash

# Script pour configurer le keystore original
# Usage: ./setup-keystore.sh <chemin-vers-keystore.jks> <alias> <mot-de-passe>

KEYSTORE_PATH=$1
ALIAS=${2:-upload}
PASSWORD=$3

if [ -z "$KEYSTORE_PATH" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <chemin-vers-keystore.jks> <alias> <mot-de-passe>"
    echo "Exemple: $0 /Users/hologram/upload-keystore.jks upload MotDePasse123"
    exit 1
fi

if [ ! -f "$KEYSTORE_PATH" ]; then
    echo "❌ Le fichier keystore n'existe pas: $KEYSTORE_PATH"
    exit 1
fi

echo "🔍 Vérification du keystore: $KEYSTORE_PATH"
echo ""

# Vérifier l'empreinte SHA1
SHA1=$(keytool -list -v -keystore "$KEYSTORE_PATH" -alias "$ALIAS" -storepass "$PASSWORD" 2>&1 | grep -A 1 "Certificate fingerprints" | grep "SHA1" | awk '{print $2}')

if [ -z "$SHA1" ]; then
    echo "❌ Erreur: Impossible de lire le keystore"
    echo "   Vérifiez le mot de passe et l'alias"
    exit 1
fi

echo "✅ Empreinte SHA1 trouvée: $SHA1"
echo ""

EXPECTED_SHA1="43:FE:10:30:1D:E2:AF:82:E1:DD:31:E9:1D:23:CD:EB:4D:C1:CD:2E"

if [ "$SHA1" == "$EXPECTED_SHA1" ]; then
    echo "✅ ✅ ✅ CORRECT! Ce keystore correspond à celui attendu par Google Play!"
    echo ""
    
    # Sauvegarder l'ancien keystore s'il existe
    if [ -f "/Users/hologram/upload-keystore.jks" ] && [ "$KEYSTORE_PATH" != "/Users/hologram/upload-keystore.jks" ]; then
        echo "📦 Sauvegarde de l'ancien keystore..."
        cp /Users/hologram/upload-keystore.jks /Users/hologram/upload-keystore.jks.backup.$(date +%Y%m%d_%H%M%S)
    fi
    
    # Copier le keystore au bon emplacement
    echo "📋 Copie du keystore vers /Users/hologram/upload-keystore.jks..."
    cp "$KEYSTORE_PATH" /Users/hologram/upload-keystore.jks
    
    # Mettre à jour key.properties
    KEY_PROPERTIES_FILE="$(dirname "$0")/key.properties"
    cat > "$KEY_PROPERTIES_FILE" << EOF
storePassword=$PASSWORD
keyPassword=$PASSWORD
keyAlias=$ALIAS
storeFile=/Users/hologram/upload-keystore.jks
EOF
    
    echo "✅ Fichier key.properties mis à jour!"
    echo ""
    echo "📋 Configuration:"
    echo "   - Keystore: /Users/hologram/upload-keystore.jks"
    echo "   - Alias: $ALIAS"
    echo "   - Empreinte SHA1: $SHA1"
    echo ""
    echo "✅ Tout est prêt! Vous pouvez maintenant reconstruire l'app bundle:"
    echo "   flutter build appbundle"
else
    echo "❌ Ce keystore ne correspond PAS à celui attendu par Google Play"
    echo "   Attendu: $EXPECTED_SHA1"
    echo "   Trouvé:  $SHA1"
    echo ""
    echo "⚠️  Ce keystore ne pourra pas être utilisé pour cette application."
    exit 1
fi

