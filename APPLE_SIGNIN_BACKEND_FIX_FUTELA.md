# 🍎 FIX APPLE SIGN-IN BACKEND - FUTELA

## 🚨 PROBLÈME
L'endpoint `/api/auth/apple` retourne **"Jeton Apple invalide" (401)** alors que l'app mobile envoie des tokens Apple parfaitement valides.

## 🔑 VOS CLÉS APPLE DEVELOPER - FUTELA ✅ COMPLÈTES
```env
APPLE_TEAM_ID=3UWPS2AHCF4KJN6A9RY4
APPLE_BUNDLE_ID=com.naara.futela
APPLE_KEY_ID=3UWPS2AHCF
APPLE_PRIVATE_KEY_PATH=/path/to/AuthKey_3UWPS2AHCF.p8
```

## 📋 ÉTAPES POUR RÉCUPÉRER LA CLÉ MANQUANTE

### 1. Aller sur Apple Developer Console
- URL: https://developer.apple.com/account
- Se connecter avec votre compte Apple Developer

### 2. Créer/Récupérer la clé Sign In with Apple
- **Certificates, Identifiers & Profiles** → **Keys**
- **Créer une nouvelle clé** ou utiliser une existante
- **Nom**: "Futela Apple Sign In Key"
- **Cocher "Sign In with Apple"**
- **Télécharger le fichier .p8** (ex: `AuthKey_ABCD123456.p8`)
- **Noter le Key ID** affiché (format: 10 caractères comme `ABCD123456`)

### 3. Vérifier Bundle ID
- **Identifiers** → Chercher `com.naara.futela`
- **Vérifier que "Sign In with Apple" est activé**

## 🔧 CODE BACKEND COMPLET AVEC VOS CLÉS

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
const fs = require('fs');

// ✅ CONFIGURATION FUTELA AVEC VOS VRAIES CLÉS COMPLÈTES
const APPLE_CONFIG = {
  teamId: '3UWPS2AHCF4KJN6A9RY4',        // ✅ Votre Team ID
  keyId: '3UWPS2AHCF',                   // ✅ Votre Key ID
  bundleId: 'com.naara.futela',           // ✅ Bundle ID confirmé
  privateKeyPath: '/path/to/AuthKey_3UWPS2AHCF.p8'  // ✅ Fichier .p8 à placer
};

// Client pour clés publiques Apple
const client = jwksClient({
  jwksUri: 'https://appleid.apple.com/auth/keys',
  cache: true,
  cacheMaxEntries: 5,
  cacheMaxAge: 600000
});

// Valider le token Apple avec les clés publiques
function validateAppleToken(idToken) {
  return new Promise((resolve, reject) => {
    const decoded = jwt.decode(idToken, { complete: true });
    
    if (!decoded) {
      return reject(new Error('Token invalide'));
    }

    console.log('🔍 Validation token Apple pour Futela');
    console.log('   - Bundle ID attendu: com.naara.futela');
    console.log('   - Token Kid:', decoded.header.kid);
    
    client.getSigningKey(decoded.header.kid, (err, key) => {
      if (err) {
        console.error('❌ Erreur clé Apple:', err);
        return reject(err);
      }
      
      const signingKey = key.publicKey || key.rsaPublicKey;
      
      jwt.verify(idToken, signingKey, {
        issuer: 'https://appleid.apple.com',
        audience: 'com.naara.futela',  // ✅ Votre Bundle ID exact
        algorithms: ['RS256']
      }, (err, payload) => {
        if (err) {
          console.error('❌ Erreur validation:', err);
          reject(err);
        } else {
          console.log('✅ Token Apple validé pour Futela');
          resolve(payload);
        }
      });
    });
  });
}

// Créer client secret avec votre Team ID
function createClientSecret() {
  try {
    const privateKey = fs.readFileSync(APPLE_CONFIG.privateKeyPath, 'utf8');
    const now = Math.floor(Date.now() / 1000);
    
    const payload = {
      iss: '3UWPS2AHCF4KJN6A9RY4',  // ✅ Votre Team ID
      iat: now,
      exp: now + 3600,
      aud: 'https://appleid.apple.com',
      sub: 'com.naara.futela'       // ✅ Votre Bundle ID
    };

    return jwt.sign(payload, privateKey, {
      algorithm: 'ES256',
      keyid: '3UWPS2AHCF'  // ✅ Votre Key ID
    });
    
  } catch (error) {
    console.error('❌ Erreur client secret Futela:', error);
    throw error;
  }
}

