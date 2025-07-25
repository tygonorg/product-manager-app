import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/export.dart';
// Import ExportItem
import '../models/product.dart';
import '../services/database_service.dart';
import '../core/service_locator.dart';

class ExportController extends GetxController {
  DatabaseService get _databaseService => serviceLocator<DatabaseService>();

  final RxList<Export> exports = <Export>[].obs;
  final RxBool sortAscending = false.obs; // New state for sorting order
  final RxList<Product> selectedProductsToExport = <Product>[].obs;
  final RxMap<String, int> productQuantities = <String, int>{}.obs;
  final RxString customerName = ''.obs;
  final RxString customerPhone = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (ServiceLocator.isDatabaseInitialized) {
      loadExports();
    }
  }

  void loadExports() {
    try {
      isLoading.value = true;
      final allExports = _databaseService.getAllExports();
      // Apply sorting based on sortAscending
      allExports.sort((a, b) => sortAscending.value
          ? a.exportDate.compareTo(b.exportDate)
          : b.exportDate.compareTo(a.exportDate));
      exports.value = allExports;
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Lỗi', 'Không thể tải danh sách hóa đơn xuất: $e');
      });
    } finally {
      isLoading.value = false;
    }
  }

  void toggleSortOrder() {
    sortAscending.value = !sortAscending.value;
    loadExports(); // Reload and re-sort
  }

  void addProductToExport(Product product) {
    if (!selectedProductsToExport.contains(product)) {
      selectedProductsToExport.add(product);
      productQuantities[product.id] = 1; // Default quantity
    }
  }

  void removeProductFromExport(Product product) {
    selectedProductsToExport.remove(product);
    productQuantities.remove(product.id);
  }

  void updateProductQuantity(Product product, int quantity) {
    if (quantity > 0 && quantity <= product.quantity) {
      productQuantities[product.id] = quantity;
    } else if (quantity > product.quantity) {
      Get.snackbar('Lỗi', 'Số lượng xuất vượt quá số lượng tồn kho.');
      productQuantities[product.id] = product.quantity; // Set to max available
    } else {
      productQuantities[product.id] = 1; // Minimum 1
    }
  }

  double calculateTotalAmount() {
    double total = 0.0;
    for (var product in selectedProductsToExport) {
      total += product.price * (productQuantities[product.id] ?? 0);
    }
    return total;
  }

  void createExport({
    required String employeeId,
    required String customerName,
    required String customerPhone,
  }) {
    if (selectedProductsToExport.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng chọn sản phẩm để xuất.');
      return;
    }

    // Check stock before exporting
    for (var product in selectedProductsToExport) {
      final currentQuantity = _databaseService.getProductById(product.id)?.quantity ?? 0;
      final exportQuantity = productQuantities[product.id] ?? 0;
      if (exportQuantity > currentQuantity) {
        Get.snackbar('Lỗi', 'Sản phẩm ${product.name} không đủ số lượng tồn kho.');
        return;
      }
    }

    try {
      const uuid = Uuid();
      final now = DateTime.now();
      
      // Convert ExportItem list to JSON string
      final List<Map<String, dynamic>> exportItemsJson = selectedProductsToExport.map((product) {
        return {
          'productId': product.id,
          'productName': product.name,
          'priceAtExport': product.price,
          'quantity': productQuantities[product.id] ?? 0,
          'categoryId': product.category, // Add categoryId here
        };
      }).toList();
      final String itemsJsonString = jsonEncode(exportItemsJson);

      final newExport = Export(
        uuid.v4(),
        employeeId,
        customerName,
        customerPhone,
        now,
        calculateTotalAmount(),
        itemsJsonString,
      );

      _databaseService.addExport(newExport);

      // Update product quantities in stock
      for (var product in selectedProductsToExport) {
        _databaseService.updateProductQuantity(product.id, -(productQuantities[product.id] ?? 0));
      }

      loadExports(); // Refresh export list
      clearExportSelection();
      Get.back(); // Close export screen
      Get.snackbar('Thành công', 'Đã tạo hóa đơn xuất hàng.');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tạo hóa đơn xuất hàng: $e');
    }
  }

  void deleteExport(String exportId) {
    try {
      final export = _databaseService.getExportById(exportId);
      if (export == null) {
        Get.snackbar('Lỗi', 'Không tìm thấy hóa đơn xuất.');
        return;
      }

      Get.dialog(
        AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text(
            'Bạn có chắc chắn muốn xóa hóa đơn #${export.id.substring(0, 8)}?\n'
            'Khách hàng: ${export.customerName}\n'
            'Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(export.totalAmount)}\n\n'
            'Lưu ý: Số lượng sản phẩm sẽ được hoàn trả lại kho.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                _performDeleteExport(export);
                Get.back();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Xóa'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa hóa đơn: $e');
    }
  }

  void _performDeleteExport(Export export) {
    try {
      // Parse items JSON để hoàn trả số lượng về kho
      final itemsJsonString = export.itemsJson;
      final List<dynamic> itemsJson = jsonDecode(itemsJsonString);

      // Hoàn trả số lượng sản phẩm về kho
      for (var itemData in itemsJson) {
        final productId = itemData['productId'] as String;
        final quantity = itemData['quantity'] as int;
        
        // Cộng lại số lượng vào kho
        _databaseService.updateProductQuantity(productId, quantity);
      }

      // Xóa hóa đơn khỏi database
      _databaseService.deleteExport(export.id);
      
      // Refresh danh sách
      loadExports();
      
      Get.snackbar(
        'Thành công', 
        'Đã xóa hóa đơn và hoàn trả ${itemsJson.length} sản phẩm về kho.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Lỗi khi xóa hóa đơn: $e');
    }
  }

  void clearExportSelection() {
    selectedProductsToExport.clear();
    productQuantities.clear();
    customerName.value = '';
    customerPhone.value = '';
  }
}
