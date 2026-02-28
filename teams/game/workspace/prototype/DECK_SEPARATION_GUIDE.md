# Dream Collector - Deck Separation Guide
**Version:** 1.0  
**Date:** February 23, 2026  
**Purpose:** Clearly separate Player Cards from Monster Cards

---

## 🎴 Overview: Two Distinct Card Systems

### Player Cards (61 cards total)
- Cards the PLAYER uses during their turn
- Managed by PLAYER (with GM assistance)
- Organized into: Draw Pile, Hand, Discard Pile

### Monster Cards (34 cards total)
- Cards the GM uses to represent enemies
- Managed by GM only
- Organized into: Monster Deck, Active Monster, Defeated Pile

**KEY RULE:** These two decks NEVER mix. Keep them physically separated.

---

## 🃏 Player Card System (61 Cards)

### Card Distribution by Type

| Type | Count | Color Code | Purpose |
|------|-------|------------|---------|
| Attack | 18 | Red border | Deal damage to monsters |
| Defense | 12 | Blue border | Block monster damage |
| Collection | 16 | Gold border | Generate Reveries |
| Synergy | 15 | Purple border | Combo effects |
| **Total** | **61** | | |

### Player Deck Structure (During Game)

```
┌─────────────────────────────────────┐
│ PLAYER AREA                         │
├─────────────────────────────────────┤
│                                     │
│  [Draw Pile]  [Hand (5 max)]  [Discard] │
│   (face down)  (face up)      (face up) │
│                                     │
│  Starting: 8 cards based on Character │
│  Grows: +1 card per combat win       │
│  Max: ~15 cards by end of run        │
│                                     │
└─────────────────────────────────────┘
```

### Starting Decks by Character

**Serenity (Balanced):**
- 3× Memory Shard (Collection)
- 2× Basic Strike (Attack)
- 1× Dream Shield (Defense)
- 2× Reverie Burst (Collection)

**Vigor (Aggro):**
- 4× Basic Strike (Attack)
- 2× Quick Slash (Attack, 0 cost)
- 1× Dream Shield (Defense)
- 1× Reverie Burst (Collection)

**Curator (Economy):**
- 4× Memory Shard (Collection)
- 2× Reverie Burst (Collection)
- 1× Basic Strike (Attack)
- 1× Dream Shield (Defense)

*(See CHARACTER_CARDS.md for all 12 starting decks)*

### Player Card Pool (Reward Pool)

**Remaining 53 cards** = Reward pool for mid-run additions

**GM keeps these in a separate pile:**
- When Player wins combat → Draw 3 random cards
- Show to Player
- Player picks 1 to add to their deck
- Other 2 go back to pool (shuffle)

**Organization Tip:**
Sort Reward Pool by rarity for easier drawing:
- Commons (20 cards) - Green sleeve
- Uncommons (20 cards) - Blue sleeve
- Rares (10 cards) - Purple sleeve
- Epics (3 cards) - Gold sleeve

---

## 👾 Monster Card System (34 Cards)

### Card Distribution by Tier

| Tier | Count | Color Code | Purpose |
|------|-------|------------|---------|
| Basic | 14 | White border | Regular encounters |
| Elite | 10 | Purple border | Optional hard fights |
| Boss | 10 | Red border | Final encounter |
| **Total** | **34** | | |

### Monster Deck Structure (During Game)

```
┌─────────────────────────────────────┐
│ GM AREA (Monsters)                  │
├─────────────────────────────────────┤
│                                     │
│  [Basic Monster]  [Active]  [Defeated] │
│   Deck (14)      Monster    Pile        │
│   (face down)    (face up)  (face down) │
│                                     │
│  [Boss Deck]                        │
│   (10 cards, pre-select 1)          │
│                                     │
└─────────────────────────────────────┘
```

### Monster Deck Preparation (GM Setup)

**Before Game Starts:**

1. **Basic Monster Deck (14 cards):**
   - Shuffle all 14 Basic Monster cards
   - Place face down in GM area
   - This is the "encounter deck"

2. **Boss Deck (10 cards):**
   - Do NOT shuffle
   - Pre-select 1 Boss for Node 10 based on difficulty
   - Put selected Boss aside (face down)
   - Put other 9 Bosses back in box

