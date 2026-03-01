# Dream Collector - Paper Prototype Rulebook
**Version:** 1.0  
**Date:** February 23, 2026  
**Prototype Type:** Card-based Tabletop Simulation

---

## 🎯 Purpose

This paper prototype simulates the **core gameplay loop** of Dream Collector:
- **Deckbuilding** (card selection)
- **Roguelike runs** (randomized encounters)
- **Idle progression** (simplified for paper)

**Playtime:** 15-30 minutes per run  
**Players:** 1 (solo) or 2 (competitive)

---

## 📦 Game Setup

### Materials Needed

1. **Card Decks:**
   - Player Deck (8-12 cards selected from Card Pool)
   - Event Deck (shuffled encounter cards)
   - Reward Deck (cards gained during run)

2. **Tokens:**
   - Reverie Tokens (use coins/beads) - 50+ pieces
   - Energy Tokens (5-10 pieces)
   - Health Tokens (10 pieces)

3. **Game Board:**
   - Draw a simple path with 8-12 nodes (use paper grid)
   - Mark nodes as: Memory (○), Event (?), Combat (⚔), Boss (★)

4. **Reference Sheet:**
   - Card types & effects
   - Action costs
   - Win/loss conditions

### Setup Steps

1. **Choose Your Dreamer** (difficulty level):
   - Serenity (Easy): Start with 10 HP, 3 Energy/turn
   - Anxiety (Medium): Start with 8 HP, 4 Energy/turn
   - Fear (Hard): Start with 6 HP, 5 Energy/turn

2. **Build Your Starting Deck:**
   - Select 8 cards from the Basic Card Pool
   - Shuffle your deck and draw 4 cards (starting hand)

3. **Setup Game Board:**
   - Shuffle Event Deck (20 cards)
   - Place Reverie tokens nearby (the "bank")
   - Set your Health and Energy trackers

4. **Begin at Node 1**

---

## 🎮 Core Rules

### Turn Structure

Each node on the path represents one turn:

```
┌─────────────────────────────────────┐
│ 1. DRAW PHASE                       │
│    - Draw 1 card (hand limit: 5)   │
├─────────────────────────────────────┤
│ 2. REVEAL NODE                      │
│    - Draw Event Card (if ? or ⚔)   │
│    - Or collect Reveries (if ○)    │
├─────────────────────────────────────┤
│ 3. ACTION PHASE                     │
│    - Spend Energy to play cards     │
│    - Resolve card effects           │
│    - Make choices (Event cards)     │
├─────────────────────────────────────┤
│ 4. END PHASE                        │
│    - Discard excess cards (>5)     │
│    - Reset Energy to max            │
│    - Move to next node              │
└─────────────────────────────────────┘
```

### Energy System

- **Starting Energy:** 3-5 per turn (based on Dreamer)
- **Card Costs:** Range from 0-3 Energy
- **Energy Resets:** At the end of each turn
- **Unspent Energy:** Does NOT carry over

### Health System

- **Starting HP:** 6-10 (based on Dreamer)
- **Damage:** Taken from Combat encounters
- **Healing:** Rare (some Event cards, Defense cards)
- **Death:** HP reaches 0 = Run fails (see Failure Rules)

---

## 🗺️ Game Board & Node Types

### Path Layout (8-12 nodes)

Example 10-node run:

```
START → ○ → ? → ○ → ⚔ → ○ → ? → ⚔ → ○ → ★ END
```

### Node Types

#### ○ Memory Node (60% frequency)
**Safe collection point**

**Effect:**
- Collect base Reveries (10 tokens)
- +2 bonus if you have "Memory Shard" card in hand
- No cost, automatic

#### ? Event Node (20% frequency)
**Choice-based encounter**

**Procedure:**
1. Draw 1 Event Card from Event Deck
2. Read the event description
3. Choose Option A or Option B
4. Apply the consequence

**Example Event Card:**
```
[Crossroads]
Choice A: Gain 20 Reveries (safe)
Choice B: Flip a coin - Heads: 50 Reveries, Tails: Lose 10 HP
```

#### ⚔ Combat Node (15% frequency)
**Battle with Nightmare**

**Procedure:**
1. Draw 1 Combat Card from Event Deck
2. Note enemy HP and Attack pattern
3. Use Action cards to deal damage
4. Survive all enemy attacks

