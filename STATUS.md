# XenTimer — Project Status (Handoff)

> Snapshot taken **2026-05-28**. Pick up here on another Mac in Claude Code.

Full plan: [`PLAN.md`](PLAN.md). Original requirement brief: [`docs/requirement.md`](docs/requirement.md).

---

## Where we are

| Phase | Status | Notes |
|---|---|---|
| 1. Design mockups | ✅ Done | 7 HTML/CSS mockups + shared `styles.css` + `design-spec.md`. Open `design/index.html` in a browser. |
| 2. Xcode project setup | ✅ Done | `project.yml` (xcodegen), `Info.plist`, `XenTimer.entitlements`, Asset Catalog with 17 color sets (light + dark). |
| 3. Models & Services | ✅ Done | All SwiftData models + services written. |
| 4. Views | ✅ Done | All 8 views implemented per mockups (~4,500 LOC of Swift). |
| 5. Polish & verify | ⏳ Pending Xcode | Needs Xcode install for build / run / end-to-end verification. |

**~26 Swift files, ~4,500 LOC.** Functionally MVP-complete pending a real build.

---

## What's implemented

### Foundation
- `Theme` — palette / typography / spacing / motion tokens — `XenTimer/Utilities/Theme.swift`
- `TimeFormatting` — clock/duration/range helpers — `XenTimer/Utilities/TimeFormatting.swift`

### Models (SwiftData)
- `FocusSession`, `BreathingSession`, `BreathingPattern`, `AppSettings`
- `SeedData` — seeds 4 default breathing patterns (Box, Relax, 4-7-8, Coherent) + AppSettings row on first launch

### Services
- `TimerService` — focus / break / breathing countdown with pause/resume/stop/skip + `finishedTick` event
- `BreathingController` — phase state machine (inhale → hold → exhale → rest) + cycle tracking
- `AudioService` — bell + voice (AVSpeechSynthesizer) + ambient hook + fade-out + per-phase guide
- `NotificationService` — UNUserNotificationCenter wiring for all 5 event types
- `DailyAggregator` — query + aggregate today's stats from SwiftData
- `MarkdownExporter` — full markdown rendering per spec + folder picker + security-scoped bookmark write
- `FullScreenPresenter` — coordinates open/close of full-screen window across views

### App scenes
- `XenTimerApp` — WindowGroup (main), MenuBarExtra, Window (full-screen breathing), Settings scene + command menu

### Views (all per mockups)
| View | Mockup | What it does |
|---|---|---|
| `MainWindowView` | shell | Top toolbar with mode tabs + page switcher (Timer/Dashboard/History/Settings icons) |
| `FocusTabView` | 01 | Duration presets + custom stepper, tag/sound pickers, volume slider, Start button |
| `BreathingTabView` | 02 | Pattern preset grid, custom rhythm card, duration/sound/guide pickers, Start button |
| `ActiveSessionView` | 01 (variant) | Large clock + progress, Pause/Stop/Skip; commits session on finish; shows rating sheet |
| `FocusCompleteSheet` | — | Rating (1–10 burgundy dots), reflection note, "Skip break" / "Save & start break" CTA |
| `FullScreenBreathingView` | 04 | Animated breathing circle (scale 0.55↔1.0), cross-fading text guide, cycle counter, ESC to exit |
| `DashboardView` | 05 | Hero stats + sparkline + 10-dot rating + breathing/tags/streak + today's timeline |
| `HistoryView` | 06 | Filter bar (search/type/range) + grouped-by-day list + detail pane + per-day export |
| `SettingsView` | 07 | Sidebar nav with 6 sections; General + Markdown export + Audio fully wired to AppSettings |
| `MenuBarLabelView` + `MenuBarContentView` | 03 | Menu bar item with mode-tinted dot, dropdown with progress + controls + today summary |

### Shared UI components (`Views/Components/ViewComponents.swift`)
`ChipView`, `CardContainer`, `ModeTabsView`, `IconButton`, `PresetSegment`, `FieldLabel`, `PrimaryActionButton`, `ModeBanner`

---

## What's left (Phase 5 — Polish + Verify)

