# 🃏 턴베이스 전투 시스템 — 최종 완성 설계서 v1.0
# Dream Collector | Turn-Based Combat (StS × Expedition 33 × 소울류)

**문서 버전**: COMPLETE v1.0 (모든 이전 설계 통합본)
**작성일**: 2026-03-01
**작성자**: Kim.G (게임팀장)
**통합 출처**: TURNBASED_MOBILE_v1, REACTION_TURNBASED_v1, OPS 분석 리포트 4종
**상태**: ✅ 개발 이관 준비 완료

> 이 문서는 Dream Collector 턴베이스 전투 시스템의 **단일 최종 레퍼런스**입니다.

---

## PART 1. 시스템 개요

### 1.1 핵심 철학

**세 가지 원칙**:
1. **StS의 뼈대** — 에너지 3, 손패 5장, 의도 공개 시스템
2. **방어가 자원이다** — 패링/회피 성공 → 다음 턴 에너지 보너스
3. **모바일 최적화** — 오토 플레이, 짧은 세션, 한 손 조작

### 1.2 전투 구성 요소

```
턴베이스 전투
├── 에너지 시스템 (매 턴 3 자동 + 방어 보너스)
├── 손패 시스템 (드로우 5장/턴, 버림 더미)
├── 리액션 시스템 (패링/회피/방어 → 다음 턴 에너지)
├── 의도 시스템 (다음 2~3행동 예고)
├── 블록 시스템 (턴 종료 시 소멸 기본)
├── 타로 에너지 시스템 (특수 자원)
├── 꿈 조각 시스템 (즉발 소비 자원)
├── 덱 패시브 시스템 (덱 구성 → 패시브)
└── 오토 플레이 AI (3단계)
```

---

## PART 2. 기본 턴 흐름

```
[턴 시작]
에너지 = 3 (기본) + 방어 보너스 (지난 적 턴)
카드 드로우 = 5장 (+ 지난 패링 드로우 보너스)
의도 확인 (적 다음 행동)

[플레이어 행동]
카드 사용 (에너지 소모) — 순서 자유
꿈 조각 소비 (즉발 효과)
언제든 "턴 종료" 가능

[플레이어 턴 종료]
미사용 카드 → 버림 더미
블록 소멸 (기본값)

[적 턴]
의도대로 행동 실행

[리액션 윈도우 — 1.2초]
  패링 탭 (0.5초 이내) → 다음 턴 에너지 +2 + 드로우 1장
  회피 탭 (1.2초 이내) → 다음 턴 에너지 +1
  방어 카드 탭         → 블록 흡수 (에너지 보너스 없음)
  무반응               → 풀 피해

→ 다음 플레이어 턴 시작
```

---

## PART 3. 에너지 시스템

### 3.1 에너지 구조

```gdscript
# TurnBasedEnergySystem.gd
const BASE_ENERGY = 3
const PARRY_BONUS = 2
const DODGE_BONUS = 1
const GUARD_BONUS = 0
const OVERFLOW_MAX = 5  # 패링 보너스 합산 시 최대

var pending_energy_bonus: int = 0  # 적 턴 방어로 적립된 보너스

func start_player_turn():
    var total = min(OVERFLOW_MAX, BASE_ENERGY + pending_energy_bonus)
    current_energy = total
    pending_energy_bonus = 0
    EnergyUI.update(current_energy)

func on_parry_success():
    pending_energy_bonus += PARRY_BONUS
    draw_card(1)                   # 즉시 드로우
    EnergyUI.show_bonus_preview(pending_energy_bonus)

func on_dodge_success():
    pending_energy_bonus += DODGE_BONUS
    EnergyUI.show_bonus_preview(pending_energy_bonus)
```

### 3.2 에너지 시나리오

| 방어 결과 | 다음 턴 에너지 | 플레이 가능 카드 |
|---------|-------------|-------------|
| 패링 성공 | 최대 5 | 카드 3~5장 |
| 회피 성공 | 최대 4 | 카드 2~4장 |
| 방어/무반응 | 3 | 카드 2~3장 |

