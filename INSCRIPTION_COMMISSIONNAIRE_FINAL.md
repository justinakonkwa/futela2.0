# Inscription Commissionnaire - Guide Final

## 🎯 Vue d'ensemble

Le système d'inscription pour les commissionnaires est maintenant **complet** avec **2 méthodes** :

### Méthode 1 : Inscription directe (Email/Mot de passe) ✅
### Méthode 2 : Inscription OAuth puis complétion ✅

---

## 📱 Méthode 1 : Inscription directe (RegisterScreen)

### Flux utilisateur :

1. **Ouvrir l'écran d'inscription**
   - Cliquer sur "Créer un compte"

2. **Sélectionner le rôle**
   - 👤 **Visiteur** (par défaut)
   - 💼 **Commissionnaire**

3. **Remplir les informations de base** (tous les rôles)
   - Prénom
   - Nom
   - Email
   - Téléphone (+243...)
   - Mot de passe
   - Confirmation mot de passe

4. **Si Commissionnaire → Champs supplémentaires**
   
   **Informations professionnelles :**
   - Type de pièce d'identité * (dropdown)
   - Numéro du document *
   - Nom commercial
   - Adresse professionnelle
   - Numéro fiscal / RCCM
   
   **Documents de vérification :**
   - 📄 Photo de la pièce d'identité * (obligatoire)
   - 🤳 Selfie de vérification * (obligatoire)

5. **Soumettre**
   - Bouton "Créer mon compte"
   - Appel API : `POST /api/auth/register` avec tous les champs
   - Upload automatique des documents
   - Redirection vers `MainNavigation`

### Code technique :

```dart
// Dans RegisterScreen
String _selectedRole = 'ROLE_USER'; // Par défaut

// Sélecteur de rôle
SegmentedButton<String>(
  segments: [
    ButtonSegment(value: 'ROLE_USER', label: Text('Visiteur')),
    ButtonSegment(value: 'ROLE_COMMISSIONNAIRE', label: Text('Commissionnaire')),
  ],
  selected: {_selectedRole},
  onSelectionChanged: (newSelection) {
    setState(() => _selectedRole = newSelection.first);
  },
)

// Champs conditionnels
if (_isCommissionnaire) ...[
  // Tous les champs commissionnaire
]

// Inscription
if (_isCommissionnaire) {
  await authProvider.registerCommissionnaire(...);
} else {
  await authProvider.signUp(...);
}
```

---

## 🔐 Méthode 2 : Inscription OAuth (Google/Apple)

### Flux utilisateur :

1. **Écran de connexion**
   - Cliquer sur "Se connecter avec Google" ou "Se connecter avec Apple"

2. **Authentification OAuth**
   - Connexion réussie

3. **Redirection automatique**
   - L'app détecte `profileCompleted == false`
   - Affiche `RoleSelectionScreen`

4. **Sélection de rôle**
   - 👤 Visiteur
   - 💼 Commissionnaire

5. **Complétion du profil** (CompleteProfileScreen)
   - Mêmes champs que l'inscription directe
   - Appel API : `PUT /api/users/me/complete-profile`
   - Upload des documents

6. **Redirection**
   - Vers `MainNavigation`

### Code technique :

```dart
// ProfileCompletionWrapper vérifie automatiquement
if (!user.profileCompleted) {
  return RoleSelectionScreen();
}
return MainNavigation();
```

---

## 🎨 Interface utilisateur

### Sélection de rôle (2 options)

```
┌─────────────────────────────────────────┐
│  👤 Visiteur                            │
│  Je cherche un bien immobilier          │
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│  💼 Commissionnaire                     │
│  Je suis un professionnel               │
└─────────────────────────────────────────┘
```

### Formulaire commissionnaire

**Informations personnelles**
- Prénom *
- Nom *
- Téléphone * (+243...)

**Informations professionnelles**
- Type de pièce d'identité * (dropdown)
  - Carte d'identité nationale
  - Passeport
  - Permis de conduire
  - Carte d'électeur
- Numéro du document *
- Nom commercial
- Adresse professionnelle
- Numéro fiscal / RCCM

**Documents de vérification**
- 📄 Pièce d'identité * (photo)
- 🤳 Selfie * (caméra)

---

## 🔧 API Endpoints utilisés

### Inscription directe commissionnaire

```bash
POST /api/auth/register
{
  "password": "********",
  "firstName": "John",
  "lastName": "Doe",
  "email": "user@example.com",
  "phoneNumber": "+243812345678",
  "role": "ROLE_COMMISSIONNAIRE",
  "idDocumentType": "national_id",
  "idDocumentNumber": "CD1234567",
  "businessName": "Futela Immo SARL",
  "businessAddress": "Av. Kasa-Vubu 123, Kinshasa",
  "taxId": "CD/KIN/RCCM/24-A-12345"
}
```

### Upload documents

```bash
POST /api/users/me/id-document-photo
Content-Type: multipart/form-data
file: [binary]

POST /api/users/me/selfie-photo
Content-Type: multipart/form-data
file: [binary]
```

### Complétion profil OAuth

