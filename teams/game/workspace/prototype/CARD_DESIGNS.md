# Dream Collector - Card Designs
**Version:** 1.0  
**Date:** February 23, 2026  
**Total Cards:** 85 cards

---

## 📋 Card Index

| Category | Count | Range |
|----------|-------|-------|
| **Attack Cards** | 18 | #001-#018 |
| **Defense Cards** | 12 | #019-#030 |
| **Collection Cards** | 16 | #031-#046 |
| **Synergy Cards** | 15 | #047-#061 |
| **Enemy Cards** | 14 | #062-#075 |
| **Boss Cards** | 10 | #076-#085 |
| **Total** | **85** | |

---

## 🗡️ Attack Cards (18)

### Basic Tier (Common)

#### #001 - Basic Strike
```yaml
Name: Basic Strike
Type: Action (Attack)
Rarity: Common
Cost: 1 Energy
Effect: Deal 5 damage to target enemy
Flavor: "The simplest dreams cut deepest."
Upgrade Path: → Strong Strike (8 damage)
```

#### #002 - Double Tap
```yaml
Name: Double Tap
Type: Action (Attack)
Rarity: Common
Cost: 2 Energy
Effect: Deal 3 damage twice (total 6)
Flavor: "Once for the dream, twice for the memory."
Synergy: Triggers twice for combo effects
```

#### #003 - Quick Slash
```yaml
Name: Quick Slash
Type: Action (Attack)
Rarity: Common
Cost: 0 Energy
Effect: Deal 3 damage
Flavor: "Speed over strength."
```

#### #004 - Heavy Blow
```yaml
Name: Heavy Blow
Type: Action (Attack)
Rarity: Common
Cost: 3 Energy
Effect: Deal 12 damage
Drawback: Discard 1 card
Flavor: "Power demands sacrifice."
```

### Intermediate Tier (Uncommon)

#### #005 - Lucid Strike
```yaml
Name: Lucid Strike
Type: Action (Attack)
Rarity: Uncommon
Cost: 2 Energy
Effect: Deal 10 damage
Bonus: If enemy HP < 50%, deal +5 damage
Flavor: "Clarity brings precision."
```

#### #006 - Chain Lightning
```yaml
Name: Chain Lightning
Type: Action (Attack)
Rarity: Uncommon
Cost: 2 Energy
Effect: Deal 6 damage. If this kills the enemy, gain 2 Energy.
Flavor: "From one dream to the next."
```

#### #007 - Nightmare Blade
```yaml
Name: Nightmare Blade
Type: Action (Attack)
Rarity: Uncommon
Cost: 2 Energy
Effect: Deal 8 damage. Gain +2 damage for each Nightmare card in your hand.
Flavor: "Fear sharpens the blade."
Synergy: Nightmare theme
```

#### #008 - Dream Shatter
```yaml
Name: Dream Shatter
Type: Action (Attack)
Rarity: Uncommon
Cost: 3 Energy
Effect: Deal 15 damage. Cannot be blocked.
Flavor: "Some dreams cannot be defended."
```

#### #009 - Echo Strike
```yaml
Name: Echo Strike
Type: Action (Attack)
Rarity: Uncommon
Cost: 1 Energy
Effect: Deal 4 damage. Repeat this attack next turn (free).
Flavor: "Reverberations through the dreamscape."
```

### Advanced Tier (Rare)

#### #010 - Void Spear
```yaml
Name: Void Spear
Type: Action (Attack)
Rarity: Rare
Cost: 2 Energy
Effect: Deal 10 damage. Enemy loses 1 Energy next turn.
Flavor: "Drain the dream's essence."
```

#### #011 - Reality Break
```yaml
Name: Reality Break
Type: Action (Attack)
Rarity: Rare
Cost: 3 Energy
Effect: Deal damage equal to 2× your current Energy.
Example: If you have 5 Energy, deal 10 damage
Flavor: "Bend the rules of existence."
```

#### #012 - Dream Cascade
```yaml
Name: Dream Cascade
Type: Action (Attack)
Rarity: Rare
Cost: 2 Energy
Effect: Deal 5 damage. For each Attack card played this turn, deal +3 damage.
Flavor: "Momentum builds with each strike."
Combo Synergy: Play after other attacks
```

