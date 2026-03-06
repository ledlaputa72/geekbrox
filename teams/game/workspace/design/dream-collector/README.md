# 🎮 Dream Collector — Game Design Documentation

**프로젝트:** Dream Collector (꿈 수집가)  
**장르:** Roguelike + Deckbuilding + Idle Incremental  
**플랫폼:** Godot 4.x (Mobile Portrait)  
**상태:** 🟢 개발 중 (70% 완료)  
**최종 업데이트:** 2026-03-06

---

## 📂 폴더 구조 가이드

### 🎯 **01_vision/** — 게임 비전 및 전략
게임의 핵심 가치, 장르 분석, 비전 선언문 등 **전략적 방향**을 담는 폴더입니다.

**포함 내용:**
- 게임 철학 및 핵심 가치
- 장르 분석 (Roguelike, Deckbuilding, Idle)
- 타겟 플레이어 프로필
- 경쟁 게임 분석

**시작 문서:** README.md (폴더 내)

---

### 🔧 **02_core_design/** — 핵심 게임 설계
게임의 **주요 시스템**과 **밸런싱**을 정의하는 폴더입니다.

#### 📂 **cards/** — 카드 시스템
- **CARD_200_FINAL_DATA.md** ⭐ 최신 — 200개 카드 최종 데이터
- **TAROT_SYSTEM_GUIDE.md** — 타로 카드 기본 시스템
- **CARD_COMBAT_SYSTEM_DESIGN.md** — 전투에서의 카드 사용 방식
- **CARD_FUNCTION_MAPPING_UNIFIED_v3.md** — 카드 기능 구현 매핑
- **CARD_MASTER_UNIFIED_v1.md** — 카드 마스터 데이터
- **CARD_TYPE_SYSTEM_v2.md** — ATTACK/SKILL/POWER/CURSE 분류
- **CARD_CLASSIFICATION_SYSTEM.md** — 카드 분류 체계
- **scripts/generate_cards.py** — 카드 생성 유틸리티
- **scripts/generate_cards_200.py** — 200개 카드 생성 자동화
- **README.md** — 카드 시스템 가이드

#### 📂 **equipment/** — 장비 시스템
- **EQUIPMENT_SYSTEM_GDD_FINAL.md** ⭐ 최신 — 장비 시스템 최종 설계
- **EQUIPMENT_BALANCE_SIMULATION.md** — 밸런싱 검증
- **EQUIPMENT_SYSTEM_COST_ANALYSIS.md** — 경제 영향 분석
- **CARD_EQUIPMENT_INTEGRATION_BALANCE.md** — 카드-장비 밸런싱
- **README.md** — 장비 시스템 가이드

#### 📂 **characters/** — 캐릭터 시스템
- **CHARACTER_DESIGN_SYSTEM.md** — 캐릭터 기본 설계
- **CHARACTER_EQUIPMENT_SYSTEM.md** — 캐릭터-장비 연동
- **CHARACTER_TRAITS_ENHANCED.md** — 개선된 트레이트 시스템
- **TRAIT_SYSTEM_DETAILED_DESIGN.md** — 트레이트 상세 설계
- **TRAIT_SYSTEM_OPERATION_GUIDE.md** — 운영 가이드
- **TRAIT_MASTERY_REDESIGNED_v2.md** — 숙련도 시스템
- **README.md** — 캐릭터 시스템 가이드

#### 📂 **mechanics/** — 게임 메커닉
- **COMBAT_SYSTEM_MASTER_SPEC.md** — 전투 시스템 마스터 스펙
- **GAME_MECHANICS_UNIFIED_GUIDE.md** — 통합 게임 메커닉
- **SYSTEM_MECHANICS_DEEP_DIVE.md** — 심화 분석
- **PROGRESSION_SYSTEM_REDESIGNED.md** — 진행 시스템
- **GAME_PHILOSOPHY_STS_ROGUELIKE_ANALYSIS.md** — 게임 철학 및 분석
- **README.md** — 게임 메커닉 가이드

