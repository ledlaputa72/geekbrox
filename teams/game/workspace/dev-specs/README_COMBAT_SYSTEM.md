# 🎮 Dream Collector — 전투 시스템 개발 패키지
# Cursor / Claude Code 구현 시작점

**프로젝트**: Dream Collector (모바일 로그라이크 덱빌딩 RPG)
**엔진**: Godot 4.x (GDScript)
**타겟**: iOS / Android, 세로 모드, 1080×1920
**패키지 버전**: v1.0 | **날짜**: 2026-03-01
**작성**: GeekBrox OpenClaw 멀티에이전트 (Atlas → Kim.G + Park.O)

---

## ⚡ 빠른 시작

이 문서를 먼저 읽고, 아래 순서대로 작업하세요.

```
1단계: shared/DEV_SPEC_SHARED.md    ← 공통 시스템 (Card, Monster, StatusEffect 등)
2단계: atb/DEV_SPEC_ATB.md          ← ATB 전투 전용 (실시간 전투)
      또는
      turnbased/DEV_SPEC_TURNBASED.md  ← 턴베이스 전투 전용
3단계: 아래 "구현 우선순위" 참고하여 스크립트 작성
```

---

## 📁 전체 문서 맵

### 🔧 개발 사양서 (이 폴더 — 구현의 기준)

| 파일명 | 역할 | 우선순위 |
|--------|------|---------|
| `README_COMBAT_SYSTEM.md` | **지금 읽는 이 파일** — 전체 구조 안내 | 최우선 |
| `shared/DEV_SPEC_SHARED.md` | 공통 시스템 (Card, Monster, 카드 30종 목록) | 1순위 |
| `atb/DEV_SPEC_ATB.md` | ATB 전투 모드 스크립트 전체 | 2순위 |
| `turnbased/DEV_SPEC_TURNBASED.md` | 턴베이스 전투 모드 스크립트 전체 | 2순위 |

### 📐 설계서 (참조용 — 구현 중 의도 파악에 사용)

경로: `teams/game/workspace/design/dream-collector/03_implementation_guides/combat/`

| 파일명 | 설명 |
|--------|------|
| `COMBAT_ATB_COMPLETE_v1.md` | **ATB 최종 설계서** — 수치와 흐름도 포함 |
| `COMBAT_TURNBASED_COMPLETE_v1.md` | **턴베이스 최종 설계서** — 수치와 흐름도 포함 |
| `REACTION_ATB_v1.md` | ATB 리액션 시스템 상세 (설계 의도) |
| `REACTION_TURNBASED_v1.md` | 턴베이스 리액션 시스템 상세 (설계 의도) |
| `ATB_COMBAT_SYSTEM_v3.md` | ATB v3 (루미 NPC, 전투 일기 포함 — 참고용) |

### 📊 OPS 리포트 (배경 참고용)

경로: `teams/ops/workspace/research/combat-analysis/`

| 파일명 | 설명 |
|--------|------|
| `05_PLAYTEST_ATB_REPORT.md` | ATB 모바일 플레이테스트 결과 (8.7/10) |
| `06_PLAYTEST_TURNBASED_REPORT.md` | 턴베이스 모바일 플레이테스트 결과 (8.45/10) |
| `04_COMPARATIVE_APPLICATION_REPORT.md` | 경쟁 게임 분석 + 적용 방안 |

---

## 🏗️ Godot 프로젝트 폴더 구조

```
res://
├── scripts/
│   ├── combat/
│   │   ├── shared/
│   │   │   ├── Card.gd ← DEV_SPEC_SHARED 2장
│   │   │   ├── Monster.gd ← DEV_SPEC_SHARED 3장
│   │   │   ├── StatusEffectSystem.gd ← DEV_SPEC_SHARED 4장
│   │   │   ├── BattleDiary.gd ← DEV_SPEC_SHARED 5장
│   │   │   └── SettingsManager.gd ← DEV_SPEC_SHARED 6장
│   │   ├── atb/
│   │   │   ├── CombatManagerATB.gd ← DEV_SPEC_ATB 2장
│   │   │   ├── ATBEnergySystem.gd ← DEV_SPEC_ATB 3장
│   │   │   ├── ATBReactionManager.gd ← DEV_SPEC_ATB 4장
│   │   │   ├── ATBIntentSystem.gd ← DEV_SPEC_ATB 5장
│   │   │   ├── ATBComboSystem.gd ← DEV_SPEC_ATB 6장
│   │   │   ├── ATBAutoAI.gd ← DEV_SPEC_ATB 7장
│   │   │   ├── ATBFocusMode.gd ← DEV_SPEC_ATB 8장
│   │   │   └── ATBCrisisMode.gd ← DEV_SPEC_ATB 9장
│   │   └── turnbased/
│   │       ├── CombatManagerTB.gd ← DEV_SPEC_TURNBASED 2장
│   │       ├── TurnBasedEnergySystem.gd ← DEV_SPEC_TURNBASED 3장
│   │       ├── TurnBasedReactionManager.gd ← DEV_SPEC_TURNBASED 4장
│   │       ├── TurnBasedIntentSystem.gd ← DEV_SPEC_TURNBASED 5장
│   │       ├── TurnBasedHandSystem.gd ← DEV_SPEC_TURNBASED 6장
│   │       ├── TarotEnergySystem.gd ← DEV_SPEC_TURNBASED 7장
│   │       ├── DreamShardSystem.gd ← DEV_SPEC_TURNBASED 8장
│   │       ├── DeckPassiveCalculator.gd ← DEV_SPEC_TURNBASED 9장
│   │       └── TurnBasedAutoAI.gd ← DEV_SPEC_TURNBASED 10장
│   ├── scenes/
│   │   ├── combat/
│   │   │   ├── CombatSceneATB.tscn ← DEV_SPEC_ATB 10장 구성
│   │   │   └── CombatSceneTB.tscn ← DEV_SPEC_TURNBASED 11장 구성
│   │   └── ui/
│   ├── assets/
│   │   ├── cards/
│   │   ├── vfx/
│   │   └── sfx/
│   └── data/
│       └── cards/ ← 카드 30종 데이터 (DEV_SPEC_SHARED 7장)
```

