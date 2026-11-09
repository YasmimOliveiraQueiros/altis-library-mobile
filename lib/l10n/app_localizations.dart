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

  /// No description provided for @adminAccess.
  ///
  /// In pt, this message translates to:
  /// **'Acesso administrativo'**
  String get adminAccess;

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
