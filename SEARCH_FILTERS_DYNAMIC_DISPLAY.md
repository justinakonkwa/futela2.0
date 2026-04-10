# Affichage dynamique des filtres rapides selon la catégorie

## Date
10 avril 2026

## Problème
Les filtres rapides (T1, T2, T3, T4+, Meublé, Parking, Piscine) s'affichaient pour toutes les catégories, même quand ils n'étaient pas pertinents (ex: T1-T4+ pour les voitures).

## Solution appliquée

### Logique d'affichage des filtres

**Fichier**: `lib/screens/search/search_screen.dart`

Les filtres s'affichent maintenant dynamiquement selon la catégorie sélectionnée:

#### T1, T2, T3, T4+ (Nombre de chambres)
Affichés pour:
- Apartment / Appartement
- House / Maison / Villa
- Toutes (quand aucune catégorie n'est sélectionnée)

#### Meublé
Affiché pour:
- Apartment / Appartement
- House / Maison / Villa
- Toutes

#### Parking
Affiché pour:
- Apartment / Appartement
- House / Maison / Villa
- Event Hall / Salle
- Toutes

#### Piscine
Affiché pour:
- House / Maison / Villa
- Toutes

### Catégories sans filtres rapides
- **Car / Voiture** → Aucun filtre (non pertinent)
- **Land / Terrain** → Aucun filtre (non pertinent)

### Implémentation

```dart
Widget _buildQuickFilters() {
  final categoryLower = _selectedCategory?.toLowerCase() ?? '';
  
  // Déterminer quels filtres afficher
  final showRoomFilters = categoryLower.isEmpty || 
                         categoryLower.contains('apartment') || 
                         categoryLower.contains('house') || ...;
  
  final showFurnished = ...;
  final showParking = ...;
  final showPool = ...;
  
  // Construire la liste de filtres dynamiquement
  List<Widget> filters = [];
  
  if (showRoomFilters) {
    filters.addAll([T1, T2, T3, T4+ widgets]);
  }
  
  if (showFurnished) {
    filters.add(Meublé widget);
  }
  
  // ... etc
  
  return filters.isEmpty 
    ? SizedBox.shrink() 
    : SingleChildScrollView(child: Row(children: filters));
}
```

## Avantages

1. **UX améliorée** - L'utilisateur ne voit que les filtres pertinents
2. **Interface épurée** - Moins de confusion avec des filtres non applicables
3. **Logique métier** - Respecte la nature de chaque type de propriété
4. **Flexibilité** - Facile d'ajouter/modifier les règles d'affichage

## Comportement

### Exemple 1: Catégorie "Apartment"
Filtres affichés: T1, T2, T3, T4+, Meublé, Parking

### Exemple 2: Catégorie "Car"
Filtres affichés: Aucun

### Exemple 3: Catégorie "House"
Filtres affichés: T1, T2, T3, T4+, Meublé, Parking, Piscine

### Exemple 4: Aucune catégorie (Toutes)
Filtres affichés: Tous (T1, T2, T3, T4+, Meublé, Parking, Piscine)

## Note sur les filtres côté client

Les filtres Meublé, Parking et Piscine ne sont pas supportés par l'API selon la documentation. Ils sont filtrés côté client après réception des résultats. Cela peut causer des résultats vides si l'API retourne des propriétés qui ne correspondent pas aux critères.

## Fichiers modifiés
- `lib/screens/search/search_screen.dart` - Méthode `_buildQuickFilters()` rendue dynamique

## Résultat
Les filtres rapides s'affichent maintenant intelligemment selon le contexte, améliorant l'expérience utilisateur.