### Elite Tier (Epic)

#### #013 - Lucid Nova
```yaml
Name: Lucid Nova
Type: Action (Attack)
Rarity: Epic
Cost: 3 Energy
Effect: Deal 20 damage to target enemy. Gain 1 card draw.
Flavor: "The brightest dreams burn away all shadows."
```

#### #014 - Nightmare King's Wrath
```yaml
Name: Nightmare King's Wrath
Type: Action (Attack)
Rarity: Epic
Cost: 4 Energy
Effect: Deal 30 damage. Costs 1 less Energy for each Nightmare card in play.
Flavor: "The throne of fear knows no mercy."
Synergy: Nightmare deck archetype
```

#### #015 - Oblivion Strike
```yaml
Name: Oblivion Strike
Type: Action (Attack)
Rarity: Epic
Cost: 5 Energy
Effect: Deal 40 damage. Remove this card from the game after use.
Flavor: "Ultimate power, ultimate cost."
One-shot: Use wisely
```

### Legendary Tier

#### #016 - Dream Ender
```yaml
Name: Dream Ender
Type: Action (Attack)
Rarity: Legendary
Cost: 3 Energy
Effect: Deal damage equal to target's missing HP (execute)
Example: Enemy at 10/30 HP → Deal 20 damage
Flavor: "Finish what you started."
Finisher: Best used on low-HP enemies
```

#### #017 - Infinity Edge
```yaml
Name: Infinity Edge
Type: Action (Attack)
Rarity: Legendary
Cost: 2 Energy
Effect: Deal 8 damage. Permanently gain +1 damage each time played.
Scaling: Gets stronger over time
Flavor: "Every cut leaves a deeper scar."
```

#### #018 - Apocalypse Dream
```yaml
Name: Apocalypse Dream
Type: Action (Attack)
Rarity: Legendary
Cost: X Energy (variable)
Effect: Deal 10 damage per Energy spent.
Example: Spend 3 Energy → 30 damage
Flavor: "The end of all dreams."
```

---

## 🛡️ Defense Cards (12)

### Basic Tier (Common)

#### #019 - Dream Shield
```yaml
Name: Dream Shield
Type: Defense
Rarity: Common
Cost: 1 Energy
Effect: Block 8 damage
Instant: Can be played outside your turn
Flavor: "Protect the fragile sleep."
```

#### #020 - Mist Barrier
```yaml
Name: Mist Barrier
Type: Defense
Rarity: Common
Cost: 0 Energy
Effect: Block 4 damage
Flavor: "The softest fog still obscures."
```

#### #021 - Memory Wall
```yaml
Name: Memory Wall
Type: Defense
Rarity: Common
Cost: 2 Energy
Effect: Block 12 damage
Flavor: "Remember when you felt safe?"
```

### Intermediate Tier (Uncommon)

#### #022 - Ethereal Guard
```yaml
Name: Ethereal Guard
Type: Defense
Rarity: Uncommon
Cost: 1 Energy
Effect: Block 10 damage. If this blocks all damage, gain 1 Energy.
Flavor: "Perfect defense fuels offense."
```

#### #023 - Nightmare Ward
```yaml
Name: Nightmare Ward
Type: Defense (Synergy)
Rarity: Uncommon
Cost: 2 Energy
Effect: Block 8 damage.
Combo: If you have [Fear Essence] in play, block 16 instead.
Flavor: "Face your fears to conquer them."
```

#### #024 - Phase Shift
```yaml
Name: Phase Shift
Type: Defense
Rarity: Uncommon
Cost: 1 Energy
Effect: Block all damage this turn. Discard 1 card.
Flavor: "Exist between moments."
```

#### #025 - Reflection
```yaml
Name: Reflection
Type: Defense
Rarity: Uncommon
Cost: 2 Energy
Effect: Block 8 damage. Deal 50% of blocked damage back to attacker.
Flavor: "Your nightmare reflects upon you."
```

### Advanced Tier (Rare)

#### #026 - Lucid Barrier
```yaml
Name: Lucid Barrier
Type: Defense
Rarity: Rare
Cost: 2 Energy
Effect: Block 15 damage. If excess block remains, convert to HP healing.
Example: Block 15, take 8 damage → Heal 7 HP
Flavor: "Waste nothing."
```

