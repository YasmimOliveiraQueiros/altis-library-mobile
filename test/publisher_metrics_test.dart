import 'package:altis_library_mobile/core/theme/app_theme.dart';
import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/publishers/widgets/publisher_metrics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps publisher metric cards side by side on mobile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        locale: const Locale('pt'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
          child: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: PublisherMetrics(totalPublishers: 123, booksOnPage: 456),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final cards = tester.widgetList<Card>(find.byType(Card)).toList();
    expect(cards, hasLength(2));
    final firstCard = tester.getRect(find.byWidget(cards[0]));
    final secondCard = tester.getRect(find.byWidget(cards[1]));
    expect(firstCard.right, lessThanOrEqualTo(secondCard.left));
    expect(secondCard.top, lessThan(firstCard.bottom));
    expect(secondCard.bottom, greaterThan(firstCard.top));
    expect(find.text('123'), findsOneWidget);
    expect(find.text('456'), findsOneWidget);
  });
}
