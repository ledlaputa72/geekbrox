# Dream Collector - Monster Designs
**Version:** 1.0  
**Date:** February 23, 2026  
**Total Monsters:** 34 designs (14 Basic, 10 Elite, 10 Bosses)

---

## 📋 Monster Index

| Category | Count | Difficulty Range |
|----------|-------|------------------|
| **Basic Monsters** | 14 | Easy - Normal |
| **Elite Monsters** | 10 | Hard - Very Hard |
| **Boss Monsters** | 10 | Boss - Nightmare |
| **Total** | **34** | |

---

## 🎯 Design Philosophy

**Gameplay Goals:**
1. **Progressive Difficulty** - Early enemies teach mechanics, later ones demand mastery
2. **Pattern Recognition** - Each monster has distinct behavior players can learn
3. **Strategic Choices** - Monsters punish specific strategies, reward adaptability
4. **Risk/Reward Balance** - Harder enemies give better rewards

**Balance Targets:**
- **Average Combat Length:** 3-5 turns
- **Player Damage Taken:** 30-50% HP per combat (without defense)
- **Reverie per Combat:** 20-50 (Basic), 60-150 (Elite), 200+ (Boss)

---

## 👾 Basic Monsters (14)

### Tier 1: Tutorial Enemies (Nodes 1-3)

#### #M01 - Dream Wisp
```yaml
Name: Dream Wisp
Difficulty: ★☆☆☆☆ (Very Easy)
HP: 8
Attack: 1 per turn
Pattern: 
  - Turn 1-3: Attack 1 damage
  - No special abilities
Reward: 10 Reveries
Threat Level: None (training dummy)
Strategy: Any deck can defeat easily
Flavor: "A harmless fragment of forgotten daydreams."
Appearance: Small glowing orb, pale blue
```

#### #M02 - Sleepy Shadow
```yaml
Name: Sleepy Shadow
Difficulty: ★☆☆☆☆ (Very Easy)
HP: 10
Attack: 2 per turn
Pattern:
  - Turn 1: Attack 2 damage
  - Turn 2: Sleep (skip turn, no attack)
  - Turn 3+: Repeat pattern
Reward: 15 Reveries
Threat Level: Minimal (teaches pattern recognition)
Strategy: Attack during sleep turns for free damage
Flavor: "It dozes off between attacks."
Appearance: Wispy humanoid shape, constantly yawning
```

#### #M03 - Memory Nibbler
```yaml
Name: Memory Nibbler
Difficulty: ★★☆☆☆ (Easy)
HP: 12
Attack: 2 per turn
Pattern:
  - Attacks every turn
  - Special: If player plays 3+ cards in one turn, gain +1 Attack (permanent)
Reward: 20 Reveries
Threat Level: Low (punishes overextending)
Strategy: Play 2 cards max per turn, take it slow
Flavor: "It feeds on excessive activity."
Appearance: Small rat-like creature made of mist
```

### Tier 2: Early Challenge (Nodes 4-5)

#### #M04 - Shadow Whisper
```yaml
Name: Shadow Whisper
Difficulty: ★★☆☆☆ (Easy)
HP: 15
Attack: 3 per turn
Pattern:
  - Attacks every turn
  - No special abilities
Reward: 25 Reveries
Threat Level: Low (standard enemy)
Strategy: Straightforward damage race
Flavor: "Soft voices in the dark."
Appearance: Shadowy figure with glowing eyes
```

#### #M05 - Anxious Echo
```yaml
Name: Anxious Echo
Difficulty: ★★★☆☆ (Normal)
HP: 18
Attack: 2-5 (random each turn)
Pattern:
  - Roll d4 each turn: 1=2dmg, 2=3dmg, 3=4dmg, 4=5dmg
  - Unpredictable damage
Reward: 30 Reveries
Threat Level: Medium (variance can spike)
Strategy: Maintain high defense every turn
Flavor: "You never know what it will do next."
Appearance: Flickering humanoid, constantly shifting
```

#### #M06 - Dream Glutton
```yaml
Name: Dream Glutton
Difficulty: ★★★☆☆ (Normal)
HP: 20
Attack: 3 per turn
Pattern:
  - Attacks every turn
  - Special: Steals 5 Reveries per turn from player
Reward: 40 Reveries (includes stolen amount)
Threat Level: Medium (long combats hurt economy)
Strategy: Kill quickly to minimize Reverie loss
Flavor: "It grows fat on stolen dreams."
Appearance: Blob-like creature with gaping maw
```

