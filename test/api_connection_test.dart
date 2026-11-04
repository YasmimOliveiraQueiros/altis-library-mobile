import 'package:flutter_test/flutter_test.dart';
import 'package:altis_library_mobile/core/services/http/api_client.dart';

void main() {
  test('Deve conectar ao backend Spring Boot', () async {
    final apiClient = ApiClient();

    try {
      final response = await apiClient.get('/swagger-ui/index.html');

      expect(response.statusCode, 200);
    } finally {
      apiClient.dispose();
    }
  });
}
