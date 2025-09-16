import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import '../models/user.dart';
import '../models/property.dart';
import '../models/auth_response.dart';
import '../models/visit.dart';
import '../models/fee.dart';
import '../models/favorite.dart';

class ApiService {
  static const String baseUrl = 'https://cpanel.futela.com'; // URL de l'API Futela
  static const String apiVersion = '';
  
  static String get fullBaseUrl => '$baseUrl$apiVersion';
  
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }


  // Auth endpoints
  static Future<AuthResponse> signIn(String login, String password) async {
    final url = '$fullBaseUrl/auth/sign-in';
    final headers = await _getHeaders();
    final body = jsonEncode({
      'login': login,
      'password': password,
    });

    print('🔐 LOGIN API REQUEST:');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('🔐 LOGIN API RESPONSE:');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('🔐 LOGIN SUCCESS - Parsed Data: $data');
      return AuthResponse.fromJson(data);
    } else if (response.statusCode == 401) {
      print('🔐 LOGIN FAILED - 401 Unauthorized');
      throw Exception('Login ou mot de passe incorrect');
    } else {
      print('🔐 LOGIN FAILED - Status: ${response.statusCode}');
      throw Exception('Erreur de connexion: ${response.statusCode}');
    }
  }

  static Future<AuthResponse> signUp({
    required String phone,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? middleName,
  }) async {
    final url = '$fullBaseUrl/auth/sign-up';
    final headers = await _getHeaders();
    final body = jsonEncode({
      'phone': phone,
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      if (middleName != null) 'middleName': middleName,
    });

    print('📝 SIGNUP API REQUEST:');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('📝 SIGNUP API RESPONSE:');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('📝 SIGNUP SUCCESS - Parsed Data: $data');
      return AuthResponse.fromJson(data);
    } else if (response.statusCode == 409) {
      print('📝 SIGNUP FAILED - 409 Conflict');
      throw Exception('L\'utilisateur existe déjà ou utilise un numéro/email existant');
    } else {
      print('📝 SIGNUP FAILED - Status: ${response.statusCode}');
      throw Exception('Erreur d\'inscription: ${response.statusCode}');
    }
  }

  static Future<User> getProfile() async {
    final url = '$fullBaseUrl/auth/profile';
    final headers = await _getHeaders();

    print('👤 GET PROFILE API REQUEST:');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('👤 GET PROFILE API RESPONSE:');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('👤 GET PROFILE SUCCESS - Parsed Data: $data');
      return User.fromJson(data);
    } else if (response.statusCode == 404) {
      print('👤 GET PROFILE FAILED - 404 Not Found');
      throw Exception('Utilisateur non trouvé');
    } else {
      print('👤 GET PROFILE FAILED - Status: ${response.statusCode}');
      throw Exception('Erreur de récupération du profil: ${response.statusCode}');
    }
  }

  static Future<User> getPublicProfile(String id) async {
    final response = await http.get(
      Uri.parse('$fullBaseUrl/auth/public/profile/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Utilisateur non trouvé');
    } else {
      throw Exception('Erreur de récupération du profil public: ${response.statusCode}');
    }
  }

  static Future<void> updateUserInfo(Map<String, dynamic> userData) async {
    final response = await http.patch(
      Uri.parse('$fullBaseUrl/auth/user/update-infos'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Utilisateur non trouvé');
    } else {
      throw Exception('Erreur de mise à jour: ${response.statusCode}');
    }
  }

  static Future<void> updatePassword(String oldPassword, String newPassword) async {
    final response = await http.patch(
      Uri.parse('$fullBaseUrl/auth/user/update-password'),
      headers: await _getHeaders(),
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Utilisateur non trouvé');
    } else {
      throw Exception('Erreur de mise à jour du mot de passe: ${response.statusCode}');
    }
  }

  // Properties endpoints
  static Future<String> createProperty(Map<String, dynamic> propertyData) async {
    final url = '$fullBaseUrl/properties';
    final headers = await _getHeaders();
    final body = jsonEncode(propertyData);

    print('🏗️ CREATE PROPERTY REQUEST');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('🏗️ CREATE PROPERTY RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else if (response.statusCode == 400) {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Données de propriété invalides';
        final details = errorData['details'] ?? errorData['errors'] ?? '';
        throw Exception('Erreur de validation: $message${details != '' ? ' - Détails: $details' : ''}');
      } catch (e) {
        throw Exception('Données de propriété invalides: ${response.body}');
      }
    } else {
      throw Exception('Erreur de création de propriété: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getProperties({
    String? direction,
    String? cursor,
    int? limit,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? owner,
    String? town,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    if (direction != null) queryParams['direction'] = direction;
    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (category != null) queryParams['category'] = category;
    if (owner != null) queryParams['owner'] = owner;
    if (town != null) queryParams['town'] = town;
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$fullBaseUrl/properties').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    print('🏠 GET PROPERTIES REQUEST');
    print('URL: ${uri.toString()}');
    print('Headers: $headers');
    print('Query: $queryParams');

    final response = await http.get(uri, headers: headers);

    print('🏠 GET PROPERTIES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      // Tolérance: l'API peut renvoyer soit un objet { metaData, properties }, soit une liste brute
      if (decoded is List) {
        return {
          'metaData': {
            'nextCursor': null,
            'prevCursor': null,
            'total': decoded.length,
          },
          'properties': decoded,
        };
      }
      return decoded as Map<String, dynamic>;
    } else {
      throw Exception('Erreur de récupération des propriétés: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getMyProperties({
    String? direction,
    String? cursor,
    int? limit,
    double? minPrice,
    double? maxPrice,
    String? category,
    String? owner,
    String? town,
    String? type,
  }) async {
    final queryParams = <String, String>{};
    if (direction != null) queryParams['direction'] = direction;
    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (minPrice != null) queryParams['minPrice'] = minPrice.toString();
    if (maxPrice != null) queryParams['maxPrice'] = maxPrice.toString();
    if (category != null) queryParams['category'] = category;
    if (owner != null) queryParams['owner'] = owner;
    if (town != null) queryParams['town'] = town;
    if (type != null) queryParams['type'] = type;

    final uri = Uri.parse('$fullBaseUrl/properties/users/my-properties').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    print('👤 GET MY PROPERTIES REQUEST');
    print('URL: ${uri.toString()}');
    print('Headers: $headers');
    print('Query: $queryParams');

    final response = await http.get(uri, headers: headers);

    print('👤 GET MY PROPERTIES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return {
          'metaData': {
            'nextCursor': null,
            'prevCursor': null,
            'total': decoded.length,
          },
          'properties': decoded,
        };
      }
      return decoded as Map<String, dynamic>;
    } else {
      throw Exception('Erreur de récupération de mes propriétés: ${response.statusCode}');
    }
  }

  static Future<Property> getProperty(String id) async {
    final url = '$fullBaseUrl/properties/$id';
    final headers = await _getHeaders();

    print('🔎 GET PROPERTY REQUEST');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('🔎 GET PROPERTY RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Property.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Propriété non trouvée');
    } else {
      throw Exception('Erreur de récupération de la propriété: ${response.statusCode}');
    }
  }

  // My properties endpoints
  static Future<Property> getMyProperty(String id) async {
    final url = '$fullBaseUrl/properties/users/my-properties/$id';
    final headers = await _getHeaders();

    print('👤🔎 GET MY PROPERTY REQUEST');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('👤🔎 GET MY PROPERTY RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Property.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Propriété non trouvée');
    } else {
      throw Exception('Erreur de récupération de ma propriété: ${response.statusCode}');
    }
  }

  static Future<void> updateProperty(String id, Map<String, dynamic> propertyData) async {
    final url = '$fullBaseUrl/properties/$id';
    final headers = await _getHeaders();
    final body = jsonEncode(propertyData);

    print('✏️ UPDATE PROPERTY REQUEST');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.patch(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('✏️ UPDATE PROPERTY RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Propriété non trouvée');
    } else {
      throw Exception('Erreur de mise à jour de la propriété: ${response.statusCode}');
    }
  }

  static Future<void> deleteProperty(String id) async {
    final url = '$fullBaseUrl/properties/$id';
    final headers = await _getHeaders();

    print('🗑️ DELETE PROPERTY REQUEST');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http.delete(
      Uri.parse(url),
      headers: headers,
    );

    print('🗑️ DELETE PROPERTY RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      return;
    } else if (response.statusCode == 404) {
      throw Exception('Propriété non trouvée');
    } else {
      throw Exception('Erreur de suppression de la propriété: ${response.statusCode}');
    }
  }

  // Categories endpoints
  static Future<List<PropertyCategory>> getCategories() async {
    final url = '$fullBaseUrl/categories';
    final headers = await _getHeaders();

    print('🏷️ GET CATEGORIES REQUEST');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('🏷️ GET CATEGORIES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final categories = data['categories'] as List;
      return categories.map((json) => PropertyCategory.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de récupération des catégories: ${response.statusCode}');
    }
  }

  // Provinces, Cities, Towns endpoints
  static Future<List<Province>> getProvinces() async {
    final url = '$fullBaseUrl/provinces';
    final headers = await _getHeaders();

    print('🗺️ GET PROVINCES REQUEST');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('🗺️ GET PROVINCES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final provinces = data['provinces'] as List;
      return provinces.map((json) => Province.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de récupération des provinces: ${response.statusCode}');
    }
  }

  static Future<List<City>> getCities({String? province, String? search}) async {
    final queryParams = <String, String>{};
    if (province != null) queryParams['province'] = province;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('$fullBaseUrl/cities').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    print('🏙️ GET CITIES REQUEST');
    print('URL: ${uri.toString()}');
    print('Headers: $headers');
    print('Query: $queryParams');

    final response = await http.get(uri, headers: headers);

    print('🏙️ GET CITIES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final cities = data['cities'] as List;
      return cities.map((json) => City.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de récupération des villes: ${response.statusCode}');
    }
  }

  static Future<List<Town>> getTowns({String? city, String? search}) async {
    final queryParams = <String, String>{};
    if (city != null) queryParams['city'] = city;
    if (search != null) queryParams['search'] = search;

    final uri = Uri.parse('$fullBaseUrl/towns').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    print('🏘️ GET TOWNS REQUEST');
    print('URL: ${uri.toString()}');
    print('Headers: $headers');
    print('Query: $queryParams');

    final response = await http.get(uri, headers: headers);

    print('🏘️ GET TOWNS RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final towns = data['towns'] as List;
      return towns.map((json) => Town.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de récupération des communes: ${response.statusCode}');
    }
  }

  // Visits endpoints
  static Future<String> createVisit(VisitRequest visitRequest) async {
    final url = '$fullBaseUrl/visits';
    final headers = await _getHeaders();
    final body = jsonEncode(visitRequest.toJson());

    print('📅 CREATE VISIT REQUEST');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('📅 CREATE VISIT RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['id'] ?? '';
    } else if (response.statusCode == 409) {
      throw Exception('Conflit: Cette visite existe déjà');
    } else if (response.statusCode == 400) {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Requête invalide';
        throw Exception('Erreur de validation: $message');
      } catch (e) {
        throw Exception('Erreur de validation: ${response.body}');
      }
    } else {
      throw Exception('Erreur de création de visite: ${response.statusCode}');
    }
  }

  static Future<VisitResponse> getMyVisits({
    String? direction,
    String? cursor,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (direction != null) queryParams['direction'] = direction;
    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$fullBaseUrl/visits/my-visits').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    print('📅 GET MY VISITS REQUEST');
    print('URL: ${uri.toString()}');
    print('Headers: $headers');
    print('Query: $queryParams');

    final response = await http.get(uri, headers: headers);

    print('📅 GET MY VISITS RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return VisitResponse.fromJson(data);
    } else {
      throw Exception('Erreur de récupération des visites: ${response.statusCode}');
    }
  }

  static Future<PaymentResponse> payVisit(String visitId, PaymentRequest paymentRequest) async {
    final url = '$fullBaseUrl/visits/$visitId/pay';
    final headers = await _getHeaders();
    final body = jsonEncode(paymentRequest.toJson());

    print('💳 PAY VISIT REQUEST');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('💳 PAY VISIT RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 202) {
      final data = jsonDecode(response.body);
      return PaymentResponse.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('La propriété que vous voulez payer n\'existe pas');
    } else if (response.statusCode == 417) {
      throw Exception('Le paiement a été refusé ou a échoué');
    } else {
      throw Exception('Erreur de paiement: ${response.statusCode}');
    }
  }

  // Payments endpoints
  static Future<PaymentCheckResponse> checkPayment(String paymentId) async {
    final url = '$fullBaseUrl/payments/check/$paymentId';
    final headers = await _getHeaders();

    print('🔍 CHECK PAYMENT REQUEST');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('🔍 CHECK PAYMENT RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PaymentCheckResponse.fromJson(data);
    } else if (response.statusCode == 417) {
      throw Exception('Erreur de vérification du paiement');
    } else {
      throw Exception('Erreur de vérification du paiement: ${response.statusCode}');
    }
  }

  static Future<void> requestWithdrawal(WithdrawalRequest withdrawalRequest) async {
    final url = '$fullBaseUrl/payments/users/withdrawal';
    final headers = await _getHeaders();
    final body = jsonEncode(withdrawalRequest.toJson());

    print('💰 WITHDRAWAL REQUEST');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('💰 WITHDRAWAL RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 202) {
      return;
    } else if (response.statusCode == 417) {
      throw Exception('Le retrait a été refusé ou a échoué');
    } else {
      throw Exception('Erreur de retrait: ${response.statusCode}');
    }
  }

  // Fees endpoints
  static Future<FeeResponse> getFees({
    String? direction,
    String? cursor,
    int? limit,
  }) async {
    final queryParams = <String, String>{};
    if (direction != null) queryParams['direction'] = direction;
    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit.toString();

    final uri = Uri.parse('$fullBaseUrl/fees').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    print('💸 GET FEES REQUEST');
    print('URL: ${uri.toString()}');
    print('Headers: $headers');
    print('Query: $queryParams');

    final response = await http.get(uri, headers: headers);

    print('💸 GET FEES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FeeResponse.fromJson(data);
    } else {
      throw Exception('Erreur de récupération des frais: ${response.statusCode}');
    }
  }

  static Future<Fee> getFee(String feeId) async {
    final url = '$fullBaseUrl/fees/$feeId';
    final headers = await _getHeaders();

    print('💸 GET FEE REQUEST');
    print('URL: $url');
    print('Headers: $headers');

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('💸 GET FEE RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Fee.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Frais non trouvé');
    } else {
      throw Exception('Erreur de récupération du frais: ${response.statusCode}');
    }
  }

  // Upload endpoints
  static Future<void> uploadImages(String propertyId, List<String> imagePaths) async {
    final url = '$fullBaseUrl/upload-images/$propertyId';
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('Token d\'authentification manquant');
    }

    print('📸 UPLOAD IMAGES REQUEST');
    print('URL: $url');
    print('Property ID: $propertyId');
    print('Images: $imagePaths');

    // Créer une requête multipart
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    // IMPORTANT: envoyer une seule image par requête pour éviter 413
    for (int i = 0; i < imagePaths.length; i++) {
      final singleRequest = http.MultipartRequest('POST', Uri.parse(url));
      singleRequest.headers['Authorization'] = 'Bearer $token';
      final path = imagePaths[i];
      final lower = path.toLowerCase();
      final isPng = lower.endsWith('.png');
      final mediaType = isPng
          ? MediaType('image', 'png')
          : MediaType('image', 'jpeg');
      final file = await http.MultipartFile.fromPath(
        'images',
        path,
        contentType: mediaType,
      );
      singleRequest.files.add(file);
      final streamedResponse = await singleRequest.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('📸 UPLOAD IMAGE [$i/${imagePaths.length}] RESPONSE: ${response.statusCode}');
      if (response.statusCode != 201) {
        throw Exception('Erreur d\'upload de l\'image ${i + 1}: ${response.statusCode}');
      }
    }
    return;
  }

  static Future<void> uploadCoverImage(String propertyId, String imagePath) async {
    final url = '$fullBaseUrl/upload-images/$propertyId/cover';
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('Token d\'authentification manquant');
    }

    print('🖼️ UPLOAD COVER IMAGE REQUEST');
    print('URL: $url');
    print('Property ID: $propertyId');
    print('Image: $imagePath');

    // Créer une requête multipart
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';

    // Envoyer l'image de couverture seule
    final lower = imagePath.toLowerCase();
    final isPng = lower.endsWith('.png');
    final mediaType = isPng ? MediaType('image', 'png') : MediaType('image', 'jpeg');
    final file = await http.MultipartFile.fromPath('cover', imagePath, contentType: mediaType);
    request.files.add(file);
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('🖼️ UPLOAD COVER IMAGE RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode != 201) {
      throw Exception('Erreur d\'upload de l\'image de couverture: ${response.statusCode}');
    }
    return;
  }

  // Favorites endpoints
  static Future<void> savePropertyToFavorites(String propertyId, String listId) async {
    final url = '$fullBaseUrl/lists/save-properties';
    final headers = await _getHeaders();
    final body = jsonEncode(FavoriteRequest(
      property: propertyId,
      list: listId,
    ).toJson());

    print('❤️ SAVE TO FAVORITES REQUEST');
    print('URL: $url');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    print('❤️ SAVE TO FAVORITES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 201) {
      return;
    } else if (response.statusCode == 400) {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Requête invalide';
        throw Exception('Erreur de validation: $message. Vérifiez que la liste existe.');
      } catch (e) {
        throw Exception('Erreur de validation: ${response.body}. L\'ID de liste pourrait être invalide.');
      }
    } else if (response.statusCode == 500) {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Erreur serveur';
        throw Exception('Erreur serveur: $message. La liste pourrait ne pas exister.');
      } catch (e) {
        throw Exception('Erreur serveur: ${response.body}. Vérifiez que la liste existe.');
      }
    } else {
      throw Exception('Erreur de sauvegarde en favoris: ${response.statusCode}');
    }
  }

  static Future<FavoritesResponse> getFavoriteProperties({
    String? direction,
    String? cursor,
    int? limit,
    String? property,
    String? listId,
  }) async {
    final queryParams = <String, String>{};
    if (direction != null) queryParams['direction'] = direction;
    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (property != null) queryParams['property'] = property;
    if (listId != null) queryParams['list'] = listId;

    final uri = Uri.parse('$fullBaseUrl/lists/properties').replace(queryParameters: queryParams);
    final headers = await _getHeaders();

    print('❤️ GET FAVORITES REQUEST');
    print('URL: ${uri.toString()}');
    print('Headers: $headers');
    print('Query: $queryParams');

    final response = await http.get(uri, headers: headers);

    print('❤️ GET FAVORITES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Headers: ${response.headers}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FavoritesResponse.fromJson(data);
    } else if (response.statusCode == 400) {
      try {
        final errorData = jsonDecode(response.body);
        final message = errorData['message'] ?? 'Requête invalide';
        throw Exception('Erreur de validation: $message');
      } catch (e) {
        throw Exception('Erreur de validation: ${response.body}');
      }
    } else {
      throw Exception('Erreur de récupération des favoris: ${response.statusCode}');
    }
  }
}
