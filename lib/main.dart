import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/models/app_role.dart';
import 'core/services/http/api_client.dart';
import 'core/services/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_navigation_shell.dart';
import 'core/widgets/app_locale_scope.dart';
import 'l10n/app_localizations.dart';
import 'modules/auth/pages/auth_gate.dart';
import 'modules/auth/pages/login_page.dart';
import 'modules/auth/pages/password_recovery_page.dart';
import 'modules/auth/pages/admin_password_recovery_page.dart';
import 'modules/auth/pages/registration_page.dart';
import 'modules/books/pages/books_page.dart';
import 'modules/dashboard/pages/admin_dashboard_page.dart';
import 'modules/loans/pages/loans_page.dart';
import 'modules/publishers/pages/publishers_page.dart';
import 'modules/tenant/pages/tenant_dashboard_page.dart';
import 'modules/tenant/pages/tenant_password_page.dart';
import 'modules/tenant/pages/tenant_profile_page.dart';
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
  final _navigatorKey = GlobalKey<NavigatorState>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  int _handledSessionExpiration = 0;
  late Locale _locale = widget.locale ?? const Locale('pt');

  void _setLocale(Locale locale) => setState(() => _locale = locale);

  @override
  void didUpdateWidget(covariant MyApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.locale != widget.locale && widget.locale != null) {
      _locale = widget.locale!;
    }
  }

  @override
  void initState() {
    super.initState();
    _apiClient.sessionExpirations.addListener(_handleSessionExpiration);
  }

  void _handleSessionExpiration() {
    final expiration = _apiClient.sessionExpirations.value;
    if (expiration == _handledSessionExpiration) return;
    _handledSessionExpiration = expiration;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;
    navigator.pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _navigatorKey.currentContext;
      if (context == null || !mounted) return;
      final localizations = AppLocalizations.of(context);
      if (localizations == null) return;
      _scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(localizations.sessionExpired)),
      );
    });
  }

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
        builder = (_) => _adminPage(
          AppRoutes.dashboard,
          AdminDashboardPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.users:
        builder = (_) =>
            _adminPage(AppRoutes.users, UsersPage(apiClient: _apiClient));
        break;
      case AppRoutes.publishers:
        builder = (_) => _adminPage(
          AppRoutes.publishers,
          PublishersPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.books:
        builder = (_) =>
            _adminPage(AppRoutes.books, BooksPage(apiClient: _apiClient));
        break;
      case AppRoutes.loans:
        builder = (_) =>
            _adminPage(AppRoutes.loans, LoansPage(apiClient: _apiClient));
        break;
      case AppRoutes.tenant:
        builder = (_) => _userPage(
          AppRoutes.tenant,
          TenantDashboardPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.tenantProfile:
        builder = (_) => _userPage(
          AppRoutes.tenantProfile,
          TenantProfilePage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.tenantPassword:
        builder = (_) => _userPage(
          AppRoutes.tenantPassword,
          TenantPasswordPage(apiClient: _apiClient),
        );
        break;
      case AppRoutes.passwordRecovery:
        builder = (_) => PasswordRecoveryPage(apiClient: _apiClient);
        break;
      case AppRoutes.adminPasswordRecovery:
        builder = (_) => const AdminPasswordRecoveryPage();
        break;
      case AppRoutes.register:
        builder = (_) => RegistrationPage(apiClient: _apiClient);
        break;
      default:
        builder = (_) => AuthGate(apiClient: _apiClient);
        break;
    }

    if (name == AppRoutes.tenantProfile) {
      return MaterialPageRoute<bool>(builder: builder, settings: settings);
    }
    return MaterialPageRoute<void>(builder: builder, settings: settings);
  }

  Widget _adminPage(String route, Widget page) => AppNavigationShell(
    apiClient: _apiClient,
    requiredRole: AppRole.admin,
    currentRoute: route,
    child: ProtectedRoute(
      apiClient: _apiClient,
      requiredRole: AppRole.admin,
      builder: (_) => page,
    ),
  );

  Widget _userPage(String route, Widget page) => AppNavigationShell(
    apiClient: _apiClient,
    requiredRole: AppRole.user,
    currentRoute: route,
    child: ProtectedRoute(
      apiClient: _apiClient,
      requiredRole: AppRole.user,
      builder: (_) => page,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'Altis+ Biblioteca',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      builder: (context, child) => AppLocaleScope(
        locale: _locale,
        setLocale: _setLocale,
        child: child ?? const SizedBox.shrink(),
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: _buildRoute,
    );
  }

  @override
  void dispose() {
    _apiClient.sessionExpirations.removeListener(_handleSessionExpiration);
    if (widget.apiClient == null) _apiClient.dispose();
    super.dispose();
  }
}
