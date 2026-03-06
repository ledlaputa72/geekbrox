# 🎮 Dream Collector — Cursor IDE 참조 가이드

**작성:** Atlas (PM)  
**날짜:** 2026-03-04  
**대상:** Game팀 (Cursor IDE에서 구현 작업)

---

## 📌 Cursor 설정 방법

### 1. 프로젝트 폴더 열기

```bash
# Cursor에서 다음 폴더 열기
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/

또는

~/Projects/geekbrox/
```

### 2. .cursorrules 추가 (권장)

프로젝트 루트에 다음 파일 생성:

```
~/Projects/geekbrox/.cursorrules
```

내용:

```
# Dream Collector Game Design Reference

## Core Systems Documentation
Game design reference files are located in:
- teams/game/workspace/design/dream-collector/*.md

All design specifications are marked with:
- 📋 Reference: [filename]
- 🔧 Implementation: [GDScript class]
- ⚙️ Dependencies: [related files]

## Required Reading Order
1. CARD_200_DETAILED_DESIGN_GUIDE.md
2. CHARACTER_EQUIPMENT_SYSTEM.md
3. PROGRESSION_SYSTEM_REDESIGNED.md
4. GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md

## Data Files
- teams/game/workspace/design/dream-collector/data/cards_200_v2.json (complete card database)

## Implementation Notes
- Trait system (마스터리) is EXCLUDED
- Character has automatic stat distribution (no player choice)
- All enhancements are 100% success rate
- Progression is infinite (Lv 1-1000+)
```

---

## 📚 핵심 참조 문서 (우선순위순)

### 1️⃣ **카드 시스템** - PRIORITY: HIGHEST

**파일:** `CARD_200_DETAILED_DESIGN_GUIDE.md`  
**경로:** `~/Projects/geekbrox/teams/game/workspace/design/dream-collector/CARD_200_DETAILED_DESIGN_GUIDE.md`

**내용:**
- 200종 카드 완전 정의
- 4가지 분류 (ATTACK/SKILL/POWER/CURSE)
- 희귀도별 효과
- 강화 방식 (같은 카드 2개 또는 + 골드)
- 100% 성공률

**구현 필요:**
- Card 클래스 (id, name, type, rarity, effect, etc.)
- CardDatabase.gd
- Card 강화 로직

**참조:**
```
📋 Reference: CARD_200_DETAILED_DESIGN_GUIDE.md
🔧 Implementation: Card.gd, CardDatabase.gd, CardEnhanceSystem.gd
⚙️ Dependencies: CHARACTER_EQUIPMENT_SYSTEM.md (장비와의 상호작용)
```

---

### 2️⃣ **장비 강화 시스템** - PRIORITY: HIGH

**파일:** `CHARACTER_EQUIPMENT_SYSTEM.md`  
**경로:** `~/Projects/geekbrox/teams/game/workspace/design/dream-collector/CHARACTER_EQUIPMENT_SYSTEM.md`

**추가 문서:**
- `EQUIPMENT_IMPLEMENTATION_DESIGN.md` (GDScript 구현 세부사항)
- `CHARACTER_TRAITS_ENHANCED.md` (특성은 제외되었으나 참조용)

**내용:**
- 4슬롯 장비 시스템 (무기/방어구/악세서리/보조무기)
- 66종 장비
- 강화: +0~+10 (100% 성공)
- P2W 비율: 1.86x (목표 1.5x)

**구현 필요:**
- Equipment 클래스
- EquipmentDatabase.gd
- Equipment 강화 로직
- Equipment UI

**참조:**
```
📋 Reference: CHARACTER_EQUIPMENT_SYSTEM.md, EQUIPMENT_IMPLEMENTATION_DESIGN.md
🔧 Implementation: Equipment.gd, EquipmentDatabase.gd, EquipmentEnhanceUI.gd
⚙️ Dependencies: CARD_200_DETAILED_DESIGN_GUIDE.md (카드와의 상호작용)
```

---

### 3️⃣ **성장 시스템** - PRIORITY: HIGH

**파일:** `PROGRESSION_SYSTEM_REDESIGNED.md`  
**경로:** `~/Projects/geekbrox/teams/game/workspace/design/dream-collector/PROGRESSION_SYSTEM_REDESIGNED.md`

