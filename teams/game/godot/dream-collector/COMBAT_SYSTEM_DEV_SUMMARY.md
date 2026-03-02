# 🗡️ Dream Collector — 전투 시스템 개발 요약
> **작성일**: 2026-03-01 | **작성**: Claude Code
> **목적**: Cursor AI 온보딩용 — 이 문서 하나로 전체 전투 시스템을 파악할 수 있습니다.

---

## 1. 개요

Dream Collector는 **ATB 전투(일반)** + **턴베이스 전투(보스)** 두 가지 전투 시스템을 갖춘 모바일 로그라이크 덱빌딩 게임입니다.

| 항목 | 내용 |
|------|------|
| 엔진 | Godot 4.x / GDScript |
| 해상도 | 390×844 (Portrait, 9:16) |
| 전투 구조 | 일반 몬스터 → **ATB** / 보스 → **턴베이스** |
| 공통 자원 | 카드 30종, 몬스터 클래스, 상태이상, 전투 일지 |
| 단축키 전환 | F1=ATB 강제 / F2=턴베이스 강제 / F3=자동 복귀 |

---

## 2. 폴더 구조

```
res://
├── scripts/
│   ├── combat/
│   │   ├── shared/          ← 두 전투 모드 공통 시스템
│   │   │   ├── Card.gd
│   │   │   ├── CardDatabase.gd
│   │   │   ├── Monster.gd
│   │   │   ├── StatusEffectSystem.gd
│   │   │   └── BattleDiary.gd
│   │   ├── atb/             ← ATB 전투 (일반 몬스터)
│   │   │   ├── CombatManagerATB.gd
│   │   │   ├── ATBEnergySystem.gd
│   │   │   ├── ATBReactionManager.gd
│   │   │   ├── ATBIntentSystem.gd
│   │   │   ├── ATBComboSystem.gd
│   │   │   ├── ATBAutoAI.gd
│   │   │   ├── ATBFocusMode.gd
│   │   │   └── ATBCrisisMode.gd
│   │   └── turnbased/       ← 턴베이스 전투 (보스)
│   │       ├── CombatManagerTB.gd
│   │       ├── TurnBasedEnergySystem.gd
│   │       ├── TurnBasedReactionManager.gd
│   │       ├── TurnBasedIntentSystem.gd
│   │       ├── TurnBasedHandSystem.gd
│   │       ├── TarotEnergySystem.gd
│   │       ├── DreamShardSystem.gd
│   │       ├── DeckPassiveCalculator.gd
│   │       └── TurnBasedAutoAI.gd
│   └── autoloads/
│       └── SettingsManager.gd   ← 전투 설정 전역 관리
├── scenes/
│   └── combat/
│       ├── CombatSceneATB.tscn  ← ATB 씬 트리
│       └── CombatSceneTB.tscn   ← 턴베이스 씬 트리
└── ui/screens/
    └── InRun_v4.gd              ← 전투 진입점 (수정됨)
```

**project.godot autoload 등록**:
```
SettingsManager = res://scripts/autoloads/SettingsManager.gd
CardDatabase    = res://scripts/combat/shared/CardDatabase.gd
```

---

## 3. 공통 시스템

### 3-1. Card.gd
```gdscript
class_name Card extends Resource

# 주요 프로퍼티
@export var id: String          # "ATK_001"
@export var type: String        # "ATK" | "DEF" | "SKILL" | "POWER" | "CURSE"
@export var tags: Array[String] # ["PARRY", "DODGE", "GUARD", "MAJOR_ARCANA"]
@export var cost: int           # 에너지 비용
@export var damage: int
@export var block: int
@export var draw: int
@export var status_effects: Array[Dictionary]  # [{target, type, value}]

# 주요 메서드
func has_tag(tag: String) -> bool
func is_major_arcana() -> bool
func duplicate_card() -> Card
func dmg_per_energy() -> float   # 효율 계산용
```

### 3-2. CardDatabase.gd (Autoload)
30종 카드 전체 정의. `CardDatabase.get_starter_deck()` 또는 `CardDatabase.get_by_id("ATK_001")`으로 접근.

**카드 목록 요약**:
| 분류 | 수 | 예시 |
|------|----|------|
| ATK (공격) | 10 | 검의 에이스(1/6), 세계(4/20+블록10) |
| DEF (방어) | 8  | 철벽(1/블록5), 여황제(3/블록18) |
| PARRY (패링) | 5 | 꿈의 쳐내기(0/패링+드로우1), 완벽한 방어(겸용) |
| DODGE (회피) | 5 | 꿈의 스텝(0/회피+⚡+1), 황혼의 도약 |
| SKILL       | 2 | 바보(0/드로우1+⚡+1), 달의 환영(2/드로우3) |

