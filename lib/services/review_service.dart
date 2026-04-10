import 'package:dio/dio.dart';
import '../models/review/property_review.dart';
import 'api_client.dart';

class ReviewService {
  final Dio _dio = ApiClient().dio;

  /// GET /api/properties/{propertyId}/reviews
  Future<ReviewsResponse> getPropertyReviews({
    required String propertyId,
    int page = 1,
    String? orderRating, // 'asc' ou 'desc'
  }) async {
    print('📝 GET PROPERTY REVIEWS');
    print('Property ID: $propertyId');
    print('Page: $page');

    try {
      final queryParams = <String, dynamic>{
        'page': page,
      };

      if (orderRating != null) {
        queryParams['order[rating]'] = orderRating;
      }

      final response = await _dio.get(
        '/api/properties/$propertyId/reviews',
        queryParameters: queryParams,
      );

      print('✅ Reviews loaded: ${response.statusCode}');
      return ReviewsResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ Error loading reviews: ${e.message}');
      throw Exception('Erreur lors du chargement des avis: ${e.message}');
    }
  }

  /// GET /api/properties/{propertyId}/reviews/average
  Future<Map<String, dynamic>> getAverageRating({
    required String propertyId,
  }) async {
    print('⭐ GET AVERAGE RATING');
    print('Property ID: $propertyId');

    try {
      final response = await _dio.get(
        '/api/properties/$propertyId/reviews/average',
      );

      print('✅ Average rating loaded: ${response.statusCode}');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('❌ Error loading average rating: ${e.message}');
      throw Exception('Erreur lors du chargement de la note moyenne: ${e.message}');
    }
  }

  /// GET /api/properties/{propertyId}/reviews/stats
  Future<ReviewStats> getReviewStats({
    required String propertyId,
  }) async {
    print('📊 GET REVIEW STATS');
    print('Property ID: $propertyId');

    try {
      final response = await _dio.get(
        '/api/properties/$propertyId/reviews/stats',
      );

      print('✅ Review stats loaded: ${response.statusCode}');
      return ReviewStats.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ Error loading review stats: ${e.message}');
      throw Exception('Erreur lors du chargement des statistiques: ${e.message}');
    }
  }
}
