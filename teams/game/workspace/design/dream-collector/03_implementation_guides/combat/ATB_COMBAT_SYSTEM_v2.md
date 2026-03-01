# ⚡ ATB 전투 시스템 v2.0 — 강화 설계서
# "꿈의 격류 (Dream Torrent)"

**작성일**: 2026-03-01
**작성자**: 게임팀 (Claude Cowork)
**상태**: 🔴 설계 확정 → OPS 테스트 대기
**이전 버전**: ATB_Implementation_Guide.md (v1.0)

---

## 📌 핵심 문제 인식

현재 ATB v1.0의 치명적 약점:

> **"오토 전투는 보는 게임이다"** — 카드를 에너지 생기는 대로 AI가 자동으로 쓰면, 플레이어의 선택과 긴장감이 사라진다.

| v1.0 문제점 | 영향 | 심각도 |
|-----------|------|--------|
| AI가 모든 카드를 기계적으로 처리 | 플레이어 주도권 없음 | 🔴 치명적 |
| 카드 간 시너지/콤보 인식 없음 | 전략 깊이 부재 | 🔴 치명적 |
| 위험 순간에도 자동 진행 | 긴장감 제로 | 🟠 심각 |
| 에너지 충전 타이밍 선택지 없음 | 재미 요소 부족 | 🟠 심각 |
| 속도만 다를 뿐 매전투 동일한 패턴 | 리플레이성 저하 | 🟡 보통 |

**v2.0 목표**: 오토 편의성은 유지하되, 선택의 무게와 전술적 긴장감을 삽입한다.

---

## 🎯 v2.0 핵심 철학: "능동적 오토 (Active Auto)"

```
기존: 오토 = 수동의 열등한 대체재
v2.0: 오토 = 편의성 레이어 / 수동 = 전략 레이어
      플레이어는 두 레이어 사이를 자유롭게 오간다
```

**핵심 신규 시스템 5가지**:
1. 🔴 **위기 개입 시스템 (Crisis Interrupt)** — 위험 상황에서 자동 일시정지
2. 🟡 **전술 개입 (Tactical Override)** — 플레이어가 AI의 다음 카드를 선택
3. 🔵 **드림 콤보 (Dream Combo)** — 연속 카드 사용 시 폭발적 보너스
4. 🟣 **리액션 카드 (Reaction Card)** — 특정 트리거에 즉시 발동하는 새 카드 유형
5. ⚪ **집중 모드 (Focus Mode)** — 시간을 느리게 해서 전략적 선택

---

## 1. 위기 개입 시스템 (Crisis Interrupt)

### 1.1 개념

오토 전투 중, 특정 임계 상황 발생 시 **전투가 자동으로 0.5배속으로 전환되고 경고 UI**가 떠서 플레이어의 개입을 유도한다.

### 1.2 위기 트리거 조건

| 트리거 ID | 조건 | 개입 유형 |
|---------|------|--------|
| CRISIS-01 | 플레이어 HP 30% 이하 | 전속 일시정지 + 방어 카드 추천 |
| CRISIS-02 | 적이 "강력한 공격" 예고 (다음 턴 데미지 2배 이상) | 일시정지 + 방어 선택 요청 |
| CRISIS-03 | 보스 등장 | 완전 일시정지 + "보스 정보" 팝업 |
| CRISIS-04 | 저주 카드가 손패에 포함 | 경고 UI + 버릴지 쓸지 선택 |
| CRISIS-05 | 콤보 기회 감지 (특정 카드 3장 이상 동시 보유) | 느린 모드 + 콤보 하이라이트 |
| CRISIS-06 | 에너지 3개 + 손패 풀 (최고 효율 순간) | 짧은 하이라이트 UI |

### 1.3 위기 개입 UI

```
┌─────────────────────────────────┐
│  ⚠️ 위기! HP 28% — 공격 예고됨  │
│                                 │
│  [🛡 방어 카드 사용]  [무시하기]  │
│  [⏸ 잠깐 생각하기]               │
└─────────────────────────────────┘
```