#### #027 - Time Freeze
```yaml
Name: Time Freeze
Type: Defense
Rarity: Rare
Cost: 3 Energy
Effect: Block all damage this turn. Skip enemy's next turn.
Flavor: "Stop the dream in its tracks."
```

#### #028 - Immortal Sleep
```yaml
Name: Immortal Sleep
Type: Defense
Rarity: Rare
Cost: 1 Energy
Effect: Block 10 damage. Permanently gain +2 block each time played.
Scaling: Gets stronger over time
Flavor: "Each rest brings deeper peace."
```

### Elite Tier (Epic)

#### #029 - Sanctuary
```yaml
Name: Sanctuary
Type: Defense
Rarity: Epic
Cost: 3 Energy
Effect: Block 20 damage. Heal 5 HP. Gain 1 Energy next turn.
Flavor: "A safe haven in chaos."
Multi-utility: Best defensive card
```

#### #030 - Absolute Shield
```yaml
Name: Absolute Shield
Type: Defense
Rarity: Epic
Cost: 4 Energy
Effect: Block all damage for 2 turns. Cannot play Attack cards during this time.
Trade-off: Safety vs. offense
Flavor: "Ultimate protection, ultimate stillness."
```

---

## 💰 Collection Cards (16)

### Basic Tier (Common)

#### #031 - Memory Shard
```yaml
Name: Memory Shard
Type: Collection (Passive)
Rarity: Common
Cost: 1 Energy
Effect: Gain +2 Reveries at each Memory Node (○)
Duration: Permanent (this run)
Flavor: "Every fragment tells a story."
```

#### #032 - Dream Dust
```yaml
Name: Dream Dust
Type: Collection (Passive)
Rarity: Common
Cost: 1 Energy
Effect: Gain +5 Reveries per turn (passive income)
Flavor: "The smallest grains build mountains."
```

#### #033 - Reverie Burst
```yaml
Name: Reverie Burst
Type: Action (Collection)
Rarity: Common
Cost: 1 Energy
Effect: Gain 10 Reveries instantly
Flavor: "Quick collection for the impatient."
```

#### #034 - Sleep Essence
```yaml
Name: Sleep Essence
Type: Collection (Passive)
Rarity: Common
Cost: 2 Energy
Effect: Gain +3 Reveries per turn. +1 bonus at Memory Nodes.
Flavor: "Deep sleep yields richer dreams."
```

### Intermediate Tier (Uncommon)

#### #035 - Lucid Harvest
```yaml
Name: Lucid Harvest
Type: Action (Collection)
Rarity: Uncommon
Cost: 2 Energy
Effect: Gain 20 Reveries. If at Memory Node, gain 30 instead.
Flavor: "Clarity maximizes collection."
```

#### #036 - Dream Weaver
```yaml
Name: Dream Weaver
Type: Collection (Passive)
Rarity: Uncommon
Cost: 2 Energy
Effect: Gain +10 Reveries per turn. Bonus: +2 per Collection card in play.
Synergy: Collection deck archetype
Flavor: "Weave threads of many dreams."
```

#### #037 - Memory Echo
```yaml
Name: Memory Echo
Type: Collection (Passive)
Rarity: Uncommon
Cost: 1 Energy
Effect: Whenever you collect Reveries from any source, gain +20%.
Multiplier: Stacks with other bonuses
Flavor: "Echoes magnify."
```

#### #038 - Idle Dream
```yaml
Name: Idle Dream
Type: Collection (Passive)
Rarity: Uncommon
Cost: 3 Energy
Effect: Gain +15 Reveries per turn. Effect persists even after this run ends.
Meta-progression: Permanent bonus
Flavor: "Dreams that never end."
```

### Advanced Tier (Rare)

#### #039 - Nightmare Harvest
```yaml
Name: Nightmare Harvest
Type: Action (Collection)
Rarity: Rare
Cost: 2 Energy
Effect: Gain 5 Reveries per enemy defeated this run.
Scaling: Rewards aggressive play
Flavor: "Fear is a resource."
```

