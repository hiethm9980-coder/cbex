import 'package:equatable/equatable.dart';

/// Address-book entry (`/addresses`).
class Address extends Equatable {
  final String id;
  final String? type; // sender | recipient | both
  final bool isDefaultSender;
  final String? label;
  final String contactName;
  final String? companyName;
  final String phone;
  final String? email;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String? state;
  final String? postalCode;
  final String country; // ISO-2

  const Address({
    required this.id,
    this.type,
    this.isDefaultSender = false,
    this.label,
    required this.contactName,
    this.companyName,
    required this.phone,
    this.email,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    this.state,
    this.postalCode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> j) => Address(
        id: j['id']?.toString() ?? '',
        type: j['type'] as String?,
        isDefaultSender:
            j['is_default_sender'] == true || j['is_default_sender'] == 1,
        label: j['label'] as String?,
        contactName: j['contact_name'] as String? ?? '',
        companyName: j['company_name'] as String?,
        phone: j['phone'] as String? ?? '',
        email: j['email'] as String?,
        addressLine1: j['address_line_1'] as String? ?? '',
        addressLine2: j['address_line_2'] as String?,
        city: j['city'] as String? ?? '',
        state: j['state'] as String?,
        postalCode: j['postal_code'] as String?,
        country: j['country'] as String? ?? '',
      );

  @override
  List<Object?> get props =>
      [id, type, contactName, phone, addressLine1, city, country];
}
