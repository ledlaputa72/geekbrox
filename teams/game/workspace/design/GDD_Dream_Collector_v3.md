# Dream Collector (꿈 수집가)
## Game Design Document v3.0 - Implementation Update

**Document Date:** February 24, 2026  
**Document Version:** 3.0 (Implementation Milestone)  
**Genre:** Idle / Incremental + Roguelike + Deckbuilding  
**Platform:** Mobile (iOS/Android) Primary, PC Secondary  
**Target Audience:** Ages 12+, fans of idle games and atmospheric experiences  
**Session Length:** 1-5 minutes (active), Continuous (idle progression)  
**Implementation Status:** ⚡ **Core Combat System Complete** (75% Overall)

---

## 📋 Document Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial GDD (3D Adventure/Puzzle) |
| 2.0 | 2026-02-20 | **Major Redesign:** 2D Mobile Idle Game |
| 3.0 | 2026-02-24 | **Implementation Update:** Combat System Complete |

**Key Changes in v3.0:**
- ✅ Combat System **100% Implemented** (ATB + Card Hybrid)
- ✅ Slay the Spire Style Card System
- ✅ Real-time Energy with Dynamic Charging
- ✅ Visual Node Map System
- ✅ 10/12 UI Screens Complete
- ✅ Victory/Defeat Flow Complete
- 📊 Overall Progress: **75%**

---

## 🎮 Implemented Features (v3.0)

### ✅ Combat System (100% Complete)

**Real-time ATB + Card Hybrid System:**
- ATB auto-battle runs continuously in background
- Energy timer charges based on hand size (dynamic)
- Player can play cards anytime (tower defense style)
- No turn-based phases (everything real-time)

**Combat Flow:**
```
ATB System (Background)
    ↓ Continuous
Character/Monster auto-attacks
    +
Energy System (Real-time)
    ↓ Timer-based charging
Player plays cards anytime
    =
Hybrid Real-time Combat
```

### ✅ Card System (Slay the Spire Style)

**Fan Layout:**
- Overlapping fan layout (center 70% visible, edge 50%)
- Card selection pushes adjacent cards (60px)
- Drag targeting with red arrow to monsters
- Description visible only when selected

**Card Design:**
- Cost as integer (top-left, yellow)
- Top 50%: Image area (type-based colors)
- Bottom 50%: Description (shown on selection)
- Type icons: ⚔️ Attack / 🛡️ Defense / ✨ Skill

**Card Mechanics:**
- Deck → Hand → Play → Discard → Shuffle cycle
- Hand max: 10 cards
- Starting hand: 5 cards
- Draw timing: energy charge or timer

### ✅ Energy System (Circular Orb)

