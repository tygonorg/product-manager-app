import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/customer.dart';
import '../extensions/export_extensions.dart';
import '../controllers/customer_controller.dart';
import '../services/database_service.dart';
import '../core/service_locator.dart';
import './add_edit_customer_screen.dart';
import './export_detail_screen.dart';

class CustomerDetailScreen extends StatelessWidget {
  final Customer customer;
  final CustomerController customerController = Get.find<CustomerController>();
  final DatabaseService _databaseService = serviceLocator<DatabaseService>();

  CustomerDetailScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Khách Hàng'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Get.to(() => AddEditCustomerScreen(customer: customer)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Header Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: customer.customerType == 'company' 
                        ? Colors.blue 
                        : Colors.green,
                      child: Icon(
                        customer.customerType == 'company' 
                          ? Icons.business 
                          : Icons.person,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            customer.customerType == 'company' ? 'Công ty' : 'Cá nhân',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contact Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin liên hệ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildContactRow(context, Icons.phone, 'Điện thoại', customer.phone),
                    _buildContactRow(context, Icons.email, 'Email', customer.email),
                    _buildContactRow(context, Icons.location_on, 'Địa chỉ', customer.address),
                    if (customer.company.isNotEmpty)
                      _buildContactRow(context, Icons.business, 'Công ty', customer.company),
                    if (customer.taxCode.isNotEmpty)
                      _buildContactRow(context, Icons.receipt, 'Mã số thuế', customer.taxCode),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Additional Information
            if (customer.notes.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ghi chú',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        customer.notes,
                        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Export Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thống kê giao dịch',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildStatisticRow(context, 'Số lượng hóa đơn', customer.getExportCount(_databaseService.realm).toString()),
                    _buildStatisticRow(
                      context, 
                      'Tổng giá trị', 
                      NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(customer.getTotalExportAmount(_databaseService.realm))
                    ),
                    _buildStatisticRow(context, 'Ngày tạo', DateFormat('dd/MM/yyyy').format(customer.createdAt)),
                    _buildStatisticRow(context, 'Cập nhật cuối', DateFormat('dd/MM/yyyy').format(customer.updatedAt)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Export History
            _buildExportHistory(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(BuildContext context, IconData icon, String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: label == 'Tổng giá trị' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportHistory(BuildContext context) {
    final exports = customer.getExports(_databaseService.realm);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lịch sử hóa đơn',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '(${exports.length} hóa đơn)',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (exports.isEmpty)
              Text(
                'Chưa có hóa đơn nào.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: exports.length > 5 ? 5 : exports.length, // Show only first 5
                itemBuilder: (context, index) {
                  final export = exports[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      'Hóa đơn #${export.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      '${DateFormat('dd/MM/yyyy').format(export.exportDate)} - ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(export.totalAmount)}',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Get.to(() => ExportDetailScreen(export: export)),
                  );
                },
              ),
            
            if (exports.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Text(
                    'Và ${exports.length - 5} hóa đơn khác...',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
