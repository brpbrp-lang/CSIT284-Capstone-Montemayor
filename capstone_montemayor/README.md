# Class Schedule / Timetable Viewer (CSIT284)

- **Student Name:** [John Emmanuel B. Montemayor]
- **Workstation Number:** [WS 27]
- **Section:** BSIT 3 - G1
- **Capstone Task:** X7. Class Schedule / Timetable Viewer

---

## Project Description
A single-section (**BSIT 3 - G1**), read-only Flutter mobile timetable application backed by **Firebase Realtime Database**. It enables students to view their weekly schedule, track today’s classes with live ongoing/upcoming status indicators, and receive automated local push notifications **10 minutes before each scheduled class**.

### Scope & Design Decisions
- **Single-Section Scope:** Built specifically for one block section (`BSIT 3 - G1`) without authentication walls or in-app CRUD editing forms.
- **Seeded Cloud Backend:** Connects to Firebase Realtime Database via REST API (`http` + `dart:convert`), automatically seeding the section's 13 weekly class sessions on initial launch if the database node is empty.

---

## Core Features
1. **Today's Classes Home Screen (`TodayScreen`)**
   - Displays a live **"Happening Now / Starts In"** focus card showing remaining or countdown time.
   - Features a **Daily Goal** concentric progress ring tracking completed classes and study hours.
   - Includes instant search (by course code, title, or room) and status filter pills (`All`, `Ongoing`, `Upcoming`, `Done`).
2. **Weekly Timetable View (`WeeklyScreen`)**
   - Interactive Monday–Saturday day selector with visual class status indicators and daily hour summary.
   - Chronological timeline cards with subject color-coding (`SubjectColors`) and a tap-to-view **Class Details Bottom Sheet** (`ClassDetailsSheet`).
3. **10-Minute Pre-Class Reminders (`NotificationService`)**
   - Uses `flutter_local_notifications` and `timezone` (`Asia/Manila`) to schedule recurring weekly alerts 10 minutes before every class starts.

---

## Project Structure (`lib/`)
```text
lib/
├── main.dart                         # App entry point, Firebase REST fetch/seed, floating navigation bar
├── data/
│   └── dummy_data.dart               # Seed schedule for BSIT 3 - G1 (13 class sessions)
├── models/
│   └── class_session.dart            # ClassSession model, time formatting, and JSON mappers
├── screens/
│   ├── today_screen.dart             # Today's classes dashboard, focus card, search, and filters
│   └── weekly_screen.dart            # Mon–Sat weekly timetable overview and daily timeline
├── services/
│   └── notification_service.dart     # Automated 10-minute pre-class weekly notification scheduler
├── theme/
│   └── subject_colors.dart           # Dark bento palette and deterministic subject accent colors
└── widgets/
    ├── class_card.dart               # Reusable class card (standard & compact modes)
    └── class_details_sheet.dart      # Modal bottom sheet displaying full class & reminder details