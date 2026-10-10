# Thiết lập Supabase cho MOVIEGO

> Khóa `sb_publishable_...` dùng trong app **không có quyền tạo bảng**. Bảng được tạo bằng SQL ở dashboard.

1. Mở Supabase Dashboard > **SQL Editor** > dán toàn bộ `schema.sql` > **Run**.
2. Dán `seed.sql` > **Run** (nạp 32 phim, 3 rạp/5 phòng, 3 combo, 2 mã giảm giá).
3. **Authentication > Providers > Email**: để thử nhanh có thể tắt "Confirm email". Nếu để bật, app sẽ báo "kiểm tra email để xác nhận".
4. Kiểm tra `.env` ở thư mục gốc có `SUPABASE_URL` và `SUPABASE_ANON_KEY` (mẫu: `.env.example`).
5. `flutter pub get` rồi `flutter run`.

## Nạp dữ liệu mẫu từ app (tùy chọn, chỉ dev)
Thay cho bước 2: chạy `dev_seed_policies.sql`, đặt `SEED_DEMO_DATA=true` trong `.env`, chạy app một lần, rồi chạy `drop_dev_seed_policies.sql` và đặt lại `SEED_DEMO_DATA=false`.

## Tạo tài khoản nhân viên / quản lý
Đăng ký bình thường trong app, rồi chạy trong SQL Editor:
```sql
update public.profiles set role = 'manager' where id = (select id from auth.users where email = 'email-cua-ban@example.com');
```
Người dùng không tự đổi được `role` từ app (đã `revoke update`).

## Bảng chính
`profiles`, `movies`, `cinemas`, `rooms`, `showtimes`, `combos`, `promotions`, `bookings`, `booking_seats` (unique theo suất + ghế, chống đặt trùng), `booking_combos`, `reviews`, `favorites`.
Hàm RPC: `ensure_showtime`, `hold_seats`, `release_seats`, `confirm_booking`, `set_booking_status`.
