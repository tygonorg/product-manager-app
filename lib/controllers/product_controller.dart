import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../core/service_locator.dart';
import '../services/excel_service.dart';
import '../services/cloud_sync_service.dart';
import '../services/google_drive_service.dart';

class ProductController extends GetxController {
  DatabaseService get _databaseService => serviceLocator<DatabaseService>();
  final ExcelService _excelService = ExcelService();
  final CloudSyncService _cloudService = CloudSyncService('https://example.com');
  
  final RxList<Product> products = <Product>[].obs;
  final RxList<Product> filteredProducts = <Product>[].obs;
  final RxList<Category> categories = <Category>[].obs;
  
  final RxString searchQuery = ''.obs;
  final RxnString selectedCategoryId = RxnString(); // Can be null
  final RxBool isLoading = false.obs;
  
  // Price filtering
  final RxDouble minPrice = 0.0.obs;
  final RxDouble maxPrice = double.infinity.obs;
  final RxBool priceFilterEnabled = false.obs;
  
  // Pagination
  static const int pageSize = 20;
  final RxInt currentPage = 0.obs;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;
  List<Product> _allProducts = [];
  List<Product> _allFilteredProducts = [];
  
  @override
  void onInit() {
    super.onInit();
    
    // Chỉ load data nếu database đã được khởi tạo
    if (ServiceLocator.isDatabaseInitialized) {
      loadInitialData();
    }
    
    // Lắng nghe thay đổi search, category và price
    ever(searchQuery, (_) => filterProducts());
    ever(selectedCategoryId, (_) => filterProducts());
    ever(minPrice, (_) => filterProducts());
    ever(maxPrice, (_) => filterProducts());
    ever(priceFilterEnabled, (_) => filterProducts());
  }
  
  void loadInitialData() {
    // Kiểm tra database đã khởi tạo trước khi load
    if (!ServiceLocator.isDatabaseInitialized) {
      print('Database not initialized yet');
      return;
    }
    
    loadCategories();
    loadProducts();
  }
  
