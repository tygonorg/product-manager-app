# Product Manager App 📦

Ứng dụng quản lý sản phẩm được xây dựng bằng Flutter với GetX state management và Realm database có mã hóa.

## 🌟 Tính năng

- ✅ **GetX State Management**: Quản lý trạng thái hiệu quả
- ✅ **Realm Database**: Database với mã hóa password 
- ✅ **CRUD Operations**: Thêm, sửa, xóa, tìm kiếm sản phẩm
- ✅ **Tìm kiếm**: Tìm kiếm theo tên và mô tả sản phẩm
- ✅ **Lọc theo danh mục**: Điện tử, Thời trang, Thực phẩm, Sách, Khác
- ✅ **Giao diện tiếng Việt**: UI thân thiện với người dùng Việt Nam
- ✅ **Bảo mật**: Database được mã hóa bằng password

## 🛠 Cài đặt

1. **Clone dự án và cài đặt dependencies:**
   ```bash
   cd product_manager_app
   flutter pub get
   ```

2. **Generate Realm schema:**
   ```bash
   dart run realm generate
   ```

3. **Chạy ứng dụng:**
   ```bash
   flutter run
   ```

## 📱 Sử dụng

1. **Đăng nhập**: Nhập password để mã hóa database (có thể dùng password bất kỳ)
2. **Thêm sản phẩm**: Nhấn nút + để thêm sản phẩm mới
3. **Tìm kiếm**: Dùng thanh tìm kiếm ở đầu màn hình
4. **Lọc**: Chọn danh mục để lọc sản phẩm
5. **Sửa/Xóa**: Nhấn menu 3 chấm trên mỗi sản phẩm

## 🗂 Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point
├── bindings/
│   └── app_bindings.dart     # Dependency injection
├── controllers/
│   └── product_controller.dart # Business logic
├── models/
│   ├── product.dart          # Product model
│   └── product.realm.dart    # Generated Realm schema
├── services/
│   └── database_service.dart # Database operations
└── views/
    ├── login_screen.dart     # Password login
    ├── product_list_screen.dart # Main product list
    └── add_edit_product_screen.dart # Add/Edit form
```

## 🔐 Bảo mật Database

- Database Realm được mã hóa bằng AES-256
- Password được hash bằng SHA-256 để tạo encryption key
- Database file: `product_manager.realm` (được mã hóa)

## 💡 Ghi chú

- Lần đầu chạy app, bạn có thể nhập bất kỳ password nào
- Password này sẽ được dùng để mã hóa database
- **Lưu ý**: Nếu quên password, bạn sẽ không thể truy cập dữ liệu cũ

## 📋 Dependencies chính

- `get: ^4.6.6` - State management
- `realm: ^3.0.0` - Database
- `crypto: ^3.0.3` - Encryption
- `uuid: ^4.4.0` - Unique IDs
- `intl: ^0.20.2` - Internationalization

## 🚀 Các tính năng có thể mở rộng

- [ ] Upload hình ảnh sản phẩm
- [ ] Xuất/nhập dữ liệu Excel
- [ ] Thống kê và báo cáo
- [ ] Đồng bộ cloud
- [ ] Quản lý tồn kho nâng cao
- [ ] Barcode scanner

---

Chúc bạn sử dụng app vui vẻ! 🎉
