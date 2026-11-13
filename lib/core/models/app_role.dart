enum AppRole {
  admin('ADMIN'),
  user('USER');

  const AppRole(this.apiValue);

  final String apiValue;

  static AppRole? fromApiValue(Object? value) => switch (value) {
    'ADMIN' => AppRole.admin,
    'USER' => AppRole.user,
    _ => null,
  };
}
