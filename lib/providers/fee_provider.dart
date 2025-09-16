import 'package:flutter/foundation.dart';
import '../models/fee.dart';
import '../services/api_service.dart';

class FeeProvider with ChangeNotifier {
  List<Fee> _fees = [];
  Map<String, dynamic> _metaData = {};
  Fee? _selectedFee;
  bool _isLoading = false;
  String? _error;

  List<Fee> get fees => _fees;
  Map<String, dynamic> get metaData => _metaData;
  Fee? get selectedFee => _selectedFee;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadFees({
    String? direction,
    String? cursor,
    int? limit,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getFees(
        direction: direction,
        cursor: cursor,
        limit: limit,
      );

      _fees = response.fees;
      _metaData = response.metaData;
    } catch (e) {
      _setError('Erreur lors du chargement des frais: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Cette méthode n'est plus nécessaire car nous avons tous les frais dans la liste
  // Future<void> loadFee(String feeId) async {
  //   _setLoading(true);
  //   _clearError();

  //   try {
  //     _selectedFee = await ApiService.getFee(feeId);
  //   } catch (e) {
  //     _setError('Erreur lors du chargement du frais: $e');
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearFees() {
    _fees.clear();
    _metaData.clear();
    _selectedFee = null;
    notifyListeners();
  }
}
