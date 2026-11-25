# CLAUDE.md

This file guides Claude Code (claude.ai/code) when it works in this repository.

## What this is

This is a university team project for "Języki programowania – Smalltalk", 2026/27, Politechnika Gdańska (WETI), taught by Magdalena Godlewska. The project is **GoSmall – planer podróży**, a text-only travel planner in Smalltalk. A trip is made of segments that use different means of transport. The grade rests on visible use of OOP concepts: inheritance and class hierarchy, polymorphism and method overriding, messages with different numbers of arguments, aggregation of objects of different classes, and dynamic type recognition.

All identifiers, comments and output are in **Polish**. Keep that convention: method names such as `czas`, `koszt`, `dystans`, `drukuj`, `opis`, and messages without diacritics such as `zl` instead of `zł`.

## Repository layout

- `odcinek.st`: the entire program. It holds the class definitions plus the inline test/demo script at the bottom.
- `docs/`: course materials, **gitignored** (local only):
  - `smalltalk_zadanie.pdf`: the assignment spec (modules, requirements, grading).
  - `GoSmall.pdf`: the lecturer's GNU Smalltalk tutorial for this project (syntax, `+` design hints, the mini-test template that the tests in `odcinek.st` come from).

## Running

The target dialect is **GNU Smalltalk** (bracket class syntax). `gst` 3.2.5 is installed at `/opt/homebrew/bin/gst`.

```sh
gst odcinek.st
```

Expected output: `Testy Modulu 2: OK`, `Testy Modulu 3: OK`, the printed route, `Testy Modulu A: OK`, then the module A demo.

**Testing gotcha:** there is no test framework. Checks use a `sprawdz` block that raises `Error signal: opis`. In gst, an error in a top-level statement **prints a stack trace and execution continues**, with exit code 0. A later `... OK` line will still print. Always check the output for `error:` / stack traces. Do not rely on the "OK" lines or on the exit code.

## Architecture (`odcinek.st`)

```
Object
├── Trasa                      route: ordered collection of segments
└── OdcinekPodrozy             base segment: poczatek, koniec, dystans
    ├── Pieszo                 czas = dystans*12, koszt 0
    ├── Rower                  czas = dystans*4,  koszt 2
    └── Autobus                czas = dystans*2+2, koszt 4
```

- **OdcinekPodrozy** holds shared state and accessors. It provides the constructor `od:do:dystans:` (keyword message with 3 args), default `czas`/`koszt` = 0, `nazwaTransportu`, and `opis`. Subclasses override only `nazwaTransportu`, `czas` and `koszt`, because the spec forbids duplicating shared code in subclasses.
- **`+` is defined twice**, in both `OdcinekPodrozy` and `Trasa`. Dispatch happens on the left operand's class. The method then checks the right operand with `isKindOf:` (`OdcinekPodrozy` or `Trasa`) and otherwise calls `self error: 'Oczekiwano odcinka lub trasy'`. It always returns a **new** `Trasa` built from a fresh `OrderedCollection` (`add:`/`addAll:`). Operands must never be mutated, and the tests verify this.
- **Trasa** aggregates with `inject:into:` by sending `dystans`/`czas`/`koszt` to each segment. The spec **forbids** class checks for time/cost and **forbids** separate per-transport collections, so aggregation must stay polymorphic. `drukuj` prints to `Transcript` in the format from the spec.
- **Delays (module A):** `OdcinekPodrozy` answers `opoznienie` with 0, and its `opoznienie:` raises an error. Only `Autobus` overrides both and adds the delay in `czas`. Setting a delay replaces the previous value. `drukuj` shows a delay line only when it is > 0.
- File order: `Trasa` is defined before `OdcinekPodrozy`, but each class's methods refer to the other. gst accepts this because method bodies bind globals late. Any new class must be defined before the test script at the bottom.
- The test/demo script is a single top-level `| ... |` block at the end of the file. New features should get their own `sprawdz` checks there and a printed demo.

## Assignment status

Grading totals 15 pts. Mandatory modules are worth 2 pts each. The optional modules together are worth 4.5 pts. The remaining points cover collections/iteration, polymorphism, class responsibilities, and quality/tests/error handling/presentation.

| Module | Status |
|---|---|
| 1. Środki transportu i dziedziczenie | done |
| 2. Łączenie odcinków – `+` | done, tested |
| 3. Trasa jako agregator (`dystans`, `czas`, `koszt`, `drukuj`) | done, tested |
| A. Opóźnienia (optional) | done, tested |
| Other optional modules | **not started** |

The optional modules to choose from:
- **A** opóźnienia (`opoznienie:`)
- **B** przesiadki (separate waiting time)
- **C** `PlanerPodrozy` with `najszybsza`
- **D** `najtansza`, comparing ≥3 routes
- **E** `emisjaCO2`
- **F** `Pasazer` with ≥2 subclasses and `kosztDla:`
- **G** `Warunki` with `czasDla:`
- **H** `uprosc`, which merges contiguous same-type segments
- **I** `sprawdz`, a continuity check
- **J** `zastap:przez:`
- **K** a module of the team's own design

The spec is inconsistent about how many optional modules to pick: one slide says 4, the module slides and the grading table say 3. Ask the user before assuming.

General requirements that apply to all new code:
- Messages with different arities.
- A collection of mixed classes.
- At least one message that accepts any object and recognizes its class.
- Use of Smalltalk collection/iteration protocols (`do:`, `collect:`, `select:`, `inject:into:`, `detect:`…).
- Proper handling of invalid input and operations.
- A demo for every chosen module.

Known gaps compared with the spec's example output:
- Distances are integers. The spec shows decimal values (`0,8 km`, `4,80 zł`).
- `Rower` costs 2, while the spec example uses 1 zł.
- `opis` is implemented but not exercised in the demo.
