import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @name.
  ///
  /// In pt, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @manageUsers.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar usuários'**
  String get manageUsers;

  /// No description provided for @managePublishers.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar editoras'**
  String get managePublishers;

  /// No description provided for @manageBooks.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar livros'**
  String get manageBooks;

  /// No description provided for @manageLoans.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciar aluguéis'**
  String get manageLoans;

  /// No description provided for @navDashboard.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navLoans.
  ///
  /// In pt, this message translates to:
  /// **'Aluguéis'**
  String get navLoans;

  /// No description provided for @navBooks.
  ///
  /// In pt, this message translates to:
  /// **'Livros'**
  String get navBooks;

  /// No description provided for @navPublishers.
  ///
  /// In pt, this message translates to:
  /// **'Editoras'**
  String get navPublishers;

  /// No description provided for @navUsers.
  ///
  /// In pt, this message translates to:
  /// **'Usuários'**
  String get navUsers;

  /// No description provided for @navEditProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar Perfil'**
  String get navEditProfile;

  /// No description provided for @navChangePassword.
  ///
  /// In pt, this message translates to:
  /// **'Alterar Senha'**
  String get navChangePassword;

  /// No description provided for @navLogout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get navLogout;

  /// No description provided for @navOpen.
  ///
  /// In pt, this message translates to:
  /// **'Abrir menu'**
  String get navOpen;

  /// No description provided for @navClose.
  ///
  /// In pt, this message translates to:
  /// **'Fechar menu'**
  String get navClose;

  /// No description provided for @userMenu.
  ///
  /// In pt, this message translates to:
  /// **'Menu do usuário'**
  String get userMenu;

  /// No description provided for @changeLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Alterar idioma'**
  String get changeLanguage;

  /// No description provided for @editProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @signOut.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get signOut;

  /// No description provided for @closeAccount.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar conta'**
  String get closeAccount;

  /// No description provided for @closeAccountInfo.
  ///
  /// In pt, this message translates to:
  /// **'O encerramento da conta ainda não está disponível. Nenhuma alteração será feita agora.'**
  String get closeAccountInfo;

  /// No description provided for @close.
  ///
  /// In pt, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @portuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get english;

  /// No description provided for @spanish.
  ///
  /// In pt, this message translates to:
  /// **'Espanhol'**
  String get spanish;

  /// No description provided for @profilePersonalData.
  ///
  /// In pt, this message translates to:
  /// **'Dados pessoais'**
  String get profilePersonalData;

  /// No description provided for @dashboardBrand.
  ///
  /// In pt, this message translates to:
  /// **'Altis+ Biblioteca'**
  String get dashboardBrand;

  /// No description provided for @dashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Dashboard Administrativo'**
  String get dashboardTitle;

  /// No description provided for @dashboardOverview.
  ///
  /// In pt, this message translates to:
  /// **'Visão geral do sistema'**
  String get dashboardOverview;

  /// No description provided for @dashboardViewAll.
  ///
  /// In pt, this message translates to:
  /// **'Ver todos'**
  String get dashboardViewAll;

  /// No description provided for @dashboardTotalUsers.
  ///
  /// In pt, this message translates to:
  /// **'Usuários'**
  String get dashboardTotalUsers;

  /// No description provided for @dashboardTotalBooks.
  ///
  /// In pt, this message translates to:
  /// **'Livros'**
  String get dashboardTotalBooks;

  /// No description provided for @dashboardTotalPublishers.
  ///
  /// In pt, this message translates to:
  /// **'Editoras'**
  String get dashboardTotalPublishers;

  /// No description provided for @dashboardActiveLoans.
  ///
  /// In pt, this message translates to:
  /// **'Aluguéis ativos'**
  String get dashboardActiveLoans;

  /// No description provided for @dashboardLoanStatus.
  ///
  /// In pt, this message translates to:
  /// **'Aluguéis por situação'**
  String get dashboardLoanStatus;

  /// No description provided for @dashboardPendingLoans.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes'**
  String get dashboardPendingLoans;

  /// No description provided for @dashboardOverdueLoans.
  ///
  /// In pt, this message translates to:
  /// **'Atrasados'**
  String get dashboardOverdueLoans;

  /// No description provided for @dashboardReturnedLoans.
  ///
  /// In pt, this message translates to:
  /// **'Devolvidos'**
  String get dashboardReturnedLoans;

  /// No description provided for @dashboardLoansByMonth.
  ///
  /// In pt, this message translates to:
  /// **'Aluguéis por mês'**
  String get dashboardLoansByMonth;

  /// No description provided for @dashboardBooksByStatus.
  ///
  /// In pt, this message translates to:
  /// **'Disponibilidade dos livros'**
  String get dashboardBooksByStatus;

  /// No description provided for @dashboardAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponíveis'**
  String get dashboardAvailable;

  /// No description provided for @dashboardRented.
  ///
  /// In pt, this message translates to:
  /// **'Alugados'**
  String get dashboardRented;

  /// No description provided for @dashboardNoMonthlyLoans.
  ///
  /// In pt, this message translates to:
  /// **'Não há dados mensais de aluguéis.'**
  String get dashboardNoMonthlyLoans;

  /// No description provided for @dashboardRecentLoans.
  ///
  /// In pt, this message translates to:
  /// **'Aluguéis recentes'**
  String get dashboardRecentLoans;

  /// No description provided for @dashboardNoRecentLoans.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum aluguel recente.'**
  String get dashboardNoRecentLoans;

  /// No description provided for @dashboardLoanDate.
  ///
  /// In pt, this message translates to:
  /// **'Alugado em'**
  String get dashboardLoanDate;

  /// No description provided for @dashboardLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar o dashboard.'**
  String get dashboardLoadFailed;

  /// No description provided for @dashboardRefresh.
  ///
  /// In pt, this message translates to:
  /// **'Atualizar dashboard'**
  String get dashboardRefresh;

  /// No description provided for @loanDashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Altis+ Biblioteca'**
  String get loanDashboardTitle;

  /// No description provided for @loanDashboardSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle de empréstimos de livros'**
  String get loanDashboardSubtitle;

  /// No description provided for @loanPendingMetric.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes na consulta'**
  String get loanPendingMetric;

  /// No description provided for @loanOverdueMetric.
  ///
  /// In pt, this message translates to:
  /// **'Atrasados na consulta'**
  String get loanOverdueMetric;

  /// No description provided for @loanReturnedMetric.
  ///
  /// In pt, this message translates to:
  /// **'Devolvidos na consulta'**
  String get loanReturnedMetric;

  /// No description provided for @loanTotalMetric.
  ///
  /// In pt, this message translates to:
  /// **'Total na consulta'**
  String get loanTotalMetric;

  /// No description provided for @addLoan.
  ///
  /// In pt, this message translates to:
  /// **'Novo aluguel'**
  String get addLoan;

  /// No description provided for @editLoan.
  ///
  /// In pt, this message translates to:
  /// **'Editar aluguel'**
  String get editLoan;

  /// No description provided for @loanBorrower.
  ///
  /// In pt, this message translates to:
  /// **'Locatário'**
  String get loanBorrower;

  /// No description provided for @loanBook.
  ///
  /// In pt, this message translates to:
  /// **'Livro'**
  String get loanBook;

  /// No description provided for @loanDate.
  ///
  /// In pt, this message translates to:
  /// **'Data do aluguel'**
  String get loanDate;

  /// No description provided for @loanDueDate.
  ///
  /// In pt, this message translates to:
  /// **'Devolução prevista'**
  String get loanDueDate;

  /// No description provided for @loanDueDateBeforeLoanDate.
  ///
  /// In pt, this message translates to:
  /// **'A devolução prevista não pode ser anterior à data do aluguel.'**
  String get loanDueDateBeforeLoanDate;

  /// No description provided for @loanStatus.
  ///
  /// In pt, this message translates to:
  /// **'Status'**
  String get loanStatus;

  /// No description provided for @loanObservations.
  ///
  /// In pt, this message translates to:
  /// **'Observações'**
  String get loanObservations;

  /// No description provided for @loanPending.
  ///
  /// In pt, this message translates to:
  /// **'Pendente'**
  String get loanPending;

  /// No description provided for @loanOverdue.
  ///
  /// In pt, this message translates to:
  /// **'Atrasado'**
  String get loanOverdue;

  /// No description provided for @loanReturned.
  ///
  /// In pt, this message translates to:
  /// **'Devolvido'**
  String get loanReturned;

  /// No description provided for @loanReturnedLate.
  ///
  /// In pt, this message translates to:
  /// **'Devolvido com atraso'**
  String get loanReturnedLate;

  /// No description provided for @searchLoans.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar pelo nome do locatário'**
  String get searchLoans;

  /// No description provided for @filterLoanStatus.
  ///
  /// In pt, this message translates to:
  /// **'Filtrar por status'**
  String get filterLoanStatus;

  /// No description provided for @allLoanStatuses.
  ///
  /// In pt, this message translates to:
  /// **'Todos os status'**
  String get allLoanStatuses;

  /// No description provided for @returnLoan.
  ///
  /// In pt, this message translates to:
  /// **'Registrar devolução'**
  String get returnLoan;

  /// No description provided for @returnLoanTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar devolução'**
  String get returnLoanTitle;

  /// No description provided for @returnLoanMessage.
  ///
  /// In pt, this message translates to:
  /// **'Deseja registrar a devolução de {book}?'**
  String returnLoanMessage(Object book);

  /// No description provided for @loanSaved.
  ///
  /// In pt, this message translates to:
  /// **'Aluguel salvo com sucesso.'**
  String get loanSaved;

  /// No description provided for @loansLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os aluguéis.'**
  String get loansLoadFailed;

  /// No description provided for @noLoansFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum aluguel encontrado.'**
  String get noLoansFound;

  /// No description provided for @loanSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o aluguel.'**
  String get loanSaveFailed;

  /// No description provided for @loanValidationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Verifique os dados informados e tente novamente.'**
  String get loanValidationFailed;

  /// No description provided for @loanOptionsLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar locatários e livros.'**
  String get loanOptionsLoadFailed;

  /// No description provided for @loanReturnFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível registrar a devolução.'**
  String get loanReturnFailed;

  /// No description provided for @loanMetricsLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os indicadores globais.'**
  String get loanMetricsLoadFailed;

  /// No description provided for @bookDashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Altis+ Biblioteca'**
  String get bookDashboardTitle;

  /// No description provided for @bookDashboardSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle de livros'**
  String get bookDashboardSubtitle;

  /// No description provided for @bookCopiesOnPage.
  ///
  /// In pt, this message translates to:
  /// **'Exemplares nesta página'**
  String get bookCopiesOnPage;

  /// No description provided for @booksOnPage.
  ///
  /// In pt, this message translates to:
  /// **'Livros nesta página'**
  String get booksOnPage;

  /// No description provided for @booksTotalInQuery.
  ///
  /// In pt, this message translates to:
  /// **'Total na consulta'**
  String get booksTotalInQuery;

  /// No description provided for @addBook.
  ///
  /// In pt, this message translates to:
  /// **'Novo livro'**
  String get addBook;

  /// No description provided for @editBook.
  ///
  /// In pt, this message translates to:
  /// **'Editar livro'**
  String get editBook;

  /// No description provided for @deleteBook.
  ///
  /// In pt, this message translates to:
  /// **'Excluir livro'**
  String get deleteBook;

  /// No description provided for @deleteBookTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar exclusão'**
  String get deleteBookTitle;

  /// No description provided for @deleteBookMessage.
  ///
  /// In pt, this message translates to:
  /// **'Deseja excluir o livro {title}?'**
  String deleteBookMessage(Object title);

  /// No description provided for @bookTitle.
  ///
  /// In pt, this message translates to:
  /// **'Título'**
  String get bookTitle;

  /// No description provided for @bookAuthor.
  ///
  /// In pt, this message translates to:
  /// **'Autor'**
  String get bookAuthor;

  /// No description provided for @bookPublisher.
  ///
  /// In pt, this message translates to:
  /// **'Editora'**
  String get bookPublisher;

  /// No description provided for @bookQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Quantidade disponível'**
  String get bookQuantity;

  /// No description provided for @bookStatus.
  ///
  /// In pt, this message translates to:
  /// **'Status'**
  String get bookStatus;

  /// No description provided for @bookObservations.
  ///
  /// In pt, this message translates to:
  /// **'Observações'**
  String get bookObservations;

  /// No description provided for @bookAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Disponível'**
  String get bookAvailable;

  /// No description provided for @bookRented.
  ///
  /// In pt, this message translates to:
  /// **'Alugado'**
  String get bookRented;

  /// No description provided for @bookId.
  ///
  /// In pt, this message translates to:
  /// **'ID'**
  String get bookId;

  /// No description provided for @actions.
  ///
  /// In pt, this message translates to:
  /// **'Ações'**
  String get actions;

  /// No description provided for @searchBooks.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar por título, autor ou observações'**
  String get searchBooks;

  /// No description provided for @sortBooksBy.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar por'**
  String get sortBooksBy;

  /// No description provided for @sortAscending.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar em ordem crescente'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In pt, this message translates to:
  /// **'Ordenar em ordem decrescente'**
  String get sortDescending;

  /// No description provided for @noBooksFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum livro encontrado.'**
  String get noBooksFound;

  /// No description provided for @booksLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os livros.'**
  String get booksLoadFailed;

  /// No description provided for @bookSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar o livro.'**
  String get bookSaveFailed;

  /// No description provided for @bookValidationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Verifique os dados informados e tente novamente.'**
  String get bookValidationFailed;

  /// No description provided for @bookDeleteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível excluir o livro. Tente novamente.'**
  String get bookDeleteFailed;

  /// No description provided for @bookSaved.
  ///
  /// In pt, this message translates to:
  /// **'Livro salvo com sucesso.'**
  String get bookSaved;

  /// No description provided for @invalidBookQuantity.
  ///
  /// In pt, this message translates to:
  /// **'Informe uma quantidade inteira igual ou maior que zero.'**
  String get invalidBookQuantity;

  /// No description provided for @adminAccess.
  ///
  /// In pt, this message translates to:
  /// **'Acesso administrativo'**
  String get adminAccess;

  /// No description provided for @authBrand.
  ///
  /// In pt, this message translates to:
  /// **'Altis+ Biblioteca'**
  String get authBrand;

  /// No description provided for @authSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Sistema de gestão de aluguéis'**
  String get authSubtitle;

  /// No description provided for @loginWelcome.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta!'**
  String get loginWelcome;

  /// No description provided for @loginDescription.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para acessar o sistema.'**
  String get loginDescription;

  /// No description provided for @loginForgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar senha?'**
  String get loginForgotPassword;

  /// No description provided for @loginRegister.
  ///
  /// In pt, this message translates to:
  /// **'Realizar cadastro?'**
  String get loginRegister;

  /// No description provided for @showPassword.
  ///
  /// In pt, this message translates to:
  /// **'Mostrar senha'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In pt, this message translates to:
  /// **'Ocultar senha'**
  String get hidePassword;

  /// No description provided for @loginInvalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'E-mail ou senha incorretos.'**
  String get loginInvalidCredentials;

  /// No description provided for @loginForbidden.
  ///
  /// In pt, this message translates to:
  /// **'Você não tem permissão para entrar.'**
  String get loginForbidden;

  /// No description provided for @accessDenied.
  ///
  /// In pt, this message translates to:
  /// **'Acesso negado. Você não tem permissão para esta ação.'**
  String get accessDenied;

  /// No description provided for @sessionExpired.
  ///
  /// In pt, this message translates to:
  /// **'Sua sessão expirou. Entre novamente.'**
  String get sessionExpired;

  /// No description provided for @loginInvalidResponse.
  ///
  /// In pt, this message translates to:
  /// **'A resposta de autenticação é inválida.'**
  String get loginInvalidResponse;

  /// No description provided for @apiConnectionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível conectar à API. Verifique sua conexão.'**
  String get apiConnectionFailed;

  /// No description provided for @apiTimeout.
  ///
  /// In pt, this message translates to:
  /// **'A solicitação excedeu o tempo limite. Tente novamente.'**
  String get apiTimeout;

  /// No description provided for @loginConnectionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível conectar à API. Verifique sua conexão.'**
  String get loginConnectionFailed;

  /// No description provided for @loginRequestFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível realizar o login. Tente novamente.'**
  String get loginRequestFailed;

  /// No description provided for @authSessionRequired.
  ///
  /// In pt, this message translates to:
  /// **'Faça login para continuar.'**
  String get authSessionRequired;

  /// No description provided for @backToLogin.
  ///
  /// In pt, this message translates to:
  /// **'Voltar ao login'**
  String get backToLogin;

  /// No description provided for @registerTitle.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar nova conta'**
  String get registerTitle;

  /// No description provided for @registerFullName.
  ///
  /// In pt, this message translates to:
  /// **'Nome completo'**
  String get registerFullName;

  /// No description provided for @registerConfirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get registerConfirmPassword;

  /// No description provided for @registerButton.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get registerButton;

  /// No description provided for @registrationSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Cadastro realizado com sucesso. Faça login para continuar.'**
  String get registrationSuccess;

  /// No description provided for @registrationConnectionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível conectar à API. Verifique sua conexão e tente novamente.'**
  String get registrationConnectionFailed;

  /// No description provided for @registrationValidationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Confira os dados informados e tente novamente.'**
  String get registrationValidationFailed;

  /// No description provided for @registrationEmailConflict.
  ///
  /// In pt, this message translates to:
  /// **'O e-mail informado já está cadastrado.'**
  String get registrationEmailConflict;

  /// No description provided for @registrationCpfConflict.
  ///
  /// In pt, this message translates to:
  /// **'O CPF informado já está cadastrado.'**
  String get registrationCpfConflict;

  /// No description provided for @registrationConflict.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um cadastro com esses dados.'**
  String get registrationConflict;

  /// No description provided for @registrationRequestFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível realizar o cadastro. Tente novamente.'**
  String get registrationRequestFailed;

  /// No description provided for @passwordRecoveryTitle.
  ///
  /// In pt, this message translates to:
  /// **'Recuperar senha'**
  String get passwordRecoveryTitle;

  /// No description provided for @recoveryDescription.
  ///
  /// In pt, this message translates to:
  /// **'Informe seu e-mail e CPF para continuar.'**
  String get recoveryDescription;

  /// No description provided for @recoveryCpf.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get recoveryCpf;

  /// No description provided for @recoveryConfirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar senha'**
  String get recoveryConfirmPassword;

  /// No description provided for @recoveryInvalidCpf.
  ///
  /// In pt, this message translates to:
  /// **'Informe um CPF válido.'**
  String get recoveryInvalidCpf;

  /// No description provided for @recoveryConnectionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível conectar à API. Verifique sua conexão.'**
  String get recoveryConnectionFailed;

  /// No description provided for @recoveryInvalidResponse.
  ///
  /// In pt, this message translates to:
  /// **'A resposta da API é inválida.'**
  String get recoveryInvalidResponse;

  /// No description provided for @recoveryRequestFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível verificar os dados. Tente novamente.'**
  String get recoveryRequestFailed;

  /// No description provided for @recoveryResetButton.
  ///
  /// In pt, this message translates to:
  /// **'Redefinir senha'**
  String get recoveryResetButton;

  /// No description provided for @recoverySuccess.
  ///
  /// In pt, this message translates to:
  /// **'Senha redefinida com sucesso. Faça login para continuar.'**
  String get recoverySuccess;

  /// No description provided for @recoveryAdminBlocked.
  ///
  /// In pt, this message translates to:
  /// **'A recuperação de senha de administrador exige contato com o responsável pelo sistema. Volte ao login.'**
  String get recoveryAdminBlocked;

  /// No description provided for @recoveryAdminQuestion.
  ///
  /// In pt, this message translates to:
  /// **'Você é usuário administrador?'**
  String get recoveryAdminQuestion;

  /// No description provided for @recoveryResetFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível redefinir a senha. Tente novamente.'**
  String get recoveryResetFailed;

  /// No description provided for @authFlowNotAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Este fluxo estará disponível em uma próxima etapa.'**
  String get authFlowNotAvailable;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @tenantTemporaryAccess.
  ///
  /// In pt, this message translates to:
  /// **'Acesso temporário do locatário'**
  String get tenantTemporaryAccess;

  /// No description provided for @tenantDashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Área do locatário'**
  String get tenantDashboardTitle;

  /// No description provided for @tenantDashboardLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seu perfil e empréstimos.'**
  String get tenantDashboardLoadFailed;

  /// No description provided for @tenantLoansLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seus empréstimos.'**
  String get tenantLoansLoadFailed;

  /// No description provided for @tenantTotalLoans.
  ///
  /// In pt, this message translates to:
  /// **'Total de empréstimos'**
  String get tenantTotalLoans;

  /// No description provided for @tenantLoansOnPage.
  ///
  /// In pt, this message translates to:
  /// **'Empréstimos nesta página'**
  String get tenantLoansOnPage;

  /// No description provided for @tenantMyLoans.
  ///
  /// In pt, this message translates to:
  /// **'Meus empréstimos'**
  String get tenantMyLoans;

  /// No description provided for @tenantNoLoans.
  ///
  /// In pt, this message translates to:
  /// **'Você não possui empréstimos.'**
  String get tenantNoLoans;

  /// No description provided for @tenantPhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone'**
  String get tenantPhone;

  /// No description provided for @tenantReturnedAt.
  ///
  /// In pt, this message translates to:
  /// **'Devolvido em'**
  String get tenantReturnedAt;

  /// No description provided for @tenantEditProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar perfil'**
  String get tenantEditProfile;

  /// No description provided for @tenantProfileLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar seu perfil.'**
  String get tenantProfileLoadFailed;

  /// No description provided for @tenantProfileValidationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Revise os dados do perfil e tente novamente.'**
  String get tenantProfileValidationFailed;

  /// No description provided for @tenantProfileConflict.
  ///
  /// In pt, this message translates to:
  /// **'Já existe um perfil com esse e-mail.'**
  String get tenantProfileConflict;

  /// No description provided for @tenantProfileSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar seu perfil.'**
  String get tenantProfileSaveFailed;

  /// No description provided for @tenantProfileSaved.
  ///
  /// In pt, this message translates to:
  /// **'Perfil atualizado com sucesso.'**
  String get tenantProfileSaved;

  /// No description provided for @tenantChangePassword.
  ///
  /// In pt, this message translates to:
  /// **'Alterar senha'**
  String get tenantChangePassword;

  /// No description provided for @tenantCurrentPassword.
  ///
  /// In pt, this message translates to:
  /// **'Senha atual'**
  String get tenantCurrentPassword;

  /// No description provided for @tenantNewPassword.
  ///
  /// In pt, this message translates to:
  /// **'Nova senha'**
  String get tenantNewPassword;

  /// No description provided for @tenantConfirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar nova senha'**
  String get tenantConfirmPassword;

  /// No description provided for @tenantPasswordMinLength.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 8 caracteres.'**
  String get tenantPasswordMinLength;

  /// No description provided for @tenantPasswordsDoNotMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem.'**
  String get tenantPasswordsDoNotMatch;

  /// No description provided for @tenantPasswordValidationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Revise os dados da senha e tente novamente.'**
  String get tenantPasswordValidationFailed;

  /// No description provided for @tenantPasswordChangeFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível alterar a senha. Confira a senha atual e tente novamente.'**
  String get tenantPasswordChangeFailed;

  /// No description provided for @tenantPasswordChanged.
  ///
  /// In pt, this message translates to:
  /// **'Senha alterada com sucesso.'**
  String get tenantPasswordChanged;

  /// No description provided for @tenantConnectionFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível conectar à API. Verifique a conexão.'**
  String get tenantConnectionFailed;

  /// No description provided for @tenantUserAccessRequired.
  ///
  /// In pt, this message translates to:
  /// **'Esta tela está disponível somente para usuários.'**
  String get tenantUserAccessRequired;

  /// No description provided for @tenantFieldTooLong.
  ///
  /// In pt, this message translates to:
  /// **'O texto excede o limite de caracteres permitido.'**
  String get tenantFieldTooLong;

  /// No description provided for @tenantAddress.
  ///
  /// In pt, this message translates to:
  /// **'Endereço'**
  String get tenantAddress;

  /// No description provided for @tenantCpf.
  ///
  /// In pt, this message translates to:
  /// **'CPF'**
  String get tenantCpf;

  /// No description provided for @tenantBirthDate.
  ///
  /// In pt, this message translates to:
  /// **'Data de nascimento'**
  String get tenantBirthDate;

  /// No description provided for @temporaryTenantReady.
  ///
  /// In pt, this message translates to:
  /// **'Sessão USER ativa. O dashboard será adicionado em um próximo checkpoint.'**
  String get temporaryTenantReady;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Encerrar sessão'**
  String get logout;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @loginRequiredFields.
  ///
  /// In pt, this message translates to:
  /// **'Informe o e-mail e a senha.'**
  String get loginRequiredFields;

  /// No description provided for @loginFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível realizar o login.'**
  String get loginFailed;

  /// No description provided for @usersManagement.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciamento de usuários'**
  String get usersManagement;

  /// No description provided for @searchUsers.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar por nome ou e-mail'**
  String get searchUsers;

  /// No description provided for @clearSearch.
  ///
  /// In pt, this message translates to:
  /// **'Limpar pesquisa'**
  String get clearSearch;

  /// No description provided for @totalUsers.
  ///
  /// In pt, this message translates to:
  /// **'Total de resultados'**
  String get totalUsers;

  /// No description provided for @activeOnPage.
  ///
  /// In pt, this message translates to:
  /// **'Ativos nesta página'**
  String get activeOnPage;

  /// No description provided for @inactiveOnPage.
  ///
  /// In pt, this message translates to:
  /// **'Inativos nesta página'**
  String get inactiveOnPage;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @administrator.
  ///
  /// In pt, this message translates to:
  /// **'Administrador'**
  String get administrator;

  /// No description provided for @standardUser.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get standardUser;

  /// No description provided for @active.
  ///
  /// In pt, this message translates to:
  /// **'Ativo'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In pt, this message translates to:
  /// **'Inativo'**
  String get inactive;

  /// No description provided for @activateUser.
  ///
  /// In pt, this message translates to:
  /// **'Ativar usuário'**
  String get activateUser;

  /// No description provided for @deactivateUser.
  ///
  /// In pt, this message translates to:
  /// **'Desativar usuário'**
  String get deactivateUser;

  /// No description provided for @confirmStatusTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar alteração'**
  String get confirmStatusTitle;

  /// No description provided for @confirmStatusMessage.
  ///
  /// In pt, this message translates to:
  /// **'Deseja {action} {name}?'**
  String confirmStatusMessage(Object action, Object name);

  /// No description provided for @activateAction.
  ///
  /// In pt, this message translates to:
  /// **'ativar'**
  String get activateAction;

  /// No description provided for @deactivateAction.
  ///
  /// In pt, this message translates to:
  /// **'desativar'**
  String get deactivateAction;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @statusUpdateFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível atualizar a situação do usuário.'**
  String get statusUpdateFailed;

  /// No description provided for @usersLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar os usuários.'**
  String get usersLoadFailed;

  /// No description provided for @retry.
  ///
  /// In pt, this message translates to:
  /// **'Tentar novamente'**
  String get retry;

  /// No description provided for @noUsersFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum usuário encontrado.'**
  String get noUsersFound;

  /// No description provided for @pageInfo.
  ///
  /// In pt, this message translates to:
  /// **'Página {current} de {total}'**
  String pageInfo(int current, int total);

  /// No description provided for @rowsPerPage.
  ///
  /// In pt, this message translates to:
  /// **'Itens por página'**
  String get rowsPerPage;

  /// No description provided for @previousPage.
  ///
  /// In pt, this message translates to:
  /// **'Página anterior'**
  String get previousPage;

  /// No description provided for @nextPage.
  ///
  /// In pt, this message translates to:
  /// **'Próxima página'**
  String get nextPage;

  /// No description provided for @publishersManagement.
  ///
  /// In pt, this message translates to:
  /// **'Gerenciamento de editoras'**
  String get publishersManagement;

  /// No description provided for @publisherDashboardTitle.
  ///
  /// In pt, this message translates to:
  /// **'Altis+ Biblioteca'**
  String get publisherDashboardTitle;

  /// No description provided for @publisherDashboardSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Controle de editoras'**
  String get publisherDashboardSubtitle;

  /// No description provided for @publishersMetric.
  ///
  /// In pt, this message translates to:
  /// **'Editoras'**
  String get publishersMetric;

  /// No description provided for @linkedBooksOnPage.
  ///
  /// In pt, this message translates to:
  /// **'Livros vinculados nesta página'**
  String get linkedBooksOnPage;

  /// No description provided for @searchPublishers.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar editoras por nome ou e-mail'**
  String get searchPublishers;

  /// No description provided for @noPublishersFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma editora encontrada.'**
  String get noPublishersFound;

  /// No description provided for @publishersLoadFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível carregar as editoras.'**
  String get publishersLoadFailed;

  /// No description provided for @publisherSaveFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível salvar a editora.'**
  String get publisherSaveFailed;

  /// No description provided for @publisherValidationFailed.
  ///
  /// In pt, this message translates to:
  /// **'Verifique os dados informados e tente novamente.'**
  String get publisherValidationFailed;

  /// No description provided for @publisherAlreadyExists.
  ///
  /// In pt, this message translates to:
  /// **'Já existe uma editora com esses dados.'**
  String get publisherAlreadyExists;

  /// No description provided for @publisherSaved.
  ///
  /// In pt, this message translates to:
  /// **'Editora salva com sucesso.'**
  String get publisherSaved;

  /// No description provided for @publisherDeleteFailed.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível excluir a editora.'**
  String get publisherDeleteFailed;

  /// No description provided for @addPublisher.
  ///
  /// In pt, this message translates to:
  /// **'Adicionar editora'**
  String get addPublisher;

  /// No description provided for @editPublisher.
  ///
  /// In pt, this message translates to:
  /// **'Editar editora'**
  String get editPublisher;

  /// No description provided for @deletePublisher.
  ///
  /// In pt, this message translates to:
  /// **'Excluir editora'**
  String get deletePublisher;

  /// No description provided for @deletePublisherTitle.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar exclusão'**
  String get deletePublisherTitle;

  /// No description provided for @deletePublisherMessage.
  ///
  /// In pt, this message translates to:
  /// **'Deseja excluir a editora {name}?'**
  String deletePublisherMessage(Object name);

  /// No description provided for @cnpj.
  ///
  /// In pt, this message translates to:
  /// **'CNPJ'**
  String get cnpj;

  /// No description provided for @city.
  ///
  /// In pt, this message translates to:
  /// **'Cidade'**
  String get city;

  /// No description provided for @state.
  ///
  /// In pt, this message translates to:
  /// **'Estado'**
  String get state;

  /// No description provided for @bookCount.
  ///
  /// In pt, this message translates to:
  /// **'Livros vinculados'**
  String get bookCount;

  /// No description provided for @requiredField.
  ///
  /// In pt, this message translates to:
  /// **'Campo obrigatório.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'Informe um e-mail válido.'**
  String get invalidEmail;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
