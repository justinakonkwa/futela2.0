import 'package:dio/dio.dart';
import '../models/property/property.dart';
import '../models/property/category.dart';
import '../models/property/property_photo.dart';
import 'api_client.dart';

/// Extrait la liste de catégories d’une enveloppe JSON (member, Hydra, etc.).
List<dynamic> _categoriesListFromEnvelope(Map<String, dynamic> map) {
  for (final key in ['member', 'hydra:member', 'items', 'data']) {
    final v = map[key];
    if (v is List) {
      print('📋 Categories found in "$key": ${v.length}');
      return List<dynamic>.from(v);
    }
  }
  return [];
}

/// Résultat paginé pour GET /api/properties (format `member` + totalPages ou liste brute).
class PagedPropertiesResult {
  final List<Property> items;
  final int page;
  final int totalPages;
  final int totalItems;

  PagedPropertiesResult({
    required this.items,
    required this.page,
    required this.totalPages,
    required this.totalItems,
  });

  bool get hasNextPage => page < totalPages;
}

class PropertyService {
  final Dio _dio;

  PropertyService() : _dio = ApiClient().dio;

  /// Mappe une catégorie (nom ou slug) vers le type API correspondant
  String? _mapCategoryToType(String category) {
    if (category.isEmpty) return null;
    
    final categoryLower = category.toLowerCase().trim();
    
    print('🔄 _mapCategoryToType: Converting "$category" (lowercase: "$categoryLower")');
    
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
    
    print('⚠️ No mapping found for category: "$category"');
    return null; // Catégorie non reconnue
  }

  // --- Categories ---

