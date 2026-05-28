# XenTimer — Project Setup & Build Plan

## Context

XenTimer คือ macOS productivity app แนว **Pomodoro + Guided Breathing** — "Productivity Through Recovery" ตาม requirement ใน [MindNote/XenTimer.md](MindNote/XenTimer.md)

**สถานะปัจจุบัน:** `/Users/dhammasak/Code/XenTimer/` ว่างเปล่า — สร้างจากศูนย์

**Decision ที่ยืนยันแล้ว:**
- **Design First** — ใช้ Claude Design ออกแบบ interface ก่อนเขียน code
- **Tech Stack** — Swift + SwiftUI native (macOS 14+)
- **Scope** — MVP เต็มตามเอกสาร section 13.1
- **Storage** — SwiftData (รองรับ iCloud sync ในอนาคต)

**ผลลัพธ์ที่คาดหวัง:** app macOS ที่ user เริ่ม focus session → breathing break → ดู dashboard → export markdown เปิดใน Obsidian ได้ครบ end-to-end

---

## Phase 1 — Design (Claude Design Mockups)

**Goal:** ได้ visual direction ครบทุก surface ก่อนเริ่ม code เพื่อ lock down look & feel ของ "calm, premium, minimal"

ออกแบบเป็น HTML/CSS mockups (renderable ใน browser, iterate ได้เร็ว) แล้วค่อย translate เป็น SwiftUI

**Mockups ที่ต้องสร้าง:**

| # | Surface | จุดที่ต้องตัดสินใจ |
|---|---------|-------------------|
| 1 | Main Window — Focus mode tab | Layout เลือก duration / tag / sound, ปุ่ม Start, แยก Focus กับ Breathing ชัด |
| 2 | Main Window — Breathing mode tab | Quick presets (Calm/Box/Relax), custom session |
| 3 | Menu Bar Timer | Text format `XenTimer · Focus 18:42`, dropdown menu |
| 4 | Full-screen Breathing — 4 phases | Inhale/Hold/Exhale/Rest — breathing circle expand/contract, text guide |
| 5 | Dashboard (Today) | Sessions count, total time, average rating, most used tag/pattern |
| 6 | History (Daily list) | List ของ session, click ดู detail |
| 7 | Settings | General / Notification / Markdown export folder / Audio |
| 8 | Color palette + typography spec | Deep navy / warm white / soft grey / soft green / muted burgundy |

**Deliverable:** Folder `design/` ใน project root มี HTML mockups + design spec markdown

**Checkpoint:** review mockup กับ user → approve ก่อนเข้า Phase 2

---

## Phase 2 — Xcode Project Setup

สร้าง Xcode project structure:

```
/Users/dhammasak/Code/XenTimer/
├── XenTimer.xcodeproj/
├── XenTimer/                   # main app target
│   ├── XenTimerApp.swift       # @main entry
│   ├── Models/                 # SwiftData models
│   ├── Services/               # TimerService, AudioService, MarkdownExporter
│   ├── Views/
│   │   ├── Main/               # MainWindowView, FocusTabView, BreathingTabView
│   │   ├── MenuBar/            # MenuBarTimerView
│   │   ├── Breathing/          # FullScreenBreathingView, BreathingCircle
│   │   ├── Dashboard/          # DashboardView
│   │   ├── History/            # HistoryView
│   │   └── Settings/           # SettingsView
│   ├── Resources/
│   │   ├── Sounds/             # ambient + voice + bell files
│   │   └── Assets.xcassets     # color palette, icons
│   └── Utilities/              # extensions, helpers
├── XenTimerTests/
├── design/                     # Phase 1 mockups
└── README.md
```

**Setup tasks:**
- Xcode project: macOS 14.0+ deployment target (สำหรับ SwiftData)
- SwiftUI App lifecycle (`@main struct XenTimerApp: App`)
- `MenuBarExtra` API สำหรับ menu bar timer
- `App.commands` + `Settings` scene
- Bundle ID: `com.tety.xentimer` (หรือ user ระบุ)
- Initialize git repo
- `.gitignore` standard Xcode

---

## Phase 3 — Models & Services

### SwiftData Models

```swift
@Model FocusSession {
    id: UUID, startTime: Date, endTime: Date,
    plannedDuration: TimeInterval, actualDuration: TimeInterval,
    tag: String?, backgroundSound: String?,
    rating: Int?, note: String?, completed: Bool
}

@Model BreathingSession {
    id: UUID, startTime: Date, endTime: Date,
    duration: TimeInterval, pattern: BreathingPattern,
    ambientSound: String?, reflectionNote: String?,
    sessionType: SessionType  // .pomodoroBreak | .standalone
}

@Model BreathingPattern {
    name: String, inhale: Int, holdAfterInhale: Int,
    exhale: Int, holdAfterExhale: Int, isCustom: Bool
}

@Model AppSettings {
    defaultFocusDuration, defaultBreakDuration,
    defaultBreathingPatternID, defaultFocusSound, defaultBreakSound,
    notificationsEnabled, menuBarDisplay,
    markdownExportFolder: URL?, autoExportEnabled,
    defaultStandaloneBreathingDuration
}
```