```bash
PUT /api/users/me/complete-profile
{
  "firstName": "Jean",
  "lastName": "Mukendi",
  "phone": "+243812345678",
  "role": "ROLE_COMMISSIONNAIRE",
  "idDocumentType": "national_id",
  "idDocumentNumber": "CD1234567",
  "businessName": "Futela Immo SARL",
  "businessAddress": "Av. Kasa-Vubu 123, Kinshasa",
  "taxId": "CD/KIN/RCCM/24-A-12345"
}
```

---

## ✅ Validation

### Champs obligatoires (tous)
- ✅ Prénom (2-100 caractères)
- ✅ Nom (2-100 caractères)
- ✅ Téléphone (+243 + 9 ou 10 chiffres)
- ✅ Email (format valide)
- ✅ Mot de passe (min 4 caractères)

### Champs obligatoires (commissionnaire uniquement)
- ✅ Type de pièce d'identité
- ✅ Numéro du document
- ✅ Photo de la pièce d'identité
- ✅ Selfie de vérification

### Validation des documents
- **Formats acceptés** : JPEG, PNG, WEBP, PDF (pas PDF pour selfie)
- **Taille max** : 8 MB
- **Vérification** : Avant soumission

---

## 📊 Comparaison des méthodes

| Critère | Inscription directe | OAuth + Complétion |
|---------|--------------------|--------------------|
| **Étapes** | 1 écran | 2 écrans |
| **Mot de passe** | Requis | Non requis |
| **Vérification identité** | Email | Google/Apple |
| **Temps** | ~3 min | ~2 min |
| **Recommandé pour** | Tous | Commissionnaires |

---

## 🎯 Statuts d'approbation

Après inscription commissionnaire :

| Status | Label | Couleur | Description |
|--------|-------|---------|-------------|
| `pending` | En attente | 🟡 amber | Demande en cours |
| `approved` | Approuvé | 🟢 green | Validé |
| `rejected` | Rejeté | 🔴 red | Refusé |

---

## 🚀 Fichiers modifiés/créés

### Créés
1. `lib/models/auth/profile_completion_request.dart`
2. `lib/services/profile_service.dart`
3. `lib/screens/auth/role_selection_screen.dart`
4. `lib/screens/auth/complete_profile_screen.dart`
5. `lib/screens/auth/profile_completion_wrapper.dart`

### Modifiés
1. `lib/models/auth/user.dart` - Ajout champs commissionnaire
2. `lib/providers/auth_provider.dart` - Ajout méthodes
3. `lib/services/auth_service.dart` - Ajout registerCommissionnaire
4. `lib/screens/auth/register_screen.dart` - Ajout sélection rôle
5. `lib/screens/auth/login_screen.dart` - Navigation wrapper
6. `lib/widgets/social_login_buttons.dart` - Navigation wrapper
7. `pubspec.yaml` - Ajout http_parser

---

## 📝 Résumé des changements

### RegisterScreen (Inscription directe)
- ✅ Ajout sélecteur de rôle (Visiteur / Commissionnaire)
- ✅ Champs commissionnaire conditionnels
- ✅ Upload de documents intégré
- ✅ Validation complète
- ✅ Appel API avec tous les champs

### RoleSelectionScreen (OAuth)
- ✅ 2 options : Visiteur / Commissionnaire
- ✅ Design moderne avec icônes
- ✅ Navigation vers CompleteProfileScreen

### CompleteProfileScreen (OAuth)
- ✅ Formulaire adaptatif selon rôle
- ✅ Upload de documents
- ✅ Validation complète
- ✅ Appel API complétion profil

### AuthProvider
- ✅ Méthode `registerCommissionnaire()`
- ✅ Méthode `completeProfile()`
- ✅ Upload automatique des documents

### AuthService
- ✅ Méthode `registerCommissionnaire()`
- ✅ Support tous les champs commissionnaire

---

## 🎉 Résultat final

### Pour un visiteur :
1. Inscription simple (email/mot de passe)
2. Accès immédiat à l'app

### Pour un commissionnaire :

**Option A - Inscription directe :**
1. Sélectionner "Commissionnaire"
2. Remplir tous les champs
3. Uploader les documents
4. Soumettre
5. Statut "En attente"

**Option B - OAuth :**
1. Google/Apple Sign-In
2. Sélectionner "Commissionnaire"
3. Compléter le profil
4. Uploader les documents
5. Soumettre
6. Statut "En attente"

---

## ✨ Avantages

1. **Flexibilité** - 2 méthodes d'inscription
2. **Simplicité** - Formulaire adaptatif
3. **Sécurité** - Validation complète
4. **UX** - Interface moderne et intuitive
5. **Conformité** - Documents obligatoires
6. **Traçabilité** - Statuts d'approbation

---

## 🔜 Prochaines étapes

1. **Écran d'administration** pour approuver/rejeter
2. **Notifications** sur changement de statut
3. **Modification de profil** commissionnaire
4. **Re-soumission** après rejet
5. **Tableau de bord** commissionnaire

---

## 📞 Support

Pour toute question sur l'inscription commissionnaire :
- Voir `COMMISSIONNAIRE_REGISTRATION.md` pour la documentation complète
- Voir `COMMISSIONNAIRE_IMPLEMENTATION_SUMMARY.md` pour les détails techniques

---

**Système d'inscription commissionnaire : ✅ COMPLET ET OPÉRATIONNEL**
