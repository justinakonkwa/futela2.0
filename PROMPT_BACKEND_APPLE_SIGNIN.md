# 🍎 PROMPT BACKEND - Configuration Apple Sign-In COMPLÈTE

## 🚨 PROBLÈME URGENT

L'endpoint `/api/auth/apple` retourne **"Jeton Apple invalide" (401)** alors que l'application mobile envoie des tokens Apple parfaitement valides.

**DIAGNOSTIC :** Il manque la configuration Apple Sign-In complète côté backend.

## 📱 INFORMATIONS PROJET FUTELA

### 🔑 **Clés et Identifiants Projet**
```
Bundle ID: com.naara.futela
App Name: Futela
Package: com.naara.futela
```

### 📋 **Configuration Apple Developer Requise**
Vous devez récupérer ces informations depuis votre Apple Developer Console :

```env
# À RÉCUPÉRER DEPUIS APPLE DEVELOPER CONSOLE
APPLE_TEAM_ID=XXXXXXXXXX          # Format: 10 caractères (ex: 6MPDV0UYYX)
APPLE_KEY_ID=XXXXXXXXXX           # Format: 10 caractères (ex: ABCDE12345)
APPLE_BUNDLE_ID=com.naara.futela  # ✅ CONFIRMÉ
APPLE_PRIVATE_KEY_PATH=/path/to/AuthKey_KEYID.p8
```

### 🔍 **Comment Récupérer Vos Clés**

