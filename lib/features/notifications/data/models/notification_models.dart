import 'package:equatable/equatable.dart';

/// An in-app notification (`/notifications/in-app`).
class AppNotification extends Equatable {
  final String id;
  final String? title;
  final String? body;
  final String? type;
  final String? createdAt;
  final bool isRead;

  const AppNotification({
    required this.id,
    this.title,
    this.body,
    this.type,
    this.createdAt,
    this.isRead = false,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id']?.toString() ?? '',
        title: (j['title'] ?? j['title_en'] ?? j['title_ar']) as String?,
        body: (j['body'] ?? j['message'] ?? j['body_en']) as String?,
        type: j['type'] as String?,
        createdAt: (j['created_at'] ?? j['read_at'])?.toString(),
        isRead: j['is_read'] == true || j['read_at'] != null,
      );

  @override
  List<Object?> get props => [id, title, isRead];
}

/// Notification channel preferences (`/notifications/preferences`).
class NotificationPreferences extends Equatable {
  final Map<String, dynamic> data;
  const NotificationPreferences(this.data);

  factory NotificationPreferences.fromJson(Map<String, dynamic> j) =>
      NotificationPreferences(j);

  @override
  List<Object?> get props => [data];
}
