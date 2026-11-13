import 'package:flutter/material.dart';

import '../../../core/models/app_role.dart';
import '../../../core/services/http/api_client.dart';
import '../../../core/services/routes/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/widgets/admin_login_form.dart';
import 'tenant_dashboard_page.dart';

class TemporaryTenantAccessPage extends StatelessWidget {
  const TemporaryTenantAccessPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<int>(
      valueListenable: apiClient.sessionChanges,
      builder: (context, revision, _) => apiClient.hasUserSession
          ? TenantDashboardPage(key: ValueKey(revision), apiClient: apiClient)
          : Scaffold(
              appBar: AppBar(
                title: Text(l10n.tenantTemporaryAccess),
                leading: IconButton(
                  tooltip: l10n.back,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () =>
                      Navigator.of(context)
                          .popUntil(ModalRoute.withName(AppRoutes.home)),
                ),
              ),
              body: TemporaryRoleLoginForm(
                apiClient: apiClient,
                role: AppRole.user,
                onAuthenticated: () {},
              ),
            ),
    );
  }
}
