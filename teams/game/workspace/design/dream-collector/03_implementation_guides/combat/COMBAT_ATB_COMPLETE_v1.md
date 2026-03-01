# ⚡ ATB 전투 시스템 — 최종 완성 설계서 v1.0
# Dream Collector | Active Time Battle Combat

**문서 버전**: COMPLETE v1.0 (모든 이전 설계 통합본)
**작성일**: 2026-03-01  
**작성자**: Kim.G (게임팀장)
**통합 출처**: ATB_v2, ATB_v3, REACTION_ATB_v1, REACTION_INTENT_v3, OPS 분석 리포트 4종
**상태**: ✅ 개발 이관 준비 완료

> 이 문서는 Dream Collector ATB 전투 시스템의 **단일 최종 레퍼런스**입니다.
> 모든 이전 기획서의 내용이 이 문서 하나로 통합되었습니다.

---

## PART 1. 시스템 개요

### 1.1 ATB 전투 핵심 철학

**세 가지 원칙**:
1. **오토도 재밌다** — 풀오토 플레이어도 볼거리와 전략이 있음
2. **잘 막으면 더 공격한다** — 방어 성공 → 즉시 에너지 → 즉시 반격 가능
3. **복잡하지 않다** — 자세 게이지 등 부가 시스템 없음, 에너지 경제 하나로 통일

### 1.2 전투 구성 요소

```
ATB 전투
├── ATB 게이지 시스템 (실시간 충전)
├── 에너지 시스템 (자동 회복 + 방어 보너스)
├── 카드 시스템 (손패 운영)
├── 리액션 시스템 (패링/회피/방어 → 즉시 에너지)
├── 의도 시스템 (적 행동 예고)
├── 드림 콤보 시스템 (연속 카드 조합)
├── 집중 모드 (시간 슬로우)
└── 오토 플레이 AI (3단계)
```

---

## PART 2. ATB 게이지 시스템

### 2.1 핵심 수치

| 변수 | 값 | 설명 |
|------|-----|------|
| ATB_MAX | 100.0 | ATB 게이지 최대값 |
| ATB_CHARGE_RATE | 1.0 | 초당 충전 배율 |
| ENERGY_MAX | 3 | 에너지 최대값 |
| ENERGY_OVERFLOW_MAX | 5 | 패링 보너스 초과 최대 |
| ENERGY_AUTO_INTERVAL | 5.0초 | 자동 에너지 1 회복 주기 |
| SPEED_DEFAULT | 1.0x | 기본 전투 속도 |
| SPEED_MAX | 2.5x | 최대 전투 속도 |
| SPEED_FOCUS | 0.3x | 집중 모드 속도 |
| SPEED_CRISIS | 0.5x | 위기 개입 속도 |

### 2.2 ATB 게이지 충전

```gdscript
# CombatManagerATB.gd
func _update_atb(delta: float):
    for entity in all_entities:
        if entity.is_alive():
            var charge = (ATB_MAX / entity.spd) * delta * ATB_CHARGE_RATE * speed_multiplier
            entity.atb = min(ATB_MAX, entity.atb + charge)
            if entity.atb >= ATB_MAX:
                _on_entity_atb_full(entity)

func _on_entity_atb_full(entity):
    entity.atb = 0.0
    if entity.is_player:
        _player_atb_action()
    else:
        _enemy_atb_attack(entity)
```

### 2.3 에너지 자동 회복

```gdscript
var energy_timer: float = 0.0
const ENERGY_AUTO_INTERVAL = 5.0

func _update_energy_timer(delta: float):
    energy_timer += delta
    if energy_timer >= ENERGY_AUTO_INTERVAL:
        energy_timer = 0.0
        add_energy(1)

func add_energy(amount: float):
    var prev = current_energy
    current_energy = min(ENERGY_OVERFLOW_MAX, current_energy + amount)
    if current_energy > ENERGY_MAX and prev <= ENERGY_MAX:
        _start_overflow_timer()  # 2초 후 3으로 감소
    EnergyUI.update(current_energy, ENERGY_MAX)
```

---

## PART 3. 리액션 시스템 (방어 → 즉시 에너지)

### 3.1 3단계 방어 체계

| 방어 유형 | 윈도우 | 피해 감소 | 즉시 에너지 | 추가 효과 |
|---------|--------|---------|-----------|---------|
| **패링** | 0.5초 | 100% | **+2** | 카드 드로우 1장, 적 ATB 50% 롤백 |
| **회피** | 1.2초 | 100% | **+1** | 없음 |
| **방어(가드)** | 언제든 | 블록값 | **+0.5** | 블록 자체가 보상 |
| **무반응** | — | 0% | 0 | 풀 피해 |

