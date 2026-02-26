# Changelog - Dream Collector

All notable changes to this project will be documented in this file.

**Format**: Based on [Keep a Changelog](https://keepachangelog.com/)  
**Authors**: Steve PM, Atlas, Cursor, Team Members

---

## [Unreleased]

### Changed
- DreamCardSelection: Redesigned to show selected cards progressively (2026-02-25 PM)
  - Top: 3 cards (back-facing, always visible)
  - Middle: 3 slots showing selected cards as user chooses
  - Bottom: 1-line prompt + start button
  - No longer: cards disappear / fly away
  - New: accumulative display (slots fill up)

### Planned
- Combat gameplay logic implementation
- Card database (JSON)
- Monster database (JSON)
- DeckManager card draw/shuffle system
- Shop purchase mechanics
- Save/load system
- Asset replacement (emoji → sprites)
- Sound effects integration
- Animation polish

---

## [2026-02-25] - Atlas + Steve

### Added
- **All 12 screens UI complete** (100%)
  - MainLobby: Home hub with past dreams
  - InRun_v4: Active run gameplay (exploration/combat/shop/story)
  - DreamCardSelection: 3-stage gacha card selection
  - CardLibrary: Card collection viewer
  - DeckBuilder: Deck editor
  - Shop: Item/card purchase
  - UpgradeTree: Character permanent upgrades
  - Settings: Sound, language, account
  - (4 more screens)

- **BottomNav component** (`ui/components/BottomNav.tscn/gd`)
  - Unified 5-tab navigation (Home, Cards, Upgrade, Progress, Shop)
  - Applied to all meta-screens
  - Single source of truth for navigation

- **Combat visual effects**
  - DamageNumber component: Floating damage numbers (red/orange/green)
  - CharacterNode shake effect: Position + rotation (0.4s)
  - CharacterNode red flash: Color modulate (0.3s)
  - HP sync via `entity_updated` signal

- **DreamCardSelection gacha system**
  - 3-stage card selection (START → JOURNEY → END)
  - Blind pick mechanic: First click = preview (20px down), Second click = confirm + reveal
  - Card flip animation (scale x)
  - Block-style log panels (colored backgrounds)
  - Summary screen with 2-row layout

- **Time-based exploration logs**
  - GameManager generates hourly time logs from dream cards
  - Event logs (combat, shop, NPC, boss) + Travel logs (walking, resting)
  - Auto-progression system (2s per log, pausable)
  - Real-time format (PM/AM 12-hour)

- **GameManager dream card integration**
  - `dream_cards`, `dream_nodes`, `dream_time_logs` variables
  - `set_dream_cards()`, `get_dream_nodes()`, `get_dream_time_logs()` functions
  - Automatic node/log generation from selected cards

- **Documentation**
  - `.cursorrules`: AI context file for Cursor IDE
  - `CURSOR_GUIDE.md`: Developer workflow guide
  - `CHANGELOG.md`: This file

### Changed
- **Settings access**: Moved from BottomNav (4th tab) to top-right ⚙️ button
- **BottomNav 4th tab**: "Settings" → "Progress" (reserved for future feature)
- **InRun_v4 TopBar**: Added navigation bar with "← 나가기", title, ⚙️ button
- **Card dimensions**: 80×140 → 140×220 (tarot ratio)
- **Log style**: Plain labels → Block-style panels (DreamItem style)

### Fixed
- Monster/Hero HP bars not updating during combat (connected `entity_updated` signal)
- Damage numbers not appearing (created DamageNumber component)
- DreamCardSelection flip logic (gacha system: blind pick until confirmation)
- Card selection button disable bug (added immediate disable on confirmation)
- BottomNav inconsistency across screens (unified component)

### Removed
- Inline BottomNav definitions from individual screens (replaced with component)
- Back buttons from meta-screens (CardLibrary, Shop, UpgradeTree)
- RunPrep screen (replaced with DreamCardSelection)

---

## [2026-02-24] - Atlas

### Added
- Initial project setup
- Basic UI framework
- GameManager singleton
- CombatManager singleton
- DeckManager singleton

### In Progress
- Screen implementations
- Combat system design

---

## How to Use This File

### When You Make Changes (Cursor / Developers)

Add your changes under `[Unreleased]` section using this format:

```markdown
## [Unreleased]

### Added
- New feature X in FileY.gd (brief description)

### Changed
- Modified function Z in FileW.gd (reason: ...)

### Fixed
- Bug in combat HP sync (details...)

### Removed
- Deprecated function ABC from GameManager.gd
```

### When Ready to Release

1. Move `[Unreleased]` changes to new dated section
2. Follow format: `## [YYYY-MM-DD] - Author`
3. Keep chronological order (newest first)

### Categories

- **Added**: New features, files, functions
- **Changed**: Modifications to existing code
- **Deprecated**: Soon-to-be-removed features
- **Removed**: Deleted features/code
- **Fixed**: Bug fixes
- **Security**: Security patches

---

**Maintained by**: Atlas + Team  
**Last Updated**: 2026-02-25
