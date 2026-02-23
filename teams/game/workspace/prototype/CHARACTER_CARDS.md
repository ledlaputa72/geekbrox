# Dream Collector - Character Cards (Dreamers)
**Version:** 1.0  
**Date:** February 23, 2026  
**Total Characters:** 12 Dreamers

---

## 🎭 Character System Overview

Each player chooses one **Dreamer** (character class) before starting a run. Each Dreamer has:
- **Base Stats** (HP, Energy, Starting Deck)
- **Passive Ability** (always active)
- **Active Skill** (can be activated once per combat)
- **Ultimate Ability** (charged by collecting Reveries)

---

## 📊 Character Card Template

```yaml
Name: [Dreamer Name]
Archetype: [Playstyle]
Difficulty: ★★★☆☆

Base Stats:
  - Starting HP: X
  - Energy per Turn: X
  - Starting Deck: [8 specific cards]

Passive Ability: [Always active effect]
Active Skill: [Once per combat, costs X Energy]
Ultimate: [Requires X Reveries, game-changing effect]

Strengths: [What this character is good at]
Weaknesses: [What this character struggles with]
Recommended For: [Player skill level]
```

---

## 🌟 Starter Characters (Easy)

### #C01 - Serenity the Peaceful Dreamer

```yaml
Name: Serenity
Title: The Peaceful Dreamer
Archetype: Balanced / Beginner-Friendly
Difficulty: ★☆☆☆☆ (Easiest)

Base Stats:
  - Starting HP: 12
  - Energy per Turn: 3
  - Starting Deck:
    - 3× Memory Shard (Collection)
    - 2× Basic Strike (Attack)
    - 1× Dream Shield (Defense)
    - 2× Reverie Burst (Collection)

Passive Ability: "Inner Peace"
  - Heal 1 HP at the start of each combat
  - Maximum HP: 15 (can heal above starting HP)

Active Skill: "Calming Breath" (2 Energy, once per combat)
  - Block 10 damage
  - Draw 2 cards
  - Gain 1 Energy next turn

Ultimate: "Sanctuary of Dreams" (Requires 100 Reveries)
  - Fully heal to max HP
  - Gain immunity for 2 turns
  - Draw 3 cards

Strengths:
  - High survivability (self-healing)
  - Forgiving for beginners
  - Balanced offense and defense

Weaknesses:
  - No damage amplification
  - Slower clear speed
  - Less exciting for experienced players

Recommended For: New players, first playthrough
Playstyle: Defensive, safe, forgiving
Flavor: "In stillness, I find strength."
```

---

### #C02 - Vigor the Action Hero

```yaml
Name: Vigor
Title: The Action Hero
Archetype: Aggro / High Damage
Difficulty: ★★☆☆☆ (Easy)

Base Stats:
  - Starting HP: 10
  - Energy per Turn: 4
  - Starting Deck:
    - 4× Basic Strike (Attack)
    - 2× Quick Slash (Attack, 0 cost)
    - 1× Dream Shield (Defense)
    - 1× Reverie Burst (Collection)

Passive Ability: "Adrenaline Rush"
  - Deal +2 damage with all Attack cards
  - After killing an enemy, gain 1 Energy immediately

Active Skill: "Burst Fire" (3 Energy, once per combat)
  - Deal 15 damage
  - If this kills the enemy, refund 2 Energy

Ultimate: "Rampage Mode" (Requires 80 Reveries)
  - For 3 turns:
    - All Attack cards cost 1 less Energy
    - Deal double damage
    - Cannot use Defense cards

Strengths:
  - Fast combat clears
  - High damage output
  - Snowballs after first kill

Weaknesses:
  - Low HP (dies quickly to burst damage)
  - Requires aggressive play
  - No sustain

Recommended For: Players who like offense, speedrunners
Playstyle: Glass cannon, kill-or-be-killed
Flavor: "The best defense is a dead enemy."
```

---

### #C03 - Curator the Collector

