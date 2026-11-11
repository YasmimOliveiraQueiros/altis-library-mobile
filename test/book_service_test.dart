import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/modules/books/models/book.dart';
import 'package:altis_library_mobile/modules/books/services/book_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const bookJson = {
    'id': 42,
    'title': 'A Biblioteca',
    'author': 'Ana Silva',
    'publisherId': 73,
    'quantity': 0,
    'status': 'AVAILABLE',
    'observations': null,
  };

  test('book parsing and payload serialization match the API contract', () {
    final book = Book.fromJson(bookJson);
    const data = BookData(
      title: 'A Biblioteca',
      author: 'Ana Silva',
      publisherId: 73,
      quantity: 0,
    );

    expect(book.status, BookStatus.available);
    expect(book.publisherId, 73);
    expect(book.quantity, 0);
    expect(book.observations, isNull);
    expect(data.toJson(), {
      'title': 'A Biblioteca',
      'author': 'Ana Silva',
      'publisherId': 73,
      'quantity': 0,
    });
  });

  test(
    'book CRUD sends documented paths, queries, and numeric publisherId',
    () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET' && request.url.path == '/books') {
            return http.Response(
              jsonEncode({
                'content': [bookJson],
                'totalElements': 11,
                'totalPages': 2,
                'number': 1,
                'size': 10,
                'first': false,
                'last': true,
                'empty': false,
              }),
              200,
            );
          }
          if (request.method == 'GET') {
            return http.Response(jsonEncode(bookJson), 200);
          }
          return http.Response('', 200);
        }),
      );
      client.setToken('test-token');
      final service = BookService(client);
      const data = BookData(
        title: 'A Biblioteca',
        author: 'Ana Silva',
        publisherId: 73,
        quantity: 0,
        observations: 'Edição revisada',
      );

      try {
        final page = await service.getBooks(
          search: ' Ana & Biblioteca ',
          page: 1,
          size: 10,
          sortBy: 'author',
          sortDirection: 'DESC',
        );
        final book = await service.getBook(42);
        await service.createBook(data);
        await service.updateBook(42, data);
        await service.deleteBook(42);

        expect(page.content.single.title, 'A Biblioteca');
        expect(page.totalElements, 11);
        expect(book.status, BookStatus.available);
        expect(requests.map((request) => request.method), [
          'GET',
          'GET',
          'POST',
          'PUT',
          'DELETE',
        ]);
        expect(requests.first.url.path, '/books');
        expect(requests.first.url.queryParameters, {
          'page': '1',
          'size': '10',
          'sortBy': 'author',
          'sortDirection': 'DESC',
          'search': 'Ana & Biblioteca',
        });
        expect(jsonDecode(requests[2].body), {
          'title': 'A Biblioteca',
          'author': 'Ana Silva',
          'publisherId': 73,
          'quantity': 0,
          'observations': 'Edição revisada',
        });
        expect(jsonDecode(requests[2].body)['publisherId'], isA<int>());
        expect(jsonDecode(requests[2].body), isNot(contains('status')));
        expect(requests[2].url.path, '/books');
        expect(requests[3].url.path, '/books/42');
        expect(requests[4].url.path, '/books/42');
        for (final request in requests) {
          expect(request.headers.containsKey('authorization'), isTrue);
        }
      } finally {
        client.dispose();
      }
    },
  );

  test(
    'write failure keeps the status without exposing the response body',
    () async {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response('private backend detail', 409),
        ),
      );
      final service = BookService(client);

      try {
        await expectLater(
          service.deleteBook(42),
          throwsA(
            isA<BookRequestException>().having(
              (error) => error.statusCode,
              'statusCode',
              409,
            ),
          ),
        );
      } finally {
        client.dispose();
      }
    },
  );
}
