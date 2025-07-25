import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../core/service_locator.dart';
import '../services/database_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsController settingsController = Get.find<SettingsController>();

  SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildThemeSetting(context),
          const Divider(),
          _buildPrimaryColorSetting(context), // New primary color setting
          const Divider(),
          _buildAppConfigSetting(context),
          const Divider(),
          _buildResetDataSetting(context),
        ],
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context) {
    return Obx(
      () => ListTile(
        title: const Text('Giao diện'),
        subtitle: Text(settingsController.currentThemeModeString),
        trailing: Icon(settingsController.themeMode.value == ThemeMode.dark
            ? Icons.dark_mode
            : Icons.light_mode),
        onTap: () {
          settingsController.toggleThemeMode();
        },
      ),
    );
  }

  Widget _buildPrimaryColorSetting(BuildContext context) {
    final List<Color> availableColors = [
      Colors.deepOrange,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
    ];

    return Obx(
      () => ListTile(
        title: const Text('Màu chủ đạo'),
        subtitle: Text(
            'Màu hiện tại: ' + settingsController.primaryColor.value.toString()),
        trailing: CircleAvatar(
          backgroundColor: settingsController.primaryColor.value,
          radius: 12,
        ),
        onTap: () {
          Get.defaultDialog(
            title: 'Chọn màu chủ đạo',
            content: SizedBox(
              width: double.maxFinite,
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: availableColors.length,
                itemBuilder: (context, index) {
                  final color = availableColors[index];
                  return GestureDetector(
                    onTap: () {
                      settingsController.changePrimaryColor(color);
                      Get.back(); // Close the dialog
                    },
                    child: CircleAvatar(
                      backgroundColor: color,
                      child: settingsController.primaryColor.value == color
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('Hủy'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppConfigSetting(BuildContext context) {
    return ListTile(
      title: const Text('Cấu hình ứng dụng'),
      subtitle: const Text('Thay đổi các cài đặt chung của ứng dụng'),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        // TODO: Implement app configuration screen
        Get.snackbar(
          'Thông báo',
          'Chức năng đang được phát triển',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.shade100,
          colorText: Colors.blue.shade800,
        );
      },
    );
  }

  Widget _buildResetDataSetting(BuildContext context) {
    return ListTile(
      title: const Text('Xóa toàn bộ dữ liệu'),
      subtitle: const Text('Xóa tất cả sản phẩm, danh mục, nhân viên và xuất nhập'),
      trailing: const Icon(Icons.warning_amber_rounded),
      onTap: () {
        Get.defaultDialog(
          title: 'Xác nhận xóa dữ liệu',
          middleText:
              'Bạn có chắc chắn muốn xóa toàn bộ dữ liệu? Hành động này không thể hoàn tác.',
          textConfirm: 'Xóa',
          textCancel: 'Hủy',
          confirmTextColor: Colors.white,
          buttonColor: Colors.red,
          onConfirm: () async {
            Get.back(); // Close dialog
            try {
              final DatabaseService databaseService = serviceLocator<DatabaseService>();
              await databaseService.deleteAllData();
              Get.snackbar(
                'Thành công',
                'Đã xóa toàn bộ dữ liệu.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green.shade100,
                colorText: Colors.green.shade800,
              );
              // Navigate back to login screen after deleting data
              Get.offAll(() => LoginScreen());
            } catch (e) {
              Get.snackbar(
                'Lỗi',
                'Không thể xóa dữ liệu: $e',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade100,
                colorText: Colors.red.shade800,
              );
            }
          },
        );
      },
    );
  }
}
