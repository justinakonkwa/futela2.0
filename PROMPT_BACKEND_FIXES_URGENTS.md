# 🚨 Corrections urgentes Backend - API Futela

## 🐛 Problème 1 : Code de vérification non généré après paiement

### Description
Après qu'un visiteur paie une visite, **aucun code de vérification n'est généré automatiquement**. L'endpoint `/api/me/verification-codes` retourne un tableau vide `[]` alors que la visite est bien marquée comme payée (`isPaid: true`).

### Comportement actuel
1. Visiteur réserve une visite ✅
2. Visiteur paie la visite ✅
3. Visite marquée comme `isPaid: true` ✅
4. **Aucun code de vérification généré** ❌
5. `/api/me/verification-codes` retourne `[]` ❌

### Comportement attendu
1. Visiteur réserve une visite
2. Visiteur paie la visite
3. Visite marquée comme `isPaid: true`
4. **Code OTP à 6 chiffres généré automatiquement** ✅
5. `/api/me/verification-codes` retourne le code généré ✅

### Logs observés
```json
// GET /api/me/visits - Visite payée
{
  "id": "019d9672-d6e1-7caa-8538-616a8e744836",
  "isPaid": true,  ✅
  "paymentTransactionId": "019d9672-cde0-7887-a94c-326d8b2235df"
}

// GET /api/me/verification-codes - Aucun code
[]  ❌
```

### Ce qui doit être fait
Après confirmation du paiement (webhook), générer automatiquement un code de vérification avec :
- Code OTP unique à 6 chiffres
- Lié à la visite payée
- Lié au visiteur
- Lié à la propriété
- Montant et devise du paiement
- Date d'expiration (24h recommandé)

### Réponse attendue de `/api/me/verification-codes`
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

---

## 🐛 Problème 2 : Délégation de propriété non automatique

### Description
Lorsqu'un utilisateur crée une propriété, **il n'est pas automatiquement ajouté comme délégué** de cette propriété. Cela empêche le créateur de gérer sa propre propriété.

### Comportement actuel
1. Utilisateur crée une propriété ✅
2. Propriété créée avec succès ✅
3. **Aucune délégation créée** ❌
4. Utilisateur ne peut pas gérer sa propriété ❌

### Comportement attendu
1. Utilisateur crée une propriété
2. Propriété créée avec succès
3. **Délégation automatique créée pour le créateur** ✅
4. Utilisateur peut gérer sa propriété immédiatement ✅

### Ce qui doit être fait
Lors de la création d'une propriété, créer automatiquement une délégation pour l'utilisateur créateur avec :
- Lien vers la propriété créée
- Lien vers l'utilisateur créateur
- Permissions complètes (édition, suppression, gestion des visites, etc.)

### Impact
Sans cette délégation automatique :
- L'utilisateur ne peut pas modifier sa propre propriété
- L'utilisateur ne peut pas supprimer sa propriété
- L'utilisateur ne peut pas gérer les visites
- L'utilisateur ne peut pas voir les statistiques

---

## 🎯 Priorité

**🔴 CRITIQUE** - Ces deux problèmes bloquent des fonctionnalités essentielles :

1. **Code de vérification** : Bloque tout le workflow de commission (les commissionnaires ne peuvent pas vérifier leurs commissions)
2. **Délégation de propriété** : Empêche les utilisateurs de gérer leurs propres propriétés

---

## 📋 Checklist de vérification

### Problème 1 : Code de vérification
- [ ] Après paiement d'une visite, un code est généré automatiquement
- [ ] Le code est unique et à 6 chiffres
- [ ] `/api/me/verification-codes` retourne les codes actifs du visiteur
- [ ] Le code contient toutes les informations nécessaires (propertyTitle, amount, etc.)
- [ ] Le code peut être utilisé pour vérifier une commission

### Problème 2 : Délégation de propriété
- [ ] Après création d'une propriété, une délégation est créée automatiquement
- [ ] La délégation lie l'utilisateur créateur à sa propriété
- [ ] L'utilisateur peut modifier sa propriété
- [ ] L'utilisateur peut supprimer sa propriété
- [ ] L'utilisateur peut gérer les visites de sa propriété

---

## 🧪 Tests suggérés

### Test 1 : Code de vérification
1. Créer une visite
2. Payer la visite
3. Vérifier que `/api/me/verification-codes` retourne le code généré
4. Vérifier que le commissionnaire peut utiliser ce code pour valider sa commission

### Test 2 : Délégation de propriété
1. Créer une propriété
2. Vérifier que l'utilisateur peut modifier cette propriété
3. Vérifier que l'utilisateur peut supprimer cette propriété
4. Vérifier que l'utilisateur peut voir les visites de cette propriété

---

**Merci de corriger ces deux problèmes en priorité ! 🙏**
