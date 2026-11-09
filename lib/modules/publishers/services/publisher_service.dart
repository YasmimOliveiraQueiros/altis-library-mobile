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

  Future<Publisher> createPublisher(PublisherData publisher) async {
    final response = await _apiClient.post(
      '/publishers',
      body: publisher.toJson(),
    );
    return _parsePublisherResponse(response, 'criar editora');
  }

  Future<Publisher> updatePublisher(int id, PublisherData publisher) async {
    final response = await _apiClient.put(
      '/publishers/$id',
      body: publisher.toJson(),
    );
    return _parsePublisherResponse(response, 'atualizar editora');
  }

  Future<void> deletePublisher(int id) async {
    final response = await _apiClient.delete('/publishers/$id');

    if (response.statusCode != 200) {
      throw Exception('Erro ao excluir editora: HTTP ${response.statusCode}');
    }
  }

  Publisher _parsePublisherResponse(http.Response response, String action) {
    if (response.statusCode != 200) {
      throw Exception('Erro ao $action: HTTP ${response.statusCode}');
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return Publisher.fromJson(json);
  }
}
