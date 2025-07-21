import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/product_controller.dart';
import '../models/product.dart';
import 'add_edit_product_screen.dart';
import 'category_list_screen.dart'; // Import category screen
import 'export_screen.dart';
import 'update_quantity_screen.dart';

class ProductListScreen extends StatelessWidget {
  final ProductController controller = Get.find<ProductController>();
  
  ProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quản Lý Sản Phẩm',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            onPressed: () {
              Get.to(() => CategoryListScreen())?.then((_) => controller.loadCategories());
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadInitialData(),
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary,
            child: Column(
              children: [
                // Search Bar
                SizedBox(
                  height: 50, // Explicitly constrain TextField height
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm sản phẩm...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onChanged: (value) => controller.searchProducts(value),
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Category Filter
                SizedBox(
                  height: 40,
                  child: Obx(() => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    // Add 1 for the "Tất cả" (All) option
                    itemCount: controller.categories.length + 1,
                    itemBuilder: (context, index) {
                      // First item is "All"
                      if (index == 0) {
                        final isSelected = controller.selectedCategoryId.value == null;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text('Tất cả'),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                controller.selectCategory(null);
                              }
                            },
                            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                            selectedColor: Theme.of(context).colorScheme.secondary,
                            labelStyle: TextStyle(
                              color: isSelected ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onSurfaceVariant,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      }
                      
                      // Other items are categories from the controller
                      final category = controller.categories[index - 1];
                      final isSelected = controller.selectedCategoryId.value == category.id;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              controller.selectCategory(category.id);
                            } else {
                              controller.selectCategory(null);
                            }
                          },
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          selectedColor: Theme.of(context).colorScheme.secondary,
                          labelStyle: TextStyle(
                            color: isSelected ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                  )),
                ),
              ],
            ),
          ),
          
          // Product List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.filteredProducts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        controller.searchQuery.value.isNotEmpty || controller.selectedCategoryId.value != null
                          ? 'Không tìm thấy sản phẩm'
                          : 'Chưa có sản phẩm nào',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.searchQuery.value.isNotEmpty || controller.selectedCategoryId.value != null
                          ? 'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc'
                          : 'Nhấn nút + để thêm sản phẩm đầu tiên',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = controller.filteredProducts[index];
                  return ProductCard(
                    product: product,
                    // Pass category name to the card
                    categoryName: controller.getCategoryName(product.category),
                    onEdit: () => _editProduct(product),
                    onDelete: () => controller.deleteProduct(product.id),
                    onExport: () => _exportProduct(product),
                    onUpdateQuantity: () => _updateQuantity(product),
                  );
                },
              );
            }),
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSecondary),
      ),
    );
  }

  void _addProduct() {
    if (controller.categories.isEmpty) {
      Get.snackbar(
        'Không có danh mục',
        'Vui lòng thêm ít nhất một danh mục trước khi thêm sản phẩm.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.to(() => AddEditProductScreen());
  }

  void _editProduct(Product product) {
    Get.to(() => AddEditProductScreen(product: product));
  }

  void _exportProduct(Product product) {
    Get.to(() => ExportScreen(productToExport: product));
  }

  void _updateQuantity(Product product) {
    Get.to(() => UpdateQuantityScreen(product: product));
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onExport;
  final VoidCallback onUpdateQuantity;

  const ProductCard({
    super.key,
    required this.product,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
    required this.onExport,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Name and Actions
            Row(
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                    if (value == 'export') onExport();
                    if (value == 'update_quantity') onUpdateQuantity();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'export',
                      child: Row(
                        children: [
                          Icon(Icons.local_shipping, size: 20),
                          SizedBox(width: 8),
                          Text('Xuất hàng'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'update_quantity',
                      child: Row(
                        children: [
                          Icon(Icons.add_box, size: 20),
                          SizedBox(width: 8),
                          Text('Cập nhật SL'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Description
            if (product.description.isNotEmpty)
              Text(
                product.description,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            
            const SizedBox(height: 12),
            
            // Price and Quantity
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    currencyFormat.format(product.price),
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: product.quantity > 10 
                      ? Colors.blue.shade100 
                      : Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2,
                        size: 16,
                        color: product.quantity > 10 
                          ? Colors.blue.shade800 
                          : Colors.orange.shade800,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.quantity}',
                        style: TextStyle(
                          color: product.quantity > 10 
                            ? Colors.blue.shade800 
                            : Colors.orange.shade800,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Category and Date
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    categoryName, // Use category name
                    style: TextStyle(
                      color: Colors.purple.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                
                const Spacer(),
                
                Text(
                  'Cập nhật: ${DateFormat('dd/MM/yyyy HH:mm').format(product.updatedAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
