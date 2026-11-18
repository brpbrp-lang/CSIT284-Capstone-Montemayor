# Agent Guide — Capstone Montemayor

## Project Overview

A **Flutter** class-schedule viewer app for **BSIT 3-A** students. Students see their fixed block schedule (Today view & Weekly view) and can add personal extra subjects (meetings, overloads, etc.). There is **no authentication** and **no teacher role** — those are deferred to future phases.

Design reference: **"Timetable: Class Scheduler Plan"** by Erfouris Studio (iOS-inspired, color-coded subjects, hero banner, capsule day tabs).

---

## Tech Stack

| Layer | Detail |
|---|---|
| Framework | Flutter (Dart) |
| Dart SDK | `^3.13.0` |
| State management | `InheritedWidget` via `ScheduleScope` (no third-party packages) |
| Key packages | `intl ^0.20.3`, `device_frame ^1.4.0`, `cupertino_icons ^1.0.8` |
| Backend | None yet (future: Firebase Firestore) |
| Target | Web (runs inside a `PhoneFrame` wrapper) |

**Flutter is NOT on PATH.** Always invoke via full path:

```powershell
& "C:\Users\L12X16W27\Documents\flutter\flutter\bin\flutter.bat"
```

---

## Project Structure

```
capstone_montemayor/
├── lib/
│   ├── main.dart                       # Entry point, TimetableApp, HomeShell, PhoneFrame
│   ├── data/
│   │   └── dummy_data.dart             # Hard-coded BSIT 3-A block schedule
│   ├── models/
│   │   └── class_session.dart          # ClassSession model (immutable, copyWith, fromMap/toMap)
│   ├── providers/
│   │   └── schedule_provider.dart      # ScheduleProvider (ChangeNotifier) + ScheduleScope (InheritedWidget)
│   ├── screens/
│   │   ├── today_screen.dart           # Today view — hero "UP NEXT / NOW HAPPENING" card, auto-refresh
│   │   └── weekly_screen.dart          # Weekly view — horizontal day capsule tabs, 5/7-day toggle
│   ├── theme/
│   │   └── subject_colors.dart         # SubjectTheme color palette per course code
│   └── widgets/
│       ├── add_edit_class_sheet.dart    # Bottom sheet for adding/editing a subject
│       ├── class_card.dart             # Reusable class card with left-accent color bar
│       └── class_details_sheet.dart    # Modal bottom sheet showing full class details + edit/remove
├── test/
│   └── widget_test.dart                # Widget test + ScheduleProvider unit test
├── pubspec.yaml
└── agent.md                            # (this file)
```

---

## Architecture & Conventions

### State Management

- `ScheduleProvider` extends `ChangeNotifier` and holds a `List<ClassSession>`.
- Exposed to the widget tree via `ScheduleScope`, a custom `InheritedWidget`.
- Access anywhere with `ScheduleScope.of(context)`.

### Data Model — `ClassSession`

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | Block subjects use course code (e.g. `'csit284'`). Added subjects use `'overload_<timestamp>'`. |
| `courseCode` | `String` | e.g. `'CSIT284'` |
| `courseTitle` | `String` | e.g. `'Capstone Project 2'` |
| `dayOfWeek` | `String` | Full day name: `'Monday'` through `'Sunday'` |
| `startHour` / `startMinute` | `int` | 24-hour format |
| `endHour` / `endMinute` | `int` | 24-hour format |
| `room` | `String` | |
| `instructor` | `String` | |
| `isOverload` | `bool` | `true` = student-added subject (editable/removable). `false` = block schedule (read-only). |
| `statusNote` | `String?` | Reserved for future teacher announcements |

### Naming: "Overload" (internal) vs "Subject" / "Added" (UI)

- **Internal code** uses `isOverload`, `overload_` ID prefix, `defaultOverloadTheme` — these are technical field names and must NOT be renamed.
- **User-facing strings** say **"Add Subject"**, **"Edit Subject"**, **"Added"** badge, **"Remove Subject?"** — never expose the word "overload" to the user.

### UI Patterns

- **Phone Frame**: Web builds render inside a `DeviceFrame` (iPhone 15 Pro) wrapper.
- **Today Screen**: Auto-refreshing hero card (gradient banner with live countdown), class list sorted by time.
- **Weekly Screen**: Horizontal capsule day tab bar, 5-Day / 7-Day toggle, day-scoped class list.
- **Subject Colors**: Each course code maps to a `SubjectTheme` (primary + accent). Added subjects get a default amber theme.
- **Bottom Sheets**: Used for both add/edit and class details (modal, rounded corners).

---

## Verification Checklist

Always run these **before** declaring work complete:

```powershell
cd C:\Users\L12X16W27\Documents\CAPSTONE-MONTEMAYOR\capstone_montemayor

# Static analysis — must report "No issues found!"
& "C:\Users\L12X16W27\Documents\flutter\flutter\bin\flutter.bat" analyze

# Tests — must report "All tests passed!"
& "C:\Users\L12X16W27\Documents\flutter\flutter\bin\flutter.bat" test
```

---

## Git Info

| Item | Value |
|---|---|
| Repo root | `C:\Users\L12X16W27\Documents\CAPSTONE-MONTEMAYOR` |
| Remote | `https://github.com/brpbrp-lang/CSIT284-Capstone-Montemayor.git` |
| Branch | `main` |
| Current state | Only `README.md` committed on remote; project files are untracked locally |

> **Do NOT** run `git push --force` without explicit user confirmation.

---

## Roadmap (Future / Not Yet Started)

- [ ] Firebase Firestore cloud integration (Phase 3)
- [ ] Authentication — login screen for BSIT 3-A students
- [ ] Local notifications (`flutter_local_notifications`)
- [ ] Commit and push all project files to GitHub
