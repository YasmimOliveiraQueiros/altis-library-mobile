import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('ADMIN menu toggles, keeps order, navigates and logs out', (
    tester,
  ) async {
    final requests = <http.Request>[];
    final client = ApiClient(
      client: MockClient((request) async {
        requests.add(request);
        return http.Response('', 500);
      }),
    );
    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Abrir menu'), findsOneWidget);
    expect(find.text('Aluguéis'), findsNothing);

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();

    const adminItems = [
      'Dashboard',
      'Aluguéis',
      'Livros',
      'Editoras',
      'Usuários',
    ];
    final itemPositions = adminItems
        .map((label) => tester.getTopLeft(find.text(label)).dy)
        .toList();
    expect(itemPositions, orderedEquals([...itemPositions]..sort()));
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Dashboard' &&
            widget.properties.selected == true,
      ),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Fechar menu'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Abrir menu'), findsOneWidget);
    expect(find.text('Aluguéis'), findsNothing);

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usuários'));
    await tester.pumpAndSettle();

    expect(find.text('Gerenciamento de usuários'), findsOneWidget);
    expect(client.hasAdminSession, isTrue);
    expect(
      requests.any(
        (request) =>
            request.url.path == '/users' &&
            request.headers['authorization'] == 'Bearer admin-jwt',
      ),
      isTrue,
    );

    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Livros'));
    await tester.pumpAndSettle();
    expect(find.text('Controle de livros'), findsOneWidget);
    expect(client.hasToken, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Visão geral do sistema'), findsOneWidget);

    await tester.tap(find.text('Sair'));
    await tester.pumpAndSettle();

    expect(client.hasToken, isFalse);
    expect(client.role, isNull);
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
  });

  testWidgets('USER menu contains only tenant actions and preserves session', (
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
    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Editar Perfil'), findsNothing);
    expect(find.text('Alterar Senha'), findsNothing);
    expect(find.text('Sair'), findsOneWidget);
    expect(find.text('Aluguéis'), findsNothing);
    expect(find.text('Livros'), findsNothing);
    expect(find.text('Editoras'), findsNothing);
    expect(find.text('Usuários'), findsNothing);

    await tester.tap(find.byTooltip('Menu do usuário'));
    await tester.pumpAndSettle();
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Alterar senha'), findsNothing);
    expect(find.text('Encerrar conta'), findsOneWidget);
    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle();
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(client.hasUserSession, isTrue);
    expect(
      requests.any(
        (request) =>
            request.url.path == '/users/me' &&
            request.headers['authorization'] == 'Bearer user-jwt',
      ),
      isTrue,
    );
  });

  testWidgets('menu remains usable without overflow on compact screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/dashboard') {
          return http.Response(
            jsonEncode({
              'totalUsers': 4,
              'totalBooks': 6,
              'totalPublishers': 2,
              'activeLoans': 1,
              'overdueLoans': 0,
              'returnedLoans': 3,
              'pendingLoans': 1,
              'latestLoans': [],
              'loansByMonth': [],
              'booksByStatus': {'available': 5, 'rented': 1},
            }),
            200,
          );
        }
        return http.Response('', 500);
      }),
    );
    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Abrir menu'));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Fechar menu'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('navigation labels are localized in PT, EN and ES', (
    tester,
  ) async {
    const locales = ['pt', 'en', 'es'];
    const openLabels = ['Abrir menu', 'Open menu', 'Abrir menú'];
    const bookLabels = ['Livros', 'Books', 'Libros'];
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    addTearDown(client.dispose);

    for (var index = 0; index < locales.length; index++) {
      await tester.pumpWidget(
        MyApp(apiClient: client, locale: Locale(locales[index])),
      );
      await tester.pumpAndSettle();
      expect(find.byTooltip(openLabels[index]), findsOneWidget);
      await tester.tap(find.byTooltip(openLabels[index]));
      await tester.pumpAndSettle();
      expect(find.text(bookLabels[index]), findsOneWidget);
      await tester.tap(
        find.byTooltip(
          index == 0
              ? 'Fechar menu'
              : index == 1
              ? 'Close menu'
              : 'Cerrar menú',
        ),
      );
      await tester.pumpAndSettle();
    }
  });
}
