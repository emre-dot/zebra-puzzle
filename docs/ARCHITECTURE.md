# Technical Architecture
## Overview

The app is built using **SwiftUI** for a declarative UI and follows the **MVVM (Model-View-ViewModel)** pattern to ensure separation of concerns. The core architecture relies on a **Data-Driven Design**, where the UI is completely agnostic of the specific cultural content it is displaying.

## Core Components

### 1. Data Models (`PuzzleDataModels.swift`)
The data structure is designed to be serializable to/from JSON.
*   `ZebraPuzzle`: Root object containing all puzzle data.
*   `CulturalContext`: Metadata describing the language and theme.
*   `PuzzleCategory` & `PuzzleItem`: Define the grid structure (Rows/Columns).
*   `PuzzleClue`: The instructions for the player.

### 2. Localization & Content Engine (`LocalizationManager.swift`)
This is the heart of the "Cultural Engine."
*   **Responsibility:** Manages the active language/culture state.
*   **Dynamic Loading:** Instead of hardcoding puzzle data, it loads JSON files based on the user's selected region.
*   **Future Proofing:** In a production environment, this would interface with a backend API (AWS Lambda / Firebase) that generates puzzles on the fly or fetches them from a CMS (Content Management System).

### 3. Separation of Logic and Narrative
The architecture explicitly separates the *mathematical logic* of the puzzle from the *textual representation*.
*   **Logic Layer:** Solves constraints (e.g., `Entity(1,1)` != `Entity(2,1)`).
*   **Presentation Layer:** Maps `Entity(1,1)` to "Green House" (US) or "Yeşil Ev" (TR).

## JSON Data Flow
1.  App requests a "Medium" puzzle.
2.  `LocalizationManager` checks `currentLanguageCode` (e.g., `tr-TR`).
3.  App loads `sample_puzzle_tr.json`.
4.  `JSONDecoder` parses it into `ZebraPuzzle` struct.
5.  ViewModel exposes `ZebraPuzzle` to the SwiftUI View.
6.  SwiftUI View renders the grid using `puzzle.categories` and `puzzle.items`.

## Scalability for 2026
*   **Server-Side Generation:** The JSON structure allows the backend to generate infinite variations using AI, which the client can render without app updates.
*   **Hot-Swappable Themes:** New cultural themes (e.g., for holidays like Ramadan or Thanksgiving) can be deployed simply by pushing new JSON files.
