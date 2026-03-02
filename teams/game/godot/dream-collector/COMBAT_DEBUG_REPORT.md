# Dream Collector - 전투 시스템 디버깅 보고서

**작성일**: 2026-03-01  
**작업 범위**: 전투 시스템 전체 (ATB + 턴베이스) 버그 수정 + UI 연결  
**담당**: Cursor AI (Claude)

---

## 1. 요약 (Executive Summary)

Dream Collector 전투 시스템의 전체 코드를 분석하고, **CRITICAL 3건 / HIGH 12건 / MEDIUM 8건**의 버그를 발견 및 수정했습니다.

주요 성과:
- 전투 진입 시 **크래시 해결** (action_patterns 타입 불일치)
- **카드 덱 UI 미표시 문제 해결** (CombatBottomUI ↔ 새 전투 매니저 브릿지 구축)
- ATB/턴베이스 양쪽 시스템의 **로직 오류 23건** 일괄 수정

---

## 2. 수정된 파일 목록

### 기존 파일 수정 (Modified: 3개)

| 파일 | 변경 내용 |
|------|-----------|
| `ui/screens/InRun_v4.gd` | ATB/TB 전투 분기, 몬스터 노드 생성, CombatBottomUI 매니저 연결 |
| `ui/bottom_uis/CombatBottomUI.gd` | 새 전투 매니저 브릿지, Card→Dictionary 변환, 카드 플레이 라우팅 |
| `project.godot` | 새 autoload 등록 (UI, VFX, SFX, Haptics 등) |

### 새로 생성된 파일 (Untracked: ~50개)

#### 전투 씬
- `scenes/combat/CombatSceneATB.tscn` — ATB 전투 씬
- `scenes/combat/CombatSceneTB.tscn` — 턴베이스 전투 씬

#### 공통 전투 시스템 (`scripts/combat/shared/`)
- `Card.gd` — 카드 Resource 클래스
- `CardDatabase.gd` — 카드 DB 및 스타터 덱
- `Monster.gd` — 몬스터 클래스
- `StatusEffectSystem.gd` — 상태이상 시스템
- `BattleDiary.gd` — 전투 기록 시스템

#### ATB 전투 시스템 (`scripts/combat/atb/`)
- `CombatManagerATB.gd` — ATB 전투 중앙 관리자
- `ATBEnergySystem.gd` — 실시간 에너지 자동 회복
- `ATBComboSystem.gd` — 콤보 감지/보너스
- `ATBCrisisMode.gd` — 위기 모드 (HP 임계)
- `ATBFocusMode.gd` — 집중 모드 (시간 감속)
- `ATBIntentSystem.gd` — 적 의도 표시
- `ATBReactionManager.gd` — 리액션 윈도우 (패링/회피/방어)
- `ATBAutoAI.gd` — 자동 전투 AI

#### 턴베이스 전투 시스템 (`scripts/combat/turnbased/`)
- `CombatManagerTB.gd` — 턴베이스 중앙 관리자
- `TurnBasedEnergySystem.gd` — 턴당 에너지
- `TurnBasedHandSystem.gd` — 덱/손패/버림더미 관리
- `TurnBasedIntentSystem.gd` — 적 의도 표시
- `TurnBasedReactionManager.gd` — 적 턴 리액션 윈도우
- `TurnBasedAutoAI.gd` — 자동 전투 AI
- `TarotEnergySystem.gd` — 타로 에너지 (보스 고유)
- `DreamShardSystem.gd` — 꿈 조각 시스템
- `DeckPassiveCalculator.gd` — 덱 구성 패시브

#### Autoload UI 스텁 (`scripts/autoloads/`)
- `HandUI.gd`, `IntentUI.gd`, `FocusUI.gd`, `CrisisUI.gd`
- `ComboHintUI.gd`, `UI.gd`, `VFX.gd`, `SFX.gd`, `Haptics.gd`
- `SettingsManager.gd`

---

## 3. 버그 수정 상세

### CRITICAL (크래시/게임 불가) — 3건

#### C1. 전투 진입 크래시 — `action_patterns` 타입 불일치
- **파일**: `InRun_v4.gd` (`_create_test_monster_nodes`)
- **증상**: 전투 화면 진입 시 즉시 크래시
- **원인**: `Monster.action_patterns`는 `Array[Dictionary]` 타입인데, 코드에서 일반 `Array` 리터럴(`[{...}, {...}]`)을 직접 대입 → Godot 4.x 타입 안전성 위반
- **수정**: `Array[Dictionary]` 변수 선언 후 `.assign()` 메서드로 타입 변환

