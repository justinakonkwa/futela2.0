import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/property.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentPosition;
  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedTown;
  bool _isLoading = false;
  String? _error;

  Position? get currentPosition => _currentPosition;
  String? get selectedProvince => _selectedProvince;
  String? get selectedCity => _selectedCity;
  String? get selectedTown => _selectedTown;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Obtenir la position actuelle
  Future<void> getCurrentLocation() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _error = 'Permission de localisation refusée';
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _error = 'Permission de localisation définitivement refusée';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Obtenir la position
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Erreur lors de la récupération de la position: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Définir la province sélectionnée
  void setSelectedProvince(String? provinceId) {
    _selectedProvince = provinceId;
    // Réinitialiser la ville et la commune quand on change de province
    _selectedCity = null;
    _selectedTown = null;
    notifyListeners();
  }

  // Définir la ville sélectionnée
  void setSelectedCity(String? cityId) {
    _selectedCity = cityId;
    // Réinitialiser la commune quand on change de ville
    _selectedTown = null;
    notifyListeners();
  }

  // Définir la commune sélectionnée
  void setSelectedTown(String? townId) {
    _selectedTown = townId;
    notifyListeners();
  }

  // Calculer la distance entre deux positions
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  // Calculer la distance entre la position actuelle et une propriété
  double? calculateDistanceToProperty(Property property) {
    if (_currentPosition == null || property.location == null) {
      return null;
    }

    final propertyLat = property.location!['latitude']?.toDouble();
    final propertyLon = property.location!['longitude']?.toDouble();

    if (propertyLat == null || propertyLon == null) {
      return null;
    }

    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      propertyLat,
      propertyLon,
    );
  }

  // Formater la distance
  String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.toStringAsFixed(0)} m';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
    }
  }

  // Obtenir l'adresse formatée
  String getFormattedAddress() {
    final parts = <String>[];
    
    if (_selectedTown != null) {
      parts.add(_selectedTown!);
    }
    if (_selectedCity != null) {
      parts.add(_selectedCity!);
    }
    if (_selectedProvince != null) {
      parts.add(_selectedProvince!);
    }
    
    return parts.join(', ');
  }

  // Réinitialiser la sélection
  void resetSelection() {
    _selectedProvince = null;
    _selectedCity = null;
    _selectedTown = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
