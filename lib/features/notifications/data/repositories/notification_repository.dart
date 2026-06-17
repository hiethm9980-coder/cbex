import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_x.dart';
import '../models/notification_models.dart';

/// Notifications data layer (`status` envelope).
class NotificationRepository {
  final ApiClient _client;
  NotificationRepository({required ApiClient client}) : _client = client;

  Future<List<AppNotification>> inApp() async {
    final r = await _client.get<List<AppNotification>>(
        ApiConstants.notificationsInApp,
        fromJson: (j) => asMapList(j).map(AppNotification.fromJson).toList());
    return r.data ?? const [];
  }

  /// `data = { unread_count: N }` — ideal for a badge.
  Future<int> unreadCount() async {
    final r = await _client.get<int>(ApiConstants.notificationsUnreadCount,
        fromJson: (j) => (asMap(j)['unread_count'] as num?)?.toInt() ?? 0);
    return r.data ?? 0;
  }

  Future<void> markRead(String id) async {
    await _client.post<void>(ApiConstants.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _client.post<void>(ApiConstants.notificationsReadAll);
  }

  Future<NotificationPreferences> preferences() async {
    final r = await _client.get<NotificationPreferences>(
        ApiConstants.notificationsPreferences,
        fromJson: (j) => NotificationPreferences.fromJson(asMap(j)));
    return r.data!;
  }

  Future<NotificationPreferences> updatePreferences(
      Map<String, dynamic> body) async {
    final r = await _client.put<NotificationPreferences>(
        ApiConstants.notificationsPreferences,
        data: body,
        fromJson: (j) => NotificationPreferences.fromJson(asMap(j)));
    return r.data!;
  }
}
