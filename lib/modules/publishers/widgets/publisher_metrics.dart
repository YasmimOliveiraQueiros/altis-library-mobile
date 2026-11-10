import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class PublisherMetrics extends StatelessWidget {
  const PublisherMetrics({
    super.key,
    required this.totalPublishers,
    required this.booksOnPage,
  });

  final int totalPublishers;
  final int booksOnPage;

  Widget _buildMetricCard(
    BuildContext context, {
    required String label,
    required int value,
  }) {
    final theme = Theme.of(context);

    return Card(
      color: AppTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$value',
                style: theme.textTheme.titleLarge?.copyWith(
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
          child: _buildMetricCard(
            context,
            label: l10n.publishersMetric,
            value: totalPublishers,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricCard(
            context,
            label: l10n.linkedBooksOnPage,
            value: booksOnPage,
          ),
        ),
      ],
    );
  }
}
