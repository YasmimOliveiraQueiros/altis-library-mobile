import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/page_response.dart';
import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/widgets/admin_login_form.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/user_list_widgets.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final _searchController = TextEditingController();
  final Set<int> _updatingUserIds = {};

  late final UserService _userService;

  Timer? _searchDebounce;
  bool _isAuthenticated = false;
  int? _authorizedSessionRevision;
  bool _isLoading = false;
  String? _errorMessage;
  PageResponse<User>? _usersPage;
  int _pageSize = 10;
  int _requestedPage = 0;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.apiClient);
    _isAuthenticated = widget.apiClient.hasAdminSession;
    if (_isAuthenticated) {
      _authorizedSessionRevision = widget.apiClient.sessionRevision;
      _loadUsers(page: 0);
    }
  }

  void _onAuthenticated() {
    setState(() {
      _isAuthenticated = true;
      _authorizedSessionRevision = widget.apiClient.sessionRevision;
    });
    _loadUsers(page: 0);
  }

  bool get _canUseAdminSession =>
      _isAuthenticated &&
      widget.apiClient.hasAdminSession &&
      _authorizedSessionRevision == widget.apiClient.sessionRevision;

  Future<void> _loadUsers({required int page}) async {
    _requestedPage = page;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _userService.getUsers(
        search: _searchController.text,
        page: page,
        size: _pageSize,
      );
      if (!mounted) return;
      setState(() {
        _usersPage = response;
        _errorMessage = null;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.usersLoadFailed;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    setState(() {
      _usersPage = null;
      _isLoading = true;
      _errorMessage = null;
      _requestedPage = 0;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) {
        _loadUsers(page: 0);
      }
    });
  }

  Future<void> _updateUserStatus(User user, bool active) async {
    final l10n = AppLocalizations.of(context)!;
    final action = active ? l10n.activateAction : l10n.deactivateAction;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmStatusTitle),
        content: Text(l10n.confirmStatusMessage(user.name, action)),
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

    setState(() {
      _updatingUserIds.add(user.id);
    });

    try {
      await _userService.setUserActive(user.id, active: active);
      if (!mounted) return;
      await _loadUsers(page: _usersPage?.number ?? 0);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.statusUpdateFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _updatingUserIds.remove(user.id);
        });
      }
    }
  }

  Widget _buildLoginForm() {
    return AdminLoginForm(
      apiClient: widget.apiClient,
      onAuthenticated: _onAuthenticated,
    );
  }

  Widget _buildPagination(PageResponse<User> page) {
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
                    _loadUsers(page: 0);
                  },
          ),
          IconButton(
            tooltip: l10n.previousPage,
            onPressed: page.first || _isLoading
                ? null
                : () => _loadUsers(page: page.number - 1),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: l10n.nextPage,
            onPressed: page.last || _isLoading
                ? null
                : () => _loadUsers(page: page.number + 1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(PageResponse<User> page) {
    final l10n = AppLocalizations.of(context)!;
    final activeCount = page.content.where((user) => user.active).length;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        UserMetrics(
          totalResults: page.totalElements,
          activeOnPage: activeCount,
          inactiveOnPage: page.content.length - activeCount,
        ),
        const SizedBox(height: 12),
        if (page.empty || page.content.isEmpty)
          SizedBox(height: 220, child: Center(child: Text(l10n.noUsersFound)))
        else
          ...page.content.map(
            (user) => UserListItem(
              user: user,
              isUpdating: _updatingUserIds.contains(user.id),
              onStatusChanged: _isLoading
                  ? null
                  : (active) => _updateUserStatus(user, active),
            ),
          ),
        _buildPagination(page),
      ],
    );
  }

  Widget _buildAuthenticatedBody() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              labelText: l10n.searchUsers,
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
                          onPressed: () => _loadUsers(page: _requestedPage),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : _usersPage == null
              ? const Center(child: CircularProgressIndicator())
              : _buildResults(_usersPage!),
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
      appBar: AppBar(title: Text(l10n.usersManagement)),
      body: ValueListenableBuilder<int>(
        valueListenable: widget.apiClient.sessionChanges,
        builder: (context, _, _) =>
            _canUseAdminSession ? _buildAuthenticatedBody() : _buildLoginForm(),
      ),
    );
  }
}