**스타터 덱**: `CardDatabase.get_starter_deck()` — 10장 기본 구성 반환

### 3-3. Monster.gd
```gdscript
class_name Monster extends Node

@export var id: String
@export var display_name: String
@export var max_hp: int
@export var atk: int
@export var spd: float          # ATB 충전 속도 (100=기준속도)
@export var is_boss: bool
@export var action_patterns: Array[Dictionary]
# 패턴 예: {"type": "NORMAL"|"HEAVY"|"UNBLOCKABLE"|"BUFF"|"DEFEND", "damage_mult": 1.0}

# 런타임
var current_hp: int
var atb: float                  # ATB 게이지 (0~100)
var block: int
var status_effects: Dictionary  # {"VULNERABLE": 2, "WEAK": 1, ...}

# 주요 메서드
func is_alive() -> bool
func hp_ratio() -> float
func take_damage(dmg: int)
func get_next_action() -> Dictionary
func get_action_queue(count: int) -> Array[Dictionary]  # 턴베이스 의도용
func make_attack_data() -> Dictionary  # CombatManager 전달용
```

### 3-4. StatusEffectSystem.gd
```gdscript
class_name StatusEffectSystem extends Node

# 7종 상태이상
enum StatusType { POISON, VULNERABLE, WEAK, STRENGTH, DEXTERITY, BURNING, ENTANGLED }

func apply(type, stacks: int)
func tick_turn()                       # 매 턴 DoT 처리
func get_damage_multiplier() -> float  # 취약: 1.5배
func get_outgoing_multiplier() -> float # 약화: 0.75배

# 정적 메서드 (외부에서 대상 직접 지정)
static func apply_to(target, type, stacks: int)
```

### 3-5. BattleDiary.gd
전투 통계 추적 + 결과 팁 생성. `battle_diary.compile_report()` → 패링률, 콤보 수, 소요 시간 등 반환.

### 3-6. SettingsManager.gd (Autoload)
```gdscript
# 전투 모드 결정 (InRun_v4에서 호출)
func get_combat_mode(is_boss: bool) -> String  # "ATB" | "TURNBASED"

# 주요 설정값
var story_mode: bool = true         # 패링 윈도우 0.8s (false=0.5s)
var crisis_slow_enabled: bool = true
var battle_speed: float = 1.0       # 1.0 / 1.5 / 2.0 / 2.5

# 강제 전환 (InRun_v4 F1/F2 단축키 연동)
var force_atb_mode: bool = false
var force_tb_mode: bool = false
```

---

## 4. ATB 전투 시스템

**진입**: `InRun_v4.switch_to_combat(false)` → `_start_atb_combat()` → `CombatManagerATB.start_combat()`

### 핵심 수치
| 항목 | 값 |
|------|----|
| ATB_MAX | 100 |
| 기본 충전 속도 | spd/100 × 1.0/초 |
| 에너지 기본 | 3 (오버플로우 최대 5) |
| 오버플로우 지속 | **3초** (OPS 피드백) |
| 패링 윈도우 (Story) | **0.8초** |
| 회피 윈도우 (Story) | **1.8초** |
| 반격 창 | **2.0초** |
| 집중 모드 지속 | 3초 / 드레인 **10%/초** |
| 위기 모드 지속 | **10초** (HP ≤ 30%) |

### CombatManagerATB.gd — 핵심 흐름
```
start_combat(player_data, enemies, deck)
    ↓
_process(delta)
    ├─ _update_atb(delta)         # ATB 충전
    ├─ energy_system.update_timer  # 에너지 자동 회복
    └─ crisis_mode.check           # HP ≤ 30% 체크

_on_enemy_atb_full(enemy)
    ├─ reaction_mgr.open_reaction_window(attack)
    ├─ await reaction_mgr.reaction_resolved
    └─ _apply_attack_result(...)   # PARRY/DODGE/GUARD/NONE

player_play_card(card)
    ├─ reaction_open? → reaction_mgr.on_player_tap_card(card)
    └─ _resolve_card_effect(card)  # ATK/DEF/상태이상/드로우
```

### ATBEnergySystem.gd
```gdscript
# 방어 성공 시 에너지 보상
on_parry_success()  → +2 (즉시, 오버플로우 가능)
on_dodge_success()  → +1
on_guard_success()  → +0.5

# 오버플로우: 3초간 최대 5 에너지 유지 후 3으로 감소
```

