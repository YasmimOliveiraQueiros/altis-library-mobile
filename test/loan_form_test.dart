import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/loans/models/loan.dart';
import 'package:altis_library_mobile/modules/loans/pages/loan_form_page.dart';
import 'package:altis_library_mobile/modules/loans/services/loan_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget _app(Widget home) => MaterialApp(
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

Map<String, dynamic> _page(List<Map<String, dynamic>> content) => {
  'content': content,
  'totalElements': content.length,
  'totalPages': content.isEmpty ? 0 : 1,
  'number': 0,
  'size': 100,
  'first': true,
  'last': true,
  'empty': content.isEmpty,
};

Map<String, dynamic> _user({required bool active}) => {
  'id': active ? 42 : 77,
  'name': active ? 'Ana Silva' : 'Conta inativa',
  'email': 'ana@example.test',
  'phone': '123',
  'cpf': '456',
  'birthDate': '2000-01-01',
  'address': 'Rua A',
  'isAdmin': false,
  'active': active,
  'createdAt': '2026-01-01T00:00:00',
  'updatedAt': '2026-01-01T00:00:00',
};

Map<String, dynamic> _book({
  required int id,
  required String title,
  required String status,
  required int quantity,
}) => {
  'id': id,
  'title': title,
  'author': 'Autora',
  'publisherId': 5,
  'quantity': quantity,
  'status': status,
  'observations': null,
};

void main() {
  testWidgets('new loan form selects eligible records and sends integer IDs', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        if (request.method == 'GET' && request.url.path == '/users') {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode(_page([_user(active: true), _user(active: false)])),
            ),
            200,
          );
        }
        if (request.method == 'GET' && request.url.path == '/books') {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode(
                _page([
                  _book(
                    id: 70,
                    title: 'Livro disponível',
                    status: 'AVAILABLE',
                    quantity: 3,
                  ),
                  _book(
                    id: 71,
                    title: 'Livro indisponível',
                    status: 'RENTED',
                    quantity: 0,
                  ),
                ]),
              ),
            ),
            200,
          );
        }
        return http.Response('', 200);
      }),
    );
    client.setToken('test-token');
    addTearDown(client.dispose);

    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LoanFormPage(
                    apiClient: client,
                    loanService: LoanService(client),
                  ),
                ),
              ),
              child: const Text('Abrir formulário'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir formulário'));
    await tester.pumpAndSettle();

    expect(find.text('Conta inativa'), findsNothing);
    await tester.tap(find.byType(DropdownButtonFormField<int>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ana Silva'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(DropdownButtonFormField<int>).last);
    await tester.pumpAndSettle();
    expect(find.text('Livro indisponível · 0'), findsNothing);
    await tester.tap(find.text('Livro disponível · 3'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextFormField, 'Data do aluguel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextFormField, 'Devolução prevista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'Salvar'));
    await tester.pumpAndSettle();

    final request = requests.singleWhere((item) => item.method == 'POST');
    final payload = jsonDecode(request.body) as Map<String, dynamic>;
    expect(request.url.path, '/loans');
    expect(payload['userId'], 42);
    expect(payload['bookId'], 70);
    expect(payload['userId'], isA<int>());
    expect(payload['bookId'], isA<int>());
    expect(payload['loanDate'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    expect(payload['returnDate'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    expect(payload, isNot(contains('status')));
    expect(payload, isNot(contains('returnedAt')));
  });

  testWidgets('editing keeps the existing user, book, and date values', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/users') {
          return http.Response.bytes(
            utf8.encode(jsonEncode(_page([_user(active: false)]))),
            200,
          );
        }
        if (request.url.path == '/books') {
          return http.Response.bytes(
            utf8.encode(
              jsonEncode(
                _page([
                  _book(
                    id: 70,
                    title: 'Livro emprestado',
                    status: 'RENTED',
                    quantity: 0,
                  ),
                ]),
              ),
            ),
            200,
          );
        }
        return http.Response('', 200);
      }),
    );
    addTearDown(client.dispose);
    const loan = Loan(
      id: 31,
      userId: 77,
      bookId: 70,
      bookTitle: 'Livro emprestado',
      loanDate: '2026-03-10',
      returnDate: '2026-03-20',
      returnedAt: null,
      status: LoanStatus.overdue,
      observations: 'Observação existente',
    );

    await tester.pumpWidget(
      _app(
        LoanFormPage(
          apiClient: client,
          loanService: LoanService(client),
          loan: loan,
        ),
      ),
    );
    await tester.pumpAndSettle();

    final dropdowns = tester
        .widgetList<DropdownButtonFormField<int>>(
          find.byType(DropdownButtonFormField<int>),
        )
        .toList();
    expect(dropdowns[0].initialValue, 77);
    expect(dropdowns[1].initialValue, 70);
    expect(find.text('2026-03-10'), findsOneWidget);
    expect(find.text('2026-03-20'), findsOneWidget);
    expect(find.text('Observação existente'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
