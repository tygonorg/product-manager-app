import 'package:realm/realm.dart';
import './product.dart';
import './export_item.dart';

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
