<div align="center">
  <h1>CaptureImage</h1>
  <p>
    A lightweight native macOS screenshot utility for fast area capture,
    floating preview, and quick image actions.
  </p>

  <p>
    <a href="#">Website</a>
    ·
    <a href="#">Docs</a>
    ·
    <a href="#">Download</a>
    ·
    <a href="https://grie-portfolio.vercel.app">Portfolio</a>
  </p>

  <p>
    <img alt="Swift" src="https://img.shields.io/badge/Swift-6.0-orange">
    <img alt="Platform" src="https://img.shields.io/badge/platform-macOS-lightgrey">
    <img alt="UI" src="https://img.shields.io/badge/UI-AppKit-blue">
    <img alt="License" src="https://img.shields.io/badge/license-TBD-lightgrey">
  </p>

  <p>
    Tiếng Việt · English · Français · Latina
  </p>
</div>

---

## Giới Thiệu

CaptureImage là một ứng dụng chụp ảnh màn hình cho macOS, tập trung vào thao tác nhanh: chọn vùng cần chụp, lưu ảnh PNG, copy vào clipboard, và hiển thị danh sách ảnh vừa chụp ở cạnh màn hình.

Ứng dụng được thiết kế như một menu bar utility, không chiếm Dock, phù hợp cho workflow cần chụp nhiều ảnh liên tục khi làm việc, test UI, viết tài liệu, hoặc gửi minh họa nhanh.

## Tính Năng

- Chụp một vùng màn hình bằng phím tắt `Command + S`.
- Kéo chuột để chọn vùng cần chụp.
- Lưu ảnh PNG vào `~/Pictures/CaptureImage`.
- Copy ảnh đã chụp vào clipboard.
- Hiển thị floating capture shelf ở cạnh trái màn hình.
- Ảnh mới nhất nằm trên cùng danh sách.
- Danh sách ảnh có thể scroll khi có nhiều ảnh.
- Hiển thị `+N` khi còn ảnh nằm ngoài vùng đang nhìn thấy.
- Kéo ảnh từ shelf vào Finder hoặc folder để tạo bản PNG copy.
- Chuột phải vào ảnh để mở menu thao tác nhanh.
- Chụp lại vùng đã chọn gần nhất từ menu bar.
- Hỗ trợ đổi ngôn ngữ trong app: English, Tiếng Việt, Français, Latina.

## Menu Chuột Phải Trên Ảnh

Khi chuột phải vào ảnh trong capture shelf, app hỗ trợ:

- Phóng to ảnh trong cửa sổ preview.
- Copy ảnh vào clipboard.
- Mở file ảnh.
- Hiển thị file trong Finder.
- Xóa ảnh khỏi danh sách shelf.

## Cách Sử Dụng

1. Mở app `CaptureImage`.
2. Bấm icon `Capture` trên menu bar.
3. Chọn `Capture Area` hoặc dùng phím tắt `Command + S`.
4. Kéo chuột để chọn vùng màn hình cần chụp.
5. Sau khi chụp, ảnh sẽ xuất hiện trong capture shelf bên trái.
6. Scroll danh sách nếu có nhiều ảnh.
7. Chuột phải vào ảnh để chọn tool phù hợp.

## Phím Tắt

| Hành động | Phím tắt |
| --- | --- |
| Capture Area | `Command + S` |
| Repeat Last Area | `Command + R` |
| Open Save Folder | `Command + O` |
| Quit CaptureImage | `Command + Q` |

Bạn cũng có thể mở menu bar item và chọn `Show Shortcuts` để xem danh sách phím tắt trong app.

## Tech Stack

- Swift 6
- AppKit
- Swift Package Manager
- macOS 14+
- Carbon HotKey APIs
- CoreGraphics screen capture
- NSPanel, NSScrollView, NSMenu
- VIPER-style module structure

## Kiến Trúc Dự Án

```text
CaptureImage/
├── App/                 # AppDelegate và menu bar lifecycle
├── Helpers/             # Hotkey, screen capture, shelf, storage, clipboard
├── Modules/Capture/     # Capture View, Interactor, Presenter, Entity, Router
├── Utils/               # Theme, constants, localization, filename builder
├── Tests/               # Unit tests
├── scripts/             # Build scripts
└── Packaging/           # Info.plist cho app bundle
```

## Build Và Chạy

Trong project này, script chính để build bản mới và mở app là:

```bash
cd "/Users/tien/Documents/New MacOS Tool/CaptureImage"
scripts/build-and-run.sh
```

Script này sẽ:

- Build release app.
- Tắt bản `CaptureImage` cũ nếu đang chạy.
- Cập nhật shortcut `CaptureImage` trên Desktop trỏ tới bản mới.
- Mở app mới sau khi build xong.

## Build App Bundle

Nếu chỉ muốn build app bundle mà chưa mở app:

```bash
cd "/Users/tien/Documents/New MacOS Tool/CaptureImage"
scripts/build-app.sh
```

App sau khi build nằm tại:

```text
CaptureImage/.build/CaptureImage.app
```

## Quyền Trên macOS

macOS có thể yêu cầu quyền Screen Recording khi app chụp nội dung từ màn hình hoặc cửa sổ app khác.

Nếu capture không hoạt động, mở:

```text
System Settings > Privacy & Security > Screen Recording
```

Sau đó bật quyền cho `CaptureImage` và mở lại app.

## Ghi Chú

`Command + S` được dùng cho MVP vì app ưu tiên thao tác chụp nhanh một bước. Phím tắt này có thể trùng với lệnh Save của app đang focus.

## Portfolio

Created by Grie:

https://grie-portfolio.vercel.app

## License

TBD
