import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_x.dart';
import '../../../../core/network/pagination.dart';
import '../models/order_models.dart';

/// A page of orders plus its pagination metadata.
class OrdersPage {
  final List<Order> items;
  final Pagination pagination;
  const OrdersPage(this.items, this.pagination);
}

/// Orders data layer (B2B, `success` envelope).
class OrderRepository {
  final ApiClient _client;
  OrderRepository({required ApiClient client}) : _client = client;

  Future<OrdersPage> list({int limit = 50, int offset = 0}) async {
    final r = await _client.get<List<Order>>(
      ApiConstants.orders,
      query: {'limit': limit, 'offset': offset},
      fromJson: (j) => asMapList(j).map(Order.fromJson).toList(),
    );
    return OrdersPage(r.data ?? const [], Pagination.fromMeta(r.meta));
  }

  Future<Order> get(String id) async {
    final r = await _client.get<Order>(ApiConstants.order(id),
        fromJson: (j) => Order.fromJson(asMap(j)));
    return r.data!;
  }

  Future<Order> create(Map<String, dynamic> body) async {
    final r = await _client.post<Order>(ApiConstants.orders,
        data: body, fromJson: (j) => Order.fromJson(asMap(j)));
    return r.data!;
  }
}
