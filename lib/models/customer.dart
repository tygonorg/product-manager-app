import 'package:realm/realm.dart';

part 'customer.realm.dart';

@RealmModel()
class _Customer {
  @PrimaryKey()
  late String id;

  late String name;
  late String email;
  late String phone;
  late String address;
  late String company;
  late String taxCode; // Mã số thuế
  late String customerType; // "individual" hoặc "company"
  late String notes; // Ghi chú
  late DateTime createdAt;
  late DateTime updatedAt;
}
