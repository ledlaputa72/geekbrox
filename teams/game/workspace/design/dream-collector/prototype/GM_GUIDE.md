# Dream Collector - Game Master Guide
**Version:** 1.0  
**Date:** February 23, 2026  
**For:** 1 Player + 1 GM (Game Master)

---

## 🎭 What is a Game Master (GM)?

The **Game Master** acts as the game system, controlling:
- **Monster encounters** (when and which enemies appear)
- **Event choices** (narrating story moments)
- **Reward distribution** (giving cards and Reveries)
- **Game pacing** (keeping flow smooth)

**Think of the GM as:** The digital game AI, but in human form.

---

## 📦 GM Setup Checklist

### Before the Session

- [ ] **Print Components:**
  - 1× Character Card for Player (they choose)
  - 61× Player Cards (shuffled into Player Deck Pool)
  - 34× Monster Cards (sorted by difficulty)
  - Tokens: 100+ Reveries, 20 Energy, 20 HP
  
- [ ] **Prepare Decks:**
  - **Player Starting Deck:** Based on chosen character (8 cards)
  - **Player Draw Pile:** Shuffled
  - **Player Discard Pile:** Empty at start
  - **Monster Deck:** Shuffle 14 Basic Monsters
  - **Boss Deck:** Separate (choose 1 Boss for final node)
  
- [ ] **Prepare Game Board:**
  - Draw or print 10-node path
  - Pre-determine node types: ○ = Memory, ? = Event, ⚔ = Combat, ★ = Boss
  - Example: `START → ○ → ? → ○ → ⚔ → ○ → ? → ⚔ → ○ → ★`

- [ ] **Reference Materials:**
  - This GM Guide
  - MONSTER_DESIGNS.md (for monster stats)
  - CARD_DESIGNS.md (for card effects)
  - Paper and pencil for tracking

---

## 🎮 GM Role During Play

### Your Responsibilities

1. **Narrate the Journey**
   - Describe each node's atmosphere
   - Read Event card text dramatically
   - Announce enemy appearances

2. **Control Monsters**
   - Draw Monster cards from deck
   - Track Monster HP, Attack
   - Execute Monster actions each turn
   - Apply special abilities

3. **Manage Resources**
   - Give Reveries after combats
   - Offer card rewards
   - Track Player HP, Energy, Reveries

4. **Enforce Rules**
   - Remind Player of turn phases
   - Check card costs and effects
   - Resolve combat damage
   - Answer rules questions

5. **Adjust Difficulty** (Optional)
   - Add/remove HP from monsters if too easy/hard
   - Adjust rewards
   - Offer hints if Player is stuck

---

## 🗂️ Deck Management

### Player Deck System

**Three Piles:**
1. **Draw Pile** - Cards Player will draw from
2. **Hand** - Cards Player currently holds (max 5)
3. **Discard Pile** - Used cards

**GM Duties:**
- Shuffle Player's Draw Pile at start
- When Draw Pile empty: Shuffle Discard Pile → becomes new Draw Pile
- Draw 1 card for Player at start of each turn
- Move played cards to Discard Pile

### Monster Deck System

**Two Decks:**
1. **Basic Monster Deck** - Shuffled 14 basic monsters
2. **Boss Deck** - Pre-selected Boss for final node

**GM Duties:**
- Draw 1 monster card when Player reaches Combat node (⚔)
- Reveal monster stats to Player
- Place defeated monsters aside (out of game)
- Do NOT reshuffle defeated monsters back in

**Scaling Difficulty:**
- Early nodes (1-3): Draw from top 5 cards (easiest)
- Mid nodes (4-7): Draw from middle 5 cards
- Late nodes (8-9): Draw from bottom 4 cards (hardest)
- Final node (10): Use pre-selected Boss

---

## 🎯 Turn-by-Turn GM Script

### Turn Structure (GM's Checklist)

