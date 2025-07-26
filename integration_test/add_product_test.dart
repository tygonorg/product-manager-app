
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:product_manager_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Add Product E2E Test', () {
    testWidgets('should add a new product and verify it is in the list',
        (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Enter password
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Navigate to products screen
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle();

      // Tap the add product button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Enter product details
      await tester.enterText(find.byKey(const Key('productName')), 'New Product');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('productDescription')), 'This is a new product.');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('productPrice')), '100');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('productSKU')), 'SKU123');
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('productQuantity')), '10');
      await tester.pumpAndSettle();

      // Select a category
      await tester.tap(find.byKey(const Key('categoryDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Electronics').last);
      await tester.pumpAndSettle();

      // Save the product
      await tester.tap(find.text('Add Product'));
      await tester.pumpAndSettle();

      // Verify the product is in the list
      expect(find.text('New Product'), findsOneWidget);
      expect(find.text('This is a new product.'), findsOneWidget);
    });
  });
}
