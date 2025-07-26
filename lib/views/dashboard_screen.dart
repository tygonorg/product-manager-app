import 'package:flutter/material.dart';
import 'package:get/get.dart';
import './product_list_screen.dart';
import './category_list_screen.dart';
import './employee_list_screen.dart';
import './customer_list_screen.dart';
import './export_list_screen.dart';
import './statistics_screen.dart';
import './settings_screen.dart';
import '../controllers/product_controller.dart';
import '../controllers/category_controller.dart';
import '../controllers/employee_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/export_controller.dart';
import '../controllers/statistics_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  
  @override
  void onInit() {
    // Initialize all controllers when dashboard loads
    Get.put(ProductController());
    Get.put(CategoryController());
    Get.put(EmployeeController());
    Get.put(CustomerController());
    Get.put(ExportController());
    Get.put(StatisticsController());
  }

  @override
  Widget build(BuildContext context) {
    // Initialize controllers
    Get.put(ProductController());
    Get.put(CategoryController());
    Get.put(EmployeeController());
    Get.put(CustomerController());
    Get.put(ExportController());
    Get.put(StatisticsController());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.to(() => SettingsScreen()),
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16.0),
        mainAxisSpacing: 16.0,
        crossAxisSpacing: 16.0,
        children: [
          _buildDashboardItem(
            context,
            icon: Icons.inventory,
            label: 'Sản phẩm',
            onTap: () => Get.to(() => ProductListScreen()),
          ),
          _buildDashboardItem(
            context,
            icon: Icons.category,
            label: 'Danh mục',
            onTap: () => Get.to(() => CategoryListScreen()),
          ),
          _buildDashboardItem(
            context,
            icon: Icons.people,
            label: 'Nhân viên',
            onTap: () => Get.to(() => EmployeeListScreen()),
          ),
          _buildDashboardItem(
            context,
            icon: Icons.groups,
            label: 'Khách hàng',
            onTap: () => Get.to(() => CustomerListScreen()),
          ),
          _buildDashboardItem(
            context,
            icon: Icons.local_shipping,
            label: 'Xuất hàng',
            onTap: () => Get.to(() => ExportListScreen()),
          ),
          _buildDashboardItem(
            context,
            icon: Icons.bar_chart,
            label: 'Thống kê',
            onTap: () => Get.to(() => StatisticsScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardItem(BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
