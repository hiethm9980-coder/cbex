import 'package:cbex/core/errors/exception_mapper.dart';
import 'package:cbex/core/errors/exceptions.dart';
import 'package:cbex/core/network/json_x.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('envelope unwrap (3 CBEX shapes)', () {
    test('unwraps {success, data}', () {
      expect(unwrapData({'success': true, 'data': {'x': 1}}), {'x': 1});
    });
    test('unwraps {status, data}', () {
      expect(unwrapData({'status': 'success', 'data': [1, 2]}), [1, 2]);
    });
    test('passes through a bare body (no data key)', () {
      expect(unwrapData({'x': 1}), {'x': 1});
    });
    test('extractMeta reads the meta block', () {
      expect(extractMeta({'data': [], 'meta': {'total': 5, 'limit': 50}}),
          {'total': 5, 'limit': 50});
      expect(extractMeta({'data': []}), isNull);
    });
  });

  group('ExceptionMapper.fromHttp', () {
    test('401 → AuthRequiredException with error_code', () {
      final e = ExceptionMapper.fromHttp(statusCode: 401, body: {
        'success': false,
        'error_code': 'ERR_UNAUTHENTICATED',
        'message': 'unauth',
      });
      expect(e, isA<AuthRequiredException>());
      expect(e.errorCode, 'ERR_UNAUTHENTICATED');
      expect(e.statusCode, 401);
    });

    test('403 → ForbiddenException', () {
      final e = ExceptionMapper.fromHttp(statusCode: 403, body: {
        'error_code': 'ERR_USER_TYPE_FORBIDDEN',
        'message': 'forbidden',
      });
      expect(e, isA<ForbiddenException>());
      expect(e.errorCode, 'ERR_USER_TYPE_FORBIDDEN');
    });

    test('422 → ValidationException exposes field errors', () {
      final e = ExceptionMapper.fromHttp(statusCode: 422, body: {
        'message': 'invalid',
        'errors': {
          'email': ['ERR_INVALID_CREDENTIALS: بيانات الدخول غير صحيحة.']
        },
      });
      expect(e, isA<ValidationException>());
      expect(e.fieldError('email'), contains('بيانات'));
    });

    test('409 reads error_code nested under data', () {
      final e = ExceptionMapper.fromHttp(statusCode: 409, body: {
        'status': 'error',
        'data': {'error_code': 'ERR_BOOKING_IN_PROGRESS'},
      });
      expect(e, isA<ConflictException>());
      expect(e.errorCode, 'ERR_BOOKING_IN_PROGRESS');
    });

    test('429 reads the Retry-After header', () {
      final e = ExceptionMapper.fromHttp(
        statusCode: 429,
        body: {'message': 'slow down'},
        headerValues: {
          'retry-after': ['30']
        },
      );
      expect(e, isA<RateLimitedException>());
      expect((e as RateLimitedException).retryAfterSeconds, 30);
    });

    test('500 → ServerException', () {
      final e = ExceptionMapper.fromHttp(statusCode: 500, body: {'message': 'boom'});
      expect(e, isA<ServerException>());
    });

    test('404 falls back to a default message when none provided', () {
      final e = ExceptionMapper.fromHttp(statusCode: 404, body: const {});
      expect(e, isA<NotFoundException>());
      expect(e.message, isNotEmpty);
    });
  });
}
