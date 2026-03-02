# 🔧 DEV SPEC — 리액션 시스템 (색상 구간 방식)

**버전**: v1.0
**작성일**: 2026-03
**상태**: ✅ 구현 완료 (DEV_UPDATE_REACTION_UI_202503.md 기반)
**적용 범위**: ATB + 턴베이스 공통
**기획 참조**: COMBAT_SYSTEM_MASTER_SPEC.md → 4. 리액션 시스템

> 이 문서는 색상 구간 기반 리액션 시스템의 **구현 상세 스펙**이다.
> DEV_SPEC_ATB.md / DEV_SPEC_TURNBASED.md의 리액션 관련 내용은 이 문서로 대체한다.

---

## 1. 시스템 구조

```
ATBReactionManager.gd         (ATB 전투 리액션 판정)
TurnBasedReactionManager.gd   (턴베이스 전투 리액션 판정)
CombatManagerATB.gd           (피해 계산 + 패널티 적용 + 로그)
CombatManagerTB.gd            (동일)
CombatBottomUI.gd             (리액션 버튼 UI + 우선순위 + 연속 시도)
CharacterNode.gd              (! 아이콘 색상 전환 + 플로팅 텍스트)
InRun_v4.gd                   (시그널 연결 + 큐 UI + 전체 갱신)
```

---

## 2. 색상 구간 타이밍 (ReactionManager 공통)

### 2.1 구간 정의

```gdscript
# ATBReactionManager.gd / TurnBasedReactionManager.gd

# Story 모드
const GREEN_DURATION_STORY  : float = 1.0   # 가드만 가능
const YELLOW_DURATION_STORY : float = 1.0   # 회피 + 가드
const RED_DURATION_STORY    : float = 0.4   # 패링 + 회피 + 가드

# Hard 모드
const GREEN_DURATION_HARD   : float = 0.65
const YELLOW_DURATION_HARD  : float = 0.70
const RED_DURATION_HARD     : float = 0.25

enum Phase { GREEN, YELLOW, RED }
```

### 2.2 구간 판별 함수

```gdscript
func _get_phase(elapsed: float) -> Phase:
    var green  = GREEN_DURATION_STORY if story_mode else GREEN_DURATION_HARD
    var yellow = YELLOW_DURATION_STORY if story_mode else YELLOW_DURATION_HARD
    if elapsed < green:
        return Phase.GREEN
    elif elapsed < green + yellow:
        return Phase.YELLOW
    else:
        return Phase.RED
```

---

## 3. 리액션 판정 로직

### 3.1 판정 규칙

| 시도 | 현재 구간 | 결과 |
|------|----------|------|
| PARRY | RED | ✅ 패링 성공 |
| PARRY | GREEN / YELLOW | ❌ 패링 실패 (윈도우 유지) |
| PARRY | UNBLOCKABLE 공격 | ❌ 패링 실패 (어떤 구간이든) |
| DODGE | YELLOW / RED | ✅ 회피 성공 |
| DODGE | GREEN | ❌ 회피 실패 |
| GUARD | GREEN / YELLOW / RED | ✅ 가드 성공 |

### 3.2 결과 적용 (CombatManagerATB.gd / CombatManagerTB.gd)

```gdscript
# _apply_attack_result(result: String, base_damage: int, enemy: EnemyEntity):

match result:
    "PARRY":
        # 피해 0 + 적 ATB 완전 초기화
        enemy.atb = -ATB_MAX
        battle_log("패링 성공! (%s)" % enemy.display_name)
        emit_signal("reaction_feedback", "패링 성공!", "PARRY_SUCCESS", enemy_idx)

    "PARRY_FAIL":
        # 피해 1.5배 + 적 ATB 0.5배 빠름
        var dmg = int(base_damage * 1.5)
        apply_damage_to_player(dmg)
        enemy.atb = ATB_MAX * 0.5
        battle_log("패링 실패! (%s) 피해 %d (+50%%) / 적 ATB 빨라짐" % [enemy.display_name, dmg])
        emit_signal("reaction_feedback", "패링 실패!", "PARRY_FAIL", enemy_idx)

    "DODGE":
        # 피해 0
        battle_log("회피 성공! (%s)" % enemy.display_name)
        emit_signal("reaction_feedback", "회피 성공!", "DODGE_SUCCESS", enemy_idx)

    "DODGE_FAIL":
        # 피해 1.2배
        var dmg = int(base_damage * 1.2)
        apply_damage_to_player(dmg)
        battle_log("회피 실패! (%s) 피해 %d (+20%%)" % [enemy.display_name, dmg])
        emit_signal("reaction_feedback", "회피 실패!", "DODGE_FAIL", enemy_idx)

    "GUARD":
        # 블록만큼 경감 후 나머지 HP 적용
        var remaining = max(0, base_damage - current_block)
        if remaining > 0:
            apply_damage_to_player(remaining)
        battle_log("가드! (%s) 피해 %d" % [enemy.display_name, remaining])
        emit_signal("reaction_feedback", "가드", "GUARD", enemy_idx)
        emit_signal("damage_dealt", remaining, player_entity)

    "NONE":
        # 기본 피해 (실패 시도 기록 있으면 해당 페널티 적용)
        apply_damage_to_player(base_damage)
```

