import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/services/routes/app_routes.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/main.dart';
import 'package:altis_library_mobile/modules/auth/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

http.Response _userProfileResponse() => http.Response(
  jsonEncode({
    'id': 42,
    'name': 'Ana Silva',
    'email': 'ana@example.test',
    'phone': '555-1234',
    'cpf': '123',
    'birthDate': '2000-01-01',
    'address': 'Rua A',
    'isAdmin': false,
    'active': true,
    'createdAt': '2026-01-01T00:00:00',
    'updatedAt': '2026-01-01T00:00:00',
  }),
  200,
);

http.Response _emptyLoansResponse() => http.Response(
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

Widget _localizedLogin(ApiClient client, Locale locale) => MaterialApp(
  locale: locale,
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  home: LoginPage(apiClient: client, onAuthenticated: () {}),
);

void main() {
  testWidgets('ADMIN login opens the administrative dashboard', (tester) async {
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/auth/login') {
          return http.Response(
            jsonEncode({'token': 'admin-jwt', 'role': 'ADMIN'}),
            200,
          );
        }
        return http.Response('', 500);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'admin@example.test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'secret',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(client.hasAdminSession, isTrue);
    expect(find.text('Visão geral do sistema'), findsOneWidget);
    expect(find.text('Bem-vindo de volta!'), findsNothing);
  });

  testWidgets('USER login opens the tenant dashboard', (tester) async {
    final requestPaths = <String>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requestPaths.add(request.url.path);
        if (request.url.path == '/auth/login') {
          return http.Response(
            jsonEncode({'token': 'user-jwt', 'role': 'USER'}),
            200,
          );
        }
        if (request.url.path == '/users/me') return _userProfileResponse();
        if (request.url.path == '/loans/my') return _emptyLoansResponse();
        return http.Response('', 404);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'ana@example.test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'secret',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(client.hasUserSession, isTrue);
    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.text('Meus empréstimos'), findsOneWidget);
    expect(requestPaths.where((path) => path == '/users/me').length, 1);
    expect(requestPaths.where((path) => path == '/loans/my').length, 1);
  });

  testWidgets('USER cannot open an administrative route', (tester) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        if (request.url.path == '/users/me') return _userProfileResponse();
        if (request.url.path == '/loans/my') return _emptyLoansResponse();
        return http.Response('', 403);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();
    tester
        .state<NavigatorState>(find.byType(Navigator))
        .pushNamed(AppRoutes.users);
    await tester.pumpAndSettle();

    expect(find.text('Acesso administrativo'), findsOneWidget);
    expect(requests.any((request) => request.url.path == '/users'), isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('protected 401 clears session and returns to Login', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 401)),
    );
    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();

    expect(client.hasToken, isFalse);
    expect(client.role, isNull);
    expect(client.sessionExpirations.value, 1);
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Sua sessão expirou. Entre novamente.'), findsOneWidget);
    expect(
      Navigator.of(tester.element(find.byType(LoginPage))).canPop(),
      isFalse,
    );

    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Visão geral do sistema'), findsNothing);
  });

  testWidgets('protected 403 shows access denied and preserves session', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 403)),
    );
    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Acesso negado. Você não tem permissão para esta ação.'),
      findsOneWidget,
    );
    expect(find.byType(LoginPage), findsNothing);
    expect(client.hasAdminSession, isTrue);
    expect(client.sessionExpirations.value, 0);
  });

  testWidgets('public login 401 does not show a session-expired notice', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 401)),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'ana@example.test',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'wrong-password',
    );
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('E-mail ou senha incorretos.'), findsOneWidget);
    expect(find.text('Sua sessão expirou. Entre novamente.'), findsNothing);
    expect(client.sessionExpirations.value, 0);
  });

  testWidgets('login form remains usable on a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(320, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Entrar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login labels are localized in Portuguese, English and Spanish', (
    tester,
  ) async {
    final translations = {
      'pt': ['Bem-vindo de volta!', 'Recuperar senha?', 'Realizar cadastro?'],
      'en': ['Welcome back!', 'Forgot password?', 'Create an account?'],
      'es': [
        '¡Bienvenido de nuevo!',
        '¿Olvidaste tu contraseña?',
        '¿Crear una cuenta?',
      ],
    };

    for (final entry in translations.entries) {
      final client = ApiClient(
        client: MockClient((_) async => http.Response('', 500)),
      );
      addTearDown(client.dispose);

      await tester.pumpWidget(_localizedLogin(client, Locale(entry.key)));
      await tester.pumpAndSettle();

      for (final label in entry.value) {
        expect(find.text(label), findsOneWidget);
      }
    }
  });
}
