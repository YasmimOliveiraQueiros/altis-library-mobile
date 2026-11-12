import 'package:flutter/material.dart';

import '../../../core/services/http/api_client.dart';
import '../../../core/services/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/widgets/admin_login_form.dart';
import '../../users/models/user.dart';
import '../../users/services/user_service.dart';
import '../models/dashboard.dart';
import '../services/dashboard_service.dart';
import '../widgets/dashboard_widgets.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  late final DashboardService _dashboardService;
  late final UserService _userService;
  late bool _isAuthenticated;
  bool _isLoading = false;
  bool _usersLoaded = false;
  bool _userLoadFailed = false;
  String? _errorMessage;
  Dashboard? _dashboard;
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _dashboardService = DashboardService(widget.apiClient);
    _userService = UserService(widget.apiClient);
    _isAuthenticated = widget.apiClient.hasToken;
    if (_isAuthenticated) _loadDashboard();
  }

  void _onAuthenticated() {
    setState(() {
      _isAuthenticated = true;
    });
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final dashboard = await _dashboardService.getDashboard();
      var users = _users;
      var userLoadFailed = false;
      if (!_usersLoaded) {
        try {
          users = await _userService.getAllUsers();
        } catch (_) {
          userLoadFailed = true;
        }
      }
      if (!mounted) return;
      setState(() {
        _dashboard = dashboard;
        _users = users;
        _usersLoaded = !userLoadFailed;
        _userLoadFailed = userLoadFailed;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.dashboardLoadFailed;
        _isLoading = false;
      });
    }
  }

  Widget _section(
    BuildContext context,
    String title,
    Widget child, {
    Widget? action,
  }) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                action ?? const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildDashboard(BuildContext context, Dashboard dashboard) {
    final l10n = AppLocalizations.of(context)!;
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide = constraints.maxWidth >= 700;
        final loansChart = _section(
          context,
          l10n.dashboardLoansByMonth,
          LoansByMonthChart(months: dashboard.loansByMonth),
        );
        final booksChart = _section(
          context,
          l10n.dashboardBooksByStatus,
          BooksByStatusSummary(booksByStatus: dashboard.booksByStatus),
        );
        final metrics = <({String id, String label, int value, Color color})>[
          (
            id: 'books',
            label: l10n.dashboardTotalBooks,
            value: dashboard.totalBooks,
            color: AppTheme.primaryColor,
          ),
          (
            id: 'publishers',
            label: l10n.dashboardTotalPublishers,
            value: dashboard.totalPublishers,
            color: Colors.teal,
          ),
          (
            id: 'rented',
            label: l10n.dashboardRented,
            value: dashboard.activeLoans,
            color: Theme.of(context).colorScheme.error,
          ),
          (
            id: 'users',
            label: l10n.dashboardTotalUsers,
            value: dashboard.totalUsers,
            color: Colors.blueGrey,
          ),
          (
            id: 'pending',
            label: l10n.dashboardPendingLoans,
            value: dashboard.pendingLoans,
            color: Colors.amber.shade800,
          ),
          (
            id: 'overdue',
            label: l10n.dashboardOverdueLoans,
            value: dashboard.overdueLoans,
            color: Theme.of(context).colorScheme.error,
          ),
        ];
        final usersById = {for (final user in _users) user.id: user};
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 840),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < metrics.length; index += 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: DashboardMetricCard(
                              id: metrics[index].id,
                              label: metrics[index].label,
                              value: metrics[index].value,
                              dotColor: metrics[index].color,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DashboardMetricCard(
                              id: metrics[index + 1].id,
                              label: metrics[index + 1].label,
                              value: metrics[index + 1].value,
                              dotColor: metrics[index + 1].color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (sideBySide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: loansChart),
                        const SizedBox(width: 12),
                        Expanded(child: booksChart),
                      ],
                    )
                  else ...[
                    loansChart,
                    booksChart,
                  ],
                  _section(
                    context,
                    l10n.dashboardRecentLoans,
                    RecentLoansSection(
                      loans: dashboard.latestLoans,
                      usersById: usersById,
                      userLoadFailed: _userLoadFailed,
                    ),
                    action: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.loans);
                      },
                      child: Text(l10n.dashboardViewAll),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (!_isAuthenticated) {
      return AdminLoginForm(
        apiClient: widget.apiClient,
        onAuthenticated: _onAuthenticated,
      );
    }
    if (_isLoading && _dashboard == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null && _dashboard == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _loadDashboard,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.retry),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadDashboard,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              if (_dashboard != null) _buildDashboard(context, _dashboard!),
            ],
          ),
        ),
        if (_isLoading)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(),
          ),
        if (_errorMessage != null && _dashboard != null)
          Align(
            alignment: Alignment.topCenter,
            child: Material(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(_errorMessage!, textAlign: TextAlign.center),
              ),
            ),
          ),
      ],
    );
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
            Text(l10n.dashboardBrand),
            Text(
              l10n.dashboardOverview,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        actions: [
          if (_isAuthenticated)
            IconButton(
              tooltip: l10n.dashboardRefresh,
              onPressed: _isLoading ? null : _loadDashboard,
              icon: const Icon(Icons.refresh),
            ),
          const Padding(
            padding: EdgeInsets.only(left: 4, right: 12),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE7EDF2),
              child: Icon(Icons.person_outline, color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }
}
