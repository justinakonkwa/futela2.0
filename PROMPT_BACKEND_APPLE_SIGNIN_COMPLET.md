# 🍎 PROMPT BACKEND - Configuration Apple Sign-In COMPLÈTE

## 🚨 PROBLÈME URGENT

L'endpoint `/api/auth/apple` retourne **"Jeton Apple invalide" (401)** alors que l'application mobile envoie des tokens Apple parfaitement valides.

**DIAGNOSTIC :** Il manque la configuration Apple Sign-In complète côté backend.

## 📱 INFORMATIONS PROJET FUTELA - CLÉS RÉELLES

### 🔑 **Clés et Identifiants Confirmés - PROJET FUTELA**
```
Bundle ID: com.naara.futela
App Name: Futela
Package Android: com.naara.futela
Project ID: futela
Project Number: 474613582555
Version Code: 6
Version Name: 1.0.1
```

### 🔑 **Configuration Apple Sign-In Mobile (Déjà Active)**
```
Bundle ID: com.naara.futela
Apple Sign-In Capability: ✅ Activée (com.apple.developer.applesignin = Default)
iOS Entitlements: ✅ Configurés
Scopes demandés: email, fullName
```

### 🔑 **Clés Google OAuth (Déjà Configurées et Fonctionnelles)**
```
Google Web Client ID (Backend): 474613582555-etdekl4un7r2r11u08h1jv2jelg3br0q.apps.googleusercontent.com
Google iOS Client ID: 474613582555-hhr7atbpp8uesekpevt69gav51a8ep5c.apps.googleusercontent.com
Google Android Client ID: 474613582555-t7p56t9dejfjfa2fovv8f4jc7ospogbm.apps.googleusercontent.com
URL Scheme iOS: com.googleusercontent.apps.474613582555-hhr7atbpp8uesekpevt69gav51a8ep5c
```

### 🔑 **Endpoints API Futela (Déjà Configurés)**
```
Apple Sign-In: POST /api/auth/apple
Google Sign-In: POST /api/auth/google
User Profile: GET /api/auth/me
Token Refresh: POST /api/auth/refresh
Logout: POST /api/auth/logout
```

### 📋 **Configuration Apple Developer Requise**
Vous devez récupérer ces informations depuis votre Apple Developer Console :

```env
# À RÉCUPÉRER DEPUIS APPLE DEVELOPER CONSOLE
APPLE_TEAM_ID=XXXXXXXXXX          # Format: 10 caractères (ex: 6MPDV0UYYX)
APPLE_KEY_ID=XXXXXXXXXX           # Format: 10 caractères (ex: ABCDE12345)
APPLE_BUNDLE_ID=com.naara.futela  # ✅ CONFIRMÉ
APPLE_PRIVATE_KEY_PATH=/path/to/AuthKey_KEYID.p8

# CLÉS GOOGLE DÉJÀ DISPONIBLES
GOOGLE_WEB_CLIENT_ID=474613582555-etdekl4un7r2r11u08h1jv2jelg3br0q.apps.googleusercontent.com
GOOGLE_IOS_CLIENT_ID=474613582555-hhr7atbpp8uesekpevt69gav51a8ep5c.apps.googleusercontent.com
GOOGLE_ANDROID_CLIENT_ID=474613582555-t7p56t9dejfjfa2fovv8f4jc7ospogbm.apps.googleusercontent.com
PROJECT_ID=futela
PROJECT_NUMBER=474613582555
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
  "idToken": "eyJraWQiOiI1aXEzM2xKQllqIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm5hYXJhLmZ1dGVsYSIsImV4cCI6MTc3NTgyMzkzOCwiaWF0IjoxNzc1NzM3NTM4LCJzdWIiOiIwMDAxNjEuYWNhMjQ2YzY3MWI2NDQzY2I4NzFmNmUwNThiY2ZjNjguMTAwNyIsImNfaGFzaCI6IkZfNTJaXzFnX3pEQzI2R0h0YTdfUFEiLCJlbWFpbCI6InNxandkYmg4eXRAcHJpdmF0ZXJlbGF5LmFwcGxlaWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzX3ByaXZhdGVfZW1haWwiOnRydWUsImF1dGhfdGltZSI6MTc3NTczNzUzOCwibm9uY2Vfc3VwcG9ydGVkIjp0cnVlfQ.iUpxVUb2QQCnwjGxcAokxUkqqxmfXL4DXFxAKf2bsIi2igU_CctqRssStobkBQPpKTmWHXjya3ZGWn0VG4aRm2j4qqiFdafs0uXG7as5MNvuFw4PT2iqH9cF1TmzkY69dIUbXnQfq6U9vGPBxAz-E_ekD10Jr20X62kMJZDhvrQBKKPMqnMMXbQ796eME6uOrQDDmXFcVMK_wWhhDSl5rEfIVSzPutr4Z6EX8t-zu7duh2mdrJJv2bnIBnjqjO3uvBEEsrwZQuLXfG68qCuakTLs3PIWRhR6eZZNzmMZCOUdEDGlYuf72Awdsr17qM-R-Wq0Uftc4iapzuyByO-iyQ",
  "authorizationCode": "cda0736a3c65a420fb907560fb21fd15d.0.mrwr.0j4nhpGqUhFDXzFwd5Pt8g",
  "userIdentifier": "000161.aca246c671b6443cb871f6e058bcfc68.1007"
}
```