### Tier 3: Mid-Game Threats (Nodes 6-7)

#### #M07 - Regret Wraith
```yaml
Name: Regret Wraith
Difficulty: ★★★☆☆ (Normal)
HP: 22
Attack: 4 per turn
Pattern:
  - Attacks every turn
  - Special: If player blocks damage, attacks again (bonus attack)
Reward: 45 Reveries
Threat Level: Medium-High (punishes defense)
Strategy: Either block all damage or take it, don't half-block
Flavor: "Defending only delays the inevitable."
Appearance: Ghostly figure weeping constantly
```

#### #M08 - Lucid Hunter
```yaml
Name: Lucid Hunter
Difficulty: ★★★☆☆ (Normal)
HP: 25
Attack: 3 per turn
Pattern:
  - Turn 1-2: Attack 3 damage
  - Turn 3: Charge (no attack, next attack +5 damage)
  - Turn 4: Attack 8 damage (3 + 5 bonus)
  - Repeat
Reward: 50 Reveries
Threat Level: High (burst damage)
Strategy: Save defense for turn 4, attack during turns 1-3
Flavor: "It patiently stalks its prey."
Appearance: Wolf-like shadow with glowing eyes
```

#### #M09 - Memory Thief
```yaml
Name: Memory Thief
Difficulty: ★★★★☆ (Hard)
HP: 20
Attack: 3 per turn
Pattern:
  - Attacks every turn
  - Special: Each time you play a card, takes 2 bonus damage to player
Reward: 55 Reveries
Threat Level: High (punishes card spam)
Strategy: Play 1-2 high-impact cards per turn
Flavor: "Every action hurts you."
Appearance: Skeletal figure draped in stolen memories
```

### Tier 4: Late-Game Enemies (Nodes 8-9)

#### #M10 - Nightmare Hound
```yaml
Name: Nightmare Hound
Difficulty: ★★★★☆ (Hard)
HP: 28
Attack: 5 per turn
Pattern:
  - Attacks every turn
  - Special: If HP < 50%, Attack becomes 8 (instead of 5)
Reward: 65 Reveries + 1 random Uncommon card
Threat Level: Very High (enrage mechanic)
Strategy: Burst it down before 50% HP, or prepare heavy defense
Flavor: "Wounded beasts are most dangerous."
Appearance: Massive wolf-like shadow, scarred and fierce
```

#### #M11 - Dream Parasite
```yaml
Name: Dream Parasite
Difficulty: ★★★★☆ (Hard)
HP: 30
Attack: 2 per turn
Pattern:
  - Attacks every turn (low damage)
  - Special: Steals 5 Reveries per turn
  - Special: Heals 2 HP per turn
Reward: 80 Reveries (includes stolen amount)
Threat Level: Very High (long war of attrition)
Strategy: Kill fast with high damage, ignore defense
Flavor: "It grows fat on your dreams."
Appearance: Bloated worm-like creature
```

#### #M12 - Void Fragment
```yaml
Name: Void Fragment
Difficulty: ★★★★☆ (Hard)
HP: 25
Attack: 6 per turn
Pattern:
  - Attacks every turn
  - Special: Immune to first 10 damage each turn
Reward: 70 Reveries
Threat Level: Very High (requires consistent high damage)
Strategy: Deal 15+ damage per turn to overcome immunity
Flavor: "The void consumes the weak."
Appearance: Crack in reality, swirling darkness
```

#### #M13 - Fear Phantom
```yaml
Name: Fear Phantom
Difficulty: ★★★★★ (Very Hard)
HP: 35
Attack: 7 per turn
Pattern:
  - Attacks every turn
  - Special: Cannot be blocked by Defense cards
Reward: 90 Reveries + 1 random Rare card
Threat Level: Extreme (pure damage race)
Strategy: Race to kill before it kills you, HP recovery helps
Flavor: "Pure, undiluted terror."
Appearance: Towering shadow with glowing red eyes
```

#### #M14 - Time Eater
```yaml
Name: Time Eater
Difficulty: ★★★★★ (Very Hard)
HP: 40
Attack: 4 per turn
Pattern:
  - Attacks every turn
  - Special: You can only play 1 card per turn
Reward: 100 Reveries + 1 random Rare card
Threat Level: Extreme (limits player options)
Strategy: Play your best card each turn, focus efficiency
Flavor: "Time is the ultimate enemy."
Appearance: Hourglass-shaped entity draining sand
```

