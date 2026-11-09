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
  String get manageUsers => 'Administrar usuarios';

  @override
  String get managePublishers => 'Administrar editoriales';

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

  @override
  String get publishersManagement => 'Gestión de editoriales';

  @override
  String get searchPublishers =>
      'Buscar editoriales por nombre o correo electrónico';

  @override
  String get noPublishersFound => 'No se encontraron editoriales.';

  @override
  String get publishersLoadFailed => 'No se pudieron cargar las editoriales.';

  @override
  String get publisherSaveFailed => 'No se pudo guardar la editorial.';

  @override
  String get publisherDeleteFailed => 'No se pudo eliminar la editorial.';

  @override
  String get addPublisher => 'Añadir editorial';

  @override
  String get editPublisher => 'Editar editorial';

  @override
  String get deletePublisher => 'Eliminar editorial';

  @override
  String get deletePublisherTitle => 'Confirmar eliminación';

  @override
  String deletePublisherMessage(Object name) {
    return '¿Deseas eliminar la editorial $name?';
  }

  @override
  String get cnpj => 'CNPJ';

  @override
  String get city => 'Ciudad';

  @override
  String get state => 'Estado';

  @override
  String get bookCount => 'Libros vinculados';

  @override
  String get requiredField => 'Este campo es obligatorio.';

  @override
  String get invalidEmail => 'Introduce un correo electrónico válido.';

  @override
  String get save => 'Guardar';
}
