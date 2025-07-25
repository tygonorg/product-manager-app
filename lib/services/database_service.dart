import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:realm/realm.dart';
import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/product.dart';
import '../models/category.dart';
import '../models/employee.dart';
import '../models/export.dart';

class DatabaseService {
  Realm? _realm;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;

  Realm get realm => _realm!;
  
  // Tạo encryption key từ password
  Uint8List _generateEncryptionKey(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    final key = Uint8List(64);
    final digestBytes = digest.bytes;
    
    // Lặp lại digest để tạo đủ 64 bytes
    for (int i = 0; i < 64; i++) {
      key[i] = digestBytes[i % digestBytes.length];
    }
    
    return key;
  }
  
  Future<void> initDatabase(String password) async {
    try {
      final encryptionKey = _generateEncryptionKey(password);
      
      // Lấy đường dẫn thư mục Documents của app
      Directory appDocDir;
      if (Platform.isIOS) {
        appDocDir = await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        // Sử dụng getApplicationSupportDirectory() cho Android để tránh lỗi permission
        appDocDir = await getApplicationSupportDirectory();
      } else {
        appDocDir = await getApplicationDocumentsDirectory();
      }
      
      // Tạo đường dẫn đầy đủ cho file database
      final dbPath = path.join(appDocDir.path, 'product_manager.realm');
      
      print('Database path: $dbPath');
      
      final config = Configuration.local(
        [Product.schema, Category.schema, Employee.schema, Export.schema], // Thêm Export và ExportItem schema
        encryptionKey: encryptionKey,
        path: dbPath,
      );
      
      _realm = Realm(config);
      _isInitialized = true;
      print('Database initialized successfully with encryption at: $dbPath');
    } catch (e) {
      _isInitialized = false;
      print('Error initializing database: $e');
      rethrow;
    }
  }
  
  void _ensureInitialized() {
    if (!_isInitialized || _realm == null) {
      throw Exception('Database not initialized. Call initDatabase() first.');
    }
  }
  
  // CRUD operations cho Product
  void addProduct(Product product) {
    _ensureInitialized();
    _realm!.write(() {
      _realm!.add(product);
    });
  }
  
  List<Product> getAllProducts() {
    _ensureInitialized();
    return _realm!.all<Product>().toList();
  }
  
  Product? getProductById(String id) {
    _ensureInitialized();
    return _realm!.find<Product>(id);
  }
  
  void updateProduct(Product product) {
    _ensureInitialized();
    _realm!.write(() {
      _realm!.add(product, update: true);
    });
  }
  
  void deleteProduct(String id) {
    _ensureInitialized();
    final product = _realm!.find<Product>(id);
    if (product != null) {
      _realm!.write(() {
        _realm!.delete(product);
      });
    }
  }
  
  void updateProductQuantity(String productId, int quantityChange) {
    _ensureInitialized();
    final product = _realm!.find<Product>(productId);
    if (product != null) {
      _realm!.write(() {
        product.quantity += quantityChange;
      });
    }
  }
  
  // CRUD operations cho Category
  void addCategory(Category category) {
    _ensureInitialized();
    _realm!.write(() {
      _realm!.add(category);
    });
  }

  List<Category> getAllCategories() {
    _ensureInitialized();
    return _realm!.all<Category>().toList();
  }

  void updateCategory(Category category) {
    _ensureInitialized();
    _realm!.write(() {
      _realm!.add(category, update: true);
    });
  }

  void deleteCategory(String id) {
    _ensureInitialized();
    final category = _realm!.find<Category>(id);
    if (category != null) {
      _realm!.write(() {
        _realm!.delete(category);
      });
    }
  }
  
  // CRUD operations cho Employee
  void addEmployee(Employee employee) {
    _ensureInitialized();
    _realm!.write(() {
      _realm!.add(employee);
    });
  }

  List<Employee> getAllEmployees() {
    _ensureInitialized();
    return _realm!.all<Employee>().toList();
  }

  Employee? getEmployeeById(String id) {
    _ensureInitialized();
    return _realm!.find<Employee>(id);
  }

  void updateEmployee(Employee employee) {
    _ensureInitialized();
    _realm!.write(() {
      _realm!.add(employee, update: true);
    });
  }

  void deleteEmployee(String id) {
    _ensureInitialized();
    final employee = _realm!.find<Employee>(id);
    if (employee != null) {
      _realm!.write(() {
        _realm!.delete(employee);
      });
    }
  }
  
  // CRUD operations cho Export
  void addExport(Export export) {
    _ensureInitialized();
    _realm!.write(() {
      _realm!.add(export);
    });
  }

  List<Export> getAllExports() {
    _ensureInitialized();
    return _realm!.all<Export>().toList();
  }

  Export? getExportById(String id) {
    _ensureInitialized();
    return _realm!.find<Export>(id);
  }

  void deleteExport(String id) {
    _ensureInitialized();
    final export = _realm!.find<Export>(id);
    if (export != null) {
      _realm!.write(() {
        _realm!.delete(export);
      });
    }
  }
  
  List<Product> searchProducts(String query) {
    _ensureInitialized();
    final lowerCaseQuery = query.toLowerCase();

    // 1. Find category IDs that match the query
    final matchingCategoryIds = _realm!
        .all<Category>()
        .where((c) => c.name.toLowerCase().contains(lowerCaseQuery))
        .map((c) => c.id)
        .toList();

    // 2. Query products by name, description, or matching category ID
    return _realm!.all<Product>().where((product) {
      final productNameMatch = product.name.toLowerCase().contains(lowerCaseQuery);
      final productDescriptionMatch =
          product.description.toLowerCase().contains(lowerCaseQuery);
      final categoryMatch = matchingCategoryIds.contains(product.category);

      return productNameMatch || productDescriptionMatch || categoryMatch;
    }).toList();
  }
  
  List<Product> getProductsByCategory(String categoryId) {
    _ensureInitialized();
    return _realm!.all<Product>()
        .where((product) => product.category == categoryId)
        .toList();
  }
  
  Future<void> deleteAllData() async {
    _ensureInitialized();
    try {
      _realm!.write(() {
        _realm!.deleteAll<Product>();
        _realm!.deleteAll<Category>();
        _realm!.deleteAll<Employee>();
        _realm!.deleteAll<Export>();
      });
      _realm!.close();
      _realm = null;
      _isInitialized = false;

      // Delete the Realm file from the file system
      Directory appDocDir;
      if (Platform.isIOS) {
        appDocDir = await getApplicationDocumentsDirectory();
      } else if (Platform.isAndroid) {
        appDocDir = await getApplicationSupportDirectory();
      } else {
        appDocDir = await getApplicationDocumentsDirectory();
      }
      final dbPath = path.join(appDocDir.path, 'product_manager.realm');
      final dbFile = File(dbPath);
      if (await dbFile.exists()) {
        await dbFile.delete();
        print('Realm database file deleted: $dbPath');
      }
    } catch (e) {
      print('Error deleting all data: $e');
      rethrow;
    }
  }

  void dispose() {
    if (_realm != null) {
      _realm!.close();
      _realm = null;
    }
    _isInitialized = false;
  }
}