#### #040 - Compound Interest
```yaml
Name: Compound Interest
Type: Collection (Passive)
Rarity: Rare
Cost: 3 Energy
Effect: At the end of each turn, gain Reveries equal to 10% of your total Reveries.
Exponential: Gets stronger the more you have
Flavor: "Wealth begets wealth."
```

#### #041 - Dream Factory
```yaml
Name: Dream Factory
Type: Collection (Passive)
Rarity: Rare
Cost: 2 Energy
Effect: Gain +5 Reveries per turn per Collection card you have played.
Example: 3 Collection cards in play → +15 Reveries/turn
Synergy: Collection deck archetype
Flavor: "Industrialize your dreams."
```

### Elite Tier (Epic)

#### #042 - Golden Sleep
```yaml
Name: Golden Sleep
Type: Collection (Passive)
Rarity: Epic
Cost: 4 Energy
Effect: Gain +30 Reveries per turn. Double all Reveries from Memory Nodes.
Flavor: "The richest dreams are golden."
```

#### #043 - Infinity Well
```yaml
Name: Infinity Well
Type: Collection (Passive)
Rarity: Epic
Cost: 3 Energy
Effect: Gain +1 Reverie per turn. Permanently increase this by +1 each turn.
Scaling: Turn 1 → +1, Turn 2 → +2, Turn 3 → +3, etc.
Flavor: "The well never runs dry."
```

### Legendary Tier

#### #044 - Collector's Greed
```yaml
Name: Collector's Greed
Type: Collection (Passive)
Rarity: Legendary
Cost: 5 Energy
Effect: Triple all Reverie income from all sources.
Trade-off: High cost, massive payoff
Flavor: "More. Always more."
```

#### #045 - Eternal Dream
```yaml
Name: Eternal Dream
Type: Collection (Passive)
Rarity: Legendary
Cost: 3 Energy
Effect: Gain +20 Reveries per turn. After this run ends, gain +10 Reveries per turn in ALL future runs.
Meta-progression: Permanent bonus
Flavor: "A gift that keeps giving."
```

#### #046 - Dream Monopoly
```yaml
Name: Dream Monopoly
Type: Collection (Passive)
Rarity: Legendary
Cost: 4 Energy
Effect: All Memory Nodes now give 3× Reveries. You cannot gain Reveries from Combat.
Trade-off: Pacifist strategy
Flavor: "Own all dreams."
```

---

## 🔗 Synergy Cards (15)

### Nightmare Theme (5 cards)

#### #047 - Fear Essence
```yaml
Name: Fear Essence
Type: Synergy (Passive)
Rarity: Uncommon
Cost: 2 Energy
Effect: All Nightmare-tagged cards cost 1 less Energy.
Enabler: Play this first
Flavor: "Embrace the darkness."
```

#### #048 - Shadow Step
```yaml
Name: Shadow Step
Type: Synergy (Action)
Rarity: Uncommon
Cost: 1 Energy
Effect: Deal 5 damage. If [Fear Essence] is in play, deal 10 instead.
Combo: Nightmare theme
Flavor: "Move through shadows."
```

#### #049 - Terror Wave
```yaml
Name: Terror Wave
Type: Synergy (Action)
Rarity: Rare
Cost: 3 Energy
Effect: Deal 8 damage. For each Nightmare card in your hand, deal +3 damage.
Combo: Hold Nightmare cards for big burst
Flavor: "Let fear cascade."
```

#### #050 - Nightmare King
```yaml
Name: Nightmare King
Type: Synergy (Passive)
Rarity: Epic
Cost: 4 Energy
Effect: All Nightmare cards gain +5 damage/block/Reveries.
Payoff: Ultimate Nightmare synergy
Flavor: "Rule the dark."
```

#### #051 - Phobia
```yaml
Name: Phobia
Type: Synergy (Action)
Rarity: Rare
Cost: 2 Energy
Effect: Deal 12 damage. If you have 3+ Nightmare cards in play, stun enemy for 1 turn.
Combo: Nightmare control
Flavor: "Paralyze with pure fear."
```

### Memory Theme (5 cards)

#### #052 - Nostalgia
```yaml
Name: Nostalgia
Type: Synergy (Passive)
Rarity: Uncommon
Cost: 2 Energy
Effect: Memory Nodes now also draw 1 card.
Utility: Card advantage
Flavor: "Remember the good times."
```