```
┌─────────────────────────────────────────┐
│ START OF TURN                           │
├─────────────────────────────────────────┤
│ 1. RESET PHASE (GM)                     │
│    □ Player Energy → Max (3-5)          │
│    □ Draw 1 card for Player             │
│    □ Check Character Passive (if any)   │
├─────────────────────────────────────────┤
│ 2. NODE REVEAL (if new node)            │
│    □ Memory (○): Give Reveries          │
│    □ Event (?): Read Event, choices     │
│    □ Combat (⚔): Draw Monster card      │
│    □ Boss (★): Reveal Boss card         │
├─────────────────────────────────────────┤
│ 3. PLAYER ACTION PHASE                  │
│    □ Player plays cards (pay Energy)    │
│    □ GM resolves card effects           │
│    □ Player can use Active Skill        │
│    □ Player can use Ultimate (if ready) │
├─────────────────────────────────────────┤
│ 4. MONSTER ACTION PHASE (if in combat)  │
│    □ Announce Monster action            │
│    □ Player can play Defense cards      │
│    □ Calculate damage to Player         │
│    □ Update Player HP                   │
├─────────────────────────────────────────┤
│ 5. END PHASE                             │
│    □ Discard over-limit cards (>5)      │
│    □ Check win/loss conditions          │
│    □ If combat won: Give rewards        │
│    □ If combat ongoing: Next turn       │
└─────────────────────────────────────────┘
```

---

## ⚔️ Combat Example (Step-by-Step)

### Scenario: Player vs Shadow Whisper

**Setup:**
- Player: Serenity (12 HP, 3 Energy/turn)
- Monster: Shadow Whisper (15 HP, 3 Attack/turn)
- Player Hand: [Basic Strike], [Dream Shield], [Memory Shard], [Reverie Burst]

---

**Turn 1:**

**GM:** "You draw 1 card. Your Energy resets to 3. It's your turn."

**Player:** "I play [Basic Strike] for 1 Energy. That's 5 damage."

**GM:** *Moves Basic Strike to Discard Pile*  
"Shadow Whisper takes 5 damage. It's now at 10 HP. Any other actions?"

**Player:** "No, I'm done."

**GM:** "Shadow Whisper attacks! It deals 3 damage. Do you play a Defense card?"

**Player:** "Yes, I play [Dream Shield] for 1 Energy. That blocks 8 damage."

**GM:** *Moves Dream Shield to Discard*  
"You block all 3 damage. You take 0 damage. Turn ends. You have 2 cards in hand."

---

**Turn 2:**

**GM:** "You draw 1 card → [Basic Strike]. Your Energy resets to 3. Your turn."

**Player:** "I play both [Basic Strike] for 1 Energy each. That's 10 damage total."

**GM:** "Shadow Whisper takes 10 damage. It's at 0 HP. You win! Collect your rewards."

**GM gives:**
- 25 Reveries
- Player draws 3 cards from Reward Pool (GM offers 3 random cards, Player picks 1)

---

## 📜 Event Node Script

When Player reaches **? Event Node**, GM draws/reads an Event.

### Example Event: "Crossroads"

**GM reads:**

> "You stand at a crossroads in the dream realm. Two paths diverge:
> 
> Path A leads through a peaceful meadow. You sense safety, but little reward.
> 
> Path B leads into a dark forest. You hear whispers... and the glint of treasure."

**GM offers choices:**

**Choice A (Safe):**
- Gain 20 Reveries
- No combat
- Continue

**Choice B (Risky):**
- Flip a coin (or roll d6: 1-3 = success, 4-6 = failure)
- **Success:** Gain 50 Reveries + draw 1 extra card
- **Failure:** Lose 2 HP, gain 10 Reveries

**Player decides.**

**GM resolves** based on choice and coin flip.

---

## 💰 Reward Distribution

### After Combat Victory

**GM gives:**

1. **Reveries** (based on monster defeated)
   - Basic Monsters: 20-50 Reveries
   - Elite Monsters: 60-150 Reveries
   - Bosses: 150-1000 Reveries

2. **Card Reward** (GM offers choices)
   - Draw 3 random cards from Player Card Pool
   - Show them to Player
   - Player picks 1 to add to their deck
   - Put other 2 back in pool (shuffle)

3. **Special Rewards** (from specific monsters)
   - Some monsters specify: "Reward: +1 Rare card"
   - GM draws from Rare card pool specifically

### After Memory Node (○)

**GM gives:**
- Base: 10 Reveries
- If Player has [Memory Shard] in play: +2 Reveries per Shard
- No card reward (Reveries only)

---

## 🎲 GM Decision-Making

### When to Use Which Monster

**Node 1-3 (Early):** Use tutorial monsters
- Dream Wisp (HP 8, Atk 1)
- Sleepy Shadow (HP 10, Atk 2)
- Memory Nibbler (HP 12, Atk 2)

**Node 4-5 (Mid-Early):** Standard enemies
- Shadow Whisper (HP 15, Atk 3)
- Anxious Echo (HP 18, Atk 2-5 random)
- Dream Glutton (HP 20, Atk 3)

