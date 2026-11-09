import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/page_response.dart';
import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/services/auth_service.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/user_list_widgets.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  final ApiClient _apiClient = ApiClient();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _searchController = TextEditingController();
  final Set<int> _updatingUserIds = {};

  late final UserService _userService;
  late final AuthService _authService;

  Timer? _searchDebounce;
  bool _isAuthenticated = false;
  bool _isLoggingIn = false;
  bool _isLoading = false;
  String? _loginError;
  String? _errorMessage;
  PageResponse<User>? _usersPage;
  int _pageSize = 10;
  int _requestedPage = 0;

  @override
  void initState() {
    super.initState();
    _userService = UserService(_apiClient);
    _authService = AuthService(_apiClient);
  }

  Future<void> _login() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _loginError = l10n.loginRequiredFields;
      });
      return;
    }

    setState(() {
      _isLoggingIn = true;
      _loginError = null;
    });

    try {
      final token = await _authService.login(email: email, password: password);
      if (!mounted) return;

      _apiClient.setToken(token);
      _passwordController.clear();
      setState(() {
        _isAuthenticated = true;
      });
      await _loadUsers(page: 0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loginError = l10n.loginFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

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
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.admin_panel_settings,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.adminAccess,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                onSubmitted: (_) {
                  if (!_isLoggingIn) _login();
                },
                decoration: InputDecoration(
                  labelText: l10n.password,
                  border: const OutlineInputBorder(),
                ),
              ),
              if (_loginError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _loginError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoggingIn ? null : _login,
                child: _isLoggingIn
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.login),
              ),
            ],
          ),
        ),
      ),
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
    _emailController.dispose();
    _passwordController.dispose();
    _searchController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.usersManagement)),
      body: _isAuthenticated ? _buildAuthenticatedBody() : _buildLoginForm(),
    );
  }
}