---

### 📚 **03_implementation_guides/** — 구현 가이드 및 참고자료

#### 📂 **ui/** — UI 설계 및 구현
- **UI_CHARACTER_SCREEN_SPEC.md** — 캐릭터 화면 상세 스펙
- **UI_EQUIPMENT_TAB_DESIGN.md** — 장비 탭 UI 설계
- (추가 UI 스크린 명세서들)

#### 📂 **dev_tools/** — 개발 도구 가이드
- **CURSOR_COMPLETE_DEV_GUIDE.md** — Cursor IDE 완벽 가이드
- **CURSOR_REFERENCE_GUIDE.md** — Cursor 빠른 참조

#### 📂 **operations/** — 운영 및 경제 시스템
- **GAME_ECONOMY_MANAGEMENT.md** — 게임 경제 통합 관리
- **ECONOMY_COST_ANALYSIS.md** — 경제 비용 분석
- **COST_ANALYSIS_v2.md** — 업데이트 비용 분석
- **GACHA_ENHANCEMENT_FINAL_SIMPLIFIED.md** — 뽑기 시스템 가이드
- **PLAYTEST_REPORT_50TESTERS.md** — 50명 테스터 보고서
- **FINAL_OPS_BALANCE_REPORT.md** — 최종 밸런스 리포트
- **NOTION_UPDATE_SUMMARY.md** — Notion 업데이트 요약

#### 📂 **root files** — 구현 메인 가이드
- **IMPLEMENTATION_GUIDE.md** — 전체 구현 가이드

---

### 🎬 **04_narrative_and_lore/** — 스토리 및 월드빌딩

#### 📂 **story/** — 스토리 및 던전
- **DUNGEON_MAP_SYSTEM.md** — 던전 구조 및 맵 설계
- (추가 스토리 문서들)

#### 📂 **npcs/** — NPC 시스템
- **STORY_NPC_SYSTEM.md** — NPC 시스템 및 대화
- (추가 NPC 관련 문서들)

#### 📂 **lore/** — 월드 백그라운드
- (월드 설정, 배경 스토리)

---

### 📊 **05_development_tracking/** — 개발 추적 및 진행도

#### 📂 **reports/** — 진행 보고서
- **PROJECT_COMPLETION_SUMMARY.md** — 프로젝트 완성 요약
- (주간/월간 진행 보고서)

#### 📂 **root files** — 개발 로그
- **DEVELOPMENT_LOG_2026.md** — 2026년 개발 일지 (3/6 기준, 70% 완료)
- **PROGRESS_TRACKER.md** — 진행도 추적
- **WEEKLY_PROGRESS_REPORT_2026-W10.md** — 주간 보고서

---

### 🗂️ **_archive/deprecated_files/** — 백업 및 이전 버전
게임 기획 과정에서 생성된 **이전 버전** 파일들을 보관합니다.

**포함 내용 (20개 파일):**
- EQUIPMENT_SYSTEM_GDD_v1.md (이전 버전)
- EQUIPMENT_SYSTEM_OVERVIEW_v1.md
- EQUIPMENT_SYSTEM_OVERVIEW_v2.md
- EQUIPMENT_IMPLEMENTATION_DESIGN.md
- FINAL_EQUIPMENT_PROJECT_REPORT.md
- GACHA_ENHANCEMENT_INTEGRATED_SYSTEM.md
- SIMPLIFIED_SYSTEM_DESIGN_v2.md
- CARD_200_GENERATION_REPORT_v2.md
- CARD_FUNCTION_DESIGN_GUIDE_UNIFIED_v1.md
- CARD_MONTHLY_ROADMAP_UNIFIED_v1.md
- CARD_TYPE_SYSTEM_UNIFIED_v1.md
- CARD_CATALOG_UNIFIED_v1.md
- CARD_FUNCTION_MAPPING_UNIFIED_v1.md
- CARD_CLASSIFICATION_UPDATED_v2.md
- 기타 이전 버전 파일들

