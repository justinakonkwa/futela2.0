# Solutions pour le problème de keystore sur Google Play

## ❌ Impossible de changer le keystore

**Google Play ne permet PAS de changer le keystore de signature** une fois qu'une application a été publiée. C'est une mesure de sécurité importante pour protéger les utilisateurs.

## ✅ Solutions possibles

### Option 1 : Utiliser Google Play App Signing (RECOMMANDÉ)

Si vous avez activé **Google Play App Signing**, Google gère la signature finale et vous pouvez utiliser un **certificat d'upload** différent.

**Comment vérifier si c'est activé :**
1. Allez sur [Google Play Console](https://play.google.com/console)
2. Sélectionnez votre application
3. Allez dans **Release** > **Setup** > **App signing**
4. Si vous voyez "Google Play App Signing", c'est activé ✅

**Si c'est activé :**
- Google vous fournit un **certificat d'upload** à télécharger
- Vous pouvez utiliser ce certificat pour signer vos futurs uploads
- Vous n'avez pas besoin du keystore original

**Si ce n'est PAS activé :**
- Vous pouvez l'activer maintenant (mais vous aurez toujours besoin du keystore original pour la première fois)
- Une fois activé, Google gérera la signature finale

### Option 2 : Trouver le keystore original

Vous **DEVEZ** retrouver le keystore original qui a été utilisé pour la première publication.

**Où chercher :**
- 📁 Votre ordinateur de développement (recherchez tous les fichiers `.jks` ou `.keystore`)
- 💾 Backups/archives (disques externes, Time Machine, etc.)
- ☁️ Services cloud (Google Drive, Dropbox, OneDrive, etc.)
- 📧 Emails (recherchez "keystore", "signing key", "upload key")
- 📝 Notes/documentation du projet
- 👥 Collègues/équipe (si c'est un projet collaboratif)

**Pour vérifier un keystore :**
```bash
keytool -list -v -keystore <chemin-keystore.jks> -alias <alias> -storepass <mot-de-passe> | grep SHA1
```

L'empreinte SHA1 doit être : `43:FE:10:30:1D:E2:AF:82:E1:DD:31:E9:1D:23:CD:EB:4D:C1:CD:2E`

### Option 3 : Créer une nouvelle application (Dernier recours)

⚠️ **ATTENTION** : Cela signifie :
- ❌ Perdre tous les téléchargements existants
- ❌ Perdre les avis et notes
- ❌ Les utilisateurs devront désinstaller l'ancienne app et installer la nouvelle
- ❌ Perdre l'historique de l'application

**Si vous choisissez cette option :**
1. Créez une nouvelle application dans Google Play Console avec un **nouveau package name** (ex: `com.naara.futela2`)
2. Mettez à jour le `applicationId` dans `android/app/build.gradle.kts`
3. Utilisez le nouveau keystore (`futela-upload-keystore.jks`)
4. Publiez la nouvelle application

## 🔍 Script pour trouver le keystore

J'ai créé un script `check-keystore.sh` pour vérifier si un keystore correspond :

```bash
cd android
./check-keystore.sh <chemin-keystore.jks> <alias> <mot-de-passe>
```

## 📋 Checklist

- [ ] Vérifier si Google Play App Signing est activé
- [ ] Chercher le keystore original sur votre ordinateur
- [ ] Chercher dans les backups
- [ ] Chercher dans les services cloud
- [ ] Vérifier les emails
- [ ] Si rien ne fonctionne, considérer créer une nouvelle application

## 💡 Recommandation

**La meilleure solution est de trouver le keystore original** ou d'utiliser Google Play App Signing si c'est disponible.

Si vous ne pouvez vraiment pas le retrouver, vous devrez créer une nouvelle application avec un nouveau package name.

