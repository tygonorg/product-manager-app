# Export Model Customer Relationship Migration

## Overview
The Export model has been updated to use a proper customer relationship instead of storing customer name and phone directly. This improves data consistency and enables better customer management.

## Changes Made

### 1. Export Model Updates (`lib/models/export.dart`)
- **Added**: `customerId` field - ObjectId/UUID reference to Customer
- **Deprecated**: `customerName` and `customerPhone` fields (marked with `@Deprecated` annotation)
- **Note**: Old fields are kept as optional for migration compatibility

### 2. Customer Relationship
Instead of using direct Realm object relationships (which caused circular import issues), we use:
- **Export → Customer**: via `customerId` field with programmatic lookup
- **Customer → Exports**: via query `realm.query<Export>('customerId == $0', [customerId])`

### 3. Migration Support
- **Migration Helper**: `lib/migrations/export_customer_migration.dart`
- **Extensions**: `lib/extensions/export_extensions.dart` for easy relationship access

## Usage Examples

### Getting Customer from Export
```dart
// Using extension method (recommended)
import 'package:product_manager_app/extensions/export_extensions.dart';

final customer = export.getCustomer(realm);
final customerName = export.getCustomerName(realm); // Handles fallback to deprecated fields
final customerPhone = export.getCustomerPhone(realm);

// Or directly
final customer = realm.find<Customer>(export.customerId);
```

### Getting Exports for Customer
```dart
// Using extension method (recommended)
import 'package:product_manager_app/extensions/export_extensions.dart';

final exports = customer.getExports(realm);
final exportCount = customer.getExportCount(realm);
final totalAmount = customer.getTotalExportAmount(realm);

// Or directly
final exports = realm.query<Export>('customerId == \$0', [customer.id]);
```

### Creating New Export
```dart
final export = Export(
  ObjectId().hexString, // id
  employeeId,
  customer.id, // customerId - reference to existing customer
  DateTime.now(), // exportDate
  totalAmount,
  itemsJson,
);

// Set deprecated fields to null (they're optional now)
export.customerName = null;
export.customerPhone = null;

realm.write(() => realm.add(export));
```

## Migration Process

### 1. Automatic Migration
The migration helper will automatically:
- Find existing customers matching the name/phone from exports
- Create new customers if no match is found
- Set the `customerId` field appropriately
- Preserve deprecated fields for backward compatibility

### 2. Schema Version Update
Update your Realm configuration to use the migration:

```dart
import 'package:product_manager_app/migrations/export_customer_migration.dart';

final config = ExportCustomerMigration.getMigrationConfiguration([
  Export.schema,
  Customer.schema,
  // ... other schemas
]);

final realm = Realm(config);
```

### 3. Gradual Migration
During the transition period:
- New exports should use `customerId` only
- Old exports will have both `customerId` and deprecated fields
- Use extension methods which handle fallback automatically
- Deprecated fields can be removed in a future version

## Benefits

1. **Data Consistency**: Customer information is stored once in Customer table
2. **Referential Integrity**: Changes to customer data automatically reflect in all exports
3. **Better Queries**: Can efficiently query exports by customer or customer exports
4. **Extensibility**: Easy to add more customer fields without affecting Export model

## Testing Migration

1. **Backup Data**: Always backup your Realm database before migration
2. **Test Environment**: Run migration in test environment first
3. **Validation**: Check that all exports have valid `customerId` after migration
4. **Fallback Testing**: Ensure extension methods work with both new and old data

## Cleanup Plan

After confirming successful migration:
1. Update all UI code to use extension methods
2. Remove usage of deprecated `customerName` and `customerPhone` fields
3. In future version, remove deprecated fields entirely
4. Update schema version and remove migration code

## Code Examples

### Before (Old Implementation)
```dart
// Creating export
final export = Export(
  id,
  employeeId,
  'John Doe', // customerName
  '+1234567890', // customerPhone
  exportDate,
  totalAmount,
  itemsJson,
);

// Displaying customer info
Text('Customer: ${export.customerName}');
Text('Phone: ${export.customerPhone}');
```

### After (New Implementation)
```dart
// Creating export
final export = Export(
  id,
  employeeId,
  customer.id, // customerId
  exportDate,
  totalAmount,
  itemsJson,
);

// Displaying customer info (using extensions)
Text('Customer: ${export.getCustomerName(realm)}');
Text('Phone: ${export.getCustomerPhone(realm)}');
Text('Email: ${export.getCustomerEmail(realm)}'); // Now available!
```

## Troubleshooting

### Migration Issues
- Check that Customer data exists before running migration
- Ensure schema version is properly incremented
- Verify migration callback is registered

### Runtime Issues
- Import extension files where needed
- Pass Realm instance to extension methods
- Handle null customers gracefully

### Performance
- Consider indexing `customerId` field for better query performance
- Use `realm.query()` instead of filtering in memory for large datasets
