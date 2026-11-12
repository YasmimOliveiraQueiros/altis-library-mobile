import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/loans/pages/loans_page.dart';
import 'package:altis_library_mobile/modules/loans/widgets/loan_metrics.dart';
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

Map<String, dynamic> _page({
  List<Map<String, dynamic>> content = const [],
  int total = 0,
}) => {
  'content': content,
  'totalElements': total,
  'totalPages': total == 0 ? 0 : 1,
  'number': 0,
  'size': 10,
  'first': true,
  'last': true,
  'empty': content.isEmpty,
};

void main() {
  testWidgets('four loan metrics use three cards then a second-row total', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(12),
            child: LoanMetrics(
              pending: 12,
              overdue: 3,
              returned: 21,
              total: 36,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final cards = tester.widgetList<Card>(find.byType(Card)).toList();
    expect(cards, hasLength(4));
    final first = tester.getRect(find.byWidget(cards[0]));
    final second = tester.getRect(find.byWidget(cards[1]));
    final third = tester.getRect(find.byWidget(cards[2]));
    final total = tester.getRect(find.byWidget(cards[3]));
    expect(first.right, lessThanOrEqualTo(second.left));
    expect(second.right, lessThanOrEqualTo(third.left));
    expect(total.top, greaterThanOrEqualTo(first.bottom));
    for (final value in ['12', '3', '21', '36']) {
      expect(find.text(value), findsOneWidget);
    }
  });

  testWidgets('loans page displays server-backed results and global metrics', (
    tester,
  ) async {
    final loan = {
      'id': 31,
      'userId': 42,
      'bookId': 70,
      'bookTitle': 'A Biblioteca',
      'loanDate': '2026-03-10',
      'returnDate': '2026-03-20',
      'returnedAt': null,
      'status': 'PENDING',
      'observations': null,
    };
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/loans') {
          final status = request.url.queryParameters['status'];
          final size = int.parse(request.url.queryParameters['size']!);
          final count = switch (status) {
            'PENDING' => 4,
            'OVERDUE' => 2,
            'RETURNED' => 3,
            'RETURNED_LATE' => 1,
            _ => 10,
          };
          return http.Response.bytes(
            utf8.encode(
              jsonEncode(
                _page(
                  content: size == 1 || status != null ? [] : [loan],
                  total: count,
                ),
              ),
            ),
            200,
          );
        }
        return http.Response.bytes(
          utf8.encode(
            jsonEncode(
              _page(
                content: [
                  {
                    'id': 42,
                    'name': 'Ana Silva',
                    'email': 'ana@example.test',
                    'phone': '123',
                    'cpf': '456',
                    'birthDate': '2000-01-01',
                    'address': 'Rua A',
                    'isAdmin': false,
                    'active': true,
                    'createdAt': '2026-01-01T00:00:00',
                    'updatedAt': '2026-01-01T00:00:00',
                  },
                ],
                total: 1,
              ),
            ),
          ),
          200,
        );
      }),
    );
    client.setToken('test-token');
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(LoansPage(apiClient: client)));
    await tester.pumpAndSettle();

    expect(find.text('A Biblioteca'), findsOneWidget);
    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('4'), findsNWidgets(2));
    expect(find.text('2'), findsOneWidget);
    expect(find.text('10'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });
}
