#!/bin/bash

# Script pour vérifier l'empreinte SHA1 d'un keystore
# Usage: ./check-keystore.sh <chemin-keystore> <alias> <mot-de-passe>

KEYSTORE=$1
ALIAS=$2
PASSWORD=$3

if [ -z "$KEYSTORE" ] || [ -z "$ALIAS" ] || [ -z "$PASSWORD" ]; then
    echo "Usage: $0 <chemin-keystore> <alias> <mot-de-passe>"
    exit 1
fi

if [ ! -f "$KEYSTORE" ]; then
    echo "❌ Le fichier keystore n'existe pas: $KEYSTORE"
    exit 1
fi

echo "🔍 Vérification du keystore: $KEYSTORE"
echo ""

SHA1=$(keytool -list -v -keystore "$KEYSTORE" -alias "$ALIAS" -storepass "$PASSWORD" 2>&1 | grep -A 1 "Certificate fingerprints" | grep "SHA1" | awk '{print $2}')

if [ -z "$SHA1" ]; then
    echo "❌ Erreur: Impossible de lire le keystore (mauvais mot de passe ou alias?)"
    exit 1
fi

echo "✅ Empreinte SHA1 trouvée: $SHA1"
echo ""

EXPECTED_SHA1="43:FE:10:30:1D:E2:AF:82:E1:DD:31:E9:1D:23:CD:EB:4D:C1:CD:2E"

if [ "$SHA1" == "$EXPECTED_SHA1" ]; then
    echo "✅ ✅ ✅ CORRECT! Ce keystore correspond à celui attendu par Google Play!"
    echo ""
    echo "📋 Mettez à jour android/key.properties avec:"
    echo "   storeFile=$KEYSTORE"
    echo "   keyAlias=$ALIAS"
    echo "   storePassword=$PASSWORD"
    echo "   keyPassword=$PASSWORD"
else
    echo "❌ Ce keystore ne correspond PAS à celui attendu par Google Play"
    echo "   Attendu: $EXPECTED_SHA1"
    echo "   Trouvé:  $SHA1"
fi