---

## 👹 Elite Monsters (10)

Elite monsters appear rarely (5% chance) and offer high rewards but extreme challenge.

### Mid-Boss Tier

#### #E01 - Shadow Champion
```yaml
Name: Shadow Champion
Difficulty: ★★★★☆ (Hard)
HP: 45
Attack: 6 per turn
Pattern:
  - Turn 1-2: Attack 6 damage
  - Turn 3: Summon Shadow Whisper (15 HP, 3 Attack)
  - Turn 4-6: Attack 6 damage
  - Turn 7+: Repeat from turn 3
Reward: 120 Reveries + 2 Uncommon cards
Special: Summoned enemies act immediately after Champion's turn
Strategy: Kill summons quickly or ignore and burst Champion
Flavor: "It commands lesser shadows."
Appearance: Armored shadow warrior with glowing blade
```

#### #E02 - Lucid Archon
```yaml
Name: Lucid Archon
Difficulty: ★★★★☆ (Hard)
HP: 50
Attack: 5 per turn
Pattern:
  - Attacks every turn
  - Special: Steals 1 random card from your hand each turn (discards it)
  - If your hand is empty, deals +5 bonus damage instead
Reward: 150 Reveries + 2 Rare cards
Threat Level: Extreme (hand disruption)
Strategy: Draw extra cards to replenish, or empty hand on purpose
Flavor: "It bends your will against you."
Appearance: Robed figure with glowing third eye
```

#### #E03 - Memory Colossus
```yaml
Name: Memory Colossus
Difficulty: ★★★★☆ (Hard)
HP: 60
Attack: 5 per turn
Pattern:
  - Attacks every turn
  - Special: Each time you play a Memory-tagged card, gains +2 Attack (permanent)
Reward: 180 Reveries + 3 Rare cards + 1 Epic card
Threat Level: Extreme (punishes specific decks)
Strategy: Avoid Memory cards, or burst before Attack stacks too high
Flavor: "Built from a thousand forgotten dreams."
Appearance: Massive stone giant covered in memory fragments
```

#### #E04 - Nightmare Hydra (3-Headed)
```yaml
Name: Nightmare Hydra
Difficulty: ★★★★★ (Very Hard)
HP: 70 (split into 3 heads: 25/25/20)
Attack: 3 per head (total 9 damage/turn)
Pattern:
  - Each head attacks independently
  - Special: Each head regenerates 5 HP per turn
  - Must kill all 3 heads to win
Reward: 220 Reveries + 4 Rare cards + 1 Epic card
Threat Level: Extreme (multi-target puzzle)
Strategy: Focus fire one head at a time, deal 25+ damage in one turn
Flavor: "Cut off one head, two more appear... or do they?"
Appearance: Three-headed serpent made of shadow
```

#### #E05 - Void Wraith
```yaml
Name: Void Wraith
Difficulty: ★★★★★ (Very Hard)
HP: 55
Attack: 7 per turn
Pattern:
  - Attacks every turn
  - Special: Immune to first 10 damage each turn
  - Special: If you don't deal damage this turn, heals 10 HP
Reward: 200 Reveries + 3 Rare cards + 1 Epic card
Threat Level: Extreme (damage check)
Strategy: Deal 15+ damage EVERY turn, no skipping
Flavor: "Existence means nothing to the void."
Appearance: Humanoid crack in reality
```

### Hard-Mode Elites

#### #E06 - Fear Incarnate
```yaml
Name: Fear Incarnate
Difficulty: ★★★★★ (Very Hard)
HP: 50
Attack: 8 per turn
Pattern:
  - Attacks every turn
  - Special: Cannot be blocked by Defense cards
  - Special: If HP < 30%, Attack becomes 12
Reward: 250 Reveries + 4 Rare cards + 1 Epic card
Threat Level: Extreme (pure damage race)
Strategy: Burst damage only, ignore defense, HP recovery essential
Flavor: "Terror given form."
Appearance: Towering shadow with countless glowing eyes
```

#### #E07 - Time Devourer
```yaml
Name: Time Devourer
Difficulty: ★★★★★ (Very Hard)
HP: 65
Attack: 6 per turn
Pattern:
  - Attacks every turn
  - Special: You can only play 1 card per turn
  - Special: Each turn, permanently gain +1 Attack
Reward: 280 Reveries + 5 Rare cards + 1 Epic card
Threat Level: Extreme (escalating threat)
Strategy: Kill within 5 turns or Attack becomes unmanageable
Flavor: "Time devours all."
Appearance: Hourglass entity with endless hunger
```