  Future<List<Category>> getCategories() async {
    print('🏷️ GET CATEGORIES REQUEST (PropertyService)');
    print('URL: /api/categories');
    
    final response = await _dio.get('/api/categories');

    print('🏷️ GET CATEGORIES RESPONSE (PropertyService)');
    print('Status Code: ${response.statusCode}');
    print('Response Data Type: ${response.data.runtimeType}');
    
    if (response.statusCode == 200) {
      List<dynamic> categoriesList;
      
      // Formats possibles (API v1 Hydra / API v2 paginée) :
      // 1. Liste directe: [...]
      // 2. { "member": [...] }  (souvent après migration)
      // 3. { "hydra:member": [...] }
      if (response.data is List) {
        print('📋 Response is a direct List');
        categoriesList = response.data as List<dynamic>;
      } else if (response.data is Map) {
        final map = Map<String, dynamic>.from(
          response.data as Map,
        );
        print('📋 Response is a Map with keys: ${map.keys.toList()}');
        categoriesList = _categoriesListFromEnvelope(map);
      } else {
        print('❌ Unexpected response type: ${response.data.runtimeType}');
        throw Exception('Format de réponse inattendu pour les catégories');
      }
      
      print('Categories Count: ${categoriesList.length}');
      if (categoriesList.isNotEmpty) {
        print('First Category Sample: ${categoriesList.first}');
      }
      
      final categories = categoriesList.map((json) {
        try {
          if (json is! Map) {
            throw Exception('Category JSON is not a Map: ${json.runtimeType}');
          }
          return Category.fromJson(Map<String, dynamic>.from(json));
        } catch (e, stackTrace) {
          print('❌ Error parsing category: $e');
          print('Category JSON: $json');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
      
      print('✅ Successfully parsed ${categories.length} categories');
      return categories;
    } else {
      print('❌ Failed to load categories: ${response.statusCode}');
      print('Response: ${response.data}');
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  // --- Properties ---

  /// Recherche de propriétés avec filtres (GET /api/properties/search)
  /// Doc API : type, cityId, townId, minPrice, maxPrice, bedrooms, available, query, limit, offset
  Future<List<Property>> searchProperties({
    int limit = 20,
    int offset = 0,
    String? type,
    String? cityId,
    String? townId,
    String? categoryId, // Sera converti en type
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    bool? available,
    String? query,
    // Ces paramètres ne sont pas dans la doc API mais on les garde pour compatibilité
    bool? hasParking,
    bool? hasPool,
    bool? furnished,
  }) async {
    final Map<String, dynamic> params = {
      'limit': limit,
      'offset': offset,
    };
    
    // Utiliser le type fourni ou mapper la catégorie vers le type
    String? finalType = type;
    if (finalType == null && categoryId != null && categoryId.isNotEmpty) {
      print('🔥 SEARCH SERVICE - Attempting to map category to type');
      print('  - Input categoryId: "$categoryId"');
      finalType = _mapCategoryToType(categoryId);
      print('  - Mapped to type: "$finalType"');
    } else if (finalType != null) {
      print('🔥 SEARCH SERVICE - Type already provided: "$finalType"');
    } else {
      print('🔥 SEARCH SERVICE - No type or category provided');
    }
    
    // Paramètres selon la documentation API
    if (finalType != null && finalType.isNotEmpty) params['type'] = finalType;
    if (cityId != null && cityId.isNotEmpty) params['cityId'] = cityId;
    if (townId != null && townId.isNotEmpty) params['townId'] = townId;
    if (minPrice != null && minPrice > 0) params['minPrice'] = minPrice; // Ne pas envoyer si 0
    if (maxPrice != null && maxPrice > 0) params['maxPrice'] = maxPrice;
    if (bedrooms != null && bedrooms > 0) params['bedrooms'] = bedrooms; // Ne pas envoyer si 0
    if (available != null) params['available'] = available;
    if (query != null && query.isNotEmpty && query.length <= 255) params['query'] = query;
    
    // Paramètres non documentés mais gardés pour compatibilité (seront ignorés par l'API)
    if (hasParking == true) params['hasParking'] = true;
    if (hasPool == true) params['hasPool'] = true;
    if (furnished == true) params['furnished'] = true;

    print('🏠 GET PROPERTIES SEARCH (PropertyService)');
    print('URL: /api/properties/search');
    print('Query Parameters: $params');
    print('🔥 FINAL SEARCH PARAMS: $params');

    try {
      final response = await _dio.get('/api/properties/search', queryParameters: params);

      print('🏠 GET PROPERTIES RESPONSE (PropertyService)');
      print('Status Code: ${response.statusCode}');
      print('Response Data Type: ${response.data.runtimeType}');
      print('═══════════════════════════════════════════════════════════');
      print('📥 RAW API RESPONSE:');
      print(response.data);
      print('═══════════════════════════════════════════════════════════');

      if (response.statusCode == 200) {
        List<dynamic> propertiesList;
        Map<String, dynamic>? pagination;

        if (response.data is List) {
          print('📋 Response is a direct List');
          propertiesList = response.data as List<dynamic>;
          pagination = null;
        } else if (response.data is Map) {
          print('📋 Response is a Map with keys: ${(response.data as Map).keys.toList()}');
          final Map<String, dynamic> responseData = response.data as Map<String, dynamic>;
          
          // L'API peut retourner 'member', 'properties', ou 'hydra:member'
          propertiesList = responseData['member'] ?? 
                          responseData['properties'] ?? 
                          responseData['hydra:member'] ?? 
                          [];
          
          print('📋 Found ${propertiesList.length} properties in response');
          
          pagination = responseData['pagination'] != null
              ? responseData['pagination'] as Map<String, dynamic>
              : null;
        } else {
          print('❌ Unexpected response type: ${response.data.runtimeType}');
          throw Exception('Format de réponse inattendu pour les propriétés');
        }

        print('Properties Count: ${propertiesList.length}');
        if (pagination != null) {
          print('Pagination: total=${pagination['total']}, currentPage=${pagination['currentPage']}, totalPages=${pagination['totalPages']}');
        }
        if (propertiesList.isNotEmpty) {
          print('First Property Sample: ${propertiesList.first}');
        }

        final parsedProperties = propertiesList.map((json) {
          try {
            if (json is! Map<String, dynamic>) {
              throw Exception('Property JSON is not a Map: ${json.runtimeType}');
            }
            return Property.fromJson(json);
          } catch (e, stackTrace) {
            print('❌ Error parsing property: $e');
            print('Property JSON: $json');
            print('Stack trace: $stackTrace');
            rethrow;
          }
        }).toList();

        print('✅ Successfully parsed ${parsedProperties.length} properties');
        return parsedProperties;
      } else {
        print('❌ Failed to search properties: ${response.statusCode}');
        print('Response: ${response.data}');
        throw Exception(_searchErrorMessage(response.statusCode));
      }
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      print('❌ DioException searching properties: $e');
      print('Status: $statusCode, Response: ${e.response?.data}');
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('La requête a pris trop de temps. Réessayez.');
      }
      throw Exception(_searchErrorMessage(statusCode));
    }
  }

  /// Liste toutes les propriétés (page d’accueil) — GET /api/properties
  /// Pagination v2 : page, itemsPerPage ; réponse possible : `member`, `properties`, liste, Hydra.
  Future<PagedPropertiesResult> listProperties({
    int page = 1,
    int itemsPerPage = 30,
    String? categoryId,
  }) async {
    final Map<String, dynamic> params = {
      'page': page,
      'itemsPerPage': itemsPerPage,
    };
    if (categoryId != null && categoryId.isNotEmpty) {
      print('🔥 SERVICE - Attempting to map category to type');
      print('  - Input categoryId: "$categoryId"');
      final mappedType = _mapCategoryToType(categoryId);
      print('  - Mapped type: "$mappedType"');
      if (mappedType != null) {
        params['type'] = mappedType;
        print('🔥 SERVICE - Added type param to request');
        print('  - API param "type": ${params['type']}');
      } else {
        print('🔥 SERVICE - Could not map category "$categoryId" to a valid type');
      }
    } else {
      print('🔥 SERVICE - No category filter (showing all properties)');
    }

    print('🏠 GET PROPERTIES LIST (PropertyService)');
    print('URL: /api/properties');
    print('Query Parameters: $params');
    print('🔥 FINAL PARAMS BEING SENT TO API: $params');

    try {
      final response =
          await _dio.get('/api/properties', queryParameters: params);

      print('🏠 GET PROPERTIES LIST RESPONSE');
      print('Status Code: ${response.statusCode}');
      print('Response Data Type: ${response.data.runtimeType}');

      if (response.statusCode != 200) {
        print('❌ Failed list properties: ${response.statusCode}');
        throw Exception(_searchErrorMessage(response.statusCode));
      }

      final result = _parsePagedPropertiesResponse(
        response.data,
        requestedPage: page,
        itemsPerPage: itemsPerPage,
      );

      print('Properties Count: ${result.items.length}');
      print(
          'Pagination: page=${result.page}, totalPages=${result.totalPages}, totalItems=${result.totalItems}');
      if (result.items.isNotEmpty) {
        print('First Property Sample: ${result.items.first.id}');
        print('🔍 PROPERTY DETAILS FOR DEBUGGING:');
        print('  - Property ID: ${result.items.first.id}');
        print('  - Property Title: ${result.items.first.title}');
        print('  - Property Category: ${result.items.first.categoryName}');
        if (result.items.length > 1) {
          print('  - Second Property ID: ${result.items[1].id}');
          print('  - Second Property Category: ${result.items[1].categoryName}');
        }
      }
      print('✅ Successfully parsed ${result.items.length} properties (list)');
      return result;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      print('❌ DioException list properties: $e');
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        throw Exception('La requête a pris trop de temps. Réessayez.');
      }
      throw Exception(_searchErrorMessage(statusCode));
    }
  }

  PagedPropertiesResult _parsePagedPropertiesResponse(
    dynamic data, {
    required int requestedPage,
    required int itemsPerPage,
  }) {
    List<dynamic> rawList = [];
    int totalItems = 0;
    int totalPages = 1;
    int currentPage = requestedPage;

    print('🔍 _parsePagedPropertiesResponse called');
    print('  - data type: ${data.runtimeType}');

    if (data is List) {
      print('  - Data is a List');
      rawList = data;
      totalItems = rawList.length;
      currentPage = requestedPage;
      totalPages = rawList.length < itemsPerPage ? requestedPage : requestedPage + 1;
    } else if (data is Map<String, dynamic>) {
      final m = data;
      print('  - Data is a Map with keys: ${m.keys.toList()}');
      
      if (m['member'] is List) {
        rawList = m['member'] as List<dynamic>;
        print('  - Found "member" key with ${rawList.length} items');
      } else if (m['properties'] is List) {
        rawList = m['properties'] as List<dynamic>;
        print('  - Found "properties" key with ${rawList.length} items');
      } else if (m['hydra:member'] is List) {
        rawList = m['hydra:member'] as List<dynamic>;
        print('  - Found "hydra:member" key with ${rawList.length} items');
      } else {
        print('  - ⚠️ No valid list key found in Map');
      }

      totalItems = (m['totalItems'] as num?)?.toInt() ??
          (m['hydra:totalItems'] as num?)?.toInt() ??
          rawList.length;
      totalPages = (m['totalPages'] as num?)?.toInt() ?? 1;
      currentPage = (m['page'] as num?)?.toInt() ?? requestedPage;

      print('  - totalItems: $totalItems');
      print('  - totalPages: $totalPages');
      print('  - currentPage: $currentPage');

      if (totalPages <= 1 &&
          totalItems > rawList.length &&
          rawList.length == itemsPerPage) {
        totalPages = (totalItems / itemsPerPage).ceil();
      }
      if (totalPages <= 1 && rawList.length == itemsPerPage) {
        totalPages = currentPage + 1;
      }
    } else {
      print('  - ❌ Unexpected data type');
      throw Exception('Format de réponse inattendu pour /api/properties');
    }

    print('🔄 About to parse ${rawList.length} properties');

    final items = rawList.map((json) {
      if (json is! Map<String, dynamic>) {
        print('❌ Property JSON is not a Map: ${json.runtimeType}');
        throw Exception('Property JSON is not a Map: ${json.runtimeType}');
      }
      try {
        final property = Property.fromJson(json);
        print('✅ Successfully parsed property: id=${property.id}, type=${property.type}, title=${property.title}');
        return property;
      } catch (e, stackTrace) {
        print('❌ Error parsing property JSON:');
        print('JSON: $json');
        print('Error: $e');
        print('StackTrace: $stackTrace');
        rethrow;
      }
    }).toList();

    print('📊 Parsed ${items.length} properties successfully');
    
    return PagedPropertiesResult(
      items: items,
      page: currentPage,
      totalPages: totalPages < 1 ? 1 : totalPages,
      totalItems: totalItems,
    );
  }

  /// Message utilisateur selon le code HTTP (recherche propriétés).
  static String _searchErrorMessage(int? statusCode) {
    if (statusCode == null) {
      return 'Impossible de joindre le serveur. Vérifiez votre connexion et réessayez.';
    }
    if (statusCode >= 500 && statusCode < 600) {
      return 'Le serveur est temporairement indisponible. Veuillez réessayer dans quelques instants.';
    }
    if (statusCode == 404) {
      return 'Service de recherche indisponible. Réessayez plus tard.';
    }
    if (statusCode == 400 || statusCode == 422) {
      return 'Critères de recherche invalides. Modifiez les filtres et réessayez.';
    }
    if (statusCode == 401 || statusCode == 403) {
      return 'Accès refusé. Connectez-vous si nécessaire.';
    }
    return 'Une erreur est survenue (${statusCode}). Veuillez réessayer.';
  }

  Future<Property> getProperty(String id) async {
    print('🏠 GET PROPERTY REQUEST (détail / édition)');
    print('URL: /api/properties/$id');
    final response = await _dio.get('/api/properties/$id');
    print('🏠 GET PROPERTY RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('═══════════════════════════════════════════════════════════');
    print('📥 RÉPONSE BRUTE /api/properties/$id (clic Modifier):');
    print(response.data);
    print('═══════════════════════════════════════════════════════════');
    if (response.statusCode == 200) {
      return Property.fromJson(response.data);
    } else {
      throw Exception('Failed to retrieve property details');
    }
  }

  /// Récupère les propriétés de l'utilisateur connecté.
  /// GET /api/me/properties avec pagination (page, itemsPerPage).
  /// Réponse Hydra : hydra:member (PropertyResponse[]), hydra:totalItems.
  Future<List<Property>> getMyProperties({
    int page = 1,
    int itemsPerPage = 20,
  }) async {
    print('🏠 GET MY PROPERTIES REQUEST');
    print('URL: /api/me/properties');
    print('Query Parameters: {page: $page, itemsPerPage: $itemsPerPage}');

    final response = await _dio.get('/api/me/properties', queryParameters: {
      'page': page,
      'itemsPerPage': itemsPerPage,
    });

    print('🏠 GET MY PROPERTIES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Response Data Type: ${response.data.runtimeType}');
    print('═══════════════════════════════════════════════════════════');
    print('📥 RÉPONSE BRUTE /api/me/properties (entrée Mes propriétés):');
    print(response.data);
    print('═══════════════════════════════════════════════════════════');

    if (response.statusCode == 200) {
      List<dynamic> propertiesList;
      final dataMap = response.data is Map
          ? response.data as Map<String, dynamic>
          : null;

      if (response.data is List) {
        print('📋 Response is a direct List');
        propertiesList = response.data as List<dynamic>;
      } else if (dataMap != null) {
        print('📋 Response is Hydra Map with keys: ${dataMap.keys.toList()}');
        propertiesList = dataMap['hydra:member'] ?? [];
        final totalItems = dataMap['hydra:totalItems'];
        if (totalItems != null) {
          print('Total items: $totalItems');
        }
      } else {
        print('❌ Unexpected response type: ${response.data.runtimeType}');
        throw Exception('Format de réponse inattendu pour les propriétés');
      }

      print('Properties Count: ${propertiesList.length}');
      if (propertiesList.isNotEmpty) {
        print('First Property Sample: ${propertiesList.first}');
      }

      final parsedProperties = propertiesList.map((json) {
        try {
          if (json is! Map<String, dynamic>) {
            throw Exception('Property data is not a Map: ${json.runtimeType}');
          }
          return Property.fromJson(json);
        } catch (e, stackTrace) {
          print('❌ Error parsing property: $e');
          print('Property JSON: $json');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();

      print('✅ Successfully parsed ${parsedProperties.length} properties');
      return parsedProperties;
    } else {
      print('❌ Failed to load my properties: ${response.statusCode}');
      print('Response: ${response.data}');
      throw Exception('Failed to load my properties: ${response.statusCode}');
    }
  }

  Future<Property> createProperty(Map<String, dynamic> propertyData) async {
    final response = await _dio.post('/api/properties', data: propertyData);

    print('═══════════════════════════════════════════════════════════');
    print('📥 RÉPONSE API (création propriété) - status: ${response.statusCode}');
    print('═══════════════════════════════════════════════════════════');
    print(response.data);
    print('═══════════════════════════════════════════════════════════');

    if (response.statusCode == 201) {
      return Property.fromJson(response.data);
    } else {
      throw Exception('Failed to create property: ${response.data}');
    }
  }

  Future<Property> updateProperty(
      String id, Map<String, dynamic> propertyData) async {
    final response = await _dio.put('/api/properties/$id', data: propertyData);

    print('═══════════════════════════════════════════════════════════');
    print('📥 RÉPONSE API (mise à jour propriété) - status: ${response.statusCode}');
    print('═══════════════════════════════════════════════════════════');
    print(response.data);
    print('═══════════════════════════════════════════════════════════');

    if (response.statusCode == 200) {
      return Property.fromJson(response.data);
    } else {
      throw Exception('Failed to update property: ${response.data}');
    }
  }

  Future<void> deleteProperty(String id) async {
    final response = await _dio.delete('/api/properties/$id');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete property');
    }
  }

  Future<void> publishProperty(String id) async {
    await _dio.post('/api/properties/$id/publish');
  }

  Future<void> unpublishProperty(String id) async {
    await _dio.post('/api/properties/$id/unpublish');
  }

  // --- Photos ---

  /// Upload une seule photo pour une propriété (avec URL)
  Future<PropertyPhoto> uploadPhoto(String propertyId, String photoUrl,
      {String? caption, bool isPrimary = false}) async {
    final response =
        await _dio.post('/api/properties/$propertyId/photos', data: {
      'propertyId': propertyId,
      'photoUrl': photoUrl,
      'caption': caption,
      'isPrimary': isPrimary,
    });

    if (response.statusCode == 201) {
      return PropertyPhoto.fromJson(response.data);
    } else {
      throw Exception('Failed to upload photo: ${response.statusCode}');
    }
  }

  /// Upload plusieurs photos pour une propriété (avec URLs)
  /// Conforme à la documentation API
  Future<List<PropertyPhoto>> uploadPhotos(
      String propertyId, List<String> photoUrls) async {
    final List<PropertyPhoto> uploadedPhotos = [];

    for (int i = 0; i < photoUrls.length; i++) {
      final photo = await uploadPhoto(
        propertyId,
        photoUrls[i],
        isPrimary: i == 0, // La première photo est la photo principale
      );
      uploadedPhotos.add(photo);
    }

    return uploadedPhotos;
  }

  /// Upload de photos en multipart/form-data (conforme à l'API : photos[], caption, isPrimary)
  /// [filePaths] : chemins des fichiers (la photo principale doit être en premier si [primaryIndex] == 0)
  /// [primaryIndex] : index dans [filePaths] de la photo principale (l'API prend la 1ère du tableau si isPrimary=true)
  Future<List<PropertyPhoto>> uploadPhotosMultipart(
    String propertyId,
    List<String> filePaths, {
    String? caption,
    int primaryIndex = 0,
  }) async {
    if (filePaths.isEmpty) return [];

    // Réordonner pour mettre la photo principale en premier (API : "la première photo sera définie comme principale")
    final ordered = <String>[];
    if (primaryIndex >= 0 && primaryIndex < filePaths.length) {
      ordered.add(filePaths[primaryIndex]);
      for (int i = 0; i < filePaths.length; i++) {
        if (i != primaryIndex) ordered.add(filePaths[i]);
      }
    } else {
      ordered.addAll(filePaths);
    }

    final formData = FormData.fromMap({
      'caption': caption ?? '',
      'isPrimary': true,
    });

    for (int i = 0; i < ordered.length; i++) {
      formData.files.add(MapEntry(
        'photos[$i]',
        await MultipartFile.fromFile(
          ordered[i],
          filename: ordered[i].split('/').last,
        ),
      ));
    }

    final response = await _dio.post(
      '/api/properties/$propertyId/photos',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json'},
      ),
    );

    if (response.statusCode == 201) {
      final data = response.data;
      // Liste de photos directement
      if (data is List) {
        return data
            .map((e) => PropertyPhoto.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      if (data is Map<String, dynamic>) {
        if (data['photos'] is List) {
          return (data['photos'] as List)
              .map((e) => PropertyPhoto.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        // Objet unique (photo ou propriété avec champs photo)
        if (data['url'] != null || data['filename'] != null) {
          return [PropertyPhoto.fromJson(data)];
        }
      }
    }
    throw Exception('Échec upload photos: ${response.statusCode}');
  }

  /// Upload un fichier image directement pour une propriété
  /// D'abord upload le fichier vers /upload-images/{propertyId} pour obtenir une URL
  /// Puis utilise cette URL avec /api/properties/{id}/photos
  Future<PropertyPhoto> uploadPhotoFile(String propertyId, String filePath,
      {String? caption, bool isPrimary = false}) async {
    print('📸 UPLOAD PHOTO FILE REQUEST');
    print('Property ID: $propertyId');
    print('File Path: $filePath');
    print('Is Primary: $isPrimary');

    try {
      // Étape 1: Uploader le fichier vers /upload-images/{propertyId}
      // Liste des noms de champs possibles à essayer
      final candidateFieldNames = ['file', 'photo', 'image', 'photos', 'images'];
      String? photoUrl;
      
      for (final fieldName in candidateFieldNames) {
        try {
          print('📸 Trying to upload file with field name: $fieldName');
          
          final formData = FormData.fromMap({
            fieldName: await MultipartFile.fromFile(
              filePath,
              filename: filePath.split('/').last,
            ),
          });

          final uploadResponse = await _dio.post(
            '/upload-images/$propertyId',
            data: formData,
          );

          print('📸 FILE UPLOAD RESPONSE (field: $fieldName)');
          print('Status Code: ${uploadResponse.statusCode}');
          print('Response: ${uploadResponse.data}');

          if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 201) {
            // Extraire l'URL de la réponse
            if (uploadResponse.data is Map) {
              final data = uploadResponse.data as Map<String, dynamic>;
              // Essayer différents champs possibles pour l'URL
              photoUrl = data['url'] ?? 
                        data['photoUrl'] ?? 
                        data['imageUrl'] ?? 
                        data['fileUrl'] ??
                        (data['data'] is Map ? (data['data'] as Map)['url'] : null);
              
              if (photoUrl == null && data['filename'] != null) {
                // Construire l'URL à partir du filename si nécessaire
                photoUrl = 'https://cdn.futela.com/uploads/${data['filename']}';
              }
            } else if (uploadResponse.data is String) {
              photoUrl = uploadResponse.data as String;
            }
            
            if (photoUrl != null && photoUrl.isNotEmpty) {
              print('✅ File uploaded successfully, got URL: $photoUrl');
              break;
            }
          }
        } catch (e) {
          print('❌ ERROR uploading file with field $fieldName: $e');
          // Continuer avec le champ suivant
          continue;
        }
      }
      
      if (photoUrl == null || photoUrl.isEmpty) {
        throw Exception('Failed to upload file: Could not get photo URL from upload endpoint');
      }
      
      // Étape 2: Utiliser l'URL pour créer la photo via /api/properties/{id}/photos
      print('📸 Creating photo record with URL: $photoUrl');
      return await uploadPhoto(propertyId, photoUrl, caption: caption, isPrimary: isPrimary);
      
    } catch (e) {
      print('❌ ERROR in uploadPhotoFile: $e');
      rethrow;
    }
  }

  /// Upload plusieurs fichiers images directement pour une propriété
  Future<List<PropertyPhoto>> uploadPhotoFiles(
      String propertyId, List<String> filePaths) async {
    final List<PropertyPhoto> uploadedPhotos = [];

    for (int i = 0; i < filePaths.length; i++) {
      try {
        final photo = await uploadPhotoFile(
          propertyId,
          filePaths[i],
          isPrimary: i == 0, // La première photo est la photo principale
        );
        uploadedPhotos.add(photo);
      } catch (e) {
        print('❌ Error uploading photo ${i + 1}/${filePaths.length}: $e');
        // Continuer avec les autres photos même si une échoue
      }
    }

    return uploadedPhotos;
  }

  Future<void> deletePhoto(String propertyId, String photoId) async {
    final response =
        await _dio.delete('/api/properties/$propertyId/photos/$photoId');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete photo: ${response.statusCode}');
    }
  }

  // --- Availability & Calendar ---

  Future<Map<String, dynamic>> checkAvailability(
      String propertyId, String checkIn, String checkOut) async {
    final response = await _dio
        .get('/api/properties/$propertyId/availability', queryParameters: {
      'checkIn': checkIn,
      'checkOut': checkOut,
    });

    if (response.statusCode == 200) {
      return response.data;
    } else {
      throw Exception('Failed to check availability');
    }
  }
}