#### #053 - Déjà Vu
```yaml
Name: Déjà Vu
Type: Synergy (Action)
Rarity: Uncommon
Cost: 1 Energy
Effect: Play the last card you played this turn again (for free).
Combo: Double powerful effects
Flavor: "Haven't I been here before?"
```

#### #054 - Memory Lane
```yaml
Name: Memory Lane
Type: Synergy (Passive)
Rarity: Rare
Cost: 2 Energy
Effect: Whenever you play a Memory-tagged card, gain 5 Reveries.
Payoff: Memory theme
Flavor: "Walk down familiar paths."
```

#### #055 - Perfect Recall
```yaml
Name: Perfect Recall
Type: Synergy (Action)
Rarity: Rare
Cost: 3 Energy
Effect: Draw 3 cards. If you have 3+ Memory cards in play, draw 5 instead.
Combo: Memory card draw engine
Flavor: "Remember everything."
```

#### #056 - Timeless
```yaml
Name: Timeless
Type: Synergy (Passive)
Rarity: Epic
Cost: 3 Energy
Effect: All Memory cards you play are permanently active (never discarded).
Payoff: Memory persistence
Flavor: "Some memories never fade."
```

### Lucid Theme (5 cards)

#### #057 - Lucid Awakening
```yaml
Name: Lucid Awakening
Type: Synergy (Passive)
Rarity: Uncommon
Cost: 1 Energy
Effect: Gain +1 Energy per turn. Bonus: +1 more if you have 3+ Lucid cards.
Enabler: Lucid theme
Flavor: "Awareness brings power."
```

#### #058 - Reality Bender
```yaml
Name: Reality Bender
Type: Synergy (Action)
Rarity: Rare
Cost: 2 Energy
Effect: Change target enemy's Attack to 0 this turn. If [Lucid Awakening] in play, also block 10.
Combo: Lucid control
Flavor: "Control the dream."
```

#### #059 - Dream Logic
```yaml
Name: Dream Logic
Type: Synergy (Passive)
Rarity: Rare
Cost: 2 Energy
Effect: Your hand size limit is now 7 (instead of 5).
Utility: Lucid card advantage
Flavor: "Impossible rules for impossible worlds."
```

#### #060 - Hyper Awareness
```yaml
Name: Hyper Awareness
Type: Synergy (Action)
Rarity: Epic
Cost: 3 Energy
Effect: Draw 2 cards. Gain 2 Energy. If you have 3+ Lucid cards, double these effects.
Combo: Lucid value engine
Flavor: "See everything, control everything."
```

#### #061 - God Mode
```yaml
Name: God Mode
Type: Synergy (Passive)
Rarity: Legendary
Cost: 5 Energy
Effect: All cards cost 1 less Energy (minimum 0). You cannot lose HP this run.
Payoff: Ultimate Lucid power
Flavor: "The lucid dreamer is invincible."
```

---

## 👹 Enemy Cards (14)

### Basic Enemies (Common)

#### #062 - Shadow Whisper
```yaml
Name: Shadow Whisper
Type: Enemy
Rarity: Common
HP: 10
Attack: 2 per turn
Pattern: Attacks every turn
Reward: 15 Reveries
Flavor: "Soft voices in the dark."
```

#### #063 - Dream Nibbler
```yaml
Name: Dream Nibbler
Type: Enemy
Rarity: Common
HP: 8
Attack: 3 per turn
Pattern: Attacks every turn, low HP
Reward: 20 Reveries
Flavor: "Tiny teeth, constant gnawing."
```

#### #064 - Forgotten Memory
```yaml
Name: Forgotten Memory
Type: Enemy
Rarity: Common
HP: 12
Attack: 2 per turn
Special: Heals 1 HP per turn
Reward: 25 Reveries + 1 Memory card
Flavor: "What was I trying to remember?"
```

### Intermediate Enemies (Uncommon)

#### #065 - Shadow Fiend
```yaml
Name: Shadow Fiend
Type: Enemy
Rarity: Uncommon
HP: 15
Attack: 3 per turn
Special: +1 Attack each turn (stacking)
Reward: 30 Reveries
Flavor: "It grows stronger in darkness."
```

