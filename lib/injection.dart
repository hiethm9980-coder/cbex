import 'package:get_it/get_it.dart';

import 'core/network/api_client.dart';
import 'core/network/session_manager.dart';
import 'core/storage/secure_token_storage.dart';
import 'features/account/data/repositories/account_repository.dart';
import 'features/addresses/data/repositories/address_repository.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/orders/data/repositories/order_repository.dart';
import 'features/payments/data/repositories/payment_repository.dart';
import 'features/rates/data/repositories/rate_repository.dart';
import 'features/shipments/data/repositories/shipment_repository.dart';
import 'features/tracking/data/repositories/tracking_repository.dart';
import 'features/wallet/data/repositories/wallet_repository.dart';

/// Service locator for the data layer.
final GetIt sl = GetIt.instance;

/// Registers the data layer once at startup:
/// storage → session → ApiClient → all feature repositories.
Future<void> initDependencies() async {
  // ── Core ──
  sl.registerLazySingleton<SecureTokenStorage>(() => SecureTokenStorage());
  sl.registerLazySingleton<SessionManager>(
    () => SessionManager(storage: sl<SecureTokenStorage>()),
  );
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(
      storage: sl<SecureTokenStorage>(),
      sessionManager: sl<SessionManager>(),
    ),
  );

  // ── Repositories ──
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
        client: sl<ApiClient>(), session: sl<SessionManager>()),
  );
  sl.registerLazySingleton<AccountRepository>(
      () => AccountRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<AddressRepository>(
      () => AddressRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<ShipmentRepository>(
      () => ShipmentRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<RateRepository>(
      () => RateRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<TrackingRepository>(
      () => TrackingRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<WalletRepository>(
      () => WalletRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<PaymentRepository>(
      () => PaymentRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<NotificationRepository>(
      () => NotificationRepository(client: sl<ApiClient>()));
  sl.registerLazySingleton<OrderRepository>(
      () => OrderRepository(client: sl<ApiClient>()));
}
