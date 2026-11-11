import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/page_response.dart';
import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/widgets/admin_login_form.dart';
import '../../publishers/models/publisher.dart';
import '../../publishers/services/publisher_service.dart';
import '../models/book.dart';
import '../services/book_service.dart';
import '../widgets/book_metrics.dart';
import '../widgets/book_table.dart';
import 'book_form_page.dart';

class BooksPage extends StatefulWidget {
  const BooksPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<BooksPage> createState() => _BooksPageState();
}

class _BooksPageState extends State<BooksPage> {
  final _searchController = TextEditingController();
  late final BookService _bookService;
  late final PublisherService _publisherService;
  Timer? _searchDebounce;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _publisherNamesError;
  PageResponse<Book>? _booksPage;
  List<Publisher> _publishers = [];
  int _pageSize = 10;
  int _requestedPage = 0;
  String _sortBy = 'title';
  String _sortDirection = 'ASC';

  @override
  void initState() {
    super.initState();
    _bookService = BookService(widget.apiClient);
    _publisherService = PublisherService(widget.apiClient);
    _isAuthenticated = widget.apiClient.hasToken;
    if (_isAuthenticated) _loadBooks(page: 0);
  }

  void _onAuthenticated() {
    setState(() {
      _isAuthenticated = true;
    });
    _loadBooks(page: 0);
  }

  Future<void> _loadBooks({required int page}) async {
    _requestedPage = page;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _bookService.getBooks(
        search: _searchController.text,
        page: page,
        size: _pageSize,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );
      if (!mounted) return;
      setState(() {
        _booksPage = response;
        _isLoading = false;
      });
      if (response.empty && response.number > 0) {
        await _loadBooks(page: response.number - 1);
        return;
      }
      if (_publishers.isEmpty && response.content.isNotEmpty) {
        _loadPublisherNames();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.booksLoadFailed;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPublisherNames() async {
    try {
      final firstPage = await _publisherService.getPublishers(size: 100);
      final publishers = [...firstPage.content];
      for (var page = 1; page < firstPage.totalPages; page++) {
        final nextPage = await _publisherService.getPublishers(
          page: page,
          size: 100,
        );
        publishers.addAll(nextPage.content);
      }
      if (mounted) {
        setState(() {
          _publishers = publishers;
          _publisherNamesError = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _publisherNamesError = AppLocalizations.of(context)!
              .publishersLoadFailed;
        });
      }
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    setState(() {
      _booksPage = null;
      _isLoading = true;
      _errorMessage = null;
      _requestedPage = 0;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _loadBooks(page: 0);
    });
  }

  Future<void> _openForm([Book? book]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BookFormPage(
          service: _bookService,
          publisherService: _publisherService,
          book: book,
        ),
      ),
    );
    if (saved == true && mounted) {
      await _loadBooks(page: _booksPage?.number ?? 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.bookSaved)),
      );
    }
  }

  Future<void> _deleteBook(Book book) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBookTitle),
        content: Text(l10n.deleteBookMessage(book.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _bookService.deleteBook(book.id);
      if (!mounted) return;
      await _loadBooks(page: _booksPage?.number ?? 0);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.bookDeleteFailed)));
    }
  }

  Widget _buildPagination(PageResponse<Book> page) {
    final l10n = AppLocalizations.of(context)!;
    final currentPage = page.totalPages == 0 ? 0 : page.number + 1;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          Text(l10n.pageInfo(currentPage, page.totalPages)),
          Text(l10n.rowsPerPage),
          DropdownButton<int>(
            value: _pageSize,
            items: const [10, 20, 50]
                .map(
                  (size) => DropdownMenuItem(value: size, child: Text('$size')),
                )
                .toList(),
            onChanged: _isLoading
                ? null
                : (size) {
                    if (size == null) return;
                    setState(() {
                      _pageSize = size;
                    });
                    _loadBooks(page: 0);
                  },
          ),
          IconButton(
            tooltip: l10n.previousPage,
            onPressed: page.first || _isLoading
                ? null
                : () => _loadBooks(page: page.number - 1),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: l10n.nextPage,
            onPressed: page.last || _isLoading
                ? null
                : () => _loadBooks(page: page.number + 1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(PageResponse<Book> page) {
    final l10n = AppLocalizations.of(context)!;
    final publishersById = {
      for (final publisher in _publishers) publisher.id: publisher.name,
    };
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        if (page.empty || page.content.isEmpty)
          SizedBox(height: 180, child: Center(child: Text(l10n.noBooksFound)))
        else
          BookTable(
            books: page.content,
            publisherNames: publishersById,
            onEdit: _openForm,
            onDelete: _deleteBook,
          ),
        _buildPagination(page),
      ],
    );
  }

  Widget _buildHeader() {
    final l10n = AppLocalizations.of(context)!;
    final books = _booksPage?.content ?? const <Book>[];
    final copiesOnPage = books.fold<int>(
      0,
      (total, book) => total + book.quantity,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BookMetrics(
            copiesOnPage: copiesOnPage,
            booksOnPage: books.length,
            totalResults: _booksPage?.totalElements ?? 0,
          ),
          if (_publisherNamesError != null)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _loadPublisherNames,
                icon: const Icon(Icons.refresh),
                label: Text(_publisherNamesError!),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _openForm(),
            icon: const Icon(Icons.add),
            label: Text(l10n.addBook.toUpperCase()),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedBody() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              labelText: l10n.searchBooks,
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.clearSearch,
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  decoration: InputDecoration(
                    labelText: l10n.sortBooksBy,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(value: 'id', child: Text(l10n.bookId)),
                    DropdownMenuItem(
                      value: 'title',
                      child: Text(l10n.bookTitle),
                    ),
                    DropdownMenuItem(
                      value: 'author',
                      child: Text(l10n.bookAuthor),
                    ),
                    DropdownMenuItem(
                      value: 'quantity',
                      child: Text(l10n.bookQuantity),
                    ),
                    DropdownMenuItem(
                      value: 'status',
                      child: Text(l10n.bookStatus),
                    ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _sortBy = value;
                          });
                          _loadBooks(page: 0);
                        },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: _sortDirection == 'ASC'
                    ? l10n.sortDescending
                    : l10n.sortAscending,
                onPressed: _isLoading
                    ? null
                    : () {
                        setState(() {
                          _sortDirection = _sortDirection == 'ASC'
                              ? 'DESC'
                              : 'ASC';
                        });
                        _loadBooks(page: 0);
                      },
                icon: Icon(
                  _sortDirection == 'ASC'
                      ? Icons.arrow_upward
                      : Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ),
        if (_isLoading) const LinearProgressIndicator(),
        Expanded(
          child: _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _loadBooks(page: _requestedPage),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : _booksPage == null
              ? const Center(child: CircularProgressIndicator())
              : _buildResults(_booksPage!),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.bookDashboardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              l10n.bookDashboardSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      body: _isAuthenticated
          ? _buildAuthenticatedBody()
          : AdminLoginForm(
              apiClient: widget.apiClient,
              onAuthenticated: _onAuthenticated,
            ),
    );
  }
}
