import 'package:get_it/get_it.dart';
import '../services/database_service.dart';

/// Singleton instance of GetIt for service location
final GetIt serviceLocator = GetIt.instance;

/// A utility class to register and manage services used across the app.
/// Uses the `get_it` package for dependency injection.
class ServiceLocator {
  /// Register all the services used in the application
  /// This should be called once during app startup
  static Future<void> setupLocator() async {
    // Register DatabaseService as a lazy singleton
    // This means the instance will be created only when it's first needed
    serviceLocator.registerLazySingleton<DatabaseService>(() => DatabaseService());
  }

  /// Initialize the database after user authentication using a password
  static Future<void> initializeDatabase(String password) async {
    final databaseService = serviceLocator<DatabaseService>();
    await databaseService.initDatabase(password);
  }

  /// Reset all registered services (useful when logging out or running tests)
  static void reset() {
    serviceLocator.reset();
  }

  /// Check if the database service is registered and initialized
  static bool get isDatabaseInitialized {
    try {
      final databaseService = serviceLocator<DatabaseService>();
      return databaseService.isInitialized;
    } catch (e) {
      // If the service is not found or not initialized
      return false;
    }
  }
}
