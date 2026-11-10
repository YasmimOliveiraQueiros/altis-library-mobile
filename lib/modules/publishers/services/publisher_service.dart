import 'dart:convert';

import 'package:altis_library_mobile/core/models/page_response.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:http/http.dart' as http;

import '../models/publisher.dart';

class PublisherService {
  PublisherService(this._apiClient);

  final ApiClient _apiClient;

  Future<PageResponse<Publisher>> getPublishers({
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
      path: '/publishers',
      queryParameters: queryParameters,
    ).toString();
    final response = await _apiClient.get(endpoint);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar editoras: HTTP ${response.statusCode}');
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return PageResponse<Publisher>.fromJson(json, Publisher.fromJson);
  }

  Future<void> createPublisher(PublisherData publisher) async {
    final response = await _apiClient.post(
      '/publishers',
      body: publisher.toJson(),
    );
    _checkSaveResponse(response);
  }

  Future<void> updatePublisher(int id, PublisherData publisher) async {
    final response = await _apiClient.put(
      '/publishers/$id',
      body: publisher.toJson(),
    );
    _checkSaveResponse(response);
  }

  Future<void> deletePublisher(int id) async {
    final response = await _apiClient.delete('/publishers/$id');

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir editora: HTTP ${response.statusCode}');
    }
  }

  void _checkSaveResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw PublisherSaveException(response.statusCode);
    }
  }
}

class PublisherSaveException implements Exception {
  const PublisherSaveException(this.statusCode);

  final int statusCode;
}
