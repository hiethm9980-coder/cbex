import 'exceptions.dart';

/// Builds typed [ApiException]s from CBEX HTTP error responses.
///
/// Handles all three envelopes and the documented error shapes:
/// - 401/403/404 `{ message, error_code? }`
/// - 409 `{ status:"error", data:{ error_code } }`
/// - 422 `{ message, errors:{ field:[...] } }`
/// - 429 with a `Retry-After` header
class ExceptionMapper {
  ExceptionMapper._();

  static ApiException fromHttp({
    required int statusCode,
    dynamic body,
    Map<String, List<String>>? headerValues,
  }) {
    final map =
        body is Map ? Map<String, dynamic>.from(body) : const <String, dynamic>{};
    final data =
        map['data'] is Map ? Map<String, dynamic>.from(map['data'] as Map) : null;

    final errorCode = (map['error_code'] ?? data?['error_code'])?.toString();
    final traceId = (map['trace_id'] ?? map['traceId'])?.toString();
    final rawMessage = map['message'];
    final message = (rawMessage is String && rawMessage.trim().isNotEmpty)
        ? rawMessage
        : _defaultMessage(statusCode);
    final errors = _parseErrors(map['errors']);

    switch (statusCode) {
      case 401:
        return AuthRequiredException(
            message: message, statusCode: 401, errorCode: errorCode, traceId: traceId);
      case 403:
        return ForbiddenException(
            message: message, statusCode: 403, errorCode: errorCode, traceId: traceId);
      case 404:
        return NotFoundException(
            message: message, statusCode: 404, errorCode: errorCode, traceId: traceId);
      case 409:
        return ConflictException(
            message: message, statusCode: 409, errorCode: errorCode, traceId: traceId);
      case 422:
        return ValidationException(
            message: message,
            errors: errors,
            statusCode: 422,
            errorCode: errorCode,
            traceId: traceId);
      case 429:
        final ra = headerValues?['retry-after']?.first;
        return RateLimitedException(
          message: message,
          retryAfterSeconds: ra == null ? null : int.tryParse(ra),
          statusCode: 429,
          errorCode: errorCode,
          traceId: traceId,
        );
      default:
        if (statusCode >= 500) {
          return ServerException(
              message: message,
              statusCode: statusCode,
              errorCode: errorCode,
              traceId: traceId);
        }
        return ApiException(
          message: message,
          statusCode: statusCode,
          errorCode: errorCode,
          traceId: traceId,
          errors: errors,
        );
    }
  }

  static Map<String, List<String>> _parseErrors(dynamic raw) {
    if (raw is Map) {
      final out = <String, List<String>>{};
      raw.forEach((k, v) {
        if (v is List) {
          out[k.toString()] = v.map((e) => e.toString()).toList();
        } else if (v != null) {
          out[k.toString()] = [v.toString()];
        }
      });
      return out;
    }
    return const {};
  }

  static String _defaultMessage(int status) {
    if (status == 401) return 'انتهت الجلسة. الرجاء تسجيل الدخول.';
    if (status == 403) return 'لا تملك صلاحية لهذا الإجراء.';
    if (status == 404) return 'العنصر المطلوب غير موجود.';
    if (status == 429) return 'محاولات كثيرة. حاول بعد قليل.';
    if (status >= 500) return 'خطأ في الخادم. حاول لاحقًا.';
    return 'حدث خطأ غير متوقع.';
  }
}
