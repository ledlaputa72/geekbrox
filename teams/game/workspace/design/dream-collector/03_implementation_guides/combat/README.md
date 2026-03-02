# ⚔️ 전투 시스템 구현 가이드

이 폴더는 Dream Collector의 **전투 시스템 구현**을 위한 모든 기술 명세와 가이드를 포함합니다.

---

## 📚 문서 계층도

### 1단계: 통합 설계 (모든 개발자가 시작)

**파일**: `COMBAT_UNIFIED_DESIGN_v1.md`  
**규모**: 전체 전투 시스템 통합 설계  
**대상**: 모든 개발팀

**포함 내용**:
- ✅ ATB & 턴베이스 공통 프레임워크
- ✅ 30장 카드 구조 정의
- ✅ 공통 에너지 시스템
- ✅ 공통 리액션 시스템
- ✅ 콤보 감지 로직
- ✅ 상태이상 관리
- ✅ ATB 특수 시스템
- ✅ 턴베이스 특수 시스템
- ✅ AI 구현 가이드
- ✅ 성능 최적화 팁

**활용**: 개발 시작 전 읽고 전체 구조 이해

---

### 2단계: 모드별 상세 설계

#### ATB 전투

**파일**: `COMBAT_ATB_COMPLETE_v1.md`  
**규모**: ATB 전투 완전 설계  
**대상**: ATB 담당 개발자

**포함 내용**:
- ATB 게이지 시스템 상세
- 실시간 리액션 프레임워크
- ATB 특수 모드 (집중/위기)
- 의도 표시 시스템
- 콤보 감지 (ATB 버전)
- AI 우선순위 (ATB)

**구현 순서**:
1. ATBEnergySystem 작성
2. ATBReactionManager 작성
3. CombatManagerATB 통합
4. ATB 특수 모드 구현

---

#### 턴베이스 전투

**파일**: `COMBAT_TURNBASED_COMPLETE_v1.md`  
**규모**: 턴베이스 전투 완전 설계  
**대상**: 턴베이스 담당 개발자

**포함 내용**:
- 턴 루프 시스템 상세
- 손패 및 드로우 관리
- 턴베이스 리액션 프레임워크
- 타로 에너지 시스템
- 꿈 조각 시스템
- 덱 패시브 시스템
- AI 우선순위 (TB)

**구현 순서**:
1. TurnBasedHandSystem 작성
2. TurnBasedEnergySystem 작성
3. TurnBasedReactionManager 작성
4. CombatManagerTB 통합
5. 보조 시스템 (타로/꿈조각/패시브)

---

### 3단계: 세부 시스템 설계

#### 리액션 시스템

**ATB 버전**: `REACTION_ATB_v1.md`
- 패링/회피 윈도우 타이밍
- ATB 기반 강도 계산
- 이펙트 및 피드백

**TB 버전**: `REACTION_TURNBASED_v1.md`
- 턴 기반 리액션 플로우
- 의도 공개와 반응
- 다음 턴 보너스 관리

---

## 🎯 빠른 시작 가이드

### 개발자라면

1. **COMBAT_UNIFIED_DESIGN_v1.md** 읽기 (30분)
   → 전체 구조 이해

2. **담당 모드 선택**
   - ATB: `COMBAT_ATB_COMPLETE_v1.md`
   - TB: `COMBAT_TURNBASED_COMPLETE_v1.md`
   (각 60분)

3. **상세 시스템 문서** 참고
   - `REACTION_ATB_v1.md` 또는
   - `REACTION_TURNBASED_v1.md`
   (필요할 때마다)

4. **기획서로 돌아가기**
   → `02_core_design/CARD_COMBAT_SYSTEM_DESIGN.md`
   (막힐 때 참고)

---

### 기획팀이라면

1. **COMBAT_UNIFIED_DESIGN_v1.md** 읽기
   → 구현 방향 이해

2. **02_core_design/ 문서들** 참고
   → 기획 의도 확인

3. **개발팀 진행 상황** 모니터링
   → 이 폴더의 각 문서 완성도 추적

