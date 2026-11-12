import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(l10n.loanBorrower)),
          DataColumn(label: Text(l10n.loanBook)),
          DataColumn(label: Text(l10n.loanDate)),
          DataColumn(label: Text(l10n.loanDueDate)),
          DataColumn(label: Text(l10n.loanStatus)),
          DataColumn(label: Text(l10n.actions)),
        ],
        rows: loans.map((loan) {
          final canReturn =
              loan.status == LoanStatus.pending ||
              loan.status == LoanStatus.overdue;
          final isReturning = returningIds.contains(loan.id);
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 170,
                  child: Text(
                    userNames[loan.userId] ??
                        '${l10n.loanBorrower} #${loan.userId}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 180,
                  child: Text(loan.bookTitle, overflow: TextOverflow.ellipsis),
                ),
              ),
              DataCell(Text(loan.loanDate)),
              DataCell(Text(loan.returnDate)),
              DataCell(Text(_statusLabel(l10n, loan.status))),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.editLoan,
                      onPressed: isReturning ? null : () => onEdit(loan),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    if (canReturn)
                      IconButton(
                        tooltip: l10n.returnLoan,
                        onPressed: isReturning ? null : () => onReturn(loan),
                        icon: isReturning
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.assignment_return_outlined),
                      ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n, LoanStatus status) {
    return switch (status) {
      LoanStatus.pending => l10n.loanPending,
      LoanStatus.overdue => l10n.loanOverdue,
      LoanStatus.returned => l10n.loanReturned,
      LoanStatus.returnedLate => l10n.loanReturnedLate,
    };
  }
}
