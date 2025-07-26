import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/customer.dart';
import '../services/database_service.dart';
import '../core/service_locator.dart';

class CustomerController extends GetxController {
  DatabaseService get _databaseService => serviceLocator<DatabaseService>();

  final RxList<Customer> customers = <Customer>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Chỉ load data nếu database đã được khởi tạo
    if (ServiceLocator.isDatabaseInitialized) {
      loadCustomers();
    }
  }

  void loadCustomers() {
    try {
      isLoading.value = true;
      final allCustomers = _databaseService.getAllCustomers();
      allCustomers.sort((a, b) => a.name.compareTo(b.name));
      customers.value = allCustomers;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách khách hàng: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void searchCustomers(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      loadCustomers();
    } else {
      try {
        isLoading.value = true;
        final searchResults = _databaseService.searchCustomers(query);
        customers.value = searchResults;
      } catch (e) {
        Get.snackbar('Lỗi', 'Không thể tìm kiếm khách hàng: $e');
      } finally {
        isLoading.value = false;
      }
    }
  }

  Customer? addCustomer({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String company,
    required String taxCode,
    required String customerType,
    required String notes,
  }) {
    try {
      const uuid = Uuid();
      final now = DateTime.now();
      final customer = Customer(
        uuid.v4(),
        name,
        email,
        phone,
        address,
        company,
        taxCode,
        customerType,
        notes,
        now,
        now,
      );
      _databaseService.addCustomer(customer);
      loadCustomers();
      Get.back(result: customer); // Return the created customer
      Get.snackbar('Thành công', 'Đã thêm khách hàng "$name"');
      return customer;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm khách hàng: $e');
      return null;
    }
  }

  Customer? updateCustomer({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String address,
    required String company,
    required String taxCode,
    required String customerType,
    required String notes,
    required DateTime createdAt,
  }) {
    try {
      final customer = Customer(
        id,
        name,
        email,
        phone,
        address,
        company,
        taxCode,
        customerType,
        notes,
        createdAt,
        DateTime.now(),
      );
      _databaseService.updateCustomer(customer);
      loadCustomers();
      Get.back(result: customer); // Return the updated customer
      Get.snackbar('Thành công', 'Đã cập nhật khách hàng "$name"');
      return customer;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật khách hàng: $e');
      return null;
    }
  }

  void deleteCustomer(String id) {
    try {
      final customer = _databaseService.getCustomerById(id);
      if (customer != null) {
        Get.dialog(
          AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa khách hàng "${customer.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  _databaseService.deleteCustomer(id);
                  loadCustomers();
                  Get.back();
                  Get.snackbar('Thành công', 'Đã xóa khách hàng');
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa khách hàng: $e');
    }
  }

  // Lấy danh sách khách hàng theo loại
  List<Customer> getCustomersByType(String type) {
    return customers.where((customer) => customer.customerType == type).toList();
  }

  // Thống kê khách hàng
  Map<String, int> getCustomerStatistics() {
    final individualCount = customers.where((c) => c.customerType == 'individual').length;
    final companyCount = customers.where((c) => c.customerType == 'company').length;
    
    return {
      'individual': individualCount,
      'company': companyCount,
      'total': customers.length,
    };
  }
}
