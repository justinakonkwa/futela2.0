# Fonctionnalités Visites, Paiements et Frais

Ce document décrit les nouvelles fonctionnalités ajoutées à l'application Futela pour gérer les visites, paiements et frais.

## 📅 Visites

### Modèles
- **Visit** : Modèle principal pour représenter une visite
- **VisitRequest** : Modèle pour créer une nouvelle visite
- **VisitResponse** : Modèle pour la réponse de l'API lors de la récupération des visites

### Fonctionnalités
- **Créer une visite** : Demander une visite pour une propriété
- **Lister mes visites** : Voir toutes les visites de l'utilisateur connecté
- **Payer une visite** : Effectuer un paiement pour une visite

### Écrans
- **MyVisitsScreen** : Affiche la liste des visites de l'utilisateur
- **RequestVisitScreen** : Formulaire pour demander une nouvelle visite

### API Endpoints
- `POST /visits` - Créer une visite
- `GET /visits/my-visits` - Récupérer les visites de l'utilisateur
- `POST /visits/{id}/pay` - Payer une visite

## 💳 Paiements

### Modèles
- **PaymentRequest** : Modèle pour effectuer un paiement
- **PaymentResponse** : Réponse après un paiement
- **PaymentCheckResponse** : Vérification du statut d'un paiement
- **WithdrawalRequest** : Demande de retrait

### Fonctionnalités
- **Payer une visite** : Effectuer un paiement pour une visite
- **Vérifier un paiement** : Vérifier le statut d'un paiement
- **Demander un retrait** : Demander un retrait d'argent

### API Endpoints
- `GET /payments/check/{id}` - Vérifier un paiement
- `POST /payments/users/withdrawal` - Demander un retrait

## 💸 Frais

### Modèles
- **Fee** : Modèle pour représenter un frais
- **FeeResponse** : Réponse de l'API pour la liste des frais

### Fonctionnalités
- **Lister les frais** : Voir tous les frais disponibles
- **Voir les détails d'un frais** : Consulter les détails d'un frais spécifique

### Écrans
- **FeesScreen** : Affiche la liste des frais

### API Endpoints
- `GET /fees` - Récupérer la liste des frais
- `GET /fees/{id}` - Récupérer un frais spécifique

## 🔧 Providers

### VisitProvider
Gère l'état des visites :
- Chargement des visites
- Création de nouvelles visites
- Paiement des visites
- Vérification des paiements
- Demandes de retrait

### FeeProvider
Gère l'état des frais :
- Chargement de la liste des frais
- Chargement des détails d'un frais

## 🎨 Interface Utilisateur

### MyVisitsScreen
- Liste des visites avec statut
- Boutons pour voir les détails et payer
- Dialogue de paiement avec formulaire
- Gestion des erreurs et états de chargement

### RequestVisitScreen
- Formulaire de demande de visite
- Sélecteur de date et heure
- Champ de message optionnel
- Validation des données

### FeesScreen
- Liste des frais disponibles
- Dialogue de détails pour chaque frais
- Gestion des erreurs et états de chargement

## 🔌 Intégration API

Toutes les fonctionnalités sont intégrées avec l'API Futela :
- Gestion des tokens d'authentification
- Gestion des erreurs HTTP
- Logging détaillé des requêtes et réponses
- Support de la pagination

## 📱 Utilisation

### Demander une visite
1. Naviguer vers une propriété
2. Cliquer sur "Demander une visite"
3. Remplir le formulaire (date, heure, message, contact)
4. Soumettre la demande

### Payer une visite
1. Aller dans "Mes Visites"
2. Cliquer sur "Payer" pour une visite
3. Remplir les informations de paiement
4. Confirmer le paiement

### Consulter les frais
1. Aller dans l'écran "Frais"
2. Voir la liste des frais disponibles
3. Cliquer sur "Voir les détails" pour plus d'informations

## 🚀 Prochaines étapes

- Intégration avec la navigation principale
- Notifications push pour les visites
- Historique des paiements
- Gestion des favoris pour les visites
- Interface d'administration pour les propriétaires


