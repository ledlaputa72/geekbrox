# Dream Collector - Playtest Guide
**Version:** 1.0  
**Date:** February 23, 2026  
**Prototype Status:** Alpha - Ready for Testing

---

## 🎯 Playtest Objectives

This guide helps you run effective playtests to validate:

1. **Core Gameplay Loop** - Is it fun and engaging?
2. **Balance** - Are cards/enemies/rewards fair?
3. **Strategic Depth** - Do choices matter?
4. **Pacing** - Is the game too fast/slow?
5. **Replayability** - Do players want to play again?

---

## 📋 Pre-Playtest Checklist

### Materials Preparation

- [ ] **Print all cards** (use CARD_DESIGNS.md templates)
  - 61 player cards minimum
  - 24 enemy/boss cards
  - Print 2x copies for testing deck variety
  
- [ ] **Gather tokens:**
  - 100+ small tokens (Reveries) - use coins, beads, or poker chips
  - 20 Energy tokens (different color)
  - 20 Health tokens (different color)
  - OR use paper tracking sheet instead

- [ ] **Prepare game board:**
  - Draw 10-node path on paper/whiteboard
  - Label nodes: ○ (Memory), ? (Event), ⚔ (Combat), ★ (Boss)
  - Example layout: `START → ○ → ? → ○ → ⚔ → ○ → ? → ⚔ → ○ → ★`

- [ ] **Print reference sheets:**
  - Turn structure flowchart
  - Card type reference
  - Damage/block calculations

- [ ] **Create decks:**
  - Shuffle player card pool (face up for selection)
  - Shuffle event deck (face down)
  - Separate enemy and boss cards

### Participant Preparation

- [ ] **Recruit playtesters** (1-4 people ideal)
- [ ] **Prepare feedback forms** (see section below)
- [ ] **Set timer** (track session length)
- [ ] **Setup recording** (optional: video/audio for review)

---

## 🎮 Playtest Session Structure

### Session Flow (60-90 minutes)

```
┌─────────────────────────────────────────┐
│ 1. Introduction (5 min)                 │
│    - Explain game concept               │
│    - Review core rules                  │
├─────────────────────────────────────────┤
│ 2. Tutorial Run (15-20 min)            │
│    - Guided first playthrough           │
│    - Answer questions as they arise     │
├─────────────────────────────────────────┤
│ 3. Independent Run (20-30 min)         │
│    - Player(s) play without guidance    │
│    - Observer takes notes               │
├─────────────────────────────────────────┤
│ 4. Feedback Session (15-20 min)        │
│    - Discuss experience                 │
│    - Fill out feedback form             │
├─────────────────────────────────────────┤
│ 5. Optional Second Run (20 min)        │
│    - Test different deck archetype      │
│    - Validate changes if needed         │
└─────────────────────────────────────────┘
```

### Introduction Script

**Read to playtesters:**

> "Welcome! Today you're testing **Dream Collector**, a card-based roguelike game about collecting dreams.
> 
> **Your goal:** Build a deck of 8-12 cards, navigate a dream path, defeat enemies, and collect Reveries (dream fragments).
> 
> **This is a prototype:** Cards are unbalanced, rules may be unclear, and things might break. That's GOOD—we want to find problems!
> 
> **Your job:** Play naturally, speak your thoughts aloud, and tell us what feels fun or frustrating.
> 
> **No wrong answers:** If you're confused, that's our fault, not yours. Ask questions anytime!"

---

## 🧪 What to Test

### Phase 1: Core Mechanics (First 2 Playtests)

**Focus Areas:**
1. **Turn Structure** - Is the flow intuitive?
2. **Energy System** - Does 3 Energy/turn feel right?
3. **Card Play** - Are costs fair?
4. **Combat** - Is damage/HP balanced?

**Key Questions:**
- Did players understand when to draw cards?
- Was Energy ever wasted or always scarce?
- Did combat feel too easy or too hard?
- Were Health totals appropriate (dying too fast/slow)?

**Red Flags to Watch For:**
- ❌ Players confused about turn order
- ❌ Players constantly out of Energy (costs too high)
- ❌ Players always have leftover Energy (costs too low)
- ❌ Combat over in 1-2 turns (too fast)
- ❌ Combat dragging 5+ turns (too slow)

