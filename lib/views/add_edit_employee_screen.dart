import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/employee_controller.dart';
import '../models/employee.dart';

/// Màn hình thêm hoặc sửa thông tin nhân viên
/// Nếu `employee` khác null, chế độ sửa sẽ được bật
class AddEditEmployeeScreen extends StatefulWidget {
  final Employee? employee;

  const AddEditEmployeeScreen({super.key, this.employee});

  @override
  State<AddEditEmployeeScreen> createState() => _AddEditEmployeeScreenState();
}

class _AddEditEmployeeScreenState extends State<AddEditEmployeeScreen> {
  final EmployeeController controller = Get.find<EmployeeController>();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _positionController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late DateTime _startDate;

  @override
  void initState() {
    super.initState();
    // Khởi tạo controller và các trường nhập liệu từ employee nếu có
    _nameController = TextEditingController(text: widget.employee?.name ?? '');
    _positionController = TextEditingController(text: widget.employee?.position ?? '');
    _emailController = TextEditingController(text: widget.employee?.email ?? '');
    _phoneController = TextEditingController(text: widget.employee?.phone ?? '');
    _startDate = widget.employee?.startDate ?? DateTime.now();
  }

  @override
  void dispose() {
    // Giải phóng bộ nhớ các TextEditingController
    _nameController.dispose();
    _positionController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Lưu hoặc cập nhật nhân viên tùy theo chế độ sửa hay thêm mới
  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final position = _positionController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();

      if (widget.employee != null) {
        controller.updateEmployee(
          id: widget.employee!.id,
          name: name,
          position: position,
          email: email,
          phone: phone,
          startDate: _startDate,
          createdAt: widget.employee!.createdAt,
        );
      } else {
        controller.addEmployee(
          name: name,
          position: position,
          email: email,
          phone: phone,
          startDate: _startDate,
        );
      }
    }
  }

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  String? _validateNotEmpty(String? value, String message) {
    return (value == null || value.trim().isEmpty) ? message : null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Vui lòng nhập email';
    if (!GetUtils.isEmail(value.trim())) return 'Email không hợp lệ';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.employee != null ? 'Sửa Nhân Viên' : 'Thêm Nhân Viên'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Tên nhân viên',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                validator: (value) => _validateNotEmpty(value, 'Vui lòng nhập tên'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _positionController,
                decoration: InputDecoration(
                  labelText: 'Chức vụ',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.work, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                validator: (value) => _validateNotEmpty(value, 'Vui lòng nhập chức vụ'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Số điện thoại',
                  border: const OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone, color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => _validateNotEmpty(value, 'Vui lòng nhập số điện thoại'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Ngày bắt đầu: ${DateFormat('dd/MM/yyyy').format(_startDate)}'),
                  ),
                  TextButton(
                    onPressed: _pickStartDate,
                    child: const Text('Chọn ngày'),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  child: Text(widget.employee != null ? 'Cập nhật' : 'Lưu'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
