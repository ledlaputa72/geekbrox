# ⚡ 리액션 & 의도 시스템 v3.0
# "꿈의 반격 (Dream Counter)" — Expedition 33 × 소울류 패러다임 통합

**문서 버전**: v3.0
**작성일**: 2026-03-01
**작성자**: Kim.G (게임팀장)
**참조 시스템**:
  - Clair Obscur: Expedition 33 (Sandfall Interactive, 2025) — Reactive Turn-Based 전투
  - Sekiro: Shadows Die Twice (FromSoftware, 2019) — 패링 & 자세 게이지
**업그레이드 대상**: ATB_COMBAT_SYSTEM_v2.md — 4. 리액션 카드 시스템 + 6. 몬스터 의도 시스템
**상태**: ✅ 설계 완료

> 📌 **설계 철학**
>
> Expedition 33은 턴제 RPG에 소울류의 패링·회피를 삽입해서 *"적의 공격도 내 플레이다"* 라는
> 혁신을 이뤄냈다. TGA 2025 올해의 게임 포함 9개 부문 수상.
> Dream Collector는 이 철학을 모바일 카드 ATB 전투에 재해석한다.
>
> **핵심 전환**: 기존 리액션 카드 = "버튼 누르기 기회"
> → v3.0 리액션 = "공격 패턴을 읽고, 타이밍에 맞춰, 반격까지 이어지는 전투 레이어"

---

## 🎯 Expedition 33에서 가져오는 것

| Expedition 33 메카닉 | Dream Collector 적용 |
|--------------------|-------------------|
| 패링 (Parry) — 좁은 윈도우, 높은 보상 | **완전 패링** — 카드 즉발 + 반격 효과 |
| 회피 (Dodge) — 넓은 윈도우, 낮은 보상 | **반응 카드** — 기존 리액션 카드 방식 유지 |
| 체인 패링 → 체인 카운터 | **연속 패링 → 꿈의 반격** 콤보 |
| 원정대 카운터 (팀 광역 방어) | **꿈의 방어막** — 특수 리액션 카드 |
| 브레이크 게이지 → 취약 상태 | **몬스터 자세 게이지** 시스템 |

## 🎯 소울류(Sekiro)에서 가져오는 것

| Sekiro 메카닉 | Dream Collector 적용 |
|-------------|-------------------|
| 시각/청각 예고 신호 (공격 직전 플래시) | **3단계 공격 예고 연출** |
| 자세(Posture) 게이지 → 처형 | **자세 붕괴 → 꿈의 파쇄** 상태 |
| 패링 성공 → 자세 누적 | **완전 패링 → 자세 게이지 급증** |
| 공격 직전 빨간 일본어 한자 (危) 표시 | **"⚡위험!" 텍스트 플래시** |

---

## 🔄 v2.0 → v3.0 핵심 변화

| 항목 | v2.0 (기존) | v3.0 (업그레이드) |
|------|----------|----------------|
| 리액션 종류 | 단일 방식 (카드 탭) | 3단계 (완전 패링 / 반응 카드 / 긴급 가드) |
| 타이밍 보상 | 동일 효과 | 타이밍 정밀도에 따라 보상 차등 |
| 반격 시스템 | 없음 | 완전 패링 성공 시 즉각 반격 카드 발동 |
| 체인 공격 | 없음 | 연속 패링 성공 시 체인 카운터 보너스 |
| 자세 게이지 | 없음 | 몬스터 자세 게이지 → 파쇄 상태 |
| 공격 예고 | 아이콘 1개 | 3단계 연출 (예고 → 경보 → 임팩트) |
| 특수 공격 유형 | 없음 | 광역 공격 / 관통 공격 / 그라디언트 공격 |

---

## ⚔️ 시스템 1: 3단계 방어 반응 (Three-Tier Defense)

Expedition 33처럼 모든 적 공격에 대해 **3가지 반응 방식** 중 하나를 선택한다.

```
적 공격 예고
    │
    ├── [완전 패링] ← 가장 좁은 윈도우 (0.4초) / 최고 보상
    │       → 피해 완전 무효 + 반격 카드 즉발 + 자세 게이지 급증
    │
    ├── [반응 카드] ← 중간 윈도우 (1.2초) / 중간 보상
    │       → 피해 50~100% 감소 (카드 효과에 따라) + 일부 자세 누적
    │
    └── [긴급 가드] ← 가장 넓은 윈도우 (2.0초) / 낮은 보상
            → 피해 30% 감소 (손에 방어 카드 없어도 자동 발동)
            → 에너지 1 소모
```

