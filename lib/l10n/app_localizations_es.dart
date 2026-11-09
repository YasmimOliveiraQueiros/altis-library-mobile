// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get name => 'Nombre';

  @override
  String get adminAccess => 'Acceso administrativo';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get loginRequiredFields =>
      'Introduce el correo electrónico y la contraseña.';

  @override
  String get loginFailed => 'No se pudo iniciar sesión.';

  @override
  String get usersManagement => 'Gestión de usuarios';

  @override
  String get searchUsers => 'Buscar por nombre o correo electrónico';

  @override
  String get clearSearch => 'Borrar búsqueda';

  @override
  String get totalUsers => 'Total de resultados';

  @override
  String get activeOnPage => 'Activos en esta página';

  @override
  String get inactiveOnPage => 'Inactivos en esta página';

  @override
  String get profile => 'Perfil';

  @override
  String get administrator => 'Administrador';

  @override
  String get standardUser => 'Usuario';

  @override
  String get active => 'Activo';

  @override
  String get inactive => 'Inactivo';

  @override
  String get activateUser => 'Activar usuario';

  @override
  String get deactivateUser => 'Desactivar usuario';

  @override
  String get confirmStatusTitle => 'Confirmar cambio';

  @override
  String confirmStatusMessage(Object action, Object name) {
    return '¿Deseas $action a $name?';
  }

  @override
  String get activateAction => 'activar';

  @override
  String get deactivateAction => 'desactivar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get statusUpdateFailed =>
      'No se pudo actualizar el estado del usuario.';

  @override
  String get usersLoadFailed => 'No se pudieron cargar los usuarios.';

  @override
  String get retry => 'Intentar de nuevo';

  @override
  String get noUsersFound => 'No se encontraron usuarios.';

  @override
  String pageInfo(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get rowsPerPage => 'Elementos por página';

  @override
  String get previousPage => 'Página anterior';

  @override
  String get nextPage => 'Página siguiente';
}
