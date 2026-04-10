# 🍎 Configuration Backend Apple Sign-In - Guide Complet

## 🚨 PROBLÈME IDENTIFIÉ

Le backend retourne "Jeton Apple invalide" car il manque la **configuration complète Apple** côté serveur.

## 🔑 Éléments OBLIGATOIRES Manquants

### 1. Clé Privée Apple (.p8 file)
**CRITIQUE** : Le backend doit avoir le fichier `.p8` téléchargé depuis Apple Developer Console.

#### Comment l'obtenir :
1. Aller sur [Apple Developer Console](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles** → **Keys**
3. **Créer une nouvelle clé** ou utiliser une existante
4. **Cocher "Sign In with Apple"**
5. **Télécharger le fichier .p8** (ex: `AuthKey_7N5XJ12345.p8`)
6. **Noter le Key ID** (ex: `7N5XJ12345`)

### 2. Informations Apple Developer
```json
{
  "teamId": "HL46P12345",        // Team ID Apple Developer
  "keyId": "7N5XJ12345",         // Key ID de la clé .p8
  "bundleId": "com.naara.futela", // Bundle ID de l'app
  "privateKeyPath": "/path/to/AuthKey_7N5XJ12345.p8"
}
```

## 🔧 Implémentation Backend Correcte

### Étape 1: Validation du Identity Token (JWT)

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');

// Client pour récupérer les clés publiques Apple
const client = jwksClient({
  jwksUri: 'https://appleid.apple.com/auth/keys'
});

function getApplePublicKey(header, callback) {
  client.getSigningKey(header.kid, (err, key) => {
    const signingKey = key.publicKey || key.rsaPublicKey;
    callback(null, signingKey);
  });
}

// Valider le identity token
function validateIdentityToken(identityToken) {
  return new Promise((resolve, reject) => {
    jwt.verify(identityToken, getApplePublicKey, {
      issuer: 'https://appleid.apple.com',
      audience: 'com.naara.futela'
    }, (err, decoded) => {
      if (err) reject(err);
      else resolve(decoded);
    });
  });
}
```

### Étape 2: Création du Client Secret

```javascript
const fs = require('fs');

// Lire la clé privée .p8
const privateKey = fs.readFileSync('/path/to/AuthKey_7N5XJ12345.p8', 'utf8');

function createClientSecret() {
  const now = Math.floor(Date.now() / 1000);
  
  const payload = {
    iss: 'HL46P12345',           // Team ID
    iat: now,
    exp: now + 3600,             // Expire dans 1 heure
    aud: 'https://appleid.apple.com',
    sub: 'com.naara.futela'      // Bundle ID
  };

  return jwt.sign(payload, privateKey, {
    algorithm: 'ES256',
    keyid: '7N5XJ12345'          // Key ID
  });
}
```

### Étape 3: Validation Complète avec Apple Server

```javascript
async function validateWithAppleServer(authorizationCode) {
  const clientSecret = createClientSecret();
  
  const response = await fetch('https://appleid.apple.com/auth/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      client_id: 'com.naara.futela',
      client_secret: clientSecret,
      code: authorizationCode,
      grant_type: 'authorization_code'
    })
  });

  if (!response.ok) {
    throw new Error(`Apple validation failed: ${response.status}`);
  }

  return await response.json();
}
```

### Étape 4: Endpoint Complet

```javascript
app.post('/api/auth/apple', async (req, res) => {
  try {
    const { idToken, authorizationCode, userIdentifier } = req.body;

    // 1. Valider le identity token
    const decodedToken = await validateIdentityToken(idToken);
    
    // 2. Optionnel : Valider avec Apple server
    // const appleResponse = await validateWithAppleServer(authorizationCode);
    
    // 3. Créer ou récupérer l'utilisateur
    const user = await findOrCreateUser({
      appleId: decodedToken.sub,
      email: decodedToken.email,
      emailVerified: decodedToken.email_verified,
      isPrivateEmail: decodedToken.is_private_email
    });

    // 4. Générer les tokens de votre app
    const accessToken = generateAccessToken(user);
    const refreshToken = generateRefreshToken(user);

    res.json({
      accessToken,
      refreshToken,
      sessionId: generateSessionId(),
      expiresIn: 3600,
      tokenType: 'Bearer'
    });

  } catch (error) {
    console.error('Apple Sign-In Error:', error);
    res.status(401).json({
      error: {
        message: 'Erreur de validation Apple',
        code: 401
      }
    });
  }
});
```

## 📋 Checklist Configuration Backend

### ✅ Fichiers Requis
- [ ] Fichier `.p8` téléchargé et accessible au serveur
- [ ] Team ID Apple Developer noté
- [ ] Key ID de la clé .p8 noté
- [ ] Bundle ID correct : `com.naara.futela`

### ✅ Dépendances
```bash
npm install jsonwebtoken jwks-rsa
# ou
pip install PyJWT cryptography requests
```

### ✅ Variables d'Environnement
```env
APPLE_TEAM_ID=HL46P12345
APPLE_KEY_ID=7N5XJ12345
APPLE_BUNDLE_ID=com.naara.futela
APPLE_PRIVATE_KEY_PATH=/path/to/AuthKey_7N5XJ12345.p8
```

## 🧪 Test de Validation

### Token de Test (du log mobile)
```
idToken: eyJraWQiOiI1aXEzM2xKQllqIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm5hYXJhLmZ1dGVsYSIsImV4cCI6MTc3NTgyMzkzOCwiaWF0IjoxNzc1NzM3NTM4LCJzdWIiOiIwMDAxNjEuYWNhMjQ2YzY3MWI2NDQzY2I4NzFmNmUwNThiY2ZjNjguMTAwNyIsImNfaGFzaCI6IkZfNTJaXzFnX3pEQzI2R0h0YTdfUFEiLCJlbWFpbCI6InNxandkYmg4eXRAcHJpdmF0ZXJlbGF5LmFwcGxlaWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzX3ByaXZhdGVfZW1haWwiOnRydWUsImF1dGhfdGltZSI6MTc3NTczNzUzOCwibm9uY2Vfc3VwcG9ydGVkIjp0cnVlfQ.iUpxVUb2QQCnwjGxcAokxUkqqxmfXL4DXFxAKf2bsIi2igU_CctqRssStobkBQPpKTmWHXjya3ZGWn0VG4aRm2j4qqiFdafs0uXG7as5MNvuFw4PT2iqH9cF1TmzkY69dIUbXnQfq6U9vGPBxAz-E_ekD10Jr20X62kMJZDhvrQBKKPMqnMMXbQ796eME6uOrQDDmXFcVMK_wWhhDSl5rEfIVSzPutr4Z6EX8t-zu7duh2mdrJJv2bnIBnjqjO3uvBEEsrwZQuLXfG68qCuakTLs3PIWRhR6eZZNzmMZCOUdEDGlYuf72Awdsr17qM-R-Wq0Uftc4iapzuyByO-iyQ
```

### Informations Décodées
```json
{
  "iss": "https://appleid.apple.com",
  "aud": "com.naara.futela",
  "sub": "000161.aca246c671b6443cb871f6e058bcfc68.1007",
  "email": "sqjwdbh8yt@privaterelay.appleid.com",
  "email_verified": true,
  "is_private_email": true,
  "exp": 1775823938
}
```

## 🚨 Points Critiques

1. **Le fichier .p8 est OBLIGATOIRE** - Sans lui, impossible de créer le client_secret
2. **Team ID et Key ID doivent être exacts** - Une erreur = échec de validation
3. **Bundle ID doit correspondre** - `com.naara.futela` exactement
4. **Gestion des emails privés** - Ne pas forcer un "vrai" email

## 📞 Action Immédiate Requise

L'équipe backend doit :
1. **Télécharger le fichier .p8** depuis Apple Developer Console
2. **Configurer les variables d'environnement** Apple
3. **Implémenter la validation complète** selon ce guide
4. **Tester avec le token fourni** dans les logs

Une fois ces éléments configurés, Apple Sign-In fonctionnera parfaitement ! 🎯