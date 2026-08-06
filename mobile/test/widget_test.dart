import 'package:flutter_test/flutter_test.dart';

import 'package:shopright/app/shop_right_app.dart';

void main() {
  testWidgets('home screen opens the static comparison flow', (tester) async {
    await tester.pumpWidget(const ShopRightApp());

    expect(find.text('Shop Right'), findsOneWidget);
    expect(find.text('ZMW 1,200.00'), findsOneWidget);
    expect(
      find.text('Your Shopping List (3 Items)'.toUpperCase()),
      findsOneWidget,
    );

    await tester.tap(find.text('Compare All Shops & Lowest Prices'));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('COMPARISON COMPLETE'), findsOneWidget);
    expect(find.text('ZMW 860.00'), findsWidgets);
    expect(find.text('Optimal Split Purchase'), findsOneWidget);
  });
}
