import 'package:flutter_test/flutter_test.dart';

import 'package:medivault/main.dart';

void main() {
  testWidgets('MediVault app launches and shows SplashScreen', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const MediVaultApp());

    // Verify MediVault text is shown on splash screen
    expect(find.text('MediVault'), findsOneWidget);
    expect(find.text('Your Lifelong Medical Record'), findsOneWidget);

    // Advance past the 7-second splash timer to avoid pending timer error
    await tester.pump(const Duration(seconds: 8));
  });
}