```gdscript
# Before (크래시)
boss.action_patterns = [{"type": "NORMAL", "damage_mult": 1.0}]

# After (정상)
var boss_patterns: Array[Dictionary] = []
boss_patterns.assign([{"type": "NORMAL", "damage_mult": 1.0}])
boss.action_patterns = boss_patterns
```

#### C2. 카드 덱 UI 미표시
- **파일**: `CombatBottomUI.gd`, `InRun_v4.gd`
- **증상**: 전투 진입 후 카드가 전혀 보이지 않음 (로그 + 버튼만 표시)
- **원인**: `CombatBottomUI`가 기존 `CombatManager`/`DeckManager` autoload에만 연결되어 있고, 새 `CombatManagerATB`/`CombatManagerTB`의 `hand_updated` 시그널을 수신하지 않음
- **수정**: 
  - `CombatBottomUI`에 `connect_combat_manager(manager)` 브릿지 메서드 추가
  - `Card` Resource → `Dictionary` 변환 로직 (`_card_to_dict()`)
  - 카드 타입 매핑: `ATK→Attack`, `DEF→Defense`, `SKILL→Skill`, `POWER→Power`
  - 카드 사용/에너지/덱 카운트/버튼 모두 새 매니저에 라우팅
  - `InRun_v4`에서 ATB/TB 매니저 생성 후 `connect_combat_manager()` 호출

#### C3. Monster.get_action_queue() 0으로 나누기 크래시
- **파일**: `Monster.gd`
- **증상**: `action_patterns`가 비어있을 때 `% action_patterns.size()` → 0으로 나누기
- **수정**: `action_patterns.is_empty()` 체크 후 기본 NORMAL 패턴 반환

### HIGH (로직 오류) — 12건

| # | 파일 | 버그 | 수정 |
|---|------|------|------|
| H1 | `CombatManagerATB.gd` | 콤보 등록이 카드 효과 해결 후 실행되어 콤보 미적용 | `register_card()` → `_resolve_card_effect()` 순서로 변경 |
| H2 | `CombatManagerATB.gd` | 모든 ATK 카드가 AoE로 동작 | `card.has_tag("AOE")` 체크 추가, 단일 대상은 첫 생존 적만 |
| H3 | `CombatManagerTB.gd` | 동일 (모든 ATK가 AoE) | 동일 수정 |
| H4 | `ATBCrisisMode.gd` | `player_entity` Dict에 `has_method("hp_ratio")` 호출 → 항상 false | Dict 키 기반 HP 비율 계산으로 변경 |
| H5 | `ATBCrisisMode.gd` | `SettingsManager` null 가드 없음 | `has_node("/root/SettingsManager")` 체크 추가 |
| H6 | `ATBFocusMode.gd` | `focus_remaining` 소진 속도가 1초 미만 | `delta * (1.0/FOCUS_SPEED)` → `delta`로 수정 |
| H7 | `ATBCrisisMode.gd` / `ATBFocusMode.gd` | 비활성화 시 상대방 속도 무시 | 크로스체크 후 적절한 speed 복원 |
| H8 | `ATBReactionManager.gd` | `_process` + `create_timer` 이중 타이머 비동기 | `create_timer` 제거, `_process` 단일화 |
| H9 | `StatusEffectSystem.gd` | VULNERABLE/WEAK 효과가 감소하지 않음 | `tick_turn()`에 감소 로직 추가 |
| H10 | `CombatManagerTB.gd` | 타로 스킬 후 `_check_battle_end()` 미호출 | 데미지 스킬 후 체크 추가 |
| H11 | `CombatManagerTB.gd` | `await` 후 `combat_active` 가드 없음 | 가드 삽입 |
| H12 | `TurnBasedAutoAI.gd` | 같은 카드 중복 선택 가능 | `not selected.has(card)` 체크 추가 |

### MEDIUM (통계/일관성) — 8건

