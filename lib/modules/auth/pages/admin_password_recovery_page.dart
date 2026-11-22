import 'package:flutter/material.dart';

import '../../../core/services/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class AdminPasswordRecoveryPage extends StatelessWidget {
  const AdminPasswordRecoveryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              child: Column(
                children: [
                  const Icon(
                    Icons.menu_book_outlined,
                    color: Colors.white,
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.authBrand,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.authSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_outlined,
                          size: 42,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.recoveryAdminQuestion,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.recoveryAdminBlocked,
                          key: const ValueKey('admin-recovery-guidance'),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 28),
                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            key: const ValueKey('admin-recovery-back-to-login'),
                            onPressed: () => Navigator.of(context)
                                .pushNamedAndRemoveUntil(
                                  AppRoutes.login,
                                  (_) => false,
                                ),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              shape: const RoundedRectangleBorder(),
                            ),
                            child: Text(l10n.backToLogin),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