---

## 🎭 시스템 2: 완전 패링 (Perfect Parry)

### 2.1 개념

소울류의 패링 + Expedition 33의 타이밍 카운터를 합친 핵심 메카닉.
적 공격의 **임팩트 직전 0.4초** 안에 손패의 패링 카드를 탭하면 발동.

성공 시: **피해 완전 무효 + 반격 카드 즉발 + 자세 게이지 급상승**
실패(늦음): 반응 카드 판정으로 하향
실패(너무 빠름): 긴급 가드 판정으로 하향

### 2.2 반격 카드 (Counter Card)

완전 패링 성공 시 손패에서 **반격 카드** 1장이 자동 하이라이트되며 즉시 발동 선택권 부여.

```
[완전 패링 성공!]

✨ 반격 기회! (1.5초)
══════════════════════════════
★ [꿈의 반격] — 적에게 방어도의 150% 데미지
  [무시하기]  → 반격 포기 (자세 게이지 보상은 유지)
══════════════════════════════
```

반격 카드 목록:

| 반격 카드명 | 효과 | 특수 조건 |
|----------|------|---------|
| **꿈의 반격 (Dream Counter)** | 받을 뻔한 데미지의 120% 반사 | 기본 반격 |
| **자세 붕괴 (Posture Crush)** | 몬스터 자세 게이지 +40 즉시 | 자세 게이지 시스템 연동 |
| **연속 반격 (Chain Counter)** | 공격 +30% × 현재 패링 연속 횟수 | 체인 패링 시 강화 |
| **기억의 역습 (Memory Strike)** | 이번 전투에서 받은 총 피해의 50% 단타 | 하드 데미지 보상 |
| **꿈의 각성 (Dream Awaken)** | 에너지 +2 즉시 충전 | 에너지 부족 상황 반전 |

### 2.3 패링 윈도우 타이밍 구조

```
적 공격 전 타임라인:

[예고 단계]      [경보 단계]    [임팩트]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━▶
   -1.5초          -0.8초       0초

  노란 글로우      빨간 플래시   ★ 패링 윈도우
  "공격 온다"      "⚡위험!"     -0.4초 ~ 0초
  (자세 확인)     (손가락 준비)  (탭해야 함)
```

```gdscript
# PerfectParrySystem.gd
class_name PerfectParrySystem

const PARRY_WINDOW = 0.4          # 완전 패링 윈도우 (초)
const REACTION_WINDOW = 1.2       # 반응 카드 윈도우 (초, v3.0 적용)
const GUARD_WINDOW = 2.0          # 긴급 가드 윈도우 (초)
const WARNING_FLASH_TIME = 0.8    # 경보 플래시 발생 시점 (임팩트 전)

enum ParryResult {
    PERFECT_PARRY,  # 0.4초 이내 탭
    REACTION_CARD,  # 0.4~1.2초 탭
    EMERGENCY_GUARD, # 1.2~2.0초 탭
    HIT             # 반응 없음 or 2.0초 초과
}

var impact_time: float = 0.0   # 임팩트까지 남은 시간
var parry_phase: String = "IDLE"
var chain_parry_count: int = 0

func _process(delta):
    if parry_phase == "IDLE":
        return
    impact_time -= delta
    _update_visual_phase()

func _update_visual_phase():
    if impact_time > WARNING_FLASH_TIME:
        # 예고 단계: 노란 글로우
        AttackTellUI.show_warning_glow(Color.YELLOW, impact_time)
    elif impact_time > 0.0:
        # 경보 단계: 빨간 플래시 + "⚡위험!" 텍스트
        AttackTellUI.show_danger_flash()
        AttackTellUI.show_danger_text("⚡ 위험!")
        # 패링 가능 카드 황금 테두리
        HandUI.highlight_parry_cards()
    else:
        # 임팩트
        _resolve_impact()

func register_player_tap(tap_time_before_impact: float) -> ParryResult:
    if tap_time_before_impact <= PARRY_WINDOW:
        _on_perfect_parry()
        return ParryResult.PERFECT_PARRY
    elif tap_time_before_impact <= REACTION_WINDOW:
        return ParryResult.REACTION_CARD
    elif tap_time_before_impact <= GUARD_WINDOW:
        _on_emergency_guard()
        return ParryResult.EMERGENCY_GUARD
    else:
        return ParryResult.HIT

func _on_perfect_parry():
    chain_parry_count += 1
    # 시각 효과
    VFXManager.play("perfect_parry_flash")   # 흰색 링 폭발
    SoundManager.play("parry_clang")         # 쇳소리
    CameraManager.slight_shake(0.2)

    # 보상
    CombatManager.negate_incoming_damage()
    PostureSystem.add_to_enemy(40)           # 자세 게이지 +40
    _offer_counter_card()                    # 반격 카드 제시

func _on_emergency_guard():
    CombatManager.reduce_incoming_damage(0.30)  # 30% 경감
    CombatManager.spend_energy(1)
```

