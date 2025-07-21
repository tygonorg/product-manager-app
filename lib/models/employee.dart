import 'package:realm/realm.dart';

part 'employee.realm.dart';

@RealmModel()
class _Employee {
  @PrimaryKey()
  late String id;

  late String name;
  late String position;
  late String email;
  late String phone;
  late DateTime startDate;
  late DateTime createdAt;
  late DateTime updatedAt;
}
