# 🧪 Guide de Test OAuth - Google & Apple Sign-In

## Tests à effectuer après configuration complète

### Prérequis
- Configuration Firebase Android terminée
- Configuration Apple Developer iOS terminée  
- Endpoints backend implémentés
- App compilée sans erreurs

## Test iOS (Apple Sign-In)

### Environnement requis
- **Appareil** : iPhone/iPad physique (iOS 13+)
- **Simulateur** : ❌ Ne fonctionne pas
- **Xcode** : Capability "Sign In with Apple" activée
- **Apple ID** : Compte configuré sur l'appareil

### Étapes de test
1. **Compiler** l'app sur l'appareil physique
2. **Ouvrir** l'écran de connexion
3. **Vérifier** que le bouton "Continuer avec Apple" est visible
4. **Cliquer** sur le bouton Apple Sign-In
5. **Suivre** le flux d'authentification Apple
6. **Vérifier** la connexion réussie dans l'app

### Résultats attendus
- ✅ Bouton Apple visible uniquement sur iOS
- ✅ Flux d'authentification Apple natif
- ✅ Connexion automatique dans l'app
- ✅ Navigation vers l'écran principal

## Test Android (Google Sign-In)

### Environnement requis
- **Appareil** : Android physique ou émulateur avec Google Play Services
- **Firebase** : Configuration complète avec SHA-1
- **Google Account** : Compte Google configuré sur l'appareil

### Étapes de test
1. **Compiler** l'app sur Android
2. **Ouvrir** l'écran de connexion
3. **Vérifier** que le bouton "Continuer avec Google" est visible
4. **Cliquer** sur le bouton Google Sign-In
5. **Sélectionner** un compte Google
6. **Autoriser** l'accès à l'app
7. **Vérifier** la connexion réussie dans l'app

### Résultats attendus
- ✅ Bouton Google visible sur toutes les plateformes
- ✅ Sélecteur de compte Google
- ✅ Écran d'autorisation Google
- ✅ Connexion automatique dans l'app
- ✅ Navigation vers l'écran principal

## Test iOS (Google Sign-In)

### Environnement requis
- **Appareil** : iPhone/iPad physique ou simulateur
- **Google Account** : Compte Google configuré
- **Configuration** : Client ID iOS configuré

### Étapes de test
1. **Compiler** l'app sur iOS
2. **Ouvrir** l'écran de connexion
3. **Cliquer** sur "Continuer avec Google"
4. **Suivre** le flux Google (Safari ou app Google)
5. **Autoriser** l'accès
6. **Vérifier** le retour dans l'app

### Résultats attendus
- ✅ Redirection vers Safari ou app Google
- ✅ Flux d'autorisation Google
- ✅ Retour automatique dans l'app
- ✅ Connexion réussie

## Débogage des erreurs communes

### Erreurs iOS Apple Sign-In

| Erreur | Cause probable | Solution |
|--------|----------------|----------|
| "Apple Sign-In not available" | iOS < 13 ou simulateur | Tester sur appareil iOS 13+ |
| "Invalid client" | Bundle ID incorrect | Vérifier Bundle ID dans Apple Developer |
| "Authorization failed" | Capability manquante | Ajouter capability dans Xcode |

### Erreurs Google Sign-In

| Erreur | Cause probable | Solution |
|--------|----------------|----------|
| "Sign in canceled" | Utilisateur a annulé | Normal, pas d'action requise |
| "Network error" | Pas de connexion | Vérifier la connexion internet |
| "Invalid client" | Client ID incorrect | Vérifier les Client IDs dans la config |
| "Audience mismatch" | Client Web incorrect | Vérifier GIDServerClientID |

### Erreurs Android spécifiques

| Erreur | Cause probable | Solution |
|--------|----------------|----------|
| "Developer error" | SHA-1 manquant | Ajouter SHA-1 dans Firebase Console |
| "App not authorized" | Package name incorrect | Vérifier package dans Firebase |
| "Google Play Services" | Services manquants | Installer Google Play Services |

## Logs de débogage

### Activer les logs détaillés

```dart
// Dans main.dart pour le debug
void main() {
  if (kDebugMode) {
    print('🔧 Mode debug activé');
  }
  runApp(MyApp());
}
```

### Logs à surveiller

#### iOS
- Console Xcode pour les erreurs Apple Sign-In
- Logs réseau pour les appels API
- Erreurs de redirection URL

#### Android  
- Logcat pour les erreurs Google Sign-In
- Logs Firebase pour la configuration
- Erreurs de certificat SHA-1

## Checklist de validation

### Avant les tests
- [ ] Configuration Firebase Android complète
- [ ] Configuration Apple Developer iOS complète
- [ ] Endpoints backend implémentés et testés
- [ ] App compile sans erreurs
- [ ] Dépendances installées (`flutter pub get`)

### Tests iOS
- [ ] Apple Sign-In fonctionne sur appareil physique
- [ ] Google Sign-In fonctionne sur iOS
- [ ] Navigation post-connexion correcte
- [ ] Gestion des erreurs appropriée

### Tests Android
- [ ] Google Sign-In fonctionne sur Android
- [ ] Sélection de compte Google
- [ ] Autorisation et retour dans l'app
- [ ] Gestion des erreurs appropriée

### Tests généraux
- [ ] Boutons visibles selon la plateforme
- [ ] Messages d'erreur en français
- [ ] États de chargement affichés
- [ ] Déconnexion fonctionne correctement

## Commandes utiles

### Rebuild complet
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

### Logs détaillés
```bash
flutter run --verbose
```

### Debug Android
```bash
adb logcat | grep -i google
```

### Debug iOS
```bash
# Dans Xcode: Window > Devices and Simulators > View Device Logs
```

Une fois tous les tests validés, votre système d'authentification OAuth sera pleinement fonctionnel ! 🎉