### 2.4 완전 패링 시각 연출

Expedition 33의 **그라디언트 카운터**처럼 완전 패링 성공 시 특별한 시각 연출:

```
[완전 패링 성공 연출]

1. 화면 0.15초 흰색 플래시
2. 적 공격 이펙트가 역방향으로 튕겨나가는 파티클
3. "PERFECT!" 텍스트 (황금색, 화면 중앙)
4. 슬로모 0.3초 (반격 선택을 위한 여유)
5. 반격 카드 UI 팝업
```

---

## 🔗 시스템 3: 체인 패링 & 체인 카운터

Expedition 33의 **연속 공격 체인**처럼, 일부 몬스터는 **2~5회 연속 공격**을 한다.
모든 공격을 연속 패링하면 **체인 카운터** 발동.

### 3.1 체인 공격 시퀀스

```
[보스 체인 공격: "악몽의 3연격"]

공격 1 →  [완전 패링] ✅  → "체인 1"
공격 2 →  [완전 패링] ✅  → "체인 2"
공격 3 →  [완전 패링] ✅  → "체인 3"
                              ↓
                    ★ "3연속 완전 패링! 체인 카운터!"
                    → 반격 카드 자동 최강화 발동
                    → 자세 게이지 +100 (즉시 파쇄!)
```

```gdscript
# ChainParrySystem.gd
var chain_count: int = 0
var chain_bonus_multiplier: float = 1.0

func on_perfect_parry_in_chain():
    chain_count += 1
    chain_bonus_multiplier = 1.0 + (chain_count * 0.3)  # 체인당 +30%

    match chain_count:
        1: HUD.show_chain_text("체인 1!", Color.WHITE)
        2: HUD.show_chain_text("체인 2!", Color.YELLOW)
        3: HUD.show_chain_text("체인 3!", Color.ORANGE)
        _: HUD.show_chain_text("체인 %d!" % chain_count, Color.RED)

func on_chain_complete(total_chain: int):
    # 체인 완성 보상
    var counter_damage = base_counter_damage * chain_bonus_multiplier
    CombatManager.deal_damage(counter_damage, "체인 카운터!")

    # 화면 효과
    VFXManager.play("chain_counter_explosion")
    CameraManager.dramatic_shake(0.5)

    # 특별 보상 (3연 이상)
    if total_chain >= 3:
        CombatManager.draw_card(1)  # 보너스 카드 드로우
        EnergyManager.add_energy(1)  # 에너지 +1

func on_chain_broken():
    # 체인 끊김 페널티 없음 (다음 공격부터 새 체인)
    chain_count = 0
    chain_bonus_multiplier = 1.0
```

---

## 💔 시스템 4: 몬스터 자세 게이지 (Posture / Break System)

Sekiro의 **자세(Posture)** + Expedition 33의 **브레이크 게이지**를 카드 ATB에 적용.

### 4.1 자세 게이지 구조

```
[몬스터 HP 바 하단]

HP:  ████████████░░ 85/100
자세: ████░░░░░░░░░ 35/100   ← 자세 게이지
      ↑ 패링/공격 시 누적
```

### 4.2 자세 게이지 충전 방법

| 행동 | 자세 충전량 |
|------|----------|
| 완전 패링 성공 | +40 |
| 반응 카드 사용 | +20 |
| 긴급 가드 | +5 |
| 공격 카드 (일반) | +8 |
| 공격 카드 (관통 속성) | +20 (자세 특화) |
| 피해 받음 | -10 (자세 회복) |
| 몬스터 방어 사용 | -15 (자세 회복) |

