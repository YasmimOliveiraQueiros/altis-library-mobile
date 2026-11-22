import 'package:flutter/material.dart';

import '../../../core/services/http/api_client.dart';
import '../../../core/services/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../services/password_recovery_service.dart';
import '../widgets/auth_input_formatters.dart';

class PasswordRecoveryPage extends StatefulWidget {
  const PasswordRecoveryPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<PasswordRecoveryPage> createState() => _PasswordRecoveryPageState();
}

class _PasswordRecoveryPageState extends State<PasswordRecoveryPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final PasswordRecoveryService _recoveryService;
  bool _isVerifying = false;
  bool _isResetting = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _adminBlocked = false;
  String? _verifiedEmail;
  String? _verifiedCpf;
  PasswordRecoveryFailure? _failure;
  String? _backendMessage;
  bool _failureIsReset = false;

  bool get _identityVerified =>
      _verifiedEmail == _emailController.text.trim() &&
      _verifiedCpf == _cpfController.text.replaceAll(RegExp(r'\D'), '');

  @override
  void initState() {
    super.initState();
    _recoveryService = PasswordRecoveryService(widget.apiClient);
  }

  Future<void> _verifyIdentity() async {
    if (_isVerifying ||
        _isResetting ||
        _identityVerified ||
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isVerifying = true;
      _failure = null;
      _backendMessage = null;
      _adminBlocked = false;
      _failureIsReset = false;
    });

    try {
      final email = _emailController.text.trim();
      final cpf = _cpfController.text.replaceAll(RegExp(r'\D'), '');
      await _recoveryService.verify(email: email, cpf: cpf);
      if (!mounted) return;
      setState(() {
        _verifiedEmail = email;
        _verifiedCpf = cpf;
      });
    } on PasswordRecoveryException catch (error) {
      if (!mounted) return;
      setState(() {
        _failure = error.failure == PasswordRecoveryFailure.adminBlocked
            ? null
            : error.failure;
        _backendMessage = error.displayMessage;
        _adminBlocked = error.failure == PasswordRecoveryFailure.adminBlocked;
      });
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_isVerifying ||
        _isResetting ||
        !_identityVerified ||
        !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isResetting = true;
      _failure = null;
      _backendMessage = null;
      _failureIsReset = false;
    });

    try {
      await _recoveryService.reset(
        email: _verifiedEmail!,
        cpf: _verifiedCpf!,
        newPassword: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (!mounted) return;
      _passwordController.clear();
      _confirmPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.recoverySuccess)),
      );
      Navigator.of(context).pop();
    } on PasswordRecoveryException catch (error) {
      if (!mounted) return;
      final adminBlocked =
          error.failure == PasswordRecoveryFailure.adminBlocked;
      setState(() {
        _failure = adminBlocked ? null : error.failure;
        _backendMessage = adminBlocked ? null : error.displayMessage;
        _failureIsReset = !adminBlocked;
        _adminBlocked = adminBlocked;
        if (adminBlocked) {
          _verifiedEmail = null;
          _verifiedCpf = null;
          _passwordController.clear();
          _confirmPasswordController.clear();
        }
      });
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  String _failureMessage(AppLocalizations l10n) {
    if (_backendMessage != null) return _backendMessage!;
    return switch (_failure!) {
      PasswordRecoveryFailure.connection => l10n.recoveryConnectionFailed,
      PasswordRecoveryFailure.timeout => l10n.apiTimeout,
      PasswordRecoveryFailure.invalidResponse => l10n.recoveryInvalidResponse,
      PasswordRecoveryFailure.requestFailed =>
        _failureIsReset ? l10n.recoveryResetFailed : l10n.recoveryRequestFailed,
      PasswordRecoveryFailure.adminBlocked => l10n.recoveryAdminBlocked,
    };
  }

  void _identityChanged() {
    if ((_verifiedEmail == null && !_adminBlocked) || _identityVerified) {
      return;
    }
    setState(() {
      _verifiedEmail = null;
      _verifiedCpf = null;
      _adminBlocked = false;
      _failure = null;
      _backendMessage = null;
      _failureIsReset = false;
      _passwordController.clear();
      _confirmPasswordController.clear();
    });
  }

  void _backToLogin() => Navigator.of(context).pop();

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.requiredField;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  String? _validateCpf(String? value, AppLocalizations l10n) {
    final cpf = (value ?? '').replaceAll(RegExp(r'\D'), '');
    if (cpf.isEmpty) return l10n.requiredField;
    if (!_isValidCpf(cpf)) return l10n.recoveryInvalidCpf;
    return null;
  }

  bool _isValidCpf(String cpf) {
    if (cpf.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(cpf)) {
      return false;
    }

    final digits = cpf.split('').map(int.parse).toList();
    for (var index = 9; index < 11; index++) {
      var sum = 0;
      for (var position = 0; position < index; position++) {
        sum += digits[position] * ((index + 1) - position);
      }
      final remainder = (sum * 10) % 11;
      final checkDigit = remainder == 10 ? 0 : remainder;
      if (digits[index] != checkDigit) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
                                Icons.lock_reset_outlined,
                                size: 42,
                                color: AppTheme.primaryColor,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                l10n.passwordRecoveryTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.recoveryDescription,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 28),
                              TextFormField(
                                key: const ValueKey('recovery-email'),
                                controller: _emailController,
                                enabled: !_isVerifying && !_isResetting,
                                onChanged: (_) => _identityChanged(),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    _validateEmail(value, l10n),
                                decoration: InputDecoration(
                                  labelText: l10n.email,
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('recovery-cpf'),
                                controller: _cpfController,
                                enabled: !_isVerifying && !_isResetting,
                                onChanged: (_) => _identityChanged(),
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [CpfInputFormatter()],
                                validator: (value) => _validateCpf(value, l10n),
                                decoration: InputDecoration(
                                  labelText: l10n.recoveryCpf,
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  border: const OutlineInputBorder(),
                                  hintText: '000.000.000-00',
                                ),
                              ),
                              if (_adminBlocked) ...[
                                const SizedBox(height: 16),
                                Text(
                                  l10n.recoveryAdminBlocked,
                                  key: const ValueKey('recovery-admin-blocked'),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              if (_identityVerified) ...[
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: const ValueKey('recovery-password'),
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  enabled: !_isResetting,
                                  validator: (value) => (value ?? '').isEmpty
                                      ? l10n.requiredField
                                      : null,
                                  decoration: InputDecoration(
                                    labelText: l10n.tenantNewPassword,
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
                                const SizedBox(height: 16),
                                TextFormField(
                                  key: const ValueKey(
                                    'recovery-confirm-password',
                                  ),
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  enabled: !_isResetting,
                                  validator: (value) {
                                    if ((value ?? '').isEmpty) {
                                      return l10n.requiredField;
                                    }
                                    if (value != _passwordController.text) {
                                      return l10n.tenantPasswordsDoNotMatch;
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: l10n.recoveryConfirmPassword,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    border: const OutlineInputBorder(),
                                    suffixIcon: IconButton(
                                      tooltip: _isConfirmPasswordVisible
                                          ? l10n.hidePassword
                                          : l10n.showPassword,
                                      onPressed: () => setState(
                                        () => _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible,
                                      ),
                                      icon: Icon(
                                        _isConfirmPasswordVisible
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (_failure != null) ...[
                                const SizedBox(height: 12),
                                Text(
                                  _failureMessage(l10n),
                                  key: const ValueKey('recovery-error'),
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
                                  key: const ValueKey('recovery-submit'),
                                  onPressed: _isVerifying || _isResetting
                                      ? null
                                      : _adminBlocked
                                      ? _backToLogin
                                      : _identityVerified
                                      ? _resetPassword
                                      : _verifyIdentity,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: const RoundedRectangleBorder(),
                                  ),
                                  child: _isVerifying || _isResetting
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Text(
                                          _identityVerified
                                              ? l10n.recoveryResetButton
                                              : _adminBlocked
                                              ? l10n.backToLogin
                                              : l10n.confirm,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(l10n.backToLogin),
                                ),
                              ),
                              Center(
                                child: TextButton(
                                  key: const ValueKey('recovery-admin-link'),
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.adminPasswordRecovery),
                                  child: Text(l10n.recoveryAdminQuestion),
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
