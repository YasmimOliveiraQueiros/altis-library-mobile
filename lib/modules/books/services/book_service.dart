import 'dart:convert';

import 'package:altis_library_mobile/core/models/page_response.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';

import '../models/book.dart';

class BookService {
  BookService(this._apiClient);

  final ApiClient _apiClient;

  Future<PageResponse<Book>> getBooks({
    String? search,
    int page = 0,
    int size = 10,
    String sortBy = 'title',
    String sortDirection = 'ASC',
  }) async {
    final queryParameters = <String, String>{
      'page': page.toString(),
      'size': size.toString(),
      'sortBy': sortBy,
      'sortDirection': sortDirection,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final endpoint = Uri(
      path: '/books',
      queryParameters: queryParameters,
    ).toString();
    final response = await _apiClient.get(endpoint);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar livros: HTTP ${response.statusCode}');
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    return PageResponse<Book>.fromJson(json, Book.fromJson);
  }

  Future<List<Book>> getAllBooks({int size = 100}) async {
    final books = <Book>[];
    var page = 0;
    int totalPages;
    do {
      final response = await getBooks(page: page, size: size);
      books.addAll(response.content);
      totalPages = response.totalPages;
      page++;
    } while (page < totalPages);
    return books;
  }

  Future<Book> getBook(int id) async {
    final response = await _apiClient.get('/books/$id');

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar livro: HTTP ${response.statusCode}');
    }

    return Book.fromJson(
      jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
    );
  }

  Future<void> createBook(BookData book) async {
    final response = await _apiClient.post('/books', body: book.toJson());
    _checkWriteResponse(response.statusCode);
  }

  Future<void> updateBook(int id, BookData book) async {
    final response = await _apiClient.put('/books/$id', body: book.toJson());
    _checkWriteResponse(response.statusCode);
  }

  Future<void> deleteBook(int id) async {
    final response = await _apiClient.delete('/books/$id');
    _checkWriteResponse(response.statusCode);
  }

  void _checkWriteResponse(int statusCode) {
    if (statusCode < 200 || statusCode >= 300) {
      throw BookRequestException(statusCode);
    }
  }
}

class BookRequestException implements Exception {
  const BookRequestException(this.statusCode);

  final int statusCode;
}