1. **Install Xcode + xcodegen** (see next section) — required before anything below
2. **Run `xcodegen generate` + open project** — first build will surface any remaining compile errors
3. **Build + run end-to-end** through the verification checklist in [`PLAN.md`](PLAN.md) (section "Phase 5"):
   - Start focus → menu bar countdown updates → complete → rating sheet → save
   - Start standalone breathing → full-screen breathing window with animation
   - Pomodoro break flow (focus → rating → "Save & start break" → full-screen breath)
   - Dashboard reflects today's data
   - History shows past sessions with detail
   - Settings → choose markdown folder → "Export today now" → verify file opens correctly in Obsidian
4. **App Icon** — design + drop into `Assets.xcassets/AppIcon.appiconset/` (currently empty)
5. **Ambient sound files** — `AudioService.playAmbient` is a no-op until `.m4a` files are bundled in `Resources/Sounds/`. The voice and bell paths already work via system audio.
6. **First-run experience** — currently the user has to visit Settings to set the Markdown export folder. Optional: prompt on first launch.

### Possible polish items (not in MVP scope)
- Custom-pattern save flow (currently the BreathingTab creates a transient `Custom` pattern but doesn't persist it)
- Per-tab keyboard shortcuts in CommandMenu (some are wired but not all)
- Settings Notifications tab — currently only has the toggle; could add per-event opt-ins
- Streak goal threshold (currently "any completed focus session" counts as a day)

---

## Setup on the new Mac

```bash
# 1. Clone
git clone <your-repo-url> XenTimer
cd XenTimer

# 2. Install Xcode 15+ from Mac App Store, then accept license
sudo xcodebuild -license accept

# 3. Install xcodegen
brew install xcodegen

# 4. Generate Xcode project
xcodegen generate

# 5. Open in Xcode
open XenTimer.xcodeproj
```

In Xcode, select the **XenTimer** scheme and press **⌘R** to build & run.

Whenever you add / remove Swift files, re-run `xcodegen generate`.

---

## Recommended pickup workflow (Claude Code on the new Mac)

Open Claude Code in the project folder and say:

> *"อ่าน STATUS.md กับ PLAN.md ก่อน แล้วช่วย Phase 5 — ทำ end-to-end verification หลังจาก xcodegen generate"*

Or in English:

> *"Read STATUS.md and PLAN.md, then take Phase 5 — run xcodegen, open in Xcode, fix any compile errors, then walk through the verification checklist."*

Claude Code will:
- See all source files
- Use the design mockups as reference for any visual tweaks
- Run `xcodegen generate` and `xcodebuild -scheme XenTimer build` to verify

---

## Open decisions (carry-over from PLAN.md)

| # | Decision | Current state |
|---|---|---|
| 1 | Bundle ID + App name | `com.tety.xentimer` (in `project.yml`) |
| 2 | Markdown export folder | User picks via Settings → Markdown tab (no hard-coded default) |
| 3 | Audio source — sound files? | None bundled; AudioService.playAmbient is a no-op for now |
| 4 | Voice guidance | AVSpeechSynthesizer (US English, rate 0.42) |
| 5 | App Icon | Placeholder (empty appiconset) |
| 6 | License / GitHub repo public? | Up to you — repo is private-friendly |

---

## Project layout

```
XenTimer/                                 ← repo root
├── PLAN.md
├── STATUS.md                             ← this file
├── README.md
├── project.yml                           ← xcodegen project definition
├── .gitignore
├── docs/
│   └── requirement.md                    ← original requirement brief
├── design/                               ← Phase 1 mockups + spec (open index.html)
│   ├── index.html
│   ├── design-spec.md
│   ├── styles.css
│   └── 01-…07-…html
├── XenTimer/                             ← Swift sources
│   ├── XenTimerApp.swift                 (@main, scenes, command menu)
│   ├── Models/
│   ├── Services/
│   ├── Views/
│   │   ├── Components/ViewComponents.swift
│   │   ├── Main/                         (MainWindow + FocusTab + BreathingTab + ActiveSession + FocusCompleteSheet)
│   │   ├── Breathing/FullScreenBreathingView.swift
│   │   ├── MenuBar/MenuBarViews.swift
│   │   ├── Dashboard/DashboardView.swift
│   │   ├── History/HistoryView.swift
│   │   └── Settings/SettingsView.swift
│   ├── Utilities/                        (Theme + TimeFormatting)
│   └── Resources/
│       ├── Info.plist
│       ├── XenTimer.entitlements         (sandbox + user-selected file r/w + bookmarks)
│       └── Assets.xcassets/              (17 color sets + AppIcon set [empty])
└── XenTimerTests/                        (empty)
```
