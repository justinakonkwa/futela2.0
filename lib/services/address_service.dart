import 'api_service.dart';

class AddressService {
  // Cache pour éviter les appels API répétés
  static final Map<String, String> _cityCache = {};
  static final Map<String, String> _provinceCache = {};

  // Récupérer le nom d'une ville par ID
  static Future<String> getCityName(String cityId) async {
    if (_cityCache.containsKey(cityId)) {
      return _cityCache[cityId]!;
    }

    try {
      final cityData = await ApiService.getCityById(cityId);
      final cityName = cityData['name'] ?? 'Ville inconnue';
      _cityCache[cityId] = cityName;
      return cityName;
    } catch (e) {
      print('Erreur lors de la récupération de la ville $cityId: $e');
      return 'Ville inconnue';
    }
  }

  // Récupérer le nom d'une province par ID
  static Future<String> getProvinceName(String provinceId) async {
    if (_provinceCache.containsKey(provinceId)) {
      return _provinceCache[provinceId]!;
    }

    try {
      final provinceData = await ApiService.getProvinceById(provinceId);
      final provinceName = provinceData['name'] ?? 'Province inconnue';
      _provinceCache[provinceId] = provinceName;
      return provinceName;
    } catch (e) {
      print('Erreur lors de la récupération de la province $provinceId: $e');
      return 'Province inconnue';
    }
  }

  // Construire une adresse complète avec les noms des villes et provinces
  static Future<String> buildFullAddress({
    required String address,
    required String townName,
    required String cityId,
    required String provinceId,
  }) async {
    // Si l'adresse est valide, l'utiliser
    if (address.isNotEmpty && address.toLowerCase() != 'string') {
      return address;
    }

    // Sinon, construire l'adresse à partir des informations de localisation
    final cityName = await getCityName(cityId);
    final provinceName = await getProvinceName(provinceId);
    
    final finalTownName = townName.isNotEmpty ? townName : 'Ville inconnue';
    
    return '$finalTownName, $cityName, $provinceName';
  }

  // Vider le cache (utile pour les tests ou en cas de problème)
  static void clearCache() {
    _cityCache.clear();
    _provinceCache.clear();
  }
}
