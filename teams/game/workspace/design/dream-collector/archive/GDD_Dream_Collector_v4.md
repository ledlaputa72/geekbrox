# Dream Collector (꿈 수집가)
## Game Design Document v4.0 - Full System Integration

**Document Date:** February 25, 2026  
**Document Version:** 4.0 (Full Integration Milestone)  
**Genre:** Idle / Incremental + Roguelike + Deckbuilding  
**Platform:** Mobile (iOS/Android) Primary, PC Secondary  
**Target Audience:** Ages 12+, fans of idle games and atmospheric experiences  
**Session Length:** 1-5 minutes (active), Continuous (idle progression)  
**Implementation Status:** 🎉 **All Core Systems Complete** (95% Overall)

---

## 📋 Document Revision History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-20 | Initial GDD (3D Adventure/Puzzle) |
| 2.0 | 2026-02-20 | **Major Redesign:** 2D Mobile Idle Game |
| 3.0 | 2026-02-24 | **Implementation Update:** Combat System Complete |
| 4.0 | 2026-02-25 | **Full Integration:** All 12 Screens + Systems Complete |

**Key Changes in v4.0:**
- ✅ **All 12 UI Screens Implemented** (100%)
- ✅ **Auto-Progress Run System** (Node-based Exploration)
- ✅ **Currency System Fully Integrated** (Gold/Gems/Energy)
- ✅ **Component Architecture Complete** (CharacterNode, BottomNav, CardHandItem, EnergyOrb)
- ✅ **Combat Victory → Rewards → Next Event Loop** Complete
- ✅ **Target Selection System** Restored
- 📊 Overall Progress: **95%**

---

## 🎯 Core Game Loop

### Meta Progression (Main Lobby)
```
Main Lobby
    ├─ View Past Dreams (클리어한 꿈 목록)
    ├─ Claim Gold Rewards (50-200 gold per dream)
    ├─ Deck Building (12장 덱 편성)
    ├─ Card Library (85장 수집)
    ├─ Upgrade Tree (Character/Skills/Passive)
    └─ Shop (Gacha/Items/Exchange)
         ↓
    Start New Run (Energy 3 소비)
```

### Run Loop (Roguelike Run)
```
Run Prep (타로 카드 3장 선택)
    ↓
Exploration (자동 진행 - 노드 기반)
    ├─ 일반 노드: 나레이션 로그 (계속 진행)
    ├─ 전투 노드: Combat 화면으로 자동 전환
    ├─ 상점 노드: Shop 화면으로 자동 전환
    ├─ NPC 노드: Dialog 화면으로 자동 전환
    └─ 보스 노드: Boss Combat 전환
         ↓
Combat (Real-time ATB + Cards)
    ├─ 승리 → Reward Modal → Next Node
    ├─ 패배 → Defeat Modal → Run 종료
    └─ 마지막 노드 클리어 → Main Lobby
```

---

## 🎮 Implemented Systems (v4.0)

### ✅ 1. All 12 UI Screens (100%)

| # | Screen | Status | Description |
|---|--------|--------|-------------|
| 1 | MainLobby | ✅ 100% | Animated viewport + Past Dreams list + CharacterNode |
| 2 | CardLibrary | ✅ 100% | 85 cards, filter by type, BottomNav component |
| 3 | DeckBuilder | ✅ 100% | 12-card deck editing, drag cards in/out |
| 4 | UpgradeTree | ✅ 100% | 3-tab system (Character/Skills/Passive) |
| 5 | Shop | ✅ 100% | 3-tab gacha system (Gold/Gems 1-pull/10-pull) |
| 6 | RunPrep | ✅ 100% | Tarot card selection (3 cards with flip animation) |
| 7 | InRun_v4 | ✅ 100% | Unified container screen (iframe pattern) |
| 8 | Combat | ✅ 100% | Real-time ATB + Card system, Iron Glory style cards |
| 9 | Victory | ✅ 100% | Reward modal (not full-screen) |
| 10 | Defeat | ✅ 100% | Defeat modal with retry option |
| 11 | Rewards | ✅ 100% | Gold/Energy/Cards reward display |
| 12 | Settings | ✅ 100% | Sound/Language/Account/Info sections |

