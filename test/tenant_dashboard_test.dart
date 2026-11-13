import 'dart:async';
import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/loans/models/loan.dart';
import 'package:altis_library_mobile/modules/loans/services/loan_service.dart';
import 'package:altis_library_mobile/modules/tenant/pages/tenant_dashboard_page.dart';
import 'package:altis_library_mobile/modules/tenant/pages/temporary_tenant_access_page.dart';
import 'package:altis_library_mobile/modules/users/models/user.dart';
import 'package:altis_library_mobile/modules/users/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _userJson() => {
  'id': 42,
  'name': 'Ana Silva',
  'email': 'ana@example.test',
  'phone': '555-1234',
  'cpf': '12345678900',
  'birthDate': '2000-01-01',
  'address': 'Rua A',
  'isAdmin': false,
  'active': true,
  'createdAt': '2026-01-01T00:00:00',
  'updatedAt': '2026-01-01T00:00:00',
};

Map<String, dynamic> _loanJson(int id, String status) => {
  'id': id,
  'userId': 42,
  'bookId': 70 + id,
  'bookTitle': 'Livro $id',
  'loanDate': '2026-03-10',
  'returnDate': '2026-03-20',
  'returnedAt': status == 'RETURNED' || status == 'RETURNED_LATE'
      ? '2026-03-19T10:00:00'
      : null,
  'status': status,
  'observations': null,
};

Map<String, dynamic> _loansPage({
  int page = 0,
  int total = 4,
  List<Map<String, dynamic>>? content,
}) => {
  'content':
      content ??
      [
        _loanJson(1, 'PENDING'),
        _loanJson(2, 'OVERDUE'),
        _loanJson(3, 'RETURNED'),
        _loanJson(4, 'RETURNED_LATE'),
      ],
  'totalElements': total,
  'totalPages': total == 0 ? 0 : (total / 10).ceil(),
  'number': page,
  'size': 10,
  'numberOfElements': content?.length ?? 4,
  'first': page == 0,
  'last': total == 0 || page >= (total / 10).ceil() - 1,
  'empty': (content?.isEmpty ?? false) || total == 0,
};

http.Response _responseFor(
  http.Request request, {
  Map<String, dynamic>? loansResponse,
  bool failProfile = false,
  bool failLoans = false,
}) {
  if (request.url.path == '/users/me') {
    return failProfile
        ? http.Response('', 500)
        : http.Response(jsonEncode(_userJson()), 200);
  }
  if (request.url.path == '/loans/my') {
    return failLoans
        ? http.Response('', 500)
        : http.Response(
            jsonEncode(
              loansResponse ??
                  _loansPage(
                    page: int.parse(request.url.queryParameters['page']!),
                  ),
            ),
            200,
          );
  }
  return http.Response('', 404);
}