### 4.3 자세 파쇄 (Posture Break) — "꿈의 파쇄"

자세 게이지 100 도달 시:

```
★ "꿈의 파쇄!" 연출

1. 몬스터 화면 중앙으로 줌인
2. 크랙 이펙트 (몬스터 전신 균열)
3. 몬스터 "파쇄됨" 상태 진입 (3초)
4. 파쇄 윈도우 UI 표시:
   ┌────────────────────────────────┐
   │  💥 파쇄 상태! 3초간 취약!     │
   │  이 시간 동안 모든 카드 +50%!  │
   └────────────────────────────────┘
```

```gdscript
# PostureSystem.gd
class_name PostureSystem

var current_posture: float = 0.0
const MAX_POSTURE = 100.0
const BREAK_DURATION = 3.0
const POSTURE_REGEN_RATE = 5.0  # 초당 자연 회복

var is_broken: bool = false
var break_timer: float = 0.0

func add_posture(amount: float, source: String):
    if is_broken:
        return  # 파쇄 중엔 추가 불필요

    current_posture = min(MAX_POSTURE, current_posture + amount)
    _update_posture_bar()

    if current_posture >= MAX_POSTURE:
        _trigger_posture_break()

func _trigger_posture_break():
    is_broken = true
    break_timer = BREAK_DURATION
    current_posture = 0.0

    # 몬스터 파쇄 상태
    monster.apply_status("파쇄됨", BREAK_DURATION)
    monster.set_damage_multiplier(1.5)  # 모든 피해 +50%

    # 연출
    CameraManager.zoom_to_monster(0.5)
    VFXManager.play("posture_break_crack")
    SoundManager.play("glass_shatter")
    HUD.show_break_ui(BREAK_DURATION)

func _process(delta):
    if is_broken:
        break_timer -= delta
        if break_timer <= 0:
            _exit_break_state()
    elif current_posture > 0:
        # 자연 회복 (파쇄 쿨타임 없이 바로)
        current_posture = max(0, current_posture - POSTURE_REGEN_RATE * delta)
        _update_posture_bar()
```

---

## 🎯 시스템 5: 3단계 공격 예고 연출 (Attack Tell System)

소울류 게임처럼 공격 직전 **시각+청각 신호**로 타이밍을 알려준다.
Expedition 33에서도 "음시각 큐(audiovisual cue)"를 통해 패링 타이밍을 알린다.

### 5.1 3단계 예고 시퀀스

```
─────────────────────────────────────────────────────────
시간:  -2.0초        -0.8초       -0.4초      0초 (임팩트)
─────────────────────────────────────────────────────────
Phase: [WINDUP]     [WARNING]    [FLASH]      [IMPACT]
       예비 동작    경보 단계    임팩트 직전   충돌
─────────────────────────────────────────────────────────
시각:  노란 글로우   빨간 진동    흰 번쩍임    이펙트 폭발
       아이콘 표시   ⚡텍스트     패링 UI 강조  데미지/패링
─────────────────────────────────────────────────────────
청각:  낮은 으르렁   긴장 사운드  쇳소리 예비  공격음
─────────────────────────────────────────────────────────
플레이어:            자세 확인   ★패링 탭!!   결과 판정
─────────────────────────────────────────────────────────
```

### 5.2 공격 유형별 예고 시각화

Expedition 33처럼 **공격 유형마다 다른 시각 신호** 사용:

| 공격 유형 | 예고 색상 | 특수 표시 | 대응 |
|---------|---------|---------|------|
| 일반 공격 | 🟡 노란 글로우 | ⚔️ 아이콘 + 데미지 숫자 | 패링 or 반응 카드 |
| 강한 공격 | 🔴 빨간 진동 | ⚠️ + 데미지 × 2.0 | 반드시 반응 필요 |
| 광역 공격 | 🟠 주황 원형파 | 🌀 전체 표시 | 꿈의 방어막 카드 |
| 관통 공격 | 🟣 보라 화살 | 🔱 "방어 불가!" | 회피만 가능 |
| 그라디언트 (보스) | ⚪ 흑백 화면 | 특수 연출 | 그라디언트 카운터 |