### ATBReactionManager.gd
```gdscript
# 윈도우 오픈 → 플레이어 카드 탭 → 결과 emit
open_reaction_window(attack: Dictionary)
on_player_tap_card(card: Card)

# 판정 결과: ReactionResult { type: "PARRY"|"DODGE"|"GUARD"|"NONE", card }
# UNBLOCKABLE 공격: PARRY 불가, DODGE만 유효
```

### ATBComboSystem.gd — 4종 콤보
| 이름 | 조건 | 보너스 |
|------|------|--------|
| 연타 | ATK 3연속 | +75% 데미지 |
| 완벽한 방어 | DEF 2연속 | 블록 +10 (별도) |
| 패링 반격 | PARRY → ATK | +30% 데미지 |
| 약점 폭로 | VULNERABLE 부여 → ATK | +50% 데미지 |

`combo_system.get_next_combo_hint()` → 힌트 문자열 반환 (UI 표시용)

### ATBFocusMode.gd
- `activate()` → 에너지 1 소모 → 속도 0.3배 슬로우 3초
- 도중 `deactivate_by_player()` 가능

### ATBCrisisMode.gd
- HP ≤ 30% 감지 → `_enter_crisis()` → 속도 0.5배 10초
- 한 전투에 1회만 발동 (`triggered_once`)

### ATBAutoAI.gd — 3단계
```gdscript
enum AutoMode { MANUAL, SEMI, FULL }

# 행동 결정 우선순위:
# 1) 적 ATB ≥ 80% → 방어 카드
# 2) 적 HP ≤ 30% → 강한 공격
# 3) VULNERABLE 없음 → 디버프 카드
# 4) 기본 → 코스트 대비 효율 공격 (damage/cost)
```

---

## 5. 턴베이스 전투 시스템

**진입**: `InRun_v4.switch_to_combat(true)` → `_start_tb_combat()` → `CombatManagerTB.start_combat()`

### 턴 흐름
```
[플레이어 턴]
  ├─ 에너지 3 + 이전 턴 방어 보너스 지급
  ├─ 카드 5장 드로우 (+ 패링 보너스)
  ├─ 의도 표시 (적 다음 2~3행동)
  └─ 카드 플레이 or 턴 종료 버튼

[적 턴]
  ├─ 각 적 행동 순서대로
  ├─ 리액션 윈도우 열림 (패링/회피 가능)
  └─ 상태이상 DoT 처리

[반복]
```

### TurnBasedEnergySystem.gd
```gdscript
const BASE_ENERGY = 3
const PARRY_BONUS = 2   # 패링 성공 → 다음 턴 +2
const DODGE_BONUS = 1   # 회피 성공 → 다음 턴 +1

# start_player_turn() 호출 시 pending_energy_bonus 합산 (최대 5)
# OPS 피드백: 보너스 미리보기 → UI에 금색/하늘색으로 표시
```

### TurnBasedHandSystem.gd
```gdscript
const HAND_MAX = 10   # 손패 최대

initialize(deck_list: Array[Card])
draw_to_hand(n: int)    # 덱 → 손패 (덱 소진 시 버림더미 셔플)
discard_card(card)
discard_remaining()     # 턴 종료 시 전체 버림
```

### TarotEnergySystem.gd
- 메이저 아르카나 태그 카드 사용 시 타로 에너지 +1 (최대 3)
- 타로 스킬: `달의 환영(×2)`, `태양의 폭발(×3)`, `심판의 날(×2)`

### DreamShardSystem.gd
```gdscript
enum ShardAbility { QUICK_DRAW(1), ENERGY_BURST(2), DREAM_HEAL(3), NIGHTMARE(5) }

# 꿈 조각 획득: 패링 성공 시 +1 (CombatManagerTB에서 호출)
# 최대 5 보유
```

### DeckPassiveCalculator.gd — 5종 패시브
| 조건 | 패시브명 | 효과 |
|------|----------|------|
| DEF ≥ 5장 | 달의 기사 | 매 플레이어 턴 블록 +3 |
| ATK ≥ 7장 | 검의 달인 | 첫 공격 데미지 +2 |
| 메이저 아르카나 ≥ 3 | 타로 학자 | 전투 시작 타로 에너지 +1 |
| PARRY ≥ 4장 | 달빛 반격사 | 패링 에너지 보너스 +1 추가 |
| SKILL ≥ 3장 | 꿈꾸는 자 | 매 턴 꿈 조각 +1 |

