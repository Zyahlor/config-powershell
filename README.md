# Hướng dẫn Cấu hình PowerShell theo phong cách devaslife (Takuya Matsuyama)

Video tham khảo: [How to set up PowerShell prompt with Oh My Posh on Windows 11 - devaslife](https://www.youtube.com/watch?v=5-aK2_WwrmM)

---

## 🚀 1. Những gì đã được thiết lập trên máy của bạn

1. **PowerShell 7 (PowerShell Core 7.6.6)**: Bản PowerShell mới nhất, tốc độ cao hơn và hỗ trợ đa nền tảng.
2. **Oh My Posh (v31.7+) & Theme `takuya.omp.json`**:
   - Giao diện prompt 2 dòng bo tròn phong cách pill/diamond cực đẹp.
   - Hiển thị shell hiện tại, đường dẫn thư mục, trạng thái Git (branch, ahead/behind, unstaged/staged), Node.js version và đồng hồ thời gian thực.
3. **Phông chữ Nerd Font**:
   - Máy đã cài sẵn `JetBrainsMono Nerd Font` (đầy đủ ký tự icon, glyphs, Powerline arrows).
4. **Các PowerShell Module chuyên nghiệp**:
   - **`Terminal-Icons`**: Hiển thị icon màu cho từng loại file/thư mục khi chạy lệnh `ls` hoặc `ll`.
   - **`PSReadLine` (v2.4.5)**: Tự động gợi ý lệnh theo lịch sử gõ (Inline prediction giống Fish shell), chỉnh sửa kiểu Emacs (`Ctrl+D`, `Ctrl+A`, `Ctrl+E`), không tiếng bíp khó chịu.
   - **`PSFzf`**: Tìm kiếm lịch sử lệnh và file/thư mục mờ (fuzzy finder) tích hợp với `fzf`.
   - **`posh-git`**: Tự động gợi ý tab cho lệnh git và theo dõi trạng thái branch.
   - **`z`**: Nhảy nhanh tới thư mục thường dùng mà không cần gõ đường dẫn dài.
5. **Windows Terminal**:
   - Đã cấu hình font mặc định `JetBrainsMono Nerd Font`.
   - Đã bật hiệu ứng kính mờ **Acrylic** và độ mờ nền **90%** (trong suốt sang trọng như video).
   - Đã đặt **PowerShell 7** làm profile mở mặc định.

---

## 🎮 2. Hướng dẫn Test và Sử dụng

Hãy mở **Windows Terminal** (hoặc mở tab PowerShell mới trong Windows Terminal) để trải nghiệm ngay:

| Tính năng | Cách dùng | Mô tả |
| :--- | :--- | :--- |
| **Gợi ý lệnh (Autosuggestion)** | Gõ vài ký tự đầu | Chữ mờ màu xám sẽ xuất hiện theo lịch sử, bấm phím **`Mũi tên phải (→)`** để điền toàn bộ lệnh. |
| **Tìm kiếm lịch sử lệnh (fzf)** | Bấm **`Ctrl + R`** | Tìm kiếm lệnh đã gõ trước đây bằng fuzzy search cực nhanh. |
| **Tìm kiếm file/thư mục** | Bấm **`Ctrl + F`** | Tìm kiếm file/thư mục ngay trong terminal. |
| **Nhảy thư mục siêu tốc (z)** | `z <tên_thư_mục>` | Ví dụ: `z setup` sẽ tự động nhảy vào `E:\setup`. |
| **Xem danh sách có icon màu** | `ll` hoặc `ls` | Hiển thị file kèm icon màu theo định dạng file. |
| **Viết tắt Git tiện lợi** | `g status`, `g diff` | Thay thế cho `git status`, `git diff`. |
| **Viết tắt Neovim** | `vim <file>` | Mở file bằng Neovim (`nvim`). |
| **Tự hoàn thành file sạch (Tab)** | `gcc m<Tab>` | Tự động điền `main.c` gọn gàng, không chèn thêm `.\` rườm rà vào đối số. |
| **Xóa ký tự nhanh** | **`Ctrl + D`** | Xóa ký tự tại vị trí con trỏ (Emacs binding). |

---

## 🛠️ 3. Script tự động cấu hình: `setup-powershell.ps1`

File script tự động cấu hình đặt tại:
`E:\setup\setup-powershell.ps1`

### Cách chạy script trên bất kỳ máy mới nào:
Mở PowerShell (hoặc PowerShell 7) và chạy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
powershell.exe -ExecutionPolicy Bypass -File E:\setup\setup-powershell.ps1
```

Script sẽ tự động chạy toàn bộ 7 bước:
1. Cho phép chạy script và bật TLS 1.2
2. Cài đặt các công cụ CLI qua Winget (PowerShell 7, Oh My Posh, Git, fzf, Neovim)
3. Cài đặt NuGet PackageProvider và tin cậy PSGallery
4. Cài đặt toàn bộ Module: `posh-git`, `Terminal-Icons`, `PSReadLine`, `PSFzf`, `z`
5. Copy cấu hình theme `takuya.omp.json` và `user_profile.ps1` vào `~/.config/powershell/`
6. Tự động liên kết `$PROFILE` cho cả **PowerShell 7** và **Windows PowerShell 5.1**
7. Tinh chỉnh Windows Terminal với `JetBrainsMono Nerd Font`, Acrylic và độ trong suốt 90%.
