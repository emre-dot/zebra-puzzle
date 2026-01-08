# Zebra Puzzle Pro - Project Roadmap & Strategy (2026 Edition)

## Overview
**Project Name:** Zebra Puzzle Pro (Global Edition)
**Target Markets:** USA, Turkey, Japan
**Core Value Proposition:** A culturally immersive logic puzzle experience that adapts its narrative to the player's region while maintaining universal logic rules.

---

## 1. Multi-Language & Cultural Engine (The "Culture-First" Approach)
In 2026, simple translation is insufficient. Users expect "hyper-localization." We will build a **Cultural Adaptation Engine** that decouples the *logic skeleton* of a puzzle from its *narrative skin*.

### Supported Languages & Themes

#### 🇺🇸 USA / Global (English)
*   **Focus:** Urban lifestyle, Tech culture, Pop culture.
*   **Themes:**
    *   *Silicon Valley Startup:* Founders, coding languages, coffee preferences, office pets.
    *   *New York Jazz Clubs:* Musicians, instruments, drink orders, jazz standards.
    *   *National Parks:* Campers, gear, wildlife sightings, trails.

#### 🇹🇷 Turkey (Turkish)
*   **Focus:** Traditional richness, Modern Istanbul life, Culinary heritage.
*   **Themes:**
    *   *Kapalıçarşı Esnafı (Grand Bazaar Merchants):* Selling carpets/spices, drinking tea/coffee, shop locations.
    *   *Ege Ot Festivali (Aegean Herb Festival):* Chefs, local herbs (şevketi bostan, radika), olive oil dishes.
    *   *Vapur Yolculuğu (Ferry Commute):* Passengers, newspapers, tea/simit combos, destinations (Kadıköy, Beşiktaş).

#### 🇯🇵 Japan (Japanese)
*   **Focus:** Harmony, Seasonal appreciation, Otaku culture, Traditional arts.
*   **Themes:**
    *   *Kyoto Tea Ceremony:* Kimono patterns, tea utensils, wagashi (sweets), seasons.
    *   *Akihabara Tech Expo:* Gadgets, anime figures, cosplay types, release dates.
    *   *Hanami (Cherry Blossom Viewing):* Locations, bento box contents, sake types.

---

## 2. Dynamic Content Generation Pipeline

### The Logic vs. Narrative Split
We will use a "Template + Dictionary" approach.
1.  **Logic Skeleton:** Abstract entities (Item A, Item B, Item C) and constraints (A is next to B).
2.  **Cultural Dictionaries:** Key-value pairs of culturally equivalent terms.

### 2026 Trend: Generative AI for Contextual Nuance
*   **Pipeline:**
    *   *Step 1:* Generate a valid logic grid (mathematically solvable).
    *   *Step 2:* Select a "Cultural Theme" (e.g., "Breakfast").
    *   *Step 3:* Map abstract entities to cultural items via AI or curated lists.
        *   *US:* Bagel, Cream Cheese, Coffee.
        *   *TR:* Simit, Labne, Çay.
        *   *JP:* Shokupan, Butter, Matcha Latte.
    *   *Step 4:* Generate localized clues using idiomatic expressions.

### Example: Clue "The person eating [Item A] is next to the person drinking [Item B]"
*   **English:** "The guy munching on a **Bagel** is sitting right next to the **Espresso** drinker."
*   **Turkish:** "**Simit** yiyen kişi, **Çay** içen kişinin hemen yanındadır."
*   **Japanese:** "**おにぎり**を食べている人は、**緑茶**を飲んでいる人の隣にいます。"

---

## 3. Global Monetization Strategies

We will adopt a **Hybrid Model** optimized for regional purchasing power and user behavior trends in 2026.

### 🇺🇸 USA / 🇪🇺 Europe (High Purchasing Power)
*   **Primary:** Subscription (Weekly/Yearly).
*   **Features:** Unlimited puzzles, "Zen Mode" (no ads), detailed statistics, cloud sync.
*   **Strategy:** "Puzzle Pass" - focuses on daily habits and brain training benefits.
*   **Price Point:** $4.99/month or $39.99/year.

### 🇹🇷 Turkey / Emerging Markets (Price Sensitive / Ad-Tolerant)
*   **Primary:** Freemium + Rewarded Ads.
*   **Strategy:**
    *   Lower subscription price (localized pricing ~30-40% of US price).
    *   **High-Frequency Rewarded Ads:** Watch an ad to get a hint, undo a mistake, or unlock a specific "Premium Theme" pack.
    *   **Micro-transactions:** One-time purchase for specific theme packs (e.g., "The Ottoman History Pack").

### 🇯🇵 Japan (Gacha / Collection / Quality Focus)
*   **Primary:** One-time Unlock + Cosmetic Gacha.
*   **Strategy:**
    *   Japanese users often prefer high-quality, ad-free experiences or "collection" mechanics.
    *   **Decoration System:** Solving puzzles earns currency to decorate a virtual "Study" or "Zen Garden."
    *   **Premium Unlock:** A higher upfront cost to remove ads forever, rather than a subscription.

---

## 4. Technical Architecture Highlights (SwiftUI)
*   **MVVM Architecture:** Clean separation of Puzzle Logic (Model) and UI (View).
*   **Protocol-Oriented Programming:** `PuzzleThemeProtocol` to enforce structure across cultural modules.
*   **Combine Framework:** For reactive UI updates when puzzle state changes.
*   **CloudKit:** For syncing progress across devices (essential for US/JP markets).
