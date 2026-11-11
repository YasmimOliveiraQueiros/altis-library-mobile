import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class BookMetrics extends StatelessWidget {
  const BookMetrics({
    super.key,
    required this.copiesOnPage,
    required this.booksOnPage,
    required this.totalResults,
  });

  final int copiesOnPage;
  final int booksOnPage;
  final int totalResults;

  Widget _metricCard(
    BuildContext context, {
    required String label,
    required int value,
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
                '$value',
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
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            context,
            label: l10n.bookCopiesOnPage,
            value: copiesOnPage,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _metricCard(
            context,
            label: l10n.booksOnPage,
            value: booksOnPage,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _metricCard(
            context,
            label: l10n.booksTotalInQuery,
            value: totalResults,
          ),
        ),
      ],
    );
  }
}
