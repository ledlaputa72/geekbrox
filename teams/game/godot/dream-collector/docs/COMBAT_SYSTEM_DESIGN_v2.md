# Combat System Design V2 - Real-time Hybrid System

**Version:** 2.1  
**Date:** 2026-02-24  
**Status:** ✅ **IMPLEMENTED** (All 4 Phases Complete)  

---

## 🎯 System Overview

Dream Collector의 전투 시스템은 **실시간 ATB 자동 전투**와 **실시간 카드 플레이**가 동시에 진행되는 혁신적인 하이브리드 시스템입니다.

### Core Concept

```
┌─────────────────────────────────────┐
│  ATB 자동 전투 (백그라운드)         │
│  ↓ 계속 진행                        │
│  캐릭터/몬스터 자동 기본 공격       │
└─────────────────────────────────────┘
              +
┌─────────────────────────────────────┐
│  카드 시스템 (실시간)               │
│  ↓ 타이머로 에너지 충전             │
│  플레이어 언제든 카드 사용 가능     │
└─────────────────────────────────────┘
```

**Genre Mix:**
- 🎮 **디펜스 게임** - 실시간 자원 관리 (에너지 타이머)
- 🃏 **덱빌딩** - Slay the Spire 방식 (덱/무덤/셔플)
- ⚔️ **ATB 전투** - Final Fantasy 방식 (실시간 게이지)

---

## 🔄 ATB Auto-Battle System

### ATB 게이지 메커니즘

```
Hero ATB:  ████████████░░░░ 75%  (2.5초 후 턴)
Slime ATB: ██████░░░░░░░░░░ 40%  (6초 후 턴)
Bat ATB:   ████████████████ 100% (지금 턴!)
```

**충전 공식:**
```
ATB += (100 / Speed) per second
ATB >= 100 → Trigger Turn → ATB = 0
```

**스탯:**
- `Speed` - ATB 충전 속도 (기본: 10 = 10초마다 턴)
- `ATK` - 공격력
- `DEF` - 방어력
- `EVA` - 회피율 (%)

### ATB Turn Flow

```
1. ATB 게이지 100% 도달
   ↓
2. 자동 기본 공격 실행
   - 타겟 선택 (첫 번째 살아있는 적)
   - 데미지 계산 (ATK vs DEF)
   - 회피 체크 (EVA%)
   ↓
3. 데미지 적용
   ↓
4. ATB 게이지 리셋 (0%)
   ↓
5. 다시 충전 시작
```

**중요:** ATB는 **항상 백그라운드에서 진행**. 플레이어가 카드를 쓰든 안 쓰든 계속 진행됩니다.

---

## ⚡ Energy & Card System

### Energy Timer

**디펜스 게임 방식:**

```
Energy Timer: ████████░░░░ (4초 / 5초)
   ↓
Filled (5초 경과)
   ↓
+1 Energy & +1 Card Draw
   ↓
Timer Reset
```

**규칙:**
- **시작**: 3 에너지 (가득 참) + 5 카드 드로우
- **충전**: 5초마다 +1 에너지 & +1 카드
- **최대**: 3 에너지 (더 안 참)
- **핸드 최대**: 10 카드 (더 안 뽑힘)

**에너지 소비:**
- 카드 플레이 시 코스트만큼 소비
- 남은 에너지는 소멸 안 함 (계속 누적 가능, 최대 3까지)

### Card Draw & Deck Cycle

```
┌───────────┐
│   Deck    │ (12장 시작)
└─────┬─────┘
      │ Energy 충전 시 +1 드로우
      ↓
┌───────────┐
│   Hand    │ (5-10장)
└─────┬─────┘
      │ 플레이어가 사용
      ↓
┌───────────┐
│   Play    │ (사용된 카드)
└─────┬─────┘
      │ 즉시 무덤으로
      ↓
┌───────────┐
│  Discard  │ (무덤)
└─────┬─────┘
      │ Deck 소진 시
      ↓
┌───────────┐
│  Shuffle  │ → Deck으로 재사용
└───────────┘
```

**중요 차이점 (vs Slay the Spire):**

| Feature | Slay the Spire | Dream Collector |
|---------|----------------|-----------------|
| 드로우 타이밍 | 턴 시작 시 5장 | 에너지 충전 시 1장 |
| 에너지 리셋 | 턴마다 전체 리셋 | 타이머로 하나씩 충전 |
| 남은 카드 | 턴 종료 시 무덤 | 핸드 유지 (버리기 없음) |
| 플레이 타이밍 | 자기 턴에만 | 언제든 (실시간) |

---

## 🎴 Card Hand UI