#### #E08 - Dream Colossus
```yaml
Name: Dream Colossus
Difficulty: ★★★★★ (Very Hard)
HP: 80
Attack: 5 per turn
Pattern:
  - Turn 1-3: Attack 5 damage
  - Turn 4: Charge (no attack)
  - Turn 5: Massive Attack (15 damage, ignores block)
  - Repeat from turn 1
Reward: 300 Reveries + 6 Rare cards + 2 Epic cards
Threat Level: Extreme (burst window)
Strategy: Use turn 4 to heal/prepare, kill before turn 5 or die
Flavor: "When it strikes, the world trembles."
Appearance: Massive stone golem with glowing cracks
```

#### #E09 - Lucid Nemesis
```yaml
Name: Lucid Nemesis
Difficulty: ★★★★★ (Very Hard)
HP: 60
Attack: 6 per turn
Pattern:
  - Attacks every turn
  - Special: Copies one of your cards each turn and plays it against you
  - Copied card uses your Energy, not theirs
Reward: 320 Reveries + 7 Rare cards + 2 Epic cards
Threat Level: Extreme (uses your strategy against you)
Strategy: Play defensive cards so they copy defense, then burst
Flavor: "It learns from you."
Appearance: Mirror image of player's shadow
```

#### #E10 - Eternal Nightmare
```yaml
Name: Eternal Nightmare
Difficulty: ★★★★★★ (Extreme)
HP: 100
Attack: 8 per turn
Pattern:
  - Attacks every turn
  - Special: When HP reaches 0, revives once at 30 HP
  - Special: After revival, Attack becomes 12
Reward: 400 Reveries + 10 Rare cards + 3 Epic cards + 1 Legendary card
Threat Level: Maximum (endurance test)
Strategy: Prepare for long fight, conserve resources for phase 2
Flavor: "It cannot die, only fade."
Appearance: Swirling vortex of darkness and screaming faces
```

---

## 👑 Boss Monsters (10)

Bosses appear at the final node (★) and have multi-phase mechanics.

### Tier 1 Bosses (Dreamer Level 1-3)

#### #B01 - Dream Eater
```yaml
Name: Dream Eater
Difficulty: ★★★★☆ (Boss - Easy)
HP: 60
Phase 1 (60-30 HP):
  - Attack: 5 per turn
  - Pattern: Attacks every turn
Phase 2 (30-0 HP):
  - Attack: 7 per turn
  - Special: Drains 1 Energy per turn
  - Enrage: Faster and hungrier
Reward: 150 Reveries + 2 Rare cards + 1 Epic card + Unlock new Dreamer
Strategy: Save Energy for phase 2, burst phase 1 quickly
Flavor: "It hungers for your dreams."
Appearance: Massive maw floating in void
```

#### #B02 - Shadow King
```yaml
Name: Shadow King
Difficulty: ★★★★☆ (Boss - Medium)
HP: 80
Phase 1 (80-40 HP):
  - Attack: 6 per turn
  - Special: Every 3 turns, summons Shadow Whisper (15 HP, 3 Attack)
Phase 2 (40-0 HP):
  - Attack: 8 per turn
  - Special: Every 2 turns, summons Shadow Whisper
  - Special: All summons gain +2 Attack
Reward: 200 Reveries + 3 Rare cards + 2 Epic cards + [Nightmare King] card
Strategy: Kill summons or ignore and race King
Flavor: "Ruler of the dark realm."
Appearance: Crowned shadow on obsidian throne
```

#### #B03 - Anxiety Titan
```yaml
Name: Anxiety Titan
Difficulty: ★★★★☆ (Boss - Medium)
HP: 70
Attack: Varies (random)
Pattern:
  - Each turn, roll d10: 1-5 = 5 damage, 6-9 = 10 damage, 10 = 15 damage
  - Unpredictable chaos
Phase 2 (HP < 40%):
  - Attacks twice per turn (roll twice)
Reward: 250 Reveries + 4 Rare cards + 2 Epic cards
Strategy: Maintain high defense always, RNG will spike
Flavor: "Unpredictability incarnate."
Appearance: Shifting mass of anxious energy
```

