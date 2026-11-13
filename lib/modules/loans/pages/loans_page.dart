import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/page_response.dart';
import '../../../core/services/http/api_client.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/widgets/admin_login_form.dart';
import '../../users/models/user.dart';
import '../../users/services/user_service.dart';
import '../models/loan.dart';
import '../services/loan_service.dart';
import '../widgets/loan_metrics.dart';
import '../widgets/loan_table.dart';
import 'loan_form_page.dart';

class LoansPage extends StatefulWidget {
  const LoansPage({super.key, required this.apiClient});

  final ApiClient apiClient;

  @override
  State<LoansPage> createState() => _LoansPageState();
}

class _LoansPageState extends State<LoansPage> {
  final _searchController = TextEditingController();
  late final LoanService _loanService;
  late final UserService _userService;
  Timer? _searchDebounce;
  bool _isAuthenticated = false;
  int? _authorizedSessionRevision;
  bool _isLoading = false;
  String? _errorMessage;
  bool _metricsError = false;
  PageResponse<Loan>? _loansPage;
  List<User> _users = [];
  final Set<int> _returningIds = {};
  int? _pendingCount;
  int? _overdueCount;
  int? _returnedCount;
  int? _totalCount;
  int _pageSize = 10;
  int _requestedPage = 0;
  LoanStatus? _statusFilter;
  final String _sortBy = 'loanDate';
  String _sortDirection = 'DESC';

  @override
  void initState() {
    super.initState();
    _loanService = LoanService(widget.apiClient);
    _userService = UserService(widget.apiClient);
    _isAuthenticated = widget.apiClient.hasAdminSession;
    if (_isAuthenticated) {
      _authorizedSessionRevision = widget.apiClient.sessionRevision;
    }
    if (_isAuthenticated) _loadLoans(page: 0);
  }

  void _onAuthenticated() {
    setState(() {
      _isAuthenticated = true;
      _authorizedSessionRevision = widget.apiClient.sessionRevision;
    });
    _loadLoans(page: 0);
  }

  bool get _canUseAdminSession =>
      _isAuthenticated &&
      widget.apiClient.hasAdminSession &&
      _authorizedSessionRevision == widget.apiClient.sessionRevision;

