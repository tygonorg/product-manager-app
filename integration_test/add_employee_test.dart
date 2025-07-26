
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:product_manager_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Employee E2E Test', () {
    testWidgets('should add a new employee and verify it is in the list',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // --- Login --- 
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Wait for navigation

      // --- Navigate to Employees Screen ---
      // Assuming the navigation icon for employees is Icons.badge
      await tester.tap(find.byIcon(Icons.badge));
      await tester.pumpAndSettle();

      // --- Tap the Add Employee Button ---
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // --- Enter Employee Details ---
      // IMPORTANT: You must add these Keys to your TextFormFields
      await tester.enterText(find.byKey(const Key('employeeName')), 'New Employee');
      await tester.enterText(find.byKey(const Key('employeePosition')), 'Developer');
      await tester.pumpAndSettle();

      // --- Save the Employee ---
      // Assuming the save button has the text 'Add Employee'
      await tester.tap(find.text('Add Employee'));
      await tester.pumpAndSettle(const Duration(seconds: 2)); // Wait for navigation

      // --- Verify the Employee is in the list ---
      expect(find.text('New Employee'), findsOneWidget);
      expect(find.text('Developer'), findsOneWidget);
    });
  });
}
