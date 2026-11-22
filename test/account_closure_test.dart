import 'dart:async';
import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('confirmation sends one authenticated DELETE with no body', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final response = Completer<http.Response>();
    final api = ApiClient(
      client: MockClient((request) {
        requests.add(request);
        return request.method == 'DELETE'
            ? response.future
            : Future.value(http.Response('{}', 200));
      }),
    );
    api.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(api.dispose);

    await tester.pumpWidget(MyApp(apiClient: api, locale: const Locale('pt')));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encerrar conta'));
    await tester.pumpAndSettle();
    expect(requests.any((request) => request.method == 'DELETE'), isFalse);
    requests.clear();
    final confirmButton = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(FilledButton),
    );
    expect(confirmButton, findsOneWidget);
    final buttonCenter = tester.getCenter(confirmButton);
    await tester.tap(confirmButton);
    await tester.pump();
    await tester.tapAt(buttonCenter);
    await tester.pump();
    expect(requests, hasLength(1));
    expect(requests.single.method, 'DELETE');
    expect(requests.single.url.path, '/users/me');
    expect(requests.single.headers['authorization'], 'Bearer user-jwt');
    expect(requests.single.body, isEmpty);

    response.complete(http.Response('', 204));
    await tester.pumpAndSettle();
    expect(api.hasToken, isFalse);
    expect(api.role, isNull);
    expect(
      find.text('Conta encerrada com sucesso. Você saiu do aplicativo.'),
      findsOneWidget,
    );
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(api.hasToken, isFalse);
    expect(find.text('Entrar'), findsWidgets);
  });

  testWidgets('409 keeps session and shows the backend message', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient(
        (request) async => request.method == 'DELETE'
            ? http.Response.bytes(
                utf8.encode(
                  jsonEncode({'message': 'Existem empréstimos ativos.'}),
                ),
                409,
              )
            : http.Response('{}', 200),
      ),
    );
    api.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(api.dispose);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encerrar conta'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.hasUserSession, isTrue);
    expect(find.text('Existem empréstimos ativos.'), findsOneWidget);
  });

  testWidgets('403 keeps session and does not claim account closure', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient(
        (request) async => request.method == 'DELETE'
            ? http.Response.bytes(
                utf8.encode(jsonEncode({'message': 'Ação não permitida.'})),
                403,
              )
            : http.Response('{}', 200),
      ),
    );
    api.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(api.dispose);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encerrar conta'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.hasUserSession, isTrue);
    expect(find.text('Ação não permitida.'), findsOneWidget);
    expect(find.text('Conta encerrada com sucesso.'), findsNothing);
  });

  testWidgets('401 is centrally handled as session expiration', (tester) async {
    final api = ApiClient(
      client: MockClient(
        (request) async => request.method == 'DELETE'
            ? http.Response('', 401)
            : http.Response('{}', 200),
      ),
    );
    api.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(api.dispose);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encerrar conta'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.hasToken, isFalse);
    expect(find.text('Conta encerrada com sucesso.'), findsNothing);
  });

  testWidgets('connection failure does not clear session or claim success', (
    tester,
  ) async {
    final api = ApiClient(
      client: MockClient((request) async {
        if (request.method == 'DELETE') {
          throw http.ClientException('network unavailable');
        }
        return http.Response('{}', 200);
      }),
    );
    api.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(api.dispose);
    await tester.pumpWidget(MyApp(apiClient: api));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Encerrar conta'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(api.hasUserSession, isTrue);
    expect(find.text('Conta encerrada com sucesso.'), findsNothing);
    expect(
      find.text('Não foi possível conectar à API. Verifique sua conexão.'),
      findsOneWidget,
    );
  });
}
