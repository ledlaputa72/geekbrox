# Balance Patch v1.1

**Date:** 2026-02-23  
**Status:** Applied  
**Reason:** Virtual testing revealed 82% win rate (target: 50-60%). Game too easy, 2 OP cards dominating meta, 4 cards underperforming.

---

## Changes Summary

### Nerfs (2 cards)
1. **Oblivion Strike** - Overpowered finisher
2. **Dream Ender** - Too easy to trigger

### Buffs (2 cards)
3. **Memory Guardian** - Healing too weak
4. **Reverie Burst** - Lacking impact

### Difficulty Increase
5. **Enemy Stats** - Global HP/Attack buff

---

## Detailed Changes

### 1. Oblivion Strike (Nerf)

**Before:**
- Cost: 3 Energy
- Effect: Deal 20 damage. If this kills an enemy, gain 5 Energy.
- Type: Attack

**After:**
- Cost: **5 Energy** (↑ +2)
- Effect: Deal **15 damage** (↓ -5). If this kills an enemy, gain 5 Energy.
- Type: Attack

**Reason:** Most picked card (usage 94%). Cost increase prevents early-game spam, damage reduction prevents one-shot kills on mid-tier enemies.

---

### 2. Dream Ender (Nerf)

**Before:**
- Cost: 5 Energy
- Effect: Deal 30 damage. Only usable when your HP is 5 or less.
- Type: Attack

**After:**
- Cost: 5 Energy
- Effect: Deal **20 damage** (↓ -10). Only usable when your HP is **3 or less** (↓ -2).
- Type: Attack

**Reason:** Too easy to trigger at 5 HP. Reduced condition to 3 HP makes it a true "last resort" card. Damage reduced to prevent guaranteed boss kills.

---

### 3. Memory Guardian (Buff)

**Before:**
- Cost: 2 Energy
- Effect: Restore 2 HP. Draw 1 card.
- Type: Support

**After:**
- Cost: 2 Energy
- Effect: Restore **5 HP** (↑ +3). Draw 1 card.
- Type: Support

**Reason:** Pick rate only 38%. Healing too weak to justify deck slot. Increased to 5 HP makes it viable for HP recovery strategies.

---

### 4. Reverie Burst (Buff)

**Before:**
- Cost: 4 Energy
- Effect: Gain 20 Reveries (in-game currency).
- Type: Economy

**After:**
- Cost: 4 Energy
- Effect: Gain 20 Reveries **and deal 8 damage to current enemy** (↑ NEW).
- Type: **Economy + Attack**

**Reason:** Pure economy card with no combat impact. Added damage component makes it playable during combat without losing tempo.

---

### 5. Difficulty Increase (Global)

**Enemy Stats Buff:**

| Enemy Tier | HP Change | Attack Change |
|------------|-----------|---------------|
| Basic (M01-M05) | +20% | +1 |
| Mid (M06-M10) | +20% | +1 |
| Advanced (M11-M14) | +20% | +1 |
| Elite (E01-E10) | +20% | +1 |
| Boss (B01-B10) | +20% | +1 |

**Example Changes:**

| Monster | Old HP | New HP | Old ATK | New ATK |
|---------|--------|--------|---------|---------|
| M01 (Forgotten Echo) | 8 | **10** | 1 | **2** |
| M05 (Twisted Reflection) | 20 | **24** | 4 | **5** |
| M10 (Shattered Dreamer) | 40 | **48** | 8 | **9** |
| E05 (The Void Caller) | 70 | **84** | 9 | **10** |
| B05 (Dream Devourer) | 100 | **120** | 10 | **11** |

**Reason:** 82% win rate indicates game is too easy. Global +20% HP and +1 Attack increases threat level without requiring individual monster redesigns.

---

## Testing Goals (Re-test with 20 Virtual Players)

### Primary Metrics:
- **Win Rate:** 50-60% (target range)
- **Fun Rating:** ≥3.8/5 (maintain or improve)
- **Combat Length:** 3-5 turns (maintain)
- **HP Loss:** 30-50% (maintain)

### Secondary Metrics:
- **Oblivion Strike Usage:** Should drop from 94% to ~70%
- **Dream Ender Usage:** Should remain similar but trigger less frequently
- **Memory Guardian Pick Rate:** Should increase from 38% to ~50%
- **Reverie Burst Pick Rate:** Should increase from 42% to ~60%

---

## Expected Impact

### Positive:
- ✅ Reduced win rate to healthy 50-60%
- ✅ More card diversity (less Oblivion Strike spam)
- ✅ Healing and economy cards more viable
- ✅ Higher strategic depth
- ✅ Better risk/reward balance

### Risks:
- ⚠️ Game might become too hard if changes stack
- ⚠️ Players might struggle to find new meta
- ⚠️ Tutorial needed more than ever

---

## Rollback Plan

If re-test shows win rate drops below 40%:
1. Reduce enemy HP buff from +20% to +10%
2. Keep card changes as-is
3. Re-test again with 10 more virtual players

---

## Next Steps

1. ✅ Document changes (this file)
2. 🔄 Run virtual re-test (20 players)
3. ⏳ Analyze results
4. ⏳ Update CARD_DESIGNS.md with v1.1 stats
5. ⏳ Update MONSTER_DESIGNS.md with new HP/ATK values
6. ⏳ Git commit + push (await approval)
7. ⏳ Notion update (await approval)
8. ⏳ Print new prototype cards for real playtesting

---

**Status:** Awaiting re-test results from OPS team.
