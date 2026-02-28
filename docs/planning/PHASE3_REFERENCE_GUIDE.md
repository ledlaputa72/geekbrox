# 📚 Phase 3 참조 자료 종합 가이드

**작성일**: 2026-02-28  
**작성자**: Atlas (AI PM)  
**목적**: 모든 Phase 3 작업에 필요한 참조 자료 한눈에 보기

---

## 📊 Phase 3 문서 전체 지도

```
Phase 3 (Systems Design) 필수 문서
├─ 📖 기본 문서 (지금 읽어야 함)
│  ├─ PHASE3_DETAILED_TASKS.md ← 지금 여기!
│  ├─ PHASE3_NEXT_TASKS.md
│  └─ PHASE3_REFERENCE_GUIDE.md ← 지금 여기!
│
├─ ✅ 완성된 기획 문서 (참고)
│  ├─ INTEGRATED_GAME_CONCEPT.md (v2.0)
│  ├─ TAROT_SYSTEM_GUIDE.md (v2.2)
│  ├─ STORY_LEVEL_DESIGN_CONCEPT.md
│  ├─ STORY_CONCEPT_GUIDE.md
│  └─ ART_STYLE_GUIDE.md
│
├─ 🎯 진행 중인 작업 (작성 예정)
│  ├─ CARD_POOL.md (3/5 마감)
│  ├─ ENEMY_DESIGN.md (3/7 마감)
│  ├─ BOSS_NARRATIVE.md (3/7 마감)
│  ├─ RELIC_SYSTEM.md (3/10 마감)
│  ├─ ECONOMY_BALANCE.md (3/12 마감)
│  ├─ CHARACTER_DESIGN.md (3/14 마감)
│  ├─ ASCENSION_SYSTEM.md (3/21 마감)
│  └─ NODE_INTERACTION.md (3/23 마감)
│
└─ 🔧 스프레드시트 (데이터 정리용)
   ├─ CARD_MASTER.xlsx
   ├─ ENEMY_MASTER.xlsx
   ├─ RELIC_MASTER.xlsx
   └─ ECONOMY_MASTER.xlsx
```

---

## 🎯 1. 각 업무별 필수 참조 문서

### Task 1.1: 전투 시스템 결정 (3/3)

**읽어야 할 문서:**
```
1️⃣ 필수
   ├─ /teams/game/workspace/design/dream-collector/03_implementation_guides/combat/
   │  ├─ ATB_Implementation_Guide.md
   │  ├─ TurnBased_Implementation_Guide.md
   │  └─ Cursor_Dual_Combat_Guide.md
   └─ PHASE3_DETAILED_TASKS.md (Task 1.1 섹션)

2️⃣ 참고
   ├─ INTEGRATED_GAME_CONCEPT.md (세계관 재확인)
   └─ 기존 전투 구현 코드 (Godot)
      └─ /teams/game/godot/autoload/CombatManager.gd
```

**산출물:**
- 결정 선택지 (ATB / Turn-Based)
- 선택 이유 (500자 이상)
- 모든 팀에게 공식 공지

---

### Task 1.2: 카드 풀 설계 (3/5)

**읽어야 할 문서:**
```
1️⃣ 필수
   ├─ PHASE3_DETAILED_TASKS.md (Task 1.2 섹션)
   ├─ TAROT_SYSTEM_GUIDE.md (타로 테마 활용)
   ├─ CARD_FUNCTION_DESIGN_GUIDE.md (기존 카드 설계 원칙)
   └─ 선택된 전투 시스템 가이드 (ATB or Turn)

2️⃣ 참고
   ├─ INTEGRATED_GAME_CONCEPT.md (게임 톤)
   └─ 비교 게임 카드 풀
      ├─ Slay the Spire (620장 분석)
      ├─ Monster Train (450장 분석)
      └─ Peglin (280장 분석)
```

**템플릿:**
```yaml
# PHASE3_DETAILED_TASKS.md의 "카드 설계 템플릿" 복사
Card:
  Name: 
  Cost: 
  Type: 
  Rarity: 
  Effect: 
  Upgraded: 
  SynergyWith: 
  Obtained: 
```

**산출물:**
1. `CARD_POOL.md` (설계 철학 + 목록)
2. `CARD_MASTER.xlsx` (모든 카드 스펙)
   - 컬럼: ID, Name, Cost, Type, Rarity, Effect, Upgraded, Synergy, Obtained