### Fan Layout (부채꼴 배치)

**레퍼런스 게임:** 아이언 글로리 (제공된 이미지)

```
일반 상태 (겹침):
  ┌──┬─┬─┬─┬──┐
  │카│ │ │ │카│  ← 5-10장, 부채꼴로 겹쳐서 표시
  └──┴─┴─┴─┴──┘
     약 30-40° 각도로 펼침
     
선택 시 (확대):
        ┌────────┐
        │  카드  │  ← 위로 올라와서 전체 보임
        │  전체  │  ← 설명 텍스트, 이펙트 등
        └────────┘
  ┌──┬─┬─┬─┬──┐
  │  │ │ │ │  │
  └──┴─┴─┴─┴──┘
  
사용 시 (애니메이션):
        ┌────────┐
        │ 카드   │  ↗️ 타겟으로 날아감
        └────────┘
```

### Card UI Elements

**각 카드:**
- 코스트 (좌상단, 원형 배지)
- 이름 (상단)
- 일러스트 (중앙)
- 타입 아이콘 (공격/방어/스킬)
- 설명 텍스트 (하단)

**상태:**
- **Normal** - 기본 상태 (살짝 어둡게)
- **Hovered** - 마우스 오버 (밝게 + 위로 lift)
- **Selected** - 선택됨 (크게 확대)
- **Disabled** - 에너지 부족 (회색 처리)

### Card Play Interaction

**모바일:**
1. 카드 탭 → 선택 (확대)
2. 다시 탭 → 사용 (타겟 자동)
3. 또는 드래그 → 타겟으로 날리기

**PC:**
1. 카드 호버 → 확대
2. 클릭 → 타겟 선택 모드
3. 타겟 클릭 → 사용

---

## 🖥️ UI Layout (390×844px Portrait)

### Screen Breakdown

```
┌─────────────────────────────────────┐ 0px
│ ┌─────────────────────────────────┐ │
│ │  🏷️ Top Bar (54px)              │ │ ← HP, Energy, Icons
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤ 54px
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │  ⚔️ Battle Scene (280px)        │ │ ← 가로 액자 전투 뷰
│ │  👤 Hero  vs  👾👾👾 Monsters  │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤ 334px
│                                     │
│  📊 Combat Log (60px)               │ ← 전투 로그 (스크롤)
│  • Hero dealt 5 damage              │
│  • Slime attacked (3 dmg)           │
│                                     │
├─────────────────────────────────────┤ 394px
│                                     │
│  🎴 Card Hand Area (220px)          │ ← 카드 핸드 (부채꼴)
│                                     │
│     ┌──┬─┬─┬─┬──┐                  │
│     │카│ │ │ │카│                  │
│     └──┴─┴─┴─┴──┘                  │
│                                     │
├─────────────────────────────────────┤ 614px
│                                     │
│  ⚡ Energy & Deck Info (120px)      │
│                                     │
│  ┌─────┐  Energy: ⚡⚡⚡ (3/3)      │
│  │ 3/3 │  [Deck: 12] [Disc: 8]     │
│  └─────┘  Timer: ████░░ (3/5s)     │
│                                     │
├─────────────────────────────────────┤ 734px
│  🎮 Action Buttons (110px)          │
│                                     │
│  ┌──────────┬──────────┬─────────┐  │
│  │End Turn  │  Auto    │  Menu   │  │
│  │(Pass)    │  On/Off  │         │  │
│  └──────────┴──────────┴─────────┘  │
└─────────────────────────────────────┘ 844px
```

### Detailed Areas

#### 1️⃣ Top Bar (54px)

```
┌─────────────────────────────────────┐
│ Led          ❤️ 80/80  💰 111  ⚡3  │
│ 아이언글로리                    ⚙️📊 │
└─────────────────────────────────────┘
```

- Player Name (좌측)
- HP (❤️ 80/80)
- Gold (💰 111)
- Energy (⚡3)
- Settings/Stats (우측 아이콘들)

#### 2️⃣ Battle Scene (280px) - 가로 액자

```
┌─────────────────────────────────────┐
│                                     │
│  👤 Hero (좌측)        👾👾👾 (우측)│
│  ████ 80/80             15  8  5   │
│  ⚡3 🛡5                /20 /12 /8  │
│  ATB: ████████░░       ATB 게이지  │
│                                     │
│  [전투 애니메이션 영역]             │
│                                     │
└─────────────────────────────────────┘
```

**좌측 (Hero, 195px):**
- 캐릭터 스프라이트 (큼, 120×120px)
- HP Bar (길게)
- 현재 에너지 표시
- 현재 방어도 (Block)
- ATB 게이지 (가로, 길게)

