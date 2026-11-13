import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/auth/widgets/admin_login_form.dart';
import 'package:altis_library_mobile/modules/books/pages/books_page.dart';
import 'package:altis_library_mobile/modules/dashboard/pages/admin_dashboard_page.dart';
import 'package:altis_library_mobile/modules/loans/pages/loans_page.dart';
import 'package:altis_library_mobile/modules/publishers/pages/publishers_page.dart';
import 'package:altis_library_mobile/modules/tenant/pages/temporary_tenant_access_page.dart';
import 'package:altis_library_mobile/modules/users/pages/users_page.dart';
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

void main() {
  final adminModules = <String, Widget Function(ApiClient)>{
    'dashboard': (client) => AdminDashboardPage(apiClient: client),
    'users': (client) => UsersPage(apiClient: client),
    'publishers': (client) => PublishersPage(apiClient: client),
    'books': (client) => BooksPage(apiClient: client),
    'loans': (client) => LoansPage(apiClient: client),
  };

  for (final entry in adminModules.entries) {
    testWidgets('USER cannot open the administrative ${entry.key} module', (
      tester,
    ) async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('', 403);
        }),
      );
      client.setSession(token: 'user-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      await tester.pumpWidget(_app(entry.value(client)));
      await tester.pumpAndSettle();

      expect(find.text('Acesso administrativo'), findsOneWidget);
      expect(requests, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('ADMIN login keeps administrative access and sends credentials', (
    tester,
  ) async {
    http.Request? loginRequest;
    final client = ApiClient(
      client: MockClient((request) async {
        loginRequest = request;
        return http.Response(
          jsonEncode({'token': 'admin-jwt', 'role': 'ADMIN'}),
          200,
        );
      }),
    );
    var authenticated = false;
    addTearDown(client.dispose);

    await tester.pumpWidget(
      _app(
        Scaffold(
          body: AdminLoginForm(
            apiClient: client,
            onAuthenticated: () => authenticated = true,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField).at(0), 'admin@example.test');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(authenticated, isTrue);
    expect(client.hasAdminSession, isTrue);
    expect(client.hasUserSession, isFalse);
    expect(loginRequest?.method, 'POST');
    expect(loginRequest?.url.path, '/auth/login');
    expect(jsonDecode(loginRequest!.body), {
      'email': 'admin@example.test',
      'password': 'password',
    });
  });

  testWidgets('temporary tenant access accepts USER and clears session', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(
            jsonEncode({'token': 'user-jwt', 'role': 'USER'}),
            200,
          );
        }
        if (request.url.path == '/users/me') {
          return http.Response(
            jsonEncode({
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
            }),
            200,
          );
        }
        if (request.url.path == '/loans/my') {
          return http.Response(
            jsonEncode({
              'content': [],
              'totalElements': 0,
              'totalPages': 0,
              'number': 0,
              'size': 10,
              'first': true,
              'last': true,
              'empty': true,
            }),
            200,
          );
        }
        return http.Response('', 404);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TemporaryTenantAccessPage(apiClient: client)));
    await tester.enterText(find.byType(TextField).at(0), 'user@example.test');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(client.hasUserSession, isTrue);
    expect(client.hasAdminSession, isFalse);
    expect(find.text('Ana Silva'), findsOneWidget);

    await tester.tap(find.byTooltip('Encerrar sessão'));
    await tester.pumpAndSettle();

    expect(client.hasToken, isFalse);
    expect(client.role, isNull);
    expect(find.text('Acesso temporário do locatário'), findsWidgets);
  });

  testWidgets('an ADMIN module hides prior data when the role changes', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(UsersPage(apiClient: client)));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar os usuários.'), findsOneWidget);

    client.setSession(token: 'user-jwt', role: AppRole.user);
    await tester.pumpAndSettle();

    expect(find.text('Acesso administrativo'), findsOneWidget);
    expect(find.text('Não foi possível carregar os usuários.'), findsNothing);
  });
}
