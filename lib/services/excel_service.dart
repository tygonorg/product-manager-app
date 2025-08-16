import 'dart:io';
import 'package:excel/excel.dart';
import '../models/product.dart';

class ExcelService {
  List<Product> importProducts(String filePath) {
    final bytes = File(filePath).readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel.sheets.values.first;
    final products = <Product>[];

    for (final row in sheet.rows.skip(1)) {
      final id = row[0]?.value.toString() ?? '';
      final name = row[1]?.value.toString() ?? '';
      final description = row[2]?.value.toString() ?? '';
      final price = double.tryParse(row[3]?.value.toString() ?? '') ?? 0;
      final quantity = int.tryParse(row[4]?.value.toString() ?? '') ?? 0;
      final category = row[5]?.value.toString() ?? '';
      final imageUrl = row.length > 6 ? row[6]?.value.toString() ?? '' : '';
      final now = DateTime.now();
      products.add(Product(id, name, description, price, quantity, category, now, now, imageUrl));
    }

    return products;
  }

  void exportProducts(String filePath, List<Product> products) {
    final excel = Excel.createExcel();
    final sheet = excel['Products'];
    sheet.appendRow(['ID', 'Name', 'Description', 'Price', 'Quantity', 'Category', 'ImageUrl']);
    for (final p in products) {
      sheet.appendRow([p.id, p.name, p.description, p.price, p.quantity, p.category, p.imageUrl]);
    }
    final bytes = excel.encode();
    File(filePath).writeAsBytesSync(bytes!);
  }
}