### ✅ 2. Auto-Progress Exploration System

**Node-Based Run System:**
```gdscript
RunProgressBar Component
    ├─ Nodes: [🚩 Start, 📖 Narration, ⚔️ Combat, 🛒 Shop, 💀 Boss]
    ├─ Auto-Progress: 3 seconds per node (TIME_PER_NODE = 3.0)
    ├─ Visual: Yellow line progress + Red arrow (current position)
    └─ Signals: node_reached(index, data), run_completed()

ExplorationBottomUI
    ├─ Scrolling event log
    ├─ Auto-adds entries: "📖 이상한 숲을 지나간다..."
    └─ Event triggers: "⚔️ 슬림 무리 발견!" → Auto switch to Combat

InRun_v4 (Unified Container)
    ├─ TopArea (280px): Hero + Monsters/NPCs (fly-in/out animations)
    ├─ BottomArea (564px): Dynamic UI (iframe pattern)
    │   ├─ ExplorationBottomUI (narration log)
    │   ├─ CombatBottomUI (cards + actions)
    │   ├─ ShopBottomUI (items for sale)
    │   ├─ NPCDialogBottomUI (choices)
    │   └─ StoryBottomUI (story events)
    └─ No scene transitions (all handled within InRun_v4)
```

**Flow:**
1. Node timer fills → Reach node
2. Check node type:
   - Narration: Add log + continue
   - Combat: Pause progress + switch to Combat UI + spawn monsters
   - Shop: Pause progress + switch to Shop UI
   - etc.
3. Event completes → Resume progress → Next node

### ✅ 3. Combat System (Slay the Spire Style)

**Real-time ATB + Card Hybrid:**
- ATB runs continuously in background (no UI display)
- Energy system: Timer-based charging (hand size = seconds)
- Cards: Click to select (lift 40px), click again to use
- Attack cards: Click monster to target
- Defense/Skill cards: Auto-target (no selection needed)

**Card Design (Iron Glory Style):**
```
┌────────────────────┐
│  ┌──────────┐  ○3  │ ← Cost badge (yellow circle)
│  │ Circular │      │
│  │   Art    │      │
│  │  Area    │      │
│  └──────────┘      │
│  ╔════════╗        │ ← Ribbon banner (sky blue)
│  ║  Name  ║        │
│  ╚════════╝        │
│   [Type]           │ ← Type badge below art
│  Description       │ ← Bottom panel
└────────────────────┘
```

**Combat Loop:**
1. Combat starts: Hero + 4 monsters spawn
2. ATB system: Auto-attacks run continuously
3. Energy timer: Charges based on hand size
4. Player: Select card → Choose target (monsters) → Play
5. All monsters dead: Victory modal → Rewards → Return to exploration
6. Hero dead: Defeat modal → Run ends

### ✅ 4. Currency System (Fully Integrated)

**Three Currencies:**
- 🪙 **Gold (Reveries):** Main currency (combat rewards, shop purchases)
- 💎 **Gems:** Premium currency (gacha, special items)
- ⚡ **Energy:** Run entry cost (3 per run, regenerates over time)

**GameManager Integration:**
```gdscript
// All currency changes emit signals
GameManager.add_gold(50)
    → reveries_changed.emit(new_amount)
    → Auto-save to SaveSystem
    → UI auto-updates (InRun TopBar, Shop display, MainLobby)

// Usage:
MainLobby → Claim Dream Reward: +50 gold ✅
Combat Victory → Rewards: +50 gold, +10 energy ✅
Shop → Purchase: -100 gold ✅
All trigger real-time UI updates across all screens.
```

**Display Locations:**
- MainLobby: CurrencyBar (⚡ Energy, 💎 Gems, 🪙 Gold)
- InRun_v4: **No currency display** (only ⚙️ + Node Bar)
- Shop: 💎 Gems + 🪙 Gold (center top)

