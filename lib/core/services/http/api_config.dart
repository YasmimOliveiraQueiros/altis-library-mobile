class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isConfigured => baseUrl.trim().isNotEmpty;

  static const String configurationError =
      'API_BASE_URL is not configured. Copy .env.example to .env and run '
      'flutter run --dart-define-from-file=.env.';
}
