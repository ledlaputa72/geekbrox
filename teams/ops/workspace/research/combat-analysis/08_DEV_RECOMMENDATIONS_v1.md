# 🔧 Dream Collector — 추가 개발 및 밸런스 개선 권고 리포트
# OPS Team | DEV-REC-2026-0302-v1

**작성**: Park.O (OPS팀장)
**기반**: 07_GAMETEST_REPORT_v1.md 테스트 결과
**우선순위**: P0(즉시) / P1(다음 스프린트) / P2(중기)

---

## 🔴 P0 — 즉시 수정 (다음 빌드 전)

### P0-1. 오토 AI 기본값 변경

**현재**: `auto_ai.set_mode(ATBAutoAI.AutoMode.FULL)` — 전투 시작 시 무조건 풀오토
**변경**: 첫 5회 전투는 `MANUAL`, 이후 플레이어 선택

```gdscript
# CombatManagerATB.gd start_combat()
var cleared_battles = SaveSystem.get_stat("battles_won", 0)
if cleared_battles < 5:
    auto_ai.set_mode(ATBAutoAI.AutoMode.MANUAL)
else:
    auto_ai.set_mode(SettingsManager.get_auto_mode())
```

**이유**: 신규 유저가 패링/회피/콤보 시스템을 경험하지 못한 채 방치게임으로 인식하는 것을 방지.

---

### P0-2. PAR_003 (각성의 쳐내기) 윈도우 조정

**현재**: 0.3초 윈도우 — 모바일 터치 지연 감안 시 사실상 불가
**변경**: Story 모드 0.5초, Hard 모드 0.3초 유지

```gdscript
# ATBReactionManager.gd
const PARRY_WINDOW_STORY_ENHANCED = 0.5  # PAR_003 전용
func open_reaction_window(attack: AttackData):
    var using_par003 = (reaction_card and reaction_card.id == "PAR_003")
    var pw = (PARRY_WINDOW_STORY_ENHANCED if story_mode else 0.3) if using_par003 else \
             (PARRY_WINDOW_STORY if story_mode else PARRY_WINDOW_HARD)
```

**이유**: 에너지 +3이라는 높은 보상이 의미 있으려면 성공 가능성이 있어야 함.

---

### P0-3. 스타터 덱 리액션 비중 상향

**현재 (10장)**: 패링 2장(20%), 회피 1장(10%)
**변경 (12장)**: 패링 3장(25%), 회피 2장(17%)

```gdscript
# CardDatabase.gd get_starter_deck()
var starter_ids = [
    "ATK_001", "ATK_001", "ATK_006",   # 공격 3장
    "DEF_002", "DEF_006",               # 방어 2장 (3→2)
    "PAR_001", "PAR_001", "PAR_001",    # 패링 3장 (2→3)
    "DOD_001", "DOD_001",               # 회피 2장 (1→2)
    "SKL_001", "SKL_001",               # 스킬 2장 (1→2)
]
```

**이유**: 보스전 손패 5장에서 리액션 카드 0장 턴 빈도를 줄여 핵심 시스템 경험 보장.

---

## 🟡 P1 — 다음 스프린트 (1~2주)

### P1-1. 전투 튜토리얼 시스템

신규 유저의 첫 전투를 가이드하는 최소한의 튜토리얼. 풀 튜토리얼이 아닌 "첫 번째 패링 성공 유도" 수준.

**구현 제안**:
```
첫 전투 전용 씬 (TutorialBattle)
1. 느린 슬라임 (spd 40) 등장
2. 슬라임 ATB 70% → 손패 패링 카드에 큰 화살표 + "탭하세요!" 텍스트
3. 패링 성공 → "패링 성공! 에너지 +2를 받았습니다" 팝업
4. 에너지로 공격 카드 사용 → "방어하면 더 강하게 공격할 수 있어요!"
5. 튜토리얼 전투 승리 → 일반 전투 진입
```

**파일**: `scripts/combat/TutorialBattleManager.gd` (신규)

---

### P1-2. 콤보 힌트 UI 구현

현재 `ComboHintUI.gd`는 파일만 존재, 로직 미구현 상태.

**표시 조건**:
- 공격 카드 2장 연속 사용 → "⚡ 공격 1장 더 → 연타 콤보!"
- 패링 성공 직후 → "🥊 공격 카드 → 패링 반격 콤보!"
- DEF 카드 1장 사용 → "🛡️ 방어 1장 더 → 완벽한 방어!"

**UI 위치**: 손패 상단, 작은 노란색 배너로 3초 표시 후 페이드아웃.

---

### P1-3. 의도(Intent) 2~3번째 행동 시각적 강화

**현재**: 첫 번째 행동만 강조, 2~3번째는 흐릿하게 표시
**변경**: 2번째는 70% 불투명도, 3번째는 50% 불투명도 + 작은 크기로 표시

```gdscript
# TurnBasedIntentSystem.gd display_intent()
for i in range(upcoming.size()):
    var alpha = 1.0 if i == 0 else (0.7 if i == 1 else 0.5)
    var scale = 1.0 if i == 0 else (0.85 if i == 1 else 0.7)
    IntentUI.add_slot(enemy, icon, value, color, i == 0, ..., alpha, scale)
```

---

### P1-4. 꿈 조각 획득 조건 UI 표시

**추가**: 조각 획득 시 획득 이유 표시 (0.5초 팝업)

```
패링 성공 → "◆ +1 (패링 보너스)"
같은 색 2장 연속 → "◆ +1 (콤보 연결)"
비용 합계 5+ → "◆ +1 (대형 플레이)"
```

`DreamShardSystem.gd gain_shard()` 시그널에 reason 파라미터 추가.

---