Widget _app(Widget home, {Locale locale = const Locale('pt')}) => MaterialApp(
  theme: AppTheme.lightTheme,
  locale: locale,
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
  test('profile and own-loans services use only personal endpoints', () async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return _responseFor(request);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    final profile = await UserService(client).getMyProfile();
    final loans = await LoanService(client).getMyLoans();

    expect(profile, isA<User>());
    expect(profile.name, 'Ana Silva');
    expect(profile.email, 'ana@example.test');
    expect(loans.content, hasLength(4));
    expect(loans.content.last.status, LoanStatus.returnedLate);
    expect(requests.map((request) => request.url.path), [
      '/users/me',
      '/loans/my',
    ]);
    expect(requests.every((request) => request.method == 'GET'), isTrue);
    expect(
      requests.every(
        (request) => request.headers['authorization'] == 'Bearer user-jwt',
      ),
      isTrue,
    );
    expect(requests.last.url.queryParameters, {
      'page': '0',
      'size': '10',
      'sortBy': 'id',
      'sortDirection': 'DESC',
    });
  });

  testWidgets('dashboard displays personal profile, totals and loan statuses', (
    tester,
  ) async {
    for (final width in [360.0, 1000.0]) {
      tester.view.physicalSize = Size(width, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return _responseFor(request);
        }),
      );
      client.setSession(token: 'user-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      await tester.pumpWidget(
        _app(
          TemporaryTenantAccessPage(key: ValueKey(width), apiClient: client),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ana Silva'), findsOneWidget);
      expect(find.textContaining('ana@example.test'), findsOneWidget);
      expect(find.textContaining('555-1234'), findsOneWidget);
      expect(find.text('Total de empréstimos'), findsOneWidget);
      expect(find.text('4'), findsWidgets);
      expect(find.text('Empréstimos nesta página'), findsOneWidget);
      for (final status in [
        'Pendente',
        'Atrasado',
        'Devolvido',
        'Devolvido com atraso',
      ]) {
        expect(find.text(status), findsOneWidget);
      }
      expect(find.text('Devolvido em: 2026-03-19T10:00:00'), findsNWidgets(2));
      expect(requests.map((request) => request.url.path).toSet(), {
        '/users/me',
        '/loans/my',
      });
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('loan statuses are translated in English and Spanish', (
    tester,
  ) async {
    final translations = {
      'en': ['Pending', 'Overdue', 'Returned', 'Returned late'],
      'es': ['Pendiente', 'Atrasado', 'Devuelto', 'Devuelto con retraso'],
    };

    for (final entry in translations.entries) {
      final client = ApiClient(
        client: MockClient((request) async => _responseFor(request)),
      );
      client.setSession(token: 'user-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      await tester.pumpWidget(
        _app(
          TemporaryTenantAccessPage(
            key: ValueKey(entry.key),
            apiClient: client,
          ),
          locale: Locale(entry.key),
        ),
      );
      await tester.pumpAndSettle();

      for (final label in entry.value) {
        expect(find.text(label), findsOneWidget);
      }
    }
  });

  testWidgets('temporary USER login opens the dashboard with personal data', (
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
        return _responseFor(request);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TemporaryTenantAccessPage(apiClient: client)));
    await tester.enterText(find.byType(TextField).at(0), 'ana@example.test');
    await tester.enterText(find.byType(TextField).at(1), 'password');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(client.hasUserSession, isTrue);
    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('Meus empréstimos'), findsOneWidget);
  });

  testWidgets('ADMIN and token-only sessions cannot read tenant data', (
    tester,
  ) async {
    for (final session in [
      (token: 'admin-jwt', role: AppRole.admin),
      (token: 'unclassified-jwt', role: null),
    ]) {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('', 403);
        }),
      );
      if (session.role != null) {
        client.setSession(token: session.token, role: session.role!);
      } else {
        client.setToken(session.token);
      }
      addTearDown(client.dispose);

      await tester.pumpWidget(_app(TenantDashboardPage(apiClient: client)));
      await tester.pumpAndSettle();

      expect(find.text('Acesso temporário do locatário'), findsWidgets);
      expect(requests, isEmpty);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('dashboard handles empty loans and refresh retry after failure', (
    tester,
  ) async {
    var shouldFail = true;
    var requestCount = 0;
    final client = ApiClient(
      client: MockClient((request) async {
        requestCount++;
        if (shouldFail) return http.Response('', 500);
        return _responseFor(
          request,
          loansResponse: _loansPage(total: 0, content: []),
        );
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TemporaryTenantAccessPage(apiClient: client)));
    await tester.pumpAndSettle();

    expect(
      find.text('Não foi possível carregar seu perfil e empréstimos.'),
      findsOneWidget,
    );
    shouldFail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('Você não possui empréstimos.'), findsOneWidget);
    expect(find.text('Total de empréstimos'), findsOneWidget);
    expect(find.text('0'), findsWidgets);
    expect(requestCount, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard pagination loads the next personal loans page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final requestedPages = <String>[];
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/loans/my') {
          final page = request.url.queryParameters['page']!;
          requestedPages.add(page);
          if (page == '1') {
            return http.Response(
              jsonEncode(
                _loansPage(
                  page: 1,
                  total: 11,
                  content: [_loanJson(11, 'OVERDUE')],
                ),
              ),
              200,
            );
          }
          return http.Response(jsonEncode(_loansPage(page: 0, total: 11)), 200);
        }
        return _responseFor(request);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TemporaryTenantAccessPage(apiClient: client)));
    await tester.pumpAndSettle();
    expect(find.text('Página 1 de 2'), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Próxima página'));
    await tester.tap(find.byTooltip('Próxima página'));
    await tester.pumpAndSettle();

    expect(find.text('Página 2 de 2'), findsOneWidget);
    expect(find.text('Livro 11'), findsOneWidget);
    expect(requestedPages, ['0', '1']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('refresh reloads profile and personal loan totals', (
    tester,
  ) async {
    var profileVersion = 0;
    var personalRequests = 0;
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/users/me') {
          profileVersion++;
          final json = _userJson();
          json['name'] = profileVersion == 1 ? 'Ana Silva' : 'Ana Atualizada';
          return http.Response(jsonEncode(json), 200);
        }
        if (request.url.path == '/loans/my') {
          personalRequests++;
          return http.Response(
            jsonEncode(_loansPage(total: personalRequests == 1 ? 4 : 7)),
            200,
          );
        }
        return http.Response('', 404);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TemporaryTenantAccessPage(apiClient: client)));
    await tester.pumpAndSettle();
    expect(find.text('Ana Silva'), findsOneWidget);

    await tester.tap(find.byTooltip('Atualizar dashboard'));
    await tester.pumpAndSettle();

    expect(find.text('Ana Atualizada'), findsOneWidget);
    expect(find.text('7'), findsWidgets);
    expect(profileVersion, 2);
    expect(personalRequests, 2);
  });

  testWidgets('dashboard shows loading until personal requests complete', (
    tester,
  ) async {
    final response = Completer<void>();
    final client = ApiClient(
      client: MockClient((request) async {
        await response.future;
        return _responseFor(request);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TemporaryTenantAccessPage(apiClient: client)));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    response.complete();
    await tester.pumpAndSettle();
    expect(find.text('Ana Silva'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard logout clears the session and hides personal data', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((request) async => _responseFor(request)),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TemporaryTenantAccessPage(apiClient: client)));
    await tester.pumpAndSettle();
    expect(find.text('Ana Silva'), findsOneWidget);

    await tester.tap(find.byTooltip('Encerrar sessão'));
    await tester.pumpAndSettle();

    expect(client.hasToken, isFalse);
    expect(client.role, isNull);
    expect(find.text('Acesso temporário do locatário'), findsWidgets);
    expect(find.text('Ana Silva'), findsNothing);
  });
}
