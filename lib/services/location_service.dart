import 'package:dio/dio.dart';
import '../models/location/country.dart';
import '../models/location/province.dart';
import '../models/location/city.dart';
import '../models/location/town.dart';
import '../models/location/district.dart';
import '../models/location/address.dart';
import 'api_client.dart';

class LocationService {
  final Dio _dio;

  LocationService() : _dio = ApiClient().dio;

  // --- Countries ---

  Future<List<Country>> getCountries(
      {int page = 1, int itemsPerPage = 30}) async {
    print('🌍 GET COUNTRIES REQUEST');
    print('URL: /api/countries');
    print('Query Parameters: {page: $page, itemsPerPage: $itemsPerPage}');
    
    final response = await _dio.get('/api/countries', queryParameters: {
      'page': page,
      'itemsPerPage': itemsPerPage,
      'order[name]': 'asc',
    });

    print('🌍 GET COUNTRIES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Response Data Type: ${response.data.runtimeType}');

    if (response.statusCode == 200) {
      List<dynamic> countriesList;
      
      // Gérer les deux formats possibles
      if (response.data is List) {
        print('📋 Response is a direct List');
        countriesList = response.data as List<dynamic>;
      } else if (response.data is Map) {
        print('📋 Response is a Map with keys: ${(response.data as Map).keys.toList()}');
        countriesList = response.data['hydra:member'] ?? [];
      } else {
        print('❌ Unexpected response type: ${response.data.runtimeType}');
        throw Exception('Format de réponse inattendu pour les pays');
      }
      
      print('Countries Count: ${countriesList.length}');
      if (countriesList.isNotEmpty) {
        print('First Country Sample: ${countriesList.first}');
      }
      
      final countries = countriesList.map((json) {
        try {
          if (json is! Map<String, dynamic>) {
            throw Exception('Country JSON is not a Map: ${json.runtimeType}');
          }
          return Country.fromJson(json);
        } catch (e, stackTrace) {
          print('❌ Error parsing country: $e');
          print('Country JSON: $json');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
      
      print('✅ Successfully parsed ${countries.length} countries');
      return countries;
    } else {
      print('❌ Failed to load countries: ${response.statusCode}');
      throw Exception('Failed to load countries: ${response.statusCode}');
    }
  }

  Future<Country> getCountry(String id) async {
    final response = await _dio.get('/api/countries/$id');
    if (response.statusCode == 200) {
      return Country.fromJson(response.data);
    } else {
      throw Exception('Failed to load country');
    }
  }

  // --- Provinces ---

  Future<List<Province>> getProvinces(String countryId, {int page = 1}) async {
    print('🏛️ GET PROVINCES REQUEST');
    print('URL: /api/provinces');
    print('Query Parameters: {country: $countryId, page: $page}');
    
    final response = await _dio.get('/api/provinces', queryParameters: {
      'country': countryId,
      'page': page,
      'order[name]': 'asc',
    });

    print('🏛️ GET PROVINCES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Response Data Type: ${response.data.runtimeType}');

    if (response.statusCode == 200) {
      List<dynamic> provincesList;
      
      // Gérer les deux formats possibles
      if (response.data is List) {
        print('📋 Response is a direct List');
        provincesList = response.data as List<dynamic>;
      } else if (response.data is Map) {
        print('📋 Response is a Map with keys: ${(response.data as Map).keys.toList()}');
        provincesList = response.data['hydra:member'] ?? [];
      } else {
        print('❌ Unexpected response type: ${response.data.runtimeType}');
        throw Exception('Format de réponse inattendu pour les provinces');
      }
      
      print('Provinces Count: ${provincesList.length}');
      if (provincesList.isNotEmpty) {
        print('First Province Sample: ${provincesList.first}');
      }
      
      final provinces = provincesList.map((json) {
        try {
          if (json is! Map<String, dynamic>) {
            throw Exception('Province JSON is not a Map: ${json.runtimeType}');
          }
          return Province.fromJson(json);
        } catch (e, stackTrace) {
          print('❌ Error parsing province: $e');
          print('Province JSON: $json');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
      
      print('✅ Successfully parsed ${provinces.length} provinces');
      return provinces;
    } else {
      print('❌ Failed to load provinces: ${response.statusCode}');
      throw Exception('Failed to load provinces: ${response.statusCode}');
    }
  }

  // --- Cities ---

  Future<List<City>> getCities(String provinceId, {int page = 1}) async {
    print('🏙️ GET CITIES REQUEST');
    print('URL: /api/cities');
    print('Query Parameters: {province: $provinceId, page: $page}');
    
    final response = await _dio.get('/api/cities', queryParameters: {
      'province': provinceId,
      'page': page,
      'order[name]': 'asc',
    });

    print('🏙️ GET CITIES RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Response Data Type: ${response.data.runtimeType}');

    if (response.statusCode == 200) {
      List<dynamic> citiesList;
      
      // Gérer les deux formats possibles
      if (response.data is List) {
        print('📋 Response is a direct List');
        citiesList = response.data as List<dynamic>;
      } else if (response.data is Map) {
        print('📋 Response is a Map with keys: ${(response.data as Map).keys.toList()}');
        citiesList = response.data['hydra:member'] ?? [];
      } else {
        print('❌ Unexpected response type: ${response.data.runtimeType}');
        throw Exception('Format de réponse inattendu pour les villes');
      }
      
      print('Cities Count: ${citiesList.length}');
      if (citiesList.isNotEmpty) {
        print('First City Sample: ${citiesList.first}');
      }
      
      final cities = citiesList.map((json) {
        try {
          if (json is! Map<String, dynamic>) {
            throw Exception('City JSON is not a Map: ${json.runtimeType}');
          }
          return City.fromJson(json);
        } catch (e, stackTrace) {
          print('❌ Error parsing city: $e');
          print('City JSON: $json');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
      
      print('✅ Successfully parsed ${cities.length} cities');
      return cities;
    } else {
      print('❌ Failed to load cities: ${response.statusCode}');
      throw Exception('Failed to load cities: ${response.statusCode}');
    }
  }

  /// Récupère une ville par ID (pour obtenir provinceId / provinceName en mode édition).
  Future<City?> getCity(String cityId) async {
    try {
      final response = await _dio.get('/api/cities/$cityId');
      if (response.statusCode == 200 && response.data is Map) {
        return City.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  // --- Towns ---

  Future<List<Town>> getTowns(String cityId, {int page = 1}) async {
    print('🏘️ GET TOWNS REQUEST');
    print('URL: /api/towns');
    print('Query Parameters: {city: $cityId, page: $page}');
    
    final response = await _dio.get('/api/towns', queryParameters: {
      'city': cityId,
      'page': page,
      'order[name]': 'asc',
    });

    print('🏘️ GET TOWNS RESPONSE');
    print('Status Code: ${response.statusCode}');
    print('Response Data Type: ${response.data.runtimeType}');

    if (response.statusCode == 200) {
      List<dynamic> townsList;
      
      // Gérer les deux formats possibles
      if (response.data is List) {
        print('📋 Response is a direct List');
        townsList = response.data as List<dynamic>;
      } else if (response.data is Map) {
        print('📋 Response is a Map with keys: ${(response.data as Map).keys.toList()}');
        townsList = response.data['hydra:member'] ?? [];
      } else {
        print('❌ Unexpected response type: ${response.data.runtimeType}');
        throw Exception('Format de réponse inattendu pour les communes');
      }
      
      print('Towns Count: ${townsList.length}');
      if (townsList.isNotEmpty) {
        print('First Town Sample: ${townsList.first}');
      }
      
      final towns = townsList.map((json) {
        try {
          if (json is! Map<String, dynamic>) {
            throw Exception('Town JSON is not a Map: ${json.runtimeType}');
          }
          return Town.fromJson(json);
        } catch (e, stackTrace) {
          print('❌ Error parsing town: $e');
          print('Town JSON: $json');
          print('Stack trace: $stackTrace');
          rethrow;
        }
      }).toList();
      
      print('✅ Successfully parsed ${towns.length} towns');
      return towns;
    } else {
      print('❌ Failed to load towns: ${response.statusCode}');
      throw Exception('Failed to load towns: ${response.statusCode}');
    }
  }

  // --- Districts ---

  Future<List<District>> getDistricts(
      {String? townId, String? cityId, int page = 1}) async {
    final Map<String, dynamic> params = {'page': page, 'order[name]': 'asc'};
    if (townId != null) params['town'] = townId;
    if (cityId != null) params['city'] = cityId;

    final response = await _dio.get('/api/districts', queryParameters: params);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['hydra:member'];
      return data.map((json) => District.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load districts');
    }
  }

  // --- Addresses ---

  Future<List<Address>> searchAddresses(String query, {int limit = 10}) async {
    final response = await _dio.get('/api/addresses/search', queryParameters: {
      'q': query,
      'limit': limit,
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['results'];
      return data.map((json) => Address.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search addresses');
    }
  }

  Future<Address> getAddress(String id) async {
    final response = await _dio.get('/api/addresses/$id');
    if (response.statusCode == 200) {
      return Address.fromJson(response.data);
    } else {
      throw Exception('Failed to load address');
    }
  }

  Future<Address> createAddress({
    required String townId,
    String? districtId,
    String? street,
    String? number,
    String? additionalInfo,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.post('/api/addresses', data: {
      'townId': townId,
      'districtId': districtId,
      'street': street,
      'number': number,
      'additionalInfo': additionalInfo,
      'latitude': latitude,
      'longitude': longitude,
    });

    if (response.statusCode == 201) {
      return Address.fromJson(response.data);
    } else {
      throw Exception('Failed to create address');
    }
  }

  Future<Address> updateAddress(
    String id, {
    required String townId,
    String? districtId,
    String? street,
    String? number,
    String? additionalInfo,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.put('/api/addresses/$id', data: {
      'townId': townId,
      'districtId': districtId,
      'street': street,
      'number': number,
      'additionalInfo': additionalInfo,
      'latitude': latitude,
      'longitude': longitude,
    });

    if (response.statusCode == 200) {
      return Address.fromJson(response.data);
    } else {
      throw Exception('Failed to update address');
    }
  }
}
