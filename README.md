<div align="center">

# 💪 FitX

### Your AI-Powered Gym & Fitness Companion

[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Riverpod](https://img.shields.io/badge/Riverpod-2.6-00A859?style=for-the-badge)](https://riverpod.dev)
[![Material 3](https://img.shields.io/badge/Material_3-Design-757575?style=for-the-badge&logo=materialdesign&logoColor=white)](https://m3.material.io)
[![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)](LICENSE)

**FitX** is a full-featured, offline-first fitness tracker built with Flutter.  
Log workouts, track nutrition & body metrics, earn achievements, and let an AI coach generate personalized plans — all without an internet connection.

[Getting Started](#-getting-started) · [Features](#-features) · [Architecture](#-architecture) · [Roadmap](#-roadmap)

</div>

---

## ✨ Features

<table>
<tr>
<td width="50%">

### 🏋️ Workout Logging
- Build workouts from a library of **30+ exercises**
- Adjust sets, reps & weight with intuitive steppers
- Live session timer with rest-timer notifications
- Full workout history with detail view

</td>
<td width="50%">

### 🤖 AI Workout Generator
- Pick a goal: **build muscle · lose weight · get strong · endurance**
- Select muscle focus, available equipment & duration
- Template engine builds a complete plan instantly
- One tap to start the generated plan as a logged workout

</td>
</tr>
<tr>
<td>

### 📊 Progress & Analytics
- **fl_chart**-powered graphs for weight & volume over time
- Body metrics tracking (weight, body fat %, measurements)
- Personal records board for every exercise
- Day-streak & calorie stats on the home dashboard

</td>
<td>

### 🥗 Nutrition Tracking
- Daily macro dashboard (calories, protein, carbs, fat)
- AI-powered Indian food database with search
- Meal logging (breakfast, lunch, dinner, snacks)
- Per-meal breakdown & daily totals

</td>
</tr>
<tr>
<td>

### 🏆 Gamification & Badges
- Unlock achievement badges for milestones
- Track workout streaks & consistency
- Visual badge gallery with progress indicators
- Motivational system tied to real activity data

</td>
<td>

### ⚙️ Settings & Export
- Light & dark theme toggle
- Export workout history to **PDF** via `pdf` package
- Share workouts with `share_plus`
- Pluggable backend architecture for future cloud sync

</td>
</tr>
</table>

<details>
<summary><strong>🔍 More highlights</strong></summary>

- **Exercise Library** — browse by muscle group (chest, back, legs, shoulders, arms, core, cardio), view form cues, default parameters, and detailed descriptions
- **AI Fitness Coach** — conversational chat interface powered by Gemini for on-demand fitness advice
- **Auth** — local sign-up / sign-in with email & password, plus a one-tap **demo account** for instant exploration
- **Atomic Design UI** — shared components built with an atoms → molecules → organisms hierarchy for consistency

</details>

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter SDK | `≥ 3.24` |
| Dart SDK | `≥ 3.4` |

### Run

```bash
# Clone the repo
git clone https://github.com/cbashray/fitx.git
cd fitx

# Install dependencies
flutter pub get

# Launch on any platform
flutter run
```

> **Platforms:** Android · iOS · macOS · Web  
> **No backend or API keys needed** — everything works offline out of the box.

### Demo Account

Tap **"Try Demo Account"** on the sign-in screen to explore instantly, or create your own account.

---

## 🏗 Architecture

FitX follows a **feature-first clean architecture** with clear separation of concerns:

```
lib/
├── main.dart                          # App entry → ProviderScope → MaterialApp.router
├── core/
│   ├── constants/                     # App-wide constants & feature flags
│   ├── di/                            # Dependency injection setup
│   ├── errors/                        # Failure types
│   ├── providers/                     # Repository providers (DI)
│   ├── routers/                       # go_router config + auth-aware redirects
│   ├── theme/                         # Light & dark Material 3 themes
│   └── utils/                         # String / list extensions
└── features/
    ├── auth/                          # Local auth (SharedPreferences-backed)
    ├── home/                          # Dashboard: stats, history, quick actions
    ├── workouts/                      # Workout logging, history & personal records
    ├── exercise_library/              # 30+ seeded exercises, browse & detail
    ├── progress/                      # Charts (fl_chart) & body metrics
    ├── nutrition/                     # Daily macros, food search & meal logging
    ├── settings/                      # Theme toggle, export to PDF
    ├── shared/                        # Shared UI (atoms / molecules / organisms)
    │   └── gamification/              # Badge & achievement engine
    └── ai/
        ├── adaptive_workout/          # AI workout plan generator
        ├── fitness_coach/             # Conversational AI coach (Gemini)
        ├── form_correction/           # 🚧 Camera-based form analysis
        └── indian_food_ai/            # 🚧 AI food recognition
```

Each feature is self-contained with three layers:

```
feature/
├── domain/          # Entities & repository interfaces (contracts)
├── data/            # Repository implementations (SharedPreferences / API)
└── presentation/    # Providers (Riverpod) & screens (Flutter widgets)
```

### Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter — Material 3 with light + dark themes |
| **State Management** | Riverpod (`flutter_riverpod`) |
| **Navigation** | `go_router` with auth-aware redirects |
| **Persistence** | `shared_preferences` (JSON-encoded local storage) |
| **Charts** | `fl_chart` for progress visualization |
| **AI** | `google_generative_ai` (Gemini) for coach & workout gen |
| **Export** | `pdf` + `share_plus` + `path_provider` |
| **Notifications** | `flutter_local_notifications` (rest timer alerts) |
| **IDs** | `uuid` for unique entity identification |
| **CI** | GitHub Actions (`dart.yml` workflow) |

---

## 🔌 Swapping in a Real Backend

The UI only talks to repository **interfaces** — never to concrete implementations:

```
AuthRepository  ·  WorkoutRepository  ·  ExerciseRepository  ·  AdaptiveWorkoutRepository
```

To connect Firebase, Supabase, or any backend:

1. Create a new implementation of the interface  
   (e.g., `SupabaseAuthRepository implements AuthRepository`)
2. Swap the provider in [`app_providers.dart`](lib/core/providers/app_providers.dart)

**Zero changes** to screens or providers required.

---

## 🗺 Roadmap

- [x] Workout logging & exercise library
- [x] AI workout generator
- [x] Progress charts & body metrics
- [x] Nutrition tracking
- [x] AI fitness coach (Gemini)
- [x] Gamification & badges
- [x] PDF export & sharing
- [x] Light & dark themes
- [ ] Camera-based form correction
- [ ] AI food recognition from photos
- [ ] Cloud sync (Supabase / Firebase)
- [ ] Social features & leaderboards
- [ ] Apple Health / Google Fit integration
- [ ] Wearable device support

---

## 🤝 Contributing

Contributions are welcome! Please follow the existing architecture patterns:

1. **Fork** the repo
2. **Create** a feature branch (`git checkout -b feature/amazing-feature`)
3. **Commit** your changes (`git commit -m 'Add amazing feature'`)
4. **Push** to the branch (`git push origin feature/amazing-feature`)
5. **Open** a Pull Request

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with 💚 and Flutter**

Made by [@cbashray](https://github.com/cbashray)

</div>
