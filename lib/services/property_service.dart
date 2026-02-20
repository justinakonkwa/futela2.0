import 'package:dio/dio.dart';
import '../models/property/property.dart';
import '../models/property/category.dart';
import '../models/property/property_photo.dart';
import 'api_client.dart';

class PropertyService {
  final Dio _dio;

  PropertyService() : _dio = ApiClient().dio;

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
      
      // Gérer les deux formats possibles :
      // 1. Liste directe: [...]
      // 2. Objet Hydra: { "hydra:member": [...] }
      if (response.data is List) {
        print('📋 Response is a direct List');
        categoriesList = response.data as List<dynamic>;
      } else if (response.data is Map) {
        print('📋 Response is a Map with keys: ${(response.data as Map).keys.toList()}');
        categoriesList = (response.data as Map<String, dynamic>)['hydra:member'] ?? [];
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
          if (json is! Map<String, dynamic>) {
            throw Exception('Category JSON is not a Map: ${json.runtimeType}');
          }
          return Category.fromJson(json);
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
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int? bedrooms,
    bool? available,
    String? query,
  }) async {
    final Map<String, dynamic> params = {
      'limit': limit,
      'offset': offset,
    };
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (cityId != null && cityId.isNotEmpty) params['cityId'] = cityId;
    if (townId != null && townId.isNotEmpty) params['townId'] = townId;
    if (categoryId != null && categoryId.isNotEmpty) params['categoryId'] = categoryId;
    if (minPrice != null) params['minPrice'] = minPrice;
    if (maxPrice != null) params['maxPrice'] = maxPrice;
    if (bedrooms != null) params['bedrooms'] = bedrooms;
    if (available != null) params['available'] = available;
    if (query != null && query.isNotEmpty) params['query'] = query;

    print('🏠 GET PROPERTIES SEARCH (PropertyService)');
    print('URL: /api/properties/search');
    print('Query Parameters: $params');

    try {
      final response = await _dio.get('/api/properties/search', queryParameters: params);

      print('🏠 GET PROPERTIES RESPONSE (PropertyService)');
      print('Status Code: ${response.statusCode}');
      print('Response Data Type: ${response.data.runtimeType}');

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
          propertiesList = responseData['properties'] ?? [];
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
      throw Exception(_searchErrorMessage(statusCode));
    }
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
