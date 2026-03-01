# ⚔️ ATB 전투 시스템 v3.0 — 최종 개선 설계서
# Dream Collector — Combat Design

**문서 버전**: v3.0 (OPS 리포트 QA-2026-0301-ATB-002 기반 최종 개선)
**작성일**: 2026-03-01
**작성자**: Kim.G (게임팀장)
**선행 문서**: ATB_COMBAT_SYSTEM_v2.md → OPS_TEST_REPORT_ATB_v2.md → **이 문서**
**상태**: ✅ 구현 준비 완료

> 📌 이 문서는 OPS 팀의 시뮬레이션 테스트 결과를 전면 반영한 **최종 ATB 전투 시스템 설계서**입니다.
> v2.0의 방향성(재미 지수 +42%)을 유지하면서 발견된 13개 이슈와 3개 추가 제안을 통합했습니다.

---

## 📊 버전 비교 요약

| 항목 | v1.0 | v2.0 | v3.0 (목표) |
|------|------|------|------------|
| 재미 지수 | 5.1/10 | 7.25/10 | 8.5+/10 |
| 긴장감 | ★★☆☆☆ | ★★★★☆ | ★★★★★ |
| 전략성 | ★★☆☆☆ | ★★★★☆ | ★★★★★ |
| 모바일 편의성 | ★★★★☆ | ★★★★☆ | ★★★★★ |
| 초보자 친화성 | ★★★★★ | ★★★★☆ | ★★★★★ |
| 하드코어 만족도 | ★★☆☆☆ | ★★★★☆ | ★★★★★ |

**v3.0 핵심 변화**: UX 폴리싱 + 밸런스 조정 + 3개 신규 시스템 추가

---

## 🔧 OPS 리포트 13개 수정사항 전면 반영

### ✅ 수정 #1 — 위기 자동 해제 시간: 8초 → **10초**

```gdscript
# CombatManagerATB.gd - 위기 개입 해제
const CRISIS_DURATION = 10.0  # v2.0: 8.0 → v3.0: 10.0

func _check_crisis_end():
    crisis_timer += delta
    if crisis_timer >= CRISIS_DURATION:
        _exit_crisis_mode()
        crisis_timer = 0.0
```

**이유**: OPS 테스트에서 8초는 카드를 고르기에 부족하다는 피드백 반영. 10초로 연장하면 캐주얼 유저가 여유 있게 방어 카드 선택 가능.

---

### ✅ 수정 #2 — 위기 개입 끄기 옵션 추가

**설정 메뉴** → "전투 설정" → "위기 자동 슬로우" 토글

```gdscript
# SettingsManager.gd
var crisis_auto_slow: bool = true  # 기본값: 활성화

# CombatManagerATB.gd
func _trigger_crisis(reason: String):
    if not SettingsManager.crisis_auto_slow:
        return  # 하드코어 유저: 위기 개입 스킵
    _enter_crisis_mode(reason)
```

**UX**: 설정 변경 시 "⚡ 하드코어 모드: 위기 자동 슬로우 해제됨" 알림 표시.

---

### ✅ 수정 #3 — 리액션 윈도우: 0.8초 → **1.2초**

```gdscript
# CombatManagerATB.gd
const REACTION_WINDOW = 1.2  # v2.0: 0.8 → v3.0: 1.2

func _open_reaction_window():
    reaction_active = true
    reaction_timer = 0.0
    _show_reaction_ui()  # 황금 테두리 + 진동 이펙트 (수정 #13)

func _update_reaction(delta):
    if not reaction_active:
        return
    reaction_timer += delta
    # 게이지 바: 1.2초 카운트다운 시각화
    reaction_ui.set_timer_progress(1.0 - reaction_timer / REACTION_WINDOW)
    if reaction_timer >= REACTION_WINDOW:
        _close_reaction_window()
        if auto_battle_enabled:
            _ai_reaction_card(0.7)  # AI 자동 처리 (70% 효율)
```

**이유**: 캐주얼 유저(QA-A) 성공률 40% → 75%로 향상.

---

### ✅ 수정 #4 — 집중 모드 소모: 초당 20% → **초당 10%**

