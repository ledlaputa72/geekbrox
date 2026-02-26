# Dream Collector (꿈 수집가)
## Game Design Document v2.0 - 2D Mobile Idle Edition

**Document Date:** February 20, 2026  
**Document Version:** 2.0 (Major Revision)  
**Genre:** Idle / Incremental + Roguelike + Deckbuilding  
**Platform:** Mobile (iOS/Android) Primary, PC Secondary  
**Target Audience:** Ages 12+, fans of idle games and atmospheric experiences  
**Session Length:** 1-5 minutes (active), Continuous (idle progression)

---

## 📋 Document Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial GDD (3D Adventure/Puzzle) |
| 2.0 | 2026-02-20 | **Major Redesign:** 2D Mobile Idle Game |

**Key Changes in v2.0:**
- ✅ 3D → 2D visual style
- ✅ Active exploration → Idle automation
- ✅ PC-focused → Mobile-first
- ✅ 15-30 min sessions → 1-5 min sessions
- ✅ Complex puzzles → Strategic card-based choices
- ✅ Added: Offline progression, Auto-collection, Prestige system

---

## Table of Contents
1. [High Concept](#high-concept)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Idle Mechanics](#idle-mechanics)
4. [Card System (Deckbuilding)](#card-system-deckbuilding)
5. [Roguelike Elements](#roguelike-elements)
6. [Progression Systems](#progression-systems)
7. [Monetization (F2P Optional)](#monetization)
8. [Art Style Guide (2D)](#art-style-guide-2d)
9. [UI/UX Design (Mobile)](#uiux-design-mobile)
10. [Technical Specifications](#technical-specifications)

---

## High Concept

**One-Liner:** *Build your dream collection empire while you sleep—literally.*

Dream Collector is a **2D mobile idle game** where you automate the collection of dreams from sleeping souls. While you're away, your Dream Collector works tirelessly, gathering Reveries (dream fragments) that unlock new abilities, cards, and deeper dreamscapes. 

**Core Pillars:**
- **Idle Automation:** Dreams collect themselves over time
- **Strategic Deckbuilding:** Build the perfect deck of Dream Cards to optimize collection
- **Roguelike Runs:** Each Dreamer is a unique run with random events
- **Prestige Loop:** Ascend to unlock powerful meta-progression
- **Atmospheric Vibes:** Relaxing, meditative dream aesthetic

**Genre Fusion:**
- **Idle/Incremental** (Adventure Capitalist, Egg Inc.)
- **Deckbuilding** (Slay the Spire, Balatro)
- **Roguelike** (Hades, Dead Cells)
- **Collection** (Pokémon, Genshin Impact)

---

## Core Gameplay Loop

### Primary Loop (Active Play: 1-5 minutes)

```
1. OPEN APP → See accumulated offline progress
   ↓
2. COLLECT REWARDS (Reveries, Currency, Cards)
   ↓
3. CHOOSE NEXT DREAMER (Roguelike run)
   ↓
4. BUILD/ADJUST DECK (Select 8-12 Dream Cards)
   ↓
5. START DREAM RUN (Automated)
   ↓
6. MAKE STRATEGIC CHOICES (Card plays, branching paths)
   ↓
7. COMPLETE RUN → Earn rewards
   ↓
8. UPGRADE CARDS/ABILITIES
   ↓
9. CLOSE APP → Idle collection continues
```

### Idle Loop (Passive: While Closed)

```
Dream Collector auto-explores → Encounters play out automatically →
Reveries accumulate → Offline rewards cap at 8 hours →
Player returns to collect
```

### Meta Loop (Long-term: Days/Weeks)

```
COLLECT REVERIES → COMPLETE DREAM SETS → UNLOCK NEW DREAMERS →
PRESTIGE (ASCEND) → GAIN PERMANENT BONUSES → DEEPER CONTENT →
DISCOVER STORY CHAPTERS
```

---

## Idle Mechanics

### 1. Offline Progression

**How It Works:**
- **Base Rate:** Collect X Reveries per hour (based on your deck power)
- **Cap:** 8 hours of offline rewards (prevents infinite accumulation)
- **Notification:** Push notification when cap is reached
- **Collection:** Tap "Collect" to gather all accumulated rewards

**Idle Speed Modifiers:**
- **Card Synergies:** Certain card combinations boost idle rate
- **Prestige Bonuses:** Permanent multipliers from Ascending
- **Active Bonuses:** Temporary boosts from watching ads or IAP

### 2. Automation Systems

**Auto-Collection:**
- Dream Collector automatically navigates dreamscapes
- No player input required during idle time
- Returns to Archive when inventory is full

**Auto-Battle (Optional):**
- Nightmare encounters resolve automatically
- Uses your deck's AI strategy (set by player)
- Can be toggled off for manual play

**Auto-Upgrade:**
- Toggle to automatically spend currency on upgrades
- Respects player-set priority (Cards > Abilities > Dreamers)

### 3. Idle Optimization

Players optimize idle earnings through:
- **Deck Composition:** Cards with "Idle Boost" tags
- **Dreamer Selection:** Some Dreamers have higher idle rates
- **Upgrades:** Permanent upgrades to collection speed
- **Prestige:** Each Ascension increases base idle rate

---

## Card System (Deckbuilding)

### Card-Based Gameplay

Instead of direct character abilities, players build **decks of Dream Cards** that define their collection strategy.

### Card Types

#### 1. **Collection Cards** (Passive Income)
Increase Reverie collection rate.

**Example:**
```
[Memory Shard]
Type: Collection
Rarity: Common
Effect: +5 Reveries/hour
Upgrade: +2 per level
```

#### 2. **Action Cards** (Active Events)
Used during encounters/choices.

**Example:**
```
[Lucid Dream]
Type: Action
Cost: 2 Energy
Effect: Gain 50 Reveries instantly
Cooldown: 5 minutes
```

#### 3. **Synergy Cards** (Combos)
Bonus effects when played with specific cards.

**Example:**
```
[Nightmare Ward]
Type: Synergy
Effect: +20% Collection when paired with [Fear Dream]
Bonus: If 3+ Nightmare cards in deck, double effect
```

#### 4. **Event Cards** (Roguelike Randomness)
Drawn during runs, offer choices.

**Example:**
```
[Crossroads]
Type: Event
Choice A: Gain 100 Reveries (safe)
Choice B: 50% chance 500 Reveries, 50% lose 50 (risky)
```

### Deck Building Rules

- **Deck Size:** 8-12 cards (starts at 8, expands with upgrades)
- **Card Limit:** Max 3 copies of any card
- **Rarity Balance:** Higher rarity cards have deck cost (balancing)
- **Synergy Focus:** Encourage thematic decks (all Nightmare, all Memory, etc.)

### Card Acquisition

- **Drops:** Earn cards from completing runs
- **Shop:** Purchase specific cards with currency
- **Crafting:** Combine duplicate cards to upgrade
- **Gacha (Optional):** Card packs for IAP (not required)

---

## Roguelike Elements

### Run Structure

Each Dreamer is a **roguelike run**:

1. **Select Dreamer** (Difficulty/Theme)
2. **Build Deck** (8-12 cards)
3. **Enter Dreamscape** (Automated exploration)
4. **Encounter Events** (Random)
5. **Complete Run** (Success = rewards, Failure = partial rewards)

### Procedural Events

During each run, encounter random events:

| Event Type | Frequency | Effect |
|------------|-----------|--------|
| Memory Node | 60% | Collect Reveries (safe) |
| Choice Event | 20% | Pick from 2-3 options (risk/reward) |
| Nightmare Battle | 15% | Use Action cards to fight |
| Treasure | 5% | Bonus rare cards/currency |

### Permadeath Lite

- **Run Failure:** Lose run-specific rewards, keep 50% of Reveries
- **Persistent Progress:** Card upgrades and Prestige bonuses carry over
- **No Penalty:** Failing is part of learning and experimentation

---

## Progression Systems

### 1. Card Upgrades

- **Leveling:** Spend Reveries to level up cards (increase effects)
- **Evolution:** Rare cards can evolve into Epic at max level
- **Awakening:** Special upgrade that adds new effect

### 2. Prestige System (Ascension)

**When to Prestige:**
- Unlocked after collecting 10,000 Reveries
- Resets most progress BUT grants permanent bonuses

**Prestige Bonuses:**
- **Dream Shards:** Permanent currency, spend on:
  - +10% Idle Rate (stackable)
  - Unlock new Dreamers
  - Unlock card slots
  - Unlock auto-features

**Prestige Tiers:**
- Tier 1: +10% Idle, unlock 2 Dreamers
- Tier 2: +25% Idle, unlock rare cards
- Tier 3: +50% Idle, unlock Nightmare mode
- ...
- Tier 10: +500% Idle, unlock secret ending

### 3. Dream Archive (Collection)

- **Reverie Gallery:** Visual collection of all Reveries found
- **Lore Entries:** Reading unlocks story fragments
- **Completion Rewards:** Bonus when completing themed sets

### 4. Dreamer Progression

- **Unlock Dreamers:** Through prestige and story milestones
- **Dreamer Levels:** Repeat runs with same Dreamer = better rewards
- **Dreamer Bonuses:** Each Dreamer has unique passive ability

---

## Monetization (F2P Optional)

**Business Model:** Free-to-play with optional IAP

### Free Player Experience

- **Full Game:** All content accessible for free
- **Progression:** Slower but fair grind
- **Ads:** Optional ad views for temporary boosts

### Monetization Pillars

#### 1. **Time Acceleration**
- **Double Idle Speed (1 hour):** $0.99
- **Instant Collection:** $0.99 (collect idle rewards immediately)

#### 2. **Card Packs**
- **Standard Pack (5 cards):** $1.99
- **Premium Pack (10 cards, 1 guaranteed rare):** $4.99
- NOT Pay-to-Win: All cards obtainable free

#### 3. **Cosmetics**
- **Dream Themes:** Change visual style ($2.99)
- **Collector Skins:** Customize your avatar ($1.99)

#### 4. **Battle Pass**
- **Season Pass ($9.99):** 
  - Exclusive cards
  - Bonus currency
  - Cosmetic rewards
- **Free Track:** Everyone gets some rewards

#### 5. **Remove Ads**
- **Permanent:** $4.99 (one-time)

### Monetization Philosophy

- **No Gacha Gambling:** Card packs show contents
- **No Energy System:** Play as much as you want
- **No Paywalls:** All content unlockable free
- **Generous F2P:** Daily login rewards, events

---

## Art Style Guide (2D)

### Visual Aesthetic

**Style:** **Hand-painted 2D Illustrative + Particle Effects**

**Reference Games:**
- Gris (color palette, minimalism)
- Monument Valley (impossible geometry, color)
- Florence (emotional storytelling)
- Hades (stylized characters, VFX)

### Color Palette

**Dream Themes:**
Each Dreamer has a unique color palette:

| Theme | Primary | Secondary | Accent |
|-------|---------|-----------|--------|
| Serenity | Soft Blue | Lavender | White |
| Anxiety | Dark Purple | Gray | Sharp Red |
| Nostalgia | Warm Orange | Sepia | Gold |
| Fear | Deep Black | Blood Red | Pale Yellow |
| Joy | Bright Yellow | Pink | Sky Blue |

### Character Design (2D)

**Dream Collector:**
- Minimalist silhouette (gender-neutral)
- Flowing cloak with particle trail
- Glowing eyes (only facial feature)
- Floats/hovers (no walking animation needed)

**Dreamers (NPCs):**
- Appear as stylized portraits (not full body)
- Distorted/abstract facial features (dream logic)
- Background reflects their theme

### Environment (2D Layers)

**Parallax Scrolling:**
- Background layer (slow)
- Mid-ground (medium)
- Foreground (fast)
- Particle overlay (floating dream essence)

**Dreamscape Elements:**
- Floating islands/platforms
- Impossible architecture (Escher-inspired)
- Ethereal vegetation
- Memory fragments (glowing orbs)

### UI/UX Aesthetic

- **Glassmorphism:** Semi-transparent panels with blur
- **Soft Shadows:** Depth without harshness
- **Glow Effects:** Interactive elements glow
- **Smooth Animations:** All transitions eased

---

## UI/UX Design (Mobile)

### Screen Layout

#### 1. **Home/Archive Screen**
```
┌─────────────────────────┐
│ [Currency] [Settings]   │ ← Top Bar
├─────────────────────────┤
│                         │
│   [Dream Collector]     │ ← Center: Character Idle Animation
│                         │
├─────────────────────────┤
│ [Collect: 345 Reveries] │ ← Big Button (Tap to collect offline)
├─────────────────────────┤
│ [Start Run] [Cards]     │
│ [Upgrade]  [Prestige]   │ ← Bottom: Main Navigation
└─────────────────────────┘
```

#### 2. **Deck Builder Screen**
```
┌─────────────────────────┐
│ [← Back]  Deck Builder  │
├─────────────────────────┤
│ Current Deck (8/12):    │
│ [Card] [Card] [Card]... │ ← Horizontal Scroll
├─────────────────────────┤
│ All Cards:              │
│ [Filters: ▼ Type ▼ Rarity]
│                         │
│ [Card Grid]             │ ← Scrollable Grid
│ [Card] [Card] [Card]    │
│ [Card] [Card] [Card]    │
└─────────────────────────┘
```

#### 3. **Run In Progress**
```
┌─────────────────────────┐
│ Progress: ████▁▁▁▁ 50%  │
├─────────────────────────┤
│                         │
│   [Dreamscape View]     │ ← Animated Background
│   [Collector Moving]    │
│                         │
├─────────────────────────┤
│ Event: [Choice Card]    │
│ [Option A] [Option B]   │ ← Player Choice
├─────────────────────────┤
│ [Skip] [Speed Up 2x]    │
└─────────────────────────┘
```

### Touch Controls

**Gestures:**
- **Tap:** Select/Confirm
- **Swipe:** Navigate menus/cards
- **Long Press:** View card details
- **Pinch:** N/A (no zoom needed)

**Accessibility:**
- **Large Tap Targets:** Minimum 44x44pt
- **Haptic Feedback:** On important actions
- **Color Blind Mode:** Alternative palettes
- **Text Size:** Adjustable (Small/Medium/Large)

---

## Technical Specifications

### Platform

**Primary:** Mobile (iOS 14+, Android 10+)  
**Secondary:** PC (Steam, via Unity/Godot export)

### Engine

**Recommended:** Unity 2D or Godot 4.x

**Reasoning:**
- Excellent 2D tools
- Mobile export (iOS/Android)
- Cross-platform (PC secondary)
- Large asset ecosystem
- Strong community

### Technical Requirements

#### Mobile
- **Minimum:**
  - iPhone 8 / Android 10
  - 2GB RAM
  - 500MB storage
- **Recommended:**
  - iPhone 12 / Android 12
  - 4GB RAM
  - 1GB storage

#### PC (Secondary)
- **Minimum:**
  - Windows 10 / macOS 10.15
  - Intel i3 / Ryzen 3
  - 4GB RAM
  - Integrated GPU
- **Recommended:**
  - Windows 11 / macOS 12
  - Intel i5 / Ryzen 5
  - 8GB RAM
  - Dedicated GPU (optional)

### Performance Targets

- **Frame Rate:** 60 FPS (mobile), 120 FPS (PC)
- **Battery:** <5% per hour (idle mode)
- **Load Time:** <3 seconds (cold start)
- **Memory:** <300MB RAM (mobile)

### Technology Stack

**Core:**
- Engine: Unity 2D / Godot 4.x
- Language: C# (Unity) or GDScript (Godot)
- Version Control: Git (GitHub)

**Backend (Optional - for cloud saves):**
- Firebase (free tier sufficient)
- PlayFab (Unity-friendly)
- Or: Local save only (simpler)

**Analytics:**
- Unity Analytics / Google Analytics
- Optional: Mixpanel for retention tracking

**Monetization:**
- Unity Ads / AdMob (video ads)
- Unity IAP / Google Play Billing (purchases)

---

## Development Roadmap (2D Mobile Idle)

### Phase 1: Core Prototype (Weeks 1-4)

**Goal:** Playable idle loop + basic card system

**Features:**
- ✅ Idle progression (offline rewards)
- ✅ 10 starter cards
- ✅ 1 Dreamer (Serenity theme)
- ✅ Basic UI (Home, Deck Builder, Run)
- ✅ Card leveling

### Phase 2: Content Expansion (Weeks 5-8)

**Goal:** Roguelike variety + more cards

**Features:**
- ✅ 5 Dreamers (different themes)
- ✅ 50 total cards
- ✅ Event system (choices during runs)
- ✅ Nightmare encounters
- ✅ Card synergies

### Phase 3: Meta Progression (Weeks 9-12)

**Goal:** Long-term retention

**Features:**
- ✅ Prestige system (Ascension)
- ✅ Dream Archive (collection)
- ✅ Story chapters (lore)
- ✅ Daily quests/rewards

### Phase 4: Polish & Monetization (Weeks 13-16)

**Goal:** Launch-ready

**Features:**
- ✅ Full art assets (2D illustrations)
- ✅ Sound & music
- ✅ IAP implementation (ethical)
- ✅ Ad integration (optional)
- ✅ Tutorial & onboarding

### Phase 5: Beta & Launch (Weeks 17-20)

**Goal:** Soft launch → Global launch

**Milestones:**
- ✅ Closed beta (TestFlight / Google Play Beta)
- ✅ Metrics & balancing
- ✅ Soft launch (1 country)
- ✅ Global launch

---

## Key Differences from v1.0

| Aspect | v1.0 (3D Puzzle) | v2.0 (2D Idle) |
|--------|------------------|----------------|
| **Perspective** | 3rd-person 3D | 2D side-view / top-down |
| **Platform** | PC primary | Mobile primary |
| **Gameplay** | Active exploration/puzzles | Idle automation |
| **Session** | 15-30 min | 1-5 min |
| **Core Loop** | Explore → Puzzle → Collect | Build Deck → Run → Idle |
| **Skill** | Puzzle-solving, reflexes | Strategy, deck optimization |
| **Art** | 3D models, dynamic camera | 2D illustrations, parallax |
| **Monetization** | Premium ($15-20) | F2P + IAP |

---

## Why This Pivot?

### Advantages of 2D Mobile Idle:

1. **Lower Dev Cost:**
   - 2D art cheaper than 3D modeling
   - Smaller team (1-3 people)
   - Faster iteration

2. **Larger Market:**
   - Mobile gaming > PC gaming (revenue)
   - Idle genre proven success (Egg Inc., AdVenture Capitalist)
   - Accessible to casual audience

3. **Retention Mechanics:**
   - Daily login rewards
   - Prestige loop (play forever)
   - Idle progression (no FOMO)

4. **Hybrid Genre Appeal:**
   - Idle fans (passive gameplay)
   - Deckbuilding fans (Slay the Spire audience)
   - Roguelike fans (replayability)

### Risks Mitigated:

- **Puzzle Fatigue:** Idle removes frustration of stuck puzzles
- **Session Length:** Mobile players want short sessions
- **Monetization:** F2P model more proven than premium

---

## Next Steps

1. ✅ **Finalize GDD v2.0** (this document)
2. ⏳ **Paper Prototype** (card system on paper)
3. ⏳ **Tech Stack Decision** (Unity vs Godot)
4. ⏳ **Art Style Test** (mock up 1 Dreamer)
5. ⏳ **Core Loop Prototype** (playable in 2 weeks)

---

**Document Status:** ✅ Complete  
**Next Review:** After Paper Prototype (Week 1)  
**Approvals Needed:** Steve PM (Owner)

---

_GDD v2.0 | Dream Collector (2D Mobile Idle Edition) | © GeekBrox 2026_
