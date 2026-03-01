# 🃏 턴베이스 전투 시스템 v1.0 — StS 모바일 최적화
# Dream Collector — Mobile Turn-Based Combat Design

**문서 버전**: v1.0
**작성일**: 2026-03-01
**작성자**: Kim.G (게임팀장)
**참고 시스템**: Slay the Spire (StS) 핵심 전투 구조
**대상 플랫폼**: 모바일 (iOS/Android 우선, 추후 PC 지원)
**상태**: ✅ 설계 완료 — 구현 준비

> 📌 이 문서는 StS의 기본 전투 구조를 Dream Collector 모바일 환경에 맞게 재해석한 기획서입니다.
> **캐주얼 유저도 오토 플레이로 진행 가능**하되, 수동 플레이 시 깊은 전략적 재미를 제공합니다.

---

## 🎯 설계 목표

| 목표 | 내용 |
|------|------|
| **핵심 재미** | 카드 선택의 전략성 + 덱 시너지의 발견 |
| **모바일 최적화** | 한 손 조작, 짧은 전투, 직관적 UI |
| **접근성** | 오토 플레이로 누구나 진행 가능 |
| **깊이감** | 고수 플레이어는 콤보/시너지로 차별화 |
| **수익화** | 광고 없는 프리미엄 UX + 선택적 과금 |

**목표 전투 시간**: 60~120초 (일반 전투) / 2~4분 (보스 전투)

---

## ⚔️ 기본 전투 구조 (StS 기반)

### 턴 흐름

```
[전투 시작]
    │
    ▼
[플레이어 턴 시작]
├── 에너지 초기화 (기본 3)
├── 카드 드로우 (기본 5장)
├── 몬스터 의도(Intent) 표시
│
│  ← 플레이어 카드 플레이 (에너지 소모)
│  ← 카드 효과 즉시 적용
│  ← [언제든] 턴 종료 버튼 가능
│
▼
[플레이어 턴 종료]
├── 사용 않은 카드 버리기 (기본값)
├── 블록 소멸 (기본값)
│
▼
[몬스터 턴]
├── 의도대로 행동 실행
├── 상태이상 적용
│
▼
[몬스터 턴 종료]
    │
    ▼
[다음 플레이어 턴 시작] (루프)
```

### 핵심 수치 (기본값)

| 항목 | StS 원작 | Dream Collector |
|------|---------|----------------|
| 턴당 에너지 | 3 | 3 (유지) |
| 초기 손패 | 5장 | 5장 (유지) |
| 드로우 카드 | 5장/턴 | 5장 (유지) |
| 블록 지속 | 1턴 | 1턴 (유지) |
| 일반 HP | 70~80 | 70 |
| 보스 HP | 200~300+ | 150~350 (보스 등급별) |
| 덱 크기 | 10~30장 | 12~25장 (모바일 최적) |

---

## 📱 모바일 최적화 UX

### 1. 한 손 조작 레이아웃

```
┌────────────────────────────┐
│  [몬스터 영역]               │ ← 화면 상단 50%
│  HP: ████░░ 120/200        │
│  의도: ⚔️ 15 다음 턴        │
│  상태: 중독 🟢 2            │
│                            │
├────────────────────────────┤
│  [플레이어 영역]             │ ← 화면 중단
│  HP: ██████ 60/70          │
│  블록: 🛡️ 8    에너지: ⚡2/3│
│                            │
├────────────────────────────┤
│ [카드 손패]                 │ ← 화면 하단 35%
│ [카드1][카드2][카드3][카드4][카드5] │
│           [턴 종료]         │
└────────────────────────────┘
```

**조작 방식**:
- **카드 사용**: 카드를 위로 스와이프 → 몬스터/아군 타겟 자동 선택
- **타겟 지정**: 광역이 아닌 카드는 몬스터 탭으로 타겟 지정
- **카드 확인**: 카드 꾹 누르기 → 카드 상세 팝업 (0.5초 유지)
- **턴 종료**: 화면 하단 중앙 버튼 (크게, 실수 방지용 더블 탭 옵션)

### 2. 카드 확대 없는 읽기 편의성

