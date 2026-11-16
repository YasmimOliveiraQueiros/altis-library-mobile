import 'package:flutter/material.dart';

import '../../../core/services/http/api_client.dart';
import '../../../core/services/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.apiClient,
    required this.onAuthenticated,
  });

  final ApiClient apiClient;
  final VoidCallback onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final AuthService _authService;
  bool _isLoggingIn = false;
  bool _isPasswordVisible = false;
  AuthFailure? _failure;
  String? _backendMessage;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(widget.apiClient);
  }

  Future<void> _login() async {
    if (_isLoggingIn || !_formKey.currentState!.validate()) return;

    setState(() {
      _isLoggingIn = true;
      _failure = null;
      _backendMessage = null;
    });

    try {
      await _authService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      _passwordController.clear();
      widget.onAuthenticated();
    } on AuthException catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = error.failure;
        _backendMessage = error.message;
      });
    } finally {
      if (mounted) setState(() => _isLoggingIn = false);
    }
  }

  String _failureMessage(AppLocalizations l10n) {
    if (_backendMessage != null) return _backendMessage!;
    return switch (_failure!) {
      AuthFailure.invalidCredentials => l10n.loginInvalidCredentials,
      AuthFailure.forbidden => l10n.loginForbidden,
      AuthFailure.invalidResponse => l10n.loginInvalidResponse,
      AuthFailure.connection => l10n.apiConnectionFailed,
      AuthFailure.timeout => l10n.apiTimeout,
      AuthFailure.requestFailed => l10n.loginRequestFailed,
    };
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
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight > 64
                          ? constraints.maxHeight - 64
                          : 0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 42,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.loginWelcome,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.loginDescription,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 28),
                              TextFormField(
                                key: const ValueKey('login-email'),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.username],
                                validator: (value) {
                                  final email = value?.trim() ?? '';
                                  if (email.isEmpty) return l10n.requiredField;
                                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                      .hasMatch(email)) {
                                    return l10n.invalidEmail;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: l10n.email,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('login-password'),
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _login(),
                                validator: (value) => (value ?? '').isEmpty
                                    ? l10n.requiredField
                                    : null,
                                decoration: InputDecoration(
                                  labelText: l10n.password,
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    tooltip: _isPasswordVisible
                                        ? l10n.hidePassword
                                        : l10n.showPassword,
                                    onPressed: () => setState(
                                      () => _isPasswordVisible =
                                          !_isPasswordVisible,
                                    ),
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              if (_failure != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _failureMessage(l10n),
                                  key: const ValueKey('login-error'),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: _isLoggingIn ? null : _login,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: const RoundedRectangleBorder(),
                                  ),
                                  child: _isLoggingIn
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(l10n.login),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.of(context)
                                      .pushNamed(AppRoutes.passwordRecovery),
                                  child: Text(l10n.loginForgotPassword),
                                ),
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () =>
                                      Navigator.of(context)
                                          .pushNamed(AppRoutes.register),
                                  child: Text(l10n.loginRegister),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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
