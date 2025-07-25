import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../services/database_service.dart';
import '../core/service_locator.dart';

class CategoryController extends GetxController {
  DatabaseService get _databaseService => serviceLocator<DatabaseService>();
  
  final RxList<Category> categories = <Category>[].obs;
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    
    // Chỉ load data nếu database đã được khởi tạo
    if (ServiceLocator.isDatabaseInitialized) {
      loadCategories();
    }
  }
  
  void loadCategories() {
    print('CategoryController: Loading categories...');
    try {
      isLoading.value = true;
      final allCategories = _databaseService.getAllCategories();
      // Sort by name for consistent display
      allCategories.sort((a, b) => a.name.compareTo(b.name));
      categories.value = allCategories;
      print('CategoryController: Categories loaded. Count: ${categories.length}');
      for (var c in categories) {
        print('  - ${c.name} (${c.id})');
      }
    } catch (e) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar('Lỗi', 'Không thể tải danh mục: $e');
      });
    } finally {
      isLoading.value = false;
    }
  }
  
  void addCategory(String name) {
    print('CategoryController: Adding category: $name');
    if (name.isEmpty) {
      Get.snackbar('Lỗi', 'Tên danh mục không được để trống');
      return;
    }
    
    // Check for duplicates
    if (categories.any((c) => c.name.toLowerCase() == name.toLowerCase())) {
      Get.snackbar('Lỗi', 'Danh mục "$name" đã tồn tại');
      return;
    }
    
    try {
      const uuid = Uuid();
      final now = DateTime.now();
      
      final category = Category(
        uuid.v4(),
        name,
        now,
        now,
      );
      
      _databaseService.addCategory(category);
      loadCategories(); // Refresh list
      
      Get.back(); // Close dialog
      Get.snackbar('Thành công', 'Đã thêm danh mục "$name"');
      print('CategoryController: Category added successfully.');
      
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm danh mục: $e');
      print('CategoryController: Error adding category: $e');
    }
  }
  
  void updateCategory(Category category, String newName) {
    print('CategoryController: Updating category ${category.name} to $newName');
    if (newName.isEmpty) {
      Get.snackbar('Lỗi', 'Tên danh mục không được để trống');
      return;
    }
    
    // Check for duplicates, excluding the current category
    if (categories.any((c) => c.id != category.id && c.name.toLowerCase() == newName.toLowerCase())) {
      Get.snackbar('Lỗi', 'Danh mục "$newName" đã tồn tại');
      return;
    }
    
    try {
      final updatedCategory = Category(
        category.id,
        newName,
        category.createdAt,
        DateTime.now(),
      );
      
      _databaseService.updateCategory(updatedCategory);
      loadCategories(); // Refresh list
      
      Get.back(); // Close dialog
      Get.snackbar('Thành công', 'Đã cập nhật danh mục');
      print('CategoryController: Category updated successfully.');
      
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật danh mục: $e');
      print('CategoryController: Error updating category: $e');
    }
  }
  
  void deleteCategory(Category category) {
    print('CategoryController: Deleting category: ${category.name}');
    try {
      // Check if any product is using this category
      final productsInCategory = _databaseService.getProductsByCategory(category.id);
      
      if (productsInCategory.isNotEmpty) {
        Get.snackbar(
          'Không thể xóa', 
          'Vẫn còn ${productsInCategory.length} sản phẩm trong danh mục "${category.name}"',
        );
        print('CategoryController: Cannot delete category, products still exist.');
        return;
      }
      
      _databaseService.deleteCategory(category.id);
      loadCategories(); // Refresh list
      
      Get.snackbar('Thành công', 'Đã xóa danh mục "${category.name}"');
      print('CategoryController: Category deleted successfully.');
      
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa danh mục: $e');
      print('CategoryController: Error deleting category: $e');
    }
  }
}
