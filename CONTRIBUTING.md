# Quy ước làm việc nhóm (Bài 6: Lập trình theo thiết kế & Git)

## Chuẩn code (Dart)
- Lớp: danh từ, `PascalCase` (`CheckoutService`). Hàm/biến: `camelCase`, tên có nghĩa nghiệp vụ (`totalAmount`, không dùng `tam`, `x`).
- Hằng số gom vào `AppConstants` hoặc `const`, không để số/chuỗi "ma thuật" rải rác.
- Mỗi hàm một việc, khoảng 20-30 dòng. Không để code bị comment-out; `TODO` phải ghi rõ ai làm: `TODO(ten): ...`.
- Chạy `dart format .` và `flutter analyze` trước khi commit.

## Từ thiết kế sang code
- Phụ thuộc vào interface, không vào lớp cụ thể: `PaymentStrategy`, `BookingObserver`, `MovieRepository`.
- Thêm phương thức thanh toán mới = thêm 1 lớp trong `lib/business/payment/` + 1 dòng trong `payment_methods.dart`.
- Thêm kênh thông báo mới = thêm 1 lớp `BookingObserver` + đăng ký ở `lib/app/app.dart`.

## Git
- Nhánh: `main` (ổn định) <- `dev` (tích hợp) <- `feature/ten-tinh-nang` (mỗi người một nhánh).
- Không code trực tiếp trên `main`. Pull `dev` mới nhất trước khi bắt đầu mỗi ngày.
- Commit: `<loại>: <mô tả>` với loại là `feat`, `fix`, `refactor`, `docs`, `test`. VD: `feat: thêm PaymentStrategy cho ví điện tử`.
- Mỗi Pull Request nhỏ, một tính năng, có người khác review trong 24-48 giờ; không tự merge PR của mình.

## Dùng AI (liêm chính học thuật)
Trong mô tả PR ghi rõ: phần nào có AI hỗ trợ, đã kiểm tra/chỉnh sửa gì, và vì sao chọn mẫu thiết kế đó.
Thành viên nộp PR phải giải thích được từng đoạn code khi giảng viên hỏi.
