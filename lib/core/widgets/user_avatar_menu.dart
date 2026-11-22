import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../models/app_role.dart';
import '../services/http/api_client.dart';
import '../services/routes/app_routes.dart';
import '../theme/app_theme.dart';
import 'app_navigation_shell.dart';
import 'app_locale_scope.dart';
import '../services/http/api_errors.dart';
import '../../modules/tenant/services/account_service.dart';

class UserAvatarMenu extends StatelessWidget {
  const UserAvatarMenu({
    super.key,
    required this.apiClient,
    this.userName,
    this.onProfileUpdated,
  });

  final ApiClient apiClient;
  final String? userName;
  final VoidCallback? onProfileUpdated;

  Future<void> _openProfile(BuildContext context) async {
    if (apiClient.role != AppRole.user) return;
    final saved = await Navigator.of(context)
        .pushNamed<bool>(AppRoutes.tenantProfile);
    if (saved == true) onProfileUpdated?.call();
  }

  String _initials(String? name) {
    final words = (name ?? '').trim().split(RegExp(r'\s+'))
      ..removeWhere((word) => word.isEmpty);
    if (words.isEmpty) return '?';
    return words.length == 1
        ? words.first.substring(0, 1).toUpperCase()
        : '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
              .toUpperCase();
  }

  Future<void> _showLanguages(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(l10n.changeLanguage)),
            for (final entry in [
              ('pt', l10n.portuguese),
              ('en', l10n.english),
              ('es', l10n.spanish),
            ])
              ListTile(
                title: Text(entry.$2),
                onTap: () => Navigator.pop(context, entry.$1),
              ),
          ],
        ),
      ),
    );
    if (selected != null && context.mounted) {
      AppLocaleScope.maybeOf(context)?.setLocale(Locale(selected));
    }
  }

  Future<void> _confirmAccountClosure(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _CloseAccountDialog(
        apiClient: apiClient,
        onConfirmed: () => Navigator.pop(context, true),
      ),
    );
    if (confirmed == true && context.mounted) {
      AppNavigationShell.logout(context, apiClient);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.closeAccountSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isUser = apiClient.role == AppRole.user;
    return PopupMenuButton<String>(
      tooltip: l10n.userMenu,
      position: PopupMenuPosition.over,
      offset: const Offset(0, 42),
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width - 16,
      ),
      onSelected: (value) {
        switch (value) {
          case 'language':
            _showLanguages(context);
            break;
          case 'profile':
            _openProfile(context);
            break;
          case 'logout':
            AppNavigationShell.logout(context, apiClient);
            break;
          case 'close-account':
            if (isUser) {
              _confirmAccountClosure(context);
            }
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'language',
          child: _MenuLabel(
            icon: Icons.language_outlined,
            label: l10n.changeLanguage,
          ),
        ),
        if (isUser)
          PopupMenuItem(
            value: 'profile',
            child: _MenuLabel(
              icon: Icons.person_outline,
              label: l10n.editProfile,
            ),
          ),
        PopupMenuItem(
          value: 'logout',
          child: _MenuLabel(icon: Icons.logout_outlined, label: l10n.signOut),
        ),
        if (isUser)
          PopupMenuItem(
            value: 'close-account',
            child: _MenuLabel(
              icon: Icons.warning_amber_outlined,
              label: l10n.closeAccount,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.only(left: 4, right: 12),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            _initials(userName),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseAccountDialog extends StatefulWidget {
  const _CloseAccountDialog({
    required this.apiClient,
    required this.onConfirmed,
  });

  final ApiClient apiClient;
  final VoidCallback onConfirmed;

  @override
  State<_CloseAccountDialog> createState() => _CloseAccountDialogState();
}

class _CloseAccountDialogState extends State<_CloseAccountDialog> {
  bool _isSubmitting = false;
  String? _error;

  Future<void> _closeAccount() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context)!;
    try {
      await AccountService(widget.apiClient).closeAccount();
      if (mounted) widget.onConfirmed();
    } on ApiHttpException catch (error) {
      if (!mounted || error.statusCode == 401) return;
      setState(() {
        _error = error.statusCode == 409
            ? (error.errorResponse?.displayMessage ??
                  l10n.closeAccountActiveLoans)
            : apiHttpErrorMessage(
                error,
                l10n.closeAccountFailed,
                forbiddenFallback: l10n.closeAccountForbidden,
              );
        _isSubmitting = false;
      });
    } on ApiTransportException catch (error) {
      if (!mounted) return;
      setState(() {
        _error = apiTransportErrorMessage(l10n, error);
        _isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = l10n.closeAccountFailed;
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      icon: Icon(
        Icons.warning_amber_rounded,
        color: Theme.of(context).colorScheme.error,
      ),
      title: Text(l10n.closeAccount),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.closeAccountInfo),
          const SizedBox(height: 12),
          Text(l10n.closeAccountActiveLoans),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _closeAccount,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.closeAccount),
        ),
      ],
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, size: 18, color: color ?? AppTheme.primaryColor),
      const SizedBox(width: 12),
      Flexible(
        child: Text(label, style: TextStyle(color: color)),
      ),
    ],
  );
}