---

## ⚙️ 핵심 수치 요약

### ATB 모드

| 항목 | 수치 |
|------|------|
| ATB_MAX | 100.0 |
| ENERGY_MAX | 3 |
| ENERGY_OVERFLOW_MAX | 5 |
| ENERGY_AUTO_INTERVAL | 5.0초 |
| 패링 에너지 보상 | +2 즉시 |
| 회피 에너지 보상 | +1 즉시 |
| 방어 에너지 보상 | +0.5 즉시 |
| 패링 윈도우 (Story) | **0.8초** (기본값) |
| 패링 윈도우 (Hard) | 0.5초 |
| 회피 윈도우 (Story) | **1.8초** |
| 오버플로우 유지 시간 | **3.0초** |
| 집중 모드 속도 | 0.3× |
| 집중 모드 드레인 | **10%/초** |
| 위기 모드 HP 기준 | 30% 이하 |
| 위기 모드 지속 | **10초** |
| 패링 반격 콤보 보너스 | **+75%** |

### 턴베이스 모드

| 항목 | 수치 |
|------|------|
| 기본 에너지/턴 | 3 |
| 에너지 최대 (오버플로우) | 5 |
| 패링 에너지 보상 | +2 (다음 턴) |
| 회피 에너지 보상 | +1 (다음 턴) |
| 방어 에너지 보상 | 없음 (블록이 보상) |
| 패링 윈도우 (Story) | **0.8초** (기본값) |
| 회피 윈도우 (Story) | **1.8초** |
| 드로우/턴 | 5장 |
| 손패 최대 | 10장 |
| 타로 에너지 최대 | 3 |
| 꿈 조각 최대 | 5 |
| 의도 예고 수 | 2~3행동 |

---

## 🚀 구현 시작 가이드

### Phase 1 — 공통 기반 (DEV_SPEC_SHARED 기준)

```
[ ] Card.gd 작성 + 카드 30종 Resource 파일 생성
[ ] Monster.gd + AttackData 작성
[ ] StatusEffectSystem.gd 기본 상태이상 4종 (POISON, VULNERABLE, WEAK, STRENGTH)
[ ] SettingsManager.gd (story_mode, auto_mode 플래그)
[ ] BattleDiary.gd (전투 로그)
```

### Phase 2 — ATB 전투 (DEV_SPEC_ATB 기준)

```
[ ] ATBEnergySystem.gd — 에너지 + 오버플로우
[ ] ATBReactionManager.gd — 패링/회피/방어 판정
[ ] CombatManagerATB.gd — 메인 전투 루프
[ ] ATBIntentSystem.gd — 의도 표시
[ ] ATBComboSystem.gd — 드림 콤보
[ ] ATBAutoAI.gd — 오토 플레이
[ ] ATBFocusMode.gd + ATBCrisisMode.gd — 특수 모드
[ ] CombatSceneATB.tscn — 씬 조립
```

### Phase 3 — 턴베이스 전투 (DEV_SPEC_TURNBASED 기준)

```
[ ] TurnBasedHandSystem.gd — 덱/손패/버림
[ ] TurnBasedEnergySystem.gd — 에너지 + 다음 턴 보너스
[ ] TurnBasedReactionManager.gd — 리액션 윈도우
[ ] CombatManagerTB.gd — 메인 턴 루프
[ ] TurnBasedIntentSystem.gd — 의도 2~3행동 예고
[ ] TarotEnergySystem.gd + DreamShardSystem.gd — 보조 자원
[ ] DeckPassiveCalculator.gd — 덱 패시브
[ ] TurnBasedAutoAI.gd — 오토 플레이
[ ] CombatSceneTB.tscn — 씬 조립
```

---

## 📌 팀 컨벤션

- **클래스명**: PascalCase (예: CombatManagerATB)
- **변수명**: snake_case (예: current_energy)
- **상수**: UPPER_CASE (예: ENERGY_MAX)
- **시그널명**: snake_case 동사형 (예: reaction_resolved, combat_ended)
- **주석**: 한국어 허용, 영어 병기 권장
- **파일 헤더**: `# scripts/combat/atb/ClassName.gd` 형식으로 경로 명시

---

## 📞 문의

- **게임 설계 관련**: Kim.G (게임팀장) — `teams/game/workspace/`
- **플레이테스트 데이터**: Park.O (OPS팀장) — `teams/ops/workspace/`
- **프로젝트 전반**: Atlas (PM) — `project-management/`

---

*이 문서는 GeekBrox OpenClaw 멀티에이전트 시스템이 자동 생성한 개발 패키지입니다.*
*Dream Collector 전투 시스템 v1.0 — 2026-03-01*
