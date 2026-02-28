# Dungeon Parasite (던전 기생충)
## Game Design Document

**Version:** 1.0  
**Date:** February 20, 2026  
**Genre:** Roguelike Deck-builder / Parasitic Strategy  
**Platform:** PC (Primary), Console (Future)  
**Target Audience:** 16+, fans of Slay the Spire, Inscryption, Monster Train

---

## Table of Contents

1. [High Concept](#high-concept)
2. [Core Loop](#core-loop)
3. [Mechanics Deep Dive](#mechanics-deep-dive)
4. [Balancing Framework](#balancing-framework)
5. [Story Overview](#story-overview)
6. [Art Style Guide](#art-style-guide)
7. [Sound Direction](#sound-direction)
8. [Technical Considerations](#technical-considerations)

---

## High Concept

**Dungeon Parasite** is a dark roguelike deck-builder where you play as a parasitic entity that infests and controls dungeon monsters. Instead of fighting monsters, you *become* them—hijacking their abilities, mutating their forms, and consuming their essence to build an ever-evolving deck of monstrous powers.

**Core Pillars:**
- **Parasitic Possession:** Switch between host bodies mid-combat
- **Infection & Mutation:** Transform enemies into grotesque allies
- **Resource Cannibalism:** Consume defeated hosts for permanent upgrades
- **Adaptive Deck Evolution:** Cards change based on which body you inhabit

**Unique Selling Points:**
1. Body-swapping mid-combat creates tactical depth beyond traditional deck-builders
2. Cards have dual states (parasite form vs. host form)
3. Permanent consequences—consumed hosts can't be possessed again
4. Asymmetric difficulty: you start weak but grow exponentially

---

## Core Loop

### Macro Loop (Run Structure)

```
START RUN → Possess Starting Host → Navigate Dungeon Floors → 
Combat/Events → Consume/Preserve Hosts → Boss Fight → 
Ascend/Descend → Meta Progression → START RUN
```

**Floor Progression:**
- 8 floors per dungeon layer
- Floor types: Combat (60%), Elite (15%), Shop (10%), Event (15%)
- Boss every 8th floor
- 3 dungeon layers (24 floors total for full run)

### Micro Loop (Single Combat)

```
Combat Start → Choose Active Host → Play Cards → 
Enemy Turn → Assess Threats → 
Switch Host (if available) OR Infect New Enemy → 
Resolve Combat → Harvest/Preserve Decision
```

**Turn Structure:**
1. **Parasite Phase** (Your Turn)
   - Draw 5 cards (+ bonuses from host)
   - Gain 3 energy (+ bonuses)
   - Play cards from parasite deck + active host deck
   - Use host-specific abilities
   - Can attempt infection once per turn (costs energy)

2. **Enemy Phase**
   - Enemies act in initiative order
   - Your active host takes damage
   - Infected enemies obey your commands

3. **End Phase**
   - Check host integrity (if HP ≤ 0, forced ejection)
   - Decay effects tick
   - Draw next hand

### Meta Progression Loop

```
Complete Run → Unlock Parasite Strains → 
Unlock Mutation Trees → Gain Research Points → 
Unlock New Starting Hosts → Unlock Dungeon Modifiers
```

---

## Mechanics Deep Dive

### 1. Possession System

**Host Integrity (HP):**
- Each host has base HP (50-200 depending on tier)
- When host HP = 0, parasite is ejected
- Ejected parasite: 20 HP, vulnerable state
- Must infect new host within 2 turns or lose run

**Host Categories:**

| Tier | Examples | Base HP | Deck Size | Special |
|------|----------|---------|-----------|---------|
| Fodder | Goblin, Rat, Imp | 50 | 4 cards | Disposable |
| Standard | Skeleton, Orc, Wolf | 100 | 6 cards | Balanced |
| Elite | Minotaur, Gargoyle | 150 | 8 cards | Unique mechanics |
| Boss | Dragon, Lich | 200 | 10 cards | Ultimate abilities |

**Possession Mechanics:**
- **Infection Roll:** Base 60% success chance
  - +10% per turn target is damaged
  - -20% if target is Elite tier or higher
  - Can be boosted by parasite mutations
  
- **Control Duration:** Permanent until host is destroyed or consumed

- **Multi-Host Management:**
  - Start with 1 host slot
  - Unlock up to 3 host slots through upgrades
  - Can switch active host once per turn (costs 1 energy)
  - Inactive hosts don't take damage but can't act

### 2. Dual-Deck System

**Parasite Core Deck:**
- 15 cards at run start
- Represents your true abilities (independent of host)
- Examples:
  - *"Tendril Strike"* - Deal 6 damage, if kills enemy, attempt infection
  - *"Neural Hijack"* - Take control of enemy for 1 turn
  - *"Metabolic Surge"* - Drain 10 HP from host, gain 2 energy

**Host Deck:**
- Each possessed body adds 4-10 cards to draw pool
- Cards only available when that host is active
- Examples (Skeleton Host):
  - *"Bone Spear"* - Deal 8 damage
  - *"Death Rattle"* - When host dies, deal 15 damage to all enemies
  - *"Reassemble"* - Restore 20 HP to this host

**Deck Merging Rules:**
- Draw from combined parasite + active host deck
- Hand size: 5 base (+ host bonuses)
- Can upgrade parasite cards at campfires
- Host cards upgrade automatically when host "evolves"

### 3. Mutation & Evolution

**Mutation Points (MP):**
- Earned by consuming hosts (+3 MP per host)
- Earned by defeating elites (+5 MP)
- Spent on parasite evolution tree

**Mutation Trees (3 Branches):**

**A. Predator Path** (Aggressive)
- Tier 1: +20% infection chance
- Tier 2: Gain 5 HP when consuming hosts
- Tier 3: "Apex Predator" - Can possess Boss-tier enemies
- Ultimate: "Hivemind" - Control 2 hosts simultaneously

**B. Symbiote Path** (Defensive)
- Tier 1: Hosts retain 50% HP when switching
- Tier 2: +1 host slot
- Tier 3: "Regeneration" - Active host heals 5 HP per turn
- Ultimate: "Perfect Union" - Merge two hosts into one super-host

**C. Mutant Path** (Chaos)
- Tier 1: Random mutation on host possession
- Tier 2: Infecting enemy adds random host card to deck
- Tier 3: "Genetic Instability" - Cards have random upgraded effects
- Ultimate: "Abomination" - Transform into true form (discard all hosts, gain massive power)

### 4. Resource Economy

**Primary Resources:**

1. **Energy:** 3 per turn (standard deck-builder economy)
   - Most cards cost 0-3 energy
   - Powerful host abilities cost 4-5

2. **Host Integrity (HP):** Your defensive resource
   - Manage multiple hosts like a "HP pool rotation"
   - Risk/reward: keep damaged host or switch?

3. **Mutation Points:** Long-term progression currency
   - Carry over between runs
   - Unlock permanent parasite upgrades

4. **Infection Biomass:** Combat-specific resource
   - Gain 1 per enemy killed
   - Spend to boost infection attempts or heal hosts

**Resource Conversion:**
- Consume host: +3 MP, +1 biomass, remove host cards from deck
- Preserve host: Keep host cards, can re-summon later in run
- Sacrifice host: Deal damage equal to host's current HP to all enemies

### 5. Combat Scenarios

**Example Combat Flow:**

**Turn 1:**
- Active Host: Skeleton Warrior (100 HP)
- Hand: 3 Parasite cards, 2 Skeleton cards
- Enemies: 2 Goblins (30 HP each), 1 Orc Brute (80 HP)
- Play "Bone Spear" (8 dmg) → Kill Goblin 1 (+1 biomass)
- Play "Tendril Strike" (6 dmg) → Damage Goblin 2, attempt infection (success!)
- Now control: Skeleton + Goblin

**Turn 2:**
- Switch active host to Goblin (40 HP)
- Command Skeleton to attack Orc (using Goblin deck cards)
- Goblin deck has "Swarm Tactics" - Deal 4 dmg, if you control 2+ units, repeat
- Chain attacks with both hosts

**Turn 3:**
- Orc drops to 20 HP
- Play "Neural Hijack" - Take control of Orc for 1 turn
- Use Orc to attack itself
- Finish with Skeleton, gain Orc as potential possession target

**Post-Combat:**
- Decision: Consume Skeleton for MP, or preserve for next combat?
- If consumed: +3 MP, lose "Bone Spear" and "Death Rattle" from deck

---

## Balancing Framework

### Difficulty Scaling

**Enemy Scaling (Per Floor):**
- Floor 1-4: Tier 1 enemies (HP: 20-50, Damage: 3-6)
- Floor 5-8: Tier 2 enemies (HP: 60-120, Damage: 8-12)
- Floor 9-16: Tier 3 enemies (HP: 100-180, Damage: 10-18)
- Floor 17-24: Tier 4 enemies (HP: 150-300, Damage: 15-25)

**Boss Difficulty:**
- Layer 1 Boss: 300 HP, multi-phase, summons minions
- Layer 2 Boss: 500 HP, infection resistance, area attacks
- Layer 3 Boss: 800 HP, adaptive AI, anti-parasite mechanics

### Power Curve

**Player Power Trajectory:**

| Floor Range | Expected Hosts | Avg Deck Size | Damage Per Turn | Host HP Pool |
|-------------|---------------|---------------|-----------------|--------------|
| 1-4 | 1 | 15-20 cards | 20-30 | 100 |
| 5-8 | 1-2 | 20-30 cards | 40-60 | 200 |
| 9-16 | 2-3 | 30-45 cards | 70-100 | 350 |
| 17-24 | 3-4 | 45-60 cards | 120-180 | 550 |

**Balancing Levers:**

1. **Infection Success Rate:**
   - Base: 60%
   - With upgrades: 75-90%
   - Elite enemies: -20% penalty
   - Bosses: -40% penalty (requires specific mutations)

2. **Card Power Budget:**
   - Common card value: ~1.5 damage per energy
   - Uncommon: ~2.0 damage per energy
   - Rare: ~2.5 damage per energy + utility
   - Host-specific cards: 20% stronger but locked to that host

3. **Consumption vs. Preservation:**
   - Consuming grants immediate power (MP)
   - Preserving grants versatility (more deck options)
   - Target ratio: Consume 60%, Preserve 40%

4. **Energy Economy:**
   - Average hand should use 3-4 energy
   - 20% of cards should be 0-cost (fodder)
   - 5% of cards should be high-cost (finishers)

### Anti-Frustration Measures

1. **Guaranteed Infection:** First infection attempt each combat has 100% success
2. **Emergency Host:** If ejected with no valid targets, spawn a weak "Larva" host
3. **Deck Bloat Protection:** Max deck size 60 cards, auto-condense at campfires
4. **Bad Luck Protection:** After 3 failed infections, +10% per additional failure

---

## Story Overview

### Premise

You are **The Progenitor**, an ancient parasitic consciousness sealed in the deepest dungeon layer for eons. Adventurers seeking treasure have weakened your prison. You escape in larval form, beginning a journey upward through the dungeon to reach the surface world—not for conquest, but for **understanding**.

You are not evil. You are **hungry**. You are **curious**. You are **survival**.

### Narrative Structure

**Act I: Awakening (Floors 1-8)**
- Learn to possess weak dungeon creatures
- Discover fragmented memories within consumed hosts
- Hint at larger threat: the dungeon itself is dying
- Boss: **The Warden** - A construct designed to keep you imprisoned

**Act II: Ascension (Floors 9-16)**
- Possess more intelligent creatures (orcs, dark elves)
- Gain glimpses of their thoughts and fears
- Revelation: Adventurers are not explorers, they're **harvesters**
- The dungeon is a farm for cultivating "monster essence"
- Boss: **The Harvester Captain** - A human commander

**Act III: Emergence (Floors 17-24)**
- Reach upper dungeon, closer to surface
- Possess fallen adventurers (moral complexity!)
- Learn the truth: Surface world is in ecological collapse
- Dungeons were created to store/preserve extinct species as monsters
- You are the immune system of a dying archive
- Final Boss: **The Architect** - Creator of the dungeon system

### Ending Variations

**Ending A: Consumption**
- Kill the Architect, consume all, become god-parasite
- Surface world overrun by you
- Dark ending: You become the new threat

**Ending B: Symbiosis**
- Merge with the Architect's consciousness
- Understand the purpose, agree to become new dungeon guardian
- Neutral ending: You replace what you destroyed

**Ending C: Liberation**
- Reject both consumption and imprisonment
- Free all dungeon entities, break the cycle
- Good ending: Unknown consequences, but freedom

### Environmental Storytelling

**Lore Delivery Methods:**
1. **Memory Echoes:** Consuming hosts grants brief flashbacks
2. **Dungeon Tablets:** Lore rooms with story fragments
3. **Boss Dialogues:** Each boss represents a philosophical stance
4. **Host Inner Monologue:** Possessed creatures have thoughts/fears

**Themes:**
- Parasitism vs. Symbiosis
- Consciousness and identity (you are what you consume)
- Ecological preservation vs. freedom
- The morality of survival

---

## Art Style Guide

### Visual Identity

**Core Aesthetic:** **Biopunk Horror meets Dark Fantasy**

- Inspiration: *Darkest Dungeon* meets *Hollow Knight* meets *Carrion*
- Tone: Grotesque but beautiful, horrifying but fascinating
- Color palette: Deep purples, sickly greens, blood reds, bone whites

### Parasite Design (Your True Form)

**Visual Language:**
- Translucent, jellyfish-like core
- Writhing tendrils/cilia
- Bioluminescent nerve patterns
- Fractal, organic geometry
- No eyes, but "senses" shown through pulsing light

**Evolution Stages:**
1. **Larva:** Tiny, fetal, vulnerable (3-4 tendrils)
2. **Juvenile:** Cat-sized, more tendrils, faintly glowing (8-10 tendrils)
3. **Mature:** Human torso-sized, complex neural web, bright bioluminescence
4. **Progenitor:** Massive, cathedral-like, reality-warping presence

### Host Transformations

**Infection Visual Progression:**

**Stage 1: Fresh Possession (Turn 1-3)**
- Subtle veins of purple under skin
- Eyes glow faintly
- Movements slightly jerky (fighting control)

**Stage 2: Integrated (Turn 4-8)**
- Veins spread across body
- Tendrils emerge from wounds
- Host gains unnatural flexibility

**Stage 3: Mutated (Turn 9+)**
- Host body warps and twists
- Extra limbs/eyes/mouths appear
- Fully grotesque, barely recognizable

### UI/UX Art Direction

**Card Design:**
- Hand-drawn, sketch-like borders
- Parasitic motifs (tendrils framing art)
- Dual-state cards show "before/after" infection
- Animated parasitic growth on card upgrades

**Color Coding:**
- **Parasite cards:** Purple glow, tendril borders
- **Host cards:** Color-coded by host type (bone white for undead, blood red for beasts, etc.)
- **Infection cards:** Pulsing green-yellow toxicity

**Typography:**
- Header font: Angular, sharp (like chitin)
- Body text: Organic, slightly distorted
- Flavor text: Italic, whispered memories

### Environmental Art

**Dungeon Layers:**

**Layer 1: The Deep Tombs**
- Aesthetics: Ancient stone, bioluminescent fungi
- Lighting: Dim blue-green
- Enemies: Skeletons, rats, slimes
- Mood: Claustrophobic, primordial

**Layer 2: The Living Quarters**
- Aesthetics: Ruined architecture, monster nests
- Lighting: Firelight, flickering torches
- Enemies: Orcs, goblins, dark elves
- Mood: Contested territory, war-torn

**Layer 3: The Surface Threshold**
- Aesthetics: Crystalline formations, magical wards
- Lighting: Harsh white light (surface sun bleeding through)
- Enemies: Constructs, corrupted adventurers, guardians
- Mood: Sterile, oppressive, artificial

### Animation Principles

1. **Parasite Movement:** Fluid, undulating, hypnotic
2. **Possession Moment:** Explosive tendril burst, host convulses
3. **Host Death:** Parasite extraction (graphic but stylized)
4. **Mutation:** Bone-cracking, flesh-rippling body horror
5. **Card Play:** Parasite extends from host to enact effect

---

## Sound Direction

### Audio Pillars

1. **Organic Horror:** Wet, visceral, biological sounds
2. **Alien Intelligence:** Unsettling, non-human tones
3. **Tactical Clarity:** Clear audio feedback for game states
4. **Atmospheric Immersion:** Dripping dungeon ambience

### Music Direction

**Composer Reference:** Austin Wintory (Journey), Darren Korb (Hades), but darker

**Instrumentation:**
- Primary: Cello (deep, mournful)
- Secondary: Prepared piano (percussive, eerie)
- Accent: Theremin/synth (alien, unsettling)
- Texture: Waterphone, bowed cymbals (horror)

**Musical Themes:**

**Main Theme: "The Progenitor"**
- Tempo: Slow, 60 BPM
- Feel: Melancholic, ancient, patient
- Progression: Starts minimal, builds with each layer ascended
- Leitmotif: Descending minor thirds (represents downward origin, upward journey)

**Combat Music Tiers:**
- **Fodder Fights:** Minimal percussion, ambient drones
- **Elite Fights:** Full instrumentation, rhythmic intensity
- **Boss Fights:** Unique themes per boss, memorable melodies

**Dynamic Music System:**
- Intensity layers based on host HP
- Infection success triggers harmonic resolution
- Host death triggers dissonant breakdown
- New possession triggers fresh musical phrase

### Sound Effects

**Parasite Actions:**

| Action | Sound Description | Reference |
|--------|------------------|-----------|
| Tendril attack | Wet whip-crack + electrical snap | - |
| Infection attempt | Squelching penetration + host gasp | *Carrion* infection |
| Possession success | Organic crunch + neural pulse | Synthesized whale song (pitched down) |
| Host switch | Fluid transition + bone crack | - |
| Consumption | Digestive gurgling + energy absorption hum | *Dead Space* necro sounds |

**Host-Specific Sounds:**

- **Skeleton:** Dry bone clatter, hollow impacts
- **Beast:** Guttural growls, heavy breathing
- **Undead:** Moaning, decayed vocals
- **Construct:** Mechanical grinding, magical hum

**UI Sounds:**

- **Card draw:** Soft organic rustle (like membrane unfurling)
- **Card play:** Distinct tone per card type (parasite = low, host = mid-high)
- **Energy gain:** Bioluminescent chime
- **Host death warning:** Heartbeat-like pulsing (increases tempo as HP drops)

### Ambient Soundscapes

**Layer 1 Ambience:**
- Distant dripping water
- Stone settling/creaking
- Faint chittering (other parasites?)
- Low-frequency rumble (dungeon breathing)

**Layer 2 Ambience:**
- Distant combat sounds
- Monster vocalizations
- Torch crackling
- Wind through corridors

**Layer 3 Ambience:**
- Magical hum of wards
- Crystalline resonance
- Surface world sounds bleeding through (birds? wind?)
- Oppressive silence (unnatural stillness)

### Voice Direction

**Parasite Voice:**
- **Processed:** Layered whispers (male + female + child vocals)
- **Effect:** Heavy reverb, slight pitch shift down
- **Tone:** Curious, ancient, neither malicious nor benign
- **Language:** Minimal dialogue, mostly reactive (grunts of effort, gasps of pain)

**Host Voices:**
- **Pre-possession:** Normal monster sounds
- **During possession:** Distorted version of original voice + parasitic undertone
- **Full mutation:** Completely replaced by parasite voice

**Boss Dialogues:**
- **The Warden:** Robotic, emotionless
- **The Harvester Captain:** Gruff, militaristic
- **The Architect:** Calm, philosophical, melancholic

**Narration:**
- **Style:** Second-person, rare, poetic
- **Voice:** Same as parasite (processed whispers)
- **Triggers:** Major story beats, endings

---

## Technical Considerations

### Core Systems

**Tech Stack Recommendations:**
- **Engine:** Unity or Godot (2D focus)
- **Language:** C# (Unity) or GDScript (Godot)
- **Art:** Spine for animations (or Unity built-in)
- **Audio:** FMOD or Wwise for dynamic music

**Key Technical Features:**

1. **Dynamic Deck Manager**
   - Real-time deck merging (parasite + active host)
   - Efficient card filtering based on active host state
   - Card upgrade state tracking per host

2. **Host State System**
   - Multiple host instances with independent HP/status
   - Host swapping with transition animations
   - Host mutation data structure (visual + mechanical changes)

3. **Infection Probability Engine**
   - Calculate infection chance based on multiple modifiers
   - Visual feedback for success probability
   - RNG seeding for run consistency

4. **Procedural Dungeon Generation**
   - Floor layout templates (combat, elite, shop, event distribution)
   - Enemy composition tables per floor tier
   - Branching paths with risk/reward balance

5. **Mutation Tree Unlocks**
   - Persistent progression database (SQLite or JSON)
   - Unlock conditions tracking
   - Mutation synergy calculator

### Performance Targets

- **Target Frame Rate:** 60 FPS (not demanding, turn-based)
- **Load Times:** <3 seconds between floors
- **Memory Footprint:** <2 GB RAM
- **Save File Size:** <5 MB (run state + meta progression)

### Accessibility Features

1. **Colorblind Modes:** Icon-based card identification (not just color)
2. **Font Scaling:** Adjustable UI text size
3. **Audio Cues:** Screen reader support for card text
4. **Difficulty Options:** Adjustable infection rates, starting HP
5. **Speed Controls:** Animation speed sliders

### Monetization (If Applicable)

**Premium Model Recommended:**
- **Base Game:** $19.99 USD
- **DLC Potential:** New parasite strains, dungeon layers, challenge modes
- **No MTX:** Avoid pay-to-win, preserve game balance

**Post-Launch Content:**
- **Free Updates:** Balance patches, QoL improvements
- **Paid Expansion:** "Surface World" act (6-12 months post-launch)

---

## Development Roadmap (Suggested)

### Phase 1: Vertical Slice (3-4 months)
- Core combat system (1 parasite strain, 3 host types)
- 8 floors (Layer 1 only)
- 30 cards total (15 parasite, 15 distributed among hosts)
- 1 boss fight
- Basic UI/UX
- Placeholder art/audio

### Phase 2: Content Expansion (4-6 months)
- Add Layers 2 & 3 (24 floors total)
- Expand to 100+ cards
- Implement mutation trees (3 full branches)
- 10+ host types
- First pass art and animation
- Dynamic music system

### Phase 3: Polish & Balance (2-3 months)
- Full art pass (all environments, characters)
- Complete audio implementation
- Balance tuning (playtest extensively)
- Story integration (dialogues, lore)
- Accessibility features
- Steam integration

### Phase 4: Launch & Support (Ongoing)
- Day 1 patch readiness
- Community feedback integration
- Post-launch balance updates
- DLC planning

**Total Estimated Dev Time:** 12-16 months (small team of 3-5)

---

## Appendix: Sample Cards

### Parasite Core Cards

**"Invasive Strike"**
- Cost: 1 Energy
- Effect: Deal 8 damage. If this kills an enemy, attempt to infect their corpse (revive as host).
- Upgrade: Deal 12 damage.

**"Metabolic Drain"**
- Cost: 2 Energy
- Effect: Drain 15 HP from active host. Gain 2 energy and draw 1 card.
- Upgrade: Drain 15 HP from active host. Gain 3 energy and draw 2 cards.

**"Parasitic Bond"**
- Cost: 1 Energy
- Effect: Transfer 10 HP from one host to another.
- Upgrade: Transfer 15 HP. If target host is damaged, also draw 1 card.

**"Hive Mind"**
- Cost: 3 Energy
- Effect: All your hosts attack the same target for 6 damage each.
- Upgrade: All your hosts attack for 9 damage each.

**"Forced Evolution"**
- Cost: 2 Energy (Exhaust)
- Effect: Mutate active host. Gain 1 random upgraded host card permanently.
- Upgrade: Gain 2 random upgraded host cards.

### Host-Specific Cards (Examples)

**Skeleton Warrior Cards:**

**"Bone Spear"**
- Cost: 1 Energy
- Effect: Deal 8 damage.
- Upgrade: Deal 12 damage.

**"Death Rattle"**
- Cost: 2 Energy
- Effect: When this host dies, deal 15 damage to all enemies.
- Upgrade: Deal 25 damage.

**Goblin Swarm Cards:**

**"Swarm Tactics"**
- Cost: 0 Energy
- Effect: Deal 4 damage. If you control 2+ hosts, repeat this card.
- Upgrade: Deal 6 damage.

**"Desperate Bite"**
- Cost: 1 Energy
- Effect: Deal 6 damage. If this host is below 50% HP, deal 12 instead.
- Upgrade: Deal 10 damage, or 18 if below 50% HP.

**Orc Brute Cards:**

**"Crushing Blow"**
- Cost: 2 Energy
- Effect: Deal 14 damage. This host takes 5 damage.
- Upgrade: Deal 20 damage. This host takes 5 damage.

**"Blood Frenzy"**
- Cost: 1 Energy
- Effect: Gain +3 damage on all attacks this turn for each 10 HP this host is missing.
- Upgrade: Gain +5 damage per 10 HP missing.

---

## Closing Notes

**Dungeon Parasite** aims to innovate within the roguelike deck-builder space by introducing asymmetric resource management (hosts as rotating HP pools), emergent storytelling (through consumed memories), and morally complex themes (parasitism as survival, not evil).

The game's difficulty should feel like **growing from insignificant to inevitable**—starting as a fragile larva and ending as an unstoppable force of nature, but with meaningful choices at every step.

**Design Philosophy:**
- **"Every host is a tool, a story, and a sacrifice."**
- Encourage experimentation with host combinations.
- Punish reckless consumption (deck bloat, lost opportunities).
- Reward strategic preservation (versatile options, combo potential).

**Core Question for Players:**
*"What are you willing to consume to survive?"*

---

**Document Status:** Draft v1.0  
**Next Steps:**
1. Create prototype combat system
2. Playtest infection mechanics for fun/frustration balance
3. Develop 3-5 sample host types with full card sets
4. Commission concept art for parasite evolution stages

**Contact:** [Your Studio/Team Name]  
**Last Updated:** 2026-02-20
