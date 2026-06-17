import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/account/data/repositories/account_repository.dart';
import '../../features/addresses/data/repositories/address_repository.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/notifications/data/repositories/notification_repository.dart';
import '../../features/orders/data/repositories/order_repository.dart';
import '../../features/payments/data/repositories/payment_repository.dart';
import '../../features/rates/data/repositories/rate_repository.dart';
import '../../features/shipments/data/repositories/shipment_repository.dart';
import '../../features/tracking/data/repositories/tracking_repository.dart';
import '../../features/wallet/data/repositories/wallet_repository.dart';
import '../../injection.dart';
import '../network/api_client.dart';
import '../network/session_manager.dart';
import '../storage/secure_token_storage.dart';

// ── Core singletons (bridged from GetIt) ──
final sessionManagerProvider =
    Provider<SessionManager>((_) => sl<SessionManager>());
final secureStorageProvider =
    Provider<SecureTokenStorage>((_) => sl<SecureTokenStorage>());
final apiClientProvider = Provider<ApiClient>((_) => sl<ApiClient>());

// ── Repository providers ──
final authRepositoryProvider =
    Provider<AuthRepository>((_) => sl<AuthRepository>());
final accountRepositoryProvider =
    Provider<AccountRepository>((_) => sl<AccountRepository>());
final addressRepositoryProvider =
    Provider<AddressRepository>((_) => sl<AddressRepository>());
final shipmentRepositoryProvider =
    Provider<ShipmentRepository>((_) => sl<ShipmentRepository>());
final rateRepositoryProvider =
    Provider<RateRepository>((_) => sl<RateRepository>());
final trackingRepositoryProvider =
    Provider<TrackingRepository>((_) => sl<TrackingRepository>());
final walletRepositoryProvider =
    Provider<WalletRepository>((_) => sl<WalletRepository>());
final paymentRepositoryProvider =
    Provider<PaymentRepository>((_) => sl<PaymentRepository>());
final notificationRepositoryProvider =
    Provider<NotificationRepository>((_) => sl<NotificationRepository>());
final orderRepositoryProvider =
    Provider<OrderRepository>((_) => sl<OrderRepository>());