---

## 4. 리액션 버튼 (CombatBottomUI.gd)

### 4.1 버튼 활성화 조건

- `reaction_window_opened` 시그널 수신 → `_reaction_window_active = true`
- `reaction_window_closed` 시그널 수신 → `_reaction_window_active = false`
- 버튼은 **리액션 윈도우 활성 중에만** 탭 가능

### 4.2 카드 우선순위

```gdscript
# 손패에서 리액션 카드 선택 (우선순위: PARRY > DODGE > GUARD)
func _find_best_reaction_card(hand: Array[Card]) -> Card:
    for priority_tag in ["PARRY", "DODGE", "GUARD"]:
        for card in hand:
            if priority_tag in card.tags and priority_tag not in _excluded_reaction_types:
                return card
    return null
```

### 4.3 연속 시도 로직

```gdscript
var _excluded_reaction_types: Array[String] = []

func _on_reaction_attempt_failed(attempted_type: String) -> void:
    _excluded_reaction_types.append(attempted_type)
    _update_reaction_button()   # 다음 우선순위 카드로 버튼 갱신

func _on_reaction_window_closed(_result) -> void:
    _excluded_reaction_types.clear()
    _update_reaction_button()
```

### 4.4 턴베이스 에너지 무소모

```gdscript
func _on_reaction_button_pressed() -> void:
    var card = _find_best_reaction_card(hand)
    if card == null:
        return
    # TB 리액션 윈도우 중에는 에너지 체크 생략
    if not (combat_manager is CombatManagerTB and _reaction_window_active):
        if current_energy < card.cost:
            return
    emit_signal("reaction_card_played", card)
```

---

## 5. "!" 아이콘 색상 전환 (CharacterNode.gd / InRun_v4.gd)

### 5.1 ! 아이콘 규칙

- 리액션 윈도우 시작 시 **한 번 나타나고 사라지지 않음**
- 구간 변경 시 색상만 변경 (`alert_label.modulate = color`)
- `_reaction_alert_enemy_idx` 로 현재 리액션 중인 적을 추적 → 해당 적의 `set_alert_state(false)` 호출 차단

### 5.2 구간별 색상

```gdscript
# CharacterNode.gd
func set_alert_phase(phase: int, is_unblockable: bool) -> void:
    match phase:
        0:  # GREEN
            alert_label.modulate = Color.GREEN
        1:  # YELLOW
            alert_label.modulate = Color.YELLOW
        2:  # RED
            alert_label.modulate = Color.RED
    alert_label.text = "!!" if is_unblockable else "!"
```

### 5.3 InRun_v4 시그널 연결

```gdscript
# reaction_phase_changed 시그널로 색상 갱신
func _on_reaction_phase_changed(phase: int, is_unblockable: bool) -> void:
    if _reaction_alert_enemy_idx >= 0:
        character_nodes[_reaction_alert_enemy_idx].set_alert_phase(phase, is_unblockable)

# reaction_window_opened 시그널로 인덱스 저장
func _on_reaction_window_opened(attack: AttackData) -> void:
    _reaction_alert_enemy_idx = _find_enemy_node_index(attack.attacker)
    if _reaction_alert_enemy_idx >= 0:
        character_nodes[_reaction_alert_enemy_idx].set_alert_state(true)

# reaction_window_closed 시그널로 인덱스 초기화 + ! 제거
func _on_reaction_window_closed(_result) -> void:
    if _reaction_alert_enemy_idx >= 0:
        character_nodes[_reaction_alert_enemy_idx].set_alert_state(false)
    _reaction_alert_enemy_idx = -1
```

---

## 6. 플로팅 텍스트 (DamageNumber.gd / CharacterNode.gd)

### 6.1 텍스트 타입별 색상

