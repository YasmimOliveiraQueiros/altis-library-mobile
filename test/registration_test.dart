import 'dart:async';
import 'dart:convert';

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
  testWidgets('registration renders every requested field and enables submit', (
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
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Cadastrar'),
    );
    expect(button.onPressed, isNotNull);
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

  testWidgets('successful registration posts and returns to login', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('{}', 201);
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));
    await _fillRegistration(tester);
    await _tapVisible(tester, find.text('Cadastrar'));

    expect(requests, hasLength(1));
    expect(requests.single.url.path, '/users');
    expect(requests.single.headers.containsKey('authorization'), isFalse);
    final requestBody =
        jsonDecode(requests.single.body) as Map<String, dynamic>;
    expect(requestBody.keys.toSet(), {
      'name',
      'email',
      'password',
      'phone',
      'cpf',
      'birthDate',
      'address',
    });
    expect(requestBody['cpf'], '12345678900');
    expect(requestBody['phone'], '85999999999');
    expect(requestBody['birthDate'], matches(RegExp(r'^\d{4}-\d{2}-\d{2}$')));
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Cadastrar nova conta'), findsNothing);
    expect(
      find.text('Cadastro realizado com sucesso. Faça login para continuar.'),
      findsOneWidget,
    );
    expect(client.hasToken, isFalse);
  });

  testWidgets('400 displays backend validation errors and retains input', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message': 'Dados da requisição inválidos.',
            'fieldErrors': [
              {'field': 'email', 'message': 'E-mail inválido.'},
            ],
          }),
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));
    await _fillRegistration(tester);
    await _tapVisible(tester, find.text('Cadastrar'));

    expect(find.text('Dados da requisição inválidos.'), findsOneWidget);
    expect(find.text('E-mail inválido.'), findsOneWidget);
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('registration-name')),
          )
          .controller!
          .text,
      'Pessoa Exemplo',
    );
    expect(find.text('Cadastrar nova conta'), findsOneWidget);
  });

  testWidgets('duplicate submission is blocked and failures retain input', (
    tester,
  ) async {
    final responseCompleter = Completer<http.Response>();
    var requestCount = 0;
    final client = ApiClient(
      client: MockClient((_) {
        requestCount++;
        return responseCompleter.future;
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));
    await _fillRegistration(tester);

    final submit = find.widgetWithText(FilledButton, 'Cadastrar');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();

    expect(requestCount, 1);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const ValueKey('registration-submit')),
          )
          .onPressed,
      isNull,
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    responseCompleter.complete(http.Response('error', 503));
    await tester.pumpAndSettle();

    expect(requestCount, 1);
    expect(
      find.text('Não foi possível realizar o cadastro. Tente novamente.'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('registration-name')),
          )
          .controller!
          .text,
      'Pessoa Exemplo',
    );
  });

  testWidgets('network failure shows retry guidance and preserves input', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async {
        throw http.ClientException('network unavailable');
      }),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await _tapVisible(tester, find.text('Realizar cadastro?'));
    await _fillRegistration(tester);
    await _tapVisible(tester, find.text('Cadastrar'));

    expect(
      find.text(
        'Não foi possível conectar à API. Verifique sua conexão e tente novamente.',
      ),
      findsOneWidget,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('registration-name')),
          )
          .controller!
          .text,
      'Pessoa Exemplo',
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
    const registrationMessages = {
      'pt': (
        success: 'Cadastro realizado com sucesso. Faça login para continuar.',
        emailConflict: 'O e-mail informado já está cadastrado.',
      ),
      'en': (
        success: 'Registration completed successfully. Sign in to continue.',
        emailConflict: 'The email address is already registered.',
      ),
      'es': (
        success:
            'Registro completado correctamente. Inicia sesión para continuar.',
        emailConflict: 'El correo electrónico ya está registrado.',
      ),
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
          home: RegistrationPage(
            apiClient: ApiClient(
              client: MockClient((_) async => http.Response('', 500)),
            ),
          ),
        ),
      );
      final pageClient = tester
          .widget<RegistrationPage>(find.byType(RegistrationPage))
          .apiClient;
      addTearDown(pageClient.dispose);
      await tester.pumpAndSettle();

      for (final label in entry.value) {
        expect(find.text(label), findsOneWidget);
      }
      final localizations = AppLocalizations.of(
        tester.element(find.byType(RegistrationPage)),
      )!;
      expect(
        localizations.registrationSuccess,
        registrationMessages[entry.key]!.success,
      );
      expect(
        localizations.registrationEmailConflict,
        registrationMessages[entry.key]!.emailConflict,
      );

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

Future<void> _fillRegistration(WidgetTester tester) async {
  for (final entry in const {
    'registration-name': 'Pessoa Exemplo',
    'registration-cpf': '12345678900',
    'registration-phone': '85999999999',
    'registration-address': 'Rua Exemplo, 100',
    'registration-email': 'pessoa@example.com',
    'registration-password': 'senha',
    'registration-confirm-password': 'senha',
  }.entries) {
    await _enterTextVisible(
      tester,
      find.byKey(ValueKey(entry.key)),
      entry.value,
    );
  }

  await _tapVisible(
    tester,
    find.byKey(const ValueKey('registration-birth-date')),
  );
  await _tapVisible(tester, find.text('OK'));
}
