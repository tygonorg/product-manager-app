import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product;

  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final ProductController controller = Get.find<ProductController>();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? '');
    
    if (widget.product != null) {
      _selectedCategoryId = widget.product!.category;
    } else {
      // Set default category if available
      _selectedCategoryId = controller.categories.isNotEmpty ? controller.categories.first.id : null;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        Get.snackbar('Lỗi', 'Vui lòng chọn một danh mục.');
        return;
      }

      final name = _nameController.text.trim();
      final description = _descriptionController.text.trim();
      final price = double.tryParse(_priceController.text) ?? 0.0;
      final quantity = int.tryParse(_quantityController.text) ?? 0;

      if (widget.product != null) {
        controller.updateProduct(
          id: widget.product!.id,
          name: name,
          description: description,
          price: price,
          quantity: quantity,
          categoryId: _selectedCategoryId!,
        );
      } else {
        controller.addProduct(
          name: name,
          description: description,
          price: price,
          quantity: quantity,
          categoryId: _selectedCategoryId!,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Sửa Sản Phẩm' : 'Thêm Sản Phẩm'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Theme.of(context).colorScheme.onPrimary),
            onPressed: _saveProduct,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên sản phẩm',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.label, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên sản phẩm';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Giá',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập giá';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Giá không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Số lượng',
                        border: const OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập số lượng';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Số lượng không hợp lệ';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Obx(() => DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                items: controller.categories.map((category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Loại sản phẩm',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Vui lòng chọn loại sản phẩm';
                  }
                  return null;
                },
              )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _saveProduct,
                  icon: Icon(Icons.save, color: Theme.of(context).colorScheme.onPrimary),
                  label: Text(
                    widget.product != null ? 'Cập Nhật' : 'Lưu',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

