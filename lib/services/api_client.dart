import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth/auth_response.dart';

class ApiClient {
  // Singleton pattern
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late Dio _dio;
  String? _accessToken;
  bool _isRefreshing = false;
  Future<void>? _refreshFuture;

  // Base URL from documentation (or environment variable)
  static const String baseUrl =
      'https://api.futela.com'; // À configurer selon votre env

  ApiClient._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status! < 500; // Let application handle 4xx errors
      },
    ));

    _setupInterceptors();
  }

  Dio get dio => _dio;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<void> _doRefresh(String refreshToken, SharedPreferences prefs) async {
    final refreshDio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    final refreshResponse = await refreshDio.post(
      '/api/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    if (refreshResponse.statusCode == 200 && refreshResponse.data is Map) {
      final authResponse = AuthResponse.fromJson(
        refreshResponse.data as Map<String, dynamic>,
      );
      _accessToken = authResponse.accessToken;
      await prefs.setString('access_token', authResponse.accessToken);
      await prefs.setString('refresh_token', authResponse.refreshToken);
      print('🔐 Token refreshed successfully (expiresIn: ${authResponse.expiresIn}s)');
    } else {
      throw Exception('Refresh failed: ${refreshResponse.statusCode}');
    }
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        if (_accessToken != null) {
          options.headers['Authorization'] = 'Bearer $_accessToken';
        }

        // Log request (can be removed in production)
        print('--> ${options.method} ${options.path}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        // Log response
        print('<-- ${response.statusCode} ${response.requestOptions.path}');
        return handler.next(response);
      },
      onError: (DioException e, handler) async {
        // Ne pas intercepter les erreurs autres que 401 ou si c'est la requête refresh
        final is401 = e.response?.statusCode == 401;
        final isRefreshRequest = e.requestOptions.path.contains('auth/refresh');

        if (!is401 || isRefreshRequest) {
          print('ERROR: ${e.message}');
          return handler.next(e);
        }

        // Si un refresh est déjà en cours, attendre qu'il se termine puis réessayer
        if (_isRefreshing && _refreshFuture != null) {
          try {
            await _refreshFuture!.timeout(const Duration(seconds: 15));
            if (_accessToken != null) {
              final opts = e.requestOptions;
              opts.headers['Authorization'] = 'Bearer $_accessToken';
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            }
          } catch (_) {}
          return handler.next(e);
        }

        final prefs = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString('refresh_token');
        if (refreshToken == null || refreshToken.isEmpty) {
          print('🔐 No refresh token, cannot refresh');
          return handler.next(e);
        }

        _isRefreshing = true;
        _refreshFuture = _doRefresh(refreshToken, prefs);

        try {
          await _refreshFuture!;
          if (_accessToken != null) {
            final opts = e.requestOptions;
            opts.headers['Authorization'] = 'Bearer $_accessToken';
            final response = await _dio.fetch(opts);
            return handler.resolve(response);
          }
        } catch (refreshError) {
          print('🔐 Token refresh failed: $refreshError');
        } finally {
          _isRefreshing = false;
          _refreshFuture = null;
        }

        return handler.next(e);
      },
    ));
  }
}
