import 'package:flutter_test/flutter_test.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';
import 'package:altis_library_mobile/core/services/http/api_config.dart';

void main() {
  test('informa quando API_BASE_URL não foi definida', () async {
    if (ApiConfig.isConfigured) return;
    final apiClient = ApiClient();
    addTearDown(apiClient.dispose);

    await expectLater(
      apiClient.get('/books'),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('API_BASE_URL is not configured'),
        ),
      ),
    );
  });

  test('Deve conectar ao backend Spring Boot', () async {
    final apiClient = ApiClient();

    try {
      final response = await apiClient.get('/swagger-ui/index.html');

      expect(response.statusCode, 200);
    } finally {
      apiClient.dispose();
    }
  }, skip: ApiConfig.isConfigured ? null : ApiConfig.configurationError);
}