**"방어 카드 사용"** 클릭 시: AI가 최고 방어값 카드를 즉시 사용
**"무시하기"**: 오토 전투 재개
**"잠깐 생각하기"**: 전술 개입 모드 진입

### 1.4 GDScript 구조

```gdscript
# CombatManagerATB_v2.gd

var crisis_check_enabled: bool = true
var crisis_threshold_hp: float = 0.30      # 30% HP
var crisis_threshold_boss_damage: int = 25  # 25 이상 예고 공격

signal crisis_triggered(crisis_type: String, context: Dictionary)

func _check_crisis_conditions():
    if not crisis_check_enabled:
        return

    var hp_ratio = float(hero.hp) / float(hero.max_hp)

    # HP 위기
    if hp_ratio <= crisis_threshold_hp and not crisis_active:
        _trigger_crisis("HP_CRITICAL", {
            "hp": hero.hp,
            "max_hp": hero.max_hp,
            "ratio": hp_ratio
        })
        return

    # 강한 공격 예고
    for monster in monsters:
        if monster.hp > 0 and monster.get("next_action_damage", 0) >= crisis_threshold_boss_damage:
            _trigger_crisis("BIG_ATTACK_INCOMING", {
                "monster": monster.name,
                "damage": monster.next_action_damage
            })
            return

    # 콤보 기회
    if _detect_combo_opportunity():
        _trigger_crisis("COMBO_OPPORTUNITY", {
            "combo_cards": _get_combo_cards()
        })

func _trigger_crisis(crisis_type: String, context: Dictionary):
    crisis_active = true
    speed_multiplier = 0.5  # 슬로우
    crisis_triggered.emit(crisis_type, context)

    # 플레이어가 선택하면 자동으로 해제
    await get_tree().create_timer(8.0).timeout
    _resolve_crisis_auto()  # 8초 무응답 시 자동 무시
```

---

## 2. 전술 개입 시스템 (Tactical Override)

### 2.1 개념

오토 전투 중 언제든지 플레이어가 **"다음에 낼 카드"를 직접 선택**할 수 있다. AI의 선택 큐(Queue)가 반투명하게 표시되고, 플레이어가 이를 변경할 수 있다.

### 2.2 AI 큐 UI

```
오토 AI의 다음 3장 예정:
┌──────────┬──────────┬──────────┐
│ [공격-2] │ [공격-1] │ [방어-3] │
│  ★지금   │  예정1   │  예정2   │  ← 탭해서 순서 변경
└──────────┴──────────┴──────────┘
```

**동작 방식**:
- 카드를 탭 → 즉시 그 카드를 사용 (AI 큐 무시)
- 드래그 앤 드롭 → 큐 순서 재배열
- 외부 클릭 → 오토 유지

### 2.3 "세미 오토" 모드

기존 Auto ON/OFF에 추가:

```
[ 🤖 풀오토 ] → [ 🎮 세미오토 ] → [ ✋ 수동 ]

풀오토: AI가 모든 카드를 자동 선택+사용
세미오토: AI가 선택한 카드를 플레이어가 최종 확인 후 사용
         (에너지 충전 시 자동 드로우, 카드 사용은 탭 필요)
수동:   기존 수동 플레이
```

**세미오토의 핵심 재미**: AI가 추천하는 카드를 보면서 "아 이게 낫겠다" 하며 바꾸는 경험.

---

## 3. 드림 콤보 시스템 (Dream Combo)

### 3.1 개념

같은 턴 내 특정 카드 조합을 연속으로 사용하면 **콤보 보너스** 발생. 이 시스템은 오토 AI도 인식하지만, **수동 플레이어가 훨씬 잘 트리거**할 수 있도록 설계.

### 3.2 기본 콤보 목록 (초기 15종)

