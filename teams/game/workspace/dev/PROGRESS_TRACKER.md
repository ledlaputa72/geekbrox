# 📈 Dream Collector - 진행 추적 (Progress Tracker)

> 각 Phase별 상세 진행 상황을 추적합니다.
> 매일 자동 업데이트됩니다.

---

## Phase 1️⃣: UI Foundation ✅ 100% COMPLETE

**목표**: 12개 핵심 화면 프로토타입 완성  
**상태**: ✅ 완료 (2026-02-24)

### 완료 항목
- [x] MainLobby (홈 화면) + DreamItem 컴포넌트
- [x] InRun_v4 (탐험 화면) + 3개 뷰 (ExplorationView, CombatView, ShopView)
- [x] Combat (전투 화면) + CardHandUI + DamageNumber
- [x] DreamCardSelection (가챠 화면) - 3단계 블라인드 픽
- [x] RunPrep (타로 카드 선택)
- [x] VictoryScreen + DefeatScreen + RewardsModal
- [x] DeckBuilder (덱 커스터마이징)
- [x] 기타 (Settings, HowToPlay 등)

### 통계
- **총 파일**: 12개 화면 완성
- **컴포넌트**: 43개
- **총 라인**: 8,210+ 라인
- **개발 시간**: ~40시간

---

## Phase 2️⃣: Visual Assets ✅ 100% COMPLETE

**목표**: 캐릭터/배경/몬스터 스프라이트 + 애니메이션  
**상태**: ✅ 완료 (2026-02-26)

### 완료 항목
- [x] 배경 이미지 (home_bg.png, 8.2MB)
- [x] 플레이어 스프라이트 (player_ani.png, 7.0MB) - 4×4 그리드, 다중 상태
- [x] 플레이어 걷기 전용 (player_walk.png, 5.2MB)
- [x] 몬스터 1 스프라이트 (monster1_ani.png, 6.8MB)
- [x] NPC 1, 2 스프라이트 (7.3MB, 7.9MB)
- [x] Chroma Key 셰이더 (마젠타 투명 처리)
- [x] PlayerSpriteAnimator (공용 애니메이션 컴포넌트)
- [x] HomeHeroSprite (홈 화면 캐릭터)

### 통계
- **에셋 총량**: 43MB (6개 이미지)
- **스프라이트 상태**: 5가지 (IDLE, WALK, ATTACK, HIT, DIE)
- **개발 시간**: ~6시간

---

## Phase 3️⃣: Systems Design 🔄 25% IN PROGRESS

**목표**: 게임의 핵심 시스템 설계 완성  
**상태**: 🔄 진행 중 (2026-02-27 시작)

### 완료 항목 ✅

#### 3.1 Game Vision & Concept
- [x] INTEGRATED_GAME_CONCEPT.md v2.0
  - 게임 정체성: "꿈의 직조인(The Mnemonic Weaver)"
  - 아트 스타일: "정교한 동화"
  - 세계관: "꿈의 바다"
  - 주인공: 녹스(Nox), 기억 상실 캐릭터
  
#### 3.2 Tarot System
- [x] TAROT_SYSTEM_GUIDE.md v2.2
  - 메이저 아르카나 22종 (희귀 17 + 서사 5)
  - 코트 카드 16종 (희귀 8 + 고급 8)
  - 핍 카드 40종 (일반 32 + 고급 8)
  - **총 78장 설정 완료**

#### 3.3 Story & Level Design
- [x] STORY_LEVEL_DESIGN_CONCEPT.md v1.0
  - "금실"(고정 서사) + "은실"(절차적 생성)
  - 3막 구조 확정
  - 콘텐츠 해금 로드맵
  
#### 3.4 Story Plot
- [x] STORY_CONCEPT_GUIDE.md v1.0
  - 3개 플롯 분석 (기억의 건축가, 꿈의 파수꾼, 침묵의 역병)
  - **최종 선택**: "The Mnemonic Weaver" (플롯 1 + 플롯 3 하이브리드)

