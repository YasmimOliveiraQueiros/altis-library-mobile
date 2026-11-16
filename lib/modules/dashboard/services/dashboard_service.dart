import 'dart:convert';

import '../../../core/services/http/api_client.dart';
import '../../../core/services/http/api_errors.dart';
import '../models/dashboard.dart';

class DashboardService {
  DashboardService(this._apiClient);

  final ApiClient _apiClient;

  Future<Dashboard> getDashboard() async {
    final response = await _apiClient.get('/dashboard');
    if (response.statusCode != 200) {
      throw DashboardRequestException(response);
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Dashboard.fromJson(json);
  }
}

class DashboardRequestException extends ApiHttpException {
  DashboardRequestException(super.response);
}
