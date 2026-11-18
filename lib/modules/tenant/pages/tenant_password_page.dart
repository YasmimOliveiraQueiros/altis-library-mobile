import 'package:flutter/material.dart';

import '../../../core/services/http/api_client.dart';
import '../../../core/widgets/app_navigation_shell.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/tenant_password_form.dart';

class TenantPasswordPage extends StatelessWidget {
  const TenantPasswordPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: const AppNavigationButton(),
        automaticallyImplyLeading: false,
        title: Text(l10n.tenantChangePassword),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: TenantPasswordForm(apiClient: apiClient),
            ),
          ),
        ),
      ),
    );
  }
}
