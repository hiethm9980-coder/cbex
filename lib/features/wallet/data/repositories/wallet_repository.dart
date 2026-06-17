import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_x.dart';
import '../models/wallet_models.dart';

/// Wallet & billing data layer (`success` envelope).
class WalletRepository {
  final ApiClient _client;
  WalletRepository({required ApiClient client}) : _client = client;

  Future<Wallet> get() async {
    final r = await _client.get<Wallet>(ApiConstants.wallet,
        fromJson: (j) => Wallet.fromJson(asMap(j)));
    return r.data!;
  }

  Future<List<LedgerEntry>> ledger({int limit = 50}) async {
    final r = await _client.get<List<LedgerEntry>>(ApiConstants.walletLedger,
        query: {'limit': limit},
        fromJson: (j) => asMapList(j).map(LedgerEntry.fromJson).toList());
    return r.data ?? const [];
  }

  Future<LedgerEntry> topup({
    required num amount,
    String? referenceId,
    String? description,
  }) async {
    final r = await _client.post<LedgerEntry>(
      ApiConstants.walletTopup,
      data: {
        'amount': amount,
        if (referenceId != null) 'reference_id': referenceId,
        if (description != null) 'description': description,
      },
      fromJson: (j) => LedgerEntry.fromJson(asMap(j)),
    );
    return r.data!;
  }

  Future<Wallet> myWallet() async {
    final r = await _client.get<Wallet>(ApiConstants.billingMyWallet,
        fromJson: (j) => Wallet.fromJson(asMap(j)));
    return r.data!;
  }
}
