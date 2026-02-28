# docs/planning/ — Dream Collector Phase Planning & Roadmap

**PURPOSE**: Comprehensive planning documents for Dream Collector development phases, with detailed task breakdowns, timelines, and strategic decisions.

## Current Status

| Phase | Status | Progress | Completion |
|-------|--------|----------|------------|
| Phase 1: UI Design | ✅ Complete | 100% | 2026-02-24 |
| Phase 2: Asset Integration | ✅ Complete | 100% | 2026-02-26 |
| **Phase 3: Systems Design** | 🔄 In Progress | **25%** | Due 2026-03-21 |
| Phase 4: Combat Implementation | ⏸️ Blocked | 0% | Awaiting Phase 3 |
| Phase 5: Polish & Release | 🔲 Pending | 0% | Post-Phase 4 |

**Overall Project Progress**: 40%

## Contents

| File | Purpose | Timeline |
|------|---------|----------|
| **PHASE3_NEXT_TASKS.md** | Phase 3 status, 3-week roadmap, critical blockers | 3/3 - 3/21 |
| **PHASE3_DETAILED_TASKS.md** | In-depth task breakdown with dependencies & estimates | Reference |
| **PHASE3_REFERENCE_GUIDE.md** | Quick lookup for Phase 3 systems and concepts | Reference |

## 🔴 CRITICAL BLOCKER

**Combat System Decision** ⏰ **Due: 2026-03-03** (TUESDAY)

- **Options**: ATB vs Turn-Based
- **Impact**: HIGH - cascades to card costs, enemy stats, economy, Phase 4 schedule
- **Decision Owner**: Steve PM
- **Implementation Guides**: Available in design/ folders

### Phase 3 Roadmap

```
Week 1 (3/3-3/9):   Combat decision + Card pool design + Enemy design
Week 2 (3/10-3/16): Relics + Economy + Character systems
Week 3 (3/17-3/23): Elite content + Ascension + Node interactions
Completion:         2026-03-21 ✅
```

## Completed Phase 3 Tasks (5/18)

1. ✅ **Game Vision** - Core concept finalized
2. ✅ **Tarot System** - 78 cards designed & documented
3. ✅ **Story/Levels** - 3-act structure + "금실과 은실" approach
4. ✅ **Art Style** - Reference games + style guide
5. ✅ **Game Mechanics** - Roguelike deck-building hybrid defined

## Phase 3 Remaining Tasks (13/18)

| # | Task | Type | Status | Due |
|----|------|------|--------|-----|
| 6 | Combat System | Decision | ⏸️ BLOCKED | 3/3 |
| 7 | Card Pool Design | Design | 🔲 Ready | 3/5 |
| 8 | Monster & Boss Design | Design | 🔲 Ready | 3/7 |
| 9 | Relic System | Design | 🔲 Queue | 3/10 |
| 10 | Economy Balancing | Balancing | 🔲 Queue | 3/12 |
| 11 | Character Systems | Design | 🔲 Queue | 3/14 |
| 12 | Elite Content | Design | 🔲 Queue | 3/17 |
| 13 | Ascension System | Design | 🔲 Queue | 3/21 |
| 14 | Node Interactions | Design | 🔲 Queue | 3/23 |
| 15-18 | Combat Implementation | Dev | 🔲 Queue | Post-Phase 3 |

## Team Assignments

- **[Steve]** - Combat system final decision (3/3)
- **[Kim.G]** - Phase 4 dev preparation (ongoing)
- **[Planning Team]** - Card pool & enemy design (3/4-3/7)
- **[Balance Team]** - Relic & economy tuning (3/10-3/14)
- **[Content Team]** - Elite & Ascension content (3/17-3/23)

## References

- **Implementation Guides**: Check teams/game/workspace/design/dream-collector/ for ATB & Turn-Based guides
- **Game Vision**: INTEGRATED_GAME_CONCEPT.md v2.0
- **Complete Task Tracking**: PHASE3_DETAILED_TASKS.md (13KB)

## For Next Session

1. **[IF Combat Decision arrives]**: Route to Kim.G + Planning team
2. **[THEN Unlock]**: Card Pool Design (3/4) + Enemy Design (3/5)
3. **[TRACK]**: Weekly progress toward 3/21 Phase 3 completion

---

**Last Updated**: 2026-02-28 by Atlas  
**See also**: [docs/team-management/TEAM_WORKFLOWS.md](../team-management/TEAM_WORKFLOWS.md) for task assignment procedures