---

## 🎯 **주요 시작 문서 (Quick Navigation)**

### 🌟 **새로운 참여자라면?**
1. **DESIGN_DOCUMENTS_MASTER_v1.md** ← 전체 가이드 시작
2. **01_vision/README.md** ← 게임 비전 이해
3. **02_core_design/README.md** ← 핵심 시스템 학습

### 🚀 **개발자라면?**
1. **03_implementation_guides/IMPLEMENTATION_GUIDE.md** ← 구현 방향
2. **03_implementation_guides/dev_tools/CURSOR_COMPLETE_DEV_GUIDE.md** ← 개발 도구
3. **02_core_design/mechanics/COMBAT_SYSTEM_MASTER_SPEC.md** ← 전투 구현

### 🎮 **게임 디자이너라면?**
1. **02_core_design/cards/CARD_200_FINAL_DATA.md** ← 카드 데이터
2. **02_core_design/equipment/EQUIPMENT_SYSTEM_GDD_FINAL.md** ← 장비 설계
3. **03_implementation_guides/operations/GAME_ECONOMY_MANAGEMENT.md** ← 경제 관리

### 📊 **PM/운영진이라면?**
1. **05_development_tracking/DEVELOPMENT_LOG_2026.md** ← 진행도 추적
2. **03_implementation_guides/operations/FINAL_OPS_BALANCE_REPORT.md** ← 밸런스 리포트
3. **05_development_tracking/PROGRESS_TRACKER.md** ← 진행 현황

---

## 📈 **프로젝트 진행도 (2026-03-06 기준)**

| 시스템 | 진행도 | 상태 | 담당 |
|--------|--------|------|------|
| **UI/UX** | 100% | ✅ 완료 | Game팀 |
| **카드 시스템** | 100% | ✅ 완료 | Game팀 |
| **장비 시스템** | 95% | 🟨 거의 완료 | Game팀 |
| **전투 시스템** | 80% | 🟨 진행 중 | Game팀 |
| **게임 경제** | 100% | ✅ 완료 | OPS팀 |
| **설계 문서** | 100% | ✅ 완료 | PM |
| **개발 코드** | 85% | 🟨 진행 중 | Dev팀 |
| **테스트** | 0% | 🔴 미시작 | QA팀 |
| **전체** | **70%** | **🟨 온트랙** | **전사** |

---

## 🗓️ **마일스톤 (3/5 ~ 3/13)**

| 날짜 | 마일스톤 | 상태 | 진행도 |
|------|---------|------|--------|
| 3/5 (수) | Game팀 Step 1 시작 | 🟨 진행 중 | 50% |
| **3/6 (목)** | **게임 경제 완성 + 폴더 정리** | **✅ 완료** | **100%** |
| 3/8 (토) | Game팀 Step 2 완료 | ⏳ 대기 | 0% |
| 3/9 (일) | Game팀 Step 3~4 + OPS팀 시뮬 시작 | ⏳ 대기 | 0% |
| 3/10 (월) | Game팀 Step 5 완료 | ⏳ 대기 | 0% |
| 3/12 (수) | OPS팀 최종 보고서 | ⏳ 대기 | 0% |
| 3/13 (목) | 프로젝트 최종 완료 | ⏳ 대기 | 0% |

---

## 📝 **폴더별 파일 정리 현황**

### ✅ 완료 상태
```
dream-collector/
├── 01_vision/
├── 02_core_design/
│   ├── cards/          (5개 문서 + 2개 스크립트)
│   ├── equipment/      (4개 문서)
│   ├── characters/     (6개 문서)
│   ├── mechanics/      (5개 문서)
│   └── README.md
├── 03_implementation_guides/
│   ├── ui/             (2개 UI 스펙) ← NEW
│   ├── dev_tools/      (2개 문서)
│   ├── operations/     (7개 문서)
│   └── IMPLEMENTATION_README.md
├── 04_narrative_and_lore/
│   ├── story/          (1개 문서)
│   ├── npcs/           (1개 문서)
│   └── README.md
├── 05_development_tracking/
│   ├── reports/        (1개 문서)
│   ├── DEVELOPMENT_LOG_2026.md
│   └── 기타 추적 파일
├── _archive/deprecated_files/
│   └── (20개 이전 버전)
├── DESIGN_DOCUMENTS_MASTER_v1.md  (마스터 인덱스)
└── README.md (이 파일)
```