**우측 (Monsters, 195px):**
- 몬스터 3마리 (작게, 각 60×60px)
- 각 몬스터:
  - HP 숫자 (위)
  - HP Bar (작게)
  - ATB 게이지 (짧게)
  - Intent 아이콘 (다음 행동)

#### 3️⃣ Combat Log (60px)

```
┌─────────────────────────────────────┐
│ • Slime dealt 3 damage to Hero      │
│ • Hero played Strike (5 dmg)        │
│ • Bat evaded!                       │
└─────────────────────────────────────┘
```

- 스크롤 가능 (3-4줄)
- 최신 로그 위로
- 반투명 배경

#### 4️⃣ Card Hand (220px)

```
┌─────────────────────────────────────┐
│                                     │
│         ┌──┬─┬─┬─┬──┐              │
│         │ │ │▲│ │ │  ← 선택된 카드 │
│         │카│ │ │ │카│              │
│         └──┴─┴─┴─┴──┘              │
│          5-10장 부채꼴              │
└─────────────────────────────────────┘
```

- 중앙 정렬
- 부채꼴 레이아웃 (30-40° 펼침)
- 선택 시 위로 lift (50px)
- 터치/클릭 인터랙션

#### 5️⃣ Energy & Deck Info (120px)

```
┌─────────────────────────────────────┐
│  ┌─────┐                            │
│  │ 3/3 │  ⚡⚡⚡ Energy              │
│  └─────┘                            │
│  (좌측)                             │
│                                     │
│  📚 Deck: 12    🪦 Discard: 8      │
│  ⏱️ Next Energy: ████░░ (3/5s)     │
└─────────────────────────────────────┘
```

**좌측:**
- 에너지 원형 표시 (큼, 80×80px)

**우측:**
- 에너지 게이지 (⚡⚡⚡)
- 덱 카운터
- 무덤 카운터
- 에너지 타이머 (프로그레스 바)

#### 6️⃣ Action Buttons (110px)

```
┌──────────┬──────────┬─────────┐
│End Turn  │  Auto    │  Menu   │
│(Pass)    │  On/Off  │         │
└──────────┴──────────┴─────────┘
```

- **End Turn (Pass)** - 에너지 낭비 없이 대기
- **Auto** - 자동 카드 사용 (AI)
- **Menu** - 설정/도망가기

---

## ⚙️ Combat Flow

### Real-time Concurrent Systems

```
┌─────────────────────────────────────┐
│  ATB System (백그라운드)            │
│  ↓ 계속 진행                        │
│  Hero ATB 충전 중...                │
│  Slime ATB 충전 중...               │
│  Bat ATB 100% → 자동 공격!          │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Energy System (백그라운드)         │
│  ↓ 계속 진행                        │
│  Timer 충전 중... ████░░ (3/5s)     │
│  Timer 100% → +1 Energy & Draw 1    │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  Player Actions (언제든)            │
│  ↓ 에너지 있으면                    │
│  카드 선택 → 타겟 → 사용            │
│  에너지 소비 → 카드 무덤으로        │
└─────────────────────────────────────┘
```

**핵심:** 3개 시스템이 **독립적으로 동시에** 진행됩니다!

### Combat Start

```
1. 전투 시작
   ↓
2. 초기화
   - Hero HP/Energy (3/3)
   - Monsters (1-3마리)
   - Deck 섞기
   - 5장 드로우
   ↓
3. 모든 시스템 시작
   - ATB 게이지 충전 시작
   - Energy Timer 시작
   - Player input 대기
```

### During Combat

**ATB Turn (자동):**
```
Entity ATB 100%
   ↓
자동 기본 공격
   - 데미지 계산
   - 회피 체크
   - HP 감소
   ↓
Combat Log 업데이트
   ↓
ATB 리셋 (0%)
```

**Energy Charge (자동):**
```
Timer 100% (5초 경과)
   ↓
+1 Energy (최대 3)
   ↓
+1 Card Draw (최대 10 핸드)
   - Deck에서 1장
   - Deck 없으면 Discard 섞어서 Deck
   ↓
Timer 리셋 (0%)
```

**Card Play (플레이어):**
```
플레이어 카드 선택
   ↓
에너지 체크 (부족하면 불가)
   ↓
타겟 선택 (필요 시)
   ↓
카드 효과 발동
   - 데미지/방어/버프 등
   ↓
에너지 소비
   ↓
카드 → Discard Pile
   ↓
Hand에서 제거
```

### Combat End

**승리 조건:**
- 모든 몬스터 HP 0

**패배 조건:**
- Hero HP 0

