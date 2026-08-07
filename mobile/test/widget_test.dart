import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shopright/app/shop_right_app.dart';

void main() {
  testWidgets('home screen opens the static comparison flow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ShopRightApp());

    expect(find.text('Shop Right'), findsOneWidget);
    expect(find.text('ZMW 1,200.00'), findsOneWidget);
    expect(
      find.text('Your Shopping List (3 Items)'.toUpperCase()),
      findsOneWidget,
    );

    await tester.tap(find.text('Compare'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('COMPARISON COMPLETE'), findsOneWidget);
    expect(find.text('ZMW 860.00'), findsWidgets);
    expect(find.text('Total Basket By Shop'.toUpperCase()), findsOneWidget);
  });

  testWidgets('search opens a modal sheet to pick items', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ShopRightApp());

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    expect(find.text('Add Items'), findsOneWidget);

    await tester.enterText(find.byType(TextField).last, 'meal');
    await tester.pump();

    expect(find.text('Breakfast Meal 25kg'), findsWidgets);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Add Items'), findsNothing);
  });

  testWidgets('swipe left removes an item from the list', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ShopRightApp());

    final card = find.widgetWithText(Dismissible, 'Cooking Oil 2.5L');
    expect(card, findsOneWidget);

    await tester.drag(card, const Offset(-500, 0));
    await tester.pumpAndSettle();

    expect(card, findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet taps toggle item selection', (tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const ShopRightApp());

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Roller Meal 10kg'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Dismissible, 'Roller Meal 10kg'), findsOneWidget);

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Roller Meal 10kg'));
    await tester.pump();
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Dismissible, 'Roller Meal 10kg'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
