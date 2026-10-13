// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:food_ingredient_scanner/main.dart';
import 'package:food_ingredient_scanner/providers/app_provider.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    final appProvider = AppProvider();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appProvider,
        child: MyApp(appProvider: appProvider),
      ),
    );

    // Verify that the app title is displayed.
    expect(find.text('FoodScan'), findsOneWidget);
  });
}
