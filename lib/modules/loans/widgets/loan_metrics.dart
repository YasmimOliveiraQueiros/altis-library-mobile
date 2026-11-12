import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class LoanMetrics extends StatelessWidget {
  const LoanMetrics({
    super.key,
    required this.pending,
    required this.overdue,
    required this.returned,
    required this.total,
  });

  final int? pending;
  final int? overdue;
  final int? returned;
  final int? total;

  Widget _metricCard(
    BuildContext context, {
    required String label,
    required int? value,
  }) {
    return Card(
      color: AppTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value?.toString() ?? '—',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _metricCard(
                context,
                label: l10n.loanPendingMetric,
                value: pending,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _metricCard(
                context,
                label: l10n.loanOverdueMetric,
                value: overdue,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _metricCard(
                context,
                label: l10n.loanReturnedMetric,
                value: returned,
              ),
            ),
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 160,
            child: _metricCard(
              context,
              label: l10n.loanTotalMetric,
              value: total,
            ),
          ),
        ),
      ],
    );
  }
}