```gdscript
# CardUI.gd (턴베이스 버전)
const CARD_MIN_HEIGHT = 100    # 최소 높이 (px)
const CARD_MIN_TOUCH = 80      # 최소 터치 영역
const CARD_FONT_SIZE = 14      # 최소 폰트 크기

# 카드 정보 표시 레이어
func _render_card(card: Card):
    # 상단: 에너지 비용 (크게)
    cost_label.text = str(card.cost)
    cost_label.add_theme_font_size_override("font_size", 20)

    # 중단: 카드 이름 (굵게)
    name_label.text = card.name

    # 하단: 효과 한 줄 요약 (아이콘 + 숫자)
    effect_label.text = card.get_short_description()  # "⚔️ 8" or "🛡️ 5" or "✨ 드로우 1"
```

### 3. 모바일 편의 기능

#### 빠른 확인 (Quick Preview)
카드 상세 설명이 긴 경우 꾹 눌러 팝업 확인. 손가락을 떼면 팝업 사라짐.

#### 자동 타겟 (Smart Target)
공격 카드를 스와이프하면 가장 약한 적이 기본 선택됨. 원하는 적이 다른 경우 드래그로 변경.

#### 실행 취소 방지 (Confirm Toggle)
설정에서 "카드 사용 전 확인" 옵션 (기본값: OFF). 초보자는 ON 권장.

#### 빠른 카드 플레이 (Speed Mode)
설정에서 "카드 사용 애니메이션 속도" 선택 (보통/빠름/즉시). 기본값: 보통.

---

## 🤖 오토 플레이 시스템

### 오토 플레이 모드 3단계

| 모드 | 동작 | 대상 유저 |
|------|------|---------|
| **풀 오토** | AI가 카드 선택 + 턴 종료 자동 | 캐주얼 (방치 플레이) |
| **세미 오토** | AI 추천 카드 → 플레이어 탭으로 확인 | 중간 유저 |
| **수동** | 모든 결정 플레이어 직접 | 전략 유저 |

### 오토 AI 알고리즘 (우선순위 기반)

```gdscript
# TurnBasedAutoAI.gd
class_name TurnBasedAutoAI

enum Priority { SURVIVAL, EFFICIENCY, COMBO }

func decide_cards_to_play(hand: Array[Card], state: CombatState) -> Array[Card]:
    var priority = _get_current_priority(state)

    match priority:
        Priority.SURVIVAL:
            # HP < 30%: 방어/치유 우선
            return _survival_strategy(hand, state)
        Priority.EFFICIENCY:
            # 일반 상황: 에너지 최대 활용
            return _efficiency_strategy(hand, state)
        Priority.COMBO:
            # 시너지 카드 있음: 콤보 완성 우선
            return _combo_strategy(hand, state)

func _efficiency_strategy(hand: Array[Card], state: CombatState) -> Array[Card]:
    var selected: Array[Card] = []
    var remaining_energy = state.energy

    # 몬스터가 다음 턴 강한 공격 예고 시 블록 우선
    if state.enemy_next_attack > state.player_block + 10:
        var best_block = _find_best_block_card(hand, remaining_energy)
        if best_block:
            selected.append(best_block)
            remaining_energy -= best_block.cost

    # 남은 에너지로 공격 카드 선택 (데미지 효율 순)
    var attack_cards = hand.filter(func(c): return c.type == "ATK" and c.cost <= remaining_energy)
    attack_cards.sort_custom(func(a, b): return a.get_damage_per_energy() > b.get_damage_per_energy())

    for card in attack_cards:
        if remaining_energy >= card.cost:
            selected.append(card)
            remaining_energy -= card.cost

    return selected

# 오토 플레이 속도 (애니메이션 포함)
const AUTO_CARD_DELAY = 0.5   # 카드 간 딜레이
const AUTO_TURN_DELAY = 1.0   # 턴 종료 후 딜레이
```

### 오토 플레이 표시 UI

```
[오토 모드 활성화 시]
┌────────────────────────────┐
│           🤖 AUTO           │ ← 상단 중앙에 AUTO 배지
│                            │
│  [AI가 생각 중...]          │ ← 카드 선택 전 0.3초 대기
│  [카드 2 선택 → 적용]       │
│  [카드 5 선택 → 적용]       │
│  [에너지 소진 → 턴 종료]    │
└────────────────────────────┘
```

**세미 오토**: AI가 카드 위에 "▶ 추천" 배지 표시 → 플레이어가 탭하면 실행. 3초 내 탭 없으면 AI가 자동 실행.

---

## 🌙 Dream Collector 독자 시스템

StS의 기본 구조 위에 Dream Collector만의 독자적인 시스템을 추가합니다.

### 1. 타로 에너지 시스템