```yaml
Name: Curator
Title: The Collector
Archetype: Economy / Reverie-focused
Difficulty: ★★☆☆☆ (Easy)

Base Stats:
  - Starting HP: 10
  - Energy per Turn: 3
  - Starting Deck:
    - 4× Memory Shard (Collection)
    - 2× Reverie Burst (Collection)
    - 1× Basic Strike (Attack)
    - 1× Dream Shield (Defense)

Passive Ability: "Midas Touch"
  - Gain +50% Reveries from all sources
  - Can spend Reveries during combat for effects

Active Skill: "Emergency Fund" (0 Energy, once per combat)
  - Spend 20 Reveries: Deal 10 damage OR Block 10 damage
  - Can use multiple times if you have enough Reveries

Ultimate: "Golden Dream" (Requires 150 Reveries)
  - Instantly win current combat (skip to rewards)
  - Gain double rewards from this node
  - Note: Does not work on Boss nodes

Strengths:
  - Fastest economic growth
  - Can buy victory with Reveries
  - Strong late-game scaling

Weaknesses:
  - Weak early combat
  - Requires smart resource management
  - Ultimate doesn't work on Bosses

Recommended For: Players who like economy games, strategic thinkers
Playstyle: Avoid combat, maximize income, buy power
Flavor: "Everything has a price."
```

---

## ⚔️ Advanced Characters (Medium)

### #C04 - Lucida the Awakened Mind

```yaml
Name: Lucida
Title: The Awakened Mind
Archetype: Combo / Card Draw
Difficulty: ★★★☆☆ (Medium)

Base Stats:
  - Starting HP: 11
  - Energy per Turn: 3
  - Starting Deck:
    - 2× Basic Strike (Attack)
    - 2× Dream Shield (Defense)
    - 2× Memory Shard (Collection)
    - 2× Lucid Awakening (Synergy - draw cards)

Passive Ability: "Hyper-Awareness"
  - Hand size limit: 7 (instead of 5)
  - Draw 1 extra card at start of turn

Active Skill: "Mental Overdrive" (2 Energy, once per combat)
  - Draw 3 cards
  - Reduce all card costs by 1 this turn (minimum 0)

Ultimate: "Perfect Clarity" (Requires 100 Reveries)
  - For 2 turns:
    - Draw 2 cards per turn (instead of 1)
    - All cards cost 0 Energy
    - No hand size limit

Strengths:
  - Incredible card cycling
  - Powerful combo potential
  - Flexible response options

Weaknesses:
  - Requires planning ahead
  - Can overdraw and waste cards
  - Lower base stats

Recommended For: Players who like combos, TCG veterans
Playstyle: Draw engine, big combo turns
Flavor: "I see all possibilities."
```

---

### #C05 - Umbra the Shadow Walker

```yaml
Name: Umbra
Title: The Shadow Walker
Archetype: Defensive / Control
Difficulty: ★★★☆☆ (Medium)

Base Stats:
  - Starting HP: 14
  - Energy per Turn: 3
  - Starting Deck:
    - 2× Basic Strike (Attack)
    - 4× Dream Shield (Defense)
    - 2× Memory Shard (Collection)

Passive Ability: "Shadow Form"
  - Block 3 damage automatically every turn (before Defense cards)
  - Enemies deal -1 damage (minimum 1)

Active Skill: "Phase Shift" (1 Energy, once per combat)
  - Become invulnerable for 1 turn (take no damage)
  - Cannot attack during this turn

Ultimate: "Nightmare Cloak" (Requires 120 Reveries)
  - For 3 turns:
    - Auto-block 10 damage per turn
    - Reflect 50% of blocked damage back to attacker

Strengths:
  - Extremely tanky
  - Punishes aggressive enemies
  - Survives long combats

Weaknesses:
  - Low damage output
  - Slow combat clears
  - Boring for some players

Recommended For: Defensive players, survivors
Playstyle: Outlast enemies, win through attrition
Flavor: "You cannot kill what you cannot touch."
```

---

### #C06 - Memoria the Archivist

