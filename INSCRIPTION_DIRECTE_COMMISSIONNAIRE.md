# Comment ajouter l'inscription directe pour commissionnaires

## Problème actuel

L'écran `RegisterScreen` ne permet pas de choisir le rôle lors de l'inscription classique (email/mot de passe). Il crée toujours un compte avec le rôle par défaut.

## Solution proposée

### Option A : Ajouter la sélection de rôle dans RegisterScreen

Modifier `lib/screens/auth/register_screen.dart` pour :

1. **Ajouter un sélecteur de rôle** avant les champs du formulaire
2. **Afficher conditionnellement** les champs commissionnaire si ce rôle est sélectionné
3. **Envoyer le rôle** dans la requête `POST /api/auth/register`

#### Exemple de code à ajouter :

```dart
// Dans _RegisterScreenState
String _selectedRole = 'ROLE_USER'; // Par défaut visiteur

// Dans le formulaire, après le logo :
SegmentedButton<String>(
  segments: const [
    ButtonSegment(value: 'ROLE_USER', label: Text('Visiteur'), icon: Icon(Icons.person)),
    ButtonSegment(value: 'ROLE_LANDLORD', label: Text('Propriétaire'), icon: Icon(Icons.home)),
    ButtonSegment(value: 'ROLE_COMMISSIONNAIRE', label: Text('Pro'), icon: Icon(Icons.business)),
  ],
  selected: {_selectedRole},
  onSelectionChanged: (Set<String> newSelection) {
    setState(() {
      _selectedRole = newSelection.first;
    });
  },
),

// Afficher les champs commissionnaire si nécessaire
if (_selectedRole == 'ROLE_COMMISSIONNAIRE') ...[
  // Tous les champs de CompleteProfileScreen
],
```

### Option B : Rediriger vers le flux OAuth (RECOMMANDÉ)

Garder l'inscription classique simple et encourager les commissionnaires à utiliser Google/Apple Sign-In :

1. **Ajouter un message** dans `RegisterScreen` :
   ```
   "Vous êtes un professionnel ? 
   Utilisez Google ou Apple Sign-In pour une inscription rapide"
   ```

2. **Mettre en avant** les boutons OAuth pour les commissionnaires

## Flux recommandé (actuel)

```
┌─────────────────────────────────────────────────────────┐
│  Écran de connexion/inscription                         │
│                                                          │
│  [Inscription classique] → Compte visiteur basique      │
│                                                          │
│  [Google Sign-In]  ┐                                    │
│  [Apple Sign-In]   ├─→ Sélection de rôle → Complétion  │
│                    │    (Commissionnaire)                │
└────────────────────┴─────────────────────────────────────┘
```

## Avantages du flux OAuth pour commissionnaires

1. ✅ **Vérification d'identité** plus forte (compte Google/Apple)
2. ✅ **Moins de friction** - pas besoin de créer un mot de passe
3. ✅ **Séparation claire** - formulaire dédié aux professionnels
4. ✅ **Upload de documents** dans un écran séparé et clair
5. ✅ **Meilleure UX** - formulaire adaptatif selon le rôle

## Recommandation finale

**Garder le système actuel** et ajouter simplement un message dans `RegisterScreen` :

```dart
// Après les boutons sociaux
Container(
  padding: EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.purple.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Row(
    children: [
      Icon(Icons.business, color: Colors.purple),
      SizedBox(width: 12),
      Expanded(
        child: Text(
          'Professionnel de l\'immobilier ? Utilisez Google ou Apple Sign-In pour accéder au formulaire commissionnaire.',
          style: TextStyle(fontSize: 13),
        ),
      ),
    ],
  ),
)
```

Cela guide les commissionnaires vers le bon flux sans compliquer l'inscription classique.
