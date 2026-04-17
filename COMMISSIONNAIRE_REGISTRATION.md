# Inscription Commissionnaire - Documentation

## Vue d'ensemble

Le système d'inscription pour les commissionnaires permet aux professionnels de l'immobilier de créer un compte et de soumettre leur demande d'approbation. Le processus comprend :

1. **Sélection du rôle** - L'utilisateur choisit son rôle (Visiteur, Propriétaire, ou Commissionnaire)
2. **Complétion du profil** - Saisie des informations personnelles et professionnelles
3. **Upload des documents** - Pièce d'identité et selfie de vérification
4. **Validation backend** - Le profil est soumis avec `approvalStatus: "pending"`

## Architecture

### Modèles

#### `ProfileCompletionRequest`
```dart
class ProfileCompletionRequest {
  final String firstName;
  final String lastName;
  final String phone;
  final String role; // ROLE_USER, ROLE_LANDLORD, ROLE_COMMISSIONNAIRE
  final String? idDocumentType; // national_id, passport, driver_license, voter_card
  final String? idDocumentNumber;
  final String? businessName;
  final String? businessAddress;
  final String? taxId;
}
```

#### `User` (mis à jour)
Nouveaux champs ajoutés :
- `profileCompleted`: bool - Indique si le profil est complété
- `approvalStatus`: String? - Statut d'approbation (pending, approved, rejected)
- `approvalStatusLabel`: String? - Label du statut (En attente, Approuvé, Rejeté)
- `approvalStatusColor`: String? - Couleur du statut (amber, green, red)
- `idDocumentType`: String?
- `idDocumentNumber`: String?
- `idDocumentPhotoUrl`: String?
- `selfiePhotoUrl`: String?
- `businessName`: String?
- `businessAddress`: String?
- `taxId`: String?

### Services

#### `ProfileService`
Nouveau service pour gérer la complétion de profil et l'upload de documents :

- `completeProfile(ProfileCompletionRequest)` → `User`
  - PUT `/api/users/me/complete-profile`
  - Complète le profil après inscription OAuth

- `uploadIdDocument(File)` → `String` (URL)
  - POST `/api/users/me/id-document-photo`
  - Upload de la pièce d'identité (JPEG, PNG, WEBP, PDF, max 8 MB)

- `uploadSelfie(File)` → `String` (URL)
  - POST `/api/users/me/selfie-photo`
  - Upload du selfie (JPEG, PNG, WEBP, max 8 MB)

#### `AuthProvider` (mis à jour)
Nouvelle méthode ajoutée :

```dart
Future<bool> completeProfile({
  required String firstName,
  required String lastName,
  required String phone,
  required String role,
  String? idDocumentType,
  String? idDocumentNumber,
  String? businessName,
  String? businessAddress,
  String? taxId,
  File? idDocumentFile,
  File? selfieFile,
})
```

Cette méthode :
1. Complète le profil via l'API
2. Upload les documents si fournis
3. Rafraîchit le profil utilisateur
4. Gère les erreurs et le loading state

### Écrans

#### `RoleSelectionScreen`
- Affiche 3 options de rôle avec icônes et descriptions
- Visiteur (ROLE_USER) - Cherche un bien
- Propriétaire (ROLE_LANDLORD) - Met en location/vente
- Commissionnaire (ROLE_COMMISSIONNAIRE) - Professionnel

#### `CompleteProfileScreen`
Formulaire adaptatif selon le rôle sélectionné :

**Champs communs (tous les rôles) :**
- Prénom (2-100 caractères)
- Nom (2-100 caractères)
- Téléphone (+243 préfixé, 9 ou 10 chiffres)

**Champs spécifiques commissionnaire :**
- Type de pièce d'identité (dropdown)
- Numéro du document
- Nom commercial
- Adresse professionnelle
- Numéro fiscal / RCCM
- Photo de la pièce d'identité (obligatoire)
- Selfie de vérification (obligatoire)

