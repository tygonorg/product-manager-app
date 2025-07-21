import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class UpdateQuantityScreen extends StatefulWidget {
  final Product product;

  const UpdateQuantityScreen({super.key, required this.product});

  @override
  State<UpdateQuantityScreen> createState() => _UpdateQuantityScreenState();
}

class _UpdateQuantityScreenState extends State<UpdateQuantityScreen> {
  final ProductController controller = Get.find<ProductController>();
  late TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(text: widget.product.quantity.toString());
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _updateQuantity() {
    final newQuantity = int.tryParse(_quantityController.text);
    if (newQuantity == null || newQuantity < 0) {
      Get.snackbar('Lỗi', 'Số lượng không hợp lệ.');
      return;
    }

    controller.updateProduct(
      id: widget.product.id,
      name: widget.product.name,
      description: widget.product.description,
      price: widget.product.price,
      quantity: newQuantity,
      categoryId: widget.product.category,
      imageUrl: widget.product.imageUrl,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cập nhật số lượng: ${widget.product.name}'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số lượng mới',
                border: const OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers, color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateQuantity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Cập nhật'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
