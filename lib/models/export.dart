import 'package:realm/realm.dart';

part 'export.realm.dart';

@RealmModel()
class _Export {
  @PrimaryKey()
  late String id;
  
  late String employeeId; // ID của nhân viên thực hiện xuất hàng
  late String customerName;
  late String customerPhone;
  late DateTime exportDate;
  late double totalAmount;
  
  late String itemsJson;
}
