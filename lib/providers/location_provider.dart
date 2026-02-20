import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/location/country.dart';
import '../models/location/province.dart';
import '../models/location/city.dart';
import '../models/location/town.dart';
import '../models/location/district.dart';
import '../models/property/property.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  final LocationService _locationService = LocationService();

  List<Country> _countries = [];
  List<Province> _provinces = [];
  List<City> _cities = [];
  List<Town> _towns = [];
  List<District> _districts = [];

  bool _isLoading = false;
  String? _error;

  // Current location
  Position? _currentPosition;
  double? _currentLatitude;
  double? _currentLongitude;

  Position? get currentPosition => _currentPosition;
  double? get currentLatitude => _currentLatitude;
  double? get currentLongitude => _currentLongitude;

  List<Country> get countries => _countries;
  List<Province> get provinces => _provinces;
  List<City> get cities => _cities;
  List<Town> get towns => _towns;
  List<District> get districts => _districts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Selections
  Country? _selectedCountry;
  Province? _selectedProvince;
  City? _selectedCity;
  Town? _selectedTown;
  District? _selectedDistrict;

  Country? get selectedCountry => _selectedCountry;
  Province? get selectedProvince => _selectedProvince;
  City? get selectedCity => _selectedCity;
  Town? get selectedTown => _selectedTown;
  District? get selectedDistrict => _selectedDistrict;

  Future<void> loadCountries() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _countries = await _locationService.getCountries();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCountry(Country country) async {
    _selectedCountry = country;
    _provinces = [];
    _selectedProvince = null;
    _cities = [];
    _selectedCity = null;
    _towns = [];
    _selectedTown = null;
    notifyListeners();

    _isLoading = true;
    try {
      _provinces = await _locationService.getProvinces(country.id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProvince(Province province) async {
    _selectedProvince = province;
    _cities = [];
    _selectedCity = null;
    _towns = [];
    _selectedTown = null;
    notifyListeners();

    _isLoading = true;
    try {
      _cities = await _locationService.getCities(province.id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectCity(City city) async {
    _selectedCity = city;
    _towns = [];
    _selectedTown = null;
    notifyListeners();

    _isLoading = true;
    try {
      _towns = await _locationService.getTowns(city.id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectTown(Town town) async {
    _selectedTown = town;
    _districts = [];
    _selectedDistrict = null;
    notifyListeners();

    _isLoading = true;
    try {
      _districts = await _locationService.getDistricts(townId: town.id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectDistrict(District district) {
    _selectedDistrict = district;
    notifyListeners();
  }

  // Get current GPS location
  Future<void> getCurrentLocation() async {
    try {
      // Vérifier les permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _error = 'Les services de localisation sont désactivés';
        notifyListeners();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Permission de localisation refusée';
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Permission de localisation définitivement refusée';
        notifyListeners();
        return;
      }

      // Obtenir la position actuelle
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentLatitude = _currentPosition?.latitude;
      _currentLongitude = _currentPosition?.longitude;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la récupération de la localisation: $e';
      notifyListeners();
    }
  }

  // Calculate distance to a property
  double? calculateDistanceToProperty(Property property) {
    if (_currentLatitude == null || _currentLongitude == null) {
      return null;
    }

    if (property.address?.latitude == null || property.address?.longitude == null) {
      return null;
    }

    try {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentLatitude!,
        _currentLongitude!,
        property.address!.latitude!,
        property.address!.longitude!,
      );

      // Convertir en kilomètres
      return distanceInMeters / 1000.0;
    } catch (e) {
      return null;
    }
  }

  // Format distance for display
  String formatDistance(double distanceInKm) {
    if (distanceInKm < 1) {
      // Afficher en mètres si moins d'1 km
      int meters = (distanceInKm * 1000).round();
      return '$meters m';
    } else if (distanceInKm < 10) {
      // Afficher avec 1 décimale si moins de 10 km
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      // Afficher sans décimale si plus de 10 km
      return '${distanceInKm.toStringAsFixed(0)} km';
    }
  }
}