### ✅ 5. Component Architecture

**Reusable UI Components:**
1. **CharacterNode** (Hero/Monster/NPC)
   - Size: 60×120px (vertical box, height = 2×width)
   - Displays: Emoji, Name, HP Bar, Type Color
   - Used in: MainLobby (hero walk animation), InRun_v4 (combat)
   - Unified design across all screens

2. **BottomNav** (Navigation Bar)
   - 5 tabs: Home 🏠, Cards 🎴, Upgrade ⚙️, Settings ⚙️, Shop 🛒
   - Centralized component (no inline definitions)
   - Used in: MainLobby, CardLibrary, DeckBuilder, Shop

3. **CardHandItem** (Iron Glory Style)
   - Size: 70×98px (scaled down from CardItem)
   - Fan layout with 35px spacing (30-70% overlap)
   - Selection: Y-position lift (40px selected, 20px hover)
   - No scale animation (cleaner visual)

4. **EnergyOrb** (Circular Display)
   - Circular orb with number + radial progress gauge
   - Shows: Current/Max energy + timer progress
   - Updates real-time from CombatManager signals

5. **RunProgressBar** (Auto-Progress System)
   - Capsule shape with nodes
   - Yellow line for progress, red arrow for current position
   - Auto-progresses (3s per node), emits signals

6. **RewardModal** (Victory/Defeat Overlay)
   - CanvasLayer (z-index 100)
   - Modal overlay (not full-screen transition)
   - Shows rewards and "Continue" button

7. **DreamItem** (Accordion Component)
   - Collapsible dream entry with story + rewards
   - Gold claim button
   - Accordion behavior (only one expanded at a time)

### ✅ 6. InRun_v4 Architecture (Iframe Pattern)

**Unified Container Screen:**
- No scene transitions within a run
- All events handled in single screen
- BottomUI scenes loaded/unloaded dynamically

```
InRun_v4 Structure (390×844px)
├─ TopBar (60px)
│   ├─ ⚙️ Settings (left)
│   └─ RunProgressBar (center-right, full width)
├─ TopArea (280px)
│   ├─ Background (scrolling)
│   ├─ HeroArea (left): Permanent hero node
│   └─ CharacterArea (right): Monster/NPC pool (reuse pattern)
└─ BottomArea (504px)
    └─ Dynamic UI container (iframe pattern)
        ├─ Load: ExplorationBottomUI.tscn
        ├─ Load: CombatBottomUI.tscn
        ├─ Load: ShopBottomUI.tscn
        ├─ Load: NPCDialogBottomUI.tscn
        └─ Load: StoryBottomUI.tscn
```

**State Management:**
```gdscript
enum ScreenState {
    EXPLORATION,  # Narration log + auto-progress
    COMBAT,       # Cards + monsters
    SHOP,         # Items for sale
    NPC_DIALOG,   # NPC choices
    STORY         # Story events
}

func _switch_bottom_ui(scene_path: String):
    # Remove old UI
    if current_bottom_ui:
        bottom_area.remove_child(current_bottom_ui)
        current_bottom_ui.queue_free()
    
    # Load new UI
    var scene = load(scene_path)
    current_bottom_ui = scene.instantiate()
    bottom_area.add_child(current_bottom_ui)
    current_bottom_ui.ui_action_requested.connect(_on_bottom_ui_action)
```

**Character Management:**
- **Hero**: Never deleted (permanent persistence)
- **Monsters/NPCs**: Reuse pool pattern (hidden/shown, not destroyed/recreated)
- **Animations**: fly_in_from_right(), fly_out_to_right() (0.5s cubic ease)

---

## 🎨 Visual Design