#### #066 - Anxiety Spiral
```yaml
Name: Anxiety Spiral
Type: Enemy
Rarity: Uncommon
HP: 20
Attack: 1-5 (random each turn)
Special: Unpredictable damage
Reward: 35 Reveries
Flavor: "You never know what to expect."
```

#### #067 - Regret Echo
```yaml
Name: Regret Echo
Type: Enemy
Rarity: Uncommon
HP: 18
Attack: 4 per turn
Special: If you block, it attacks again
Reward: 40 Reveries
Flavor: "Defending only delays the inevitable."
```

#### #068 - Lucid Stalker
```yaml
Name: Lucid Stalker
Type: Enemy
Rarity: Uncommon
HP: 22
Attack: 3 per turn
Special: Drains 1 Energy per turn
Reward: 45 Reveries + 1 card
Flavor: "It feeds on your awareness."
```

### Advanced Enemies (Rare)

#### #069 - Nightmare Hound
```yaml
Name: Nightmare Hound
Type: Enemy
Rarity: Rare
HP: 25
Attack: 5 per turn
Special: If HP < 50%, Attack becomes 8
Reward: 60 Reveries + 1 Nightmare card
Flavor: "Wounded beasts are most dangerous."
```

#### #070 - Memory Thief
```yaml
Name: Memory Thief
Type: Enemy
Rarity: Rare
HP: 20
Attack: 3 per turn
Special: When you play a card, deal 2 bonus damage
Reward: 50 Reveries
Flavor: "Every action hurts you."
```

#### #071 - Dream Parasite
```yaml
Name: Dream Parasite
Type: Enemy
Rarity: Rare
HP: 30
Attack: 2 per turn
Special: Steals 5 Reveries per turn
Reward: 80 Reveries (includes stolen amount)
Flavor: "It grows fat on your dreams."
```

### Elite Enemies (Epic)

#### #072 - Void Wraith
```yaml
Name: Void Wraith
Type: Enemy (Elite)
Rarity: Epic
HP: 35
Attack: 6 per turn
Special: Immune to first 10 damage each turn
Reward: 100 Reveries + 2 cards
Flavor: "Existence means nothing to the void."
```

#### #073 - Fear Incarnate
```yaml
Name: Fear Incarnate
Type: Enemy (Elite)
Rarity: Epic
HP: 40
Attack: 7 per turn
Special: Cannot be blocked by Defense cards
Reward: 120 Reveries + 1 Epic card
Flavor: "Pure, undiluted terror."
```

#### #074 - Time Devourer
```yaml
Name: Time Devourer
Type: Enemy (Elite)
Rarity: Epic
HP: 50
Attack: 4 per turn
Special: You can only play 1 card per turn
Reward: 150 Reveries + 1 rare card
Flavor: "Time is the ultimate enemy."
```

#### #075 - Lucid Nemesis
```yaml
Name: Lucid Nemesis
Type: Enemy (Elite)
Rarity: Epic
HP: 45
Attack: 5 per turn
Special: Copies one of your cards each turn
Reward: 180 Reveries + 2 rare cards
Flavor: "It learns from you."
```

---

## 👑 Boss Cards (10)

### Tier 1 Bosses (Dreamer Level 1-3)

#### #076 - Dream Eater
```yaml
Name: Dream Eater
Type: Boss
Difficulty: Easy
HP: 40
Attack: 5 per turn
Phase 1 (40-20 HP): Attacks normally
Phase 2 (20-0 HP): Attack becomes 7, drains 1 Energy
Reward: 100 Reveries + 2 rare cards + unlock new Dreamer
Flavor: "It hungers for your dreams."
```

#### #077 - Shadow King
```yaml
Name: Shadow King
Type: Boss
Difficulty: Medium
HP: 50
Attack: 4 per turn
Special Ability (every 3 turns): Summons Shadow Whisper (10 HP, 2 Attack)
Phase Shift (HP < 30%): Becomes immune to damage for 1 turn, then takes double damage next turn
Reward: 150 Reveries + 3 rare cards + [Nightmare King] card
Flavor: "Ruler of the dark realm."
```

