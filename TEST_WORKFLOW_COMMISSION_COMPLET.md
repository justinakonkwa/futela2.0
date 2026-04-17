# 🧪 Test du workflow complet de commission

## 📋 Vue d'ensemble

Ce document décrit comment tester le workflow complet de commission de bout en bout.

## 🎯 Workflow à tester

```
Visiteur réserve → Visiteur paie → Code généré → Commissionnaire vérifie → Commission payée
```

## 🔄 Étapes détaillées

### Étape 1 : Visiteur réserve une visite

**Endpoint** : `POST /api/properties/{propertyId}/visits`

**Request** :
```json
{
  "scheduledAt": "2026-04-17T15:00:00+02:00",
  "notes": "Je suis disponible toute la journée"
}
```

**Response attendue** :
```json
{
  "id": "019d9672-d6e1-7caa-8538-616a8e744836",
  "propertyId": "019d95f6-3222-7384-a92a-7879aa4bc993",
  "propertyTitle": "Maison base chambre salon",
  "visitorId": "019cf15f-f2c8-7554-85ea-cccda6d84b9a",
  "visitorName": "jaz alias",
  "scheduledAt": "2026-04-17T15:00:00+02:00",
  "status": "scheduled",
  "notes": "Je suis disponible toute la journée",
  "createdAt": "2026-04-16T15:20:01+02:00",
  "isPaid": false,  ← Pas encore payé
  "paymentTransactionId": null
}
```

✅ **Vérifications** :
- La visite est créée
- `isPaid` est `false`
- `status` est `"scheduled"`

---

### Étape 2 : Visiteur paie la visite

**Endpoint** : `POST /api/visits/{visitId}/payment`

**Request** :
```json
{
  "amount": 10.0,
  "currency": "USD",
  "paymentMethod": "mobile_money",
  "phoneNumber": "+243812345678"
}
```

**Response attendue** :
```json
{
  "paymentTransactionId": "019d9672-cde0-7887-a94c-326d8b2235df",
  "status": "pending",
  "checkoutUrl": "https://payment-provider.com/checkout/xxx"
}
```

✅ **Vérifications** :
- Transaction de paiement créée
- URL de paiement retournée

---

### Étape 3 : Webhook de confirmation de paiement

**Endpoint** : `POST /api/webhooks/payment` (appelé par le provider de paiement)

**Request** :
```json
{
  "transactionId": "019d9672-cde0-7887-a94c-326d8b2235df",
  "status": "completed",
  "amount": 10.0,
  "currency": "USD"
}
```

**Actions backend attendues** :
1. Marquer `visit.isPaid = true`
2. Mettre à jour `visit.paymentTransactionId`
3. **🔴 GÉNÉRER AUTOMATIQUEMENT LE CODE DE VÉRIFICATION** ← MANQUANT
4. Créer une entrée dans `verification_codes` :
   ```json
   {
     "code": "123456",  ← Code OTP à 6 chiffres
     "visitId": "019d9672-d6e1-7caa-8538-616a8e744836",
     "visitorId": "019cf15f-f2c8-7554-85ea-cccda6d84b9a",
     "propertyId": "019d95f6-3222-7384-a92a-7879aa4bc993",
     "propertyTitle": "Maison base chambre salon",
     "amount": 10.0,
     "currency": "USD",
     "expiresAt": "2026-04-18T15:20:01+02:00",  ← 24h après
     "isUsed": false
   }
   ```

✅ **Vérifications** :
- `visit.isPaid` est `true`
- Code de vérification créé dans la base de données
- Code est unique et à 6 chiffres

---

### Étape 4 : Visiteur récupère son code

**Endpoint** : `GET /api/me/verification-codes`

