import 'package:dio/dio.dart';
import '../models/commission/commission.dart';
import '../models/commission/withdrawal.dart';
import '../models/commission/wallet.dart';
import 'api_client.dart';

class CommissionService {
  final Dio _dio;

  CommissionService() : _dio = ApiClient().dio;

  /// Récupérer le wallet du commissionnaire
  Future<CommissionnaireWallet> getWallet() async {
    try {
      final response = await _dio.get('/api/commissionnaire/wallet');
      if (response.statusCode == 200) {
        return CommissionnaireWallet.fromJson(response.data as Map<String, dynamic>);
      }
      return CommissionnaireWallet.empty();
    } on DioException catch (e) {
      // 404 = endpoint pas encore disponible → wallet vide
      if (e.response?.statusCode == 404) {
        return CommissionnaireWallet.empty();
      }
      throw Exception('Erreur lors de la récupération du wallet: ${e.message}');
    }
  }

  /// Récupérer les commissions du commissionnaire
  Future<List<Commission>> getCommissions({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (status != null) queryParams['status'] = status;

    try {
      final response = await _dio.get(
        '/api/commissionnaire/commissions',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = (data['member'] ?? data['data'] ?? data['items'] ?? []) as List<dynamic>;
        } else {
          list = [];
        }
        return list
            .whereType<Map<String, dynamic>>()
            .map((json) => Commission.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Erreur lors de la récupération des commissions: ${e.message}');
    }
  }

  /// Vérifier une commission avec le code OTP
  Future<Commission> verifyCommission(String commissionId, String code) async {
    final response = await _dio.post(
      '/api/commissionnaire/commissions/$commissionId/verify',
      data: {'code': code},
    );
    
    if (response.statusCode == 200) {
      return Commission.fromJson(response.data);
    } else {
      throw Exception('Code de vérification incorrect');
    }
  }

  /// Trouver une commission par numéro de téléphone du visiteur
  Future<Commission> findCommissionByPhone(String phoneNumber, String code) async {
    final response = await _dio.post(
      '/api/commissionnaire/commissions/find-by-phone',
      data: {
        'phone': phoneNumber,
        'code': code,
      },
    );
    
    if (response.statusCode == 200) {
      return Commission.fromJson(response.data);
    } else {
      throw Exception('Commission non trouvée ou code incorrect');
    }
  }

  /// Récupérer les retraits du commissionnaire
  Future<List<Withdrawal>> getWithdrawals({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get(
      '/api/commissionnaire/withdrawals',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['data'] ?? response.data;
      return data.map((json) => Withdrawal.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des retraits: ${response.data}');
    }
  }

  /// Demander un retrait
  Future<Withdrawal> requestWithdrawal({
    required double amount,
    required String phoneNumber,
  }) async {
    final response = await _dio.post(
      '/api/commissionnaire/withdrawals',
      data: {
        'amount': amount,
        'phoneNumber': phoneNumber,
      },
    );
    
    if (response.statusCode == 201) {
      return Withdrawal.fromJson(response.data);
    } else {
      final message = _extractErrorMessage(response.data);
      throw Exception(message);
    }
  }

  /// Récupérer les codes de vérification pour le visiteur
  Future<List<Map<String, dynamic>>> getVerificationCodes() async {
    final response = await _dio.get('/api/me/verification-codes');
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(response.data);
    } else {
      throw Exception('Erreur lors de la récupération des codes: ${response.data}');
    }
  }

  /// Extraire le message d'erreur de la réponse API
  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      final map = data as Map<String, dynamic>;
      final error = map['error'];
      if (error is Map) {
        final msg = error['message']?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
      }
      final msg = map['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;
    }
    return 'Une erreur est survenue';
  }
}