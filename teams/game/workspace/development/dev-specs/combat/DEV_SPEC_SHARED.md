# 🔧 공통 시스템 개발 사양서
# Dream Collector — Shared Combat Systems

**대상**: Cursor IDE / Claude Code 구현용
**버전**: v2.0 | **날짜**: 2026-03 (카드 타입 4체계 업데이트)
**작성**: Kim.G (게임팀장) + OPS 플레이테스트 반영

> ⚠️ 이 문서는 ATB와 턴베이스 두 전투 모드에서 공통으로 사용하는 시스템을 정의합니다.

---

## 1. 프로젝트 기본 설정

**엔진**: Godot 4.x (GDScript)
**타겟**: 모바일 (iOS / Android), 세로 모드
**화면 해상도**: 1080×1920 기준 (비율 9:16)
**최소 터치 영역**: 44px (iOS HIG 기준)

### 폴더 구조

```
res://
├── scripts/
│   ├── combat/
│   │   ├── shared/          ← 이 문서 대상
│   │   ├── atb/             ← DEV_SPEC_ATB.md 대상
│   │   └── turnbased/       ← DEV_SPEC_TURNBASED.md 대상
│   ├── cards/
│   ├── ui/
│   └── autoloads/
├── scenes/
│   ├── combat/
│   └── ui/
└── assets/
    ├── cards/
    ├── vfx/
    └── sfx/
```

---

## 2. 카드 시스템 (Card System)

### 2.1 Card 클래스

```gdscript
# scripts/cards/Card.gd
class_name Card
extends Resource

@export var id: String = ""
@export var name: String = ""
@export var cost: int = 1
@export var type: String = ""       # "ATTACK" | "SKILL" | "POWER" | "CURSE"
                                    # ⚠️ v2.0: 기존 "ATK"→"ATTACK", "DEF"→"SKILL", 별도 "POWER"/"CURSE" 추가
@export var tags: Array[String] = []  # ["PARRY", "DODGE", "GUARD", "MAJOR_ARCANA"]
@export var rarity: String = "COMMON"  # COMMON | RARE | SPECIAL | LEGENDARY
@export var description: String = ""
@export var short_desc: String = ""   # 모바일용 짧은 설명 (아이콘+숫자)

# 효과 데이터
@export var damage: int = 0
@export var block: int = 0
@export var draw: int = 0
@export var energy_cost_reduction: int = 0
@export var status_effects: Array[Dictionary] = []

# 태그 체크
func has_tag(tag: String) -> bool:
    return tags.has(tag)

func is_major_arcana() -> bool:
    return tags.has("MAJOR_ARCANA")

func get_mobile_description() -> String:
    if short_desc != "":
        return short_desc
    # 자동 생성
    var parts = []
    if damage > 0: parts.append("⚔️%d" % damage)
    if block > 0:  parts.append("🛡️%d" % block)
    if draw > 0:   parts.append("✨드로우%d" % draw)
    return " ".join(parts)

func dmg_per_energy() -> float:
    if cost == 0: return float(damage)
    return float(damage) / float(cost)
```

### 2.2 카드 등급 색상

```gdscript
# scripts/cards/CardRarityColor.gd
static func get_border_color(rarity: String) -> Color:
    match rarity:
        "COMMON":    return Color(0.7, 0.7, 0.7)   # 회색
        "RARE":      return Color(0.2, 0.5, 1.0)   # 파란색
        "SPECIAL":   return Color(1.0, 0.8, 0.0)   # 금색
        "LEGENDARY": return Color.from_hsv(0.0, 0.0, 1.0)  # 무지개 (애니메이션)
    return Color.WHITE
```

### 2.3 기본 카드 목록 (30장 구현 필수)

**공격 카드 (ATK) — 10장**:
| ID | 이름 | 비용 | 데미지 | 효과 |
|----|------|------|--------|------|
| ATK_001 | 검의 에이스 | 1 | 6 | 단타 |
| ATK_002 | 이중 베기 | 2 | 9 | 2회 공격 (각 4.5) |
| ATK_003 | 마법사 | 2 | 4 | 전체 광역 |
| ATK_004 | 탑 | 2 | 15 | 자해 3 |
| ATK_005 | 세계 | 4 | 20 + 🛡️10 | 복합 |
| ATK_006 | 번개 | 1 | 8 | 단타 |
| ATK_007 | 악마 | 2 | 5 + 중독3 | 광역 디버프 |
| ATK_008 | 태양 | 3 | 18 | 강타 |
| ATK_009 | 별 | 2 | 7 + 드로우1 | 유틸 공격 |
| ATK_010 | 황제 | 3 | 12 + 힘+2 | 버프 공격 |

