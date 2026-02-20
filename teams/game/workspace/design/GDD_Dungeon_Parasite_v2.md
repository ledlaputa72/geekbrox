# Dungeon Parasite (던전 기생충)
## Game Design Document v2.0 - 2D Mobile Edition

**Document Date:** February 20, 2026  
**Document Version:** 2.0 (Major Revision)  
**Genre:** Roguelike Deckbuilder / Parasitic Strategy  
**Platform:** Mobile (iOS/Android) Primary, PC Secondary  
**Target Audience:** Ages 16+, fans of Slay the Spire, Monster Train, and dark fantasy  
**Session Length:** 5-15 minutes per run

---

## 📋 Document Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial GDD (PC Roguelike Deckbuilder) |
| 2.0 | 2026-02-20 | **Major Redesign:** 2D Mobile Touch-Optimized |

**Key Changes in v2.0:**
- ✅ PC-focused → Mobile-first design
- ✅ Complex 3D visuals → Stylized 2D art
- ✅ Long runs (45-60 min) → Short runs (5-15 min)
- ✅ Mouse/keyboard → Touch gestures optimized
- ✅ Streamlined UI for vertical mobile screens
- ✅ Added: Quick Run mode, Daily Challenges, Cloud saves

---

## Table of Contents
1. [High Concept](#high-concept)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Possession & Combat Mechanics](#possession--combat-mechanics)
4. [Deck System](#deck-system)
5. [Progression Systems](#progression-systems)
6. [Mobile-Specific Features](#mobile-specific-features)
7. [Monetization (Premium)](#monetization-premium)
8. [Art Style Guide (2D)](#art-style-guide-2d)
9. [UI/UX Design (Mobile)](#uiux-design-mobile)
10. [Technical Specifications](#technical-specifications)

---

## High Concept

**One-Liner:** *You are the monster—possess, mutate, and consume your way through dungeons.*

**Dungeon Parasite** is a dark 2D mobile roguelike deckbuilder where you play as a parasitic entity that hijacks dungeon monsters. Instead of fighting enemies, you **become them**—controlling their bodies, stealing their powers, and evolving through grotesque mutations. 

**Core Pillars:**
- **Parasitic Possession:** Body-swap mid-combat for tactical advantage
- **Infection & Mutation:** Turn enemies into infected allies
- **Adaptive Deckbuilding:** Cards change based on which host you inhabit
- **Dark Fantasy Aesthetic:** Grotesque, Lovecraftian body horror

**Unique Selling Points:**
1. **Host-Swapping Mechanic:** Switch bodies mid-combat (unique to the genre)
2. **Dual-Deck System:** Parasite core + host-specific cards
3. **Cannibalism System:** Consume hosts for permanent power (risk/reward)
4. **Mobile-Optimized:** 5-15 minute runs, portrait mode, one-handed play

**Genre Fusion:**
- **Roguelike Deckbuilder** (Slay the Spire, Monster Train)
- **Body Horror Strategy** (Carrion, Prototype)
- **Dark Fantasy** (Darkest Dungeon, Dead Cells)

---

## Core Gameplay Loop

### Primary Loop (Single Run: 5-15 minutes)

```
1. SELECT PARASITE STRAIN (Starting loadout)
   ↓
2. POSSESS STARTING HOST (Weak monster)
   ↓
3. NAVIGATE DUNGEON (8 floors, 3 choices per floor)
   ↓
4. ENCOUNTER (Combat 70%, Event 20%, Shop 10%)
   ↓
5. COMBAT: Play cards, infect enemies, switch hosts
   ↓
6. WIN: Choose rewards (new cards, mutations, gold)
   ↓
7. DECISION: Consume host (power now) or Keep (flexibility later)
   ↓
8. REPEAT until Boss Fight (Floor 8)
   ↓
9. BOSS BATTLE: Ultimate possession challenge
   ↓
10. RUN COMPLETE: Unlock meta progression
```

### Combat Loop (Per Encounter: 1-3 minutes)

```
YOUR TURN:
  Draw 5 cards → Play cards (cost energy) → 
  Attack/Defend/Infect → 
  Switch Host (optional, 1 energy) →
  End Turn

ENEMY TURN:
  Enemies attack active host → 
  Check host integrity (if HP = 0, forced eject) →
  Your Turn

VICTORY:
  Consume or preserve defeated enemies →
  Choose reward →
  Continue
```

### Meta Progression Loop

```
Complete Runs → Unlock Parasite Strains → 
Unlock Mutation Trees → Gain DNA Points → 
Unlock Starting Hosts → Ascension Levels
```

---

## Possession & Combat Mechanics

### 1. Possession System

**Core Concept:**
You are a parasitic organism. You MUST inhabit a host body to survive. Losing all hosts = Game Over.

**Host Slots:**
- Start: 1 host slot
- Unlock: Up to 3 host slots (via meta upgrades)
- Active Host: Takes damage, provides cards
- Inactive Hosts: Safe, can't act

**Host Categories:**

| Tier | Examples | HP | Deck Size | Infection % |
|------|----------|-----|-----------|-------------|
| **Fodder** | Goblin, Rat, Slime | 30 | 3 cards | 80% |
| **Standard** | Skeleton, Orc, Spider | 60 | 5 cards | 60% |
| **Elite** | Minotaur, Gargoyle, Wraith | 100 | 7 cards | 40% |
| **Boss** | Dragon, Lich, Demon Lord | 150 | 10 cards | 20% |

**Possession Mechanics:**

**Infection Roll:**
- Base success chance depends on tier
- +15% per turn target is below 50% HP
- +10% if target is stunned/debuffed
- -20% if target is Boss tier
- Failure: Waste 1 energy, can retry next turn

**Host Swapping:**
- Costs: 1 energy
- Instant: No action delay
- Limit: Once per turn
- Tactical Use: Avoid damage, activate host-specific abilities

### 2. Combat System

**Turn Structure:**

**Phase 1: Draw Phase**
- Draw 5 cards (from Parasite Deck + Active Host Deck)
- Gain 3 energy (base) + host bonuses
- Check status effects (poison, buffs, etc.)

**Phase 2: Action Phase (Your Turn)**
- Play cards (unlimited, until energy runs out)
- Attack, defend, infect, mutate
- Switch host (1 energy, once per turn)
- End turn manually OR auto-end when no energy

**Phase 3: Enemy Phase**
- Enemies act in initiative order (shown via intent icons)
- Attacks target your active host
- Special enemy abilities trigger

**Phase 4: End Phase**
- Status effects tick (poison, regen, etc.)
- Check host integrity (if HP ≤ 0, forced ejection)
- New turn begins

**Ejection State (Emergency):**
- If active host dies, parasite ejects automatically
- Parasite Form: 15 HP, can only play Parasite Core cards
- MUST infect new host within 2 turns or game over
- Vulnerable: Takes double damage

### 3. Infection Mechanic

**How to Infect:**
1. Play "Infection" cards (reduce target HP)
2. When target is low HP, attempt possession
3. Roll based on tier (80% Fodder, 20% Boss)
4. Success: Enemy becomes your host, full HP restored
5. Failure: Wasted energy, target becomes enraged (+25% damage)

**Infected Enemies:**
- Become permanent allies (for this combat)
- Act on your turn
- Provide their deck to your card pool
- Can be consumed post-combat for permanent power

---

## Deck System

### Dual-Deck Mechanic

**1. Parasite Core Deck (15 cards)**
Your true identity. Always accessible regardless of host.

**Categories:**
- **Infection Cards:** Deal damage + infect chance
- **Mutation Cards:** Permanent buffs to parasite
- **Energy Cards:** Generate extra energy
- **Utility Cards:** Draw, heal, debuff

**Example Cards:**
```
[Tendril Strike]
Cost: 1 | Deal 8 damage. If kills, 100% infect.

[Neural Hijack]
Cost: 2 | Control enemy for 1 turn.

[Metabolic Drain]
Cost: 1 | Drain 15 HP from host, gain 2 energy.
```

**2. Host Deck (3-10 cards per host)**
Each possessed body adds unique cards. Only available when that host is active.

**Example: Skeleton Host**
```
[Bone Spear]
Cost: 1 | Deal 10 damage.

[Death Rattle]
Cost: 0 | Passive: When this host dies, deal 20 AOE damage.

[Reassemble]
Cost: 2 | Restore 30 HP to this host.
```

**Example: Orc Host**
```
[Brutal Cleave]
Cost: 2 | Deal 18 damage. Draw 1 card.

[Rage]
Cost: 1 | +5 damage to all attacks this turn. Lose 5 HP.

[War Cry]
Cost: 1 | All infected allies gain +3 damage this turn.
```

### Card Acquisition

- **Post-Combat Rewards:** Choose 1 of 3 cards
- **Shops:** Buy specific cards (gold)
- **Events:** Random card rewards
- **Consume Host:** Gain 1 signature card permanently

### Card Upgrade System

- **Campfires:** Upgrade 1 card (every 3 floors)
- **Elite Victories:** Guaranteed rare card
- **Consume Host:** Auto-upgrade all host cards

---

## Progression Systems

### 1. Within-Run Progression

**Deck Building:**
- Start: 15 Parasite cards + 1 host (5 cards) = 20 cards
- End: 25-30 cards (ideal)
- Remove cards: Available at shops (gold cost)

**Mutations (Temporary Buffs):**
- Earned from Events and Elite victories
- Examples:
  - *Reinforced Carapace:* +20 max HP to all hosts
  - *Rapid Regeneration:* Heal 5 HP per turn
  - *Multi-Infection:* Can attempt 2 infections per turn

**Gold & Shops:**
- Gold from victories
- Shops every 4-5 floors
- Buy: Cards, potions, host upgrades

### 2. Meta Progression (Between Runs)

**Parasite Strains (Starting Loadouts):**
Unlock 8 unique strains, each with different starting deck.

| Strain | Starting Deck | Playstyle |
|--------|---------------|-----------|
| **Hivemind** | Multi-infection focus | Swarm many weak hosts |
| **Apex Predator** | High-damage, risky | Solo one strong host |
| **Shapeshifter** | Host-swapping bonuses | Fluid, adaptive |
| **Plague Bearer** | Poison & DOT | Slow, grindy |

**DNA Points (Currency):**
- Earned: 50-200 per run (based on performance)
- Spend on:
  - Unlock Parasite Strains (500 DNA)
  - Unlock Starting Hosts (300 DNA)
  - Permanent Upgrades (+1 card draw, +1 energy, etc.)

**Ascension Levels (Difficulty Tiers):**
- 20 Ascension levels
- Each adds modifiers (enemies stronger, you weaker)
- Rewards: More DNA, exclusive unlocks

### 3. Achievements & Challenges

- **Daily Run:** Fixed seed, leaderboard
- **Weekly Challenge:** Special modifiers
- **Achievements:** 50+ achievements (unlocks cosmetics)

---

## Mobile-Specific Features

### 1. Touch Gestures

**Optimized for One-Handed Play:**
- **Tap:** Select card, play card
- **Drag:** Drag card to target enemy (attack)
- **Long Press:** View card details
- **Swipe:** Switch between hosts (swipe left/right on portrait)
- **Pinch:** Zoom into battlefield (optional)

### 2. Portrait Mode UI

**Screen Layout:**
```
┌─────────────────┐
│ [Energy] [HP]   │ ← Top: Resources
├─────────────────┤
│                 │
│  [Enemy Area]   │ ← Enemies (horizontally scrollable if >3)
│  🦴 👹 🐉        │
│                 │
├─────────────────┤
│  [Active Host]  │ ← Your current body (large)
│      🧟         │
├─────────────────┤
│ [Inactive Hosts]│ ← Swipe to switch (if unlocked)
│   🐀 ⚔️         │
├─────────────────┤
│ [Hand: 5 Cards] │ ← Horizontally scrollable
│ 🃏🃏🃏🃏🃏       │
│ [End Turn]      │ ← Big button
└─────────────────┘
```

### 3. Session Flexibility

**Quick Run Mode:**
- 8 floors → 5 floors (6-10 min runs)
- Reduced card pool (easier decisions)
- For commute gaming

**Standard Run Mode:**
- 8 floors (10-15 min runs)
- Full experience

**Endless Mode (Unlock after 5 victories):**
- Infinite floors, scaling difficulty
- Leaderboard

### 4. Cloud Save & Cross-Play

- Sync via Google Play / iCloud
- Play on phone, continue on tablet/PC
- No loss of progress

---

## Monetization (Premium)

**Business Model:** Premium (Paid Upfront)

**Pricing:** $4.99 (Mobile), $9.99 (PC/Steam)

**Why Premium:**
- No ads
- No IAP
- No energy system
- Complete game on purchase
- Aligns with roguelike community expectations

**Post-Launch Content (Optional):**
- **Expansion DLC ($2.99):** 
  - 3 new Parasite Strains
  - 10 new host types
  - New dungeon layer (Hell theme)
- **Cosmetic Pack ($0.99):**
  - Alternative parasite skins
  - Card back designs

---

## Art Style Guide (2D)

### Visual Aesthetic

**Style:** **Dark Fantasy Hand-Painted 2D + Pixel Art Hybrid**

**Reference Games:**
- Darkest Dungeon (gothic, painterly)
- Dead Cells (fluid animation, pixel art)
- Slay the Spire (clean UI, readable cards)
- Inscryption (creepy, hand-drawn cards)

### Color Palette

**Core Palette:**
- **Primary:** Deep Crimson (blood), Bone White, Shadow Black
- **Secondary:** Putrid Green (infection), Bruise Purple, Rust Brown
- **Accents:** Glowing Teal (parasite energy), Sickly Yellow (weak spots)

**Mood:** Oppressive, claustrophobic, visceral

### Character Design (2D)

**Parasite (Player):**
- Amorphous blob with tendrils
- Glowing core (cyan/teal)
- Pulsating, organic animation
- No face, pure body horror

**Hosts (Monsters):**
- Stylized, exaggerated proportions
- Visible infection veins (glowing teal) when possessed
- Each tier has distinct silhouette
- Fodder: Small, pathetic
- Elite: Imposing, detailed
- Boss: Screen-filling, multi-phase

**Infected State:**
- Glowing eyes (cyan)
- Veins/tendrils visible under skin
- Twitchy, unnatural movement
- Mouth dripping parasite residue

### Environment (2D Layers)

**Dungeon Themes:**
1. **Crypt:** Bone piles, cobwebs, torches
2. **Sewers:** Slime, dripping water, rats
3. **Hell:** Fire, brimstone, chains

**Parallax Layers:**
- Background: Stone walls, ambient flames
- Midground: Platforms, obstacles
- Foreground: Fog, particle effects

### Card Art

- **Illustration Style:** Hand-painted, grotesque detail
- **Frame:** Organic, bone-like borders
- **Energy Cost:** Glowing number (top-left)
- **Card Rarity:** 
  - Common: Gray border
  - Uncommon: Green border
  - Rare: Purple border
  - Legendary: Gold border

---

## UI/UX Design (Mobile)

### Design Principles

1. **Readability First:** Large text, high contrast
2. **One-Handed Play:** All buttons in thumb reach
3. **Fast Decisions:** Auto-zoom on drag targets
4. **Minimal Clutter:** Hide non-essential info until tapped

### Core Screens

#### 1. Main Menu
```
┌─────────────────┐
│  DUNGEON        │ ← Title
│  PARASITE       │
├─────────────────┤
│ [Continue Run]  │ ← If run in progress
│ [New Run]       │
│ [Daily Run]     │
│ [Collection]    │ ← View unlocked cards/hosts
│ [Upgrades]      │ ← Spend DNA points
│ [Settings]      │
└─────────────────┘
```

#### 2. Pre-Run Setup
```
┌─────────────────┐
│ SELECT STRAIN   │
├─────────────────┤
│ [Hivemind] 🦠   │ ← Swipe to browse
│ Multi-infection │
│ focus           │
├─────────────────┤
│ [Start Run]     │
│ [Ascension: 3]  │ ← Difficulty toggle
└─────────────────┘
```

#### 3. Combat (Primary Screen)
See "Portrait Mode UI" section above.

**Combat Feedback:**
- **Damage Numbers:** Fly up from targets
- **Healing:** Green +HP text
- **Energy Cost:** Cards briefly glow when played
- **Host Switch:** Screen flashes (fast transition)

#### 4. Reward Screen
```
┌─────────────────┐
│ VICTORY!        │
├─────────────────┤
│ Choose 1 Reward:│
│                 │
│ [Card 1]        │ ← Tap to see details
│ [Card 2]        │
│ [Card 3]        │
├─────────────────┤
│ Defeated Host:  │
│ 🦴 Skeleton     │
│ [Consume] [Keep]│ ← Major decision
└─────────────────┘
```

**Consume vs. Keep:**
- **Consume:** Gain 1 signature card permanently, lose host forever
- **Keep:** Host remains in pool (can use in future combats)

### Accessibility Features

- **Colorblind Mode:** Alternative color schemes
- **Text Size:** Small / Medium / Large
- **Screen Reader Support:** All UI elements labeled
- **Haptic Feedback:** On/Off toggle
- **Battery Saver Mode:** Reduce animations

---

## Technical Specifications

### Platform

**Primary:** Mobile (iOS 14+, Android 10+)  
**Secondary:** PC (Steam, via Unity export)

### Engine

**Recommended:** Unity 2D or Godot 4.x

**Reasoning:**
- Strong 2D tooling
- Excellent mobile export
- Asset store (card game templates)
- Cross-platform (phone/tablet/PC)

### Technical Requirements

#### Mobile
- **Minimum:**
  - iPhone 8 / Android 10
  - 2GB RAM
  - 400MB storage
- **Recommended:**
  - iPhone 12 / Android 12
  - 4GB RAM
  - 800MB storage

#### PC (Secondary)
- **Minimum:**
  - Windows 10 / macOS 10.15
  - Intel i3 / Ryzen 3
  - 4GB RAM
  - Integrated GPU

### Performance Targets

- **Frame Rate:** 60 FPS (combat), 30 FPS (menus acceptable)
- **Battery:** <8% per hour (typical play)
- **Load Time:** <5 seconds (run start)
- **Save Time:** <1 second (after each floor)

### Technology Stack

**Core:**
- Engine: Unity 2D / Godot 4.x
- Language: C# (Unity) or GDScript (Godot)
- Version Control: Git (GitHub)

**Plugins:**
- Spine / DragonBones (2D animation)
- TextMesh Pro (text rendering)
- DOTween (animation tweening)

**Backend (Optional):**
- PlayFab (leaderboards, cloud saves)
- Or: Local save only (simpler, offline-first)

---

## Development Roadmap (2D Mobile)

### Phase 1: Core Prototype (Weeks 1-6)

**Goal:** Playable combat loop + basic deck

**Features:**
- ✅ Turn-based combat (parasite + 1 host vs 3 enemies)
- ✅ 20 starter cards (10 parasite, 10 host)
- ✅ Possession mechanic (1 host slot)
- ✅ Basic UI (combat screen only)
- ✅ Win/lose conditions

### Phase 2: Roguelike Structure (Weeks 7-10)

**Goal:** Full 8-floor run

**Features:**
- ✅ Dungeon map (8 floors, branching paths)
- ✅ 3 host types (Fodder/Standard/Elite)
- ✅ Reward system (card choices)
- ✅ Boss fight (simple)
- ✅ Consume/Keep decision

### Phase 3: Content & Balance (Weeks 11-14)

**Goal:** 50+ cards, 3 parasite strains

**Features:**
- ✅ 50 total cards
- ✅ 3 Parasite Strains (Hivemind, Apex, Shapeshifter)
- ✅ 10 host types
- ✅ Events & shops
- ✅ Balancing (playtesting)

### Phase 4: Meta Progression (Weeks 15-18)

**Goal:** Unlockables & replayability

**Features:**
- ✅ DNA point system
- ✅ Permanent upgrades
- ✅ Ascension levels (1-10)
- ✅ Achievements

### Phase 5: Polish & Launch (Weeks 19-22)

**Goal:** Release-ready

**Features:**
- ✅ Full art assets (2D illustrations)
- ✅ Sound & music
- ✅ Tutorial (first 2 floors)
- ✅ Daily Run
- ✅ Bug fixes & optimization

### Phase 6: Post-Launch (Months 2-6)

**Goal:** Content updates

**Features:**
- ✅ Balance patches
- ✅ New hosts (2-3 per month)
- ✅ New Parasite Strains
- ✅ Expansion DLC (optional)

---

## Key Differences from v1.0

| Aspect | v1.0 (PC) | v2.0 (Mobile) |
|--------|-----------|---------------|
| **Platform** | PC primary | Mobile primary |
| **Session** | 45-60 min runs | 5-15 min runs |
| **Controls** | Mouse/Keyboard | Touch gestures |
| **UI** | Landscape, complex | Portrait, simplified |
| **Run Length** | 24 floors (3 layers) | 8 floors (1 layer) |
| **Host Slots** | Up to 5 | Up to 3 |
| **Card Count** | 80+ cards | 50+ cards (curated) |
| **Monetization** | TBD | Premium ($4.99) |

---

## Why Mobile-First?

### Advantages:

1. **Larger Market:**
   - Mobile roguelike boom (Dead Cells, Hades mobile ports)
   - Slay the Spire proven success on mobile
   - Wider audience reach

2. **Perfect Fit for Roguelikes:**
   - Turn-based = no reflex pressure
   - Short runs = commute-friendly
   - Touch = intuitive card dragging

3. **Monetization:**
   - Premium model viable (no F2P grind needed)
   - $4.99 price point proven (Slay the Spire, Monster Train)

4. **Development Efficiency:**
   - 2D art cheaper than 3D
   - Smaller team (2-4 people)
   - Faster iteration

### Risks Mitigated:

- **Screen Size:** Portrait mode + large UI elements
- **Touch Precision:** Auto-targeting, large tap areas
- **Battery Drain:** 2D sprites, 30-60 FPS cap

---

## Next Steps

1. ✅ **Finalize GDD v2.0** (this document)
2. ⏳ **Paper Prototype** (card mechanics on paper)
3. ⏳ **Tech Stack Decision** (Unity vs Godot)
4. ⏳ **Art Style Test** (mock up 1 host + parasite)
5. ⏳ **Combat Prototype** (playable in 3 weeks)

---

**Document Status:** ✅ Complete  
**Next Review:** After Combat Prototype (Week 3)  
**Approvals Needed:** Steve PM (Owner)

---

_GDD v2.0 | Dungeon Parasite (2D Mobile Edition) | © GeekBrox 2026_
