#!/bin/bash

# Script pour créer un keystore pour la signature de l'application Android
# Usage: ./create-keystore.sh

echo "🔐 Création du keystore pour la signature de l'application Futela"
echo ""

# Demander les informations nécessaires
read -p "Entrez le chemin où sauvegarder le keystore (défaut: ~/upload-keystore.jks): " KEYSTORE_PATH
KEYSTORE_PATH=${KEYSTORE_PATH:-~/upload-keystore.jks}

while true; do
    read -p "Entrez le mot de passe du keystore (min 6 caractères): " -s STORE_PASSWORD
    echo ""
    
    if [ ${#STORE_PASSWORD} -lt 6 ]; then
        echo "❌ Le mot de passe doit contenir au moins 6 caractères!"
        continue
    fi
    
    read -p "Confirmez le mot de passe du keystore: " -s STORE_PASSWORD_CONFIRM
    echo ""
    
    if [ "$STORE_PASSWORD" != "$STORE_PASSWORD_CONFIRM" ]; then
        echo "❌ Les mots de passe ne correspondent pas!"
        continue
    fi
    break
done

while true; do
    read -p "Entrez le mot de passe de la clé (min 6 caractères, peut être le même): " -s KEY_PASSWORD
    echo ""
    
    if [ ${#KEY_PASSWORD} -lt 6 ]; then
        echo "❌ Le mot de passe doit contenir au moins 6 caractères!"
        continue
    fi
    
    read -p "Confirmez le mot de passe de la clé: " -s KEY_PASSWORD_CONFIRM
    echo ""
    
    if [ "$KEY_PASSWORD" != "$KEY_PASSWORD_CONFIRM" ]; then
        echo "❌ Les mots de passe ne correspondent pas!"
        continue
    fi
    break
done

# Trouver keytool
KEYTOOL=$(which keytool)
if [ -z "$KEYTOOL" ]; then
    # Essayer de trouver keytool dans le JDK d'Android Studio
    if [ -d "$HOME/Library/Android/sdk" ]; then
        JAVA_HOME=$(/usr/libexec/java_home -v 17 2>/dev/null || /usr/libexec/java_home -v 11 2>/dev/null)
        if [ -n "$JAVA_HOME" ]; then
            KEYTOOL="$JAVA_HOME/bin/keytool"
        fi
    fi
fi

if [ -z "$KEYTOOL" ] || [ ! -f "$KEYTOOL" ]; then
    echo "❌ keytool n'a pas été trouvé. Veuillez installer Java JDK ou Android Studio."
    exit 1
fi

echo ""
echo "📝 Création du keystore..."

# Créer le keystore
"$KEYTOOL" -genkey -v \
    -keystore "$KEYSTORE_PATH" \
    -storetype JKS \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -alias upload \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=Futela, OU=Development, O=Naara, L=City, ST=State, C=CD"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore créé avec succès: $KEYSTORE_PATH"
    echo ""
    
    # Convertir le chemin relatif en chemin absolu
    if [[ "$KEYSTORE_PATH" == ~* ]]; then
        KEYSTORE_ABSOLUTE_PATH="${KEYSTORE_PATH/#\~/$HOME}"
    else
        KEYSTORE_ABSOLUTE_PATH="$KEYSTORE_PATH"
    fi
    
    # Créer le fichier key.properties
    KEY_PROPERTIES_FILE="$(dirname "$0")/key.properties"
    cat > "$KEY_PROPERTIES_FILE" << EOF
# Configuration du keystore pour la signature de release
# ⚠️ NE COMMITEZ JAMAIS CE FICHIER DANS LE CONTRÔLE DE VERSION !

storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=upload
storeFile=$KEYSTORE_ABSOLUTE_PATH
EOF
    
    echo "✅ Fichier key.properties créé automatiquement!"
    echo ""
    echo "📋 Le fichier contient:"
    echo "   - storeFile: $KEYSTORE_ABSOLUTE_PATH"
    echo "   - keyAlias: upload"
    echo ""
    echo "⚠️  IMPORTANT: Ne commitez JAMAIS key.properties dans le contrôle de version!"
    echo "   Le fichier est déjà dans .gitignore"
else
    echo ""
    echo "❌ Erreur lors de la création du keystore"
    exit 1
fi

