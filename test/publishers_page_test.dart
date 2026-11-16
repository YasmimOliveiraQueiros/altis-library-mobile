import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/publishers/pages/publishers_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _publisher(int id, String name) => {
  'id': id,
  'name': name,
  'email': 'editora@example.test',
  'cnpj': '12345678000199',
  'city': 'São Paulo',
  'state': 'SP',
  'bookCount': 0,
  'status': 'ACTIVE',
};

Map<String, dynamic> _page({
  required int number,
  required int totalElements,
  required int totalPages,
  required List<Map<String, dynamic>> content,
}) => {
  'content': content,
  'totalElements': totalElements,
  'totalPages': totalPages,
  'number': number,
  'size': 10,
  'first': number == 0,
  'last': number >= totalPages - 1,
  'empty': content.isEmpty,
};

Widget _app(ApiClient apiClient) => MaterialApp(
  theme: AppTheme.lightTheme,
  locale: const Locale('pt'),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: PublishersPage(apiClient: apiClient),
);

void main() {
  testWidgets(
    'publisher sorting is sent and deletion falls back to prior page',
    (tester) async {
      final requests = <http.Request>[];
      var deletionRequested = false;
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          if (request.method == 'DELETE') {
            deletionRequested = true;
            return http.Response('', 204);
          }

          final page = int.parse(request.url.queryParameters['page']!);
          final totalElements = deletionRequested ? 10 : 11;
          final totalPages = deletionRequested ? 1 : 2;
          final content = page == 1
              ? deletionRequested
                    ? <Map<String, dynamic>>[]
                    : [_publisher(11, 'Última editora')]
              : [_publisher(1, 'Editora inicial')];
          return http.Response.bytes(
            utf8.encode(
              jsonEncode(
                _page(
                  number: page,
                  totalElements: totalElements,
                  totalPages: totalPages,
                  content: content,
                ),
              ),
            ),
            200,
          );
        }),
      );
      client.setSession(token: 'test-token', role: AppRole.admin);
      addTearDown(client.dispose);

      await tester.pumpWidget(_app(client));
      await tester.pumpAndSettle();
      final l10n = AppLocalizations.of(
        tester.element(find.byType(PublishersPage)),
      )!;

      await tester.tap(find.byTooltip(l10n.sortAscending));
      await tester.pumpAndSettle();
      expect(requests[1].url.queryParameters['sortBy'], 'id');
      expect(requests[1].url.queryParameters['sortDirection'], 'ASC');

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pumpAndSettle();
      expect(find.text('Última editora'), findsOneWidget);

      await tester.tap(find.byTooltip(l10n.deletePublisher));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, l10n.confirm));
      await tester.pumpAndSettle();

      expect(find.text('Editora inicial'), findsOneWidget);
      expect(find.text('Última editora'), findsNothing);
      final requestedPages = requests
          .where((request) => request.method == 'GET')
          .map((request) => request.url.queryParameters['page'])
          .toList();
      expect(requestedPages, ['0', '0', '1', '1', '0']);
      expect(tester.takeException(), isNull);
    },
  );
}
