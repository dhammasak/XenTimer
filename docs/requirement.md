# XenTimer — Requirement Brief

## 1. Project Overview

**XenTimer** is a macOS productivity application based on the Pomodoro concept, combined with guided breathing breaks.

The main idea is:

> **Productivity Through Recovery**
> Users work deeply during focus sessions, then recover intentionally through guided breathing breaks before starting the next cycle.

XenTimer is not just a timer. It is a rhythm-based productivity tool designed to help working professionals improve focus, manage energy, and build a sustainable daily productivity habit.

In addition to Pomodoro-based workflows, XenTimer should also support standalone guided breathing sessions for users who want to practice breathing, relaxation, meditation, or recovery independently without starting a focus session first.

---

## 2. Target Users

The primary users are:

* Working professionals
* Managers and executives
* Knowledge workers
* Students or learners who need deep focus
* People who want to improve productivity through structured work and recovery cycles
* Users who want a simple guided breathing and recovery tool without using Pomodoro sessions

The app should feel calm, professional, minimal, and premium.

---

## 3. Core Concept

XenTimer has two primary usage modes:

```text
Focus Session
↓
Guided Breathing Break
↓
Repeat Cycle
↓
Daily History & Markdown Report
```

and

```text
Standalone Guided Breathing Session
↓
Relaxation / Recovery / Meditation
↓
Optional Session History
```

The app should help users answer three simple questions each day:

1. How many focus sessions did I complete?
2. How well did I focus?
3. Did I recover properly between work sessions?

For standalone breathing users, the app should also support intentional recovery and breathing practice without requiring productivity tracking.

---

# 4. Main Application Modes

XenTimer should support four main user interfaces:

## 4.1 Main Window

The main window is used for:

* Setting up focus sessions
* Choosing session duration
* Choosing music or background sound
* Starting, pausing, stopping, or completing a session
* Starting standalone guided breathing sessions
* Viewing daily progress
* Accessing history and settings

The main window should clearly separate:

* Focus Session Mode
* Standalone Breathing Mode

so users can immediately choose their intended activity.

## 4.2 Menu Bar Timer

The macOS menu bar timer should show:

* Current session status
* Remaining time
* Start / pause / stop shortcut
* Quick access to the main window

Example display:

```text
XenTimer · Focus 18:42
```

or

```text
XenTimer · Break 03:10
```

or

```text
XenTimer · Breathing 07:20
```

## 4.3 Full-screen Breathing Mode

The full-screen breathing mode is used during guided breathing sessions.

It should provide a calm, distraction-free guided breathing experience with:

* Animated breathing circle
* Text guidance
* Optional sound guidance
* Optional music or ambient sound

This mode should work for both:

* Pomodoro recovery breaks
* Standalone breathing sessions

## 4.4 Standalone Guided Breathing Mode

Users should be able to launch guided breathing directly without starting a Pomodoro session first.

This mode should support:

* Quick breathing session start
* Breathing pattern selection
* Custom duration
* Full-screen breathing experience
* Optional ambient sound
* Optional session history tracking

Suggested quick actions:

```text
Start Breathing
Quick Calm Session
Box Breathing
Relax Breathing
Custom Session
```

---

# 5. Focus Session Requirements

## 5.1 Focus Duration

Users should be able to choose a focus duration.

Default presets:

| Preset           | Duration     |
| ---------------- | ------------ |
| Short Focus      | 15 minutes   |
| Classic Pomodoro | 25 minutes   |
| Deep Work        | 45 minutes   |
| Custom           | User-defined |

Users should be able to customise the duration in minutes.

---

## 5.2 Focus Session Controls

The focus session should support:

* Start
* Pause
* Resume
* Stop
* Complete session
* Skip session

When a focus session is completed, the app should automatically suggest starting a guided breathing break.

---

## 5.3 Focus Session Label

Users should be able to name or tag each session.

Example labels:

* Writing
* Reading
* Strategy
* Study
* Planning
* Deep Work
* Admin
* Meeting Preparation
* Custom tag

This helps make the history more meaningful.

---

## 5.4 Focus Music / Background Sound

Users should be able to select background sound during focus sessions.

Suggested sound categories:

| Category | Examples                             |
| -------- | ------------------------------------ |
| Nature   | Rain, forest, stream, ocean          |
| Ambient  | Soft background atmosphere           |
| Noise    | White noise, brown noise, pink noise |
| Music    | Lo-fi, instrumental, meditation      |
| Silence  | No sound                             |

Users should be able to control the volume independently from system volume where possible.

---

