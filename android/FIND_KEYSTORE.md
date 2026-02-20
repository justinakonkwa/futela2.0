# Problème de signature - Keystore incorrect

## Situation
Google Play attend un keystore avec l'empreinte SHA1 :
```
43:FE:10:30:1D:E2:AF:82:E1:DD:31:E9:1D:23:CD:EB:4D:C1:CD:2E
```

Mais le keystore actuel (`futela-upload-keystore.jks`) a l'empreinte :
```
A0:1F:84:9C:AA:68:01:34:8E:41:9B:0C:4D:BF:91:70:9A:73:40:6A
```

## Solutions possibles

### Option 1 : Utiliser Google Play App Signing (Recommandé)
Si vous avez activé Google Play App Signing, vous pouvez :
1. Aller dans Google Play Console
2. Accéder à "Release" > "Setup" > "App signing"
3. Télécharger le certificat d'upload fourni par Google
4. Utiliser ce certificat pour signer vos futurs uploads

### Option 2 : Trouver le keystore original
Vous devez trouver le keystore original qui a été utilisé pour la première publication.

**Où chercher :**
- Votre ordinateur de développement
- Backups/archives
- Google Drive ou autre service de stockage cloud
- Email avec les informations de keystore
- Notes/documentation du projet

**Pour vérifier un keystore :**
```bash
keytool -list -v -keystore <chemin-vers-keystore.jks> -alias <alias> -storepass <mot-de-passe>
```

Cherchez l'empreinte SHA1 qui correspond à : `43:FE:10:30:1D:E2:AF:82:E1:DD:31:E9:1D:23:CD:EB:4D:C1:CD:2E`

### Option 3 : Réinitialiser l'application (Dernier recours)
⚠️ **ATTENTION** : Cela supprimera toutes les données de l'application existante sur Google Play.

Si vous ne pouvez pas retrouver le keystore original et que Google Play App Signing n'est pas activé, vous devrez :
1. Supprimer l'application existante de Google Play Console
2. Créer une nouvelle application avec un nouveau package name
3. Utiliser le nouveau keystore

## Vérifier l'empreinte d'un keystore

Pour vérifier l'empreinte SHA1 d'un keystore :
```bash
keytool -list -v -keystore <chemin-keystore.jks> -alias <alias> -storepass <mot-de-passe> | grep SHA1
```

## Important
- **NE PERDEZ JAMAIS** le keystore original utilisé pour publier sur Google Play
- Gardez toujours une copie de sauvegarde sécurisée
- Si vous utilisez Google Play App Signing, vous n'avez besoin que du certificat d'upload

