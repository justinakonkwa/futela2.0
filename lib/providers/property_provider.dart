import 'package:flutter/material.dart';
import '../models/property/property.dart';
import '../models/property/category.dart';
import '../models/location/province.dart';
import '../models/location/city.dart';
import '../models/location/town.dart';
import '../services/property_service.dart';
import '../services/location_service.dart';

class PropertyProvider with ChangeNotifier {
  final PropertyService _propertyService = PropertyService();
  final LocationService _locationService = LocationService();

  // Listes séparées pour Home et Search
  List<Property> _homeProperties = [];
  List<Property> _searchProperties = [];
  List<Property> _myProperties = [];
  List<Category> _categories = [];
  List<Province> _provinces = [];
  List<City> _cities = [];
  List<Town> _towns = [];

  bool _isLoading = false;
  String? _error;
  String? _nextCursor;
  String? _prevCursor;
  int _total = 0;

  /// Pagination page d’accueil (GET /api/properties)
  int _homeNextPage = 1;
  bool _homeHasMore = false;
  static const int _homePageSize = 20;

  // Getters
  List<Property> get homeProperties => _homeProperties;
  List<Property> get searchResults => _searchProperties;
  List<Property> get properties => _searchProperties; // Pour compatibilité avec SearchScreen
  List<Property> get myProperties => _myProperties;
  List<Category> get categories => _categories;
  List<Province> get provinces => _provinces;
  List<City> get cities => _cities;
  List<Town> get towns => _towns;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get nextCursor => _nextCursor;
  String? get prevCursor => _prevCursor;
  int get total => _total;
  /// True s’il reste des pages à charger pour le fil d’accueil.
  bool get hasMoreHomeFeed => _homeHasMore;

  // Convertir un nom de catégorie en type correspondant
  String? _categoryNameToType(String? categoryName) {
    if (categoryName == null || categoryName.isEmpty) return null;
    
    final categoryLower = categoryName.toLowerCase().trim();
    
    print('🔄 _categoryNameToType: Converting "$categoryName" (lowercase: "$categoryLower")');
    
    // Mapping selon la documentation API : apartment, house, land, event_hall, car
    if (categoryLower.contains('apartment') || 
        categoryLower.contains('appartement')) {
      print('✅ Mapped to: apartment');
      return 'apartment';
    } else if (categoryLower.contains('house') || 
               categoryLower.contains('maison') ||
               categoryLower.contains('villa')) {
      print('✅ Mapped to: house');
      return 'house';
    } else if (categoryLower.contains('land') || 
               categoryLower.contains('terrain')) {
      print('✅ Mapped to: land');
      return 'land';
    } else if (categoryLower.contains('event') || 
               categoryLower.contains('hall') ||
               categoryLower.contains('salle')) {
      print('✅ Mapped to: event_hall');
      return 'event_hall';
    } else if (categoryLower.contains('car') || 
               categoryLower.contains('voiture') ||
               categoryLower.contains('vehicule') ||
               categoryLower.contains('véhicule') ||
               categoryLower.contains('auto')) {
      print('✅ Mapped to: car');
      return 'car';
    }
    
    // Si aucun mapping trouvé, essayer de retourner le nom tel quel s'il correspond à un type API
    final validTypes = ['apartment', 'house', 'land', 'event_hall', 'car'];
    if (validTypes.contains(categoryLower)) {
      print('✅ Direct match with API type: $categoryLower');
      return categoryLower;
    }
    
    print('⚠️ No mapping found for category: "$categoryName"');
    return null;
  }

