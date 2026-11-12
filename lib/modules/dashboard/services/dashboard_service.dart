import 'dart:convert';

import '../../../core/services/http/api_client.dart';
import '../models/dashboard.dart';

class DashboardService {
  DashboardService(this._apiClient);

  final ApiClient _apiClient;

  Future<Dashboard> getDashboard() async {
    final response = await _apiClient.get('/dashboard');
    if (response.statusCode != 200) {
      throw DashboardRequestException(response.statusCode);
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Dashboard.fromJson(json);
  }
}

class DashboardRequestException implements Exception {
  const DashboardRequestException(this.statusCode);

  final int statusCode;
}