**내용:**
- 무한 레벨 (Lv 1-1000+)
- 자동 스탯 배분 (플레이어 선택 없음)
  * ATK: +1.5/레벨
  * DEF: +1/레벨
  * HP: +5/레벨
  * SPD: +0.3/레벨
  
- 마일스톤 보상 (재화 + 컨텐츠 오픈)
  * 초반 (Lv 1-20): 매 2레벨마다
  * 중반 (Lv 21-50): 5레벨마다
  * 후반 (Lv 51+): 점차 긴 구간

**구현 필요:**
- LevelSystem.gd (경험치/레벨)
- MilestoneRewardSystem.gd (마일스톤 보상)
- ContentUnlockManager.gd (컨텐츠 오픈 로직)

**참조:**
```
📋 Reference: PROGRESSION_SYSTEM_REDESIGNED.md
🔧 Implementation: LevelSystem.gd, MilestoneRewardSystem.gd, ContentUnlockManager.gd
⚙️ Dependencies: GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md (보상 연계)
```

---

### 4️⃣ **가챭 시스템** - PRIORITY: HIGH

**파일:** `GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md`  
**경로:** `~/Projects/geekbrox/teams/game/workspace/design/dream-collector/GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md`

**내용:**
- 장비 가챭 (50 다이아/회)
- 카드 가챭 (50 다이아/회)
- 희귀도별 확률 (장비: 55% COMMON ~ 2% LEGENDARY)
- 보장 시스템 (50/100/150회)

**구현 필요:**
- GachaSystem.gd
- GachaUI.gd
- DropRateTable.gd

**참조:**
```
📋 Reference: GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md
🔧 Implementation: GachaSystem.gd, GachaUI.gd, DropRateTable.gd
⚙️ Dependencies: CARD_200_DETAILED_DESIGN_GUIDE.md, CHARACTER_EQUIPMENT_SYSTEM.md
```

---

## 📊 보조 참조 문서

### 게임 밸런스 검증

**파일들:**
- `COMBAT_BALANCE_SIMULATION_REPORT.md` (전투 밸런스, Grade A+)
- `MONETIZATION_BALANCE_SIMULATION_REPORT.md` (경제 밸런스, Grade A)
- `EQUIPMENT_BALANCE_SIMULATION.md` (장비 P2W 분석)

**용도:**
- 수치 검증
- 밸런스 확인
- 문제 해결 시 참조

**참조:**
```
📋 Reference: COMBAT_BALANCE_SIMULATION_REPORT.md (Grade A+: 92/100)
📋 Reference: MONETIZATION_BALANCE_SIMULATION_REPORT.md (Grade A: 91/100)
📋 Reference: EQUIPMENT_BALANCE_SIMULATION.md (Grade B+: 87/100)
```

---

### 최종 프로젝트 보고서

**파일:** `FINAL_PROJECT_REPORT.md`  
**내용:**
- 전체 설계 요약
- 시스템 통합도
- 구현 체크리스트

---

## 🎯 Cursor에서 시작하기

### Step 1: 프로젝트 열기

```bash
# Cursor에서 이 폴더 열기:
~/Projects/geekbrox/

# 또는 설계 폴더만:
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/
```

### Step 2: 문서 순서대로 읽기

```
1️⃣ CARD_200_DETAILED_DESIGN_GUIDE.md (30분)
   → 카드 시스템의 모든 것

2️⃣ CHARACTER_EQUIPMENT_SYSTEM.md (30분)
   → 장비 시스템 + 강화

3️⃣ PROGRESSION_SYSTEM_REDESIGNED.md (20분)
   → 성장 시스템 + 마일스톤

4️⃣ GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md (20분)
   → 가챭 시스템

합계: ~2시간으로 전체 설계 이해 가능
```

### Step 3: 데이터 파일 확인

```
JSON 데이터:
  ~/Projects/geekbrox/teams/game/workspace/design/dream-collector/data/cards_200_v2.json

용도:
  - 카드 정보 (200종, 완전한 데이터)
  - 가챭 드롭 테이블 생성 기초
```

### Step 4: Godot 프로젝트 설정

