import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/publisher.dart';
import '../services/publisher_service.dart';

class PublisherFormPage extends StatefulWidget {
  const PublisherFormPage({super.key, required this.service, this.publisher});

  final PublisherService service;
  final Publisher? publisher;

  @override
  State<PublisherFormPage> createState() => _PublisherFormPageState();
}

class _PublisherFormPageState extends State<PublisherFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _cnpjController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  bool _isSaving = false;
  String? _errorMessage;

  bool get _isEditing => widget.publisher != null;

  @override
  void initState() {
    super.initState();
    final publisher = widget.publisher;
    _nameController = TextEditingController(text: publisher?.name ?? '');
    _emailController = TextEditingController(text: publisher?.email ?? '');
    _cnpjController = TextEditingController(text: publisher?.cnpj ?? '');
    _cityController = TextEditingController(text: publisher?.city ?? '');
    _stateController = TextEditingController(text: publisher?.state ?? '');
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
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final data = PublisherData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      cnpj: _cnpjController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
    );

    try {
      if (_isEditing) {
        await widget.service.updatePublisher(widget.publisher!.id, data);
      } else {
        await widget.service.createPublisher(data);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.publisherSaveFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cnpjController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editPublisher : l10n.addPublisher),
      ),
      body: SafeArea(
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
                    _buildTextField(
                      controller: _nameController,
                      label: l10n.name,
                      validator: _requiredValidator,
                    ),
                    _buildTextField(
                      controller: _emailController,
                      label: l10n.email,
                      validator: _emailValidator,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    _buildTextField(
                      controller: _cnpjController,
                      label: l10n.cnpj,
                      validator: _requiredValidator,
                      keyboardType: TextInputType.text,
                    ),
                    _buildTextField(
                      controller: _cityController,
                      label: l10n.city,
                      validator: _requiredValidator,
                    ),
                    _buildTextField(
                      controller: _stateController,
                      label: l10n.state,
                      validator: _requiredValidator,
                    ),
                    if (_errorMessage != null) ...[
                      Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
                    FilledButton(
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
      ),
    );
  }
}
