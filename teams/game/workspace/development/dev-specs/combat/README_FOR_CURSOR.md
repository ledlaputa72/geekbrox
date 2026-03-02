# 🎮 Dream Collector — 전투 시스템 개발 패키지
# Cursor / Claude Code 구현 시작점

**프로젝트**: Dream Collector (모바일 로그라이크 덱빌딩 RPG)
**엔진**: Godot 4.x (GDScript)
**타겟**: iOS / Android, 세로 모드, 1080×1920
**패키지 버전**: v2.0 | **날짜**: 2026-03 (리액션 시스템 색상 구간 방식으로 업데이트)
**작성**: GeekBrox OpenClaw 멀티에이전트 (Atlas → Kim.G + Park.O)

---

## ⚡ 빠른 시작

이 문서를 먼저 읽고, 아래 순서대로 작업하세요.

```
1단계: DEV_SPEC_SHARED.md    ← 공통 시스템 (Card, Monster, StatusEffect 등)
2단계: DEV_SPEC_ATB.md       ← ATB 전투 전용 (실시간 전투)
      또는
      DEV_SPEC_TURNBASED.md  ← 턴베이스 전투 전용
3단계: DEV_SPEC_REACTION.md  ← ⚠️ 리액션 시스템 (색상 구간 방식, 2026-03 업데이트)
4단계: 아래 "구현 우선순위" 참고하여 스크립트 작성
```

> ⚠️ **중요**: 리액션 시스템은 `DEV_SPEC_REACTION.md`가 **DEV_SPEC_ATB.md / DEV_SPEC_TURNBASED.md의 리액션 관련 내용을 대체**합니다. 기존 DEV_SPEC의 PARRY_WINDOW, DODGE_WINDOW 상수는 더 이상 사용되지 않습니다.

---

## 📁 전체 문서 맵

### 🔧 개발 사양서 (이 폴더 — 구현의 기준)

| 파일명 | 역할 | 우선순위 |
|--------|------|---------|
| `README_FOR_CURSOR.md` | **지금 읽는 이 파일** — 전체 구조 안내 | 최우선 |
| `DEV_SPEC_SHARED.md` | 공통 시스템 (Card, Monster, 카드 30종 목록) | 1순위 |
| `DEV_SPEC_ATB.md` | ATB 전투 모드 스크립트 전체 | 2순위 |
| `DEV_SPEC_TURNBASED.md` | 턴베이스 전투 모드 스크립트 전체 | 2순위 |
| `DEV_SPEC_REACTION.md` | ⚠️ **리액션 시스템 전용** (색상 구간 방식, 최신) | 3순위 |

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
│   │   │   ├── Card.gd                    ← DEV_SPEC_SHARED 2장
│   │   │   ├── Monster.gd                 ← DEV_SPEC_SHARED 3장
│   │   │   ├── StatusEffectSystem.gd      ← DEV_SPEC_SHARED 4장
│   │   │   ├── BattleDiary.gd             ← DEV_SPEC_SHARED 5장
│   │   │   └── SettingsManager.gd         ← DEV_SPEC_SHARED 6장
│   │   ├── atb/
│   │   │   ├── CombatManagerATB.gd        ← DEV_SPEC_ATB 2장
│   │   │   ├── ATBEnergySystem.gd         ← DEV_SPEC_ATB 3장
│   │   │   ├── ATBReactionManager.gd      ← DEV_SPEC_ATB 4장
│   │   │   ├── ATBIntentSystem.gd         ← DEV_SPEC_ATB 5장
│   │   │   ├── ATBComboSystem.gd          ← DEV_SPEC_ATB 6장
│   │   │   ├── ATBAutoAI.gd               ← DEV_SPEC_ATB 7장
│   │   │   ├── ATBFocusMode.gd            ← DEV_SPEC_ATB 8장
│   │   │   └── ATBCrisisMode.gd           ← DEV_SPEC_ATB 9장
│   │   └── turnbased/
│   │       ├── CombatManagerTB.gd         ← DEV_SPEC_TURNBASED 2장
│   │       ├── TurnBasedEnergySystem.gd   ← DEV_SPEC_TURNBASED 3장
│   │       ├── TurnBasedReactionManager.gd← DEV_SPEC_TURNBASED 4장
│   │       ├── TurnBasedIntentSystem.gd   ← DEV_SPEC_TURNBASED 5장
│   │       ├── TurnBasedHandSystem.gd     ← DEV_SPEC_TURNBASED 6장
│   │       ├── TarotEnergySystem.gd       ← DEV_SPEC_TURNBASED 7장
│   │       ├── DreamShardSystem.gd        ← DEV_SPEC_TURNBASED 8장
│   │       ├── DeckPassiveCalculator.gd   ← DEV_SPEC_TURNBASED 9장
│   │       └── TurnBasedAutoAI.gd         ← DEV_SPEC_TURNBASED 10장
├── scenes/
│   ├── combat/
│   │   ├── CombatSceneATB.tscn            ← DEV_SPEC_ATB 10장 구성
│   │   └── CombatSceneTB.tscn             ← DEV_SPEC_TURNBASED 11장 구성
│   └── ui/
├── assets/
│   ├── cards/
│   ├── vfx/
│   └── sfx/
└── data/
    └── cards/                             ← 카드 30종 데이터 (DEV_SPEC_SHARED 7장)
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
| 오버플로우 유지 시간 | **3.0초** |
| 집중 모드 속도 | 0.3× |
| 집중 모드 드레인 | **10%/초** |
| 위기 모드 HP 기준 | 30% 이하 |
| 위기 모드 지속 | **10초** |
| 패링 반격 콤보 보너스 | **+75%** |

