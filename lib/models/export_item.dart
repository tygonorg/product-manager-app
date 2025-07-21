import 'package:realm/realm.dart';

part 'export_item.realm.dart';

@RealmModel()
class _ExportItem {
  late String productId;
  late String productName; // Để tiện hiển thị
  late double priceAtExport;
  late int quantity;
}
