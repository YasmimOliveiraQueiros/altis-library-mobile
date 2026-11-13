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
  String get manageBooks => 'Gerenciar livros';

  @override
  String get manageLoans => 'Gerenciar aluguéis';

  @override
  String get dashboardBrand => 'Altis+ Biblioteca';

  @override
  String get dashboardTitle => 'Dashboard Administrativo';

  @override
  String get dashboardOverview => 'Visão geral do sistema';

  @override
  String get dashboardViewAll => 'Ver todos';

  @override
  String get dashboardTotalUsers => 'Usuários';

  @override
  String get dashboardTotalBooks => 'Livros';

  @override
  String get dashboardTotalPublishers => 'Editoras';

  @override
  String get dashboardActiveLoans => 'Aluguéis ativos';

  @override
  String get dashboardLoanStatus => 'Aluguéis por situação';

  @override
  String get dashboardPendingLoans => 'Pendentes';

  @override
  String get dashboardOverdueLoans => 'Atrasados';

  @override
  String get dashboardReturnedLoans => 'Devolvidos';

  @override
  String get dashboardLoansByMonth => 'Aluguéis por mês';

  @override
  String get dashboardBooksByStatus => 'Disponibilidade dos livros';

  @override
  String get dashboardAvailable => 'Disponíveis';

  @override
  String get dashboardRented => 'Alugados';

  @override
  String get dashboardNoMonthlyLoans => 'Não há dados mensais de aluguéis.';

  @override
  String get dashboardRecentLoans => 'Aluguéis recentes';

  @override
  String get dashboardNoRecentLoans => 'Nenhum aluguel recente.';

  @override
  String get dashboardLoanDate => 'Alugado em';

  @override
  String get dashboardLoadFailed => 'Não foi possível carregar o dashboard.';

  @override
  String get dashboardRefresh => 'Atualizar dashboard';

  @override
  String get loanDashboardTitle => 'Altis+ Biblioteca';

  @override
  String get loanDashboardSubtitle => 'Controle de empréstimos de livros';

  @override
  String get loanPendingMetric => 'Pendentes na consulta';

  @override
  String get loanOverdueMetric => 'Atrasados na consulta';

  @override
  String get loanReturnedMetric => 'Devolvidos na consulta';

  @override
  String get loanTotalMetric => 'Total na consulta';

  @override
  String get addLoan => 'Novo aluguel';

  @override
  String get editLoan => 'Editar aluguel';

  @override
  String get loanBorrower => 'Locatário';

  @override
  String get loanBook => 'Livro';

  @override
  String get loanDate => 'Data do aluguel';

  @override
  String get loanDueDate => 'Devolução prevista';

  @override
  String get loanStatus => 'Status';

  @override
  String get loanObservations => 'Observações';

  @override
  String get loanPending => 'Pendente';

  @override
  String get loanOverdue => 'Atrasado';

  @override
  String get loanReturned => 'Devolvido';

  @override
  String get loanReturnedLate => 'Devolvido com atraso';

  @override
  String get searchLoans => 'Pesquisar pelo nome do locatário';

  @override
  String get filterLoanStatus => 'Filtrar por status';

  @override
  String get allLoanStatuses => 'Todos os status';

  @override
  String get returnLoan => 'Registrar devolução';

  @override
  String get returnLoanTitle => 'Confirmar devolução';

  @override
  String returnLoanMessage(Object book) {
    return 'Deseja registrar a devolução de $book?';
  }

  @override
  String get loanSaved => 'Aluguel salvo com sucesso.';

  @override
  String get loansLoadFailed => 'Não foi possível carregar os aluguéis.';

  @override
  String get noLoansFound => 'Nenhum aluguel encontrado.';

  @override
  String get loanSaveFailed => 'Não foi possível salvar o aluguel.';

  @override
  String get loanValidationFailed =>
      'Verifique os dados informados e tente novamente.';

  @override
  String get loanOptionsLoadFailed =>
      'Não foi possível carregar locatários e livros.';

  @override
  String get loanReturnFailed => 'Não foi possível registrar a devolução.';

  @override
  String get loanMetricsLoadFailed =>
      'Não foi possível carregar os indicadores globais.';

  @override
  String get bookDashboardTitle => 'Altis+ Biblioteca';

  @override
  String get bookDashboardSubtitle => 'Controle de livros';

  @override
  String get bookCopiesOnPage => 'Exemplares nesta página';

  @override
  String get booksOnPage => 'Livros nesta página';

  @override
  String get booksTotalInQuery => 'Total na consulta';

  @override
  String get addBook => 'Novo livro';

  @override
  String get editBook => 'Editar livro';

  @override
  String get deleteBook => 'Excluir livro';

  @override
  String get deleteBookTitle => 'Confirmar exclusão';

  @override
  String deleteBookMessage(Object title) {
    return 'Deseja excluir o livro $title?';
  }

  @override
  String get bookTitle => 'Título';

  @override
  String get bookAuthor => 'Autor';

  @override
  String get bookPublisher => 'Editora';

  @override
  String get bookQuantity => 'Quantidade disponível';

  @override
  String get bookStatus => 'Status';

  @override
  String get bookObservations => 'Observações';

  @override
  String get bookAvailable => 'Disponível';

  @override
  String get bookRented => 'Alugado';

  @override
  String get bookId => 'ID';

  @override
  String get actions => 'Ações';

  @override
  String get searchBooks => 'Pesquisar por título, autor ou observações';

  @override
  String get sortBooksBy => 'Ordenar por';

  @override
  String get sortAscending => 'Ordenar em ordem crescente';

  @override
  String get sortDescending => 'Ordenar em ordem decrescente';

  @override
  String get noBooksFound => 'Nenhum livro encontrado.';

  @override
  String get booksLoadFailed => 'Não foi possível carregar os livros.';

  @override
  String get bookSaveFailed => 'Não foi possível salvar o livro.';

  @override
  String get bookValidationFailed =>
      'Verifique os dados informados e tente novamente.';

  @override
  String get bookDeleteFailed =>
      'Não foi possível excluir o livro. Tente novamente.';

  @override
  String get bookSaved => 'Livro salvo com sucesso.';

  @override
  String get invalidBookQuantity =>
      'Informe uma quantidade inteira igual ou maior que zero.';

  @override
  String get adminAccess => 'Acesso administrativo';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get login => 'Entrar';

  @override
  String get tenantTemporaryAccess => 'Acesso temporário do locatário';

  @override
  String get tenantDashboardTitle => 'Área do locatário';

  @override
  String get tenantDashboardLoadFailed =>
      'Não foi possível carregar seu perfil e empréstimos.';

  @override
  String get tenantLoansLoadFailed =>
      'Não foi possível carregar seus empréstimos.';

  @override
  String get tenantTotalLoans => 'Total de empréstimos';

  @override
  String get tenantLoansOnPage => 'Empréstimos nesta página';

  @override
  String get tenantMyLoans => 'Meus empréstimos';

  @override
  String get tenantNoLoans => 'Você não possui empréstimos.';

  @override
  String get tenantPhone => 'Telefone';

  @override
  String get tenantReturnedAt => 'Devolvido em';

  @override
  String get tenantEditProfile => 'Editar perfil';

  @override
  String get tenantProfileLoadFailed => 'Não foi possível carregar seu perfil.';

  @override
  String get tenantProfileValidationFailed =>
      'Revise os dados do perfil e tente novamente.';

  @override
  String get tenantProfileConflict => 'Já existe um perfil com esse e-mail.';

  @override
  String get tenantProfileSaveFailed => 'Não foi possível salvar seu perfil.';

  @override
  String get tenantProfileSaved => 'Perfil atualizado com sucesso.';

  @override
  String get tenantChangePassword => 'Alterar senha';

  @override
  String get tenantCurrentPassword => 'Senha atual';

  @override
  String get tenantNewPassword => 'Nova senha';

  @override
  String get tenantConfirmPassword => 'Confirmar nova senha';

  @override
  String get tenantPasswordMinLength =>
      'A senha deve ter pelo menos 8 caracteres.';

  @override
  String get tenantPasswordsDoNotMatch => 'As senhas não coincidem.';

  @override
  String get tenantPasswordValidationFailed =>
      'Revise os dados da senha e tente novamente.';

  @override
  String get tenantPasswordChangeFailed =>
      'Não foi possível alterar a senha. Confira a senha atual e tente novamente.';

  @override
  String get tenantPasswordChanged => 'Senha alterada com sucesso.';

  @override
  String get tenantConnectionFailed =>
      'Não foi possível conectar à API. Verifique a conexão.';

  @override
  String get tenantUserAccessRequired =>
      'Esta tela está disponível somente para usuários.';

  @override
  String get tenantFieldTooLong =>
      'O texto excede o limite de caracteres permitido.';

  @override
  String get tenantAddress => 'Endereço';

  @override
  String get tenantCpf => 'CPF';

  @override
  String get tenantBirthDate => 'Data de nascimento';

  @override
  String get temporaryTenantReady =>
      'Sessão USER ativa. O dashboard será adicionado em um próximo checkpoint.';

  @override
  String get logout => 'Encerrar sessão';

  @override
  String get back => 'Voltar';

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
