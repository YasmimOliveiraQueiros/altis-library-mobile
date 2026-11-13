import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../users/models/user.dart';
import '../../users/services/user_service.dart';

class TenantProfilePage extends StatefulWidget {
  const TenantProfilePage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<TenantProfilePage> createState() => _TenantProfilePageState();
}

class _TenantProfilePageState extends State<TenantProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  late final UserService _userService;
  late final int _sessionRevision;
  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  String? _saveError;

  bool get _hasUserSession =>
      widget.apiClient.hasUserSession &&
      widget.apiClient.sessionRevision == _sessionRevision;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.apiClient);
    _sessionRevision = widget.apiClient.sessionRevision;
    if (_hasUserSession) _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final user = await _userService.getMyProfile();
      if (!mounted || !_hasUserSession) return;
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
        _addressController.text = user.address;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted || !_hasUserSession) return;
      setState(() {
        _loadError = AppLocalizations.of(context)!.tenantProfileLoadFailed;
        _isLoading = false;
      });
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.requiredField;
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value!.trim())) {
      return AppLocalizations.of(context)!.invalidEmail;
    }
    if (value.trim().length > 255) {
      return AppLocalizations.of(context)!.tenantFieldTooLong;
    }
    return null;
  }

  String? _maxLengthValidator(String? value, int maxLength) {
    final requiredError = _requiredValidator(value);
    if (requiredError != null) return requiredError;
    if (value!.trim().length > maxLength) {
      return AppLocalizations.of(context)!.tenantFieldTooLong;
    }
    return null;
  }

  Future<void> _save() async {
    if (_isSaving || _isLoading || _user == null || !_hasUserSession) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await _userService.updateMyProfile(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );
      if (mounted && _hasUserSession) Navigator.pop(context, true);
    } on UserRequestException catch (error) {
      if (!mounted || !_hasUserSession) return;
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _saveError = switch (error.statusCode) {
          400 || 422 => l10n.tenantProfileValidationFailed,
          409 => l10n.tenantProfileConflict,
          _ => l10n.tenantProfileSaveFailed,
        };
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
        _saveError = AppLocalizations.of(context)!.tenantProfileSaveFailed;
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

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required Key key,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: key,
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        maxLength: maxLength,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _readOnlyField(Key key, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        key: key,
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _isLoading ? null : _loadProfile,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    final user = _user;
    if (user == null) {
      return Center(child: Text(l10n.tenantProfileLoadFailed));
    }

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
                  _textField(
                    key: const ValueKey('tenant-profile-name'),
                    controller: _nameController,
                    label: l10n.name,
                    validator: (value) => _maxLengthValidator(value, 255),
                    maxLength: 255,
                  ),
                  _textField(
                    key: const ValueKey('tenant-profile-email'),
                    controller: _emailController,
                    label: l10n.email,
                    validator: _emailValidator,
                    keyboardType: TextInputType.emailAddress,
                    maxLength: 255,
                  ),
                  _textField(
                    key: const ValueKey('tenant-profile-phone'),
                    controller: _phoneController,
                    label: l10n.tenantPhone,
                    validator: (value) => _maxLengthValidator(value, 20),
                    keyboardType: TextInputType.phone,
                    maxLength: 20,
                  ),
                  _textField(
                    key: const ValueKey('tenant-profile-address'),
                    controller: _addressController,
                    label: l10n.tenantAddress,
                    validator: (value) => _maxLengthValidator(value, 255),
                    maxLength: 255,
                  ),
                  _readOnlyField(
                    const ValueKey('tenant-profile-cpf'),
                    l10n.tenantCpf,
                    user.cpf,
                  ),
                  _readOnlyField(
                    const ValueKey('tenant-profile-birth-date'),
                    l10n.tenantBirthDate,
                    user.birthDate.toIso8601String().split('T').first,
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
                    key: const ValueKey('tenant-profile-submit'),
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.save),
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
        appBar: AppBar(title: Text(l10n.tenantEditProfile)),
        body: _hasUserSession
            ? _buildBody(context)
            : Center(child: Text(l10n.tenantUserAccessRequired)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}
