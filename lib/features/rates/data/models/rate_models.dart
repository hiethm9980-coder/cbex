import 'package:equatable/equatable.dart';

/// Estimated delivery window for a rate offer.
class EstimatedDelivery extends Equatable {
  final int? daysMin;
  final int? daysMax;
  final String? label;

  const EstimatedDelivery({this.daysMin, this.daysMax, this.label});

  factory EstimatedDelivery.fromJson(Map<String, dynamic> j) =>
      EstimatedDelivery(
        daysMin: (j['days_min'] as num?)?.toInt(),
        daysMax: (j['days_max'] as num?)?.toInt(),
        label: j['label'] as String?,
      );

  @override
  List<Object?> get props => [daysMin, daysMax, label];
}

/// A carrier rate option (`/shipments/{id}/offers`).
class RateOffer extends Equatable {
  final String id;
  final String? carrierCode;
  final String? carrierName;
  final String? serviceName;
  final String? currency;
  final num? displayRate;
  final bool isAvailable;
  final bool isSelected;
  final EstimatedDelivery? estimatedDelivery;

  const RateOffer({
    required this.id,
    this.carrierCode,
    this.carrierName,
    this.serviceName,
    this.currency,
    this.displayRate,
    this.isAvailable = true,
    this.isSelected = false,
    this.estimatedDelivery,
  });

  factory RateOffer.fromJson(Map<String, dynamic> j) => RateOffer(
        id: j['id']?.toString() ?? '',
        carrierCode: j['carrier_code'] as String?,
        carrierName: j['carrier_name'] as String?,
        serviceName: j['service_name'] as String?,
        currency: j['currency'] as String?,
        displayRate: j['display_rate'] as num?,
        isAvailable: j['is_available'] != false,
        isSelected: j['is_selected'] == true,
        estimatedDelivery: j['estimated_delivery'] is Map
            ? EstimatedDelivery.fromJson(
                Map<String, dynamic>.from(j['estimated_delivery'] as Map))
            : null,
      );

  @override
  List<Object?> get props => [id, carrierCode, serviceName, displayRate];
}

/// A rate quote: the quote id plus its available [offers]. The payload may be a
/// `{ rate_quote_id, offers:[...] }` object or a bare list of offers.
class RateQuote extends Equatable {
  final String? rateQuoteId;
  final List<RateOffer> offers;

  const RateQuote({this.rateQuoteId, this.offers = const []});

  factory RateQuote.fromPayload(Object? payload) {
    if (payload is List) {
      return RateQuote(offers: _offers(payload));
    }
    final m =
        payload is Map ? Map<String, dynamic>.from(payload) : <String, dynamic>{};
    return RateQuote(
      rateQuoteId: (m['rate_quote_id'] ?? m['quote_id'])?.toString(),
      offers: _offers(m['offers'] ?? m['data']),
    );
  }

  static List<RateOffer> _offers(Object? raw) => raw is List
      ? raw
          .whereType<Map>()
          .map((e) => RateOffer.fromJson(Map<String, dynamic>.from(e)))
          .toList()
      : const [];

  @override
  List<Object?> get props => [rateQuoteId, offers];
}