> **Story 모드**: 패링 0.8초, 회피 1.8초로 자동 확장

### 3.2 에너지 오버플로우

```gdscript
# ATBEnergySystem.gd
const ENERGY_MAX = 3
const ENERGY_OVERFLOW_MAX = 5
const OVERFLOW_DURATION = 2.0

var overflow_timer: float = 0.0

func on_parry_success():
    current_energy = min(ENERGY_OVERFLOW_MAX, current_energy + 2.0)
    if current_energy > ENERGY_MAX:
        overflow_timer = OVERFLOW_DURATION
        EnergyUI.show_overflow_glow(Color.GOLD)
    draw_card(1)                          # 카드 드로우
    enemy.atb = enemy.atb * 0.5          # 적 ATB 롤백

func on_dodge_success():
    add_energy(1.0)

func on_guard_success(block_val: int):
    add_energy(0.5)
    player.block += block_val
```

### 3.3 리액션 윈도우 흐름

```
적 ATB 80% 도달
  → 게이지 황금색 + 의도 아이콘 강조
  → 손패 패링/회피 카드 황금 테두리 + 진동

적 ATB 95% 도달
  → "⚡ 위험!" 텍스트 플래시

적 ATB 100% (공격 실행)
  → 0.5초 패링 윈도우 오픈
  → 0.5~1.2초 회피 윈도우 오픈
  → 방어 카드: 언제든 사용 가능

판정 결과 → 즉시 에너지 충전 → 카드 플레이
```

```gdscript
# ATBReactionManager.gd
func open_reaction_window(attack: AttackData):
    var parry_window = 0.5 if not story_mode else 0.8
    var dodge_window = 1.2 if not story_mode else 1.8

    reaction_state = "OPEN"
    parry_timer = parry_window
    dodge_timer = dodge_window
    HandUI.highlight_reaction_cards(attack.type)

func on_player_tap_card(card: Card):
    if card.has_tag("PARRY") and parry_timer > 0:
        _resolve_parry(card)
    elif card.has_tag("DODGE") and dodge_timer > 0:
        _resolve_dodge(card)
    elif card.has_tag("GUARD"):
        _resolve_guard(card)
```

---

## PART 4. 의도(Intent) 시스템

### 4.1 적 ATB 연동 의도 표시

```gdscript
# ATBIntentSystem.gd
func display_intent(enemy: Enemy):
    var action = enemy.get_next_action()
    IntentUI.show(
        icon  = _type_to_icon(action.type),
        value = action.damage,
        is_heavy    = action.damage > enemy.atk * 1.5,
        is_unblock  = action.type == AttackType.UNBLOCKABLE
    )

func _type_to_icon(t: AttackType) -> String:
    match t:
        AttackType.NORMAL:     return "⚔️"
        AttackType.HEAVY:      return "⚔️⚠️"
        AttackType.AOE:        return "🌀"
        AttackType.UNBLOCKABLE:return "🔱"
        AttackType.BUFF:       return "✨"
        AttackType.DEFEND:     return "🛡️"
    return "❓"
```

### 4.2 공격 유형별 권장 대응

| 아이콘 | 공격 유형 | 패링 가능 | 회피 가능 | 에너지 보상 |
|--------|---------|---------|---------|----------|
| ⚔️ | 일반 | ✅ | ✅ | 최대 +2 |
| ⚔️⚠️ | 강한 공격 | ✅ 권장 | ✅ | 최대 +2 |
| 🔱 | 관통 | ❌ | ✅ 전용 | +1 |
| 🌀 | 광역 | ✅ 어려움 | ✅ | +1 |
| ✨ | 버프 | ❌ | ❌ | 없음 |

---

## PART 5. 드림 콤보 시스템

### 5.1 기본 콤보 목록

| 콤보명 | 조건 | 보너스 | 오토 가능 |
|--------|------|--------|---------|
| 연타 | 공격 카드 3연속 | 마지막 +75% + 슬로모 0.3초 | ✅ |
| 완벽한 방어 | 방어 카드 2연속 | 블록 +10 추가 | ✅ |
| 약점 폭로 | 취약 부여 → 공격 | 데미지 ×1.5 | ✅ |
| 악몽의 폭발 | 중독 2스택 → 공격 | 중독 즉시 폭발 ×3 | 수동 유리 |
| 꿈의 파도 | 광역+단일 조합 3장 | 전체 광역 추가타 | 수동 유리 |
| 패링 반격 | 패링 성공 후 공격 | +30% 보너스 | 수동 전용 |

### 5.2 GDScript

