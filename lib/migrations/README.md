# Realm Migration Guide

## Export-Customer Migration (Schema Version 1 → 2)

This migration handles the transition from storing customer information directly in Export records (customerName, customerPhone) to using a proper Customer relationship model.

### What the Migration Does

1. **Creates Customer Records**: For each unique combination of (customerName, customerPhone) found in existing Export records, creates a new Customer record with a generated UUID.

2. **Assigns Customer IDs**: Updates all Export records to reference the appropriate Customer via the `customerId` field.

3. **Preserves Deprecated Fields**: Keeps the old `customerName` and `customerPhone` fields for backward compatibility (marked as `@Deprecated`).

4. **Handles Edge Cases**: Creates an "Unknown Customer" record for exports with missing or empty customer information.

### Schema Changes

#### Before (Schema Version 1)
```dart
class Export {
  String id;
  String employeeId;
  String? customerName;      // Direct storage
  String? customerPhone;     // Direct storage
  DateTime exportDate;
  double totalAmount;
  String itemsJson;
}
```

#### After (Schema Version 2)
```dart
class Export {
  String id;
  String employeeId;
  String customerId;         // New: Reference to Customer
  @Deprecated String? customerName;      // Preserved for compatibility
  @Deprecated String? customerPhone;     // Preserved for compatibility
  DateTime exportDate;
  double totalAmount;
  String itemsJson;
}

class Customer {
  String id;                 // New entity
  String name;
  String email;
  String phone;
  String address;
  String company;
  String taxCode;
  String customerType;
  String notes;
  DateTime createdAt;
  DateTime updatedAt;
}
```

### Usage

The migration is automatically applied when initializing the database:

```dart
import '../migrations/export_customer_migration.dart';

// In DatabaseService.initDatabase()
final config = ExportCustomerMigration.getMigrationConfiguration(
  schemas,
  path: dbPath,
  encryptionKey: encryptionKey,
);

final realm = Realm(config);
```

### Helper Methods

The migration class provides several helper methods for working with the new relationship:

```dart
// Get all exports for a customer
final exports = ExportCustomerMigration.getCustomerExports(realm, customerId);

// Get customer for an export
final customer = ExportCustomerMigration.getExportCustomer(realm, export.customerId);

// Create a default "Unknown Customer"
final unknownCustomer = ExportCustomerMigration.createUnknownCustomer();
```

### Testing

Run the migration tests to verify functionality:

```bash
flutter test test/migrations/export_customer_migration_test.dart
```

The tests cover:
- Basic migration from old to new schema
- Handling of duplicate customer information
- Creation of unique Customer records
- Preservation of deprecated fields
- Special characters in customer names
- Empty database migration
- Helper method functionality

### Rollback Considerations

⚠️ **Important**: This migration is not easily reversible because:

1. Customer records are created with generated UUIDs
2. The relationship is normalized (multiple exports can reference the same customer)
3. Customer data may be cleaned/standardized during migration

**Before running in production:**
1. Create a backup of your Realm database
2. Test the migration thoroughly with your actual data
3. Verify that your application works correctly with the new schema

### Performance Notes

- Migration time is proportional to the number of Export records
- Memory usage scales with the number of unique (customerName, customerPhone) combinations
- Consider running migration during off-peak hours for large datasets

### Troubleshooting

**Migration fails with "Schema mismatch" error:**
- Ensure all model files are properly generated with `dart run realm generate`
- Verify that the schema version constants are correct

**Customer records not created:**
- Check that Export records have valid customerName/customerPhone data
- Review migration logs for error messages

**Performance issues:**
- For very large datasets (>100k exports), consider implementing batch processing
- Monitor memory usage during migration

**Data integrity issues:**
- Verify that all Export records have a valid customerId after migration
- Check that Customer records were created correctly
- Use the provided test suite to validate migration logic