**Token décodé (valide) :**
```json
{
  "iss": "https://appleid.apple.com",     ✅ Correct
  "aud": "com.naara.futela",              ✅ Bundle ID correct
  "sub": "000161.aca246c671b6443cb871f6e058bcfc68.1007",
  "email": "sqjwdbh8yt@privaterelay.appleid.com",
  "email_verified": true,
  "is_private_email": true,               ✅ Email privé Apple normal
  "exp": 1775823938,                      ✅ Token non expiré
  "kid": "5iq33lJBYj"                     ✅ Clé Apple valide
}
```

## 🔧 CONFIGURATION BACKEND COMPLÈTE

### 1. EXEMPLE AVEC VOS VRAIES CLÉS

**Remplacez par vos vraies valeurs :**

```env
# EXEMPLE - REMPLACEZ PAR VOS VRAIES VALEURS
APPLE_TEAM_ID=6MPDV0UYYX              # Votre Team ID (10 caractères)
APPLE_KEY_ID=ABCDE12345               # Votre Key ID (10 caractères)
APPLE_BUNDLE_ID=com.naara.futela      # ✅ Bundle ID confirmé
APPLE_PRIVATE_KEY_PATH=/path/to/AuthKey_ABCDE12345.p8
```

### 2. FICHIER .P8 EXEMPLE

**Votre fichier .p8 ressemble à ça :**
```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
[CONTENU DE VOTRE CLÉ PRIVÉE]
...
-----END PRIVATE KEY-----
```

### 3. CODE BACKEND COMPLET AVEC VOS CLÉS

#### Installation dépendances :
```bash
# Node.js
npm install jsonwebtoken jwks-rsa

# Python
pip install PyJWT cryptography requests

# PHP
composer require firebase/php-jwt
```

#### Implémentation Node.js COMPLÈTE :