### Tier 2 Bosses (Dreamer Level 4-6)

#### #B04 - Memory Monarch
```yaml
Name: Memory Monarch
Difficulty: ★★★★★ (Boss - Hard)
HP: 90
Phase 1 (90-50 HP):
  - Attack: 7 per turn
  - Special: Each Memory card you play gives boss +2 Attack (permanent)
Phase 2 (50-0 HP):
  - Attack: 10 + accumulated bonuses
  - Special: Steals 1 card from hand each turn
Reward: 300 Reveries + 5 Rare cards + 3 Epic cards + [Timeless] synergy card
Strategy: Avoid Memory cards phase 1, burst phase 2 fast
Flavor: "Built from a thousand forgotten dreams."
Appearance: Regal figure made of swirling memories
```

#### #B05 - Lucid Sovereign
```yaml
Name: Lucid Sovereign
Difficulty: ★★★★★ (Boss - Hard)
HP: 85
Phase 1 (85-45 HP):
  - Attack: 6 per turn
  - Special: Steals 1 card from hand each turn (discards it)
Phase 2 (45-0 HP):
  - Attack: 9 per turn
  - Special: Steals 1 card AND plays it against you
  - Special: Gains +2 Energy per turn
Reward: 350 Reveries + 6 Rare cards + 3 Epic cards + [God Mode] synergy card
Strategy: Keep hand small phase 1, prepare for your cards phase 2
Flavor: "Perfect awareness, perfect control."
Appearance: Being of pure light with infinite eyes
```

#### #B06 - Nightmare Legion
```yaml
Name: Nightmare Legion
Difficulty: ★★★★★ (Boss - Hard)
HP: 100 (5 bodies: 20 HP each)
Attack: 4 per body (total 20/turn)
Pattern:
  - Each body attacks independently
  - Special: When one dies, others gain +2 Attack each
  - Must kill all 5 to win
Phase 2 (3 or fewer bodies remain):
  - Remaining bodies attack twice per turn
Reward: 400 Reveries + 7 Rare cards + 4 Epic cards + [Fear Incarnate] card
Strategy: Kill all fast, or leave 1-2 and control them
Flavor: "We are legion, we are many."
Appearance: Five shadowy figures moving as one
```

### Tier 3 Bosses (Dreamer Level 7-10)

#### #B07 - The Forgotten
```yaml
Name: The Forgotten
Difficulty: ★★★★★★ (Boss - Very Hard)
HP: 110
Phase 1 (110-60 HP):
  - Attack: 8 per turn
  - Special: Every 2 turns, resets your hand (discard all, draw 4)
Phase 2 (60-0 HP):
  - Attack: 12 per turn
  - Special: Resets hand every turn
  - Special: Drains 2 Energy per turn
Reward: 500 Reveries + 8 Rare cards + 5 Epic cards + [Eternal Dream] legendary
Strategy: Play all cards immediately, expect disruption
Flavor: "What was forgotten can never be remembered."
Appearance: Blank void in the shape of a person
```

#### #B08 - Void Sovereign
```yaml
Name: Void Sovereign
Difficulty: ★★★★★★ (Boss - Very Hard)
HP: 120
Attack: 9 per turn (when vulnerable)
Pattern: Alternating immunity/vulnerability
  - Turn 1: Immune (takes no damage, still attacks)
  - Turn 2: Vulnerable (takes double damage)
  - Repeat
Phase 2 (HP < 50%):
  - Vulnerability windows give triple damage instead
  - Attack increases to 14 when vulnerable
Reward: 600 Reveries + 10 Rare cards + 6 Epic cards + [Dream Ender] legendary
Strategy: Burst damage on vulnerable turns, defend on immune turns
Flavor: "The absence of everything."
Appearance: Living void that consumes light
```

#### #B09 - Time Breaker
```yaml
Name: Time Breaker
Difficulty: ★★★★★★ (Boss - Extreme)
HP: 130
Attack: 8 per turn (but attacks 3 times = 24 total!)
Pattern:
  - Attacks 3 times per turn (triple damage)
  - Special: Must kill within 10 turns or instant loss
  - Time pressure forces aggression
Phase 2 (HP < 60):
  - Time limit becomes 5 turns from this point
Reward: 700 Reveries + 12 Rare cards + 8 Epic cards + [Apocalypse Dream] legendary
Strategy: All-out offense, ignore defense, race clock
Flavor: "Time is not on your side."
Appearance: Shattered clock with hands spinning wildly
```