| 콤보 이름 | 구성 카드 | 보너스 효과 | 발동 레이어 |
|----------|---------|-----------|-----------|
| **연타 (Rapid Strike)** | 공격 카드 3장 연속 | 마지막 공격 +50% 데미지 | 오토 가능 |
| **완벽한 방어 (Iron Wall)** | 방어 카드 2장 연속 | 방어도 +10 추가 | 오토 가능 |
| **약점 폭로 (Expose)** | 취약 부여 → 공격 카드 | 데미지 x1.5 (취약 효과 누적) | 오토 가능 |
| **악몽의 폭발 (Nightmare Burst)** | 악몽 중독 부여 3스택 → 공격 | 중독 스택 즉시 폭발 (3배 피해) | 수동 필수 |
| **영혼의 방패 (Soul Barrier)** | 방어도 0일 때 방어 카드 2장 | 방어도 2배로 얻음 | 수동 유리 |
| **꿈의 파도 (Dream Wave)** | 광역 공격 → 단일 공격 → 광역 | 단일 공격이 전체에 스플래시 | 수동 필수 |
| **차가운 이성 (Cold Logic)** | 버프 → 공격 → 버프 | 두 번째 버프 효과 2배 | 오토 인식 |
| **카드 폭주 (Card Blitz)** | 한 턴에 카드 5장 사용 | 다음 에너지 충전 즉시 | 수동 유리 |
| **최후의 저항 (Last Stand)** | HP 20% 이하에서 방어 카드 | 방어도 + 즉시 HP 회복 10% | 위기개입 |
| **기억의 반향 (Memory Echo)** | 이미 사용한 카드와 동일 카드 재사용 | 효과 1.3배 | 오토 가능 |

### 3.3 콤보 감지 UI

```
┌────────────────────────────────┐
│  ✨ COMBO! "연타" 발동!         │
│  마지막 공격 +50%!  → 데미지 9  │
└────────────────────────────────┘

(0.8초 후 자동 사라짐)
```

### 3.4 GDScript 구조

```gdscript
# ComboSystem.gd (new autoload)
extends Node

var combo_window: float = 3.0       # 3초 내 카드 조합 인식
var current_combo_sequence: Array = []  # 현재 사용된 카드 시퀀스
var combo_timer: float = 0.0

signal combo_triggered(combo_name: String, bonus: Dictionary)

func register_card_played(card: Dictionary):
    current_combo_sequence.append(card)
    combo_timer = 0.0
    _check_all_combos()

func _process(delta):
    if combo_timer > combo_window:
        current_combo_sequence.clear()
        combo_timer = 0.0
    elif not current_combo_sequence.is_empty():
        combo_timer += delta

func _check_all_combos():
    # 연타 체크
    if _is_combo_rapid_strike():
        _trigger_combo("연타 (Rapid Strike)", {
            "damage_bonus": 0.5,
            "target": "last_attack"
        })

    # 악몽의 폭발 체크
    if _is_combo_nightmare_burst():
        _trigger_combo("악몽의 폭발 (Nightmare Burst)", {
            "nightmare_multiplier": 3.0
        })

func _is_combo_rapid_strike() -> bool:
    var attack_count = 0
    for card in current_combo_sequence:
        if card.get("type") == "Attack":
            attack_count += 1
        else:
            attack_count = 0
        if attack_count >= 3:
            return true
    return false
```

---

## 4. 리액션 카드 시스템 (Reaction Cards)

### 4.1 개념

기존 카드는 플레이어 턴에만 사용 가능. **리액션 카드**는 특정 조건이 트리거되면 **적의 턴 도중에도** 즉시 발동할 수 있는 새로운 카드 유형.

이 시스템이 ATB 전투에 가장 강력한 긴장감을 부여한다 — "적이 공격하려는 순간, 내가 반응해야 한다".

### 4.2 리액션 카드 목록 (초기 10종)

