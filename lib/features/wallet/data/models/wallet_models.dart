import 'package:equatable/equatable.dart';

/// Wallet balance (`/wallet`, `/billing/my-wallet`, `/payments/wallet`).
class Wallet extends Equatable {
  final num balance;
  final String? currency;
  final Map<String, dynamic> raw;

  const Wallet({this.balance = 0, this.currency, this.raw = const {}});

  factory Wallet.fromJson(Map<String, dynamic> j) => Wallet(
        balance: (j['balance'] ?? j['available_balance'] ?? 0) as num? ?? 0,
        currency: j['currency'] as String?,
        raw: j,
      );

  @override
  List<Object?> get props => [balance, currency];
}

/// A wallet ledger movement (`/wallet/ledger`, `/wallet/topup`).
class LedgerEntry extends Equatable {
  final String id;
  final num amount;
  final num? runningBalance;
  final String? type;
  final String? description;
  final String? createdAt;

  const LedgerEntry({
    required this.id,
    this.amount = 0,
    this.runningBalance,
    this.type,
    this.description,
    this.createdAt,
  });

  factory LedgerEntry.fromJson(Map<String, dynamic> j) => LedgerEntry(
        id: (j['id'] ?? j['entry_id'])?.toString() ?? '',
        amount: (j['amount'] as num?) ?? 0,
        runningBalance: j['running_balance'] as num?,
        type: j['type'] as String?,
        description: j['description'] as String?,
        createdAt: j['created_at']?.toString(),
      );

  @override
  List<Object?> get props => [id, amount, createdAt];
}
