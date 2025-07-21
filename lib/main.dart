import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/service_locator.dart';
import 'controllers/product_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/employee_controller.dart';
import 'controllers/export_controller.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Setup GetIt service locator
  await ServiceLocator.setupLocator();
  
  // Put GetX controllers
  Get.put(ProductController());
  Get.put(CategoryController());
  Get.put(EmployeeController());
  Get.put(ExportController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Quản Lý Sản Phẩm',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
