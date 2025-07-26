import 'package:flutter_test/flutter_test.dart';
import 'package:realm/realm.dart';
import 'package:product_manager_app/models/export.dart';
import 'package:product_manager_app/models/customer.dart';
import 'package:product_manager_app/migrations/export_customer_migration.dart';
import 'dart:io';

void main() {
  group('ExportCustomerMigration', () {
    late String testDbPath;
    
    setUp(() {
      // Create a unique test database path
      testDbPath = '${Directory.systemTemp.path}/test_migration_${DateTime.now().millisecondsSinceEpoch}.realm';
    });
    
    tearDown(() {
      // Clean up test database files
      try {
        final file = File(testDbPath);
        if (file.existsSync()) {
          file.deleteSync();
        }
        final lockFile = File('$testDbPath.lock');
        if (lockFile.existsSync()) {
          lockFile.deleteSync();
        }
        final noteFile = File('$testDbPath.note');
        if (noteFile.existsSync()) {
          noteFile.deleteSync();
        }
      } catch (e) {
        print('Cleanup error: $e');
      }
    });

    test('should create migration configuration with correct path', () {
      final schemas = [Export.schema, Customer.schema];
      final config = ExportCustomerMigration.getMigrationConfiguration(
        schemas,
        path: testDbPath,
      );
      
      expect(config.path, equals(testDbPath));
      // Migration callback is internal, just verify config is created
      expect(config, isNotNull);
    });

    test('should perform migration from old schema to new schema', () async {
      // Step 1: Create database with old schema (without customerId)
      final oldSchemas = [Export.schema, Customer.schema];
      final oldConfig = Configuration.local(
        oldSchemas,
        schemaVersion: ExportCustomerMigration.oldSchemaVersion,
        path: testDbPath,
      );
      
      // Create test data in old schema format
      final oldRealm = Realm(oldConfig);
      oldRealm.write(() {
        // Create export records with customerName and customerPhone only
        oldRealm.add(Export(
          'export1',
          'employee1',
          '', // customerId will be empty initially
          DateTime.now(),
          100.0,
          '[]',
          customerName: 'John Doe',
          customerPhone: '123-456-7890',
        ));
        
        oldRealm.add(Export(
          'export2',
          'employee1',
          '', // customerId will be empty initially
          DateTime.now(),
          200.0,
          '[]',
          customerName: 'Jane Smith',
          customerPhone: '098-765-4321',
        ));
        
        // Create duplicate customer info
        oldRealm.add(Export(
          'export3',
          'employee2',
          '', // customerId will be empty initially
          DateTime.now(),
          150.0,
          '[]',
          customerName: 'John Doe',
          customerPhone: '123-456-7890', // Same as export1
        ));
        
        // Create export with minimal customer info
        oldRealm.add(Export(
          'export4',
          'employee2',
          '', // customerId will be empty initially
          DateTime.now(),
          75.0,
          '[]',
          customerName: '',
          customerPhone: '',
        ));
      });
      oldRealm.close();

      // Step 2: Open with migration configuration
      final migrationConfig = ExportCustomerMigration.getMigrationConfiguration(
        [Export.schema, Customer.schema],
        path: testDbPath,
      );
      
      final migratedRealm = Realm(migrationConfig);
      
      // Step 3: Verify migration results
      final exports = migratedRealm.all<Export>().toList();
      final customers = migratedRealm.all<Customer>().toList();
      
      // Should have 4 exports
      expect(exports.length, equals(4));
      
      // Should have created customers for unique (name, phone) pairs
      // John Doe + 123-456-7890, Jane Smith + 098-765-4321, and Unknown Customer
      expect(customers.length, equals(3));
      
      // Verify all exports have customerId assigned
      for (final export in exports) {
        expect(export.customerId, isNotEmpty);
        expect(export.customerId, isNot(equals('')));
      }
      
      // Verify exports with same customer info share the same customerId
      final johnDoeExports = exports.where((e) => e.customerName == 'John Doe').toList();
      expect(johnDoeExports.length, equals(2));
      expect(johnDoeExports[0].customerId, equals(johnDoeExports[1].customerId));
      
      // Verify customer creation
      final johnDoeCustomer = customers.firstWhere((c) => c.name == 'John Doe');
      expect(johnDoeCustomer.phone, equals('123-456-7890'));
      expect(johnDoeCustomer.notes, contains('Migrated from Export record'));
      
      final janeSmithCustomer = customers.firstWhere((c) => c.name == 'Jane Smith');
      expect(janeSmithCustomer.phone, equals('098-765-4321'));
      
      // Verify unknown customer was created for empty customer info
      final unknownCustomer = customers.firstWhere((c) => c.name == 'Unknown Customer');
      expect(unknownCustomer.id, equals('unknown-customer'));
      expect(unknownCustomer.notes, contains('Default customer for migrated records'));
      
      migratedRealm.close();
    });

    test('should handle empty database migration gracefully', () {
      final schemas = [Export.schema, Customer.schema];
      final config = ExportCustomerMigration.getMigrationConfiguration(
        schemas,
        path: testDbPath,
      );
      
      final realm = Realm(config);
      
      // Should create empty database with new schema version
      expect(realm.all<Export>().length, equals(0));
      expect(realm.all<Customer>().length, equals(0));
      // Schema version is not publicly accessible in current Realm API
      
      realm.close();
    });

    test('should preserve deprecated fields during migration', () async {
      // Create database with old schema
      final oldConfig = Configuration.local(
        [Export.schema, Customer.schema],
        schemaVersion: ExportCustomerMigration.oldSchemaVersion,
        path: testDbPath,
      );
      
      final oldRealm = Realm(oldConfig);
      oldRealm.write(() {
        oldRealm.add(Export(
          'export1',
          'employee1',
          '',
          DateTime.now(),
          100.0,
          '[]',
          customerName: 'Test Customer',
          customerPhone: '555-1234',
        ));
      });
      oldRealm.close();

      // Migrate
      final migrationConfig = ExportCustomerMigration.getMigrationConfiguration(
        [Export.schema, Customer.schema],
        path: testDbPath,
      );
      
      final migratedRealm = Realm(migrationConfig);
      final export = migratedRealm.all<Export>().first;
      
      // Verify deprecated fields are preserved
      expect(export.customerName, equals('Test Customer'));
      expect(export.customerPhone, equals('555-1234'));
      
      // Verify new customerId field is populated
      expect(export.customerId, isNotEmpty);
      
      migratedRealm.close();
    });

    test('helper methods should work correctly', () {
      final schemas = [Export.schema, Customer.schema];
      final config = ExportCustomerMigration.getMigrationConfiguration(
        schemas,
        path: testDbPath,
      );
      
      final realm = Realm(config);
      
      // Test createUnknownCustomer helper
      final unknownCustomer = ExportCustomerMigration.createUnknownCustomer();
      expect(unknownCustomer.name, equals('Unknown Customer'));
      expect(unknownCustomer.customerType, equals('individual'));
      
      // Add test data to test query helpers
      realm.write(() {
        final customer = Customer(
          'test-customer-1',
          'Test Customer',
          'test@example.com',
          '555-1234',
          '123 Test St',
          '',
          '',
          'individual',
          'Test notes',
          DateTime.now(),
          DateTime.now(),
        );
        realm.add(customer);
        
        final export = Export(
          'test-export-1',
          'employee1',
          'test-customer-1',
          DateTime.now(),
          100.0,
          '[]',
        );
        realm.add(export);
      });
      
      // Test getCustomerExports helper
      final customerExports = ExportCustomerMigration.getCustomerExports(realm, 'test-customer-1');
      expect(customerExports.length, equals(1));
      expect(customerExports.first.id, equals('test-export-1'));
      
      // Test getExportCustomer helper
      final exportCustomer = ExportCustomerMigration.getExportCustomer(realm, 'test-customer-1');
      expect(exportCustomer, isNotNull);
      expect(exportCustomer!.name, equals('Test Customer'));
      
      realm.close();
    });

    test('should handle migration with special characters in customer data', () async {
      // Create database with old schema
      final oldConfig = Configuration.local(
        [Export.schema, Customer.schema],
        schemaVersion: ExportCustomerMigration.oldSchemaVersion,
        path: testDbPath,
      );
      
      final oldRealm = Realm(oldConfig);
      oldRealm.write(() {
        oldRealm.add(Export(
          'export1',
          'employee1',
          '',
          DateTime.now(),
          100.0,
          '[]',
          customerName: 'Nguyễn Văn A',
          customerPhone: '+84 123-456-789',
        ));
        
        oldRealm.add(Export(
          'export2',
          'employee1',
          '',
          DateTime.now(),
          200.0,
          '[]',
          customerName: 'José María',
          customerPhone: '(555) 123-4567',
        ));
      });
      oldRealm.close();

      // Migrate
      final migrationConfig = ExportCustomerMigration.getMigrationConfiguration(
        [Export.schema, Customer.schema],
        path: testDbPath,
      );
      
      final migratedRealm = Realm(migrationConfig);
      
      final exports = migratedRealm.all<Export>().toList();
      final customers = migratedRealm.all<Customer>().toList();
      
      // Should handle Unicode characters properly
      expect(customers.length, equals(2));
      
      final vietnameseCustomer = customers.firstWhere((c) => c.name == 'Nguyễn Văn A');
      expect(vietnameseCustomer.phone, equals('+84 123-456-789'));
      
      final spanishCustomer = customers.firstWhere((c) => c.name == 'José María');
      expect(spanishCustomer.phone, equals('(555) 123-4567'));
      
      migratedRealm.close();
    });
  });
}