```gdscript
# ComboSystem.gd
const COMBO_WINDOW = 3.0  # 3초 내 조합 인식

var sequence: Array[Card] = []
var timer: float = 0.0

func register_card(card: Card):
    sequence.append(card)
    timer = 0.0
    _check_combos()

func _check_combos():
    # 연타 체크
    var atk_streak = 0
    for c in sequence:
        atk_streak = atk_streak + 1 if c.type == "ATK" else 0
    if atk_streak >= 3:
        _trigger("연타", {"dmg_bonus": 0.75, "slo_mo": 0.3})

    # 패링 반격 체크
    if sequence.size() >= 2:
        var prev = sequence[-2]
        var curr = sequence[-1]
        if prev.has_tag("PARRY") and curr.type == "ATK":
            _trigger("패링 반격", {"dmg_bonus": 0.30})
```

---

## PART 6. 위기 개입 시스템

### 6.1 위기 트리거

| 트리거 | 조건 | 속도 변화 | 지속 |
|--------|------|---------|------|
| HP 위기 | HP < 30% | 0.5x | 10초 |
| 강한 공격 예고 | 예고 데미지 > 현재 HP×0.3 | 0.5x | 10초 |
| 보스 페이즈 전환 | 보스 HP < 70%/40% | 일시 정지 | 3초 |

```gdscript
# CrisisSystem.gd
const CRISIS_DURATION = 10.0
var last_crisis: Dictionary = {}

func check_crisis(state: CombatState):
    var hp_ratio = float(state.player_hp) / state.player_max_hp

    if hp_ratio < 0.30:
        _try_trigger("HP_CRITICAL", 15.0)

    for enemy in state.enemies:
        var incoming = enemy.get_next_damage()
        if incoming > state.player_hp * 0.30:
            _try_trigger("HEAVY_ATTACK", 15.0)

func _try_trigger(crisis_id: String, cooldown: float):
    var now = Time.get_ticks_msec() / 1000.0
    if now - last_crisis.get(crisis_id, 0.0) < cooldown:
        return  # 쿨타임 내 재발 시 생략
    last_crisis[crisis_id] = now
    _activate_crisis(crisis_id)

func _activate_crisis(id: String):
    if not SettingsManager.crisis_slow_enabled:
        return  # 하드코어 옵션: 끄기 가능
    speed_multiplier = 0.5
    CrisisUI.show(id)
    await get_tree().create_timer(CRISIS_DURATION).timeout
    speed_multiplier = 1.0
```

---

## PART 7. 집중 모드 (Focus Mode)

```gdscript
# FocusModeSystem.gd
const DRAIN_RATE = 10.0    # 초당 10% 소모
const REGEN_RATE = 8.0     # 10초당 8% 회복
const MIN_TO_USE = 20.0    # 최소 20% 이상 보유 시 사용 가능

var focus_gauge: float = 100.0
var focus_active: bool = false

func enter_focus():
    if focus_gauge < MIN_TO_USE: return
    focus_active = true
    speed_multiplier = 0.3
    FocusUI.show_active()

func exit_focus():
    focus_active = false
    speed_multiplier = 1.0
    FocusUI.hide()

func _process(delta):
    if focus_active:
        focus_gauge -= DRAIN_RATE * delta
        if focus_gauge <= 0:
            exit_focus()
    else:
        focus_gauge = min(100.0, focus_gauge + REGEN_RATE * delta / 10.0)
    FocusUI.update_gauge(focus_gauge)
```

**UI**: 화면 우측 하단 🌙 전용 버튼 (44px 원형)

---

## PART 8. 오토 플레이 AI

### 8.1 3단계 오토 모드

| 모드 | 설명 | 패링 성공률 |
|------|------|----------|
| 풀 오토 | 모든 행동 자동 | 65% |
| 세미 오토 | AI 추천 → 플레이어 탭 확인 | 수동 결정 |
| 수동 | 모두 플레이어 직접 | 100% (숙련도 의존) |

```gdscript
# ATBAutoAI.gd
func decide_action(hand: Array[Card], state: CombatState) -> String:
    # 에너지 부족 시 패링 최우선 (에너지 회복 목적)
    if state.energy < 1 and hand.has_parry_card():
        return "PARRY"
    # 강한 공격 예고 시 패링 시도
    if state.enemy_next_heavy and hand.has_parry_card():
        return "PARRY" if randf() < 0.70 else "GUARD"
    # 일반 상황: 회피 선호
    if hand.has_dodge_card():
        return "DODGE"
    # 패링 카드 있으면 65% 확률로 패링
    if hand.has_parry_card() and randf() < 0.65:
        return "PARRY"
    return "GUARD"

func select_attack_card(hand: Array[Card], energy: int) -> Array[Card]:
    var selected = []
    var remaining = energy
    # 데미지 효율 순으로 정렬
    var attacks = hand.filter(func(c): return c.type == "ATK" and c.cost <= remaining)
    attacks.sort_custom(func(a,b): return a.damage_per_energy() > b.damage_per_energy())
    for card in attacks:
        if remaining >= card.cost:
            selected.append(card)
            remaining -= card.cost
    return selected
```