```yaml
Name: Memoria
Title: The Archivist
Archetype: Synergy / Memory Theme
Difficulty: ★★★☆☆ (Medium)

Base Stats:
  - Starting HP: 11
  - Energy per Turn: 3
  - Starting Deck:
    - 2× Basic Strike (Attack)
    - 2× Dream Shield (Defense)
    - 4× Memory Shard (Collection, but also counts as "Memory" tag)

Passive Ability: "Deja Vu"
  - When you play a card, 20% chance to return it to hand (can play again)
  - Memory-tagged cards have 50% chance instead

Active Skill: "Recall" (2 Energy, once per combat)
  - Return 2 discarded cards to your hand
  - They cost 1 less Energy this turn

Ultimate: "Perfect Recall" (Requires 100 Reveries)
  - Shuffle your entire discard pile back into deck
  - Draw 5 cards
  - For this turn, can play any number of cards

Strengths:
  - Card recursion (reuse powerful cards)
  - Strong with Memory synergies
  - Consistent deck cycling

Weaknesses:
  - RNG-dependent passive
  - Requires specific cards to shine
  - Mediocre without synergies

Recommended For: Players who like graveyard mechanics, combo players
Playstyle: Recycle powerful cards, maximize value
Flavor: "The past is never truly gone."
```

---

## 🔥 Expert Characters (Hard)

### #C07 - Pyra the Dream Burner

```yaml
Name: Pyra
Title: The Dream Burner
Archetype: High Risk / High Reward
Difficulty: ★★★★☆ (Hard)

Base Stats:
  - Starting HP: 8 (VERY LOW)
  - Energy per Turn: 5 (VERY HIGH)
  - Starting Deck:
    - 4× Basic Strike (Attack)
    - 2× Heavy Blow (Attack, high cost high damage)
    - 1× Dream Shield (Defense)
    - 1× Reverie Burst (Collection)

Passive Ability: "Burn Bright"
  - Deal +3 damage with all Attack cards
  - At end of turn, lose 1 HP (unavoidable self-damage)
  - Cannot heal during combat (healing items disabled)

Active Skill: "Last Stand" (0 Energy, once per combat, only at HP ≤ 3)
  - Deal 25 damage
  - Become invulnerable for 1 turn
  - Gain 2 Energy next turn

Ultimate: "Supernova" (Requires 80 Reveries)
  - Deal damage equal to (Max HP - Current HP) × 5 to all enemies
  - Example: At 3/8 HP → 25 damage to all
  - After use, fully heal to max HP

Strengths:
  - Highest damage potential in game
  - Extremely fast clears
  - Ultimate scales with low HP (risk/reward)

Weaknesses:
  - Constantly losing HP
  - Cannot heal in combat
  - One mistake = death

Recommended For: Expert players, thrill-seekers, speedrunners
Playstyle: Live on the edge, burn everything before you burn out
Flavor: "I'll die when I'm done."
```

---

### #C08 - Chronos the Time Weaver

```yaml
Name: Chronos
Title: The Time Weaver
Archetype: Tempo / Turn Manipulation
Difficulty: ★★★★☆ (Hard)

Base Stats:
  - Starting HP: 10
  - Energy per Turn: 3
  - Starting Deck:
    - 2× Basic Strike (Attack)
    - 2× Dream Shield (Defense)
    - 2× Memory Shard (Collection)
    - 2× Echo Strike (Attack that repeats next turn)

Passive Ability: "Time Loop"
  - 30% chance for any played card to activate twice
  - If it triggers, that card is removed from game after

Active Skill: "Haste" (2 Energy, once per combat)
  - Take an extra turn immediately after this one
  - Enemy does not attack between your turns
  - Draw 1 card at start of bonus turn

Ultimate: "Temporal Rift" (Requires 150 Reveries)
  - Rewind time: reset combat to turn 1
  - Keep your current deck state
  - Enemy resets to full HP
  - Use when: you drew poorly and want a re-do

Strengths:
  - Incredible tempo advantage (extra turns)
  - Can fix bad RNG with Ultimate
  - Unique gameplay

Weaknesses:
  - RNG-heavy passive
  - Ultimate can backfire
  - Complex decision-making

Recommended For: Expert players, those who like unique mechanics
Playstyle: Manipulate action economy, control tempo
Flavor: "Time bends to my will."
```

---

### #C09 - Nyx the Nightmare Queen