---

## PART 4. 리액션 시스템 (턴베이스)

### 4.1 리액션 카드 목록

**패링 전용 카드 (5종)**:

| 카드명 | 비용 | 효과 |
|--------|------|------|
| 꿈의 쳐내기 | 0 | 패링 — 무효 + ⚡+2 (다음턴) + 드로우1 |
| 반사의 순간 | 0 | 패링 — 무효 + ⚡+2 + 피해 30% 반격 |
| 각성의 쳐내기 | 0 | 패링 — 무효 + ⚡+3 (윈도우 0.3초) |
| 달빛 반격 | 1 | 패링 — 무효 + ⚡+1 + 즉시 8 공격 |
| 완벽한 방어 | 0 | 패링/회피 — 무효 + ⚡+1 |

**회피 전용 카드 (5종)**:

| 카드명 | 비용 | 효과 |
|--------|------|------|
| 꿈의 스텝 | 0 | 회피 — 회피 + ⚡+1 (다음턴) |
| 잔상 (殘像) | 0 | 회피 — 회피 + ⚡+1 + 버프 이전 |
| 황혼의 도약 | 0 | 회피 — 회피 + ⚡+1 + 다음 공격 +3 |
| 연막 | 1 | 회피 — 회피 + ⚡+1 + 적 다음 공격 -3 |
| 반보 앞으로 | 0 | 패링/회피 — 50% 감소 + ⚡+1 |

### 4.2 리액션 시스템 GDScript

```gdscript
# TurnBasedReactionManager.gd
func on_enemy_attack_begin(attack: AttackData):
    var parry_window = 0.5 if not story_mode else 0.8
    var dodge_window = 1.2 if not story_mode else 1.8
    ReactionTimer.start(parry_window, dodge_window)
    HandUI.highlight_reaction_cards(attack.type)

func on_player_card_tapped(card: Card, time_elapsed: float):
    var parry_limit = 0.5 if not story_mode else 0.8

    if card.has_tag("PARRY") and time_elapsed <= parry_limit:
        EnergySystem.on_parry_success()
        VFX.play("parry_flash")
        attack.cancel()

    elif card.has_tag("DODGE") and ReactionTimer.dodge_active:
        EnergySystem.on_dodge_success()
        attack.cancel()

    elif card.has_tag("GUARD"):
        player.add_block(card.block_value)

    else:
        attack.apply_full_damage()
```

---

## PART 5. 의도(Intent) 시스템

### 5.1 다음 3행동 예고

```gdscript
# TurnBasedIntentSystem.gd
func display_intent(enemy: Enemy):
    var upcoming = enemy.action_queue.slice(0, 3)
    IntentUI.clear()
    for i in range(upcoming.size()):
        IntentUI.add_slot(
            icon     = _get_icon(upcoming[i]),
            value    = upcoming[i].damage,
            is_current = (i == 0),
            is_heavy = upcoming[i].damage > enemy.atk * 1.5,
            is_unblockable = (upcoming[i].type == AttackType.UNBLOCKABLE)
        )
```

### 5.2 공격 유형별 표기

| 아이콘 | 의미 | 패링 가능 | 에너지 보상 |
|--------|------|---------|----------|
| ⚔️ (숫자) | 일반 공격 | ✅ | +2 or +1 |
| ⚔️⚠️ | 강한 공격 | ✅ 권장 | +2 |
| 🔱 | 관통 (방어불가) | ❌ | +1 (회피) |
| 🛡️ | 방어 강화 | ❌ | — |
| ✨ | 버프 | ❌ | — |
| 💤 | 쉬는 턴 | — | — |

---

## PART 6. 타로 에너지 시스템