---

## 🔗 **중요 링크**

### 📊 **데이터 파일** (~/workspace/data/)
- **weapons_data_v2.json** (20개 무기)
- **armors_data_v2.json** (20개 방어구)
- **rings_data.json** (25개 반지)
- **necklaces_data.json** (25개 목걸이)
- **cards_200_v2.json** (200개 카드)

### 💻 **코드** (~/godot/dream-collector/)
- **scripts/combat/shared/Card.gd** — 카드 클래스
- **scripts/combat/shared/Equipment.gd** — 장비 클래스
- **scripts/systems/GachaSystem.gd** — 뽑기 시스템
- **scripts/systems/MilestoneRewardSystem.gd** — 마일스톤

### 🎨 **UI** (~/interface/v0-exports/dream-theme/)
- **c06-character-equipment-fixed.tsx** — 캐릭터 장비 화면
- **EquipmentDetailModal.tsx** — 장비 상세 정보 모달

### 📖 **문서** (여기 dream-collector/)
- 모든 게임 설계 문서 (이 폴더)

---

## 🚀 **빠른 시작 (5분 가이드)**

### 1️⃣ **전체 개요 이해 (2분)**
```
DESIGN_DOCUMENTS_MASTER_v1.md 읽기
→ "꿈 수집가"의 전체 구조 파악
```

### 2️⃣ **관심 시스템 심화 학습 (3분)**
```
카드? → 02_core_design/cards/README.md
장비? → 02_core_design/equipment/README.md
경제? → 03_implementation_guides/operations/GAME_ECONOMY_MANAGEMENT.md
스토리? → 04_narrative_and_lore/README.md
```

### 3️⃣ **구현 시작 (필요시)**
```
03_implementation_guides/IMPLEMENTATION_GUIDE.md
→ 개발 환경 설정 및 코딩 기준 확인
```

---

## 📞 **문의 및 피드백**

**질문이 있으신가요?**
1. 해당 폴더의 **README.md** 읽기
2. **DESIGN_DOCUMENTS_MASTER_v1.md**에서 키워드 검색
3. **05_development_tracking/** 진행 보고서 확인
4. PM/Game팀 리더에게 문의

---

## 📅 **문서 관리 정책**

### ✅ **활성 문서**
- **FINAL**, **v3**, **v2**: 최신 버전 사용
- 모든 README.md: 각 폴더 가이드

### 🗄️ **아카이브 문서**
- **v1**, **deprecated**: _archive/deprecated_files/ 보관
- 참고용으로만 사용

### 🔄 **업데이트 규칙**
1. 새 문서는 해당 폴더에 생성
2. 이전 버전은 **_archive/**로 이동
3. README.md는 항상 최신 상태 유지

---

## 🎯 **프로젝트 비전**

> **Dream Collector (꿈 수집가)**는 행동 타이밍 전투(ATB)와 카드 기반 게임플레이를 결합한 **로그라이크 덱빌딩 아이들 게임**입니다. 
> 플레이어는 **메모리를 잃은 존재 Nox**로서 분실된 꿈들을 수집하고, 각 꿈의 본질을 카드로 변환하여 전투에 활용합니다.
> 
> **핵심 가치:** 선택의 자유, 장기 플레이 가능성, 아름다운 비주얼 스토리텔링

---

**최종 업데이트:** 2026-03-06 14:30 PST  
**상태:** 🟢 온트랙 (70% 완료, 3/13 목표)  
**관리자:** Atlas PM  

*다음 마일스톤: 3/8 Game팀 Step 2 완료*