```yaml
Name: Nyx
Title: The Nightmare Queen
Archetype: Nightmare Synergy / Debuff
Difficulty: ★★★★☆ (Hard)

Base Stats:
  - Starting HP: 11
  - Energy per Turn: 3
  - Starting Deck:
    - 2× Nightmare Blade (Attack, scales with Nightmare cards)
    - 2× Nightmare Ward (Defense, synergy)
    - 2× Fear Essence (Synergy enabler)
    - 2× Memory Shard (Collection)

Passive Ability: "Queen of Fears"
  - All Nightmare-tagged cards cost 1 less Energy
  - Enemies deal -1 damage for each Nightmare card you've played this combat

Active Skill: "Terrorize" (2 Energy, once per combat)
  - Enemy skips their next turn (stun)
  - Apply "Frightened" debuff: -3 Attack permanently

Ultimate: "Reign of Terror" (Requires 100 Reveries)
  - For 3 turns:
    - All your cards become Nightmare-tagged
    - Gain +5 damage and +5 block
    - Enemies deal half damage

Strengths:
  - Powerful with Nightmare synergies
  - Strong debuff control
  - Scales extremely well

Weaknesses:
  - Weak without Nightmare cards
  - Requires specific deck build
  - Mediocre early game

Recommended For: Players who like synergy decks, deckbuilding enthusiasts
Playstyle: Build around Nightmare theme, dominate late
Flavor: "They will fear the dark."
```

---

## 💀 Master Characters (Very Hard)

### #C10 - Void the Erased

```yaml
Name: Void
Title: The Erased
Archetype: Exile / Resource Sacrifice
Difficulty: ★★★★★ (Very Hard)

Base Stats:
  - Starting HP: 12
  - Energy per Turn: 4
  - Starting Deck:
    - 3× Basic Strike (Attack)
    - 2× Dream Shield (Defense)
    - 3× Oblivion Strike (Epic attack, removes itself after use)

Passive Ability: "Entropy"
  - Can exile cards from hand (remove from game permanently)
  - For each exiled card: Gain +2 Max HP and +1 Energy next turn
  - Warning: Exiled cards are gone forever (even between combats)

Active Skill: "Void Rift" (3 Energy, once per combat)
  - Exile all cards in hand
  - Deal 10 damage per exiled card
  - Draw 3 cards

Ultimate: "Embrace the Void" (Requires 200 Reveries)
  - Exile your entire deck (all remaining cards)
  - Gain HP = cards exiled × 3
  - Gain Energy = cards exiled × 1
  - For rest of run, draw from a special Void Deck (6 powerful cards only)

Strengths:
  - Extreme power scaling
  - Can turn bad cards into resources
  - Ultimate is game-changing

Weaknesses:
  - Permanently shrinks deck
  - Irreversible choices
  - Requires perfect planning

Recommended For: Master players only, those who like high-risk gameplay
Playstyle: Sacrifice everything for power, thin deck strategy
Flavor: "From nothing, I become everything."
```

---

### #C11 - Genesis the World Builder

```yaml
Name: Genesis
Title: The World Builder
Archetype: Creation / Card Generation
Difficulty: ★★★★★ (Very Hard)

Base Stats:
  - Starting HP: 10
  - Energy per Turn: 3
  - Starting Deck:
    - 2× Basic Strike (Attack)
    - 2× Dream Shield (Defense)
    - 4× Dream Dust (Collection, generates random cards)

Passive Ability: "Creation"
  - At end of each turn, add 1 random card to your hand
  - Cards created this way cost 1 less Energy
  - Your deck size has no maximum

Active Skill: "Manifest" (2 Energy, once per combat)
  - Choose: Offensive, Defensive, or Utility
  - Add 3 random cards of that type to your hand
  - They cost 0 this turn

Ultimate: "Big Bang" (Requires 150 Reveries)
  - Create 10 random cards and add to deck
  - For rest of this combat:
    - Draw 2 cards per turn
    - No hand size limit
    - All cards cost 1 less

Strengths:
  - Infinite deck growth
  - Incredible flexibility (always have options)
  - Can adapt to any situation

Weaknesses:
  - Pure RNG (cards are random)
  - Deck becomes bloated and inconsistent
  - No reliable strategy

Recommended For: Players who embrace chaos, roguelike veterans
Playstyle: Adapt on the fly, improvise solutions
Flavor: "From chaos, I create worlds."
```

---

### #C12 - Oracle the All-Seeing

