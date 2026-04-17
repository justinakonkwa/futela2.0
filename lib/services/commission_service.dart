import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../models/commission/commission.dart';
import '../models/commission/withdrawal.dart';
import '../models/commission/wallet.dart';
import 'api_client.dart';

class CommissionService {
  final Dio _dio;

  CommissionService() : _dio = ApiClient().dio;

  // ─── Wallet ────────────────────────────────────────────────────────────────

  /// GET /api/commissionnaire/wallet/summary
  /// Résumé: totalEarnings, pendingCommissions (count int), verifiedCount, walletBalance, currency
  Future<CommissionnaireWallet> getWallet() async {
    try {
      final response = await _dio.get('/api/commissionnaire/wallet/summary');
      if (response.statusCode == 200) {
        return CommissionnaireWallet.fromJson(response.data as Map<String, dynamic>);
      }
      return CommissionnaireWallet.empty();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return CommissionnaireWallet.empty();
      throw Exception('Erreur wallet: ${_extractErrorMessage(e.response?.data)}');
    }
  }

  // ─── Commissions ───────────────────────────────────────────────────────────

  /// GET /api/commissionnaire/commissions
  /// Params: page, itemsPerPage, verificationStatus
  Future<List<Commission>> getCommissions({
    int page = 1,
    int itemsPerPage = 20,
    String? verificationStatus,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'itemsPerPage': itemsPerPage,
    };
    if (verificationStatus != null) {
      queryParams['verificationStatus'] = verificationStatus;
    }

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
      throw Exception('Erreur commissions: ${_extractErrorMessage(e.response?.data)}');
    }
  }

  /// POST /api/commissionnaire/commissions/find-by-phone
  /// Body: { phone: "0812345678" }  ← format local sans +243
  /// Retourne la commission en attente (code_sent) pour ce visiteur
  Future<Commission> findCommissionByPhone(String phoneNumber) async {
    // Normaliser : enlever +243 ou 243 en tête et garder le format local 0XXXXXXXXX
    final normalized = _normalizePhone(phoneNumber);
    debugPrint('find-by-phone → envoi phone: "$normalized"');

    try {
      final response = await _dio.post(
        '/api/commissionnaire/commissions/find-by-phone',
        data: {'phone': normalized},
      );
      debugPrint('find-by-phone ← ${response.statusCode}: ${response.data}');

      if (response.statusCode == 200) {
        return Commission.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception(_extractErrorMessage(response.data));
    } on DioException catch (e) {
      debugPrint('find-by-phone DioError ${e.response?.statusCode}: ${e.response?.data}');
      throw Exception(_extractErrorMessage(e.response?.data));
    }
  }

  /// POST /api/commissionnaire/commissions/{id}/verify
  /// Body: { code: "123456" }
  /// Max 5 tentatives, puis locked. Idempotent si déjà verified.
  Future<Commission> verifyCommission(String commissionId, String code) async {
    try {
      final response = await _dio.post(
        '/api/commissionnaire/commissions/$commissionId/verify',
        data: {'code': code},
      );
      debugPrint('verify ← ${response.statusCode}: ${response.data}');

      if (response.statusCode == 200) {
        return Commission.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception(_extractErrorMessage(response.data));
    } on DioException catch (e) {
      debugPrint('verify DioError ${e.response?.statusCode}: ${e.response?.data}');
      throw Exception(_extractErrorMessage(e.response?.data));
    }
  }

  // ─── Visiteur ──────────────────────────────────────────────────────────────

  /// GET /api/me/verification-codes
  /// Codes OTP actifs pour le visiteur connecté
  Future<List<Map<String, dynamic>>> getVerificationCodes() async {
    try {
      final response = await _dio.get('/api/me/verification-codes');
      debugPrint('verification-codes ← ${response.statusCode}: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.whereType<Map<String, dynamic>>().toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Erreur codes: ${_extractErrorMessage(e.response?.data)}');
    }
  }

  // ─── Retraits ──────────────────────────────────────────────────────────────

  Future<List<Withdrawal>> getWithdrawals({int page = 1, int itemsPerPage = 20}) async {
    try {
      final response = await _dio.get(
        '/api/commissionnaire/withdrawals',
        queryParameters: {'page': page, 'itemsPerPage': itemsPerPage},
      );
      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list;
        if (data is List) {
          list = data;
        } else if (data is Map) {
          list = (data['data'] ?? data['member'] ?? data['items'] ?? []) as List<dynamic>;
        } else {
          list = [];
        }
        return list.whereType<Map<String, dynamic>>()
            .map((json) => Withdrawal.fromJson(json))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception('Erreur retraits: ${_extractErrorMessage(e.response?.data)}');
    }
  }

  Future<Withdrawal> requestWithdrawal({
    required double amount,
    required String phoneNumber,
  }) async {
    try {
      final response = await _dio.post(
        '/api/commissionnaire/withdrawals',
        data: {'amount': amount, 'phoneNumber': phoneNumber},
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Withdrawal.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception(_extractErrorMessage(response.data));
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e.response?.data));
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Normalise le numéro au format local: 0812345678
  /// Accepte: +243812345678, 243812345678, 0812345678, 812345678
  String _normalizePhone(String phone) {
    String p = phone.trim().replaceAll(' ', '').replaceAll('-', '');
    if (p.startsWith('+243')) {
      p = '0${p.substring(4)}';
    } else if (p.startsWith('243') && p.length >= 12) {
      p = '0${p.substring(3)}';
    } else if (!p.startsWith('0') && p.length == 9) {
      p = '0$p';
    }
    return p;
  }

  /// Extrait le message d'erreur lisible depuis la réponse API
  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Une erreur est survenue';
    if (data is String && data.isNotEmpty) return data;
    if (data is Map) {
      final map = data as Map<String, dynamic>;

      // { "detail": "..." }
      final detail = map['detail']?.toString();
      if (detail != null && detail.isNotEmpty) return detail;

      // { "message": "..." }
      final msg = map['message']?.toString();
      if (msg != null && msg.isNotEmpty) return msg;

      // { "error": { "message": "..." } } ou { "error": "..." }
      final error = map['error'];
      if (error is Map) {
        final errMsg = error['message']?.toString();
        if (errMsg != null && errMsg.isNotEmpty) return errMsg;
      } else if (error is String && error.isNotEmpty) {
        return error;
      }

      // { "violations": [{ "message": "..." }] }
      final violations = map['violations'];
      if (violations is List && violations.isNotEmpty) {
        final first = violations.first;
        if (first is Map) {
          final v = first['message']?.toString();
          if (v != null && v.isNotEmpty) return v;
        }
      }

      // { "errors": ["..."] }
      final errors = map['errors'];
      if (errors is List && errors.isNotEmpty) {
        return errors.first.toString();
      }
    }
    return 'Une erreur est survenue';
  }
}
