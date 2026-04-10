import 'package:dio/dio.dart';
import '../models/user/public_profile.dart';
import 'api_client.dart';

class PublicProfileService {
  final Dio _dio = ApiClient().dio;

  /// GET /api/users/{id}/profile
  Future<PublicProfile> getPublicProfile({required String userId}) async {
    try {
      final response = await _dio.get('/api/users/$userId/profile');
      return PublicProfile.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception('Erreur lors du chargement du profil: $msg');
    }
  }

  /// GET /api/users/{id}/properties
  Future<List<PublicPropertyItem>> getUserProperties({required String userId}) async {
    try {
      final response = await _dio.get('/api/users/$userId/properties');
      final data = response.data as Map<String, dynamic>;
      final members = data['member'] as List<dynamic>? ?? [];
      return members
          .map((e) => PublicPropertyItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? e.message;
      throw Exception('Erreur lors du chargement des propriétés: $msg');
    }
  }
}