### Phase 2: Strategic Depth (Playtests 3-5)

**Focus Areas:**
1. **Deck Building** - Do choices matter?
2. **Card Synergies** - Do combos feel rewarding?
3. **Risk/Reward** - Are Event choices interesting?
4. **Archetype Viability** - Can different strategies win?

**Key Questions:**
- Did players feel their deck choices mattered?
- Did synergy cards create "aha!" moments?
- Did players engage with Event choices or ignore them?
- Can both aggressive and defensive decks succeed?

**Test Different Archetypes:**

| Run # | Archetype | Deck Composition | Expected Playstyle |
|-------|-----------|------------------|-------------------|
| 1 | Aggro Attack | 10 Attack, 2 Defense | Fast kills |
| 2 | Control | 6 Defense, 4 Attack, 2 Collection | Outlast |
| 3 | Economy | 8 Collection, 4 Defense | Reverie focus |
| 4 | Synergy | 8 Nightmare + combos | Combo explosions |
| 5 | Balanced | 4/4/4 split | Flexibility |

**Red Flags:**
- ❌ All decks feel the same
- ❌ One archetype dominates (balance issue)
- ❌ Synergies never trigger (too hard to combo)
- ❌ Players ignoring card text (effects unclear)

### Phase 3: Pacing & Replayability (Playtests 6-10)

**Focus Areas:**
1. **Run Length** - Is 10 nodes too long/short?
2. **Progression Curve** - Does difficulty ramp well?
3. **Reward Satisfaction** - Do rewards feel good?
4. **Replay Desire** - Do players want to play again?

**Key Questions:**
- Did players complete runs in 20-30 minutes?
- Did difficulty increase appropriately toward the boss?
- Did rewards feel meaningful or arbitrary?
- After losing, did players want to try again?

**Adjust These Variables:**

| Metric | Too Low → Fix | Too High → Fix |
|--------|---------------|----------------|
| **Run Length** | Add 2 nodes | Remove 2 nodes |
| **Difficulty** | +5 enemy HP | -5 enemy HP |
| **Rewards** | +10 Reveries/node | -10 Reveries/node |
| **HP Total** | +2 starting HP | -2 starting HP |

**Red Flags:**
- ❌ Players checking time repeatedly (bored)
- ❌ Runs end in 5 minutes (too fast)
- ❌ Runs drag past 40 minutes (too slow)
- ❌ Players say "one more game!" (GOOD sign!)

---

## 📝 Feedback Collection

### Observation Notes (Taken During Play)

**Observer should track:**

1. **Confusion Points:**
   - Timestamp + what happened
   - Example: "5:23 - Player asked 'Do I draw before or after resolving the node?'"

2. **Emotional Reactions:**
   - Positive: Laughter, "Nice!", fist pump
   - Negative: Sighs, frustration, "This is stupid"
   - Neutral: Long pauses, checking phone

3. **Decision Time:**
   - Fast decisions (<5 sec) = intuitive or boring
   - Slow decisions (>30 sec) = interesting or confusing
   - Track which decisions take longest

4. **Rule Lookups:**
   - How many times did players check rulebook?
   - Which rules were referenced most?

5. **Unused Cards:**
   - Which cards never got played?
   - Which cards always got played?

### Post-Play Feedback Form

**Give to playtesters after each run:**

---

#### **Dream Collector Playtest Feedback Form**

**Date:** _______________  
**Run #:** _______________  
**Deck Archetype:** _______________  
**Result:** Win / Loss  
**Final Stats:**
- HP Remaining: ______
- Reveries Earned: ______
- Run Length: ______ minutes

---

#### **Section 1: Overall Experience**

**1. How fun was this game?**
```
Not Fun  1 --- 2 --- 3 --- 4 --- 5  Very Fun
```

**2. How easy was it to understand the rules?**
```
Very Confusing  1 --- 2 --- 3 --- 4 --- 5  Very Clear
```

**3. How strategic did the game feel?**
```
No Strategy  1 --- 2 --- 3 --- 4 --- 5  Deep Strategy
```

**4. Would you play this again?**
```
Never  1 --- 2 --- 3 --- 4 --- 5  Absolutely
```

