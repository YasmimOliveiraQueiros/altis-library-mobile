import 'package:flutter/material.dart';

import '../../../core/services/routes/app_routes.dart';
import '../../../l10n/app_localizations.dart';

class AuthPlaceholderPage extends StatelessWidget {
  const AuthPlaceholderPage({super.key, required this.isRegistration});

  final bool isRegistration;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final title = isRegistration
        ? l10n.registerTitle
        : l10n.passwordRecoveryTitle;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.authFlowNotAvailable, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              OutlinedButton(
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
