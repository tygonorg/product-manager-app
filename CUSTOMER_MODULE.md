# Customer Management Module

## Tổng quan
Module quản lý khách hàng cho phép thêm, sửa, xóa và tìm kiếm khách hàng trong ứng dụng Product Manager. Module hỗ trợ hai loại khách hàng: Cá nhân và Công ty.

## Cấu trúc Files

### Models
- `lib/models/customer.dart` - Customer model với Realm database
- `lib/models/customer.realm.dart` - Generated Realm schema file

### Controllers  
- `lib/controllers/customer_controller.dart` - Business logic và state management

### Views
- `lib/views/customer_list_screen.dart` - Danh sách khách hàng với tìm kiếm và filter
- `lib/views/add_edit_customer_screen.dart` - Form thêm/sửa khách hàng

### Services
- Database operations được thêm vào `lib/services/database_service.dart`

## Tính năng chính

### 1. Quản lý khách hàng
- ✅ Thêm khách hàng mới (cá nhân/công ty)
- ✅ Chỉnh sửa thông tin khách hàng
- ✅ Xóa khách hàng với xác nhận
- ✅ Tìm kiếm khách hàng theo tên, email, SĐT, công ty, địa chỉ
- ✅ Filter theo loại khách hàng (cá nhân/công ty)

### 2. Thông tin khách hàng
**Cá nhân:**
- Tên khách hàng *
- Email *
- Số điện thoại *
- Địa chỉ *
- Ghi chú

**Công ty:**
- Tên khách hàng *
- Email *
- Số điện thoại *
- Địa chỉ *
- Tên công ty *
- Mã số thuế
- Ghi chú

### 3. Tính năng nâng cao
- ✅ Validation form đầy đủ
- ✅ Hiển thị chi tiết khách hàng
- ✅ Thống kê số lượng khách hàng
- ✅ Responsive UI với Material Design 3
- ✅ Dark mode support

## Cách sử dụng

### 1. Truy cập module
1. Mở ứng dụng và đăng nhập
2. Từ Dashboard, chọn "Khách hàng"

### 2. Thêm khách hàng mới
1. Nhấn nút "+" ở góc dưới bên phải
2. Chọn loại khách hàng (Cá nhân/Công ty)
3. Điền đầy đủ thông tin bắt buộc (*)
4. Nhấn "Thêm" để lưu

### 3. Tìm kiếm khách hàng
1. Sử dụng thanh tìm kiếm ở đầu danh sách
2. Nhập từ khóa (tên, email, SĐT, công ty, địa chỉ)
3. Sử dụng filter chips để lọc theo loại

### 4. Chỉnh sửa khách hàng
1. Nhấn icon "edit" trên item khách hàng
2. Hoặc nhấn vào khách hàng để xem chi tiết, sau đó nhấn "Chỉnh sửa"
3. Cập nhật thông tin và nhấn "Cập Nhật"

### 5. Xóa khách hàng
1. Nhấn icon "delete" (màu đỏ) trên item khách hàng
2. Xác nhận trong dialog popup

## Database Schema

```dart
@RealmModel()
class _Customer {
  @PrimaryKey()
  late String id;
  late String name;
  late String email;
  late String phone;
  late String address;
  late String company;
  late String taxCode;
  late String customerType; // "individual" hoặc "company"
  late String notes;
  late DateTime createdAt;
  late DateTime updatedAt;
}
```

## API Methods

### CustomerController
- `loadCustomers()` - Load tất cả khách hàng
- `searchCustomers(String query)` - Tìm kiếm khách hàng
- `addCustomer(...)` - Thêm khách hàng mới
- `updateCustomer(...)` - Cập nhật thông tin khách hàng
- `deleteCustomer(String id)` - Xóa khách hàng
- `getCustomersByType(String type)` - Lấy khách hàng theo loại
- `getCustomerStatistics()` - Thống kê khách hàng

### DatabaseService
- `addCustomer(Customer customer)` - Thêm vào database
- `getAllCustomers()` - Lấy tất cả khách hàng
- `getCustomerById(String id)` - Lấy khách hàng theo ID
- `updateCustomer(Customer customer)` - Cập nhật database
- `deleteCustomer(String id)` - Xóa khỏi database
- `searchCustomers(String query)` - Tìm kiếm trong database

## Validation Rules

1. **Tên khách hàng**: Bắt buộc, không được để trống
2. **Email**: Bắt buộc, phải đúng định dạng email
3. **Số điện thoại**: Bắt buộc, phải đúng định dạng số điện thoại
4. **Địa chỉ**: Bắt buộc, không được để trống
5. **Tên công ty**: Bắt buộc khi loại là "Công ty"
6. **Mã số thuế**: Tùy chọn cho công ty
7. **Ghi chú**: Tùy chọn

## Screenshots Tính năng

### Dashboard
- Thêm tile "Khách hàng" với icon `Icons.groups`

### Customer List Screen
- Search bar với clear button
- Filter chips: Tất cả, Cá nhân, Công ty
- List view với avatar icons khác nhau cho từng loại
- Statistics button trong app bar
- FAB để thêm khách hàng mới

### Add/Edit Customer Screen
- Radio buttons để chọn loại khách hàng
- Dynamic form fields dựa trên loại được chọn
- Validation đầy đủ với error messages
- Action buttons: Hủy, Thêm/Cập Nhật

## Integration với App

Module được tích hợp hoàn toàn vào ứng dụng Product Manager:

1. **Dashboard**: Thêm navigation tile cho Customer
2. **Database**: Schema được thêm vào Realm configuration  
3. **Service Locator**: Controllers được đăng ký tự động
4. **Navigation**: Sử dụng GetX routing như các module khác
5. **Theme**: Tuân thủ Material Design 3 và dark mode

## Future Enhancements

- [ ] Export danh sách khách hàng ra Excel/PDF
- [ ] Import khách hàng từ file CSV
- [ ] Lịch sử giao dịch với khách hàng
- [ ] Nhóm khách hàng và tags
- [ ] Backup/restore dữ liệu khách hàng
- [ ] API sync với external CRM systems

## Testing

Để test module:

1. Chạy `flutter test` cho unit tests
2. Thêm khách hàng cá nhân và công ty
3. Test tìm kiếm với các từ khóa khác nhau
4. Test validation với input không hợp lệ
5. Test CRUD operations đầy đủ

## Branch Information

- **Branch**: `feature/add-manager-customer`
- **Base**: `develop`
- **Status**: ✅ Ready for review
- **Files changed**: 7 files, +1020 insertions, -1 deletion

## Commit History

```
d6c5c8a feat: Add customer management module
- Add Customer model with Realm database support  
- Add CustomerController with full CRUD operations
- Add CustomerListScreen with search and filter functionality
- Add AddEditCustomerScreen with form validation
- Support both individual and company customer types
- Add customer statistics and details view
- Update DatabaseService to include customer operations
- Add customer management to Dashboard
- Generate Realm schema files
```
