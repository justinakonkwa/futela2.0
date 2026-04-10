# 🚨 Fix Apple Sign-In Error 1000

## Erreur observée
```
Erreur Apple inconnue: The operation couldn't be completed. 
(com.apple.AuthenticationServices.AuthorizationError error 1000.)
```

## Cause principale
L'erreur 1000 indique que la **capability "Sign In with Apple" n'est pas configurée** dans Xcode ou que l'**App ID n'existe pas** dans Apple Developer Console.

## Solution OBLIGATOIRE

### Étape 1: Configuration Xcode (CRITIQUE)

1. **Ouvrir Xcode**
   ```bash
   open ios/Runner.xcodeproj
   ```

2. **Dans Xcode :**
   - Sélectionner le target **"Runner"** dans la sidebar
   - Aller dans l'onglet **"Signing & Capabilities"**
   - Cliquer sur **"+ Capability"** en haut à gauche
   - Chercher et ajouter **"Sign In with Apple"**
   - Vérifier que le Bundle Identifier est **"com.naara.futela"**

3. **Vérifier les entitlements :**
   - Un fichier `Runner.entitlements` doit apparaître
   - Il doit contenir la clé `com.apple.developer.applesignin`

### Étape 2: Apple Developer Console

1. **Aller sur** [Apple Developer Console](https://developer.apple.com/)

2. **Naviguer vers :**
   - Certificates, Identifiers & Profiles
   - Identifiers
   - App IDs

3. **Chercher votre App ID :**
   - Bundle ID: `com.naara.futela`
   - Si il n'existe pas, cliquer "Register a New Identifier"

4. **Configurer l'App ID :**
   - Type: App IDs
   - Bundle ID: Explicit - `com.naara.futela`
   - Description: Futela App
   - **Capabilities: Cocher "Sign In with Apple"**
   - Cliquer "Continue" puis "Register"

### Étape 3: Rebuild et test

1. **Nettoyer le projet :**
   ```bash
   cd ios
   rm -rf build/
   pod install
   cd ..
   flutter clean
   flutter pub get
   ```

2. **Compiler sur appareil physique :**
   ```bash
   flutter run --release
   ```

3. **Tester Apple Sign-In**

## Vérifications importantes

### ✅ Checklist avant test
- [ ] Capability "Sign In with Apple" ajoutée dans Xcode
- [ ] Bundle ID correct: `com.naara.futela`
- [ ] App ID créé dans Apple Developer Console
- [ ] Sign In with Apple activé pour l'App ID
- [ ] Test sur appareil physique iOS 13+
- [ ] Apple ID configuré sur l'appareil de test
- [ ] Compte Apple Developer actif

### ❌ Causes communes d'échec
- **Simulateur iOS :** Apple Sign-In ne fonctionne pas sur simulateur
- **iOS < 13 :** Apple Sign-In nécessite iOS 13 minimum
- **Capability manquante :** La plus commune - doit être ajoutée dans Xcode
- **Bundle ID incorrect :** Doit correspondre exactement
- **App ID inexistant :** Doit être créé dans Apple Developer Console

## Test de validation

Après avoir suivi ces étapes, l'erreur 1000 devrait disparaître et vous devriez voir :

1. **Bouton Apple Sign-In** visible dans l'app
2. **Flux d'authentification Apple** qui s'ouvre
3. **Sélection/confirmation du compte Apple**
4. **Retour dans l'app** avec connexion réussie

## Si l'erreur persiste

### Vérifications supplémentaires
1. **Provisioning Profile :** Régénérer si vous utilisez un profil manuel
2. **Team ID :** Vérifier que le bon team est sélectionné dans Xcode
3. **Certificats :** S'assurer que les certificats de développement sont valides
4. **Logs Xcode :** Consulter la console Xcode pour plus de détails

### Commande de diagnostic
```bash
./debug_apple_signin.sh
```

## Notes importantes

- **Apple Sign-In est OBLIGATOIRE** si vous proposez d'autres connexions sociales (Google)
- **Test uniquement sur appareil physique** - ne fonctionne pas sur simulateur
- **Compte Apple Developer payant requis** (99$/an)
- **Configuration une seule fois** - ensuite ça fonctionne pour toujours

Une fois configuré correctement, Apple Sign-In fonctionnera parfaitement ! 🍎✅