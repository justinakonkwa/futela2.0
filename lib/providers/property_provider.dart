import 'package:flutter/material.dart';
import '../models/property.dart';
import '../services/api_service.dart';

class PropertyProvider with ChangeNotifier {
  List<Property> _properties = [];
  List<Property> _myProperties = [];
  List<PropertyCategory> _categories = [];
  List<Province> _provinces = [];
  List<City> _cities = [];
  List<Town> _towns = [];
  
  bool _isLoading = false;
  String? _error;
  String? _nextCursor;
  String? _prevCursor;
  int _total = 0;

  // Getters
  List<Property> get properties => _properties;
  List<Property> get myProperties => _myProperties;
  List<PropertyCategory> get categories => _categories;
  List<Province> get provinces => _provinces;
  List<City> get cities => _cities;
  List<Town> get towns => _towns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get nextCursor => _nextCursor;
  String? get prevCursor => _prevCursor;
  int get total => _total;

  // Charger les propriétés avec filtres
  Future<void> loadProperties({
    String? direction,
    String? cursor,
    int? limit,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? owner,
    String? town,
    String? type,
    bool refresh = false,
  }) async {
    if (refresh) {
      _properties.clear();
      _nextCursor = null;
      _prevCursor = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getProperties(
        direction: direction,
        cursor: cursor ?? _nextCursor,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        category: category,
        owner: owner,
        town: town,
        type: type,
      );

      // Métadonnées résilientes
      final dynamic metaRaw = response['metaData'];
      final Map<String, dynamic> metaData = metaRaw is Map<String, dynamic>
          ? metaRaw
          : {
              'nextCursor': (response['nextCursor'] ?? null),
              'prevCursor': (response['prevCursor'] ?? null),
              'total': (response['total'] ?? 0),
            };
      _nextCursor = metaData['nextCursor'];
      _prevCursor = metaData['prevCursor'];
      _total = (metaData['total'] ?? 0) as int;

      // Données propriétés résilientes
      final dynamic propsRaw =
          response['properties'] ?? response['data'] ?? response['items'] ?? response;
      final List<dynamic> propertiesData = propsRaw is List
          ? propsRaw
          : (propsRaw is Map<String, dynamic> && propsRaw['results'] is List
              ? (propsRaw['results'] as List)
              : <dynamic>[]);
      final newProperties =
          propertiesData.map((json) => Property.fromJson(json as Map<String, dynamic>)).toList();

      if (refresh) {
        _properties = newProperties;
      } else {
        _properties.addAll(newProperties);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger mes propriétés
  Future<void> loadMyProperties({
    String? direction,
    String? cursor,
    int? limit,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? owner,
    String? town,
    String? type,
    bool refresh = false,
    int retryCount = 0,
  }) async {
    if (refresh) {
      _myProperties.clear();
      _nextCursor = null;
      _prevCursor = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.getMyProperties(
        direction: direction,
        cursor: cursor ?? _nextCursor,
        limit: limit,
        minPrice: minPrice,
        maxPrice: maxPrice,
        category: category,
        owner: owner,
        town: town,
        type: type,
      );

      // Métadonnées résilientes
      final dynamic metaRaw = response['metaData'];
      final Map<String, dynamic> metaData = metaRaw is Map<String, dynamic>
          ? metaRaw
          : {
              'nextCursor': (response['nextCursor'] ?? null),
              'prevCursor': (response['prevCursor'] ?? null),
              'total': (response['total'] ?? 0),
            };
      _nextCursor = metaData['nextCursor'];
      _prevCursor = metaData['prevCursor'];
      _total = (metaData['total'] ?? 0) as int;

      final dynamic propsRaw =
          response['properties'] ?? response['data'] ?? response['items'] ?? response;
      final List<dynamic> propertiesData = propsRaw is List
          ? propsRaw
          : (propsRaw is Map<String, dynamic> && propsRaw['results'] is List
              ? (propsRaw['results'] as List)
              : <dynamic>[]);
      final newProperties =
          propertiesData.map((json) => Property.fromJson(json as Map<String, dynamic>)).toList();

      if (refresh) {
        _myProperties = newProperties;
      } else {
        _myProperties.addAll(newProperties);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      // Log the error for debugging
      print('❌ Error loading my properties: $e');
      
      // If it's a 500 error and we haven't retried too many times, retry
      if (e.toString().contains('500') && retryCount < 2) {
        print('🔄 Retrying loadMyProperties (attempt ${retryCount + 1})');
        await Future.delayed(Duration(seconds: 2 * (retryCount + 1))); // Exponential backoff
        return loadMyProperties(
          direction: direction,
          cursor: cursor,
          limit: limit,
          minPrice: minPrice,
          maxPrice: maxPrice,
          category: category,
          owner: owner,
          town: town,
          type: type,
          refresh: refresh,
          retryCount: retryCount + 1,
        );
      }
      
      // Set error message and stop loading
      if (e.toString().contains('500')) {
        _error = 'Erreur serveur temporaire. Veuillez réessayer plus tard.';
      } else {
        _error = e.toString();
      }
      
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les catégories
  Future<void> loadCategories() async {
    if (_categories.isNotEmpty) return;

    // Ne pas notifier au début pour éviter setState durant le build
    _isLoading = true;
    _error = null;

    try {
      _categories = await ApiService.getCategories();
      _isLoading = false;
      // Notifier uniquement après avoir reçu les données
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les provinces
  Future<void> loadProvinces() async {
    if (_provinces.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _provinces = await ApiService.getProvinces();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les villes
  Future<void> loadCities({String? province, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cities = await ApiService.getCities(province: province, search: search);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les communes
  Future<void> loadTowns({String? city, String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _towns = await ApiService.getTowns(city: city, search: search);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Créer une propriété
  Future<String?> createProperty(Map<String, dynamic> propertyData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final propertyId = await ApiService.createProperty(propertyData);
      _isLoading = false;
      notifyListeners();
      return propertyId;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Mettre à jour une propriété
  Future<bool> updateProperty(String id, Map<String, dynamic> propertyData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.updateProperty(id, propertyData);
      
      // Mettre à jour la propriété dans la liste locale
      final index = _properties.indexWhere((p) => p.id == id);
      if (index != -1) {
        _properties[index] = await ApiService.getProperty(id);
      }
      
      final myIndex = _myProperties.indexWhere((p) => p.id == id);
      if (myIndex != -1) {
        _myProperties[myIndex] = await ApiService.getProperty(id);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Supprimer une propriété
  Future<bool> deleteProperty(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.deleteProperty(id);
      
      // Supprimer la propriété des listes locales
      _properties.removeWhere((p) => p.id == id);
      _myProperties.removeWhere((p) => p.id == id);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Obtenir une propriété par ID
  Future<Property?> getPropertyById(String id) async {
    try {
      return await ApiService.getProperty(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Obtenir une de MES propriétés par ID
  Future<Property?> getMyPropertyById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final property = await ApiService.getMyProperty(id);
      
      // Enrichir les données de localisation si nécessaire
      await _enrichLocationData(property);
      
      // Ajouter la propriété à la liste si elle n'y est pas déjà
      final existingIndex = _myProperties.indexWhere((p) => p.id == id);
      if (existingIndex != -1) {
        _myProperties[existingIndex] = property;
      } else {
        _myProperties.add(property);
      }
      
      _isLoading = false;
      notifyListeners();
      return property;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Enrichir les données de localisation manquantes
  Future<void> _enrichLocationData(Property property) async {
    try {
      // Si le nom de la ville est manquant, essayer de le récupérer
      if (property.town.city.name.isEmpty && property.town.city.id.isNotEmpty) {
        final cityData = await ApiService.getCityById(property.town.city.id);
        if (cityData['name'] != null) {
          // Note: On ne peut pas modifier directement la propriété car elle est immutable
          // Cette méthode est préparée pour une future amélioration
          print('Ville trouvée: ${cityData['name']}');
        }
      }
    } catch (e) {
      // Ignorer les erreurs d'enrichissement pour ne pas bloquer l'affichage
      print('Erreur lors de l\'enrichissement des données de localisation: $e');
    }
  }

  // Rechercher des propriétés
  Future<void> searchProperties({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? town,
    String? type,
  }) async {
    await loadProperties(
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: category,
      town: town,
      type: type,
      refresh: true,
    );
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearProperties() {
    _properties.clear();
    _nextCursor = null;
    _prevCursor = null;
    _total = 0;
    notifyListeners();
  }

  // Upload d'images
  Future<void> uploadImages(String propertyId, List<String> imagePaths) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.uploadImages(propertyId, imagePaths);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload d'image de couverture
  Future<void> uploadCoverImage(String propertyId, String imagePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await ApiService.uploadCoverImage(propertyId, imagePath);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
