import 'package:flutter/foundation.dart';
import '../models/visit.dart';
import '../services/api_service.dart';

class VisitProvider with ChangeNotifier {
  List<String> _visits = [];
  Map<String, dynamic> _metaData = {};
  bool _isLoading = false;
  String? _error;

  List<String> get visits => _visits;
  Map<String, dynamic> get metaData => _metaData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMyVisits({
    String? direction,
    String? cursor,
    int? limit,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getMyVisits(
        direction: direction,
        cursor: cursor,
        limit: limit,
      );

      _visits = response.visits;
      _metaData = response.metaData;
    } catch (e) {
      _setError('Erreur lors du chargement des visites: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<String> createVisit({
    required String visitor,
    required String property,
    required List<String> dates,
    String? message,
    String? contact,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final visitRequest = VisitRequest(
        visitor: visitor,
        property: property,
        dates: dates,
        message: message,
        contact: contact,
      );

      // Appel direct à l'API
      final visitId = await ApiService.createVisit(visitRequest);
      
      // Attendre un peu pour laisser l'API synchroniser
      await Future.delayed(const Duration(seconds: 2));
      
      // Recharger la liste des visites après création
      await loadMyVisits();
      
      return visitId;
    } catch (e) {
      _setError('Erreur lors de la création de la visite: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }



  Future<PaymentResponse> payVisit({
    required String visitId,
    required String type,
    required String phone,
    required double amount,
    required String currency,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final paymentRequest = PaymentRequest(
        type: type,
        phone: phone,
        amount: amount,
        currency: currency,
      );

      final response = await ApiService.payVisit(visitId, paymentRequest);
      
      // Recharger la liste des visites après paiement
      await loadMyVisits();
      
      return response;
    } catch (e) {
      _setError('Erreur lors du paiement: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<PaymentCheckResponse> checkPayment(String paymentId) async {
    _setLoading(true);
    _clearError();

    try {
      return await ApiService.checkPayment(paymentId);
    } catch (e) {
      _setError('Erreur lors de la vérification du paiement: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> requestWithdrawal({
    required String currency,
    required double amount,
    required String phone,
    required String type,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final withdrawalRequest = WithdrawalRequest(
        currency: currency,
        amount: amount,
        phone: phone,
        type: type,
      );

      await ApiService.requestWithdrawal(withdrawalRequest);
    } catch (e) {
      _setError('Erreur lors de la demande de retrait: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

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

  void clearVisits() {
    _visits.clear();
    _metaData.clear();
    notifyListeners();
  }
}