### Color Palette (Dream Theme)
- **Primary:** #7B9EF0 (Sky Blue) - Dreams, magic, wonder
- **Background:** #1A1A2E (Deep Night) - Mystery, depth
- **Panel:** #2A2A3E (Dark Purple) - UI containers
- **Text:** #FFFFFF (White) - High contrast
- **Text Dim:** #888888 (Gray) - Secondary text
- **Attack:** #FF6B6B (Red) - Aggressive actions
- **Defense:** #4ECDC4 (Cyan) - Protective actions
- **Skill:** #FFE66D (Yellow) - Utility
- **Power:** #A8E6CF (Green) - Buffs

### Typography
- **Font:** Nunito (rounded, friendly)
- **Sizes:**
  - Tiny: 10px (labels)
  - Small: 12px (captions)
  - Body: 14px (standard text)
  - Subtitle: 16px (section headers)
  - Title: 20px (screen titles)
  - Header: 24px (modal titles)
  - Large: 32px (hero text)

### Screen Resolution
- **Mobile Target:** 390×844px (iPhone 14)
- **Development Window:** 780×1688px (2× for better visibility)

---

## 📊 Game Economy

### Currency Flow

**Gold (🪙 Reveries):**
- **Earn:**
  - Combat victory: +50 gold (normal), +100 (elite), +200 (boss)
  - Dream completion: +50-200 gold (claim from MainLobby)
  - Shop sales (future): Variable
- **Spend:**
  - Shop items: 100-2000 gold
  - Upgrades: 100-300 gold per level
  - Card packs: 300 gold

**Gems (💎):**
- **Earn:**
  - Daily login: +10 gems
  - Achievements: +50-100 gems
  - IAP (future): Real money
- **Spend:**
  - Premium gacha: 150 gems (1-pull), 1500 gems (10-pull)
  - Premium items: 500-2000 gems
  - Energy refill: 50 gems (instant +10 energy)

**Energy (⚡):**
- **Max:** 100 (starting value)
- **Regen:** 1 per 10 minutes (natural regen)
- **Usage:** 3 per run (run entry cost)
- **Restore:** Combat victory (+10), potions, gems

### Balancing Goals
- **Session Length:** 3-5 minutes per run (7-10 nodes)
- **Daily Sessions:** 3-5 runs (15-25 minutes active play)
- **Progression Feel:** Noticeable power growth every 2-3 runs
- **Gacha Pity:** Guaranteed rare every 10 pulls

---

## 🗂️ Data Architecture

### GameManager (Autoload Singleton)
```gdscript
var reveries: float = 1000.0  # Gold
var gems: int = 0
var energy: int = 100
var current_deck: Array = []  # 12 cards
var total_runs_completed: int = 0

# Signals
signal reveries_changed(new_amount: float)
signal gems_changed(new_amount: int)
signal energy_changed(new_amount: int)
signal deck_saved(deck_size: int)

# Auto-save on all currency changes
```

### SaveSystem (JSON Persistence)
```gdscript
var save_data = {
    "player": {
        "reveries": 1000.0,
        "gems": 0,
        "energy": 100,
        "runs_completed": 0
    },
    "deck": [...],  # 12 card IDs
    "collection": [...],  # Unlocked cards
    "upgrades": {...}
}

func save_game():
    var file = FileAccess.open("user://save.json", FileAccess.WRITE)
    file.store_string(JSON.stringify(save_data))
```

### Card Data Structure
```gdscript
{
    "id": 1,
    "name": "Strike",
    "type": "attack",  # attack, defense, skill, power
    "cost": 1,
    "description": "Deal 6 damage.",
    "rarity": "common",  # common, uncommon, rare, epic, legendary
    "effects": [
        {"type": "damage", "value": 6, "target": "enemy"}
    ]
}
```

---

## 🚀 Implementation Status

### Completed (95%)
- ✅ All 12 UI Screens (100%)
- ✅ Combat System (100%)
- ✅ Auto-Progress Run System (100%)
- ✅ Currency System (100%)
- ✅ Component Architecture (100%)
- ✅ Save/Load System (100%)
- ✅ Victory/Defeat Flow (100%)

