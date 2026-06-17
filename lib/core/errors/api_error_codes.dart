/// Known CBEX `error_code` values. Extend as the backend grows.
class ApiErrorCodes {
  ApiErrorCodes._();

  static const String unauthenticated = 'ERR_UNAUTHENTICATED';
  static const String userTypeForbidden = 'ERR_USER_TYPE_FORBIDDEN';
  static const String invalidCredentials = 'ERR_INVALID_CREDENTIALS';
  static const String bookingInProgress = 'ERR_BOOKING_IN_PROGRESS';

  /// Whether this failure should force the user back to the login screen.
  static bool requiresLogout(int? statusCode, String? errorCode) =>
      statusCode == 401 || errorCode == unauthenticated;
}