# 6. Guided Breathing Break Requirements

## 6.1 Break Duration

Users should be able to choose a break duration.

Default presets:

| Preset         | Duration     |
| -------------- | ------------ |
| Short Break    | 3 minutes    |
| Standard Break | 5 minutes    |
| Long Break     | 10 minutes   |
| Custom         | User-defined |

Standalone breathing sessions should also support longer durations such as:

| Preset                  | Duration     |
| ----------------------- | ------------ |
| Meditation Session      | 15 minutes   |
| Deep Relaxation         | 20 minutes   |
| Custom Extended Session | User-defined |

---

## 6.2 Breathing Pattern

The app should include default breathing patterns commonly used for relaxation, meditation, and recovery.

Suggested default patterns:

| Pattern            | Inhale       | Hold         | Exhale       | Hold After Exhale | Purpose          |
| ------------------ | ------------ | ------------ | ------------ | ----------------- | ---------------- |
| Box Breathing      | 4 sec        | 4 sec        | 4 sec        | 4 sec             | Calm and focus   |
| Relax Breathing    | 4 sec        | 0 sec        | 6 sec        | 0 sec             | Relaxation       |
| 4-7-8 Breathing    | 4 sec        | 7 sec        | 8 sec        | 0 sec             | Stress reduction |
| Coherent Breathing | 5 sec        | 0 sec        | 5 sec        | 0 sec             | Balanced rhythm  |
| Custom             | User-defined | User-defined | User-defined | User-defined      | Personal use     |

Users should be able to customise:

* Inhale duration
* Hold after inhale duration
* Exhale duration
* Hold after exhale duration
* Number of cycles
* Total break duration

Users should also be able to save custom breathing patterns.

---

## 6.3 Guided Breathing Animation

The guided breathing animation should use a breathing circle.

Animation behaviour:

```text
Inhale
→ Circle expands smoothly

Hold
→ Circle remains at maximum size

Exhale
→ Circle contracts smoothly

Hold After Exhale
→ Circle remains at minimum size
```

The animation should be smooth, calm, and visually minimal.

---

## 6.4 Breathing Text Guidance

The screen should show text guidance during each phase.

Suggested text:

| Phase             | English Text | Thai Text |
| ----------------- | ------------ | --------- |
| Inhale            | Breathe In   | หายใจเข้า |
| Hold              | Hold         | ค้างไว้   |
| Exhale            | Breathe Out  | หายใจออก  |
| Hold After Exhale | Rest         | พักไว้    |

The app should support English first, with the possibility of Thai language support later.

---

## 6.5 Breathing Sound Guidance

Users should be able to choose guidance mode:

| Mode        | Description                                                    |
| ----------- | -------------------------------------------------------------- |
| Voice Guide | Spoken instruction such as “Breathe in”, “Hold”, “Breathe out” |
| Bell Guide  | Soft bell or chime when phase changes                          |
| Visual Only | No sound guide, only animation                                 |
| Silent      | No voice, no bell, no music                                    |

The sound guidance should be soft and non-intrusive.

---

## 6.6 Break Music / Ambient Sound

Break sessions should have separate music settings from focus sessions.

Suggested categories:

| Category       | Examples                         |
| -------------- | -------------------------------- |
| Meditation     | Soft meditation bell, calm drone |
| Nature Calm    | Light rain, ocean, wind          |
| Breath Ambient | Soft breathing atmosphere        |
| Silence        | No sound                         |

Audio should fade in at the beginning and fade out at the end.

---

## 6.7 Standalone Breathing Session Requirement

Users should be able to start guided breathing independently without any focus session dependency.

Standalone breathing sessions should support:

* Quick start breathing
* Full-screen breathing mode
* Breathing presets
* Custom breathing patterns
* Ambient sound selection
* Optional session logging
* Optional timer-free breathing mode

This mode should feel suitable for:

* Stress reduction
* Meditation
* Recovery
* Calm breaks during meetings
* Morning breathing routines
* Evening wind-down routines

---

# 7. Rating & Reflection

After each completed focus session, users should be able to rate their focus quality.

## 7.1 Focus Rating

Rating scale:

```text
1–10
```

Suggested meaning:

| Rating | Meaning         |
| ------ | --------------- |
| 1–3    | Poor focus      |
| 4–6    | Moderate focus  |
| 7–8    | Good focus      |
| 9–10   | Excellent focus |

The rating should be optional but encouraged.

---

## 7.2 Optional Reflection Note

After each session, the user may add a short note.

Examples:

```text
Good focus, but interrupted once.
```

