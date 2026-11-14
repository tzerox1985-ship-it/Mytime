# Taishodo Payroll & Attendance App (Flutter)

Ứng dụng chấm công hàng ngày và tính thu nhập realtime theo chuẩn bảng lương **CÔNG TY TNHH TAISHODO VIỆT NAM**.

---

## 1. Tính Năng Chính
- **Đăng nhập**: Hỗ trợ Email/Mật khẩu và Google Sign-In.
- **Tính thu nhập Realtime**: Cập nhật tức thì số tiền tích lũy theo từng ngày làm việc và từng giờ tăng ca.
- **Bảng hệ số tăng ca (OT) chuẩn Taishodo**:
  - Giờ làm thường: **150%**
  - Tăng ca sau 22h ngày thường: **200%**
  - Tăng ca đêm thường liên tục: **210%**
  - Tăng ca chủ nhật: **200%**
  - Tăng ca chủ nhật sau 22h: **270%**
  - Tăng ca ngày lễ: **300%**
  - Tăng ca sau 22h ngày lễ: **390%**
  - Phụ cấp ca đêm: **130%**
- **Cấu hình trích đóng Bảo hiểm & Đoàn phí**:
  - BHXH: **8%**
  - BHYT: **1.5%**
  - BHTN: **1%**
  - Kinh phí Công đoàn (KPCĐ): **40,000 đ**
- **Bảng lương điện tử**: Sao chép nguyên mẫu 37 dòng trên phiếu lương Taishodo, xuất file đối soát.

---

## 2. Hướng Dẫn Đóng Gói File .APK

### Cách 1: Tự Động Build .APK trên Cloud (GitHub Actions - Khuyên dùng)
Dự án đã tích hợp sẵn file `.github/workflows/build-apk.yml`.
1. Đẩy mã nguồn dự án lên kho chứa GitHub cá nhân.
2. Vào tab **Actions** $\rightarrow$ Chọn **Build Flutter APK** $\rightarrow$ Bấm **Run workflow**.
3. Sau khoảng 2-3 phút, GitHub sẽ xuất file `Taishodo-Payroll-Release-APK.zip` chứa file `app-release.apk` để tải trực tiếp về điện thoại cài đặt.

### Cách 2: Build Trực Tiếp Trên Máy Bằng Lệnh
Nếu máy bạn đã cài đặt Flutter SDK và Android Studio:
```bash
# 1. Cài đặt các thư viện
flutter pub get

# 2. Đóng gói file APK Release
flutter build apk --release
```
File APK thành phẩm sẽ nằm tại đường dẫn:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 3. Trải Nghiệm Nhanh Giao Diện (Web Preview)
Bạn có thể mở trực tiếp file `web_preview/index.html` bằng bất kỳ trình duyệt nào (Chrome, Edge) để trải nghiệm giao diện và thuật toán tính tiền realtime ngay lập tức!