  /// Fil d’accueil : liste paginée via GET /api/properties
  Future<void> loadHomeProperties({
    String? categoryId,
    bool refresh = false,
  }) async {
    if (!refresh && !_homeHasMore) return;

    print('📋 PropertyProvider.loadHomeProperties');
    print('Category: $categoryId, refresh: $refresh');

    if (refresh) {
      _homeProperties.clear();
      _homeNextPage = 1;
      _homeHasMore = true;
      _nextCursor = null;
      _prevCursor = null;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pageToFetch = refresh ? 1 : _homeNextPage;
      final categoryParam = (categoryId != null && categoryId.isNotEmpty) ? categoryId : null;
      
      print('🔥 PROVIDER - About to call listProperties');
      print('  - pageToFetch: $pageToFetch');
      print('  - itemsPerPage: $_homePageSize');
      print('  - categoryParam: $categoryParam');
      
      final result = await _propertyService.listProperties(
        page: pageToFetch,
        itemsPerPage: _homePageSize,
        categoryId: categoryParam,
      );

      if (refresh) {
        _homeProperties = List<Property>.from(result.items);
      } else {
        _homeProperties.addAll(result.items);
      }

      _homeNextPage = result.page + 1;
      _homeHasMore = result.hasNextPage;
      _total = result.totalItems > 0 ? result.totalItems : _homeProperties.length;
      _nextCursor = _homeHasMore ? 'home' : null;

      print(
          '✅ loadHomeProperties: +${result.items.length} items, hasMore=$_homeHasMore');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _userFriendlyError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les propriétés avec filtres (GET /api/properties/search)
  Future<void> loadProperties({
    String? direction,
    String? cursor,
    int? limit,
    int? offset,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? owner,
    String? town,
    String? cityId,
    String? type,
    String? query,
    int? bedrooms,
    bool? available,
    bool? hasParking,
    bool? hasPool,
    bool? furnished,
    bool refresh = false,
  }) async {
    print('📋 PropertyProvider.loadProperties called');
    print('Category filter (categoryName): $category');
    print('Type filter: $type');
    print('Town filter: $town');
    print('Query: $query');
    print('Refresh: $refresh');
    
    // Convertir categoryName en type si nécessaire
    String? finalType = type;
    if (category != null && category.isNotEmpty && type == null) {
      finalType = _categoryNameToType(category);
      print('🔄 Converted categoryName "$category" to type: $finalType');
    }
    
    if (refresh) {
      _searchProperties.clear();
      _nextCursor = null;
      _prevCursor = null;
      print('🔄 Cleared search properties list for refresh');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('🔍 Calling PropertyService.searchProperties');
      print('  - type: $finalType');
      print('  - townId: $town');
      print('  - query: ${query ?? ""}');
      final response = await _propertyService.searchProperties(
        query: query,
        minPrice: minPrice,
        maxPrice: maxPrice,
        townId: town,
        cityId: cityId,
        type: finalType,
        categoryId: null, // Ne plus passer categoryId, utiliser type
        bedrooms: bedrooms,
        available: available,
        hasParking: hasParking,
        hasPool: hasPool,
        furnished: furnished,
        limit: limit ?? 20,
        offset: offset ?? 0,
      );
      
      print('✅ PropertyService.searchProperties returned ${response.length} properties');
      if (response.isNotEmpty) {
        print('📋 First property sample:');
        print('  - id: ${response.first.id}');
        print('  - type: ${response.first.type}');
        print('  - title: ${response.first.title}');
        print('  - hasParking: ${response.first.hasParking}');
        print('  - hasPool: ${response.first.hasPool}');
        print('  - isFurnished: ${response.first.isFurnished}');
      }

      // Filtre côté client si l'API ne filtre pas (meublé, parking, piscine)
      var filtered = response;
      print('🔍 Applying client-side filters:');
      print('  - hasParking filter: $hasParking');
      print('  - hasPool filter: $hasPool');
      print('  - furnished filter: $furnished');
      
      if (hasParking == true) {
        final beforeCount = filtered.length;
        filtered = filtered.where((p) => p.hasParking).toList();
        print('  - hasParking filter removed ${beforeCount - filtered.length} properties');
      }
      if (hasPool == true) {
        final beforeCount = filtered.length;
        filtered = filtered.where((p) => p.hasPool == true).toList();
        print('  - hasPool filter removed ${beforeCount - filtered.length} properties');
      }
      if (furnished == true) {
        final beforeCount = filtered.length;
        filtered = filtered.where((p) => p.isFurnished == true).toList();
        print('  - furnished filter removed ${beforeCount - filtered.length} properties');
      }
      
      print('✅ After client-side filtering: ${filtered.length} properties remain');

      if (refresh) {
        _searchProperties = filtered;
      } else {
        _searchProperties.addAll(filtered);
      }

      // Mettre à jour le total avec la taille de la liste
      _total = _searchProperties.length;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = _userFriendlyError(e);
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Message d'erreur affichable (sans stack trace ni préfixe technique).
  String _userFriendlyError(Object e) {
    final s = e.toString();
    if (s.startsWith('Exception: ')) {
      return s.substring(11);
    }
    if (s.contains('took longer') || s.contains('receive timeout') || s.contains('connect timeout')) {
      return 'La requête a pris trop de temps. Réessayez.';
    }
    if (s.contains('SocketException') || s.contains('Connection')) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion et réessayez.';
    }
    if (s.contains('500') || s.contains('502') || s.contains('503')) {
      return 'Le serveur est temporairement indisponible. Veuillez réessayer dans quelques instants.';
    }
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Recherche de propriétés (GET /api/properties/search)
  /// Filtres doc API : type, cityId, townId, minPrice, maxPrice, bedrooms, available, query, limit, offset, hasParking, hasPool, furnished
  Future<void> searchProperties({
    String? query,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? town,
    String? cityId,
    String? type,
    int? bedrooms,
    bool? available,
    bool? hasParking,
    bool? hasPool,
    bool? isFurnished,
    int? limit,
    int? offset,
    bool refresh = false,
  }) async {
    print('🔍 PropertyProvider.searchProperties called');
    print('  - category (Name): $category');
    print('  - type: $type');
    print('  - query: $query');
    
    await loadProperties(
      query: query,
      minPrice: minPrice,
      maxPrice: maxPrice,
      category: category,
      town: town,
      cityId: cityId,
      type: type,
      bedrooms: bedrooms,
      available: available,
      hasParking: hasParking,
      hasPool: hasPool,
      furnished: isFurnished,
      limit: limit,
      offset: offset,
      refresh: refresh,
    );
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
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _propertyService
          .getMyProperties(); // Currently no args in service

      if (refresh) {
        _myProperties = response;
      } else {
        _myProperties.addAll(response);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading my properties: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les catégories
  Future<void> loadCategories({bool forceRefresh = false}) async {
    if (!forceRefresh && _categories.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _categories = await _propertyService.getCategories();
      print('📋 Categories loaded: ${_categories.length}');
      for (var cat in _categories) {
        print('  - Category: id="${cat.id}", name="${cat.name}", slug="${cat.slug}"');
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('❌ Error loading categories: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les provinces
  Future<void> loadProvinces({bool forceRefresh = false}) async {
    if (!forceRefresh && _provinces.isNotEmpty) {
      print('📋 Provinces already loaded, skipping');
      return;
    }

    print('🏛️ Loading provinces...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Charger d'abord les pays
      print('🌍 Loading countries first...');
      final countries = await _locationService.getCountries();
      print('🌍 Loaded ${countries.length} countries');
      
      if (countries.isEmpty) {
        print('⚠️ No countries found, cannot load provinces');
        _error = 'Aucun pays trouvé';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Charger les provinces du premier pays (ou de tous les pays si nécessaire)
      print('🏛️ Loading provinces for country: ${countries.first.id}');
      _provinces = await _locationService.getProvinces(countries.first.id);
      print('✅ Loaded ${_provinces.length} provinces');
      
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Error loading provinces: $e');
      print('Stack trace: $stackTrace');
      _error = 'Erreur lors du chargement des provinces: ${_userFriendlyError(e)}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Charger les villes
  Future<void> loadCities({required String province, String? search}) async {
    print('🏙️ Loading cities for province: $province');
    _isLoading = true;
    _error = null;
    _cities = []; // Vider la liste avant de charger
    notifyListeners();

    try {
      _cities = await _locationService.getCities(province);
      print('✅ Loaded ${_cities.length} cities');
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Error loading cities: $e');
      print('Stack trace: $stackTrace');
      _error = 'Erreur lors du chargement des villes: ${_userFriendlyError(e)}';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupère une ville par ID (pour afficher la province en mode édition).
  Future<City?> getCityById(String cityId) async {
    return _locationService.getCity(cityId);
  }

  // Charger les communes
  Future<void> loadTowns({required String city, String? search}) async {
    print('🏘️ Loading towns for city: $city');
    _isLoading = true;
    _error = null;
    _towns = []; // Vider la liste avant de charger
    notifyListeners();

    try {
      _towns = await _locationService.getTowns(city);
      print('✅ Loaded ${_towns.length} towns');
      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e, stackTrace) {
      print('❌ Error loading towns: $e');
      print('Stack trace: $stackTrace');
      _error = 'Erreur lors du chargement des communes: ${_userFriendlyError(e)}';
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
      final property = await _propertyService.createProperty(propertyData);
      // Ajouter la propriété à la liste locale
      _myProperties.add(property);
      _isLoading = false;
      notifyListeners();
      return property.id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // Mettre à jour une propriété
  Future<bool> updateProperty(
      String id, Map<String, dynamic> propertyData) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final property = await _propertyService.updateProperty(id, propertyData);

      // Mettre à jour la propriété dans toutes les listes locales
      final homeIndex = _homeProperties.indexWhere((p) => p.id == id);
      if (homeIndex != -1) {
        _homeProperties[homeIndex] = property;
      }
      
      final searchIndex = _searchProperties.indexWhere((p) => p.id == id);
      if (searchIndex != -1) {
        _searchProperties[searchIndex] = property;
      }

      final myIndex = _myProperties.indexWhere((p) => p.id == id);
      if (myIndex != -1) {
        _myProperties[myIndex] = property;
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

  /// Supprime une photo d'une propriété (mode édition).
  Future<void> deletePhoto(String propertyId, String photoId) async {
    await _propertyService.deletePhoto(propertyId, photoId);
  }

  // Supprimer une propriété
  Future<bool> deleteProperty(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _propertyService.deleteProperty(id);

      // Supprimer la propriété de toutes les listes locales
      _homeProperties.removeWhere((p) => p.id == id);
      _searchProperties.removeWhere((p) => p.id == id);
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final property = await _propertyService.getProperty(id);

      // Ajouter la propriété aux listes si elle n'y est pas déjà
      final homeIndex = _homeProperties.indexWhere((p) => p.id == id);
      if (homeIndex != -1) {
        _homeProperties[homeIndex] = property;
      } else {
        _homeProperties.add(property);
      }
      
      final searchIndex = _searchProperties.indexWhere((p) => p.id == id);
      if (searchIndex != -1) {
        _searchProperties[searchIndex] = property;
      } else {
        _searchProperties.add(property);
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

  // Obtenir une de MES propriétés par ID (alias pour getPropertyById pour l'instant)
  Future<Property?> getMyPropertyById(String id) async {
    return getPropertyById(id);
  }

  /// Upload des photos en multipart (API: photos[], caption, isPrimary).
  /// [imagePaths] : chemins des fichiers.
  /// [primaryIndex] : index de la photo principale (affichée en couverture).
  /// [caption] : légende optionnelle.
  Future<void> uploadImages(
    String propertyId,
    List<String> imagePaths, {
    int primaryIndex = 0,
    String? caption,
  }) async {
    if (imagePaths.isEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _propertyService.uploadPhotosMultipart(
        propertyId,
        imagePaths,
        caption: caption,
        primaryIndex: primaryIndex,
      );
      await getPropertyById(propertyId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadCoverImage(String propertyId, String imagePath) async {
    return uploadImages(propertyId, [imagePath], primaryIndex: 0);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearProperties() {
    _homeProperties.clear();
    _searchProperties.clear();
    _nextCursor = null;
    _prevCursor = null;
    _total = 0;
    notifyListeners();
  }
}
