# Pokédex Flutter

A cross-platform Pokédex app built with **Flutter**, consuming the public [PokéAPI](https://pokeapi.co/). Built as a showcase of production-grade Flutter practices — **Clean Architecture**, **BLoC** state management, and a CI pipeline — by a mobile engineer with 11+ years of native Android experience bridging into Flutter.

> **Status:** Personal portfolio project · Runs on Android, iOS, and Windows.

---

## ✨ Features

- Browse Pokémon fetched live from the PokéAPI (REST)
- View detailed stats, types, and sprites for each Pokémon
- Responsive UI that runs across Android, iOS, and desktop (Windows)
- Loading / error / empty states handled explicitly via BLoC

> _Note: update this list to match the exact features currently in the app._

## 🏗 Architecture

The app follows **Clean Architecture**, separating concerns into clear layers:

```
lib/
├── data/          # Data sources, DTOs, repository implementations (PokéAPI)
├── domain/        # Entities, repository contracts, use cases
└── presentation/  # BLoC (events/states), pages, and widgets
```

**Why this matters:**
- **Domain layer** has no Flutter or network dependencies — pure Dart, easy to test.
- **Data layer** handles the PokéAPI REST calls and maps responses to domain entities.
- **Presentation layer** uses **BLoC** to drive UI state, keeping widgets dumb and predictable.

This mirrors the same separation I apply in production Android work (e.g. mapping `StateFlow` → `BlocBuilder`, repository pattern, use cases), making the codebase predictable and testable.

## 🛠 Tech Stack

| Area | Choice |
|------|--------|
| Framework | Flutter (Dart) |
| State Management | **BLoC** (`flutter_bloc`) |
| Architecture | **Clean Architecture** (data / domain / presentation) |
| Networking | REST → PokéAPI |
| Testing | `flutter_test` (unit / widget tests) |
| CI/CD | **Codemagic** (`codemagic.yaml`) |
| Platforms | Android · iOS · Windows |

## 🚀 Getting Started

**Prerequisites:** Flutter SDK installed ([guide](https://docs.flutter.dev/get-started/install)).

```bash
# 1. Clone
git clone https://github.com/pogimista/flutter_2026.git
cd flutter_2026

# 2. Install dependencies
flutter pub get

# 3. Run
flutter run
```

## 🧪 Running Tests

```bash
flutter test
```

## 📸 Screenshots

> _Add 2–3 screenshots or a short GIF here — recruiters look at this first._
> _Tip: drop images in a `/screenshots` folder and reference them like:_
> `![Home](screenshots/home.png)`

## 📌 Roadmap / Notes

- [ ] Add search & filtering
- [ ] Cache responses for offline support
- [ ] Add widget + integration test coverage
- [ ] Publish CI build artifacts

---

Built by **John Christopher B. Mista** — Senior/Lead Mobile Engineer (Android Native · iOS · Flutter).
[LinkedIn](https://www.linkedin.com/in/john-christopher-mista)