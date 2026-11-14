import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../widgets/auth_input_formatters.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  DateTime? _birthDate;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final initialDate = _birthDate ?? now;
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (!mounted || selectedDate == null) return;

    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    setState(() {
      _birthDate = date;
      _birthDateController.text = MaterialLocalizations.of(context)
          .formatMediumDate(date);
    });
  }

  String? _validateRequired(String? value, AppLocalizations l10n) {
    return (value?.trim().isEmpty ?? true) ? l10n.requiredField : null;
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return l10n.requiredField;
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return l10n.invalidEmail;
    }
    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthDateController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
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
                    vertical: 28,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight > 56
                          ? constraints.maxHeight - 56
                          : 0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Form(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                l10n.registerTitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                key: const ValueKey('registration-name'),
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    _validateRequired(value, l10n),
                                decoration: InputDecoration(
                                  labelText: l10n.registerFullName,
                                  prefixIcon: const Icon(Icons.person_outline),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('registration-birth-date'),
                                controller: _birthDateController,
                                readOnly: true,
                                onTap: _selectBirthDate,
                                validator: (_) => _birthDate == null
                                    ? l10n.requiredField
                                    : null,
                                decoration: InputDecoration(
                                  labelText: l10n.tenantBirthDate,
                                  prefixIcon: const Icon(
                                    Icons.calendar_month_outlined,
                                  ),
                                  suffixIcon: const Icon(Icons.arrow_drop_down),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('registration-cpf'),
                                controller: _cpfController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [CpfInputFormatter()],
                                validator: (value) =>
                                    _validateRequired(value, l10n),
                                decoration: InputDecoration(
                                  labelText: l10n.tenantCpf,
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  hintText: '000.000.000-00',
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('registration-phone'),
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [PhoneInputFormatter()],
                                validator: (value) =>
                                    _validateRequired(value, l10n),
                                decoration: InputDecoration(
                                  labelText: l10n.tenantPhone,
                                  prefixIcon: const Icon(Icons.phone_outlined),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('registration-address'),
                                controller: _addressController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    _validateRequired(value, l10n),
                                decoration: InputDecoration(
                                  labelText: l10n.tenantAddress,
                                  prefixIcon: const Icon(Icons.home_outlined),
                                  border: const OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey('registration-email'),
                                controller: _emailController,
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
                                key: const ValueKey('registration-password'),
                                controller: _passwordController,
                                obscureText: !_isPasswordVisible,
                                textInputAction: TextInputAction.next,
                                validator: (value) =>
                                    _validateRequired(value, l10n),
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
                              const SizedBox(height: 16),
                              TextFormField(
                                key: const ValueKey(
                                  'registration-confirm-password',
                                ),
                                controller: _confirmPasswordController,
                                obscureText: !_isConfirmPasswordVisible,
                                textInputAction: TextInputAction.done,
                                validator: (value) {
                                  final requiredError = _validateRequired(
                                    value,
                                    l10n,
                                  );
                                  if (requiredError != null) {
                                    return requiredError;
                                  }
                                  if (value != _passwordController.text) {
                                    return l10n.tenantPasswordsDoNotMatch;
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: l10n.registerConfirmPassword,
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
                              const SizedBox(height: 20),
                              Semantics(
                                liveRegion: true,
                                child: Text(
                                  l10n.registrationUnavailable,
                                  key: const ValueKey(
                                    'registration-unavailable',
                                  ),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 48,
                                child: FilledButton(
                                  onPressed: null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    shape: const RoundedRectangleBorder(),
                                  ),
                                  child: Text(l10n.registerButton),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  child: Text(l10n.backToLogin),
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