3. **Elite Monster Deck (10 cards) - OPTIONAL:**
   - If using Elite encounters (5% chance)
   - Keep separate from Basic deck
   - Draw when special event triggers

### Monster Card Format

```
┌─────────────────────────────┐
│ SHADOW WHISPER              │
│ Basic Monster      [⚔⚔☆☆☆] │  ← Difficulty
├─────────────────────────────┤
│                             │
│   [Monster Art]             │
│                             │
├─────────────────────────────┤
│ HP: 15    Attack: 3/turn    │
├─────────────────────────────┤
│ PATTERN:                    │
│ Attacks every turn          │
│ No special abilities        │
├─────────────────────────────┤
│ REWARD:                     │
│ 25 Reveries                 │
└─────────────────────────────┘
```

---

## 🎲 Combat Flow: Card Interaction

### Setup Phase (Before Combat)

**GM:**
1. Draw 1 Monster card from Basic Monster Deck
2. Place face-up in Active Monster zone
3. Announce: "You face a [Monster Name]!"
4. Read stats: HP, Attack, Special abilities

**Player:**
5. No setup needed (already has hand of 5 cards)

### Combat Phase (Each Turn)

```
┌──────────────────────────────────────┐
│ TURN STRUCTURE                       │
├──────────────────────────────────────┤
│ 1. Player Turn                       │
│    - Draw 1 card from Draw Pile      │
│    - Play cards from Hand            │
│    - Each card → Discard Pile        │
│    - Deal damage to Active Monster   │
├──────────────────────────────────────┤
│ 2. Monster Turn (GM controls)        │
│    - Read Monster Pattern            │
│    - Announce Attack value           │
│    - Player can play Defense         │
│    - Calculate damage to Player      │
├──────────────────────────────────────┤
│ 3. Check Victory                     │
│    - Monster HP = 0? → Player wins   │
│    - Player HP = 0? → Player loses   │
│    - Neither? → Next turn            │
└──────────────────────────────────────┘
```

### Resolution Phase (After Combat)

**If Player Wins:**
- GM moves Monster card to Defeated Pile
- GM gives Reveries (amount listed on Monster card)
- GM draws 3 cards from Player Reward Pool → Player picks 1

**If Player Loses:**
- Game Over
- Player keeps 50% of Reveries
- Restart with new character

---

## 📦 Physical Organization Tips

### Setup Recommendation

```
TABLE LAYOUT:

┌─────────────────────────────────────────┐
│         PLAYER SIDE                     │
│                                         │
│  [Draw]  [Hand (5 cards)]  [Discard]   │
│                                         │
│  [Character Card]  [Reveries: XXX]     │
│  HP: ☐☐☐☐☐☐☐☐☐☐  Energy: ☐☐☐          │
│                                         │
├─────────────────────────────────────────┤
│              COMBAT ZONE                │
│                                         │
│         [Active Monster Card]           │
│         HP: ☐☐☐☐☐☐☐☐☐☐                 │
│                                         │
├─────────────────────────────────────────┤
│           GM SIDE                       │
│                                         │
│  [Monster Deck]  [Reward Pool]  [Boss] │
│   (14 cards)     (53 cards)     (1 card)│
│                                         │
│  [Defeated Pile]                        │
│                                         │
└─────────────────────────────────────────┘
```

### Card Storage Between Sessions

**Player Cards (61):**
- Store in one deck box
- Use card sleeves (red for Attack, blue for Defense, etc.)
- Include Character Cards (12) separately

**Monster Cards (34):**
- Store in separate deck box
- Use black sleeves for Basic (14)
- Use purple sleeves for Elite (10)
- Use red sleeves for Boss (10)

**Tokens:**
- Ziplock bag: Reverie tokens (100+)
- Small container: HP/Energy tokens (40)

---

## 🔢 Card Counting Checklist

### Before Each Game (GM Setup)

**Player Card Pool:**
- [ ] Character Card selected (1)
- [ ] Starting Deck shuffled (8 cards)
- [ ] Reward Pool ready (remaining 53)
- [ ] Total: 61 Player cards + 1 Character = 62 cards