### In Progress (0%)
- ⏳ Audio System (0%) - BGM, SFX
- ⏳ Asset Integration (0%) - Replace emoji with sprites
- ⏳ Tutorial System (0%) - First-time player guidance

### Planned (5%)
- 📋 Meta Progression Depth (Prestige system, permanent upgrades)
- 📋 Additional Content (More cards, monsters, events)
- 📋 Daily Missions & Achievements
- 📋 Cloud Save (Cross-device sync)
- 📋 Localization (Korean + English)

---

## 🔧 Technical Stack

### Engine & Tools
- **Engine:** Godot 4.x (GDScript)
- **Version Control:** Git + GitHub
- **Design:** Figma (UI mockups)
- **Project Management:** Notion + Telegram

### Architecture Patterns
- **UI:** Component-based (reusable scenes)
- **State Management:** Enum-based state machine
- **Data:** Autoload singletons (GameManager, SaveSystem, CombatManager, DeckManager)
- **Signals:** Event-driven communication (no tight coupling)

### Performance Targets
- **FPS:** 60 FPS on mobile (iPhone 12 baseline)
- **Load Times:** <1s for scene transitions
- **Memory:** <200MB RAM usage

---

## 📝 Development Notes

### Key Decisions
1. **Real-time Combat:** More engaging than turn-based for mobile
2. **Auto-Progress Runs:** Reduces repetitive tapping (idle game feel)
3. **Component Architecture:** Ensures consistency and maintainability
4. **Unified InRun Screen:** No scene transitions = smoother experience
5. **Currency Integration:** All changes trigger auto-save + UI updates
6. **CharacterNode Unification:** Same component for Hero/Monster/NPC across all screens

### Lessons Learned
1. **UITheme.apply_button_style()** doesn't work reliably on dynamic buttons → Use StyleBoxFlat directly
2. **Array[Dictionary]** type hints break JSON compatibility → Use plain Array
3. **@onready timing:** May fail in complex hierarchies → Use get_node() in _ready()
4. **Energy timer:** Dynamic duration (based on hand size) creates strategic tension
5. **Hero persistence:** Never delete hero node = smoother transitions
6. **Character reuse pool:** Hidden/shown pattern prevents memory spikes

### Future Improvements
1. **Particle Effects:** Card play, damage numbers, explosions
2. **Shader Effects:** Screen shake, color grading for dream atmosphere
3. **Animated Sprites:** Replace emoji with proper 2D art
4. **Sound Design:** Dreamy ambient BGM, satisfying SFX
5. **Juice Polish:** More animations, transitions, feedback

---

## 📅 Roadmap

### Phase 1: Core Loop (✅ Complete)
- Week 1-2: UI Screens (12/12)
- Week 2-3: Combat System
- Week 3-4: Run System + Integration

### Phase 2: Content & Polish (Current)
- Week 5: Audio integration
- Week 6: Asset replacement (emoji → sprites)
- Week 7: Tutorial system
- Week 8: Balancing & playtesting

### Phase 3: Meta Progression (Future)
- Week 9-10: Prestige system
- Week 11: Daily missions
- Week 12: Achievements

### Phase 4: Launch Prep (Future)
- Week 13: Localization (Korean + English)
- Week 14: Cloud save
- Week 15: Marketing assets
- Week 16: Soft launch (iOS TestFlight)

---

## 🎯 Success Metrics

### Engagement
- **D1 Retention:** >40% (target)
- **D7 Retention:** >20%
- **Session Length:** 5-10 minutes
- **Sessions/Day:** 3-5

### Monetization (Future)
- **ARPU:** $0.50/day (target)
- **Conversion:** 5% (IAP)
- **LTV:** $15 (90-day)

---

## 📞 Contact & Credits

**Developer:** GeekBrox Studio  
**Lead Designer:** Steve PM  
**AI Assistant:** Atlas (OpenClaw)  
**Engine:** Godot 4.x  
**Status:** In Development (95% Core Complete)

---

**End of Document**  
*Last Updated: February 25, 2026*  
*Next Review: Post-Audio Integration*
