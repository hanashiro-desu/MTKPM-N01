# Cấu trúc thư mục MOVIEGO (MVVM + tầng nghiệp vụ + tầng dữ liệu)

```
lib/
├─ main.dart                      Điểm vào: nạp .env → kết nối Supabase → chạy app
├─ app/app.dart                   Gắn Repository → ViewModel (MultiProvider), MaterialApp
├─ core/                          Dùng chung toàn app
│  ├─ config/app_config.dart        Singleton cấu hình (.env, thời gian giữ ghế)
│  ├─ constants/app_constants.dart  Hằng số (giá ghế, URL ảnh, ...)
│  ├─ theme/app_theme.dart          Màu sắc, theme
│  └─ routes/app_routes.dart        Tên route
│
├─ models/                        MODEL: dữ liệu thuần, khớp cột bảng Supabase (fromRow / toRow)
│  ├─ movie_model.dart  cinema_model.dart  booking_model.dart  user_model.dart
│
├─ views/                         VIEW: chỉ vẽ giao diện, không gọi Supabase, không có luật nghiệp vụ
│  ├─ shell/        app_shell.dart            Thanh điều hướng dưới
│  ├─ onboarding/   splash_screen, onboarding_screen
│  ├─ auth/         login, register, forgot_password, otp_verify
│  ├─ home/         home, search, movies
│  ├─ movie/        movie_detail_screen
│  ├─ cinema/       cinemas_screen
│  ├─ booking/      cinema_select, showtime, seat, combo, payment, payment_success
│  ├─ ticket/       tickets_screen, ticket_detail_screen
│  ├─ profile/      profile_screen
│  └─ widgets/      Thành phần dùng lại: app_logo, primary_button, movie_card, poster_image, ...
│
├─ viewmodels/                    VIEWMODEL: trạng thái màn hình (ChangeNotifier), gọi tầng business/db
│  ├─ auth_provider.dart  movie_provider.dart  booking_provider.dart
│
├─ business/                      NGHIỆP VỤ: không biết Flutter UI, không biết Supabase
│  ├─ booking/      booking_facade (Facade), booking_observer + booking_notifiers (Observer),
│  │                promo_rule, show_slot
│  ├─ payment/      payment_strategy + ewallet/card/cod (Strategy), checkout_service
│  └─ pricing/      seat_pricing (Strategy giá ghế)
│
└─ db/                            DỮ LIỆU: nơi duy nhất nói chuyện với Supabase / API ngoài
   ├─ supabase_client.dart          Khởi tạo kết nối (Singleton)
   ├─ database_seeder.dart          Nạp dữ liệu mẫu (chỉ dev)
   ├─ repositories/                 Interface + bản Supabase / trong bộ nhớ / TMDB
   ├─ remote/movie_api_service.dart Gọi API TMDB
   └─ mock/                         Dữ liệu mẫu offline

supabase/    schema.sql, seed.sql, dev_seed_policies.sql (chạy ở SQL Editor)
test/        Phản chiếu cấu trúc lib: business/, viewmodels/, db/
docs/        DESIGN_PATTERNS.md, CAU_TRUC_THU_MUC.md, ANDROID_STUDIO.md
```

## Chiều phụ thuộc (chỉ đi xuống)
`views → viewmodels → business → db → models`
- View không import `db/` hay `supabase_flutter`.
- `business/` không import `views/` hay `supabase_flutter`.
- Ngoại lệ có chủ ý: ViewModel đọc danh mục (phim, rạp) trực tiếp qua interface Repository; luồng đặt vé luôn qua `BookingFacade`.

## Thêm một chức năng mới (ví dụ: đánh giá phim)
1. Bảng `reviews` đã có trong `supabase/schema.sql`.
2. `models/review_model.dart` (+ `fromRow`).
3. `db/repositories/review_repository.dart` (interface) + `supabase_review_repository.dart`.
4. `viewmodels/review_provider.dart`, đăng ký ở `app/app.dart`.
5. `views/movie/review_section.dart`, gắn vào `movie_detail_screen.dart`.
6. Test ở `test/viewmodels/`.