```javascript
const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
const fs = require('fs');

// ✅ CONFIGURATION FUTELA - REMPLACEZ PAR VOS VRAIES VALEURS
const APPLE_CONFIG = {
  teamId: process.env.APPLE_TEAM_ID,        // Ex: '6MPDV0UYYX'
  keyId: process.env.APPLE_KEY_ID,          // Ex: 'ABCDE12345'
  bundleId: 'com.naara.futela',             // ✅ Bundle ID confirmé
  privateKeyPath: process.env.APPLE_PRIVATE_KEY_PATH  // '/path/to/AuthKey_ABCDE12345.p8'
};

// Client pour clés publiques Apple
const client = jwksClient({
  jwksUri: 'https://appleid.apple.com/auth/keys',
  cache: true,
  cacheMaxEntries: 5,
  cacheMaxAge: 600000 // 10 minutes
});

// 1. Valider le identity token avec les clés publiques Apple
function validateAppleToken(idToken) {
  return new Promise((resolve, reject) => {
    // Décoder le header pour obtenir le kid
    const decoded = jwt.decode(idToken, { complete: true });
    
    if (!decoded) {
      return reject(new Error('Token invalide - impossible de décoder'));
    }

    console.log('🔍 Token Header:', decoded.header);
    console.log('🔍 Token Kid:', decoded.header.kid);
    
    // Récupérer la clé publique Apple correspondante
    client.getSigningKey(decoded.header.kid, (err, key) => {
      if (err) {
        console.error('❌ Erreur récupération clé Apple:', err);
        return reject(err);
      }
      
      const signingKey = key.publicKey || key.rsaPublicKey;
      console.log('✅ Clé publique Apple récupérée');
      
      // Valider le token avec la clé publique Apple
      jwt.verify(idToken, signingKey, {
        issuer: 'https://appleid.apple.com',
        audience: 'com.naara.futela',
        algorithms: ['RS256']
      }, (err, payload) => {
        if (err) {
          console.error('❌ Erreur validation token:', err);
          reject(err);
        } else {
          console.log('✅ Token Apple validé avec succès');
          resolve(payload);
        }
      });
    });
  });
}

// 2. Créer client secret avec votre clé privée .p8
function createClientSecret() {
  try {
    const privateKey = fs.readFileSync(APPLE_CONFIG.privateKeyPath, 'utf8');
    const now = Math.floor(Date.now() / 1000);
    
    const payload = {
      iss: APPLE_CONFIG.teamId,     // Votre Team ID
      iat: now,
      exp: now + 3600,              // Expire dans 1 heure
      aud: 'https://appleid.apple.com',
      sub: APPLE_CONFIG.bundleId    // com.naara.futela
    };

    const clientSecret = jwt.sign(payload, privateKey, {
      algorithm: 'ES256',
      keyid: APPLE_CONFIG.keyId     // Votre Key ID
    });

    console.log('✅ Client secret créé avec succès');
    return clientSecret;
    
  } catch (error) {
    console.error('❌ Erreur création client secret:', error);
    throw error;
  }
}

// 3. Validation optionnelle avec Apple Server
async function validateWithAppleServer(authorizationCode) {
  try {
    const clientSecret = createClientSecret();
    
    const response = await fetch('https://appleid.apple.com/auth/token', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: new URLSearchParams({
        client_id: APPLE_CONFIG.bundleId,
        client_secret: clientSecret,
        code: authorizationCode,
        grant_type: 'authorization_code'
      })
    });

    if (!response.ok) {
      const errorText = await response.text();
      throw new Error(`Apple server validation failed: ${response.status} - ${errorText}`);
    }

    const result = await response.json();
    console.log('✅ Validation Apple server réussie');
    return result;
    
  } catch (error) {
    console.error('❌ Erreur validation Apple server:', error);
    throw error;
  }
}

// 4. Endpoint Apple Sign-In COMPLET
app.post('/api/auth/apple', async (req, res) => {
  console.log('🍎 [Apple Sign-In] Début validation backend');
  
  try {
    const { idToken, authorizationCode, userIdentifier } = req.body;

    // Vérifier les données reçues
    if (!idToken) {
      return res.status(400).json({
        error: { message: 'idToken manquant', code: 400 }
      });
    }

    console.log('📥 Données reçues:', {
      idToken: idToken ? 'présent' : 'manquant',
      authorizationCode: authorizationCode ? 'présent' : 'manquant',
      userIdentifier: userIdentifier || 'manquant'
    });

    // 1. Valider le token Apple avec les clés publiques
    const appleUser = await validateAppleToken(idToken);
    
    console.log('✅ Utilisateur Apple validé:', {
      appleId: appleUser.sub,
      email: appleUser.email,
      emailVerified: appleUser.email_verified,
      isPrivateEmail: appleUser.is_private_email
    });

    // 2. Optionnel : Validation supplémentaire avec Apple server
    // const appleServerResponse = await validateWithAppleServer(authorizationCode);

    // 3. Créer ou récupérer l'utilisateur dans votre DB
    const user = await findOrCreateUser({
      appleId: appleUser.sub,
      email: appleUser.email,
      emailVerified: appleUser.email_verified,
      isPrivateEmail: appleUser.is_private_email,
      // Gérer les noms si disponibles (première connexion uniquement)
      firstName: req.body.firstName || null,
      lastName: req.body.lastName || null
    });

    // 4. Générer vos tokens d'authentification
    const accessToken = generateYourAccessToken(user);
    const refreshToken = generateYourRefreshToken(user);
    const sessionId = generateSessionId();

    console.log('✅ Authentification Apple réussie pour:', user.id);

    // 5. Réponse de succès
    res.json({
      accessToken,
      refreshToken,
      sessionId,
      expiresIn: 3600,
      tokenType: 'Bearer'
    });

  } catch (error) {
    console.error('❌ Erreur Apple Sign-In:', error.message);
    console.error('❌ Stack:', error.stack);
    
    res.status(401).json({
      error: {
        message: 'Erreur de validation Apple',
        code: 401,
        details: error.message
      }
    });
  }
});

// Fonction helper pour créer/récupérer utilisateur
async function findOrCreateUser(appleData) {
  // Chercher utilisateur existant par Apple ID
  let user = await User.findOne({ appleId: appleData.appleId });
  
  if (!user) {
    // Créer nouvel utilisateur
    user = await User.create({
      appleId: appleData.appleId,
      email: appleData.email,
      emailVerified: appleData.emailVerified,
      isPrivateEmail: appleData.isPrivateEmail,
      firstName: appleData.firstName,
      lastName: appleData.lastName,
      provider: 'apple'
    });
    console.log('✅ Nouvel utilisateur Apple créé:', user.id);
  } else {
    console.log('✅ Utilisateur Apple existant trouvé:', user.id);
  }
  
  return user;
}
```

