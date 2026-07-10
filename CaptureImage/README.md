<div align="center">
  <img src="../docs/assets/captureimage-icon.svg" alt="CaptureImage icon" width="120" height="120">

  <h1>CaptureImage</h1>

  <p>
    A lightweight native macOS screenshot utility for fast area capture,
    floating previews, and quick image actions.
  </p>

  <p>
    <a href="#">Website</a>
    ·
    <a href="#">Docs</a>
    ·
    <a href="https://github.com/gorie2572dev/capture_image/releases">Download</a>
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
    English · Vietnamese · French · Latin
  </p>
</div>

---

## Overview

CaptureImage is a native macOS screenshot utility focused on speed. It lets you capture a selected screen area, save it as PNG, copy it to the clipboard, and keep recent captures in a floating shelf on the side of the screen.

The app is designed as a menu bar utility, so it stays out of the Dock and fits workflows where you need to capture multiple screenshots while testing UI, writing documentation, or sharing visual notes quickly.

## Features

- Capture a selected screen area with `Command + S`.
- Drag to select the exact area you want to capture.
- Save PNG files to `~/Pictures/CaptureImage`.
- Copy captured images to the clipboard.
- Show recent captures in a floating shelf on the left side of the screen.
- Keep newest captures at the top of the shelf.
- Scroll the capture shelf when many images are available.
- Show a `+N` indicator when more images are outside the visible area.
- Drag a capture card into Finder or folders to create a PNG copy.
- Right-click an image to open quick actions.
- Repeat the last captured area from the menu bar.
- Switch the app language between English, Vietnamese, French, and Latin.
- Choose solid, gradient, or custom backgrounds from the menu bar.

## Install with Homebrew

CaptureImage is distributed as an Apple Silicon macOS cask. Install Homebrew first, then run:

```bash
brew tap gorie2572dev/capture_image https://github.com/gorie2572dev/capture_image
brew trust gorie2572dev/capture_image
brew install --cask captureimage
```

Open the app from Applications or run:

```bash
open -a CaptureImage
```

Update and remove it with:

```bash
brew update
brew upgrade --cask captureimage
brew uninstall --cask captureimage
```

The app is currently unsigned. macOS may ask you to confirm the first launch. Open it once from Finder with Control-click > Open, then grant Screen Recording permission when prompted.

## Image Context Menu

Right-click any image in the capture shelf to:

- Open a larger image preview.
- Copy the image to the clipboard.
- Open the image file.
- Reveal the image in Finder.
- Remove the image from the shelf.

## Usage

1. Open `CaptureImage`.
2. Click the `Capture` menu bar item.
3. Choose `Capture Area` or press `Command + S`.
4. Drag to select the screen area.
5. Release the mouse to capture.
6. Use the floating shelf to review, scroll, drag, or right-click recent captures.
7. Open `Appearance` from the menu bar to change the app background.

## Shortcuts

| Action | Shortcut |
| --- | --- |
| Capture Area | `Command + S` |
| Repeat Last Area | `Command + R` |
| Open Save Folder | `Command + O` |
| Quit CaptureImage | `Command + Q` |

You can also open the menu bar item and choose `Show Shortcuts` to view the shortcut list in the app.

## Tech Stack

- Swift 6
- AppKit
- Swift Package Manager
- macOS 14+
- Carbon HotKey APIs
- CoreGraphics screen capture
- `NSPanel`, `NSScrollView`, `NSMenu`
- VIPER-style module structure

## Project Structure

```text
CaptureImage/
├── App/                 # AppDelegate and menu bar lifecycle
├── Helpers/             # Hotkeys, screen capture, shelf, storage, clipboard
├── Modules/Capture/     # Capture View, Interactor, Presenter, Entity, Router
├── Utils/               # Theme, constants, localization, filename builder
├── Tests/               # Unit tests
├── scripts/             # Build scripts
└── Packaging/           # Info.plist for the app bundle
```

## Build And Run

The recommended local workflow is:

```bash
cd "/Users/tien/Documents/New MacOS Tool/CaptureImage"
scripts/build-and-run.sh
```

This script will:

- Build the release app.
- Stop the old `CaptureImage` process if it is running.
- Update the Desktop `CaptureImage` shortcut to point to the latest build.
- Open the new app after the build completes.

## Build App Bundle Only

To build the app bundle without opening it:

```bash
cd "/Users/tien/Documents/New MacOS Tool/CaptureImage"
scripts/build-app.sh
```

The generated app is located at:

```text
CaptureImage/.build/CaptureImage.app
```

## Release A New Version

1. Update `CFBundleShortVersionString` and the cask version.
2. Commit the release, then push a matching `v<version>` tag.
3. GitHub Actions builds the Apple Silicon archive and publishes the GitHub Release.
4. Download the published archive, calculate its SHA-256, and update `Casks/captureimage.rb` before announcing the release.

## macOS Permissions

macOS may require Screen Recording permission before the app can capture content from the screen or from other app windows.

If capture does not work, open:

```text
System Settings > Privacy & Security > Screen Recording
```

Then enable permission for `CaptureImage` and restart the app.

## Notes

`Command + S` is used for the MVP because CaptureImage is optimized for one-step capture. This shortcut may conflict with the Save command in the currently focused app.

## Portfolio

Created by Grie:

https://grie-portfolio.vercel.app

## License

TBD