---

#### **Section 2: Specific Feedback**

**5. What was the MOST FUN moment?**

```
_________________________________________________________________
```

**6. What was the MOST FRUSTRATING moment?**

```
_________________________________________________________________
```

**7. Which cards felt OVERPOWERED (too strong)?**

```
_________________________________________________________________
```

**8. Which cards felt USELESS (too weak)?**

```
_________________________________________________________________
```

**9. Was the game too easy, too hard, or just right?**

```
Too Easy  ○    Just Right  ○    Too Hard  ○
```

**10. Did you feel like your decisions mattered?**

```
Not at All  1 --- 2 --- 3 --- 4 --- 5  Very Much
```

---

#### **Section 3: Open Comments**

**11. What would you change about this game?**

```
_________________________________________________________________
_________________________________________________________________
```

**12. If this were a mobile game, would you download it?**

```
No  ○    Maybe  ○    Yes  ○    I'd pay for it  ○
```

**13. Any other thoughts?**

```
_________________________________________________________________
_________________________________________________________________
```

---

### Verbal Debrief Questions

**Ask after the form is filled out:**

1. **"Walk me through your deck-building process. How did you decide which cards to pick?"**
   - Goal: Understand decision-making

2. **"When you were at [specific node], why did you choose that option?"**
   - Goal: Validate that choices felt meaningful

3. **"If you could add ONE new card to the game, what would it do?"**
   - Goal: Identify missing mechanics

4. **"Was there ever a moment where you thought 'I wish I could do X'?"**
   - Goal: Find UX friction points

5. **"On a scale of 1-10, how likely are you to recommend this to a friend?"**
   - Goal: Net Promoter Score (NPS)

---

## 🔧 Common Issues & Solutions

### Problem: Players Don't Understand Turn Structure

**Symptoms:**
- Confusion about when to draw cards
- Playing cards at wrong times
- Forgetting to reset Energy

**Solutions:**
- Add turn tracker card (flip after each phase)
- Create visual flowchart reference
- Simplify turn structure (remove a phase?)

---

### Problem: Combat Too Easy

**Symptoms:**
- Enemies die in 1-2 turns
- Players never use Defense cards
- Players at full HP every fight

**Solutions:**
- Increase enemy HP by 30%
- Increase enemy Attack by +2
- Add more Combat nodes to path
- Reduce starting player HP by 2

---

### Problem: Combat Too Hard

**Symptoms:**
- Players die before Boss node
- Players forced to use all Defense cards
- Frustration instead of challenge

**Solutions:**
- Decrease enemy HP by 20%
- Decrease enemy Attack by -1
- Add more Memory nodes (safe Reverie collection)
- Increase starting player HP by 2
- Add healing Event cards

---

### Problem: Energy System Feels Bad

**Symptoms:**
- Players always have leftover Energy
- OR players always out of Energy
- Players saying "I can't do anything"

**Solutions (Too Much Energy):**
- Increase card costs by +1 across the board
- Reduce starting Energy to 2/turn
- Add more expensive cards (4-5 cost)

**Solutions (Too Little Energy):**
- Decrease card costs by -1
- Increase starting Energy to 4/turn
- Add Energy-generating cards

---

### Problem: Decks Feel Too Similar

**Symptoms:**
- All decks play the same way
- Players pick same cards every run
- Synergies never matter

