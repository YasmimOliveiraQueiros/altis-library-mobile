import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/book.dart';

class BookTable extends StatelessWidget {
  const BookTable({
    super.key,
    required this.books,
    required this.publisherNames,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Book> books;
  final Map<int, String> publisherNames;
  final ValueChanged<Book> onEdit;
  final ValueChanged<Book> onDelete;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (final book in books)
        BookListItem(
          book: book,
          publisherName: publisherNames[book.publisherId],
          onEdit: () => onEdit(book),
          onDelete: () => onDelete(book),
        ),
    ],
  );
}

class BookListItem extends StatelessWidget {
  const BookListItem({
    super.key,
    required this.book,
    required this.publisherName,
    required this.onEdit,
    required this.onDelete,
  });

  final Book book;
  final String? publisherName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(book.title, style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  tooltip: l10n.editBook,
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: l10n.deleteBook,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('${l10n.bookAuthor}: ${book.author}'),
            Text(
              '${l10n.bookPublisher}: ${publisherName ?? '${l10n.bookPublisher} #${book.publisherId}'}',
            ),
            Text('${l10n.bookQuantity}: ${book.quantity}'),
            Text(
              '${l10n.bookStatus}: ${book.status == BookStatus.available ? l10n.bookAvailable : l10n.bookRented}',
            ),
            if (book.observations?.isNotEmpty == true)
              Text('${l10n.bookObservations}: ${book.observations}'),
          ],
        ),
      ),
    );
  }
}
