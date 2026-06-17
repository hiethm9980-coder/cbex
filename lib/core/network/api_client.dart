import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/exception_mapper.dart';
import '../errors/exceptions.dart';
import '../storage/secure_token_storage.dart';
import 'auth_interceptor.dart';
import 'base_response.dart';
import 'json_x.dart';
import 'session_manager.dart';

/// Dio-based HTTP client for the CBEX API.
///
/// Envelope-agnostic by design: the API uses three response shapes
/// (`{success,data}`, `{status,data}`, bare `{data}`). This client treats **any
/// 2xx as success**, unwraps the JSON `data` key (or the whole body when absent)
/// and passes it to [fromJson]; list pagination `meta` is exposed via
/// [ApiResult.meta]. Non-2xx responses become typed [ApiException]s, and any 401
/// clears the session first.
class ApiClient {
  late final Dio _dio;
  final SessionManager sessionManager;

  ApiClient({
    required SecureTokenStorage storage,
    required this.sessionManager,
    Dio? dio,
  }) {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout:
                const Duration(milliseconds: ApiConstants.connectTimeout),
            receiveTimeout:
                const Duration(milliseconds: ApiConstants.receiveTimeout),
            sendTimeout: const Duration(milliseconds: ApiConstants.sendTimeout),
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            // Handle every status code ourselves (no thrown DioException on 4xx/5xx).
            validateStatus: (_) => true,
          ),
        );
    _dio.interceptors
        .add(AuthInterceptor(storage: storage, sessionManager: sessionManager));
  }

  Future<ApiResult<T>> get<T>(
    String path, {
    T Function(Object? data)? fromJson,
    Map<String, dynamic>? query,
  }) =>
      _execute<T>(() => _dio.get(path, queryParameters: query), fromJson);

  Future<ApiResult<T>> post<T>(
    String path, {
    Object? data,
    T Function(Object? data)? fromJson,
    Map<String, dynamic>? query,
  }) =>
      _execute<T>(
          () => _dio.post(path, data: data, queryParameters: query), fromJson);

  Future<ApiResult<T>> put<T>(
    String path, {
    Object? data,
    T Function(Object? data)? fromJson,
  }) =>
      _execute<T>(() => _dio.put(path, data: data), fromJson);

  Future<ApiResult<T>> delete<T>(
    String path, {
    Object? data,
    T Function(Object? data)? fromJson,
  }) =>
      _execute<T>(() => _dio.delete(path, data: data), fromJson);

  Future<ApiResult<T>> _execute<T>(
    Future<Response> Function() send,
    T Function(Object? data)? fromJson,
  ) async {
    final Response response;
    try {
      response = await send();
    } on DioException catch (e) {
      throw _mapDio(e);
    }

    final status = response.statusCode ?? 0;
    final body = response.data;

    if (status >= 200 && status < 300) {
      final payload = unwrapData(body);
      final meta = extractMeta(body);
      final message = body is Map ? body['message'] as String? : null;
      return ApiResult<T>(
        data: fromJson != null ? fromJson(payload) : null,
        meta: meta,
        message: message,
        statusCode: status,
      );
    }

    // Clear the session on 401 before surfacing the error.
    if (status == 401) {
      await sessionManager.onTokenExpired();
    }
    throw ExceptionMapper.fromHttp(
      statusCode: status,
      body: body,
      headerValues: response.headers.map,
    );
  }

  ApiException _mapDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutException();
      case DioExceptionType.connectionError:
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const NetworkException();
      case DioExceptionType.cancel:
        return const NetworkException(message: 'تم إلغاء الطلب.');
      case DioExceptionType.badResponse:
        return ExceptionMapper.fromHttp(
          statusCode: e.response?.statusCode ?? 0,
          body: e.response?.data,
          headerValues: e.response?.headers.map,
        );
    }
  }
}