**Response attendue** :
```json
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

✅ **Vérifications** :
- Le code est retourné
- Toutes les informations sont présentes
- `isUsed` est `false`

---

### Étape 5 : Commissionnaire recherche la commission par téléphone

**Endpoint** : `GET /api/commissionnaire/commissions/search?phone=+243812345678`

**Response attendue** :
```json
{
  "id": "019d9672-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "visitId": "019d9672-d6e1-7caa-8538-616a8e744836",
  "propertyId": "019d95f6-3222-7384-a92a-7879aa4bc993",
  "propertyTitle": "Maison base chambre salon",
  "visitorPhone": "+243812345678",
  "visitorName": "jaz alias",
  "amount": 10.0,
  "currency": "USD",
  "rate": 0.05,  ← 5%
  "commissionAmount": 0.50,  ← 5% de 10.0
  "status": "pending",
  "isVerified": false,
  "scheduledAt": "2026-04-17T15:00:00+02:00",
  "createdAt": "2026-04-16T15:20:01+02:00"
}
```

✅ **Vérifications** :
- Commission trouvée par téléphone
- `status` est `"pending"`
- `isVerified` est `false`
- `commissionAmount` est calculé correctement

---

### Étape 6 : Commissionnaire vérifie avec le code

**Endpoint** : `POST /api/commissionnaire/commissions/{commissionId}/verify`

**Request** :
```json
{
  "code": "123456"
}
```

**Response attendue** :
```json
{
  "id": "019d9672-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "visitId": "019d9672-d6e1-7caa-8538-616a8e744836",
  "propertyId": "019d95f6-3222-7384-a92a-7879aa4bc993",
  "propertyTitle": "Maison base chambre salon",
  "visitorPhone": "+243812345678",
  "visitorName": "jaz alias",
  "amount": 10.0,
  "currency": "USD",
  "rate": 0.05,
  "commissionAmount": 0.50,
  "status": "verified",  ← Changé de "pending" à "verified"
  "isVerified": true,  ← Changé de false à true
  "verifiedAt": "2026-04-16T16:00:00+02:00",  ← Date de vérification
  "scheduledAt": "2026-04-17T15:00:00+02:00",
  "createdAt": "2026-04-16T15:20:01+02:00"
}
```

**Actions backend attendues** :
1. Vérifier que le code existe et correspond à la commission
2. Vérifier que le code n'est pas expiré
3. Vérifier que le code n'a pas déjà été utilisé
4. Marquer `commission.isVerified = true`
5. Mettre à jour `commission.status = "verified"`
6. Mettre à jour `commission.verifiedAt = now()`
7. Marquer `verificationCode.isUsed = true`
8. Mettre à jour `verificationCode.usedAt = now()`
9. **Ajouter le montant au wallet du commissionnaire**

✅ **Vérifications** :
- Commission marquée comme vérifiée
- Code marqué comme utilisé
- Wallet du commissionnaire mis à jour

---

### Étape 7 : Commissionnaire vérifie son wallet

**Endpoint** : `GET /api/commissionnaire/wallet`

**Response attendue** :
```json
{
  "balance": 0.50,  ← Montant de la commission ajouté
  "pendingAmount": 0.0,
  "totalEarned": 0.50,
  "totalWithdrawn": 0.0,
  "currency": "USD",
  "lastUpdated": "2026-04-16T16:00:00+02:00"
}
```

✅ **Vérifications** :
- `balance` a augmenté de `commissionAmount`
- `totalEarned` a augmenté de `commissionAmount`

---

## 🚨 Cas d'erreur à tester

### Erreur 1 : Code invalide

**Request** :
```json
POST /api/commissionnaire/commissions/{commissionId}/verify
{
  "code": "999999"  ← Code qui n'existe pas
}
```

**Response attendue** :
```json
{
  "error": {
    "message": "Code de vérification invalide",
    "code": 400
  }
}
```

---

### Erreur 2 : Code expiré

**Request** :
```json
POST /api/commissionnaire/commissions/{commissionId}/verify
{
  "code": "123456"  ← Code expiré
}
```

**Response attendue** :
```json
{
  "error": {
    "message": "Code de vérification expiré",
    "code": 400
  }
}
```

---

### Erreur 3 : Code déjà utilisé

**Request** :
```json
POST /api/commissionnaire/commissions/{commissionId}/verify
{
  "code": "123456"  ← Code déjà utilisé
}
```

**Response attendue** :
```json
{
  "error": {
    "message": "Code de vérification déjà utilisé",
    "code": 400
  }
}
```

---

### Erreur 4 : Code ne correspond pas à la commission

**Request** :
```json
POST /api/commissionnaire/commissions/{wrongCommissionId}/verify
{
  "code": "123456"  ← Code valide mais pour une autre commission
}
```

**Response attendue** :
```json
{
  "error": {
    "message": "Code de vérification ne correspond pas à cette commission",
    "code": 400
  }
}
```

---

## 📊 Résumé des vérifications

| Étape | Endpoint | Statut actuel | Action requise |
|-------|----------|---------------|----------------|
| 1. Réserver visite | POST /api/properties/{id}/visits | ✅ Fonctionne | - |
| 2. Payer visite | POST /api/visits/{id}/payment | ✅ Fonctionne | - |
| 3. Webhook paiement | POST /api/webhooks/payment | ⚠️ Partiel | **Ajouter génération code** |
| 4. Récupérer codes | GET /api/me/verification-codes | ❌ Vide | **Retourner codes générés** |
| 5. Chercher commission | GET /api/commissionnaire/commissions/search | ✅ Fonctionne | - |
| 6. Vérifier commission | POST /api/commissionnaire/commissions/{id}/verify | ✅ Fonctionne | - |
| 7. Voir wallet | GET /api/commissionnaire/wallet | ✅ Fonctionne | - |

---

## 🎯 Action prioritaire

**Implémenter la génération automatique du code de vérification dans le webhook de paiement (Étape 3)**

Une fois cette étape implémentée, tout le workflow fonctionnera de bout en bout ! 🚀