#### #078 - Anxiety Titan
```yaml
Name: Anxiety Titan
Type: Boss
Difficulty: Medium
HP: 45
Attack: Varies (1-10 random)
Special: Each turn, roll dice - odd = low damage, even = high damage
Chaos Mode (HP < 50%): Attacks twice per turn
Reward: 180 Reveries + 2 epic cards
Flavor: "Unpredictability incarnate."
```

### Tier 2 Bosses (Dreamer Level 4-6)

#### #079 - Memory Colossus
```yaml
Name: Memory Colossus
Type: Boss
Difficulty: Hard
HP: 60
Attack: 6 per turn
Special: Permanently gains +2 Attack each time you play a Memory card
Counter-play: Avoid Memory cards or burst it quickly
Reward: 200 Reveries + 3 epic cards + [Timeless] synergy card
Flavor: "Built from a thousand forgotten dreams."
```

#### #080 - Lucid Archon
```yaml
Name: Lucid Archon
Type: Boss
Difficulty: Hard
HP: 55
Attack: 5 per turn
Special: Can play your own cards against you (steals 1 card from hand each turn)
Phase 2 (HP < 30%): Gains +2 Energy per turn
Reward: 250 Reveries + 4 epic cards + [God Mode] synergy card
Flavor: "Perfect awareness, perfect control."
```

#### #081 - Nightmare Hydra
```yaml
Name: Nightmare Hydra
Type: Boss
Difficulty: Hard
HP: 70 (split into 3 heads: 25/25/20)
Attack: 3 per head (total 9/turn)
Special: Must defeat all 3 heads. Each head regenerates 5 HP per turn.
Strategy: Focus fire one head at a time
Reward: 300 Reveries + 5 epic cards + [Fear Incarnate] summon card
Flavor: "Cut off one head, two more appear... or do they?"
```

### Tier 3 Bosses (Dreamer Level 7-10)

#### #082 - The Forgotten
```yaml
Name: The Forgotten
Type: Boss (Secret)
Difficulty: Very Hard
HP: 80
Attack: 8 per turn
Special: Every 2 turns, resets your hand (discard all, draw 4)
Phase 2 (HP < 40%): Drains 2 Energy per turn, Attack becomes 10
Reward: 400 Reveries + 6 epic cards + [Eternal Dream] legendary
Flavor: "What was forgotten can never be remembered."
```

#### #083 - Void Sovereign
```yaml
Name: Void Sovereign
Type: Boss (Secret)
Difficulty: Very Hard
HP: 90
Attack: 7 per turn
Special: Immune to damage every other turn (alternating)
Phases:
- Turn 1: Immune (block)
- Turn 2: Vulnerable (attack)
- Repeat
Strategy: Maximize damage on vulnerable turns
Reward: 500 Reveries + 7 epic cards + [Dream Ender] legendary
Flavor: "The absence of everything."
```

#### #084 - Time Breaker
```yaml
Name: Time Breaker
Type: Boss (Secret)
Difficulty: Extreme
HP: 100
Attack: 6 per turn (but attacks 3 times per turn = 18 total!)
Special: You must defeat it within 10 turns or instant loss
Time Pressure: Forces aggressive play
Reward: 600 Reveries + 10 epic cards + [Apocalypse Dream] legendary
Flavor: "Time is not on your side."
```

#### #085 - The Dreamer (Final Boss)
```yaml
Name: The Dreamer
Type: Boss (Final)
Difficulty: Nightmare
HP: 120
Attack: Varies by phase
Phase 1 (120-80 HP): 
  - Attack: 5 per turn
  - Summons minions every 2 turns
Phase 2 (80-40 HP):
  - Attack: 8 per turn
  - Drains 2 Energy per turn
  - Heals 5 HP every 3 turns
Phase 3 (40-0 HP):
  - Attack: 12 per turn
  - Immunity shield (blocks first 20 damage per turn)
  - You can only play 2 cards per turn
Ultimate Challenge: Tests all skills
Reward: 1000 Reveries + ALL remaining locked cards + Secret Ending unlock
Flavor: "You are the dream. The dream is you."
Lore: The final confrontation with your own consciousness
```

---

## 📊 Card Statistics Summary

### By Rarity

| Rarity | Count | Percentage |
|--------|-------|------------|
| Common | 20 | 23.5% |
| Uncommon | 28 | 32.9% |
| Rare | 22 | 25.9% |
| Epic | 12 | 14.1% |
| Legendary | 3 | 3.5% |
| **Total** | **85** | **100%** |

