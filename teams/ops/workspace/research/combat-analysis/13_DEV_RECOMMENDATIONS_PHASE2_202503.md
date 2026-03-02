# 🔧 OPS 개발 권고 리포트 — Phase 2
# DEV-REC-2026-0302-v2 | Dream Collector

**작성**: Park.O (OPS팀장) · Choi.M (밸런스분석)
**기반**: 12_GAMETEST_FULL_REPORT_202503.md
**우선순위**: P0(즉시) / P1(이번 스프린트) / P2(다음 스프린트)

---

## 🔴 P0 — 즉시 수정 (다음 빌드 전)

### P0-A. 스타터 덱 12장으로 확대 (이전 P0-3 미적용)

**파일**: `scripts/combat/shared/CardDatabase.gd`

```gdscript
func get_starter_deck() -> Array[Card]:
    var starter_ids = [
        "ATK_001", "ATK_001", "ATK_006",   # 공격 3장
        "DEF_002", "DEF_006",               # 방어 2장 (3→2장)
        "PAR_001", "PAR_001", "PAR_001",   # 패링 3장 (2→3장)
        "DOD_001", "DOD_001",               # 회피 2장 (1→2장)
        "SKL_001", "SKL_002",               # 스킬 2장 (1→2장)
    ]
```

**이유**: 현재 리액션 카드 3장(30%)으로는 신규 유저가 색상 구간 리액션 시스템을 충분히 경험하기 어렵다. 5장(42%)으로 높이면 전투당 평균 2~3회 리액션 기회가 생긴다.

---

### P0-B. 오토 모드 최후 안전망 추가

**파일**: `scripts/combat/atb/CombatManagerATB.gd`

**현재 문제**: `_try_auto_reaction()`에서 GUARD 없고 DODGE 실패 시 아무것도 하지 않아 NONE(기본 피해 100%) 처리됨. 패링 카드가 손에 있어도 오토에서는 사용 불가.

```gdscript
func _try_auto_reaction():
    var cur_energy = energy_system.get_current() if energy_system else 0
    # 1) 가드 100% 우선
    for card in hand:
        if card.has_tag("GUARD") and card.cost <= cur_energy:
            player_play_card(card)
            return
    # 2) 회피: 카드별 확률
    for card in hand:
        if card.has_tag("DODGE") and card.cost <= cur_energy:
            if randf() < card.auto_dodge_success_rate:
                player_play_card(card)
                return
    # 3) ★ 신규 추가: 방어 카드(GUARD 태그 없는 DEF)로 폴백 가드
    for card in hand:
        if card.type == "DEF" and card.cost <= cur_energy:
            player_play_card(card)
            return
    # 4) ★ 신규 추가: 에너지 1 있으면 빈 가드(에너지 소모 최소 방어)
    # reaction_mgr에 force_guard() 메서드 추가 필요
    # reaction_mgr.force_guard()
```

**TB 동일 적용**: `TurnBasedAutoAI.decide_defense()`에도 동일한 폴백 로직 추가.

---

### P0-C. PAR_003 카드 설명 수정

**파일**: `scripts/combat/shared/CardDatabase.gd`

```gdscript
# 현재
"[패링] 0.3초의 좁은 윈도우. 성공 시 에너지 +3."

# 수정
"[패링] 빨간 구간(0.4초/Story)의 패링 전용 카드. 성공 시 에너지 +3."
```

**이유**: 실제 구현된 0.4초 빨간 구간과 카드 설명 불일치. 플레이어 혼란 유발.

---

## 🟡 P1 — 이번 스프린트 (1~2주 내)

### P1-1. 오토 회피 실패 시 방어 카드 폴백 + 확률 최적화

**현재**: `_try_auto_reaction()`이 손패 배열 순서대로 첫 번째 DODGE 카드를 시도하고 실패하면 끝.

**개선**: 에너지 효율 기준으로 정렬 후 성공률이 높은 카드부터 시도.

```gdscript
func _try_auto_reaction():
    var cur_energy = energy_system.get_current() if energy_system else 0

    # 1) 가드 우선 (비용 낮은 것 먼저)
    var guard_cards = hand.filter(func(c): return c.has_tag("GUARD") and c.cost <= cur_energy)
    guard_cards.sort_custom(func(a, b): return a.cost < b.cost)
    if not guard_cards.is_empty():
        player_play_card(guard_cards[0])
        return

    # 2) 회피: 성공률 높은 것 먼저, 모두 시도
    var dodge_cards = hand.filter(func(c): return c.has_tag("DODGE") and c.cost <= cur_energy)
    dodge_cards.sort_custom(func(a, b): return a.auto_dodge_success_rate > b.auto_dodge_success_rate)
    for card in dodge_cards:
        if randf() < card.auto_dodge_success_rate:
            player_play_card(card)
            return

    # 3) DEF 카드 폴백 (블록값 높은 것 먼저)
    var def_cards = hand.filter(func(c): return c.type == "DEF" and c.cost <= cur_energy)
    def_cards.sort_custom(func(a, b): return a.block > b.block)
    if not def_cards.is_empty():
        player_play_card(def_cards[0])
        return
```

