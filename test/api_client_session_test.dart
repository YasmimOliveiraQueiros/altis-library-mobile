import 'package:altis_library_mobile/core/models/app_role.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('clearing a temporary session removes both token and role', () {
    final client = ApiClient();
    addTearDown(client.dispose);

    client.setSession(token: 'user-jwt', role: AppRole.user);
    expect(client.hasUserSession, isTrue);
    expect(client.role, AppRole.user);

    client.clearSession();

    expect(client.hasToken, isFalse);
    expect(client.role, isNull);
    expect(client.hasAdminSession, isFalse);
    expect(client.hasUserSession, isFalse);
  });

  test('a bare token cannot grant an administrative or tenant role', () {
    final client = ApiClient();
    addTearDown(client.dispose);

    client.setSession(token: 'admin-jwt', role: AppRole.admin);
    client.setToken('unclassified-jwt');

    expect(client.hasToken, isTrue);
    expect(client.role, isNull);
    expect(client.hasAdminSession, isFalse);
    expect(client.hasUserSession, isFalse);
  });
}