| 카드 이름 | 트리거 | 효과 | 에너지 |
|---------|--------|------|--------|
| **꿈의 방패 (Dream Guard)** | 적이 공격 직전 | 방어도 +8 | 1 |
| **역반사 (Refraction)** | 피해 받을 때 | 받은 피해의 30%를 반사 | 1 |
| **기억의 실 (Memory Thread)** | 손패에 카드 없을 때 | 즉시 카드 2장 드로우 | 0 |
| **잠깐! (Hold On!)** | 적 ATB 80% 이상 | 적의 ATB를 50%로 되돌림 | 2 |
| **꿈의 도약 (Dream Leap)** | 피해를 받는 순간 | 피해 무효 + 1회 | 2 |
| **악몽 흡수 (Nightmare Drink)** | 중독/저주 상태 시 | 디버프를 공격력으로 변환 | 1 |
| **기억의 반향 즉발 (Echo Shot)** | 적이 버프 사용 직후 | 버프 제거 + 버프값만큼 공격 | 1 |
| **시간의 흐름 (Time Flow)** | 에너지 만충 시 | 에너지 1 추가, 즉시 발동 | 0 |

### 4.3 리액션 카드 UI

```
적 [꿈의 악몽] ATB 82% — 공격 예고!

손패: [공격-1] [방어-2] ★[꿈의 방패 — 반응!]

          ↑ 강조 표시 + 0.5초 선택 윈도우
```

**반응 윈도우**: 0.8~1.5초 (난이도에 따라 조정). 이 시간 안에 반응 카드를 탭하면 발동.

---

## 5. 집중 모드 (Focus Mode)

### 5.1 개념

ATB 전투 도중 언제든지 **"집중" 버튼**을 누르면 전투가 0.3배속으로 전환되며, 에너지 아이콘 주변에 "집중 게이지"가 표시된다.

집중 모드에서는 모든 카드가 천천히 움직이며 선택하기 쉬워진다. **단, 집중 게이지가 소모**된다.

### 5.2 집중 게이지

```
⚡⚡⚡  [집중 █████████░░] 90%
         집중 모드 사용 가능
```

- 최대 100% → 집중 모드 5초 유지 가능
- 전투 시작 시 100%
- 집중 모드 사용 중 초당 20% 감소
- 10초마다 5% 자연 회복
- **보스전에서만**: 적 처치 시 30% 충전 보너스

### 5.3 모바일 적용

```
[집중 버튼] = 두 손가락 화면 꾹 누르기 (0.5초)
해제 = 손가락 떼기
```

---

## 6. 몬스터 "의도 (Intent)" 시스템

ATB에서도 StS 식의 **적 다음 행동 예고**를 도입. 단, ATB이므로 "이번 ATB 턴에 할 행동"을 미리 표시.

### 6.1 의도 아이콘

| 아이콘 | 의미 | 대응 |
|--------|------|------|
| ⚔️ (숫자) | 공격 예정 + 예상 데미지 | 방어 카드 준비 |
| 🛡️ | 방어 강화 예정 | 디버프 카드 선제 사용 |
| ✨ | 버프 예정 | 버프 제거 카드 준비 |
| ☠️ | 강화 공격 예정 (치명적) | 위기 개입 트리거 |
| ❓ | 불명 (보스 특수) | 위기 모드 |

### 6.2 GDScript 구조

```gdscript
# MonsterIntent.gd
extends Node

enum IntentType {
    ATTACK,
    DEFEND,
    BUFF,
    CRITICAL_ATTACK,
    UNKNOWN
}

func determine_intent(monster: Dictionary) -> Dictionary:
    var intent = {}

    # 다음 ATB 턴에 할 행동 결정
    var next_action = monster.get("ai_pattern", [])
    var action_index = monster.get("action_index", 0)

    if next_action.is_empty():
        intent = {"type": IntentType.ATTACK, "damage": monster.atk}
    else:
        var current_action = next_action[action_index % next_action.size()]
        intent = _parse_action(current_action, monster)

    return intent

func _parse_action(action: Dictionary, monster: Dictionary) -> Dictionary:
    match action.type:
        "attack":
            return {
                "type": IntentType.ATTACK,
                "damage": monster.atk + action.get("bonus_damage", 0),
                "icon": "⚔️"
            }
        "defend":
            return {
                "type": IntentType.DEFEND,
                "block": action.get("block", 5),
                "icon": "🛡️"
            }
        "buff":
            return {
                "type": IntentType.BUFF,
                "stat": action.stat,
                "value": action.value,
                "icon": "✨"
            }
        "big_attack":
            return {
                "type": IntentType.CRITICAL_ATTACK,
                "damage": monster.atk * 2,
                "icon": "☠️"
            }
    return {"type": IntentType.UNKNOWN, "icon": "❓"}
```

