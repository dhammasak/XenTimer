# XenTimer

> Work with rhythm. Rest with breath.

A macOS productivity timer that combines deep focus sessions with guided breathing breaks. Built with **SwiftUI** and **SwiftData**, targeting **macOS 14+**.

---

## Project layout

```
XenTimer/
├── design/                 # Phase 1 HTML/CSS mockups + design spec
├── project.yml             # xcodegen project definition
├── XenTimer/
│   ├── XenTimerApp.swift   # @main entry point
│   ├── Models/             # SwiftData models
│   ├── Services/           # TimerService, AudioService, MarkdownExporter, …
│   ├── Views/
│   │   ├── Main/           # MainWindowView, FocusTabView, BreathingTabView
│   │   ├── MenuBar/        # MenuBarTimerView
│   │   ├── Breathing/      # FullScreenBreathingView, BreathingCircle
│   │   ├── Dashboard/      # DashboardView
│   │   ├── History/        # HistoryView
│   │   ├── Settings/       # SettingsView
│   │   └── Components/     # Shared UI components
│   ├── Utilities/
│   └── Resources/
│       ├── Assets.xcassets # Color palette, app icon
│       ├── Info.plist
│       └── XenTimer.entitlements
└── XenTimerTests/
```

---

## First-time setup

XenTimer is checked in as **source code + xcodegen definition**. The `.xcodeproj` is generated locally — not committed.

### 1. Install Xcode

Download Xcode 15+ from the Mac App Store (or developer.apple.com). Then accept the license:

```bash
sudo xcodebuild -license accept
```

### 2. Install xcodegen

```bash
brew install xcodegen
```

### 3. Generate the Xcode project

From the repo root:

```bash
xcodegen generate
```

This creates `XenTimer.xcodeproj` from `project.yml`.

### 4. Open and run

```bash
open XenTimer.xcodeproj
```

In Xcode, select the **XenTimer** scheme and press **⌘R**.

---

## Daily workflow

When you add or remove source files, re-run `xcodegen generate` to refresh the project.

```bash
xcodegen generate && open XenTimer.xcodeproj
```

xcodegen reads file names from disk — you do **not** need to manually add files to the project.

---

## Architecture

- **SwiftUI App lifecycle** — `@main XenTimerApp` declares `WindowGroup`, `MenuBarExtra`, and `Settings` scenes.
- **SwiftData** — persistent store for `FocusSession`, `BreathingSession`, `BreathingPattern`, `AppSettings`. Designed to support iCloud sync in a future version.
- **Observable services** — `TimerService`, `BreathingController`, `AudioService`, `NotificationService` are `@Observable` classes injected via `@Environment`.
- **MarkdownExporter** — writes daily reports to a user-chosen folder (security-scoped bookmark) using the template from the design spec.

See `design/design-spec.md` for visual language. See `MindNote/XenTimer.md` (in the Obsidian vault) for the original requirement brief.

---

## Status

See [`STATUS.md`](STATUS.md) for a detailed handoff snapshot — what's built, what's stubbed, what's left. The original implementation plan lives in [`PLAN.md`](PLAN.md).

| Phase | Status |
|---|---|
| 1. Design mockups | ✅ Complete — see `design/index.html` |
| 2. Project setup | ✅ Complete |
| 3. Models & services | ✅ Complete |
| 4. Views | 🚧 Partial — `FocusTabView` real; others are TODO stubs with mockup references |
| 5. Polish & verify | — Awaiting Xcode install for end-to-end run |