**Node 6-7 (Mid):** Threatening enemies
- Regret Wraith (HP 22, Atk 4)
- Lucid Hunter (HP 25, Atk 3, charge mechanic)
- Memory Thief (HP 20, Atk 3, punishes cards)

**Node 8-9 (Late):** Dangerous enemies
- Nightmare Hound (HP 28, Atk 5, enrages at 50%)
- Dream Parasite (HP 30, Atk 2, steals Reveries)
- Void Fragment (HP 25, Atk 6, immune to first 10 dmg)

**Node 10 (Boss):** Choose 1 Boss
- Easy Run: Dream Eater (HP 60, phase change)
- Medium Run: Shadow King (HP 80, summons minions)
- Hard Run: Any Tier 2-3 Boss

---

## 🛠️ GM Tools & Tips

### Quick Reference Cards (GM Should Make)

Create index cards with:

**Monster Quick Stats:**
```
Shadow Whisper
HP: 15  Atk: 3/turn
Pattern: Attack every turn
Reward: 25 Reveries
```

**Event Quick Reference:**
```
Event: Crossroads
A: Safe (+20 Rev)
B: Risky (Coin flip: +50 Rev OR -2 HP)
```

### Tracking Sheet Template

```
PLAYER STATUS:
HP: [  /  ] (Current / Max)
Energy: [  /  ] (per turn)
Reveries: [    ]
Character: __________

CURRENT COMBAT:
Monster: __________
Monster HP: [  /  ] 
Monster Attack: __
Special: __________

TURN: [ ]
```

---

## 🎨 Narration Tips (Make it Cinematic!)

### Combat Descriptions

**Instead of:** "The monster attacks for 5 damage."

**Try:** "The Shadow Whisper lunges from the darkness, its ethereal claws raking across your defenses for 5 damage!"

---

**Instead of:** "You deal 10 damage."

**Try:** "Your Lucid Strike pierces the veil of dreams, shattering the creature for 10 damage! It reels back, wounded."

---

### Event Descriptions

**Instead of:** "You reach an event node."

**Try:** "The dream shifts around you. The path splits ahead, and you feel a choice weighing on your mind..."

---

### Victory Descriptions

**Instead of:** "You win. Take 30 Reveries."

**Try:** "The creature dissolves into mist, leaving behind glittering dream fragments worth 30 Reveries. You feel your power growing..."

---

## ⚖️ GM Difficulty Adjustment

### If Player is Struggling

**Easy Fixes:**
- Give +2 HP to Player between combats
- Reduce Monster HP by 20%
- Offer extra card choices (4 instead of 3)
- Add extra Memory nodes (free Reveries)

### If Player is Dominating

**Hard Fixes:**
- Increase Monster HP by 30%
- Add +1 Attack to monsters
- Reduce Reverie rewards by 25%
- Draw harder monsters earlier

### Mid-Run Balancing

**Too Easy Signal:**
- Player at full HP after 3+ combats
- Player never uses Defense cards
- Combats end in 2 turns

**Too Hard Signal:**
- Player below 50% HP constantly
- Player out of cards often
- Player losing by Node 5-6

**GM Action:**
- Adjust next monster stats on the fly
- Offer bonus healing at Memory nodes
- Add/remove event choices

---

## 🏆 Win Conditions

### Player Wins If:
- Defeats Boss at Node 10 (★)
- HP > 0 at end

**GM says:** "The final nightmare fades. You wake, empowered. Victory!"

**GM gives:**
- Boss rewards (Reveries + cards)
- Bonus: +20 Reveries per HP remaining
- Unlock: New character (if applicable)

### Player Loses If:
- HP reaches 0

**GM says:** "The dream consumes you. You fade into the void... but not forever."

**GM gives (Consolation):**
- Keep 50% of Reveries collected
- No new cards
- Encourage retry with different character/deck

---

## 📊 Post-Session Debrief

### GM Questions to Ask Player

1. "How was the difficulty? Too easy, too hard, or just right?"
2. "Which character ability did you like most?"
3. "Were any monsters too strong or too weak?"
4. "Did you understand all the rules, or were there confusing parts?"
5. "Would you play again? What would you change?"

### GM Self-Evaluation

- Did I keep the game moving (no long delays)?
- Did I narrate engagingly (or just read stats)?
- Did I balance difficulty appropriately?
- Did the player have fun?

---

## 🔧 GM Common Mistakes

### Mistake #1: Forgetting Player Energy Reset

**Problem:** Player says "I'm out of Energy" on turn 2.

**Fix:** Energy resets to max EVERY turn. Don't forget!

