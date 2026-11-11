enum BookStatus { available, rented }

class Book {
  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisherId,
    required this.quantity,
    required this.status,
    required this.observations,
  });

  final int id;
  final String title;
  final String author;
  final int publisherId;
  final int quantity;
  final BookStatus status;
  final String? observations;

  factory Book.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status']) {
      'AVAILABLE' => BookStatus.available,
      'RENTED' => BookStatus.rented,
      final value => throw FormatException('Status de livro inválido: $value'),
    };

    return Book(
      id: json['id'] as int,
      title: json['title'] as String,
      author: json['author'] as String,
      publisherId: json['publisherId'] as int,
      quantity: json['quantity'] as int,
      status: status,
      observations: json['observations'] as String?,
    );
  }
}

class BookData {
  const BookData({
    required this.title,
    required this.author,
    required this.publisherId,
    required this.quantity,
    this.observations,
  });

  final String title;
  final String author;
  final int publisherId;
  final int quantity;
  final String? observations;

  Map<String, dynamic> toJson() => {
    'title': title,
    'author': author,
    'publisherId': publisherId,
    'quantity': quantity,
    if (observations != null) 'observations': observations,
  };
}