### TurnBasedAutoAI.gd
```gdscript
# 방어 결정 (적 턴 리액션)
decide_defense(hand, attack, energy) -> Card
# UNBLOCKABLE → DODGE 전용
# 강한 공격(base*1.3 초과) → 70% 확률 PARRY 시도

# 공격 결정 (플레이어 턴)
decide_attack_cards(hand, energy, enemy, player_hp_ratio) -> Array[Card]
# HP < 40% → DEF 카드 우선
# damage/cost 효율순 ATK 선택
```

### CombatManagerTB.gd — 주요 공개 API
```gdscript
start_combat(p_data: Dictionary, enemy_list: Array, card_deck: Array[Card])
player_play_card(card: Card)    # 플레이어 입력 진입점
player_end_turn()               # 턴 종료 버튼 연결
use_shard_ability(ability: int) # 꿈 조각 사용
use_tarot_skill(skill_name: String) # 타로 스킬 사용

# 시그널
signal combat_ended(result: String)     # "WIN" | "LOSE"
signal player_turn_started(energy, hand)
signal player_hp_changed(hp, max_hp)
signal enemy_hp_changed(idx, hp, max_hp)
signal hand_updated(hand)
signal energy_updated(current, base)
signal tarot_updated(current, max)
signal shard_updated(current, max)
```

---

## 6. InRun_v4.gd — 전투 진입 로직 (수정 사항)

### 전투 모드 분기
```gdscript
# 새로 추가된 변수
var current_is_boss: bool = false
var active_combat_scene: Node = null
var combat_mode_override: String = ""  # "" | "ATB" | "TURNBASED"

# 전투 전환 함수 (기존 switch_to_combat() 확장)
func switch_to_combat(is_boss: bool = false):
    # 모드 결정 우선순위:
    # 1) combat_mode_override (F1/F2 단축키)
    # 2) SettingsManager.get_combat_mode(is_boss)
    # 3) 기본: is_boss → TURNBASED, else → ATB
    if combat_mode == "TURNBASED":
        await _start_tb_combat()
    else:
        await _start_atb_combat()
```

### 단축키
| 키 | 동작 |
|----|------|
| `2` | 일반 전투 (ATB) 테스트 |
| `B` | 보스 전투 (턴베이스) 테스트 |
| `F1` | ATB 강제 모드 ON |
| `F2` | 턴베이스 강제 모드 ON |
| `F3` | 강제 모드 해제 (자동 판단) |

### 이벤트 → 전투 분기
```gdscript
_handle_combat_event() → switch_to_combat(false)  # 일반 몬스터 → ATB
_handle_boss_event()   → switch_to_combat(true)   # 보스 → 턴베이스

# _handle_time_log_event()의 "boss" 타입도 switch_to_combat(true)
```

### 새 전투 시스템 → InRun_v4 시그널 연결
```gdscript
manager.combat_ended.connect(_on_new_combat_ended)
manager.player_hp_changed.connect(_on_new_player_hp_changed)
manager.enemy_hp_changed.connect(_on_new_enemy_hp_changed)
```

---

## 7. 씬 트리 구조

### CombatSceneATB.tscn
```
CombatSceneATB (Node)
└─ CombatManagerATB
   ├─ ATBEnergySystem
   ├─ ATBReactionManager
   ├─ ATBIntentSystem
   ├─ ATBComboSystem
   ├─ ATBAutoAI
   ├─ ATBFocusMode
   ├─ ATBCrisisMode
   └─ BattleDiary
EnemyGroup (Node)
UI (CanvasLayer)
   ├─ EnergyUI        ← ⚡⚡⚡ + 오버플로우 골드
   ├─ HandUI          ← 손패 (패링/회피 강조)
   ├─ IntentUI        ← 적 ATB 위험 단계 표시
   ├─ ComboHintUI     ← 콤보 힌트 Label
   ├─ FocusUI         ← 집중 모드 게이지 (ProgressBar)
   ├─ CrisisUI        ← 위기 모드 Label (빨강)
   └─ ATBBarUI        ← ATB 게이지
```

### CombatSceneTB.tscn
```
CombatSceneTB (Node)
└─ CombatManagerTB
   ├─ TurnBasedEnergySystem
   ├─ TurnBasedReactionManager
   ├─ TurnBasedIntentSystem
   ├─ TurnBasedHandSystem
   ├─ TarotEnergySystem
   ├─ DreamShardSystem
   ├─ DeckPassiveCalculator
   ├─ TurnBasedAutoAI
   └─ BattleDiary
EnemyGroup (Node)
UI (CanvasLayer)
   ├─ EnergyUI         ← 에너지 오브 + 보너스 미리보기
   ├─ HandUI           ← 손패 (최대 10장)
   ├─ IntentUI         ← 다음 2~3행동 슬롯
   ├─ TarotUI          ← 🌙×3 (보라색)
   ├─ ShardUI          ← ◆×5 (청록색)
   ├─ DeckPassiveUI    ← 활성 패시브 목록
   ├─ TurnEndButton    ← "턴 종료" 버튼
   └─ AutoModeToggle   ← 수동/세미/풀오토 전환
```

