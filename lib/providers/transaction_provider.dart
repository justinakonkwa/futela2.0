import 'package:flutter/foundation.dart';
import '../models/finance/transaction.dart';
import '../services/finance_service.dart';

class TransactionProvider with ChangeNotifier {
  final FinanceService _service = FinanceService();

  List<Transaction> _transactions = [];
  int _totalItems = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  int _itemsPerPage = 30;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  String? _type; // payment, deposit, withdrawal
  String? _startDate; // YYYY-MM-DD
  String? _endDate; // YYYY-MM-DD

  List<Transaction> get transactions => _transactions;
  int get totalItems => _totalItems;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get itemsPerPage => _itemsPerPage;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMoreTransactions => _currentPage < _totalPages;
  String? get error => _error;

  String? get typeFilter => _type;
  String? get startDate => _startDate;
  String? get endDate => _endDate;

  bool get hasActiveFilters =>
      _type != null ||
      (_startDate != null && _startDate!.isNotEmpty) ||
      (_endDate != null && _endDate!.isNotEmpty);

  void setTypeFilter(String? type) {
    _type = type;
    notifyListeners();
  }

  void setStartDate(String? ymd) {
    _startDate = ymd;
    notifyListeners();
  }

  void setEndDate(String? ymd) {
    _endDate = ymd;
    notifyListeners();
  }

  void clearFilters() {
    _type = null;
    _startDate = null;
    _endDate = null;
    notifyListeners();
  }

  Future<void> loadTransactions({
    int page = 1,
    int itemsPerPage = 30,
    bool refresh = true,
  }) async {
    _setLoading(true);
    _clearError();
    _itemsPerPage = itemsPerPage;

    try {
      final res = await _service.getTransactions(
        page: page,
        itemsPerPage: itemsPerPage,
        type: _type,
        startDate: _startDate,
        endDate: _endDate,
      );
      if (refresh) {
        _transactions = List<Transaction>.from(res.member);
      } else {
        _transactions.addAll(res.member);
      }
      _totalItems = res.totalItems;
      _currentPage = res.page;
      _totalPages = res.totalPages;
    } catch (e) {
      _setError('Erreur lors du chargement des transactions: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMoreTransactions || _isLoadingMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();
    _clearError();
    try {
      final res = await _service.getTransactions(
        page: _currentPage + 1,
        itemsPerPage: _itemsPerPage,
        type: _type,
        startDate: _startDate,
        endDate: _endDate,
      );
      _transactions.addAll(res.member);
      _totalItems = res.totalItems;
      _currentPage = res.page;
      _totalPages = res.totalPages;
    } catch (e) {
      _setError('Erreur lors du chargement: $e');
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<Transaction?> getTransactionDetail(String id) async {
    _clearError();
    try {
      return await _service.getTransactionById(id);
    } catch (e) {
      _setError('Erreur lors du chargement du détail: $e');
      return null;
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
}