**예상 시간:**
- 전투 시스템 결정: 2시간
- 비용 기준표 작성: 3시간
- 카드 목록 작성: 5시간
- 각 카드 효과 상세화: 8시간
- 밸런싱 검증: 3시간
- **총: 21시간 (3일)**

---

### Task 1.3: 몬스터 & 보스 설계 (3/7)

**읽어야 할 문서:**
```
1️⃣ 필수
   ├─ PHASE3_DETAILED_TASKS.md (Task 1.3 섹션)
   ├─ STORY_LEVEL_DESIGN_CONCEPT.md (Act별 테마)
   ├─ STORY_CONCEPT_GUIDE.md (스토리 연결)
   ├─ INTEGRATED_GAME_CONCEPT.md (세계관)
   └─ 완성된 CARD_POOL.md (드롭 테이블)

2️⃣ 참고
   ├─ 비교 게임 분석
   │  ├─ Slay the Spire (몬스터 AI 패턴)
   │  ├─ Monster Train (몬스터 설계)
   │  └─ Peglin (적 패턴)
   └─ Godot 구현 참고
      └─ /teams/game/godot/scenes/
```

**템플릿:**
```yaml
# PHASE3_DETAILED_TASKS.md의 "몬스터 설계 템플릿" 복사
Monster:
  ID:
  Name:
  Description:
  Type:
  Stats:
    HP:
    Attack:
    Defense:
    Speed:
  Intent:
  Action:
  Pattern:
  Drop:
```

**산출물:**
1. `ENEMY_DESIGN.md` (50-70종 몬스터)
2. `BOSS_NARRATIVE.md` (3명 보스 스토리)
3. `ENEMY_MASTER.xlsx`
   - 컬럼: ID, Name, HP, Attack, Defense, Speed, Intent, Pattern, Drop, ArtRef

**체력 곡선 참고:**
```
일반 몬스터        엘리트 (×1.5~2.0)   보스 (×3~5)
Act 1: 15 HP      25 HP              60-80 HP
Act 2: 40 HP      60 HP              120-160 HP
Act 3: 65 HP      100 HP             180-240 HP
```

---

### Task 2.1: 유물 시스템 설계 (3/10)

**읽어야 할 문서:**
```
1️⃣ 필수
   ├─ PHASE3_DETAILED_TASKS.md (Task 2.1 섹션)
   ├─ 완성된 CARD_POOL.md (시너지 분석)
   └─ 완성된 ECONOMY_BALANCE.md (가격 기준)

2️⃣ 참고
   ├─ Slay the Spire 유물 설계
   └─ Monster Train 유물 시스템
```

**유물 분류:**
- 공격 유물: 7-10개
- 방어 유물: 5-7개
- 특수 유물: 5-7개
- 하이브리드: 2-4개
- 음수 유물: 1-2개
- **합계: 20-30개**

---

### Task 2.2: 경제 수치 밸런싱 (3/12)

**읽어야 할 문서:**
```
1️⃣ 필수
   ├─ PHASE3_DETAILED_TASKS.md (Task 2.2 섹션)
   ├─ 완성된 CARD_POOL.md
   ├─ 완성된 ENEMY_DESIGN.md
   └─ 완성된 RELIC_SYSTEM.md

2️⃣ 참고
   ├─ Slay the Spire 경제 분석
   └─ FTL 스케일링 공식
```

**핵심 수치:**
```
보상 골드:
- 일반 몬스터: 10-15 골드
- 엘리트: 35-50 골드
- 보스: 100-150 골드

상점 가격:
- 기본 카드: 50-70 골드
- 희귀 카드: 100-120 골드
- 서사 카드: 150-200 골드
- 유물: 50-300 골드 (등급별)
```

---

### Task 2.3: 캐릭터 추가 설계 (3/14)

**읽어야 할 문서:**
```
1️⃣ 필수
   ├─ PHASE3_DETAILED_TASKS.md (Task 2.3 섹션)
   ├─ INTEGRATED_GAME_CONCEPT.md (주인공 녹스)
   └─ STORY_CONCEPT_GUIDE.md

2️⃣ 참고
   ├─ 기존 캐릭터 설계 (녹스)
   └─ Slay the Spire 캐릭터 설계
```

**캐릭터 요소:**
```
기본 정보
├─ 이름
├─ 직업/역할
├─ 배경 스토리
└─ 비주얼 설명

게임 수치
├─ 기본 체력
├─ 기본 에너지
├─ 시작 카드 풀
└─ 고유 능력

특별 메커닉
├─ 패시브 능력
├─ 액티브 능력
└─ 메타프로그레션 (승천 보너스)
```

