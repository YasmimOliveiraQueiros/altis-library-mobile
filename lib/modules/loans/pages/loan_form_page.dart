import 'package:flutter/material.dart';

import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../books/models/book.dart';
import '../../books/services/book_service.dart';
import '../../users/models/user.dart';
import '../../users/services/user_service.dart';
import '../models/loan.dart';
import '../services/loan_service.dart';

class LoanFormPage extends StatefulWidget {
  const LoanFormPage({
    super.key,
    required this.apiClient,
    required this.loanService,
    this.loan,
  });

  final ApiClient apiClient;
  final LoanService loanService;
  final Loan? loan;

  @override
  State<LoanFormPage> createState() => _LoanFormPageState();
}

class _LoanFormPageState extends State<LoanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _loanDateController = TextEditingController();
  final _returnDateController = TextEditingController();
  final _observationsController = TextEditingController();
  late final UserService _userService;
  late final BookService _bookService;
  List<User> _users = [];
  List<Book> _books = [];
  int? _userId;
  int? _bookId;
  DateTime? _loanDate;
  DateTime? _returnDate;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _loadError;
  String? _saveError;

  bool get _isEditing => widget.loan != null;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.apiClient);
    _bookService = BookService(widget.apiClient);
    final loan = widget.loan;
    _userId = loan?.userId;
    _bookId = loan?.bookId;
    _loanDate = loan == null ? null : DateTime.parse(loan.loanDate);
    _returnDate = loan == null ? null : DateTime.parse(loan.returnDate);
    _observationsController.text = loan?.observations ?? '';
    _loanDateController.text = _apiDate(_loanDate);
    _returnDateController.text = _apiDate(_returnDate);
    _loadOptions();
  }

  Future<void> _loadOptions() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final results = await Future.wait([
        _userService.getAllUsers(),
        _bookService.getAllBooks(),
      ]);
      if (!mounted) return;
      setState(() {
        _users = results[0] as List<User>;
        _books = results[1] as List<Book>;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = AppLocalizations.of(context)!.loanOptionsLoadFailed;
        _isLoading = false;
      });
    }
  }

  String _apiDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickDate({required bool loanDate}) async {
    final selectedDate = loanDate ? _loanDate : _returnDate;
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateUtils.dateOnly(DateTime.now()),
      firstDate: DateTime(1),
      lastDate: DateTime(9999, 12, 31),
    );
    if (date == null || !mounted) return;
    setState(() {
      if (loanDate) {
        _loanDate = date;
        _loanDateController.text = _apiDate(date);
      } else {
        _returnDate = date;
        _returnDateController.text = _apiDate(date);
      }
    });
  }

  Future<void> _save() async {
    if (_isSaving || _isLoading || _loadError != null) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final data = LoanData(
      userId: _userId!,
      bookId: _bookId!,
      loanDate: _apiDate(_loanDate),
      returnDate: _apiDate(_returnDate),
      observations: _observationsController.text.trim().isEmpty
          ? null
          : _observationsController.text.trim(),
    );

    try {
      if (_isEditing) {
        await widget.loanService.updateLoan(widget.loan!.id, data);
      } else {
        await widget.loanService.createLoan(data);
      }
      if (mounted) Navigator.pop(context, true);
    } on LoanRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _saveError = error.statusCode == 400 || error.statusCode == 422
            ? l10n.loanValidationFailed
            : l10n.loanSaveFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saveError = AppLocalizations.of(context)!.loanSaveFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _dateField({
    required String label,
    required TextEditingController controller,
    required bool loanDate,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _pickDate(loanDate: loanDate),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        validator: (_) => (loanDate ? _loanDate : _returnDate) == null
            ? l10n.requiredField
            : null,
      ),
    );
  }

  @override
  void dispose() {
    _loanDateController.dispose();
    _returnDateController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final eligibleUsers = _users
        .where((user) => user.active || user.id == widget.loan?.userId)
        .toList();
    final eligibleBooks = _books
        .where(
          (book) =>
              (book.status == BookStatus.available && book.quantity > 0) ||
              book.id == widget.loan?.bookId,
        )
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editLoan : l10n.addLoan)),
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
                    if (_loadError != null) ...[
                      Text(
                        _loadError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      TextButton.icon(
                        onPressed: _isLoading ? null : _loadOptions,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ] else if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<int>(
                          initialValue: _userId,
                          decoration: InputDecoration(
                            labelText: l10n.loanBorrower,
                            border: const OutlineInputBorder(),
                          ),
                          items: eligibleUsers
                              .map(
                                (user) => DropdownMenuItem(
                                  value: user.id,
                                  child: Text(
                                    user.name,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (id) => setState(() => _userId = id),
                          validator: (id) =>
                              id == null ? l10n.requiredField : null,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<int>(
                          initialValue: _bookId,
                          decoration: InputDecoration(
                            labelText: l10n.loanBook,
                            border: const OutlineInputBorder(),
                          ),
                          items: eligibleBooks
                              .map(
                                (book) => DropdownMenuItem(
                                  value: book.id,
                                  child: Text(
                                    '${book.title} · ${book.quantity}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (id) => setState(() => _bookId = id),
                          validator: (id) =>
                              id == null ? l10n.requiredField : null,
                        ),
                      ),
                      _dateField(
                        label: l10n.loanDate,
                        controller: _loanDateController,
                        loanDate: true,
                      ),
                      _dateField(
                        label: l10n.loanDueDate,
                        controller: _returnDateController,
                        loanDate: false,
                      ),
                      TextFormField(
                        controller: _observationsController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.loanObservations,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                    if (_saveError != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _saveError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSaving
                                ? null
                                : () => Navigator.pop(context, false),
                            child: Text(l10n.cancel),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed:
                                _isSaving || _isLoading || _loadError != null
                                ? null
                                : _save,
                            child: _isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(l10n.save),
                          ),
                        ),
                      ],
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
