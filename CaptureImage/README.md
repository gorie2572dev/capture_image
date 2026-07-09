# CaptureImage

CaptureImage is a lightweight macOS screenshot utility focused on fast area capture.

The project uses a VIPER-style structure:

- `App`: application delegate and menu bar lifecycle
- `Modules/Capture`: Capture View, Interactor, Presenter, Entity, Router, Builder
- `Helpers`: reusable app operations such as hotkeys, clipboard, screen capture, file saving
- `Utils`: constants, theme tokens, filename formatting, low-level extensions

## MVP

- Global hotkey: `Command + S`
- Drag to select a screen area
- Save PNG to `~/Pictures/CaptureImage`
- Copy the captured image to the clipboard
- Show a floating capture shelf after capture
- Add newest captures at the top of the shelf
- Drag a capture card into Finder/folders to save a PNG copy there
- Show a `+N` overflow pill when the shelf reaches the screen height
- Repeat the last capture area from the menu bar

`Command + S` is intentionally used for the MVP because CaptureImage is designed around one-step area capture. Be aware this can conflict with Save in the currently focused app.

## Shortcuts

Open the CaptureImage menu bar item and choose `Show Shortcuts` to see all active project shortcuts in a two-column action/shortcut menu.

## Run

```bash
swift run CaptureImage
```

The app appears in the macOS menu bar as `Capture`.

## Permissions

macOS may request Screen Recording permission when capturing other app windows.

## Build

```bash
swift build -c release
```

## Build App Bundle

```bash
./scripts/build-app.sh
open .build/CaptureImage.app
```

The generated `.app` uses `LSUIElement=true`, so it behaves like a menu bar utility and does not show a Dock icon.