---

## 📚 2. 비교 게임 참고 자료

### Slay the Spire

**카드 밸런싱:**
- 총 620장 카드
- 분류: 공격(140), 방어(130), 파워(90), 상황(260)
- 비용: 0-3 에너지
- 공식: Avg Damage = (비용 × 4) ± 2

**링크:**
- 공식 사이트: https://www.slay-the-spire.com
- 카드 위키: https://slay-the-spire.fandom.com/wiki/Cards

---

### Monster Train

**카드 조합 시스템:**
- 계층형 덱 구성 (Starter + Clan A + Clan B)
- 클랜별 시너지 맵핑
- 총 450장 카드

**링크:**
- 공식 사이트: https://monstrain.com
- 전략 가이드: https://monstrain.fandom.com

---

### Peglin

**카드 효과 설계:**
- 피직스 기반 카드 (핀볼 메커닉)
- 총 280장 카드
- 비용: 0-5 에너지

**링크:**
- 공식 사이트: https://peglin.com

---

### FTL: Faster Than Light

**난이도 곡선:**
- 지수 증가 공식 사용 (Level × 1.2^(Level-1))
- 승천 모드 (Easy, Normal, Hard)
- 각 난이도별 敵 능력 증가

**링크:**
- 공식 사이트: https://ftl-game.com

---

## 📊 3. 스프레드시트 템플릿

### CARD_MASTER.xlsx

```
| ID | Name | Cost | Type | Rarity | Effect | Upgraded | Synergy | Obtained | Notes |
|----|------|------|------|--------|--------|----------|---------|----------|-------|
| C001 | 꿈의 검격 | 2 | Attack | Uncommon | Dmg 8 | Dmg 10 | 힘 관련 | Shop | 기본 공격 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
```

### ENEMY_MASTER.xlsx

```
| ID | Name | Type | HP | ATK | DEF | SPD | Intent | Action | Pattern | Drop | Art |
|----|------|------|----|----|-----|-----|--------|--------|---------|------|-----|
| E001 | 기억의 조각 | Spirit | 15 | 3 | 1 | 100 | 공격 | Dmg 3 | 공격-공격-강화 | 10-15G | 투명한 파란 입자 |
| ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... | ... |
```

---

## 🎯 4. 시간 소요 예상 (총 75시간)

```
Task 1.1 (전투 시스템)     2시간   ████░░░░░░░░░░░░░░░░░
Task 1.2 (카드 풀)        21시간   ████████████████░░░░░░░░
Task 1.3 (몬스터)         25시간   ████████████████████░░░░░
Task 2.1 (유물)            8시간   ██████░░░░░░░░░░░░░░░░░░
Task 2.2 (경제)           10시간   ███████░░░░░░░░░░░░░░░░░
Task 2.3 (캐릭터)          7시간   █████░░░░░░░░░░░░░░░░░░░
Task 3.1-3.3 (심화)        2시간   ██░░░░░░░░░░░░░░░░░░░░░░

총계: 75시간 (3주 기준 25시간/주 또는 10시간/일)
```

---

## 📅 5. 주간 진행 일정

### Week 1 (3/3 ~ 3/9)

**월요일 (3/3)**
- [ ] Steve: 전투 시스템 최종 결정
- [ ] 기획팀: 카드 비용 기준표 작성
- [ ] 아트팀: 몬스터 컨셉 아트 시작

**화요일-목요일 (3/4 ~ 3/6)**
- [ ] 기획팀: 카드 풀 50% 작성
- [ ] 기획+아트: 몬스터 50개 이름 정의
- [ ] 밸런스팀: 체력 곡선 그래프 작성

**금요일 (3/7)**
- [ ] 기획팀: 카드 풀 100% 완료
- [ ] 기획+아트: 몬스터 설계 100% 완료
- [ ] 주간 보고 (Atlas에게)

---

### Week 2 (3/10 ~ 3/16)

**월요일-수요일 (3/10 ~ 3/12)**
- [ ] 기획팀: 유물 시스템 설계
- [ ] 밸런스팀: 경제 수치 밸런싱
- [ ] 기획팀: 캐릭터 3-5개 설계

**목요일-금요일 (3/13 ~ 3/14)**
- [ ] 최종 검증 및 보고
- [ ] 주간 보고

