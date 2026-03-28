import 'package:flutter/foundation.dart';
import '../models/visit.dart';
import '../services/api_service.dart';

class VisitProvider with ChangeNotifier {
  List<MyVisit> _visits = [];
  int _totalItems = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  /// Filtre actif pour `GET /me/visits?status=` (null = tous).
  String? _listStatusFilter;
  int _itemsPerPage = 20;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  List<MyVisit> get visits => _visits;
  int get totalItems => _totalItems;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  String? get listStatusFilter => _listStatusFilter;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreVisits => _currentPage < _totalPages;
  String? get error => _error;

  /// [updateStatusFilter] : true quand l’utilisateur change le chip (sinon on garde le filtre courant).
  Future<void> loadMyVisits({
    int page = 1,
    int itemsPerPage = 20,
    String? status,
    bool refresh = true,
    bool updateStatusFilter = false,
  }) async {
    if (updateStatusFilter) {
      _listStatusFilter = status;
    }
    _itemsPerPage = itemsPerPage;
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getMyVisits(
        page: page,
        itemsPerPage: itemsPerPage,
        status: _listStatusFilter,
      );

      if (refresh) {
        _visits = List<MyVisit>.from(response.member);
      } else {
        _visits.addAll(response.member);
      }
      _totalItems = response.totalItems;
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (e) {
      _setError('Erreur lors du chargement des visites: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreVisits() async {
    if (!hasMoreVisits || _isLoadingMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();
    _clearError();
    try {
      final response = await ApiService.getMyVisits(
        page: _currentPage + 1,
        itemsPerPage: _itemsPerPage,
        status: _listStatusFilter,
      );
      _visits.addAll(response.member);
      _totalItems = response.totalItems;
      _currentPage = response.page;
      _totalPages = response.totalPages;
    } catch (e) {
      _setError('Erreur lors du chargement: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  /// Crée une visite (paiement optionnel via paymentPhone dans le payload).
  Future<VisitCreateResult> createVisit({
    required String propertyId,
    required String scheduledAt,
    String? notes,
    num? paymentAmount,
    String? paymentCurrency,
    String? paymentPhone,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final payload = RequestVisitPayload(
        propertyId: propertyId,
        scheduledAt: scheduledAt,
        notes: notes,
        paymentAmount: paymentAmount,
        paymentCurrency: paymentCurrency,
        paymentPhone: paymentPhone,
      );
      final result = await ApiService.createVisit(payload);
      await Future.delayed(const Duration(milliseconds: 400));
      await loadMyVisits(refresh: true);
      return result;
    } catch (e) {
      _setError(e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim());
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
      await loadMyVisits(refresh: true);
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

  /// Un poll GET payment-status (utilisé par l’écran d’attente).
  Future<VisitPaymentStatus> fetchVisitPaymentStatus(
    String visitId,
    String transactionId,
  ) {
    return ApiService.getVisitPaymentStatus(visitId, transactionId);
  }

  /// POST /api/visits/{id}/cancel
  Future<void> cancelVisit(String visitId) async {
    _clearError();
    try {
      await ApiService.cancelVisit(visitId);
      await loadMyVisits(refresh: true);
    } catch (e) {
      _setError(e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim());
      rethrow;
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
    _totalItems = 0;
    _currentPage = 1;
    _totalPages = 1;
    notifyListeners();
  }
}
