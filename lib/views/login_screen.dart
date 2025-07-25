import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/service_locator.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/employee_controller.dart';
import '../controllers/export_controller.dart';
import '../controllers/statistics_controller.dart';
import '../controllers/settings_controller.dart';
import './dashboard_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.inventory,
                  size: 60,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Title
              Text(
                'Quản Lý Sản Phẩm',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'Nhập mật khẩu để truy cập database',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Password input
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Obx(() => TextField(
                  controller: passwordController,
                  obscureText: obscurePassword.value,
                  decoration: InputDecoration(
                    hintText: 'Nhập mật khẩu database',
                    prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword.value 
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () => obscurePassword.toggle(),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onSubmitted: (_) => _login(),
                )),
              ),
              
              const SizedBox(height: 24),
              
              // Login button
              Obx(() => SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading.value ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: isLoading.value
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.onPrimary),
                        ),
                      )
                    : const Text(
                        'Đăng Nhập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                ),
              )),
              
              const SizedBox(height: 16),
              
              // Note
              Text(
                'Lưu ý: Mật khẩu được sử dụng để mã hóa database',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _login() async {
    final password = passwordController.text.trim();
    
    if (password.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập mật khẩu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      // Initialize database with password using ServiceLocator
      await ServiceLocator.initializeDatabase(password);
      
      // Put GetX controllers
      Get.put(ProductController());
      Get.put(CategoryController());
      Get.put(EmployeeController());
      Get.put(ExportController());
      Get.put(StatisticsController());
      Get.put(SettingsController()); // Add this line
      
      // Load data into controllers now that database is initialized
      final productController = Get.find<ProductController>();
      final categoryController = Get.find<CategoryController>();
      final employeeController = Get.find<EmployeeController>();
      final exportController = Get.find<ExportController>();
      
      // Load initial data
      productController.loadInitialData();
      categoryController.loadCategories();
      employeeController.loadEmployees();
      exportController.loadExports();
      
      // Navigate to dashboard screen
      Get.offAll(() => const DashboardScreen());
      
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        'Không thể kết nối database. Kiểm tra lại mật khẩu.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
