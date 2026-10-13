# MOVIEGO - Flutter Mobile App

Đây là bản Flutter full-flow được dựng từ bộ màn hình MOVIEGO bạn đã cung cấp.

## Chạy
1. Cài Flutter 3.x.
2. Mở thư mục này.
3. Chạy `flutter pub get`
4. Chạy `flutter run`

## Cấu trúc & chạy trên Android Studio
- Thư mục: `docs/CAU_TRUC_THU_MUC.md` (Model, View, ViewModel, Business, Db).
- Cài và chạy trên máy ảo Android: `docs/ANDROID_STUDIO.md`.

## Kết nối Supabase (database + đăng nhập + đặt vé)
Xem `supabase/README.md`: chạy `supabase/schema.sql` rồi `supabase/seed.sql` trong SQL Editor, điền `SUPABASE_URL` và `SUPABASE_ANON_KEY` vào `.env`.
Chưa cấu hình Supabase thì app tự chạy chế độ offline (dữ liệu mẫu, đặt vé lưu trong bộ nhớ).
Kiến trúc 3 tầng và các mẫu thiết kế: `docs/DESIGN_PATTERNS.md`.

## Kết nối API phim

Ứng dụng đọc `TMDB_API_KEY` từ file `.env` (file này không được commit):

```bash
cp .env.example .env   # rồi điền API key TMDB của bạn
flutter run
```

Nếu chưa có key hoặc API/mạng lỗi, ứng dụng tự dùng danh sách phim mẫu (`lib/db/mock/mock_data.dart`).

## Cấu trúc & mẫu thiết kế
- `lib/business/payment/`: mẫu **Strategy** cho thanh toán (`PaymentStrategy`, `EWalletPayment`, `CardPayment`, `CodPayment`, context `CheckoutService`).
- `lib/business/booking/`: mẫu **Observer** cho thông báo vé (`BookingObserver`, `BookingSubject`, `InAppNotifier`, `EmailNotifier`) và quy tắc mã giảm giá.
- `lib/db/repositories/`: interface `MovieRepository`, `CinemaRepository`, `BookingRepository`, `AuthRepository` và bản hiện thực Supabase / TMDB / trong bộ nhớ.
- `lib/business/booking/booking_facade.dart`: mẫu **Facade** cho luồng đặt vé. `lib/business/pricing/`: **Strategy** cho giá ghế. `lib/core/config/`, `lib/db/`: **Singleton**.
- Quy ước code & Git: xem `CONTRIBUTING.md`. Chạy test: `flutter test`.

## Luồng đã có
Splash → Onboarding → Đăng nhập/Đăng ký → OTP/Quên mật khẩu → Trang chủ → Tìm kiếm → Danh sách phim → Chi tiết phim → Chọn rạp → Chọn ngày/suất → Chọn ghế → Bắp nước → Phương thức thanh toán → QR/thanh toán → Thành công → Vé → Chi tiết vé → Yêu thích → Thông báo → Tài khoản → Hồ sơ → Đổi mật khẩu → Lịch sử giao dịch → Cài đặt → Trợ giúp.

## Lưu ý
Đã nối Supabase cho phim, rạp, tài khoản, giữ ghế realtime và lưu vé. Thanh toán vẫn là mô phỏng, chưa có cổng thanh toán thật. Poster mẫu vẫn được dùng làm fallback khi API không có dữ liệu.