**방어 카드 (DEF) — 8장**:
| ID | 이름 | 비용 | 블록 | 효과 |
|----|------|------|------|------|
| DEF_001 | 방패의 왕 | 2 | 12 | 기본 방어 |
| DEF_002 | 철벽 | 1 | 5 | 저비용 |
| DEF_003 | 여황제 | 3 | 18 | 강한 방어 |
| DEF_004 | 교황 | 2 | 8 + 드로우1 | 방어+드로우 |
| DEF_005 | 달 | 2 | 10 + 민첩+1 | 방어 강화 |
| DEF_006 | 정의 | 1 | 7 | 균형 |
| DEF_007 | 은둔자 | 2 | 15 | 순수 방어 |
| DEF_008 | 절제 | 1 | 4 + HP2 | 소량 치유 |

**패링 카드 (PARRY 태그) — 5장**:
| ID | 이름 | 비용 | 효과 |
|----|------|------|------|
| PAR_001 | 꿈의 쳐내기 | 0 | 패링: 무효 + ⚡+2(다음) + 드로우1 |
| PAR_002 | 반사의 순간 | 0 | 패링: 무효 + ⚡+2 + 30% 반격 |
| PAR_003 | 각성의 쳐내기 | 0 | 패링: 무효 + ⚡+3 (윈도우 0.3초) |
| PAR_004 | 달빛 반격 | 1 | 패링: 무효 + ⚡+1 + 8 반격 |
| PAR_005 | 완벽한 방어 | 0 | 패링/회피 겸용: 무효 + ⚡+1 |

**회피 카드 (DODGE 태그) — 5장**:
| ID | 이름 | 비용 | 효과 |
|----|------|------|------|
| DOD_001 | 꿈의 스텝 | 0 | 회피: ⚡+1(다음) |
| DOD_002 | 잔상 | 0 | 회피: ⚡+1 + 버프 이전 |
| DOD_003 | 황혼의 도약 | 0 | 회피: ⚡+1 + 다음 공격 +3 |
| DOD_004 | 연막 | 1 | 회피: ⚡+1 + 적 다음 공격 -3 |
| DOD_005 | 반보 앞으로 | 0 | 패링/회피: 50% 감소 + ⚡+1 |

**스킬 카드 (SKILL) — 2장**:
| ID | 이름 | 비용 | 효과 |
|----|------|------|------|
| SKL_001 | 바보 | 0 | 드로우1 + 에너지+1 |
| SKL_002 | 달의 환영 | 2 | 드로우3 (타로 에너지 2 소모 버전 별도) |

---

## 3. 상태이상 시스템

```gdscript
# scripts/combat/shared/StatusEffectSystem.gd
class_name StatusEffectSystem
extends Node

enum StatusType {
    POISON,       # 중독: 매 턴 HP 감소
    VULNERABLE,   # 취약: 받는 피해 +50%
    WEAK,         # 약화: 주는 피해 -25%
    STRENGTH,     # 힘: 공격력 증가 (영구)
    DEXTERITY,    # 민첩: 블록 획득량 증가 (영구)
    BURNING,      # 화상: 중독과 유사, 별도 스택
    ENTANGLED     # 묶음: 이번 턴 공격 불가
}

var statuses: Dictionary = {}  # StatusType → stack_count

func apply(type: StatusType, stacks: int):
    statuses[type] = statuses.get(type, 0) + stacks
    StatusUI.update(type, statuses[type])

func tick_turn():
    # 매 턴 적용
    if statuses.has(StatusType.POISON):
        owner.take_damage(statuses[StatusType.POISON])
        statuses[StatusType.POISON] -= 1
        if statuses[StatusType.POISON] <= 0:
            statuses.erase(StatusType.POISON)

func get_damage_multiplier() -> float:
    var mult = 1.0
    if statuses.has(StatusType.VULNERABLE):
        mult *= 1.5
    return mult

func get_outgoing_multiplier() -> float:
    var mult = 1.0
    if statuses.has(StatusType.WEAK):
        mult *= 0.75
    return mult
```

---

## 4. 전투 일지 (Battle Diary) — 공통

```gdscript
# scripts/combat/shared/BattleDiary.gd
class_name BattleDiary
extends Node

var stats: Dictionary = {
    "start_time": 0,
    "parry_attempts": 0,
    "parry_successes": 0,
    "dodge_successes": 0,
    "combos_triggered": 0,
    "best_combo_name": "",
    "total_damage_dealt": 0,
    "total_damage_taken": 0,
    "cards_played": 0,
}

func start():
    stats["start_time"] = Time.get_ticks_msec()

func record_parry(success: bool):
    stats["parry_attempts"] += 1
    if success: stats["parry_successes"] += 1

func compile_report() -> Dictionary:
    var duration = (Time.get_ticks_msec() - stats["start_time"]) / 1000.0
    var parry_rate = 0.0
    if stats["parry_attempts"] > 0:
        parry_rate = float(stats["parry_successes"]) / stats["parry_attempts"]
    return {
        "duration": duration,
        "parry_rate": parry_rate,
        "combos": stats["combos_triggered"],
        "best_combo": stats["best_combo_name"],
        "cards_played": stats["cards_played"],
        "tip": _generate_tip(parry_rate)
    }

func _generate_tip(parry_rate: float) -> String:
    if parry_rate < 0.4:
        return "패링 카드를 더 활용해보세요! 성공 시 에너지가 즉시 +2 충전돼요."
    if stats["combos_triggered"] == 0:
        return "공격 카드 3장을 연속으로 쓰면 콤보가 발동해요! 데미지 +75%!"
    return "완벽한 전투였어요! 🌟"
```

