import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/publisher.dart';

class PublisherListItem extends StatelessWidget {
  const PublisherListItem({
    super.key,
    required this.publisher,
    required this.onEdit,
    required this.onDelete,
  });

  final Publisher publisher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final statusColor = publisher.status == PublisherStatus.active
        ? Colors.green.shade700
        : Colors.grey.shade700;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    publisher.name,
                    style: theme.textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  publisher.status == PublisherStatus.active
                      ? l10n.active
                      : l10n.inactive,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(publisher.email, maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${publisher.cnpj} · ${publisher.city}/${publisher.state}'),
            Text('${l10n.bookCount}: ${publisher.bookCount}'),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                spacing: 4,
                children: [
                  IconButton(
                    tooltip: l10n.editPublisher,
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: l10n.deletePublisher,
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
