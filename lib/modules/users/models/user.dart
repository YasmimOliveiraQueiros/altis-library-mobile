class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String cpf;
  final DateTime birthDate;
  final String address;
  final bool isAdmin;
  final bool active;
  final String createdAt;
  final String updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.cpf,
    required this.birthDate,
    required this.address,
    required this.isAdmin,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      cpf: json['cpf'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      address: json['address'] as String,
      isAdmin: json['isAdmin'] as bool,
      active: json['active'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }
}
