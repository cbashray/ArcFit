# FitX 💪

**FitX** is an AI-powered gym & fitness tracker built with Flutter. Log workouts, browse an exercise library, and generate workout plans tailored to your goals and equipment.

## Features

- **Auth** — sign up / sign in with email & password, plus a one-tap demo account (local, offline-first)
- **Workout logging** — build a workout, add exercises, adjust sets/reps/weight with steppers, live session timer, save to history
- **Exercise library** — 30+ seeded exercises across chest, back, legs, shoulders, arms, core and cardio, with search, muscle-group filters, form cues and default parameters
- **AI workout generator** — pick a goal (build muscle / lose weight / get strong / endurance), muscle focus, equipment and duration; FitX builds a plan using a template engine and lets you start it as a logged workout
- **Home dashboard** — real stats (workouts, total sets, day streak, calories), recent workout history, quick actions

## Tech stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Material 3, light + dark theme) |
| State management | Riverpod (`flutter_riverpod`) |
| Navigation | `go_router` with auth-aware redirects |
| Persistence | `shared_preferences` (JSON-encoded local storage) |
| Architecture | Feature-first clean architecture: `domain` (entities + repo interfaces) / `data` (repo implementations) / `presentation` (providers + screens) |

## Getting started

```bash
flutter pub get
flutter run
```

Runs on Android, iOS, macOS and web. No backend or API keys needed — everything works offline out of the box.

**Demo login:** tap **"Try Demo Account"** on the sign-in screen, or create your own account.

## Project structure

```
lib/
├── main.dart                     # App entry, ProviderScope, MaterialApp.router
├── core/
│   ├── constants/                # App-wide constants & feature flags
│   ├── errors/                   # Failure types
│   ├── providers/                # Repository providers (DI)
│   ├── routers/                  # go_router config + auth redirect
│   ├── theme/                    # Light/dark themes
│   └── utils/                    # String/list extensions
└── features/
    ├── auth/                     # Local auth (SharedPreferences-backed)
    ├── home/                     # Dashboard with stats & history
    ├── workouts/                 # Workout logging + history
    ├── exercise_library/         # Seeded exercise data + browse/detail
    └── ai/adaptive_workout/      # Workout plan generator
```

## Swapping in a real backend

The UI only talks to repository **interfaces** (`AuthRepository`, `WorkoutRepository`, `ExerciseRepository`, `AdaptiveWorkoutRepository`). To connect Supabase or Firebase:

1. Add a new implementation of the interface (e.g. `SupabaseAuthRepository`)
2. Swap the provider in `lib/core/providers/app_providers.dart`

No screen or provider code needs to change.

## Roadmap

- [ ] Progress charts (weight/volume over time)
- [ ] Real AI plan generation via LLM API
- [ ] Form correction via camera
- [ ] Nutrition tracking
- [ ] Cloud sync (Supabase)
