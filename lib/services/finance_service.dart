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

    final displayUri = Uri.parse('${ApiClient.baseUrl}/api/transactions')
        .replace(
          queryParameters: params.map((k, v) => MapEntry(k, '$v')),
        );

    print('💰 GET /api/transactions');
    print('  URL complète: $displayUri');
    print('  Query params: $params');

    final response =
        await _dio.get('/api/transactions', queryParameters: params);

    print('💰 GET /api/transactions — RÉPONSE');
    print('  Status: ${response.statusCode}');
    print('  Data (brut): ${response.data}');

    if (response.statusCode == 200) {
      final data = (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final parsed = PaginatedTransactionsResponse.fromJson(data);
      print(
          '  Pagination: page=${parsed.page} / ${parsed.totalPages} (total=${parsed.totalItems})');
      print('  member.length=${parsed.member.length}');
      for (var i = 0; i < parsed.member.length && i < 5; i++) {
        final t = parsed.member[i];
        print(
            '  [tx $i] id=${t.id} type=${t.type} status=${t.status} amount=${t.amount} ${t.currency}');
      }
      if (parsed.member.length > 5) {
        print('  … (${parsed.member.length - 5} autres non affichées)');
      }
      return parsed;
    }
    throw Exception('Failed to load transactions');
  }

  /// Détail : GET /api/transactions/{id}
  Future<Transaction> getTransactionById(String id) async {
    final displayUri = Uri.parse('${ApiClient.baseUrl}/api/transactions/$id');
    print('💰 GET /api/transactions/{id}');
    print('  URL complète: $displayUri');

    final response = await _dio.get('/api/transactions/$id');

    print('💰 GET /api/transactions/{id} — RÉPONSE');
    print('  Status: ${response.statusCode}');
    print('  Data (brut): ${response.data}');

    if (response.statusCode == 200) {
      final data = (response.data is Map<String, dynamic>)
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      return Transaction.fromJson(data);
    }
    throw Exception('Failed to load transaction detail');
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
