# 🐛 Problème : Code de vérification non généré après paiement

## 📋 Description du problème

Après qu'un visiteur paie une visite, **aucun code de vérification n'est généré automatiquement**.

## 🔍 Logs observés

```
flutter: URL: https://api.futela.com/api/me/visits?page=1&itemsPerPage=20
flutter: 📅 GET MY VISITS RESPONSE
flutter: Status Code: 200
flutter: Body: {
  "member": [
    {
      "id": "019d95fb-822e-7b7b-8a35-1323bfefdd02",
      "propertyId": "019d95f6-3222-7384-a92a-7879aa4bc993",
      "propertyTitle": "Maison base chambre salon",
      "visitorId": "019cf15f-f2c8-7554-85ea-cccda6d84b9a",
      "visitorName": "jaz alias",
      "scheduledAt": "2026-04-17T15:00:00+02:00",
      "status": "scheduled",
      "notes": "disponible a la dinde la journée",
      "createdAt": "2026-04-16T13:09:41+02:00",
      "isPaid": false,  ← ❌ Pas payé
      "paymentTransactionId": "019d95fb-7965-77b9-8794-24ed825d4233"
    },
    {
      "id": "019d9672-d6e1-7caa-8538-616a8e744836",
      "propertyId": "019d95f6-3222-7384-a92a-7879aa4bc993",
      "propertyTitle": "Maison base chambre salon",
      "visitorId": "019cf15f-f2c8-7554-85ea-cccda6d84b9a",
      "visitorName": "jaz alias",
      "scheduledAt": "2026-04-17T14:00:00+02:00",
      "status": "scheduled",
      "notes": "Maison basse nouvellement construit",
      "createdAt": "2026-04-16T15:20:01+02:00",
      "isPaid": true,  ← ✅ Payé
      "paymentTransactionId": "019d9672-cde0-7887-a94c-326d8b2235df"
    }
  ]
}

flutter: --> GET /api/me/verification-codes
flutter: <-- 200 /api/me/verification-codes
flutter: verification-codes ← 200: []  ← ❌ TABLEAU VIDE !
```

## ❌ Problème identifié

1. ✅ La visite est bien créée
2. ✅ Le paiement est bien enregistré (`isPaid: true`)
3. ❌ **Le code de vérification n'est PAS généré automatiquement**
4. ❌ L'endpoint `/api/me/verification-codes` retourne un tableau vide

## 🎯 Comportement attendu

Après le paiement d'une visite, le backend devrait **automatiquement** :

1. Générer un code OTP unique (6 chiffres)
2. Créer une entrée dans la table `verification_codes` avec :
   - `code`: Le code OTP généré
   - `visitId`: L'ID de la visite payée
   - `visitorId`: L'ID du visiteur
   - `propertyId`: L'ID de la propriété
   - `propertyTitle`: Le titre de la propriété
   - `amount`: Le montant payé
   - `currency`: La devise (USD, CDF, etc.)
   - `expiresAt`: Date d'expiration (optionnel, ex: 24h après création)
   - `isUsed`: false (par défaut)
   - `createdAt`: Date de création

3. Retourner ce code dans la réponse de `/api/me/verification-codes`

## 📊 Structure attendue de la réponse

```json
GET /api/me/verification-codes

[
  {
    "id": "019d9672-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
    "code": "123456",
    "visitId": "019d9672-d6e1-7caa-8538-616a8e744836",
    "propertyId": "019d95f6-3222-7384-a92a-7879aa4bc993",
    "propertyTitle": "Maison base chambre salon",
    "amount": 10.0,
    "currency": "USD",
    "expiresAt": "2026-04-18T15:20:01+02:00",
    "isUsed": false,
    "createdAt": "2026-04-16T15:20:01+02:00"
  }
]
```

## 🔧 Solution backend requise

### Option 1 : Génération automatique lors du paiement (RECOMMANDÉ)

Modifier le webhook/callback de paiement pour générer automatiquement le code :