| # | 파일 | 버그 | 수정 |
|---|------|------|------|
| M1 | `CombatManagerATB.gd` / `CombatManagerTB.gd` | GUARD/NONE에 `record_parry(false)` 호출 → 패링률 왜곡 | 해당 분기에서 `record_parry` 제거 |
| M2 | `ATBIntentSystem.gd` | 적 ATB≥95% 시 `print()` 스팸 | print 제거 |
| M3 | `ATBIntentSystem.gd` / `TurnBasedIntentSystem.gd` | 의도 데미지에 `atk_bonus` 미반영 | `enemy.atk_bonus` 포함 |
| M4 | `Monster.gd` | `get_next_damage()`에 `atk_bonus` 미포함 | 포함 |
| M5 | `DreamShardSystem.gd` | DREAM_HEAL 후 UI 미갱신 | `player_hp_changed` 시그널 emit |
| M6 | `DreamShardSystem.gd` | NIGHTMARE 후 전투 종료 미체크 | `_check_battle_end()` 호출 |
| M7 | `TurnBasedReactionManager.gd` | `reset()`에서 `pending_draw_bonus` 초기화 누락 | 초기화 추가 |
| M8 | `BattleDiary.gd` | `start()` 리셋 로직 불안정 | 전체 `stats` dict 재생성 |

---

## 4. 아키텍처 변경 사항

### 전투 모드 분기 (새로 추가)
```
전투 진입
├── 일반 전투 → CombatSceneATB.tscn → CombatManagerATB (실시간 ATB)
├── 보스 전투 → CombatSceneTB.tscn → CombatManagerTB (턴제)
└── 폴백 → 기존 CombatManager autoload (씬 로드 실패 시)
```

### CombatBottomUI 브릿지 패턴
```
CombatBottomUI
├── new_combat_manager == null → 기존 CombatManager/DeckManager autoload 사용
└── new_combat_manager != null → 새 매니저 시그널 사용
    ├── hand_updated → Card Resource를 Dictionary로 변환 → CardHandItem 표시
    ├── energy_updated → EnergyOrb 업데이트
    ├── combat_ended → 로그 표시
    └── 카드 플레이 → manager.player_play_card(card) 직접 호출
```

### 디버그 단축키
| 키 | 기능 |
|----|------|
| `1~5` | 탐험/전투/상점/NPC/스토리 전환 |
| `B` | 보스 전투 (턴베이스) |
| `F1` | ATB 전투 강제 모드 |
| `F2` | 턴베이스 전투 강제 모드 |
| `F3` | 전투 모드 오버라이드 해제 |
| `9` | 즉시 승리 (치트) |
| `0` | 자동 진행 일시정지/재개 |
| `-` | 다음 노드 스킵 |

---

## 5. 알려진 제한사항 / TODO

1. **타겟팅 미완성**: ATB에서 공격 카드 사용 시 자동으로 첫 번째 살아있는 적을 공격함 (타겟 선택 UI 미연동)
2. **Auto AI 미연동**: CombatBottomUI의 Auto 버튼이 새 매니저의 AutoAI를 직접 제어하지는 않음 (현재 UI 토글만)
3. **리액션 윈도우 UI**: 패링/회피/방어 반응을 위한 시각적 UI 컴포넌트가 아직 stub 상태
4. **사운드/이펙트**: SFX.gd, VFX.gd, Haptics.gd가 stub (실제 에셋 연동 필요)
5. **카드 아트**: CardHandItem이 플레이스홀더 이모지 사용 중

---

## 6. 테스트 방법

1. Godot 에디터에서 `MainLobby.tscn` 실행
2. 게임 시작 → 탐험 모드 진입
3. 전투 노드 도달 시 자동으로 ATB 전투 진입
4. **확인사항**:
   - 카드 5장이 하단 UI에 팬 레이아웃으로 표시되는지
   - 카드 클릭 시 선택 → 재클릭 시 사용 (2단계)
   - 에너지 오브가 현재 에너지를 표시하는지
   - 덱/버림더미 카운트가 업데이트되는지
   - Pass/Auto/Speed 버튼 동작
5. 단축키 `2` (일반 전투), `B` (보스 전투) 로 즉시 전투 진입 가능

---

## 7. 변경 통계

```
수정 파일: 3개
신규 파일: ~50개 (전투 시스템 전체)
코드 변경: +543 / -158 lines (기존 파일만)
버그 수정: CRITICAL 3 / HIGH 12 / MEDIUM 8 = 총 23건
```
