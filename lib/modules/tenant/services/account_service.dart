import '../../../core/services/http/api_client.dart';
import '../../../core/services/http/api_errors.dart';

class AccountService {
  AccountService(this._apiClient);

  final ApiClient _apiClient;

  Future<void> closeAccount() async {
    final response = await _apiClient.delete('/users/me');
    if (response.statusCode != 204) throw ApiHttpException(response);
  }
}
