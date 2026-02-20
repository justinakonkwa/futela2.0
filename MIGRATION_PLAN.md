# Plan de Migration vers la Nouvelle Structure API Futela

Ce document détaille les étapes pour mettre à jour l'application Flutter `futela` afin de se conformer à la nouvelle documentation API (`new_documentation.md`).

## 1. Analyse de l'existant vs Nouveau

**Actuellement :**
- `api_service.dart` est monolithique (~41KB).
- Modèles limités (`Property`, `User`, `Visit`, `Favorite`).
- Structure d'adresse probablement simplifiée.
- Absence de gestion des portefeuilles, paiements complexes, et messagerie détaillée.

**Nouvelle Cible :**
- Architecture modulaire par domaine (Auth, Location, Property, Reservation, etc.).
- Hiérarchie géographique complète (Pays > Province > Ville > Commune > Quartier > Adresse).
- Flux de réservation complet avec statuts (pending, confirmed, etc.).
- Intégration FlexPay et Wallet.
- Messagerie et Notifications en temps réel.

---

## 2. Refonte des Modèles de Données (`lib/models/`)

Il faut créer ou mettre à jour les modèles pour correspondre aux schémas JSON.

### 2.1. Géolocalisation (Nouveau)
Créer un dossier `lib/models/location/` :
- `Country`
- `Province`
- `City`
- `Town`
- `District`
- `Address` (incluant lat/lng et relations)

### 2.2. Authentification et Utilisateur
Mettre à jour `lib/models/user.dart` et créer `lib/models/auth/` :
- `User` (ajouter `phoneNumber`, `isVerified`, `roles`, etc.)
- `AuthResponse` (tokens + user)
- `Device` (gestion des sessions)

### 2.3. Propriétés
Mettre à jour `lib/models/property.dart` :
- Structurer `Property` avec la nouvelle `Address`.
- Ajouter `PropertyPhoto` (avec `isPrimary`, `caption`).
- Ajouter `Category` (avec `slug`, `icon`).
- Ajouter `PropertyCalendar` et `Availability`.

### 2.4. Réservations et Visites
Créer `lib/models/booking/` :
- `Reservation` (avec statuts, dates, prix).
- `Visit` (avec statuts scheduled/confirmed/completed).
- `Invoice` (facture).

### 2.5. Finance (Nouveau)
Créer `lib/models/finance/` :
- `Wallet`
- `Transaction` (type payment/deposit/withdrawal).
- `Currency`.
- `PaymentInitiation` et `PaymentStatus`.

### 2.6. Messagerie et Notifications (Nouveau)
Créer `lib/models/messaging/` :
- `Conversation`
- `Message` (avec attachments).
- `Notification` (avec types et data).

---

## 3. Modularisation des Services (`lib/services/`)

Découper `api_service.dart` en services spécialisés injectables ou statiques.

- **`AuthService`** :
  - Login, Register, Refresh Token.
  - Gestion des sessions (Logout, Revoke).
  - Vérification Email/SMS.

- **`LocationService`** :
  - Fetch Countries, Provinces, Cities, Towns, Districts.
  - Recherche d'adresses.

- **`PropertyService`** :
  - CRUD Propriétés et Photos.
  - Recherche avancée (filtres).
  - Gestion du calendrier et disponibilités.

- **`ReservationService`** :
  - Création, Modification, Annulation.
  - Workflow de confirmation et paiement.
  - Gestion des visites (`VisitService` peut être séparé ou inclus).

- **`FinanceService` (ou `PaymentService`)** :
  - Gestion du Wallet (solde, topup, withdraw).
  - Initiation paiements FlexPay.

- **`MessagingService`** :
  - Gestion des Conversations et Messages.
  - Marquer comme lu/archivé.

- **`NotificationService`** :
  - Listing, Compteurs non-lus.

---

## 4. Mise à jour de la Gestion de l'État (`lib/providers/`)

Mettre à jour les `ChangeNotifier` pour utiliser les nouveaux services.

- `AuthProvider` : Gérer l'état de connexion, le user courant, et le refresh token automatique.
- `LocationProvider` : Gérer les sélections en cascade (ex: choisir Pays -> charge Provinces).
- `PropertyProvider` : Gérer la recherche, les filtres et la pagination.
- `BookingProvider` : Gérer le panier de réservation et le suivi des visites.
- `WalletProvider` : Gérer le solde et les transactions.
- `MessagingProvider` : Gérer la liste des conversations et le polling/socket des messages.

---

## 5. Priorités d'Implémentation

1.  **Refonte de l'Authentification** (Base de tout système).
2.  **Système de Localisation** (Nécessaire pour créer des propriétés et adresses).
3.  **Gestion des Propriétés** (Cœur de métier).
4.  **Réservations & Visites**.
5.  **Finance & Messagerie**.