**개요**: 기본 에너지(3) 외에 특정 카드 조합으로 "타로 에너지" 충전. 강력한 아르카나 카드 사용 가능.

```
[기본 에너지]    [타로 에너지]
⚡⚡⚡           🌙🌙 (충전 시)
```

```gdscript
# TarotEnergySystem.gd
var tarot_energy: int = 0
const TAROT_ENERGY_MAX = 3

func on_card_played(card: Card):
    # 메이저 아르카나 카드 사용 시 타로 에너지 1 충전
    if card.is_major_arcana:
        tarot_energy = min(TAROT_ENERGY_MAX, tarot_energy + 1)
        _show_tarot_charge_effect()

    # 타로 에너지 소모 카드
    if card.costs_tarot_energy:
        tarot_energy -= card.tarot_cost
```

**타로 에너지 카드 예시**:
| 카드 | 타로 비용 | 효과 |
|------|---------|------|
| 달의 환영 | 🌙×2 | 패에서 카드 3장 드로우 + 다음 턴 에너지 +1 |
| 태양의 폭발 | 🌙×3 | 전체 적에게 30 데미지 + 모든 디버프 제거 |
| 심판의 날 | 🌙×2 | 가장 강한 적에게 HP의 40% 피해 |

---

### 2. 꿈 조각 시스템 (Dream Shard)

**개요**: 특정 카드 조합 플레이 시 "꿈 조각"이 쌓임. 꿈 조각을 소비해 즉발 효과 발동.

```gdscript
# DreamShardSystem.gd
var dream_shards: int = 0
const MAX_SHARDS = 5

# 꿈 조각 획득 조건
func _check_shard_gain(cards_played_this_turn: Array[Card]):
    # 같은 색 카드 2장 연속 → 꿈 조각 1
    if _has_same_color_combo(cards_played_this_turn):
        gain_shard(1)
    # 비용 합계 5 이상 한 턴에 사용 → 꿈 조각 1
    if _get_total_cost(cards_played_this_turn) >= 5:
        gain_shard(1)

# 꿈 조각 소비 (턴 중 언제든 탭)
func spend_shards(ability: ShardAbility):
    match ability:
        ShardAbility.QUICK_DRAW:   # 1조각: 카드 1장 드로우
            spend(1); CombatManager.draw_card(1)
        ShardAbility.ENERGY_BURST: # 2조각: 에너지 +1
            spend(2); CombatManager.add_energy(1)
        ShardAbility.DREAM_HEAL:   # 3조각: HP 8 회복
            spend(3); CombatManager.heal(8)
        ShardAbility.NIGHTMARE:    # 5조각: 적 전체 약점 노출
            spend(5); CombatManager.expose_all_weaknesses()
```

**UI**: 화면 상단 우측에 꿈 조각 아이콘 (별 형태). 탭하면 소비 메뉴 팝업.

---

### 3. 꿈 기억 (Dream Memory) 패시브 효과

**개요**: 덱에서 특정 카드 조합을 보유하면 전투 시작 시 패시브 효과 활성화. 덱빌딩 전략 깊이 추가.

| 조합 이름 | 조건 | 패시브 효과 |
|---------|------|----------|
| 달의 기사 | 방어 카드 5장+ | 턴 시작 시 블록 3 자동 생성 |
| 검의 달인 | 공격 카드 7장+ | 첫 번째 공격 카드 데미지 +2 |
| 꿈의 직공 | 같은 카드 3장+ | 해당 카드 효과 +50% |
| 균형의 자 | 카드 비용 합계 짝수 | 에너지 1 추가 (첫 턴만) |
| 타로 학자 | 메이저 아르카나 3장+ | 타로 에너지 시작값 +1 |

```gdscript
# DeckPassiveCalculator.gd
func calculate_passives(deck: Array[Card]) -> Array[Passive]:
    var passives: Array[Passive] = []
    var defense_count = deck.filter(func(c): return c.type == "DEF").size()
    var attack_count = deck.filter(func(c): return c.type == "ATK").size()
    var arcana_count = deck.filter(func(c): return c.is_major_arcana).size()

    if defense_count >= 5:
        passives.append(Passive.new("달의 기사", "턴 시작 시 블록 3"))
    if attack_count >= 7:
        passives.append(Passive.new("검의 달인", "첫 공격 +2"))
    if arcana_count >= 3:
        passives.append(Passive.new("타로 학자", "타로 에너지 시작 +1"))

    return passives
```

---

## 💰 수익화 모델

