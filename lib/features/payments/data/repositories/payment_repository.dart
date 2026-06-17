import 'package:uuid/uuid.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_x.dart';
import '../../../wallet/data/models/wallet_models.dart';
import '../models/payment_models.dart';

/// Payments data layer (`status` envelope).
class PaymentRepository {
  final ApiClient _client;
  PaymentRepository({required ApiClient client}) : _client = client;

  Future<Wallet> walletSummary() async {
    final r = await _client.get<Wallet>(ApiConstants.paymentsWallet,
        fromJson: (j) => Wallet.fromJson(asMap(j)));
    return r.data!;
  }

  /// [filters]: type, status, from, to, direction, per_page.
  Future<List<Transaction>> transactions({Map<String, dynamic>? filters}) async {
    final r = await _client.get<List<Transaction>>(
        ApiConstants.paymentsTransactions,
        query: filters,
        fromJson: (j) => asMapList(j).map(Transaction.fromJson).toList());
    return r.data ?? const [];
  }

  Future<TopupResult> topup({
    required num amount,
    required String gateway,
    String paymentMethod = 'card',
    String? idempotencyKey,
  }) async {
    final r = await _client.post<TopupResult>(
      ApiConstants.paymentsTopup,
      data: {
        'amount': amount,
        'gateway': gateway,
        'payment_method': paymentMethod,
        'idempotency_key': idempotencyKey ?? const Uuid().v4(),
      },
      fromJson: (j) => TopupResult.fromJson(asMap(j)),
    );
    return r.data!;
  }

  Future<TopupResult> chargeShipping({
    required String shipmentId,
    required num amount,
    String? promoCode,
    String? idempotencyKey,
  }) async {
    final r = await _client.post<TopupResult>(
      ApiConstants.paymentsChargeShipping,
      data: {
        'shipment_id': shipmentId,
        'amount': amount,
        if (promoCode != null) 'promo_code': promoCode,
        'idempotency_key': idempotencyKey ?? const Uuid().v4(),
      },
      fromJson: (j) => TopupResult.fromJson(asMap(j)),
    );
    return r.data!;
  }

  Future<List<Invoice>> invoices() async {
    final r = await _client.get<List<Invoice>>(ApiConstants.paymentsInvoices,
        fromJson: (j) => asMapList(j).map(Invoice.fromJson).toList());
    return r.data ?? const [];
  }
}
