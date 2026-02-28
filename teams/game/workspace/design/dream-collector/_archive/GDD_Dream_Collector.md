# 꿈 수집가 (Dream Collector)
## Game Design Document v1.0

**Document Date:** February 20, 2026  
**Genre:** Adventure / Puzzle / Exploration  
**Platform:** PC, Mobile (iOS/Android)  
**Target Audience:** Ages 12+, fans of atmospheric puzzle games  
**Estimated Play Time:** 8-12 hours (main story), 15-20 hours (100% completion)

---

## Table of Contents
1. [High Concept](#high-concept)
2. [Core Gameplay Loop](#core-gameplay-loop)
3. [Mechanics Design](#mechanics-design)
4. [Balancing Framework](#balancing-framework)
5. [Story Overview](#story-overview)
6. [Art Style Guide](#art-style-guide)
7. [Sound Direction](#sound-direction)
8. [Progression Systems](#progression-systems)
9. [Technical Specifications](#technical-specifications)

---

## High Concept

**One-Liner:** *Enter the dreams of sleeping souls, collect their forgotten memories, and piece together the mystery of the Dreamscape.*

Players take on the role of a Dream Collector—a mysterious entity who travels through the subconscious minds of sleeping people, gathering fragmented dream memories (called "Reveries"). These collected dreams unlock new abilities, reveal hidden stories, and gradually unveil the truth about the player's own forgotten past.

**Core Pillars:**
- **Exploration:** Navigate surreal, ever-changing dreamscapes
- **Collection:** Gather and catalog unique dream fragments
- **Puzzle-Solving:** Use collected abilities to overcome dream-logic obstacles
- **Narrative:** Uncover interconnected stories through collected memories

---

## Core Gameplay Loop

### Primary Loop (Session: 15-30 minutes)

```
1. SELECT DREAMER
   ↓
2. ENTER DREAMSCAPE
   ↓
3. EXPLORE & NAVIGATE
   ↓
4. ENCOUNTER OBSTACLES/PUZZLES
   ↓
5. USE COLLECTED ABILITIES
   ↓
6. DISCOVER REVERIES (Dream Fragments)
   ↓
7. COLLECT REVERIE
   ↓
8. RETURN TO ARCHIVE
   ↓
9. CATALOG & PROCESS REVERIE
   ↓
10. UNLOCK NEW ABILITIES/DREAMERS
    ↓
    (Loop back to 1)
```

### Secondary Loop (Meta-Progression)

```
COLLECT REVERIES → COMPLETE DREAM SETS → UNLOCK STORY CHAPTERS → 
GAIN PERMANENT ABILITIES → ACCESS DEEPER DREAMSCAPES → 
DISCOVER COLLECTOR'S PAST
```

### Session Structure

**Act 1: Selection (1-2 min)**
- Browse available Dreamers in the Archive
- Review Dreamer profile (personality, fears, desires)
- Select target Dreamer

**Act 2: Immersion (10-20 min)**
- Enter Dreamscape with unique visual theme
- Navigate surreal environments
- Solve 2-4 puzzles using dream logic
- Encounter 1-2 Reverie fragments
- Optional: Find hidden secrets/collectibles

**Act 3: Collection (2-5 min)**
- Trigger Reverie collection sequence
- Mini-puzzle or challenge to extract the Reverie
- Return to Archive (graceful exit)

**Act 4: Cataloging (3-5 min)**
- Place Reverie in Archive collection
- Read/experience the memory fragment
- Check completion progress
- Unlock rewards (abilities, new Dreamers, story)

---

## Mechanics Design

### 1. Dream Navigation

**Movement System:**
- **Walk/Float:** Standard movement, affected by dream-physics (lighter gravity, momentum shifts)
- **Dream Dash:** Quick burst movement, leaves ethereal trail
- **Phase Shift:** Toggle between "solid" and "ethereal" states to pass through certain objects
- **Anchor Points:** Grapple to floating memories to swing/pull yourself

**Camera:**
- Third-person perspective, 3/4 view
- Dynamic camera that tilts/rotates based on dreamscape gravity
- Smooth transitions during reality shifts

### 2. Reverie Collection

**Types of Reveries:**

| Type | Rarity | Effect | Collection Method |
|------|--------|--------|-------------------|
| Memory Shard | Common | Story fragments | Simple interaction |
| Emotion Echo | Uncommon | Unlock abilities | Solve emotion puzzle |
| Nightmare Fragment | Rare | Boss challenges | Combat/stealth sequence |
| Core Dream | Epic | Major story reveal | Complex multi-stage puzzle |
| Hidden Whisper | Secret | Lore/Easter eggs | Environmental discovery |

**Collection Mechanics:**
1. **Approach:** Reveries appear as glowing, distorted objects
2. **Attunement:** Hold interaction button, match rhythm mini-game
3. **Extraction:** Quick-time event or puzzle sequence (varies by type)
4. **Integration:** Reverie flows into player, visual feedback

### 3. Ability System

**Starter Abilities:**
- **Dream Sight:** Reveal hidden paths and objects
- **Memory Echo:** Replay recent events in the environment
- **Whisper:** Communicate with dream entities

**Unlockable Abilities (Collected from Reveries):**

| Ability | Source | Use Case |
|---------|--------|----------|
| Time Fracture | Anxiety Dreams | Slow/reverse time in localized area |
| Shape Shift | Identity Dreams | Transform into objects seen in the dream |
| Lucid Touch | Creative Dreams | Manipulate dream matter (move/create platforms) |
| Nightmare Ward | Fear Dreams | Protect from hostile dream entities |
| Memory Weave | Nostalgia Dreams | Connect disparate objects to create new paths |
| Void Step | Loss Dreams | Teleport short distances through rifts |

**Ability Upgrade System:**
- Each ability has 3 tiers
- Upgrades unlock through repeated use + collecting related Reveries
- Higher tiers: increased range, duration, new effects

### 4. Puzzle Design Philosophy

**Dream Logic Puzzles:**
Puzzles follow "dream logic" rather than real-world physics:
- Doors that open when you stop looking at them
- Gravity shifts based on perspective
- Objects that exist in multiple places simultaneously
- Emotional states affecting environment (fear makes shadows solid)

**Puzzle Categories:**

**A. Environmental Manipulation**
- Use Lucid Touch to reshape platforms
- Phase Shift to reach otherwise inaccessible areas
- Memory Echo to see solutions from the Dreamer's subconscious

**B. Perception Challenges**
- Rotate perspective to align fragmented pathways
- Use Dream Sight to reveal invisible bridges
- Navigate M.C. Escher-style impossible geometry

**C. Emotional Resonance**
- Match emotional states to unlock doors
- Calm or provoke dream entities
- Balance emotional energy in the environment

**D. Temporal Puzzles**
- Use Time Fracture to coordinate multiple moving parts
- Reverse events to undo changes
- Create time loops to accomplish parallel tasks

### 5. Dreamscape Generation

**Structure:**
Each Dreamscape is procedurally influenced but hand-crafted:
- **Core Layout:** Pre-designed main paths and key areas
- **Decorative Elements:** Procedurally placed based on Dreamer profile
- **Dynamic Events:** Random encounters and mini-puzzles
- **Thematic Consistency:** All elements reflect Dreamer's psyche

**Dreamer Profiles Affect:**
- Visual aesthetic (color palette, architectural style)
- Ambient entities (peaceful creatures vs anxious shadows)
- Puzzle types (logical vs emotional)
- Environmental hazards (frequency and danger level)
- Hidden secrets density

**Difficulty Zones:**
Dreamscapes categorized by depth:
- **Surface Dreams (Levels 1-3):** Safe, tutorial-like, gentle puzzles
- **REM Dreams (Levels 4-6):** Moderate challenge, ability combinations needed
- **Deep Dreams (Levels 7-9):** Complex puzzles, hostile entities, navigation challenges
- **Core Dreams (Level 10):** Boss-level challenge, story-critical, requires mastery

---

## Balancing Framework

### Progression Curve

**Hours 0-2: Tutorial Phase**
- Introduce basic movement and one ability at a time
- Linear Dreamscapes with clear objectives
- No fail states, emphasis on exploration
- Collect 5-8 Reveries (all Common/Uncommon)

**Hours 3-5: Expansion Phase**
- Unlock 3-4 new abilities
- Branching paths in Dreamscapes
- Introduce optional challenges
- Collect 12-15 Reveries (mix of rarities)
- First Nightmare Fragment (mini-boss)

**Hours 6-9: Mastery Phase**
- All core abilities unlocked
- Complex multi-ability puzzles
- Access to Deep Dreams
- Collect 15-20 Reveries
- 2-3 major story reveals (Core Dreams)

**Hours 10-12: Climax Phase**
- Final Dreamscapes unlock
- Hardest puzzles requiring all abilities
- Collect remaining Core Dreams (3-4)
- Final boss: Confront fragmented self
- Epilogue and 100% completion content

### Difficulty Scaling

**Variables:**
- **Puzzle Complexity:** Number of steps to solve
- **Time Pressure:** Optional time limits for advanced players
- **Enemy Density:** Frequency of hostile dream entities
- **Navigation Challenge:** Level of disorientation/maze complexity

**Accessibility Options:**
- **Story Mode:** Simplified puzzles, no fail states, navigation hints
- **Standard Mode:** Balanced challenge (default)
- **Dream Master Mode:** No hints, complex variants, time challenges
- **Custom:** Individual toggles for puzzle hints, enemy aggression, etc.

### Economy & Rewards

**Resources:**

1. **Dream Essence (Primary Currency)**
   - Gained: Collecting Reveries, exploring, completing puzzles
   - Spent: Unlocking Archive upgrades, hint system
   - Balance: ~100 essence per hour, 50 essence per upgrade

2. **Insight Points (Ability Upgrade Currency)**
   - Gained: Using abilities, completing ability-specific challenges
   - Spent: Upgrading abilities to higher tiers
   - Balance: 1 point per 5 ability uses, 10 points per upgrade

**Reward Schedule:**
- **Minor reward:** Every 15 minutes (small story snippet, cosmetic)
- **Medium reward:** Every 45 minutes (new ability or upgrade)
- **Major reward:** Every 2-3 hours (new story chapter, new Dream depth unlocked)

### Replayability

**New Game+ Features:**
- Retain all abilities from start
- Remixed Dreamscapes with harder puzzle variants
- New hidden Reveries only accessible with full ability set
- Alternate ending paths based on collection completion percentage

---

## Story Overview

### Premise

You awaken in **The Archive**, a liminal space between dreams and reality. You have no memory of who you were, only an instinctive knowledge: you are a **Dream Collector**, tasked with gathering forgotten Reveries from the sleeping minds of humanity.

As you collect more dreams, fragments of your own past begin to surface. Each Dreamer's memories echo pieces of your forgotten life. The more you collect, the more you realize: *you were once human, and something catastrophic caused you to fragment into the Dreamscape itself.*

### Three-Act Structure

**ACT I: The Awakening (Hours 0-4)**

*"Who am I? Why do I collect dreams?"*

- Player begins with no memories, only purpose
- Introduced to The Archive by **The Curator** (mysterious guide)
- Early Dreamers have simple, relatable dreams (childhood memories, daily anxieties)
- First revelation: A Reverie contains YOUR face in someone else's memory
- **Inciting Incident:** Discovery of a "Fractured Reverie"—a corrupted memory that shouldn't exist

**ACT II: The Searching (Hours 4-9)**

*"These dreams are connected. They're all connected to me."*

- Dreamers become more complex: fears, traumas, deep desires
- Pattern emerges: Many Dreamers have similar recurring imagery (a lighthouse, a song, a specific date)
- Collect "Nightmare Fragments"—hostile, corrupted memories
- **Midpoint Revelation:** Player was once a researcher studying dream therapy, trying to cure a loved one trapped in eternal sleep
- The experiment went wrong: Player's consciousness shattered across the collective unconscious
- **New Goal:** Find the Core Dreams that contain pieces of the truth

**ACT III: The Reconciliation (Hours 9-12)**

*"To be whole again, I must face what I've forgotten."*

- Enter the dreams of **The Sleeper**—the loved one you tried to save
- Their dream is a nightmare labyrinth, combining all previous dream themes
- Each Core Dream reveals a piece of the tragedy:
  - You violated ethical boundaries to save them
  - The experiment backfired, trapping both of you
  - The Curator is your fractured guilt, trying to guide you
- **Climax:** Confront your fractured self in The Sleeper's core
- **Choice:** 
  - **Reunite:** Merge back together, wake up, but The Sleeper remains asleep (bittersweet)
  - **Release:** Let go of your physical form, stay as Dream Collector, free The Sleeper (sacrifice)
  - **Remain:** Stay fragmented, continue collecting, searching for another way (ambiguous)

### Key Characters

**The Collector (Player Character)**
- Amnesiac entity
- Gentle, curious, empathetic
- Slowly regains memories through gameplay
- Customizable appearance unlocks as they remember their human form

**The Curator**
- Enigmatic guide, appears in The Archive
- Offers cryptic advice and exposition
- Voice only, no physical form
- **True identity:** The player's manifested guilt and sense of responsibility

**The Sleeper**
- The loved one trapped in eternal dream
- Never seen directly until Act III
- Their presence felt throughout via recurring symbols
- **Relationship:** Ambiguous (partner, family, close friend—player's interpretation)

**The Dreamers (NPCs)**
- 20+ unique profiles with backstories
- Each represents different human experiences
- Some are connected to The Collector's past life
- Profiles viewable in Archive with unlocked lore

### Narrative Delivery

**Methods:**
1. **Reverie Playback:** Collected memories play as short vignettes
2. **Archive Codex:** Written entries unlock with collection milestones
3. **Environmental Storytelling:** Dreamscape details hint at Dreamer's life
4. **The Curator's Monologues:** Direct exposition during key moments
5. **Fragmented Flashbacks:** Brief flashes of the player's memories during gameplay

**Tone:**
- Melancholic yet hopeful
- Philosophical exploration of memory and identity
- Emotional without being overwrought
- Mystery with satisfying reveals

---

## Art Style Guide

### Visual Identity

**Core Aesthetic:** Ethereal Surrealism meets Soft Sci-Fi

Blend of:
- Studio Ghibli's dreamy atmospherics
- Monument Valley's impossible geometry  
- Gris's emotional color language
- Inside's minimalist environmental storytelling

### Color Philosophy

**The Archive (Hub):**
- Palette: Deep indigos, soft whites, silver highlights
- Lighting: Cool, calm, library-like
- Mood: Safe, contemplative, timeless

**Dreamscapes (Dynamic per Dreamer):**

| Emotion/Theme | Primary Colors | Secondary | Accent |
|---------------|----------------|-----------|--------|
| Joy/Nostalgia | Warm gold, sky blue | Cream, peach | Bright yellow |
| Fear/Anxiety | Deep purple, shadow blue | Dark gray | Sharp red |
| Sadness/Loss | Muted blue, slate gray | Pale lavender | Cold white |
| Anger/Frustration | Burnt orange, crimson | Charcoal | Bright orange |
| Peace/Serenity | Soft green, aqua | Pearl white | Mint |
| Confusion/Chaos | Shifting gradients | Contradictory | Neon clashes |

**Color Rules:**
- Reveries glow with bright, saturated versions of environment colors
- Player character has subtle rainbow iridescence (shifting with abilities used)
- Hostile entities appear as dark silhouettes with colored outlines
- Hidden paths revealed through color inversion or saturation shifts

### Character Design

**The Collector:**
- Androgynous, ethereal humanoid
- Semi-transparent, like watercolor
- Flowing garments that react to movement (think Journey)
- Face partially obscured (players project onto them)
- Glowing core where heart would be (brighter with each collected Reverie)
- As memories return, appearance becomes more defined

**Dream Entities:**
- **Friendly:** Soft, rounded shapes, gentle animations
- **Neutral:** Abstract geometric forms, curious behaviors  
- **Hostile:** Jagged, shadow-based, erratic movements
- All entities are symbolic rather than realistic
- Examples: Floating books (knowledge), shadow hands (fear), singing orbs (joy)

### Environment Design

**Architecture:**
- Impossible geometry that shifts when not observed
- Floating platforms and non-Euclidean spaces
- Architecture reflects Dreamer's subconscious:
  - Child's dream: oversized furniture, toy-like buildings
  - Artist's dream: brushstroke textures, paint-drip waterfalls
  - Scientist's dream: blueprint overlays, mathematical symbols as structures

**Nature Elements:**
- Dreamlike flora: trees with clock-face flowers, rivers of light
- Sky: No sun/moon, ambient glow from undefined sources
- Weather: Emotional (rain of memories, fog of confusion, snow of forgotten things)

**Scale:**
- Varied dramatically to evoke dream-distortion
- Important objects oversized to draw attention
- Distant objects might be closer than they appear (dream logic)

### Visual Effects

**Key VFX:**
1. **Reverie Collection:** Particle streams flowing into player, color explosion
2. **Ability Use:** Unique visual signatures per ability (time fracture = ripple distortion)
3. **Phase Shift:** Player becomes translucent with outline glow
4. **Dream Transition:** Reality dissolves into pixels/particles, reforms as new Dreamscape
5. **Memory Echo:** Ghostly replay with reduced saturation and trailing effect

**Post-Processing:**
- Subtle chromatic aberration for dream-like feel
- Soft bloom on important objects
- Depth of field to guide player attention
- Color grading that shifts with emotional state of Dreamscape

### UI/UX Design

**In-Game HUD:**
- Minimal, transparent elements
- Ability icons: Small, bottom-right, glow when available
- Reverie counter: Top-left, stylized as constellation
- Interaction prompts: Contextual, appear/disappear smoothly
- No health bar (no combat/death in traditional sense)

**Menus:**
- **Archive Screen:** Library aesthetic, books and floating orbs representing collected Reveries
- **Dreamer Selection:** Constellation map, stars = Dreamers, connecting lines show relationships
- **Ability Tree:** Organic growth pattern, tree branches or neural networks
- **Settings:** Clean, accessible, high contrast for readability

**Typography:**
- Primary: Elegant serif for Archive/story text (like Garamond or Freight Text)
- Secondary: Clean sans-serif for UI (like Proxima Nova)
- Dream text: Handwritten, organic, varies by Dreamer

### Animation Principles

**Player Movement:**
- Floaty, weightless feel
- Smooth acceleration/deceleration  
- Fabric/hair trails behind movement
- Idle animations: Gentle floating bob, looking around curiously

**Environmental Animation:**
- Constant subtle motion (nothing truly still)
- Floating objects drift lazily
- Platforms breathe/pulse gently
- Water/liquid elements move in slow motion

**Interaction Feedback:**
- Objects react to proximity (lean toward player)
- Successful interactions: Satisfying expansion/contraction
- Failed attempts: Object gently shakes "no"

### Reference Mood Board

**Games:**
- Journey (player design, environmental flow)
- Gris (emotional color use, platforming feel)
- Superliminal (perspective puzzles)
- Manifold Garden (impossible geometry)
- Spiritfarer (emotional narrative, gentle aesthetics)

**Art:**
- Salvador Dalí (surreal landscapes)
- Yayoi Kusama (infinity rooms, pattern work)
- James Turrell (light and space)
- Simon Stålenhag (melancholic sci-fi)

**Film/Animation:**
- Paprika (dream sequences)
- Spirited Away (otherworldly environments)
- Inception (dream layers concept)
- Eternal Sunshine of the Spotless Mind (memory aesthetics)

---

## Sound Direction

### Audio Philosophy

**Core Concept:** Sound as Emotional Memory

Audio design that:
- Reflects the emotional state of each Dreamscape
- Uses musical motifs to connect related Reveries
- Creates intimacy through subtle, close sounds
- Avoids harsh or jarring effects (except Nightmares)

### Music Composition

**Compositional Style:**
- Ambient, atmospheric, minimal
- Live instruments blended with synthesizers
- Influenced by: Max Richter, Ólafur Arnalds, Brian Eno
- Emphasis on piano, strings, ethereal vocals, subtle electronics

**Archive Theme (Main Hub):**
- Instrumentation: Solo piano, soft string pad, distant chimes
- Tempo: Slow, meditative (60-70 BPM)
- Mood: Safe, contemplative, slightly melancholic
- Leitmotif: Simple 4-note melody (this becomes the "memory theme" throughout)

**Dreamscape Music (Dynamic System):**

Each Dreamscape has:
1. **Base Layer:** Ambient drone/pad matching emotional tone
2. **Melodic Layer:** Adds when exploring (related to Dreamer's personality)
3. **Rhythmic Layer:** Introduces during puzzles/challenges
4. **Reverie Layer:** Special motif when approaching collectible

**Emotional Themes:**

| Emotion | Instrumentation | Musical Character |
|---------|----------------|-------------------|
| Joy/Nostalgia | Acoustic guitar, music box, warm synths | Major key, lilting rhythm, music-box quality |
| Fear/Anxiety | Dissonant strings, prepared piano, low drones | Minor key, irregular rhythm, tense |
| Sadness/Loss | Cello, haunting vocals, distant piano | Slow, spacious, descending melodies |
| Anger | Heavy percussion, distorted synth bass | Driving rhythm, harsh timbres |
| Peace | Harp, ambient pads, field recordings | Open fifths, slow harmonic movement |
| Confusion | Overlapping time signatures, fragmented melodies | Polyrhythmic, detuned, unstable |

**Adaptive Music System:**
- Music evolves based on player proximity to objectives
- Intensity scales with puzzle complexity
- Successful Reverie collection triggers musical "resolution" (tension → release)
- Failure/wrong attempts subtly introduce dissonance
- Transitions between areas are seamless (cross-fade over 3-4 seconds)

**Boss/Nightmare Themes:**
- More structured, rhythmic
- Introduce distorted versions of earlier motifs
- Build to climax with full instrumentation
- Resolution after victory returns to calm

### Sound Effects

**Player Actions:**

| Action | Sound Description | Reference |
|--------|------------------|-----------|
| Movement | Soft whoosh, fabric rustling | Gentle wind through cloth |
| Jump/Float | Ascending chime, air displacement | Wind chime caught in breeze |
| Land | Soft impact, harmonic resonance | Padded thud + subtle bell tone |
| Phase Shift | Reality "tearing," brief static | VHS tape distortion + glass harmonica |
| Ability Use | Unique signature per ability | Time Fracture = reversed audio swell |
| Reverie Collect | Crystalline chimes, harmonic cascade | Music box + glass bottles clinking |

**Environmental Sounds:**

**The Archive:**
- Distant page turning
- Soft whispers (unintelligible)
- Occasional clock ticking
- Gentle ambient hum
- Footsteps on marble

**Dreamscapes:**
- Contextual ambience (ocean dreams have surreal wave sounds)
- Interactive objects make melodic tones when touched
- Weather sounds processed to be dreamlike (rain = soft marimba)
- Spatial audio for navigation cues

**Entity Sounds:**
- **Friendly:** Soft coos, musical tones, gentle breath
- **Neutral:** Curiosity sounds (chirps, questioning tones)
- **Hostile:** Low growls, distorted breathing, sharp dissonant notes

### Voice Direction

**The Curator:**
- Gender-neutral, warm, slightly echo-ed
- Processed to sound distant/ethereal
- Speaks slowly, thoughtfully
- Reference: Bastion narrator meets GRIS emotional tone
- Language: [Player choice - English, Korean, etc.]
- Minimal VO (key story moments only)

**The Dreamers:**
- No direct dialogue
- Occasional whispered phrases (emotional, not expositional)
- Processed to sound like memory/echo
- Multilingual whispers (dreamscape is universal)

**The Sleeper:**
- Heard only at climax
- Clear, intimate, raw emotion
- No processing (most "real" voice in game)
- Single line delivery of player's real name (customizable)

### Audio Implementation

**Technical Approach:**
- FMOD or Wwise for adaptive music system
- Binaural audio for headphone users (optional)
- Full spatial audio support
- Dynamic mixing: music ducks for important VO/SFX
- Accessibility: Visual sound indicators (optional setting)

**Mix Balance:**
- Music: Primary emotional driver (40% of mix in calm areas, 30% in intense moments)
- Ambience: Constant presence (30-40% of mix)
- SFX: Clear, present, never masked (20-30%)
- VO: Prioritized when present, music ducks to 20%

### Accessibility Features

**Audio Options:**
- Individual volume sliders (Master, Music, SFX, VO, Ambience)
- Subtitles + speaker labels
- Visual sound indicators for important audio cues
- Mono/stereo/surround options
- Photosensitive mode (reduces audio-reactive visual flashing)
- Text size and background opacity controls

---

## Progression Systems

### Collection Completion

**Reverie Catalog:**
- Total Reveries: 100
  - 40 Memory Shards (Common)
  - 30 Emotion Echoes (Uncommon)
  - 20 Nightmare Fragments (Rare)
  - 8 Core Dreams (Epic)
  - 2 Hidden Whispers (Secret)

**Collection Tracking:**
- Archive displays completion percentage
- Sets/themes visible (e.g., "Childhood Dreams" 4/6)
- Completing sets unlocks bonus content (concept art, music tracks)
- Steam/platform achievements tied to milestones

### Ability Progression

**Unlock Path:**
- 3 abilities at start (Dream Sight, Memory Echo, Whisper)
- 6 abilities unlock through story progression (spread across Acts I-III)
- Each ability has 3 upgrade tiers
- Tier 1: Basic function
- Tier 2: Enhanced (longer duration, larger area, reduced cooldown)
- Tier 3: Mastery (new properties, combo potential)

**Upgrade Costs:**
- Tier 2: 10 Insight Points
- Tier 3: 25 Insight Points
- Total to max all: 315 Insight Points
- Expected playthrough earnings: 350-400 (allows choice/flexibility)

### Dreamer Unlocking

**Initial Pool:** 5 Dreamers available
**Progressive Unlocks:**
- Story milestones unlock 3-4 new Dreamers each
- Completing certain Reverie sets unlocks hidden Dreamers
- New Game+ unlocks special "Lucid Dreamers" (harder variants)

### Cosmetic Progression

**Player Customization:**
Unlock appearance options as memories return:
- Clothing patterns/colors (20 options)
- Particle effects (10 trail styles)
- Idle animations (5 personality variants)
- Reverie collection effects (8 visual styles)

**Archive Customization:**
- Furniture and decorations
- Lighting themes
- Background music selection
- Display pedestals for favorite Reveries

---

## Technical Specifications

### Engine & Platform

**Recommended Engine:** Unity or Unreal Engine 5
- Unity: Better 2.5D handling, asset pipeline
- UE5: Superior visuals (Lumen/Nanite for dreamlike quality)

**Target Platforms:**
- **Primary:** PC (Steam, Epic)
- **Secondary:** Nintendo Switch
- **Tertiary:** iOS/Android (optimized version)

**Minimum PC Specs:**
- OS: Windows 10 (64-bit)
- Processor: Intel i5-4590 / AMD FX 8350
- Memory: 8 GB RAM
- Graphics: NVIDIA GTX 960 / AMD R9 280
- Storage: 10 GB available space

**Recommended PC Specs:**
- OS: Windows 10/11 (64-bit)
- Processor: Intel i7-8700 / AMD Ryzen 5 3600
- Memory: 16 GB RAM
- Graphics: NVIDIA RTX 2060 / AMD RX 5600 XT
- Storage: 10 GB SSD

### Performance Targets

- **PC:** 60 FPS @ 1080p, 30-60 FPS @ 4K
- **Switch:** 30 FPS @ 720p (docked), 30 FPS @ 540p (handheld)
- **Mobile:** 30-60 FPS @ device native resolution (scalable)

### Key Technical Features

1. **Procedural Dreamscape Elements**
   - Custom procedural generation for decorative objects
   - Hand-crafted core layouts with proc-gen dressing

2. **Dynamic Lighting**
   - Real-time global illumination (UE5 Lumen or Unity HDRP)
   - Emotional color grading system

3. **Adaptive Audio**
   - Middleware integration (FMOD/Wwise)
   - Real-time music layering

4. **Save System**
   - Cloud saves
   - Multiple save slots (3)
   - Auto-save at key moments

5. **Localization**
   - Initial launch: English, Korean, Japanese, Chinese (Simplified)
   - Text + subtitles
   - VO for The Curator in all languages

### Development Roadmap Estimate

**Pre-Production:** 3 months
- Prototype core mechanics
- Vertical slice (one full Dreamscape)
- Finalize art style

**Production:** 18 months
- Build all 20+ Dreamscapes
- Implement all abilities and puzzles
- Complete narrative content
- Full music score and SFX

**Polish & Testing:** 6 months
- QA, bug fixes
- Balancing pass
- Localization
- Platform certification

**Total Development Time:** 27 months (2.25 years)

---

## Appendix

### Target KPIs (Post-Launch)

**Player Engagement:**
- Average session length: 35-45 minutes
- Completion rate: 45-60% (main story)
- Replay rate: 15-25% (New Game+)

**Community:**
- Active subreddit/Discord for sharing Reverie discoveries
- Fan art/screenshot sharing encouraged (photo mode)

**Commercial:**
- Target sales: 100K units in first year
- Positive review threshold: 80%+ (Steam)
- Post-launch DLC potential: New Dreamer packs, expanded story

### Inspiration & References

**Direct Influences:**
- Journey: Player connection, emotional arc
- Gris: Color as emotion, platforming+art fusion
- Outer Wilds: Exploration-driven narrative
- Inside: Atmospheric puzzle-platforming

**Narrative Influences:**
- Eternal Sunshine of the Spotless Mind: Memory and identity
- Paprika: Dream logic and surrealism
- The Matrix: Questioning reality
- Inception: Dream layers and architecture

---

## Document Revision History

- **v1.0 (Feb 20, 2026):** Initial comprehensive GDD
- Future revisions will be logged here

---

**END OF DOCUMENT**

*This GDD is a living document and will evolve through development. All stakeholders should refer to the latest version.*