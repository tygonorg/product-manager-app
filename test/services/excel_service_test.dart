import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:product_manager_app/models/product.dart';
import 'package:product_manager_app/services/excel_service.dart';

void main() {
  test('exportInventoryReport creates summary sheet', () {
    final service = ExcelService();
    final now = DateTime.now();
    final products = [
      Product('1', 'A', 'desc', 10.0, 2, 'CatA', now, now, ''),
      Product('2', 'B', 'desc', 20.0, 1, 'CatA', now, now, ''),
      Product('3', 'C', 'desc', 5.0, 4, 'CatB', now, now, ''),
    ];

    final file = File('test_report.xlsx');
    service.exportInventoryReport(file.path, products);

    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel['InventoryReport'];

    final rowA = sheet.rows[1];
    final rowB = sheet.rows[2];

    expect(rowA[0]!.value, 'CatA');
    expect(rowA[1]!.value, 3);
    expect(rowA[2]!.value, 40.0);

    expect(rowB[0]!.value, 'CatB');
    expect(rowB[1]!.value, 4);
    expect(rowB[2]!.value, 20.0);

    file.deleteSync();
  });
}
