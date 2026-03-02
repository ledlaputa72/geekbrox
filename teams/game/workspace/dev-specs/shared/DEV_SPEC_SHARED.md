# 🔧 공통 시스템 개발 사양서
# Dream Collector — Shared Combat Systems

**대상**: Cursor IDE / Claude Code 구현용
**버전**: v1.0 | **날짜**: 2026-03-01
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
class_name Card extends Resource

@export var id: String = ""
@export var name: String = ""
@export var cost: int = 1
@export var type: String = ""       # "ATK" | "DEF" | "SKILL" | "POWER" | "CURSE"
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

### 2.2 기본 카드 목록 (30장 필수)

**공격 카드 (ATK) — 10장**

| ID | 이름 | 비용 | 데미지 | 효과 |
|----|------|------|--------|------|
| ATK_001 | 검의 에이스 | 1 | 6 | 단타 |
| ATK_002 | 이중 베기 | 2 | 9 | 2회 공격 |
| ATK_003 | 마법사 | 2 | 4 | 광역 |
| ATK_004 | 탑 | 2 | 15 | 자해 3 |
| ATK_005 | 세계 | 4 | 20 | 블록 10 |
| ATK_006 | 번개 | 1 | 8 | 단타 |
| ATK_007 | 악마 | 2 | 5 | 중독 3 |
| ATK_008 | 태양 | 3 | 18 | 강타 |
| ATK_009 | 별 | 2 | 7 | 드로우 1 |
| ATK_010 | 황제 | 3 | 12 | 힘 +2 |

(계속 DEF, PARRY, DODGE, SKILL 카드 정의...)

---

## 3. 상태이상 시스템

```gdscript
# scripts/combat/shared/StatusEffectSystem.gd
class_name StatusEffectSystem extends Node

enum StatusType {
    POISON,        # 중독: 매 턴 HP 감소
    VULNERABLE,    # 취약: 받는 피해 +50%
    WEAK,          # 약화: 주는 피해 -25%
    STRENGTH,      # 힘: 공격력 증가
    DEXTERITY,     # 민첩: 블록 획득량 증가
    BURNING,       # 화상
    ENTANGLED      # 묶음: 공격 불가
}

var statuses: Dictionary = {}

func apply(type: StatusType, stacks: int):
    statuses[type] = statuses.get(type, 0) + stacks
    StatusUI.update(type, statuses[type])

func tick_turn():
    if statuses.has(StatusType.POISON):
        owner.take_damage(statuses[StatusType.POISON])
        statuses[StatusType.POISON] -= 1

func get_damage_multiplier() -> float:
    var mult = 1.0
    if statuses.has(StatusType.VULNERABLE):
        mult *= 1.5
    return mult
```

---

## 4. 설정 관리자 (SettingsManager)

```gdscript
# scripts/autoloads/SettingsManager.gd
extends Node

var parry_window_story_mode: bool = true
var auto_play_mode: int = 0  # 0=수동, 1=세미, 2=풀오토
var battle_speed: float = 1.0
var lumi_enabled: bool = true

func get_parry_window() -> float:
    return 0.8 if parry_window_story_mode else 0.5

func save():
    var config = ConfigFile.new()
    config.set_value("combat", "story_mode", parry_window_story_mode)
    config.save("user://settings.cfg")
```

---

**다음 문서**: DEV_SPEC_ATB.md, DEV_SPEC_TURNBASED.md
