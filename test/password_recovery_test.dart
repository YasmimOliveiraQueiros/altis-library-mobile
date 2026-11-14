import 'dart:convert';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/main.dart';
import 'package:altis_library_mobile/modules/auth/pages/password_recovery_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Widget _app(ApiClient client, {Locale locale = const Locale('pt')}) =>
    MyApp(apiClient: client, locale: locale);

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
}

void main() {
  testWidgets('recovery requires valid email and CPF and masks the CPF', (
    tester,
  ) async {
    var requestCount = 0;
    final client = ApiClient(
      client: MockClient((_) async {
        requestCount++;
        return http.Response('', 200);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Recuperar senha?'));

    await _tapVisible(tester, find.text('Confirmar'));
    expect(find.text('Campo obrigatório.'), findsNWidgets(2));
    expect(requestCount, 0);

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
    await _tapVisible(tester, find.text('Confirmar'));

    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('Informe um CPF válido.'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('recovery-cpf')))
          .controller!
          .text,
      '123.456.789-00',
    );
    expect(requestCount, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('successful verification retains identity and never resets', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('', 200);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Recuperar senha?'));
    await _enterTextVisible(
      tester,
      find.byKey(const ValueKey('recovery-email')),
      'ana@example.test',
    );
    await _enterTextVisible(
      tester,
      find.byKey(const ValueKey('recovery-cpf')),
      '52998224725',
    );
    await _tapVisible(tester, find.text('Confirmar'));

    expect(requests, hasLength(1));
    expect(requests.single.url.path, '/auth/password-recovery/verify');
    expect(requests.single.method, 'POST');
    expect(jsonDecode(requests.single.body), {
      'email': 'ana@example.test',
      'cpf': '52998224725',
    });
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('recovery-email')))
          .controller!
          .text,
      'ana@example.test',
    );
    expect(
      tester
          .widget<TextFormField>(find.byKey(const ValueKey('recovery-cpf')))
          .controller!
          .text,
      '529.982.247-25',
    );
    expect(find.byKey(const ValueKey('recovery-password')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('recovery-confirm-password')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('recovery-reset-blocked')),
      findsOneWidget,
    );
    expect(find.text('Administrador'), findsNothing);

    final confirmButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Confirmar'),
    );
    expect(confirmButton.onPressed, isNull);
    expect(
      requests.any((request) => request.url.path.endsWith('/reset')),
      isFalse,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('network and unexpected responses do not advance recovery', (
    tester,
  ) async {
    final cases = [
      (
        response: null,
        throwsConnection: true,
        expected: 'Não foi possível conectar à API. Verifique sua conexão.',
      ),
      (
        response: http.Response('unexpected', 200),
        throwsConnection: false,
        expected: 'A resposta da API é inválida.',
      ),
      (
        response: http.Response('', 500),
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

      await tester.pumpWidget(_app(client));
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.text('Recuperar senha?'));
      await _enterTextVisible(
        tester,
        find.byKey(const ValueKey('recovery-email')),
        'ana@example.test',
      );
      await _enterTextVisible(
        tester,
        find.byKey(const ValueKey('recovery-cpf')),
        '52998224725',
      );
      await _tapVisible(tester, find.text('Confirmar'));

      expect(find.text(testCase.expected), findsOneWidget);
      expect(find.byKey(const ValueKey('recovery-password')), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('recovery text is localized in Portuguese, English and Spanish', (
    tester,
  ) async {
    final labels = {
      'pt': ['Recuperar senha', 'CPF', 'Confirmar senha', 'Voltar ao login'],
      'en': ['Recover password', 'CPF', 'Confirm password', 'Back to sign in'],
      'es': [
        'Recuperar contraseña',
        'CPF',
        'Confirmar contraseña',
        'Volver al inicio de sesión',
      ],
    };

    for (final entry in labels.entries) {
      final client = ApiClient(
        client: MockClient((_) async => http.Response('', 200)),
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
      await _enterTextVisible(
        tester,
        find.byKey(const ValueKey('recovery-email')),
        'ana@example.test',
      );
      await _enterTextVisible(
        tester,
        find.byKey(const ValueKey('recovery-cpf')),
        '52998224725',
      );
      await _tapVisible(
        tester,
        find.text(entry.key == 'en' ? 'Confirm' : 'Confirmar'),
      );

      for (final label in entry.value) {
        expect(find.text(label), findsOneWidget);
      }
    }
  });

  testWidgets('recovery layout remains usable on a narrow viewport', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Recuperar senha?'));

    expect(find.text('Confirmar'), findsOneWidget);
    expect(find.text('Voltar ao login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
