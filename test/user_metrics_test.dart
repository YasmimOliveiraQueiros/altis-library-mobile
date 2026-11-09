import 'package:altis_library_mobile/l10n/app_localizations.dart';
import 'package:altis_library_mobile/modules/users/widgets/user_list_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps all user metrics in one row on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
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
              child: Align(
                alignment: Alignment.topCenter,
                child: UserMetrics(
                  totalResults: 123,
                  activeOnPage: 8,
                  inactiveOnPage: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final cards = find
        .byType(Card)
        .evaluate()
        .map((element) => tester.getRect(find.byWidget(element.widget)))
        .toList();
    expect(cards, hasLength(3));
    expect(cards[0].right, lessThanOrEqualTo(cards[1].left));
    expect(cards[1].right, lessThanOrEqualTo(cards[2].left));
    expect(
      cards
          .skip(1)
          .every(
            (card) =>
                card.top < cards.first.bottom && card.bottom > cards.first.top,
          ),
      isTrue,
    );
  });
}
