import 'package:flutter/material.dart';

import '../../../core/models/app_role.dart';
import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class AdminLoginForm extends StatelessWidget {
  const AdminLoginForm({
    super.key,
    required this.apiClient,
    required this.onAuthenticated,
  });

  final ApiClient apiClient;
  final VoidCallback onAuthenticated;

  @override
  Widget build(BuildContext context) => TemporaryRoleLoginForm(
    apiClient: apiClient,
    role: AppRole.admin,
    onAuthenticated: onAuthenticated,
  );
}

class TemporaryRoleLoginForm extends StatefulWidget {
  const TemporaryRoleLoginForm({
    super.key,
    required this.apiClient,
    required this.role,
    required this.onAuthenticated,
  });

  final ApiClient apiClient;
  final AppRole role;
  final VoidCallback onAuthenticated;

  @override
  State<TemporaryRoleLoginForm> createState() => _TemporaryRoleLoginFormState();
}

class _TemporaryRoleLoginFormState extends State<TemporaryRoleLoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;
  bool _isLoggingIn = false;
  String? _loginError;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(widget.apiClient);
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _loginError = l10n.loginRequiredFields;
      });
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    try {
      final token = await _authService.login(
        email: email,
        password: password,
        expectedRole: widget.role,
      );
      if (!mounted) return;

      widget.apiClient.setSession(token: token, role: widget.role);
      _passwordController.clear();
      widget.onAuthenticated();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loginError = l10n.loginFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = widget.role == AppRole.admin;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                isAdmin ? Icons.admin_panel_settings : Icons.person_outline,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                isAdmin ? l10n.adminAccess : l10n.tenantTemporaryAccess,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) {
                  if (!_isLoggingIn) _login();
                },
                decoration: InputDecoration(
                  labelText: l10n.password,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_loginError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _loginError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoggingIn ? null : _login,
                child: _isLoggingIn
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.login),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
