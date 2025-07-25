import 'dart:convert';
import 'package:get/get.dart';
import 'package:product_manager_app/models/export.dart';
import 'package:product_manager_app/models/export_item_data.dart';
import 'package:product_manager_app/services/database_service.dart';
import 'package:realm/realm.dart';
import 'package:product_manager_app/models/category.dart'; // Import Category model

import 'package:product_manager_app/core/service_locator.dart';

class StatisticsController extends GetxController {
  final DatabaseService _databaseService = serviceLocator<DatabaseService>();
  final RxMap<String, int> productSales = <String, int>{}.obs;
  final RxMap<String, int> categorySales = <String, int>{}.obs; // New: Sales by category
  final RxMap<String, double> monthlySales = <String, double>{}.obs;
  final RxMap<String, double> quarterlySales = <String, double>{}.obs;
  final RxMap<String, double> yearlySales = <String, double>{}.obs;

  final RxString selectedChartType = 'product'.obs; // 'product' or 'category'

  @override
  void onInit() {
    super.onInit();
    fetchStatistics();
  }

  void fetchStatistics() {
    final exports = _databaseService.realm.all<Export>();
    _calculateProductSales(exports);
    _calculateCategorySales(exports); // New: Calculate category sales
    _calculatePeriodicSales(exports);
  }

  void _calculateProductSales(RealmResults<Export> exports) {
    final sales = <String, int>{};
    for (var export in exports) {
      final List<dynamic> itemsJson = jsonDecode(export.itemsJson);
      for (var itemData in itemsJson) {
        final item = ExportItemData.fromJson(itemData);
        sales.update(item.productName, (value) => value + item.quantity,
            ifAbsent: () => item.quantity);
      }
    }
    productSales.assignAll(sales);
  }

  void _calculateCategorySales(RealmResults<Export> exports) {
    final sales = <String, int>{};
    final categories = _databaseService.realm.all<Category>().toList();
    final categoryMap = {for (var cat in categories) cat.id: cat.name};

    for (var export in exports) {
      final List<dynamic> itemsJson = jsonDecode(export.itemsJson);
      for (var itemData in itemsJson) {
        final item = ExportItemData.fromJson(itemData);
        final categoryName = categoryMap[item.categoryId] ?? 'Không xác định';
        sales.update(categoryName, (value) => value + item.quantity,
            ifAbsent: () => item.quantity);
      }
    }
    categorySales.assignAll(sales);
  }

  void _calculatePeriodicSales(RealmResults<Export> exports) {
    final monthly = <String, double>{};
    final quarterly = <String, double>{};
    final yearly = <String, double>{};

    for (var export in exports) {
      final date = export.exportDate;
      final year = date.year;
      final month = date.month;
      final quarter = (month / 3).ceil();

      // Monthly
      final monthKey = '$year-${month.toString().padLeft(2, '0')}'; // Format month with leading zero
      monthly.update(monthKey, (value) => value + export.totalAmount,
          ifAbsent: () => export.totalAmount);

      // Quarterly
      final quarterKey = '$year-Q$quarter';
      quarterly.update(quarterKey, (value) => value + export.totalAmount,
          ifAbsent: () => export.totalAmount);

      // Yearly
      final yearKey = '$year';
      yearly.update(yearKey, (value) => value + export.totalAmount,
          ifAbsent: () => export.totalAmount);
    }

    // Sort monthly sales by key (year-month)
    final sortedMonthly = Map.fromEntries(
      monthly.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );
    monthlySales.assignAll(sortedMonthly);

    // Sort quarterly sales by key (year-Qquarter)
    final sortedQuarterly = Map.fromEntries(
      quarterly.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );
    quarterlySales.assignAll(sortedQuarterly);

    // Sort yearly sales by key (year)
    final sortedYearly = Map.fromEntries(
      yearly.entries.toList()..sort((e1, e2) => e1.key.compareTo(e2.key)),
    );
    yearlySales.assignAll(sortedYearly);
  }

  void setSelectedChartType(String type) {
    selectedChartType.value = type;
  }
}