```gdscript
# TarotEnergySystem.gd
var tarot_energy: int = 0
const TAROT_MAX = 3

func on_card_played(card: Card):
    if card.is_major_arcana:
        tarot_energy = min(TAROT_MAX, tarot_energy + 1)
        TarotUI.update(tarot_energy)

# 타로 에너지 카드
# "달의 환영" — 🌙×2 — 드로우3 + 다음 턴 에너지 +1
# "태양의 폭발" — 🌙×3 — 전체 30 데미지 + 디버프 제거
# "심판의 날" — 🌙×2 — 가장 강한 적 HP 40% 피해
```

---

## PART 7. 꿈 조각 시스템

```gdscript
# DreamShardSystem.gd
var shards: int = 0
const MAX_SHARDS = 5

enum ShardAbility { QUICK_DRAW, ENERGY_BURST, DREAM_HEAL, NIGHTMARE }

func spend(ability: ShardAbility):
    match ability:
        ShardAbility.QUICK_DRAW:    # 1조각: 드로우 1
            if shards >= 1: shards -= 1; draw_card(1)
        ShardAbility.ENERGY_BURST:  # 2조각: 에너지 +1
            if shards >= 2: shards -= 2; add_energy(1)
        ShardAbility.DREAM_HEAL:    # 3조각: HP 8 회복
            if shards >= 3: shards -= 3; player.heal(8)
        ShardAbility.NIGHTMARE:     # 5조각: 적 전체 약점 노출
            if shards >= 5: shards -= 5; expose_all_weaknesses()

func gain_shard(n: int = 1):
    shards = min(MAX_SHARDS, shards + n)
    ShardUI.update(shards)
```

꿈 조각 획득 조건:
- 같은 색 카드 2장 연속 → +1
- 한 턴 비용 합계 5 이상 → +1
- 패링 성공 → +1

---

## PART 8. 덱 패시브 시스템

```gdscript
# DeckPassiveCalculator.gd
func calculate(deck: Array[Card]) -> Array[Passive]:
    var passives = []
    var def_count = deck.filter(func(c): return c.type == "DEF").size()
    var atk_count = deck.filter(func(c): return c.type == "ATK").size()
    var arcana_count = deck.filter(func(c): return c.is_major_arcana).size()
    var parry_count = deck.filter(func(c): return c.has_tag("PARRY")).size()

    if def_count >= 5:
        passives.append(Passive.new("달의 기사", "턴 시작 시 블록 3"))
    if atk_count >= 7:
        passives.append(Passive.new("검의 달인", "첫 공격 +2"))
    if arcana_count >= 3:
        passives.append(Passive.new("타로 학자", "타로 에너지 시작 +1"))
    if parry_count >= 4:
        passives.append(Passive.new("달빛 반격사", "패링 에너지 보너스 +1"))
    return passives
```

---

## PART 9. 오토 플레이 AI

```gdscript
# TurnBasedAutoAI.gd
func decide_defense(hand: Array[Card], attack: AttackData) -> String:
    # 에너지 부족 시 패링 우선
    if pending_energy_bonus < 1 and hand.has_parry_card():
        return "PARRY"
    if attack.is_heavy and hand.has_parry_card() and randf() < 0.70:
        return "PARRY"
    if hand.has_dodge_card():
        return "DODGE"
    if hand.has_parry_card() and randf() < 0.65:
        return "PARRY"
    return "GUARD"

func decide_attack_cards(hand: Array[Card], energy: int) -> Array[Card]:
    var selected = []
    var rem = energy
    # 생존 우선
    if float(player.hp) / player.max_hp < 0.40:
        var def_card = hand.find_card("DEF", rem)
        if def_card: selected.append(def_card); rem -= def_card.cost
    # 데미지 효율 순
    var attacks = hand.filter(func(c): return c.type == "ATK" and c.cost <= rem)
    attacks.sort_custom(func(a,b): return a.dmg_per_energy() > b.dmg_per_energy())
    for c in attacks:
        if rem >= c.cost: selected.append(c); rem -= c.cost
    return selected
```

---

## PART 10. 보스 전투 특수 규칙

### 10.1 보스 페이즈