**Solutions:**
- Boost synergy bonuses (+50% effect)
- Add restrictions (can't mix certain types)
- Create stronger archetype payoffs
- Add more unique card effects

---

### Problem: Runs Too Long

**Symptoms:**
- Players checking time
- Boredom in mid-game
- Sessions exceeding 40 minutes

**Solutions:**
- Reduce path to 8 nodes (from 10)
- Increase damage numbers (faster combat)
- Remove some Event nodes (slow)
- Speed up draw/discard phases

---

### Problem: Runs Too Short

**Symptoms:**
- Players want "just one more node"
- Feeling of abrupt ending
- Not enough time to build combos

**Solutions:**
- Extend path to 12 nodes
- Add more Combat variety
- Include mid-boss at node 6
- Slow down damage scaling

---

### Problem: No Replay Desire

**Symptoms:**
- Players don't want second run
- "I've seen everything"
- Lack of excitement

**Solutions:**
- Add more card variety (20+ new cards)
- Introduce random events with branching
- Create unlock progression (meta-game)
- Increase difficulty tiers (Easy/Normal/Hard)

---

## 📊 Data Tracking Sheet

### Track Across All Playtests

| Run # | Date | Tester | Deck Type | Result | HP Left | Reveries | Time (min) | Fun (1-5) | Issues |
|-------|------|--------|-----------|--------|---------|----------|------------|-----------|--------|
| 1 | 2/23 | Alice | Aggro | Win | 4 | 280 | 25 | 4 | Confused by Energy |
| 2 | 2/23 | Bob | Control | Loss | 0 | 150 | 32 | 3 | Enemies too strong |
| 3 | 2/24 | Carol | Economy | Win | 8 | 420 | 28 | 5 | None |
| ... | | | | | | | | | |

**Goal:** Collect 10+ runs to identify patterns

---

## 🎯 Success Metrics

### Minimum Viable Product (MVP) Targets

**Must achieve before moving to digital prototype:**

| Metric | Target | Status |
|--------|--------|--------|
| **Average Fun Rating** | ≥ 3.5/5 | ⬜ |
| **Rules Clarity** | ≥ 4.0/5 | ⬜ |
| **Win Rate** | 40-60% | ⬜ |
| **Session Length** | 20-30 min | ⬜ |
| **Replay Desire** | ≥ 4.0/5 | ⬜ |
| **Would Recommend** | ≥ 70% | ⬜ |

**If all targets met:** ✅ Proceed to digital prototype  
**If any target missed:** 🔄 Iterate and retest

---

## 🔄 Iteration Process

### After Each Playtest Session

1. **Review Feedback Forms** (10 min)
   - Calculate average scores
   - Identify common complaints
   - Note surprising insights

2. **Update Balance Spreadsheet** (15 min)
   - Adjust card values
   - Modify enemy stats
   - Recalculate difficulty curve

3. **Document Changes** (5 min)
   - Log what was changed and why
   - Version control (v1.1, v1.2, etc.)

4. **Reprint Updated Cards** (20 min)
   - Only reprint changed cards
   - Mark version number on back

5. **Test Again** (next session)
   - Repeat with same or new playtesters
   - Compare results to previous version

### Version Control Example

```
v1.0 (Initial) - Feb 23, 2026
- 85 cards, 10-node path
- Starting HP: 10, Energy: 3

v1.1 (Balance Pass 1) - Feb 24, 2026
- Increased enemy HP by 20%
- Reduced [Oblivion Strike] cost to 4 (from 5)
- Added 3 new Defense cards

v1.2 (Balance Pass 2) - Feb 25, 2026
- Path reduced to 8 nodes (faster runs)
- Buffed Collection cards (+5 Reveries each)
- Nerfed [Dream Ender] (10 HP threshold → 5 HP)
```

---

## 🧪 Advanced Playtest Scenarios

### Scenario 1: Speed Run Challenge

**Goal:** Test if aggression is viable

**Rules:**
- Complete run in under 15 minutes
- Must use Attack-heavy deck (8+ Attack cards)
- No Defense cards allowed

**Success:** Win with 20%+ HP remaining  
**Failure:** Death or time exceeded

---

### Scenario 2: Pacifist Run

**Goal:** Test if avoiding combat is viable

**Rules:**
- Use Economy deck (8 Collection cards)
- Avoid all Combat nodes (if possible via Events)
- Goal: Maximize Reveries, minimize damage taken

**Success:** 500+ Reveries earned  
**Failure:** Forced into combat and die

---

### Scenario 3: No-Damage Run

**Goal:** Test Defense card power

**Rules:**
- Complete run without taking any damage
- Defense-heavy deck (6+ Defense cards)

**Success:** Perfect victory (100% HP)  
**Failure:** Any HP loss

---

### Scenario 4: Chaos Mode

**Goal:** Test with broken rules

**Rules:**
- Infinite Energy (test card balance without cost limits)
- Draw 10 cards per turn (test combo potential)

**Observation:** Which cards become overpowered?

---

## 📚 Appendix: Playtester Profiles

### Recruit Different Player Types

| Type | Description | Testing Value |
|------|-------------|---------------|
| **Spike** | Competitive, optimization-focused | Tests balance, finds exploits |
| **Timmy** | Loves big plays, dramatic moments | Tests fun factor, excitement |
| **Johnny** | Enjoys combos, creative strategies | Tests synergies, depth |
| **Casual** | Plays for relaxation, not challenge | Tests accessibility, clarity |
| **Non-Gamer** | No card game experience | Tests tutorial, onboarding |

**Ideal Mix:** 2 Spikes, 2 Timmys, 1 Johnny, 2 Casuals, 1 Non-Gamer

---

## 🎬 Sample Playtest Video Checklist

**If recording video for remote review:**

- [ ] **Intro:** State date, version, tester name
- [ ] **Setup:** Show full game board, cards, tokens
- [ ] **Play:** Capture entire run (unedited)
- [ ] **Think-Aloud:** Ask tester to narrate decisions
- [ ] **Debrief:** Record verbal feedback session
- [ ] **Close:** Summarize key takeaways

**Upload to:** Shared drive for team review

---

## 🏁 Final Playtest Report Template

**After 10+ playtests, compile results:**

---

### Dream Collector - Playtest Summary Report

**Testing Period:** Feb 23 - Mar 5, 2026  
**Total Runs:** 15  
**Unique Testers:** 8  
**Version Tested:** v1.3

---

#### **Quantitative Results**

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Average Fun | ≥ 3.5 | 4.2 | ✅ Pass |
| Rules Clarity | ≥ 4.0 | 3.8 | ⚠️ Close |
| Win Rate | 40-60% | 53% | ✅ Pass |
| Session Length | 20-30 min | 26 min | ✅ Pass |
| Replay Desire | ≥ 4.0 | 4.5 | ✅ Pass |

---

#### **Qualitative Insights**

**Top 3 Strengths:**
1. Synergy combos felt rewarding
2. Deck building choices were meaningful
3. Boss battles were climactic

**Top 3 Weaknesses:**
1. Turn structure still confusing for new players
2. Some cards never used (weak)
3. Mid-game pacing sags at nodes 5-7

---

#### **Most Changed Elements**

| Element | Original | Final | Reason |
|---------|----------|-------|--------|
| Starting HP | 10 | 8 | Easier difficulty |
| Path Length | 10 nodes | 8 nodes | Faster runs |
| [Oblivion Strike] | 5 cost | 3 cost | Too expensive |
| Enemy HP | Base 15 | Base 20 | Too easy |

---

#### **Recommendations for Digital Build**

**High Priority:**
- ✅ Core mechanics validated - proceed to digital
- ⚠️ Simplify turn structure (merge phases 2-3)
- ⚠️ Rebalance 5 weak cards (see list)

**Medium Priority:**
- Add mid-boss at node 5 (break up pacing)
- Create interactive tutorial (onboarding)
- Add 10 more cards for variety

**Low Priority:**
- Polish flavor text
- Add visual effects for combos
- Implement idle progression simulation

---

#### **Go/No-Go Decision**

**Recommendation:** ✅ **PROCEED TO DIGITAL PROTOTYPE**

**Justification:**
- All critical metrics met or exceeded
- Core loop validated as fun and strategic
- Balance issues are addressable in digital build
- Replay desire indicates long-term potential

**Next Steps:**
1. Select game engine (Unity vs Godot)
2. Prototype core card system (Week 1)
3. Implement combat (Week 2)
4. Playtest digital build (Week 3)

---

_Report compiled by: [Your Name]_  
_Date: March 5, 2026_

---

## 🎓 Conclusion

This playtest guide provides a structured approach to validating **Dream Collector's** paper prototype. Follow the phases, track metrics, and iterate based on feedback.

**Remember:**
- Playtesting is about learning, not proving you're right
- Negative feedback is MORE valuable than positive
- One confused player represents 100 confused players
- Iterate quickly, test often

**Good luck, and may your dreams be balanced!** ✨

---

**Document Version:** 1.0  
**Last Updated:** February 23, 2026  
**Status:** Ready for alpha testing

---

_Playtest Guide © GeekBrox 2026 | Dream Collector Paper Prototype_