  void loadProducts() {
    try {
      isLoading.value = true;
      _allProducts = _databaseService.getAllProducts();
      resetPagination();
      applyFiltersAndPagination();
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Lỗi', 'Không thể tải danh sách sản phẩm: $e');
      });
    } finally {
      isLoading.value = false;
    }
  }
  
  void loadCategories() {
    print('ProductController: Loading categories...');
    try {
      final allCategories = _databaseService.getAllCategories();
      allCategories.sort((a, b) => a.name.compareTo(b.name));
      categories.value = allCategories;
      print('ProductController: Categories loaded. Count: ${categories.length}');
      for (var c in categories) {
        print('  - ${c.name} (${c.id})');
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Lỗi', 'Không thể tải danh mục: $e');
      });
    }
  }
  
  String getCategoryName(String categoryId) {
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => Category('', 'Không xác định', DateTime.now(), DateTime.now()),
    );
    return category.name;
  }
  
  void filterProducts() {
    resetPagination();
    applyFiltersAndPagination();
  }
  
  void resetPagination() {
    currentPage.value = 0;
    hasMoreData.value = true;
    isLoadingMore.value = false;
  }
  
  void applyFiltersAndPagination() {
    List<Product> filtered = _allProducts;
    
    // Filter by category
    if (selectedCategoryId.value != null) {
      filtered = filtered.where((p) => p.category == selectedCategoryId.value).toList();
    }
    
    // Filter by search query
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        p.description.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    // Filter by price range
    if (priceFilterEnabled.value) {
      filtered = filtered.where((p) => 
        p.price >= minPrice.value && p.price <= maxPrice.value
      ).toList();
    }
    
    _allFilteredProducts = filtered;
    
    // Apply pagination
    final endIndex = (currentPage.value + 1) * pageSize;
    final currentPageItems = _allFilteredProducts.take(endIndex).toList();
    
    filteredProducts.value = currentPageItems;
    hasMoreData.value = _allFilteredProducts.length > endIndex;
  }
  
  void addProduct({
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String categoryId,
    String imageUrl = '',
  }) {
    try {
      const uuid = Uuid();
      final now = DateTime.now();
      
      final product = Product(
        uuid.v4(),
        name,
        description,
        price,
        quantity,
        categoryId,
        now,
        now,
        imageUrl,
      );
      
      _databaseService.addProduct(product);
      loadProducts();
      
      Get.back(); // Close add/edit screen
      Get.snackbar(
        'Thành công', 
        'Đã thêm sản phẩm "$name"',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm sản phẩm: $e');
    }
  }
  
  void updateProduct({
    required String id,
    required String name,
    required String description,
    required double price,
    required int quantity,
    required String categoryId,
    String imageUrl = '',
  }) {
    try {
      final existingProduct = _databaseService.getProductById(id);
      if (existingProduct != null) {
        final updatedProduct = Product(
          id,
          name,
          description,
          price,
          quantity,
          categoryId,
          existingProduct.createdAt,
          DateTime.now(),
          imageUrl,
        );
        
        _databaseService.updateProduct(updatedProduct);
        loadProducts();
        
        Get.back(); // Close add/edit screen
        Get.snackbar(
          'Thành công', 
          'Đã cập nhật sản phẩm "$name"',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật sản phẩm: $e');
    }
  }
  
  void deleteProduct(String id) {
    try {
      final product = _databaseService.getProductById(id);
      if (product != null) {
        Get.dialog(
          AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc chắn muốn xóa sản phẩm "${product.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  _databaseService.deleteProduct(id);
                  loadProducts();
                  Get.back();
                  Get.snackbar(
                    'Thành công', 
                    'Đã xóa sản phẩm "${product.name}"',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa sản phẩm: $e');
    }
  }
  
  void searchProducts(String query) {
    searchQuery.value = query;
  }
  
  void selectCategory(String? categoryId) {
    selectedCategoryId.value = categoryId;
  }
  
  void setPriceFilter({required double min, required double max, required bool enabled}) {
    minPrice.value = min;
    maxPrice.value = max;
    priceFilterEnabled.value = enabled;
  }
  
  void clearPriceFilter() {
    minPrice.value = 0.0;
    maxPrice.value = double.infinity;
    priceFilterEnabled.value = false;
  }

  Future<void> importFromExcel(String filePath) async {
    try {
      final imported = _excelService.importProducts(filePath);
      for (final p in imported) {
        _databaseService.addProduct(p);
      }
      loadProducts();
      Get.snackbar('Thành công', 'Đã nhập dữ liệu từ Excel');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể nhập dữ liệu: $e');
    }
  }

  Future<void> exportToExcel(String filePath) async {
    try {
      _excelService.exportProducts(filePath, _allProducts);
      Get.snackbar('Thành công', 'Đã xuất dữ liệu ra Excel');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xuất dữ liệu: $e');
    }
  }

  Future<void> exportInventoryReport(String filePath) async {
    try {
      _excelService.exportInventoryReport(filePath, _allProducts);
      Get.snackbar('Thành công', 'Đã xuất báo cáo ra Excel');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xuất báo cáo: $e');
    }
  }

  Future<void> exportReportToGoogleDrive(
      String filePath, String accessToken) async {
    try {
      _excelService.exportInventoryReport(filePath, _allProducts);
      final drive = GoogleDriveService(accessToken);
      await drive.uploadFile(File(filePath));
      Get.snackbar('Thành công', 'Đã tải báo cáo lên Google Drive');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải lên Google Drive: $e');
    }
  }

  Future<void> syncToCloud() async {
    try {
      await _cloudService.syncProducts(_allProducts);
      Get.snackbar('Thành công', 'Đồng bộ cloud thành công');
    } catch (e) {
      Get.snackbar('Lỗi', 'Đồng bộ cloud thất bại: $e');
    }
  }
}
