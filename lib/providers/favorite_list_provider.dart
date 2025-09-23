import 'package:flutter/material.dart';
import '../models/favorite_list.dart';
import '../services/api_service.dart';

class FavoriteListProvider with ChangeNotifier {
  List<FavoriteList> _favoriteLists = [];
  bool _isLoading = false;
  String? _error;
  String? _nextCursor;
  String? _prevCursor;
  int _total = 0;

  // Getters
  List<FavoriteList> get favoriteLists => _favoriteLists;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get nextCursor => _nextCursor;
  String? get prevCursor => _prevCursor;
  int get total => _total;

  // Charger les listes de favoris
  Future<void> loadFavoriteLists({
    String? direction,
    String? cursor,
    int? limit,
    String? name,
    bool refresh = false,
  }) async {
    if (refresh) {
      _favoriteLists.clear();
      _nextCursor = null;
      _prevCursor = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getFavoriteLists(
        direction: direction,
        cursor: cursor ?? _nextCursor,
        limit: limit,
        name: name,
      );

      _nextCursor = response.metaData.nextCursor;
      _prevCursor = response.metaData.prevCursor;
      _total = response.metaData.total;

      if (refresh) {
        _favoriteLists = response.lists;
      } else {
        _favoriteLists.addAll(response.lists);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      
      // Log the error for debugging
      print('❌ Error loading favorite lists: $e');
      
      // If it's a 500 error, show a more user-friendly message
      if (e.toString().contains('500')) {
        _error = 'Erreur serveur temporaire. Veuillez réessayer plus tard.';
      }
    }
  }

  // Obtenir la liste de favoris par défaut (première liste)
  FavoriteList? get defaultFavoriteList {
    return _favoriteLists.isNotEmpty ? _favoriteLists.first : null;
  }

  // Ajouter une propriété à une liste de favoris
  Future<bool> addPropertyToFavoriteList(String propertyId, String listId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.savePropertyToFavoriteList(propertyId, listId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      
      // Log the error for debugging
      print('❌ Error adding property to favorite list: $e');
      
      // If it's a 500 error, show a more user-friendly message
      if (e.toString().contains('500')) {
        _error = 'Erreur serveur temporaire. Veuillez réessayer plus tard.';
      }
      return false;
    }
  }

  // Ajouter une propriété à la liste de favoris par défaut
  Future<bool> addPropertyToDefaultFavoriteList(String propertyId) async {
    final defaultList = defaultFavoriteList;
    if (defaultList == null) {
      _error = 'Aucune liste de favoris trouvée';
      notifyListeners();
      return false;
    }
    
    return await addPropertyToFavoriteList(propertyId, defaultList.id);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearFavoriteLists() {
    _favoriteLists.clear();
    _nextCursor = null;
    _prevCursor = null;
    _total = 0;
    notifyListeners();
  }
}

