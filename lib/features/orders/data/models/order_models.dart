import 'package:equatable/equatable.dart';

/// A line item within an order.
class OrderItem extends Equatable {
  final String name;
  final int quantity;
  final num unitPrice;
  final double? weight;
  final String? sku;

  const OrderItem({
    required this.name,
    this.quantity = 1,
    this.unitPrice = 0,
    this.weight,
    this.sku,
  });

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        name: j['name'] as String? ?? '',
        quantity: (j['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (j['unit_price'] as num?) ?? 0,
        weight: (j['weight'] as num?)?.toDouble(),
        sku: j['sku'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
        'unit_price': unitPrice,
        if (weight != null) 'weight': weight,
        if (sku != null) 'sku': sku,
      };

  @override
  List<Object?> get props => [name, quantity, unitPrice, sku];
}

/// A merchant order (`/orders`, B2B).
class Order extends Equatable {
  final String id;
  final String? status;
  final String? customerName;
  final String? currency;
  final String? createdAt;
  final num? total;
  final List<OrderItem> items;

  const Order({
    required this.id,
    this.status,
    this.customerName,
    this.currency,
    this.createdAt,
    this.total,
    this.items = const [],
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id']?.toString() ?? '',
        status: j['status'] as String?,
        customerName: j['customer_name'] as String?,
        currency: j['currency'] as String?,
        createdAt: j['created_at']?.toString(),
        total: j['total'] as num?,
        items: (j['items'] as List?)
                ?.whereType<Map>()
                .map((e) => OrderItem.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      );

  @override
  List<Object?> get props => [id, status, customerName];
}
