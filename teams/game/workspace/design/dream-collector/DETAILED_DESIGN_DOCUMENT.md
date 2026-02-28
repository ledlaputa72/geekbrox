# Dream Collector - Detailed Design Document
**Version:** 1.0  
**Date:** February 23, 2026  
**Purpose:** Implementation-ready game design specification  
**Target:** Development Team (Programmers, Artists, QA)

---

## Document Overview

This document provides **implementation-level specifications** for Dream Collector, a 2D mobile idle/roguelike/deckbuilding game. Every system, mechanic, and value is defined with precise numbers suitable for direct coding.

**Structure:**
1. [Game Systems Design](#1-game-systems-design) - Core mechanics and formulas
2. [Content Specification](#2-content-specification) - All cards, monsters, events
3. [Balance System](#3-balance-system) - Economy, difficulty, progression curves
4. [UI/UX Flow](#4-uiux-flow) - Screen layouts, navigation, feedback
5. [Technical Specification](#5-technical-specification) - Data structures, performance targets
6. [Development Milestones](#6-development-milestones) - Phased delivery roadmap

---

## Table of Contents
- [1. Game Systems Design](#1-game-systems-design)
  - [1.1 Combat System](#11-combat-system)
  - [1.2 Deckbuilding System](#12-deckbuilding-system)
  - [1.3 Progression System](#13-progression-system)
  - [1.4 Resource System](#14-resource-system)
  - [1.5 Idle Mechanics](#15-idle-mechanics)
- [2. Content Specification](#2-content-specification)
  - [2.1 Card Database](#21-card-database)
  - [2.2 Monster Database](#22-monster-database)
  - [2.3 Dungeon Structure](#23-dungeon-structure)
  - [2.4 Reward Tables](#24-reward-tables)
- [3. Balance System](#3-balance-system)
  - [3.1 Difficulty Curve](#31-difficulty-curve)
  - [3.2 Economic Balance](#32-economic-balance)
  - [3.3 Card Balance](#33-card-balance)
  - [3.4 Progression Speed](#34-progression-speed)
- [4. UI/UX Flow](#4-uiux-flow)
  - [4.1 Screen Structure](#41-screen-structure)
  - [4.2 Combat Screen Layout](#42-combat-screen-layout)
  - [4.3 Input System](#43-input-system)
  - [4.4 Feedback System](#44-feedback-system)
- [5. Technical Specification](#5-technical-specification)
  - [5.1 Platform Requirements](#51-platform-requirements)
  - [5.2 Data Structure](#52-data-structure)
  - [5.3 Save System](#53-save-system)
  - [5.4 Performance Targets](#54-performance-targets)
- [6. Development Milestones](#6-development-milestones)

---

# 1. Game Systems Design

## 1.0 Meta Game System (Dream Linking)

### 1.0.1 Overview: Tarot Card-Based Dream Connection

**Core Concept:**
Dream Collector features a **meta-game layer** above the combat system, where players connect **Tarot-style Dream Cards** in a 3-stage sequence to create complete dreams. This system determines:
- Which combat encounters occur
- Rewards and bonuses earned
- Idle progression efficiency

**System Hierarchy:**
```
┌─────────────────────────────────────────┐
│ META GAME: Dream Linking (Tarot Cards) │ ← Player selects/draws cards
├─────────────────────────────────────────┤
│ COMBAT LAYER: Deckbuilding Battles     │ ← Triggered by Dream progress
├─────────────────────────────────────────┤
│ IDLE LAYER: Offline Progression        │ ← Runs automatically
└─────────────────────────────────────────┘
```

**Integration with Paper Prototype:**
- **Combat system remains unchanged** (PROTOTYPE_RULEBOOK.md mechanics)
- Tarot cards **trigger** combat encounters within dreams
- Players build combat decks separately from Dream Cards

---

### 1.0.2 Dream Linking Mechanics

**3-Stage Dream Structure:**
```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ DREAM START  │ →  │ DREAM MIDDLE │ →  │ DREAM END    │
│ (Tarot Card) │    │ (Tarot Card) │    │ (Tarot Card) │
│              │    │ + Combat     │    │              │
└──────────────┘    └──────────────┘    └──────────────┘
      Block 1            Block 2             Block 3
```

**Connection States:**

| Connection Type | Condition | Rewards | Description |
|----------------|-----------|---------|-------------|
| **Perfect Dream** (완성형 꿈) | All 3 cards same series | 100% base + 50% bonus | Complete story arc |
| **Partial Dream** | 2 cards match | 100% base + 20% bonus | Coherent but incomplete |
| **Broken Dream** (개꿈) | No matches | 50% base rewards | Random disconnected dreams |

**Example:**
```
Perfect Dream:
[The Fool - I] → [The Fool - II] → [The Fool - III]
Result: "The Fool's Journey" complete story
Bonus: +50% Reveries, rare card guaranteed

Broken Dream:
[The Fool - I] → [The Tower - II] → [Death - III]
Result: Incoherent dream fragments
Penalty: -50% Reveries, no bonus card
```

---

### 1.0.3 Tarot Card System

**Dream Card Structure:**
```json
{
  "id": "dream_001",
  "name": "The Fool",
  "series": "Major Arcana - The Fool",
  "stage": 1,
  "tier": "Common",
  "combat_triggers": [
    {"type": "basic_enemy", "difficulty": 1},
    {"type": "event", "id": "crossroads"}
  ],
  "story_text": "A young dreamer stands at the edge of a cliff, ready to leap into the unknown.",
  "completion_bonus": {
    "reveries": 50,
    "card_drop": "guaranteed_uncommon"
  }
}
```

**Card Drawing Mechanic:**
```python
def draw_dream_card(player, block_stage, tier):
    """
    Draw a random Dream Card for the current block.
    Higher tiers = lower connection probability.
    """
    
    # Tier affects series distribution
    if tier == "common":
        series_weights = {"same_as_previous": 60, "different": 40}
    elif tier == "rare":
        series_weights = {"same_as_previous": 30, "different": 70}
    elif tier == "epic":
        series_weights = {"same_as_previous": 10, "different": 90}
    
    # Draw card
    if block_stage == 1:
        # First block: random series
        return random_dream_card(tier)
    else:
        # Blocks 2-3: weighted by previous series
        previous_series = player.current_dream.blocks[-1].series
        
        if weighted_random(series_weights) == "same_as_previous":
            return draw_from_series(previous_series, block_stage, tier)
        else:
            return random_dream_card(tier)
```

**Re-draw Mechanic:**
```yaml
Re-draw Cost: 10 Reveries (Block 1), 20 Reveries (Block 2), 30 Reveries (Block 3)
Re-draw Limit: 3 per block
Strategy: Players can spend Reveries to re-draw cards, increasing connection chance
```

---

### 1.0.4 Dream Series (Tarot-Inspired)

**Series Categories (30 total series):**

| Series Name | Theme | Stages | Combat Type | Tier |
|-------------|-------|--------|-------------|------|
| **The Fool's Journey** | Beginnings | 3 | Easy enemies | Common |
| **The Tower's Fall** | Chaos | 3 | Hard enemies | Rare |
| **Death's Transformation** | Change | 3 | Elite enemies | Epic |
| **The Moon's Illusion** | Mystery | 3 | Boss encounters | Legendary |

**Example Series: The Fool's Journey (Common)**
```yaml
Stage 1 - The Fool Awakens:
  Story: "A dreamer opens their eyes in a strange new world."
  Combat: 1× Dream Wisp (tutorial enemy)
  Reward: 20 Reveries

Stage 2 - The Fool Explores:
  Story: "Wandering through shifting landscapes, curiosity drives them forward."
  Combat: 1× Shadow Whisper + 1× Event (Crossroads)
  Reward: 40 Reveries

Stage 3 - The Fool Leaps:
  Story: "At the cliff's edge, they choose to leap into the unknown."
  Combat: 1× Lucid Hunter (mini-boss)
  Reward: 60 Reveries + Series Completion Bonus

Completion Bonus:
  - Total: 120 Reveries (base) + 60 (50% bonus) = 180 Reveries
  - Guaranteed: 1 Uncommon card
  - Achievement: "First Steps" unlocked
```

---

### 1.0.5 Energy System (Tarot Card Activation)

**Energy as Gating Mechanic:**
```yaml
Energy Purpose: Gate dream progression, monetization lever
Energy Max: 5 units
Energy Consumption: 1 unit per Dream Block (3 total per complete dream)
Energy Regeneration: 1 unit per 30 minutes (natural)
Energy Purchase: 5 units for $0.99 (IAP)

Daily Free Energy: +3 units at daily reset (00:00 local time)
```

**Energy Flow:**
```python
class EnergyManager:
    def __init__(self):
        self.max_energy = 5
        self.current_energy = 5
        self.regen_rate = 1800  # 30 minutes in seconds
        self.last_regen = time.time()
    
    def can_start_dream_block(self):
        return self.current_energy >= 1
    
    def consume_energy(self, amount=1):
        if self.current_energy >= amount:
            self.current_energy -= amount
            return True
        return False
    
    def update(self):
        """Called every frame to regenerate energy"""
        now = time.time()
        elapsed = now - self.last_regen
        
        if elapsed >= self.regen_rate:
            regen_count = int(elapsed / self.regen_rate)
            self.current_energy = min(self.max_energy, self.current_energy + regen_count)
            self.last_regen = now
    
    def add_energy(self, amount):
        """IAP or reward"""
        self.current_energy = min(self.max_energy, self.current_energy + amount)
```

**Energy Monetization:**
```yaml
Energy Packs:
  - Small Pack: 5 Energy → $0.99
  - Medium Pack: 15 Energy → $2.99
  - Large Pack: 50 Energy → $9.99

Alternative: Energy-Free Mode ($4.99 one-time purchase)
  - Unlimited energy
  - No regeneration wait
  - Premium feature
```

---

### 1.0.6 Dream Home (Hub Screen)

**UI Layout:**
```
┌────────────────────────────────────┐
│ [Energy: ⚡⚡⚡▫▫] [Settings ⚙]    │ ← Top Bar (Energy display)
├────────────────────────────────────┤
│  ╔════════╗  ╔════════╗  ╔════════╗│
│  ║ BLOCK 1║  ║ BLOCK 2║  ║ BLOCK 3║│ ← Tarot Cards (Horizontal)
│  ║  [?]   ║  ║ [LOCK] ║  ║ [LOCK] ║│   Block 1 active, 2-3 locked
│  ╚════════╝  ╚════════╝  ╚════════╝│
│  [Draw Card - 1 Energy]            │ ← Action Button
├────────────────────────────────────┤
│ Current Dream Story:               │
│ "The Fool awakens in a strange     │ ← Story Text (scrollable)
│  world, filled with wonder and     │
│  uncertainty..."                   │
├────────────────────────────────────┤
│ Previous Dreams (Stack):           │
│ ┌──────────────────────────────┐  │
│ │ [Complete] The Fool's Journey │  │ ← Scrollable History
│ │ +180 Reveries • 2 hours ago   │  │
│ └──────────────────────────────┘  │
│ ┌──────────────────────────────┐  │
│ │ [Broken] Mixed Dreams         │  │
│ │ +50 Reveries • 5 hours ago    │  │
│ └──────────────────────────────┘  │
└────────────────────────────────────┘
```

**Interaction Flow:**
```
1. Player Opens App → Dream Home loads
   ↓
2. Check Current Dream State:
   - No active dream? Start new dream (Block 1)
   - Active dream? Resume where left off
   ↓
3. Player taps "Draw Card" (costs 1 Energy)
   ↓
4. Tarot Card Reveal Animation (2s)
   ↓
5. Card placed in current block
   ↓
6. If Block has combat trigger → Transition to Combat
   ↓
7. After combat → Return to Dream Home
   ↓
8. If Block 3 complete → Calculate Dream Completion
   ↓
9. Show Dream Result Screen (rewards, story)
   ↓
10. Stack completed dream, start new dream
```

---

### 1.0.7 Dream-to-Combat Transition

**Visual Transition:**
```
Dream Home Screen (Calm, Floating Tarot Cards)
        ↓
[Tarot Card pulses and grows]
        ↓
[Screen vortex effect - player "sucked into" card]
        ↓
Combat Screen (Dark, Intense)
```

**Technical Implementation:**
```python
def transition_to_combat(dream_block):
    # Store return state
    game_state.previous_screen = "dream_home"
    game_state.current_dream_block = dream_block
    
    # Trigger animation
    play_animation("vortex_transition", duration=1.5)
    
    # Load combat
    combat_encounter = dream_block.combat_trigger
    load_combat_scene(combat_encounter)
    
    # After combat ends, return to Dream Home
    on_combat_end = lambda result: return_to_dream_home(result)
```

**Combat Return Flow:**
```python
def return_to_dream_home(combat_result):
    # Apply combat rewards
    player.reveries += combat_result.reveries_earned
    player.cards.extend(combat_result.cards_earned)
    
    # Update dream progress
    current_dream.blocks[current_block_index].completed = True
    
    # Transition back
    play_animation("emerge_from_vortex", duration=1.5)
    load_scene("dream_home")
    
    # Check if dream complete
    if all_blocks_complete(current_dream):
        calculate_dream_completion_bonus()
```

---

### 1.0.8 Idle Dream Automation

**Automatic Dream Playing (While Offline):**
```python
def calculate_idle_dreams(time_away_seconds):
    """
    While offline, the game automatically plays dreams
    using player's auto-battle settings.
    """
    
    # Calculate energy regenerated while away
    energy_regen = min(5, time_away_seconds // 1800)
    
    # Each dream costs 3 energy (3 blocks)
    dreams_playable = energy_regen // 3
    
    # Simulate dreams with auto-battle
    total_rewards = {
        "reveries": 0,
        "cards": []
    }
    
    for i in range(dreams_playable):
        dream_result = simulate_auto_dream(player.auto_battle_settings)
        total_rewards["reveries"] += dream_result.reveries
        total_rewards["cards"].extend(dream_result.cards)
    
    return total_rewards
```

**Auto-Battle Settings (for Idle):**
```yaml
Aggressive Mode:
  - Prioritize high-damage cards
  - Ignore defense unless HP < 30%
  - Fast combat, higher risk

Defensive Mode:
  - Prioritize block cards
  - Only attack when safe
  - Slow combat, lower risk

Balanced Mode:
  - Mix of attack and defense
  - Adaptive to enemy threat
  - Medium speed, medium risk
```

---

## 1.1 Combat System

### 1.1.1 Turn-Based Combat Flow

**Combat Structure:**
```
┌──────────────────────────────────────┐
│ COMBAT INITIALIZATION                │
│ - Load enemy stats from database     │
│ - Set player HP/Energy from run state│
│ - Draw 4 cards (starting hand)       │
└──────────────────────────────────────┘
           ↓
┌──────────────────────────────────────┐
│ PLAYER TURN                          │
│ 1. Draw Phase: Draw 1 card           │
│ 2. Action Phase: Play cards          │
│    - Spend Energy to play cards      │
│    - Resolve card effects            │
│    - Update HP/Energy state          │
│ 3. End Phase: Check hand limit (5)   │
└──────────────────────────────────────┘
           ↓
┌──────────────────────────────────────┐
│ ENEMY TURN                           │
│ 1. Execute AI pattern                │
│ 2. Apply attack damage               │
│ 3. Check for special abilities       │
│ 4. Trigger status effects            │
└──────────────────────────────────────┘
           ↓
┌──────────────────────────────────────┐
│ CHECK WIN/LOSS CONDITIONS            │
│ - Enemy HP ≤ 0? → Victory            │
│ - Player HP ≤ 0? → Defeat            │
│ - Else: Loop to Player Turn          │
└──────────────────────────────────────┘
```

### 1.1.2 Damage Calculation

**Attack Formula:**
```
Base Damage = Card Attack Value
Modifiers = Synergy Bonuses + Status Effects
Final Damage = Base Damage × (1 + Modifiers)

Example:
- Card: [Lucid Strike] = 10 damage
- Synergy: +20% from [Fear Essence]
- Status: +10% from player buff
- Final = 10 × (1 + 0.2 + 0.1) = 13 damage
```

**Defense Formula:**
```
Blocked Damage = MIN(Defense Value, Incoming Damage)
Damage Taken = MAX(0, Incoming Damage - Defense Value)

Example:
- Enemy Attack: 8 damage
- Player Defense: 5 (from [Dream Shield])
- Damage Taken = MAX(0, 8 - 5) = 3 HP lost
```

**Critical Hits (Optional - Advanced Feature):**
```
Crit Chance = 5% base + card modifiers
Crit Multiplier = 1.5×

Example:
- Attack: 10 damage
- 5% chance → 15 damage (1.5× crit)
```

### 1.1.3 Energy System

**Energy Mechanics:**
```yaml
Starting Energy: 3 per turn
Energy Cost Range: 0-5 (card-dependent)
Energy Carry-Over: No (resets each turn)
Energy Generation: Some cards grant bonus Energy
Max Energy Cap: 10 (hard limit)
```

**Energy State Transitions:**
```
Turn Start → Reset to Max Energy (3)
     ↓
Play Card → Subtract Card Cost
     ↓
Check Energy → If < Card Cost, cannot play
     ↓
Turn End → Energy resets (unused Energy lost)
```

**Energy-Modifying Effects:**
```python
# Example: Card that drains Energy
if card.type == "energy_drain":
    player.energy -= card.drain_amount
    player.max_energy_this_turn -= card.drain_amount
    clamp(player.max_energy_this_turn, 0, 10)
```

### 1.1.4 Status Effects System

**Status Effect Types:**

| Effect | Duration | Mechanic |
|--------|----------|----------|
| **Vulnerable** | 1-3 turns | +50% damage taken |
| **Strength** | 1-3 turns | +3 damage dealt |
| **Weak** | 1-3 turns | -3 damage dealt |
| **Regeneration** | 2-4 turns | +2 HP per turn |
| **Poison** | 3 turns | -2 HP per turn |
| **Stunned** | 1 turn | Skip turn (cannot act) |

**Status Implementation:**
```python
class StatusEffect:
    def __init__(self, type, duration, potency):
        self.type = type
        self.duration = duration
        self.potency = potency
    
    def apply(self, entity):
        if self.type == "vulnerable":
            entity.damage_taken_multiplier += 0.5
        elif self.type == "strength":
            entity.damage_dealt_bonus += 3
        # ... etc.
    
    def tick(self):
        self.duration -= 1
        if self.duration <= 0:
            self.remove()
```

### 1.1.5 AI Patterns

**Basic Enemy AI:**
```python
class BasicAI:
    def __init__(self, attack_value):
        self.attack = attack_value
    
    def execute_turn(self, player):
        player.take_damage(self.attack)
```

**Pattern-Based AI (Advanced):**
```python
class PatternAI:
    def __init__(self, patterns):
        self.patterns = patterns  # List of (condition, action) tuples
        self.turn_count = 0
    
    def execute_turn(self, player):
        self.turn_count += 1
        
        # Example: Shadow Fiend (+1 Attack per turn)
        if self.turn_count % 3 == 0:
            self.attack += 1
        
        player.take_damage(self.attack)
```

**Conditional AI (Boss):**
```python
class BossAI:
    def __init__(self, hp, attack):
        self.hp = hp
        self.max_hp = hp
        self.attack = attack
        self.phase = 1
    
    def execute_turn(self, player):
        # Phase transition at 50% HP
        if self.hp < self.max_hp * 0.5 and self.phase == 1:
            self.phase = 2
            self.attack += 3  # Enrage
            player.drain_energy(1)
        
        player.take_damage(self.attack)
```

---

## 1.2 Deckbuilding System

### 1.2.1 Deck Structure

**Deck Constraints:**
```yaml
Minimum Cards: 8
Maximum Cards: 12
Duplicate Limit: 3 copies per card
Starting Deck: 8 pre-selected cards (tutorial)
```

**Deck Composition Rules:**
```python
class Deck:
    def __init__(self):
        self.cards = []
        self.max_size = 12
        self.min_size = 8
        self.duplicate_limit = 3
    
    def can_add_card(self, card_id):
        if len(self.cards) >= self.max_size:
            return False, "Deck is full"
        
        count = self.cards.count(card_id)
        if count >= self.duplicate_limit:
            return False, f"Max {self.duplicate_limit} copies allowed"
        
        return True, "OK"
    
    def add_card(self, card_id):
        success, msg = self.can_add_card(card_id)
        if success:
            self.cards.append(card_id)
        return success, msg
```

### 1.2.2 Card Acquisition

**Sources of New Cards:**

| Source | Frequency | Quality |
|--------|-----------|---------|
| Combat Victory | 100% (random 1 card) | Common-Uncommon |
| Event Success | 50% | Uncommon-Rare |
| Boss Defeat | 100% (choose 1 of 3) | Rare-Epic |
| Shop Purchase | On-demand | All rarities |
| Achievement | One-time | Epic-Legendary |

**Card Drop Formula:**
```python
def generate_card_reward(source, player_level):
    rarity_weights = {
        "common": 60,
        "uncommon": 30,
        "rare": 8,
        "epic": 1.5,
        "legendary": 0.5
    }
    
    # Adjust weights based on source
    if source == "boss":
        rarity_weights["rare"] += 20
        rarity_weights["epic"] += 5
    
    # Increase rare drops with player level
    rarity_weights["rare"] += player_level * 0.5
    rarity_weights["epic"] += player_level * 0.1
    
    return weighted_random_choice(rarity_weights)
```

### 1.2.3 Card Upgrade System

**Upgrade Mechanics:**
```yaml
Upgrade Cost Formula:
  base_cost = 20 * rarity_multiplier * (level + 1)
  
Rarity Multipliers:
  Common: 1.0
  Uncommon: 1.5
  Rare: 2.5
  Epic: 4.0
  Legendary: 7.0

Max Upgrade Level: 10

Upgrade Effects:
  - Damage/Block: +20% per level
  - Reveries: +25% per level
  - Energy Cost: -1 at level 5, -1 at level 10
```

**Example Upgrade Path:**
```
[Lucid Strike] - Level 1
- Cost: 2 Energy
- Effect: Deal 10 damage
- Upgrade Cost: 20 × 2.5 × 2 = 100 Reveries

[Lucid Strike] - Level 5
- Cost: 1 Energy (reduced at level 5)
- Effect: Deal 20 damage (10 × 2.0)
- Upgrade Cost: 20 × 2.5 × 6 = 300 Reveries

[Lucid Strike] - Level 10 (Max)
- Cost: 0 Energy (reduced at level 10)
- Effect: Deal 30 damage (10 × 3.0)
- Upgrade Cost: N/A (maxed)
```

### 1.2.4 Synergy System

**Synergy Tags:**
```python
synergy_tags = {
    "nightmare": ["Fear Essence", "Shadow Step", "Terror Wave", "Nightmare King", "Phobia"],
    "memory": ["Nostalgia", "Déjà Vu", "Memory Lane", "Perfect Recall", "Timeless"],
    "lucid": ["Lucid Awakening", "Reality Bender", "Dream Logic", "Hyper Awareness", "God Mode"]
}
```

**Synergy Activation:**
```python
def calculate_synergy_bonus(deck, active_cards):
    bonus_multiplier = 1.0
    
    # Check for Nightmare synergy
    nightmare_count = sum(1 for c in active_cards if c.has_tag("nightmare"))
    if nightmare_count >= 2:
        bonus_multiplier += 0.2  # +20% for 2+ Nightmare cards
    if nightmare_count >= 3:
        bonus_multiplier += 0.3  # +30% for 3+ Nightmare cards
    
    # Check for enabler cards (e.g., Fear Essence)
    if "fear_essence" in active_cards:
        nightmare_energy_discount = 1  # All Nightmare cards cost -1 Energy
    
    return bonus_multiplier, nightmare_energy_discount
```

**Combo Examples:**

**Nightmare Combo:**
```
[Fear Essence] (Cost: 2) → Enables Nightmare synergy
+ [Shadow Step] (Cost: 1-1=0) → Deal 10 damage (5 × 2 from synergy)
+ [Terror Wave] (Cost: 3) → Deal 8 base + 3×3 = 17 damage
Total: 27 damage for 5 Energy (or 4 with discount)
```

**Memory Combo:**
```
[Nostalgia] (Cost: 2) → Memory Nodes draw 1 card
+ [Memory Lane] (Cost: 2) → Gain 5 Reveries per Memory card
+ [Perfect Recall] (Cost: 3) → Draw 5 cards (with 3+ Memory)
Total: Massive card advantage + Reverie generation
```

---

## 1.3 Progression System

### 1.3.1 Run Structure

**Single Run Flow:**
```
1. SELECT DREAMER (Difficulty: Easy/Medium/Hard)
2. BUILD DECK (8-12 cards from collection)
3. START RUN (10 nodes)
4. NAVIGATE NODES:
   - Memory Node (60%): Collect Reveries
   - Event Node (20%): Choice-based rewards
   - Combat Node (15%): Fight enemy
   - Boss Node (5%): Final fight
5. COMPLETE RUN:
   - Victory: Full rewards
   - Defeat: 50% rewards
6. RETURN TO LOBBY: Spend Reveries on upgrades
```

**Node Generation Algorithm:**
```python
def generate_run_path(length=10):
    nodes = []
    
    # First node always Memory (safe start)
    nodes.append("memory")
    
    # Generate middle nodes (nodes 2-9)
    for i in range(1, length - 1):
        roll = random.uniform(0, 100)
        
        if roll < 60:
            nodes.append("memory")
        elif roll < 80:
            nodes.append("event")
        else:
            nodes.append("combat")
    
    # Last node always Boss
    nodes.append("boss")
    
    # Ensure at least 2 combat nodes before boss
    combat_count = nodes.count("combat")
    if combat_count < 2:
        for i in range(2 - combat_count):
            idx = random.randint(5, 8)
            nodes[idx] = "combat"
    
    return nodes
```

### 1.3.2 Dreamer System

**Dreamer Stats:**
```yaml
Serenity (Easy):
  HP: 10
  Energy: 3
  Special: Heals 1 HP every 3 nodes
  
Anxiety (Medium):
  HP: 8
  Energy: 4
  Special: Draw +1 card per turn
  
Fear (Hard):
  HP: 6
  Energy: 5
  Special: +50% damage dealt/taken
```

**Dreamer Unlocks:**
```python
dreamer_unlock_conditions = {
    "serenity": {"condition": "default", "cost": 0},
    "anxiety": {"condition": "complete_run", "runs": 1, "cost": 100},
    "fear": {"condition": "complete_run", "runs": 5, "cost": 500},
    "nostalgia": {"condition": "prestige", "prestige_level": 1, "cost": 1000},
    "lucid": {"condition": "achievement", "achievement_id": "perfect_run"}
}
```

### 1.3.3 Prestige System (Ascension)

**Prestige Requirements:**
```yaml
First Prestige: 10,000 Reveries collected (lifetime)
Subsequent Prestiges: 2× previous threshold (20k, 40k, 80k...)

Prestige Resets:
  - Player HP/Energy (back to base)
  - Deck (back to starter 8 cards)
  - Reveries (reset to 0)

Prestige Keeps:
  - Card Collection (all unlocked cards)
  - Upgrade Levels (permanent)
  - Dream Shards (permanent currency)
  - Achievements
```

**Dream Shard Formula:**
```python
def calculate_dream_shards_earned(total_reveries_collected):
    # 1 Dream Shard per 1000 Reveries collected
    base_shards = total_reveries_collected // 1000
    
    # Bonus for completing runs
    completed_runs = player_stats.runs_completed
    bonus_shards = completed_runs * 5
    
    return base_shards + bonus_shards
```

**Prestige Bonus Tree:**
```yaml
Tier 1 (Cost: 10 Dream Shards each):
  - Idle Rate +10%
  - Starting HP +2
  - Starting Energy +1
  - Unlock Dreamer: Anxiety

Tier 2 (Cost: 25 Dream Shards each):
  - Idle Rate +25%
  - Card Upgrade Cost -20%
  - Starting Deck Size +2
  - Unlock Dreamer: Fear

Tier 3 (Cost: 50 Dream Shards each):
  - Idle Rate +50%
  - Rare Card Drop Rate +10%
  - Combat Rewards +50%
  - Unlock Dreamer: Nostalgia

Tier 4 (Cost: 100 Dream Shards each):
  - Idle Rate +100%
  - Boss Rewards +100%
  - Energy Cost -1 (all cards)
  - Unlock Nightmare Mode
```

---

## 1.4 Resource System

### 1.4.1 Reveries (Primary Currency)

**Reverie Sources:**
```yaml
Memory Node: 10 base + (2 × collection_card_count)
Combat Victory: 30-100 (scales with enemy difficulty)
Event Success: 20-150 (risk/reward dependent)
Boss Defeat: 100-300 (scales with boss tier)
Idle Generation: (deck_idle_power × 10) per hour
```

**Reverie Sinks:**
```yaml
Card Upgrades: 20-500 per upgrade
Card Purchases (Shop): 50-1000 per card
Deck Slot Expansion: 100 (unlock 9th slot), 200 (10th), etc.
Reroll Event: 50 Reveries
Healing at Memory Node: 30 Reveries per 5 HP
```

**Inflation Control:**
```python
# Soft cap on Reverie accumulation
def apply_reverie_softcap(reveries):
    if reveries < 10000:
        return reveries  # No cap
    elif reveries < 50000:
        excess = reveries - 10000
        return 10000 + (excess * 0.8)  # 20% reduction
    else:
        excess = reveries - 50000
        return 50000 + (excess * 0.5)  # 50% reduction
```

### 1.4.2 Energy (In-Combat Resource)

**Energy Properties:**
```yaml
Starting Energy: 3 (base) + Dreamer modifier
Max Energy: 10 (hard cap)
Energy Persistence: Resets every turn (no carry-over)
Energy Steal: Some enemies drain 1-2 Energy per turn
```

**Energy Generation Cards:**
```
[Reverie Burst] → Gain 2 Energy instantly
[Chain Lightning] → Refund 2 Energy on kill
[Lucid Awakening] → +1 Energy per turn (passive)
```

### 1.4.3 Health Points (HP)

**HP Mechanics:**
```yaml
Starting HP: 6-10 (Dreamer-dependent)
Max HP: Cannot exceed 20 (hard cap)
HP Regeneration: Rare (specific cards/events only)
HP Loss: Combat damage, event penalties
```

**HP Recovery Methods:**
```
1. Event Choice: "Rest" → Heal 5 HP
2. Memory Node: Spend 30 Reveries → Heal 5 HP
3. Card: [Sanctuary] → Heal 5 HP (once per combat)
4. Dreamer Ability: Serenity → Heal 1 HP every 3 nodes
```

**Death Prevention (Optional Mechanic):**
```python
# "Second Chance" item (consumable)
if player.hp <= 0 and player.has_item("second_chance"):
    player.hp = 1
    player.remove_item("second_chance")
    display_message("You barely survived!")
else:
    trigger_run_failure()
```

### 1.4.4 Dream Shards (Meta-Currency)

**Dream Shard Generation:**
```python
def on_prestige(player):
    lifetime_reveries = player.stats.total_reveries_collected
    completed_runs = player.stats.runs_completed
    
    shards_earned = (lifetime_reveries // 1000) + (completed_runs * 5)
    player.dream_shards += shards_earned
    
    # Reset temporary progress
    player.reveries = 0
    player.current_run = None
```

**Dream Shard Spending:**
```yaml
Permanent Upgrades:
  - +10% Idle Rate: 10 Shards (repeatable)
  - +1 Starting HP: 25 Shards (max 5 purchases)
  - -10% Upgrade Cost: 50 Shards (max 3 purchases)
  - Unlock Rare Card: 100 Shards

One-Time Unlocks:
  - New Dreamer: 100-500 Shards
  - Deck Slot +1: 50 Shards (max 4)
  - Auto-Battle: 200 Shards
```

---

## 1.5 Idle Mechanics

### 1.5.1 Offline Progression

**Idle Accumulation Formula:**
```python
def calculate_offline_rewards(time_away_seconds):
    # Cap at 8 hours (28800 seconds)
    capped_time = min(time_away_seconds, 28800)
    
    # Base rate: player's deck idle power
    idle_power = calculate_deck_idle_power(player.deck)
    
    # Prestige bonuses
    idle_multiplier = 1.0 + (player.prestige_idle_bonus / 100)
    
    # Calculate Reveries earned
    hours_away = capped_time / 3600
    reveries_earned = idle_power * 10 * hours_away * idle_multiplier
    
    return {
        "reveries": int(reveries_earned),
        "time_capped": time_away_seconds > 28800,
        "hours_calculated": min(hours_away, 8)
    }
```

**Deck Idle Power Calculation:**
```python
def calculate_deck_idle_power(deck):
    power = 0
    
    for card in deck:
        if card.has_tag("collection"):
            power += 5  # Collection cards add +5 power
        if card.has_tag("synergy"):
            power += 3  # Synergy cards add +3 power
        
        # Upgraded cards are more powerful
        power += card.level * 0.5
    
    return power
```

**Example Idle Calculation:**
```
Player with:
- 4 Collection cards (4 × 5 = 20 power)
- 2 Synergy cards (2 × 3 = 6 power)
- Average card level: 3 (+1.5 power per card × 12 cards = 18 power)
- Prestige bonus: +50% idle rate

Total Idle Power: 20 + 6 + 18 = 44

Offline for 6 hours:
Reveries = 44 × 10 × 6 × 1.5 = 3,960 Reveries
```

### 1.5.2 Auto-Battle System

**Auto-Battle AI:**
```python
class AutoBattleAI:
    def __init__(self, deck, player_stats):
        self.deck = deck
        self.player = player_stats
        self.strategy = self.determine_strategy()
    
    def determine_strategy(self):
        attack_cards = [c for c in self.deck if c.type == "attack"]
        defense_cards = [c for c in self.deck if c.type == "defense"]
        
        if len(attack_cards) > 6:
            return "aggressive"
        elif len(defense_cards) > 4:
            return "defensive"
        else:
            return "balanced"
    
    def play_turn(self, hand, enemy):
        if self.strategy == "aggressive":
            # Play highest damage cards first
            playable = [c for c in hand if c.cost <= self.player.energy]
            playable.sort(key=lambda c: c.damage, reverse=True)
            return playable[:2]  # Play top 2 damage cards
        
        elif self.strategy == "defensive":
            # Play defense if enemy attack > 5
            if enemy.attack > 5:
                defense = [c for c in hand if c.type == "defense"]
                return defense[:1]
            else:
                attack = [c for c in hand if c.type == "attack"]
                return attack[:1]
        
        # Balanced: alternate attack/defense
        return self.balanced_choice(hand)
```

### 1.5.3 Idle Optimization

**Recommended Idle Deck:**
```yaml
Optimal Idle Deck (12 cards):
  - 6× Collection Cards (e.g., Memory Shard, Dream Dust)
  - 3× Synergy Cards (e.g., Nightmare combos)
  - 2× Defense Cards (for auto-battles)
  - 1× High-damage Attack (for quick auto-battles)

Idle Power: ~60-80 (depending on upgrades)
Expected Reveries/hour: 600-1200 (with prestige bonuses)
```

**Idle vs Active Earnings Comparison:**
```
Active Play (30 min session):
- Complete 1 run (10 nodes)
- ~500-800 Reveries (with good deck)

Idle (8 hours):
- ~4,800-9,600 Reveries (optimized deck + prestige)

Balance: Idle provides steady income, active play provides fun + card unlocks
```

### 1.5.4 Push Notifications

**Notification Triggers:**
```yaml
Offline Cap Reached (8 hours):
  Title: "Dreams are overflowing!"
  Body: "Collect your {amount} Reveries!"
  Trigger: time_away >= 28800 seconds

Daily Reset:
  Title: "New dreams await"
  Body: "Daily quests and rewards available"
  Trigger: Local midnight

Special Event:
  Title: "Rare card available!"
  Body: "Check the shop for limited offers"
  Trigger: Server-side event start
```

---

# 2. Content Specification

## 2.0 Dream Card Database (Tarot System)

### 2.0.1 Dream Card Data Structure

**JSON Schema:**
```json
{
  "id": "dream_001",
  "name": "The Fool - Awakening",
  "name_ko": "바보 - 각성",
  "series": "The Fool's Journey",
  "series_id": "series_001",
  "stage": 1,
  "tier": "common",
  "theme": "beginnings",
  "story_text": "A young dreamer stands at the edge of a cliff, ready to leap into the unknown.",
  "story_text_ko": "젊은 꿈꾸는 자가 절벽 끝에 서서, 미지의 세계로 뛰어들 준비를 합니다.",
  "combat_triggers": [
    {
      "type": "combat",
      "enemy_id": "enemy_001",
      "chance": 0.8
    },
    {
      "type": "event",
      "event_id": "event_001",
      "chance": 0.2
    }
  ],
  "rewards": {
    "reveries_base": 20,
    "card_drop_chance": 0.3,
    "card_pool": ["common"]
  },
  "art_asset": "dreams/the_fool_01.png"
}
```

---

### 2.0.2 Dream Series List (30 Series)

**Tier 1: Common Series (10 series, 3 stages each = 30 cards)**

```yaml
series_001:
  name: "The Fool's Journey"
  theme: "Beginnings & Innocence"
  difficulty: Easy
  stages:
    - stage_1: "The Fool - Awakening"
      combat: 1× Dream Wisp
      reveries: 20
    - stage_2: "The Fool - Wandering"
      combat: 1× Sleepy Shadow + Event (Crossroads)
      reveries: 40
    - stage_3: "The Fool - Leaping"
      combat: 1× Memory Nibbler
      reveries: 60
  completion_bonus:
    reveries: +60 (50% of 120)
    card: Guaranteed Uncommon
    achievement: "First Steps"

series_002:
  name: "The Magician's Craft"
  theme: "Skill & Creation"
  difficulty: Easy
  stages:
    - stage_1: "The Magician - Tools"
      combat: 1× Shadow Whisper
      reveries: 25
    - stage_2: "The Magician - Practice"
      combat: 1× Anxious Echo
      reveries: 45
    - stage_3: "The Magician - Mastery"
      combat: 1× Dream Glutton
      reveries: 70
  completion_bonus:
    reveries: +70
    card: Guaranteed Uncommon (Attack type)

series_003:
  name: "The High Priestess's Secrets"
  theme: "Intuition & Mystery"
  difficulty: Easy
  stages:
    - stage_1: "The Priestess - Veil"
      combat: Event (Mystic Fountain)
      reveries: 30
    - stage_2: "The Priestess - Insight"
      combat: 1× Regret Wraith
      reveries: 50
    - stage_3: "The Priestess - Revelation"
      combat: Event (Dream Library)
      reveries: 80
  completion_bonus:
    reveries: +80
    card: Guaranteed Uncommon (Collection type)

series_004:
  name: "The Empress's Garden"
  theme: "Abundance & Growth"
  difficulty: Easy
  stages:
    - stage_1: "The Empress - Seeds"
    - stage_2: "The Empress - Bloom"
    - stage_3: "The Empress - Harvest"
  completion_bonus:
    reveries: +90
    card: Guaranteed Uncommon (Collection type)

series_005:
  name: "The Emperor's Throne"
  theme: "Authority & Structure"
  difficulty: Medium
  stages:
    - stage_1: "The Emperor - Foundation"
    - stage_2: "The Emperor - Rule"
    - stage_3: "The Emperor - Legacy"
  completion_bonus:
    reveries: +100
    card: Guaranteed Uncommon (Defense type)

series_006:
  name: "The Hierophant's Wisdom"
  theme: "Tradition & Teaching"
  difficulty: Medium
  completion_bonus:
    reveries: +110
    card: Guaranteed Rare

series_007:
  name: "The Lovers' Choice"
  theme: "Relationships & Decisions"
  difficulty: Medium
  completion_bonus:
    reveries: +120
    card: Guaranteed Rare

series_008:
  name: "The Chariot's Victory"
  theme: "Willpower & Triumph"
  difficulty: Medium
  completion_bonus:
    reveries: +130
    card: Guaranteed Rare (Attack type)

series_009:
  name: "Strength's Courage"
  theme: "Inner Strength & Compassion"
  difficulty: Medium
  completion_bonus:
    reveries: +140
    card: Guaranteed Rare (Defense type)

series_010:
  name: "The Hermit's Solitude"
  theme: "Introspection & Guidance"
  difficulty: Medium
  completion_bonus:
    reveries: +150
    card: Guaranteed Rare
```

**Tier 2: Rare Series (10 series, 3 stages each = 30 cards)**

```yaml
series_011:
  name: "The Wheel of Fortune"
  theme: "Fate & Change"
  difficulty: Hard
  completion_bonus:
    reveries: +200
    card: Guaranteed Rare + 50% Epic chance

series_012:
  name: "Justice's Balance"
  theme: "Fairness & Consequence"
  difficulty: Hard

series_013:
  name: "The Hanged Man's Sacrifice"
  theme: "Surrender & New Perspective"
  difficulty: Hard

series_014:
  name: "Death's Transformation"
  theme: "Endings & Beginnings"
  difficulty: Hard

series_015:
  name: "Temperance's Harmony"
  theme: "Balance & Moderation"
  difficulty: Hard

series_016:
  name: "The Devil's Temptation"
  theme: "Bondage & Materialism"
  difficulty: Very Hard

series_017:
  name: "The Tower's Destruction"
  theme: "Chaos & Revelation"
  difficulty: Very Hard

series_018:
  name: "The Star's Hope"
  theme: "Inspiration & Renewal"
  difficulty: Very Hard

series_019:
  name: "The Moon's Illusion"
  theme: "Subconscious & Deception"
  difficulty: Very Hard

series_020:
  name: "The Sun's Radiance"
  theme: "Joy & Success"
  difficulty: Very Hard
```

**Tier 3: Epic Series (10 series, 3 stages each = 30 cards)**

```yaml
series_021:
  name: "Judgement's Reckoning"
  theme: "Rebirth & Absolution"
  difficulty: Extreme
  completion_bonus:
    reveries: +500
    card: Guaranteed Epic

series_022:
  name: "The World's Completion"
  theme: "Fulfillment & Unity"
  difficulty: Extreme
  completion_bonus:
    reveries: +600
    card: Guaranteed Epic + Legendary chance

series_023-030:
  name: "[Additional Epic Series]"
  theme: "Nightmare Variations"
  difficulty: Nightmare
  completion_bonus:
    reveries: +400-800
    card: Epic/Legendary mix
```

---

### 2.0.3 Dream Series Connection Probability

**Tier-Based Connection Rates:**

| Tier | Stage 2 Match Probability | Stage 3 Match Probability | Perfect Dream Rate |
|------|---------------------------|---------------------------|-------------------|
| **Common** | 60% | 50% | 30% |
| **Rare** | 30% | 25% | 7.5% |
| **Epic** | 10% | 10% | 1% |

**Calculation Example:**
```python
def calculate_perfect_dream_probability(tier):
    """
    Probability of drawing all 3 stages of same series
    """
    if tier == "common":
        # Stage 1: 100% (any card)
        # Stage 2: 60% match
        # Stage 3: 50% match
        return 1.0 * 0.6 * 0.5  # = 0.30 (30%)
    
    elif tier == "rare":
        return 1.0 * 0.3 * 0.25  # = 0.075 (7.5%)
    
    elif tier == "epic":
        return 1.0 * 0.1 * 0.1  # = 0.01 (1%)
```

**Re-draw Impact:**
```yaml
Re-draw Strategy:
  - Player can re-draw up to 3 times per block
  - Cost: 10/20/30 Reveries (increasing)
  
Example:
  - Common tier, no re-draws: 30% perfect dream chance
  - Common tier, 2 re-draws on Stage 2-3:
    - Stage 2: 60% + (40% × 60%) = 84% chance
    - Stage 3: 50% + (50% × 50%) = 75% chance
    - Perfect: 84% × 75% = 63% chance
  
Investment: 50 Reveries (20+30) for +33% success rate
Return: 50 Reveries spent → 60 Reveries bonus (net +10)
```

---

### 2.0.4 Dream Card Visual Design

**Card Layout (Tarot-Inspired):**
```
┌─────────────────────────┐
│  [SERIES ICON]          │  ← Top: Series symbol
│                         │
│    [MAIN ART]           │  ← Center: Dream illustration
│                         │
│  "The Fool - Awakening" │  ← Bottom: Card name
│  ⚡ Stage 1/3           │  ← Stage indicator
└─────────────────────────┘
```

**Color Coding:**
- **Common:** Silver/Gray border
- **Rare:** Gold border
- **Epic:** Purple/Violet border
- **Legendary:** Rainbow/Prismatic border

**Animation States:**
- **Idle:** Gentle floating animation (± 5px vertical)
- **Drawing:** Flip animation (card reveal)
- **Matching:** Glow effect (green for match, red for mismatch)
- **Complete:** Burst of light + series logo appears

---

## 2.1 Combat Card Database

### 2.1.1 Card Data Structure

**JSON Schema:**
```json
{
  "id": "card_001",
  "name": "Basic Strike",
  "type": "attack",
  "rarity": "common",
  "cost": 1,
  "effect": {
    "damage": 5,
    "target": "enemy"
  },
  "upgrade_path": {
    "damage_per_level": 1,
    "cost_reduction": [5, 10]
  },
  "tags": ["attack", "basic"],
  "flavor_text": "The simplest dreams cut deepest.",
  "art_asset": "cards/basic_strike.png"
}
```

### 2.1.2 Full Card List (85 Cards)

**Attack Cards (18 total):**

```yaml
# Basic Tier (Common) - 4 cards
card_001:
  name: "Basic Strike"
  type: attack
  rarity: common
  cost: 1
  damage: 5
  upgrade: +1 damage/level, -1 cost at lv5

card_002:
  name: "Double Tap"
  type: attack
  rarity: common
  cost: 2
  damage: 3 (×2 hits = 6 total)
  special: Triggers synergies twice

card_003:
  name: "Quick Slash"
  type: attack
  rarity: common
  cost: 0
  damage: 3

card_004:
  name: "Heavy Blow"
  type: attack
  rarity: common
  cost: 3
  damage: 12
  drawback: Discard 1 card

# Intermediate Tier (Uncommon) - 5 cards
card_005:
  name: "Lucid Strike"
  type: attack
  rarity: uncommon
  cost: 2
  damage: 10
  conditional: +5 damage if enemy HP < 50%

card_006:
  name: "Chain Lightning"
  type: attack
  rarity: uncommon
  cost: 2
  damage: 6
  special: Refund 2 Energy on kill

card_007:
  name: "Nightmare Blade"
  type: attack
  rarity: uncommon
  cost: 2
  damage: 8
  synergy: +2 damage per Nightmare card in hand
  tags: [nightmare]

card_008:
  name: "Dream Shatter"
  type: attack
  rarity: uncommon
  cost: 3
  damage: 15
  special: Cannot be blocked

card_009:
  name: "Echo Strike"
  type: attack
  rarity: uncommon
  cost: 1
  damage: 4
  special: Repeat this attack next turn (free)

# Advanced Tier (Rare) - 3 cards
card_010:
  name: "Void Spear"
  type: attack
  rarity: rare
  cost: 2
  damage: 10
  special: Enemy loses 1 Energy next turn

card_011:
  name: "Reality Break"
  type: attack
  rarity: rare
  cost: 3
  damage: "2× current Energy"
  example: 5 Energy → 10 damage

card_012:
  name: "Dream Cascade"
  type: attack
  rarity: rare
  cost: 2
  damage: "5 + 3 per Attack card played this turn"

# Elite Tier (Epic) - 3 cards
card_013:
  name: "Lucid Nova"
  type: attack
  rarity: epic
  cost: 3
  damage: 20
  special: Draw 1 card

card_014:
  name: "Nightmare King's Wrath"
  type: attack
  rarity: epic
  cost: 4
  damage: 30
  synergy: Cost -1 per Nightmare card in play
  tags: [nightmare]

card_015:
  name: "Oblivion Strike"
  type: attack
  rarity: epic
  cost: 5
  damage: 40
  special: Exile this card after use

# Legendary Tier - 3 cards
card_016:
  name: "Dream Ender"
  type: attack
  rarity: legendary
  cost: 3
  damage: "Equal to enemy missing HP (execute)"

card_017:
  name: "Infinity Edge"
  type: attack
  rarity: legendary
  cost: 2
  damage: 8
  scaling: Permanently +1 damage each time played

card_018:
  name: "Apocalypse Dream"
  type: attack
  rarity: legendary
  cost: "X (variable)"
  damage: "10 per Energy spent"
```

**Defense Cards (12 total):**

```yaml
# Basic Tier (Common) - 3 cards
card_019:
  name: "Dream Shield"
  type: defense
  rarity: common
  cost: 1
  block: 8
  special: Can be played as instant (reactive)

card_020:
  name: "Mist Barrier"
  type: defense
  rarity: common
  cost: 0
  block: 4

card_021:
  name: "Memory Wall"
  type: defense
  rarity: common
  cost: 2
  block: 12

# Intermediate Tier (Uncommon) - 4 cards
card_022:
  name: "Ethereal Guard"
  type: defense
  rarity: uncommon
  cost: 1
  block: 10
  special: Gain 1 Energy if blocks all damage

card_023:
  name: "Nightmare Ward"
  type: defense
  rarity: uncommon
  cost: 2
  block: 8
  synergy: Block 16 if [Fear Essence] in play
  tags: [nightmare]

card_024:
  name: "Phase Shift"
  type: defense
  rarity: uncommon
  cost: 1
  block: "All damage this turn"
  drawback: Discard 1 card

card_025:
  name: "Reflection"
  type: defense
  rarity: uncommon
  cost: 2
  block: 8
  special: Reflect 50% blocked damage back

# Advanced Tier (Rare) - 3 cards
card_026:
  name: "Lucid Barrier"
  type: defense
  rarity: rare
  cost: 2
  block: 15
  special: Convert excess block to HP healing

card_027:
  name: "Time Freeze"
  type: defense
  rarity: rare
  cost: 3
  block: "All damage this turn"
  special: Skip enemy's next turn

card_028:
  name: "Immortal Sleep"
  type: defense
  rarity: rare
  cost: 1
  block: 10
  scaling: Permanently +2 block each time played

# Elite Tier (Epic) - 2 cards
card_029:
  name: "Sanctuary"
  type: defense
  rarity: epic
  cost: 3
  block: 20
  special: Heal 5 HP, gain 1 Energy next turn

card_030:
  name: "Absolute Shield"
  type: defense
  rarity: epic
  cost: 4
  block: "All damage for 2 turns"
  drawback: Cannot play Attack cards during this time
```

**Collection Cards (16 total):**

```yaml
# Basic Tier (Common) - 4 cards
card_031:
  name: "Memory Shard"
  type: collection
  rarity: common
  cost: 1
  effect: "+2 Reveries at each Memory Node"
  duration: permanent (this run)
  tags: [memory]

card_032:
  name: "Dream Dust"
  type: collection
  rarity: common
  cost: 1
  effect: "+5 Reveries per turn (passive)"

card_033:
  name: "Reverie Burst"
  type: collection
  rarity: common
  cost: 1
  effect: "Gain 10 Reveries instantly"

card_034:
  name: "Sleep Essence"
  type: collection
  rarity: common
  cost: 2
  effect: "+3 Reveries/turn, +1 bonus at Memory Nodes"

# Intermediate Tier (Uncommon) - 4 cards
card_035:
  name: "Lucid Harvest"
  type: collection
  rarity: uncommon
  cost: 2
  effect: "Gain 20 Reveries (30 at Memory Node)"

card_036:
  name: "Dream Weaver"
  type: collection
  rarity: uncommon
  cost: 2
  effect: "+10 Reveries/turn + 2 per Collection card in play"
  synergy: Collection deck

card_037:
  name: "Memory Echo"
  type: collection
  rarity: uncommon
  cost: 1
  effect: "+20% to all Reverie gains"
  multiplier: Stacks with other bonuses

card_038:
  name: "Idle Dream"
  type: collection
  rarity: uncommon
  cost: 3
  effect: "+15 Reveries/turn (persists after run)"
  meta: Permanent bonus

# Advanced Tier (Rare) - 3 cards
card_039:
  name: "Nightmare Harvest"
  type: collection
  rarity: rare
  cost: 2
  effect: "5 Reveries per enemy defeated this run"
  scaling: Rewards aggressive play

card_040:
  name: "Compound Interest"
  type: collection
  rarity: rare
  cost: 3
  effect: "Gain 10% of total Reveries at end of turn"
  exponential: Gets stronger with more Reveries

card_041:
  name: "Dream Factory"
  type: collection
  rarity: rare
  cost: 2
  effect: "+5 Reveries/turn per Collection card played"
  synergy: Collection deck

# Elite Tier (Epic) - 2 cards
card_042:
  name: "Golden Sleep"
  type: collection
  rarity: epic
  cost: 4
  effect: "+30 Reveries/turn, 2× Memory Node rewards"

card_043:
  name: "Infinity Well"
  type: collection
  rarity: epic
  cost: 3
  effect: "+1 Reverie/turn, increases by +1 each turn"
  scaling: Turn 1 → +1, Turn 5 → +5, etc.

# Legendary Tier - 3 cards
card_044:
  name: "Collector's Greed"
  type: collection
  rarity: legendary
  cost: 5
  effect: "3× all Reverie income"

card_045:
  name: "Eternal Dream"
  type: collection
  rarity: legendary
  cost: 3
  effect: "+20 Reveries/turn + 10/turn in ALL future runs"
  meta: Permanent account-wide bonus

card_046:
  name: "Dream Monopoly"
  type: collection
  rarity: legendary
  cost: 4
  effect: "3× Memory Node rewards, 0× Combat rewards"
  tradeoff: Pacifist strategy
```

**Synergy Cards (15 total):**

```yaml
# Nightmare Theme (5 cards)
card_047:
  name: "Fear Essence"
  type: synergy
  rarity: uncommon
  cost: 2
  effect: "All Nightmare cards cost -1 Energy"
  tags: [nightmare]

card_048:
  name: "Shadow Step"
  type: synergy
  rarity: uncommon
  cost: 1
  damage: 5
  synergy: "Deal 10 damage if [Fear Essence] in play"
  tags: [nightmare]

card_049:
  name: "Terror Wave"
  type: synergy
  rarity: rare
  cost: 3
  damage: "8 + 3 per Nightmare card in hand"
  tags: [nightmare]

card_050:
  name: "Nightmare King"
  type: synergy
  rarity: epic
  cost: 4
  effect: "All Nightmare cards +5 damage/block/Reveries"
  tags: [nightmare]

card_051:
  name: "Phobia"
  type: synergy
  rarity: rare
  cost: 2
  damage: 12
  synergy: "Stun enemy for 1 turn if 3+ Nightmare cards"
  tags: [nightmare]

# Memory Theme (5 cards)
card_052:
  name: "Nostalgia"
  type: synergy
  rarity: uncommon
  cost: 2
  effect: "Memory Nodes also draw 1 card"
  tags: [memory]

card_053:
  name: "Déjà Vu"
  type: synergy
  rarity: uncommon
  cost: 1
  effect: "Replay last card played this turn (free)"
  tags: [memory]

card_054:
  name: "Memory Lane"
  type: synergy
  rarity: rare
  cost: 2
  effect: "Gain 5 Reveries per Memory card played"
  tags: [memory]

card_055:
  name: "Perfect Recall"
  type: synergy
  rarity: rare
  cost: 3
  effect: "Draw 3 cards (5 if 3+ Memory cards)"
  tags: [memory]

card_056:
  name: "Timeless"
  type: synergy
  rarity: epic
  cost: 3
  effect: "All Memory cards never discard (permanent)"
  tags: [memory]

# Lucid Theme (5 cards)
card_057:
  name: "Lucid Awakening"
  type: synergy
  rarity: uncommon
  cost: 1
  effect: "+1 Energy/turn (+1 more if 3+ Lucid cards)"
  tags: [lucid]

card_058:
  name: "Reality Bender"
  type: synergy
  rarity: rare
  cost: 2
  effect: "Set enemy Attack to 0 this turn"
  synergy: "Also block 10 if [Lucid Awakening] in play"
  tags: [lucid]

card_059:
  name: "Dream Logic"
  type: synergy
  rarity: rare
  cost: 2
  effect: "Hand size limit → 7 (instead of 5)"
  tags: [lucid]

card_060:
  name: "Hyper Awareness"
  type: synergy
  rarity: epic
  cost: 3
  effect: "Draw 2 cards, gain 2 Energy"
  synergy: "Double if 3+ Lucid cards"
  tags: [lucid]

card_061:
  name: "God Mode"
  type: synergy
  rarity: legendary
  cost: 5
  effect: "All cards cost -1 Energy, cannot lose HP"
  tags: [lucid]
```

**Event/Enemy Cards (24 total):**
*(See Section 2.2 for full enemy database)*

---

## 2.2 Monster Database

### 2.2.1 Monster Data Structure

**JSON Schema:**
```json
{
  "id": "enemy_001",
  "name": "Dream Wisp",
  "difficulty": 1,
  "hp": 8,
  "attack": 1,
  "pattern": "basic_attack",
  "ai_script": "attack_every_turn",
  "rewards": {
    "reveries": 10,
    "card_drop_chance": 0.0
  },
  "tags": ["tutorial", "harmless"],
  "art_asset": "enemies/dream_wisp.png"
}
```

### 2.2.2 Basic Enemies (14 total)

**Tier 1: Tutorial (Nodes 1-3):**

```yaml
enemy_001:
  name: "Dream Wisp"
  difficulty: 1
  hp: 8
  attack: 1
  pattern: basic_attack
  rewards: 10 Reveries
  threat_level: none

enemy_002:
  name: "Sleepy Shadow"
  difficulty: 1
  hp: 10
  attack: 2
  pattern: "attack_sleep_repeat"
  ai: "Turn 1: Attack 2, Turn 2: Sleep (skip), Repeat"
  rewards: 15 Reveries
  strategy: "Attack during sleep turns"

enemy_003:
  name: "Memory Nibbler"
  difficulty: 2
  hp: 12
  attack: 2
  pattern: "punish_spam"
  ai: "If player plays 3+ cards in one turn, gain +1 Attack (permanent)"
  rewards: 20 Reveries
  strategy: "Play ≤2 cards per turn"
```

**Tier 2: Early Challenge (Nodes 4-5):**

```yaml
enemy_004:
  name: "Shadow Whisper"
  difficulty: 2
  hp: 15
  attack: 3
  pattern: basic_attack
  rewards: 25 Reveries

enemy_005:
  name: "Anxious Echo"
  difficulty: 3
  hp: 18
  attack: "2-5 (random)"
  pattern: "random_damage"
  ai: "Roll d4: 1=2dmg, 2=3dmg, 3=4dmg, 4=5dmg"
  rewards: 30 Reveries
  strategy: "Maintain high defense always"

enemy_006:
  name: "Dream Glutton"
  difficulty: 3
  hp: 20
  attack: 3
  pattern: "reverie_drain"
  ai: "Steals 5 Reveries per turn"
  rewards: 40 Reveries (includes stolen)
  strategy: "Kill quickly"
```

**Tier 3: Mid-Game (Nodes 6-7):**

```yaml
enemy_007:
  name: "Regret Wraith"
  difficulty: 3
  hp: 22
  attack: 4
  pattern: "punish_block"
  ai: "If player blocks damage, attacks again (bonus attack)"
  rewards: 45 Reveries
  strategy: "Block all or take it, don't half-block"

enemy_008:
  name: "Lucid Hunter"
  difficulty: 3
  hp: 25
  attack: 3
  pattern: "charge_burst"
  ai: |
    Turn 1-2: Attack 3 damage
    Turn 3: Charge (no attack)
    Turn 4: Attack 8 damage (3 + 5 bonus)
    Repeat
  rewards: 50 Reveries
  strategy: "Save defense for Turn 4"

enemy_009:
  name: "Memory Thief"
  difficulty: 4
  hp: 20
  attack: 3
  pattern: "punish_cards"
  ai: "Each card played → deal 2 bonus damage to player"
  rewards: 55 Reveries
  strategy: "Play 1-2 high-impact cards per turn"
```

**Tier 4: Late-Game (Nodes 8-9):**

```yaml
enemy_010:
  name: "Nightmare Hound"
  difficulty: 4
  hp: 28
  attack: 5
  pattern: "enrage"
  ai: "If HP < 50%, Attack becomes 8"
  rewards: 65 Reveries + 1 Uncommon card
  strategy: "Burst before 50% or prepare heavy defense"

enemy_011:
  name: "Dream Parasite"
  difficulty: 4
  hp: 30
  attack: 2
  pattern: "drain_heal"
  ai: "Steals 5 Reveries/turn, heals 2 HP/turn"
  rewards: 80 Reveries
  strategy: "High damage, ignore defense"

enemy_012:
  name: "Void Fragment"
  difficulty: 4
  hp: 25
  attack: 6
  pattern: "damage_immunity"
  ai: "Immune to first 10 damage each turn"
  rewards: 70 Reveries
  strategy: "Deal 15+ damage per turn"

enemy_013:
  name: "Fear Phantom"
  difficulty: 5
  hp: 35
  attack: 7
  pattern: "unblockable"
  ai: "Cannot be blocked by Defense cards"
  rewards: 90 Reveries + 1 Rare card
  strategy: "Damage race, HP recovery"

enemy_014:
  name: "Time Eater"
  difficulty: 5
  hp: 40
  attack: 4
  pattern: "limit_actions"
  ai: "Player can only play 1 card per turn"
  rewards: 100 Reveries + 1 Rare card
  strategy: "Play best card each turn"
```

### 2.2.3 Elite Enemies (10 total)

```yaml
elite_001:
  name: "Shadow Champion"
  difficulty: 4
  hp: 45
  attack: 6
  pattern: "summon_minions"
  ai: |
    Turn 1-2: Attack 6
    Turn 3: Summon Shadow Whisper (15 HP, 3 Attack)
    Turn 4-6: Attack 6
    Turn 7+: Repeat
  rewards: 120 Reveries + 2 Uncommon cards

elite_002:
  name: "Lucid Archon"
  difficulty: 4
  hp: 50
  attack: 5
  pattern: "hand_disruption"
  ai: "Steals 1 card from hand each turn (discards it)"
  conditional: "If hand empty, deals +5 damage"
  rewards: 150 Reveries + 2 Rare cards

elite_003:
  name: "Memory Colossus"
  difficulty: 4
  hp: 60
  attack: 5
  pattern: "counter_memory"
  ai: "Each Memory card played → gain +2 Attack (permanent)"
  rewards: 180 Reveries + 3 Rare + 1 Epic

elite_004:
  name: "Nightmare Hydra"
  difficulty: 5
  hp: 70 (split: 25/25/20)
  attack: "3 per head (9 total)"
  pattern: "multi_target_regen"
  ai: "Each head regenerates 5 HP/turn, must kill all 3"
  rewards: 220 Reveries + 4 Rare + 1 Epic

elite_005:
  name: "Void Wraith"
  difficulty: 5
  hp: 55
  attack: 7
  pattern: "damage_immunity_heal"
  ai: "Immune to first 10 damage/turn, heals 10 if no damage dealt"
  rewards: 200 Reveries + 3 Rare + 1 Epic

elite_006:
  name: "Fear Incarnate"
  difficulty: 5
  hp: 50
  attack: 8
  pattern: "unblockable_enrage"
  ai: "Cannot be blocked. If HP < 30%, Attack → 12"
  rewards: 250 Reveries + 4 Rare + 1 Epic

elite_007:
  name: "Time Devourer"
  difficulty: 5
  hp: 65
  attack: 6
  pattern: "limit_escalate"
  ai: "Player plays 1 card/turn. Gains +1 Attack each turn"
  rewards: 280 Reveries + 5 Rare + 1 Epic

elite_008:
  name: "Dream Colossus"
  difficulty: 5
  hp: 80
  attack: 5
  pattern: "charge_burst"
  ai: |
    Turn 1-3: Attack 5
    Turn 4: Charge (no attack)
    Turn 5: Attack 15 (unblockable)
    Repeat
  rewards: 300 Reveries + 6 Rare + 2 Epic

elite_009:
  name: "Lucid Nemesis"
  difficulty: 5
  hp: 60
  attack: 6
  pattern: "copy_player"
  ai: "Copies 1 player card each turn and plays it against player"
  rewards: 320 Reveries + 7 Rare + 2 Epic

elite_010:
  name: "Eternal Nightmare"
  difficulty: 6
  hp: 100
  attack: 8
  pattern: "revive"
  ai: "When HP → 0, revive once at 30 HP with +4 Attack"
  rewards: 400 Reveries + 10 Rare + 3 Epic + 1 Legendary
```

### 2.2.4 Boss Enemies (10 total)

```yaml
boss_001:
  name: "Dream Eater"
  tier: 1
  difficulty: "Easy Boss"
  hp: 60
  phases:
    phase_1:
      hp_range: "60-30"
      attack: 5
      pattern: basic_attack
    phase_2:
      hp_range: "30-0"
      attack: 7
      special: "Drains 1 Energy/turn"
  rewards: 150 Reveries + 2 Rare + 1 Epic + Unlock Dreamer

boss_002:
  name: "Shadow King"
  tier: 1
  difficulty: "Medium Boss"
  hp: 80
  phases:
    phase_1:
      hp_range: "80-40"
      attack: 6
      pattern: "Summons Shadow Whisper every 3 turns"
    phase_2:
      hp_range: "40-0"
      attack: 8
      pattern: "Summons every 2 turns, minions +2 Attack"
  rewards: 200 Reveries + 3 Rare + 2 Epic + [Nightmare King] card

boss_003:
  name: "Anxiety Titan"
  tier: 1
  difficulty: "Medium Boss"
  hp: 70
  attack: "Random (5-15)"
  pattern: "dice_roll"
  ai: "Roll d10: 1-5 = 5dmg, 6-9 = 10dmg, 10 = 15dmg"
  phases:
    phase_2:
      trigger: "HP < 40%"
      special: "Attacks twice per turn"
  rewards: 250 Reveries + 4 Rare + 2 Epic

boss_004:
  name: "Memory Monarch"
  tier: 2
  difficulty: "Hard Boss"
  hp: 90
  phases:
    phase_1:
      hp_range: "90-50"
      attack: 7
      pattern: "counter_memory"
      ai: "Each Memory card → +2 Attack (permanent)"
    phase_2:
      hp_range: "50-0"
      attack: 10
      pattern: "hand_steal"
      ai: "Steals 1 card/turn"
  rewards: 300 Reveries + 5 Rare + 3 Epic + [Timeless] card

boss_005:
  name: "Lucid Sovereign"
  tier: 2
  difficulty: "Hard Boss"
  hp: 85
  phases:
    phase_1:
      hp_range: "85-45"
      attack: 6
      pattern: "hand_discard"
      ai: "Steals 1 card/turn (discards)"
    phase_2:
      hp_range: "45-0"
      attack: 9
      pattern: "card_copy"
      ai: "Steals 1 card AND plays it, gains +2 Energy/turn"
  rewards: 350 Reveries + 6 Rare + 3 Epic + [God Mode] card

boss_006:
  name: "Nightmare Legion"
  tier: 2
  difficulty: "Hard Boss"
  hp: 100 (5 bodies × 20 HP)
  attack: "4 per body (20 total)"
  pattern: "multi_target"
  ai: "When one dies, others gain +2 Attack"
  phases:
    phase_2:
      trigger: "≤3 bodies remain"
      special: "Remaining bodies attack twice/turn"
  rewards: 400 Reveries + 7 Rare + 4 Epic + [Fear Incarnate] card

boss_007:
  name: "The Forgotten"
  tier: 3
  difficulty: "Very Hard Boss"
  hp: 110
  phases:
    phase_1:
      hp_range: "110-60"
      attack: 8
      pattern: "hand_reset"
      ai: "Every 2 turns: reset player hand (discard all, draw 4)"
    phase_2:
      hp_range: "60-0"
      attack: 12
      pattern: "energy_drain_reset"
      ai: "Resets hand EVERY turn, drains 2 Energy/turn"
  rewards: 500 Reveries + 8 Rare + 5 Epic + [Eternal Dream] legendary

boss_008:
  name: "Void Sovereign"
  tier: 3
  difficulty: "Very Hard Boss"
  hp: 120
  attack: 9
  pattern: "immune_vulnerable"
  ai: |
    Turn 1: Immune (no damage taken), attacks
    Turn 2: Vulnerable (takes 2× damage), attacks
    Repeat
  phases:
    phase_2:
      trigger: "HP < 60"
      special: "Vulnerable turns → 3× damage instead"
  rewards: 600 Reveries + 10 Rare + 6 Epic + [Dream Ender] legendary

boss_009:
  name: "Time Breaker"
  tier: 3
  difficulty: "Extreme Boss"
  hp: 130
  attack: "8 (×3 hits = 24 total)"
  pattern: "time_limit"
  ai: "Attacks 3 times/turn. Must kill within 10 turns or instant loss"
  phases:
    phase_2:
      trigger: "HP < 60"
      special: "Time limit → 5 turns from this point"
  rewards: 700 Reveries + 12 Rare + 8 Epic + [Apocalypse Dream] legendary

boss_010:
  name: "The Dreamer"
  tier: 3
  difficulty: "Nightmare Boss (Final)"
  hp: 150
  phases:
    phase_1:
      hp_range: "150-100"
      attack: 6
      pattern: "summon_minions"
      ai: "Summons minion every 2 turns (15 HP, 4 Attack)"
    phase_2:
      hp_range: "100-50"
      attack: 10
      pattern: "drain_heal"
      ai: "Drains 2 Energy/turn, heals 5 HP every 3 turns"
      minions: "20 HP, 6 Attack"
    phase_3:
      hp_range: "50-0"
      attack: 15
      pattern: "immunity_limit"
      ai: "Immunity shield (blocks first 20 damage/turn), player plays 2 cards max"
  rewards: 1000 Reveries + ALL locked cards + Secret Ending
```

---

## 2.3 Dungeon Structure

### 2.3.1 Node Generation

**10-Node Path Structure:**
```python
def generate_dungeon_path():
    nodes = []
    
    # Node 1: Always Memory (safe start)
    nodes.append(Node("memory", reveries=10))
    
    # Nodes 2-9: Procedural generation
    for i in range(2, 10):
        roll = random.uniform(0, 100)
        
        if roll < 60:
            nodes.append(Node("memory", reveries=random.randint(10, 15)))
        elif roll < 80:
            nodes.append(generate_event_node())
        elif roll < 95:
            nodes.append(generate_combat_node(difficulty=i))
        else:
            nodes.append(generate_treasure_node())
    
    # Node 10: Always Boss
    nodes.append(generate_boss_node())
    
    # Quality check: Ensure at least 2 combats before boss
    ensure_minimum_combats(nodes, min_count=2, latest_index=8)
    
    return nodes
```

### 2.3.2 Node Types

**Node Type Distribution:**
```yaml
Memory Node (60%):
  frequency: 6 out of 10 nodes
  guaranteed: Node 1 (always first)
  rewards:
    - Base: 10 Reveries
    - Bonus: +2 per Collection card in deck
  options:
    - Collect (free)
    - Heal 5 HP (cost: 30 Reveries)
    - Upgrade 1 card (cost: varies)

Event Node (20%):
  frequency: 2 out of 10 nodes
  structure:
    - Draw 1 random event card
    - Present 2-3 choices
    - Apply consequence
  rewards: 20-150 Reveries (risk-dependent)
  
Combat Node (15%):
  frequency: 1-2 out of 10 nodes
  structure:
    - Draw enemy from pool (difficulty-scaled)
    - Execute combat
  rewards:
    - 30-100 Reveries
    - 0-100% card drop chance

Treasure Node (5%):
  frequency: 0-1 out of 10 nodes (rare)
  rewards:
    - 1 guaranteed rare/epic card
    - OR 100 Reveries
    - OR 1 artifact (future expansion)

Boss Node (Always Final):
  frequency: Node 10 only
  structure:
    - Boss enemy (multi-phase)
  rewards:
    - 150-1000 Reveries
    - 2-5 rare/epic cards
    - Achievement/unlock
```

### 2.3.3 Event Card Library

**Event Structure:**
```json
{
  "id": "event_001",
  "name": "Crossroads",
  "description": "Two paths diverge. Which will you take?",
  "choices": [
    {
      "text": "Take the safe path",
      "outcome": {
        "reveries": 20,
        "risk": "none"
      }
    },
    {
      "text": "Take the risky path",
      "outcome": {
        "type": "random",
        "success": {"reveries": 50, "probability": 0.5},
        "failure": {"hp_loss": 2, "probability": 0.5}
      }
    }
  ]
}
```

**Example Events (10 total):**

```yaml
event_001:
  name: "Crossroads"
  choices:
    - "Safe: Gain 20 Reveries"
    - "Risky: 50% → 50 Reveries, 50% → Lose 2 HP"

event_002:
  name: "Mysterious Merchant"
  choices:
    - "Buy card: Spend 50 Reveries → Gain 1 random Uncommon card"
    - "Sell card: Remove 1 card from deck → Gain 30 Reveries"
    - "Leave: Nothing"

event_003:
  name: "Fountain of Dreams"
  choices:
    - "Drink: Heal 5 HP"
    - "Bathe: Remove all negative status effects"
    - "Pray: Gain 1 random card"

event_004:
  name: "Nightmare Ambush"
  choices:
    - "Fight: Enter combat with Nightmare Hound"
    - "Flee: Lose 3 HP but skip combat"

event_005:
  name: "Memory Fragment"
  choices:
    - "Absorb: Gain 30 Reveries"
    - "Study: Upgrade 1 random card for free"

event_006:
  name: "Lucid Opportunity"
  choices:
    - "Meditate: Gain +1 max Energy this run"
    - "Train: Gain +2 max HP this run"

event_007:
  name: "Dream Library"
  choices:
    - "Research: Draw 3 cards from library, add 1 to deck"
    - "Study: Upgrade 1 card (cost: 20 Reveries)"
    - "Leave: Gain 10 Reveries"

event_008:
  name: "Sleeping Guardian"
  choices:
    - "Sneak Past: 70% → Gain 40 Reveries, 30% → Combat"
    - "Wake It: Guaranteed combat, double rewards if you win"
    - "Leave: Nothing"

event_009:
  name: "Reverie Storm"
  choices:
    - "Collect: Gain 50 Reveries, lose 1 random card"
    - "Shelter: Gain 20 Reveries, keep all cards"

event_010:
  name: "Forgotten Altar"
  choices:
    - "Offer HP: Lose 3 HP → Gain 1 Epic card"
    - "Offer Reveries: Lose 100 Reveries → Gain 2 Rare cards"
    - "Leave: Nothing"
```

### 2.3.4 Difficulty Scaling

**Enemy Stat Scaling by Node:**
```python
def scale_enemy_stats(base_enemy, current_node):
    scale_factor = 1.0 + (current_node * 0.1)  # +10% per node
    
    enemy = copy(base_enemy)
    enemy.hp = int(enemy.hp * scale_factor)
    enemy.attack = int(enemy.attack * scale_factor)
    enemy.rewards.reveries = int(enemy.rewards.reveries * scale_factor)
    
    return enemy

# Example:
# Node 1: Shadow Whisper (15 HP, 3 Attack, 25 Reveries)
# Node 5: Shadow Whisper (22 HP, 4 Attack, 37 Reveries) [1.5× scaled]
# Node 9: Shadow Whisper (28 HP, 5 Attack, 47 Reveries) [1.9× scaled]
```

---

## 2.4 Reward Tables

### 2.4.1 Combat Rewards

**Reverie Rewards:**
```python
def calculate_combat_reveries(enemy_difficulty, node_number):
    base_reward = {
        1: 10,   # Tutorial
        2: 25,   # Easy
        3: 50,   # Normal
        4: 75,   # Hard
        5: 100,  # Very Hard
        6: 150   # Elite
    }[enemy_difficulty]
    
    # Scale by node position
    node_multiplier = 1.0 + (node_number * 0.05)
    
    # Random variance ±20%
    variance = random.uniform(0.8, 1.2)
    
    return int(base_reward * node_multiplier * variance)
```

**Card Drop Rates:**
```yaml
Card Drop by Enemy Type:
  Basic Enemy:
    Common: 70%
    Uncommon: 25%
    Rare: 5%
    Total Drop Chance: 30%
  
  Elite Enemy:
    Common: 0%
    Uncommon: 50%
    Rare: 40%
    Epic: 10%
    Total Drop Chance: 100%
  
  Boss:
    Rare: 60%
    Epic: 35%
    Legendary: 5%
    Total Drop Chance: 100%
    Count: Choose 1 from 3 options
```

### 2.4.2 Event Rewards

**Event Reward Ranges:**
```yaml
Safe Choices:
  Reveries: 20-30
  HP Gain: 3-5
  Card: 1 Common-Uncommon

Risky Choices:
  Success (50-70% chance):
    Reveries: 50-100
    Card: 1 Rare
  Failure (30-50% chance):
    HP Loss: 2-5
    Reveries Loss: 10-50

High-Risk Choices:
  Success (30% chance):
    Reveries: 150+
    Card: 1 Epic
  Failure (70% chance):
    HP Loss: 5+
    Enter Combat
```

### 2.4.3 Prestige Rewards

**Dream Shard Conversion:**
```python
def calculate_prestige_rewards(player_stats):
    lifetime_reveries = player_stats.total_reveries_collected
    completed_runs = player_stats.runs_completed
    achievements = player_stats.achievements_unlocked
    
    # Base conversion: 1 Shard per 1000 Reveries
    base_shards = lifetime_reveries // 1000
    
    # Bonus: 5 Shards per completed run
    run_bonus = completed_runs * 5
    
    # Bonus: 10 Shards per achievement
    achievement_bonus = achievements * 10
    
    total_shards = base_shards + run_bonus + achievement_bonus
    
    return {
        "dream_shards": total_shards,
        "breakdown": {
            "base": base_shards,
            "runs": run_bonus,
            "achievements": achievement_bonus
        }
    }
```

---

# 3. Balance System

## 3.1 Difficulty Curve

### 3.1.1 Node-by-Node Difficulty

**Target Difficulty Progression (1-10 scale):**
```yaml
Node 1 (Memory): Difficulty 0 (safe)
Node 2 (Memory/Event): Difficulty 1
Node 3 (Combat/Event): Difficulty 2
Node 4 (Memory/Combat): Difficulty 3
Node 5 (Combat): Difficulty 4
Node 6 (Memory/Event): Difficulty 4
Node 7 (Combat/Event): Difficulty 5
Node 8 (Combat): Difficulty 6
Node 9 (Memory/Combat): Difficulty 7
Node 10 (Boss): Difficulty 10
```

**Enemy HP Growth:**
```python
# Target: Player should need 3-5 turns to kill
node_hp_targets = {
    1: 8,    # 2 turns with basic deck
    2: 12,   # 2-3 turns
    3: 18,   # 3-4 turns
    4: 22,   # 4 turns
    5: 28,   # 4-5 turns
    6: 32,   # 5 turns
    7: 38,   # 5-6 turns
    8: 45,   # 6-7 turns
    9: 50,   # 7-8 turns
    10: 60+  # Boss: 10-15 turns
}
```

**Enemy Attack Growth:**
```python
# Target: Player should lose 30-50% HP per combat
node_attack_targets = {
    1: 1,    # 10% HP (1/10)
    2: 2,    # 20% HP
    3: 3,    # 30% HP
    4: 4,    # 40% HP
    5: 5,    # 50% HP
    6: 6,    # 60% HP (requires defense)
    7: 7,    # 70% HP
    8: 8,    # 80% HP
    9: 9,    # 90% HP (must defend or die)
    10: 10+  # Boss: Lethal without defense
}
```

### 3.1.2 Dreamer Difficulty Modifiers

**Difficulty Adjustment:**
```python
def apply_dreamer_modifier(base_stats, dreamer):
    if dreamer == "serenity":  # Easy
        base_stats.player_hp = 10
        base_stats.player_energy = 3
        base_stats.enemy_scaling = 0.8  # -20% enemy stats
    
    elif dreamer == "anxiety":  # Medium
        base_stats.player_hp = 8
        base_stats.player_energy = 4
        base_stats.enemy_scaling = 1.0  # Normal
    
    elif dreamer == "fear":  # Hard
        base_stats.player_hp = 6
        base_stats.player_energy = 5
        base_stats.enemy_scaling = 1.3  # +30% enemy stats
    
    return base_stats
```

### 3.1.3 Win Rate Targets

**Desired Win Rates (After 10+ Runs):**
```yaml
Serenity (Easy): 70-80% win rate
Anxiety (Medium): 50-60% win rate
Fear (Hard): 30-40% win rate
Nightmare Mode: 10-20% win rate
```

**Balancing Tools:**
- If win rate too high → Increase enemy HP/Attack by 10%
- If win rate too low → Decrease enemy HP/Attack by 10%
- Monitor by Dreamer and player experience level

---

## 3.2 Economic Balance

### 3.2.1 Reverie Income vs Expenditure

**Expected Reverie Income (Per Run):**
```yaml
Full Run (Victory, 10 nodes):
  Memory Nodes (6): 6 × 15 = 90 Reveries
  Combat Nodes (2): 2 × 60 = 120 Reveries
  Event Nodes (2): 2 × 40 = 80 Reveries
  Boss Node (1): 1 × 150 = 150 Reveries
  Total: ~440 Reveries per successful run

Partial Run (Defeat at Node 7):
  Memory Nodes (4): 60 Reveries
  Combat Nodes (1): 60 Reveries
  Event Nodes (1): 40 Reveries
  50% Penalty: (60 + 60 + 40) × 0.5 = 80 Reveries

Idle Income (8 hours):
  Base Deck (Idle Power 30): 30 × 10 × 8 = 2,400 Reveries
  Optimized Deck (Idle Power 60): 60 × 10 × 8 = 4,800 Reveries
  With +50% Prestige: 7,200 Reveries
```

**Expected Reverie Expenditure:**
```yaml
Card Upgrades:
  Common (Level 1→5): 20 + 40 + 60 + 80 + 100 = 300 Reveries
  Rare (Level 1→5): 50 + 100 + 150 + 200 + 250 = 750 Reveries
  Epic (Level 1→5): 80 + 160 + 240 + 320 + 400 = 1,200 Reveries

Shop Purchases:
  Common Card: 50 Reveries
  Uncommon Card: 150 Reveries
  Rare Card: 400 Reveries
  Epic Card: 1,000 Reveries

Deck Expansion:
  9th Slot: 100 Reveries
  10th Slot: 200 Reveries
  11th Slot: 400 Reveries
  12th Slot: 800 Reveries
  Total: 1,500 Reveries for full expansion
```

**Economic Balance Check:**
```python
# Player should be able to:
# - Upgrade 3-5 cards after 1 run
# - Buy 1 rare card after 2 runs
# - Fully upgrade 1 deck after 10 runs
# - Max out deck slots after 20 runs

runs_for_full_deck = 10
reveries_per_run = 440
total_earned = runs_for_full_deck * reveries_per_run  # 4,400 Reveries

# Cost to fully upgrade 12 cards (mix of rarities):
# 4× Common (300 each) = 1,200
# 5× Rare (750 each) = 3,750
# 3× Epic (1,200 each) = 3,600
total_upgrade_cost = 8,550 Reveries

# Deficit: Need ~20 runs to fully max a deck (reasonable)
```

### 3.2.2 Inflation Prevention

**Soft Caps:**
```python
def apply_economic_balance(player):
    # Reverie generation soft cap
    if player.lifetime_reveries > 100_000:
        player.reverie_gain_multiplier *= 0.9  # -10% gain
    
    # Prestige encouragement
    if player.lifetime_reveries > 500_000 and not player.has_prestiged:
        show_notification("Consider Ascending for permanent bonuses!")
    
    # Upgrade cost scaling
    if player.average_card_level > 7:
        upgrade_cost_multiplier = 1.5  # Late-game upgrades more expensive
```

### 3.2.3 Dream Linking Economy

**Dream Completion Income:**
```yaml
Expected Income per Dream (3 Blocks):

Perfect Dream (30% chance, Common Tier):
  Base Reveries: 120 (20 + 40 + 60)
  Completion Bonus: +60 (50%)
  Total: 180 Reveries
  Time: ~10 minutes (with combat)
  
Broken Dream (70% chance, Common Tier):
  Base Reveries: 120
  Penalty: -50%
  Total: 60 Reveries
  Time: ~10 minutes
  
Weighted Average per Dream:
  (0.3 × 180) + (0.7 × 60) = 54 + 42 = 96 Reveries/dream
  
Energy Cost: 3 units per dream
Reveries per Energy: 96 / 3 = 32 Reveries/Energy
```

**Dream vs Combat Run Comparison:**
```yaml
Traditional Combat Run (10 nodes, 25 minutes):
  Income: ~440 Reveries
  Reveries/minute: 17.6
  Requires: Active play
  
Dream System (1 dream, 10 minutes):
  Income: 96 Reveries (average)
  Reveries/minute: 9.6
  Requires: Minimal interaction
  
Dream System (Idle, 8 hours):
  Energy regen: 16 units (8 hours / 0.5 hours per unit)
  Dreams playable: 5 (16 / 3)
  Income: 5 × 96 = 480 Reveries
  Reveries/hour: 60
  
Balance: Dreams provide steady idle income, combat runs provide active bursts
```

**Re-draw Investment Analysis:**
```python
def analyze_redraw_roi(tier, blocks_redrawn):
    """
    Return on Investment for re-drawing cards
    """
    
    # Costs
    redraw_costs = {
        1: 10,  # Block 1
        2: 20,  # Block 2
        3: 30   # Block 3
    }
    
    total_cost = sum(redraw_costs[b] for b in blocks_redrawn)
    
    # Benefits (increased perfect dream probability)
    if tier == "common":
        base_chance = 0.30
        # Each re-draw adds ~20% to match chance
        improved_chance = min(0.80, base_chance + (len(blocks_redrawn) * 0.15))
    
    expected_bonus = 60 * improved_chance  # 60 Reveries bonus
    
    return {
        "investment": total_cost,
        "expected_return": expected_bonus,
        "net_profit": expected_bonus - total_cost,
        "roi": (expected_bonus - total_cost) / total_cost * 100
    }

# Example:
# Re-draw Blocks 2-3 (50 Reveries cost)
# Improved chance: 30% → 60%
# Expected bonus: 60 × 0.6 = 36 Reveries
# Net: 36 - 50 = -14 Reveries (LOSS)
# Conclusion: Not worth it for Common tier with bonus alone
# BUT: Valuable for rare card drops and achievements
```

### 3.2.4 Energy System Balance

**Energy as Pacing Mechanic:**
```yaml
Free-to-Play Player (No IAP):
  Daily Energy: 3 (free) + 16 (regen 8 hours) = 19 units
  Dreams per day: 6 (19 / 3)
  Daily Reveries: 6 × 96 = 576 Reveries
  
Paying Player (1× $0.99 energy pack):
  Daily Energy: 19 (free) + 5 (IAP) = 24 units
  Dreams per day: 8
  Daily Reveries: 8 × 96 = 768 Reveries
  Extra income: +192 Reveries for $0.99
  Reveries per $: 194 Reveries/$
  
Energy-Free Mode ($4.99 one-time):
  Daily Energy: Unlimited
  Dreams per day: Limited by time (~20 dreams)
  Daily Reveries: 20 × 96 = 1,920 Reveries
  Extra income: +1,344 Reveries/day
  Value: Pays for itself in 4 days
```

**Energy Regeneration vs Spending:**
```python
class EnergyEconomy:
    """Balance energy generation and consumption"""
    
    def __init__(self):
        self.regen_rate = 1800  # 30 minutes = 1 energy
        self.daily_free = 3
        self.max_storage = 5
    
    def daily_free_energy(self):
        """Total free energy per day"""
        # Regen: 24 hours / 0.5 hours per unit = 48 units
        # But capped at storage: 5 max
        # Realistic: Player checks 3× daily = 15 units
        return self.daily_free + 15
    
    def calculate_energy_value(self):
        """Monetary value of 1 energy unit"""
        reveries_per_energy = 32  # From dream completion average
        reveries_per_dollar = 194  # From $0.99 pack (5 energy)
        
        energy_value = 194 / 5  # $0.198 per energy
        return {
            "usd_per_energy": 0.198,
            "reveries_per_energy": 32,
            "usd_per_reverie": 0.198 / 32  # $0.0062 per Reverie
        }
```

**Energy Cap Strategy:**
```yaml
Why 5-unit cap?
  - Prevents infinite hoarding
  - Encourages regular play (3-4 times/day)
  - Monetization lever (IAP for overflow)
  
Player Behavior:
  Morning: Collect 3 free + 3 regen = 6 units (capped at 5)
  Play 1 dream: -3 energy = 2 remaining
  Afternoon: +3 regen = 5 (capped)
  Play 1 dream: -3 energy = 2 remaining
  Evening: +3 regen = 5 (capped)
  Play 1 dream: -3 energy = 2 remaining
  
Total: 3 dreams/day (9 energy) without IAP
```

---

## 3.3 Card Balance

### 3.3.1 Damage-per-Energy Ratio

**Balance Targets:**
```yaml
Common Cards:
  Damage/Energy: 4-5
  Example: [Basic Strike] 1 cost, 5 damage = 5 DPE

Uncommon Cards:
  Damage/Energy: 5-6
  Example: [Lucid Strike] 2 cost, 10 damage = 5 DPE
           [Lucid Strike conditional] 2 cost, 15 damage = 7.5 DPE

Rare Cards:
  Damage/Energy: 6-8
  Example: [Dream Cascade] 2 cost, 14 damage (with 3 attacks) = 7 DPE

Epic Cards:
  Damage/Energy: 8-10
  Example: [Lucid Nova] 3 cost, 20 damage = 6.7 DPE (+ draw 1 card)

Legendary Cards:
  Damage/Energy: 10+
  Example: [Infinity Edge] 2 cost, 8 damage (scaling) → Eventually 20+ DPE
```

### 3.3.2 Block-per-Energy Ratio

**Balance Targets:**
```yaml
Common Cards:
  Block/Energy: 6-8
  Example: [Dream Shield] 1 cost, 8 block = 8 BPE

Uncommon Cards:
  Block/Energy: 8-10
  Example: [Ethereal Guard] 1 cost, 10 block = 10 BPE

Rare Cards:
  Block/Energy: 10-12
  Example: [Lucid Barrier] 2 cost, 15 block = 7.5 BPE (+ healing)

Epic Cards:
  Block/Energy: 12-15
  Example: [Sanctuary] 3 cost, 20 block = 6.7 BPE (+ heal 5 + energy)
```

### 3.3.3 Reveries-per-Energy Ratio

**Balance Targets:**
```yaml
Common Cards:
  Reveries/Energy: 5-10
  Example: [Reverie Burst] 1 cost, 10 Reveries = 10 RPE

Uncommon Cards:
  Reveries/Energy: 10-15
  Example: [Lucid Harvest] 2 cost, 20 Reveries = 10 RPE

Rare Cards:
  Reveries/Energy: 15-25
  Example: [Dream Factory] 2 cost, 20-40 Reveries (with synergy) = 20 RPE

Epic Cards:
  Reveries/Energy: 30+
  Example: [Golden Sleep] 4 cost, 120+ Reveries/run = 30+ RPE
```

### 3.3.4 Card Nerf/Buff Criteria

**When to Nerf:**
- Card appears in 80%+ of winning decks
- Win rate with card > 20% higher than without
- Card trivializes entire encounters

**When to Buff:**
- Card appears in <5% of decks
- Card objectively worse than same-rarity alternatives
- No viable use case

**Example Balance Changes:**
```yaml
[Oblivion Strike] BEFORE:
  Cost: 5 Energy
  Damage: 40
  Issue: Too expensive, rarely playable
  Win Rate with Card: 35%

[Oblivion Strike] AFTER:
  Cost: 3 Energy
  Damage: 40
  Exile after use (drawback added)
  Win Rate with Card: 52% (balanced)

[God Mode] BEFORE:
  Cost: 3 Energy
  Effect: All cards free, cannot lose HP
  Issue: Broken, instant win
  Win Rate with Card: 98%

[God Mode] AFTER:
  Cost: 5 Energy
  Effect: All cards cost -1, cannot lose HP this run
  Win Rate with Card: 68% (still strong, but fair)
```

---

## 3.4 Progression Speed

### 3.4.1 Session Length Targets

**Active Play Session:**
```yaml
Tutorial Run: 5-10 minutes
Standard Run: 15-25 minutes
Speed Run (optimized): 10 minutes
Boss Rush (future mode): 30 minutes

Daily Targets:
  Casual Player: 1 run/day (20 min)
  Core Player: 2-3 runs/day (60 min)
  Hardcore Player: 5+ runs/day (2+ hours)
```

### 3.4.2 Progression Milestones

**Time to Unlock (Estimated):**
```yaml
First Prestige (10,000 Reveries):
  Active Play: 20-25 runs (~8 hours)
  Idle Play: 2-3 days (with optimization)

Full Card Collection (85 cards):
  Active Play: 50-100 runs (~30 hours)
  Idle Play: 2-3 weeks

Max Upgraded Deck (12 cards, level 10):
  Active Play: 100+ runs (~50 hours)
  Idle Play: 4-6 weeks

All Prestige Bonuses (Tier 10):
  Active Play: 200+ runs (~100 hours)
  Idle Play: 2-3 months
```

### 3.4.3 Retention Targets

**Day 1: 100% players**
- Tutorial completion: 90%
- First run completion: 70%
- Second session: 50%

**Day 7: 40% retention**
- Completed 10+ runs: 60%
- Unlocked 3+ Dreamers: 40%
- First prestige: 20%

**Day 30: 20% retention**
- Completed 50+ runs: 30%
- Prestige Tier 3+: 15%
- Full card collection: 10%

**Retention Tools:**
- Daily login rewards
- Weekly challenges
- Limited-time events
- Seasonal battle pass

---

# 4. UI/UX Flow

## 4.1 Screen Structure

### 4.1.1 Dream Home Screen (Primary Hub)

**Core Concept:**
The **Dream Home** is the primary hub where players manage their dream-linking meta-game. It replaces the traditional "lobby" with a tarot card-based interface that visualizes dream progression.

**Layout (Portrait 390×844px):**
```
┌────────────────────────────────┐
│ [Energy: ⚡⚡⚡▫▫] [Reveries: 1,234] [⚙] │ ← Top Bar (60px)
├────────────────────────────────┤
│  ╔════════╗  ╔════════╗  ╔════════╗│
│  ║ BLOCK 1║  ║ BLOCK 2║  ║ BLOCK 3║│ ← Tarot Cards (200px)
│  ║        ║  ║        ║  ║        ║│   Horizontal scroll
│  ║ [Card] ║  ║ [LOCK] ║  ║ [LOCK] ║│   Large, central focus
│  ║        ║  ║        ║  ║        ║│
│  ╚════════╝  ╚════════╝  ╚════════╝│
│  The Fool's Journey • Stage 1/3   │ ← Series Name
│  [🔄 Re-draw: 10 R] [▶ Continue]  │ ← Action Buttons
├────────────────────────────────┤
│ 📖 Current Dream Story:         │
│ ┌────────────────────────────┐ │ ← Story Text Box (150px)
│ │ "A young dreamer stands at │ │   Scrollable
│ │  the edge of a cliff,      │ │   Atmospheric text
│ │  ready to leap into the    │ │
│ │  unknown..."               │ │
│ └────────────────────────────┘ │
├────────────────────────────────┤
│ Previous Dreams (Completed):   │
│ ┌──────────────────────────────┐│ ← Dream History Stack
│ │ ✓ Perfect: The Fool's Journey││   (Scrollable list)
│ │   +180 Reveries • 2h ago     ││   Each entry tappable
│ └──────────────────────────────┘│
│ ┌──────────────────────────────┐│
│ │ ✗ Broken: Mixed Dreams       ││
│ │   +60 Reveries • 5h ago      ││
│ └──────────────────────────────┘│
│ ┌──────────────────────────────┐│
│ │ ✓ Partial: Tower's Fall I-II ││
│ │   +140 Reveries • 8h ago     ││
│ └──────────────────────────────┘│
└────────────────────────────────┘
│ [Home] [Combat Deck] [Library] [Shop]│ ← Tab Bar (80px)
└────────────────────────────────┘
```

**Interactive Elements:**

**1. Energy Display (Top Left):**
- Visual: 5 energy orbs (⚡ filled, ▫ empty)
- Tap to open Energy Info modal:
  - Current: 3/5
  - Next regen: 15 minutes
  - [Buy Energy] button → IAP shop

**2. Tarot Card Blocks:**
- **Block 1 (Active):**
  - Shows drawn card or [?] placeholder
  - Tap → Card detail view (story, combat triggers)
  - Glow animation if card drawn
  
- **Block 2-3 (Locked):**
  - Grayed out with lock icon
  - Unlock when previous block complete
  
**3. Action Buttons:**
- **Re-draw (10-30 Reveries):**
  - Only visible if current block not confirmed
  - Shows cost dynamically
  - 3 re-draws max per block
  
- **Continue (1 Energy):**
  - Primary CTA, glowing
  - Draws next card OR proceeds to combat
  - Disabled if energy = 0

**4. Story Text Box:**
- Auto-updates with each card drawn
- Smooth fade transition (500ms)
- Font: Serif, slightly larger (14pt)
- Background: Semi-transparent dark overlay

**5. Dream History Stack:**
- Reverse chronological (newest on top)
- Each entry shows:
  - Completion status icon (✓ Perfect, ⚠ Partial, ✗ Broken)
  - Series name
  - Reveries earned
  - Time ago (relative: "2h ago")
- Tap entry → Full dream replay (story + rewards summary)
- Swipe left → Archive (hide from list)

**6. Tab Bar:**
- **Home:** Dream Home (current screen)
- **Combat Deck:** Deckbuilding screen (for combat cards)
- **Library:** Content library (cards, dreamers, achievements)
- **Shop:** Monetization (IAP, ads, cosmetics)

**Visual Theme:**
- **Background:** Soft gradient (purple to blue), animated stars
- **Tarot Cards:** Large, ornate, golden borders
- **Typography:** Mix of serif (story) and sans-serif (UI)
- **Animations:** Gentle floating (cards), particle effects (energy)

---

### 4.1.1.1 Dream Card Reveal Animation

**Sequence:**
```
1. Player taps "Continue" (costs 1 Energy)
   ↓ (Energy orb depletes with glow effect, 300ms)
   
2. Tarot card placeholder grows and centers (500ms)
   ↓ (Card scales to 150%, rest of UI blurs)
   
3. Card flips to reveal front (800ms)
   ↓ (3D flip animation, glowing edges)
   
4. Series match check:
   - Match: Green glow + "Series Continues!" text
   - No match: Red glow + "New Path..." text
   ↓ (Feedback lasts 1s)
   
5. Card shrinks back to block position (500ms)
   ↓ (Returns to Dream Home layout)
   
6. Story text updates (fade transition, 500ms)
   ↓
   
7. If combat trigger: Show "Enter Dream" button
   If no combat: Auto-unlock next block
```

**Total Time:** ~3.5 seconds (skippable after 1s)

---

### 4.1.1.2 Dream Home to Combat Transition

**Vortex Effect:**
```
1. Player taps "Enter Dream" button
   ↓
   
2. Tarot card pulses and glows (300ms)
   ↓
   
3. Vortex appears behind card (500ms)
   - Spiral animation (rotating inward)
   - Color: Card's series color
   - Sound: Deep whoosh
   ↓
   
4. Screen elements sucked into vortex (800ms)
   - UI elements fly toward center
   - Dream Home fades to black
   - Player feels "pulled in"
   ↓
   
5. Brief darkness (200ms)
   ↓
   
6. Combat screen fades in (500ms)
   - Enemy appears from darkness
   - Combat UI slides in from edges
   
Total: ~2.3 seconds (non-skippable, narrative importance)
```

**Return Transition (Combat → Dream Home):**
```
1. Combat victory/defeat screen (2s)
   ↓
   
2. Screen whites out (300ms)
   - Flash of light
   - Sound: Chime
   ↓
   
3. Dream Home fades back in (500ms)
   - Completed card now has checkmark
   - Story text updates with outcome
   - Rewards briefly highlight (+120 R, +1 card)
   
Total: ~2.8 seconds (skippable after victory screen)
```

### 4.1.2 Deck Builder Screen

**Layout:**
```
┌────────────────────────────────┐
│ [← Back]  Deck Builder  [Save] │ ← Header (60px)
├────────────────────────────────┤
│ Current Deck (8/12):           │ ← Deck Summary (40px)
├────────────────────────────────┤
│ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ... │ ← Horizontal Scroll
│ │C1│ │C2│ │C3│ │C4│ │C5│     │   Current Deck (120px)
│ └──┘ └──┘ └──┘ └──┘ └──┘     │   Cards: 64×90px
├────────────────────────────────┤
│ [Filters▼] [Sort▼] [Search🔍] │ ← Filter Bar (50px)
├────────────────────────────────┤
│ ┌──┐ ┌──┐ ┌──┐                │
│ │A1│ │A2│ │A3│  Available     │ ← Scrollable Grid
│ └──┘ └──┘ └──┘  Cards          │   (3 columns)
│ ┌──┐ ┌──┐ ┌──┐                │   Cards: 100×140px
│ │A4│ │A5│ │A6│                │
│ └──┘ └──┘ └──┘                │
│ ...                            │
└────────────────────────────────┘
```

**Interactions:**
1. **Tap Card in Available:** → Add to deck (if space allows)
2. **Tap Card in Deck:** → Remove from deck
3. **Long Press Card:** → Show detail modal (stats, upgrades)
4. **Drag Card:** (Optional) Drag from available to deck

**Filters:**
- **Type:** All / Attack / Defense / Collection / Synergy
- **Rarity:** All / Common / Uncommon / Rare / Epic / Legendary
- **Tags:** All / Nightmare / Memory / Lucid
- **Ownership:** All / Owned / Not Owned

### 4.1.3 Run Preparation Screen

**Layout:**
```
┌────────────────────────────────┐
│ [← Back]  Prepare Run          │
├────────────────────────────────┤
│ Select Dreamer:                │
│ ┌────────┐ ┌────────┐ ┌────┐  │
│ │Serenity│ │Anxiety │ │Fear│  │ ← Dreamer Cards
│ │  Easy  │ │ Medium │ │Hard│  │   (Horizontal Scroll)
│ │ 10 HP  │ │  8 HP  │ │6 HP│  │
│ └────────┘ └────────┘ └────┘  │
├────────────────────────────────┤
│ Your Deck (12 cards):          │
│ ┌──┐ ┌──┐ ┌──┐ ┌──┐ ...       │ ← Deck Preview
│ │C1│ │C2│ │C3│ │C4│            │   (Horizontal Scroll)
│ └──┘ └──┘ └──┘ └──┘            │
│ [Edit Deck]                    │
├────────────────────────────────┤
│                                │
│  ┌──────────────────────────┐ │
│  │    🚀 BEGIN RUN          │ │ ← Large CTA
│  └──────────────────────────┘ │
│                                │
└────────────────────────────────┘
```

### 4.1.4 Run In-Progress Screen

**Layout:**
```
┌────────────────────────────────┐
│ HP: ████▁▁ (6/10)  EN: ██▁ (2) │ ← Status Bar (50px)
│ Reveries: 125                  │
├────────────────────────────────┤
│ Progress: [1][2][3]...[10]     │ ← Node Map (80px)
│           ●━━○━━○━━○━━○━━●     │   (Visual path)
├────────────────────────────────┤
│                                │
│   [Dreamscape Background]      │ ← Main View (400px)
│   [Node Animation]             │   (Parallax layers)
│                                │
├────────────────────────────────┤
│ Current Node: Memory (○)       │ ← Node Info (120px)
│ ┌────────────────────────────┐ │
│ │ Collect 10 Reveries        │ │
│ │ [Collect] [Heal (30R)]     │ │ ← Choice Buttons
│ └────────────────────────────┘ │
├────────────────────────────────┤
│ [Skip Anim] [Auto] [Menu]      │ ← Bottom Actions (60px)
└────────────────────────────────┘
```

**Node Types - UI Variants:**

**Memory Node:**
```
│ ┌────────────────────────────┐ │
│ │ 💎 Memory Node             │ │
│ │ Collect 10 Reveries        │ │
│ │                            │ │
│ │ [Collect]                  │ │
│ │ [Heal 5 HP (30 Reveries)]  │ │
│ │ [Upgrade Card (Varies)]    │ │
│ └────────────────────────────┘ │
```

**Event Node:**
```
│ ┌────────────────────────────┐ │
│ │ ❓ Event: Crossroads       │ │
│ │ "Two paths diverge..."     │ │
│ │                            │ │
│ │ [A] Safe Path (20 R)       │ │
│ │ [B] Risky Path (50% 50R)   │ │
│ └────────────────────────────┘ │
```

**Combat Node:**
```
│ ┌────────────────────────────┐ │
│ │ ⚔ Combat: Shadow Fiend     │ │
│ │ HP: ████████▁▁ (15/18)     │ │
│ │ Attack: 3                  │ │
│ │                            │ │
│ │ [Enter Combat] →           │ │
│ └────────────────────────────┘ │
```

---

## 4.2 Combat Screen Layout

### 4.2.1 Combat UI Structure

**Full Combat Screen (Portrait):**
```
┌────────────────────────────────┐
│ [Menu ☰]  Turn: 3  [End Turn] │ ← Top Bar (50px)
├────────────────────────────────┤
│        Enemy Area              │
│  ┌──────────────────────────┐ │
│  │   Shadow Fiend           │ │ ← Enemy Card (180px)
│  │   HP: ████████▁▁ (15/18) │ │   - Name
│  │   Attack: 3 (Next turn)  │ │   - HP Bar
│  │   [Status Icons]         │ │   - Intent
│  └──────────────────────────┘ │
├────────────────────────────────┤
│        Combat Log              │
│  • You dealt 10 damage         │ ← Scrolling Log (100px)
│  • Enemy attacks for 3         │   (Recent 3 actions)
│  • You blocked 8               │
├────────────────────────────────┤
│        Player Area             │
│  HP: ████████▁▁ (7/10)         │ ← Player Stats (60px)
│  Energy: ██▁ (2/3)             │
│  [Status Icons]                │
├────────────────────────────────┤
│        Hand (5 cards)          │
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐ ┌──┐    │ ← Card Hand (150px)
│  │C1│ │C2│ │C3│ │C4│ │C5│    │   Cards: 72×101px
│  └──┘ └──┘ └──┘ └──┘ └──┘    │
├────────────────────────────────┤
│  Deck: 23  Discard: 5          │ ← Deck Info (40px)
└────────────────────────────────┘
```

### 4.2.2 Card Play Interactions

**Card Play Flow:**
```
1. Player taps card in hand
   ↓
2. Card highlights (yellow glow)
   ↓
3. If targeting required: Enemy highlights
   ↓
4. Player taps enemy (confirm target)
   ↓
5. Card plays:
   - Energy deducted
   - Animation plays
   - Effect resolves
   - Card moves to discard
   ↓
6. Update UI:
   - HP bars animate
   - Energy updates
   - Combat log entry added
```

**Card States:**
```css
.card-default {
  /* Resting state in hand */
  scale: 1.0;
  opacity: 1.0;
  filter: none;
}

.card-highlighted {
  /* Selected, ready to play */
  scale: 1.1;
  box-shadow: 0 0 20px yellow;
  transform: translateY(-10px);
}

.card-unplayable {
  /* Not enough Energy */
  opacity: 0.5;
  filter: grayscale(100%);
  pointer-events: none;
}

.card-playing {
  /* Animation during play */
  animation: card-fly-to-enemy 0.5s ease-out;
}
```

### 4.2.3 Enemy Intent Display

**Intent Icons:**
```
┌────────────────────┐
│ Shadow Fiend       │
│ HP: ████████▁▁     │
│                    │
│ Intent: ⚔️ 3        │  ← Attack (shows damage)
│ Intent: 🛡️ 5        │  ← Block (shows block value)
│ Intent: ⚡ Buff     │  ← Buff (generic)
│ Intent: 👥 Summon   │  ← Summon
│ Intent: ❓ Unknown  │  ← Mystery (some enemies)
└────────────────────┘
```

**Intent Colors:**
```yaml
Attack Intent:
  Low (1-4 damage): Yellow ⚔️
  Medium (5-8 damage): Orange ⚔️
  High (9+ damage): Red ⚔️

Debuff Intent: Purple 💀
Buff Intent: Green ⚡
Summon Intent: Blue 👥
```

---

## 4.3 Input System

### 4.3.1 Touch Gestures

**Supported Gestures:**
```yaml
Tap:
  - Select card
  - Confirm action
  - Navigate menus
  - Target enemy

Long Press (500ms):
  - View card details
  - View enemy details
  - View status effect tooltip

Swipe:
  - Horizontal: Navigate between screens
  - Vertical: Scroll lists
  - Up on card: Quick play (no targeting)

Drag (Optional - Advanced):
  - Drag card from hand to enemy
  - Drag card to reorder deck
```

### 4.3.2 Accessibility

**Touch Target Sizes:**
```yaml
Minimum Touch Target: 44×44pt (Apple HIG standard)

Button Sizes:
  Primary CTA: 280×60px
  Secondary Button: 140×50px
  Icon Button: 48×48px
  Card: 72×101px (combat), 100×140px (deck builder)
```

**Feedback:**
```yaml
Visual:
  - Button press: Scale to 0.95× + darker shade
  - Selection: Highlight border + glow
  - Disabled: 50% opacity + grayscale

Haptic:
  - Button tap: Light impact
  - Card play: Medium impact
  - Victory/Defeat: Heavy impact + pattern
  - Error: Notification feedback

Audio:
  - Button tap: Soft click
  - Card play: Whoosh + impact
  - Damage dealt: Hit sound
  - Damage taken: Hurt sound
  - Victory: Triumphant fanfare
```

### 4.3.3 Mobile-Specific Optimizations

**One-Handed Mode:**
```yaml
UI Bias: Bottom 60% of screen (thumb-reachable)
Top Bar: Read-only info (no critical actions)
Bottom Buttons: Primary actions (Start Run, End Turn)
Swipe Gestures: Alternative to top-bar buttons
```

**Landscape Support (Optional):**
```
┌─────────────────────────────────────────────────┐
│ [Menu]  HP:████ EN:██  [Turn 3]  [End Turn]   │
│                                                 │
│  ┌──────────┐                  ┌──────────────┐│
│  │  Enemy   │                  │  Hand (5)    ││
│  │  [Card]  │                  │ [C1][C2][C3] ││
│  └──────────┘                  │ [C4][C5]     ││
│                                 └──────────────┘│
└─────────────────────────────────────────────────┘
Wider layout: Enemy left, hand right, more visible at once
```

---

## 4.4 Feedback System

### 4.4.1 Animation Timing

**Core Animation Speeds:**
```yaml
Card Play:
  - Selection: 100ms (instant feel)
  - Fly to target: 300ms (readable)
  - Impact: 200ms (satisfying hit)
  - Return to discard: 200ms
  Total: ~800ms per card

Enemy Turn:
  - Intent reveal: 500ms (telegraphing)
  - Attack windup: 300ms
  - Damage dealt: 400ms (player HP animates)
  Total: ~1,200ms per enemy action

Victory/Defeat:
  - Outcome determination: 0ms (instant check)
  - Victory fanfare: 1,500ms
  - Reward screen transition: 500ms
  Total: ~2,000ms

UI Transitions:
  - Screen fade: 300ms
  - Slide transition: 400ms
  - Modal popup: 250ms
```

**Speed Settings:**
```yaml
Normal Speed: 1.0× (default)
Fast Speed: 2.0× (halve all animations)
Instant Speed: 10.0× (skip to results)

Player Preference: Saved locally, persistent
```

### 4.4.2 Visual Effects (VFX)

**Particle Systems:**
```yaml
Card Play Effects:
  Attack Cards:
    - Projectile trail (color by rarity)
    - Impact burst (sparks, debris)
    - Screen shake (2-5px, 100ms)
  
  Defense Cards:
    - Shield shimmer (translucent overlay)
    - Block particles (stars, light)
    - No screen shake
  
  Collection Cards:
    - Reverie particles (glowing orbs)
    - Upward float animation
    - Soft glow around player

Damage Effects:
  Player Takes Damage:
    - Red flash on screen edges (200ms)
    - HP bar shake (5px, 150ms)
    - Damage number floats up (-5 HP)
  
  Enemy Takes Damage:
    - Enemy card shake (8px, 200ms)
    - Damage number floats up (-10)
    - Blood/shadow particles (theme-dependent)

Victory/Defeat:
  Victory:
    - Gold confetti burst
    - Screen brightens (+20% brightness, 1s)
    - Radial blur zoom-in
  
  Defeat:
    - Screen desaturates (grayscale, 1s)
    - Vignette darkens edges
    - Slow-motion effect (0.5× speed, 500ms)
```

### 4.4.3 Audio Design

**Sound Categories:**
```yaml
UI Sounds:
  - Button Tap: Soft click (50ms)
  - Card Select: Paper rustle (100ms)
  - Menu Open: Whoosh (150ms)
  - Error: Buzzer (200ms)

Combat Sounds:
  - Card Play: Whoosh + thud (300ms)
  - Attack Hit: Impact + grunt (400ms)
  - Block: Shield clang (250ms)
  - Heal: Sparkle chime (350ms)

Ambient:
  - Menu Music: Soft piano, 80 BPM, looping
  - Combat Music: Uptempo strings, 120 BPM
  - Victory Jingle: Triumphant horns, 5s
  - Defeat Jingle: Somber strings, 3s

Voice (Optional - Future):
  - Enemy Roar: On spawn
  - Player Grunt: On hit
  - Victory Cheer: On run complete
```

**Audio Settings:**
```yaml
Volume Controls:
  - Master Volume: 0-100%
  - Music Volume: 0-100%
  - SFX Volume: 0-100%
  - Mute All: Toggle

Audio Priority:
  1. Error sounds (always play)
  2. Combat impacts (important feedback)
  3. UI sounds (can be dropped if too many)
  4. Ambient loops (background)
```

### 4.4.4 Progress Indicators

**Loading States:**
```yaml
App Launch:
  - Splash screen: GeekBrox logo (1s)
  - Loading bar: 0-100% (with asset names)
  - Timeout: 10s (then error message)

Between Screens:
  - Fade transition: 300ms (no loader needed)
  - Long loads (>1s): Spinner + "Loading..."
  
Combat Actions:
  - Card play: Immediate (no loading)
  - Enemy turn: Progressive (show each action)
  - Run generation: "Generating dreamscape..." (1-2s)

Offline Rewards:
  - Calculation: Instant (<100ms)
  - Animation: 2s (number counts up)
  - Skippable: Tap to skip to final value
```

**Progress Bars:**
```css
.progress-bar {
  height: 8px;
  background: linear-gradient(to right, #4CAF50, #8BC34A);
  border-radius: 4px;
  animation: fill 2s ease-out;
  
  /* Indeterminate (unknown duration) */
  animation: slide 1.5s infinite;
}
```

---

# 5. Technical Specification

## 5.1 Platform Requirements

### 5.1.1 Mobile Specifications

**iOS:**
```yaml
Minimum:
  - iOS Version: 14.0+
  - Devices: iPhone 8 and newer
  - RAM: 2 GB
  - Storage: 500 MB

Recommended:
  - iOS Version: 16.0+
  - Devices: iPhone 12 and newer
  - RAM: 4 GB
  - Storage: 1 GB (with asset caching)

Tested Devices:
  - iPhone 8 (minimum)
  - iPhone 12 (target)
  - iPhone 14 Pro (premium)
  - iPad Air (tablet support)
```

**Android:**
```yaml
Minimum:
  - Android Version: 10 (API 29)
  - Devices: 1080×1920 resolution
  - RAM: 2 GB
  - Storage: 500 MB

Recommended:
  - Android Version: 12 (API 31)
  - Devices: 1440×2560 resolution
  - RAM: 4 GB
  - Storage: 1 GB

Tested Devices:
  - Samsung Galaxy S10 (minimum)
  - Samsung Galaxy S21 (target)
  - Google Pixel 6 (reference)
  - OnePlus 9 (performance test)
```

### 5.1.2 PC Specifications (Secondary)

**Windows/macOS:**
```yaml
Minimum:
  - OS: Windows 10 / macOS 10.15
  - CPU: Intel i3 / Ryzen 3
  - RAM: 4 GB
  - GPU: Integrated graphics
  - Storage: 1 GB

Recommended:
  - OS: Windows 11 / macOS 13
  - CPU: Intel i5 / Ryzen 5
  - RAM: 8 GB
  - GPU: Dedicated (optional)
  - Storage: 2 GB

Input:
  - Keyboard + Mouse (primary)
  - Gamepad support (optional - future)
  - Touch screen (if available)
```

---

## 5.2 Data Structure

### 5.2.1 JSON Schema Definitions

**Card Data (`cards.json`):**
```json
{
  "cards": [
    {
      "id": "card_001",
      "name": "Basic Strike",
      "type": "attack",
      "rarity": "common",
      "cost": 1,
      "effect": {
        "type": "damage",
        "value": 5,
        "target": "enemy"
      },
      "upgrade": {
        "damage_per_level": 1,
        "cost_reduction_at": [5, 10]
      },
      "tags": ["attack", "basic"],
      "flavor_text": "The simplest dreams cut deepest.",
      "assets": {
        "thumbnail": "cards/basic_strike_thumb.png",
        "full": "cards/basic_strike_full.png"
      }
    }
  ]
}
```

**Monster Data (`monsters.json`):**
```json
{
  "monsters": [
    {
      "id": "enemy_001",
      "name": "Dream Wisp",
      "difficulty": 1,
      "stats": {
        "hp": 8,
        "attack": 1,
        "defense": 0
      },
      "ai": {
        "pattern": "basic_attack",
        "script": "attack_every_turn",
        "parameters": {}
      },
      "rewards": {
        "reveries": 10,
        "card_drop_chance": 0.0,
        "card_pool": []
      },
      "tags": ["tutorial", "harmless"],
      "assets": {
        "portrait": "enemies/dream_wisp.png",
        "sprite": "enemies/dream_wisp_anim.json"
      }
    }
  ]
}
```

**Player Save Data (`save.json`):**
```json
{
  "version": "1.0.0",
  "player": {
    "id": "uuid-string",
    "name": "Player",
    "created_at": "2026-02-23T10:00:00Z",
    "last_played": "2026-02-23T12:30:00Z"
  },
  "resources": {
    "reveries": 1234,
    "dream_shards": 56,
    "lifetime_reveries": 50000
  },
  "collection": {
    "owned_cards": [
      {"id": "card_001", "level": 5, "count": 3},
      {"id": "card_002", "level": 1, "count": 1}
    ],
    "unlocked_dreamers": ["serenity", "anxiety"],
    "unlocked_achievements": ["first_win", "perfect_run"]
  },
  "decks": [
    {
      "name": "Aggro Deck",
      "cards": ["card_001", "card_001", "card_005", "card_010", "..."]
    }
  ],
  "current_run": {
    "active": true,
    "dreamer": "serenity",
    "current_node": 5,
    "hp": 7,
    "max_hp": 10,
    "energy": 3,
    "reveries_this_run": 125,
    "path": ["memory", "event", "memory", "combat", "memory", "..."],
    "deck_state": {
      "draw_pile": ["card_001", "card_003", "..."],
      "hand": ["card_005", "card_010"],
      "discard_pile": ["card_001", "card_002"]
    }
  },
  "prestige": {
    "level": 2,
    "total_shards_earned": 150,
    "bonuses": {
      "idle_rate_bonus": 50,
      "starting_hp_bonus": 2,
      "starting_energy_bonus": 1
    }
  },
  "settings": {
    "music_volume": 0.7,
    "sfx_volume": 0.8,
    "animation_speed": 1.0,
    "notifications_enabled": true
  },
  "stats": {
    "runs_completed": 23,
    "runs_failed": 7,
    "total_combat_wins": 156,
    "total_damage_dealt": 45000,
    "total_cards_played": 2300
  }
}
```

### 5.2.2 Database Schema (If Using Backend)

**Users Table:**
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    last_login TIMESTAMP,
    total_playtime_seconds INTEGER DEFAULT 0
);
```

**Player Saves Table:**
```sql
CREATE TABLE player_saves (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    save_data JSONB NOT NULL,  -- Stores entire save.json
    version VARCHAR(10) NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_player_saves_user ON player_saves(user_id);
```

**Leaderboards Table (Optional):**
```sql
CREATE TABLE leaderboards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    category VARCHAR(50) NOT NULL,  -- 'total_reveries', 'fastest_run', etc.
    score BIGINT NOT NULL,
    metadata JSONB,  -- Additional details (deck used, etc.)
    achieved_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_leaderboards_category_score ON leaderboards(category, score DESC);
```

---

## 5.3 Save System

### 5.3.1 Local Save (Primary)

**Save Triggers:**
```python
def auto_save():
    """Called automatically at key moments"""
    triggers = [
        "on_node_complete",
        "on_card_upgrade",
        "on_deck_change",
        "on_run_complete",
        "on_prestige",
        "on_app_background",  # iOS/Android lifecycle
        "every_60_seconds"    # Periodic backup
    ]
    
    serialize_save_data()
    write_to_local_storage()
    compress_if_large()
```

**File Structure:**
```
~/.dream_collector/
├── save.json           ← Primary save file
├── save_backup.json    ← Automatic backup (previous session)
├── settings.json       ← User preferences
├── cache/
│   ├── card_images/    ← Downloaded assets
│   └── audio/          ← Audio clips
└── logs/
    └── error.log       ← Debug logs
```

**Save Integrity:**
```python
import hashlib
import json

def save_with_checksum(data):
    """Prevent save corruption"""
    json_str = json.dumps(data, sort_keys=True)
    checksum = hashlib.sha256(json_str.encode()).hexdigest()
    
    save_file = {
        "data": data,
        "checksum": checksum,
        "timestamp": time.time()
    }
    
    with open("save.json", "w") as f:
        json.dump(save_file, f, indent=2)

def load_with_verification():
    """Verify save integrity on load"""
    with open("save.json", "r") as f:
        save_file = json.load(f)
    
    data = save_file["data"]
    expected_checksum = save_file["checksum"]
    
    json_str = json.dumps(data, sort_keys=True)
    actual_checksum = hashlib.sha256(json_str.encode()).hexdigest()
    
    if actual_checksum != expected_checksum:
        raise SaveCorruptedError("Save file corrupted, loading backup...")
    
    return data
```

### 5.3.2 Cloud Save (Optional)

**Cloud Sync Strategy:**
```python
class CloudSaveManager:
    def __init__(self, backend="firebase"):
        self.backend = backend
        self.sync_interval = 300  # 5 minutes
        self.last_sync = 0
    
    def should_sync(self):
        return (time.time() - self.last_sync) > self.sync_interval
    
    def sync_to_cloud(self, save_data):
        """Upload save to cloud"""
        if not self.should_sync():
            return
        
        # Compress save data
        compressed = gzip.compress(json.dumps(save_data).encode())
        
        # Upload to backend
        if self.backend == "firebase":
            firebase.upload(user_id, compressed)
        
        self.last_sync = time.time()
    
    def sync_from_cloud(self):
        """Download save from cloud"""
        if self.backend == "firebase":
            compressed = firebase.download(user_id)
        
        # Decompress
        json_str = gzip.decompress(compressed).decode()
        return json.loads(json_str)
    
    def resolve_conflict(self, local_save, cloud_save):
        """Handle save conflicts"""
        # Use most recent save
        if local_save["last_played"] > cloud_save["last_played"]:
            return local_save
        else:
            return cloud_save
```

**Conflict Resolution:**
```yaml
Scenario 1: Cloud newer than local
  → Use cloud save, overwrite local

Scenario 2: Local newer than cloud
  → Use local save, upload to cloud

Scenario 3: Both modified (conflict)
  → Compare timestamps
  → Use newer save
  → Offer manual merge (advanced)
```

### 5.3.3 Data Migration

**Version Migration:**
```python
def migrate_save_data(old_version, new_version, data):
    """Migrate saves between game versions"""
    
    if old_version == "1.0.0" and new_version == "1.1.0":
        # Example: Add new field
        data["prestige"]["bonuses"]["new_feature"] = 0
    
    if old_version == "1.1.0" and new_version == "2.0.0":
        # Example: Restructure data
        data["collection"]["owned_cards"] = [
            {"id": c, "level": 1, "count": 1}
            for c in data["collection"]["cards"]  # Old format
        ]
        del data["collection"]["cards"]
    
    # Update version number
    data["version"] = new_version
    return data
```

---

## 5.4 Performance Targets

### 5.4.1 Frame Rate

**Target Frame Rates:**
```yaml
Mobile (iOS/Android):
  - Target: 60 FPS (16.67ms per frame)
  - Minimum: 30 FPS (33.33ms per frame)
  - Vsync: Enabled (prevent tearing)

PC:
  - Target: 120 FPS (8.33ms per frame)
  - Minimum: 60 FPS (16.67ms per frame)
  - Vsync: Optional (player choice)

Profiling Targets:
  - Game Logic: <5ms per frame
  - Rendering: <10ms per frame
  - UI Updates: <2ms per frame
  - Asset Loading: Asynchronous (non-blocking)
```

**Frame Time Budget:**
```
┌─────────────────────────────┐
│ Frame (16.67ms @ 60 FPS)    │
├─────────────────────────────┤
│ Input Processing    1ms     │
│ Game Logic          5ms     │
│ Animation Updates   3ms     │
│ Rendering           10ms    │
│ Audio Mixing        1ms     │
│ Buffer              0.67ms  │ ← Headroom for spikes
└─────────────────────────────┘
```

### 5.4.2 Memory Usage

**Memory Budget (Mobile):**
```yaml
Total App Memory (iOS/Android):
  - Minimum Device (2GB RAM): <300 MB
  - Target Device (4GB RAM): <500 MB
  - Premium Device (6GB+ RAM): <800 MB

Breakdown:
  - Code + Engine: 50-80 MB
  - Textures (Cards): 100-150 MB (compressed)
  - Audio: 20-30 MB (streamed)
  - UI Assets: 30-50 MB
  - Runtime Data: 50-100 MB
  - Buffer/Headroom: 50 MB

Optimization:
  - Use texture atlases (reduce draw calls)
  - Stream audio (don't load all at once)
  - Unload unused assets (aggressive GC)
  - Compress textures (ASTC/ETC2 for mobile)
```

**Texture Compression:**
```yaml
Card Textures:
  - Resolution: 512×716px (thumbnail), 1024×1433px (full)
  - Format: PNG (source), ASTC (mobile), BC7 (PC)
  - Mipmap Levels: 4 (for smooth scaling)
  - Estimated Size: 1 MB per card (compressed)

Background Textures:
  - Resolution: 2048×2048px (parallax layers)
  - Format: JPEG (lossy, acceptable for BG)
  - Estimated Size: 500 KB per layer

UI Sprites:
  - Atlas Size: 2048×2048px (all UI in one texture)
  - Format: PNG with alpha
  - Estimated Size: 2 MB (all UI)
```

### 5.4.3 Load Times

**Cold Start (App Launch):**
```yaml
Target: <3 seconds (from tap to playable)

Breakdown:
  - Engine Init: 500ms
  - Load Core Assets: 1,000ms
  - Load Save Data: 200ms
  - Initialize UI: 500ms
  - Splash Screen: 800ms (GeekBrox logo)
  Total: 3,000ms

Optimization:
  - Lazy load non-critical assets
  - Compress save files
  - Use lightweight splash screen
  - Preload on app install (iOS)
```

**Screen Transitions:**
```yaml
Target: <300ms (seamless feel)

Examples:
  - Lobby → Deck Builder: 200ms (fade)
  - Deck Builder → Run: 400ms (slide + load path)
  - Combat → Victory Screen: 2,000ms (includes animation)
  - Any Screen → Settings: 150ms (modal popup)

Optimization:
  - Preload next screen assets
  - Use GPU-accelerated transitions
  - Minimize layout recalculations
```

### 5.4.4 Battery Consumption

**Power Efficiency (Mobile):**
```yaml
Target: <5% battery per hour (idle mode)
         <15% battery per hour (active play)

Strategies:
  - Reduce frame rate when idle (30 FPS)
  - Disable animations when backgrounded
  - Use low-power GPU mode
  - Throttle update loops
  - Batch network requests

Power Modes:
  High Performance:
    - 60 FPS always
    - Full particle effects
    - High-res textures
    - Battery: ~20%/hour
  
  Balanced (Default):
    - 60 FPS in combat, 30 FPS in menus
    - Medium particle effects
    - Medium-res textures
    - Battery: ~15%/hour
  
  Power Saver:
    - 30 FPS always
    - Minimal particles
    - Low-res textures
    - Battery: ~10%/hour
```

### 5.4.5 Network Performance (Optional)

**Cloud Save Sync:**
```yaml
Upload Size: ~50 KB (compressed save file)
Download Size: ~50 KB
Frequency: Every 5 minutes (when connected)
Timeout: 10 seconds (then fallback to local)

Leaderboard Sync:
Upload Size: ~1 KB (single score entry)
Download Size: ~10 KB (top 100 entries)
Frequency: On run complete (manual trigger)

Analytics:
Batch Size: ~5 KB (10 events)
Frequency: Every 30 seconds or on app background
Timeout: 5 seconds (drop if network slow)
```

---

# 6. Development Milestones

## 6.1 Phase 1: Core Prototype (Weeks 1-4)

### Week 1: Foundation

**Goals:**
- Set up project structure
- Implement basic combat loop
- Create 10 starter cards

**Deliverables:**
```yaml
Code:
  - ✅ Project setup (Unity/Godot)
  - ✅ Card data structure (JSON)
  - ✅ Combat state machine
  - ✅ Basic AI (attack every turn)

Content:
  - ✅ 10 cards (5 Attack, 3 Defense, 2 Collection)
  - ✅ 3 basic enemies (Dream Wisp, Sleepy Shadow, Shadow Whisper)
  - ✅ 1 Dreamer (Serenity, Easy mode)

UI:
  - ✅ Combat screen (placeholder art)
  - ✅ Hand display (5 cards)
  - ✅ HP/Energy display

Testing:
  - ✅ Combat playable start-to-finish
  - ✅ 1 full run (10 nodes) completable
```

### Week 2: Card System

**Goals:**
- Expand card pool to 30
- Implement card effects
- Add synergy system

**Deliverables:**
```yaml
Code:
  - ✅ Card effect system (damage, block, reveries)
  - ✅ Synergy tag matching
  - ✅ Card upgrade system

Content:
  - ✅ 30 cards total (Attack, Defense, Collection, Synergy)
  - ✅ 5 enemies (add Memory Nibbler, Anxious Echo)
  - ✅ 3 event cards

UI:
  - ✅ Card tooltips (long-press details)
  - ✅ Synergy visual indicators
  - ✅ Upgrade button

Testing:
  - ✅ All 30 cards playable
  - ✅ Synergies trigger correctly
  - ✅ Upgrades persist
```

### Week 3: Deckbuilding

**Goals:**
- Implement deck builder screen
- Add card acquisition system
- Create starting deck selection

**Deliverables:**
```yaml
Code:
  - ✅ Deck builder UI
  - ✅ Card collection system
  - ✅ Deck validation (8-12 cards, max 3 copies)

Content:
  - ✅ 50 cards total (expanded pool)
  - ✅ 8 enemies (add 3 mid-game enemies)
  - ✅ 5 event cards

UI:
  - ✅ Deck builder screen (filter, sort, search)
  - ✅ Card grid (3-column layout)
  - ✅ Current deck display

Testing:
  - ✅ Deck builder UX smooth
  - ✅ Card unlocks work
  - ✅ Different deck archetypes viable
```

### Week 4: Meta-Game System (Tarot Cards)

**Goals:**
- Implement Dream Linking system (3-block tarot cards)
- Add Energy system
- Create Dream Home UI

**Deliverables:**
```yaml
Code:
  - ✅ Dream Card data structure (JSON)
  - ✅ 3-block dream system (draw, match, complete)
  - ✅ Energy manager (regen, consume, IAP hooks)
  - ✅ Dream-to-Combat transition logic

Content:
  - ✅ 10 Dream Series (Common tier)
  - ✅ 30 Dream Cards total (10 series × 3 stages)
  - ✅ 5 event cards (integrated with dream triggers)
  - ✅ 1 boss enemy (Dream Eater)

UI:
  - ✅ Dream Home screen (tarot card display)
  - ✅ Energy display (top bar, animated)
  - ✅ Card reveal animation (flip + glow)
  - ✅ Vortex transition (Dream Home ↔ Combat)
  - ✅ Dream History stack (scrollable)

Testing:
  - ✅ Perfect Dream achievable (30% rate)
  - ✅ Broken Dream functional (fallback rewards)
  - ✅ Energy system balanced (3 dreams/day free)
  - ✅ Progression loop complete: Dream → Combat → Rewards
  - ✅ Rewards feel fair
  - ✅ Progression satisfying
```

---

## 6.2 Phase 2: Alpha (Weeks 5-8)

### Week 5-6: Content Expansion

**Goals:**
- Expand to 85 cards (full set)
- Add 34 enemies (full bestiary)
- Implement 5 Dreamers

**Deliverables:**
```yaml
Content:
  - ✅ 85 cards (all rarities)
  - ✅ 14 basic enemies
  - ✅ 10 elite enemies
  - ✅ 10 boss enemies
  - ✅ 5 Dreamers (Serenity, Anxiety, Fear, Nostalgia, Lucid)
  - ✅ 10 event cards

Balance:
  - ✅ Card stat balance pass
  - ✅ Enemy HP/Attack scaling
  - ✅ Reward tuning

Testing:
  - ✅ 20+ playtest runs
  - ✅ All cards tested
  - ✅ All enemies tested
```

### Week 7: Idle System & Auto-Battle

**Goals:**
- Implement offline dream progression
- Add Auto-Battle AI (3 strategies)
- Create push notifications

**Deliverables:**
```yaml
Code:
  - ✅ Offline time tracking (8-hour cap)
  - ✅ Automatic dream playing (uses energy)
  - ✅ Auto-Battle AI:
    - Aggressive mode (high damage priority)
    - Defensive mode (survival priority)
    - Balanced mode (adaptive)
  - ✅ Notification system (iOS/Android)

UI:
  - ✅ Offline reward popup (animated count-up)
  - ✅ Auto-Battle settings screen:
    - Strategy selector (3 modes)
    - Preview combat simulation
    - Toggle auto-battle on/off
  - ✅ Idle optimization tips (deck suggestions)
  - ✅ Notification settings

Content:
  - ✅ Auto-Battle card priority database
  - ✅ AI decision trees (per strategy)

Testing:
  - ✅ Offline rewards accurate (energy consumption)
  - ✅ Auto-Battle win rates:
    - Aggressive: 60% (fast, risky)
    - Defensive: 80% (slow, safe)
    - Balanced: 70% (medium)
  - ✅ Idle balancing (not too fast/slow)
  - ✅ Notifications work (8h cap reminder)
```

### Week 8: Prestige System

**Goals:**
- Implement prestige/ascension
- Add Dream Shard currency
- Create prestige bonus tree

**Deliverables:**
```yaml
Code:
  - ✅ Prestige trigger (10k Reveries)
  - ✅ Dream Shard calculation
  - ✅ Prestige bonus application

Content:
  - ✅ 20 prestige bonuses (4 tiers)
  - ✅ Prestige UI screen

Testing:
  - ✅ Prestige loop satisfying
  - ✅ Bonuses impactful
  - ✅ No exploits
```

---

## 6.3 Phase 3: Beta (Weeks 9-12)

### Week 9-10: Polish

**Goals:**
- Full art pass (cards, enemies, UI)
- Audio implementation
- Animation polish

**Deliverables:**
```yaml
Art:
  - ✅ 85 card illustrations (final)
  - ✅ 34 enemy portraits (final)
  - ✅ UI sprites (all screens)
  - ✅ Background art (5 themes)

Audio:
  - ✅ Music tracks (menu, combat, victory, defeat)
  - ✅ SFX (50+ sounds)
  - ✅ Audio mixing

Animation:
  - ✅ Card play animations
  - ✅ Enemy attack animations
  - ✅ Victory/defeat cinematics

Testing:
  - ✅ Visual quality check
  - ✅ Audio balance
  - ✅ Animation timing
```

### Week 11: Monetization

**Goals:**
- Implement IAP system
- Add ad integration
- Create shop UI

**Deliverables:**
```yaml
Code:
  - ✅ IAP backend (Apple/Google)
  - ✅ Ad SDK integration (Unity Ads)
  - ✅ Purchase verification

Content:
  - ✅ Shop items (card packs, cosmetics, boosters)
  - ✅ Ad placements (optional rewards)
  - ✅ Battle pass (optional)

Testing:
  - ✅ Purchases work (sandbox)
  - ✅ Ads don't break game
  - ✅ Pricing fair
```

### Week 12: QA & Balancing

**Goals:**
- Bug fixing
- Balance tuning
- Performance optimization

**Deliverables:**
```yaml
QA:
  - ✅ 100+ bug reports processed
  - ✅ Crash-free rate >99%
  - ✅ Memory leaks fixed

Balance:
  - ✅ Win rates in target range
  - ✅ Economic balance verified
  - ✅ Card usage diversity

Performance:
  - ✅ 60 FPS on target devices
  - ✅ <300 MB memory usage
  - ✅ <3s load time
```

---

## 6.4 Phase 4: Launch (Weeks 13-16)

### Week 13-14: Beta Testing

**Goals:**
- Closed beta (TestFlight / Play Beta)
- Collect metrics
- Iterate based on feedback

**Activities:**
```yaml
Beta:
  - ✅ 100-500 beta testers
  - ✅ Feedback surveys
  - ✅ Analytics dashboard

Metrics:
  - Day 1 Retention: Target 50%
  - Day 7 Retention: Target 20%
  - Session Length: Target 20 min
  - IAP Conversion: Target 5%

Iteration:
  - ✅ Balance tweaks based on data
  - ✅ UI improvements from feedback
  - ✅ Bug fixes
```

### Week 15: Soft Launch

**Goals:**
- Launch in 1-2 test markets
- Monitor KPIs
- Prepare marketing materials

**Activities:**
```yaml
Soft Launch:
  - ✅ Release in Canada, Australia (test markets)
  - ✅ Monitor crash rate (<0.1%)
  - ✅ Monitor retention (Day 7 >20%)

Marketing:
  - ✅ App Store assets (screenshots, video)
  - ✅ Press kit (for reviewers)
  - ✅ Social media accounts (Twitter, Discord)

Preparation:
  - ✅ Scale backend (if using cloud)
  - ✅ Customer support ready
  - ✅ Community management
```

### Week 16: Global Launch

**Goals:**
- Launch worldwide
- Marketing push
- Post-launch support

**Activities:**
```yaml
Launch:
  - ✅ iOS App Store release
  - ✅ Google Play Store release
  - ✅ Steam release (PC, optional)

Marketing:
  - ✅ Launch trailer
  - ✅ Influencer outreach
  - ✅ Press release

Post-Launch:
  - ✅ Monitor reviews
  - ✅ Hotfix any critical bugs
  - ✅ Community engagement
  - ✅ First content update (2 weeks post-launch)
```

---

## 6.5 Post-Launch Roadmap (Months 2-6)

**Month 2:**
```yaml
Content Update 1:
  - 20 new cards
  - 5 new enemies
  - 1 new Dreamer
  - New event cards
```

**Month 3:**
```yaml
Feature Update:
  - PvP mode (asynchronous)
  - Daily challenges
  - Leaderboards
```

**Month 4:**
```yaml
Content Update 2:
  - 30 new cards
  - 10 new enemies
  - New prestige tier
  - Boss rush mode
```

**Month 5:**
```yaml
Feature Update:
  - Guild system
  - Co-op mode (2-player)
  - Custom deck sharing
```

**Month 6:**
```yaml
Expansion Pack:
  - New theme: "Lucid Nightmares"
  - 50 new cards
  - 20 new enemies
  - 3 new Dreamers
  - New game mode
```

---

# Document Completion

## Summary

This **Detailed Design Document** provides implementation-ready specifications for Dream Collector across 6 major areas:

1. ✅ **Game Systems Design** - Combat, deckbuilding, progression, resources, idle
2. ✅ **Content Specification** - 85 cards, 34 monsters, dungeon structure, rewards
3. ✅ **Balance System** - Difficulty curves, economy, card balance, progression speed
4. ✅ **UI/UX Flow** - Screen layouts, combat UI, input, feedback
5. ✅ **Technical Specification** - Platforms, data structures, save system, performance
6. ✅ **Development Milestones** - 4-phase roadmap from prototype to launch

**Next Steps:**
1. Review this document with Steve (Project Manager)
2. Begin Phase 1: Core Prototype (Week 1)
3. Set up version control (Git) and project management (Trello/Jira)
4. Recruit team (if needed): Artist, Sound Designer, QA Tester

**Document Status:** ✅ **COMPLETE**  
**Ready for:** Development Team Review → Implementation

---

_Dream Collector - Detailed Design Document v1.0_  
_© GeekBrox 2026_  
_Compiled by: AI Game Design Assistant_  
_Date: February 23, 2026_
