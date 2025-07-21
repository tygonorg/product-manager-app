import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/export_controller.dart';
import './export_screen.dart'; // Màn hình tạo/chỉnh sửa hóa đơn xuất
import './export_detail_screen.dart'; // Màn hình chi tiết hóa đơn xuất

class ExportListScreen extends StatelessWidget {
  final ExportController controller = Get.find<ExportController>();

  ExportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh Sách Hóa Đơn Xuất'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              controller.toggleSortOrder();
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.exports.isEmpty) {
          return const Center(
            child: Text(
              'Chưa có hóa đơn xuất nào.\nNhấn + để thêm.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.exports.length,
          itemBuilder: (context, index) {
            final export = controller.exports[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                title: Text('Hóa đơn #${export.id.substring(0, 8)}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Khách hàng: ${export.customerName} (${export.customerPhone})'),
                    Text('Ngày xuất: ${DateFormat('dd/MM/yyyy HH:mm').format(export.exportDate)}'),
                    Text('Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(export.totalAmount)}'),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => controller.deleteExport(export.id),
                ),
                onTap: () {
                  Get.to(() => ExportDetailScreen(export: export));
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => ExportScreen()),
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }
}