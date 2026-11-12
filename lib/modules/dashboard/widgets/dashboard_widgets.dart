import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../loans/models/loan.dart';
import '../../users/models/user.dart';
import '../models/dashboard.dart';

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    super.key,
    required this.id,
    required this.label,
    required this.value,
    required this.dotColor,
  });

  final String id;
  final String label;
  final int value;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: ValueKey('dashboardMetricCard-$id'),
      margin: EdgeInsets.zero,
      color: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFB7C4D0), width: 0.8),
      ),
      child: SizedBox(
        height: 92,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      maxLines: 1,
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$value',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoansByMonthChart extends StatelessWidget {
  const LoansByMonthChart({super.key, required this.months});

  final List<LoansByMonth> months;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (months.isEmpty) return Text(l10n.dashboardNoMonthlyLoans);

    final maxQuantity = months.fold<int>(
      0,
      (maximum, month) => month.quantity > maximum ? month.quantity : maximum,
    );
    final materialLocalizations = MaterialLocalizations.of(context);
    const barAreaHeight = 112.0;

    return SizedBox(
      height: 156,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final item in months)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  children: [
                    SizedBox(
                      height: 20,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('${item.quantity}'),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 18,
                          height: maxQuantity == 0
                              ? 0
                              : barAreaHeight * item.quantity / maxQuantity,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _shortMonth(
                            materialLocalizations,
                            item.year,
                            item.month,
                          ),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
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
}

String _shortMonth(MaterialLocalizations localizations, int year, int month) {
  final formatted = localizations.formatMonthYear(DateTime(year, month));
  final monthName = formatted
      .split(RegExp(r'[\s,./-]+'))
      .where((part) => part.isNotEmpty)
      .firstWhere(
        (part) => !RegExp(r'^\d+$').hasMatch(part),
        orElse: () => '$month',
      );
  return monthName.length > 3 ? monthName.substring(0, 3) : monthName;
}

class BooksByStatusSummary extends StatelessWidget {
  const BooksByStatusSummary({super.key, required this.booksByStatus});

  final BooksByStatus booksByStatus;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = booksByStatus.available + booksByStatus.rented;
    final availableFraction = total == 0
        ? 0.0
        : booksByStatus.available / total;
    final rentedFraction = total == 0 ? 0.0 : booksByStatus.rented / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BookStatusBar(
          label: l10n.dashboardAvailable,
          quantity: booksByStatus.available,
          progress: availableFraction,
          color: Colors.blueGrey.shade200,
        ),
        const SizedBox(height: 14),
        _BookStatusBar(
          label: l10n.dashboardRented,
          quantity: booksByStatus.rented,
          progress: rentedFraction,
          color: Theme.of(context).colorScheme.error,
        ),
      ],
    );
  }
}

class _BookStatusBar extends StatelessWidget {
  const _BookStatusBar({
    required this.label,
    required this.quantity,
    required this.progress,
    required this.color,
  });

  final String label;
  final int quantity;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ($quantity)'),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          color: color,
          backgroundColor: Colors.blueGrey.shade50,
        ),
      ],
    );
  }
}

class RecentLoansSection extends StatelessWidget {
  const RecentLoansSection({
    super.key,
    required this.loans,
    required this.usersById,
    this.userLoadFailed = false,
  });

  final List<Loan> loans;
  final Map<int, User> usersById;
  final bool userLoadFailed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (loans.isEmpty) return Text(l10n.dashboardNoRecentLoans);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (userLoadFailed) ...[
          Text(
            l10n.usersLoadFailed,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 20,
            horizontalMargin: 8,
            columns: [
              DataColumn(label: Text(l10n.loanBook)),
              DataColumn(label: Text(l10n.loanBorrower)),
              DataColumn(label: Text(l10n.loanDueDate)),
            ],
            rows: [
              for (final loan in loans)
                DataRow(
                  cells: [
                    DataCell(
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 180),
                        child: Text(
                          loan.bookTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    DataCell(Text(usersById[loan.userId]?.name ?? '—')),
                    DataCell(Text(loan.returnDate)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