Seed default patterns: Box (4-4-4-4), Relax (4-0-6-0), 4-7-8 (4-7-8-0), Coherent (5-0-5-0)

### Services

| Service | Responsibility |
|---------|----------------|
| `TimerService` | Combine/Observable countdown สำหรับ focus + break, publish remaining time, handle pause/resume/complete |
| `BreathingController` | Drive animation state machine (inhale → hold → exhale → restHold), publish current phase + cycle count |
| `AudioService` | AVFoundation playback ของ ambient + voice + bell, fade in/out, volume control แยกจาก system |
| `NotificationService` | UNUserNotificationCenter requests + dispatch สำหรับ session events |
| `MarkdownExporter` | Build daily markdown ตาม template ใน section 9.4, write file ไป export folder |
| `MenuBarController` | Update menu bar title แบบ live ตาม TimerService state |

---

## Phase 4 — Views Implementation

ลำดับการสร้าง (เพื่อให้ทดสอบเชิงปฏิสัมพันธ์ได้ตลอด):

1. **MainWindowView + FocusTabView** — set duration/tag/sound, Start button → ดึง TimerService ทำงาน
2. **MenuBarExtra** — แสดง running session, แสดง main window, quick controls
3. **FullScreenBreathingView + BreathingCircle** — animation จริง, text guide, run จาก preset
4. **BreathingTabView (Standalone)** — เลือก pattern, duration, sound → เปิด full-screen
5. **Focus complete flow** — auto suggest breathing break, rating + note prompt
6. **DashboardView** — daily summary จาก SwiftData query
7. **HistoryView** — list ของ session, detail sheet
8. **SettingsView** — bind ทุก preference ลง AppSettings model
9. **Markdown export** — manual export button + auto-export toggle

---

## Phase 5 — Polish & Verification

- Notification flow ทั้ง 5 event ตาม section 12.2
- Audio fade in/out, voice/bell guide modes
- Color palette + typography ตาม design spec
- Empty states + first-run experience
- App icon

**Verification (end-to-end):**
1. Run app จาก Xcode
2. Start focus session 1 นาที (เพื่อทดสอบเร็ว) → ดู menu bar แสดง countdown
3. Complete → rating prompt ขึ้น → ใส่ rating + note
4. กด suggested breathing break → full-screen breathing พร้อม animation ตรงตาม pattern
5. กลับมา → standalone breathing session แยกต่างหาก
6. เปิด Dashboard → ตัวเลขถูก
7. Export Markdown → ไฟล์ออกที่ folder ที่ตั้ง → เปิดใน Obsidian vault `/Users/dhammasak/Documents/Obsidian/Tety_Obsidian/` แสดงผลถูก
8. Restart app → ข้อมูลยังอยู่

---

## เปิดประเด็นที่ต้องตัดสินใจระหว่างทาง

ไม่ block การเริ่ม Phase 1 แต่ต้อง resolve ก่อน Phase 3–4:

| # | ประเด็น | Default ที่จะใช้ถ้าไม่ระบุ |
|---|---------|---------------------------|
| 1 | Bundle ID + App name display | `com.tety.xentimer` / "XenTimer" |
| 2 | Markdown export folder default | `/Users/dhammasak/Documents/Obsidian/Tety_Obsidian/Productivity/XenTimer/Daily Reports/` |
| 3 | Audio source — มี sound file พร้อมไหม? | เริ่มด้วย system sound + silence — เพิ่ม sound library Phase 5 |
| 4 | Voice guidance ใช้ AVSpeechSynthesizer หรือ recorded? | AVSpeechSynthesizer (built-in) ใน MVP |
| 5 | App Icon | Placeholder ก่อน — ออกแบบจริงตอน Phase 5 |
| 6 | License / repository public? | Local only, ยังไม่ push GitHub |

---

## สิ่งที่ **ไม่** อยู่ใน scope รอบนี้

ตาม section 14 (Future Features) — ตัด out:
- Weekly/Monthly report
- AI reflection
- Calendar integration
- Apple Health
- Custom audio import
- iPhone companion
- iCloud sync (architecture เตรียมรองรับ แต่ไม่ implement)
- Streak system, Focus goal
- Multi-language (English only ใน MVP — Thai เลื่อนไปทีหลัง)
