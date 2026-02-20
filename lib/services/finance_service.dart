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

  Future<List<Transaction>> getTransactions(
      {int page = 1, String? type}) async {
    final params = {'page': page};
    if (type != null) params['type'] = int.parse(type);

    final response =
        await _dio.get('/api/me/transactions', queryParameters: params);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data['transactions'] ?? [];
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load transactions');
    }
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
