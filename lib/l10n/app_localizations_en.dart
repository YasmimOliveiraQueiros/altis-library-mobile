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
  String get adminAccess => 'Administrator access';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get login => 'Sign in';

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
}
