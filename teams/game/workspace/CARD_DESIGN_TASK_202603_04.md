# 🎴 카드 200종 초기 론칭 기획 작업 (2026-03-04)

**할당 대상:** Kim.G (게임개발팀장)  
**기한:** -  
**우선순위:** 🔴 HIGH  
**상태:** 🟡 위임됨 - 진행 대기

---

## 📋 작업 개요

Dream Collector 초기 론칭을 위한 **카드 200여종** 세부 기획 및 데이터화 작업

### 핵심 요구사항
1. **4가지 메인 카테고리** + **서브카테고리** 체계 설계
2. **200개 카드** 기획 및 밸런스 조정
3. **게임 재화 운영** 전략 수립
4. **JSON/CSV 데이터** 변환 (CardDatabase.gd 연동)

---

## 📖 참조 문서

| 문서 | 링크 | 내용 |
|------|------|------|
| **Tarot System Guide** | `teams/game/workspace/design/dream-collector/TAROT_SYSTEM_GUIDE.md` | 기존 78카드 시스템, 메이저/마이너 분류 |
| **GDD** | `teams/game/workspace/design/dream-collector/GDD.md` | 게임 전체 설계 |
| **ATB 전투 시스템** | `teams/game/workspace/design/dream-collector/combat/` | 전투 밸런스 기준 |
| **Integrated Game Concept** | `teams/game/workspace/design/dream-collector/INTEGRATED_GAME_CONCEPT.md` | 게임 전체 비전 |

---

## 🎯 Step 1: 카드 분류 체계 설계

### 목표
4가지 메인 카테고리 정의 및 각 카테고리별 서브카테고리 구성

### 고려사항
- **기존 Tarot 78카드 시스템** 참조 (메이저 22장, 마이너 56장)
- **게임 내 역할** (공격, 방어, 치유, 상태이상 등)
- **초기 200카드 배분** (4가지 분류별 균형)

### 예시 (참고만)
```
1️⃣ 메인 카테고리: Arcana (원형)
   ├─ Major Arcana (메이저 - 강력, 한정)
   ├─ Minor Arcana (마이너 - 일반, 자주 나옴)
   └─ Custom Dreams (커스텀 - 게임 고유)

2️⃣ 메인 카테고리: Element (원소)
   ├─ Fire (불 - 공격형)
   ├─ Water (물 - 방어형)
   ├─ Wind (바람 - 속도형)
   └─ Earth (흙 - 지속형)

... (다른 2가지 분류 체계)
```

### 산출물
**파일:** `teams/game/workspace/design/dream-collector/CARD_CLASSIFICATION_SYSTEM.md`

```markdown
# 카드 분류 체계

## 4가지 메인 카테고리
1. [카테고리1]: [설명]
2. [카테고리2]: [설명]
3. [카테고리3]: [설명]
4. [카테고리4]: [설명]

## 각 카테고리별 서브카테고리 및 초기 200카드 배분
[상세 구성]

## 카드 풀 조성 (200개 총합)
- 카테고리1: XX개
- 카테고리2: XX개
- 카테고리3: XX개
- 카테고리4: XX개
```

---

## 🎯 Step 2: 게임 밸런스 기획

### 전투 밸런스 (ATB 시스템)
- **공격형 카드**: 높은 피해, 느린 속도
- **방어형 카드**: 낮은 피해, 높은 방어율
- **치유형 카드**: 지속 회복, 상태이상 제거
- **상태이상형 카드**: 약화/강화 버프/디버프

**목표:** 각 역할군 간 파워 밸런싱 (어떤 조합도 경쟁력 있게)

### 재화 운영 전략

#### 유료 구매 유도
- **프리미엄 카드** (한정, 강력): 유료 구매로만 획득 가능
- **세트 보너스**: 특정 카드 조합 시 추가 효과
- **시즌 카드**: 주기적으로 새로운 카드 출시 (FOMO)

#### 보상 및 재화
- **초보자 보상**: 게임 시작 시 기본 카드 풀 (진입 장벽 낮춤)
- **일일 보상**: 무료 카드 뽑기 기회
- **도전 과제**: 스토리/배틀 클리어 시 카드 획득
- **시즌 진행**: 시즌 패스로 카드 해금

#### 초기 플레이어 & 장기 플레이 밸런스
- **초기 30레벨**: 무료 카드 충분히 제공 → 초기 플레이 재미
- **30~60레벨**: 약간의 유료 유도 (성능차 적음)
- **60레벨+**: 강화/조합 전략에 의존 (보유 카드 차이 극복 가능)

### 산출물
**파일:** `teams/game/workspace/design/dream-collector/CARD_BALANCE_STRATEGY.md`

```markdown
# 카드 밸런스 및 재화 운영 전략

## 전투 밸런스 분석
[각 역할군별 파워 분석]

## 재화 운영 모델
[유료/무료 배분, 보상 체계]

## 초기-장기 플레이 곡선
[레벨대별 카드 획득 전략]
```

---

## 🎯 Step 3: 카드 데이터 기획 & 생성

