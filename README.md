# Product Manager App 📦

Ứng dụng quản lý toàn diện được xây dựng bằng Flutter với GetX state management và Realm database có mã hóa.

## 🌟 Tính năng

- ✅ **GetX State Management**: Quản lý trạng thái hiệu quả.
- ✅ **Realm Database**: Lưu trữ dữ liệu cục bộ an toàn với mã hóa AES-256.
- ✅ **Quản lý sản phẩm**: Thêm, sửa, xóa, tìm kiếm sản phẩm.
- ✅ **Quản lý khách hàng**: Thêm, sửa, xóa, tìm kiếm khách hàng.
- ✅ **Quản lý nhân viên**: Thêm, sửa, xóa, tìm kiếm nhân viên.
- ✅ **Quản lý danh mục**: Sắp xếp sản phẩm theo danh mục.
- ✅ **Quản lý xuất hàng**: Tạo và quản lý các đơn hàng xuất kho.
- ✅ **Thống kê và báo cáo**: Xem thống kê doanh thu, sản phẩm bán chạy theo thời gian (tháng, quý, năm) với biểu đồ trực quan.
- ✅ **Cài đặt ứng dụng**: Tùy chỉnh giao diện (sáng/tối), màu chủ đạo và quản lý dữ liệu.
- ✅ **Giao diện tiếng Việt**: UI thân thiện và dễ sử dụng.

## 🛠 Cài đặt

1. **Clone dự án và cài đặt dependencies:**
   ```bash
   cd product_manager_app
   flutter pub get
   ```

2. **Generate Realm schema:**
   Lệnh này sẽ tạo các file `.realm.dart` cần thiết cho models.
   ```bash
   dart run realm generate
   ```

3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

## 📱 Sử dụng

1. **Đăng nhập**: Nhập mật khẩu để mã hóa và truy cập database. Mật khẩu này sẽ được dùng cho các lần đăng nhập sau.
2. **Dashboard**: Màn hình chính cung cấp truy cập nhanh đến các chức năng chính: Sản phẩm, Khách hàng, Nhân viên, Xuất hàng, Thống kê, và Cài đặt.
3. **Quản lý (Sản phẩm, Khách hàng, etc.)**:
    - Nhấn nút `+` để thêm một mục mới.
    - Sử dụng thanh tìm kiếm để tìm kiếm nhanh.
    - Nhấn vào menu 3 chấm trên mỗi mục để Sửa hoặc Xóa.
4. **Xem thống kê**: Truy cập màn hình thống kê để xem các báo cáo và biểu đồ.
5. **Cài đặt**: Tùy chỉnh các cài đặt của ứng dụng.

## 🧪 Kiểm thử

Dự án sử dụng `integration_test` để thực hiện kiểm thử tự động từ đầu đến cuối (E2E testing).

**Lưu ý quan trọng:**
- Trước khi chạy test, hãy đảm bảo bạn đã kết nối một thiết bị (thật hoặc ảo).
- Các kịch bản test yêu cầu các `Key` được gán cho các widget quan trọng (như `TextField`, `DropdownButton`). Hãy kiểm tra các file test trong thư mục `integration_test/` để biết chi tiết.

**Chạy tất cả các bài test:**
```bash
flutter test integration_test
```

**Chạy một bài test cụ thể:**
Ví dụ, để chạy test cho chức năng thêm sản phẩm:
```bash
flutter test integration_test/add_product_test.dart
```

## 🗂 Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point
├── core/
│   └── service_locator.dart  # Service locator setup
├── controllers/
│   ├── product_controller.dart
│   ├── customer_controller.dart
│   ├── employee_controller.dart
│   ├── export_controller.dart
│   ├── category_controller.dart
│   ├── statistics_controller.dart
│   └── settings_controller.dart
├── models/
│   ├── product.dart, product.realm.dart
│   ├── customer.dart, customer.realm.dart
│   ├── employee.dart, employee.realm.dart
│   ├── category.dart, category.realm.dart
│   └── export.dart, export.realm.dart
├── services/
│   └── database_service.dart # Database operations
└── views/
    ├── dashboard_screen.dart
    ├── product_list_screen.dart & add_edit_product_screen.dart
    ├── customer_list_screen.dart & add_edit_customer_screen.dart
    ├── employee_list_screen.dart & add_edit_employee_screen.dart
    ├── category_list_screen.dart
    ├── export_list_screen.dart & export_detail_screen.dart
    ├── statistics_screen.dart
    └── settings_screen.dart
```

## 🔐 Bảo mật Database

- Database Realm được mã hóa bằng AES-256.
- Mật khẩu được hash bằng SHA-256 để tạo khóa mã hóa.
- **Lưu ý**: Nếu quên mật khẩu, bạn sẽ không thể truy cập dữ liệu cũ.

## 📋 Dependencies chính

- `get: ^4.6.6` - State management
- `realm: ^3.0.0` - Database
- `crypto: ^3.0.3` - Encryption
- `uuid: ^4.4.0` - Unique IDs
- `intl: ^0.20.2` - Internationalization
- `get_storage: ^2.1.1` - Local storage for settings

## 🚀 Các tính năng có thể mở rộng

- [ ] Upload hình ảnh sản phẩm
- [ ] Xuất/nhập dữ liệu Excel
- [ ] Đồng bộ cloud
- [ ] Barcode scanner

---

Chúc bạn sử dụng app vui vẻ! 🎉
