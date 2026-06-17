import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_x.dart';
import '../models/address_models.dart';

/// Address-book data layer (`/addresses`).
class AddressRepository {
  final ApiClient _client;
  AddressRepository({required ApiClient client}) : _client = client;

  Future<List<Address>> list({String? type}) async {
    final r = await _client.get<List<Address>>(
      ApiConstants.addresses,
      query: type != null ? {'type': type} : null,
      fromJson: (j) => asMapList(j).map(Address.fromJson).toList(),
    );
    return r.data ?? const [];
  }

  Future<Address> get(String id) async {
    final r = await _client.get<Address>(ApiConstants.address(id),
        fromJson: (j) => Address.fromJson(asMap(j)));
    return r.data!;
  }

  Future<Address> create(Map<String, dynamic> body) async {
    final r = await _client.post<Address>(ApiConstants.addresses,
        data: body, fromJson: (j) => Address.fromJson(asMap(j)));
    return r.data!;
  }

  Future<Address> update(String id, Map<String, dynamic> body) async {
    final r = await _client.put<Address>(ApiConstants.address(id),
        data: body, fromJson: (j) => Address.fromJson(asMap(j)));
    return r.data!;
  }

  Future<void> delete(String id) async {
    await _client.delete<void>(ApiConstants.address(id));
  }
}
