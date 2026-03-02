# Dream Collector — 개발/기획 정리 (리액션·UI 개선)

**작성일:** 2025-03  
**대상:** 클로드·텔레그램 공유용  
**범위:** 탐험 로그 제한, 리액션(!) 표시, 패링/회피/가드 버튼·규칙·피드백, 턴베이스 보스전 리액션 활성화

---

# Part 1. 기획 정리

## 1. 탐험 하단 로그 박스

### 목표
- 화면 하단 이벤트 로그가 무한히 쌓이지 않도록 제한.
- 최신 로그 위주로만 보이게 해 가독성 유지.

### 규칙
| 항목 | 내용 |
|------|------|
| 최대 표시 개수 | **3개** |
| 정렬 | **위 = 가장 오래된**, **아래 = 가장 최신** |
| 추가 시 동작 | 새 로그가 들어오면 **맨 위(가장 오래된) 로그부터 1개씩 삭제** |

### UX
- 여행/전투/상점/승리 등 타입별 색상·아이콘 유지.
- 스크롤 없이 3줄만 보이도록 단순화.

---

## 2. 머리 위 위험 표시 "!"

### 목표
- 적 공격 리액션 구간을 **한 개의 !가 색만 바뀌며** 알려주기.
- "녹→노→빨"이 각각 따로 나타났다 사라지는 느낌 제거.

### 규칙
| 구간 | 색 | 의미 |
|------|-----|------|
| 녹색 | 초록 | 가드만 가능 (가장 김) |
| 노란색 | 노랑 | 회피·가드 가능 |
| 빨간색 | 빨강 | 패링·회피·가드 가능 (패링은 이 구간만) |

### UX
- **한 번 나타난 !는 사라지지 않고**, 같은 !가 **녹 → 노 → 빨**로만 색 변경.
- 게이지가 녹색 구간 끝나면 노란색으로, 노란색 끝나면 빨간색으로 전환되는 것처럼 보이게 함.

---

## 3. 전투 하단 "패링 / 회피 / 가드" 버튼

### 목표
- 리액션 윈도우에서 **한 개의 버튼**으로 패링·회피·가드 중 **가능한 최우선 행동**을 제공.
- 어떤 몬스터 공격에 대한 리액션인지 로그로 확인 가능.
- 성공/실패를 전투 화면(플레이어 머리 위)에서도 텍스트로 표시.

### 버튼 활성 조건
- **리액션 윈도우가 열려 있을 때만** 버튼 활성 (플레이어 턴에 잘못 눌려 카드 소비 방지).
- 손패에 있는 리액션 카드 중 **패링 > 회피 > 가드** 우선순위로 1개만 버튼에 반영.
- **턴베이스(보스전):** 플레이어 턴 종료 후에도 손패 유지 → 보스 공격 턴에 패링/회피/가드 사용 가능.
- **턴베이스:** 리액션 윈도우 중에는 **에너지 소모 없이** 패링/회피/가드 사용.

### 연속 사용 (패링 실패 → 회피/가드)
- 패링을 **잘못된 타이밍**(녹/노 구간)에 누르면 **실패**로만 처리하고, 윈도우는 유지.
- 실패한 타입(패링)은 **이번 윈도우에서 제외**하고, 버튼을 **회피 또는 가드**로 갱신해 **연속 시도** 가능.
- 방어 불가(UNBLOCKABLE) 공격에서 패링을 눌렀을 때도 동일: 패링 제외 후 회피 버튼 활성화.

### 로그·피드백
- **전투 로그:**  
  `패링 성공! (몬스터명)`, `회피 성공! (몬스터명)`, `가드! (몬스터명) 피해 N`,  
  `패링 실패! (몬스터명) 피해 N (+50%) / 적 ATB 빨라짐`, `회피 실패! (몬스터명) 피해 N (+20%)` 등.
- **전투 화면:** 플레이어 머리 위에 플로팅 텍스트  
  `패링 성공!` / `회피 성공!` / `가드` / `패링 실패!` / `회피 실패!` (색상 구분).

---

## 4. 리액션 결과 규칙 (패링/회피/가드)

### 성공 시
| 행동 | 데미지 | 추가 효과 |
|------|--------|-----------|
| **패링** | 0 | 해당 몬스터 **다음 행동까지 ATB 2배 느려짐** (ATB: enemy.atb = -ATB_MAX) |
| **회피** | 0 | - |
| **가드** | 가드 수치만큼 경감 | 남은 데미지는 블록으로 상쇄 후 HP 감소 |