**Example Combat:**
```
[Shadow Fiend]
HP: 15
Attack: Deals 3 damage at end of turn
Reward: 30 Reveries + 1 random card
```

#### ★ Boss Node (5% frequency - final node)
**Final encounter**

**Procedure:**
1. Draw Boss Card
2. Boss has 30-50 HP and special abilities
3. Defeat to complete run and earn major rewards

---

## 🃏 Card Rules

### Card Types

#### 1. Collection Cards (Passive)
**Played once, permanent for this run**

**Mechanics:**
- Pay Energy cost to play
- Place in front of you (remains active)
- Effect applies automatically each relevant turn

**Example:**
```
[Memory Shard]
Cost: 1 Energy
Type: Collection
Effect: Gain +2 Reveries at each Memory Node (○)
```

#### 2. Action Cards (One-time use)
**Single-use powerful effects**

**Mechanics:**
- Pay Energy cost to play
- Resolve effect immediately
- Discard after use

**Example:**
```
[Lucid Strike]
Cost: 2 Energy
Type: Action
Effect: Deal 10 damage to current enemy
```

#### 3. Synergy Cards (Combos)
**Bonus effects when combined**

**Mechanics:**
- Can be played alone OR with combo partner
- Combo effect activates automatically if conditions met

**Example:**
```
[Nightmare Ward]
Cost: 2 Energy
Type: Synergy
Effect: Block 5 damage
Combo: If you have [Fear Essence] in play, block 10 instead
```

#### 4. Defense Cards (Reactive)
**Played in response to damage**

**Mechanics:**
- Can be played outside your turn (instant)
- Must be declared before damage is applied

**Example:**
```
[Dream Shield]
Cost: 1 Energy
Type: Defense
Effect: Block 8 damage (can be played as reaction)
```

### Card Play Rules

**Hand Limit:** 5 cards maximum  
**Draw:** 1 card per turn (at start)  
**Energy:** Cards cost 0-3 Energy to play  
**Discard:** Occurs at end of turn if over hand limit

---

## 🎲 Combat Resolution

### Combat Phase Steps

When you encounter ⚔ Combat Node:

```
1. REVEAL ENEMY
   - Draw Combat Card from Event Deck
   - Note: Enemy HP, Attack value
   
2. PLAYER TURN
   - Play Action/Attack cards
   - Spend Energy to deal damage
   - Calculate total damage
   - Reduce Enemy HP
   
3. ENEMY TURN
   - Enemy attacks automatically
   - Damage = Enemy Attack value
   - Player can play Defense cards
   - Reduce Player HP by (Attack - Defense)
   
4. REPEAT
   - Continue until Enemy HP = 0 OR Player HP = 0
   
5. VICTORY/DEFEAT
   - Victory: Collect rewards (Reveries + new card)
   - Defeat: See Failure Rules below
```

### Damage Calculation

**Player Damage to Enemy:**
```
Total Damage = Sum of all Attack cards played this turn
```

**Enemy Damage to Player:**
```
Damage Taken = Enemy Attack - Your Defense cards
(Minimum 0, cannot go negative)
```

### Combat Example

**Setup:**
- Player HP: 10
- Enemy: Shadow Fiend (HP: 15, Attack: 3)
- Player hand: [Lucid Strike] (10 dmg, 2 Energy), [Dream Shield] (block 8, 1 Energy)
- Player Energy: 3

**Turn 1:**
1. Player plays [Lucid Strike] (costs 2 Energy)
   - Enemy HP: 15 → 5
2. Enemy attacks (3 damage)
3. Player plays [Dream Shield] (costs 1 Energy, blocks 8)
   - Damage blocked: 3 (all blocked)
4. Player HP: 10 (unchanged)

**Turn 2:**
1. Player draws new card, plays attack (5 damage)
   - Enemy HP: 5 → 0 (defeated!)
2. Player collects rewards: 30 Reveries + 1 random card

---

## 🏆 Victory Conditions

### Run Completion (Win)

**How to Win:**
- Reach the final node (★ Boss Node)
- Defeat the Boss
- Survive with HP > 0

**Rewards:**
- Base: 100 Reveries
- Bonus: +20 Reveries per HP remaining
- Unlock: 1-3 new cards for next run

### Run Success Tiers

