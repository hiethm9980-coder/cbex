import 'package:equatable/equatable.dart';

/// Base type for every API / network failure surfaced to the app.
///
/// CBEX returns machine-readable `error_code` strings (e.g. `ERR_UNAUTHENTICATED`)
/// and, for 422, a Laravel-style `errors` map of `{ field: [messages] }`.
class ApiException extends Equatable implements Exception {
  final int? statusCode;
  final String? errorCode;
  final String message;
  final String? traceId;
  final Map<String, List<String>> errors;

  const ApiException({
    this.statusCode,
    this.errorCode,
    required this.message,
    this.traceId,
    this.errors = const {},
  });

  /// First validation message for [field], if any.
  String? fieldError(String field) =>
      (errors[field]?.isNotEmpty ?? false) ? errors[field]!.first : null;

  @override
  List<Object?> get props => [statusCode, errorCode, message, traceId, errors];

  @override
  String toString() => 'ApiException($statusCode/$errorCode): $message';
}

/// 401 — missing/invalid token. Forces re-login.
class AuthRequiredException extends ApiException {
  const AuthRequiredException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.traceId,
  });
}

/// 403 — authenticated but lacks the required permission / user type.
class ForbiddenException extends ApiException {
  const ForbiddenException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.traceId,
  });
}

/// 404 — resource not found (or outside the account's scope).
class NotFoundException extends ApiException {
  const NotFoundException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.traceId,
  });
}

/// 422 — input validation failed; see [errors].
class ValidationException extends ApiException {
  const ValidationException({
    required super.message,
    super.errors,
    super.statusCode,
    super.errorCode,
    super.traceId,
  });
}

/// 409 — conflict (e.g. a booking already in progress).
class ConflictException extends ApiException {
  const ConflictException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.traceId,
  });
}

/// 429 — rate limited; [retryAfterSeconds] from the `Retry-After` header.
class RateLimitedException extends ApiException {
  final int? retryAfterSeconds;
  const RateLimitedException({
    required super.message,
    this.retryAfterSeconds,
    super.statusCode,
    super.errorCode,
    super.traceId,
  });

  @override
  List<Object?> get props => [...super.props, retryAfterSeconds];
}

/// 5xx — server error.
class ServerException extends ApiException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.errorCode,
    super.traceId,
  });
}

/// No connectivity / DNS / socket error (no HTTP response).
class NetworkException extends ApiException {
  const NetworkException({
    String message = 'تعذّر الاتصال بالخادم. تحقّق من اتصالك بالإنترنت.',
  }) : super(message: message, errorCode: 'NETWORK_ERROR');
}

/// Connect/receive/send timeout.
class TimeoutException extends ApiException {
  const TimeoutException({
    String message = 'انتهت مهلة الاتصال. حاول مرة أخرى.',
  }) : super(message: message, errorCode: 'TIMEOUT');
}
