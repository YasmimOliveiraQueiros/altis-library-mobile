import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../models/loan.dart';

class LoanTable extends StatelessWidget {
  const LoanTable({
    super.key,
    required this.loans,
    required this.userNames,
    required this.returningIds,
    required this.onEdit,
    required this.onReturn,
  });

  final List<Loan> loans;
  final Map<int, String> userNames;
  final Set<int> returningIds;
  final ValueChanged<Loan> onEdit;
  final ValueChanged<Loan> onReturn;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final loan in loans)
        LoanListItem(
          loan: loan,
          userName: userNames[loan.userId],
          isReturning: returningIds.contains(loan.id),
          onEdit: () => onEdit(loan),
          onReturn: () => onReturn(loan),
        ),
    ],
  );
}

class LoanListItem extends StatelessWidget {
  const LoanListItem({
    super.key,
    required this.loan,
    required this.userName,
    required this.isReturning,
    required this.onEdit,
    required this.onReturn,
  });

  final Loan loan;
  final String? userName;
  final bool isReturning;
  final VoidCallback onEdit;
  final VoidCallback onReturn;

  String _statusLabel(AppLocalizations l10n) => switch (loan.status) {
    LoanStatus.pending => l10n.loanPending,
    LoanStatus.overdue => l10n.loanOverdue,
    LoanStatus.returned => l10n.loanReturned,
    LoanStatus.returnedLate => l10n.loanReturnedLate,
  };

  Color _statusColor(BuildContext context) => switch (loan.status) {
    LoanStatus.pending => AppTheme.primaryColor,
    LoanStatus.overdue => Theme.of(context).colorScheme.error,
    LoanStatus.returned => Colors.green.shade700,
    LoanStatus.returnedLate => Colors.deepOrange.shade700,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statusColor = _statusColor(context);
    final canReturn =
        loan.status == LoanStatus.pending || loan.status == LoanStatus.overdue;
    final borrower = userName ?? '${l10n.loanBorrower} #${loan.userId}';
    return Card(
      key: ValueKey('loan-card-${loan.id}'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    loan.bookTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l10n.editLoan,
                  onPressed: isReturning ? null : onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                if (canReturn)
                  IconButton(
                    tooltip: l10n.returnLoan,
                    onPressed: isReturning ? null : onReturn,
                    icon: isReturning
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.assignment_return_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${l10n.loanBorrower}: $borrower'),
            Text('${l10n.loanDate}: ${loan.loanDate}'),
            Text('${l10n.loanDueDate}: ${loan.returnDate}'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel(l10n),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