| 결과 | 텍스트 | 색상 |
|------|--------|------|
| 패링 성공 | 패링 성공! | 골드 (#FFD700) |
| 회피 성공 | 회피 성공! | 하늘색 (#87CEEB) |
| 가드 | 가드 | 흰색 |
| 패링 실패 | 패링 실패! | 빨강 (#FF4444) |
| 회피 실패 | 회피 실패! | 주황 (#FF8C00) |

### 6.2 구현

```gdscript
# DamageNumber.gd
func show_text(message: String, color: Color, font_size: int = 18) -> void:
    label.text = message
    label.modulate = color
    # Tween: 위로 이동 + 페이드아웃

# CharacterNode.gd
func show_floating_text(message: String, color: Color, font_size: int = 18) -> void:
    var dn = DamageNumber.instantiate()
    add_child(dn)
    dn.show_text(message, color, font_size)

# InRun_v4.gd — reaction_feedback 연결
func _on_new_reaction_feedback(text: String, result_type: String, enemy_idx: int) -> void:
    var color = _get_reaction_color(result_type)
    hero_node.show_floating_text(text, color)
```

---

## 7. 턴베이스 손패 유지 (CombatManagerTB.gd)

### 7.1 변경 사항

**기존**: `player_end_turn()` → `hand_system.discard_remaining()` 호출 → 보스 공격 턴에 손패 없음
**변경**: `_start_enemy_turns()` 루프 종료 후 `hand_system.discard_remaining()` 한 번만 호출

```gdscript
func player_end_turn() -> void:
    # discard_remaining() 제거
    _change_state(State.ENEMY_TURN)
    _start_enemy_turns()

func _start_enemy_turns() -> void:
    for enemy in active_enemies:
        if not enemy.is_alive():
            continue
        await _execute_enemy_action(enemy)
    # 모든 적 행동 종료 후 버림
    hand_system.discard_remaining()
    _change_state(State.PLAYER_TURN)
    _start_player_turn()
```

### 7.2 주의사항

다중 적(Multiple Enemies) 상황에서 첫 번째 적 리액션에서 사용한 카드가 두 번째 적 리액션에서도 남아있다. **의도된 동작** (플레이어 턴 종료 시점 손패 기준으로 보스 공격 전체 대응 가능).

---

## 8. 시그널 API 요약

| 시그널 | 소스 | 수신처 | 용도 |
|--------|------|--------|------|
| `reaction_window_opened(attack)` | ATBReactionManager / TurnBasedReactionManager | CombatBottomUI, InRun_v4 | 리액션 윈도우 시작 |
| `reaction_window_closed(result_type)` | 동일 | CombatBottomUI, InRun_v4 | 리액션 윈도우 종료 |
| `reaction_phase_changed(phase, is_unblockable)` | 동일 | InRun_v4 | ! 아이콘 색상 전환 |
| `reaction_attempt_failed(attempted_type)` | ATBReactionManager / TurnBasedReactionManager | CombatBottomUI | 연속 시도 — 해당 타입 제외 |
| `reaction_feedback(text, result_type, enemy_idx)` | CombatManagerATB / CombatManagerTB | InRun_v4 | 플로팅 텍스트 표시 |
| `battle_log_updated(message)` | CombatManagerATB / CombatManagerTB | 전투 로그 UI | 로그 메시지 (몬스터명 포함) |

---

## 9. 테스트 포인트

### 필수 테스트

- [ ] 녹색 구간에서 패링 → 실패 처리 → 버튼이 회피로 갱신되는가
- [ ] 노란색 구간에서 회피 → 성공하는가
- [ ] 빨간색 구간에서 패링 → 성공 + enemy.atb = -ATB_MAX 적용되는가
- [ ] 패링 실패 후 같은 윈도우에서 가드 → 성공하는가
- [ ] UNBLOCKABLE 공격에서 패링 → 실패 후 회피 버튼으로 전환되는가
- [ ] 손패에 리액션 카드 없을 때 버튼 상태 (비활성 or GUARD 기본 표시 확인)
- [ ] 시간 초과 → NONE 처리, 기본 피해 적용, 별도 패널티 없음

### ATB 전용

- [ ] 패링 성공 시 해당 몬스터만 느려지고 다른 몬스터 ATB는 영향 없는가
- [ ] 패링 실패 시 +50% 피해 + 해당 몬스터 다음 행동 빨라지는가

### 턴베이스 전용

- [ ] 에너지 0 상태에서 보스 공격 중 패링 → 에너지 소모 없이 발동되는가
- [ ] 플레이어 턴 종료 → 보스 공격 중 → 손패 유지되는가
- [ ] 보스 공격 모두 종료 후 손패 버려지는가
- [ ] 다중 적 상황에서 첫 번째 적 리액션 후 두 번째 적 리액션에서도 카드 사용 가능한가

---

## 10. 관련 파일 목록

| 파일 | 경로 | 역할 |
|------|------|------|
| ATBReactionManager.gd | scripts/combat/atb/ | ATB 리액션 판정 |
| TurnBasedReactionManager.gd | scripts/combat/turnbased/ | TB 리액션 판정 |
| CombatManagerATB.gd | scripts/combat/atb/ | ATB 피해 계산 + 로그 |
| CombatManagerTB.gd | scripts/combat/turnbased/ | TB 피해 계산 + 로그 |
| CombatBottomUI.gd | ui/bottom_uis/ | 리액션 버튼 UI |
| CharacterNode.gd | ui/components/ | ! 색상 + 플로팅 텍스트 |
| InRun_v4.gd | ui/screens/ | 전체 시그널 연결 |
| DamageNumber.gd | ui/components/ | 플로팅 숫자/텍스트 |