---

### Week 3 (3/17 ~ 3/23)

**월요일-금요일 (3/17 ~ 3/23)**
- [ ] 엘리트 상세 설계
- [ ] 승천 모드 (0-20 단계)
- [ ] 노드 인터랙션
- [ ] 최종 밸런싱

**금요일 (3/23)**
- [ ] Phase 3 최종 완료
- [ ] 모든 문서 아카이빙
- [ ] Phase 4 준비 시작

---

## 🔗 6. 모든 문서 위치

### 기획 문서 경로
```
/Users/stevemacbook/Projects/geekbrox/teams/game/workspace/design/dream-collector/
├─ 01_vision/
│  └─ 00_INTEGRATED_GAME_CONCEPT.md
├─ 02_core_design/
│  ├─ TAROT_SYSTEM_GUIDE.md
│  └─ CARD_FUNCTION_DESIGN_GUIDE.md
├─ 03_implementation_guides/combat/
│  ├─ ATB_Implementation_Guide.md
│  ├─ TurnBased_Implementation_Guide.md
│  └─ Cursor_Dual_Combat_Guide.md
├─ 04_narrative_and_lore/
│  ├─ STORY_LEVEL_DESIGN_CONCEPT.md
│  ├─ STORY_CONCEPT_GUIDE.md
│  └─ DREAM_REFERENCES.md
└─ 05_development_tracking/
   ├─ PROGRESS.md
   ├─ DEVELOPMENT_CHECKLIST.md
   └─ TECH_DECISIONS.md
```

### 최상위 프로젝트 문서
```
/Users/stevemacbook/Projects/geekbrox/
├─ PHASE3_DETAILED_TASKS.md ← 각 업무 상세 가이드
├─ PHASE3_REFERENCE_GUIDE.md ← 참조 자료 모음 (지금 읽는 문서!)
├─ PHASE3_NEXT_TASKS.md ← 전체 계획 및 로드맵
├─ TEAM_WORKFLOWS.md ← 팀 구성 및 역할
└─ AI_AGENTS_AND_WORKFLOW.md ← 에이전트 상세 정의
```

---

## ✅ 7. 빠른 참조 체크리스트

### 나는 지금...

- [ ] **전투 시스템을 결정해야 한다**
  - 읽기: Task 1.1 섹션 + 2개 구현 가이드
  - 시간: 2시간
  - 산출: 최종 선택 결정

- [ ] **카드 풀을 설계해야 한다**
  - 읽기: Task 1.2 섹션 + 기존 카드 가이드
  - 시간: 21시간
  - 산출: CARD_POOL.md + CARD_MASTER.xlsx

- [ ] **몬스터를 설계해야 한다**
  - 읽기: Task 1.3 섹션 + 스토리 문서
  - 시간: 25시간
  - 산출: ENEMY_DESIGN.md + ENEMY_MASTER.xlsx

- [ ] **유물 시스템을 만들어야 한다**
  - 읽기: Task 2.1 섹션
  - 시간: 8시간
  - 산출: RELIC_SYSTEM.md + RELIC_MASTER.xlsx

- [ ] **경제 수치를 밸런싱해야 한다**
  - 읽기: Task 2.2 섹션
  - 시간: 10시간
  - 산출: ECONOMY_BALANCE.md

- [ ] **새 캐릭터를 설계해야 한다**
  - 읽기: Task 2.3 섹션
  - 시간: 7시간
  - 산출: CHARACTER_DESIGN.md

---

## 📞 도움말

**Q: 어디서부터 시작해야 하나?**  
A: 📌 PHASE3_DETAILED_TASKS.md의 Task 1.1 (전투 시스템 결정)부터. 이것이 모든 것의 기초입니다.

**Q: 카드를 몇 개나 만들어야 하나?**  
A: 50-100개. 게임 규모에 따라 결정하되, 보통 60-80개가 적당합니다.

**Q: 몬스터는 각 Act마다 몇 개씩?**  
A: Act 1: 15-20개, Act 2: 20-25개, Act 3: 15-20개. 총 50-70개.

**Q: 참고할 게임이 뭘까?**  
A: Slay the Spire (카드 밸런싱), Monster Train (조합), Peglin (효과). 이 3개를 분석하면 충분합니다.

---

**문서 작성일**: 2026-02-28  
**최종 업데이트**: 2026-02-28  
**다음 검토**: 2026-03-03 (전투 시스템 결정 후)
