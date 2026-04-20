import 'package:dio/dio.dart';
import '../models/finance/wallet.dart';
import '../models/finance/transaction.dart';
import 'api_client.dart';

class FinanceService {
  final Dio _dio;

  FinanceService() : _dio = ApiClient().dio;

  // --- Wallet ---

  Future<Wallet> getWallet() async {
    final response = await _dio.get('/api/me/wallet');

    if (response.statusCode == 200) {
      return Wallet.fromJson(response.data);
    } else {
      throw Exception('Failed to load wallet: ${response.data}');
    }
  }

  Future<double> getBalance(String walletId) async {
    final response = await _dio.get('/api/me/wallet/balance', queryParameters: {
      'walletId': walletId,
    });

    if (response.statusCode == 200) {
      return (response.data['balance'] as num).toDouble();
    } else {
      throw Exception('Failed to get balance');
    }
  }

  // --- Transactions ---

  /// v2 (doc) : GET /api/transactions?page=&itemsPerPage=&type=&startDate=&endDate=
  Future<PaginatedTransactionsResponse> getTransactions({
    int page = 1,
    int itemsPerPage = 30,
    String? type, // payment, deposit, withdrawal
    String? startDate, // YYYY-MM-DD
    String? endDate, // YYYY-MM-DD
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'itemsPerPage': itemsPerPage,
      if (type != null && type.isNotEmpty) 'type': type,
      if (startDate != null && startDate.isNotEmpty) 'startDate': startDate,
      if (endDate != null && endDate.isNotEmpty) 'endDate': endDate,
    };

    try {
      final response =
          await _dio.get('/api/transactions', queryParameters: params);

      if (response.statusCode == 200) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        return PaginatedTransactionsResponse.fromJson(data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé. Vous devez être connecté pour consulter vos transactions.');
      }
      
      if (e.response?.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }
      
      throw Exception('Erreur lors du chargement des transactions. Veuillez réessayer.');
    } catch (e) {
      throw Exception('Erreur lors du chargement des transactions. Veuillez réessayer.');
    }
    
    throw Exception('Erreur lors du chargement des transactions');
  }

  /// Détail : GET /api/transactions/{id}
  Future<Transaction> getTransactionById(String id) async {
    try {
      final response = await _dio.get('/api/transactions/$id');

      if (response.statusCode == 200) {
        final data = (response.data is Map<String, dynamic>)
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        return Transaction.fromJson(data);
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw Exception('Accès refusé. Vous devez être connecté pour consulter cette transaction.');
      }
      
      if (e.response?.statusCode == 401) {
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      }
      
      if (e.response?.statusCode == 404) {
        throw Exception('Transaction introuvable.');
      }
      
      throw Exception('Erreur lors du chargement de la transaction. Veuillez réessayer.');
    } catch (e) {
      throw Exception('Erreur lors du chargement de la transaction. Veuillez réessayer.');
    }
    
    throw Exception('Erreur lors du chargement de la transaction');
  }

  // --- Payments (FlexPay) ---

  Future<Map<String, dynamic>> initiatePayment({
    required double amount,
    required String currency, // USD, CDF
    required String phoneNumber,
    String gateway = 'flexpay',
    String? description,
  }) async {
    final response = await _dio.post('/api/payments/initiate', data: {
      'amount': amount,
      'currency': currency,
      'gateway': gateway,
      'phoneNumber': phoneNumber,
      'description': description,
    });

    if (response.statusCode == 200) {
      return response.data; // Contains transactionId, paymentUrl, etc.
    } else {
      throw Exception('Payment initiation failed: ${response.data}');
    }
  }

  Future<void> withdrawFunds({
    required double amount,
    required String phoneNumber,
    String? description,
  }) async {
    final response = await _dio.post('/api/me/wallet/withdraw', data: {
      'amount': amount,
      'phoneNumber': phoneNumber,
      'description': description,
    });

    if (response.statusCode != 200) {
      throw Exception('Withdrawal failed: ${response.data}');
    }
  }

  Future<void> topUpWallet({
    required double amount,
    required String phoneNumber,
    String? description,
  }) async {
    final response = await _dio.post('/api/me/wallet/topup', data: {
      'amount': amount,
      'phoneNumber': phoneNumber,
      'description': description,
    });

    if (response.statusCode != 200) {
      throw Exception('Top-up failed: ${response.data}');
    }
  }
}