### 실패 시 (타이밍 미스 또는 잘못된 선택)
| 행동 | 데미지 | 추가 효과 |
|------|--------|-----------|
| **패링 실패** | 기본 데미지 **+50%** | 해당 몬스터 **다음 행동이 빨라짐** (ATB 0.5배로 진행) |
| **회피 실패** | 기본 데미지 **+20%** | - |

### 미선택(시간 초과)
- 리액션 윈도우가 닫힐 때까지 아무 카드도 사용하지 않으면 **NONE** 처리.
- 기본 데미지 적용 (실패 페널티 없음, 단 실패 시도 기록이 있으면 그에 따른 페널티 적용).

---

# Part 2. 개발(구현) 정리

## 2.1 탐험 로그 최대 3개

### 수정 파일
- `ui/bottom_uis/ExplorationBottomUI.gd`

### 구현 요약
- `MAX_LOG_COUNT = 3` 상수 추가.
- `_trim_old_logs()`: `event_log` 자식 수가 3 초과 시 **맨 위(인덱스 0)부터** `remove_child` + `queue_free`.
- `_build_log_row()`, `_build_victory_row()` 내에서 로그 행 추가 직후 `_trim_old_logs()` 호출.

### 참고
- `queue_free()`만 쓰면 프레임 끝에 제거되므로, **먼저 `remove_child()`로 트리에서 제거** 후 `queue_free()` 호출.

---

## 2.2 머리 위 "!" 색상 전환만 (깜빡임 제거)

### 수정 파일
- `ui/screens/InRun_v4.gd`

### 구현 요약
- `_refresh_turn_and_alert_ui()`에서 **리액션 윈도우 중인 캐릭터**는 `set_alert_state(false)` 호출하지 않음.
- `_reaction_alert_enemy_idx`로 “지금 리액션 중인 몬스터”의 character_nodes 인덱스를 구하고, 해당 인덱스만 alert 초기화에서 제외.
- 리액션 구간 변경은 기존대로 `reaction_phase_changed` 시그널로만 색상 갱신 → !는 한 번만 켜진 뒤 녹→노→빨로만 바뀜.

---

## 2.3 리액션 규칙·로그·플로팅 텍스트

### 수정 파일
- `scripts/combat/atb/ATBReactionManager.gd`  
  - `last_failed_attempt_type`, 실패 시 시그널 `reaction_attempt_failed(attempted_type)` 추가 및 emit.
- `scripts/combat/atb/CombatManagerATB.gd`  
  - `battle_log(msg)`, 시그널 `battle_log_updated`, `reaction_feedback(text, result_type, enemy_idx)` 추가.  
  - `_apply_attack_result()`: 패링 성공 시 `enemy.atb = -ATB_MAX`, 패링 실패 시 데미지 1.5배 + `enemy.atb = ATB_MAX * 0.5`, 회피 실패 시 데미지 1.2배.  
  - 가드 시 블록 적용 후 잔여 데미지 계산·적용 및 `damage_dealt` emit.  
  - 로그 메시지에 몬스터명 포함, `reaction_feedback` emit.
- `scripts/combat/turnbased/TurnBasedReactionManager.gd`  
  - 동일하게 `last_failed_attempt_type`, `reaction_attempt_failed` 추가.
- `scripts/combat/turnbased/CombatManagerTB.gd`  
  - `reaction_feedback` 시그널 및 `_apply_action_result()` 내 동일 규칙(패링/회피/가드 성공·실패·가드 데미지)·로그·`reaction_feedback` emit.  
  - `battle_log()` 사용처 정리.
- `ui/components/DamageNumber.gd`  
  - `show_text(message, color, font_size)` 추가 (플로팅 텍스트용).
- `ui/components/CharacterNode.gd`  
  - `show_floating_text(message, color, font_size)` 추가.
- `ui/screens/InRun_v4.gd`  
  - `reaction_feedback` 연결 및 `_on_new_reaction_feedback()`에서 hero 머리 위에 색상별 플로팅 텍스트 표시.

---

## 2.4 전투 하단 리액션 버튼 (ATB/TB 공통)

### 수정 파일
- `ui/bottom_uis/CombatBottomUI.gd`

### 구현 요약
- **리액션 윈도우만 버튼 활성:**  
  `reaction_mgr.reaction_window_opened` / `reaction_window_closed` 연결 → `_reaction_window_active` 설정 후 `_update_reaction_button()`에서 비활성 시 "리액션" 비활성 처리.
