# 📖 Dream Collector - 게임 기획 문서 (2026-03 업데이트)

**프로젝트 상태**: 🟠 **88% 구현 완료** (Phase 3 전투 시스템)  
**최종 업데이트**: 2026-03-03 by Atlas  
**신규 팀원**: [DESIGN_DOCUMENTS_MASTER_v1.md](./DESIGN_DOCUMENTS_MASTER_v1.md) 먼저 읽으세요 (30~60분)

---

## ⚡ **빠른 시작 가이드**

### 📊 현재 프로젝트 진행 상황

| 항목 | 현황 | 목표 | 진행도 |
|------|------|------|--------|
| **Phase 3** | 전투 시스템 구현 | 완성도 8.5/10 | 88% |
| **카드 시스템** | 4가지 타입 + **42장 (v2.0)** | 150장 (월 50장) | 28% |
| **UI/UX** | 12개 화면 완성 | 반응형 최적화 | 95% |
| **블로그** | 4/50 포스트 | 30/월 (조정 중) | 8% |

### 🎮 주요 변경사항 (2026-03)

1. **카드 타입 4가지로 재정의** (v2.0)
   - Before: ATK / DEF / PARRY / DODGE / SKILL (5가지)
   - After: ATTACK / SKILL / POWER / CURSE (4가지) ← **지금 이것으로 개발**
   - 42장 v2.0 설계 확정 (30장 구현 완료 / 12장 신규 설계: POW_001~006 + CUR_001~006)

2. **OPS 게임 테스트 완료** (게임성 7.6/10)
   - 위기 개입 시스템: 긴장감 생성 성공
   - 리액션 윈도우: 0.8초 → 1.2초 조정 권장
   - 상세: `03_implementation_guides/combat/OPS_TEST_REPORT_ATB_v2.md`

3. **현재 긴급 이슈** (P0)
   - 🔴 카드 데미지 로직 미작동 (애니메이션 O, 데미지 X) — DEBUG 진행
   - 🔴 중앙 덱 UI 누락 — 복구 필요

---

## 📚 **문서 구조 (5대 카테고리)**

### 📂 `01_vision/` — 게임의 정체성

- **목적**: 게임 비전, 핵심 루프, 세계관 정의
- **주요 문서**: `INTEGRATED_GAME_CONCEPT.md`
- **대상**: 모든 팀 (프로젝트 입문자 필독)

### 📂 `02_core_design/` — 게임 시스템 설계 ⭐ 가장 중요

- **목적**: 카드, 전투, 타로 등 핵심 시스템 설계
- **주요 문서**:
  - `CARD_TYPE_SYSTEM_v2.md` ← **4가지 타입 설명 (필독)**
  - `CARD_FUNCTION_DESIGN_GUIDE.md` ← **카드 기능 매트릭스**
  - `CARD_COMBAT_SYSTEM_DESIGN.md` ← 전투 시스템 통합 설계
  - `TAROT_SYSTEM_GUIDE.md` ← 78장 타로 + 월드빌딩
  - `CARD_CATALOG_v2.md` ← 현재 30장 + 계획 150장 상세 목록
  - `CARD_CLASSIFICATION_UPDATED_v2.md` ← 기능별 분류 + 로드맵
  - `CARD_MONTHLY_ROADMAP.md` ← 월별 카드 생성 계획
- **대상**: 기획팀, 개발팀, 콘텐츠팀
- **읽기 순서**: `CARD_TYPE_SYSTEM_v2` → `CARD_FUNCTION_DESIGN_GUIDE` → `CARD_CATALOG_v2`

### 📂 `03_implementation_guides/` — 기술 구현 명세

#### **combat/** — 전투 시스템 (88% 완료)
- `COMBAT_UNIFIED_DESIGN_v1.md` — 공통 시스템 (Card, Monster, StatusEffect)
- `COMBAT_ATB_COMPLETE_v1.md` — ATB 전체 상세 설계
- `COMBAT_TURNBASED_COMPLETE_v1.md` — 턴베이스 전체 상세 설계
- `REACTION_ATB_v1.md` — ATB 리액션 (패링/회피)
- `REACTION_TURNBASED_v1.md` — TB 리액션
- `OPS_TEST_REPORT_ATB_v2.md` — **OPS 팀 게임 테스트 결과**
- `ATB_Implementation_Guide.md`, `TurnBased_Implementation_Guide.md` — Godot 구현 가이드

**대상**: 개발팀 (Cursor IDE, Claude Code)  
**상태**: 모든 명세 완료, Godot 구현 진행 중 (88%)

### 📂 `04_narrative_and_lore/` — 스토리 & 세계관