**Monster Card Pool:**
- [ ] Basic Monster Deck shuffled (14)
- [ ] Elite Deck separate (10, optional)
- [ ] Boss pre-selected (1 from 10)
- [ ] Total: 34 Monster cards

### After Each Game (Cleanup)

**Player Cards:**
- [ ] Collect all Player cards from: Draw, Hand, Discard
- [ ] Collect any cards added during run
- [ ] Shuffle back into Player Card Pool (61 total)

**Monster Cards:**
- [ ] Collect all Monster cards from: Active, Defeated
- [ ] Sort back into: Basic (14), Elite (10), Boss (10)
- [ ] Ready for next game

---

## 🚫 Common Mistakes to Avoid

### Mistake #1: Mixing Player and Monster Cards

**Problem:** Player tries to play a Monster card.

**Fix:** Keep decks on opposite sides of table. Use different card sleeve colors.

---

### Mistake #2: Monsters in Player Reward Pool

**Problem:** GM accidentally draws Monster card as reward.

**Fix:** Pre-separate before game. Monster cards NEVER go to Player.

---

### Mistake #3: Reshuffling Defeated Monsters

**Problem:** Same monster appears twice.

**Fix:** Defeated monsters go to Defeated Pile (out of game). Do NOT reshuffle.

---

### Mistake #4: Player Drawing from Monster Deck

**Problem:** Player draws from wrong pile.

**Fix:** Label decks clearly. Player ONLY draws from their own Draw Pile.

---

### Mistake #5: Forgetting to Add Reward Card to Deck

**Problem:** Player picks reward card but forgets to add it.

**Fix:** GM should physically hand card to Player and say "Add this to your Discard Pile now."

---

## 🎨 Visual Card Design Differences

### Player Cards (Design Features)

```
┌─────────────────────┐
│ BASIC STRIKE        │  ← Card Name
│ [Red Border]        │  ← Attack card = Red
├─────────────────────┤
│ Type: Action        │
│ Cost: 1 Energy      │
├─────────────────────┤
│ Effect:             │
│ Deal 5 damage       │
├─────────────────────┤
│ "Strike fast."      │  ← Flavor text
└─────────────────────┘
```

### Monster Cards (Design Features)

```
┌─────────────────────┐
│ SHADOW WHISPER      │  ← Monster Name
│ [Black Border]      │  ← Monster = Black
├─────────────────────┤
│ HP: 15  Atk: 3      │  ← Stats
├─────────────────────┤
│ Pattern:            │
│ Attacks every turn  │
├─────────────────────┤
│ Reward: 25 Rev      │  ← Reward
└─────────────────────┘
```

**Visual Distinction:**
- Player Cards: Colored borders (Red/Blue/Gold/Purple)
- Monster Cards: Black borders
- Different card back designs

---

## 📊 Quick Reference Table

| Aspect | Player Cards | Monster Cards |
|--------|--------------|---------------|
| **Total** | 61 cards | 34 cards |
| **Managed By** | Player (+ GM help) | GM only |
| **Location** | Player side of table | GM side of table |
| **Piles** | Draw, Hand, Discard | Deck, Active, Defeated |
| **Color** | Red/Blue/Gold/Purple | Black |
| **Purpose** | Player actions | Enemy encounters |
| **Shuffling** | Reshuffle Discard when Draw empty | Do NOT reshuffle defeated |
| **Rewards** | Gained from combat | Given after defeat |

---

## ✅ GM Quick Checklist

### Game Start:
- [ ] Player cards on Player side (61 total)
- [ ] Monster cards on GM side (34 total)
- [ ] Character Card selected
- [ ] Starting Deck (8) shuffled
- [ ] Monster Deck (14) shuffled
- [ ] Boss (1) pre-selected

### During Game:
- [ ] Player draws from Player Draw Pile only
- [ ] GM draws from Monster Deck for encounters
- [ ] Defeated monsters go to Defeated Pile (not reshuffled)
- [ ] Reward cards come from Player Reward Pool

### Game End:
- [ ] Collect all Player cards back to 61
- [ ] Collect all Monster cards back to 34
- [ ] Sort and store separately

---

**Document Version:** 1.0  
**Last Updated:** February 23, 2026  
**Card Systems:** Fully Separated

---

_Deck Separation Guide © GeekBrox 2026 | Dream Collector Paper Prototype_