| 페이즈 | HP 범위 | 변화 |
|--------|---------|------|
| 1 | 100%~70% | 기본 패턴 |
| 2 | 70%~40% | 패턴 강화, 새 능력 추가 |
| 3 | 40%~0% | 격분 — 공격력 +50% |

페이즈 전환 시: "꿈의 악몽 카드" 1장 손패에 강제 삽입

### 10.2 악몽 카드

```
악몽의 속박 (코스트 0, Curse)
효과: 이 카드를 사용하지 않으면 턴 종료 시 HP 5 감소
      사용 시: 버림 더미에 저주 카드 1장 추가
→ 쓰면 손해, 안 쓰면 HP 손실. 극한의 선택 강제
```

---

## PART 11. 모바일 UX

| 항목 | 설계 |
|------|------|
| 카드 스와이프 | 위로 스와이프 → 사용 |
| 카드 확인 | 꾹 누르기 0.5초 → 상세 팝업 |
| 타겟 지정 | 광역 아닌 카드: 몬스터 탭으로 타겟 |
| 턴 종료 | 하단 중앙 큰 버튼 (더블탭 확인 옵션) |
| 카드 터치 영역 | 최소 80px, 카드 간격 8px 이상 |
| 전투 속도 | 느림/보통/빠름/즉시 선택 |
| 저장/이어하기 | 앱 전환 시 자동 저장 |

---

## PART 12. 핵심 수치 최종 정리

| 항목 | 수치 |
|------|------|
| 기본 에너지/턴 | 3 |
| 에너지 최대 (패링 보너스) | 5 |
| 패링 에너지 보너스 | +2 (다음 턴) |
| 패링 드로우 보너스 | +1장 (즉시) |
| 패링 윈도우 | 0.5초 (Story: 0.8초) |
| 회피 에너지 보너스 | +1 (다음 턴) |
| 회피 윈도우 | 1.2초 (Story: 1.8초) |
| 기본 손패 크기 | 5장 |
| 기본 드로우/턴 | 5장 |
| 블록 유지 | 1턴 (소멸) |
| 타로 에너지 최대 | 3 |
| 꿈 조각 최대 | 5 |
| 최적 덱 크기 | 12~25장 |

---

## PART 13. GDScript 파일 구조

```
res://scripts/combat/turnbased/
├── TurnBasedCombatManager.gd    # 핵심 턴 엔진
├── TurnBasedEnergySystem.gd     # 에너지 + 방어 보너스
├── TurnBasedReactionManager.gd  # 리액션 윈도우
│   ├── ParrySystem_TB.gd
│   ├── DodgeSystem_TB.gd
│   └── GuardSystem_TB.gd
├── TurnBasedIntentSystem.gd     # 의도 표시 (3행동 예고)
├── HandSystem.gd                # 손패 드로우/버리기
├── BlockSystem.gd               # 블록 생성/소멸
├── TarotEnergySystem.gd         # 타로 에너지
├── DreamShardSystem.gd          # 꿈 조각
├── DeckPassiveCalculator.gd     # 덱 패시브
├── TurnBasedAutoAI.gd           # 오토 플레이 AI
├── BossCombatManager.gd         # 보스 페이즈 + 악몽 카드
└── BattleDiary.gd               # 전투 일지
```

---

## PART 14. 구현 우선순위

### Phase A (핵심)
1. TurnBasedCombatManager.gd (턴 루프)
2. TurnBasedEnergySystem.gd
3. HandSystem.gd (드로우/버리기)
4. TurnBasedIntentSystem.gd
5. TurnBasedReactionManager.gd (패링/회피)
6. 기본 카드 30장

### Phase B (완성도)
7. TarotEnergySystem.gd
8. DreamShardSystem.gd
9. TurnBasedAutoAI.gd
10. BossCombatManager.gd (페이즈 + 악몽 카드)

### Phase C (폴리싱)
11. DeckPassiveCalculator.gd
12. BattleDiary.gd

---

**작성**: Kim.G (게임팀장) | **날짜**: 2026-03-01 | **상태**: ✅ 개발 이관 완료