| Tier | Condition | Reward Multiplier |
|------|-----------|-------------------|
| Perfect | 100% HP remaining | 2.0x Reveries |
| Strong | 50%+ HP remaining | 1.5x Reveries |
| Standard | Boss defeated | 1.0x Reveries |

---

## 💀 Defeat Conditions

### Failure States

**Run fails if:**
- Player HP reaches 0
- Player cannot draw a card when required (deck empty)

### Partial Rewards on Failure

**You still earn:**
- 50% of Reveries collected during the run
- No new cards
- Progress toward meta-unlocks (in full game)

**Example:**
- You died at Node 6 with 80 Reveries collected
- You keep: 40 Reveries (50%)
- You lose: Potential cards from later nodes

---

## 🎴 Deck Building Rules

### Starting Deck (8 cards)

**Mandatory Starter Cards:**
- 3x Memory Shard (collect +2 Reveries at ○ nodes)
- 2x Basic Strike (deal 5 damage, cost 1)
- 1x Dream Shield (block 8 damage, cost 1)
- 2x Reverie Burst (gain 10 Reveries instantly, cost 1)

**Total:** 8 cards

### Expanding Your Deck (Mid-Run)

**When you defeat enemies or complete events:**
- Draw 3 cards from Reward Deck
- Choose 1 to add to your deck
- Immediately shuffle new card into deck

**Deck Size:**
- Minimum: 8 cards
- Maximum: 12 cards (for this prototype)
- Strategy: Smaller deck = more consistent draws

### Deckbuilding Strategy

**Synergy Focus:**
- Build around a theme (all Attack, all Collection, etc.)
- Combo cards boost each other

**Example Synergy Deck:**
```
[Fear Essence] + [Nightmare Ward] = Double defense
[Memory Shard] x3 = +6 Reveries per ○ node
[Lucid Dream] + [Dream Weaver] = Chain attacks
```

---

## 🔄 Idle Simulation (Simplified)

### Paper Prototype Idle Rules

In the full game, you earn Reveries while offline. For the paper prototype:

**"Idle Run" Mode:**
1. Build a deck (8 cards)
2. Calculate your deck's "Idle Power":
   - Each Collection card = +5 points
   - Each Synergy card = +3 points
3. Simulate 1 hour of idle time:
   - Earn Reveries = Idle Power × 10

**Example:**
- Deck has 4 Collection cards, 2 Synergy cards
- Idle Power = (4 × 5) + (2 × 3) = 26
- 1 hour = 260 Reveries earned

**Use Case:**
- Between playtest runs, calculate what you would have earned
- Helps test progression balance

---

## 📊 Scoring & Progression

### Reverie Scoring

**Ways to Earn Reveries:**
- Memory Nodes (○): 10-15 per node
- Combat Victories: 30-50 per enemy
- Events: 10-100 (risk/reward)
- Boss Defeat: 100 base + bonuses
- Idle (simulated): Deck Power × 10 per hour

### Meta Progression (Between Runs)

**Spending Reveries (in full game):**
- Upgrade cards (20 Reveries per level)
- Unlock new Dreamers (100 Reveries)
- Prestige bonuses (varies)

**For Paper Prototype:**
- Track cumulative Reveries across runs
- After 5 runs, allow player to "purchase" 1 upgraded card

---

## 🎭 Example Play Scenario

### Turn-by-Turn Walkthrough

**Player:** Sarah  
**Dreamer:** Serenity (10 HP, 3 Energy/turn)  
**Starting Deck:** 8 basic cards  
**Hand:** [Memory Shard], [Basic Strike], [Reverie Burst], [Dream Shield]

---

