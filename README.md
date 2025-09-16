# Futela - Application Immobilière

Une application mobile moderne de location et vente de propriétés, inspirée du design d'Airbnb, développée avec Flutter.

## 🏠 Fonctionnalités

### Authentification
- ✅ Connexion et inscription
- ✅ Gestion du profil utilisateur
- ✅ Vérification d'identité
- ✅ Changement de mot de passe

### Propriétés
- ✅ Liste des propriétés avec pagination
- ✅ Recherche et filtres avancés
- ✅ Détails complets des propriétés
- ✅ Ajout de nouvelles propriétés
- ✅ Gestion des images
- ✅ Système de favoris

### Géolocalisation
- ✅ Localisation automatique
- ✅ Calcul de distance
- ✅ Filtrage par localisation

### Interface Utilisateur
- ✅ Design moderne inspiré d'Airbnb
- ✅ Navigation intuitive
- ✅ Animations fluides
- ✅ Mode sombre (à venir)

## 🛠️ Technologies Utilisées

- **Flutter** - Framework de développement mobile
- **Provider** - Gestion d'état
- **HTTP/Dio** - Communication avec l'API
- **SharedPreferences** - Stockage local
- **Google Fonts** - Typographie
- **Cached Network Image** - Gestion des images
- **Geolocator** - Géolocalisation
- **Image Picker** - Sélection d'images

## 📱 Écrans Principaux

### Authentification
- Écran de connexion
- Écran d'inscription
- Écran de récupération de mot de passe

### Navigation Principale
- **Accueil** - Liste des propriétés avec recherche
- **Recherche** - Filtres avancés et recherche
- **Favoris** - Propriétés sauvegardées
- **Profil** - Gestion du compte utilisateur

### Propriétés
- Détail d'une propriété
- Ajout d'une nouvelle propriété
- Modification d'une propriété
- Galerie d'images

## 🎨 Design System

### Couleurs
- **Primaire** : Rouge Airbnb (#E31C5F)
- **Secondaire** : Teal (#00A699)
- **Accent** : Orange (#FFB400)
- **Neutres** : Palette de gris

### Typographie
- **Police** : Inter (Google Fonts)
- **Hiérarchie** : Display, Headline, Title, Body, Label

### Composants
- Boutons personnalisés
- Champs de texte stylisés
- Cartes de propriétés
- Navigation bottom bar
- Modales et bottom sheets

## 🚀 Installation

1. **Cloner le projet**
   ```bash
   git clone [url-du-repo]
   cd futela
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configurer l'API**
   - Modifier l'URL de base dans `lib/services/api_service.dart`
   - Configurer les endpoints selon votre API

4. **Lancer l'application**
   ```bash
   flutter run
   ```

## 📋 Configuration API

L'application est configurée pour fonctionner avec l'API fournie. Assurez-vous de :

1. **Modifier l'URL de base** dans `lib/services/api_service.dart`
2. **Configurer l'authentification** selon votre système
3. **Adapter les modèles** si nécessaire

### Endpoints Principaux

- `POST /auth/sign-in` - Connexion
- `POST /auth/sign-up` - Inscription
- `GET /properties` - Liste des propriétés
- `POST /properties` - Créer une propriété
- `GET /properties/{id}` - Détail d'une propriété

## 🏗️ Architecture

### Structure du Projet
```
lib/
├── models/          # Modèles de données
├── providers/       # Gestion d'état (Provider)
├── services/        # Services API
├── screens/         # Écrans de l'application
├── widgets/         # Composants réutilisables
└── utils/           # Utilitaires et thème
```

### Gestion d'État
- **AuthProvider** - Authentification utilisateur
- **PropertyProvider** - Gestion des propriétés
- **LocationProvider** - Géolocalisation

## 📸 Captures d'Écran

*Les captures d'écran seront ajoutées après les tests*

## 🔧 Développement

### Commandes Utiles
```bash
# Analyser le code
flutter analyze

# Formater le code
flutter format .

# Tests
flutter test

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

### Ajout de Nouvelles Fonctionnalités

1. **Créer le modèle** dans `lib/models/`
2. **Ajouter le service API** dans `lib/services/`
3. **Créer le provider** dans `lib/providers/`
4. **Développer l'écran** dans `lib/screens/`
5. **Ajouter les widgets** dans `lib/widgets/`

## 🐛 Problèmes Connus

- [ ] Upload d'images non implémenté
- [ ] Système de paiement à développer
- [ ] Notifications push à ajouter
- [ ] Mode hors ligne à implémenter

## 📝 TODO

- [ ] Tests unitaires et d'intégration
- [ ] Documentation API
- [ ] Optimisation des performances
- [ ] Internationalisation (i18n)
- [ ] Mode sombre
- [ ] Notifications push
- [ ] Système de chat
- [ ] Évaluations et commentaires

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Équipe

- **Développeur Principal** - [Votre nom]
- **Designer UI/UX** - [Nom du designer]
- **Backend Developer** - [Nom du développeur backend]

## 📞 Support

Pour toute question ou support :
- Email : support@futela.com
- Documentation : [Lien vers la documentation]
- Issues : [Lien vers les issues GitHub]

---

**Futela** - Votre maison de rêve vous attend ! 🏠✨