> ⚠️ **리액션 타이밍 수치는 DEV_SPEC_REACTION.md 참조** (색상 구간 방식으로 변경됨)
>
> 요약: 녹색 1.0s(가드) → 노란색 1.0s(회피+가드) → 빨간색 0.4s(패링+회피+가드) [Story 기준]

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

## 🃏 카드 30종 목록 (간략)

전체 스탯은 `DEV_SPEC_SHARED.md` 7장을 참조하세요.

**공격 카드 (10종)**

| ID | 이름 | 비용 | 공격 |
|----|------|------|------|
| ATK_001 | 검의 에이스 | 1 | 8 |
| ATK_002 | 이중 베기 | 2 | 6+6 |
| ATK_003 | 마법사의 화살 | 1 | 5 |
| ATK_004 | 탑의 붕괴 | 3 | 22 |
| ATK_005 | 세계의 일격 | 3 | 15+전체 |
| ATK_006 | 악몽의 채찍 | 1 | 중독+3 |
| ATK_007 | 펜타클의 화살 | 1 | 4 |
| ATK_008 | 검의 기사 | 2 | 9 |
| ATK_009 | 달의 일격 | 2 | 6+드로우 |
| ATK_010 | 잠든 용 | 3 | 0→28 |

**방어 카드 (8종)**

| ID | 이름 | 비용 | 블록 |
|----|------|------|------|
| DEF_001 | 방패의 왕 | 2 | 14 |
| DEF_002 | 철벽 | 1 | 7 |
| DEF_003 | 여황제의 가호 | 2 | 5+힐4 |
| DEF_004 | 꿈의 방벽 | 0 | 4 |
| DEF_005 | 달빛 방패 | 1 | 9 |
| DEF_006 | 강철 의지 | 2 | 12 |
| DEF_007 | 성배의 보호 | 1 | 6 |
| DEF_008 | 별빛 갑옷 | 3 | 20 |

**패링 카드 (5종)**

| ID | 이름 | 비용 | 효과 |
|----|------|------|------|
| PAR_001 | 꿈의 쳐내기 | 0 | 패링 → 에너지+2 + 드로우1 |
| PAR_002 | 반사의 순간 | 0 | 패링 → 에너지+2 + 반격30% |
| PAR_003 | 각성의 쳐내기 | 0 | 패링 → 에너지+3 (윈도우0.3초) |
| PAR_004 | 달빛 반격 | 1 | 패링 → 에너지+1 + 즉시 8공격 |
| PAR_005 | 완벽한 방어 | 0 | 패링/회피 → 에너지+1 |

