# Screen Backlog - Dream Collector UI

**Current Status:** 8/20+ screens completed  
**Last Updated:** 2026-02-23  
**Figma:** https://www.figma.com/design/Wo1MKHvWNE9Yl5bsmD4pkK/Dream-Collector---UI-Design

---

## ✅ Completed Screens (8)

1. **c01-main-lobby** - Main lobby with 2×2 action grid
2. **c02-card-library** - Card collection view (85 cards)
3. **c03-deck-builder** - Deck editing (max 12 cards)
4. **c04-upgrade-tree** - Dream Shards upgrade system
5. **c05-shop** - Shop with Daily Deal/Cards/Energy tabs
6. **c06-run-prep** - Run preparation with Dreamer selection
7. **c07-in-run** - In-run progress with node map
8. **c08-combat** - Turn-based combat screen

---

## 🔴 Priority 1: Critical Screens (필수)

These screens are essential for a complete gameplay loop.

### c09-victory-screen
**Purpose:** Display run completion rewards  
**Components:**
- Victory animation (confetti, fanfare)
- Final stats (turns, damage dealt, Reveries earned)
- Reward cards (3 options, pick 1)
- Continue button → Main Lobby
- Replay button (same Dreamer, new run)

**Triggers:**
- Boss defeated (node 10 complete)
- All nodes cleared

---

### c10-defeat-screen
**Purpose:** Display game over state  
**Components:**
- Defeat message with cause of death
- Final statistics:
  - Nodes cleared: X/10
  - Turns survived: X
  - Damage dealt: X
  - Reveries earned: X
- "Retry" button (same setup)
- "Main Lobby" button
- Optional: Death recap (what killed you)

**Triggers:**
- Player HP reaches 0 in combat

---

### c11-rewards-modal
**Purpose:** Mid-run reward selection  
**Components:**
- 3 card options (rarity-based on node type)
- Card preview with full details
- "Skip" option (no reward)
- Rarity indicators
- Quick stats comparison

**Triggers:**
- After combat victory (node reward)
- After event completion
- After shop purchase (preview)

**Variants:**
- Card reward (3 choices)
- Upgrade reward (3 choices)
- Reveries reward (fixed amount)

---

### c12-settings
**Purpose:** Game settings and account management  
**Components:**
- Audio sliders:
  - Master volume
  - Music volume
  - SFX volume
- Display settings:
  - Particle effects (on/off)
  - Screen shake (on/off)
- Account info:
  - Player name
  - Account ID
  - Total play time
- Language selection (EN/KR)
- Credits button
- Tutorial reset button
- "Back" button

**Access:**
- Main Lobby → Settings icon (top-right)
- Pause Menu → Settings

---

## 🟠 Priority 2: Important Screens (중요)

These screens improve gameplay experience significantly.

### c13-card-upgrade-modal
**Purpose:** Upgrade card mid-run  
**Components:**
- Large card display (before/after comparison)
- Upgrade options (2-3 choices):
  - +Damage
  - -Cost
  - +Special effect
- Upgrade cost (Reveries or Shards)
- Confirm/Cancel buttons
- "Info" tooltip (what upgrade does)

**Triggers:**
- Node reward (Upgrade type)
- Shop purchase
- Special event

---

### c14-shop-in-run
**Purpose:** Mid-run shop (different from main shop)  
**Components:**
- Similar to c05-shop BUT:
  - Uses Reveries (not real currency)
  - Limited inventory (refreshes per run)
  - No Daily Deal
  - Tabs: Cards (5) | Energy (3) | Upgrades (3)
- "Leave Shop" button → continue run

**Triggers:**
- Shop node (node map)

**Differences from Main Shop:**
- Temporary purchases (run-only)
- Higher rarity cards available
- Energy refills available

---

### c15-pause-menu
**Purpose:** In-combat/in-run pause menu  
**Components:**
- Semi-transparent overlay
- Buttons:
  - Resume
  - Settings
  - View Deck
  - Abandon Run (confirmation modal)