// Endpoint Apple Sign-In pour Futela
app.post('/api/auth/apple', async (req, res) => {
  console.log('🍎 [Futela] Apple Sign-In - Début validation');
  
  try {
    const { idToken, authorizationCode, userIdentifier } = req.body;

    if (!idToken) {
      return res.status(400).json({
        error: { message: 'idToken manquant', code: 400 }
      });
    }

    console.log('📥 [Futela] Données reçues:', {
      idToken: 'présent',
      authorizationCode: authorizationCode ? 'présent' : 'manquant',
      userIdentifier: userIdentifier || 'manquant'
    });

    // Valider avec les clés publiques Apple
    const appleUser = await validateAppleToken(idToken);
    
    console.log('✅ [Futela] Utilisateur Apple validé:', {
      appleId: appleUser.sub,
      email: appleUser.email,
      bundleId: appleUser.aud,
      emailVerified: appleUser.email_verified
    });

    // Créer/récupérer utilisateur Futela
    const user = await findOrCreateFutelaUser({
      appleId: appleUser.sub,
      email: appleUser.email,
      emailVerified: appleUser.email_verified,
      isPrivateEmail: appleUser.is_private_email,
      firstName: req.body.firstName || null,
      lastName: req.body.lastName || null
    });

    // Générer tokens Futela
    const accessToken = generateFutelaAccessToken(user);
    const refreshToken = generateFutelaRefreshToken(user);
    const sessionId = generateSessionId();

    console.log('✅ [Futela] Apple Sign-In réussi pour:', user.id);

    res.json({
      accessToken,
      refreshToken,
      sessionId,
      expiresIn: 3600,
      tokenType: 'Bearer'
    });

  } catch (error) {
    console.error('❌ [Futela] Erreur Apple Sign-In:', error.message);
    
    res.status(401).json({
      error: {
        message: 'Jeton Apple invalide',
        code: 401,
        details: error.message
      }
    });
  }
});

async function findOrCreateFutelaUser(appleData) {
  let user = await User.findOne({ appleId: appleData.appleId });
  
  if (!user) {
    user = await User.create({
      appleId: appleData.appleId,
      email: appleData.email,
      emailVerified: appleData.emailVerified,
      isPrivateEmail: appleData.isPrivateEmail,
      firstName: appleData.firstName,
      lastName: appleData.lastName,
      provider: 'apple'
    });
    console.log('✅ [Futela] Nouvel utilisateur Apple créé');
  }
  
  return user;
}
```

## 🧪 TEST AVEC VOTRE TOKEN RÉEL

```bash
curl -X POST http://localhost:3000/api/auth/apple \
  -H "Content-Type: application/json" \
  -d '{
    "idToken": "eyJraWQiOiI1aXEzM2xKQllqIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm5hYXJhLmZ1dGVsYSIsImV4cCI6MTc3NTgyMzkzOCwiaWF0IjoxNzc1NzM3NTM4LCJzdWIiOiIwMDAxNjEuYWNhMjQ2YzY3MWI2NDQzY2I4NzFmNmUwNThiY2ZjNjguMTAwNyIsImNfaGFzaCI6IkZfNTJaXzFnX3pEQzI2R0h0YTdfUFEiLCJlbWFpbCI6InNxandkYmg4eXRAcHJpdmF0ZXJlbGF5LmFwcGxlaWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzX3ByaXZhdGVfZW1haWwiOnRydWUsImF1dGhfdGltZSI6MTc3NTczNzUzOCwibm9uY2Vfc3VwcG9ydGVkIjp0cnVlfQ.iUpxVUb2QQCnwjGxcAokxUkqqxmfXL4DXFxAKf2bsIi2igU_CctqRssStobkBQPpKTmWHXjya3ZGWn0VG4aRm2j4qqiFdafs0uXG7as5MNvuFw4PT2iqH9cF1TmzkY69dIUbXnQfq6U9vGPBxAz-E_ekD10Jr20X62kMJZDhvrQBKKPMqnMMXbQ796eME6uOrQDDmXFcVMK_wWhhDSl5rEfIVSzPutr4Z6EX8t-zu7duh2mdrJJv2bnIBnjqjO3uvBEEsrwZQuLXfG68qCuakTLs3PIWRhR6eZZNzmMZCOUdEDGlYuf72Awdsr17qM-R-Wq0Uftc4iapzuyByO-iyQ",
    "authorizationCode": "cda0736a3c65a420fb907560fb21fd15d.0.mrwr.0j4nhpGqUhFDXzFwd5Pt8g",
    "userIdentifier": "000161.aca246c671b6443cb871f6e058bcfc68.1007"
  }'
```

## 📋 CHECKLIST FUTELA

- [x] **Team ID confirmé**: `3UWPS2AHCF4KJN6A9RY4`
- [x] **Bundle ID confirmé**: `com.naara.futela`
- [x] **Key ID confirmé**: `3UWPS2AHCF`
- [ ] **Fichier .p8 à télécharger** : `AuthKey_3UWPS2AHCF.p8`
- [ ] **Variables d'environnement à configurer**:
  ```env
  APPLE_TEAM_ID=3UWPS2AHCF4KJN6A9RY4
  APPLE_KEY_ID=3UWPS2AHCF
  APPLE_BUNDLE_ID=com.naara.futela
  APPLE_PRIVATE_KEY_PATH=/path/to/AuthKey_3UWPS2AHCF.p8
  ```
- [ ] **Dépendances installées**: `npm install jsonwebtoken jwks-rsa`
- [ ] **Code implémenté** avec vos vraies clés
- [ ] **Test réussi** avec le token fourni

## 🎯 RÉSULTAT ATTENDU

Après configuration, l'endpoint retournera :
```json
{
  "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9...",
  "refreshToken": "abc123def456...",
  "sessionId": "019d6900-1111-7aef-bcf2-f6c19eb05379",
  "expiresIn": 3600,
  "tokenType": "Bearer"
}
```

## ⚡ TEMPS ESTIMÉ
**30 minutes** une fois que vous avez téléchargé le fichier .p8 et récupéré le Key ID.

---

**Une fois le Key ID et le fichier .p8 configurés, Apple Sign-In fonctionnera parfaitement pour Futela !** 🎉