- **목적**: 스토리, 캐릭터, 시나리오, 대사 기획
- **주요 문서**: `STORY_LEVEL_DESIGN_CONCEPT.md`, `STORY_CONCEPT_GUIDE.md`
- **대상**: 시나리오 작가, 아트팀
- **상태**: Phase 4 (3/31~)에서 집중 개발

### 📂 `05_development_tracking/` — 진행 관리 (PM용)

- **목적**: 현재 상태, 체크리스트, 기술 결정 추적
- **주요 문서**:
  - `PROJECT_STATE.md` — **작업 시작 전 필독** (현재 단계, 결정사항)
  - `PROGRESS.md` — 간단한 진행 요약 (일일 체크)
  - `PROGRESS_TRACKER.md` — 상세 체크리스트
  - `TECH_DECISIONS.md` — 기술 결정 기록
  - `DEVELOPMENT_CHECKLIST.md` — 구현 체크리스트
- **대상**: Atlas (PM), 개발팀

### 📂 `_archive/` — 과거 문서 보관

- 이전 버전, 폐기된 컨셉, 역사적 기록 보관

---

## 🎯 **신규 팀원 온보딩 (50분 경로)**

**필수 1단계 (10분)**
→ [`DESIGN_DOCUMENTS_MASTER_v1.md`](./DESIGN_DOCUMENTS_MASTER_v1.md) **이것부터 읽으세요**

**필수 2단계 (분야별 20~30분)**
- **게임 이해**: `01_vision/INTEGRATED_GAME_CONCEPT.md`
- **카드 설계팀**: `02_core_design/CARD_TYPE_SYSTEM_v2.md` + `CARD_FUNCTION_DESIGN_GUIDE.md`
- **개발팀**: `03_implementation_guides/combat/COMBAT_UNIFIED_DESIGN_v1.md`
- **콘텐츠팀**: `02_core_design/CARD_CATALOG_v2.md` + `CARD_MONTHLY_ROADMAP.md`
- **아트팀**: `04_narrative_and_lore/` + 타로 가이드

**필수 3단계 (5분)**
→ `05_development_tracking/PROJECT_STATE.md` (현재 상태 파악)

---

## 🔴 **긴급 이슈 (P0)**

### Issue #1: 카드 데미지 로직 미작동
**증상**: 공격 카드 사용 후 애니메이션은 정상이나 데미지 미적용  
**상태**: 🔄 DEBUG 진행 (CombatManagerATB)  
**예상**: 2026-03-03 오늘 중 해결 (1~2시간)  
**상세**: `memory/2026-03-02-CARD_LOGIC_DEBUG_ANALYSIS.md`

### Issue #2: 중앙 덱 UI 누락
**증상**: 전투 화면에 덱/버림더미 카운트 표시 안 됨  
**상태**: 🟡 설계 완료, 구현 대기  
**예상**: 2026-03-03 오늘 중 복구 (2~3시간)  
**상세**: `memory/2026-03-01-CLAUDE_CODE_IMPLEMENTATION.md`

---

## 📈 **이번 달 마일스톤**

| 날짜 | 마일스톤 | 상태 |
|------|---------|------|
| **2026-03-03 (오늘)** | 카드 로직 DEBUG + 덱 UI 복구 | 🔴 진행 중 |
| **2026-03-05** | Phase 3 v1.0 (게임성 8.5/10) | ⏳ 예정 |
| **2026-03-08~15** | OPS 2차 테스트 | ⏳ 예정 |
| **2026-03-31** | Phase 4 시작 (스토리/사운드) | ⏳ 예정 |

---

## 📞 **담당자 연락처**

| 분야 | 담당자 | 연락처 |
|------|--------|--------|
| 게임 기획/PM | Steve PM | Telegram |
| 기획 문서/카드 설계 | Atlas | OpenClaw |
| Godot 개발 | Cursor IDE / Claude Code | 로컬 |
| 블로그 콘텐츠 | (위임 대기) | — |
| 스토리/나레이션 | (미배정) | — |

---

## 📋 **문서 관리 규칙**

1. **모든 변경사항은 Git으로 추적**: `git log --oneline --all`
2. **주간 업데이트**: 매주 금요일 `05_development_tracking/PROGRESS.md` 갱신
3. **새로운 문서 추가 시**: 이 README.md의 폴더 섹션에 링크 추가
4. **폐기된 문서**: `_archive/`로 이동 (삭제 금지)

---

*이 문서는 모든 팀이 공동으로 관리합니다. 질문이나 업데이트 필요 시 Steve PM 또는 Atlas에 연락주세요.*

**마지막 업데이트**: 2026-03-03 09:20 by Atlas