### 5.3 관통 공격 (Unblockable) — 회피 전용

Expedition 33의 **점프 회피**처럼, 일부 공격은 패링이 불가하고 **특수 카드**만 통함:

```
[관통 공격 예고]
🔱 "이 공격은 방어할 수 없다!"
━━━━━━━━━━━━━━━━━━━━━━━━

손패에서 [회피] 유형 카드만 하이라이트됨
  ★[꿈의 도약] → 피해 무효 + 반격 가능
   [꿈의 방패] → 희미하게 표시 (사용 불가)
```

```gdscript
# AttackTellSystem.gd
class_name AttackTellSystem

enum AttackType {
    NORMAL,      # 일반 공격: 패링/반응 모두 가능
    HEAVY,       # 강한 공격: 반응 필수
    AOE,         # 광역: 꿈의 방어막 필요
    UNBLOCKABLE, # 관통: 회피 카드만 가능
    GRADIENT     # 그라디언트: 특수 카운터
}

func announce_attack(monster: Monster, attack: AttackData):
    match attack.type:
        AttackType.NORMAL:
            _show_normal_tell(attack)
        AttackType.HEAVY:
            _show_heavy_tell(attack)
        AttackType.AOE:
            _show_aoe_tell(attack)
        AttackType.UNBLOCKABLE:
            _show_unblockable_tell(attack)
        AttackType.GRADIENT:
            _show_gradient_tell(attack)

func _show_heavy_tell(attack: AttackData):
    # 빨간 진동 + ⚠️
    MonsterUI.glow(monster, Color.RED, intensity=2.0)
    MonsterUI.shake(monster, frequency=20, amplitude=5.0)
    HUD.show_danger_text("⚠️ 강한 공격!")
    HUD.show_damage_preview(attack.damage, Color.RED)
    CombatManager.trigger_crisis("HEAVY_ATTACK_INCOMING")

func _show_unblockable_tell(attack: AttackData):
    # 보라 화살 + "방어 불가!" + 패링 카드 비활성화
    MonsterUI.glow(monster, Color.PURPLE, intensity=1.5)
    HUD.show_danger_text("🔱 방어 불가!")
    HandUI.disable_parry_cards()         # 패링 카드 회색 처리
    HandUI.highlight_dodge_cards()       # 회피 카드만 강조

func _show_gradient_tell(attack: AttackData):
    # Expedition 33 오마주: 흑백 화면 전환
    PostProcessing.apply_monochrome(0.5)  # 0.5초 흑백
    HUD.show_special_text("꿈의 그라디언트!", Color.WHITE)
    HandUI.highlight_gradient_counter_card()
```

---

## 🌑 시스템 6: 그라디언트 카운터 (Gradient Counter)

Expedition 33의 **그라디언트 공격 카운터** 오마주.
보스의 특수 기술에만 등장하는 최고난이도 반응 기회.

### 6.1 그라디언트 공격 발동

```
[보스: 황혼의 지배자 — "황혼의 그라디언트"]

화면이 흑백으로 전환됨...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   꿈의 그라디언트를 카운터하라!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
★[그라디언트 카운터] 카드 전용 1.5초 윈도우
```

### 6.2 그라디언트 카운터 결과

```
[성공 시] 화면 컬러 복구 + 보스에게 엄청난 반격
  → 보스 자세 게이지 즉시 100 (파쇄!)
  → 특수 컷신 연출 (보스가 뒤로 날아감)
  → 에너지 3 완충

[실패 시] 전체 HP의 40% 피해
  → 위기 개입 자동 발동
```

```gdscript
# GradientCounterSystem.gd
const GRADIENT_WINDOW = 1.5  # 넉넉한 윈도우 (성공 쾌감 보장)

func trigger_gradient_attack(boss: Boss, attack: AttackData):
    PostProcessing.set_monochrome(true)
    HUD.show_gradient_ui()
    HandUI.show_only_gradient_counter_card()

    # 1.5초 카운터 윈도우
    var result = await _wait_for_input(GRADIENT_WINDOW)

    PostProcessing.set_monochrome(false)

    if result == "SUCCESS":
        _gradient_counter_success(boss)
    else:
        _gradient_counter_fail(attack)

func _gradient_counter_success(boss: Boss):
    # 특별 컷신
    CameraManager.cinematic_zoom(boss, 1.0)
    VFXManager.play("gradient_counter_explosion")
    SoundManager.play("gradient_counter_sfx")

    # 보상
    PostureSystem.break_immediately(boss)
    EnergyManager.set_energy_to_max()
    HUD.show_counter_text("완벽한 그라디언트 카운터!", Color.GOLD)
```

