import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final GetStorage _box = GetStorage();
  final String _themeModeKey = 'themeMode';
  final String _primaryColorKey = 'primaryColor';

  // Observable for theme mode
  Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  // Observable for primary color
  Rx<Color> primaryColor = Color(Colors.deepOrange.value).obs; // Default color

  @override
  void onInit() {
    super.onInit();
    _loadThemeMode();
    _loadPrimaryColor();
  }

  // Load theme mode from storage
  void _loadThemeMode() {
    final String? storedTheme = _box.read(_themeModeKey);
    if (storedTheme == 'light') {
      themeMode.value = ThemeMode.light;
    } else if (storedTheme == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.system;
    }
    Get.changeThemeMode(themeMode.value);
  }

  // Load primary color from storage
  void _loadPrimaryColor() {
    final int? storedColorValue = _box.read(_primaryColorKey);
    if (storedColorValue != null) {
      primaryColor.value = Color(storedColorValue);
    } else {
      // Save default color if not already stored
      _box.write(_primaryColorKey, primaryColor.value.value);
    }
  }

  // Toggle theme mode
  void toggleThemeMode() {
    if (themeMode.value == ThemeMode.light) {
      themeMode.value = ThemeMode.dark;
    } else if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.system;
    } else {
      themeMode.value = ThemeMode.light;
    }
    _box.write(_themeModeKey, themeMode.value.toString().split('.').last);
    Get.changeThemeMode(themeMode.value);
  }

  // Change primary color
  void changePrimaryColor(Color color) {
    primaryColor.value = color;
    _box.write(_primaryColorKey, color.value);
    // No need to call Get.changeTheme here, it will be handled by MyApp's Obx
  }

  // Get current theme mode as a display string
  String get currentThemeModeString {
    switch (themeMode.value) {
      case ThemeMode.light:
        return 'Sáng';
      case ThemeMode.dark:
        return 'Tối';
      case ThemeMode.system:
        return 'Hệ thống';
    }
  }
}