**Visual Design:**
- Circular orb with number in center
- Radial progress bar (clockwise from 12 o'clock)
- Color: Gold (1, 0.8, 0.2)
- Width: 4px, Radius: 24px

**Charging Mechanics:**
- **Dynamic charge time = Hand size** (5 cards = 5 seconds)
- More cards in hand → slower charge
- Fewer cards → faster charge
- **Energy at max (3):** Draw card only
- **Energy < 3:** Charge energy + draw card

### ✅ Monster System (2×2 Grid with Depth)

**Layout:**
```
    [2]         [4] ← Top row (back, right offset)
[1]         [3]     ← Bottom row (front)
```

**Positioning:**
- Bottom row: z-index 10 (front)
- Top row: z-index 5 (back, 60px right offset)
- Top row bottom = Bottom row middle height
- Vertical rectangles: 60×120px (height = width × 2)

**Visual Depth:**
- Top row offset right for depth effect
- Layer separation via z-index
- Bottom row appears closer

### ✅ Node Map System

**Visual Design:**
- Nodes as circles (dots) connected by lines
- Type icons: ⚔️ Combat, 🛒 Shop, ❓ Event, 💎 Memory, ⬆️ Upgrade, 👹 Boss
- Progress colors:
  - Green: Completed
  - Gold: Current
  - Gray: Pending
- Node numbers below each dot

**Character Movement:**
- Walking character icon (👤)
- Smooth animation (lerp-based)
- Moves to current node position

**Line Rendering:**
- Completed path: Green thick line
- Pending path: Gray thin line
- Horizontal layout with spacing

### ✅ Victory/Defeat Flow

**Victory Screen:**
- Battle statistics (time, kills, damage, cards used)
- Difficulty multiplier display
- Rewards (gold, gems, cards)
- Continue → Return to InRun

**Defeat Screen:**
- Defeat statistics (survival time, kills, final HP)
- Run progress (Floor N/20)
- Return to Lobby button

**Rewards Modal:**
- Card selection (3 cards, choose 1)
- Card preview with stats
- Type-based colors
- Adds to deck on selection

---

## 🖥️ UI Screens (10/12 Complete - 83%)

### ✅ Implemented Screens

1. **c01 - Main Lobby** ✅
   - Tab navigation (Card Library, Deck Builder, Shop)
   - Start Run button
   - Currency display
   - Bottom nav bar

2. **c02 - Card Library** ✅
   - Grid layout (2 columns)
   - Filter system (All/Attack/Defense/Skill)
   - Card count per type
   - Scroll support

3. **c03 - Deck Builder** ✅
   - Current deck display (12 slots)
   - Deck validation
   - Add/Remove cards
   - Save/Reset buttons

4. **c05 - Shop** ✅
   - 3-tab system (Gacha/Gems/Exchange)
   - Gacha banners (4 types)
   - Currency integration
   - AlertModal for feedback

5. **c06 - Run Prep** ✅
   - Deck preview (12 cards)
   - Difficulty selection (Easy/Normal/Hard)
   - Deck validation
   - Start Run button

6. **c07 - In Run** ✅
   - Visual node map
   - Status bar (HP/Energy/Reveries)
   - Node events
   - Choice system

7. **c08 - Combat** ✅ (All 4 Phases Complete)
   - Real-time ATB + Card system
   - Fan layout card hand
   - Drag targeting
   - Auto-battle AI
   - Speed control (0.5× ~ 3×)

8. **c09 - Victory** ✅
   - Statistics display
   - Difficulty rewards
   - Continue button

9. **c10 - Defeat** ✅
   - Defeat stats
   - Run progress
   - Return to lobby

10. **c11 - Rewards Modal** ✅
    - Card selection
    - Preview system
    - Deck integration

### ⏳ Remaining Screens (2/12 - 17%)

11. **c04 - Upgrade Tree** ⏳
    - Skill tree visualization
    - Upgrade paths
    - Cost/benefit display

12. **c12 - Settings** ⏳
    - Audio settings
    - Graphics options
    - Account management

---

## 🎨 Visual Design (Implemented)

### Color Palette

**Primary Colors:**
- Background: `#1A1A2E` (Dark navy)
- Panel: `#16213E` (Navy blue)
- Primary: `#7B9EF0` (Dream blue)
- Accent: `#F0A07B` (Warm peach)

**Card Type Colors:**
- Attack: Red `#CC4444` (background: `#331111`)
- Defense: Blue `#4C9ACC` (background: `#193040`)
- Skill: Green `#66CC66` (background: `#194D19`)

**Progress Colors:**
- Completed: Green `#4CB04C` (0.3, 0.7, 0.3)
- Current: Gold `#FFCC33` (1, 0.8, 0.2)
- Pending: Gray `#808080` (0.5, 0.5, 0.5)

### Typography

**Font:** Nunito (Primary), System fallback
**Sizes:**
- Tiny: 8px
- Small: 12px
- Medium: 14px
- Large: 16px
- XLarge: 20px

### Layout (Mobile 390×844px)

**Combat Screen Breakdown:**
```
┌─────────────────────────────────────┐ 0px
│  Top Bar (54px) - HP/Energy         │
├─────────────────────────────────────┤ 54px
│  Battle Scene (280px)               │
│  👤 Hero  vs  👾👾👾 Monsters      │
│                                     │
├─────────────────────────────────────┤ 334px
│  Card Hand (300px) - Fan layout     │
│     ┌──┬─┬─┬─┬──┐                  │
│     │ │ │▲│ │ │                   │
│     └──┴─┴─┴─┴──┘                  │
│  ⚡ 3  📚 5  🪦 2  🚫 0           │
├─────────────────────────────────────┤ 634px
│  Combat Log (100px)                 │
│  • Drew 1 card: Strike              │
├─────────────────────────────────────┤ 734px
│  Action Buttons (110px)             │
│  [Pass]  [Auto]  [Menu]             │
└─────────────────────────────────────┘ 844px
```

---

## ⚙️ Technical Implementation

### Architecture

**Engine:** Godot 4.x  
**Language:** GDScript  
**Resolution:** 390×844px (Portrait, mobile-first)  
**Target FPS:** 60

**Autoload Singletons:**
- `UITheme.gd` - Global design system
- `GameManager.gd` - Game state & save
- `CombatManager.gd` - Combat logic & ATB
- `DeckManager.gd` - Card management

**Component System:**
- Reusable UI components (CardItem, AlertModal, etc.)
- Signal-based communication
- Theme inheritance

### Combat System Implementation

**ATB System:**
```gdscript
# Real-time ATB charging
func _process(delta):
    hero.atb += (100 / hero.speed) * delta
    if hero.atb >= 100:
        execute_auto_attack(hero)
        hero.atb = 0
```

**Energy System:**
```gdscript
# Dynamic charge time based on hand size
var hand_size = DeckManager.get_hand_size()
var dynamic_duration = max(1.0, float(hand_size))

energy_timer += delta
if energy_timer >= dynamic_duration:
    if energy < 3:
        energy += 1
    draw_card()
    energy_timer = 0
```

**Card Layout:**
```gdscript
# Fan layout with overlap
var spread_angle = 30.0
var card_spacing = 35.0  # Heavy overlap
var arc_height = 20.0

for i in range(num_cards):
    var t = float(i) / max(1, num_cards - 1)
    var angle = lerp(-spread_angle / 2, spread_angle / 2, t)
    var x = start_x + i * card_spacing
    var y = base_y + abs((t - 0.5) * 2) * arc_height
    card.position = Vector2(x, y)
    card.rotation_degrees = angle
```

### Save System

**Save Data Structure:**
```json
{
  "player": {
    "hp": 80,
    "max_hp": 80,
    "energy": 3,
    "reveries": 125
  },
  "deck": [
    {"id": "strike_001", "level": 1},
    {"id": "defend_001", "level": 1}
  ],
  "progress": {
    "current_floor": 3,
    "nodes_completed": 2,
    "difficulty": "normal"
  },
  "unlocks": {
    "cards": ["strike", "defend", "bash"],
    "dreamers": ["child", "artist"]
  }
}
```

---

## 🎯 Design Goals Achieved

✅ **긴박감** - Real-time ATB + timer → always progressing  
✅ **전략성** - Card selection & timing critical  
✅ **접근성** - Play anytime (tower defense style)  
✅ **깊이** - Deckbuilding + ATB stat management  
✅ **독창성** - Innovative hybrid not seen before  
✅ **시각적 완성도** - Slay the Spire quality card UI  
✅ **동적 난이도** - Hand size affects energy charge speed  

---

## 📊 Development Progress

### Overall: 75% Complete

**UI Screens:** 10/12 (83%)  
**Components:** 4/5 (80%)  
**Systems:** 5/8 (62%)  
**Documents:** 6/8 (75%)  

### Completed Systems

- ✅ Combat System (ATB + Card Hybrid) - 100%
- ✅ Card Management (Deck/Hand/Discard) - 100%
- ✅ Energy System (Circular Orb + Dynamic Charge) - 100%
- ✅ Node Map (Visual System) - 100%
- ✅ Victory/Defeat Flow - 100%

### Remaining Work

- ⏳ Upgrade Tree System
- ⏳ Settings Screen
- ⏳ Save/Load System (partial)
- ⏳ Sound Effects
- ⏳ Animation Polish
- ⏳ Tutorial System
- ⏳ Monetization Integration
- ⏳ Analytics

---

## 🚀 Next Milestones

### Phase 5: Meta Progression (3-4 days)

**Goals:**
- Upgrade Tree UI (c04)
- Persistent unlocks
- Prestige system foundation

**Tasks:**
- [ ] Upgrade tree data structure
- [ ] Skill tree visualization
- [ ] Purchase/unlock logic
- [ ] Integration with combat

### Phase 6: Polish & Settings (2-3 days)

**Goals:**
- Settings screen (c12)
- Sound effects
- Animation refinement

**Tasks:**
- [ ] Audio settings UI
- [ ] Volume controls
- [ ] Graphics options
- [ ] Sound effect integration
- [ ] Animation polish

### Phase 7: Content Expansion (5-7 days)

**Goals:**
- More cards (30+ total)
- More dreamers (3-5)
- More events (10+)

**Tasks:**
- [ ] Card design & balance
- [ ] Dreamer variations
- [ ] Event writing
- [ ] Art assets

### Phase 8: Beta Launch (2-3 days)

**Goals:**
- Bug fixes
- Performance optimization
- Beta release

**Tasks:**
- [ ] Full playthrough testing
- [ ] Performance profiling
- [ ] Bug triage
- [ ] Beta deployment

---

## 🎮 Gameplay Loop (As Implemented)

### Active Play Loop (1-5 min)

```
1. Open App → See accumulated offline progress
   ↓
2. MainLobby → Manage Deck/Cards/Shop
   ↓
3. Start Run → RunPrep (Select difficulty)
   ↓
4. InRun → Node Map
   - Choose path
   - Encounter events
   - Combat nodes
   ↓
5. Combat → Real-time ATB + Cards
   - Auto-battle or manual play
   - Strategic card timing
   - Energy management
   ↓
6. Victory → Rewards
   - Card selection
   - Currency gain
   - Progress to next node
   ↓
7. Continue or Return to Lobby
   ↓
8. Upgrade → Spend currency
   ↓
9. Repeat or Close App
```

### Combat Loop (Real-time)

```
ATB System (Background):
  Hero ATB charging...
  Monster ATB charging...
  100% → Auto-attack
  
Energy System (Timer):
  Timer charging... (Hand size seconds)
  100% → +1 Energy & +1 Card
  
Player Actions (Anytime):
  Select card → Choose target → Play
  Energy cost → Card effect → Discard
```

---

## 🏆 Key Innovations

### 1. Dynamic Energy Charge
**Innovation:** Energy charge speed = hand size  
**Impact:** Creates strategic depth - use cards fast for faster energy, or hold for more options

### 2. Real-time Hybrid Combat
**Innovation:** ATB auto-battle + real-time card play  
**Impact:** Tower defense urgency + deckbuilder strategy

### 3. Overlapping Fan Layout
**Innovation:** Heavy card overlap (50-70% visibility) with depth  
**Impact:** Fits 10 cards in small mobile screen while looking premium

### 4. Visual Node Map
**Innovation:** Progress visualization with character animation  
**Impact:** Makes run progression tangible and satisfying

---

## 📚 References

### Inspirations (Implemented)

**Slay the Spire:**
- ✅ Card fan layout
- ✅ Deck/Hand/Discard cycle
- ✅ Card selection UI
- ✅ Rewards system

**Iron Glory (아이언 글로리):**
- ✅ Overlapping card display
- ✅ Selection animation
- ✅ Combat layout

**Final Fantasy:**
- ✅ ATB gauge system
- ✅ Real-time charging
- ✅ Auto-battle mechanics

**Tower Defense:**
- ✅ Resource timer
- ✅ Real-time pressure
- ✅ Strategic timing

---

## 📝 Development Notes

### Lessons Learned

1. **Fan layout needs heavy overlap** - 35px spacing works best for 5-10 cards
2. **z-index is critical** - Center cards front, edge cards back
3. **Dynamic energy is engaging** - Creates interesting strategic choices
4. **ATB bars can hide** - HP-only display is cleaner
5. **Drag targeting feels good** - More intuitive than click-to-select

### Performance Notes

**Optimizations Applied:**
- Signal-based UI updates (not every frame)
- Card pooling (reuse CardItem instances)
- Minimal _process() logic
- Efficient fan layout calculation

**Target Performance:**
- 60 FPS on mid-range mobile (2020+)
- <100ms input latency
- <200MB memory footprint

---

## 🎨 Asset Requirements

### Implemented (Placeholders)

- ✅ Character sprites (👤 emoji)
- ✅ Monster sprites (👾 emoji)
- ✅ Card backgrounds (colored rectangles)
- ✅ UI elements (Godot built-in)

### Needed for Polish

- ⏳ Character art (illustrated)
- ⏳ Monster illustrations (10+ unique)
- ⏳ Card art (30+ unique)
- ⏳ Background art (dreamscapes)
- ⏳ VFX sprites (damage, heal, buff)
- ⏳ UI decorations (frames, borders)

---

## 📞 Team & Credits

**Design & Implementation:** Atlas (AI Assistant)  
**Project Lead:** Steve PM  
**Engine:** Godot 4.x  
**Development Time:** ~42 hours (Feb 20-24, 2026)  

**Repository:** https://github.com/ledlaputa72/geekbrox  
**Latest Commit:** 631c5d3 (feat: Implement Slay the Spire style card & combat system)  

---

**Document Version:** 3.0  
**Last Updated:** February 24, 2026, 22:00 PST  
**Status:** ✅ Combat Complete, 75% Overall Progress  
**Next Update:** Phase 5 completion (Upgrade Tree)