---

### P1-2. 패링 실패 페널티 완화 (신규 유저 보호)

**현재**: 패링 실패 = 피해 +50% + 적 ATB 50% 가속

**개선안**: Story 모드에서 페널티 분리 적용

```gdscript
# ATBReactionManager.gd 또는 CombatManagerATB.gd
const PARRY_FAIL_DMG_MULT_STORY : float = 1.25   # 1.5 → 1.25 (Story)
const PARRY_FAIL_DMG_MULT_HARD  : float = 1.5    # Hard는 유지
const PARRY_FAIL_ATB_BOOST_STORY : float = 0.25  # 0.5 → 0.25 (Story)
const PARRY_FAIL_ATB_BOOST_HARD  : float = 0.5   # Hard는 유지
```

**이유**: Story 모드는 신규 유저 경험 최우선. 패링 실패의 극단적 페널티가 리액션 시도 기피로 이어진다. 실패해도 "다시 시도해야겠다"는 의욕이 생기는 수준으로 조정.

---

### P1-3. 리액션 시스템 튜토리얼 (첫 번째 전투)

**신규 시스템** — 첫 전투 시 화면 오버레이 안내

```
[첫 번째 전투 튜토리얼 흐름]
1. "! 아이콘이 보이면 적이 공격을 준비합니다" → 화살표로 ! 아이콘 가리킴
2. "녹색: 가드 가능 → 노란색: 회피 가능 → 빨간색: 패링 가능!" → 색상 구간 강조
3. 하단 리액션 버튼 강조 → "이 버튼을 눌러보세요"
4. 첫 번째 리액션 성공 시 축하 연출
```

**구현 제안**: `InRun_v4.gd`에 `_tutorial_step` 변수 추가, `SaveSystem.get_stat("battles_won") == 0`일 때 활성화.

---

### P1-4. 오토 모드 메뉴얼 전환 유도 UI

**현재**: 오토 모드로 전투하면 패링 카드에 ✕가 표시되지만 전환 유도가 없음.

**개선**: 오토 모드에서 패링 카드 ✕를 탭하면 힌트 팝업 표시.

```
"패링은 수동 모드에서만 사용 가능합니다.
수동 모드로 전환하면 더 강력한 리액션이 가능해요! [전환하기]"
```

**효과**: 오토에서 메뉴얼로의 자연스러운 전환 유도 → 장기적으로 더 깊은 게임플레이 경험.

---

### P1-5. 리액션 버튼 아이콘 추가

**현재**: 리액션 버튼에 텍스트("패링" / "회피" / "가드")만 표시.

**개선**: 텍스트 + 아이콘 조합

| 리액션 | 아이콘 제안 | 색상 |
|--------|-----------|------|
| 패링 | 🥋 또는 ⚡ | 빨강 (빨간 구간과 매칭) |
| 회피 | 🌀 또는 → | 노랑 (노란 구간과 매칭) |
| 가드 | 🛡️ | 초록 (언제나 가능) |

---

## 🟢 P2 — 다음 스프린트 (3~4주 내)

### P2-1. 오토 모드 성공률 재조정

**현재 문제**: 모든 회피 카드 50~60% → 장기전에서 누적 실패로 과도한 피해 발생.

**제안 조정**: 일반전(ATB)과 보스전(TB) 구분

| 카드 | 현재 | 제안(ATB) | 제안(TB) |
|------|------|----------|---------|
| DOD_001 꿈의 스텝 | 50% | 55% | 60% |
| DOD_002 잔상 | 55% | 58% | 65% |
| DOD_003 황혼의 도약 | 60% | 62% | 70% |
| DOD_004 연막(비용1) | 50% | 55% | 60% |
| DOD_005 반보 앞으로 | 45% | 48% | 55% |

**이유**: 보스전에서 에너지 무소모 리액션임에도 실패 확률이 높으면 오토 보스전이 너무 가혹해진다. 일반전 대비 보스전 성공률 +5~10%p 버프 권고.

---

### P2-2. 패링 연속 성공 제한 (패링 루프 방지)

**잠재적 문제**: 패링 성공 시 `enemy.atb = -ATB_MAX` → 적이 크게 느려짐. PAR_001 × 3장 + 에너지+2 보상 = 패링 연속 성공 가능. 장기적으로 패링 5장 덱에서 무한 패링 루프가 가능해질 수 있다.

**제안**: 동일 몬스터 연속 패링 성공 시 ATB 롤백 감소

