import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../extensions/product_extensions.dart';

class CloudSyncService {
  final String endpoint;

  CloudSyncService(this.endpoint);

  Future<void> syncProducts(List<Product> products) async {
    final response = await http.post(
      Uri.parse('$endpoint/sync'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(products.map((p) => p.toMap()).toList()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to sync: ${response.body}');
    }
  }
}
