import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/tenant/pages/tenant_dashboard_page.dart';
import 'package:altis_library_mobile/modules/tenant/pages/tenant_password_page.dart';
import 'package:altis_library_mobile/modules/tenant/pages/tenant_profile_page.dart';
import 'package:altis_library_mobile/modules/users/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> _profile({String name = 'Ana Silva'}) => {
  'id': 42,
  'name': name,
  'email': 'ana@example.test',
  'phone': '555-1234',
  'cpf': '12345678900',
  'birthDate': '2000-01-01',
  'address': 'Rua A, 10',
  'isAdmin': false,
  'active': true,
  'createdAt': '2026-01-01T00:00:00',
  'updatedAt': '2026-01-01T00:00:00',
};

Map<String, dynamic> _loansPage() => {
  'content': [],
  'totalElements': 0,
  'totalPages': 0,
  'number': 0,
  'size': 10,
  'first': true,
  'last': true,
  'empty': true,
};

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
  test(
    'profile and password PATCH use the documented routes and payloads',
    () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('', 200);
        }),
      );
      client.setSession(token: 'user-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      final service = UserService(client);
      await service.updateMyProfile(
        name: 'Ana Maria',
        email: 'ana.maria@example.test',
        phone: '555-9999',
        address: 'Rua B, 20',
      );
      await service.changeMyPassword(
        currentPassword: 'current-secret',
        newPassword: 'new-secret',
        confirmPassword: 'new-secret',
      );

      expect(requests.map((request) => request.method), ['PATCH', 'PATCH']);
      expect(requests.map((request) => request.url.path), [
        '/users/me',
        '/users/me/password',
      ]);
      expect(
        requests.every(
          (request) => request.headers['authorization'] == 'Bearer user-jwt',
        ),
        isTrue,
      );
      expect(jsonDecode(requests[0].body), {
        'name': 'Ana Maria',
        'email': 'ana.maria@example.test',
        'phone': '555-9999',
        'address': 'Rua B, 20',
      });
      expect(jsonDecode(requests[1].body), {
        'currentPassword': 'current-secret',
        'newPassword': 'new-secret',
        'confirmPassword': 'new-secret',
      });
    },
  );

  test('write errors retain status without exposing response bodies', () async {
    for (final statusCode in [400, 409, 500]) {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response('private backend detail', statusCode),
        ),
      );
      client.setSession(token: 'user-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      await expectLater(
        UserService(client).updateMyProfile(
          name: 'Ana',
          email: 'ana@example.test',
          phone: '555',
          address: 'Rua A',
        ),
        throwsA(
          isA<UserRequestException>().having(
            (error) => error.statusCode,
            'statusCode',
            statusCode,
          ),
        ),
      );
    }
  });

  testWidgets(
    'profile form loads own fields, validates and saves successfully',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      var profileUpdated = false;
      final patchBodies = <Map<String, dynamic>>[];
      final client = ApiClient(
        client: MockClient((request) async {
          if (request.method == 'GET' && request.url.path == '/users/me') {
            return http.Response(
              jsonEncode(
                _profile(name: profileUpdated ? 'Ana Maria' : 'Ana Silva'),
              ),
              200,
            );
          }
          if (request.method == 'GET' && request.url.path == '/loans/my') {
            return http.Response(jsonEncode(_loansPage()), 200);
          }
          if (request.method == 'PATCH' && request.url.path == '/users/me') {
            patchBodies.add(jsonDecode(request.body) as Map<String, dynamic>);
            profileUpdated = true;
            return http.Response('', 200);
          }
          return http.Response('', 404);
        }),
      );
      client.setSession(token: 'user-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      await tester.pumpWidget(_app(TenantDashboardPage(apiClient: client)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar perfil'));
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('tenant-profile-name')),
            )
            .controller!
            .text,
        'Ana Silva',
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(const ValueKey('tenant-profile-cpf')),
                matching: find.byType(TextField),
              ),
            )
            .readOnly,
        isTrue,
      );
      expect(
        tester
            .widget<TextField>(
              find.descendant(
                of: find.byKey(const ValueKey('tenant-profile-birth-date')),
                matching: find.byType(TextField),
              ),
            )
            .readOnly,
        isTrue,
      );

      await tester.enterText(
        find.byKey(const ValueKey('tenant-profile-name')),
        '',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tenant-profile-email')),
        'invalid-email',
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('tenant-profile-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('tenant-profile-submit')));
      await tester.pumpAndSettle();

      expect(find.text('Campo obrigatório.'), findsOneWidget);
      expect(find.text('Informe um e-mail válido.'), findsOneWidget);
      expect(patchBodies, isEmpty);

      await tester.enterText(
        find.byKey(const ValueKey('tenant-profile-name')),
        'Ana Maria',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tenant-profile-email')),
        'ana.maria@example.test',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tenant-profile-phone')),
        '555-9999',
      );
      await tester.enterText(
        find.byKey(const ValueKey('tenant-profile-address')),
        'Rua B, 20',
      );
      await tester.tap(find.text('Salvar'));
      await tester.pumpAndSettle();

      expect(patchBodies, [
        {
          'name': 'Ana Maria',
          'email': 'ana.maria@example.test',
          'phone': '555-9999',
          'address': 'Rua B, 20',
        },
      ]);
      expect(find.text('Ana Maria'), findsOneWidget);
      expect(find.text('Perfil atualizado com sucesso.'), findsOneWidget);
    },
  );

  testWidgets('profile conflict is shown as a conflict, not a save success', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.method == 'GET' && request.url.path == '/users/me') {
          return http.Response(jsonEncode(_profile()), 200);
        }
        if (request.method == 'GET' && request.url.path == '/loans/my') {
          return http.Response(jsonEncode(_loansPage()), 200);
        }
        if (request.method == 'PATCH' && request.url.path == '/users/me') {
          return http.Response('conflict', 409);
        }
        return http.Response('', 404);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TenantDashboardPage(apiClient: client)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(
      find.byKey(const ValueKey('tenant-profile-submit')),
    );
    await tester.tap(find.byKey(const ValueKey('tenant-profile-submit')));
    await tester.pumpAndSettle();

    expect(find.text('Já existe um perfil com esse e-mail.'), findsOneWidget);
    expect(find.text('Perfil atualizado com sucesso.'), findsNothing);
  });

  testWidgets('password form validates confirmation and accepts empty 200', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    http.Request? passwordRequest;
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/users/me') {
          return http.Response(jsonEncode(_profile()), 200);
        }
        if (request.url.path == '/loans/my') {
          return http.Response(jsonEncode(_loansPage()), 200);
        }
        if (request.method == 'PATCH' &&
            request.url.path == '/users/me/password') {
          passwordRequest = request;
          return http.Response('', 200);
        }
        return http.Response('', 404);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TenantDashboardPage(apiClient: client)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alterar senha'));
    await tester.pumpAndSettle();

    final fields = [
      find.byKey(const ValueKey('tenant-current-password')),
      find.byKey(const ValueKey('tenant-new-password')),
      find.byKey(const ValueKey('tenant-confirm-password')),
    ];
    for (final field in fields) {
      expect(
        tester
            .widget<TextField>(
              find.descendant(of: field, matching: find.byType(TextField)),
            )
            .obscureText,
        isTrue,
      );
    }

    await tester.tap(find.byKey(const ValueKey('tenant-password-submit')));
    await tester.pumpAndSettle();
    expect(find.text('Campo obrigatório.'), findsNWidgets(3));
    expect(passwordRequest, isNull);

    await tester.enterText(fields[0], 'current-secret');
    await tester.enterText(fields[1], 'short');
    await tester.enterText(fields[2], 'short');
    await tester.tap(find.byKey(const ValueKey('tenant-password-submit')));
    await tester.pumpAndSettle();
    expect(
      find.text('A senha deve ter pelo menos 8 caracteres.'),
      findsOneWidget,
    );
    expect(passwordRequest, isNull);

    await tester.enterText(fields[1], 'new-secret-123');
    await tester.enterText(fields[2], 'different-secret');
    await tester.tap(find.byKey(const ValueKey('tenant-password-submit')));
    await tester.pumpAndSettle();

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
    expect(passwordRequest, isNull);

    await tester.enterText(fields[2], 'new-secret-123');
    await tester.tap(find.byKey(const ValueKey('tenant-password-submit')));
    await tester.pumpAndSettle();

    expect(passwordRequest?.url.path, '/users/me/password');
    expect(jsonDecode(passwordRequest!.body), {
      'currentPassword': 'current-secret',
      'newPassword': 'new-secret-123',
      'confirmPassword': 'new-secret-123',
    });
    expect(find.text('Senha alterada com sucesso.'), findsOneWidget);
    expect(find.text('current-secret'), findsNothing);
    expect(find.text('new-secret-123'), findsNothing);
  });

  testWidgets('password backend errors are shown without response details', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/users/me') {
          return http.Response(jsonEncode(_profile()), 200);
        }
        if (request.url.path == '/loans/my') {
          return http.Response(jsonEncode(_loansPage()), 200);
        }
        if (request.method == 'PATCH' &&
            request.url.path == '/users/me/password') {
          return http.Response('private backend detail', 403);
        }
        return http.Response('', 404);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(TenantDashboardPage(apiClient: client)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alterar senha'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('tenant-current-password')),
      'current-secret',
    );
    await tester.enterText(
      find.byKey(const ValueKey('tenant-new-password')),
      'new-secret-123',
    );
    await tester.enterText(
      find.byKey(const ValueKey('tenant-confirm-password')),
      'new-secret-123',
    );
    await tester.tap(find.byKey(const ValueKey('tenant-password-submit')));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Não foi possível alterar a senha. Confira a senha atual e tente novamente.',
      ),
      findsOneWidget,
    );
    expect(find.text('private backend detail'), findsNothing);
    final passwordFields = tester
        .widgetList<EditableText>(find.byType(EditableText))
        .where((field) => field.obscureText);
    expect(passwordFields, hasLength(3));
  });

  testWidgets(
    'profile connection failure is reported without exposing details',
    (tester) async {
      final client = ApiClient(
        client: MockClient((request) async {
          if (request.method == 'GET' && request.url.path == '/users/me') {
            return http.Response(jsonEncode(_profile()), 200);
          }
          if (request.method == 'GET' && request.url.path == '/loans/my') {
            return http.Response(jsonEncode(_loansPage()), 200);
          }
          if (request.method == 'PATCH' && request.url.path == '/users/me') {
            throw http.ClientException('private connection detail');
          }
          return http.Response('', 404);
        }),
      );
      client.setSession(token: 'user-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      await tester.pumpWidget(_app(TenantDashboardPage(apiClient: client)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar perfil'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('tenant-profile-submit')),
      );
      await tester.tap(find.byKey(const ValueKey('tenant-profile-submit')));
      await tester.pumpAndSettle();

      expect(
        find.text('Não foi possível conectar à API. Verifique a conexão.'),
        findsOneWidget,
      );
      expect(find.text('private connection detail'), findsNothing);
    },
  );

  testWidgets('both forms reject ADMIN sessions without making requests', (
    tester,
  ) async {
    for (final page in [
      (
        name: 'profile',
        widget: (ApiClient client) => TenantProfilePage(apiClient: client),
      ),
      (
        name: 'password',
        widget: (ApiClient client) => TenantPasswordPage(apiClient: client),
      ),
    ]) {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('', 403);
        }),
      );
      client.setSession(token: 'admin-jwt', role: AppRole.admin);
      addTearDown(client.dispose);

      await tester.pumpWidget(_app(page.widget(client)));
      await tester.pumpAndSettle();

      expect(
        find.text('Esta tela está disponível somente para usuários.'),
        findsOneWidget,
      );
      expect(requests, isEmpty, reason: page.name);
    }
  });
}