```gdscript
# CombatManagerATB.gd
var parry_streak_count : Dictionary = {}  # {enemy_id: consecutive_parries}

# 패링 성공 시
var streak = parry_streak_count.get(enemy.id, 0)
var atb_rollback = -ATB_MAX * max(0.25, 1.0 - streak * 0.25)  # 연속할수록 감소
enemy.atb = atb_rollback
parry_streak_count[enemy.id] = streak + 1

# 몬스터 공격 발동 시 스트릭 리셋
parry_streak_count[enemy.id] = 0
```

**효과**: 1회 패링: -ATB_MAX (100%), 2회: -0.75 ATB_MAX (75%), 3회: -0.5 ATB_MAX (50%), 4회+: -0.25 ATB_MAX (25%).

---

### P2-3. 덱 빌딩 방향성 UI (보스전 덱 패시브 안내)

**현재**: 덱 패시브 4종(달의 기사, 검의 달인, 타로 학자, 달빛 반격사)이 존재하지만 스타터 덱에서는 어떤 패시브도 활성화되지 않는다. 플레이어가 존재를 인지하지 못할 가능성이 높다.

**제안**: 보스전 시작 전 "덱 패시브 확인" 화면 추가

```
[현재 덱 패시브 상태]
• 달의 기사: DEF 2/5장 (비활성) → 3장 더 필요
• 검의 달인: ATK 3/7장 (비활성) → 4장 더 필요
• 달빛 반격사: PARRY 3/4장 → 1장 더!  ← 하이라이트
```

**효과**: 덱 빌딩에 방향성을 부여하고 PARRY 카드 수집 동기를 유발.

---

### P2-4. 보스전 타로 에너지 접근성 개선

**현재 문제**: 타로 에너지는 주요 아르카나(MAJOR_ARCANA) 카드 사용 시 충전되지만, 스타터 덱에는 아르카나 카드가 없다. 게임 초반에 핵심 시스템이 숨겨진다.

**제안**: 스타터 덱에 MAJOR_ARCANA 카드 1장 추가 (SKL_002 대체 또는 추가)

또는 보스전 시작 시 타로 에너지 1 제공 (타로 학자 패시브 미보유 시에도).

---

### P2-5. 멀티 몬스터 리액션 UI 개선

**현재 문제**: 다중 적이 동시에 ATB를 채울 경우 어느 몬스터의 공격에 리액션하는지 명확하지 않을 수 있다.

**제안**: 리액션 버튼 위에 "(몬스터명)의 공격" 텍스트 표시 (이미 로그에는 있음).

```gdscript
# CombatBottomUI.gd
func _on_reaction_window_opened(attack: AttackData) -> void:
    _reaction_attacker_label.text = "%s의 공격!" % attack.attacker.display_name
    _reaction_attacker_label.visible = true
```

---

## 📊 밸런스 시뮬레이션 요약

### 메뉴얼 vs 오토 예상 생존력 (적 ATK 10, 전투 10회)

| 전략 | 예상 총 피해 | 에너지 회수 |
|------|------------|-----------|
| 메뉴얼 패링 100% 성공 | 0 | +20 에너지 (패링10회×+2) |
| 메뉴얼 패링 70% 성공 | 15 (실패3회×+50%) | +14 에너지 |
| 오토 가드 (DEF_002) | 20 (블록8 × 10회 = 80 경감, 잔여) | 0 |
| 오토 회피 50% | 50 (실패5회×10) | +5 에너지 (성공5회×+1) |
| 무반응 (NONE) | 100 | 0 |

**결론**: 메뉴얼 패링이 압도적으로 유리. 오토 가드가 안정적인 차선책. 오토 회피는 장기전에서 불리.

---

## 🎯 Phase 2 구현 우선순위 요약

| 우선순위 | 항목 | 예상 공수 | 효과 |
|---------|------|---------|------|
| P0-A | 스타터 덱 12장 | 15분 | 리액션 경험 즉시 개선 |
| P0-B | 오토 안전망 | 1시간 | 오토 모드 최악 케이스 방지 |
| P0-C | PAR_003 설명 수정 | 5분 | 플레이어 혼란 제거 |
| P1-1 | 오토 최적화 | 2시간 | 오토 모드 전반 품질 향상 |
| P1-2 | 패링 실패 페널티 완화(Story) | 30분 | 신규 유저 이탈 방지 |
| P1-3 | 리액션 튜토리얼 | 3시간 | 학습 곡선 단축 |
| P1-4 | 오토→메뉴얼 전환 유도 | 1시간 | 장기 참여도 향상 |
| P1-5 | 리액션 버튼 아이콘 | 1시간 | 직관성 향상 |
| P2-1 | 오토 성공률 재조정 | 30분 | 보스전 오토 밸런스 |
| P2-2 | 패링 루프 방지 | 2시간 | 장기 밸런스 보호 |
| P2-3 | 덱 패시브 안내 UI | 3시간 | 덱빌딩 참여 유도 |
| P2-4 | 타로 에너지 접근성 | 1시간 | 보스전 시스템 인지율 향상 |
| P2-5 | 멀티 몬스터 UI | 1시간 | 다중 적 상황 UX 개선 |