### 데이터 스키마
```json
{
  "id": "card_001",
  "name": "카드명 (한글)",
  "nameEn": "Card Name (English)",
  "category": "분류 (예: Arcana)",
  "subcategory": "서브분류 (예: Major)",
  "type": "card_type (attack|defend|heal|utility|buff|debuff)",
  "rarity": "common|uncommon|rare|epic|legendary",
  "cost": 3,
  "costType": "mana|soul|dream",
  "description": "카드 설명",
  "flavor": "플레이버 텍스트",
  "stats": {
    "attack": 5,
    "defense": 2,
    "speed": 3,
    "accuracy": 90
  },
  "effects": [
    {
      "id": "effect_001",
      "type": "damage|heal|debuff",
      "value": 5,
      "target": "enemy|self|all",
      "duration": 1
    }
  ],
  "availability": "base|limited|shop|gacha|battle_reward",
  "monetization": "free|premium|shop|gacha_only|battle_reward",
  "rarityRate": 0.05,
  "releasePhase": 1,
  "notes": "개발 노트"
}
```

### 생성 계획
1. **메인 카테고리 1**: XX개 카드
   - 레어리티 분포: common(XX) / uncommon(XX) / rare(XX) / epic(XX) / legendary(XX)
   - 타입 분포: attack(XX) / defend(XX) / heal(XX) / utility(XX)

2. **메인 카테고리 2**: XX개 카드
   - [유사 분석]

3. **메인 카테고리 3**: XX개 카드
4. **메인 카테고리 4**: XX개 카드

### 산출물
**파일:** `teams/game/workspace/design/dream-collector/data/cards_initial_200.json`

```json
[
  {
    "id": "card_001",
    "name": "...",
    ...
  },
  ...
]
```

**CSV 버전:** `teams/game/workspace/design/dream-collector/data/cards_initial_200.csv`

---

## 🎯 Step 4: CardDatabase.gd 연동 가이드

### 목표
생성된 200개 카드 JSON을 Godot CardDatabase.gd에 적용하기 위한 가이드

### 체크리스트
- [ ] JSON 스키마가 CardDatabase.gd 로더와 일치하는가?
- [ ] 모든 `effect` ID가 유효한가?
- [ ] 모든 `availability` 값이 enum과 매칭되는가?
- [ ] 테스트: 게임 시작 시 모든 200개 카드 로드 성공?

### 산출물
**파일:** `teams/game/workspace/design/dream-collector/CARD_DATA_INTEGRATION_GUIDE.md`

---

## 📊 최종 산출물 체크리스트

| # | 산출물 | 상태 | 파일명 |
|---|--------|------|--------|
| 1 | 카드 분류 체계 문서 | ⬜ | `CARD_CLASSIFICATION_SYSTEM.md` |
| 2 | 밸런스 & 재화 전략 | ⬜ | `CARD_BALANCE_STRATEGY.md` |
| 3 | 200개 카드 JSON | ⬜ | `data/cards_initial_200.json` |
| 4 | 200개 카드 CSV | ⬜ | `data/cards_initial_200.csv` |
| 5 | 데이터 연동 가이드 | ⬜ | `CARD_DATA_INTEGRATION_GUIDE.md` |
| 6 | 최종 완성 보고서 | ⬜ | `CARD_200_COMPLETION_REPORT.md` |

---

## 🔧 작업 진행 방식

### 절차
1. **분류 체계 검토 & 승인** (Steve PM)
   - 파일: `CARD_CLASSIFICATION_SYSTEM.md`
   - 요청: 4가지 분류 적절성 + 200개 배분안 피드백

2. **카드 기획 및 밸런스 설계**
   - 파일: `CARD_BALANCE_STRATEGY.md`
   - 전투 밸런스 + 재화 운영 전략

3. **카드 데이터 생성**
   - JSON/CSV 생성 (대량 데이터 → Gemini 2.5 Flash sub-agent 활용 권장)
   - 각 카드 상세 스펙 정의

4. **데이터 검증 & 연동**
   - CardDatabase.gd 스키마 매핑
   - 게임 테스트 (모든 카드 정상 로드)

5. **최종 보고 (Steve PM)**
   - 완성 보고서: `CARD_200_COMPLETION_REPORT.md`
   - 승인 후 → Git Push (Steve 승인 대기)

---

## ⚠️ 주의사항

### 에이전트 모델 확인
이 작업은 **Gemini 2.5 Pro**으로 수정되었습니다.
- ✅ 검증됨: 2026-03-04 모델 설정 완료
- ✅ Fallback 체인: Haiku → Flash 설정됨

### Sub-Agent 활용 (옵션)
카드 200개 JSON 데이터 생성이 많으면:
```bash
# Gemini 2.5 Flash sub-agent로 대량 생성 (80% 비용 절감)
/spawn model=gemini-2.5-flash \
  task="Generate 200 card JSON files based on CARD_CLASSIFICATION_SYSTEM.md"
```

---

## 📅 타임라인

| 마일스톤 | 예상 일정 | 상태 |
|---------|---------|------|
| 분류 체계 수립 | - | 🟡 진행 중 |
| 밸런스 전략 수립 | - | ⬜ 대기 |
| 카드 200개 생성 | - | ⬜ 대기 |
| 최종 보고 | - | ⬜ 대기 |

---

**작업 시작 시간:** 2026-03-04 12:14 PST  
**할당자:** Atlas (PM)  
**연락처:** Steve PM via Telegram
