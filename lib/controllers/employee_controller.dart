import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/employee.dart';
import '../services/database_service.dart';
import '../core/service_locator.dart';

class EmployeeController extends GetxController {
  DatabaseService get _databaseService => serviceLocator<DatabaseService>();

  final RxList<Employee> employees = <Employee>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    
    // Chỉ load data nếu database đã được khởi tạo
    if (ServiceLocator.isDatabaseInitialized) {
      loadEmployees();
    }
  }

  void loadEmployees() {
    try {
      isLoading.value = true;
      final allEmployees = _databaseService.getAllEmployees();
      allEmployees.sort((a, b) => a.name.compareTo(b.name));
      employees.value = allEmployees;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách nhân viên: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void addEmployee({
    required String name,
    required String position,
    required String email,
    required String phone,
    required DateTime startDate,
  }) {
    try {
      const uuid = Uuid();
      final now = DateTime.now();
      final employee = Employee(
        uuid.v4(),
        name,
        position,
        email,
        phone,
        startDate,
        now,
        now,
      );
      _databaseService.addEmployee(employee);
      loadEmployees();
      Get.back();
      Get.snackbar('Thành công', 'Đã thêm nhân viên "$name"');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể thêm nhân viên: $e');
    }
  }

  void updateEmployee({
    required String id,
    required String name,
    required String position,
    required String email,
    required String phone,
    required DateTime startDate,
    required DateTime createdAt,
  }) {
    try {
      final employee = Employee(
        id,
        name,
        position,
        email,
        phone,
        startDate,
        createdAt,
        DateTime.now(),
      );
      _databaseService.updateEmployee(employee);
      loadEmployees();
      Get.back();
      Get.snackbar('Thành công', 'Đã cập nhật nhân viên "$name"');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật nhân viên: $e');
    }
  }

  void deleteEmployee(String id) {
    try {
      final employee = _databaseService.getEmployeeById(id);
      if (employee != null) {
        Get.dialog(
          AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: Text('Bạn có chắc muốn xóa nhân viên "${employee.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  _databaseService.deleteEmployee(id);
                  loadEmployees();
                  Get.back();
                  Get.snackbar('Thành công', 'Đã xóa nhân viên');
                },
                child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa nhân viên: $e');
    }
  }
}
