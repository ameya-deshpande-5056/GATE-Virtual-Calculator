# GATE Virtual Calculator

A cross-platform Flutter reproduction of the GATE examination virtual
calculator, built from a single Flutter/Dart codebase for Web, Android and iOS.

## Interaction model

This is **not** a generic infix scientific calculator. It reproduces the GATE
button-sequence model in which most functions apply **after** their operand:

- `25` → `sin`
- `30` → `log` → `×` → `10`
- `5` → `n!`
- `8` → `ʸ√x` → `4`, then `=` for the exponent/root operand
- `20` → `x^y` → `2` → `+/-` → `=`

The pure-Dart engine (`lib/calculator/domain/calculator_engine.dart`) models
every key as an explicit `CalculatorAction`; widgets never compute anything.

## Architecture

```text
lib/
  app.dart                  # MaterialApp root (GateCalculatorApp)
  main.dart                 # entry point, runs offline
  core/
    constants/              # display/app-wide constants
    errors/                 # CalculatorException
    utils/                  # NumberFormatter (shortest round-trip display)
  calculator/
    domain/                 # engine, state, actions, operations, functions
    parser/                 # precedence parser + expression tree (no eval)
    application/            # CalculatorCubit (delegates to the engine)
    presentation/           # page, displays, 11-column keypad, keyboard map
```

The mathematical engine is pure Dart with no Flutter dependency and is fully
covered by unit tests. The app works fully offline.

## Reference material

- `reference/screenshots/` — authoritative behaviour/visual source of truth.
- `reference/KEYPAD_LAYOUT.md` — verified keypad geometry and display samples.
- `reference/GATE_Virtual_Calculator_Documentation.md` — secondary source.
- `KNOWN_DIFFERENCES.md` — documents every conflict/inference and what was
  used instead (screenshots win over prose descriptions).

## Run

```sh
flutter pub get
flutter analyze
flutter test
flutter run -d chrome        # web
flutter run -d android       # android
flutter run -d ios           # ios
```

## Build

```sh
flutter build web
flutter build apk
flutter build ios --no-codesign
```