---

## PART 9. 꿈 보조자 루미 (Dream Familiar)

```gdscript
# DreamFamiliar.gd
var suggestion_cooldown = 8.0
var cooldown_timer = 0.0

func suggest(state: CombatState, hand: Array[Card]) -> String:
    if cooldown_timer > 0: return ""

    # HP 위기
    if float(state.player_hp) / state.player_max_hp < 0.40:
        var def_card = hand.find_card_by_type("DEF")
        if def_card: return "지금 방어 카드 어때요? 🛡️"

    # 패링 기회
    if state.enemy_atb > 0.75 and hand.has_parry_card():
        return "적이 곧 공격해요! 패링 카드를 준비하세요! ⚡"

    # 콤보 기회
    if ComboSystem.is_one_away_from_combo(hand):
        return "이 카드로 콤보 완성이에요! ✨"

    cooldown_timer = suggestion_cooldown
    return ""
```

---

## PART 10. 전투 일지 & 보스 약점

### 10.1 전투 일지 (Battle Diary)

전투 종료 후 통계 표시:
- 전투 시간, 패링 성공 횟수, 최대 콤보, 에너지 효율
- 맞춤 팁 (플레이 패턴 기반)

### 10.2 보스 약점 발견

같은 카드 유형 3연속 → 약점 노출 → 해당 유형 데미지 +25%

---

## PART 11. 핵심 수치 최종 정리

| 항목 | 수치 |
|------|------|
| 기본 에너지 | 3 |
| 에너지 오버플로우 최대 | 5 (2초 유지) |
| 자동 에너지 회복 | 1 / 5초 |
| 패링 에너지 보너스 | +2 즉시 |
| 패링 드로우 | +1장 |
| 패링 윈도우 | 0.5초 (Story: 0.8초) |
| 회피 에너지 보너스 | +1 즉시 |
| 회피 윈도우 | 1.2초 (Story: 1.8초) |
| 방어 에너지 보너스 | +0.5 즉시 |
| 적 ATB 롤백 (패링) | 50% |
| 최대 전투 속도 | 2.5x |
| 집중 모드 속도 | 0.3x |
| 집중 소모 | 10%/초 |
| 집중 회복 | 8%/10초 |
| 위기 속도 | 0.5x |
| 위기 지속 | 10초 |
| 위기 쿨타임 | 15초 |
| 콤보 연타 보너스 | +75% |
| 오토 패링 성공률 | 65% |

---

## PART 12. GDScript 파일 구조

```
res://scripts/combat/atb/
├── CombatManagerATB.gd          # 핵심 ATB 엔진
├── ATBEnergySystem.gd           # 에너지 관리 (자동 + 보너스)
├── ATBReactionManager.gd        # 리액션 윈도우 총괄
│   ├── ParrySystem_ATB.gd       # 패링 처리
│   ├── DodgeSystem_ATB.gd       # 회피 처리
│   └── GuardSystem_ATB.gd       # 방어 처리
├── ATBIntentSystem.gd           # 의도 표시
├── ComboSystem.gd               # 드림 콤보
├── CrisisSystem.gd              # 위기 개입
├── FocusModeSystem.gd           # 집중 모드
├── ATBAutoAI.gd                 # 오토 플레이 AI
├── DreamFamiliar.gd             # 꿈 보조자 루미
├── BattleDiary.gd               # 전투 일지
└── BossWeaknessSystem.gd        # 보스 약점
```

---

## PART 13. 구현 우선순위

### Phase A (핵심 — 즉시)
1. CombatManagerATB.gd (ATB 게이지 루프)
2. ATBEnergySystem.gd (자동 + 패링 보너스)
3. ATBReactionManager.gd (리액션 윈도우)
4. ATBIntentSystem.gd (의도 표시)
5. 기본 카드 20장

### Phase B (완성도)
6. ComboSystem.gd (콤보 5종)
7. CrisisSystem.gd (위기 개입)
8. FocusModeSystem.gd
9. ATBAutoAI.gd (오토 플레이)

### Phase C (폴리싱)
10. DreamFamiliar.gd
11. BattleDiary.gd
12. BossWeaknessSystem.gd

---

**작성**: Kim.G (게임팀장) | **날짜**: 2026-03-01 | **상태**: ✅ 개발 이관 완료
