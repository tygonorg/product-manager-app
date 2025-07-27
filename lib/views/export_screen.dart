import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/export_controller.dart';
import '../controllers/product_controller.dart';
import '../controllers/employee_controller.dart';
import '../controllers/customer_controller.dart';
import '../models/customer.dart';
import '../models/product.dart';
import 'add_edit_customer_screen.dart';

class ExportScreen extends StatefulWidget {
  final Product? productToExport;

  const ExportScreen({super.key, this.productToExport});
  
  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  final ExportController exportController = Get.find<ExportController>();
  final ProductController productController = Get.find<ProductController>();
  final EmployeeController employeeController = Get.find<EmployeeController>();
  final CustomerController customerController = Get.find<CustomerController>();
  
  String? selectedEmployeeId;
  Customer? selectedCustomer;
  
  @override
  void initState() {
    super.initState();
    // Set default employee if available
    if (employeeController.employees.isNotEmpty) {
      selectedEmployeeId = employeeController.employees.first.id;
    }
    // Clear previous export data
    exportController.clearExportSelection();
    
    // Sync the selected customer with the controller
    selectedCustomer = exportController.selectedCustomer.value;

    // If a product is passed, add it to the export list
    if (widget.productToExport != null) {
      exportController.addProductToExport(widget.productToExport!);
    }
  }
  
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo Hóa Đơn Xuất Hàng'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Employee selection
                Obx(() => DropdownButtonFormField<String>(
                  value: selectedEmployeeId,
                  decoration: InputDecoration(
                    labelText: 'Nhân viên thực hiện',
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  items: employeeController.employees.map((employee) {
                    return DropdownMenuItem<String>(
                      value: employee.id,
                      child: Text('${employee.name} - ${employee.position}'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedEmployeeId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng chọn nhân viên';
                    }
                    return null;
                  },
                )),
                const SizedBox(height: 16),
                // Customer selection
                Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        // Sync selectedCustomer with controller state
                        final controllerCustomer = exportController.selectedCustomer.value;
                        if (controllerCustomer != selectedCustomer) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              selectedCustomer = controllerCustomer;
                            });
                          });
                        }
                        
                        return DropdownButtonFormField<Customer>(
                          value: selectedCustomer,
                          decoration: InputDecoration(
                            labelText: 'Khách hàng',
                            border: const OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurfaceVariant),
                          ),
                          items: customerController.customers.map((customer) {
                            return DropdownMenuItem<Customer>(
                              value: customer,
                              child: Text('${customer.name} - ${customer.phone}'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCustomer = value;
                              // Update the controller's selected customer
                              exportController.setSelectedCustomer(value);
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Vui lòng chọn khách hàng';
                            }
                            return null;
                          },
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: _addNewCustomer,
                      icon: const Icon(Icons.person_add, size: 20),
                      label: const Text('Thêm KH'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.tertiary,
                        foregroundColor: Theme.of(context).colorScheme.onTertiary,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showProductSelectionDialog(context),
                    icon: Icon(Icons.add_shopping_cart, color: Theme.of(context).colorScheme.onSecondary),
                    label: const Text('Chọn sản phẩm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (exportController.selectedProductsToExport.isEmpty) {
                return const Center(child: Text('Chưa có sản phẩm nào được chọn.'));
              }
              return ListView.builder(
                itemCount: exportController.selectedProductsToExport.length,
                itemBuilder: (context, index) {
                  final product = exportController.selectedProductsToExport[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text('Giá: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(product.price)}'),
                                Text('Tồn kho: ${product.quantity}'),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(labelText: 'SL'),
                              controller: TextEditingController(text: exportController.productQuantities[product.id]?.toString() ?? '1'),
                              onChanged: (value) {
                                int quantity = int.tryParse(value) ?? 0;
                                exportController.updateProductQuantity(product, quantity);
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => exportController.removeProductFromExport(product),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
            ),
            child: Column(
              children: [
                Obx(() => Text(
                  'Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(exportController.calculateTotalAmount())}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _createExport,
                    icon: Icon(Icons.receipt_long, color: Theme.of(context).colorScheme.onPrimary),
                    label: const Text(
                      'Tạo Hóa Đơn',
                      style: TextStyle(
                        color: Colors.white,
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
        ],
      ),
    );
  }

  void _createExport() {
    // Validation
    if (selectedEmployeeId == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn nhân viên thực hiện',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        colorText: Theme.of(context).colorScheme.onErrorContainer,
      );
      return;
    }
    
    if (selectedCustomer == null) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn khách hàng',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        colorText: Theme.of(context).colorScheme.onErrorContainer,
      );
      return;
    }
    
    if (exportController.selectedProductsToExport.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng chọn ít nhất một sản phẩm',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Theme.of(context).colorScheme.errorContainer,
        colorText: Theme.of(context).colorScheme.onErrorContainer,
      );
      return;
    }
    
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Xác nhận tạo hóa đơn'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Khách hàng: ${selectedCustomer!.name}'),
            Text('SĐT: ${selectedCustomer!.phone}'),
            Text('Số sản phẩm: ${exportController.selectedProductsToExport.length}'),
            Text(
              'Tổng tiền: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(exportController.calculateTotalAmount())}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // Close confirmation dialog
              
              exportController.createExport(
                employeeId: selectedEmployeeId!,
                customer: selectedCustomer, // Pass the Customer object
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
  
  void _addNewCustomer() async {
    final Customer? newCustomer = await Get.to(() => const AddEditCustomerScreen());
    if (newCustomer != null && mounted) {
      // Refresh the customer list and update the selected customer
      setState(() {
        selectedCustomer = newCustomer;
        exportController.setSelectedCustomer(newCustomer);
      });
      
      // Show success message
      Get.snackbar(
        'Thành công',
        'Đã thêm khách hàng mới: ${newCustomer.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade800,
      );
    }
  }
  
  void _showProductSelectionDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Chọn sản phẩm'),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() => ListView.builder(
            itemCount: productController.products.length,
            itemBuilder: (context, index) {
              final product = productController.products[index];
              final isSelected = exportController.selectedProductsToExport.contains(product);
              return ListTile(
                title: Text(product.name),
                subtitle: Text('Tồn kho: ${product.quantity}'),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.secondary)
                    : Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
                onTap: () {
                  if (isSelected) {
                    exportController.removeProductFromExport(product);
                  } else {
                    exportController.addProductToExport(product);
                  }
                },
              );
            },
          )),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}
