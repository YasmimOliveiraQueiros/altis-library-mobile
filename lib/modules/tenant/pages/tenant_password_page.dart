import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../users/services/user_service.dart';

class TenantPasswordPage extends StatefulWidget {
  const TenantPasswordPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<TenantPasswordPage> createState() => _TenantPasswordPageState();
}

class _TenantPasswordPageState extends State<TenantPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  late final UserService _userService;
  late final int _sessionRevision;
  bool _isSaving = false;
  String? _saveError;

  bool get _hasUserSession =>
      widget.apiClient.hasUserSession &&
      widget.apiClient.sessionRevision == _sessionRevision;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.apiClient);
    _sessionRevision = widget.apiClient.sessionRevision;
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context)!.requiredField;
    }
    return null;
  }

  String? _newPasswordValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;
    if (value!.length < 8) {
      return AppLocalizations.of(context)!.tenantPasswordMinLength;
    }
    return null;
  }

  String? _confirmPasswordValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;
    if (value != _newPasswordController.text) {
      return AppLocalizations.of(context)!.tenantPasswordsDoNotMatch;
    }
    return null;
  }

  Future<void> _save() async {
    if (_isSaving || !_hasUserSession || !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await _userService.changeMyPassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
      if (mounted && _hasUserSession) Navigator.pop(context, true);
    } on UserRequestException catch (error) {
      if (!mounted || !_hasUserSession) return;
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _saveError = error.statusCode == 400 || error.statusCode == 422
            ? l10n.tenantPasswordValidationFailed
            : l10n.tenantPasswordChangeFailed;
      });
    } on SocketException {
      _setConnectionError();
    } on http.ClientException {
      _setConnectionError();
    } on TimeoutException {
      _setConnectionError();
    } catch (_) {
      if (!mounted || !_hasUserSession) return;
      setState(() {
        _saveError = AppLocalizations.of(context)!.tenantPasswordChangeFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _setConnectionError() {
    if (!mounted || !_hasUserSession) return;
    setState(() {
      _saveError = AppLocalizations.of(context)!.tenantConnectionFailed;
    });
  }

  Widget _passwordField({
    required Key key,
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: key,
        controller: controller,
        obscureText: true,
        textInputAction: TextInputAction.next,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _passwordField(
                    key: const ValueKey('tenant-current-password'),
                    controller: _currentPasswordController,
                    label: l10n.tenantCurrentPassword,
                    validator: _requiredValidator,
                  ),
                  _passwordField(
                    key: const ValueKey('tenant-new-password'),
                    controller: _newPasswordController,
                    label: l10n.tenantNewPassword,
                    validator: _newPasswordValidator,
                  ),
                  _passwordField(
                    key: const ValueKey('tenant-confirm-password'),
                    controller: _confirmPasswordController,
                    label: l10n.tenantConfirmPassword,
                    validator: _confirmPasswordValidator,
                  ),
                  if (_saveError != null) ...[
                    Text(
                      _saveError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    key: const ValueKey('tenant-password-submit'),
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.tenantChangePassword),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<int>(
      valueListenable: widget.apiClient.sessionChanges,
      builder: (context, _, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.tenantChangePassword)),
        body: _hasUserSession
            ? _buildBody(context)
            : Center(child: Text(l10n.tenantUserAccessRequired)),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
