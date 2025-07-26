import 'package:realm/realm.dart';

part 'export.realm.dart';

@RealmModel()
class _Export {
  @PrimaryKey()
  late String id;
  
  late String employeeId; // ID của nhân viên thực hiện xuất hàng
  
  // New customer relationship - using ObjectId/UUID reference
  late String customerId; // ObjectId or UUID reference to Customer
  
  // Obsolete fields - marked for migration
  @Deprecated('Use customerId instead. Will be removed in future version.')
  late String? customerName;
  @Deprecated('Use customerId instead. Will be removed in future version.')
  late String? customerPhone;
  
  late DateTime exportDate;
  late double totalAmount;
  
  late String itemsJson;
}
