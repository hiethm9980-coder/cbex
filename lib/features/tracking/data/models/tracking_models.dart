import 'package:equatable/equatable.dart';

/// A single tracking event in a shipment's history.
class TrackingEvent extends Equatable {
  final String? status;
  final String? description;
  final String? location;
  final String? timestamp;

  const TrackingEvent({
    this.status,
    this.description,
    this.location,
    this.timestamp,
  });

  factory TrackingEvent.fromJson(Map<String, dynamic> j) => TrackingEvent(
        status: j['status'] as String?,
        description: (j['description'] ?? j['message']) as String?,
        location: j['location'] as String?,
        timestamp:
            (j['timestamp'] ?? j['created_at'] ?? j['occurred_at'])?.toString(),
      );

  @override
  List<Object?> get props => [status, description, location, timestamp];
}

/// Current tracking status of a shipment.
class TrackingStatus extends Equatable {
  final String? status;
  final String? trackingNumber;
  final Map<String, dynamic> raw;

  const TrackingStatus({this.status, this.trackingNumber, this.raw = const {}});

  factory TrackingStatus.fromJson(Map<String, dynamic> j) => TrackingStatus(
        status: (j['status'] ?? j['current_status']) as String?,
        trackingNumber: j['tracking_number'] as String?,
        raw: j,
      );

  @override
  List<Object?> get props => [status, trackingNumber];
}

/// Tracking dashboard summary (`/tracking/dashboard`).
class TrackingDashboard extends Equatable {
  final Map<String, dynamic> data;
  const TrackingDashboard(this.data);

  factory TrackingDashboard.fromJson(Map<String, dynamic> j) =>
      TrackingDashboard(j);

  @override
  List<Object?> get props => [data];
}
