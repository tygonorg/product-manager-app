
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:integration_test/integration_test.dart';
import 'package:product_manager_app/main.dart' as app;
import 'package:product_manager_app/models/customer.dart';
import 'package:product_manager_app/models/product.dart';
import 'package:product_manager_app/services/database_service.dart';
import 'package:realm/realm.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Create Export Order E2E Test', () {
    setUpAll(() async {
      // This setup runs once before all tests in this group.
      final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
      
      // Start the app
      app.main();
      await binding.pumpAndSettle();

      // Login to initialize services
      await binding.tester.enterText(find.byType(TextField), '123456');
      await binding.tester.tap(find.byType(ElevatedButton));
      await binding.pumpAndSettle(const Duration(seconds: 2));

      // Get database service
      final dbService = GetIt.I<DatabaseService>();

      // Create seed data
      final testCustomer = Customer(ObjectId(), 'Test Customer', email: 'test@customer.com');
      final testProduct = Product(ObjectId(), 'Test Product', price: 150, quantity: 50);
      
      await dbService.addCustomer(testCustomer);
      await dbService.addProduct(testProduct);
      
      // Go back to the dashboard to ensure a clean state for the test
      await binding.tester.tap(find.byIcon(Icons.dashboard));
      await binding.pumpAndSettle();
    });

    testWidgets('should create a new export order and verify it is in the list',
        (WidgetTester tester) async {
      // At this point, the app is already running and logged in.
      // Test data ("Test Customer", "Test Product") already exists.

      // --- Navigate to Exports Screen ---
      await tester.tap(find.byIcon(Icons.outbox));
      await tester.pumpAndSettle();

      // --- Tap the Add Export Button ---
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // --- Fill Export Details ---
      // Select the customer we created in setUpAll
      await tester.tap(find.byKey(const Key('customerDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Customer').last);
      await tester.pumpAndSettle();

      // Add a product to the order
      await tester.tap(find.byKey(const Key('addProductButton')));
      await tester.pumpAndSettle();

      // Select the product we created in setUpAll
      await tester.tap(find.text('Test Product').last);
      await tester.pumpAndSettle();

      // Enter quantity
      await tester.enterText(find.byKey(const Key('quantityField')), '5');
      await tester.pumpAndSettle();

      // Confirm adding the product
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // --- Save the Export Order ---
      await tester.tap(find.text('Create Export'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // --- Verify the Export Order is in the list ---
      expect(find.text('Test Customer'), findsOneWidget);
    });
  });
}
