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
  String get manageLoans => 'Administrar préstamos';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navLoans => 'Alquileres';

  @override
  String get navBooks => 'Libros';

  @override
  String get navPublishers => 'Editoriales';

  @override
  String get navUsers => 'Usuarios';

  @override
  String get navEditProfile => 'Editar perfil';

  @override
  String get navChangePassword => 'Cambiar contraseña';

  @override
  String get navLogout => 'Cerrar sesión';

  @override
  String get navOpen => 'Abrir menú';

  @override
  String get navClose => 'Cerrar menú';

  @override
  String get userMenu => 'Menú de usuario';

  @override
  String get changeLanguage => 'Cambiar idioma';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get signOut => 'Cerrar sesión';

  @override
  String get closeAccount => 'Cerrar cuenta';

  @override
  String get closeAccountInfo =>
      'El cierre de la cuenta aún no está disponible. No se realizará ningún cambio.';

  @override
  String get close => 'Cerrar';

  @override
  String get portuguese => 'Portugués';

  @override
  String get english => 'Inglés';

  @override
  String get spanish => 'Español';

  @override
  String get profilePersonalData => 'Datos personales';

  @override
  String get dashboardBrand => 'Altis+ Biblioteca';

  @override
  String get dashboardTitle => 'Panel administrativo';

  @override
  String get dashboardOverview => 'Resumen del sistema';

  @override
  String get dashboardViewAll => 'Ver todos';

  @override
  String get dashboardTotalUsers => 'Usuarios';

  @override
  String get dashboardTotalBooks => 'Libros';

  @override
  String get dashboardTotalPublishers => 'Editoriales';

  @override
  String get dashboardActiveLoans => 'Préstamos activos';

  @override
  String get dashboardLoanStatus => 'Préstamos por estado';

  @override
  String get dashboardPendingLoans => 'Pendientes';

  @override
  String get dashboardOverdueLoans => 'Atrasados';

  @override
  String get dashboardReturnedLoans => 'Devueltos';

  @override
  String get dashboardLoansByMonth => 'Préstamos por mes';

  @override
  String get dashboardBooksByStatus => 'Disponibilidad de libros';

  @override
  String get dashboardAvailable => 'Disponibles';

  @override
  String get dashboardRented => 'Alquilados';

  @override
  String get dashboardNoMonthlyLoans => 'No hay datos mensuales de préstamos.';

  @override
  String get dashboardRecentLoans => 'Préstamos recientes';

  @override
  String get dashboardNoRecentLoans => 'No hay préstamos recientes.';

  @override
  String get dashboardLoanDate => 'Prestado el';

  @override
  String get dashboardLoadFailed => 'No se pudo cargar el panel.';

  @override
  String get dashboardRefresh => 'Actualizar panel';

  @override
  String get loanDashboardTitle => 'Altis+ Biblioteca';

  @override
  String get loanDashboardSubtitle => 'Gestión de préstamos de libros';

  @override
  String get loanPendingMetric => 'Pendientes en resultados';

  @override
  String get loanOverdueMetric => 'Atrasados en resultados';

  @override
  String get loanReturnedMetric => 'Devueltos en resultados';

  @override
  String get loanTotalMetric => 'Total en resultados';

  @override
  String get addLoan => 'Nuevo préstamo';

  @override
  String get editLoan => 'Editar préstamo';

  @override
  String get loanBorrower => 'Prestatario';

  @override
  String get loanBook => 'Libro';

  @override
  String get loanDate => 'Fecha del préstamo';

  @override
  String get loanDueDate => 'Devolución prevista';

  @override
  String get loanDueDateBeforeLoanDate =>
      'La fecha de devolución prevista no puede ser anterior a la fecha del préstamo.';

  @override
  String get loanStatus => 'Estado';

  @override
  String get loanObservations => 'Observaciones';

  @override
  String get loanPending => 'Pendiente';

  @override
  String get loanOverdue => 'Atrasado';

  @override
  String get loanReturned => 'Devuelto';

  @override
  String get loanReturnedLate => 'Devuelto con retraso';

  @override
  String get searchLoans => 'Buscar por nombre del prestatario';

  @override
  String get filterLoanStatus => 'Filtrar por estado';

  @override
  String get allLoanStatuses => 'Todos los estados';

  @override
  String get returnLoan => 'Registrar devolución';

  @override
  String get returnLoanTitle => 'Confirmar devolución';

  @override
  String returnLoanMessage(Object book) {
    return '¿Deseas registrar la devolución de $book?';
  }

  @override
  String get loanSaved => 'Préstamo guardado correctamente.';

  @override
  String get loansLoadFailed => 'No se pudieron cargar los préstamos.';

  @override
  String get noLoansFound => 'No se encontraron préstamos.';

  @override
  String get loanSaveFailed => 'No se pudo guardar el préstamo.';

  @override
  String get loanValidationFailed =>
      'Revisa los datos introducidos e inténtalo de nuevo.';

  @override
  String get loanOptionsLoadFailed =>
      'No se pudieron cargar los prestatarios y libros.';

  @override
  String get loanReturnFailed => 'No se pudo registrar la devolución.';

  @override
  String get loanMetricsLoadFailed =>
      'No se pudieron cargar las métricas globales.';

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
  String get authBrand => 'Altis+ Biblioteca';

  @override
  String get authSubtitle => 'Sistema de gestión de préstamos';

  @override
  String get loginWelcome => '¡Bienvenido de nuevo!';

  @override
  String get loginDescription => 'Inicia sesión para acceder al sistema.';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginRegister => '¿Crear una cuenta?';

  @override
  String get showPassword => 'Mostrar contraseña';

  @override
  String get hidePassword => 'Ocultar contraseña';

  @override
  String get loginInvalidCredentials =>
      'Correo electrónico o contraseña incorrectos.';

  @override
  String get loginForbidden => 'No tienes permiso para iniciar sesión.';

  @override
  String get accessDenied =>
      'Acceso denegado. No tienes permiso para realizar esta acción.';

  @override
  String get sessionExpired => 'Tu sesión ha caducado. Inicia sesión de nuevo.';

  @override
  String get loginInvalidResponse =>
      'La respuesta de autenticación no es válida.';

  @override
  String get apiConnectionFailed =>
      'No se pudo conectar con la API. Comprueba tu conexión.';

  @override
  String get apiTimeout =>
      'La solicitud agotó el tiempo de espera. Inténtalo de nuevo.';

  @override
  String get loginConnectionFailed =>
      'No se pudo conectar con la API. Comprueba tu conexión.';

  @override
  String get loginRequestFailed =>
      'No se pudo iniciar sesión. Inténtalo de nuevo.';

  @override
  String get authSessionRequired => 'Inicia sesión para continuar.';

  @override
  String get backToLogin => 'Volver al inicio de sesión';

  @override
  String get registerTitle => 'Crear una cuenta nueva';

  @override
  String get registerFullName => 'Nombre completo';

  @override
  String get registerConfirmPassword => 'Confirmar contraseña';

  @override
  String get registerButton => 'Crear cuenta';

  @override
  String get registrationSuccess =>
      'Registro completado correctamente. Inicia sesión para continuar.';

  @override
  String get registrationConnectionFailed =>
      'No se pudo conectar con la API. Comprueba tu conexión e inténtalo de nuevo.';

  @override
  String get registrationValidationFailed =>
      'Revisa los datos introducidos e inténtalo de nuevo.';

  @override
  String get registrationEmailConflict =>
      'El correo electrónico ya está registrado.';

  @override
  String get registrationCpfConflict => 'El CPF ya está registrado.';

  @override
  String get registrationConflict => 'Ya existe una cuenta con estos datos.';

  @override
  String get registrationRequestFailed =>
      'No se pudo crear la cuenta. Inténtalo de nuevo.';

  @override
  String get passwordRecoveryTitle => 'Recuperar contraseña';

  @override
  String get recoveryDescription =>
      'Introduce tu correo electrónico y CPF para continuar.';

  @override
  String get recoveryCpf => 'CPF';

  @override
  String get recoveryConfirmPassword => 'Confirmar contraseña';

  @override
  String get recoveryInvalidCpf => 'Introduce un CPF válido.';

  @override
  String get recoveryConnectionFailed =>
      'No se pudo conectar con la API. Comprueba tu conexión.';

  @override
  String get recoveryInvalidResponse => 'La respuesta de la API no es válida.';

  @override
  String get recoveryRequestFailed =>
      'No se pudo verificar la información. Inténtalo de nuevo.';

  @override
  String get recoveryResetButton => 'Restablecer contraseña';

  @override
  String get recoverySuccess =>
      'Contraseña restablecida correctamente. Inicia sesión para continuar.';

  @override
  String get recoveryAdminBlocked =>
      'La recuperación de contraseña no está disponible para cuentas de administrador. Vuelve al inicio de sesión.';

  @override
  String get recoveryResetFailed =>
      'No se pudo restablecer la contraseña. Inténtalo de nuevo.';

  @override
  String get authFlowNotAvailable =>
      'Este flujo estará disponible en una próxima etapa.';

  @override
  String get email => 'Correo electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get login => 'Iniciar sesión';

  @override
  String get tenantTemporaryAccess => 'Acceso temporal de prestatario';

  @override
  String get tenantDashboardTitle => 'Área del prestatario';

  @override
  String get tenantDashboardLoadFailed =>
      'No se pudieron cargar tu perfil y tus préstamos.';

  @override
  String get tenantLoansLoadFailed => 'No se pudieron cargar tus préstamos.';

  @override
  String get tenantTotalLoans => 'Total de préstamos';

  @override
  String get tenantLoansOnPage => 'Préstamos en esta página';

  @override
  String get tenantMyLoans => 'Mis préstamos';

  @override
  String get tenantNoLoans => 'No tienes préstamos.';

  @override
  String get tenantPhone => 'Teléfono';

  @override
  String get tenantReturnedAt => 'Devuelto el';

  @override
  String get tenantEditProfile => 'Editar perfil';

  @override
  String get tenantProfileLoadFailed => 'No se pudo cargar tu perfil.';

  @override
  String get tenantProfileValidationFailed =>
      'Revisa los datos del perfil e inténtalo de nuevo.';

  @override
  String get tenantProfileConflict =>
      'Ya existe un perfil con este correo electrónico.';

  @override
  String get tenantProfileSaveFailed => 'No se pudo guardar tu perfil.';

  @override
  String get tenantProfileSaved => 'Perfil actualizado correctamente.';

  @override
  String get tenantChangePassword => 'Cambiar contraseña';

  @override
  String get tenantCurrentPassword => 'Contraseña actual';

  @override
  String get tenantNewPassword => 'Nueva contraseña';

  @override
  String get tenantConfirmPassword => 'Confirmar nueva contraseña';

  @override
  String get tenantPasswordMinLength =>
      'La contraseña debe tener al menos 8 caracteres.';

  @override
  String get tenantPasswordsDoNotMatch => 'Las contraseñas no coinciden.';

  @override
  String get tenantPasswordValidationFailed =>
      'Revisa los datos de la contraseña e inténtalo de nuevo.';

  @override
  String get tenantPasswordChangeFailed =>
      'No se pudo cambiar la contraseña. Comprueba la contraseña actual e inténtalo de nuevo.';

  @override
  String get tenantPasswordChanged => 'Contraseña cambiada correctamente.';

  @override
  String get tenantConnectionFailed =>
      'No se pudo conectar con la API. Comprueba tu conexión.';

  @override
  String get tenantUserAccessRequired =>
      'Esta página solo está disponible para usuarios.';

  @override
  String get tenantFieldTooLong =>
      'El texto supera el límite de caracteres permitido.';

  @override
  String get tenantAddress => 'Dirección';

  @override
  String get tenantCpf => 'CPF';

  @override
  String get tenantBirthDate => 'Fecha de nacimiento';

  @override
  String get temporaryTenantReady =>
      'Sesión USER activa. El panel se añadirá en un próximo checkpoint.';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get back => 'Volver';

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
