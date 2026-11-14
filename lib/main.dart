import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/models/app_role.dart';
import 'core/services/http/api_client.dart';
import 'core/services/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';
import 'modules/auth/pages/auth_gate.dart';
import 'modules/auth/pages/auth_placeholder_page.dart';
import 'modules/auth/pages/login_page.dart';
import 'modules/books/pages/books_page.dart';
import 'modules/dashboard/pages/admin_dashboard_page.dart';
import 'modules/loans/pages/loans_page.dart';
import 'modules/publishers/pages/publishers_page.dart';
import 'modules/tenant/pages/tenant_dashboard_page.dart';
import 'modules/users/pages/users_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.apiClient, this.locale});

  final ApiClient? apiClient;
  final Locale? locale;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ApiClient _apiClient = widget.apiClient ?? ApiClient();

  void _openHome(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  Route<dynamic> _buildRoute(RouteSettings settings) {
    final name = settings.name ?? AppRoutes.home;
    late final WidgetBuilder builder;

    switch (name) {
      case AppRoutes.home:
        builder = (_) => AuthGate(apiClient: _apiClient);
        break;
      case AppRoutes.login:
        builder = (context) => LoginPage(
          apiClient: _apiClient,
          onAuthenticated: () => _openHome(context),
        );
        break;
      case AppRoutes.dashboard:
        builder = (_) => ProtectedRoute(
          apiClient: _apiClient,
          requiredRole: AppRole.admin,
          builder: (_) => AdminDashboardPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.users:
        builder = (_) => ProtectedRoute(
          apiClient: _apiClient,
          requiredRole: AppRole.admin,
          builder: (_) => UsersPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.publishers:
        builder = (_) => ProtectedRoute(
          apiClient: _apiClient,
          requiredRole: AppRole.admin,
          builder: (_) => PublishersPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.books:
        builder = (_) => ProtectedRoute(
          apiClient: _apiClient,
          requiredRole: AppRole.admin,
          builder: (_) => BooksPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.loans:
        builder = (_) => ProtectedRoute(
          apiClient: _apiClient,
          requiredRole: AppRole.admin,
          builder: (_) => LoansPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.tenant:
        builder = (_) => ProtectedRoute(
          apiClient: _apiClient,
          requiredRole: AppRole.user,
          builder: (_) => TenantDashboardPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.passwordRecovery:
        builder = (_) => const AuthPlaceholderPage(isRegistration: false);
        break;
      case AppRoutes.register:
        builder = (_) => const AuthPlaceholderPage(isRegistration: true);
        break;
      default:
        builder = (_) => AuthGate(apiClient: _apiClient);
        break;
    }

    return MaterialPageRoute<void>(builder: builder, settings: settings);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Altis+ Biblioteca',
      debugShowCheckedModeBanner: false,
      locale: widget.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      onGenerateRoute: _buildRoute,
    );
  }

  @override
  void dispose() {
    if (widget.apiClient == null) _apiClient.dispose();
    super.dispose();
  }
}