## 🧪 TEST AVEC TOKEN RÉEL FUTELA

**Utilisez exactement ce token des logs pour tester :**

```bash
curl -X POST http://localhost:3000/api/auth/apple \
  -H "Content-Type: application/json" \
  -d '{
    "idToken": "eyJraWQiOiI1aXEzM2xKQllqIiwiYWxnIjoiUlMyNTYifQ.eyJpc3MiOiJodHRwczovL2FwcGxlaWQuYXBwbGUuY29tIiwiYXVkIjoiY29tLm5hYXJhLmZ1dGVsYSIsImV4cCI6MTc3NTgyMzkzOCwiaWF0IjoxNzc1NzM3NTM4LCJzdWIiOiIwMDAxNjEuYWNhMjQ2YzY3MWI2NDQzY2I4NzFmNmUwNThiY2ZjNjguMTAwNyIsImNfaGFzaCI6IkZfNTJaXzFnX3pEQzI2R0h0YTdfUFEiLCJlbWFpbCI6InNxandkYmg4eXRAcHJpdmF0ZXJlbGF5LmFwcGxlaWQuY29tIiwiZW1haWxfdmVyaWZpZWQiOnRydWUsImlzX3ByaXZhdGVfZW1haWwiOnRydWUsImF1dGhfdGltZSI6MTc3NTczNzUzOCwibm9uY2Vfc3VwcG9ydGVkIjp0cnVlfQ.iUpxVUb2QQCnwjGxcAokxUkqqxmfXL4DXFxAKf2bsIi2igU_CctqRssStobkBQPpKTmWHXjya3ZGWn0VG4aRm2j4qqiFdafs0uXG7as5MNvuFw4PT2iqH9cF1TmzkY69dIUbXnQfq6U9vGPBxAz-E_ekD10Jr20X62kMJZDhvrQBKKPMqnMMXbQ796eME6uOrQDDmXFcVMK_wWhhDSl5rEfIVSzPutr4Z6EX8t-zu7duh2mdrJJv2bnIBnjqjO3uvBEEsrwZQuLXfG68qCuakTLs3PIWRhR6eZZNzmMZCOUdEDGlYuf72Awdsr17qM-R-Wq0Uftc4iapzuyByO-iyQ",
    "authorizationCode": "cda0736a3c65a420fb907560fb21fd15d.0.mrwr.0j4nhpGqUhFDXzFwd5Pt8g",
    "userIdentifier": "000161.aca246c671b6443cb871f6e058bcfc68.1007"
  }'
```

## ⚠️ POINTS CRITIQUES FUTELA

1. **Bundle ID EXACT** : `com.naara.futela` (ne pas changer)
2. **Fichier .p8 OBLIGATOIRE** - Sans lui, impossible de valider
3. **Team ID et Key ID exacts** - Une erreur = échec total
4. **Emails privés Apple** - `sqjwdbh8yt@privaterelay.appleid.com` est normal
5. **Endpoint PUBLIC** - Pas de JWT requis pour `/api/auth/apple`

## 🎯 RÉSULTAT ATTENDU FUTELA

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

## 📋 CHECKLIST FUTELA

- [ ] **Team ID récupéré** depuis Apple Developer Console (format: 10 caractères)
- [ ] **Key ID récupéré** depuis la clé .p8 (format: 10 caractères)
- [ ] **Fichier .p8 téléchargé** et accessible au serveur
- [ ] **Variables d'environnement configurées** avec vos vraies valeurs
- [ ] **Bundle ID vérifié** : `com.naara.futela`
- [ ] **Sign In with Apple activé** pour le Bundle ID
- [ ] **Dépendances JWT installées**
- [ ] **Code de validation implémenté**
- [ ] **Endpoint `/api/auth/apple` accessible publiquement**
- [ ] **Test avec le token fourni réussi**

## 🚀 TEMPS ESTIMÉ

**2-3 heures** pour configuration complète et tests avec vos vraies clés.

## 📞 SUPPORT FUTELA

Si problèmes avec vos clés :
1. **Vérifier Team ID** : https://developer.apple.com/account/#/membership
2. **Vérifier Key ID** : Dans le nom du fichier .p8 téléchargé
3. **Vérifier Bundle ID** : Doit être exactement `com.naara.futela`
4. **Tester validation** avec le token fourni des logs
5. **Vérifier logs détaillés** pour identifier l'étape qui échoue

**Une fois vos vraies clés configurées, Apple Sign-In fonctionnera parfaitement !** 🎉