import 'dart:async';
import 'dart:convert';

import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/services/routes/app_routes.dart';
import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/dashboard/pages/admin_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final _dashboardJson = <String, dynamic>{
  'totalUsers': 61,
  'totalBooks': 24,
  'totalPublishers': 8,
  'activeLoans': 12,
  'overdueLoans': 3,
  'returnedLoans': 21,
  'pendingLoans': 9,
  'latestLoans': [
    {
      'id': 31,
      'userId': 42,
      'bookId': 70,
      'bookTitle': 'A Biblioteca',
      'loanDate': '2026-03-10',
      'returnDate': '2026-03-20',
      'returnedAt': null,
      'status': 'PENDING',
      'observations': null,
    },
  ],
  'loansByMonth': [
    {'year': 2026, 'month': 3, 'quantity': 7},
  ],
  'booksByStatus': {'available': 18, 'rented': 6},
};

final _usersPageJson = <String, dynamic>{
  'content': [
    {
      'id': 42,
      'name': 'Ana Silva',
      'email': 'ana@example.test',
      'phone': '123',
      'cpf': '456',
      'birthDate': '2000-01-01',
      'address': 'Rua A',
      'isAdmin': false,
      'active': true,
      'createdAt': '2026-01-01T00:00:00',
      'updatedAt': '2026-01-01T00:00:00',
    },
  ],
  'totalElements': 1,
  'totalPages': 1,
  'number': 0,
  'size': 100,
  'first': true,
  'last': true,
  'empty': false,
};

http.Response _successResponse(
  http.Request request, {
  bool emptyRecentData = false,
}) {
  final body = switch (request.url.path) {
    '/dashboard' =>
      emptyRecentData
          ? {..._dashboardJson, 'latestLoans': [], 'loansByMonth': []}
          : _dashboardJson,
    '/users' => _usersPageJson,
    _ => null,
  };
  if (body == null) return http.Response('', 404);
  return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
}

Widget _app(ApiClient apiClient, {double textScale = 1}) => MaterialApp(
  theme: AppTheme.lightTheme,
  locale: const Locale('pt'),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context)
        .copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,
  routes: {
    AppRoutes.loans: (_) => const Scaffold(body: Text('Loans destination')),
  },
  home: AdminDashboardPage(apiClient: apiClient),
);

void main() {
  for (final width in [360.0, 1200.0]) {
    testWidgets('dashboard renders server indicators at ${width.toInt()}px', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final client = ApiClient(
        client: MockClient((request) async => _successResponse(request)),
      );
      client.setSession(token: 'test-token', role: AppRole.admin);
      addTearDown(client.dispose);

      await tester.pumpWidget(_app(client, textScale: width < 400 ? 1.5 : 1));
      await tester.pumpAndSettle();

      expect(find.text('Altis+ Biblioteca'), findsOneWidget);
      expect(find.text('Visão geral do sistema'), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('A Biblioteca'), findsOneWidget);
      expect(find.text('Ana Silva'), findsOneWidget);
      expect(find.text('2026-03-20'), findsOneWidget);
      for (final value in ['24', '8', '61', '9', '3']) {
        expect(find.text(value), findsWidgets);
      }
      expect(find.text('Alugados (6)'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('dashboardMetricCard-books')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('dashboardMetricCard-publishers')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('dashboardMetricCard-rented')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('dashboardMetricCard-rented')),
          matching: find.text('12'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('dashboardMetricCard-users')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('dashboardMetricCard-pending')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('dashboardMetricCard-overdue')),
        findsOneWidget,
      );

      final firstRect = tester.getRect(
        find.byKey(const ValueKey('dashboardMetricCard-books')),
      );
      final secondRect = tester.getRect(
        find.byKey(const ValueKey('dashboardMetricCard-publishers')),
      );
      expect(secondRect.top, firstRect.top);
      final rentedRect = tester.getRect(
        find.byKey(const ValueKey('dashboardMetricCard-rented')),
      );
      final usersRect = tester.getRect(
        find.byKey(const ValueKey('dashboardMetricCard-users')),
      );
      final pendingRect = tester.getRect(
        find.byKey(const ValueKey('dashboardMetricCard-pending')),
      );
      final overdueRect = tester.getRect(
        find.byKey(const ValueKey('dashboardMetricCard-overdue')),
      );
      expect(rentedRect.top, greaterThan(firstRect.top));
      expect(usersRect.top, rentedRect.top);
      expect(pendingRect.top, greaterThan(rentedRect.top));
      expect(overdueRect.top, pendingRect.top);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dashboard displays empty sections and can be refreshed', (
    tester,
  ) async {
    var requestCount = 0;
    final client = ApiClient(
      client: MockClient((request) async {
        if (request.url.path == '/dashboard') requestCount++;
        return _successResponse(request, emptyRecentData: true);
      }),
    );
    client.setSession(token: 'test-token', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();

    expect(find.text('Não há dados mensais de aluguéis.'), findsOneWidget);
    expect(find.text('Nenhum aluguel recente.'), findsOneWidget);
    await tester.tap(find.byTooltip('Atualizar dashboard'));
    await tester.pumpAndSettle();
    expect(requestCount, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('recent loans action opens the existing loans route', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final client = ApiClient(
      client: MockClient((request) async => _successResponse(request)),
    );
    client.setSession(token: 'test-token', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Ver todos'));
    await tester.tap(find.text('Ver todos'));
    await tester.pumpAndSettle();

    expect(find.text('Loans destination'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard shows loading while the API request is pending', (
    tester,
  ) async {
    final response = Completer<void>();
    final client = ApiClient(
      client: MockClient((request) async {
        await response.future;
        return _successResponse(request);
      }),
    );
    client.setSession(token: 'test-token', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    response.complete();
    await tester.pumpAndSettle();
    expect(find.text('A Biblioteca'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dashboard shows an error and retry after request failure', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    client.setSession(token: 'test-token', role: AppRole.admin);
    addTearDown(client.dispose);

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar o dashboard.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