**도망:**
- Menu → Run Away (성공률 있음)

---

## 🎮 Implementation Phases

### Phase 1: ATB Basic Combat ✅ COMPLETE

**Goal:** ATB 자동 전투 기본 구현

**Status:** ✅ Completed (2026-02-24)  
**Git Commit:** d941bfe

**Tasks:**
- [x] Combat.tscn UI 레이아웃
- [x] CombatManager.gd ATB system
- [x] 기본 공격 로직
- [x] Combat Log 시스템
- [x] 승리/패배 조건

---

### Phase 2: Energy & Card System ✅ COMPLETE

**Goal:** 실시간 에너지 & 카드 드로우 시스템

**Status:** ✅ Completed (2026-02-24)  
**Git Commits:** df3d5fe, f071962

**Tasks:**
- [x] DeckManager.gd (Deck/Hand/Discard)
- [x] EnergySystem (5초 타이머)
- [x] cards.json 카드 데이터
- [x] 에너지 & 덱 UI
- [x] Hand UI (기본 레이아웃)

---

### Phase 3: Card Hand UI & Play ✅ COMPLETE

**Goal:** 부채꼴 카드 UI + 카드 플레이 인터랙션

**Status:** ✅ Completed (2026-02-24)  
**Git Commit:** 74cf682

**Tasks:**
- [x] Fan Layout 알고리즘 (40° spread, 35px spacing)
- [x] Card Interaction (hover, select, drag)
- [x] 카드 플레이 로직 (에너지 체크)
- [x] 카드 효과 시스템 (Attack/Defense/Skill)
- [x] 타겟 선택 UI

**Additional Features Implemented:**
- [x] Overlapping fan layout (50-70% visibility)
- [x] Drag targeting with red arrow
- [x] Card selection pushes adjacent cards (60px)
- [x] Dynamic energy charge (hand size = charge time)
- [x] Circular energy orb with radial progress

---

### Phase 4: Auto-Battle & Polish ✅ COMPLETE

**Goal:** 자동 전투 AI + 최종 다듬기

**Status:** ✅ Completed (2026-02-24)  
**Git Commit:** 234af0e

**Tasks:**
- [x] Auto-Battle AI (휴리스틱)
- [x] Speed Control (0.5× ~ 3×)
- [x] UI/UX Polish
- [x] 버그 수정 & 테스트

**AI Logic:**
- HP < 30% → Defense priority
- HP >= 30% → Damage/Cost efficiency
- Auto-play delay: 0.5 seconds
- Cheat codes: A (auto), [ ] (speed), ESC (cancel)

---

## 📊 Implementation Summary

**Total Development Time:** ~12 hours (Phase 1-4)  
**Lines of Code:** ~800 lines (CombatManager, DeckManager, Combat UI, AutoBattleAI)  
**Files Created:** 6 (CombatManager.gd, DeckManager.gd, AutoBattleAI.gd, CardHandItem, EnergyOrb.gd, NodeMapVisual.gd)  
**Files Modified:** 15+  
**Git Commits:** 6 (d941bfe, df3d5fe, f071962, 74cf682, 234af0e, 631c5d3)

**Features Beyond Original Design:**
1. ✨ Dynamic energy charge (hand size based)
2. ✨ Circular energy orb (visual upgrade)
3. ✨ 2×2 monster grid with depth effect
4. ✨ Visual node map system
5. ✨ Victory/Defeat/Rewards screens
6. ✨ Drag targeting system

**Overall Combat System Status:** 🎉 **100% COMPLETE**



## 📚 References

### Visual Reference
- **아이언 글로리** (Iron Glory) - 카드 핸드 UI, 부채꼴 레이아웃
- **Slay the Spire** - 카드 효과, 덱 관리
- **Final Fantasy** - ATB 게이지, 실시간 전투

### Similar Games
- **Chrono Trigger** - ATB 시스템
- **Random Dice** - 실시간 자원 관리 (디펜스)
- **Monster Train** - 카드 + 실시간 요소

---

## 🚀 Next Steps

1. ✅ **설계서 승인** (이 문서)
2. 🔴 **Phase 1 시작** - ATB 기본 전투 구현
3. 🟡 **Phase 2** - 에너지 & 카드 시스템
4. 🟢 **Phase 3** - 카드 UI & 플레이
5. ⚪ **Phase 4** - 자동 전투 & 마무리

**예상 소요 시간:** 7-11일 (1주일 ~ 2주일)

---

**문서 작성:** Atlas  
**마지막 업데이트:** 2026-02-24 18:45 PST  
**버전:** 2.0 (Real-time Hybrid System)
