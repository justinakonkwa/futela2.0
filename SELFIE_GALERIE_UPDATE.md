# Mise à jour : Selfie depuis Galerie ou Caméra

## 🎯 Changement effectué

Le selfie de vérification peut maintenant être pris depuis **la caméra OU la galerie**, au lieu de forcer uniquement la caméra.

## 📱 Nouvelle expérience utilisateur

### Avant
- Clic sur "Selfie de vérification"
- Ouverture automatique de la caméra
- Pas de choix possible

### Après
- Clic sur "Selfie de vérification"
- **Dialog de choix** :
  ```
  ┌─────────────────────────────────┐
  │  Selfie de vérification         │
  │                                  │
  │  Choisissez la source de votre  │
  │  photo                           │
  │                                  │
  │  [📷 Caméra]  [🖼️ Galerie]      │
  └─────────────────────────────────┘
  ```
- L'utilisateur choisit sa source préférée

## 🔧 Fichiers modifiés

### 1. `lib/screens/auth/register_screen.dart`
**Méthode `_pickSelfie()` :**
```dart
Future<void> _pickSelfie() async {
  try {
    // Afficher un dialog pour choisir la source
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selfie de vérification'),
        content: const Text('Choisissez la source de votre photo'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(CupertinoIcons.camera),
            label: const Text('Caméra'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(CupertinoIcons.photo),
            label: const Text('Galerie'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      preferredCameraDevice: CameraDevice.front,
    );
    
    if (image != null) {
      setState(() {
        _selfieFile = File(image.path);
      });
    }
  } catch (e) {
    // Gestion d'erreur
  }
}
```

**Description du widget :**
```dart
_DocumentUploadCard(
  title: 'Selfie de vérification *',
  description: 'Photo de vous (caméra ou galerie)', // ✅ Mise à jour
  icon: CupertinoIcons.camera_fill,
  file: _selfieFile,
  onTap: _pickSelfie,
),
```

### 2. `lib/screens/auth/complete_profile_screen.dart`
Mêmes modifications que dans `register_screen.dart`.

## ✅ Avantages

1. **Flexibilité** - L'utilisateur choisit sa source préférée
2. **Tests facilités** - Possibilité d'utiliser des images de test depuis la galerie
3. **Meilleure UX** - Pas de contrainte sur la source
4. **Compatibilité** - Fonctionne même si la caméra n'est pas disponible

## 🧪 Tests recommandés

### Test 1 : Caméra
1. Cliquer sur "Selfie de vérification"
2. Choisir "Caméra"
3. Prendre une photo
4. Vérifier que la photo est bien ajoutée

### Test 2 : Galerie
1. Cliquer sur "Selfie de vérification"
2. Choisir "Galerie"
3. Sélectionner une image
4. Vérifier que l'image est bien ajoutée

### Test 3 : Annulation
1. Cliquer sur "Selfie de vérification"
2. Fermer le dialog sans choisir
3. Vérifier qu'aucune erreur n'apparaît

### Test 4 : Changement de photo
1. Ajouter un selfie depuis la caméra
2. Cliquer à nouveau sur "Selfie de vérification"
3. Choisir "Galerie" et sélectionner une autre image
4. Vérifier que la nouvelle image remplace l'ancienne

## 📝 Notes

- La qualité d'image reste à **85%** pour optimiser la taille
- Pour la caméra, la **caméra frontale** est préférée (selfie)
- Les formats acceptés restent : **JPEG, PNG, WEBP**
- La taille max reste : **8 MB**

## 🎯 Cas d'usage

### Production
- Utilisateurs peuvent prendre un selfie en temps réel
- Meilleure vérification d'identité

### Tests / Développement
- Développeurs peuvent utiliser des images de test
- QA peut tester avec des images prédéfinies
- Pas besoin de prendre une vraie photo à chaque test

## ✨ Résultat

Le processus d'inscription commissionnaire est maintenant **plus flexible** et **plus facile à tester** ! 🚀