---

## 8. 향후 연동 필요 작업 (TODO)

### 높은 우선순위
- [ ] **CombatBottomUI 연동**: `InRun_v4`의 `_on_bottom_ui_action("card_played")`가 현재 기존 `CombatManager`를 호출 중 → 새 ATB/TB 매니저로 라우팅 필요
- [ ] **HandUI 실제 구현**: 현재 씬에 빈 HBoxContainer. 카드 80×110px 아이템 + PARRY/DODGE 강조 애니메이션 필요
- [ ] **EnergyUI 실제 구현**: ⚡ 오브 3개 + 오버플로우 골드 글로우 애니메이션
- [ ] **IntentUI 실제 구현**: 적 의도 아이콘 + ATB 위험 단계 색상
- [ ] **ATBBarUI**: ATB 게이지 (플레이어 + 적 각각)

### 중간 우선순위
- [ ] **VFX/SFX 연동**: `VFX.play()`, `SFX.play()` 호출이 스텁 상태 → 실제 이펙트 씬/오디오 연결
- [ ] **몬스터 스프라이트**: `_create_test_monster_nodes()`에서 생성한 Monster 노드의 스프라이트 경로 매핑
- [ ] **TurnEndButton 시그널**: CombatSceneTB.tscn의 TurnEndButton → `CombatManagerTB.player_end_turn()` 연결
- [ ] **AutoModeToggle 시그널**: `TurnBasedAutoAI.set_mode()` 연결

### 낮은 우선순위
- [ ] **카드 Resource 파일(.tres)**: 현재 CardDatabase.gd 코드 기반 생성. 필요시 30장 각각 `.tres` 파일로 Export 가능
- [ ] **보스 몬스터 데이터**: `_create_test_monster_nodes(true)` — 현재 테스트 보스 1마리. 실제 보스 데이터 추가 필요
- [ ] **Haptics**: `Haptics.vibrate_light()` 등 모바일 진동 플러그인 연결

---

## 9. 핵심 상수 치트시트

```gdscript
# ATB
ATB_MAX = 100.0
ENERGY_MAX = 3
ENERGY_OVERFLOW_MAX = 5
OVERFLOW_DURATION = 3.0       # 오버플로우 지속 (초)
PARRY_WINDOW_STORY = 0.8      # 패링 윈도우 (초)
DODGE_WINDOW_STORY = 1.8      # 회피 윈도우 (초)
COUNTER_WINDOW = 2.0          # 반격 창
FOCUS_SPEED = 0.3             # 집중 모드 속도 배율
FOCUS_DURATION = 3.0          # 집중 모드 지속
FOCUS_DRAIN_RATE = 0.1        # 10%/초
CRISIS_HP_THRESHOLD = 0.30    # 위기 진입 HP 비율
CRISIS_SPEED = 0.5            # 위기 모드 속도 배율
CRISIS_DURATION = 10.0        # 위기 모드 지속

# 턴베이스
BASE_ENERGY = 3
PARRY_BONUS = 2    # 패링 → 다음 턴 에너지 +2
DODGE_BONUS = 1    # 회피 → 다음 턴 에너지 +1
OVERFLOW_MAX = 5   # 에너지 최대 (보너스 포함)
HAND_DRAW = 5      # 턴 시작 드로우 수
HAND_MAX = 10      # 손패 최대
TAROT_MAX = 3      # 타로 에너지 최대
SHARD_MAX = 5      # 꿈 조각 최대

# 콤보 보너스
연타 = +75%
패링 반격 = +30%
약점 폭로 = +50%
```

---

## 10. 참조 문서

| 문서 | 위치 |
|------|------|
| 공통 시스템 사양서 | `dev-specs/combat/DEV_SPEC_SHARED.md` |
| ATB 시스템 사양서 | `dev-specs/combat/DEV_SPEC_ATB.md` |
| 턴베이스 시스템 사양서 | `dev-specs/combat/DEV_SPEC_TURNBASED.md` |
| 구현 가이드 전체 | `dev-specs/combat/README_FOR_CURSOR.md` |
| 프로젝트 컨텍스트 | `PROJECT_CONTEXT.md` |
| InRun 화면 구조 | `ui/screens/InRun_v4.gd` 상단 docstring |
