# Technical Architecture (2026 Edition)

## Overview

The app is built using **SwiftUI** and follows a **Data-Driven, Generative Architecture**. Instead of loading static puzzles, the app generates unique puzzles on demand by combining a **Puzzle Logic Generator** with a **Cultural Theme Engine**.

## Core Components (`src/Core`)

### 1. Data Models (`Models.swift`)
The data structure is strictly typed and UI-agnostic.
*   `ZebraPuzzle`: The generated puzzle instance.
*   `PuzzleRule`: An enum representing abstract logic constraints (e.g., `.isSame`, `.nextTo`). This separates the *logic* from the *text*.
*   `PuzzleCategory` & `PuzzleItem`: The entities involved.

### 2. Cultural Theme Engine (`ThemeEngine.swift`)
*   **Responsibility:** Maps abstract puzzle entities to specific cultural contexts.
*   **Input:** Theme Definition JSONs (e.g., `tr_local.json`, `en_classic.json`).
*   **Dynamic Text Generation:** Uses templates to convert `PuzzleRule`s into localized clues (e.g., "Item A is next to Item B" -> "Ahmet lives next to the Tea drinker").

### 3. Puzzle Generator (`PuzzleGenerator.swift`)
*   **Algorithm:**
    1.  Selects N Categories and M Items from the active Theme.
    2.  Generates a valid Solution Grid (randomized).
    3.  Derives a set of Logical Rules (`PuzzleRule`) that describe this solution.
    4.  Ensures solvability (currently via simple constraint selection).
    5.  Passes Rules to the Theme Engine to generate text clues.

### 4. Hint System (`HintSystem.swift`)
*   **Logic:** Analyzes the user's current grid state vs. the generated solution.
*   **Output:** Identifies the next logical step or a missing link (e.g., "Look for the connection between the Simit eater and the Tea drinker").

## Data Flow

1.  **User Selects Theme:** (e.g., "Turkish Local") -> App loads `src/Data/Themes/tr_local.json`.
2.  **User Hits 'New Puzzle':** `PuzzleGenerator` creates a `ZebraPuzzle` instance using the theme data.
3.  **Rendering:** `PuzzleView` (SwiftUI) renders the grid based on `puzzle.categories`.
4.  **Interaction:** User toggles cell states. `HintSystem` monitors progress.

## Scalability
*   **New Themes:** Add a new JSON file to `src/Data/Themes/`. No code changes required.
*   **New Logic:** Add new cases to `PuzzleRule` and update the Generator/Templates.