### P1-5. HEAL 상태이상 StatusEffectSystem 통합

**현재**: DEF_008(절제)의 HP 회복이 카드 직접 처리로 StatusEffectSystem 우회
**변경**: StatusEffectSystem에 HEAL 타입 추가, 일관성 있는 처리

```gdscript
# StatusEffectSystem.gd
func apply_to(target, effect_type: String, value: int):
    match effect_type:
        "HEAL":
            if "hp" in target:
                target["hp"] = min(target.get("max_hp", 200), target["hp"] + value)
        "POISON": ...
```

---

## 🟢 P2 — 중기 개발 (2~4주)

### P2-1. 카드 밸런스 수치 조정

| 카드 | 현재 | 변경 | 이유 |
|------|------|------|------|
| ATK_005 세계 | 비용 4, 공격 20, 블록 10 | 비용 5 | 가성비 과도 |
| ATK_004 탑 | 자독 3 자해 | 자독 2 자해 | 리스크 과도 |
| ATK_010 황제 | 힘 +2 영구 | 이 전투만 힘 +3 | 누적 스택 방지 |
| DEF_003 여황제 | 비용 3, 블록 18 | 비용 3, 블록 15 | 같은 비용 ATK 대비 효율 조정 |
| DOD_004 연막 | 비용 1 | 비용 0 | 꿈의 스텝과 차별화 (적 약화 효과) |
| PAR_002 반사의 순간 | 30% 확률 반격 | 확정 반격 (데미지 절반) | 확률 의존 제거 |

---

### P2-2. 몬스터 spd 밸런스 가이드라인 수립

플레이어 기본 spd 70 기준 적 spd 분류 제안:

| 티어 | spd 범위 | 유형 | 리액션 압박 |
|------|---------|------|-----------|
| 느린 적 | 40~60 | 슬라임, 드림 버블 | 패링 연습용 (여유 있음) |
| 일반 적 | 70~90 | 나이트메어 워리어 | 균형 (플레이어와 비슷) |
| 빠른 적 | 100~120 | 레이스, 섀도우 | 집중 모드 활용 권장 |
| 보스 (ATB) | 80~100 | — | 패턴 읽기 중요 |
| 보스 (TB) | — | 턴베이스 전용 | spd 없음, 의도 3행동 |

---

### P2-3. 오토 플레이 AI 꿈 조각 소비 로직 추가

```gdscript
# TurnBasedAutoAI.gd
func decide_shard_action(shards: int, player_hp_ratio: float) -> DreamShardSystem.ShardAbility:
    if shards >= 5:
        return DreamShardSystem.ShardAbility.NIGHTMARE  # 전체 약점 노출
    if shards >= 3 and player_hp_ratio < 0.4:
        return DreamShardSystem.ShardAbility.DREAM_HEAL  # HP 회복
    if shards >= 2 and current_energy == 0:
        return DreamShardSystem.ShardAbility.ENERGY_BURST  # 에너지 긴급 충전
    return -1  # 소비 안함
```

---

### P2-4. 단일 타겟 선택 UI (멀티 적 전투)

현재 `target_index`가 항상 -1(첫 번째 살아있는 적)로 고정되어 멀티 적 전투에서 타겟 선택 불가.

**제안**: 수동 모드에서 공격 카드 선택 후 적 캐릭터 탭으로 타겟 지정.
```gdscript
# InRunScene (UI)
func on_attack_card_selected(card: Card):
    if enemies.size() > 1:
        _show_target_arrows()  # 타겟 선택 화살표 표시
    else:
        combat_manager.player_play_card(card, 0)
```

---

### P2-5. 로그라이크 메타 연동 준비

현재 전투 시스템은 독립적으로 잘 구현되어 있으나 로그라이크 런 진행과의 연동 포인트 정리 필요.

**필요한 연동 인터페이스**:

```gdscript
# 전투 종료 시 GameManager에 전달해야 할 데이터
{
    "result": "WIN" | "LOSE",
    "hp_remaining": int,         # 다음 룸에 가져갈 HP
    "gold_earned": int,          # 전투 보상
    "cards_to_offer": Array,     # 카드 선택지 3장
    "battle_stats": {
        "turns_survived": int,
        "parry_count": int,
        "combo_count": int,
        "damage_taken": int,
    }
}
```

`BattleDiary.compile_report()`가 이미 일부 데이터를 수집 중이므로 확장 가능.

---

## 📋 개발 우선순위 요약

```
즉시 (이번 주):
  ✅ P0-1: 오토 AI 기본값 MANUAL (첫 5회)
  ✅ P0-2: PAR_003 Story 모드 0.5초로 조정
  ✅ P0-3: 스타터 덱 12장으로 리액션 비중 강화

다음 스프린트 (1~2주):
  🔲 P1-1: 첫 전투 튜토리얼 (패링 1회 성공 유도)
  🔲 P1-2: 콤보 힌트 UI 구현
  🔲 P1-3: 의도 2~3번째 시각적 강화
  🔲 P1-4: 꿈 조각 획득 이유 팝업
  🔲 P1-5: HEAL 상태이상 통합

중기 (2~4주):
  🔲 P2-1: 카드 밸런스 수치 조정 6종
  🔲 P2-2: 몬스터 spd 가이드라인 수립
  🔲 P2-3: AI 꿈 조각 소비 로직
  🔲 P2-4: 멀티 적 타겟 선택 UI
  🔲 P2-5: 로그라이크 메타 연동 인터페이스
```

---

**참조 리포트**: 07_GAMETEST_REPORT_v1.md
**이전 버전**: 05_PLAYTEST_ATB_REPORT.md, 06_PLAYTEST_TURNBASED_REPORT.md (설계 단계 플레이테스트)
