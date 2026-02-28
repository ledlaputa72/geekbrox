# Navigation Structure - Dream Collector UI

**Version:** 1.1  
**Last Updated:** 2026-02-23  
**Total Screens:** 12 (+ 8 planned)

---

## 🎯 Navigation Principles

### 1. Bottom Tab Bar (Main Navigation)
**Fixed bottom bar on all "meta" screens** (lobby, deck management, progression)

**5 Tabs:**
- 🏠 **Home** - Main Lobby (c01)
- 🎴 **Cards** - Card Library (c02)
- ⬆️ **Upgrade** - Upgrade Tree (c04)
- 📊 **Progress** - Collection Progress (c18, planned)
- 🛒 **Shop** - Shop (c05)

**Tab Behavior:**
- Always visible on meta screens
- Hidden during runs (c07, c08)
- Hidden on modals (c11, c09, c10)
- Active tab highlighted (#7B9EF0)
- Inactive tabs grayed out (#666666)

---

### 2. Top Navigation Bar
**Screen-specific header with consistent layout**

**Structure:**
```
[← Back / ☰ Menu]  [Screen Title]  [Action Button / Icon]
```

**Components:**
- **Left:** Back button (meta screens) OR Menu button (in-run screens)
- **Center:** Screen title
- **Right:** Context action (Save, Settings, etc.) OR empty

---

### 3. Navigation Patterns

#### Pattern A: Meta Screens (with Bottom Tab Bar)
- Top: [← Back] [Title] [Action]
- Bottom: Tab Bar (5 tabs)
- Example: Card Library, Deck Builder, Upgrade Tree, Shop

#### Pattern B: In-Run Screens (no Bottom Tab Bar)
- Top: [☰ Menu] [Info] [Action]
- Bottom: Context-specific controls
- Example: In-Run Progress, Combat

#### Pattern C: Full-Screen Modals
- No bottom tab bar
- Top: [✕ Close] or integrated close button
- Example: Rewards Modal, Settings

#### Pattern D: End Screens
- No bottom tab bar
- No top bar
- Full-screen with action buttons
- Example: Victory, Defeat

---

## 📱 Screen-by-Screen Navigation

### ✅ Completed Screens (12)

#### **c01-main-lobby** (Pattern A)
**Current Navigation:**
- Top: [empty] "Main Lobby" [⚙ Settings]
- Bottom: Tab Bar (5 tabs) - **Home active**
- Action Grid: 4 buttons (Run Start, Cards, Upgrade, Shop)

**Navigation Targets:**
- ⚙ Settings → c12-settings
- 🚀 Run Start → c06-run-prep
- 🎴 Cards → c02-card-library (or c03-deck-builder)
- ⬆️ Upgrade → c04-upgrade-tree
- 🛒 Shop → c05-shop
- Tab: Home → (current)
- Tab: Cards → c02-card-library
- Tab: Upgrade → c04-upgrade-tree
- Tab: Progress → c18-collection-progress (planned)
- Tab: Shop → c05-shop

**Status:** ✅ Bottom Tab Bar present, needs consistent styling

---

#### **c02-card-library** (Pattern A)
**Current Navigation:**
- Top: [← Back] "Card Library" [⚙ Filter]
- Bottom: **MISSING Tab Bar** ❌

**Proposed Navigation:**
- Top: [← Back] "Card Library" [⚙ Filter]
- Bottom: Tab Bar (5 tabs) - **Cards active**

**Navigation Targets:**
- ← Back → c01-main-lobby
- ⚙ Filter → Filter dropdown/modal
- Card tap → Card detail modal
- Tab: Home → c01-main-lobby
- Tab: Cards → (current)
- Tab: Upgrade → c04-upgrade-tree
- Tab: Progress → c18-collection-progress
- Tab: Shop → c05-shop

**Fix Required:** ✨ Add Bottom Tab Bar

---

#### **c03-deck-builder** (Pattern A)
**Current Navigation:**
- Top: [← Back] "Deck Builder" [💾 Save]
- Bottom: **MISSING Tab Bar** ❌

**Proposed Navigation:**
- Top: [← Back] "Deck Builder" [💾 Save]
- Bottom: Tab Bar (5 tabs) - **Cards active**

**Navigation Targets:**
- ← Back → c01-main-lobby OR c02-card-library
- 💾 Save → Save deck + return to previous screen
- Card tap → Card detail modal
- Tab: Home → c01-main-lobby
- Tab: Cards → c02-card-library
- Tab: Upgrade → c04-upgrade-tree
- Tab: Progress → c18-collection-progress
- Tab: Shop → c05-shop

**Fix Required:** ✨ Add Bottom Tab Bar

---

#### **c04-upgrade-tree** (Pattern A)
**Current Navigation:**
- Top: [← Back] "Upgrade Tree" [Dream Shards: 12]
- Bottom: **MISSING Tab Bar** ❌

**Proposed Navigation:**
- Top: [← Back] "Upgrade Tree" [Dream Shards: 12]
- Bottom: Tab Bar (5 tabs) - **Upgrade active**

**Navigation Targets:**
- ← Back → c01-main-lobby
- Node tap → Select node (update info panel)
- Tab: Home → c01-main-lobby
- Tab: Cards → c02-card-library
- Tab: Upgrade → (current)
- Tab: Progress → c18-collection-progress
- Tab: Shop → c05-shop

**Fix Required:** ✨ Add Bottom Tab Bar

---

#### **c05-shop** (Pattern A)
**Current Navigation:**
- Top: [← Back] "Shop" [Reveries: 1,234]
- Bottom: **MISSING Tab Bar** ❌

**Proposed Navigation:**
- Top: [← Back] "Shop" [Reveries: 1,234]
- Bottom: Tab Bar (5 tabs) - **Shop active**

**Navigation Targets:**
- ← Back → c01-main-lobby
- Product tap → Purchase confirmation modal
- Tab: Home → c01-main-lobby
- Tab: Cards → c02-card-library
- Tab: Upgrade → c04-upgrade-tree
- Tab: Progress → c18-collection-progress
- Tab: Shop → (current)

**Fix Required:** ✨ Add Bottom Tab Bar

---

#### **c06-run-prep** (Pattern A)
**Current Navigation:**
- Top: [← Back] "Run Preparation" [empty]
- Bottom: **MISSING Tab Bar** ❌

**Proposed Navigation:**
- Top: [← Back] "Run Preparation" [empty]
- Bottom: Tab Bar (5 tabs) - **Home active** (contextual)

**Navigation Targets:**
- ← Back → c01-main-lobby
- Edit Deck → c03-deck-builder
- 🚀 Start Run → c07-in-run (tab bar disappears)
- Tab: Home → c01-main-lobby
- Tab: Cards → c02-card-library
- Tab: Upgrade → c04-upgrade-tree
- Tab: Progress → c18-collection-progress
- Tab: Shop → c05-shop

**Fix Required:** ✨ Add Bottom Tab Bar

---

#### **c07-in-run** (Pattern B)
**Current Navigation:**
- Top: HP/Energy/Reveries status bar
- Node map: 10 nodes with current position
- Bottom: [⏩ Skip] [🤖 Auto] [☰ Menu]
- **No Tab Bar** ✅ Correct

**Navigation Targets:**
- ☰ Menu → c15-pause-menu (planned)
- Node action → Context-specific (Combat, Shop, Event, etc.)
- Memory node → Collect → Continue
- Combat node → c08-combat
- Shop node → c14-shop-in-run (planned)
- Event node → Choice modal
- Boss node → c08-combat (boss variant)
- Run complete → c09-victory-screen

**Status:** ✅ Correct (no tab bar during run)

---

#### **c08-combat** (Pattern B)
**Current Navigation:**
- Top: [☰ Menu] "Turn: 3" [End Turn]
- **No Tab Bar** ✅ Correct

**Navigation Targets:**
- ☰ Menu → c15-pause-menu (planned)
- End Turn → Enemy turn → Player turn
- Victory → c11-rewards-modal OR c07-in-run (next node)
- Defeat → c10-defeat-screen
- Card tap → Play card OR card detail modal

**Status:** ✅ Correct (no tab bar during combat)

---

#### **c09-victory-screen** (Pattern D)
**Current Navigation:**
- Full-screen victory UI
- **No Tab Bar** ✅ Correct
- **No Top Bar** ✅ Correct

**Navigation Targets:**
- Claim Reward → Add card to collection
- Continue to Main Lobby → c01-main-lobby
- 🔄 Play Again → c06-run-prep (same Dreamer)

**Status:** ✅ Correct

---

#### **c10-defeat-screen** (Pattern D)
**Current Navigation:**
- Full-screen defeat UI
- **No Tab Bar** ✅ Correct
- **No Top Bar** ✅ Correct

**Navigation Targets:**
- 🔄 Retry → c06-run-prep (same setup)
- Return to Main Lobby → c01-main-lobby
- View Death Recap → Death recap modal (planned)

**Status:** ✅ Correct

---

#### **c11-rewards-modal** (Pattern C)
**Current Navigation:**
- Full-screen modal overlay
- **No Tab Bar** ✅ Correct
- Integrated close/skip button

**Navigation Targets:**
- Add card to Deck → Return to c07-in-run (next node)
- Skip Reward → Return to c07-in-run (next node)

**Status:** ✅ Correct

---

#### **c12-settings** (Pattern C)
**Current Navigation:**
- Top: [← Back] "Settings" [empty]
- **No Tab Bar** ✅ Correct (modal-like screen)

**Navigation Targets:**
- ← Back → c01-main-lobby (or previous screen)
- View Credits → Credits screen (planned)
- Reset Tutorial → Confirmation modal

**Status:** ✅ Correct (settings is modal-like)

---

## 🎨 Bottom Tab Bar Specification

### Visual Design
```
┌─────────────────────────────────────┐
│  🏠     🎴     ⬆️     📊     🛒   │
│ Home  Cards Upgrade Progress Shop  │
└─────────────────────────────────────┘
```

**Dimensions:**
- Height: 60px
- Width: 390px (full width)
- Background: #2C2C3E
- Border-top: 1px solid #1A1A2E

**Tab Item:**
- Width: 78px (390px / 5)
- Height: 60px
- Gap: 4px between icon and label

**Icon:**
- Size: 24×24px
- Active color: #7B9EF0
- Inactive color: #666666

**Label:**
- Font: Nunito Regular 12px
- Active color: #FFFFFF
- Inactive color: #888888

**Active State:**
- Icon: #7B9EF0
- Label: #FFFFFF
- Optional: 2px blue bar on top (#7B9EF0)

**Interaction:**
- Tap: Immediate navigation
- Tap same tab: Scroll to top (if applicable)
- Transition: Fade 200ms

---

## 📋 Screen Categories

### Category 1: Meta Screens (with Bottom Tab Bar)
Screens where user manages progression, collection, upgrades outside of runs.

**Screens:**
- c01-main-lobby ✅ (has tab bar)
- c02-card-library ❌ (needs tab bar)
- c03-deck-builder ❌ (needs tab bar)
- c04-upgrade-tree ❌ (needs tab bar)
- c05-shop ❌ (needs tab bar)
- c06-run-prep ❌ (needs tab bar)
- c16-profile (planned)
- c17-daily-missions (planned)
- c18-collection-progress (planned)

**Bottom Tab Bar:** Always visible

---

### Category 2: In-Run Screens (no Bottom Tab Bar)
Screens during active run gameplay.

**Screens:**
- c07-in-run ✅
- c08-combat ✅
- c14-shop-in-run (planned)
- c13-card-upgrade-modal (planned) - contextual

**Bottom Tab Bar:** Hidden (run in progress)

---

### Category 3: Full-Screen Modals (no Bottom Tab Bar)
Modal-like screens that overlay or replace entire view.

**Screens:**
- c09-victory-screen ✅
- c10-defeat-screen ✅
- c11-rewards-modal ✅
- c12-settings ✅
- c15-pause-menu (planned)
- c19-tutorial-overlay (planned)
- c20-loading-screen (planned)

**Bottom Tab Bar:** Hidden (modal overlay)

---

## 🔄 Navigation Flow Diagram

```
┌─────────────────────────────────────────────────────┐
│                   MAIN LOBBY (c01)                  │
│          [Bottom Tab Bar: Home active]              │
└─────────┬───────────────────────────────┬───────────┘
          │                               │
     ┌────▼────┐                     ┌────▼────┐
     │ CARD    │                     │ RUN     │
     │ LIBRARY │                     │ PREP    │
     │ (c02)   │                     │ (c06)   │
     │ [Tabs]  │                     │ [Tabs]  │
     └────┬────┘                     └────┬────┘
          │                               │
     ┌────▼────┐                     ┌────▼────┐
     │ DECK    │                     │ IN-RUN  │
     │ BUILDER │                     │ (c07)   │
     │ (c03)   │                     │ [No Tab]│
     │ [Tabs]  │                     └────┬────┘
     └─────────┘                          │
                                     ┌────▼────┐
     ┌─────────┐                     │ COMBAT  │
     │ UPGRADE │                     │ (c08)   │
     │ TREE    │                     │ [No Tab]│
     │ (c04)   │                     └────┬────┘
     │ [Tabs]  │                          │
     └─────────┘                    ┌─────┴─────┐
                                    │           │
     ┌─────────┐              ┌─────▼─────┐ ┌──▼──────┐
     │  SHOP   │              │  VICTORY  │ │ DEFEAT  │
     │  (c05)  │              │   (c09)   │ │ (c10)   │
     │ [Tabs]  │              │ [No Tab]  │ │[No Tab] │
     └─────────┘              └───────────┘ └─────────┘
                                    │           │
                              ┌─────▼───────────▼─────┐
                              │    MAIN LOBBY (c01)   │
                              └───────────────────────┘

     ┌─────────┐
     │SETTINGS │
     │ (c12)   │
     │[No Tab] │
     └─────────┘
```

---

## ✨ Required Updates

### High Priority (5 screens)
1. **c02-card-library** - Add bottom tab bar (Cards active)
2. **c03-deck-builder** - Add bottom tab bar (Cards active)
3. **c04-upgrade-tree** - Add bottom tab bar (Upgrade active)
4. **c05-shop** - Add bottom tab bar (Shop active)
5. **c06-run-prep** - Add bottom tab bar (Home active)

### Low Priority (1 screen)
6. **c01-main-lobby** - Ensure tab bar styling is consistent

---

## 🎯 Implementation Checklist

### Step 1: Create Bottom Tab Bar Component
```jsx
const BottomTabBar = ({ activeTab }) => (
  <div style={{
    position: 'absolute',
    bottom: 0,
    left: 0,
    width: '390px',
    height: '60px',
    background: '#2C2C3E',
    borderTop: '1px solid #1A1A2E',
    display: 'flex',
    justifyContent: 'space-around',
    alignItems: 'center',
    zIndex: 100
  }}>
    <TabItem icon="🏠" label="Home" active={activeTab === 'home'} />
    <TabItem icon="🎴" label="Cards" active={activeTab === 'cards'} />
    <TabItem icon="⬆️" label="Upgrade" active={activeTab === 'upgrade'} />
    <TabItem icon="📊" label="Progress" active={activeTab === 'progress'} />
    <TabItem icon="🛒" label="Shop" active={activeTab === 'shop'} />
  </div>
);
```

### Step 2: Update Screen Heights
Adjust main content height to account for bottom tab bar:
- Old: `height: 844px`
- New content area: `height: calc(844px - 60px)` = 784px

### Step 3: Update Each Screen
- c02: Add `<BottomTabBar activeTab="cards" />`
- c03: Add `<BottomTabBar activeTab="cards" />`
- c04: Add `<BottomTabBar activeTab="upgrade" />`
- c05: Add `<BottomTabBar activeTab="shop" />`
- c06: Add `<BottomTabBar activeTab="home" />`

---

## 📝 Notes

**Tab "Progress" (c18):**
- Currently planned, not yet implemented
- Shows collection progress, achievements
- For now, tab is present but grayed out

**Navigation Consistency:**
- All meta screens have same bottom tab bar
- In-run screens hide tab bar for immersion
- Modals hide tab bar to focus attention

**Back Button Behavior:**
- Always returns to previous screen OR main lobby
- Never breaks user's mental model
- Consistent position (top-left)

---

**Total Updates Required:** 5 HTML files need bottom tab bar addition
**Estimated Time:** 1-2 hours (20-25 min per file)
