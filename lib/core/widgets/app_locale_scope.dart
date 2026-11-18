import 'package:flutter/material.dart';

class AppLocaleScope extends InheritedWidget {
  const AppLocaleScope({
    required this.locale,
    required this.setLocale,
    required super.child,
    super.key,
  });

  final Locale locale;
  final ValueChanged<Locale> setLocale;

  static AppLocaleScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppLocaleScope>();

  @override
  bool updateShouldNotify(AppLocaleScope oldWidget) =>
      locale != oldWidget.locale;
}
