// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get name => 'Nome';

  @override
  String get manageUsers => 'Gerenciar usuários';

  @override
  String get managePublishers => 'Gerenciar editoras';

  @override
  String get adminAccess => 'Acesso administrativo';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get login => 'Entrar';

  @override
  String get loginRequiredFields => 'Informe o e-mail e a senha.';

  @override
  String get loginFailed => 'Não foi possível realizar o login.';

  @override
  String get usersManagement => 'Gerenciamento de usuários';

  @override
  String get searchUsers => 'Pesquisar por nome ou e-mail';

  @override
  String get clearSearch => 'Limpar pesquisa';

  @override
  String get totalUsers => 'Total de resultados';

  @override
  String get activeOnPage => 'Ativos nesta página';

  @override
  String get inactiveOnPage => 'Inativos nesta página';

  @override
  String get profile => 'Perfil';

  @override
  String get administrator => 'Administrador';

  @override
  String get standardUser => 'Usuário';

  @override
  String get active => 'Ativo';

  @override
  String get inactive => 'Inativo';

  @override
  String get activateUser => 'Ativar usuário';

  @override
  String get deactivateUser => 'Desativar usuário';

  @override
  String get confirmStatusTitle => 'Confirmar alteração';

  @override
  String confirmStatusMessage(Object action, Object name) {
    return 'Deseja $action $name?';
  }

  @override
  String get activateAction => 'ativar';

  @override
  String get deactivateAction => 'desativar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get statusUpdateFailed =>
      'Não foi possível atualizar a situação do usuário.';

  @override
  String get usersLoadFailed => 'Não foi possível carregar os usuários.';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noUsersFound => 'Nenhum usuário encontrado.';

  @override
  String pageInfo(int current, int total) {
    return 'Página $current de $total';
  }

  @override
  String get rowsPerPage => 'Itens por página';

  @override
  String get previousPage => 'Página anterior';

  @override
  String get nextPage => 'Próxima página';

  @override
  String get publishersManagement => 'Gerenciamento de editoras';

  @override
  String get publisherDashboardTitle => 'Altis+ Biblioteca';

  @override
  String get publisherDashboardSubtitle => 'Controle de editoras';

  @override
  String get publishersMetric => 'Editoras';

  @override
  String get linkedBooksOnPage => 'Livros vinculados nesta página';

  @override
  String get searchPublishers => 'Pesquisar editoras por nome ou e-mail';

  @override
  String get noPublishersFound => 'Nenhuma editora encontrada.';

  @override
  String get publishersLoadFailed => 'Não foi possível carregar as editoras.';

  @override
  String get publisherSaveFailed => 'Não foi possível salvar a editora.';

  @override
  String get publisherValidationFailed =>
      'Verifique os dados informados e tente novamente.';

  @override
  String get publisherAlreadyExists => 'Já existe uma editora com esses dados.';

  @override
  String get publisherSaved => 'Editora salva com sucesso.';

  @override
  String get publisherDeleteFailed => 'Não foi possível excluir a editora.';

  @override
  String get addPublisher => 'Adicionar editora';

  @override
  String get editPublisher => 'Editar editora';

  @override
  String get deletePublisher => 'Excluir editora';

  @override
  String get deletePublisherTitle => 'Confirmar exclusão';

  @override
  String deletePublisherMessage(Object name) {
    return 'Deseja excluir a editora $name?';
  }

  @override
  String get cnpj => 'CNPJ';

  @override
  String get city => 'Cidade';

  @override
  String get state => 'Estado';

  @override
  String get bookCount => 'Livros vinculados';

  @override
  String get requiredField => 'Campo obrigatório.';

  @override
  String get invalidEmail => 'Informe um e-mail válido.';

  @override
  String get save => 'Salvar';
}