---

## 🧩 업그레이드된 몬스터 의도 시스템 (v3.0)

v2.0의 단순 아이콘 표시에서 → **동적 3단계 예고 + 공격 패턴 데이터** 시스템으로 확장.

### 6.1 의도 표시 구조

```
[몬스터 HP + 의도 표시 영역]

꿈의 악몽 (보스)
HP:  ████████░░ 78%
자세: ██████░░░░ 58%    ← v3.0 신규
━━━━━━━━━━━━━━━━━━━━━━━
다음 행동: [⚔️ 22] [🛡️] [⚔️ 40 광역]
           ↑현재   ↑예정1  ↑예정2
           진행 중  (다음)  (그 다음)
```

v3.0에서 **다음 2~3행동까지 예고**:

```gdscript
# MonsterIntentV3.gd
class_name MonsterIntentV3

var action_queue: Array[AttackData] = []  # 앞으로 할 행동 목록

func get_upcoming_actions(count: int = 3) -> Array[AttackData]:
    return action_queue.slice(0, count)

func display_intent_ui():
    var upcoming = get_upcoming_actions(3)
    IntentUI.clear()

    for i in range(upcoming.size()):
        var action = upcoming[i]
        var is_current = (i == 0)

        IntentUI.add_intent_slot(
            icon = _get_icon(action),
            value = action.damage if action.is_attack else 0,
            is_current = is_current,
            attack_type = action.type,  # NORMAL/HEAVY/AOE/UNBLOCKABLE/GRADIENT
            highlight = is_current and action.type != AttackType.NORMAL
        )
```

### 6.2 패턴 기억 시스템 (소울류 오마주)

소울류처럼 **같은 몬스터를 반복 처치할수록 패턴이 선명하게 표시**:

```gdscript
# MonsterMemorySystem.gd
# 같은 몬스터를 처치할수록 의도 예고가 더 이른 시점에 표시됨

func get_tell_advance_time(monster_id: String) -> float:
    var kill_count = PlayerProgress.get_kill_count(monster_id)

    match kill_count:
        0:   return 0.8   # 첫 만남: 경보 0.8초 전 표시
        1, 2: return 1.0  # 1~2번 처치: 1.0초 전
        3, 4: return 1.3  # 3~4번: 1.3초 전
        _:   return 1.5   # 5번 이상: 1.5초 전 (패턴 완전 파악)

func get_hint_text(monster_id: String, action: AttackData) -> String:
    var kill_count = PlayerProgress.get_kill_count(monster_id)
    if kill_count >= 3 and action.type == AttackType.GRADIENT:
        return "💡 이 공격은 그라디언트 카운터로 반격할 수 있다!"
    return ""
```

---

## 🎮 전체 전투 흐름 (v3.0 통합)

```
[전투 시작]
    │
    ▼
[몬스터 의도 표시 — v3.0]
  • 다음 2~3행동 미리 표시
  • 공격 유형 아이콘 (일반/강/광역/관통/그라디언트)
  • 자세 게이지 표시
    │
    ▼
[ATB 실시간 진행]
    │
    ├── 몬스터 공격 예고 시작:
    │   WINDUP (-2.0초): 노란 글로우
    │   WARNING (-0.8초): 빨간 진동 + "⚡위험!"
    │   FLASH (-0.4초): 흰 번쩍임 + 황금 테두리 패링 카드
    │
    ├── 플레이어 반응:
    │   ★ [완전 패링] 0.4초 이내 → 무효 + 반격 카드 제시
    │     └─ 체인 공격이면 → 체인 카운터 누적
    │     └─ 자세 게이지 +40 → 파쇄 여부 확인
    │   ★ [반응 카드] 1.2초 이내 → 50~100% 감소
    │     └─ 자세 게이지 +20
    │   ★ [긴급 가드] 2.0초 이내 → 30% 감소
    │     └─ 에너지 -1
    │   ★ [미반응] → 풀 데미지
    │
    ├── 특수 공격:
    │   관통 → 패링 불가, 회피 카드만 유효
    │   그라디언트 → 흑백 화면, 그라디언트 카운터 카드
    │
    ├── 자세 게이지 100 도달 → "꿈의 파쇄!" 3초 취약
    │
    └── [패링 카운터 후] 반격 카드 발동 → 콤보 연계 가능
                                                │
                                                ▼
                                        드림 콤보 시스템 연계
```

