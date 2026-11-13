import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/page_response.dart';
import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/widgets/admin_login_form.dart';
import '../models/publisher.dart';
import '../services/publisher_service.dart';
import '../widgets/publisher_list_item.dart';
import '../widgets/publisher_metrics.dart';
import 'publisher_form_page.dart';

class PublishersPage extends StatefulWidget {
  const PublishersPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<PublishersPage> createState() => _PublishersPageState();
}

class _PublishersPageState extends State<PublishersPage> {
  final _searchController = TextEditingController();

  late final PublisherService _publisherService;
  Timer? _searchDebounce;
  bool _isAuthenticated = false;
  int? _authorizedSessionRevision;
  bool _isLoading = false;
  String? _errorMessage;
  PageResponse<Publisher>? _publishersPage;
  int _pageSize = 10;
  int _requestedPage = 0;

  @override
  void initState() {
    super.initState();
    _publisherService = PublisherService(widget.apiClient);
    _isAuthenticated = widget.apiClient.hasAdminSession;
    if (_isAuthenticated) {
      _authorizedSessionRevision = widget.apiClient.sessionRevision;
      _loadPublishers(page: 0);
    }
  }

  void _onAuthenticated() {
    setState(() {
      _isAuthenticated = true;
      _authorizedSessionRevision = widget.apiClient.sessionRevision;
    });
    _loadPublishers(page: 0);
  }

  bool get _canUseAdminSession =>
      _isAuthenticated &&
      widget.apiClient.hasAdminSession &&
      _authorizedSessionRevision == widget.apiClient.sessionRevision;

  Future<void> _loadPublishers({required int page}) async {
    _requestedPage = page;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _publisherService.getPublishers(
        search: _searchController.text,
        page: page,
        size: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _publishersPage = response;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.publishersLoadFailed;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    setState(() {
      _publishersPage = null;
      _isLoading = true;
      _errorMessage = null;
      _requestedPage = 0;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _loadPublishers(page: 0);
    });
  }

  Future<void> _openForm([Publisher? publisher]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            PublisherFormPage(service: _publisherService, publisher: publisher),
      ),
    );
    if (saved == true && mounted) {
      await _loadPublishers(page: _publishersPage?.number ?? 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.publisherSaved)),
      );
    }
  }

  Future<void> _deletePublisher(Publisher publisher) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deletePublisherTitle),
        content: Text(l10n.deletePublisherMessage(publisher.name)),
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
      await _publisherService.deletePublisher(publisher.id);
      if (!mounted) return;
      await _loadPublishers(page: _publishersPage?.number ?? 0);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.publisherDeleteFailed)));
    }
  }

  Widget _buildPagination(PageResponse<Publisher> page) {
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
                    _loadPublishers(page: 0);
                  },
          ),
          IconButton(
            tooltip: l10n.previousPage,
            onPressed: page.first || _isLoading
                ? null
                : () => _loadPublishers(page: page.number - 1),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: l10n.nextPage,
            onPressed: page.last || _isLoading
                ? null
                : () => _loadPublishers(page: page.number + 1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(PageResponse<Publisher> page) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (page.empty || page.content.isEmpty)
          SizedBox(
            height: 220,
            child: Center(child: Text(l10n.noPublishersFound)),
          )
        else
          ...page.content.map(
            (publisher) => PublisherListItem(
              publisher: publisher,
              onEdit: () => _openForm(publisher),
              onDelete: () => _deletePublisher(publisher),
            ),
          ),
        _buildPagination(page),
      ],
    );
  }

  Widget _buildPageHeader() {
    final l10n = AppLocalizations.of(context)!;
    final booksOnPage =
        _publishersPage?.content.fold<int>(
          0,
          (total, publisher) => total + publisher.bookCount,
        ) ??
        0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PublisherMetrics(
            totalPublishers: _publishersPage?.totalElements ?? 0,
            booksOnPage: booksOnPage,
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _openForm(),
            icon: const Icon(Icons.add),
            label: Text(l10n.addPublisher.toUpperCase()),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedBody() {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        _buildPageHeader(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              labelText: l10n.searchPublishers,
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
                          onPressed: () =>
                              _loadPublishers(page: _requestedPage),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : _publishersPage == null
              ? const Center(child: CircularProgressIndicator())
              : _buildResults(_publishersPage!),
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
              l10n.publisherDashboardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              l10n.publisherDashboardSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
      ),
      body: ValueListenableBuilder<int>(
        valueListenable: widget.apiClient.sessionChanges,
        builder: (context, _, _) => _canUseAdminSession
            ? _buildAuthenticatedBody()
            : AdminLoginForm(
                apiClient: widget.apiClient,
                onAuthenticated: _onAuthenticated,
              ),
      ),
    );
  }
}
