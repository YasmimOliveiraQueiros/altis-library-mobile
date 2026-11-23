import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/services/http/api_config.dart';
import 'package:altis_library_mobile/modules/auth/services/registration_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'public registration sends the contract without a session token',
    () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('{}', 201);
        }),
      );
      client.setSession(token: 'existing-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      await RegistrationService(client).register(
        name: 'Pessoa Exemplo',
        email: 'pessoa@example.com',
        password: 'senha',
        phone: '85999999999',
        cpf: '12345678900',
        birthDate: '2005-06-15',
        address: 'Rua Exemplo, 100',
      );

      final request = requests.single;
      expect(request.method, 'POST');
      final configuredBaseUrl = ApiConfig.isConfigured
          ? ApiConfig.baseUrl
          : 'http://mock.local';
      final baseUrl = configuredBaseUrl.replaceFirst(RegExp(r'/$'), '');
      expect(request.url, Uri.parse('$baseUrl/users'));
      expect(request.headers.containsKey('authorization'), isFalse);
      expect(jsonDecode(request.body), {
        'name': 'Pessoa Exemplo',
        'email': 'pessoa@example.com',
        'password': 'senha',
        'phone': '85999999999',
        'cpf': '12345678900',
        'birthDate': '2005-06-15',
        'address': 'Rua Exemplo, 100',
      });
      expect(request.body, isNot(contains('isAdmin')));
      expect(request.body, isNot(contains('active')));
      expect(request.body, isNot(contains('role')));
      expect(client.hasUserSession, isTrue);
    },
  );

  test(
    'ordinary POST requests keep sending the existing bearer token',
    () async {
      final requests = <http.Request>[];
      final client = ApiClient(
        client: MockClient((request) async {
          requests.add(request);
          return http.Response('{}', request.url.path == '/users' ? 201 : 200);
        }),
      );
      client.setSession(token: 'existing-jwt', role: AppRole.user);
      addTearDown(client.dispose);

      await RegistrationService(client).register(
        name: 'Pessoa',
        email: 'pessoa@example.com',
        password: 'senha',
        phone: '85999999999',
        cpf: '12345678900',
        birthDate: '2005-06-15',
        address: 'Rua 1',
      );
      await client.post('/ordinary');

      expect(requests[0].headers.containsKey('authorization'), isFalse);
      expect(requests[1].headers['authorization'], 'Bearer existing-jwt');
    },
  );

  test('400 parses the message and individual field errors', () async {
    final client = ApiClient(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({
            'message': 'Dados da requisição inválidos.',
            'fieldErrors': [
              {'field': 'email', 'message': 'E-mail inválido.'},
              {'field': 'birthDate', 'message': 'Data inválida.'},
            ],
          }),
          400,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      ),
    );
    addTearDown(client.dispose);

    await expectLater(
      _register(client),
      throwsA(
        isA<RegistrationException>()
            .having(
              (error) => error.failure,
              'failure',
              RegistrationFailure.validation,
            )
            .having(
              (error) => error.message,
              'message',
              'Dados da requisição inválidos.',
            )
            .having((error) => error.fieldErrors, 'fieldErrors', {
              'email': 'E-mail inválido.',
              'birthDate': 'Data inválida.',
            }),
      ),
    );
  });

  test('409 identifies e-mail and CPF conflicts using the response', () async {
    final cases = {
      'O e-mail informado já está cadastrado.':
          RegistrationFailure.emailConflict,
      'O CPF informado já está cadastrado.': RegistrationFailure.cpfConflict,
    };

    for (final entry in cases.entries) {
      final client = ApiClient(
        client: MockClient(
          (_) async => http.Response(
            jsonEncode({'message': entry.key}),
            409,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        ),
      );
      addTearDown(client.dispose);

      await expectLater(
        _register(client),
        throwsA(
          isA<RegistrationException>().having(
            (error) => error.failure,
            'failure',
            entry.value,
          ),
        ),
      );
    }
  });

  test('network failure and 5xx are surfaced as retryable failures', () async {
    final networkClient = ApiClient(
      client: MockClient((_) async {
        throw http.ClientException('network unavailable');
      }),
    );
    addTearDown(networkClient.dispose);

    await expectLater(
      _register(networkClient),
      throwsA(
        isA<RegistrationException>().having(
          (error) => error.failure,
          'failure',
          RegistrationFailure.connection,
        ),
      ),
    );

    final serverClient = ApiClient(
      client: MockClient((_) async => http.Response('error', 503)),
    );
    addTearDown(serverClient.dispose);

    await expectLater(
      _register(serverClient),
      throwsA(
        isA<RegistrationException>().having(
          (error) => error.failure,
          'failure',
          RegistrationFailure.requestFailed,
        ),
      ),
    );
  });
}

Future<void> _register(ApiClient client) => RegistrationService(client)
    .register(
      name: 'Pessoa',
      email: 'pessoa@example.com',
      password: 'senha',
      phone: '85999999999',
      cpf: '12345678900',
      birthDate: '2005-06-15',
      address: 'Rua 1',
    );
