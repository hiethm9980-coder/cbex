import 'package:equatable/equatable.dart';

/// Account record (`GET /account`).
class Account extends Equatable {
  final String id;
  final String name;
  final String? type;
  final String? status;
  final Map<String, dynamic> raw;

  const Account({
    required this.id,
    required this.name,
    this.type,
    this.status,
    this.raw = const {},
  });

  factory Account.fromJson(Map<String, dynamic> j) => Account(
        id: j['id']?.toString() ?? '',
        name: j['name'] as String? ?? '',
        type: (j['type'] ?? j['account_type']) as String?,
        status: j['status'] as String?,
        raw: j,
      );

  @override
  List<Object?> get props => [id, name, type, status];
}

/// Account settings (`GET/PUT /account/settings`). Kept as a raw map until the
/// concrete settings shape is needed by a screen.
class AccountSettings extends Equatable {
  final Map<String, dynamic> data;
  const AccountSettings(this.data);

  factory AccountSettings.fromJson(Map<String, dynamic> j) =>
      AccountSettings(j);

  @override
  List<Object?> get props => [data];
}