### By Type (Player Cards Only)

| Type | Count |
|------|-------|
| Attack | 18 |
| Defense | 12 |
| Collection | 16 |
| Synergy | 15 |
| **Total** | **61** |

### By Energy Cost (Player Cards)

| Cost | Count |
|------|-------|
| 0 | 3 |
| 1 | 18 |
| 2 | 24 |
| 3 | 12 |
| 4+ | 4 |
| **Total** | **61** |

---

## 🎨 Print-and-Play Template

### Card Dimensions
- **Size:** 63mm × 88mm (poker card size)
- **Print:** 9 cards per A4 sheet (3×3 grid)
- **Sleeves:** Standard card sleeves (MTG/Pokémon size)

### Card Layout Template
```
┌──────────────────────┐
│ [Name]        [Cost] │  ← Top bar
├──────────────────────┤
│                      │
│    [Card Art]        │  ← Center (blank for prototype)
│                      │
├──────────────────────┤
│ [Type] [Rarity]      │  ← Meta info
├──────────────────────┤
│ [Effect Text]        │  ← Effect box
│                      │
├──────────────────────┤
│ [Flavor Text]        │  ← Bottom flavor
└──────────────────────┘
```

### Example Printed Card (Memory Shard)
```
┌──────────────────────┐
│ Memory Shard     [1] │
├──────────────────────┤
│         ✧✧✧          │
│        ✧   ✧         │
│         ✧✧✧          │
├──────────────────────┤
│ Collection • Common  │
├──────────────────────┤
│ Gain +2 Reveries     │
│ at each Memory Node  │
│ (○)                  │
├──────────────────────┤
│ "Every fragment      │
│  tells a story."     │
└──────────────────────┘
```

---

## 🧪 Playtesting Notes

### Balance Targets

**Damage per Energy:**
- Common: 4-5 damage/Energy
- Uncommon: 5-6 damage/Energy
- Rare: 6-8 damage/Energy
- Epic: 8-10 damage/Energy

**Block per Energy:**
- Common: 6-8 block/Energy
- Uncommon: 8-10 block/Energy
- Rare: 10-12 block/Energy
- Epic: 12-15 block/Energy

**Reveries per Energy (Collection):**
- Common: 5-10 Reveries/Energy
- Uncommon: 10-15 Reveries/Energy
- Rare: 15-25 Reveries/Energy
- Epic: 30+ Reveries/Energy

### Deck Archetypes to Test

1. **Aggro (Attack-focused):**
   - 10 Attack cards, 2 Defense
   - Goal: Kill enemies before they kill you

2. **Control (Defense-focused):**
   - 6 Defense cards, 4 Attack, 2 Collection
   - Goal: Outlast and grind

3. **Economy (Collection-focused):**
   - 8 Collection cards, 4 Defense
   - Goal: Maximize Reveries, avoid combat

4. **Synergy (Theme deck):**
   - 8 Nightmare cards + [Fear Essence] + [Nightmare King]
   - Goal: Combo explosions

5. **Balanced (Hybrid):**
   - 4 Attack, 4 Defense, 4 Collection
   - Goal: Flexible responses

---

## 📝 Designer Notes

### Design Philosophy

1. **Meaningful Choices:** Every card should offer strategic decisions
2. **Synergy Over Power:** Combos should feel rewarding
3. **Risk/Reward:** High-cost cards should feel impactful
4. **Theme Consistency:** Card effects match flavor/lore

### Future Expansions

**Potential New Card Types:**
- **Hex Cards:** Debuff enemies
- **Ritual Cards:** Multi-turn effects
- **Artifact Cards:** Equipment that persists
- **Weather Cards:** Environmental effects

**Potential New Themes:**
- **Joy:** Healing/buff focused
- **Nostalgia:** Recursion/graveyard mechanics
- **Madness:** High risk/high reward gambling

---

**Document Version:** 1.0  
**Last Updated:** February 23, 2026  
**Total Cards:** 85  
**Ready for Print:** Yes (use template above)

---

_Card Designs © GeekBrox 2026 | Dream Collector Paper Prototype_
