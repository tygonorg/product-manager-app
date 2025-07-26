import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';
import './add_edit_customer_screen.dart';

class CustomerListScreen extends StatelessWidget {
  final CustomerController controller = Get.find<CustomerController>();
  final TextEditingController _searchController = TextEditingController();

  CustomerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản Lý Khách Hàng'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () => _showStatistics(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm khách hàng...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    controller.searchCustomers('');
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) => controller.searchCustomers(value),
            ),
          ),
          
          // Filter tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                _buildFilterChip('Tất cả', '', context),
                const SizedBox(width: 8),
                _buildFilterChip('Cá nhân', 'individual', context),
                const SizedBox(width: 8),
                _buildFilterChip('Công ty', 'company', context),
              ],
            ),
          ),
          
          // Customer list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.customers.isEmpty) {
                return const Center(
                  child: Text(
                    'Chưa có khách hàng nào.\nNhấn + để thêm.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }
              return ListView.builder(
                itemCount: controller.customers.length,
                itemBuilder: (context, index) {
                  final customer = controller.customers[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: customer.customerType == 'company' 
                          ? Colors.blue 
                          : Colors.green,
                        child: Icon(
                          customer.customerType == 'company' 
                            ? Icons.business 
                            : Icons.person,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        customer.name, 
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (customer.company.isNotEmpty) 
                            Text('Công ty: ${customer.company}'),
                          Text('SĐT: ${customer.phone}'),
                          Text('Email: ${customer.email}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                            onPressed: () => Get.to(() => AddEditCustomerScreen(customer: customer)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => controller.deleteCustomer(customer.id),
                          ),
                        ],
                      ),
                      onTap: () => _showCustomerDetails(context, customer),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => AddEditCustomerScreen()),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }

  Widget _buildFilterChip(String label, String type, BuildContext context) {
    return Obx(() {
      final isSelected = type.isEmpty 
        ? controller.searchQuery.isEmpty 
        : controller.customers.every((c) => c.customerType == type || type.isEmpty);
      
      return FilterChip(
        label: Text(label),
        selected: false, // Simplified for now
        onSelected: (selected) {
          if (type.isEmpty) {
            controller.loadCustomers();
          } else {
            final filtered = controller.getCustomersByType(type);
            controller.customers.value = filtered;
          }
        },
      );
    });
  }

  void _showCustomerDetails(BuildContext context, customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(customer.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Loại', customer.customerType == 'company' ? 'Công ty' : 'Cá nhân'),
              if (customer.company.isNotEmpty)
                _buildDetailRow('Công ty', customer.company),
              _buildDetailRow('Email', customer.email),
              _buildDetailRow('Điện thoại', customer.phone),
              _buildDetailRow('Địa chỉ', customer.address),
              if (customer.taxCode.isNotEmpty)
                _buildDetailRow('Mã số thuế', customer.taxCode),
              if (customer.notes.isNotEmpty)
                _buildDetailRow('Ghi chú', customer.notes),
              _buildDetailRow('Ngày tạo', customer.createdAt.toString().split(' ')[0]),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.to(() => AddEditCustomerScreen(customer: customer));
            },
            child: const Text('Chỉnh sửa'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _showStatistics(BuildContext context) {
    final stats = controller.getCustomerStatistics();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thống kê khách hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow('Tổng số', stats['total'].toString()),
            _buildStatRow('Cá nhân', stats['individual'].toString()),
            _buildStatRow('Công ty', stats['company'].toString()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
