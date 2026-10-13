# Chạy MOVIEGO trên Android Studio

Project hiện chưa có thư mục `android/` (chỉ có `web/`), nên phải sinh một lần:

1. Cài Flutter SDK, mở Android Studio > Plugins > cài **Flutter** và **Dart**.
2. File > Open > chọn thư mục project (có `pubspec.yaml`).
3. Mở Terminal trong Android Studio, chạy:
   ```
   flutter create --platforms=android --project-name moviego .
   flutter pub get
   ```
   Lệnh này chỉ thêm `android/`, không ghi đè code trong `lib/`. Nếu nó đòi ghi đè `test/widget_test.dart` hoặc `pubspec.yaml`, chọn giữ bản hiện có (hoặc kiểm tra bằng `git diff`).
4. Kiểm tra `.env` có `SUPABASE_URL` và `SUPABASE_ANON_KEY` (xem `supabase/README.md` để tạo bảng).
5. Mở Device Manager, tạo máy ảo Android (API 24 trở lên), bấm Run.

## Quyền Internet khi build release
Bản debug có sẵn quyền Internet. Khi build APK release, thêm vào `android/app/src/main/AndroidManifest.xml`, ngay trên thẻ `<application>`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Lỗi thường gặp
- `Unable to load asset: .env`: thiếu file `.env` ở thư mục gốc (copy từ `.env.example`).
- Màn hình đăng nhập báo lỗi kết nối: kiểm tra máy ảo có mạng và `SUPABASE_URL` đúng.
- `relation "public.movies" does not exist`: chưa chạy `supabase/schema.sql`.
- Chạy `flutter analyze` và `flutter test` trước khi commit.