```yaml
Name: Oracle
Title: The All-Seeing
Archetype: Information / Perfect Play
Difficulty: ★★★★★ (Very Hard)

Base Stats:
  - Starting HP: 9
  - Energy per Turn: 3
  - Starting Deck:
    - 2× Basic Strike (Attack)
    - 2× Dream Shield (Defense)
    - 4× Memory Shard (Collection)

Passive Ability: "Foresight"
  - See the next 3 cards you will draw
  - See enemy's next action
  - Can spend 2 Energy to shuffle deck (reroll draw)

Active Skill: "Prophecy" (1 Energy, once per combat)
  - Look at top 10 cards of deck
  - Choose 3 to put in your hand immediately
  - Shuffle the rest

Ultimate: "Omniscience" (Requires 100 Reveries)
  - For rest of combat:
    - See all cards in deck at all times
    - Choose which card to draw each turn
    - See all enemy actions 3 turns ahead

Strengths:
  - Perfect information (no RNG surprises)
  - Can always make optimal plays
  - Skill-based, rewarding

Weaknesses:
  - Requires expert game knowledge
  - Low stats (9 HP is dangerous)
  - Information overload for beginners

Recommended For: Master players, min-maxers, competitive players
Playstyle: Perfect play, no luck required, pure skill
Flavor: "I have already seen your defeat."
```

---

## 📊 Character Comparison Chart

| Character | HP | Energy | Difficulty | Archetype | Best For |
|-----------|----|----|------------|-----------|----------|
| Serenity | 12 | 3 | ★☆☆☆☆ | Balanced | Beginners |
| Vigor | 10 | 4 | ★★☆☆☆ | Aggro | Fast clears |
| Curator | 10 | 3 | ★★☆☆☆ | Economy | Reverie farming |
| Lucida | 11 | 3 | ★★★☆☆ | Combo | Card draw |
| Umbra | 14 | 3 | ★★★☆☆ | Tank | Survivability |
| Memoria | 11 | 3 | ★★★☆☆ | Synergy | Recursion |
| Pyra | 8 | 5 | ★★★★☆ | Glass Cannon | High risk |
| Chronos | 10 | 3 | ★★★★☆ | Tempo | Extra turns |
| Nyx | 11 | 3 | ★★★★☆ | Nightmare | Debuffs |
| Void | 12 | 4 | ★★★★★ | Exile | Sacrifice |
| Genesis | 10 | 3 | ★★★★★ | RNG | Chaos |
| Oracle | 9 | 3 | ★★★★★ | Perfect Info | Skill |

---

## 🖨️ Character Card Print Template

### Card Size: 63mm × 88mm (Standard Card Size)

```
┌─────────────────────────────┐
│ [Character Name]            │
│ [Title]              [★★★] │  ← Difficulty
├─────────────────────────────┤
│                             │
│   [Character Portrait]      │  ← Art space
│                             │
├─────────────────────────────┤
│ HP: XX    Energy: X/turn    │
├─────────────────────────────┤
│ PASSIVE: [Name]             │
│ [Description]               │
├─────────────────────────────┤
│ SKILL: [Name] (X Energy)    │
│ [Description]               │
├─────────────────────────────┤
│ ULTIMATE: [Name]            │
│ (Requires X Reveries)       │
│ [Description]               │
├─────────────────────────────┤
│ "[Flavor Quote]"            │
└─────────────────────────────┘
```

---

## 🎮 Playtesting Notes

### Balance Targets

**HP Range:** 8-14 (average 11)
**Energy Range:** 3-5 (average 3.5)
**Ultimate Cost:** 80-200 Reveries (2-4 combats)

### Character Unlock Progression

**Starter Pack (Always Available):**
- Serenity (Tutorial character)
- Vigor (Aggro intro)
- Curator (Economy intro)

**Unlock After First Win:**
- Lucida
- Umbra
- Memoria

**Unlock After 5 Wins:**
- Pyra
- Chronos
- Nyx

**Unlock After 10 Wins:**
- Void
- Genesis
- Oracle

---

**Document Version:** 1.0  
**Last Updated:** February 23, 2026  
**Total Characters:** 12 Dreamers  
**Ready for Playtest:** Yes

---

_Character Cards © GeekBrox 2026 | Dream Collector Paper Prototype_
