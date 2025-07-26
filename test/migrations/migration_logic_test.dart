import 'package:flutter_test/flutter_test.dart';
import 'package:product_manager_app/models/export.dart';
import 'package:product_manager_app/models/customer.dart';
import 'package:product_manager_app/migrations/export_customer_migration.dart';

void main() {
  group('ExportCustomerMigration Logic Tests', () {
    test('should have correct schema version constants', () {
      expect(ExportCustomerMigration.oldSchemaVersion, equals(1));
      expect(ExportCustomerMigration.newSchemaVersion, equals(2));
      expect(ExportCustomerMigration.newSchemaVersion > ExportCustomerMigration.oldSchemaVersion, isTrue);
    });

    test('createUnknownCustomer should create valid customer object', () {
      final customer = ExportCustomerMigration.createUnknownCustomer();
      
      expect(customer.id, equals('unknown'));
      expect(customer.name, equals('Unknown Customer'));
      expect(customer.email, isEmpty);
      expect(customer.phone, isEmpty);
      expect(customer.address, isEmpty);
      expect(customer.company, isEmpty);
      expect(customer.taxCode, isEmpty);
      expect(customer.customerType, equals('individual'));
      expect(customer.notes, contains('Default customer for migrated records'));
      expect(customer.createdAt, isA<DateTime>());
      expect(customer.updatedAt, isA<DateTime>());
    });

    test('migration configuration should be created with proper parameters', () {
      final schemas = [Export.schema, Customer.schema];
      final testPath = '/tmp/test.realm';
      // Encryption key must be 64 bytes
      final testKey = List<int>.generate(64, (index) => index % 256);
      
      final config = ExportCustomerMigration.getMigrationConfiguration(
        schemas,
        path: testPath,
        encryptionKey: testKey,
      );
      
      expect(config, isNotNull);
      expect(config.path, equals(testPath));
    });

    test('should handle customer key generation correctly', () {
      // Test the logic that would be used in migration
      final testData = [
        {'name': 'John Doe', 'phone': '123-456-7890'},
        {'name': 'Jane Smith', 'phone': '098-765-4321'},
        {'name': 'John Doe', 'phone': '123-456-7890'}, // Duplicate
        {'name': '', 'phone': ''},
        {'name': 'Special Chars', 'phone': '+84 (123) 456-789'},
      ];
      
      final Map<String, String> customerMap = {};
      int keyCount = 0;
      
      for (final data in testData) {
        final customerName = data['name'] ?? 'Unknown Customer';
        final customerPhone = data['phone'] ?? '';
        final customerKey = '${customerName.trim()}|${customerPhone.trim()}';
        
        if (!customerMap.containsKey(customerKey)) {
          customerMap[customerKey] = 'customer-${++keyCount}';
        }
      }
      
      // Should create 4 unique keys (John Doe, Jane Smith, empty, Special Chars)
      expect(customerMap.length, equals(4));
      expect(customerMap.containsKey('John Doe|123-456-7890'), isTrue);
      expect(customerMap.containsKey('Jane Smith|098-765-4321'), isTrue);
      expect(customerMap.containsKey('|'), isTrue); // Empty name and phone
      expect(customerMap.containsKey('Special Chars|+84 (123) 456-789'), isTrue);
    });

    test('should handle Unicode characters in customer names', () {
      final testData = [
        {'name': 'Nguyễn Văn A', 'phone': '+84 123-456-789'},
        {'name': 'José María', 'phone': '(555) 123-4567'},
        {'name': '王小明', 'phone': '186-1234-5678'},
      ];
      
      final Map<String, String> customerMap = {};
      int keyCount = 0;
      
      for (final data in testData) {
        final customerName = data['name'] ?? 'Unknown Customer';
        final customerPhone = data['phone'] ?? '';
        final customerKey = '${customerName.trim()}|${customerPhone.trim()}';
        
        if (!customerMap.containsKey(customerKey)) {
          customerMap[customerKey] = 'customer-${++keyCount}';
        }
      }
      
      expect(customerMap.length, equals(3));
      expect(customerMap.containsKey('Nguyễn Văn A|+84 123-456-789'), isTrue);
      expect(customerMap.containsKey('José María|(555) 123-4567'), isTrue);
      expect(customerMap.containsKey('王小明|186-1234-5678'), isTrue);
    });

    test('should handle whitespace trimming correctly', () {
      final testData = [
        {'name': '  John Doe  ', 'phone': '  123-456-7890  '},
        {'name': 'John Doe', 'phone': '123-456-7890'},
        {'name': '\tJane Smith\n', 'phone': '\r098-765-4321\t'},
      ];
      
      final Map<String, String> customerMap = {};
      int keyCount = 0;
      
      for (final data in testData) {
        final customerName = data['name'] ?? 'Unknown Customer';
        final customerPhone = data['phone'] ?? '';
        final customerKey = '${customerName.trim()}|${customerPhone.trim()}';
        
        if (!customerMap.containsKey(customerKey)) {
          customerMap[customerKey] = 'customer-${++keyCount}';
        }
      }
      
      // Should only create 2 unique keys due to trimming
      expect(customerMap.length, equals(2));
      expect(customerMap.containsKey('John Doe|123-456-7890'), isTrue);
      expect(customerMap.containsKey('Jane Smith|098-765-4321'), isTrue);
    });

    test('should validate Export model schema', () {
      final export = Export(
        'test-id',
        'employee-id',
        'customer-id',
        DateTime.now(),
        100.0,
        '[]',
        customerName: 'Test Customer',
        customerPhone: '555-1234',
      );
      
      expect(export.id, equals('test-id'));
      expect(export.employeeId, equals('employee-id'));
      expect(export.customerId, equals('customer-id'));
      expect(export.totalAmount, equals(100.0));
      expect(export.itemsJson, equals('[]'));
      expect(export.customerName, equals('Test Customer'));
      expect(export.customerPhone, equals('555-1234'));
    });

    test('should validate Customer model schema', () {
      final now = DateTime.now();
      final customer = Customer(
        'test-id',
        'Test Customer',
        'test@example.com',
        '555-1234',
        '123 Test St',
        'Test Company',
        'TAX123',
        'company',
        'Test notes',
        now,
        now,
      );
      
      expect(customer.id, equals('test-id'));
      expect(customer.name, equals('Test Customer'));
      expect(customer.email, equals('test@example.com'));
      expect(customer.phone, equals('555-1234'));
      expect(customer.address, equals('123 Test St'));
      expect(customer.company, equals('Test Company'));
      expect(customer.taxCode, equals('TAX123'));
      expect(customer.customerType, equals('company'));
      expect(customer.notes, equals('Test notes'));
      expect(customer.createdAt, equals(now));
      expect(customer.updatedAt, equals(now));
    });

    test('should verify schema objects are properly defined', () {
      expect(Export.schema, isNotNull);
      expect(Customer.schema, isNotNull);
      
      final exportSchema = Export.schema;
      final customerSchema = Customer.schema;
      
      expect(exportSchema.name, equals('Export'));
      expect(customerSchema.name, equals('Customer'));
      
      // Schema property access is not available in current Realm API
      // but we can verify the schema objects are defined and have correct names
    });
  });
}