```php
// Après confirmation du paiement
if ($payment->status === 'completed') {
    // Marquer la visite comme payée
    $visit->isPaid = true;
    $visit->save();
    
    // Générer automatiquement le code de vérification
    $verificationCode = VerificationCode::create([
        'code' => $this->generateOTP(), // Générer un code à 6 chiffres
        'visitId' => $visit->id,
        'visitorId' => $visit->visitorId,
        'propertyId' => $visit->propertyId,
        'propertyTitle' => $visit->property->title,
        'amount' => $payment->amount,
        'currency' => $payment->currency,
        'expiresAt' => now()->addHours(24), // Expire après 24h
        'isUsed' => false,
    ]);
}

private function generateOTP(): string {
    return str_pad(random_int(0, 999999), 6, '0', STR_PAD_LEFT);
}
```

### Option 2 : Endpoint manuel de génération

Si la génération automatique n'est pas possible, créer un endpoint :

```
POST /api/visits/{visitId}/generate-code
```

Mais cette option est **moins recommandée** car elle nécessite une action manuelle.

## 🔄 Workflow complet

```
1. Visiteur réserve une visite
   ↓
2. Visiteur paie la visite
   ↓
3. Backend reçoit confirmation de paiement
   ↓
4. Backend marque visit.isPaid = true
   ↓
5. Backend génère automatiquement un code OTP ← ❌ MANQUANT
   ↓
6. Backend sauvegarde le code dans verification_codes
   ↓
7. Visiteur appelle GET /api/me/verification-codes
   ↓
8. Backend retourne le code généré
   ↓
9. Visiteur affiche le code dans l'app
   ↓
10. Commissionnaire scanne/saisit le code
    ↓
11. Backend valide le code et marque la commission comme vérifiée
```

## 📱 Côté Frontend (déjà implémenté)

Le frontend est **déjà prêt** à afficher les codes :

1. ✅ Écran `VisitorCodesScreen` pour afficher les codes
2. ✅ Provider `CommissionProvider` pour charger les codes
3. ✅ Service `CommissionService` pour appeler l'API
4. ✅ Design moderne avec gradient et informations complètes
5. ✅ Gestion de l'expiration des codes
6. ✅ Pull-to-refresh pour recharger les codes

**Il manque juste la génération côté backend !**

## 🧪 Test de vérification

Pour vérifier que le problème est résolu :

1. Créer une visite
2. Payer la visite
3. Appeler `GET /api/me/verification-codes`
4. Vérifier que le tableau contient le code généré
5. Vérifier que le code a les bonnes informations (propertyTitle, amount, etc.)

## 📞 Action requise

**Backend doit implémenter la génération automatique du code de vérification après le paiement d'une visite.**

---

## 📝 Informations complémentaires

### Endpoint actuel qui fonctionne

```
GET /api/me/verification-codes
```
- ✅ Retourne 200
- ❌ Retourne un tableau vide au lieu des codes

### Endpoint de vérification (déjà implémenté)

```
POST /api/commissionnaire/commissions/{id}/verify
Body: { "code": "123456" }
```
- ✅ Fonctionne correctement
- ✅ Valide le code et marque la commission comme vérifiée

### Table de base de données suggérée

```sql
CREATE TABLE verification_codes (
    id VARCHAR(36) PRIMARY KEY,
    code VARCHAR(6) NOT NULL,
    visit_id VARCHAR(36) NOT NULL,
    visitor_id VARCHAR(36) NOT NULL,
    property_id VARCHAR(36) NOT NULL,
    property_title VARCHAR(255) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    expires_at TIMESTAMP NULL,
    is_used BOOLEAN DEFAULT FALSE,
    used_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (visit_id) REFERENCES visits(id),
    FOREIGN KEY (visitor_id) REFERENCES users(id),
    FOREIGN KEY (property_id) REFERENCES properties(id),
    
    INDEX idx_visitor (visitor_id),
    INDEX idx_code (code),
    INDEX idx_is_used (is_used)
);
```

---

**Priorité : 🔴 HAUTE - Bloque le workflow de commission**
