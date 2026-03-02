# 🛠️ 개발 사양서 (Dev Specs)

> Dream Collector 전투 시스템 구현을 위한 상세한 기술 사양서

---

## 📁 폴더 구조

```
dev-specs/
├── README_COMBAT_SYSTEM.md      ← 전투 시스템 개요 (먼저 읽기)
│
├── shared/                       ← 공통 시스템 (2026-03-01)
│   └── DEV_SPEC_SHARED.md
│       - Card.gd 스펙
│       - Monster.gd & AttackData 스펙
│       - StatusEffectSystem.gd 스펙
│       - BattleDiary.gd 스펙
│       - SettingsManager.gd 스펙
│       - 카드 30종 상세 목록
│
├── atb/                          ← ATB (Active Time Battle) 전투
│   └── DEV_SPEC_ATB.md          (준비 중)
│       - CombatManagerATB.gd
│       - ATBEnergySystem.gd
│       - ATBReactionManager.gd
│       - ... (9개 스크립트)
│
└── turnbased/                    ← 턴베이스 전투 (2026-03-01)
    └── DEV_SPEC_TURNBASED.md
        - CombatManagerTB.gd
        - TurnBasedEnergySystem.gd
        - TurnBasedReactionManager.gd
        - ... (10개 스크립트)
```

---

## 🚀 사용 방법

### 1️⃣ 개요 읽기
```
README_COMBAT_SYSTEM.md 먼저 읽기
  → 전체 구조, 핵심 수치, Godot 폴더 구조 이해
```

### 2️⃣ 공통 시스템 구현
```
shared/DEV_SPEC_SHARED.md 읽기
  → Card, Monster, StatusEffect, SettingsManager 구현
```

### 3️⃣ 선택: ATB 또는 턴베이스
```
Option A) ATB 전투
  → atb/DEV_SPEC_ATB.md 읽기
  → 9개 스크립트 순서대로 구현

Option B) 턴베이스 전투
  → turnbased/DEV_SPEC_TURNBASED.md 읽기
  → 10개 스크립트 순서대로 구현
```

---

## 📊 각 문서의 내용

### README_COMBAT_SYSTEM.md
- **목적**: 전체 전투 시스템의 입점점
- **포함 내용**:
  - 빠른 시작 가이드
  - 전체 문서 맵
  - 핵심 수치 요약 (ATB vs 턴베이스)
  - Godot 프로젝트 폴더 구조
  - 구현 순서

### shared/DEV_SPEC_SHARED.md
- **목적**: 공통 시스템 스펙
- **포함 내용**:
  - Card.gd 완전 코드
  - Monster.gd + AttackData 스펙
  - StatusEffectSystem.gd (4가지 상태이상)
  - BattleDiary.gd (전투 로그)
  - SettingsManager.gd (설정)
  - **카드 30종 완전 목록** (테이블)

### atb/DEV_SPEC_ATB.md
- **목적**: ATB 전투 모드 전용 스펙
- **포함 내용**:
  - 9개 스크립트 완전 코드
  - CombatManagerATB.gd (핵심 루프)
  - ATB 수치 (에너지, 윈도우, 모드)
  - 구현 순서 & 체크리스트

### turnbased/DEV_SPEC_TURNBASED.md
- **목적**: 턴베이스 전투 모드 전용 스펙
- **포함 내용**:
  - 10개 스크립트 완전 코드
  - CombatManagerTB.gd (턴 루프)
  - 손패/드로우 시스템
  - 타로 에너지 & 꿈 조각
  - 덱 패시브 시스템
  - OPS 플레이테스트 반영 수치

---

## 🎯 구현 우선순위

```
Phase 1 (공통) ← 먼저 시작
┌─────────────────────┐
│ Card.gd            │
│ Monster.gd         │
│ StatusEffectSystem │
│ SettingsManager    │
│ BattleDiary        │
└─────────────────────┘
         ↓
Phase 2 (선택)
┌──────────────┬──────────────┐
│ ATB 전투     │ 턴베이스 전투 │
│ (9개 스크립트)│ (10개 스크립트)│
└──────────────┴──────────────┘
```

---

## 📌 Cursor IDE 사용법

### Step 1: 공통 시스템 복사
```
1. shared/DEV_SPEC_SHARED.md 읽기
2. Card.gd 완전 코드 복사 → Cursor에서 생성
3. Monster.gd, StatusEffectSystem.gd 등 차례로
```

### Step 2: ATB 또는 턴베이스 선택
```
ATB 선택 시:
  → atb/DEV_SPEC_ATB.md의 1장 읽고
  → 2장부터 차례로 스크립트 구현

턴베이스 선택 시:
  → turnbased/DEV_SPEC_TURNBASED.md의 1장 읽고
  → 2장부터 차례로 스크립트 구현
```

### Step 3: 각 스크립트 구현 (템플릿 포함)
```
문서에는 각 스크립트의:
  - 클래스 정의
  - 시그널 & 상수
  - 메인 로직
  - 헬퍼 함수

가 모두 포함되어 있습니다.
```

---

## 🔗 관련 설계서 경로

모든 설계서는 별도 폴더에 있습니다:

```
teams/game/workspace/design/dream-collector/
└── 03_implementation_guides/combat/
    ├── COMBAT_ATB_COMPLETE_v1.md
    ├── COMBAT_TURNBASED_COMPLETE_v1.md
    ├── REACTION_ATB_v1.md
    ├── REACTION_TURNBASED_v1.md
    └── ATB_COMBAT_SYSTEM_v3.md
```

---

## 📞 질문 & 도움

| 주제 | 담당자 | 경로 |
|------|--------|------|
| 게임 설계 | Kim.G | teams/game/workspace/ |
| 플레이테스트 데이터 | Park.O | teams/ops/workspace/research/ |
| 프로젝트 전체 | Atlas | project-management/ |

---

## ✅ 체크리스트

사용 전 확인:

```
[ ] README_COMBAT_SYSTEM.md 읽음
[ ] Godot 폴더 구조 준비됨
[ ] 공통 시스템 구현 계획 세움
[ ] ATB 또는 턴베이스 선택 완료
[ ] Cursor IDE 준비됨
```

---

**Status:** ✅ Phase 0 (공통) 준비 완료  
**Next:** shared/DEV_SPEC_SHARED.md로 공통 시스템 구현 시작  
**Version:** v1.0 | 2026-03-01
