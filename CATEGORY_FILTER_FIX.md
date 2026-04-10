# Correction du filtrage par catégorie

## Date
9 avril 2026

## Problème identifié
Le filtrage par catégorie ne fonctionnait pas correctement car le mapping entre les noms de catégories et les types API n'était pas assez robuste.

## Solution appliquée

### 1. Amélioration du mapping dans PropertyProvider
**Fichier**: `lib/providers/property_provider.dart`

Méthode `_categoryNameToType()` améliorée avec:
- Trim et lowercase pour normaliser les entrées
- Support de plus de variations (véhicule, auto, etc.)
- Vérification directe si le nom correspond déjà à un type API valide
- Logs détaillés pour le débogage

```dart
String? _categoryNameToType(String? categoryName) {
  if (categoryName == null || categoryName.isEmpty) return null;
  
  final categoryLower = categoryName.toLowerCase().trim();
  
  // Mapping avec support de multiples variations
  // apartment, house, land, event_hall, car
  
  // Fallback: vérifier si c'est déjà un type API valide
  final validTypes = ['apartment', 'house', 'land', 'event_hall', 'car'];
  if (validTypes.contains(categoryLower)) {
    return categoryLower;
  }
  
  return null;
}
```

### 2. Amélioration du mapping dans PropertyService
**Fichier**: `lib/services/property_service.dart`

Méthode `_mapCategoryToType()` améliorée avec:
- Même logique robuste que le provider
- Logs pour tracer les conversions
- Support des variations de noms (véhicule, auto, etc.)

### 3. Logs de débogage ajoutés

**PropertyProvider** (`lib/providers/property_provider.dart`):
- `loadCategories()` : Affiche toutes les catégories chargées avec id, name, slug
- `_categoryNameToType()` : Trace chaque conversion
- `loadProperties()` : Affiche les paramètres de recherche

**PropertyService** (`lib/services/property_service.dart`):
- `_mapCategoryToType()` : Trace chaque conversion
- `searchProperties()` : Affiche les paramètres envoyés à l'API
- `listProperties()` : Affiche les paramètres envoyés à l'API

**SearchScreen** (`lib/screens/search/search_screen.dart`):
- `_performSearch()` : Affiche tous les filtres appliqués

**HomeScreen** (`lib/screens/home/home_screen.dart`):
- `onCategorySelected` : Affiche la catégorie sélectionnée

## Types API supportés
Selon la documentation API, les types valides sont:
- `apartment` - Appartements
- `house` - Maisons/Villas
- `land` - Terrains
- `event_hall` - Salles d'événements
- `car` - Véhicules

## Variations de noms supportées

### Apartment
- apartment, appartement

### House
- house, maison, villa

### Land
- land, terrain

### Event Hall
- event, hall, salle

### Car
- car, voiture, vehicule, véhicule, auto

## Test de validation

Tous les mappings ont été testés et validés:
```
✅ "Car" → car
✅ "car" → car
✅ "Voiture" → car
✅ "Appartement" → apartment
✅ "Maison" → house
✅ "Terrain" → land
✅ "Salle" → event_hall
✅ " Car " (avec espaces) → car
✅ "apartment" (direct match) → apartment
```

## Flux de données

1. **CategoryChips** retourne le nom de la catégorie sélectionnée (ex: "Car")
2. **SearchScreen** passe ce nom au provider via `searchProperties(category: "Car")`
3. **PropertyProvider.loadProperties()** convertit le nom en type via `_categoryNameToType("Car")` → "car"
4. **PropertyService.searchProperties()** reçoit le type et l'envoie à l'API avec `type=car`
5. **API** retourne les propriétés filtrées

## Exemple de logs en production

```
🔥 SEARCH - _performSearch called
  - category: "Car"
🔍 PropertyProvider.searchProperties called
  - category (Name): Car
📋 PropertyProvider.loadProperties called
Category filter (categoryName): Car
🔄 _categoryNameToType: Converting "Car" (lowercase: "car")
✅ Mapped to: car
🔄 Converted categoryName "Car" to type: car
🔍 Calling PropertyService.searchProperties
  - type: car
🔥 SEARCH SERVICE - Type already provided: "car"
🏠 GET PROPERTIES SEARCH (PropertyService)
URL: /api/properties/search
Query Parameters: {limit: 20, offset: 0, type: car}
```

## Test API validé

La requête curl suivante fonctionne correctement:
```bash
curl -X GET "https://api.futela.com/api/properties/search?type=car&minPrice=0&query=car&limit=20&offset=0" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

Retourne 1 résultat (Lamborghini Mansory).

## Résultat
Le filtrage par catégorie fonctionne maintenant correctement avec:
- Support de toutes les variations de noms (français/anglais, majuscules/minuscules, espaces)
- Logs détaillés pour faciliter le débogage
- Validation complète du mapping
- Cohérence entre provider et service