---

## 7. 완성된 ATB v2.0 전투 흐름

```
전투 시작
    ↓
[몬스터 의도 표시] ← 모든 적의 다음 행동 아이콘 표시
    ↓
[ATB 실시간 진행]
    ├── 오토 모드: AI가 카드 플레이 → 콤보 자동 감지
    ├── 세미오토: AI 추천 카드 플레이어 확인 후 탭
    └── 수동: 플레이어가 직접 카드 드래그
    ↓
[리액션 윈도우] ← 적 ATB 80% 이상 시 반응 카드 기회
    ↓
[위기 개입] ← HP 30% 이하 또는 강한 공격 예고 시 자동 슬로우
    ↓
[콤보 체크] ← 카드 사용 시마다 콤보 시퀀스 확인
    ↓
[전투 종료] → 보상
```

---

## 8. 밸런싱 수치 (초기값)

### 에너지 시스템 변경

| 항목 | v1.0 | v2.0 |
|------|------|------|
| 에너지 최대 | 3 | 3 (기본) / 4 (집중 모드) |
| 에너지 충전 시간 | 5초 (손패 크기 비례) | 4초 기본 / 위기 시 3초 |
| 에너지 회복 시 | 카드 드로우 | 카드 드로우 + 콤보 게이지 소량 충전 |

### 속도 밸런싱

| 모드 | 배속 |
|------|------|
| 일반 (기본) | 1× |
| 빠름 | 2× |
| 매우 빠름 | 3× |
| 위기 개입 | 0.5× |
| 집중 모드 | 0.3× |
| 리액션 윈도우 | 0.4× |

---

## 9. Phase 구현 우선순위

| 우선순위 | 시스템 | 예상 시간 | 난이도 |
|---------|--------|---------|--------|
| 🔴 P0 | 몬스터 의도 시스템 | 1일 | 중 |
| 🔴 P0 | 위기 개입 (HP 30%) | 1일 | 낮음 |
| 🔴 P0 | 세미오토 모드 | 2일 | 중 |
| 🟠 P1 | 드림 콤보 (5종) | 2일 | 높음 |
| 🟠 P1 | 집중 모드 | 1일 | 중 |
| 🟡 P2 | 리액션 카드 (5종) | 3일 | 높음 |
| 🟡 P2 | 강대 공격 예고 위기 | 1일 | 낮음 |

**총 예상 구현 기간**: 약 11일 (2주)

---

## 10. OPS 팀 테스트 요청사항

이 설계서를 기반으로 OPS 팀에 다음 항목의 테스트를 요청한다:

```
1. 위기 개입이 실제로 긴장감을 만드는가? (질적 평가)
2. 세미오토 모드의 탭 UX가 자연스러운가?
3. 콤보 발동 빈도 (적절한가? 너무 많거나 적지 않은가?)
4. 리액션 윈도우 0.8초가 모바일에서 충분한가?
5. 집중 모드 5초 / 초당 20% 소모 밸런싱
6. 전투 평균 소요 시간 (목표: 45~90초)
7. 재미 지수 평가 (1~10점, 전후 비교)
```

---

**작성일**: 2026-03-01
**버전**: 2.0
**다음 문서**: OPS_TEST_REPORT_ATB_v2.md
**승인**: Steve PM 대기
