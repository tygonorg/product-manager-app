import '../models/product.dart';

extension ProductSerialization on Product {
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'quantity': quantity,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'imageUrl': imageUrl,
      };
}
