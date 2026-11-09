enum PublisherStatus { active, inactive }

class Publisher {
  const Publisher({
    required this.id,
    required this.name,
    required this.email,
    required this.cnpj,
    required this.city,
    required this.state,
    required this.bookCount,
    required this.status,
  });

  final int id;
  final String name;
  final String email;
  final String cnpj;
  final String city;
  final String state;
  final int bookCount;
  final PublisherStatus status;

  factory Publisher.fromJson(Map<String, dynamic> json) {
    final status = switch (json['status']) {
      'ACTIVE' => PublisherStatus.active,
      'INACTIVE' => PublisherStatus.inactive,
      final value => throw FormatException(
        'Status de editora inválido: $value',
      ),
    };

    return Publisher(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      cnpj: json['cnpj'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      bookCount: json['bookCount'] as int,
      status: status,
    );
  }
}

class PublisherData {
  const PublisherData({
    required this.name,
    required this.email,
    required this.cnpj,
    required this.city,
    required this.state,
  });

  final String name;
  final String email;
  final String cnpj;
  final String city;
  final String state;

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'cnpj': cnpj,
    'city': city,
    'state': state,
  };
}