  Future<void> _loadLoans({required int page}) async {
    _requestedPage = page;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        _loanService.getLoans(
          name: _searchController.text,
          status: _statusFilter,
          page: page,
          size: _pageSize,
          sortBy: _sortBy,
          sortDirection: _sortDirection,
        ),
        _loadMetrics(),
        if (_users.isEmpty)
          _userService.getAllUsers()
        else
          Future.value(_users),
      ]);
      if (!mounted) return;
      final loansPage = results[0] as PageResponse<Loan>;
      final metrics = results[1] as _LoanMetricValues;
      final users = results[2] as List<User>;
      setState(() {
        _loansPage = loansPage;
        _users = users;
        _pendingCount = metrics.pending;
        _overdueCount = metrics.overdue;
        _returnedCount = metrics.returned;
        _totalCount = metrics.total;
        _metricsError = metrics.error;
        _isLoading = false;
      });
      if (loansPage.empty && loansPage.number > 0) {
        await _loadLoans(page: loansPage.number - 1);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.loansLoadFailed;
        _isLoading = false;
      });
    }
  }

  Future<_LoanMetricValues> _loadMetrics() async {
    try {
      final search = _searchController.text;
      final results = await Future.wait(
        <LoanStatus?>[
          LoanStatus.pending,
          LoanStatus.overdue,
          LoanStatus.returned,
          LoanStatus.returnedLate,
          null,
        ].map(
          (status) => _loanService.getLoans(
            name: search,
            status: status,
            page: 0,
            size: 1,
            sortBy: _sortBy,
            sortDirection: _sortDirection,
          ),
        ),
      );
      return _LoanMetricValues(
        pending: results[0].totalElements,
        overdue: results[1].totalElements,
        returned: results[2].totalElements + results[3].totalElements,
        total: results[4].totalElements,
      );
    } catch (_) {
      return const _LoanMetricValues(error: true);
    }
  }

  void _onSearchChanged(String _) {
    _searchDebounce?.cancel();
    setState(() {
      _loansPage = null;
      _isLoading = true;
      _errorMessage = null;
      _requestedPage = 0;
    });
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _loadLoans(page: 0);
    });
  }

  Future<void> _openForm([Loan? loan]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LoanFormPage(
          apiClient: widget.apiClient,
          loanService: _loanService,
          loan: loan,
        ),
      ),
    );
    if (saved == true && mounted) {
      await _loadLoans(page: _loansPage?.number ?? 0);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.loanSaved)),
      );
    }
  }

  Future<void> _returnLoan(Loan loan) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.returnLoanTitle),
        content: Text(l10n.returnLoanMessage(loan.bookTitle)),
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
      _returningIds.add(loan.id);
    });
    try {
      await _loanService.returnLoan(loan.id);
      if (!mounted) return;
      await _loadLoans(page: _loansPage?.number ?? 0);
    } on LoanRequestException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_writeErrorMessage(l10n, error.statusCode))),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.loanReturnFailed)));
    } finally {
      if (mounted) {
        setState(() {
          _returningIds.remove(loan.id);
        });
      }
    }
  }

  String _writeErrorMessage(AppLocalizations l10n, int statusCode) {
    return statusCode == 400 || statusCode == 422
        ? l10n.loanValidationFailed
        : l10n.loanSaveFailed;
  }

  String _statusLabel(AppLocalizations l10n, LoanStatus status) {
    return switch (status) {
      LoanStatus.pending => l10n.loanPending,
      LoanStatus.overdue => l10n.loanOverdue,
      LoanStatus.returned => l10n.loanReturned,
      LoanStatus.returnedLate => l10n.loanReturnedLate,
    };
  }

  Widget _buildMetrics() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoanMetrics(
            pending: _pendingCount,
            overdue: _overdueCount,
            returned: _returnedCount,
            total: _totalCount,
          ),
          if (_metricsError)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _isLoading ? null : () => _loadLoans(page: 0),
                icon: const Icon(Icons.refresh),
                label: Text(l10n.loanMetricsLoadFailed),
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: _isLoading ? null : () => _openForm(),
            icon: const Icon(Icons.add),
            label: Text(l10n.addLoan.toUpperCase()),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(PageResponse<Loan> page) {
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
                    _loadLoans(page: 0);
                  },
          ),
          IconButton(
            tooltip: l10n.previousPage,
            onPressed: page.first || _isLoading
                ? null
                : () => _loadLoans(page: page.number - 1),
            icon: const Icon(Icons.chevron_left),
          ),
          IconButton(
            tooltip: l10n.nextPage,
            onPressed: page.last || _isLoading
                ? null
                : () => _loadLoans(page: page.number + 1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(PageResponse<Loan> page) {
    final l10n = AppLocalizations.of(context)!;
    final userNames = {for (final user in _users) user.id: user.name};
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
      children: [
        if (page.empty || page.content.isEmpty)
          SizedBox(height: 180, child: Center(child: Text(l10n.noLoansFound)))
        else
          LoanTable(
            loans: page.content,
            userNames: userNames,
            returningIds: _returningIds,
            onEdit: _openForm,
            onReturn: _returnLoan,
          ),
        _buildPagination(page),
      ],
    );
  }

  Widget _buildAuthenticatedBody() {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildMetrics(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              labelText: l10n.searchLoans,
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
                child: DropdownButtonFormField<LoanStatus?>(
                  initialValue: _statusFilter,
                  decoration: InputDecoration(
                    labelText: l10n.filterLoanStatus,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem<LoanStatus?>(
                      value: null,
                      child: Text(l10n.allLoanStatuses),
                    ),
                    for (final status in LoanStatus.values)
                      DropdownMenuItem<LoanStatus?>(
                        value: status,
                        child: Text(_statusLabel(l10n, status)),
                      ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (status) {
                          setState(() {
                            _statusFilter = status;
                          });
                          _loadLoans(page: 0);
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
                        _loadLoans(page: 0);
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
                          onPressed: () => _loadLoans(page: _requestedPage),
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : _loansPage == null
              ? const Center(child: CircularProgressIndicator())
              : _buildResults(_loansPage!),
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
              l10n.loanDashboardTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              l10n.loanDashboardSubtitle,
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

class _LoanMetricValues {
  const _LoanMetricValues({
    this.pending,
    this.overdue,
    this.returned,
    this.total,
    this.error = false,
  });

  final int? pending;
  final int? overdue;
  final int? returned;
  final int? total;
  final bool error;
}
