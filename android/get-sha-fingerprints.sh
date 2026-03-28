#!/bin/bash
# Génère SHA-1 et SHA-256 pour Google Sign-In (Android).
# À ajouter dans Google Cloud Console → Credentials → Client Android.

set -e

echo "=============================================="
echo "  Empreintes pour Google Sign-In (Android)"
echo "=============================================="
echo ""

# --- Debug (émulateur / tests) ---
DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
if [ -f "$DEBUG_KEYSTORE" ]; then
  echo "📱 DEBUG (tests / émulateur)"
  echo "   Keystore: ~/.android/debug.keystore"
  keytool -list -v -keystore "$DEBUG_KEYSTORE" -alias androiddebugkey -storepass android -keypass android 2>/dev/null | grep -E "SHA1:|SHA256:"
  echo ""
else
  echo "⚠️  Debug keystore non trouvé: $DEBUG_KEYSTORE"
  echo "   Lancez au moins une fois l'app en debug (Android Studio ou flutter run)."
  echo ""
fi

# --- Release (si key.properties existe) ---
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
KEY_PROPS="$PROJECT_DIR/key.properties"
if [ -f "$KEY_PROPS" ]; then
  # Extraire storeFile (supporter storeFile=path ou storeFile = path)
  STORE_FILE=$(grep -E "^storeFile=" "$KEY_PROPS" | cut -d= -f2- | tr -d " " | head -1)
  if [ -n "$STORE_FILE" ]; then
    # Chemin relatif par rapport au dossier android/
    case "$STORE_FILE" in
      /*) ;;
      *) STORE_FILE="$PROJECT_DIR/$STORE_FILE" ;;
    esac
    if [ -f "$STORE_FILE" ]; then
      KEY_ALIAS=$(grep -E "^keyAlias=" "$KEY_PROPS" | cut -d= -f2- | tr -d " " | head -1)
      KEY_ALIAS=${KEY_ALIAS:-upload}
      echo "📦 RELEASE (APK/AAB)"
      echo "   Keystore: $STORE_FILE"
      echo "   Alias: $KEY_ALIAS"
      echo "   Entrez le mot de passe du keystore quand demandé."
      keytool -list -v -keystore "$STORE_FILE" -alias "$KEY_ALIAS" 2>/dev/null | grep -E "SHA1:|SHA256:"
      echo ""
    else
      echo "⚠️  Fichier keystore introuvable: $STORE_FILE"
      echo ""
    fi
  fi
else
  echo "ℹ️  key.properties non trouvé → empreintes release non lues."
  echo "   Pour la release, configurez android/key.properties puis relancez ce script."
  echo ""
fi

echo "=============================================="
echo "  À faire : Google Cloud Console"
echo "=============================================="
echo "1. Credentials → Create credentials → OAuth client ID"
echo "2. Type : Android"
echo "3. Package name : com.futelaapp.mobile"
echo "4. Coller le SHA-1 ci-dessus (et SHA-256 si demandé)."
echo ""
