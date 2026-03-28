# Guide de Migration API — Développeur Mobile

> **Date :** 18/03/2026
> **Version :** v2.0 — Nouveau format de pagination + Paiement de visite
> **Impact :** Toutes les routes retournant des listes + nouvelles routes paiement

---

## Table des matières

1. [Changement global : Format de pagination](#1-changement-global--format-de-pagination)
2. [Nouvelle route : Statut de paiement de visite](#2-nouvelle-route--statut-de-paiement-de-visite)
3. [Mise à jour : Création de visite avec paiement](#3-mise-à-jour--création-de-visite-avec-paiement)
4. [Mise à jour : Liste des visites avec filtres](#4-mise-à-jour--liste-des-visites-avec-filtres)
5. [Nouvelles routes : Administration des devises](#5-nouvelles-routes--administration-des-devises)
6. [Nouvelles routes : Transactions](#6-nouvelles-routes--transactions)
7. [Flow complet : Paiement de visite avec polling](#7-flow-complet--paiement-de-visite-avec-polling)
8. [Webhook FlexPay : Fonctionnement et intégration](#8-webhook-flexpay--fonctionnement-et-intégration)
9. [Routes supprimées](#9-routes-supprimées)
10. [Checklist de migration](#10-checklist-de-migration)

---

## 1. Changement global : Format de pagination

**Impact : TOUTES les routes qui retournent des listes.**

L'ancien format Hydra/JSON-LD est remplacé par un format simplifié. Ce changement concerne toutes les routes paginées de l'API sans exception.

### Ancien format (à supprimer)

```json
{
  "@context": "/api/contexts/Property",
  "@id": "/api/properties",
  "@type": "hydra:Collection",
  "hydra:member": [
    { "..." }
  ],
  "hydra:totalItems": 50,
  "hydra:view": {
    "@id": "/api/properties?page=1",
    "@type": "hydra:PartialCollectionView",
    "hydra:first": "/api/properties?page=1",
    "hydra:last": "/api/properties?page=2",
    "hydra:next": "/api/properties?page=2"
  }
}
```

### Nouveau format

```json
{
  "member": [
    { "..." }
  ],
  "totalItems": 50,
  "page": 1,
  "itemsPerPage": 30,
  "totalPages": 2
}
```

### Correspondance des champs

| Ancien champ | Nouveau champ | Type | Description |
|---|---|---|---|
| `hydra:member` | `member` | `array` | Liste des éléments de la page courante |
| `hydra:totalItems` | `totalItems` | `integer` | Nombre total d'éléments toutes pages confondues |
| _(n'existait pas)_ | `page` | `integer` | Numéro de la page courante (commence à 1) |
| _(n'existait pas)_ | `itemsPerPage` | `integer` | Nombre d'éléments par page (défaut : 30) |
| _(n'existait pas)_ | `totalPages` | `integer` | Nombre total de pages |
| `hydra:view.hydra:next` | _(supprimé)_ | — | Calculer côté client : `page < totalPages` |
| `hydra:view.hydra:previous` | _(supprimé)_ | — | Calculer côté client : `page > 1` |
| `@context`, `@id`, `@type` | _(supprimés)_ | — | Plus de métadonnées JSON-LD dans les wrappers |

### Routes concernées

| Module | Routes paginées |
|---|---|
| **Propriétés** | `GET /properties`, `GET /properties/search`, `GET /me/properties`, `GET /categories`, `GET /me/favorites` |
| **Réservations** | `GET /reservations`, `GET /me/reservations`, `GET /me/bookings`, `GET /properties/{id}/reservations` |
| **Visites** | `GET /visits`, `GET /me/visits` |
| **Adresses** | `GET /countries`, `GET /provinces`, `GET /cities`, `GET /towns`, `GET /districts` |
| **Baux** | `GET /leases`, `GET /me/leases`, `GET /landlord/leases` |
| **Factures** | `GET /rent-invoices`, `GET /me/rent-invoices`, `GET /landlord/rent-invoices` |
| **Paiements loyer** | `GET /rent-payments`, `GET /me/rent-payments`, `GET /landlord/rent-payments` |
| **Transactions** | `GET /transactions`, `GET /me/transactions` |
| **Devises** | `GET /currencies` |
| **Avis** | `GET /reviews`, `GET /properties/{id}/reviews`, `GET /me/reviews` |
| **Messagerie** | `GET /conversations`, `GET /conversations/{id}/messages`, `GET /notifications` |

### Comment adapter le client mobile

#### Android / Kotlin

**Modèle de données :**
```kotlin
data class PaginatedResponse<T>(
    val member: List<T>,
    val totalItems: Int,
    val page: Int,
    val itemsPerPage: Int,
    val totalPages: Int
)
```

**Avant :**
```kotlin
val items = response.body()?.get("hydra:member") as List<Item>
val total = response.body()?.get("hydra:totalItems") as Int
val hasNext = response.body()
    ?.getJSONObject("hydra:view")
    ?.has("hydra:next") ?: false
```

**Après :**
```kotlin
val items = response.body()?.member
val total = response.body()?.totalItems
val currentPage = response.body()?.page
val hasNext = response.body()?.page ?: 0 < response.body()?.totalPages ?: 0
```

#### Flutter / Dart

**Modèle de données :**
```dart
class PaginatedResponse<T> {
  final List<T> member;
  final int totalItems;
  final int page;
  final int itemsPerPage;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
  bool get hasPreviousPage => page > 1;

  PaginatedResponse({
    required this.member,
    required this.totalItems,
    required this.page,
    required this.itemsPerPage,
    required this.totalPages,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse(
      member: (json['member'] as List)
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      totalItems: json['totalItems'] as int,
      page: json['page'] as int,
      itemsPerPage: json['itemsPerPage'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}
```

**Utilisation :**
```dart
// Avant (Hydra)
final items = response['hydra:member'] as List;
final total = response['hydra:totalItems'] as int;
final hasNext = response['hydra:view']?['hydra:next'] != null;

// Après
final paginated = PaginatedResponse.fromJson(response, Property.fromJson);
final items = paginated.member;
final total = paginated.totalItems;
final hasNext = paginated.hasNextPage;
```

**Paramètres de requête pour la pagination :**
```
GET /api/properties?page=2&itemsPerPage=20
```

| Paramètre | Type | Défaut | Description |
|---|---|---|---|
| `page` | integer | 1 | Numéro de page |
| `itemsPerPage` | integer | 30 | Nombre d'éléments par page |

---

## 2. Nouvelle route : Statut de paiement de visite

### `GET /api/visits/{id}/payment-status/{transactionId}`

Permet de vérifier le statut du paiement d'une visite. Utilisée en **polling** après la création d'une visite payante.

**Authentification :** Bearer Token (utilisateur propriétaire de la visite)

#### Paramètres de chemin

| Paramètre | Type | Description |
|---|---|---|
| `id` | string (UUID) | Identifiant de la visite |
| `transactionId` | string (UUID) | Identifiant de la transaction de paiement |

#### Réponse 200 — Paiement en attente

```json
{
  "visitId": "550e8400-e29b-41d4-a716-446655440000",
  "transactionId": "550e8400-e29b-41d4-a716-446655440099",
  "status": "pending",
  "statusLabel": "En attente",
  "statusColor": "yellow",
  "amount": 5000,
  "currency": "CDF",
  "paidAt": null
}
```

#### Réponse 200 — Paiement réussi

```json
{
  "visitId": "550e8400-e29b-41d4-a716-446655440000",
  "transactionId": "550e8400-e29b-41d4-a716-446655440099",
  "status": "completed",
  "statusLabel": "Complété",
  "statusColor": "green",
  "amount": 5000,
  "currency": "CDF",
  "paidAt": "2026-02-18T10:32:00+00:00"
}
```

#### Réponse 200 — Paiement échoué

```json
{
  "visitId": "550e8400-e29b-41d4-a716-446655440000",
  "transactionId": "550e8400-e29b-41d4-a716-446655440099",
  "status": "failed",
  "statusLabel": "Échoué",
  "statusColor": "red",
  "amount": 5000,
  "currency": "CDF",
  "paidAt": null
}
```

#### Champs de la réponse

| Champ | Type | Description |
|---|---|---|
| `visitId` | string (UUID) | ID de la visite |
| `transactionId` | string (UUID) | ID de la transaction |
| `status` | string | Statut technique : `pending`, `completed`, `failed` |
| `statusLabel` | string | Libellé lisible (vient du backend, à afficher tel quel) |
| `statusColor` | string | Couleur du badge : `yellow`, `green`, `red` |
| `amount` | number | Montant payé |
| `currency` | string | Code devise ISO 4217 (ex: `CDF`, `USD`) |
| `paidAt` | string \| null | Date/heure du paiement (ISO 8601), `null` si pas encore payé |

---

## 3. Mise à jour : Création de visite avec paiement

### `POST /api/visits`

Trois nouveaux champs optionnels permettent de déclencher un paiement mobile lors de la création de la visite.

#### Body de la requête

```json
{
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "scheduledAt": "2026-02-20T14:00:00+00:00",
  "notes": "Intéressé par une location longue durée",
  "paymentPhone": "+243812345678",
  "paymentAmount": 5000,
  "paymentCurrency": "CDF"
}
```

#### Description des champs

| Champ | Type | Requis | Description |
|---|---|---|---|
| `propertyId` | string (UUID) | **oui** | ID de la propriété à visiter |
| `scheduledAt` | string (ISO 8601) | **oui** | Date et heure souhaitées pour la visite |
| `notes` | string | non | Notes additionnelles |
| `paymentPhone` | string | non | Numéro de téléphone pour le paiement mobile (format international : `+243...`) |
| `paymentAmount` | number | non | Montant du paiement (défaut : 5.00) |
| `paymentCurrency` | string | non | Code devise ISO 4217 (défaut : `USD`). Valeurs possibles : `USD`, `CDF`, `EUR` |

> **Règle :** Si `paymentPhone` est fourni, le backend crée automatiquement une transaction de paiement via FlexPay. La réponse contiendra alors un `paymentTransactionId` à utiliser pour le polling.

#### Réponse 201

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "propertyTitle": "Appartement moderne à Gombe",
  "visitorId": "770e8400-e29b-41d4-a716-446655440002",
  "visitorName": "John Doe",
  "scheduledAt": "2026-02-20T14:00:00+00:00",
  "status": "scheduled",
  "notes": "Intéressé par une location longue durée",
  "confirmedAt": null,
  "completedAt": null,
  "createdAt": "2026-02-18T10:30:00+00:00",
  "isPaid": false,
  "paymentTransactionId": "550e8400-e29b-41d4-a716-446655440099"
}
```

> **Important :** `paymentTransactionId` est `null` si aucun paiement n'a été demandé. S'il est présent, lancer le polling (voir section 7).

---

## 4. Mise à jour : Liste des visites avec filtres

### `GET /api/me/visits`

Nouveaux paramètres de query pour la pagination et le filtrage par statut.

#### Paramètres de requête

| Paramètre | Type | Défaut | Description |
|---|---|---|---|
| `page` | integer | 1 | Numéro de page |
| `itemsPerPage` | integer | 30 | Nombre d'éléments par page |
| `status` | string | _(tous)_ | Filtrer par statut : `scheduled`, `confirmed`, `completed`, `cancelled` |

#### Exemple de requête

```
GET /api/me/visits?page=1&itemsPerPage=10&status=scheduled
```

#### Réponse 200

```json
{
  "member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "propertyId": "660e8400-e29b-41d4-a716-446655440001",
      "propertyTitle": "Appartement moderne à Gombe",
      "visitorId": "770e8400-e29b-41d4-a716-446655440002",
      "visitorName": "John Doe",
      "scheduledAt": "2026-02-20T14:00:00+00:00",
      "status": "scheduled",
      "statusLabel": "Planifiée",
      "statusColor": "blue",
      "notes": "Intéressé par une location longue durée",
      "confirmedAt": null,
      "completedAt": null,
      "createdAt": "2026-02-18T10:30:00+00:00",
      "isPaid": false,
      "paymentTransactionId": null
    }
  ],
  "totalItems": 12,
  "page": 1,
  "itemsPerPage": 10,
  "totalPages": 2
}
```

---

## 5. Nouvelles routes : Administration des devises

### `POST /api/currencies` — Créer une devise

**Authentification :** Bearer Token (admin uniquement)

#### Body de la requête

```json
{
  "code": "ZAR",
  "name": "Rand sud-africain",
  "symbol": "R",
  "exchangeRate": 18.5,
  "isActive": true
}
```

| Champ | Type | Requis | Description |
|---|---|---|---|
| `code` | string | **oui** | Code ISO 4217 (3 lettres majuscules) |
| `name` | string | **oui** | Nom complet de la devise |
| `symbol` | string | **oui** | Symbole d'affichage |
| `exchangeRate` | number | **oui** | Taux de change par rapport au USD |
| `isActive` | boolean | non | Activer/désactiver (défaut : `true`) |

#### Réponse 201

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440003",
  "code": "ZAR",
  "name": "Rand sud-africain",
  "symbol": "R",
  "exchangeRate": 18.5,
  "isActive": true,
  "createdAt": "2026-01-15T10:30:00+00:00",
  "updatedAt": "2026-01-15T10:30:00+00:00"
}
```

---

### `PUT /api/currencies/{code}` — Modifier une devise

**Authentification :** Bearer Token (admin uniquement)

#### Paramètres de chemin

| Paramètre | Type | Description |
|---|---|---|
| `code` | string | Code ISO 4217 de la devise (ex: `CDF`) |

#### Body de la requête (tous les champs sont optionnels)

```json
{
  "name": "Franc congolais",
  "symbol": "FC",
  "exchangeRate": 2800.0,
  "isActive": true
}
```

#### Réponse 200

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "code": "CDF",
  "name": "Franc congolais",
  "symbol": "FC",
  "exchangeRate": 2800.0,
  "isActive": true,
  "createdAt": "2026-01-01T00:00:00+00:00",
  "updatedAt": "2026-01-15T12:00:00+00:00"
}
```

---

## 6. Nouvelles routes : Transactions

### `GET /api/transactions` — Liste des transactions

**Authentification :** Bearer Token

#### Paramètres de requête

| Paramètre | Type | Défaut | Description |
|---|---|---|---|
| `page` | integer | 1 | Numéro de page |
| `itemsPerPage` | integer | 30 | Nombre d'éléments par page |
| `type` | string | _(tous)_ | Filtrer par type : `payment`, `deposit`, `withdrawal` |
| `startDate` | string | — | Date de début (format `YYYY-MM-DD`) |
| `endDate` | string | — | Date de fin (format `YYYY-MM-DD`) |

#### Exemple de requête

```
GET /api/transactions?page=1&itemsPerPage=20&type=payment&startDate=2026-01-01&endDate=2026-03-18
```

#### Réponse 200

```json
{
  "member": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "walletId": "550e8400-e29b-41d4-a716-446655440001",
      "type": "payment",
      "amount": 500,
      "currency": "USD",
      "status": "completed",
      "statusLabel": "Complété",
      "statusColor": "green",
      "gateway": "flexpay",
      "externalId": "FLEXPAY-123",
      "description": "Paiement réservation Appartement Gombe",
      "relatedEntity": "550e8400-e29b-41d4-a716-446655440003",
      "relatedEntityType": "reservation",
      "processedAt": "2026-01-15T10:31:00+00:00",
      "createdAt": "2026-01-15T10:30:00+00:00"
    }
  ],
  "totalItems": 25,
  "page": 1,
  "itemsPerPage": 20,
  "totalPages": 2
}
```

---

### `GET /api/transactions/{id}` — Détail d'une transaction

**Authentification :** Bearer Token

#### Paramètres de chemin

| Paramètre | Type | Description |
|---|---|---|
| `id` | string (UUID) | Identifiant de la transaction |

#### Réponse 200

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "userId": "550e8400-e29b-41d4-a716-446655440010",
  "userName": "Jean Dupont",
  "walletId": "550e8400-e29b-41d4-a716-446655440001",
  "type": "payment",
  "amount": 500,
  "currency": "USD",
  "status": "completed",
  "statusLabel": "Complété",
  "statusColor": "green",
  "gateway": "flexpay",
  "externalId": "FLEXPAY-123",
  "description": "Paiement réservation Appartement Gombe",
  "relatedEntity": "550e8400-e29b-41d4-a716-446655440003",
  "relatedEntityType": "reservation",
  "processedAt": "2026-01-15T10:31:00+00:00",
  "createdAt": "2026-01-15T10:30:00+00:00"
}
```

#### Champs de la transaction

| Champ | Type | Description |
|---|---|---|
| `id` | string (UUID) | Identifiant unique |
| `userId` | string (UUID) | ID de l'utilisateur (détail admin uniquement) |
| `userName` | string | Nom de l'utilisateur (détail admin uniquement) |
| `walletId` | string (UUID) | ID du portefeuille associé |
| `type` | string | Type : `payment`, `deposit`, `withdrawal` |
| `amount` | number | Montant |
| `currency` | string | Code devise ISO 4217 |
| `status` | string | Statut technique : `pending`, `completed`, `failed` |
| `statusLabel` | string | Libellé à afficher |
| `statusColor` | string | Couleur du badge |
| `gateway` | string | Passerelle de paiement (ex: `flexpay`) |
| `externalId` | string | Référence externe de la passerelle |
| `description` | string | Description lisible |
| `relatedEntity` | string (UUID) | ID de l'entité liée (réservation, visite, etc.) |
| `relatedEntityType` | string | Type d'entité liée : `reservation`, `visit`, `lease` |
| `processedAt` | string \| null | Date/heure de traitement |
| `createdAt` | string | Date/heure de création |

> **Auto-expiration :** Les transactions en statut `pending` expirent automatiquement après **1 heure** et passent en statut `failed`. Le mobile ne doit pas continuer à poller au-delà de 1h.

---

## 7. Flow complet : Paiement de visite avec polling

Ce flow décrit le processus complet depuis la demande de visite jusqu'à la confirmation du paiement.

### Étape 1 — Créer la visite avec les infos de paiement

```
POST /api/visits
```

```json
{
  "propertyId": "660e8400-e29b-41d4-a716-446655440001",
  "scheduledAt": "2026-02-20T14:00:00+00:00",
  "notes": "Intéressé par une location longue durée",
  "paymentPhone": "+243812345678",
  "paymentAmount": 5000,
  "paymentCurrency": "CDF"
}
```

**Réponse :** La visite est créée avec un `paymentTransactionId`. Sauvegarder le `id` (visitId) et le `paymentTransactionId`.

### Étape 2 — Démarrer le polling

Appeler la route de statut toutes les **5 à 10 secondes** :

```
GET /api/visits/{visitId}/payment-status/{paymentTransactionId}
```

### Étape 3 — Gérer les résultats du polling

| `status` reçu | Action mobile |
|---|---|
| `pending` | Continuer le polling, afficher un loader/spinner |
| `completed` | **Arrêter le polling**, afficher un message de succès, rafraîchir la liste des visites |
| `failed` | **Arrêter le polling**, afficher un message d'erreur, proposer de réessayer |

### Étape 4 — Gérer le timeout

Si après **60 minutes** de polling le statut est toujours `pending` :
- Arrêter le polling
- Afficher un message : _"Le paiement n'a pas été confirmé. La transaction a expiré."_
- Le backend passera automatiquement la transaction en `failed`

### Pseudo-code du polling — Android / Kotlin

```kotlin
// Android / Kotlin — Coroutines + Retrofit
suspend fun pollPaymentStatus(visitId: String, transactionId: String) {
    val startTime = System.currentTimeMillis()
    val maxDuration = 60 * 60 * 1000L // 1 heure
    val pollInterval = 5_000L // 5 secondes

    while (true) {
        // Vérifier le timeout
        if (System.currentTimeMillis() - startTime > maxDuration) {
            showError("Le paiement a expiré. La transaction a été annulée.")
            break
        }

        try {
            // Appeler l'API
            val response = api.getPaymentStatus(visitId, transactionId)

            when (response.status) {
                "completed" -> {
                    showSuccess("Paiement confirmé !")
                    refreshVisitsList()
                    break
                }
                "failed" -> {
                    showError("Le paiement a échoué. Veuillez réessayer.")
                    break
                }
                "pending" -> {
                    // Attendre avant le prochain appel
                    delay(pollInterval)
                }
            }
        } catch (e: Exception) {
            // Erreur réseau — attendre et réessayer
            delay(pollInterval * 2)
        }
    }
}
```

### Pseudo-code du polling — Flutter / Dart

```dart
// Flutter / Dart — avec Timer et async
import 'dart:async';

class PaymentPollingService {
  Timer? _pollTimer;
  DateTime? _startTime;
  final Duration _pollInterval = const Duration(seconds: 5);
  final Duration _maxDuration = const Duration(hours: 1);

  void startPolling({
    required String visitId,
    required String transactionId,
    required Function(String status) onStatusChange,
    required Function(String error) onError,
  }) {
    _startTime = DateTime.now();

    _pollTimer = Timer.periodic(_pollInterval, (timer) async {
      // Vérifier le timeout
      if (DateTime.now().difference(_startTime!) > _maxDuration) {
        stopPolling();
        onError('Le paiement a expiré. La transaction a été annulée.');
        return;
      }

      try {
        final response = await apiClient.get(
          '/visits/$visitId/payment-status/$transactionId',
        );
        final status = response.data['status'] as String;

        switch (status) {
          case 'completed':
            stopPolling();
            onStatusChange('completed');
            break;
          case 'failed':
            stopPolling();
            onError('Le paiement a échoué. Veuillez réessayer.');
            break;
          case 'pending':
            // Continue polling
            break;
        }
      } catch (e) {
        // Erreur réseau — continue polling (ne pas arrêter)
        debugPrint('Erreur polling: $e');
      }
    });
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}

// Utilisation dans un Widget :
final pollingService = PaymentPollingService();

pollingService.startPolling(
  visitId: visit.id,
  transactionId: visit.paymentTransactionId!,
  onStatusChange: (status) {
    setState(() => paymentCompleted = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paiement confirmé !')),
    );
    // Rafraîchir la liste des visites
    _loadVisits();
  },
  onError: (error) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erreur de paiement'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  },
);

// Ne pas oublier dans dispose() :
@override
void dispose() {
  pollingService.stopPolling();
  super.dispose();
}
```

### Diagramme de séquence

```
Mobile                    Backend                  FlexPay
  |                          |                        |
  |-- POST /visits --------->|                        |
  |                          |-- Initier paiement --->|
  |<-- 201 (visitId, txId) --|                        |
  |                          |                        |
  |-- GET /payment-status -->|                        |
  |<-- { status: pending } --|                        |
  |                          |                        |
  |        ... (polling toutes les 5s) ...            |
  |                          |                        |
  |                          |<-- POST /webhook ------|
  |                          |    (callback FlexPay)  |
  |                          |-- Confirme paiement -->|
  |                          |   (met à jour la DB)   |
  |                          |                        |
  |-- GET /payment-status -->|                        |
  |<-- { status: completed } |                        |
  |                          |                        |
  |   [Arrêter le polling]   |                        |
```

---

## 8. Webhook FlexPay : Fonctionnement et intégration

### Comment fonctionne le webhook ?

Le webhook est une **route côté backend** que FlexPay appelle automatiquement lorsqu'un paiement change de statut. **Le mobile n'appelle JAMAIS le webhook directement.**

### Route du webhook

```
POST /api/payments/webhook
```

**Accès :** Public (pas de Bearer Token — c'est FlexPay qui l'appelle)

### Flux de fonctionnement

```
1. L'utilisateur initie un paiement depuis le mobile
2. Le backend envoie la demande à FlexPay
3. FlexPay envoie un push USSD au téléphone de l'utilisateur
4. L'utilisateur confirme le paiement sur son téléphone (saisie du PIN)
5. FlexPay appelle POST /api/payments/webhook avec le résultat
6. Le backend met à jour la transaction (pending → completed ou failed)
7. Le mobile, qui poll GET /payment-status, détecte le changement
```

### Ce que FlexPay envoie au webhook

```json
{
  "orderNumber": "FLEXPAY-TXN-123456",
  "status": 0,
  "amount": "5000",
  "currency": "CDF",
  "reference": "019cb4e3-2ed0-767e-8794-4bca0d6e3..."
}
```

| Champ | Description |
|---|---|
| `orderNumber` | Référence externe de la transaction (correspond à `externalId`) |
| `status` | Code FlexPay : `0` = succès, `1` = échec, `2` = en attente |
| `amount` | Montant payé |
| `reference` | Référence interne |

### Ce que le backend fait à la réception du webhook

1. Vérifie la signature du webhook (sécurité)
2. Retrouve la transaction par `orderNumber` (= `externalId`)
3. Met à jour le statut de la transaction :
   - FlexPay `status: 0` → Transaction `completed`, visite `isPaid: true`
   - FlexPay `status: 1` → Transaction `failed`
4. Retourne `200 OK` à FlexPay

### Impact côté mobile

Le mobile **ne gère pas le webhook**. Son rôle est uniquement de :

1. **Envoyer** `POST /visits` avec les infos de paiement
2. **Poller** `GET /payment-status` pour détecter le changement de statut
3. **Réagir** au changement de statut (`completed` ou `failed`)

Le webhook est une communication **backend ↔ FlexPay** uniquement.

### Route de vérification manuelle (fallback)

Si le webhook n'a pas été reçu (réseau, timeout), la route `GET /payment-status` interroge aussi directement FlexPay pour vérifier le statut en temps réel. C'est un **double mécanisme de sécurité** :

- **Webhook (push)** : FlexPay notifie le backend → mise à jour instantanée
- **Polling (pull)** : Le backend vérifie lui-même auprès de FlexPay si le webhook n'est pas arrivé

Le mobile n'a rien à faire de spécial pour ce fallback — il continue simplement à poller `GET /payment-status`.

---

## 9. Routes supprimées

Les routes suivantes **n'existent plus** dans le backend. Toute référence dans le code mobile doit être supprimée.

| Route supprimée | Remplacement |
|---|---|
| `DELETE /api/visits/{id}` | ➡️ Utiliser `POST /api/visits/{id}/cancel` |
| `GET /api/currencies/convert` | ❌ Aucun — conversion à faire côté client avec `exchangeRate` |
| `GET /api/currencies/rate` | ❌ Aucun — utiliser le champ `exchangeRate` de `GET /currencies` |
| `GET /api/payment-methods` | ❌ Supprimé |
| `GET /api/me/transactions` | ➡️ Utiliser `GET /api/transactions` |
| `GET /api/me/transactions/history` | ❌ Supprimé — utiliser `GET /api/transactions` avec filtres `startDate`/`endDate` |
| `GET /api/transactions/by-reference/{reference}` | ❌ Supprimé |
| `GET /api/me/transactions/export` | ❌ Supprimé |

### Annulation de visite — changement de méthode

**Avant :** `DELETE /api/visits/{id}`
**Après :** `POST /api/visits/{id}/cancel`

> **Règle :** Une visite **déjà payée** (`isPaid: true`) ne peut PAS être annulée. Le backend retournera une erreur `400` avec le message _"Impossible d'annuler une visite déjà payée."_

---

## 10. Checklist de migration

Cocher chaque élément une fois implémenté :

### Pagination (priorité haute)

- [ ] Créer le modèle `PaginatedResponse<T>` générique
- [ ] Remplacer `hydra:member` par `member` dans le parsing de toutes les réponses
- [ ] Remplacer `hydra:totalItems` par `totalItems`
- [ ] Supprimer le parsing de `hydra:view`, `@context`, `@id`, `@type`
- [ ] Ajouter le support de `page`, `itemsPerPage`, `totalPages`
- [ ] Envoyer `page` et `itemsPerPage` comme query params sur les routes paginées
- [ ] Calculer `hasNextPage` comme `page < totalPages`
- [ ] Calculer `hasPreviousPage` comme `page > 1`

### Paiement de visite (priorité haute)

- [ ] Ajouter les champs `paymentPhone`, `paymentAmount`, `paymentCurrency` au formulaire de visite
- [ ] Implémenter le service de polling (`PaymentPollingService` ou coroutine)
- [ ] Gérer les 3 statuts : `pending`, `completed`, `failed`
- [ ] Implémenter le timeout de 1h sur le polling
- [ ] Afficher le `statusLabel` et `statusColor` du backend (ne pas hardcoder)
- [ ] Stopper le polling quand l'écran est quitté (`dispose()` / `onCleared()`)

### Annulation de visite

- [ ] Changer `DELETE /visits/{id}` en `POST /visits/{id}/cancel`
- [ ] Masquer le bouton d'annulation si `isPaid: true`

### Transactions

- [ ] Implémenter `GET /transactions` avec les filtres (`type`, `startDate`, `endDate`)
- [ ] Implémenter `GET /transactions/{id}` pour le détail
- [ ] Supprimer les appels aux anciennes routes (voir section 9)

### Devises (si admin dans le mobile)

- [ ] Implémenter `POST /currencies` pour la création
- [ ] Implémenter `PUT /currencies/{code}` pour la modification

### Nettoyage

- [ ] Supprimer tout code référençant les routes supprimées (section 9)
- [ ] Supprimer les interfaces/modèles Hydra (`HydraView`, `HydraSearch`, etc.)
- [ ] Tester toutes les listes paginées avec le nouveau format
- [ ] Tester le paiement de visite end-to-end (sandbox FlexPay)