### 기본 원칙: "광고 없음, 페이투윈 없음"

Dream Collector 턴베이스는 다음 원칙을 따릅니다:
1. **광고 없음**: 전투 중 광고 팝업 일절 없음
2. **페이투윈 없음**: 유료 카드가 무료 카드보다 강하지 않음
3. **시간 제한 없음**: 스태미나 시스템 없음 (언제든 플레이 가능)
4. **선택적 과금**: 모든 유료 요소는 "편의성" 또는 "커스터마이징"

### 수익화 항목

#### 🎁 스타터 팩 (일회성)
```
드림 컬렉터 스타터 팩 — ₩2,900
├── 스킨: "달빛 카드 테마" (카드 테두리 변경)
├── 덱 슬롯: +2개 추가 (기본 3개 → 5개)
└── 꿈 에너지 (소프트 커런시) 500개
```

#### 🌙 월정액 (Dream Pass) — ₩3,900/월
```
드림 패스
├── 매일 무료 카드 팩 1개 (소프트 커런시 보상)
├── 전투 경험치 +20%
├── 전용 카드 슬리브 (스킨)
└── 전용 필드 배경
```
> 단, 보상이 게임플레이에 영향 없음. 진행 속도 편의성만 향상.

#### 🃏 카드 팩 — 소프트/하드 커런시 혼용
```
꿈 카드 팩 (일반) — 꿈 에너지 100개 (무료 획득 가능)
├── 랜덤 카드 3장 (공통/희귀 등급)

달빛 카드 팩 (프리미엄) — 달빛 조각 50개 (유료 구매)
├── 랜덤 카드 3장 (희귀/특수 등급 보장)
└── 보장: 10팩 내 특수 등급 1장 이상
```

#### 🎨 코스메틱 상점
- 카드 테마 (테두리, 배경, 폰트): 각 ₩1,900~₩3,900
- 캐릭터 스킨: ₩4,900~₩9,900
- 애니메이션 이펙트: ₩1,900~₩2,900

#### 🔄 덱 슬롯 추가 — ₩1,900/슬롯
기본 3개 덱 슬롯 → 최대 10개까지 구매 가능.
전략 빌더 유저를 위한 편의 기능.

### 무료 유저 경험 보장

```gdscript
// 무료 플레이어 일일 보상
var daily_rewards = {
    "dream_energy": 150,         // 카드 팩 1.5개 분량
    "login_streak_bonus": true,  // 7일 연속 시 특별 보상
    "battle_clear_rewards": true // 전투 클리어 시 에너지 획득
}

// 모든 카드 획득 가능 여부
var card_availability = {
    "free_cards": "게임 내 전체 카드의 100%",  // 무료로 모두 획득 가능
    "paid_exclusive": "스킨/테마만 유료 독점"   // 게임플레이 영향 없음
}
```

---

## 🎮 캐주얼 모드 (모바일 편의 기능)

### 1. 자동 진행 속도 조절

```
[설정] → [전투 속도]
○ 느림  (애니메이션 100%)
● 보통  (애니메이션 75%)
○ 빠름  (애니메이션 50%)
○ 즉시  (애니메이션 없음)
```

### 2. 힌트 시스템 (Hint Light)

전략이 막힐 때 👁️ 버튼을 누르면 AI가 추천 플레이 표시.

```gdscript
# HintSystem.gd
func get_hint(hand: Array[Card], state: CombatState) -> HintResult:
    # 몬스터가 치명적 공격 예고 시
    if state.enemy_will_kill_player_next_turn:
        return HintResult.new(
            message = "위험! 블록이 필요해요.",
            highlight_cards = hand.filter(func(c): return c.type == "DEF"),
            urgency = HintUrgency.CRITICAL
        )
    # 일반 추천
    var best_play = AutoAI.new().decide_cards_to_play(hand, state)
    return HintResult.new(
        message = "이 카드 조합을 추천해요!",
        highlight_cards = best_play,
        urgency = HintUrgency.NORMAL
    )
```

**힌트 표시**: 추천 카드에 💡 아이콘 표시. 플레이어가 다른 선택을 해도 페널티 없음.

### 3. 저장/이어하기 기능

```gdscript
// 전투 중 앱 전환 시 자동 저장
func _on_app_background():
    SaveManager.save_combat_state(CombatManager.get_state())

// 다음 실행 시 "이어하기" 팝업
func _check_saved_combat():
    if SaveManager.has_saved_combat():
        _show_continue_popup()
```