```
위치:
  ~/Projects/geekbrox/teams/game/godot/dream-collector/

필요한 클래스 (GDScript):
  - Card.gd
  - CardDatabase.gd
  - CardEnhanceSystem.gd
  - Equipment.gd
  - EquipmentDatabase.gd
  - EquipmentEnhanceUI.gd
  - LevelSystem.gd
  - MilestoneRewardSystem.gd
  - ContentUnlockManager.gd
  - GachaSystem.gd
  - GachaUI.gd
  - DropRateTable.gd

구현 순서:
  1. Card + CardDatabase
  2. Equipment + EquipmentDatabase
  3. LevelSystem + Milestone
  4. GachaSystem
  5. UI 통합
```

---

## 🔗 파일 경로 빠른 참조

### 핵심 설계 문서 (4가지)

```
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/
├─ CARD_200_DETAILED_DESIGN_GUIDE.md
├─ CHARACTER_EQUIPMENT_SYSTEM.md
├─ PROGRESSION_SYSTEM_REDESIGNED.md
└─ GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md
```

### 보조 설계 문서

```
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/
├─ EQUIPMENT_IMPLEMENTATION_DESIGN.md (GDScript 구현 가이드)
├─ CHARACTER_TRAITS_ENHANCED.md (참조용, 특성은 제외됨)
├─ STORY_NPC_SYSTEM.md (스토리/NPC)
├─ DUNGEON_MAP_SYSTEM.md (지역/던전)
└─ FINAL_PROJECT_REPORT.md (전체 요약)
```

### 검증 문서

```
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/
├─ COMBAT_BALANCE_SIMULATION_REPORT.md
├─ MONETIZATION_BALANCE_SIMULATION_REPORT.md
├─ EQUIPMENT_BALANCE_SIMULATION.md
└─ PLAYTEST_REPORT_50TESTERS.md
```

### 데이터

```
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/data/
├─ cards_200_v2.json (완전한 카드 데이터)
└─ cards_200_v2.csv (CSV 형식)
```

---

## 💡 Cursor에서 유용한 팁

### 1. Quick Reference (Ctrl+K)

```
"CARD_200_DETAILED_DESIGN_GUIDE.md 참조해서 Card 클래스 만들어줘"
→ Cursor가 파일을 참조하여 코드 생성
```

### 2. 파일 전체 참조

```
Cursor에서:
@file:CARD_200_DETAILED_DESIGN_GUIDE.md
```

로 입력하면 전체 파일을 컨텍스트에 포함

### 3. 구간 참조

```
Cursor에서:
@file:PROGRESSION_SYSTEM_REDESIGNED.md:마일스톤 보상
```

로 입력하면 특정 섹션만 참조

---

## ✅ 체크리스트 (Cursor 작업 시작 전)

```
[ ] Cursor 설치
[ ] 프로젝트 폴더 열기 (~/Projects/geekbrox/)
[ ] .cursorrules 파일 생성 (선택)
[ ] CARD_200_DETAILED_DESIGN_GUIDE.md 읽기
[ ] CHARACTER_EQUIPMENT_SYSTEM.md 읽기
[ ] PROGRESSION_SYSTEM_REDESIGNED.md 읽기
[ ] GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md 읽기
[ ] 데이터 파일 확인 (cards_200_v2.json)
[ ] 구현 시작
```

---

## 🚀 구현 시작 명령어

```bash
# 1. 프로젝트 폴더로 이동
cd ~/Projects/geekbrox/

# 2. Cursor 열기
cursor .

# 3. 설계 문서 읽기 시작
# (Cursor에서 design/dream-collector/ 폴더의 MD 파일들 확인)

# 4. Godot 프로젝트 열기
# (teams/game/godot/dream-collector/)
```

---

## 📞 추가 정보

**Game팀장:** Kim.G  
**설계 완성도:** 100% ✅  
**구현 준비도:** 95% ✅  

**문의 사항:**
- 설계 의도: FINAL_PROJECT_REPORT.md 참조
- 수치 검증: COMBAT_BALANCE_SIMULATION_REPORT.md 참조
- 경제 설계: MONETIZATION_BALANCE_SIMULATION_REPORT.md 참조

---

**모든 설계가 준비되었습니다!**  
**Cursor에서 구현을 시작하세요!** 🚀
