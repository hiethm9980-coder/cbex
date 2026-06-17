/// CEBX Mobile Customer API — endpoint catalogue.
///
/// Full URL = [baseUrl] + path. Every path below already includes the `/api/v1`
/// prefix. Auth is via a Laravel Sanctum Bearer token (see AuthInterceptor).
class ApiConstants {
  ApiConstants._();

  // TODO(cbex): for the Android emulator against a local server use
  // 'http://10.0.2.2:8000'; for a LAN device use the host IP.
  static String baseUrl = 'https://cbexlogistics.com';

  static const String _v1 = '/api/v1';

  // ── Timeouts (milliseconds) ──
  static const int connectTimeout = 20000;
  static const int receiveTimeout = 30000;
  static const int sendTimeout = 20000;

  static const String traceIdHeader = 'X-Trace-Id';

  // ── Auth ──
  static const String register = '$_v1/register';
  static const String login = '$_v1/login';
  static const String me = '$_v1/me';
  static const String changePassword = '$_v1/change-password';
  static const String forgotPassword = '$_v1/forgot-password';
  static const String resetPassword = '$_v1/reset-password';
  static const String logout = '$_v1/logout';
  static const String logoutAll = '$_v1/logout-all';

  // ── Account ──
  static const String account = '$_v1/account';
  static const String accountSettings = '$_v1/account/settings';

  // ── Addresses ──
  static const String addresses = '$_v1/addresses';
  static String address(String id) => '$_v1/addresses/$id';

  // ── Shipments ──
  static const String shipments = '$_v1/shipments';
  static const String shipmentStats = '$_v1/shipments/stats';
  static String shipment(String id) => '$_v1/shipments/$id';
  static String shipmentValidate(String id) => '$_v1/shipments/$id/validate';
  static String shipmentQuickShip(String id) => '$_v1/shipments/$id/quick-ship';
  static String shipmentCancel(String id) => '$_v1/shipments/$id/cancel';
  static String shipmentLabel(String id) => '$_v1/shipments/$id/label';
  static String shipmentFromOrder(String orderId) =>
      '$_v1/shipments/from-order/$orderId';

  // ── Rates & Offers ──
  static String shipmentRates(String id) => '$_v1/shipments/$id/rates';
  static String shipmentOffers(String id) => '$_v1/shipments/$id/offers';
  static String rateQuoteSelect(String quoteId) =>
      '$_v1/rate-quotes/$quoteId/select';

  // ── Tracking ──
  static String trackingTimeline(String id) =>
      '$_v1/shipments/$id/tracking/timeline';
  static String trackingStatus(String id) =>
      '$_v1/shipments/$id/tracking/status';
  static String trackingEvents(String id) =>
      '$_v1/shipments/$id/tracking/events';
  static String trackingSubscribe(String id) =>
      '$_v1/shipments/$id/tracking/subscribe';
  static const String trackingSearch = '$_v1/tracking/search';
  static const String trackingDashboard = '$_v1/tracking/dashboard';

  // ── Wallet ──
  static const String wallet = '$_v1/wallet';
  static const String walletLedger = '$_v1/wallet/ledger';
  static const String walletTopup = '$_v1/wallet/topup';
  static const String billingMyWallet = '$_v1/billing/my-wallet';

  // ── Payments ──
  static const String paymentsWallet = '$_v1/payments/wallet';
  static const String paymentsTransactions = '$_v1/payments/transactions';
  static const String paymentsTopup = '$_v1/payments/topup';
  static const String paymentsChargeShipping = '$_v1/payments/charge-shipping';
  static const String paymentsInvoices = '$_v1/payments/invoices';

  // ── Notifications ──
  static const String notificationsInApp = '$_v1/notifications/in-app';
  static const String notificationsUnreadCount = '$_v1/notifications/unread-count';
  static String notificationRead(String id) => '$_v1/notifications/$id/read';
  static const String notificationsReadAll = '$_v1/notifications/read-all';
  static const String notificationsPreferences = '$_v1/notifications/preferences';

  // ── Orders (B2B) ──
  static const String orders = '$_v1/orders';
  static String order(String id) => '$_v1/orders/$id';
}