**이어하기 팝업**:
```
╔════════════════════╗
║  저장된 전투가 있어요  ║
║                    ║
║ [이어하기] [새 전투] ║
╚════════════════════╝
```

### 4. 짧은 세션 지원 (5분 모드)

일반 탐험 없이 "빠른 전투" 시작 → 미리 정해진 덱으로 즉시 전투. 이동 중 5분 플레이 가능.

```gdscript
// 빠른 전투 모드
func start_quick_battle():
    var preset_deck = DeckManager.get_last_used_deck()
    var random_dungeon_floor = DungeonGenerator.generate_quick(floors=3)
    CombatManager.start_battle(preset_deck, random_dungeon_floor.first_encounter)
```

### 5. 스마트 알림 (적시 복귀 유도)

```
[알림 설정] (기본값: OFF, 유저가 직접 설정)
○ 일일 보상 알림 (매일 오전 10시)
○ 달빛 패스 만료 알림 (만료 3일 전)
○ 새 콘텐츠 알림
```

---

## 🃏 카드 시스템 (모바일 최적화)

### 카드 등급

| 등급 | 색상 | 특징 | 덱 내 비율 |
|------|------|------|----------|
| 기본 (Common) | 회색 | 간단하고 안정적 | 50~60% |
| 희귀 (Rare) | 파란 | 강력하거나 특이한 효과 | 30~40% |
| 특수 (Special) | 금색 | 덱 시너지 핵심 카드 | 10~15% |
| 전설 (Legendary) | 무지개 | 매 런마다 1~2장 등장 | 2~5% |

### 카드 설명 단순화 (모바일 가독성)

**StS 원작**: "상대 가장 낮은 HP 몬스터에게 기본 8 + 버프 스택당 2 추가 피해를 입힙니다."

**Dream Collector**: "⚔️8(+버프×2) 가장 약한 적"

```gdscript
// Card.gd
func get_mobile_description() -> String:
    // 아이콘 + 숫자 + 조건 간단 표기
    return "%s%d%s" % [
        get_effect_icon(),       // ⚔️ / 🛡️ / ✨ / ☠️
        get_base_value(),        // 숫자
        get_condition_short()    // "(+버프×2)" 또는 "" 또는 " 전체"
    ]
```

### 카드 예시 (Dream Collector 타로 테마)

| 카드명 | 비용 | 효과 (모바일 표기) | 덱 설명 |
|------|------|----------------|--------|
| 검의 에이스 | 1 | ⚔️6 | 기본 공격 |
| 방패의 왕 | 2 | 🛡️12 | 강한 방어 |
| 마법사 | 2 | ⚔️4 전체 | 광역 공격 |
| 달의 여제 | 3 | ✨드로우3 + 🌙 | 타로 에너지 충전 |
| 악마 | 2 | ☠️중독3 전체 | 광역 디버프 |
| 세계 | 4 | ⚔️20 + 🛡️10 | 강력한 복합 카드 |
| 바보 | 0 | ✨드로우1 에너지+1 | 0코스트 유틸 |
| 탑 | 2 | ⚔️15 자해3 | 리스크/리워드 |

---

## 🏆 보스 전투 특수 규칙

### 보스 페이즈 시스템

```
보스 HP 100% → 70%: 페이즈 1 (기본 패턴)
보스 HP 70% → 40%: 페이즈 2 (패턴 강화, 새 능력 추가)
보스 HP 40% → 0%: 페이즈 3 (격분, 공격력 +50%)
```

```gdscript
// BossCombatManager.gd
func _check_phase_transition():
    var hp_ratio = boss.current_hp / boss.max_hp
    match current_phase:
        1:
            if hp_ratio <= 0.7:
                _transition_to_phase(2)
        2:
            if hp_ratio <= 0.4:
                _transition_to_phase(3)

func _transition_to_phase(phase: int):
    current_phase = phase
    _play_phase_transition_animation()
    boss.apply_phase_buffs(phase)
    // 보스 의도 갱신 (더 강한 패턴으로)
    MonsterIntentSystem.update_boss_intent(boss, phase)
```

### 보스 전용 메카닉: "악몽 카드 (Nightmare Card)"

페이즈 2 전환 시 플레이어 패에 "악몽 카드" 1장 강제 삽입.

```gdscript
// 악몽 카드 예시
Card.new(
    name = "악몽의 속박",
    cost = 0,
    type = CardType.CURSE,
    effect = "이 카드를 사용하지 않으면 턴 종료 시 HP 5 감소",
    description = "⚠️ 쓰면 패에 저주 카드 1장 추가"
)
```

