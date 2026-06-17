import 'package:equatable/equatable.dart';

/// A single parcel inside a shipment.
class Parcel extends Equatable {
  final double weight; // kg
  final double? length;
  final double? width;
  final double? height;
  final String? packagingType; // box | envelope | tube | custom
  final String? description;

  const Parcel({
    required this.weight,
    this.length,
    this.width,
    this.height,
    this.packagingType,
    this.description,
  });

  factory Parcel.fromJson(Map<String, dynamic> j) => Parcel(
        weight: (j['weight'] as num?)?.toDouble() ?? 0,
        length: (j['length'] as num?)?.toDouble(),
        width: (j['width'] as num?)?.toDouble(),
        height: (j['height'] as num?)?.toDouble(),
        packagingType: j['packaging_type'] as String?,
        description: j['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'weight': weight,
        if (length != null) 'length': length,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
        if (packagingType != null) 'packaging_type': packagingType,
        if (description != null) 'description': description,
      };

  @override
  List<Object?> get props =>
      [weight, length, width, height, packagingType, description];
}

/// Shipment record (`/shipments`).
class Shipment extends Equatable {
  final String id;
  final String? referenceNumber;
  final String? status;
  final String? carrierCode;
  final String? trackingNumber;
  final String? senderCity;
  final String? recipientCity;
  final String? senderCountry;
  final String? recipientCountry;
  final double? codAmount;
  final num? totalCharge; // permission-gated; may be absent
  final String? createdAt;
  final List<Parcel> parcels;

  const Shipment({
    required this.id,
    this.referenceNumber,
    this.status,
    this.carrierCode,
    this.trackingNumber,
    this.senderCity,
    this.recipientCity,
    this.senderCountry,
    this.recipientCountry,
    this.codAmount,
    this.totalCharge,
    this.createdAt,
    this.parcels = const [],
  });

  factory Shipment.fromJson(Map<String, dynamic> j) => Shipment(
        id: j['id']?.toString() ?? '',
        referenceNumber: j['reference_number'] as String?,
        status: j['status'] as String?,
        carrierCode: j['carrier_code'] as String?,
        trackingNumber: j['tracking_number'] as String?,
        senderCity: j['sender_city'] as String?,
        recipientCity: j['recipient_city'] as String?,
        senderCountry: j['sender_country'] as String?,
        recipientCountry: j['recipient_country'] as String?,
        codAmount: (j['cod_amount'] as num?)?.toDouble(),
        totalCharge: j['total_charge'] as num?,
        createdAt: j['created_at']?.toString(),
        parcels: (j['parcels'] as List?)
                ?.whereType<Map>()
                .map((e) => Parcel.fromJson(Map<String, dynamic>.from(e)))
                .toList() ??
            const [],
      );

  @override
  List<Object?> get props => [id, referenceNumber, status, trackingNumber];
}

/// Aggregate shipment counters (`/shipments/stats`).
class ShipmentStats extends Equatable {
  final Map<String, dynamic> data;
  const ShipmentStats(this.data);

  factory ShipmentStats.fromJson(Map<String, dynamic> j) => ShipmentStats(j);

  int countFor(String key) => (data[key] as num?)?.toInt() ?? 0;

  @override
  List<Object?> get props => [data];
}

/// Result of `quick-ship` (envelope ب: `data.{...}`).
class QuickShipResult extends Equatable {
  final bool success;
  final String? shipmentId;
  final String? trackingNumber;
  final String? carrierShipmentId;
  final String? carrierCode;
  final String? serviceName;
  final String? labelFormat;
  final bool wasIdempotentHit;

  const QuickShipResult({
    this.success = false,
    this.shipmentId,
    this.trackingNumber,
    this.carrierShipmentId,
    this.carrierCode,
    this.serviceName,
    this.labelFormat,
    this.wasIdempotentHit = false,
  });

  factory QuickShipResult.fromJson(Map<String, dynamic> j) => QuickShipResult(
        success: j['success'] == true,
        shipmentId: j['shipment_id']?.toString(),
        trackingNumber: j['tracking_number'] as String?,
        carrierShipmentId: j['carrier_shipment_id']?.toString(),
        carrierCode: j['carrier_code'] as String?,
        serviceName: j['service_name'] as String?,
        labelFormat: j['label_format'] as String?,
        wasIdempotentHit: j['was_idempotent_hit'] == true,
      );

  @override
  List<Object?> get props => [shipmentId, trackingNumber, success];
}
