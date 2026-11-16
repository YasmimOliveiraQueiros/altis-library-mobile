import 'dart:convert';

import 'package:altis_library_mobile/core/models/page_response.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/services/http/api_errors.dart';

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
      throw UserRequestException(response);
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    return PageResponse<User>.fromJson(json, User.fromJson);
  }

  Future<User> getMyProfile() async {
    final response = await _apiClient.get('/users/me');
    if (response.statusCode != 200) {
      throw UserRequestException(response);
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return User.fromJson(json);
  }

  Future<void> updateMyProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final response = await _apiClient.patch(
      '/users/me',
      body: {'name': name, 'email': email, 'phone': phone, 'address': address},
    );
    if (response.statusCode != 200) throw UserRequestException(response);
  }

  Future<void> changeMyPassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final response = await _apiClient.patch(
      '/users/me/password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmPassword': confirmPassword,
      },
    );
    if (response.statusCode != 204) throw UserRequestException(response);
  }

  Future<List<User>> getAllUsers({int size = 100}) async {
    final users = <User>[];
    var page = 0;
    int totalPages;
    do {
      final response = await getUsers(page: page, size: size);
      users.addAll(response.content);
      totalPages = response.totalPages;
      page++;
    } while (page < totalPages);
    return users;
  }

  Future<void> setUserActive(int id, {required bool active}) async {
    final response = await _apiClient.patch('/users/$id/status?active=$active');

    if (response.statusCode != 200) throw UserRequestException(response);
  }
}

class UserRequestException extends ApiHttpException {
  UserRequestException(super.response);
}
