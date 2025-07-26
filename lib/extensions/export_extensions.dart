import 'package:realm/realm.dart';
import '../models/export.dart';
import '../models/customer.dart';

/// Extension methods for Export model to provide easy access to customer relationships
extension ExportCustomerExtension on Export {
  /// Gets the customer associated with this export
  /// Returns null if customer is not found
  Customer? getCustomer(Realm realm) {
    return realm.find<Customer>(customerId);
  }
  
  /// Gets the customer name, preferring the relationship over deprecated field
  /// Fallback to deprecated customerName for backward compatibility during migration
  String getCustomerName(Realm realm) {
    final customer = getCustomer(realm);
    if (customer != null) {
      return customer.name;
    }
    
    // Fallback to deprecated field during migration period
    if (customerName != null && customerName!.isNotEmpty) {
      return customerName!;
    }
    
    return 'Unknown Customer';
  }
  
  /// Gets the customer phone, preferring the relationship over deprecated field
  /// Fallback to deprecated customerPhone for backward compatibility during migration
  String getCustomerPhone(Realm realm) {
    final customer = getCustomer(realm);
    if (customer != null) {
      return customer.phone;
    }
    
    // Fallback to deprecated field during migration period
    if (customerPhone != null && customerPhone!.isNotEmpty) {
      return customerPhone!;
    }
    
    return 'Unknown Phone';
  }
  
  /// Gets full customer contact info as a formatted string
  String getCustomerContactInfo(Realm realm) {
    final customer = getCustomer(realm);
    if (customer != null) {
      return '${customer.name} - ${customer.phone}';
    }
    
    // Fallback to deprecated fields during migration period
    final name = customerName ?? 'Unknown Customer';
    final phone = customerPhone ?? 'Unknown Phone';
    return '$name - $phone';
  }
  
  /// Checks if this export has valid customer data
  bool hasValidCustomer(Realm realm) {
    return getCustomer(realm) != null;
  }
  
  /// Gets customer email if available
  String getCustomerEmail(Realm realm) {
    final customer = getCustomer(realm);
    return customer?.email ?? '';
  }
  
  /// Gets customer address if available  
  String getCustomerAddress(Realm realm) {
    final customer = getCustomer(realm);
    return customer?.address ?? '';
  }
  
  /// Gets customer company if available
  String getCustomerCompany(Realm realm) {
    final customer = getCustomer(realm);
    return customer?.company ?? '';
  }
  
  /// Checks if export is using deprecated customer fields (for migration tracking)
  bool isUsingDeprecatedCustomerFields() {
    return (customerName != null && customerName!.isNotEmpty) || 
           (customerPhone != null && customerPhone!.isNotEmpty);
  }
}

/// Extension methods for Customer model to get related exports
extension CustomerExportExtension on Customer {
  /// Gets all exports for this customer
  RealmResults<Export> getExports(Realm realm) {
    return realm.query<Export>('customerId == \$0', [id]);
  }
  
  /// Gets export count for this customer
  int getExportCount(Realm realm) {
    return getExports(realm).length;
  }
  
  /// Gets total amount from all exports for this customer
  double getTotalExportAmount(Realm realm) {
    final exports = getExports(realm);
    return exports.fold(0.0, (sum, export) => sum + export.totalAmount);
  }
  
  /// Gets exports for this customer in a date range
  RealmResults<Export> getExportsInDateRange(Realm realm, DateTime startDate, DateTime endDate) {
    return realm.query<Export>('customerId == \$0 AND exportDate >= \$1 AND exportDate <= \$2', 
        [id, startDate, endDate]);
  }
  
  /// Gets the most recent export for this customer
  Export? getLatestExport(Realm realm) {
    final exports = realm.query<Export>('customerId == \$0 SORT(exportDate DESC)', [id]);
    return exports.isNotEmpty ? exports.first : null;
  }
}
