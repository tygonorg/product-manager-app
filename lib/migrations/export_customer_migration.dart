import 'package:realm/realm.dart';
import '../models/export.dart';
import '../models/customer.dart';
import 'package:uuid/uuid.dart' as uuid_pkg;

/// Migration helper for updating Export model from customerName/customerPhone 
/// to customerId relationship
class ExportCustomerMigration {
  static const int oldSchemaVersion = 1; // Schema version without customerId
  static const int newSchemaVersion = 2; // New schema version with customerId
  
  /// Performs migration from old Export schema to new schema
  /// This should be called during app initialization before opening Realm
  static Configuration getMigrationConfiguration(
    List<SchemaObject> schemas, {
    String? path,
    List<int>? encryptionKey,
  }) {
    return Configuration.local(
      schemas,
      schemaVersion: newSchemaVersion,
      path: path,
      encryptionKey: encryptionKey,
      migrationCallback: (migration, oldSchemaVersion) {
        if (oldSchemaVersion < newSchemaVersion) {
          _migrateExportCustomerFields(migration);
        }
      },
    );
  }
  
  /// Migrates Export objects from customerName/customerPhone to customerId
  static void _migrateExportCustomerFields(Migration migration) {
    print('Starting Export customer field migration...');
    
    // Map to store unique (name, phone) combinations and their generated customer IDs
    final Map<String, String> customerMap = {};
    final uuid = uuid_pkg.Uuid();
    final now = DateTime.now();
    
    // Get old exports using the old realm
    final oldExports = migration.oldRealm.all('Export');
    print('Found ${oldExports.length} export records to migrate');
    
    // First pass: create Customer records for unique (name, phone) pairs
    for (final oldExport in oldExports) {
      final customerName = oldExport.dynamic.get<String?>('customerName') ?? 'Unknown Customer';
      final customerPhone = oldExport.dynamic.get<String?>('customerPhone') ?? '';
      
      // Create a unique key for this customer combination
      final customerKey = '${customerName.trim()}|${customerPhone.trim()}';
      
      if (!customerMap.containsKey(customerKey)) {
        // Generate new customer ID
        final customerId = uuid.v4();
        customerMap[customerKey] = customerId;
        
        // Create customer in new realm using the add method
        final newCustomer = Customer(
          customerId,
          customerName,
          '', // email
          customerPhone,
          '', // address
          '', // company
          '', // taxCode
          'individual', // customerType
          'Migrated from Export record', // notes
          now, // createdAt
          now, // updatedAt
        );
        migration.newRealm.add(newCustomer);
        
        print('Created customer: $customerName (ID: $customerId)');
      }
    }
    
    print('Created ${customerMap.length} unique customer records');
    
    // Second pass: update Export records with customerId
    final newExports = migration.newRealm.all<Export>();
    int updatedCount = 0;
    
    for (final newExport in newExports) {
      final customerName = newExport.customerName ?? 'Unknown Customer';
      final customerPhone = newExport.customerPhone ?? '';
      final customerKey = '${customerName.trim()}|${customerPhone.trim()}';
      
      if (customerMap.containsKey(customerKey)) {
        final customerId = customerMap[customerKey]!;
        newExport.customerId = customerId;
        updatedCount++;
      } else {
        // Fallback: create and assign unknown customer
        final unknownCustomerId = _getOrCreateUnknownCustomer(migration.newRealm, now);
        newExport.customerId = unknownCustomerId;
        updatedCount++;
      }
    }
    
    print('Updated $updatedCount export records with customer IDs');
    print('Export customer migration completed successfully!');
  }
  
  /// Creates or gets an "Unknown Customer" record for exports without valid customer data
  static String _getOrCreateUnknownCustomer(Realm newRealm, DateTime timestamp) {
    const unknownCustomerId = 'unknown-customer';
    
    // Check if unknown customer already exists
    final existingCustomer = newRealm.find<Customer>(unknownCustomerId);
    if (existingCustomer != null) {
      return unknownCustomerId;
    }
    
    // Create unknown customer
    final unknownCustomer = Customer(
      unknownCustomerId,
      'Unknown Customer',
      '', // email
      '', // phone
      '', // address
      '', // company
      '', // taxCode
      'individual', // customerType
      'Default customer for migrated records without customer information', // notes
      timestamp, // createdAt
      timestamp, // updatedAt
    );
    
    newRealm.add(unknownCustomer);
    return unknownCustomerId;
  }
  
  /// Helper method to create a default "Unknown Customer" if needed
  static Customer createUnknownCustomer() {
    return Customer(
      'unknown',
      'Unknown Customer',
      '',
      '',
      '',
      '',
      '',
      'individual',
      'Default customer for migrated records without customer information',
      DateTime.now(),
      DateTime.now(),
    );
  }
  
  /// Helper method to get customer exports (replacement for LinkingObjects)
  /// Usage: final exports = ExportCustomerMigration.getCustomerExports(realm, customer.id);
  static RealmResults<Export> getCustomerExports(Realm realm, String customerId) {
    return realm.query<Export>('customerId == \$0', [customerId]);
  }
  
  /// Helper method to get customer for an export
  /// Usage: final customer = ExportCustomerMigration.getExportCustomer(realm, export.customerId);  
  static Customer? getExportCustomer(Realm realm, String customerId) {
    return realm.find<Customer>(customerId);
  }
}
