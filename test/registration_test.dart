import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/main.dart';
import 'package:altis_library_mobile/modules/auth/pages/registration_page.dart';
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
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('registration renders every requested field and blocked submit', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));

    for (final field in [
      'registration-name',
      'registration-birth-date',
      'registration-cpf',
      'registration-phone',
      'registration-address',
      'registration-email',
      'registration-password',
      'registration-confirm-password',
    ]) {
      expect(find.byKey(ValueKey(field)), findsOneWidget);
    }

    expect(find.text('Cadastrar nova conta'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('registration-unavailable')),
      findsOneWidget,
    );
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Cadastrar'),
    );
    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('required fields and email format are validated locally', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));
    await _enterTextVisible(
      tester,
      find.byKey(const ValueKey('registration-email')),
      'email-invalido',
    );

    expect(find.text('Informe um e-mail válido.'), findsOneWidget);
    expect(find.text('Campo obrigatório.'), findsNWidgets(7));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'CPF and phone masks format digits without checking their rules',
    (tester) async {
      final client = ApiClient(
        client: MockClient((_) async => http.Response('', 500)),
      );
      addTearDown(client.dispose);

      await tester.pumpWidget(_app(client));
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.text('Realizar cadastro?'));
      await _enterTextVisible(
        tester,
        find.byKey(const ValueKey('registration-cpf')),
        '12345678901',
      );
      await _enterTextVisible(
        tester,
        find.byKey(const ValueKey('registration-phone')),
        '11987654321',
      );

      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('registration-cpf')),
            )
            .controller!
            .text,
        '123.456.789-01',
      );
      expect(
        tester
            .widget<TextFormField>(
              find.byKey(const ValueKey('registration-phone')),
            )
            .controller!
            .text,
        '(11) 98765-4321',
      );
    },
  );

  testWidgets('password confirmation and birth date are validated', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));
    await _enterTextVisible(
      tester,
      find.byKey(const ValueKey('registration-password')),
      'senha',
    );
    await _enterTextVisible(
      tester,
      find.byKey(const ValueKey('registration-confirm-password')),
      'outra',
    );

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('registration-birth-date')),
          )
          .validator!(null),
      'Campo obrigatório.',
    );

    await _tapVisible(
      tester,
      find.byKey(const ValueKey('registration-birth-date')),
    );
    await _tapVisible(tester, find.text('OK'));

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('registration-birth-date')),
          )
          .controller!
          .text,
      isNotEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('return action navigates back to login', (tester) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));
    await _tapVisible(tester, find.text('Voltar ao login'));

    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Cadastrar nova conta'), findsNothing);
  });

  testWidgets('blocked registration never sends requests', (tester) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('', 500);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));

    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Cadastrar'))
          .onPressed,
      isNull,
    );
    expect(requests, isEmpty);
    expect(
      find.text(
        'O cadastro está temporariamente indisponível: a API ainda não oferece um endpoint público de cadastro.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('registration is localized in Portuguese, English and Spanish', (
    tester,
  ) async {
    const labels = {
      'pt': ['Cadastrar nova conta', 'Nome completo', 'Cadastrar'],
      'en': ['Create a new account', 'Full name', 'Create account'],
      'es': ['Crear una cuenta nueva', 'Nombre completo', 'Crear cuenta'],
    };

    for (final entry in labels.entries) {
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
          home: const RegistrationPage(),
        ),
      );
      await tester.pumpAndSettle();

      for (final label in entry.value) {
        expect(find.text(label), findsOneWidget);
      }

      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('registration remains usable on a narrow viewport', (
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
    await _tapVisible(tester, find.text('Realizar cadastro?'));

    expect(find.byKey(const ValueKey('registration-name')), findsOneWidget);
    await _tapVisible(tester, find.text('Voltar ao login'));
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
