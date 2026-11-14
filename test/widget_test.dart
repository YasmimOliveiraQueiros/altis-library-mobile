import 'package:flutter/material.dart';

import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  testWidgets('the application opens at the definitive login screen', (
    tester,
  ) async {
    final client = ApiClient(
      client: MockClient((_) async => http.Response('', 500)),
    );
    addTearDown(client.dispose);

    await tester.pumpWidget(
      MyApp(apiClient: client, locale: const Locale('pt')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bem-vindo de volta!'), findsOneWidget);
    expect(find.text('Altis+ Biblioteca'), findsOneWidget);
    expect(find.text('Recuperar senha?'), findsOneWidget);
    expect(find.text('Realizar cadastro?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
