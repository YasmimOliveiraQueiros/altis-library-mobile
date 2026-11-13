// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get name => 'Name';

  @override
  String get manageUsers => 'Manage users';

  @override
  String get managePublishers => 'Manage publishers';

  @override
  String get manageBooks => 'Manage books';

  @override
  String get manageLoans => 'Manage loans';

  @override
  String get dashboardBrand => 'Altis+ Library';

  @override
  String get dashboardTitle => 'Administrative Dashboard';

  @override
  String get dashboardOverview => 'System overview';

  @override
  String get dashboardViewAll => 'See all';

  @override
  String get dashboardTotalUsers => 'Users';

  @override
  String get dashboardTotalBooks => 'Books';

  @override
  String get dashboardTotalPublishers => 'Publishers';

  @override
  String get dashboardActiveLoans => 'Active loans';

  @override
  String get dashboardLoanStatus => 'Loans by status';

  @override
  String get dashboardPendingLoans => 'Pending';

  @override
  String get dashboardOverdueLoans => 'Overdue';

  @override
  String get dashboardReturnedLoans => 'Returned';

  @override
  String get dashboardLoansByMonth => 'Loans by month';

  @override
  String get dashboardBooksByStatus => 'Book availability';

  @override
  String get dashboardAvailable => 'Available';

  @override
  String get dashboardRented => 'Rented';

  @override
  String get dashboardNoMonthlyLoans => 'There is no monthly loan data.';

  @override
  String get dashboardRecentLoans => 'Recent loans';

  @override
  String get dashboardNoRecentLoans => 'There are no recent loans.';

  @override
  String get dashboardLoanDate => 'Loaned on';

  @override
  String get dashboardLoadFailed => 'Could not load the dashboard.';

  @override
  String get dashboardRefresh => 'Refresh dashboard';

  @override
  String get loanDashboardTitle => 'Altis+ Library';

  @override
  String get loanDashboardSubtitle => 'Book loan management';

  @override
  String get loanPendingMetric => 'Pending in results';

  @override
  String get loanOverdueMetric => 'Overdue in results';

  @override
  String get loanReturnedMetric => 'Returned in results';

  @override
  String get loanTotalMetric => 'Total in results';

  @override
  String get addLoan => 'New loan';

  @override
  String get editLoan => 'Edit loan';

  @override
  String get loanBorrower => 'Borrower';

  @override
  String get loanBook => 'Book';

  @override
  String get loanDate => 'Loan date';

  @override
  String get loanDueDate => 'Expected return';

  @override
  String get loanStatus => 'Status';

  @override
  String get loanObservations => 'Observations';

  @override
  String get loanPending => 'Pending';

  @override
  String get loanOverdue => 'Overdue';

  @override
  String get loanReturned => 'Returned';

  @override
  String get loanReturnedLate => 'Returned late';

  @override
  String get searchLoans => 'Search by borrower name';

  @override
  String get filterLoanStatus => 'Filter by status';

  @override
  String get allLoanStatuses => 'All statuses';

  @override
  String get returnLoan => 'Register return';

  @override
  String get returnLoanTitle => 'Confirm return';

  @override
  String returnLoanMessage(Object book) {
    return 'Do you want to register the return of $book?';
  }

  @override
  String get loanSaved => 'Loan saved successfully.';

  @override
  String get loansLoadFailed => 'Could not load loans.';

  @override
  String get noLoansFound => 'No loans found.';

  @override
  String get loanSaveFailed => 'Could not save the loan.';

  @override
  String get loanValidationFailed =>
      'Check the entered information and try again.';

  @override
  String get loanOptionsLoadFailed => 'Could not load borrowers and books.';

  @override
  String get loanReturnFailed => 'Could not register the return.';

  @override
  String get loanMetricsLoadFailed => 'Could not load global metrics.';

  @override
  String get bookDashboardTitle => 'Altis+ Library';

  @override
  String get bookDashboardSubtitle => 'Book management';

  @override
  String get bookCopiesOnPage => 'Copies on this page';

  @override
  String get booksOnPage => 'Books on this page';

  @override
  String get booksTotalInQuery => 'Total in results';

  @override
  String get addBook => 'New book';

  @override
  String get editBook => 'Edit book';

  @override
  String get deleteBook => 'Delete book';

  @override
  String get deleteBookTitle => 'Confirm deletion';

  @override
  String deleteBookMessage(Object title) {
    return 'Do you want to delete the book $title?';
  }

  @override
  String get bookTitle => 'Title';

  @override
  String get bookAuthor => 'Author';

  @override
  String get bookPublisher => 'Publisher';

  @override
  String get bookQuantity => 'Available quantity';

  @override
  String get bookStatus => 'Status';

  @override
  String get bookObservations => 'Observations';

  @override
  String get bookAvailable => 'Available';

  @override
  String get bookRented => 'Rented';

  @override
  String get bookId => 'ID';

  @override
  String get actions => 'Actions';

  @override
  String get searchBooks => 'Search by title, author or observations';

  @override
  String get sortBooksBy => 'Sort by';

  @override
  String get sortAscending => 'Sort ascending';

  @override
  String get sortDescending => 'Sort descending';

  @override
  String get noBooksFound => 'No books found.';

  @override
  String get booksLoadFailed => 'Could not load books.';

  @override
  String get bookSaveFailed => 'Could not save the book.';

  @override
  String get bookValidationFailed =>
      'Check the entered information and try again.';

  @override
  String get bookDeleteFailed => 'Could not delete the book. Please try again.';

  @override
  String get bookSaved => 'Book saved successfully.';

  @override
  String get invalidBookQuantity =>
      'Enter a whole number greater than or equal to zero.';

  @override
  String get adminAccess => 'Administrator access';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Sign in';

  @override
  String get tenantTemporaryAccess => 'Temporary tenant access';

  @override
  String get tenantDashboardTitle => 'Tenant area';

  @override
  String get tenantDashboardLoadFailed =>
      'Could not load your profile and loans.';

  @override
  String get tenantLoansLoadFailed => 'Could not load your loans.';

  @override
  String get tenantTotalLoans => 'Total loans';

  @override
  String get tenantLoansOnPage => 'Loans on this page';

  @override
  String get tenantMyLoans => 'My loans';

  @override
  String get tenantNoLoans => 'You have no loans.';

  @override
  String get tenantPhone => 'Phone';

  @override
  String get tenantReturnedAt => 'Returned at';

  @override
  String get tenantEditProfile => 'Edit profile';

  @override
  String get tenantProfileLoadFailed => 'Could not load your profile.';

  @override
  String get tenantProfileValidationFailed =>
      'Check the profile details and try again.';

  @override
  String get tenantProfileConflict =>
      'A profile with this email already exists.';

  @override
  String get tenantProfileSaveFailed => 'Could not save your profile.';

  @override
  String get tenantProfileSaved => 'Profile updated successfully.';

  @override
  String get tenantChangePassword => 'Change password';

  @override
  String get tenantCurrentPassword => 'Current password';

  @override
  String get tenantNewPassword => 'New password';

  @override
  String get tenantConfirmPassword => 'Confirm new password';

  @override
  String get tenantPasswordMinLength =>
      'Password must be at least 8 characters long.';

  @override
  String get tenantPasswordsDoNotMatch => 'Passwords do not match.';

  @override
  String get tenantPasswordValidationFailed =>
      'Check the password details and try again.';

  @override
  String get tenantPasswordChangeFailed =>
      'Could not change the password. Check your current password and try again.';

  @override
  String get tenantPasswordChanged => 'Password changed successfully.';

  @override
  String get tenantConnectionFailed =>
      'Could not connect to the API. Check your connection.';

  @override
  String get tenantUserAccessRequired =>
      'This page is available to users only.';

  @override
  String get tenantFieldTooLong =>
      'The text exceeds the allowed character limit.';

  @override
  String get tenantAddress => 'Address';

  @override
  String get tenantCpf => 'CPF';

  @override
  String get tenantBirthDate => 'Date of birth';

  @override
  String get temporaryTenantReady =>
      'USER session active. The dashboard will be added in a later checkpoint.';

  @override
  String get logout => 'Sign out';

  @override
  String get back => 'Back';

  @override
  String get loginRequiredFields => 'Enter your email and password.';

  @override
  String get loginFailed => 'Could not sign in.';

  @override
  String get usersManagement => 'User management';

  @override
  String get searchUsers => 'Search by name or email';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get totalUsers => 'Total results';

  @override
  String get activeOnPage => 'Active on this page';

  @override
  String get inactiveOnPage => 'Inactive on this page';

  @override
  String get profile => 'Profile';

  @override
  String get administrator => 'Administrator';

  @override
  String get standardUser => 'User';

  @override
  String get active => 'Active';

  @override
  String get inactive => 'Inactive';

  @override
  String get activateUser => 'Activate user';

  @override
  String get deactivateUser => 'Deactivate user';

  @override
  String get confirmStatusTitle => 'Confirm change';

  @override
  String confirmStatusMessage(Object action, Object name) {
    return 'Do you want to $action $name?';
  }

  @override
  String get activateAction => 'activate';

  @override
  String get deactivateAction => 'deactivate';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get statusUpdateFailed => 'Could not update the user\'s status.';

  @override
  String get usersLoadFailed => 'Could not load users.';

  @override
  String get retry => 'Try again';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String pageInfo(int current, int total) {
    return 'Page $current of $total';
  }

  @override
  String get rowsPerPage => 'Rows per page';

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String get publishersManagement => 'Publisher management';

  @override
  String get publisherDashboardTitle => 'Altis+ Library';

  @override
  String get publisherDashboardSubtitle => 'Publisher management';

  @override
  String get publishersMetric => 'Publishers';

  @override
  String get linkedBooksOnPage => 'Linked books on this page';

  @override
  String get searchPublishers => 'Search publishers by name or email';

  @override
  String get noPublishersFound => 'No publishers found.';

  @override
  String get publishersLoadFailed => 'Could not load publishers.';

  @override
  String get publisherSaveFailed => 'Could not save the publisher.';

  @override
  String get publisherValidationFailed =>
      'Check the entered information and try again.';

  @override
  String get publisherAlreadyExists =>
      'A publisher with these details already exists.';

  @override
  String get publisherSaved => 'Publisher saved successfully.';

  @override
  String get publisherDeleteFailed => 'Could not delete the publisher.';

  @override
  String get addPublisher => 'Add publisher';

  @override
  String get editPublisher => 'Edit publisher';

  @override
  String get deletePublisher => 'Delete publisher';

  @override
  String get deletePublisherTitle => 'Confirm deletion';

  @override
  String deletePublisherMessage(Object name) {
    return 'Do you want to delete publisher $name?';
  }

  @override
  String get cnpj => 'CNPJ';

  @override
  String get city => 'City';

  @override
  String get state => 'State';

  @override
  String get bookCount => 'Linked books';

  @override
  String get requiredField => 'This field is required.';

  @override
  String get invalidEmail => 'Enter a valid email address.';

  @override
  String get save => 'Save';
}