---

## 📊 문서 의존성

```
COMBAT_UNIFIED_DESIGN_v1.md
        ↓
    ┌───┴───┐
    ↓       ↓
 ATB      TB
 ↓        ↓
COMBAT_  COMBAT_
ATB_     TURNBASED_
COMPLETE COMPLETE

     ↓
REACTION_[MODE]_v1.md
     ↓
02_core_design/
CARD_COMBAT_SYSTEM_DESIGN.md
```

---

## 🔧 개발 상태

| 문서 | 상태 | 개발 진행률 |
|------|------|-----------|
| COMBAT_UNIFIED_DESIGN_v1.md | ✅ | 100% |
| COMBAT_ATB_COMPLETE_v1.md | ✅ | 100% (코드) |
| COMBAT_TURNBASED_COMPLETE_v1.md | ✅ | 100% (코드) |
| REACTION_ATB_v1.md | ✅ | 80% |
| REACTION_TURNBASED_v1.md | ✅ | 80% |

---

## 🚀 구현 체크리스트

### 공통 (먼저)
- [ ] Card.gd 작성
- [ ] Monster.gd 작성
- [ ] StatusEffectSystem.gd 작성
- [ ] BattleDiary.gd 작성

### ATB
- [ ] ATBEnergySystem.gd
- [ ] ATBReactionManager.gd
- [ ] CombatManagerATB.gd
- [ ] ATBIntentSystem.gd
- [ ] ATBComboSystem.gd
- [ ] ATBAutoAI.gd
- [ ] ATBFocusMode.gd
- [ ] ATBCrisisMode.gd

### 턴베이스
- [ ] TurnBasedEnergySystem.gd
- [ ] TurnBasedHandSystem.gd
- [ ] TurnBasedReactionManager.gd
- [ ] CombatManagerTB.gd
- [ ] TurnBasedIntentSystem.gd
- [ ] TarotEnergySystem.gd
- [ ] DreamShardSystem.gd
- [ ] DeckPassiveCalculator.gd
- [ ] TurnBasedAutoAI.gd

### UI (나중)
- [ ] EnergyUI
- [ ] HandUI
- [ ] IntentUI
- [ ] ComboUI
- [ ] 중앙 덱 디스플레이

---

## 💡 주요 구현 팁

### 1. Card는 Resource로
```gdscript
# ❌ 잘못된 방식
var card = Card()
card.damage = 10

# ✅ 올바른 방식
var card = CardDatabase.get_card("ATK_001")
```

### 2. 에너지 시스템은 먼저
```
ATB/TB 모두 에너지가 핵심
→ 에너지 시스템을 먼저 완성하면
   나머지 시스템이 쉬워짐
```

### 3. 리액션은 신호 기반
```gdscript
# 리액션 매니저는 결과를 신호로 발송
signal parry_success
signal dodge_success
signal guard_success
signal reaction_none

# 전투 매니저가 수신해서 처리
```

### 4. 테스트용 AutoAI부터
```
AutoAI로 풀오토 테스트하면
게임 루프 검증이 쉬움
```

---

## 🔗 관련 폴더

- **02_core_design/**: 기획 기준점
- **../**: 다른 구현 가이드
- **../../**: 전체 기획 문서

---

## 📞 문제 해결

### "에너지 시스템이 이상해요"
→ `COMBAT_UNIFIED_DESIGN_v1.md`의 에너지 섹션 재확인

### "콤보가 안 탐지돼요"
→ `COMBAT_UNIFIED_DESIGN_v1.md`의 콤보 로직 섹션 확인

### "ATB vs TB 차이를 모르겠어요"
→ `COMBAT_UNIFIED_DESIGN_v1.md`의 시스템 선택 플로우 섹션

### "카드 효과가 명확하지 않아요"
→ `02_core_design/CARD_COMBAT_SYSTEM_DESIGN.md` 참고

---

**최종 업데이트**: 2026-03-01  
**상태**: 설계 완료, 개발 진행 중 (80%)  
**완료 예정**: 2026-03-05
