# CaptureImage Project Plan

## Product Direction

CaptureImage helps Mac users capture custom screen areas quickly, then automatically saves, copies, names, and organizes the result.

## Architecture

The app follows VIPER-style boundaries for the initial Capture module:

| Layer | Responsibility |
| --- | --- |
| View | Overlay selection UI and capture shelf drawing |
| Interactor | Capture use case orchestration |
| Presenter | User intent, hotkey actions, repeat-last-area state |
| Entity | Capture request/result data |
| Router | Overlay presentation, capture shelf presentation, folder opening, alerts |
| Builder | Module dependency wiring |

Repeated operations live outside the module:

| Folder | Responsibility |
| --- | --- |
| `Helpers` | Clipboard, hotkey, frontmost app, screen image capture, file saving |
| `Utils` | Theme tokens, constants, filename builder, small extensions |

## Menu Bar Behavior

- The app installs an `NSStatusItem` with a camera viewfinder icon and `Capture` label.
- `Command + S` starts area capture from any app.
- App bundle packaging uses `LSUIElement=true` so CaptureImage behaves like a menu bar utility.

## Capture Shelf Behavior

- Every successful capture creates a draggable thumbnail card.
- New cards are inserted at the top of the shelf.
- Dragging a card into Finder or a folder writes a PNG copy using `NSFilePromiseProvider`.
- When available screen height is exhausted, the shelf keeps the newest visible cards and shows a bottom `+N` overflow indicator for hidden older captures.

## Theme Palette

| Token | Color |
| --- | --- |
| Background | `#FAF8F3` |
| Sidebar | `#F3F1EA` |
| Surface | `#FFFFFF` |
| Border | `#E5E0D8` |
| Text primary | `#34322F` |
| Text secondary | `#77736A` |
| Accent | `#D97757` |
| Accent soft | `#F3DDD3` |
| Dark status | `#2F302D` |
| Alert dot | `#2D8CDE` |

## Roadmap

| Phase | Scope |
| --- | --- |
| 1 | Menu bar app, global hotkey, area overlay, save PNG, copy clipboard |
| 2 | Capture shelf actions, repeat last area, preferences |
| 3 | Annotation tools, blur/redaction, OCR text copy |
| 4 | Screenshot inbox, tags, search, cleanup advisor |
| 5 | DMG packaging, GitHub Release, Homebrew Cask |

## Sub Agents

| Agent | Responsibility |
| --- | --- |
| Product Planner Agent | MVP priority and user flows |
| macOS Native Agent | Swift/AppKit integration, menu bar, hotkeys |
| Screen Capture Agent | Overlay, multi-monitor, Retina, permissions |
| UX/UI Agent | Visual system based on the warm Claude-like palette |
| OCR & Privacy Agent | Local OCR, sensitive text detection, blur |
| File Organizer Agent | Naming, folders, search, tags |
| QA Agent | Permission, hotkey, fullscreen, multi-display testing |
| Release Agent | `.app`, `.dmg`, GitHub Release, Homebrew Cask |