```text
Excellent deep work session.
```

```text
Tired today, but still completed the session.
```

Standalone breathing sessions may optionally support short reflection notes such as:

```text
Felt calmer after breathing.
```

```text
Used this session before an important meeting.
```

---

# 8. Daily History

The app should record completed sessions each day.

## 8.1 Data to Record

Each session should store:

| Field             | Example          |
| ----------------- | ---------------- |
| Date              | 2026-05-28       |
| Start Time        | 09:00            |
| End Time          | 09:25            |
| Focus Duration    | 25 minutes       |
| Break Duration    | 5 minutes        |
| Session Label     | Writing          |
| Focus Sound       | Rain             |
| Breathing Pattern | Box Breathing    |
| Focus Rating      | 8/10             |
| Status            | Completed        |
| Note              | Good focus today |

Standalone breathing sessions should optionally store:

| Field              | Example               |
| ------------------ | --------------------- |
| Session Type       | Standalone Breathing  |
| Breathing Duration | 10 minutes            |
| Breathing Pattern  | Relax Breathing       |
| Ambient Sound      | Ocean                 |
| Reflection Note    | Felt calmer afterward |

---

## 8.2 Daily Summary

The app should generate a daily summary.

Example:

```markdown
# XenTimer Daily Report — 2026-05-28

## Summary

- Completed Focus Sessions: 6
- Total Focus Time: 2 hr 30 min
- Total Break Time: 30 min
- Standalone Breathing Sessions: 2
- Total Breathing Practice Time: 20 min
- Average Focus Rating: 8.2/10
- Most Used Breathing Pattern: Box Breathing
- Most Used Focus Tag: Writing

## Sessions

| No. | Time | Focus Duration | Break | Tag | Rating | Note |
|---:|---|---:|---:|---|---:|---|
| 1 | 09:00–09:25 | 25 min | 5 min | Writing | 8 | Good focus |
| 2 | 09:40–10:05 | 25 min | 5 min | Reading | 7 | Slightly distracted |
```

---

# 9. Markdown Export for Obsidian

XenTimer should be able to export important daily data as Markdown files.

This is a key requirement.

## 9.1 Markdown Export Purpose

The exported Markdown files should be readable in Obsidian.

The goal is to allow users to keep productivity records as part of their personal knowledge management system.

The export should also support standalone breathing sessions and recovery practice logs.

---

## 9.2 Export Format

Each daily report should be exported as a Markdown file.

Suggested file name:

```text
XenTimer Daily Report - YYYY-MM-DD.md
```

Example:

```text
XenTimer Daily Report - 2026-05-28.md
```

---

## 9.3 Suggested Obsidian Folder Structure

Users should be able to choose an export folder.

Suggested structure:

```text
Obsidian Vault/
└── Productivity/
    └── XenTimer/
        └── Daily Reports/
            ├── XenTimer Daily Report - 2026-05-28.md
            ├── XenTimer Daily Report - 2026-05-29.md
            └── XenTimer Daily Report - 2026-05-30.md
```

---

## 9.4 Markdown Template

The daily report should follow this structure:

```markdown
# XenTimer Daily Report — {{date}}

## Daily Summary

- Completed Focus Sessions: {{completed_sessions}}
- Total Focus Time: {{total_focus_time}}
- Total Break Time: {{total_break_time}}
- Standalone Breathing Sessions: {{standalone_breathing_sessions}}
- Total Breathing Practice Time: {{total_breathing_time}}
- Average Focus Rating: {{average_rating}}/10
- Most Used Breathing Pattern: {{most_used_breathing_pattern}}
- Most Used Focus Tag: {{most_used_tag}}

## Session Log

| No. | Time | Session Type | Focus Duration | Break Duration | Tag | Breathing Pattern | Rating | Note |
|---:|---|---|---:|---:|---|---|---:|---|
| 1 | {{start_time}}–{{end_time}} | {{session_type}} | {{focus_duration}} | {{break_duration}} | {{tag}} | {{breathing_pattern}} | {{rating}} | {{note}} |

## Reflection

### What went well today?

- 

### What interrupted my focus?

- 

### What should I improve tomorrow?

- 

## Tags

#XenTimer #Pomodoro #Productivity #Recovery #Breathing
```

---

# 10. Data Sync Requirement

XenTimer should support data sync.

## 10.1 Sync Goals

The app should allow users to keep their data safe and available across devices in the future.

For Version 1, local storage is acceptable, but the app architecture should be designed to support sync later.

---

## 10.2 Suggested Sync Options

Possible sync options:

| Option                | Description                            |
| --------------------- | -------------------------------------- |
| iCloud Sync           | Best native option for macOS ecosystem |
| Local Markdown Export | Best for Obsidian users                |
| Manual Backup         | Export database or Markdown files      |
| Future Cloud Sync     | Optional future feature                |

Recommended direction:

```text
Version 1:
Local database + Markdown export

Version 2:
iCloud sync

Version 3:
Cross-device sync with iPhone/iPad support
```

---

# 11. Dashboard Requirement

For the first version, the dashboard can focus on daily data only.

## 11.1 Daily Dashboard

The dashboard should show:

* Completed focus sessions today
* Total focus time today
* Total break time today
* Standalone breathing sessions today
* Total breathing practice time today
* Average focus rating today
* Current streak
* Most used focus tag
* Most used breathing pattern

Example:

```text
Today

Completed Sessions: 6
Total Focus Time: 2 hr 30 min
Total Break Time: 30 min
Standalone Breathing Sessions: 2
Total Breathing Practice Time: 20 min
Average Focus Rating: 8.2/10
Most Used Tag: Writing
Most Used Breathing Pattern: Box Breathing
```

---

# 12. Settings Requirement

The app should include a settings page.

## 12.1 General Settings

Users should be able to set:

* Default focus duration
* Default break duration
* Default breathing pattern
* Default focus sound
* Default break sound
* Notification preference
* Menu bar display preference
* Markdown export folder
* Auto-export daily report on/off
* Default standalone breathing duration

---

## 12.2 Notification Settings

The app should support macOS notifications for:

* Focus session completed
* Break session started
* Break session completed
* Standalone breathing session completed
* Daily goal completed

Notifications should be gentle and not distracting.

---

# 13. Suggested MVP Scope

The first version should focus on the core experience.

## 13.1 MVP Features

| Area      | Feature                            |
| --------- | ---------------------------------- |
| Focus     | Set focus duration                 |
| Focus     | Start / pause / resume / stop      |
| Focus     | Select basic background sound      |
| Focus     | Add session tag                    |
| Break     | Set break duration                 |
| Breathing | Select breathing pattern           |
| Breathing | Custom breathing pattern           |
| Breathing | Standalone breathing mode          |
| Breathing | Animated breathing circle          |
| Breathing | Text guidance                      |
| Breathing | Optional sound guide               |
| History   | Record completed sessions          |
| Rating    | Focus rating from 1–10             |
| Dashboard | Daily summary                      |
| Export    | Daily Markdown export for Obsidian |
| macOS     | Menu bar timer                     |
| macOS     | Full-screen breathing mode         |

---

# 14. Future Features

Possible future development:

| Feature                       | Description                                       |
| ----------------------------- | ------------------------------------------------- |
| Weekly report                 | Weekly productivity and recovery summary          |
| Monthly report                | Long-term trend tracking                          |
| AI reflection                 | AI-generated daily productivity insight           |
| Calendar integration          | Link sessions to calendar events                  |
| Apple Health integration      | Connect recovery data with health metrics         |
| Custom audio import           | Users can import their own sound files            |
| iPhone companion app          | Continue tracking across devices                  |
| Focus goal                    | Set daily target such as 8 sessions               |
| Streak system                 | Track consecutive productive days                 |
| Obsidian advanced integration | Auto-link daily notes and tags                    |
| Meditation mode               | Dedicated meditation-focused breathing experience |

---

# 15. Design Direction

The design should feel:

```text
Minimal
Calm
Focused
Professional
Premium
Not too playful
Not too gamified
```

Suggested colour mood:

* Deep navy
* Warm white
* Soft grey
* Soft green
* Muted burgundy

The visual design should support focus and calmness, not overstimulation.

Standalone breathing mode should feel especially calm, immersive, and restorative.

---

# 16. Product Positioning

Suggested product statement:

> **XenTimer is a macOS productivity timer that combines deep focus sessions with guided breathing breaks, helping users work with rhythm, recover intentionally, and build a sustainable daily productivity habit.**

Alternative short positioning:

> **Work with rhythm. Rest with breath.**

Additional positioning direction:

> **A productivity timer and breathing companion for focused work and intentional recovery.**

---

# 17. Success Criteria for Version 1

XenTimer Version 1 should be considered successful if users can:

1. Start and complete a focus session.
2. Take a guided breathing break after the session.
3. Start a standalone guided breathing session independently.
4. Rate the focus session from 1–10.
5. Review the daily productivity summary.
6. Export the daily report as Markdown.
7. Open the exported report in Obsidian.
   
