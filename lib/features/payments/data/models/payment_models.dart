import 'package:equatable/equatable.dart';

/// A payment/wallet transaction (`/payments/transactions`).
class Transaction extends Equatable {
  final String id;
  final num amount;
  final String? type;
  final String? status;
  final String? direction; // credit | debit
  final String? createdAt;

  const Transaction({
    required this.id,
    this.amount = 0,
    this.type,
    this.status,
    this.direction,
    this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id']?.toString() ?? '',
        amount: (j['amount'] as num?) ?? 0,
        type: j['type'] as String?,
        status: j['status'] as String?,
        direction: j['direction'] as String?,
        createdAt: j['created_at']?.toString(),
      );

  @override
  List<Object?> get props => [id, amount, status];
}

/// An invoice (`/payments/invoices`).
class Invoice extends Equatable {
  final String id;
  final num? total;
  final String? status;
  final String? number;
  final String? createdAt;

  const Invoice({
    required this.id,
    this.total,
    this.status,
    this.number,
    this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> j) => Invoice(
        id: j['id']?.toString() ?? '',
        total: (j['total'] ?? j['amount']) as num?,
        status: j['status'] as String?,
        number: (j['number'] ?? j['invoice_number'])?.toString(),
        createdAt: j['created_at']?.toString(),
      );

  @override
  List<Object?> get props => [id, total, status];
}

/// Result of a gateway top-up / charge — may carry a redirect URL for the
/// payment gateway. Kept as a raw map until a payment screen consumes it.
class TopupResult extends Equatable {
  final Map<String, dynamic> data;
  const TopupResult(this.data);

  factory TopupResult.fromJson(Map<String, dynamic> j) => TopupResult(j);

  String? get redirectUrl =>
      (data['redirect_url'] ?? data['url'] ?? data['payment_url'])?.toString();

  @override
  List<Object?> get props => [data];
}