#### `ProfileCompletionWrapper`
Wrapper qui vérifie si le profil est complété après connexion OAuth :
- Si `profileCompleted == false` → Redirige vers `RoleSelectionScreen`
- Si `profileCompleted == true` → Affiche `MainNavigation`

## Flux utilisateur

### Inscription classique (email/mot de passe)
```
RegisterScreen
    ↓
POST /api/auth/register (avec role: "ROLE_COMMISSIONNAIRE")
    ↓
ProfileCompletionWrapper
    ↓
MainNavigation (profil déjà complété)
```

### Inscription OAuth (Google/Apple)
```
LoginScreen / RegisterScreen
    ↓
Google/Apple Sign-In
    ↓
POST /api/auth/google ou /api/auth/apple
    ↓
ProfileCompletionWrapper
    ↓
RoleSelectionScreen (profileCompleted == false)
    ↓
CompleteProfileScreen
    ↓
PUT /api/users/me/complete-profile
POST /api/users/me/id-document-photo
POST /api/users/me/selfie-photo
    ↓
MainNavigation
```

## Validation des documents

### Pièce d'identité
- **Formats acceptés** : JPEG, PNG, WEBP, PDF
- **Taille max** : 8 MB
- **Obligatoire** : Oui (pour commissionnaires)

### Selfie
- **Formats acceptés** : JPEG, PNG, WEBP (pas de PDF)
- **Taille max** : 8 MB
- **Obligatoire** : Oui (pour commissionnaires)
- **Source** : Caméra frontale recommandée

## Statuts d'approbation

Après soumission, le commissionnaire reçoit un statut :

| Status | Label | Couleur | Description |
|--------|-------|---------|-------------|
| `pending` | En attente | amber | Demande en cours de validation |
| `approved` | Approuvé | green | Commissionnaire validé |
| `rejected` | Rejeté | red | Demande refusée |

## Gestion des erreurs

Le système gère plusieurs types d'erreurs :

### Erreurs de validation
- Champs requis manquants
- Format de téléphone invalide
- Longueur de texte incorrecte

### Erreurs d'upload
- Fichier trop volumineux (> 8 MB)
- Format non supporté
- Erreur réseau

### Erreurs API
- 400 : Données invalides ou profil déjà complété
- 401 : Session expirée
- 413 : Fichier trop volumineux

## Intégration

### Mise à jour des écrans existants

Les écrans suivants ont été mis à jour pour utiliser `ProfileCompletionWrapper` :
- `LoginScreen`
- `RegisterScreen`
- `SocialLoginButtons`

### Dépendances ajoutées

```yaml
dependencies:
  http_parser: ^4.0.2  # Pour le multipart/form-data
  image_picker: ^1.0.4 # Déjà présent
```

## Tests recommandés

1. **Inscription classique commissionnaire**
   - Créer un compte avec role ROLE_COMMISSIONNAIRE
   - Vérifier que tous les champs sont sauvegardés
   - Vérifier le statut `pending`

2. **Inscription OAuth puis complétion**
   - Se connecter avec Google/Apple
   - Vérifier la redirection vers RoleSelectionScreen
   - Compléter le profil commissionnaire
   - Vérifier l'upload des documents

3. **Validation des documents**
   - Tester avec différents formats (JPEG, PNG, PDF)
   - Tester avec fichiers > 8 MB
   - Vérifier les messages d'erreur

4. **Gestion des erreurs**
   - Tester sans connexion internet
   - Tester avec token expiré
   - Tester la double soumission (profil déjà complété)

## Notes importantes

- Le profil ne peut être complété qu'**une seule fois** (erreur 400 si déjà complété)
- Les documents sont **obligatoires** pour les commissionnaires
- Le téléphone doit être au format **+243** (RDC)
- L'approbation admin est **automatique** pour ROLE_COMMISSIONNAIRE (status: pending)
- Les visiteurs et propriétaires n'ont **pas besoin** de documents

## Prochaines étapes

1. Créer un écran d'administration pour approuver/rejeter les commissionnaires
2. Ajouter des notifications push pour les changements de statut
3. Permettre la modification du profil commissionnaire
4. Ajouter la possibilité de re-soumettre après rejet