#### 3.5 Art Style References
- [x] ART_STYLE_GUIDE.md v1.0 (teams/game/workspace/art/)
  - 8개 레퍼런스 게임 + 공식 링크
  - 캐릭터/환경/UI 별 분석

### 미완료 항목 ❌

#### 3.6 Card Pool Design
- [ ] 카드 개수 결정 (목표: 50-100)
- [ ] 각 카드 이름, 비용, 효과
- [ ] 등급 시스템 (Common/Uncommon/Rare/Epic)
- [ ] 카드 획득 로드맵
- **예상 완료**: 2026-03-05
- **문서**: `CARD_POOL.md` (미작성)

#### 3.7 Enemy & Boss Design
- [ ] 3막 × 일반/엘리트/보스 목록 (목표: 50-70종)
- [ ] 각 몬스터: 체력, 의도, 공격 패턴
- [ ] 보스 스토리 연결고리
- **예상 완료**: 2026-03-07
- **문서**: `ENEMY_DESIGN.md`, `BOSS_NARRATIVE.md` (미작성)

#### 3.8 Relic System
- [ ] 유물 목록 (20-30)
- [ ] 유물 등급 & 획득 방식
- **예상 완료**: 2026-03-10
- **문서**: `RELIC_SYSTEM.md` (미작성)

#### 3.9 Economy Balance
- [ ] 골드 보상량 책정
- [ ] 상점 가격 결정
- [ ] 강화/제거/변형 비용
- **예상 완료**: 2026-03-12
- **문서**: `ECONOMY_BALANCE.md` (미작성)

#### 3.10 Playable Characters
- [ ] 초기 3-5 캐릭터 설계
- [ ] 캐릭터별 시작 카드 풀
- [ ] 캐릭터별 스토리 라인
- **예상 완료**: 2026-03-14
- **문서**: `CHARACTER_DESIGN.md` (미작성)

### Phase 3 진행률
```
Vision & Concept      ██████████░░░░░░░░░░ 100%
Tarot System          ██████████░░░░░░░░░░ 100%
Story & Level         ██████████░░░░░░░░░░ 100%
Card Pool Design      ░░░░░░░░░░░░░░░░░░░░ 0%
Enemy Design          ░░░░░░░░░░░░░░░░░░░░ 0%
Relic System          ░░░░░░░░░░░░░░░░░░░░ 0%
Economy Balance       ░░░░░░░░░░░░░░░░░░░░ 0%
Character Design      ░░░░░░░░░░░░░░░░░░░░ 0%

부분 평균: 25%
```

---

## Phase 4️⃣: Combat Implementation ⏸️ 0% WAITING

**목표**: 선택된 전투 시스템 구현  
**상태**: ⏸️ 블로킹 (전투 시스템 최종 결정 대기)

### 결정 필요
- [ ] ATB vs Turn-Based 최종 선택
- **예상 완료**: 2026-03-03

### 예상 작업
- CombatManager.gd 리팩토링 (선택된 시스템에 맞게)
- CardEffectSystem.gd 구현
- EnemyAI.gd 구현
- 카드 효과 해석 엔진

---

## Phase 5️⃣: Polish & Launch 🔲 0% NOT STARTED

**목표**: 버그 수정, 튜닝, 스토어 준비  
**상태**: 🔲 아직 시작 안 함

### 예상 작업
- 성능 최적화
- 사운드 & 음악 추가
- 튜토리얼 개선
- 진행 저장/로드 시스템
- 국제화 (한글/영어 완성)

---

## 📊 주요 지표

| 지표 | 값 | 목표 |
|------|-----|------|
| **전체 진행률** | 25% | 100% |
| **설계 완료율** | 60% | 100% |
| **구현 완료율** | 5% | 100% |
| **총 개발 시간** | ~50시간 | TBD |
| **예상 출시일** | 2026-06-30 | TBD |

---

## 🚨 주요 블로킹 항목

1. **[CRITICAL]** 전투 시스템 최종 결정
   - 마감: 2026-03-03
   - 영향: Phase 4, 카드 설계, 몬스터 설계 모두 영향
   - 담당: Steve PM

---

_Last updated: 2026-02-27 by Atlas PM_
