
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:product_manager_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Customer E2E Test', () {
    testWidgets('should add a new customer and verify it is in the list',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // --- Login --- 
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Wait for navigation

      // --- Navigate to Customers Screen ---
      // Assuming the navigation icon for customers is Icons.people
      await tester.tap(find.byIcon(Icons.people));
      await tester.pumpAndSettle();

      // --- Tap the Add Customer Button ---
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // --- Enter Customer Details ---
      // IMPORTANT: You must add these Keys to your TextFormFields
      await tester.enterText(find.byKey(const Key('customerName')), 'New Customer');
      await tester.enterText(find.byKey(const Key('customerEmail')), 'customer@example.com');
      await tester.enterText(find.byKey(const Key('customerPhone')), '0123456789');
      await tester.pumpAndSettle();

      // --- Save the Customer ---
      // Assuming the save button has the text 'Add Customer'
      await tester.tap(find.text('Add Customer'));
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Wait for navigation

      // --- Verify the Customer is in the list ---
      expect(find.text('New Customer'), findsOneWidget);
      expect(find.text('customer@example.com'), findsOneWidget);
    });
  });
}
