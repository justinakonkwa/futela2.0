import 'package:dio/dio.dart';
import '../models/review/property_review.dart';
import 'api_client.dart';

class ReviewService {
  final Dio _dio = ApiClient().dio;

  /// POST /api/properties/{propertyId}/reviews
  Future<void> submitReview({
    required String propertyId,
    required int rating,
    String? comment,
    bool wouldRecommend = true,
  }) async {
    try {
      await _dio.post(
        '/api/properties/$propertyId/reviews',
        data: {
          'rating': rating,
          'comment': comment ?? '',
          'wouldRecommend': wouldRecommend,
        },
      );
    } on DioException catch (e) {
      String msg = 'Erreur serveur (${e.response?.statusCode})';
      try {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          msg = (responseData['message'] ?? responseData['detail'] ?? responseData['error'] ?? msg).toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  /// GET /api/properties/{propertyId}/reviews
  Future<ReviewsResponse> getPropertyReviews({
    required String propertyId,
    int page = 1,
    String? orderRating,
  }) async {
    try {
      final queryParams = <String, dynamic>{'page': page};
      if (orderRating != null) queryParams['order[rating]'] = orderRating;

      final response = await _dio.get(
        '/api/properties/$propertyId/reviews',
        queryParameters: queryParams,
      );

      // L'API retourne [] directement ou {member: [...]}
      final data = response.data;
      if (data is List) {
        return ReviewsResponse.fromList(data);
      }
      return ReviewsResponse.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Erreur lors du chargement des avis: ${e.message}');
    }
  }

  /// GET /api/properties/{propertyId}/reviews/average
  Future<Map<String, dynamic>> getAverageRating({
    required String propertyId,
  }) async {
    try {
      final response = await _dio.get('/api/properties/$propertyId/reviews/average');
      final data = response.data;
      if (data is List) return {};
      return data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception('Erreur lors du chargement de la note moyenne: ${e.message}');
    }
  }

  /// GET /api/properties/{propertyId}/reviews/stats
  Future<ReviewStats> getReviewStats({
    required String propertyId,
  }) async {
    try {
      final response = await _dio.get('/api/properties/$propertyId/reviews/stats');
      final data = response.data;

      // L'API peut retourner [] si aucun avis
      if (data is List) {
        return ReviewStats(
          propertyId: propertyId,
          totalReviews: 0,
          averageRating: 0.0,
          ratingDistribution: {},
          recommendationRate: 0,
          topPros: [],
          topCons: [],
        );
      }
      return ReviewStats.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception('Erreur lors du chargement des statistiques: ${e.message}');
    }
  }
}
