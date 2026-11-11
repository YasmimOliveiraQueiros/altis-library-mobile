import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/books/pages/book_form_page.dart';
import 'package:altis_library_mobile/modules/books/pages/books_page.dart';
import 'package:altis_library_mobile/modules/books/services/book_service.dart';
import 'package:altis_library_mobile/modules/books/widgets/book_metrics.dart';
import 'package:altis_library_mobile/modules/publishers/services/publisher_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: const Locale('pt'),
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  testWidgets('book metrics fit together on a narrow screen', (tester) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _localizedApp(
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(12),
            child: BookMetrics(
              copiesOnPage: 24,
              booksOnPage: 10,
              totalResults: 134,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final cards = tester.widgetList<Card>(find.byType(Card)).toList();
    expect(cards, hasLength(3));
    final first = tester.getRect(find.byWidget(cards.first));
    final second = tester.getRect(find.byWidget(cards[1]));
    final third = tester.getRect(find.byWidget(cards[2]));
    expect(first.right, lessThanOrEqualTo(second.left));
    expect(second.right, lessThanOrEqualTo(third.left));
    expect(find.text('24'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('134'), findsOneWidget);
  });

  testWidgets(
    'book form loads paginated publishers and validates numeric payload',
    (tester) async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'GET') {
            final page = int.parse(request.url.queryParameters['page']!);
            final publisher = {
              'id': page == 0 ? 10 : 99,
              'name': page == 0 ? 'Editora ativa' : 'Editora inativa',
              'email': 'editora@example.test',
              'cnpj': '123',
              'city': 'São Paulo',
              'state': 'SP',
              'bookCount': 0,
              'status': page == 0 ? 'ACTIVE' : 'INACTIVE',
            };
            return http.Response.bytes(
              utf8.encode(
                jsonEncode({
                  'content': [publisher],
                  'totalElements': 2,
                  'totalPages': 2,
                  'number': page,
                  'size': 100,
                  'first': page == 0,
                  'last': page == 1,
                  'empty': false,
                }),
              ),
              200,
            );
          }
          return http.Response('', 200);
        }),
      );
      final bookService = BookService(client);
      final publisherService = PublisherService(client);
      addTearDown(client.dispose);

      await tester.pumpWidget(
        _localizedApp(
          BookFormPage(
            service: bookService,
            publisherService: publisherService,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpAndSettle();

      expect(
        requests.where((request) => request.method == 'GET'),
        hasLength(2),
      );
      await tester.tap(find.byType(DropdownButtonFormField<int>));
      await tester.pumpAndSettle();
      expect(find.text('Editora inativa · Inativo'), findsOneWidget);
      await tester.tap(find.text('Editora inativa · Inativo'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Título'),
        'Livro',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Autor'),
        'Autora',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantidade disponível'),
        '-1',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      expect(
        find.text('Informe uma quantidade inteira igual ou maior que zero.'),
        findsOneWidget,
      );
      expect(requests.where((request) => request.method == 'POST'), isEmpty);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Quantidade disponível'),
        '0',
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
      await tester.pumpAndSettle();

      final saveRequest = requests.singleWhere(
        (request) => request.method == 'POST',
      );
      final payload = jsonDecode(saveRequest.body) as Map<String, dynamic>;
      expect(saveRequest.url.path, '/books');
      expect(payload['publisherId'], 99);
      expect(payload['publisherId'], isA<int>());
      expect(payload['quantity'], 0);
      expect(payload, isNot(contains('status')));
    },
  );

  testWidgets('books page shows API results and scoped metrics', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/books') {
          return http.Response(
            jsonEncode({
              'content': [
                {
                  'id': 1,
                  'title': 'Livro de teste',
                  'author': 'Autora',
                  'publisherId': 73,
                  'quantity': 4,
                  'status': 'AVAILABLE',
                  'observations': null,
                },
              ],
              'totalElements': 3,
              'totalPages': 1,
              'number': 0,
              'size': 10,
              'first': true,
              'last': true,
              'empty': false,
            }),
            200,
          );
        }
        return http.Response(
          jsonEncode({
            'content': [],
            'totalElements': 0,
            'totalPages': 0,
            'number': 0,
            'size': 100,
            'first': true,
            'last': true,
            'empty': true,
          }),
          200,
        );
      }),
    );
    client.setToken('test-token');
    addTearDown(client.dispose);

    await tester.pumpWidget(_localizedApp(BooksPage(apiClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('Livro de teste'), findsOneWidget);
    expect(find.text('4'), findsNWidgets(2));
    expect(find.text('1'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
