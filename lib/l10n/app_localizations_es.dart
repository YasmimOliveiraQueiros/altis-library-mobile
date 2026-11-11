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
  String get manageBooks => 'Administrar libros';

  @override
  String get bookDashboardTitle => 'Altis+ Biblioteca';

  @override
  String get bookDashboardSubtitle => 'Gestión de libros';

  @override
  String get bookCopiesOnPage => 'Ejemplares en esta página';

  @override
  String get booksOnPage => 'Libros en esta página';

  @override
  String get booksTotalInQuery => 'Total en resultados';

  @override
  String get addBook => 'Nuevo libro';

  @override
  String get editBook => 'Editar libro';

  @override
  String get deleteBook => 'Eliminar libro';

  @override
  String get deleteBookTitle => 'Confirmar eliminación';

  @override
  String deleteBookMessage(Object title) {
    return '¿Deseas eliminar el libro $title?';
  }

  @override
  String get bookTitle => 'Título';

  @override
  String get bookAuthor => 'Autor';

  @override
  String get bookPublisher => 'Editorial';

  @override
  String get bookQuantity => 'Cantidad disponible';

  @override
  String get bookStatus => 'Estado';

  @override
  String get bookObservations => 'Observaciones';

  @override
  String get bookAvailable => 'Disponible';

  @override
  String get bookRented => 'Alquilado';

  @override
  String get bookId => 'ID';

  @override
  String get actions => 'Acciones';

  @override
  String get searchBooks => 'Buscar por título, autor u observaciones';

  @override
  String get sortBooksBy => 'Ordenar por';

  @override
  String get sortAscending => 'Orden ascendente';

  @override
  String get sortDescending => 'Orden descendente';

  @override
  String get noBooksFound => 'No se encontraron libros.';

  @override
  String get booksLoadFailed => 'No se pudieron cargar los libros.';

  @override
  String get bookSaveFailed => 'No se pudo guardar el libro.';

  @override
  String get bookValidationFailed =>
      'Revisa los datos introducidos e inténtalo de nuevo.';

  @override
  String get bookDeleteFailed =>
      'No se pudo eliminar el libro. Inténtalo de nuevo.';

  @override
  String get bookSaved => 'Libro guardado correctamente.';

  @override
  String get invalidBookQuantity =>
      'Introduce una cantidad entera mayor o igual que cero.';

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
  String get publisherDashboardTitle => 'Altis+ Biblioteca';

  @override
  String get publisherDashboardSubtitle => 'Gestión de editoriales';

  @override
  String get publishersMetric => 'Editoriales';

  @override
  String get linkedBooksOnPage => 'Libros vinculados en esta página';

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
  String get publisherValidationFailed =>
      'Revisa los datos introducidos e inténtalo de nuevo.';

  @override
  String get publisherAlreadyExists =>
      'Ya existe una editorial con esos datos.';

  @override
  String get publisherSaved => 'Editorial guardada correctamente.';

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
