# 🍎 Configuration Xcode pour Apple Sign-In

## Problème actuel
L'erreur 1000 indique un problème de configuration Xcode malgré que les fichiers soient corrects. Voici la solution étape par étape.

## ✅ Diagnostic confirmé
- ✅ Runner.entitlements contient `com.apple.developer.applesignin`
- ✅ Dépendance `sign_in_with_apple` installée
- ✅ Pod installé correctement
- ⚠️ Caches de build à nettoyer

## 🔧 Solution étape par étape

### Étape 1: Nettoyage complet
```bash
# Lancer le script de nettoyage
./fix_apple_signin_complete.sh
```

### Étape 2: Configuration Xcode CRITIQUE

#### 2.1 Ouvrir le projet
```bash
open ios/Runner.xcworkspace
```

#### 2.2 Vérifier le Bundle ID
1. Sélectionner le target **Runner** dans la sidebar
2. Onglet **General**
3. Vérifier que **Bundle Identifier** = `com.naara.futela`
4. Si différent, le corriger EXACTEMENT

#### 2.3 Régénérer le Provisioning Profile
1. Onglet **Signing & Capabilities**
2. **DÉCOCHER** "Automatically manage signing"
3. Attendre 2-3 secondes
4. **RECOCHER** "Automatically manage signing"
5. Sélectionner votre **Team** Apple Developer
6. Attendre que Xcode télécharge/génère le provisioning profile

#### 2.4 Vérifier la Capability
1. Dans **Signing & Capabilities**
2. Vérifier que **Sign In with Apple** est présente
3. Si absente:
   - Cliquer **+ Capability**
   - Chercher "Sign In with Apple"
   - L'ajouter

#### 2.5 Clean et Build
1. **Product** → **Clean Build Folder** (⌘⇧K)
2. **Product** → **Build** (⌘B)
3. Vérifier qu'il n'y a pas d'erreurs

### Étape 3: Test sur appareil physique

#### 3.1 Connecter un iPhone/iPad
- iOS 13+ requis
- Appareil enregistré dans Apple Developer Console

#### 3.2 Compiler et installer
```bash
flutter run --release
```

#### 3.3 Tester Apple Sign-In
1. Ouvrir l'app
2. Aller à l'écran de connexion
3. Cliquer sur "Continuer avec Apple"
4. Vérifier les logs:

**Succès attendu:**
```
🍎 [Apple Sign In] Tentative de connexion
🍎 [Apple Sign In] Disponibilité: true
🍎 [Apple Sign In] Demande des credentials...
🍎 [Apple Sign In] Credentials reçus:
   - userIdentifier: 001234.567890abcdef
   - identityToken: présent
   - authorizationCode: présent
✅ [Apple Sign In] Succès pour 001234.567890abcdef
```

## 🚨 Si l'erreur 1000 persiste

### Vérifications supplémentaires

#### Apple Developer Console
1. Aller sur [developer.apple.com](https://developer.apple.com)
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → Votre App ID `com.naara.futela`
4. Vérifier que **Sign In with Apple** est coché
5. Si modifié, régénérer le provisioning profile

#### Provisioning Profile manuel
1. Dans Xcode, **Signing & Capabilities**
2. Décocher "Automatically manage signing"
3. **Provisioning Profile** → **Download Profile...**
4. Sélectionner le bon profil pour `com.naara.futela`

#### Autres solutions
- Redémarrer Xcode complètement
- Redémarrer le Mac
- Essayer sur un autre appareil iOS
- Vérifier que l'appareil est bien enregistré dans Apple Developer Console

## 🔍 Commandes de diagnostic

```bash
# Voir les logs Apple Sign-In en temps réel
flutter run --verbose | grep -E "(Apple|🍎|AuthorizationError)"

# Vérifier la configuration
./diagnose_apple_signin.sh

# Nettoyer complètement
./fix_apple_signin_complete.sh
```

## 📱 Points critiques

1. **Bundle ID** doit être EXACTEMENT `com.naara.futela`
2. **Tester UNIQUEMENT sur appareil physique** (pas simulateur)
3. **iOS 13+** requis
4. **Provisioning profile** doit être à jour
5. **Apple Developer Account** doit avoir Sign In with Apple activé

## ✅ Validation finale

Une fois configuré, vous devriez voir:
- Bouton Apple Sign-In visible sur iOS
- Pas d'erreur 1000
- Flux d'authentification fonctionnel
- Logs de succès dans la console

L'erreur 1000 est presque toujours liée à la configuration Xcode/provisioning, pas au code Flutter qui est correct.