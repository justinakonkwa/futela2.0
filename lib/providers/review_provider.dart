import 'package:flutter/foundation.dart';
import '../models/review/property_review.dart';
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();

  List<PropertyReview> _reviews = [];
  ReviewStats? _stats;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 0;
  int _totalItems = 0;
  double _averageRating = 0.0;

  List<PropertyReview> get reviews => _reviews;
  ReviewStats? get stats => _stats;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  double get averageRating => _averageRating;
  bool get hasMoreReviews => _currentPage < _totalPages;

  /// Charger les avis d'une propriété
  Future<void> loadReviews({
    required String propertyId,
    bool refresh = false,
    String? orderRating,
  }) async {
    if (refresh) {
      _currentPage = 1;
      _reviews.clear();
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _reviewService.getPropertyReviews(
        propertyId: propertyId,
        page: _currentPage,
        orderRating: orderRating,
      );

      if (refresh) {
        _reviews = response.reviews;
      } else {
        _reviews.addAll(response.reviews);
      }

      _totalPages = response.totalPages;
      _totalItems = response.totalItems;
      _averageRating = response.averageRating;
      _error = null;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Charger plus d'avis
  Future<void> loadMoreReviews({
    required String propertyId,
    String? orderRating,
  }) async {
    if (!hasMoreReviews || _isLoading) return;

    _currentPage++;
    await loadReviews(
      propertyId: propertyId,
      refresh: false,
      orderRating: orderRating,
    );
  }

  /// Charger les statistiques des avis
  Future<void> loadStats({required String propertyId}) async {
    try {
      _stats = await _reviewService.getReviewStats(propertyId: propertyId);
      notifyListeners();
    } catch (e) {
      print('Error loading stats: $e');
    }
  }

  /// Soumettre un avis
  Future<bool> submitReview({
    required String propertyId,
    required int rating,
    String? comment,
    bool wouldRecommend = true,
  }) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _reviewService.submitReview(
        propertyId: propertyId,
        rating: rating,
        comment: comment,
        wouldRecommend: wouldRecommend,
      );
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  /// Réinitialiser
  void reset() {
    _reviews = [];
    _stats = null;
    _isLoading = false;
    _error = null;
    _currentPage = 1;
    _totalPages = 0;
    _totalItems = 0;
    _averageRating = 0.0;
    notifyListeners();
  }
}