#### **Node 1: START**
- Draw 1 card → [Memory Shard #2]
- Move to Node 2

#### **Node 2: ○ Memory Node**
- Auto-collect: 10 Reveries
- Play [Memory Shard] (cost 1 Energy)
  - Placed in front (now active permanently)
- End turn, Energy resets to 3

**Status:** 10 Reveries, 10 HP, 3 Energy

---

#### **Node 3: ? Event Node**
- Draw Event Card: **[Mystic Fountain]**
  - Choice A: Gain 15 Reveries (safe)
  - Choice B: Gamble: Coin flip - Heads: 40 Reveries, Tails: Lose 2 HP
- Sarah chooses **Choice B** (risky!)
- Flips coin → **Heads!**
- Gain 40 Reveries

**Status:** 50 Reveries, 10 HP, 3 Energy

---

#### **Node 4: ○ Memory Node**
- Auto-collect: 10 Reveries
- Bonus: +2 Reveries (from [Memory Shard] in play)
- Total: 12 Reveries

**Status:** 62 Reveries, 10 HP, 3 Energy

---

#### **Node 5: ⚔ Combat Node**
- Draw Combat Card: **[Shadow Fiend]** (15 HP, 3 Attack)

**Combat Turn 1:**
- Player plays [Basic Strike] (5 damage, 1 Energy)
- Enemy HP: 15 → 10
- Enemy attacks: 3 damage
- Player plays [Dream Shield] (block 8, 1 Energy)
- Damage blocked completely
- Player HP: 10 (unchanged)

**Combat Turn 2:**
- Player draws [Lucid Strike] (10 damage, 2 Energy)
- Player plays [Lucid Strike]
- Enemy HP: 10 → 0 (defeated!)
- Player collects rewards: 30 Reveries + draw 1 new card
- New card: [Fear Essence] (added to deck)

**Status:** 92 Reveries, 10 HP, 3 Energy

---

#### **Node 6-8: Continue...**
- More Memory/Event nodes
- Collect ~50 more Reveries

---

#### **Node 10: ★ Boss Node**
- Draw Boss Card: **[Dream Eater]** (40 HP, 5 Attack, Special: Drains 1 Energy per turn)

**Boss Battle:**
- Sarah uses optimized combo attacks
- Takes 8 damage (2 HP remaining)
- Defeats boss after 5 turns

**Final Rewards:**
- Boss reward: 100 Reveries
- Bonus: +40 Reveries (2 HP remaining × 20)
- Total earned this run: 282 Reveries

**Result:** 🏆 **Victory!** Run complete, unlocks new cards for next run.

---

## 🧪 Playtest Tips

### What to Test For

1. **Balance:**
   - Is damage balanced? (Not too easy/hard)
   - Are Reverie rewards fair?
   - Do Energy costs feel right?

2. **Pacing:**
   - Is 10 nodes too long/short?
   - Do Combat encounters feel satisfying?

3. **Strategy:**
   - Are different deck builds viable?
   - Do synergy combos feel powerful?

4. **Fun:**
   - Are choices meaningful?
   - Do you want to replay with different decks?

### Common Issues & Fixes

| Issue | Solution |
|-------|----------|
| Too easy | Increase enemy HP, reduce starting HP |
| Too hard | Add more defensive cards, reduce enemy attack |
| Boring | Add more Event cards with interesting choices |
| Too long | Reduce path to 8 nodes |
| Cards feel same | Increase synergy bonuses |

---

## 📝 Playtest Feedback Form

After each run, record:

1. **Run Result:** Win/Loss, Final HP, Reveries earned
2. **Deck Used:** List all cards
3. **Most Fun Moment:** What felt best?
4. **Frustration Point:** What felt bad?
5. **Suggested Changes:** Balance tweaks?

**Track across 5+ runs to identify patterns!**

---

## 🔧 Advanced Rules (Optional)

### Variant: Competitive Mode (2 Players)

**Setup:**
- Each player builds their own deck
- Both players traverse the same path (shared nodes)
- Combat: Players battle each other instead of AI

**Winner:** Player with most Reveries after 10 nodes

---

### Variant: Hard Mode

**Changes:**
- Start with 6 HP instead of 10
- Enemies have +5 HP
- Energy reduced to 2 per turn (instead of 3)

---

## 📚 Appendix: Quick Reference

### Action Costs Summary
- Collection cards: 1-2 Energy
- Attack cards: 1-3 Energy
- Defense cards: 0-1 Energy
- Synergy cards: 2-3 Energy

### Node Frequency Guide
- ○ Memory: 60% (6 out of 10)
- ? Event: 20% (2 out of 10)
- ⚔ Combat: 15% (1-2 out of 10)
- ★ Boss: 5% (1 final node)

### Damage Quick Reference
- Basic Attack: 5 damage
- Strong Attack: 10 damage
- Ultimate Attack: 15 damage
- Basic Defense: 5-8 block

---

**Document Version:** 1.0  
**Last Updated:** February 23, 2026  
**Playtest Status:** Ready for alpha testing  
**Next Steps:** Print cards, gather playtesters, iterate!

---

_Rulebook © GeekBrox 2026 | Dream Collector Paper Prototype_
