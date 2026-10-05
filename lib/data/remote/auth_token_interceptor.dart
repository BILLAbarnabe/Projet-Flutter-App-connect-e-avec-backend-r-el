import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthTokenInterceptor extends Interceptor {
  AuthTokenInterceptor({
    required this.client,
    required this.apiKey,
    required this.dio,
  });

  final SupabaseClient client;
  final String apiKey;
  final Dio dio;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers['apikey'] = apiKey;
    final accessToken = client.auth.currentSession?.accessToken;
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final request = err.requestOptions;
    if (err.response?.statusCode != 401 ||
        request.extra['authRetry'] == true) {
      handler.next(err);
      return;
    }

    late final AuthResponse refreshed;
    try {
      refreshed = await client.auth.refreshSession();
    } on AuthException {
      handler.next(err);
      return;
    }
    final accessToken = refreshed.session?.accessToken;
    if (accessToken == null) {
      handler.next(err);
      return;
    }

    final retryOptions = request.copyWith(
      headers: {
        ...request.headers,
        'Authorization': 'Bearer $accessToken',
        'apikey': apiKey,
      },
      extra: {...request.extra, 'authRetry': true},
    );
    try {
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}

Dio createContentDio(
  SupabaseClient client, {
  required String baseUrl,
  required String apiKey,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: '$baseUrl/rest/v1/',
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'Accept': 'application/json'},
    ),
  );
  dio.interceptors.add(
    AuthTokenInterceptor(
      client: client,
      apiKey: apiKey,
      dio: dio,
    ),
  );
  return dio;
}