- Current run info:
  - Nodes cleared
  - Current HP/Energy
  - Reveries earned

**Access:**
- Combat screen → Menu button (top-left)
- In-Run screen → Menu button

---

## 🟡 Priority 3: Nice to Have (추후)

These screens enhance long-term engagement.

### c16-profile
**Purpose:** Player profile and statistics  
**Components:**
- Profile picture/avatar
- Player name
- Account stats:
  - Total runs: X
  - Win rate: X%
  - Total Reveries earned: X
  - Favorite Dreamer
  - Most used card
- Achievements/badges
- Leaderboard link (if multiplayer)

---

### c17-daily-missions
**Purpose:** Daily quest system  
**Components:**
- 3 daily missions:
  - Complete 1 run (50 R)
  - Play 10 cards (20 R)
  - Defeat 5 enemies (30 R)
- Timer: "Resets in: 6h 23m"
- Claim buttons
- Progress bars

---

### c18-collection-progress
**Purpose:** Collection tracking  
**Components:**
- Overall progress:
  - Cards: 42/85 (49%)
  - Dreamers: 2/3 (67%)
  - Upgrades: 15/25 (60%)
- Rarity breakdown (pie chart)
- Missing cards list (grayed out)
- "How to unlock" hints

---

### c19-tutorial-overlay
**Purpose:** First-time player guidance  
**Components:**
- Dimmed background
- Spotlight on active element
- Speech bubble with text
- "Next" / "Skip Tutorial" buttons
- Progress: "Step 3/10"

**Tutorial Flow:**
1. Welcome → Main Lobby
2. Tap "Run Start" → Run Prep
3. Select Dreamer → Continue
4. First node → In-Run screen
5. First combat → Combat screen
6. Play card → Card explanation
7. End turn → Enemy turn
8. Victory → Reward selection
9. Complete run → Victory screen
10. Return to lobby → Tutorial complete

---

### c20-loading-screen
**Purpose:** Transition loading screen  
**Components:**
- Dream Collector logo
- Loading bar
- Random tip text:
  - "Try different Dreamers for varied strategies"
  - "Oblivion Strike costs 5 Energy but deals massive damage"
  - "Upgrade Tree persists across runs"
- Particle animation (floating clouds)

**Triggers:**
- App launch
- Run start (prep → in-run)
- Combat start (in-run → combat)

---

## 📊 Development Priority

**Week 1 (Current):**
- ✅ c01-c08 (Complete)

**Week 2:**
- [ ] c09-victory-screen
- [ ] c10-defeat-screen
- [ ] c11-rewards-modal
- [ ] c12-settings

**Week 3:**
- [ ] c13-card-upgrade-modal
- [ ] c14-shop-in-run
- [ ] c15-pause-menu

**Week 4:**
- [ ] c16-profile
- [ ] c17-daily-missions
- [ ] Polish & refinement

**Future:**
- [ ] c18-collection-progress
- [ ] c19-tutorial-overlay
- [ ] c20-loading-screen

---

## 🎯 Next Steps

1. **Validate flow:** Walk through complete gameplay loop with existing 8 screens
2. **Priority review:** Confirm Priority 1 screens are correct
3. **Generate Priority 1:** Create c09-c12 HTML files (same process as c02-c08)
4. **Figma import:** Add new screens to Figma prototype
5. **Connect interactions:** Link all screens in Figma for clickable prototype

---

## 📝 Notes

- All screens follow Dream theme design system (390×844px, Nunito font)
- React components with interactive prototypes
- Mobile-first design
- Rarity colors: Common (gray) → Legendary (gold)
- Consistent navigation patterns

**Total Target:** 20+ screens for complete digital prototype
**Current Progress:** 40% (8/20)
**Est. Completion:** Week 4 (2026-03-16)
