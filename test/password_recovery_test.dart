import 'dart:async';
import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/main.dart';
import 'package:altis_library_mobile/modules/auth/pages/password_recovery_page.dart';
import 'package:altis_library_mobile/modules/auth/services/password_recovery_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget _app(ApiClient client, {Locale locale = const Locale('pt')}) =>
    MyApp(apiClient: client, locale: locale);

http.Response _jsonResponse(Map<String, dynamic> body, int statusCode) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _enterTextVisible(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.ensureVisible(finder);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

Future<void> _openRecovery(WidgetTester tester, ApiClient client) async {
  await tester.pumpWidget(_app(client));
  await tester.pumpAndSettle();
  await _tapVisible(tester, find.text('Recuperar senha?'));
  await _enterIdentity(tester);
}

Future<void> _enterIdentity(
  WidgetTester tester, {
  String email = 'ana@example.test',
  String cpf = '52998224725',
}) async {
  await _enterTextVisible(
    tester,
    find.byKey(const ValueKey('recovery-email')),
    email,
  );
  await _enterTextVisible(
    tester,
    find.byKey(const ValueKey('recovery-cpf')),
    cpf,
  );
}

Future<void> _verify(WidgetTester tester) =>
    _tapVisible(tester, find.text('Confirmar'));

Future<void> _enterPasswords(
  WidgetTester tester, {
  String password = 'nova-senha',
  String confirmation = 'nova-senha',
}) async {
  await _enterTextVisible(
    tester,
    find.byKey(const ValueKey('recovery-password')),
    password,
  );
  await _enterTextVisible(
    tester,
    find.byKey(const ValueKey('recovery-confirm-password')),
    confirmation,
  );
}

bool _isObscured(WidgetTester tester, String key) => tester
    .widget<EditableText>(
      find.descendant(
        of: find.byKey(ValueKey(key)),
        matching: find.byType(EditableText),
      ),
    )
    .obscureText;

void main() {
  test('service preserves ApiErrorResponse message', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => _jsonResponse({'message': 'Dados não conferem.'}, 400),
      ),
    );
    addTearDown(client.dispose);

    await expectLater(
      PasswordRecoveryService(client)
          .verify(email: 'ana@example.test', cpf: '52998224725'),
      throwsA(
        isA<PasswordRecoveryException>().having(
          (error) => error.message,
          'message',
          'Dados não conferem.',
        ),
      ),
    );
  });

  testWidgets('verify posts email and CPF without a bearer token', (
    tester,
  ) async {
    http.Request? sentRequest;
    final client = ApiClient(
      client: MockClient((request) async {
        sentRequest = request;
        return http.Response('', 204);
      }),
    );
    client.setToken('fictional-test-token');
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    await _verify(tester);

    expect(sentRequest!.url.path, '/auth/password-recovery/verify');
    expect(sentRequest!.method, 'POST');
    expect(jsonDecode(sentRequest!.body), {
      'email': 'ana@example.test',
      'cpf': '52998224725',
    });
    expect(sentRequest!.headers.containsKey('authorization'), isFalse);
    expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('verify 204 reveals password fields on the same page', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 204)),
    );
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    final recoveryPage = find.byType(PasswordRecoveryPage);
    await _verify(tester);

    expect(recoveryPage, findsOneWidget);
    expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recovery-confirm-password')),
      findsOneWidget,
    );
    expect(find.text('Redefinir senha'), findsOneWidget);
  });

  testWidgets(
    'verify 400 displays backend message and keeps passwords hidden',
    (tester) async {
      var requestCount = 0;
      final client = ApiClient(
        client: MockClient((_) async {
          requestCount++;
          return _jsonResponse({'message': 'Dados não conferem.'}, 400);
        }),
      );
      addTearDown(client.dispose);

      await _openRecovery(tester, client);
      await _verify(tester);

      expect(requestCount, 1);
      expect(find.byKey(const ValueKey('recovery-error')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('recovery-error'))).data,
        'Dados não conferem.',
      );
      expect(find.byKey(const ValueKey('recovery-password')), findsNothing);
      expect(
        find.byKey(const ValueKey('recovery-confirm-password')),
        findsNothing,
      );
    },
  );

  testWidgets('reset posts verified identity and passwords publicly', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('', 204);
      }),
    );
    client.setToken('fictional-test-token');
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    await _verify(tester);
    await _enterPasswords(tester);
    await _tapVisible(tester, find.text('Redefinir senha'));

    expect(requests, hasLength(2));
    final resetRequest = requests.last;
    expect(resetRequest.url.path, '/auth/password-recovery/reset');
    expect(resetRequest.method, 'POST');
    expect(jsonDecode(resetRequest.body), {
      'email': 'ana@example.test',
      'cpf': '52998224725',
      'newPassword': 'nova-senha',
      'confirmPassword': 'nova-senha',
    });
    expect(resetRequest.headers.containsKey('authorization'), isFalse);
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(
      find.text('Senha redefinida com sucesso. Faça login para continuar.'),
      findsOneWidget,
    );
    expect(client.hasToken, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('divergent passwords prevent reset', (tester) async {
    var resetCount = 0;
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/reset')) resetCount++;
        return http.Response('', 204);
      }),
    );
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    await _verify(tester);
    await _enterPasswords(tester, confirmation: 'outra-senha');
    await _tapVisible(tester, find.text('Redefinir senha'));

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
    expect(resetCount, 0);
  });

  testWidgets('new and confirmation password visibility can be toggled', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 204)),
    );
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    await _verify(tester);
    await _enterPasswords(tester);

    expect(_isObscured(tester, 'recovery-password'), isTrue);
    expect(_isObscured(tester, 'recovery-confirm-password'), isTrue);

    await _tapVisible(tester, find.byTooltip('Mostrar senha').first);
    await _tapVisible(tester, find.byTooltip('Mostrar senha').first);
    expect(_isObscured(tester, 'recovery-password'), isFalse);
    expect(_isObscured(tester, 'recovery-confirm-password'), isFalse);
  });

  testWidgets('changing identity requires a new verify before reset', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('', 204);
      }),
    );
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    await _verify(tester);
    await _enterPasswords(tester);
    await _enterTextVisible(
      tester,
      find.byKey(const ValueKey('recovery-email')),
      'outra@example.test',
    );

    expect(find.byKey(const ValueKey('recovery-password')), findsNothing);
    expect(find.text('Confirmar'), findsOneWidget);
    await _verify(tester);
    await _enterPasswords(
      tester,
      password: 'senha-nova-2',
      confirmation: 'senha-nova-2',
    );
    await _tapVisible(tester, find.text('Redefinir senha'));

    expect(requests, hasLength(3));
    expect(jsonDecode(requests[1].body)['email'], 'outra@example.test');
    expect(jsonDecode(requests[2].body), {
      'email': 'outra@example.test',
      'cpf': '52998224725',
      'newPassword': 'senha-nova-2',
      'confirmPassword': 'senha-nova-2',
    });
  });

  testWidgets('network and HTTP errors are shown without revealing fields', (
    tester,
  ) async {
    final cases = [
      (
        response: null,
        throwsConnection: true,
        expected: 'Não foi possível conectar à API. Verifique sua conexão.',
      ),
      (
        response: _jsonResponse({
          'message': 'Falha de validação do backend.',
        }, 400),
        throwsConnection: false,
        expected: 'Falha de validação do backend.',
      ),
      (
        response: http.Response('', 503),
        throwsConnection: false,
        expected: 'Não foi possível verificar os dados. Tente novamente.',
      ),
    ];

    for (final testCase in cases) {
      await tester.pumpWidget(const SizedBox.shrink());
      final client = ApiClient(
        client: MockClient((_) async {
          if (testCase.throwsConnection) {
            throw http.ClientException('network unavailable');
          }
          return testCase.response!;
        }),
      );
      addTearDown(client.dispose);

      await _openRecovery(tester, client);
      await _verify(tester);
      expect(find.text(testCase.expected), findsOneWidget);
      expect(find.byKey(const ValueKey('recovery-password')), findsNothing);
    }
  });

  testWidgets('reset errors show backend message and keep the form available', (
    tester,
  ) async {
    var resetCount = 0;
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path.endsWith('/reset')) {
          resetCount++;
          if (resetCount == 1) {
            return _jsonResponse({
              'message': 'Senha recusada pelo servidor.',
            }, 400);
          }
          if (resetCount == 2) return http.Response('', 503);
          throw http.ClientException('network unavailable');
        }
        return http.Response('', 204);
      }),
    );
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    await _verify(tester);
    await _enterPasswords(tester);
    await _tapVisible(tester, find.text('Redefinir senha'));

    expect(resetCount, 1);
    expect(find.text('Senha recusada pelo servidor.'), findsOneWidget);
    expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);

    await _tapVisible(tester, find.text('Redefinir senha'));
    expect(
      find.text('Não foi possível redefinir a senha. Tente novamente.'),
      findsOneWidget,
    );
    await _tapVisible(tester, find.text('Redefinir senha'));
    expect(
      find.text('Não foi possível conectar à API. Verifique sua conexão.'),
      findsOneWidget,
    );
    expect(resetCount, 3);
  });

  testWidgets('duplicate verify and reset submissions are disabled', (
    tester,
  ) async {
    final verifyResponse = Completer<http.Response>();
    var requestCount = 0;
    final client = ApiClient(
      client: MockClient((request) {
        requestCount++;
        return request.url.path.endsWith('/verify')
            ? verifyResponse.future
            : Future.value(http.Response('', 204));
      }),
    );
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    final verifyButton = find.byKey(const ValueKey('recovery-submit'));
    await tester.ensureVisible(verifyButton);
    await tester.tap(verifyButton);
    await tester.pump();

    expect(requestCount, 1);
    expect(tester.widget<FilledButton>(verifyButton).onPressed, isNull);
    verifyResponse.complete(http.Response('', 204));
    await tester.pumpAndSettle();

    final resetResponse = Completer<http.Response>();
    var duplicatePhaseRequestCount = 0;
    final resetClient = ApiClient(
      client: MockClient((request) {
        duplicatePhaseRequestCount++;
        return duplicatePhaseRequestCount == 1
            ? Future.value(http.Response('', 204))
            : resetResponse.future;
      }),
    );
    addTearDown(resetClient.dispose);
    await tester.pumpWidget(const SizedBox.shrink());
    await _openRecovery(tester, resetClient);
    await _verify(tester);
    await _enterPasswords(tester);

    final resetButton = find.byKey(const ValueKey('recovery-submit'));
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pump();
    expect(tester.widget<FilledButton>(resetButton).onPressed, isNull);
    expect(duplicatePhaseRequestCount, 2);
    resetResponse.complete(http.Response('', 204));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('ADMIN gets informational response without password fields', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient(
        (_) async => _jsonResponse({
          'message': 'Não é permitido alterar a senha do administrador por este fluxo.',
        }, 400),
      ),
    );
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    await _verify(tester);

    expect(
      find.byKey(const ValueKey('recovery-admin-blocked')),
      findsOneWidget,
    );
    expect(find.text('Voltar ao login'), findsWidgets);
    expect(find.byKey(const ValueKey('recovery-password')), findsNothing);
    expect(
      find.text(
        'Não é permitido alterar a senha do administrador por este fluxo.',
      ),
      findsNothing,
    );
    await _tapVisible(
      tester,
      find.widgetWithText(FilledButton, 'Voltar ao login'),
    );
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
  });

  testWidgets('ADMIN reset rejection hides password fields and values', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/verify')) {
          return http.Response('', 204);
        }
        return _jsonResponse({
          'message': 'Não é permitido alterar a senha do administrador por este fluxo.',
        }, 400);
      }),
    );
    addTearDown(client.dispose);

    await _openRecovery(tester, client);
    await _verify(tester);
    await _enterPasswords(tester);
    await _tapVisible(tester, find.text('Redefinir senha'));

    expect(requests, hasLength(2));
    expect(
      find.byKey(const ValueKey('recovery-admin-blocked')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('recovery-password')), findsNothing);
    expect(
      find.byKey(const ValueKey('recovery-confirm-password')),
      findsNothing,
    );
    expect(find.text('Voltar ao login'), findsWidgets);
  });

  testWidgets('recovery remains localized in Portuguese, English and Spanish', (
    tester,
  ) async {
    const labels = {
      'pt': ['Recuperar senha', 'CPF'],
      'en': ['Recover password', 'CPF'],
      'es': ['Recuperar contraseña', 'CPF'],
    };

    for (final entry in labels.entries) {
      final client = ApiClient(
        client: MockClient((_) async => http.Response('', 204)),
      );
      addTearDown(client.dispose);

      await tester.pumpWidget(
        MaterialApp(
          locale: Locale(entry.key),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PasswordRecoveryPage(apiClient: client),
        ),
      );
      await tester.pumpAndSettle();
      for (final label in entry.value) {
        expect(find.text(label), findsOneWidget);
      }

      await _enterIdentity(tester);
      await _tapVisible(tester, find.byKey(const ValueKey('recovery-submit')));
      expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);
      expect(
        find.text(
          entry.key == 'en'
              ? 'Confirm password'
              : entry.key == 'es'
              ? 'Confirmar contraseña'
              : 'Confirmar senha',
        ),
        findsOneWidget,
      );
    }
  });

  testWidgets('recovery validates required identity and CPF locally', (
    tester,
  ) async {
    var requests = 0;
    final client = ApiClient(
      client: MockClient((_) async {
        requests++;
        return http.Response('', 204);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Recuperar senha?'));
    await _verify(tester);

    expect(find.text('Campo obrigatório.'), findsNWidgets(2));
    expect(requests, 0);

    await _enterTextVisible(
      tester,
      find.byKey(const ValueKey('recovery-email')),
      'invalid-email',
    );
    await _enterTextVisible(
      tester,
      find.byKey(const ValueKey('recovery-cpf')),
      '12345678900',
    );
    await _verify(tester);
    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('Informe um CPF válido.'), findsOneWidget);
    expect(requests, 0);
  });
}
