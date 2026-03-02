# Dream Collector 개발 업데이트 (2025-03-01)

## 요약
전투 시스템(ATB/턴베이스) UI·로직 개선, 카드 핸드 레이아웃, 에너지 규칙, 기본 체력 조정 등 적용.

---

## 1. 전투 시스템

### 에너지 규칙 (ATB/턴베이스 공통)
- **전투 시작 시 3에너지** — ATB·턴베이스 모두 동일
- **ATB**: 5초마다 +1 시간 충전 (`ATBEnergySystem.update_timer`)
- **턴베이스**: 매 턴 시작 시 새로 3에너지 (패링/회피 보너스 적용)

### 덱·손패 규칙
- **30장 덱**: ATK 10, DEF 8, PARRY 5, DODGE 5, SKILL 2
- **턴베이스**: 매 턴 5장 드로우, 턴 종료 시 손패 → 무덤, 덱 비면 무덤 셔플
- **ATB Pass**: 손패 → 무덤, 새로 5장 드로우 (10초 쿨)

### 기본 체력
- 캐릭터 기본 체력 **80 → 200**으로 변경

---

## 2. UI 변경

### 덱/무덤 표시
- 왼쪽: 덱 아이콘 📚 + 카드 수
- 오른쪽: 무덤 아이콘 🪦 + 카드 수

### 카드 애니메이션
- **덱 → 핸드**: 드로우 시 왼쪽 덱 위치에서 핸드로 이동
- **핸드 → 무덤**: 턴 종료·Pass 시 오른쪽 무덤으로 이동 후 페이드 아웃

### 핸드 카드 레이아웃
- 좌우 경계 내 정렬 (화면 밖으로 나가지 않음)
- 선택 카드: 수직(0°), 양옆 카드 최대 ±15°
- 선택 카드: 좌우 2배 간격
- 레이어: 왼쪽 아래 → 오른쪽 위, 선택 카드는 최상단

### 카드 텍스트
- 폰트 크기 약 50% 확대 (이름 7→11, 코스트 12→18 등)

### 플레이어 HP/아머
- Hero HP·블록 게이지를 캐릭터 위 10px 위치에 표시
- 전투 시작 시 `player_hp_changed` emit으로 초기화

---

## 3. 공격 카드 타겟팅

### 2단계 선택
1. 카드 선택 (확대) → 화살표로 대상 선택 (몬스터 하이라이트)
2. **같은 몬스터 재클릭** → 공격 발동

### 인덱스 매핑 수정
- `character_nodes` 인덱스 ↔ `enemies` 인덱스 불일치 해결
- `_combat_monster_character_indices` 매핑 추가

---

## 4. 수정된 파일

### 핵심
- `CombatManagerATB.gd` — Pass 10초 쿨, player_hp_changed
- `CombatManagerTB.gd` — player_hp_changed, 에너지 주석
- `CombatBottomUI.gd` — 카드 레이아웃, 덱/무덤 UI, 2단계 타겟팅
- `InRun_v4.gd` — _combat_monster_character_indices, 기본 체력 200

### 컴포넌트
- `CardHandItem.gd` — 폰트 50% 확대, 선택 스케일
- `CharacterNode.gd` — set_target_highlighted, Hero HP/블록 위 배치

### 에너지/덱
- `ATBEnergySystem.gd` — 에너지 규칙 주석
- `TurnBasedEnergySystem.gd` — 턴베이스 규칙 주석
- `CardDatabase.gd` — get_full_deck_30()

### 기타
- `CombatManager.gd`, `StatusEffectSystem.gd`, `DreamShardSystem.gd` — 기본 체력 200