---

### Mistake #2: Not Shuffling Discard Pile

**Problem:** Player can't draw cards.

**Fix:** When Draw Pile empty → Shuffle Discard → becomes new Draw Pile.

---

### Mistake #3: Allowing Over-Hand-Limit

**Problem:** Player has 8 cards in hand.

**Fix:** End of turn, Player must discard down to 5 (their choice).

---

### Mistake #4: Monster Doesn't Attack

**Problem:** Forgetting Monster action phase.

**Fix:** EVERY turn, Monster attacks (unless stated otherwise). Set a reminder!

---

### Mistake #5: No Rewards After Combat

**Problem:** Player wins but GM forgets to give Reveries/cards.

**Fix:** Immediately after "You win!" → Give Reveries, offer 3 cards.

---

## 📚 GM Quick Flowchart

```
START RUN
 ↓
Player chooses Character
 ↓
GM shuffles Player Starting Deck
 ↓
GM prepares Monster Deck
 ↓
Player starts at Node 1
 ↓
┌─────────────────────┐
│   EACH NODE:        │
│                     │
│ 1. Reset Energy     │
│ 2. Draw 1 card      │
│ 3. Reveal Node Type │
│    ↓                │
│    Memory → Reverie │
│    Event → Choice   │
│    Combat → Monster │
│    Boss → Final     │
│                     │
│ 4. Player Actions   │
│ 5. Monster Actions  │
│ 6. Check Victory    │
│    ↓                │
│    Win? → Rewards   │
│    Lose? → Game Over│
│    Ongoing? → Repeat│
└─────────────────────┘
 ↓
Next Node (if alive)
 ↓
Repeat until Node 10 (Boss)
 ↓
Boss Defeated? → VICTORY!
HP = 0? → DEFEAT
```

---

## 🎓 Advanced GM Techniques

### Dynamic Storytelling

**Link combats to narrative:**
- "This Shadow Whisper looks familiar... you've seen it in nightmares before."
- "The Dream Eater awakens. This is the source of your torment."

### Player Agency

**Let Player choose sometimes:**
- "Two paths ahead: Left leads to a Memory node, Right to Combat. You choose."
- Adjust rewards based on difficulty they picked

### Surprise Mechanics

**Occasionally add twists:**
- "The monster summons a minion! (Add +10 HP to fight)"
- "A mysterious merchant appears, offering a rare card for 50 Reveries."

---

## 📖 Sample GM Script (Full Node)

### Node 5: Combat Node

**GM:** "You arrive at a clearing in the dreamscape. Mist swirls around you. Roll for encounter." *(GM draws Monster card)*

**GM:** "From the mist emerges a *Lucid Hunter* (25 HP, 3 Attack). It circles you, patient and predatory."

**GM:** "Your Energy resets to 3. You draw 1 card." *(Hands card to Player)*

**GM:** "Your hand is now: [Lists cards]. What do you do?"

*[Player plays cards, GM resolves]*

**GM:** "You strike for 8 damage! The Hunter staggers (17 HP remaining). It growls and charges!"

**GM:** "The Hunter attacks for 3 damage. Do you defend?"

*[Player plays Defense or takes damage]*

**GM:** "The Hunter's claws rake against your shield. You block all damage. Turn ends."

*[Repeat until Hunter defeated]*

**GM:** "With a final blow, the Lucid Hunter dissolves into starlight. You collect its essence."

**GM gives:**
- 50 Reveries
- Shows 3 cards: [Card A], [Card B], [Card C]

**GM:** "Choose one to add to your deck. The others fade away."

*[Player chooses]*

**GM:** "You feel stronger. The path continues ahead..." *(Move to next node)*

---

## ✅ GM Checklist (Quick Reference)

### Every Turn:
- [ ] Reset Player Energy to max
- [ ] Draw 1 card for Player
- [ ] Player plays cards (pay Energy costs)
- [ ] Monster attacks (if in combat)
- [ ] Discard over-limit cards (>5)

### After Combat:
- [ ] Give Reveries (based on monster)
- [ ] Offer 3 card choices (Player picks 1)
- [ ] Move to next node

### End of Run:
- [ ] Calculate final score
- [ ] Give victory/defeat speech
- [ ] Ask for feedback

---

**Document Version:** 1.0  
**Last Updated:** February 23, 2026  
**Game Mode:** 1 Player + 1 GM  
**Session Length:** 30-60 minutes

---

_GM Guide © GeekBrox 2026 | Dream Collector Paper Prototype_
