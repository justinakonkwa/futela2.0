import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../models/auth/user.dart';
import '../models/auth/profile_completion_request.dart';
import 'api_client.dart';

class ProfileService {
  final Dio _dio;

  ProfileService() : _dio = ApiClient().dio;

  /// PUT /api/users/me/complete-profile
  /// Compléter le profil après inscription OAuth
  Future<User> completeProfile(ProfileCompletionRequest request) async {
    try {
      print('📝 COMPLETE PROFILE REQUEST');
      print('URL: /api/users/me/complete-profile');
      print('Data: ${request.toJson()}');

      final response = await _dio.put(
        '/api/users/me/complete-profile',
        data: request.toJson(),
      );

      print('📝 COMPLETE PROFILE RESPONSE');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      } else {
        throw Exception('Échec de complétion du profil');
      }
    } on DioException catch (e) {
      print('❌ DioException completing profile: ${e.message}');
      print('Response: ${e.response?.data}');
      
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['error']?['message'] ?? 
                      e.response?.data?['message'];

      if (statusCode == 400) {
        if (message != null && message.toString().contains('profileCompleted')) {
          throw Exception('Profil déjà complété');
        }
        throw Exception(message ?? 'Données invalides');
      } else if (statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }

      throw Exception(message ?? 'Erreur de connexion. Veuillez réessayer.');
    } catch (e) {
      print('❌ Error completing profile: $e');
      rethrow;
    }
  }

  /// POST /api/users/me/id-document-photo
  /// Upload de la pièce d'identité
  Future<String> uploadIdDocument(File file) async {
    try {
      print('📤 UPLOAD ID DOCUMENT REQUEST');
      print('File: ${file.path}');

      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      
      // Déterminer le type MIME
      MediaType? mediaType;
      if (extension == 'jpg' || extension == 'jpeg') {
        mediaType = MediaType('image', 'jpeg');
      } else if (extension == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (extension == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else if (extension == 'pdf') {
        mediaType = MediaType('application', 'pdf');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      final response = await _dio.post(
        '/api/users/me/id-document-photo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('📤 UPLOAD ID DOCUMENT RESPONSE');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final url = response.data['url'] as String?;
        if (url == null) {
          throw Exception('URL du document non reçue');
        }
        return url;
      } else {
        throw Exception('Échec d\'upload du document');
      }
    } on DioException catch (e) {
      print('❌ DioException uploading ID document: ${e.message}');
      print('Response: ${e.response?.data}');
      
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['error']?['message'] ?? 
                      e.response?.data?['message'];

      if (statusCode == 400) {
        throw Exception(message ?? 'Fichier invalide. Formats acceptés: JPEG, PNG, WEBP, PDF (max 8 MB)');
      } else if (statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (statusCode == 413) {
        throw Exception('Fichier trop volumineux (max 8 MB)');
      }

      throw Exception(message ?? 'Erreur d\'upload. Veuillez réessayer.');
    } catch (e) {
      print('❌ Error uploading ID document: $e');
      rethrow;
    }
  }

  /// POST /api/users/me/selfie-photo
  /// Upload du selfie de vérification
  Future<String> uploadSelfie(File file) async {
    try {
      print('📤 UPLOAD SELFIE REQUEST');
      print('File: ${file.path}');

      final fileName = file.path.split('/').last;
      final extension = fileName.split('.').last.toLowerCase();
      
      // Déterminer le type MIME (pas de PDF pour selfie)
      MediaType? mediaType;
      if (extension == 'jpg' || extension == 'jpeg') {
        mediaType = MediaType('image', 'jpeg');
      } else if (extension == 'png') {
        mediaType = MediaType('image', 'png');
      } else if (extension == 'webp') {
        mediaType = MediaType('image', 'webp');
      } else {
        throw Exception('Format non supporté. Utilisez JPEG, PNG ou WEBP');
      }

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          contentType: mediaType,
        ),
      });

      final response = await _dio.post(
        '/api/users/me/selfie-photo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('📤 UPLOAD SELFIE RESPONSE');
      print('Status: ${response.statusCode}');
      print('Data: ${response.data}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final url = response.data['url'] as String?;
        if (url == null) {
          throw Exception('URL du selfie non reçue');
        }
        return url;
      } else {
        throw Exception('Échec d\'upload du selfie');
      }
    } on DioException catch (e) {
      print('❌ DioException uploading selfie: ${e.message}');
      print('Response: ${e.response?.data}');
      
      final statusCode = e.response?.statusCode;
      final message = e.response?.data?['error']?['message'] ?? 
                      e.response?.data?['message'];

      if (statusCode == 400) {
        throw Exception(message ?? 'Fichier invalide. Formats acceptés: JPEG, PNG, WEBP (max 8 MB)');
      } else if (statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (statusCode == 413) {
        throw Exception('Fichier trop volumineux (max 8 MB)');
      }

      throw Exception(message ?? 'Erreur d\'upload. Veuillez réessayer.');
    } catch (e) {
      print('❌ Error uploading selfie: $e');
      rethrow;
    }
  }
}
