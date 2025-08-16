import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/service_locator.dart';
import 'package:get_storage/get_storage.dart';
import 'views/login_screen.dart';
import 'controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup GetIt service locator
  await ServiceLocator.setupLocator();

  // Initialize GetStorage
  await GetStorage.init();

  // Put SettingsController
  final SettingsController settingsController = Get.put(SettingsController());

  runApp(MyApp(settingsController: settingsController));
}

class MyApp extends StatelessWidget {
  final SettingsController settingsController;

  const MyApp({super.key, required this.settingsController});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Quản Lý Sản Phẩm',
        themeMode: settingsController.themeMode.value,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: settingsController.primaryColor.value,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: settingsController.primaryColor.value,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: LoginScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
