# 🎮 Dream Collector — 게임 기획 문서 마스터 (v1.0)

**최종 업데이트**: 2026-03-03 by Atlas  
**상태**: 🟠 88% 구현 완료 (전투 시스템 Phase 3)  
**타겟**: 게임개발팀 전원 + 신규 온보딩

---

## 📋 **목차**

1. [프로젝트 개요](#-프로젝트-개요)
2. [현재 진행 상황](#-현재-진행-상황)
3. [4가지 카드 타입 시스템 (NEW)](#-4가지-카드-타입-시스템)
4. [핵심 기획 문서 가이드](#-핵심-기획-문서-가이드)
5. [구현 상태 상세](#-구현-상태-상세)
6. [알아야 할 변경사항](#-알아야-할-변경사항)
7. [다음 마일스톤](#-다음-마일스톤)

---

## 🎯 **프로젝트 개요**

### 게임 정체성
| 항목 | 내용 |
|------|------|
| **제목** | Dream Collector (꿈수집가) |
| **장르** | 로그라이크 + 방치형 + 덱빌딩 하이브리드 |
| **플랫폼** | 모바일 (iOS/Android) 우선, PC 추후 |
| **주인공** | Nox — 기억을 잃은 존재, 사라진 꿈을 찾아다님 |
| **핵심 루프** | 숨으로 깨어남(방치) → 꿈 카드 선택(가챠) → 카드 전투 → 꿈 수집 |
| **비주얼** | Sophisticated Fairy Tale 스타일 (3-4head SD + Chrono Trigger 배경) |

### 기술 스택
- **엔진**: Godot 4.x (포트레이트 모드: 390×844px)
- **개발 환경**: Cursor IDE (free) → Claude Code (free tier) → Atlas (Gemini)
- **Git 워크플로우**: 로컬 편집 → Steve 승인 → git push

---

## 🚀 **현재 진행 상황**

### 🎬 Phase 3 — 전투 시스템 구현 **88% 완료**

```
Dream Collector Phase 3 진행도
├─ ✅ Phase 1: UI 완성 (12/12 화면)
├─ ✅ Phase 2: 기획 & 아트 레퍼런스 (완료)
├─ 🟠 Phase 3: 전투 시스템 구현 (88%)
│  ├─ ✅ 공통 시스템: Card.gd, Monster.gd, StatusEffect (100%)
│  ├─ ✅ ATB 전투: CombatManagerATB + 8개 스크립트 (100%)
│  ├─ ✅ 턴베이스 전투: CombatManagerTB + 10개 스크립트 (100%)
│  ├─ 🔴 카드 데미지 로직: 애니메이션은 정상, 데미지 미적용 (DEBUG 진행)
│  ├─ 🔴 중앙 덱 표시: UI 누락 (복구 필요)
│  └─ 🟠 반응형 UI 개선: 설계 완료, 구현 대기
├─ ⏳ Phase 4: 콘텐츠 (스토리, 나레이션, 사운드) — 3/31 시작 예정
└─ ⏳ Phase 5: 알파 빌드 + 밸런싱 — 4월 중순 목표
```

### 📊 주요 지표

| 구분 | 현황 | 목표 | 진행률 |
|------|------|------|--------|
| **카드 시스템** | 4가지 타입 설계 + **42장 카드 (v2.0 확정)** | 150장 (월 50장) | 28% |
| **전투 시스템** | ATB + 턴베이스 2가지 | 완성도 8.5/10 | 88% |
| **UI 구현** | 12개 화면 | 모든 화면 + 반응형 | 95% |
| **OPS 테스트** | 게임성 7.6/10 (조정 전) | 8.5/10 이상 | 89% |
| **블로그 자동화** | 4/50 포스트 | 30/월 (목표 조정 중) | 8% |

---

## 🃏 **4가지 카드 타입 시스템**

### ✨ v2.0 최종 설계 (2026-03)

**이전**: ATK / DEF / PARRY / DODGE / SKILL (5가지)  
**현재**: ATTACK / SKILL / POWER / CURSE (4가지) ← **모든 개발은 이 기준으로 진행**

#### 1️⃣ **ATTACK** (공격 카드) — 🔴 빨강

| 속성 | 내용 |
|------|------|
| **역할** | 즉시 단일/광역 데미지 |
| **색상** | 빨강 (`#FF4444`) |
| **테두리** | 사각형 |
| **특성** | 사용 후 버림더미로 이동 |
| **리액션** | 패링/회피/가드 불가 (순수 공격 전용) |
| **예시** | 검의 에이스 (6dmg), 마법사 (4dmg + draw 1), 탑 (15dmg) |
| **수량** | 현재 10장, 최종 40장 예상 |

#### 2️⃣ **SKILL** (스킬 카드) — 🟢 초록

| 속성 | 내용 |
|------|------|
| **역할** | 방어, 회복, 패링, 회피, 가드 |
| **색상** | 초록 (`#44FF44`) |
| **테두리** | 사각형 |
| **특성** | 리액션 태그(`PARRY`/`DODGE`/`GUARD`)로 윈도우에서도 사용 가능 |
| **리액션** | ✅ 윈도우 내 자동 발동 (플레이어 선택도 가능) |
| **예시** | 기본 방어 (6블록), 절제 (3회복), 패링 태그 |
| **수량** | 현재 18장 (DEF 8 + PARRY 5 + DODGE 5), 최종 60장 |

#### 3️⃣ **POWER** (파워 카드) — 🔵 파랑

| 속성 | 내용 |
|------|------|
| **역할** | 전투 전체 지속 버프/마법 |
| **색상** | 파랑 (`#4444FF`) |
| **테두리** | 타원형 |
| **특성** | 사용 즉시 효과 → 전투가 끝날 때까지 **영구 지속** |
| **중첩** | 동일 파워 여러 번 사용 가능 (수치 스택) |
| **예시** | 힘 +2 (영구), 드로우 +1/턴, 에너지 +1/턴 |
| **수량** | **현재 8장** (SKL_001~002, POW_001~006), 최종 30장 |

#### 4️⃣ **CURSE** (저주 카드) — 🟡 노랑

| 속성 | 내용 |
|------|------|
| **역할** | 적에게 디버프/저주 적용 |
| **색상** | 노랑 (`#FFFF44`) |
| **테두리** | 육각형 |
| **특성** | 일부는 리스크/리워드 구조 (플레이어 부작용 가능) |
| **타로** | "어두운 아르카나" 테마 (악마, 죽음, 탑 등) |
| **예시** | 적 약화 (공격력 -4), 적 취약 (받는 데미지 +50%) |
| **수량** | 현재 6장, 최종 20장 예상 |

### 📚 카드 기능 매트릭스

모든 카드는 다음 6가지 기능 카테고리로 분류:

| ID | 카테고리 | 예시 | 타입 |
|----|---------|------|------|
| **①** | **공격형** (9가지) | 단타, 광역, 다중타격, 자해 고수익 | ATTACK |
| **②** | **방어형** (8가지) | 기본 방어, 회복, 가시 반격, 피격 드로우 | SKILL |
| **③** | **강화형** (8가지) | 힘, 에너지, 드로우, 성장 | POWER |
| **④** | **약화형** (7가지) | 취약, 약화, 중독, 버프 제거 | CURSE |
| **⑤** | **카드 조작** (8가지) | 드로우, 회수, 버림더미 활용 | 모두 |
| **⑥** | **특수/복합** (7가지) | 더블탭, 방어 폭발, 예지 | 모두 |

→ **상세 문서**: `02_core_design/CARD_FUNCTION_DESIGN_GUIDE.md`

---

## 📚 **핵심 기획 문서 가이드**

### 📁 **폴더별 핵심 문서**

#### **01_vision/** — 게임의 정체성
| 문서 | 목적 | 대상 |
|------|------|------|
| `INTEGRATED_GAME_CONCEPT.md` | 게임 비전, 핵심 루프, 세계관 | 모든 팀 |

→ **이 문서부터 읽으세요**. 게임이 무엇인지 이해하는 기초입니다.

---

#### **02_core_design/** — 게임 시스템 설계
| 문서 | 목적 | 읽어야 할 때 |
|------|------|------------|
| `CARD_TYPE_SYSTEM_v2.md` | 4가지 카드 타입 + 색상 + UI 설계 | 카드/UI 구현 시 |
| `CARD_FUNCTION_DESIGN_GUIDE.md` | 카드 기능 6가지 카테고리 + 매트릭스 | 새로운 카드 설계 시 |
| `CARD_COMBAT_SYSTEM_DESIGN.md` | 카드 전투 완전 통합 설계 | 전투 시스템 이해 필요 시 |
| `TAROT_SYSTEM_GUIDE.md` | 78장 타로 시스템 (월드빌딩) | 스토리/카드 아트 작업 시 |
| `CARD_CATALOG_v2.md` | v2.0 42장 확정 + 계획 150장 상세 목록 | 카드 데이터베이스 구현 시 |
| `CARD_CLASSIFICATION_UPDATED_v2.md` | 기능별 분류 + 30개월 로드맵 | 콘텐츠 계획 수립 시 |
| `CARD_MONTHLY_ROADMAP.md` | 월별 카드 생성 상세 계획 | 콘텐츠팀 위임 시 |

→ **권장 읽기 순서**: `CARD_TYPE_SYSTEM` → `CARD_FUNCTION_DESIGN_GUIDE` → `CARD_CATALOG_v2`

---

#### **03_implementation_guides/combat/** — 기술 구현 명세

**통합 설계** (먼저 읽기):
- `COMBAT_UNIFIED_DESIGN_v1.md` — 공통 시스템 (Card, Monster, StatusEffect)

**ATB 전투** (Regular battles):
- `COMBAT_ATB_COMPLETE_v1.md` — ATB 전체 상세 설계
- `ATB_Implementation_Guide.md` — Godot 구현 가이드
- `REACTION_ATB_v1.md` — ATB 리액션 시스템

**턴베이스 전투** (Boss battles):
- `COMBAT_TURNBASED_COMPLETE_v1.md` — 턴베이스 전체 상세 설계
- `TurnBased_Implementation_Guide.md` — Godot 구현 가이드
- `REACTION_TURNBASED_v1.md` — TB 리액션 시스템

**테스트 & 분석**:
- `OPS_TEST_REPORT_ATB_v2.md` — OPS 팀 게임 테스트 결과 (게임성 7.6/10)

→ **현재 상태**: 모든 구현 명세 완료. Godot 코드 구현 중 (88% 완료).

---

#### **04_narrative_and_lore/** — 스토리 & 세계관
| 문서 | 목적 |
|------|------|
| `STORY_LEVEL_DESIGN_CONCEPT.md` | 스토리 레벨 설계 |
| `STORY_CONCEPT_GUIDE.md` | 캐릭터, 시나리오, 대사 |

→ **Phase 4 (3/31~)에서 집중 개발**

---

#### **05_development_tracking/** — 진행 관리
| 문서 | 목적 | 읽을 타이밍 |
|------|------|----------|
| `PROJECT_STATE.md` | 프로젝트 현재 단계/결정사항 | 작업 시작 전 필독 |
| `PROGRESS.md` | 간단한 진행 요약 | 일일 체크인 |
| `PROGRESS_TRACKER.md` | 상세 체크리스트 | PM이 업데이트 |
| `TECH_DECISIONS.md` | 기술적 결정 기록 | 의사결정 참고 |
| `DEVELOPMENT_CHECKLIST.md` | 구현 체크리스트 | Cursor/Claude 코딩 시 |

→ **Atlas (PM)이 관리**. 작업 후 최신 상태 반영.

---

## 📊 **구현 상태 상세**

### 🟠 Phase 3 — 전투 시스템 (88%)

#### ✅ **완료 (100%)**

**공통 시스템** (5개 파일)
- `Card.gd` — 카드 데이터 클래스 (타입, 비용, 효과)
- `Monster.gd` — 몬스터 클래스 (HP, 상태이상, AI)
- `StatusEffectSystem.gd` — 상태이상 관리
- `BattleDiary.gd` — 전투 로그 기록
- `SettingsManager.gd` — 게임 설정

**ATB 시스템** (8개 파일 + CombatManagerATB)
- `CombatManagerATB.gd` — 핵심 전투 루프
- `ATBEnergySystem.gd` — 에너지 충전
- `ATBReactionManager.gd` — 패링/회피 윈도우
- `ATBIntentSystem.gd` — 적 의도 표시
- `ATBComboSystem.gd` — 콤보 판정
- `ATBAutoAI.gd` — 자동 AI
- `ATBFocusMode.gd` — 집중 모드
- `ATBCrisisMode.gd` — 위기 개입

**턴베이스 시스템** (10개 파일 + CombatManagerTB)
- `CombatManagerTB.gd` — 핵심 전투 루프
- `TurnBasedEnergySystem.gd`
- `TurnBasedHandSystem.gd`
- `TurnBasedIntentSystem.gd`
- `TurnBasedReactionManager.gd`
- `TurnBasedAutoAI.gd`
- `TarotEnergySystem.gd`
- `DreamShardSystem.gd`
- `DeckPassiveCalculator.gd`

**카드 데이터**
- 30장 CardDatabase.gd 구현 (ATTACK 10 + SKILL 18 + POWER 2)
- **42장 v2.0 설계 확정** (POWER 8장 + CURSE 6장 신규 추가)

#### 🔴 **이슈 (12%)**

| 순번 | 이슈 | 심각도 | 상태 | 예상 해결 |
|------|------|--------|------|----------|
| 1 | **카드 데미지 로직** — 애니메이션 O, 데미지 X | 🔴 CRITICAL | DEBUG 진행 | 오늘 1~2시간 |
| 2 | **중앙 덱 표시** — UI 누락 | 🔴 CRITICAL | 설계 완료 | 오늘 2~3시간 |
| 3 | **반응형 UI 개선** — Part 2 구현 | 🟠 HIGH | 설계 완료 | 이번주 6~8시간 |

---

## ⚡ **알아야 할 변경사항**

### 🎴 **2026-03-02 카드 타입 시스템 재정의**

#### Before (v1)
```
5가지 타입: ATK / DEF / PARRY / DODGE / SKILL
문제: 분류 기준 불명확, UI 색상 부족
```

#### After (v2.0) ← **현재**
```
4가지 타입: ATTACK / SKILL / POWER / CURSE
개선: 
- 명확한 역할 분담 (공격 / 방어·리액션 / 지속버프 / 적디버프)
- 4가지 색상 (빨강/초록/파랑/노랑)
- CardDatabase.gd, Card.gd, UI 모두 업데이트됨
- 30장 카드 모두 재분류 완료
```

### 📊 **2026-03-02 OPS 게임 테스트 완료**

**주요 발견사항**:
- ✅ 위기 개입 시스템: 긴장감 생성 성공
- ✅ 세미오토 모드: AI 추천 수락률 73%
- ⚠️ 리액션 윈도우: 0.8초 → 1.2초로 연장 권장
- ⚠️ 위기 자동 해제: 8초 → 10초 조정
- 🔴 하드코어 유저: 자동 위기 끄기 옵션 요청

→ **상세**: `03_implementation_guides/combat/OPS_TEST_REPORT_ATB_v2.md`

### 🎯 **2026-03-02 블로그 목표 조정 제안**

| 항목 | 기존 | 제안 | 상태 |
|------|------|------|------|
| 월 포스트 | 50개 | 30개 | 🔄 승인 대기 |
| 진행 | 4/50 (8%) | 4/30 (13%) | — |
| 이유 | 초기 계획 | 콘텐츠 생성 병목 | — |
| 확장 | SNS 없음 | Twitter/Instagram 자동화 | 별도 검토 |

→ **이번 주 결정 필요**

---

## 🗓️ **다음 마일스톤**

### 🎯 **TODAY (2026-03-03)**

- [ ] **P0-1**: 카드 데미지 로직 DEBUG (CombatManagerATB)
  - 로깅 추가 → 콘솔 출력 분석 → 근본 원인 특정 → 수정
  - ⏰ 예상 1~2시간
  
- [ ] **P0-2**: 중앙 덱 UI 복구 (InRun_v4)
  - 덱 표시 컴포넌트 재구현
  - 카드 사용 시 애니메이션
  - ⏰ 예상 2~3시간

### 📅 **THIS WEEK (2026-03-03~05)**

- [ ] 반응형 UI 개선 Part 2 구현 (6개 섹션, 12개 파일)
- [ ] 전체 ATB 플레이테스트 (정규 전투)
- [ ] 전체 턴베이스 플레이테스트 (보스 전투)
- [ ] 발란스 조정 (OPS 권고사항 반영)

### 🚀 **이번 달 (2026-03-05 ~ 03-31)**

| 마일스톤 | 날짜 | 내용 |
|---------|------|------|
| **Phase 3 v1.0** | 3/5 | 전투 시스템 완성도 8.5/10 달성 |
| **Phase 3 QA** | 3/8~3/15 | OPS 2차 테스트 |
| **Phase 4 시작** | 3/31 | 스토리/나레이션/사운드 개발 시작 |

---

## 🔗 **문서 네비게이션 맵**

```
이 문서 (MASTER)
├── 01_vision/
│   └── INTEGRATED_GAME_CONCEPT.md (게임이 뭔지 이해)
├── 02_core_design/
│   ├── CARD_TYPE_SYSTEM_v2.md (카드 4가지 타입)
│   ├── CARD_FUNCTION_DESIGN_GUIDE.md (카드 기능)
│   ├── CARD_COMBAT_SYSTEM_DESIGN.md (전투 완전 설계)
│   ├── CARD_CATALOG_v2.md (42→150장 카드 목록)
│   └── TAROT_SYSTEM_GUIDE.md (78장 타로 스토리)
├── 03_implementation_guides/
│   └── combat/
│       ├── COMBAT_UNIFIED_DESIGN_v1.md (공통 시스템)
│       ├── COMBAT_ATB_COMPLETE_v1.md (ATB 전투)
│       ├── COMBAT_TURNBASED_COMPLETE_v1.md (턴베이스)
│       └── OPS_TEST_REPORT_ATB_v2.md (테스트 결과)
├── 04_narrative_and_lore/
│   ├── STORY_LEVEL_DESIGN_CONCEPT.md
│   └── STORY_CONCEPT_GUIDE.md
└── 05_development_tracking/
    ├── PROJECT_STATE.md (반드시 읽기)
    ├── PROGRESS.md (일일 체크)
    ├── TECH_DECISIONS.md (결정 기록)
    └── DEVELOPMENT_CHECKLIST.md
```

---

## 💡 **신규 팀원을 위한 온보딩 경로**

**1단계 (30분)**: 게임 이해  
→ `01_vision/INTEGRATED_GAME_CONCEPT.md` 읽기

**2단계 (20분)**: 카드 시스템 이해  
→ `02_core_design/CARD_TYPE_SYSTEM_v2.md` + `CARD_FUNCTION_DESIGN_GUIDE.md`

**3단계 (분야별 10~20분 추가)**:
- 개발팀: `03_implementation_guides/combat/` 문서 선택
- 콘텐츠팀: `02_core_design/CARD_CATALOG_v2.md` + `CARD_MONTHLY_ROADMAP.md`
- 아트팀: `04_narrative_and_lore/` + 타로 가이드

**4단계 (5분)**: 진행 상황 확인  
→ `05_development_tracking/PROJECT_STATE.md` + `PROGRESS.md`

---

## 📞 **문의 & 업데이트**

| 주제 | 담당자 | 문서 |
|------|--------|------|
| 게임 비전/기획 | Steve PM | INTEGRATED_GAME_CONCEPT.md |
| 카드 설계 | Atlas | CARD_TYPE_SYSTEM + CARD_FUNCTION_DESIGN_GUIDE |
| 전투 구현 | Cursor/Claude Code | COMBAT_*_COMPLETE_v1.md |
| 진행 관리 | Atlas | 05_development_tracking/ |
| 스토리/세계관 | (담당자 미정) | 04_narrative_and_lore/ |

---

**이 문서를 북마크하세요. 모든 기획 정보는 여기서 시작합니다.** 🚀

_Updated: 2026-03-03 (v1.1) by Atlas — 카드 시스템 42장 v2.0 수치 반영_
