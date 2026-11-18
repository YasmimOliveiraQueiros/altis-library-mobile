import 'package:flutter/material.dart';

import '../../../core/models/page_response.dart';
import '../../../core/services/http/api_client.dart';
import '../../../core/services/http/api_errors.dart';
import '../../../core/services/routes/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_navigation_shell.dart';
import '../../../core/widgets/user_avatar_menu.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/pages/login_page.dart';
import '../../loans/models/loan.dart';
import '../../loans/services/loan_service.dart';
import '../../users/models/user.dart';
import '../../users/services/user_service.dart';

class TenantDashboardPage extends StatefulWidget {
  const TenantDashboardPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<TenantDashboardPage> createState() => _TenantDashboardPageState();
}

class _TenantDashboardPageState extends State<TenantDashboardPage> {
  static const _pageSize = 10;

  late final UserService _userService;
  late final LoanService _loanService;
  User? _user;
  PageResponse<Loan>? _loansPage;
  bool _isLoading = true;
  bool _isLoadingLoans = false;
  String? _loadError;
  String? _loanError;
  bool _isAuthorized = false;
  late int _authorizedSessionRevision;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.apiClient);
    _loanService = LoanService(widget.apiClient);
    _isAuthorized = widget.apiClient.hasUserSession;
    _authorizedSessionRevision = widget.apiClient.sessionRevision;
    if (_isAuthorized) _loadDashboard();
  }

  void _onAuthenticated() {
    setState(() {
      _isAuthorized = widget.apiClient.hasUserSession;
      _authorizedSessionRevision = widget.apiClient.sessionRevision;
      _user = null;
      _loansPage = null;
      _isLoading = true;
    });
    if (_isAuthorized) _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
      _loanError = null;
    });

    try {
      final results = await Future.wait<Object>([
        _userService.getMyProfile(),
        _loanService.getMyLoans(page: 0, size: _pageSize),
      ]);
      if (!mounted) return;
      setState(() {
        _user = results[0] as User;
        _loansPage = results[1] as PageResponse<Loan>;
        _isLoading = false;
      });
    } on ApiHttpException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = apiHttpErrorMessage(
          error,
          AppLocalizations.of(context)!.tenantDashboardLoadFailed,
          forbiddenFallback: AppLocalizations.of(context)!.accessDenied,
        );
        _isLoading = false;
      });
    } on ApiTransportException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = apiTransportErrorMessage(
          AppLocalizations.of(context)!,
          error,
        );
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = AppLocalizations.of(context)!.tenantDashboardLoadFailed;
        _isLoading = false;
      });
    }
  }

  Future<void> _onProfileUpdated() async {
    await _loadDashboard();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.tenantProfileSaved)),
    );
  }

  Future<void> _loadLoanPage(int page) async {
    setState(() {
      _isLoadingLoans = true;
      _loanError = null;
    });

    try {
      final loans = await _loanService.getMyLoans(page: page, size: _pageSize);
      if (!mounted) return;
      setState(() {
        _loansPage = loans;
        _isLoadingLoans = false;
      });
    } on ApiHttpException catch (error) {
      if (!mounted) return;
      setState(() {
        _loanError = apiHttpErrorMessage(
          error,
          AppLocalizations.of(context)!.tenantLoansLoadFailed,
          forbiddenFallback: AppLocalizations.of(context)!.accessDenied,
        );
        _isLoadingLoans = false;
      });
    } on ApiTransportException catch (error) {
      if (!mounted) return;
      setState(() {
        _loanError = apiTransportErrorMessage(
          AppLocalizations.of(context)!,
          error,
        );
        _isLoadingLoans = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loanError = AppLocalizations.of(context)!.tenantLoansLoadFailed;
        _isLoadingLoans = false;
      });
    }
  }

  String _statusLabel(AppLocalizations l10n, LoanStatus status) {
    return switch (status) {
      LoanStatus.pending => l10n.loanPending,
      LoanStatus.overdue => l10n.loanOverdue,
      LoanStatus.returned => l10n.loanReturned,
      LoanStatus.returnedLate => l10n.loanReturnedLate,
    };
  }

  Color _statusColor(BuildContext context, LoanStatus status) {
    return switch (status) {
      LoanStatus.pending => AppTheme.primaryColor,
      LoanStatus.overdue => Theme.of(context).colorScheme.error,
      LoanStatus.returned => Colors.green.shade700,
      LoanStatus.returnedLate => Colors.deepOrange.shade700,
    };
  }

  Widget _metric({
    required BuildContext context,
    required String label,
    required int value,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              '$value',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loanCard(BuildContext context, Loan loan) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _statusColor(context, loan.status);
    return Card(
      key: ValueKey('tenant-loan-${loan.id}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loan.bookTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Text('${l10n.loanDate}: ${loan.loanDate}'),
                Text('${l10n.loanDueDate}: ${loan.returnDate}'),
                if (loan.returnedAt != null)
                  Text('${l10n.tenantReturnedAt}: ${loan.returnedAt}'),
              ],
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(
                _statusLabel(l10n, loan.status),
                style: TextStyle(color: statusColor),
              ),
              side: BorderSide(color: statusColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = _user;
    final loansPage = _loansPage;
    if (_isLoading && (user == null || loansPage == null)) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null && (user == null || loansPage == null)) {
      return _buildError(context, _loadError!, _loadDashboard);
    }
    if (user == null || loansPage == null) {
      return _buildError(
        context,
        l10n.tenantDashboardLoadFailed,
        _loadDashboard,
      );
    }

    final currentPageCount = loansPage.content.length;
    final pageLabel = loansPage.totalPages == 0 ? 0 : loansPage.number + 1;
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 840),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text('${l10n.email}: ${user.email}'),
                          if (user.phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text('${l10n.tenantPhone}: ${user.phone}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth < 500
                          ? constraints.maxWidth
                          : 240.0;
                      return Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          SizedBox(
                            width: cardWidth,
                            child: _metric(
                              context: context,
                              label: l10n.tenantTotalLoans,
                              value: loansPage.totalElements,
                            ),
                          ),
                          SizedBox(
                            width: cardWidth,
                            child: _metric(
                              context: context,
                              label: l10n.tenantLoansOnPage,
                              value: currentPageCount,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.tenantMyLoans,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (_loadError != null)
                    _inlineError(context, _loadError!, _loadDashboard),
                  if (_loanError != null)
                    _inlineError(
                      context,
                      _loanError!,
                      () => _loadLoanPage(loansPage.number),
                    ),
                  if (_isLoadingLoans) const LinearProgressIndicator(),
                  if (loansPage.empty || loansPage.content.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: Text(l10n.tenantNoLoans)),
                    )
                  else
                    ...loansPage.content.map(
                      (loan) => _loanCard(context, loan),
                    ),
                  if (loansPage.totalPages > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        children: [
                          Text(l10n.pageInfo(pageLabel, loansPage.totalPages)),
                          IconButton(
                            tooltip: l10n.previousPage,
                            onPressed: loansPage.first || _isLoadingLoans
                                ? null
                                : () => _loadLoanPage(loansPage.number - 1),
                            icon: const Icon(Icons.chevron_left),
                          ),
                          IconButton(
                            tooltip: l10n.nextPage,
                            onPressed: loansPage.last || _isLoadingLoans
                                ? null
                                : () => _loadLoanPage(loansPage.number + 1),
                            icon: const Icon(Icons.chevron_right),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    BuildContext context,
    String message,
    Future<void> Function() onRetry,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inlineError(
    BuildContext context,
    String message,
    Future<void> Function() onRetry,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(message)),
          TextButton(onPressed: onRetry, child: Text(l10n.retry)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isMenuOpen = AppNavigationShell.isMenuOpen(context);
    return ValueListenableBuilder<int>(
      valueListenable: widget.apiClient.sessionChanges,
      builder: (context, _, _) {
        final canViewDashboard =
            _isAuthorized &&
            widget.apiClient.hasUserSession &&
            _authorizedSessionRevision == widget.apiClient.sessionRevision;
        if (!canViewDashboard) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.tenantTemporaryAccess)),
            body: LoginPage(
              apiClient: widget.apiClient,
              onAuthenticated: () {
                if (widget.apiClient.hasUserSession) {
                  _onAuthenticated();
                } else {
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
                }
              },
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            leading: const AppNavigationButton(),
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.dashboardBrand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.tenantDashboardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            actions: [
              if (!isMenuOpen || MediaQuery.sizeOf(context).width >= 420)
                IconButton(
                  tooltip: l10n.dashboardRefresh,
                  onPressed: _isLoading ? null : _loadDashboard,
                  icon: const Icon(Icons.refresh),
                ),
              if (!isMenuOpen || MediaQuery.sizeOf(context).width >= 520)
                UserAvatarMenu(
                  apiClient: widget.apiClient,
                  userName: _user?.name,
                  onProfileUpdated: _onProfileUpdated,
                ),
            ],
          ),
          body: _buildContent(context),
        );
      },
    );
  }
}
