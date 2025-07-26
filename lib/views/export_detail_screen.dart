import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/export.dart';
import '../models/export_item_data.dart';
import '../controllers/employee_controller.dart';
import '../services/database_service.dart';
import '../core/service_locator.dart';
import '../extensions/export_extensions.dart';
import './customer_detail_screen.dart';
class ExportDetailScreen extends StatelessWidget {
  final Export export;
  final EmployeeController employeeController = Get.find<EmployeeController>();
  final DatabaseService _databaseService = serviceLocator<DatabaseService>();

  ExportDetailScreen({super.key, required this.export});

  String _getEmployeeName(String employeeId) {
    final employee = employeeController.employees.firstWhereOrNull(
      (emp) => emp.id == employeeId,
    );
    return employee?.name ?? 'Không xác định';
  }

  @override
  Widget build(BuildContext context) {
    // Parse itemsJson back to List<ExportItem>
    List<ExportItemData> items = [];
    try {
      final List<dynamic> decodedItems = jsonDecode(export.itemsJson);
      items = decodedItems.map((itemJson) => ExportItemData.fromJson(itemJson as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error decoding itemsJson: $e');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi Tiết Hóa Đơn Xuất'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(context, 'Mã hóa đơn:', export.id),
            _buildInfoRow(context, 'Nhân viên xuất:', _getEmployeeName(export.employeeId)),
            // Customer information - prominent display
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  final customer = export.getCustomer(_databaseService.realm);
                  if (customer != null) {
                    Get.to(() => CustomerDetailScreen(customer: customer));
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Khách hàng',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  export.getCustomerName(_databaseService.realm),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  export.getCustomerPhone(_databaseService.realm),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            _buildInfoRow(context, 'Ngày xuất:', DateFormat('dd/MM/yyyy HH:mm').format(export.exportDate)),
            _buildInfoRow(context, 'Tổng tiền:', NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(export.totalAmount)),
            
            const SizedBox(height: 24),
            Text(
              'Sản phẩm đã xuất:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
            const SizedBox(height: 8),
            
            if (items.isEmpty)
              Text('Không có sản phẩm nào trong hóa đơn này.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                          ),
                          Text('Số lượng: ${item.quantity}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text('Giá xuất: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(item.priceAtExport)}', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          Text('Thành tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(item.quantity * item.priceAtExport)}', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
          Expanded(child: Text(value, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        ],
      ),
    );
  }
}
