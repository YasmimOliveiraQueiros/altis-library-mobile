import 'dart:convert';

import 'package:altis_library_mobile/core/models/page_response.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';

import '../models/user.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<PageResponse<User>> getUsers({
    String? search,
    int page = 0,
    int size = 10,
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final endpoint = Uri(
      path: '/users',
      queryParameters: queryParameters,
    ).toString();
    final response = await _apiClient.get(endpoint);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar usuários: HTTP ${response.statusCode}');
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    return PageResponse<User>.fromJson(json, User.fromJson);
  }

  Future<void> setUserActive(int id, {required bool active}) async {
    final response = await _apiClient.patch('/users/$id/status?active=$active');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Erro ao atualizar situação do usuário: HTTP ${response.statusCode}',
      );
    }
  }
}