---

## ⚙️ 핵심 수치 요약

| 항목 | 수치 |
|------|------|
| 완전 패링 윈도우 | 0.4초 |
| 반응 카드 윈도우 | 1.2초 |
| 긴급 가드 윈도우 | 2.0초 |
| 완전 패링 → 자세 충전 | +40 |
| 반응 카드 → 자세 충전 | +20 |
| 파쇄 상태 지속 | 3.0초 |
| 파쇄 중 피해 보너스 | +50% |
| 체인 카운터 보너스 | 체인당 +30% |
| 그라디언트 카운터 윈도우 | 1.5초 |
| 패턴 기억 최대 선행 표시 | 1.5초 전 |
| 자세 자연 회복 | 초당 5 |

---

## 📱 모바일 접근성

| 항목 | 조치 |
|------|------|
| 패링 윈도우 너무 짧은 문제 | Story 모드: 0.4초 → 0.7초로 확장 (Expedition 33 동일 방식) |
| 오탭 위험 | 패링 카드 터치 영역 +10px, 카드 위치 하단 고정 |
| 그라디언트 카운터 어려움 | 첫 보스전: 튜토리얼 슬로모 연출으로 타이밍 학습 |
| 체인 공격 피로감 | 최대 5연격 이내로 제한, 마지막 공격은 패링 윈도우 0.1초 확장 |
| 설정 끄기 | "완전 패링 시스템 비활성화" → 반응 카드 단일 방식으로 전환 가능 |

---

## 🚀 구현 우선순위

### 🔴 1순위 (핵심 경험)
1. 3단계 공격 예고 연출 (AttackTellSystem)
2. 완전 패링 시스템 (PerfectParrySystem)
3. 반격 카드 5종
4. 자세 게이지 UI + 파쇄 상태

### 🟠 2순위 (깊이 추가)
5. 체인 패링 & 체인 카운터
6. 관통 공격 유형 + 회피 전용 카드
7. 몬스터 다음 2~3행동 예고

### 🟡 3순위 (보스 특화)
8. 그라디언트 카운터 시스템
9. 패턴 기억 시스템
10. 광역 공격 연출

---

## 🗂️ GDScript 파일 구조

```
scripts/combat/reaction/
├── PerfectParrySystem.gd      # 완전 패링 핵심 로직
├── ChainParrySystem.gd        # 체인 패링 & 카운터
├── PostureSystem.gd           # 자세 게이지 & 파쇄
├── AttackTellSystem.gd        # 3단계 공격 예고
├── GradientCounterSystem.gd   # 그라디언트 카운터
├── MonsterIntentV3.gd         # 의도 시스템 v3.0
├── MonsterMemorySystem.gd     # 패턴 기억
└── ReactionCardManager.gd     # 반응/패링 카드 통합 관리
```

---

**참고 자료**:
- [Clair Obscur: Expedition 33 — TGA 2025 올해의 게임](https://www.keengamer.com/articles/guides/clair-obscur-expedition-33-ultimate-combat-mechanics-guide-parrying-ap-management-and-stamina-control/)
- [Expedition 33 Combat Guide — TechTimes](https://www.techtimes.com/articles/313600/20251226/clair-obscur-expedition-33-combat-guide-how-battle-system-works-parry-timing-break-mechanics.htm)
- [Expedition 33 Wikipedia](https://en.wikipedia.org/wiki/Clair_Obscur:_Expedition_33)

**문서 작성**: Kim.G (게임팀장)
**작성일**: 2026-03-01
**연관 문서**: ATB_COMBAT_SYSTEM_v3.md, TURNBASED_MOBILE_SYSTEM_v1.md
**다음 단계**: Steve PM 검토 → 구현 우선순위 확정 → Cursor IDE 구현

---

**Status**: ✅ 설계 완료 — PM 검토 후 구현 착수