**회피 카드 (5종)**

| ID | 이름 | 비용 | 효과 |
|----|------|------|------|
| DOD_001 | 꿈의 스텝 | 0 | 회피 → 에너지+1 |
| DOD_002 | 잔상 (殘像) | 0 | 회피 → 에너지+1 + 버프이전 |
| DOD_003 | 황혼의 도약 | 0 | 회피 → 에너지+1 + 다음공격+3 |
| DOD_004 | 연막 | 1 | 회피 → 에너지+1 + 적약화 |
| DOD_005 | 반보 앞으로 | 0 | 패링/회피 — 50%감소 + 에너지+1 |

**스킬 카드 (2종)**

| ID | 이름 | 비용 | 효과 |
|----|------|------|------|
| SKL_001 | 꿈의 정수 | 0 | 드로우2 |
| SKL_002 | 악몽의 씨앗 | 1 | 적 중독+5 |

---

## 🔑 핵심 설계 원칙 (구현 중 의사결정 기준)

### 1. 방어 = 자원 경제

> **패링 > 회피 > 방어** 순으로 에너지 보상이 크다.
> 방어를 잘 할수록 더 많이 공격할 수 있다는 원칙.
> 자세 게이지, 그라디언트 카운터 등 부가 시스템은 없다.

### 2. 관통 공격 (UNBLOCKABLE)

> 🔱 아이콘 공격 = 패링 불가, 회피만 유효.
> 패링 시도 시 시각/청각 피드백으로 명확하게 실패 표시.
> UI에 "방어 불가! 회피하세요!" 텍스트 표시.

### 3. Story 모드 = 기본값

> 패링 윈도우 기본값은 0.8초 (Story 모드).
> 별도 설정 없으면 Story 모드로 실행.
> SettingsManager.story_mode 플래그로 제어.

### 4. 오토 플레이 철학

> 풀오토도 볼거리가 있어야 함.
> AutoAI는 랜덤이 아닌 결정론적 우선순위 기반.
> 세미 오토: 추천만 하고 플레이어가 확정.

### 5. 모바일 UX 원칙

> 최소 터치 영역: 44px (iOS HIG 기준).
> 중요 피드백은 반드시 햅틱 + 시각 + 청각 3중 제공.
> 한 손으로 조작 가능한 레이아웃.

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

### Phase 4 — UI & VFX

```
[ ] EnergyUI — 에너지 오브 + 오버플로우 글로우 + 보너스 미리보기
[ ] HandUI — 카드 손패 + 리액션 강조 (황금 테두리 + 진동)
[ ] IntentUI — 의도 슬롯 (ATB 연동 강도 변화 포함)
[ ] ComboHintUI — 콤보 힌트 미리보기 (ATB 전용)
[ ] TarotUI + ShardUI — 보조 자원 UI (턴베이스 전용)
[ ] VFX: parry_clash, dodge_blur, hit_impact, combo_triple 등
[ ] SFX: parry_success, dodge_whoosh, block_thud, combo 계열
```

---

## 🐛 자주 발생하는 이슈 및 해결책

| 이슈 | 원인 | 해결 |
|------|------|------|
| 패링 판정 불일치 | parry_timer와 time_elapsed 기준 혼용 | ATB는 타이머 카운트다운, TB는 타임스탬프 방식 통일 |
| 에너지 오버플로우 시각화 안됨 | overflow_timer 초기화 누락 | on_parry_success() 호출 후 overflow_timer 반드시 설정 |
| 오토 AI 무한 루프 | 플레이 가능한 카드가 없는데 루프 지속 | decide_action 반환값 null 체크 필수 |
| 의도 UI 깜빡임 | advance() 호출 순서 오류 | 적 행동 완료 후에만 advance() 호출 |
| 관통 공격 패링 허용됨 | UNBLOCKABLE 타입 체크 누락 | ATBReactionManager와 TBReactionManager 모두 체크 |

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