- **우선순위:** 손패에서 `PARRY`(3) > `DODGE`(2) > `GUARD`(1) 태그 기준으로 1장만 선택.
- **턴베이스:**  
  - `new_combat_manager is CombatManagerTB and _reaction_window_active`일 때 **에너지 체크 생략** (리액션 카드 비용 무시).
- **연속 사용:**  
  - `_excluded_reaction_types` 배열 추가.  
  - `reaction_attempt_failed(attempted_type)` 수신 시 해당 타입 추가 후 `_update_reaction_button()` 호출.  
  - `_update_reaction_button()`에서 해당 태그를 가진 카드는 제외하고 다음 우선순위 카드로 버튼 갱신.  
  - `reaction_window_closed` 시 `_excluded_reaction_types.clear()`.
- 진입/퇴장 시 `reaction_attempt_failed` 연결/해제 처리.

---

## 2.5 턴베이스(보스전) 리액션 버튼 활성화

### 수정 파일
- `scripts/combat/turnbased/CombatManagerTB.gd`

### 구현 요약
- **원인:** `player_end_turn()`에서 `hand_system.discard_remaining()` 호출로 턴 종료 시점에 손패가 비어, 보스 공격 턴(리액션 윈도우)에 패링/회피/가드 카드가 없어 버튼이 비활성화됨.
- **조치:**  
  - `player_end_turn()` 내의 `discard_remaining()` 호출 제거.  
  - `_start_enemy_turns()`에서 **모든 적 행동이 끝난 뒤** (for 루프 직후) `hand_system.discard_remaining()` 한 번만 호출.
- 그 결과 보스 공격 턴 동안에는 **플레이어 턴 종료 시점의 손패가 유지**되어, 해당 손패 기준으로 패링/회피/가드 버튼이 활성화됨.

---

## 2.6 시그널·API 요약

| 시그널 | 소스 | 용도 |
|--------|------|------|
| `battle_log_updated(message)` | CombatManagerATB | 전투 로그 메시지 (몬스터명 포함 등) |
| `reaction_feedback(text, result_type, enemy_idx)` | CombatManagerATB / CombatManagerTB | 플레이어 머리 위 플로팅 텍스트 (성공/실패) |
| `reaction_attempt_failed(attempted_type)` | ATBReactionManager / TurnBasedReactionManager | 패링/회피 타이밍 실패 시 UI에서 해당 타입 제외 후 다음 옵션(회피/가드) 활성화 |

---

## 2.7 주의사항·테스트 포인트

- **ATB:** 리액션 버튼은 리액션 윈도우가 열렸을 때만 활성; 에너지 부족 시 해당 리액션 카드는 버튼에 안 나옴.
- **TB:** 리액션 윈도우 중에는 에너지 무관하게 패링/회피/가드 버튼 활성.
- **TB 손패:** 적 턴 전체가 끝난 뒤에만 discard되므로, 여러 적이 있을 경우 한 적의 리액션에서 쓴 카드가 다음 적 리액션에서도 남아 있을 수 있음 (의도된 동작: “이전 턴 손패 기준으로 보스 공격 턴에 사용 가능”).
- **패링 실패:** `last_failed_attempt_type`은 윈도우가 NONE으로 종료될 때만 데미지/ATB 페널티에 사용; 중간에 회피/가드 성공 시에는 페널티 없음.

---

# Part 3. 요약 (클로드·텔레그램 공유용 한 줄 요약)

1. **탐험 로그:** 최대 3개, 새 로그 시 맨 위(오래된 것)부터 삭제.  
2. **리액션 !:** 한 개의 !가 녹→노→빨로만 색 변경, 깜빡이지 않음.  
3. **리액션 버튼:** 리액션 윈도우에서만 활성, 패링>회피>가드 우선, 로그·머리 위 텍스트로 몬스터명·성공/실패 표시.  
4. **리액션 규칙:** 패링 성공=데미지0+적 느려짐, 회피 성공=0, 가드=블록만큼 경감. 패링 실패=+50% 데미지+적 빨라짐, 회피 실패=+20% 데미지.  
5. **보스전:** 턴 종료 시 손패 유지 → 적 턴 끝난 뒤에만 버림. 보스 공격 턴에 패링/회피/가드 사용 가능, 에너지 무소모.  
6. **연속 사용:** 패링 실패 시 같은 윈도우에서 패링 제외 후 회피/가드 버튼으로 연속 시도 가능.
