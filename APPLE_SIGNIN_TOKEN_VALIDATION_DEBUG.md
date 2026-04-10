# Debug Apple Sign-In : Validation du Token

## Statut Actuel ✅

L'application mobile fonctionne correctement et envoie les bonnes données :

```json
{
  "idToken": "eyJraWQiOiI1aXEzM2xKQllqIiwiYWxnIjoiUlMyNTYifQ...",
  "authorizationCode": "cda0736a3c65a420fb907560fb21fd15d.0.mrwr.0j4nhpGqUhFDXzFwd5Pt8g",
  "userIdentifier": "000161.aca246c671b6443cb871f6e058bcfc68.1007"
}
```

## Problème Backend ❌

Le backend retourne : **"Jeton Apple invalide"** (401)

## Informations du Token Apple

En décodant le JWT token, voici les informations importantes :

```json
{
  "iss": "https://appleid.apple.com",
  "aud": "com.naara.futela",
  "exp": 1775823938,
  "iat": 1775737538,
  "sub": "000161.aca246c671b6443cb871f6e058bcfc68.1007",
  "email": "sqjwdbh8yt@privaterelay.appleid.com",
  "email_verified": true,
  "is_private_email": true
}
```

## Points de Vérification Backend

### 1. Bundle ID (Audience)
- ✅ **Correct** : `com.naara.futela`
- Le backend doit vérifier que `aud` = `com.naara.futela`

### 2. Émetteur (Issuer)
- ✅ **Correct** : `https://appleid.apple.com`
- Le backend doit vérifier que `iss` = `https://appleid.apple.com`

### 3. Signature du Token
- Le backend doit télécharger les clés publiques d'Apple depuis : `https://appleid.apple.com/auth/keys`
- Utiliser la clé avec `kid` = `5iq33lJBYj` pour valider la signature

### 4. Expiration
- ✅ **Valide** : Le token expire dans le futur
- `exp`: 1775823938 (timestamp Unix)

### 5. Email Privé Apple
- ✅ **Normal** : `is_private_email: true`
- L'email `sqjwdbh8yt@privaterelay.appleid.com` est un email de relais privé Apple

## Code Backend Recommandé

### Validation du Token Apple (Exemple)

```javascript
// 1. Récupérer les clés publiques d'Apple
const appleKeys = await fetch('https://appleid.apple.com/auth/keys').then(r => r.json());

// 2. Décoder le header du JWT pour obtenir le 'kid'
const header = jwt.decode(idToken, { complete: true }).header;
const key = appleKeys.keys.find(k => k.kid === header.kid);

// 3. Valider la signature
const decoded = jwt.verify(idToken, jwkToPem(key), {
  issuer: 'https://appleid.apple.com',
  audience: 'com.naara.futela'
});

// 4. Extraire les informations utilisateur
const userInfo = {
  appleId: decoded.sub,
  email: decoded.email,
  emailVerified: decoded.email_verified,
  isPrivateEmail: decoded.is_private_email
};
```

### Gestion des Emails Privés

```javascript
// Apple peut fournir des emails de relais privé
if (decoded.is_private_email) {
  // Utiliser l'email de relais fourni par Apple
  // Ne pas demander un "vrai" email à l'utilisateur
}
```

## Debugging Backend

### Logs à Ajouter

```javascript
console.log('Apple Token Header:', jwt.decode(idToken, { complete: true }).header);
console.log('Apple Token Payload:', jwt.decode(idToken));
console.log('Expected Audience:', 'com.naara.futela');
console.log('Token Audience:', decoded.aud);
console.log('Token Issuer:', decoded.iss);
console.log('Token Expiry:', new Date(decoded.exp * 1000));
```

### Vérifications Étape par Étape

1. **Le token peut-il être décodé ?**
2. **Les clés publiques Apple sont-elles récupérées ?**
3. **La signature est-elle valide ?**
4. **L'audience correspond-elle ?**
5. **L'émetteur est-il correct ?**
6. **Le token n'est-il pas expiré ?**

## Configuration Apple Developer

### Vérifier dans Apple Developer Console

1. **App ID** : `com.naara.futela`
2. **Sign In with Apple** : Activé
3. **Domains and Subdomains** : Configurés si nécessaire
4. **Return URLs** : Configurées si nécessaire

## Test Manuel

### Décoder le Token

Utiliser https://jwt.io pour décoder le token et vérifier :
- Header : `{"kid":"5iq33lJBYj","alg":"RS256"}`
- Payload : Contient `aud`, `iss`, `sub`, etc.

### Vérifier les Clés Apple

```bash
curl https://appleid.apple.com/auth/keys
```

Chercher la clé avec `kid` = `5iq33lJBYj`

## Résolution

Le problème est côté backend dans la validation du token Apple. L'application mobile fonctionne parfaitement et envoie des tokens valides.

**Action requise** : L'équipe backend doit implémenter correctement la validation des tokens Apple selon les spécifications d'Apple.