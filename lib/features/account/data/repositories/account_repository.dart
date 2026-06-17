import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/json_x.dart';
import '../models/account_models.dart';

/// Account & settings data layer (`/account`, `/account/settings`).
class AccountRepository {
  final ApiClient _client;
  AccountRepository({required ApiClient client}) : _client = client;

  Future<Account> getAccount() async {
    final r = await _client.get<Account>(ApiConstants.account,
        fromJson: (j) => Account.fromJson(asMap(j)));
    return r.data!;
  }

  Future<AccountSettings> getSettings() async {
    final r = await _client.get<AccountSettings>(ApiConstants.accountSettings,
        fromJson: (j) => AccountSettings.fromJson(asMap(j)));
    return r.data!;
  }

  Future<AccountSettings> updateSettings(Map<String, dynamic> body) async {
    final r = await _client.put<AccountSettings>(ApiConstants.accountSettings,
        data: body, fromJson: (j) => AccountSettings.fromJson(asMap(j)));
    return r.data!;
  }
}
