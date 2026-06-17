import 'package:uuid/uuid.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_x.dart';
import '../../../../core/network/pagination.dart';
import '../models/shipment_models.dart';

/// A page of shipments plus its pagination metadata.
class ShipmentsPage {
  final List<Shipment> items;
  final Pagination pagination;
  const ShipmentsPage(this.items, this.pagination);
}

/// Shipments data layer (`/shipments` …).
class ShipmentRepository {
  final ApiClient _client;
  ShipmentRepository({required ApiClient client}) : _client = client;

  /// [filters] accepts: status, carrier, source, is_cod, is_international,
  /// from, to, search.
  Future<ShipmentsPage> list({
    Map<String, dynamic>? filters,
    int limit = 50,
    int offset = 0,
  }) async {
    final r = await _client.get<List<Shipment>>(
      ApiConstants.shipments,
      query: {'limit': limit, 'offset': offset, ...?filters},
      fromJson: (j) => asMapList(j).map(Shipment.fromJson).toList(),
    );
    return ShipmentsPage(r.data ?? const [], Pagination.fromMeta(r.meta));
  }

  Future<ShipmentStats> stats() async {
    final r = await _client.get<ShipmentStats>(ApiConstants.shipmentStats,
        fromJson: (j) => ShipmentStats.fromJson(asMap(j)));
    return r.data!;
  }

  Future<Shipment> get(String id) async {
    final r = await _client.get<Shipment>(ApiConstants.shipment(id),
        fromJson: (j) => Shipment.fromJson(asMap(j)));
    return r.data!;
  }

  Future<Shipment> create(Map<String, dynamic> body) async {
    final r = await _client.post<Shipment>(ApiConstants.shipments,
        data: body, fromJson: (j) => Shipment.fromJson(asMap(j)));
    return r.data!;
  }

  Future<void> validate(String id) async {
    await _client.post<void>(ApiConstants.shipmentValidate(id));
  }

  /// Books the shipment with a carrier. A unique [idempotencyKey] is generated
  /// per call (override to safely retry the *same* booking).
  Future<QuickShipResult> quickShip(
    String id, {
    String strategy = 'best_value', // cheapest | fastest | best_value
    String? optionId,
    String labelFormat = 'pdf', // pdf | zpl | png | epl
    String? carrierCode,
    String? idempotencyKey,
  }) async {
    final r = await _client.post<QuickShipResult>(
      ApiConstants.shipmentQuickShip(id),
      data: {
        'idempotency_key': idempotencyKey ?? const Uuid().v4(),
        'strategy': strategy,
        if (optionId != null) 'option_id': optionId,
        'label_format': labelFormat,
        if (carrierCode != null) 'carrier_code': carrierCode,
      },
      fromJson: (j) => QuickShipResult.fromJson(asMap(j)),
    );
    return r.data!;
  }

  Future<void> cancel(String id, {String? reason}) async {
    await _client.post<void>(ApiConstants.shipmentCancel(id),
        data: reason != null ? {'reason': reason} : null);
  }

  /// Returns the raw label payload (url / base64 / format), shape varies.
  Future<Map<String, dynamic>> label(String id) async {
    final r = await _client.get<Map<String, dynamic>>(
        ApiConstants.shipmentLabel(id),
        fromJson: (j) => asMap(j));
    return r.data ?? const {};
  }

  Future<Shipment> createFromOrder(String orderId) async {
    final r = await _client.post<Shipment>(
        ApiConstants.shipmentFromOrder(orderId),
        fromJson: (j) => Shipment.fromJson(asMap(j)));
    return r.data!;
  }
}