**전략**: 악몽 카드를 쓰면 더 안 좋아지지만, 안 쓰면 HP 손실. 극한의 선택 강요.

---

## 📊 몬스터 의도(Intent) 시스템

### 의도 아이콘 체계

```
⚔️  = 공격 (숫자와 함께 데미지 표시)
🛡️  = 방어 (블록 획득)
💀  = 강한 공격 (일반의 1.5배 이상)
☠️  = 상태이상 부여 (중독/약화 등)
✨  = 버프 (자신 강화)
❓  = 알 수 없음 (보스 한정)
🌀  = 복합 행동 (공격 + 디버프 등)
```

```gdscript
// MonsterIntentSystem.gd
func display_intent(monster: Monster) -> IntentDisplay:
    var next_action = monster.get_next_action()

    return IntentDisplay.new(
        icon = _get_icon(next_action.type),
        value = next_action.value,  // 공격 시 데미지, 방어 시 블록량
        tooltip = next_action.get_full_description(),
        urgency = _get_urgency(next_action)  // 고데미지 → 빨간 강조
    )
```

**강조 표시**: 예고 데미지가 현재 HP의 30% 이상이면 의도 아이콘이 빨간색 + 진동.

---

## 🏗️ GDScript 구현 구조

```
scripts/combat/turnbased/
├── TurnBasedCombatManager.gd   # 핵심 턴 진행 엔진
├── TurnBasedAutoAI.gd          # 오토 플레이 AI
├── TarotEnergySystem.gd        # 타로 에너지 시스템
├── DreamShardSystem.gd         # 꿈 조각 시스템
├── DeckPassiveCalculator.gd    # 덱 패시브 계산기
├── BossCombatManager.gd        # 보스 전투 확장
├── MonsterIntentSystem.gd      # 몬스터 의도 시스템
├── HintSystem.gd               # 힌트 시스템
├── BattleDiary.gd              # 전투 일지 (ATB와 공유)
└── TurnBasedUI/
    ├── HandDisplay.gd          # 손패 표시
    ├── EnergyDisplay.gd        # 에너지 UI
    ├── IntentDisplay.gd        # 의도 아이콘
    └── TurnEndButton.gd        # 턴 종료 버튼
```

---

## 🔄 ATB vs 턴베이스 비교표

| 항목 | ATB 전투 | 턴베이스 전투 |
|------|---------|------------|
| **플레이 스타일** | 실시간 + 반사 신경 | 전략적 계획 |
| **오토 플레이** | 풀 오토 자연스러움 | 풀 오토 가능 |
| **전투 시간** | 45~90초 (수동) | 60~120초 (수동) |
| **집중도 요구** | 중~상 | 낮~중 |
| **적합 유저** | 액션/방치 좋아하는 유저 | 전략/덱빌딩 좋아하는 유저 |
| **학습 난이도** | 낮음 (오토 있음) | 낮음 (힌트 있음) |
| **전략 깊이** | 중 | 상 |
| **모바일 UX** | 실시간 반응 필요 | 여유로운 탭 |
| **추천 상황** | 짧은 세션, 이동 중 | 긴 세션, 집중 플레이 |

---

## 🚀 구현 우선순위

### 🔴 1순위 (기본 전투 가능 상태)
1. TurnBasedCombatManager.gd — 기본 턴 흐름
2. 에너지 시스템 (기본 3)
3. 손패 시스템 (5장 드로우/버리기)
4. MonsterIntentSystem.gd
5. 기본 카드 20장

### 🟠 2순위 (완성도 향상)
6. TurnBasedAutoAI.gd (풀 오토 / 세미 오토)
7. TarotEnergySystem.gd
8. DreamShardSystem.gd
9. HintSystem.gd
10. 보스 페이즈 시스템

### 🟡 3순위 (차별화 + 수익화)
11. DeckPassiveCalculator.gd
12. 악몽 카드 시스템
13. 수익화 시스템 (코스메틱 상점)
14. 5분 빠른 전투 모드
15. 전투 일지 통합

---

**문서 작성**: Kim.G (게임팀장)
**작성일**: 2026-03-01
**리뷰 예정**: Steve PM → OPS 팀 테스트 → v2.0 개선
**연관 문서**: ATB_COMBAT_SYSTEM_v3.md

---

**Status**: ✅ 설계 완료 — 구현 착수 가능