---

## 5. 설정 관리자 (SettingsManager)

```gdscript
# scripts/autoloads/SettingsManager.gd
extends Node

# 전투 설정
var crisis_slow_enabled: bool = true
var parry_window_story_mode: bool = true   # true = Story 모드 (0.8초), false = 하드 (0.5초)
var dodge_window_hard_mode: bool = false   # true = 하드 모드 (0.8초)
var auto_play_mode: int = 0               # 0=수동, 1=세미오토, 2=풀오토
var battle_speed: float = 1.0             # 1.0 / 1.5 / 2.0 / 2.5
var lumi_enabled: bool = true
var card_anim_speed: float = 1.0

# 계산 속성
func get_parry_window() -> float:
    return 0.8 if parry_window_story_mode else 0.5

func get_dodge_window() -> float:
    return 0.8 if dodge_window_hard_mode else 1.2

func save():
    var config = ConfigFile.new()
    config.set_value("combat", "crisis_slow", crisis_slow_enabled)
    config.set_value("combat", "story_mode", parry_window_story_mode)
    config.set_value("combat", "auto_play", auto_play_mode)
    config.set_value("combat", "speed", battle_speed)
    config.set_value("combat", "lumi", lumi_enabled)
    config.save("user://settings.cfg")
```

---

## 6. 몬스터 데이터 구조

```gdscript
# scripts/combat/shared/Monster.gd
class_name Monster
extends Node

@export var id: String = ""
@export var display_name: String = ""
@export var max_hp: int = 50
@export var atk: int = 10
@export var spd: float = 50.0      # ATB 속도 (높을수록 빠름)
@export var action_patterns: Array[Dictionary] = []
# 패턴 예시:
# [{"type": "NORMAL", "damage_mult": 1.0},
#  {"type": "HEAVY",  "damage_mult": 2.0},
#  {"type": "DEFEND", "block": 8},
#  {"type": "BUFF",   "stat": "atk", "value": 3}]

var current_hp: int = 0
var action_index: int = 0
var atb: float = 0.0
var status_effects: StatusEffectSystem

func get_next_action() -> Dictionary:
    return action_patterns[action_index % action_patterns.size()]

func advance_action():
    action_index += 1

func get_next_damage() -> int:
    var action = get_next_action()
    if action.get("type") == "NORMAL" or action.get("type") == "HEAVY":
        return int(atk * action.get("damage_mult", 1.0))
    return 0
```

---

## 7. UI 컴포넌트 스펙

### 7.1 카드 UI

```
[카드 크기]
기본: 80px × 110px
터치 히트박스: +10px 사방 확장 (100px × 130px)
카드 간격: 최소 8px
최대 손패 표시: 7장 (7장 이상 시 겹쳐서 표시)

[카드 표시 레이어]
상단: 에너지 비용 (20px 볼드)
중단: 카드 이미지
하단: 카드 이름 (14px) + 효과 아이콘+숫자 (12px)

[태그별 강조 표시]
PARRY: 황금 테두리 + 진동 (적 ATB 80%+)
DODGE: 청록 테두리 + 진동
MAJOR_ARCANA: 금색 테두리 상시
패링 불가 공격 시: 패링 카드 회색 처리
```

### 7.2 에너지 UI

```
[에너지 표시]
기본: ⚡⚡⚡ (파란 원형 3개)
오버플로우 (4~5): 추가 황금 원형
충전 중: 회색 원형 (빈 에너지)
방어 보너스 예정 (턴베이스): 에너지 바 우측에 "+N" 미리보기 표시
```

### 7.3 의도(Intent) UI

```
[적 HP 바 아래 의도 표시]
현재 행동 아이콘 (크게) + 예정 1~2행동 (작게)
강한 공격: 빨간색 배경
관통 공격: 보라색 배경 + 🔱 아이콘
```

---

## 8. 오디오/VFX 요구사항

| 이벤트 | 사운드 | VFX |
|--------|--------|-----|
| 패링 성공 | "clang" 금속음 | 흰 링 폭발 + 화면 0.1초 플래시 |
| 회피 성공 | "whoosh" 바람 | 잔상 이펙트 |
| 방어 성공 | "thud" 둔탁 | 방패 글로우 |
| 에너지 충전 | 차임벨 | 에너지 바 충전 애니메이션 |
| 콤보 발동 | 상승 효과음 | 파티클 폭발 + "COMBO!" 텍스트 |
| 위기 개입 | 긴박한 알람 | 화면 빨간 테두리 맥박 |
| 집중 모드 | 저음 울림 | 시간 왜곡 이펙트 |

---

**다음 문서**: DEV_SPEC_ATB.md, DEV_SPEC_TURNBASED.md
