import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/rate_models.dart';

/// Rates & offers data layer.
class RateRepository {
  final ApiClient _client;
  RateRepository({required ApiClient client}) : _client = client;

  /// Triggers carrier rate fetching for a shipment (no body; optional [carrier]).
  Future<RateQuote> fetchRates(String shipmentId, {String? carrier}) async {
    final r = await _client.post<RateQuote>(
      ApiConstants.shipmentRates(shipmentId),
      query: carrier != null ? {'carrier': carrier} : null,
      fromJson: (j) => RateQuote.fromPayload(j),
    );
    return r.data ?? const RateQuote();
  }

  Future<RateQuote> offers(String shipmentId) async {
    final r = await _client.get<RateQuote>(
      ApiConstants.shipmentOffers(shipmentId),
      fromJson: (j) => RateQuote.fromPayload(j),
    );
    return r.data ?? const RateQuote();
  }

  Future<void> selectOption(
    String quoteId, {
    String? optionId,
    String? strategy, // cheapest | fastest | best_value
  }) async {
    await _client.post<void>(
      ApiConstants.rateQuoteSelect(quoteId),
      data: {
        if (optionId != null) 'option_id': optionId,
        if (strategy != null) 'strategy': strategy,
      },
    );
  }
}
