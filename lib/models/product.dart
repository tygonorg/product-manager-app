import 'package:realm/realm.dart';

part 'product.realm.dart';

@RealmModel()
class _Product {
  @PrimaryKey()
  late String id;
  
  late String name;
  late String description;
  late double price;
  late int quantity;
  late String category;
  late DateTime createdAt;
  late DateTime updatedAt;
  late String imageUrl;
}