```gdscript
# CombatManagerATB.gd
const FOCUS_DRAIN_RATE = 10.0   # v2.0: 20.0 → v3.0: 10.0 (% per sec)
const FOCUS_REGEN_RATE = 8.0    # v2.0: 5.0 → v3.0: 8.0 (% per 10sec)
const FOCUS_DURATION_MAX = 10.0 # v2.0: 5초 → v3.0: 10초 최대 지속

func _update_focus_mode(delta):
    if focus_active:
        focus_gauge -= FOCUS_DRAIN_RATE * delta
        if focus_gauge <= 0.0:
            _exit_focus_mode()
    else:
        # 전투 중 자동 회복
        focus_gauge = min(100.0, focus_gauge + FOCUS_REGEN_RATE * delta / 10.0)
```

**체감**: "10초 동안 느린 화면에서 카드를 고를 수 있어" → 유저 만족도 대폭 향상.

---

### ✅ 수정 #5 — 집중 모드 회복: 10초당 5% → **10초당 8%**

*(수정 #4에 통합 구현. FOCUS_REGEN_RATE = 8.0)*

**회복 시간 비교**:
- v2.0: 100% → 0% 회복에 200초 (3분 20초)
- v3.0: 100% → 0% 회복에 125초 (2분 5초) → 전투 중 1~2회 재사용 가능

---

### ✅ 수정 #6 — 집중 모드 진입: 두 손가락 꾹 → **전용 버튼**

**UI 레이아웃 변경**:
```
[화면 우측 하단]
┌─────────────────────────────┐
│                          [🌙]│  ← 집중 모드 버튼 (원형, 44px)
│                          [게│  ← 집중 모드 게이지 (원형 버튼 주변)
│  [카드1][카드2][카드3][카드4]  │
└─────────────────────────────┘
```

```gdscript
# FocusModeButton.gd
func _on_focus_button_pressed():
    if CombatManager.focus_gauge >= 20.0:  # 최소 20% 이상 보유 시 사용 가능
        CombatManager.enter_focus_mode()
    else:
        # 게이지 부족 시 버튼 진동 + "게이지 부족" 텍스트
        _show_insufficient_gauge_feedback()
```

**이유**: 두 손가락 꾹 누르기가 모바일 줌인 제스처와 충돌. 전용 버튼으로 오입력 원천 차단.

---

### ✅ 수정 #7 — 카드 터치 영역: +**10px** 확장

```gdscript
# CardUI.gd
const CARD_TOUCH_PADDING = 10  # v2.0: 0 → v3.0: +10px 사방 확장
const CARD_MIN_WIDTH = 64      # 최소 터치 영역 보장 (iOS HIG: 44pt)

func _get_effective_touch_area() -> Rect2:
    var base_rect = get_rect()
    return base_rect.grow(CARD_TOUCH_PADDING)

func _input(event: InputEvent):
    if event is InputEventScreenTouch:
        if _get_effective_touch_area().has_point(event.position):
            _on_card_tapped()
```

**이슈 해결**: 오탭 빈도 3회/20전투 → 0~1회/20전투 예상.

---

### ✅ 수정 #8 — 콤보 연타 보너스: +50% → **+75%**

```gdscript
# ComboSystem.gd
const COMBO_BONUSES = {
    "연타_공격": {
        "damage_bonus": 0.75,  # v2.0: 0.50 → v3.0: 0.75
        "vfx": "combo_triple_hit",
        "slo_mo": 0.3,         # 콤보 발동 시 0.3초 슬로모 추가 (v3.0 신규)
        "screen_shake": true   # 화면 진동 추가 (v3.0 신규)
    },
    # 다른 콤보는 유지...
}
```

**체감 강화**: 수치 상향 + 시각 효과 추가로 하드코어 유저 만족도 향상.

---

### ✅ 수정 #9 — 악몽의 폭발 발동: 3스택 → **2스택**

```gdscript
# ComboSystem.gd
const COMBO_CONDITIONS = {
    "악몽의_폭발": {
        "trigger": "중독_스택",
        "stack_required": 2,  # v2.0: 3 → v3.0: 2
        "effect": "적_최대hp_10%_추가피해",
        "cooldown": 30.0      # 30초 재발동 쿨타임 (v3.0 신규 — 너무 자주 뜨지 않도록)
    }
}
```

**빈도 예측**: 매 15전투 1회 → 매 7~8전투 1회로 적절한 빈도.

---

### ✅ 수정 #10 — 꿈의 파도 조건 완화

```gdscript
# ComboSystem.gd
const COMBO_CONDITIONS = {
    "꿈의_파도": {
        # v2.0: "광역→단일→광역" (순서 고정)
        # v3.0: "광역 + 단일 조합" (순서 무관)
        "trigger": "광역_and_단일_조합",
        "count_required": 3,  # 3장 내에 광역 1장 + 단일 1장 이상 포함
        "effect": "전체_광역_추가타",
        "combo_text": "꿈의 파도! 🌊"
    }
}
```

**빈도 예측**: 20전투 0회 → 매 4~5전투 1회.

---

### ✅ 수정 #11 — 최대 속도 상한: 3× → **2.5×**

```gdscript
# CombatManagerATB.gd
const SPEED_MAX = 2.5    # v2.0: 3.0 → v3.0: 2.5
const SPEED_MIN = 0.3    # 유지
const SPEED_STEP = 0.5   # 유지

# 속도 단계: 0.3× (집중) / 1× (기본) / 1.5× / 2× / 2.5× (최대)
const SPEED_PRESETS = [0.3, 1.0, 1.5, 2.0, 2.5]
```

**이유**: 2.5×에서도 전투 시간 36~45초로 목표 범위(45~90초) 경계선. 모바일 전투 만족감 보장.

---

### ✅ 수정 #12 — 위기 UI **3종 다양화**

```gdscript
# CrisisUI.gd
enum CrisisType {
    HP_CRITICAL,      # HP 30% 이하: 🔴 빨간 맥박 애니메이션
    STRONG_ATTACK,    # 강한 공격 예고: 🟠 주황 충격파 애니메이션
    BOSS_PHASE        # 보스 페이즈 전환: 🟣 보라 소용돌이 애니메이션
}

func show_crisis(type: CrisisType):
    match type:
        CrisisType.HP_CRITICAL:
            _play_pulse_animation(Color.RED, 1.5)
            _show_text("위험! 체력이 낮습니다!")
        CrisisType.STRONG_ATTACK:
            _play_shockwave_animation(Color.ORANGE, 1.0)
            _show_text("강력한 공격이 온다!")
        CrisisType.BOSS_PHASE:
            _play_vortex_animation(Color.PURPLE, 2.0)
            _show_text("보스가 각성했다!")

# 같은 위기 15초 내 재발 시 UI 생략 (피로감 방지)
var last_crisis_time: Dictionary = {}
func _can_show_crisis(type: CrisisType) -> bool:
    var now = Time.get_ticks_msec() / 1000.0
    if last_crisis_time.get(type, 0.0) + 15.0 > now:
        return false
    last_crisis_time[type] = now
    return true
```

---

### ✅ 수정 #13 — 리액션 카드 UX: **황금 테두리 + 진동 이펙트**

```gdscript
# CardUI.gd
func highlight_as_reaction():
    # 황금 테두리 표시
    border_shader.set_shader_parameter("border_color", Color.GOLD)
    border_shader.set_shader_parameter("border_width", 4.0)
    border_shader.set_shader_parameter("glow_strength", 2.0)

    # 진동 이펙트 (0.3초 주기)
    _tween_shake(amplitude=5.0, duration=0.3)

    # 첫 리액션 기회 시 튜토리얼 팝업
    if not TutorialManager.shown("reaction_card"):
        TutorialManager.show_tooltip(
            "반응 카드!",
            "황금 테두리 카드를 탭하면\n적의 공격을 막을 수 있어요!",
            duration=2.5
        )
        TutorialManager.mark_shown("reaction_card")
```

---

## 🆕 v3.0 신규 시스템 (OPS 팀 제안 반영)

### 🧚 신규 시스템 1: 꿈 보조자 (Dream Familiar)

**개요**: 자동전투 중 작은 요정 NPC "루미"가 등장해 전략적 카드 사용을 자연스럽게 안내.

**동작 방식**:
```
[자동전투 중]
루미 등장 → 추천 카드 가리키기 → 플레이어 수락/무시 → 세미오토 행동 실행
```

```gdscript
# DreamFamiliar.gd
class_name DreamFamiliar

var suggestion_cooldown: float = 8.0  # 8초마다 최대 1회 제안
var current_cooldown: float = 0.0

func _suggest_card(combat_state: CombatState) -> CardSuggestion:
    if current_cooldown > 0:
        return null

    var best_card = _analyze_situation(combat_state)
    if best_card == null:
        return null

    current_cooldown = suggestion_cooldown
    return CardSuggestion.new(
        card = best_card,
        reason = _get_suggestion_text(best_card, combat_state),
        urgency = _get_urgency(combat_state)  # LOW/MEDIUM/HIGH
    )

func _analyze_situation(state: CombatState) -> Card:
    # 위기 상황 (HP < 40%) → 방어/치유 카드 추천
    if state.player_hp_ratio < 0.4:
        return state.hand.find_card_by_type("DEF")
    # 적 ATB 80% 이상 → 방해 카드 추천
    if state.enemy_atb_ratio > 0.8:
        return state.hand.find_card_by_type("DEB")
    # 콤보 1장 남음 → 콤보 완성 카드 추천
    if ComboSystem.is_one_away_from_combo(state.hand):
        return ComboSystem.get_combo_completing_card(state.hand)
    return null
```

**루미 대사 예시**:
- "지금 방어 카드 어때요? 🛡️"
- "적이 곧 공격해요! 빠른 카드를 써요! ⚡"
- "이 카드로 콤보 완성이에요! ✨"

**UI**: 작은 요정이 카드 위에 떠다니며 지시. 유저가 다른 카드를 선택하면 루미가 고개를 끄덕이며 사라짐.

**설정**: "꿈 보조자 표시" 토글 (기본값: ON). 하드코어 유저는 끌 수 있음.

---

### 📖 신규 시스템 2: 전투 일지 (Battle Diary)

**개요**: 전투 종료 후 짧은 통계를 "일지" 형식으로 표시. 유저가 자신의 전투를 돌아보며 개선 욕구 유발.

**전투 종료 화면**:
```
╔══════════════════════════════╗
║  📖 오늘의 전투 일지           ║
║                              ║
║  ⚔️  전투 시간: 72초           ║
║  🃏  사용 카드: 14장            ║
║  💥  최대 콤보: 연타 3연속 ✅    ║
║  ⚡  리액션 성공: 2/3 (67%)    ║
║  🌙  집중 모드: 1회 사용        ║
║  📊  데미지 효율: 84%           ║
║                              ║
║  💡 오늘의 팁:                 ║
║  "리액션 윈도우가 1.2초예요.    ║
║   황금 테두리 카드를 노려보세요!"  ║
╚══════════════════════════════╝
     [다음 전투]  [일지 보기]
```

```gdscript
# BattleDiary.gd
class_name BattleDiary

var stats: Dictionary = {}

func record_start():
    stats.clear()
    stats["start_time"] = Time.get_ticks_msec()
    stats["cards_played"] = 0
    stats["combos_triggered"] = 0
    stats["reactions_attempted"] = 0
    stats["reactions_succeeded"] = 0
    stats["focus_uses"] = 0
    stats["total_damage"] = 0
    stats["max_possible_damage"] = 0

func compile_report() -> BattleReport:
    var duration = (Time.get_ticks_msec() - stats["start_time"]) / 1000.0
    var efficiency = 0.0
    if stats["max_possible_damage"] > 0:
        efficiency = float(stats["total_damage"]) / stats["max_possible_damage"]

    return BattleReport.new(
        duration = duration,
        cards_played = stats["cards_played"],
        best_combo = stats["best_combo_name"],
        reaction_rate = float(stats["reactions_succeeded"]) / max(1, stats["reactions_attempted"]),
        focus_uses = stats["focus_uses"],
        damage_efficiency = efficiency,
        tip = _generate_tip()  # 유저 플레이 패턴 기반 맞춤 팁
    )

func _generate_tip() -> String:
    var reaction_rate = float(stats["reactions_succeeded"]) / max(1, stats["reactions_attempted"])
    if reaction_rate < 0.5:
        return "리액션 윈도우가 1.2초예요. 황금 테두리 카드를 미리 준비해두세요!"
    if stats["combos_triggered"] == 0:
        return "연속 공격 카드 3장을 연달아 쓰면 콤보가 발동돼요! 데미지 +75%!"
    if stats["focus_uses"] == 0:
        return "우측 하단 🌙 버튼으로 집중 모드를 써보세요. 더 정확하게 카드를 고를 수 있어요!"
    return "완벽한 전투였어요! 계속 이렇게 싸워주세요! 🌟"
```

**일지 히스토리**: 최근 30전투 기록 보관. "지난 7일 평균 리액션 성공률 72%" 등 추이 확인 가능.

---

### 🔍 신규 시스템 3: 보스 약점 발견 (Boss Weakness Discovery)

**개요**: 보스에게 특정 카드 유형을 연속 사용하면 약점이 노출됨. 연구와 발견의 재미 제공.

**동작 방식**:
```
[보스 전투]
공격 카드 2회 연속 → "약점 탐색 중... (1/3)"
공격 카드 3회 연속 → "약점 발견! ⚡ 공격 카드 데미지 +25%!"
```

```gdscript
# BossWeaknessSystem.gd
class_name BossWeaknessSystem

enum WeaknessType { ATTACK, DEFENSE, DEBUFF, BUFF, NONE }

var probe_counts: Dictionary = {}  # 카드 유형별 탐색 횟수
var discovered_weakness: WeaknessType = WeaknessType.NONE
const DISCOVERY_THRESHOLD = 3  # 3회 연속 같은 유형 사용 시 약점 발견

func probe_with_card(card_type: String):
    if discovered_weakness != WeaknessType.NONE:
        return  # 이미 약점 발견됨

    # 연속 같은 유형인지 확인
    if probe_counts.get("last_type") == card_type:
        probe_counts["streak"] = probe_counts.get("streak", 0) + 1
    else:
        probe_counts["streak"] = 1
        probe_counts["last_type"] = card_type

    _show_probe_progress(probe_counts["streak"])

    if probe_counts["streak"] >= DISCOVERY_THRESHOLD:
        _discover_weakness(card_type)

func _discover_weakness(card_type: String):
    discovered_weakness = _type_to_enum(card_type)
    var bonus = 0.25  # +25% 데미지

    # 약점 발견 연출
    _play_weakness_reveal_animation()
    _show_weakness_ui(card_type, bonus)
    CombatManager.apply_weakness_bonus(card_type, bonus)

func _show_probe_progress(streak: int):
    if streak == 1:
        HUD.show_hint("약점 탐색 중... (1/3)", duration=1.5)
    elif streak == 2:
        HUD.show_hint("약점 탐색 중... (2/3) 🔍", duration=1.5)

func get_weakness_damage_multiplier(card_type: String) -> float:
    if discovered_weakness == _type_to_enum(card_type):
        return 1.25  # +25% 적용
    return 1.0
```

**보스별 숨겨진 약점 (기획)**:
| 보스 | 약점 유형 | 약점 발동 조건 |
|------|---------|-------------|
| 악몽의 수호자 | 방어 카드 약점 | 공격 3연속 후 방어 데미지 +25% |
| 꿈의 파수꾼 | 디버프 약점 | 치유 3연속 후 디버프 데미지 +25% |
| 황혼의 지배자 | 버프 약점 | 공격+방어 교차 3회 후 버프 공격 +25% |

**약점 UI**: 보스 HP 바 하단에 🔍 탐색 게이지 표시 → 발견 시 ⚡ 아이콘으로 고정.

---

## 🎮 v3.0 전체 시스템 구조도

```
[전투 시작]
    │
    ├── ATB 게이지 충전 (ATB_CHARGE_RATE = 1.0)
    │       ↓
    ├── 위기 감지 시스템 (v3.0)
    │   ├── HP < 30%: HP_CRITICAL (빨간 맥박) → 10초 슬로우
    │   ├── 강한 공격 예고: STRONG_ATTACK (주황 충격파) → 10초 슬로우
    │   └── 보스 페이즈: BOSS_PHASE (보라 소용돌이) → 10초 슬로우
    │       [같은 위기 15초 재발 시 UI 생략]
    │
    ├── 카드 플레이
    │   ├── 풀오토: AI 자동 선택 (속도 1×~2.5×)
    │   ├── 세미오토: AI 추천 + 플레이어 2~3초 확인 → 터치 영역 +10px
    │   └── 수동: 플레이어 직접 선택 + 드림 보조자 루미 조언
    │
    ├── 리액션 시스템 (v3.0)
    │   ├── 적 ATB 80% 이상: 황금 테두리 + 진동 이펙트
    │   ├── 반응 윈도우: 1.2초
    │   └── 풀오토 시: AI 자동 처리 (70% 효율)
    │
    ├── 드림 콤보 시스템 (v3.0 조정)
    │   ├── 연타: 공격 3연속 → +75% + 슬로모 0.3초
    │   ├── 악몽의 폭발: 중독 2스택 → 보스 HP 10% 추가피해
    │   ├── 꿈의 파도: 광역+단일 조합 3장 → 전체 광역 추가타
    │   └── (기타 콤보 유지)
    │
    ├── 집중 모드 (v3.0)
    │   ├── 진입: 🌙 전용 버튼 (우측 하단)
    │   ├── 소모: 초당 10% (10초 유지 가능)
    │   └── 회복: 10초당 8% (약 125초 완충)
    │
    ├── 꿈 보조자 루미 (v3.0 신규)
    │   └── 8초 쿨타임으로 상황별 카드 추천 (설정으로 끄기 가능)
    │
    ├── 보스 약점 발견 (v3.0 신규)
    │   └── 같은 카드 유형 3연속 → 약점 노출 → 해당 유형 +25%
    │
    └── 전투 종료
        ├── 전투 일지 표시 (v3.0 신규)
        │   ├── 전투 통계 (시간/콤보/리액션/효율)
        │   └── 맞춤 팁 (플레이 패턴 기반)
        └── [다음 전투]
```

---

## ⚙️ 핵심 수치 요약 (v2.0 → v3.0 변경분)

| 항목 | v2.0 | v3.0 |
|------|------|------|
| 위기 자동 해제 | 8초 | **10초** |
| 리액션 윈도우 | 0.8초 | **1.2초** |
| 집중 모드 소모 | 초당 20% | **초당 10%** |
| 집중 모드 회복 | 10초당 5% | **10초당 8%** |
| 집중 모드 최대 지속 | 5초 | **10초** |
| 집중 모드 진입 | 두 손가락 꾹 | **🌙 전용 버튼** |
| 카드 터치 영역 | 기본 | **+10px 확장** |
| 연타 콤보 보너스 | +50% | **+75%** |
| 악몽의 폭발 조건 | 중독 3스택 | **중독 2스택** |
| 꿈의 파도 조건 | 순서 고정 | **순서 무관** |
| 최대 속도 | 3× | **2.5×** |
| 위기 UI | 1종 | **3종** |
| 리액션 카드 표시 | 기본 | **황금 테두리 + 진동** |

**v3.0 신규 추가**:
- 위기 개입 끄기 옵션 (설정)
- AI 리액션 자동 처리 (70% 효율)
- 콤보 발동 슬로모 0.3초
- 꿈 보조자 루미 시스템
- 전투 일지 시스템
- 보스 약점 발견 시스템

---

## 📱 모바일 UX 최종 체크리스트

| 항목 | 기준 | 상태 |
|------|------|------|
| 터치 영역 최소 크기 | 44px (iOS HIG) | ✅ +10px 확장으로 달성 |
| 카드 간격 | 8px 이상 | ✅ 적용 |
| 집중 모드 버튼 | 44px 원형 | ✅ 전용 버튼 설계 |
| 리액션 윈도우 | 1.0초 이상 | ✅ 1.2초 |
| 위기 자동 슬로우 옵션 | 끄기 가능 | ✅ 설정 메뉴 |
| 꿈 보조자 끄기 옵션 | 끄기 가능 | ✅ 설정 메뉴 |
| 전투 목표 시간 | 45~90초 | ✅ (2.5× 기준 36~45초, 1× 기준 52~75초) |
| 위기 UI 피로감 방지 | 15초 재발 생략 | ✅ 쿨타임 적용 |
| 리액션 튜토리얼 | 첫 기회 시 팝업 | ✅ |

---

## 🚀 구현 우선순위 (Phase 3)

### 🔴 1순위 (즉시 구현 — 전투 기본 기능)
1. **수정 #3** 리액션 윈도우 1.2초
2. **수정 #4/#5** 집중 모드 소모/회복 조정
3. **수정 #6** 집중 모드 전용 버튼
4. **수정 #7** 카드 터치 영역 +10px
5. **수정 #1** 위기 해제 10초
6. **수정 #2** 위기 개입 끄기 옵션

### 🟠 2순위 (콘텐츠 완성)
7. **수정 #8/#9/#10** 콤보 밸런스 조정
8. **수정 #11** 최대 속도 2.5×
9. **수정 #12** 위기 UI 3종 다양화
10. **수정 #13** 리액션 황금 테두리

### 🟡 3순위 (폴리싱 & 신규 시스템)
11. **신규** 꿈 보조자 루미
12. **신규** 전투 일지
13. **신규** 보스 약점 발견

---

## 📋 GDScript 파일 구조 (구현 참고)

```
scripts/combat/
├── CombatManagerATB.gd      # 핵심 ATB 엔진 (수정 #1~#5, #11)
├── CrisisSystem.gd          # 위기 개입 (수정 #1~#2, #12)
├── ReactionSystem.gd        # 리액션 카드 (수정 #3, #13)
├── FocusModeSystem.gd       # 집중 모드 (수정 #4~#6)
├── ComboSystem.gd           # 드림 콤보 (수정 #8~#10)
├── CardUI.gd                # 카드 UI/UX (수정 #7, #13)
├── DreamFamiliar.gd         # 꿈 보조자 루미 (신규 시스템 1)
├── BattleDiary.gd           # 전투 일지 (신규 시스템 2)
├── BossWeaknessSystem.gd    # 보스 약점 (신규 시스템 3)
└── SettingsManager.gd       # 전투 설정 (위기 끄기, 루미 끄기)
```

---

## 🎯 목표 재미 지수 달성 경로

```
v1.0: 5.1/10 (기본 오토 전투)
  ↓ +42% (긴장감 + 전략성 추가)
v2.0: 7.25/10 (5대 신규 시스템)
  ↓ +17% (UX 폴리싱 + 밸런스 조정 + 신규 시스템)
v3.0 목표: 8.5+/10 ← 여기
```

**8.5점 달성 조건**:
- UX 오탭 거의 없음 → 집중 가능 (+0.5점 예상)
- 콤보 빈도 / 체감 강화 → 성취감 (+0.3점 예상)
- 꿈 보조자 루미 → 초보자 이탈 방지 (+0.3점 예상)
- 전투 일지 → 재플레이 욕구 (+0.2점 예상)
- 보스 약점 발견 → 발견의 재미 (+0.4점 예상)
- 밸런스 안정화 → 모든 유형 만족 (+0.3점 예상)

---

**문서 작성**: Kim.G (게임팀장)
**기반 리포트**: QA-2026-0301-ATB-002 (Park.O, OPS팀)
**작성일**: 2026-03-01
**다음 단계**: Cursor IDE → GDScript 구현 → OPS 2차 테스트
**연관 문서**: TURNBASED_MOBILE_SYSTEM_v1.md (다음 문서)

---

**Status**: ✅ 구현 준비 완료 — Cursor IDE에서 구현 시작 가능
