import 'package:flutter/material.dart';

import '../../../core/models/app_role.dart';
import '../../../core/services/http/api_client.dart';
import '../../../core/services/routes/app_routes.dart';
import '../../../core/widgets/app_navigation_shell.dart';
import '../../../l10n/app_localizations.dart';
import '../../dashboard/pages/admin_dashboard_page.dart';
import '../../tenant/pages/tenant_dashboard_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: apiClient.sessionChanges,
      builder: (context, _, _) {
        if (apiClient.hasAdminSession) {
          return AppNavigationShell(
            apiClient: apiClient,
            requiredRole: AppRole.admin,
            currentRoute: AppRoutes.dashboard,
            child: AdminDashboardPage(apiClient: apiClient),
          );
        }
        if (apiClient.hasUserSession) {
          return AppNavigationShell(
            apiClient: apiClient,
            requiredRole: AppRole.user,
            currentRoute: AppRoutes.tenant,
            child: TenantDashboardPage(apiClient: apiClient),
          );
        }
        return LoginPage(apiClient: apiClient, onAuthenticated: () {});
      },
    );
  }
}

class ProtectedRoute extends StatelessWidget {
  const ProtectedRoute({
    super.key,
    required this.apiClient,
    required this.requiredRole,
    required this.builder,
  });

  final ApiClient apiClient;
  final AppRole requiredRole;
  final WidgetBuilder builder;

  void _openHome(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: apiClient.sessionChanges,
      builder: (context, _, _) {
        if (apiClient.role == requiredRole) return builder(context);
        if (apiClient.hasToken) {
          return const AuthAccessRequired();
        }
        return LoginPage(
          apiClient: apiClient,
          onAuthenticated: () => _openHome(context),
        );
      },
    );
  }
}

class AuthAccessRequired extends StatelessWidget {
  const AuthAccessRequired({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.adminAccess, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                child: Text(l10n.backToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
