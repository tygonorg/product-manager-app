import 'package:get_it/get_it.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import '../controllers/employee_controller.dart';
import '../controllers/export_controller.dart';

final GetIt getIt = GetIt.instance;

class ServiceLocator {
  static Future<void> setupLocator() async {
    // Register DatabaseService as lazy singleton
    // It will be created only when first accessed
    getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  }

  static Future<void> initializeDatabase(String password) async {
    // Initialize database with password after user authentication
    final databaseService = getIt<DatabaseService>();
    await databaseService.initDatabase(password);
  }

  static void reset() {
    // Reset all services (useful for logout or testing)
    getIt.reset();
  }

  static bool get isDatabaseInitialized {
    // Check if database service is registered and initialized
    try {
      final databaseService = getIt<DatabaseService>();
      return databaseService.isInitialized;
    } catch (e) {
      return false;
    }
  }
}
