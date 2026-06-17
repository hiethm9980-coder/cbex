import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_x.dart';
import '../models/tracking_models.dart';

/// Tracking data layer (`status` envelope).
class TrackingRepository {
  final ApiClient _client;
  TrackingRepository({required ApiClient client}) : _client = client;

  Future<List<TrackingEvent>> timeline(String shipmentId) async {
    final r = await _client.get<List<TrackingEvent>>(
        ApiConstants.trackingTimeline(shipmentId),
        fromJson: (j) => asMapList(j).map(TrackingEvent.fromJson).toList());
    return r.data ?? const [];
  }

  Future<TrackingStatus> status(String shipmentId) async {
    final r = await _client.get<TrackingStatus>(
        ApiConstants.trackingStatus(shipmentId),
        fromJson: (j) => TrackingStatus.fromJson(asMap(j)));
    return r.data!;
  }

  Future<List<TrackingEvent>> events(String shipmentId) async {
    final r = await _client.get<List<TrackingEvent>>(
        ApiConstants.trackingEvents(shipmentId),
        fromJson: (j) => asMapList(j).map(TrackingEvent.fromJson).toList());
    return r.data ?? const [];
  }

  /// [filters]: status, tracking_number, date_from, date_to, per_page.
  Future<List<TrackingEvent>> search({Map<String, dynamic>? filters}) async {
    final r = await _client.get<List<TrackingEvent>>(
        ApiConstants.trackingSearch,
        query: filters,
        fromJson: (j) => asMapList(j).map(TrackingEvent.fromJson).toList());
    return r.data ?? const [];
  }

  Future<TrackingDashboard> dashboard() async {
    final r = await _client.get<TrackingDashboard>(
        ApiConstants.trackingDashboard,
        fromJson: (j) => TrackingDashboard.fromJson(asMap(j)));
    return r.data!;
  }

  Future<void> subscribe(
    String shipmentId, {
    required String channel, // email | sms | webhook | in_app
    required String destination,
    List<String> eventTypes = const [],
    String language = 'ar',
  }) async {
    await _client.post<void>(
      ApiConstants.trackingSubscribe(shipmentId),
      data: {
        'channel': channel,
        'destination': destination,
        'event_types': eventTypes,
        'language': language,
      },
    );
  }
}
