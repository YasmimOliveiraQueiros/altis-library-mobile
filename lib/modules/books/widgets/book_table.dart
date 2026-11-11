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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text(l10n.bookTitle)),
          DataColumn(label: Text(l10n.bookAuthor)),
          DataColumn(label: Text(l10n.bookPublisher)),
          DataColumn(label: Text(l10n.bookQuantity)),
          DataColumn(label: Text(l10n.bookStatus)),
          DataColumn(label: Text(l10n.bookObservations)),
          DataColumn(label: Text(l10n.actions)),
        ],
        rows: books.map((book) {
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  width: 180,
                  child: Text(book.title, overflow: TextOverflow.ellipsis),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(book.author, overflow: TextOverflow.ellipsis),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 150,
                  child: Text(
                    publisherNames[book.publisherId] ??
                        '${l10n.bookPublisher} #${book.publisherId}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(Text('${book.quantity}')),
              DataCell(
                Text(
                  book.status == BookStatus.available
                      ? l10n.bookAvailable
                      : l10n.bookRented,
                ),
              ),
              DataCell(
                SizedBox(
                  width: 180,
                  child: Text(
                    book.observations ?? '—',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: l10n.editBook,
                      onPressed: () => onEdit(book),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: l10n.deleteBook,
                      onPressed: () => onDelete(book),
                      icon: const Icon(Icons.delete_outline),
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
}