#### 1. Team ID (10 caractères)
1. Aller sur [Apple Developer Console](https://developer.apple.com/account)
2. **Membership** → Voir "Team ID" (ex: `6MPDV0UYYX`)

#### 2. Key ID + Fichier .p8
1. **Certificates, Identifiers & Profiles** → **Keys**
2. **Créer une nouvelle clé** ou utiliser existante
3. **Cocher "Sign In with Apple"**
4. **Télécharger le fichier .p8** (ex: `AuthKey_ABCDE12345.p8`)
5. **Noter le Key ID** affiché (ex: `ABCDE12345`)

#### 3. Vérifier Bundle ID
1. **Identifiers** → Chercher `com.naara.futela`
2. **Vérifier que "Sign In with Apple" est activé**

## 📱 STATUT APPLICATION MOBILE ✅

L'app mobile fonctionne parfaitement et envoie :

```json
{
  "idToken": "eyJraWQiOiI1aXEzM2xKQllqIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm5hYXJhLmZ1dGVsYSIsImV4cCI6MTc3NTgyMzkzOCwiaWF0IjoxNzc1NzM3NTM4LCJzdWIiOiIwMDAxNjEuYWNhMjQ2YzY3MWI2NDQzY2I4NzFmNmUwNThiY2ZjNjguMTAwNyIsImVtYWlsIjoic3Fqd2RiaDh5dEBwcml2YXRlcmVsYXkuYXBwbGVpZC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwiaXNfcHJpdmF0ZV9lbWFpbCI6dHJ1ZX0...",
  "authorizationCode": "cda0736a3c65a420fb907560fb21fd15d.0.mrwr.0j4nhpGqUhFDXzFwd5Pt8g",
  "userIdentifier": "000161.aca246c671b6443cb871f6e058bcfc68.1007"
}
```

**Token décodé (valide) :**
- ✅ `iss`: `https://appleid.apple.com`
- ✅ `aud`: `com.naara.futela` (Bundle ID correct)
- ✅ `exp`: Token non expiré
- ✅ Signature valide avec clé Apple `kid: 5iq33lJBYj`

## 🔧 CONFIGURATION BACKEND REQUISE

### 1. FICHIER CLÉ PRIVÉE APPLE (.p8) - OBLIGATOIRE

**Vous devez télécharger :**
1. Aller sur [Apple Developer Console](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles** → **Keys**
3. Créer une clé avec capability **"Sign In with Apple"**
4. **Télécharger le fichier .p8** (ex: `AuthKey_ABC123XYZ.p8`)
5. **Noter le Key ID** (ex: `ABC123XYZ`)
6. **Noter votre Team ID** (visible dans Membership)

### 2. VARIABLES D'ENVIRONNEMENT

```env
APPLE_TEAM_ID=VOTRE_TEAM_ID_ICI
APPLE_KEY_ID=VOTRE_KEY_ID_ICI  
APPLE_BUNDLE_ID=com.naara.futela
APPLE_PRIVATE_KEY_PATH=/path/to/AuthKey_KEYID.p8
```

### 3. CODE BACKEND COMPLET

#### Installation dépendances :
```bash
# Node.js
npm install jsonwebtoken jwks-rsa

# Python
pip install PyJWT cryptography requests

# PHP
composer require firebase/php-jwt
```

#### Implémentation (Node.js exemple) :

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
const fs = require('fs');

// Configuration Apple
const APPLE_CONFIG = {
  teamId: process.env.APPLE_TEAM_ID,
  keyId: process.env.APPLE_KEY_ID,
  bundleId: 'com.naara.futela',
  privateKeyPath: process.env.APPLE_PRIVATE_KEY_PATH
};

// Client pour clés publiques Apple
const client = jwksClient({
  jwksUri: 'https://appleid.apple.com/auth/keys'
});

// 1. Valider le identity token
function validateAppleToken(idToken) {
  return new Promise((resolve, reject) => {
    // Décoder le header pour obtenir le kid
    const decoded = jwt.decode(idToken, { complete: true });
    
    // Récupérer la clé publique Apple
    client.getSigningKey(decoded.header.kid, (err, key) => {
      if (err) return reject(err);
      
      const signingKey = key.publicKey || key.rsaPublicKey;
      
      // Valider le token
      jwt.verify(idToken, signingKey, {
        issuer: 'https://appleid.apple.com',
        audience: 'com.naara.futela'
      }, (err, payload) => {
        if (err) reject(err);
        else resolve(payload);
      });
    });
  });
}

// 2. Créer client secret (optionnel pour validation supplémentaire)
function createClientSecret() {
  const privateKey = fs.readFileSync(APPLE_CONFIG.privateKeyPath, 'utf8');
  const now = Math.floor(Date.now() / 1000);
  
  const payload = {
    iss: APPLE_CONFIG.teamId,
    iat: now,
    exp: now + 3600,
    aud: 'https://appleid.apple.com',
    sub: APPLE_CONFIG.bundleId
  };

  return jwt.sign(payload, privateKey, {
    algorithm: 'ES256',
    keyid: APPLE_CONFIG.keyId
  });
}

// 3. Endpoint Apple Sign-In
app.post('/api/auth/apple', async (req, res) => {
  try {
    const { idToken, authorizationCode, userIdentifier } = req.body;

    // Valider le token Apple
    const appleUser = await validateAppleToken(idToken);
    
    console.log('Apple User Validated:', {
      appleId: appleUser.sub,
      email: appleUser.email,
      emailVerified: appleUser.email_verified,
      isPrivateEmail: appleUser.is_private_email
    });

    // Créer ou récupérer l'utilisateur dans votre DB
    const user = await findOrCreateUser({
      appleId: appleUser.sub,
      email: appleUser.email,
      emailVerified: appleUser.email_verified,
      isPrivateEmail: appleUser.is_private_email
    });

    // Générer vos tokens d'authentification
    const accessToken = generateYourAccessToken(user);
    const refreshToken = generateYourRefreshToken(user);

    // Réponse de succès
    res.json({
      accessToken,
      refreshToken,
      sessionId: generateSessionId(),
      expiresIn: 3600,
      tokenType: 'Bearer'
    });

  } catch (error) {
    console.error('Apple Sign-In Error:', error.message);
    
    res.status(401).json({
      error: {
        message: 'Erreur de validation Apple',
        code: 401,
        details: error.message
      }
    });
  }
});
```

## 🧪 TEST AVEC TOKEN RÉEL

**Utilisez ce token des logs pour tester :**
```
idToken: eyJraWQiOiI1aXEzM2xKQllqIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm5hYXJhLmZ1dGVsYSIsImV4cCI6MTc3NTgyMzkzOCwiaWF0IjoxNzc1NzM3NTM4LCJzdWIiOiIwMDAxNjEuYWNhMjQ2YzY3MWI2NDQzY2I4NzFmNmUwNThiY2ZjNjguMTAwNyIsImNfaGFzaCI6IkZfNTJaXzFnX3pEQzI2R0h0YTdfUFEiLCJlbWFpbCI6InNxandkYmg4eXRAcHJpdmF0ZXJlbGF5LmFwcGxlaWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzX3ByaXZhdGVfZW1haWwiOnRydWUsImF1dGhfdGltZSI6MTc3NTczNzUzOCwibm9uY2Vfc3VwcG9ydGVkIjp0cnVlfQ.iUpxVUb2QQCnwjGxcAokxUkqqxmfXL4DXFxAKf2bsIi2igU_CctqRssStobkBQPpKTmWHXjya3ZGWn0VG4aRm2j4qqiFdafs0uXG7as5MNvuFw4PT2iqH9cF1TmzkY69dIUbXnQfq6U9vGPBxAz-E_ekD10Jr20X62kMJZDhvrQBKKPMqnMMXbQ796eME6uOrQDDmXFcVMK_wWhhDSl5rEfIVSzPutr4Z6EX8t-zu7duh2mdrJJv2bnIBnjqjO3uvBEEsrwZQuLXfG68qCuakTLs3PIWRhR6eZZNzmMZCOUdEDGlYuf72Awdsr17qM-R-Wq0Uftc4iapzuyByO-iyQ
```

## ⚠️ POINTS CRITIQUES

1. **Le fichier .p8 est OBLIGATOIRE** - Sans lui, impossible de valider Apple
2. **Bundle ID doit être exact** : `com.naara.futela`
3. **Gérer les emails privés Apple** - Ne pas forcer un "vrai" email
4. **L'endpoint doit être PUBLIC** - Pas de JWT requis pour l'authentification initiale

## 🎯 RÉSULTAT ATTENDU

Après configuration, l'endpoint doit retourner :

```json
{
  "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
  "refreshToken": "abc123def456...",
  "sessionId": "019d6900-1111-7aef-bcf2-f6c19eb05379",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

## 📋 CHECKLIST

- [ ] Fichier .p8 téléchargé depuis Apple Developer Console
- [ ] Variables d'environnement configurées (Team ID, Key ID, etc.)
- [ ] Dépendances JWT installées
- [ ] Code de validation implémenté
- [ ] Endpoint `/api/auth/apple` accessible publiquement
- [ ] Test avec le token fourni

## 🚀 TEMPS ESTIMÉ

**2-3 heures** pour configuration complète et tests.

## 📞 SUPPORT

Si problèmes :
1. Vérifier que le fichier .p8 est lisible
2. Vérifier Team ID et Key ID exacts
3. Tester la validation avec le token fourni
4. Vérifier les logs d'erreur détaillés

**Une fois configuré, Apple Sign-In fonctionnera parfaitement !** 🎉