#### #B10 - The Dreamer (Final Boss)
```yaml
Name: The Dreamer
Difficulty: ★★★★★★★ (Boss - Nightmare)
HP: 150
Phase 1 (150-100 HP):
  - Attack: 6 per turn
  - Special: Summons minion every 2 turns (15 HP, 4 Attack)
Phase 2 (100-50 HP):
  - Attack: 10 per turn
  - Special: Drains 2 Energy per turn
  - Special: Heals 5 HP every 3 turns
  - Minions now have 20 HP, 6 Attack
Phase 3 (50-0 HP):
  - Attack: 15 per turn
  - Special: Immunity shield (blocks first 20 damage per turn)
  - Special: You can only play 2 cards per turn
  - No more summons
Reward: 1000 Reveries + ALL remaining locked cards + Secret Ending unlock
Ultimate Challenge: Tests all player skills
Strategy: Adapt each phase, conserve resources for phase 3
Flavor: "You are the dream. The dream is you."
Lore: The final confrontation with your own consciousness
Appearance: Mirror image of player, constantly shifting
```

---

## 📊 Balance Guidelines

### Damage per Turn Benchmarks

| Monster Tier | Damage/Turn | Player HP% Lost |
|--------------|-------------|-----------------|
| Tutorial | 1-2 | 10-20% |
| Basic Early | 2-3 | 20-30% |
| Basic Mid | 3-5 | 30-50% |
| Basic Late | 5-8 | 50-80% |
| Elite | 6-12 | 60-120% |
| Boss Phase 1 | 5-8 | 50-80% |
| Boss Phase 2 | 8-15 | 80-150% |

### HP Benchmarks

| Monster Tier | HP Range | Expected Turns to Kill |
|--------------|----------|------------------------|
| Tutorial | 8-12 | 2-3 turns |
| Basic Early | 12-20 | 3-4 turns |
| Basic Mid | 20-30 | 4-6 turns |
| Basic Late | 28-40 | 5-8 turns |
| Elite | 45-100 | 8-15 turns |
| Boss | 60-150 | 10-20 turns |

### Reverie Rewards

| Monster Tier | Reveries | Reveries/HP Ratio |
|--------------|----------|-------------------|
| Tutorial | 10-15 | 1.0-1.5 |
| Basic | 20-100 | 1.5-3.0 |
| Elite | 120-400 | 2.5-4.0 |
| Boss | 150-1000 | 5.0-10.0 |

---

## 🎨 Visual Design Guide

### Color Coding (for paper prototype)

- **Tutorial:** White/Gray (harmless)
- **Basic:** Blue (common threat)
- **Elite:** Purple (dangerous)
- **Boss:** Red/Gold (deadly)

### Iconography

- **⚔** = High Attack
- **🛡** = High Defense/Immunity
- **⚡** = Fast/Multi-Attack
- **🔄** = Repeating Pattern
- **👥** = Summons Minions
- **💀** = Instant Death Mechanic

---

## 📝 Playtesting Notes

### What to Test

1. **Time to Kill:** Are combats 3-5 turns average?
2. **Damage Taken:** Are players losing 30-50% HP per fight?
3. **Pattern Recognition:** Can players learn and adapt?
4. **Difficulty Curve:** Does it feel fair and progressive?

### Common Issues

| Issue | Solution |
|-------|----------|
| Too Easy | +30% HP, +2 Attack |
| Too Hard | -20% HP, -1 Attack |
| Too Long | -25% HP |
| Too Short | +50% HP |
| Boring | Add special ability |

---

## 🖨️ Print Template

### Monster Card Layout (63mm × 88mm)

```
┌──────────────────────┐
│ [Name]     [Threat]  │  ← Top
├──────────────────────┤
│   HP: XX  ATK: X     │  ← Stats
├──────────────────────┤
│                      │
│  [Pattern Icons]     │  ← Visual pattern
│                      │
├──────────────────────┤
│ Special:             │
│ [Ability Text]       │  ← Ability box
├──────────────────────┤
│ Reward: X Reveries   │  ← Bottom
└──────────────────────┘
```

---

**Document Version:** 1.0  
**Last Updated:** February 23, 2026  
**Ready for Playtest:** Yes  
**Next Steps:** Print, test, balance!

---

_Monster Designs © GeekBrox 2026 | Dream Collector Paper Prototype_
