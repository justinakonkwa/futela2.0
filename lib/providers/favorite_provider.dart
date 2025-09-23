import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite.dart';
import '../models/property.dart';
import '../models/favorite_list.dart';
import '../services/api_service.dart';

class FavoriteProvider with ChangeNotifier {
  List<ListProperty> _favorites = [];
  Map<String, dynamic> _metaData = {};
  bool _isLoading = false;
  String? _error;
  Set<String> _favoritePropertyIds = {};

  List<ListProperty> get favorites => _favorites;
  Map<String, dynamic> get metaData => _metaData;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Set<String> get favoritePropertyIds => _favoritePropertyIds;

  // Vérifier si une propriété est en favori
  bool isFavorite(String propertyId) {
    return _favoritePropertyIds.contains(propertyId);
  }

  // Charger les favoris locaux au démarrage
  Future<void> loadLocalFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('local_favorites') ?? [];
    _favoritePropertyIds = favorites.toSet();
    notifyListeners();
  }

  // Obtenir les propriétés favorites (sans les wrappers de liste)
  List<Property> get favoriteProperties {
    return _favorites.map((listProperty) => listProperty.property).toList();
  }

  Future<void> loadFavorites({
    String? direction,
    String? cursor,
    int? limit,
    String? property,
    String? listId,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getFavoriteProperties(
        direction: direction,
        cursor: cursor,
        limit: limit,
        property: property,
        listId: listId,
      );

      _favorites = response.listProperties;
      _metaData = response.metaData;
      
      // Mettre à jour l'ensemble des IDs des propriétés favorites
      _favoritePropertyIds = _favorites
          .map((listProperty) => listProperty.property.id)
          .toSet();
    } catch (e) {
      _setError('Erreur lors du chargement des favoris: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToFavorites(String propertyId, {String? listId}) async {
    _setLoading(true);
    _clearError();

    try {
      // D'abord, ajouter au stockage local pour une réponse immédiate
      await _addToLocalFavorites(propertyId);
      
      // Ensuite, essayer l'API
      await _tryApiAddToFavorites(propertyId, listId);
      
    } catch (e) {
      _setError('Erreur lors de l\'ajout aux favoris: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _addToLocalFavorites(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList('local_favorites') ?? [];
    
    if (!favorites.contains(propertyId)) {
      favorites.add(propertyId);
      await prefs.setStringList('local_favorites', favorites);
    }
    
    _favoritePropertyIds.add(propertyId);
    notifyListeners();
  }

  Future<void> _tryApiAddToFavorites(String propertyId, String? listId) async {
    try {
      String effectiveListId;
      
      if (listId != null) {
        effectiveListId = listId;
      } else {
        // Récupérer les listes de favoris pour obtenir l'ID de la liste par défaut
        final favoriteListsResponse = await ApiService.getFavoriteLists();
        if (favoriteListsResponse.lists.isNotEmpty) {
          // Utiliser la première liste (généralement "favoris")
          effectiveListId = favoriteListsResponse.lists.first.id;
        } else {
          throw Exception('Aucune liste de favoris trouvée');
        }
      }
      
      // Ajouter la propriété à la liste de favoris
      await ApiService.savePropertyToFavoriteList(propertyId, effectiveListId);
      
    } catch (e) {
      // Log l'erreur mais ne pas faire échouer l'ajout local
      print('Erreur API favoris: $e');
      // Optionnel: on pourrait choisir de re-lancer l'erreur ici
      // throw e;
    }
  }

  Future<void> removeFromFavorites(String propertyId) async {
    _setLoading(true);
    _clearError();

    try {
      // Supprimer du stockage local
      final prefs = await SharedPreferences.getInstance();
      final favorites = prefs.getStringList('local_favorites') ?? [];
      favorites.remove(propertyId);
      await prefs.setStringList('local_favorites', favorites);
      
      // Supprimer de l'ensemble local
      _favoritePropertyIds.remove(propertyId);
      _favorites.removeWhere((listProperty) => listProperty.property.id == propertyId);
      
      notifyListeners();
    } catch (e) {
      _setError('Erreur lors de la suppression des favoris: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFavorite(String propertyId, {String? listId}) async {
    if (isFavorite(propertyId)) {
      await removeFromFavorites(propertyId);
    } else {
      await addToFavorites(propertyId, listId: listId);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearFavorites() {
    _favorites.clear();
    _metaData.clear();
    _favoritePropertyIds.clear();
    notifyListeners();
  }
}
