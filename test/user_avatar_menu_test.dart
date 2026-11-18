import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('USER avatar menu shows authorized actions and is dismissible', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('', 500);
      }),
    );
    client.setSession(token: 'user-jwt', role: AppRole.user);
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();

    expect(find.text('Alterar idioma'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
    expect(find.text('Encerrar conta'), findsOneWidget);

    await tester.tap(find.text('Encerrar conta'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nenhuma alteração será feita'), findsOneWidget);
    expect(requests.any((request) => request.method == 'DELETE'), isFalse);
    await tester.tap(find.text('Fechar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(160, 500));
    await tester.pumpAndSettle();
    expect(find.text('Alterar idioma'), findsNothing);

    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alterar idioma'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Inglês'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('User menu'));
    await tester.pumpAndSettle();
    expect(find.text('Change language'), findsOneWidget);
    expect(find.text('Alterar idioma'), findsNothing);
  });

  testWidgets('ADMIN avatar menu excludes USER-only actions', (tester) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();

    expect(find.text('Alterar idioma'), findsOneWidget);
    expect(find.text('Sair'), findsOneWidget);
    expect(find.text('Editar perfil'), findsNothing);
    expect(find.text('Encerrar conta'), findsNothing);
  });
}
