import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../publishers/models/publisher.dart';
import '../../publishers/services/publisher_service.dart';
import '../models/book.dart';
import '../services/book_service.dart';

class BookFormPage extends StatefulWidget {
  const BookFormPage({
    super.key,
    required this.service,
    required this.publisherService,
    this.book,
  });

  final BookService service;
  final PublisherService publisherService;
  final Book? book;

  @override
  State<BookFormPage> createState() => _BookFormPageState();
}

class _BookFormPageState extends State<BookFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _quantityController;
  late final TextEditingController _observationsController;
  List<Publisher> _publishers = [];
  int? _selectedPublisherId;
  bool _isLoadingPublishers = true;
  bool _isSaving = false;
  String? _publisherLoadError;
  String? _saveError;

  bool get _isEditing => widget.book != null;

  @override
  void initState() {
    super.initState();
    final book = widget.book;
    _titleController = TextEditingController(text: book?.title ?? '');
    _authorController = TextEditingController(text: book?.author ?? '');
    _quantityController = TextEditingController(
      text: book?.quantity.toString() ?? '',
    );
    _observationsController = TextEditingController(
      text: book?.observations ?? '',
    );
    _selectedPublisherId = book?.publisherId;
    _loadPublishers();
  }

  Future<void> _loadPublishers() async {
    setState(() {
      _isLoadingPublishers = true;
      _publisherLoadError = null;
    });

    try {
      final firstPage = await widget.publisherService.getPublishers(size: 100);
      final publishers = [...firstPage.content];
      for (var page = 1; page < firstPage.totalPages; page++) {
        final nextPage = await widget.publisherService.getPublishers(
          page: page,
          size: 100,
        );
        publishers.addAll(nextPage.content);
      }
      if (!mounted) return;
      setState(() {
        _publishers = publishers;
        _isLoadingPublishers = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _publisherLoadError = AppLocalizations.of(context)!
            .publishersLoadFailed;
        _isLoadingPublishers = false;
      });
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppLocalizations.of(context)!.requiredField;
    }
    return null;
  }

  String? _quantityValidator(String? value) {
    final l10n = AppLocalizations.of(context)!;
    final quantity = int.tryParse(value?.trim() ?? '');
    if (quantity == null) return l10n.invalidBookQuantity;
    if (quantity < 0) return l10n.invalidBookQuantity;
    return null;
  }

  Future<void> _save() async {
    if (_isSaving || _isLoadingPublishers || _publisherLoadError != null) {
      return;
    }
    if (!_formKey.currentState!.validate()) return;
    final publisherId = _selectedPublisherId;
    if (publisherId == null) return;

    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    final data = BookData(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      publisherId: publisherId,
      quantity: int.parse(_quantityController.text.trim()),
      observations: _observationsController.text.trim().isEmpty
          ? null
          : _observationsController.text.trim(),
    );

    try {
      if (_isEditing) {
        await widget.service.updateBook(widget.book!.id, data);
      } else {
        await widget.service.createBook(data);
      }
      if (mounted) Navigator.pop(context, true);
    } on BookRequestException catch (error) {
      if (!mounted) return;
      setState(() {
        final l10n = AppLocalizations.of(context)!;
        _saveError = error.statusCode == 400 || error.statusCode == 422
            ? l10n.bookValidationFailed
            : l10n.bookSaveFailed;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saveError = AppLocalizations.of(context)!.bookSaveFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Widget _textField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        textInputAction: maxLines == 1
            ? TextInputAction.next
            : TextInputAction.newline,
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
    _titleController.dispose();
    _authorController.dispose();
    _quantityController.dispose();
    _observationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? l10n.editBook : l10n.addBook)),
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
                    _textField(
                      controller: _titleController,
                      label: l10n.bookTitle,
                      validator: _requiredValidator,
                    ),
                    _textField(
                      controller: _authorController,
                      label: l10n.bookAuthor,
                      validator: _requiredValidator,
                    ),
                    if (_publisherLoadError != null) ...[
                      Text(
                        _publisherLoadError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      TextButton.icon(
                        onPressed: _isLoadingPublishers
                            ? null
                            : _loadPublishers,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.retry),
                      ),
                    ] else if (_isLoadingPublishers)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: DropdownButtonFormField<int>(
                          initialValue:
                              _publishers.any(
                                (publisher) =>
                                    publisher.id == _selectedPublisherId,
                              )
                              ? _selectedPublisherId
                              : null,
                          decoration: InputDecoration(
                            labelText: l10n.bookPublisher,
                            border: const OutlineInputBorder(),
                          ),
                          items: _publishers
                              .map(
                                (publisher) => DropdownMenuItem(
                                  value: publisher.id,
                                  child: Text(
                                    '${publisher.name} · ${publisher.status == PublisherStatus.active ? l10n.active : l10n.inactive}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (id) {
                            setState(() {
                              _selectedPublisherId = id;
                            });
                          },
                          validator: (id) =>
                              id == null ? l10n.requiredField : null,
                        ),
                      ),
                    _textField(
                      controller: _quantityController,
                      label: l10n.bookQuantity,
                      validator: _quantityValidator,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: false,
                        signed: false,
                      ),
                    ),
                    _textField(
                      controller: _observationsController,
                      label: l10n.bookObservations,
                      validator: (_) => null,
                      maxLines: 4,
                    ),
                    if (_saveError != null) ...[
                      Text(
                        _saveError!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                    ],
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
                                _isSaving ||
                                    _isLoadingPublishers ||
                                    _publisherLoadError != null
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
