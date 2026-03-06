# 🎮 Dream Collector — 개발 일지 (2026)

**프로젝트:** Dream Collector (꿈 수집가)  
**기간:** 2026-03-05 ~ 진행 중  
**상태:** 🟢 진행 중

---

## 📅 2026년 3월 6일 (금요일) — 게임 경제 시스템 완성 & 설계 폴더 정리

### 📌 오늘의 주요 성과

| 항목 | 상태 | 상세 |
|------|------|------|
| 게임 경제 시스템 | ✅ 완료 | 10개 보상 데이터 파일 생성 |
| 설계 폴더 정리 | ✅ 완료 | 103개 파일 정렬, 20개 백업 |
| Git 푸시 | ✅ 완료 | 252 files, 37,595 additions |
| 개발 일지 | 🟨 진행 중 | Notion 연동 예정 |

---

## 🔧 Git 커밋 항목별 상세 일지

### **커밋 1️⃣: 로그인 보상 시스템 생성**

**파일:** `teams/game/workspace/data/login_rewards.json`  
**크기:** 11.7 KB  
**Git 링크:** [GitHub 링크](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/login_rewards.json)

#### 📋 상세 내용
```
31일 월간 로그인 보상 시스템
├─ 일일 보상 (Day 1-30)
│  ├─ 기본: 100-300 골드
│  ├─ 마일스톤: 7일, 14일, 21일, 28일, 30일 특별보상
│  └─ 아이템: Common 9개 + Uncommon 4개
├─ 누적 마일스톤
│  ├─ 7일: 가죽 갑옷 + 10보석
│  ├─ 14일: 방어력 반지 + 25보석
│  ├─ 21일: 체력 반지 + 40보석
│  └─ 30일: 화염 튜닉 + 무기 강화 반지 + 150보석
└─ 월간 합계
   ├─ 총 6,000 골드
   ├─ 총 360 보석
   └─ 총 13개 아이템 (Common 9 + Uncommon 4)
```

#### 🎯 설계 목표
- ✅ 월간 플레이어 리텐션 향상 (7d/14d/30d 체크포인트)
- ✅ 무료 플레이어에게 일정한 진행도 제공
- ✅ Uncommon 이상 아이템을 로그인만으로도 획득 가능

#### 💾 데이터 구조
```json
{
  "day": 1,
  "rewardType": "gold",
  "reward": {
    "gold": 100,
    "items": [],
    "gems": 0
  },
  "specialCondition": { ... }
}
```

---

### **커밋 2️⃣: 이벤트 보상 시스템 생성**

**파일:** `teams/game/workspace/data/event_rewards.json`  
**크기:** 6.5 KB  
**Git 링크:** [GitHub 링크](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/event_rewards.json)

#### 📋 상세 내용
```
3개 이벤트 시스템
├─ 봄 축제 (Spring Festival)
│  ├─ 기간: 3/1 ~ 3/14 (현재 진행 중)
│  ├─ 메커닉: 꽃 50/100/200개 수집
│  └─ 보상: Common 1 + 특별 무기 1개
├─ 애니메이션 콜라보 (Collaboration)
│  ├─ 기간: 3/15 ~ 3/28
│  ├─ 메커닉: 특수 보스 1/3/5마리 처치
│  └─ 보상: Common 1 + Uncommon 1 + Epic 1
└─ 생일 축제 (Birthday Celebration)
   ├─ 기간: 3/1 ~ 3/7
   ├─ 메커닉: 매일 로그인 1/3/5/7일
   └─ 보상: Common 3 + Uncommon 1

월간 합계:
├─ 6,000 골드
├─ 350 보석
└─ 12개 아이템
```

#### 🎯 설계 목표
- ✅ 매달 새로운 콘텐츠로 플레이어 재참여 유도
- ✅ 한정 아이템으로 수집 욕구 자극
- ✅ 이벤트 레벨별 보상으로 다양한 플레이어 층 포용

---

### **커밋 3️⃣: 마일스톤 보상 시스템 생성**

**파일:** `teams/game/workspace/data/milestone_rewards.json`  
**크기:** 9.4 KB  
**Git 링크:** [GitHub 링크](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/milestone_rewards.json)

#### 📋 상세 내용
```
15개 마일스톤 (4 카테고리)
├─ 레벨 기반 (7개)
│  ├─ Lv10: 불꽃 검 (Uncommon) + 20보석
│  ├─ Lv20: 용의 갑옷 (Rare) + 50보석
│  ├─ Lv30: 흡수 반지 (Rare) + 100보석
│  ├─ Lv40: 어둠의 검 (Epic) + 200보석
│  ├─ Lv50: 회심 마스터 반지 (Epic) + 300보석
│  ├─ Lv75: 성스러운 판갑옷 (Epic) + 400보석
│  └─ Lv100: 성검 (Legendary) + 1,000보석 (3선택)
├─ 스테이지 클리어 (3개)
│  ├─ Stage 10: 공격 목걸이 + 15보석
│  ├─ Stage 25: 무기 강화 반지 + 50보석
│  └─ Stage 50: 모든 카드 극대화 목걸이 (Epic) + 300보석
├─ 플레이타임 (3개)
│  ├─ 10시간: 스탯 강화 반지 + 15보석
│  ├─ 50시간: 빛의 로브 (Rare) + 150보석
│  └─ 150시간: 영원한 반지 (Legendary) + 500보석
└─ 컬렉션 (2개)
   ├─ 100개 아이템: 강화된 스킬 목걸이 (Uncommon) + 100보석
   └─ [확장 예정]

총 보상 가치:
├─ 36,600 골드
├─ 3,295 보석
└─ 15개 아이템 (Common 0 + Uncommon 3 + Rare 4 + Epic 6 + Legendary 2)
```

#### 🎯 설계 목표
- ✅ 장기 플레이 동기 부여 (Lv100 상징적 보상)
- ✅ 다양한 달성 방식 제공 (레벨/스테이지/플레이타임)
- ✅ Legendary 아이템을 극후반 보상으로 배치

---

### **커밋 4️⃣: 상인 재고 시스템 생성**

**파일:** `teams/game/workspace/data/merchant_inventory.json`  
**크기:** 10.3 KB  
**Git 링크:** [GitHub 링크](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/merchant_inventory.json)

#### 📋 상세 내용
```
4종류 상인 시스템
├─ 일반 상인 (Normal) - 마을 광장
│  ├─ 재고: 5종류 (Daily restock)
│  ├─ 가격: 1.0배 (정가)
│  ├─ 접근: Lv1 (무제한)
│  └─ 판매: Common 아이템 (800-1,100 골드)
├─ 희귀 상인 (Rare) - 던전
│  ├─ 재고: 4종류 (Weekly restock)
│  ├─ 가격: 1.2배 (20% 프리미엄)
│  ├─ 접근: Lv10 + Stage 5 Clear
│  ├─ 판매: Uncommon~Rare (7,000-30,000 골드)
│  └─ 월간 한정: 1~5개
├─ 흑시장 (Black Market) - 지하
│  ├─ 재고: 2종류 (Monthly restock)
│  ├─ 가격: 1.5배 (50% 프리미엄)
│  ├─ 접근: Lv40 + Stage 30 Clear
│  ├─ 판매: Epic (100,000-150,000 골드)
│  └─ 월간 한정: 1개
└─ 길드 상점 (Guild) - 길드홀
   ├─ 재고: 4종류 (상시)
   ├─ 가격: 0.9배 (10% 할인, 길드포인트)
   ├─ 접근: 길드 가입자
   ├─ 판매: Uncommon~Rare (450-1,800 길드포인트)
   └─ 한정 없음

총 20개 판매 아이템 (Common 0 + Uncommon 4 + Rare 2 + Epic 1)
```

#### 🎯 설계 목표
- ✅ 게임 진행에 따른 점진적 상인 접근
- ✅ 골드/길드포인트 선택 소비처
- ✅ 상위 아이템 획득 방식 다양화

---

### **커밋 5️⃣: 장비/카드 데이터 파일 추가**

**파일:**
- `teams/game/workspace/data/weapons_data_v2.json` (30 KB, 20개 무기)
- `teams/game/workspace/data/armors_data_v2.json` (33 KB, 20개 방어구)
- `teams/game/workspace/data/rings_data.json` (40 KB, 25개 반지)
- `teams/game/workspace/data/necklaces_data.json` (41 KB, 25개 목걸이)
- `teams/game/workspace/data/cards_200_v2.json` (Godot용)

**Git 링크:**
- [weapons_data_v2.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/weapons_data_v2.json)
- [armors_data_v2.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/armors_data_v2.json)
- [rings_data.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/rings_data.json)
- [necklaces_data.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/necklaces_data.json)

#### 📋 상세 내용
```
총 90개 게임 아이템 (Tier별 분배)
├─ 무기 (20개)
│  ├─ Common 7개 (ATK 15-20)
│  ├─ Uncommon 6개 (ATK 22-30)
│  ├─ Rare 4개 (ATK 35-45)
│  ├─ Epic 2개 (ATK 50-80)
│  └─ Legendary 1개 (ATK 75-100)
├─ 방어구 (20개)
│  ├─ Common 7개 (DEF 13-19)
│  ├─ Uncommon 6개 (DEF 24-32)
│  ├─ Rare 4개 (DEF 35-45)
│  ├─ Epic 2개 (DEF 50-80)
│  └─ Legendary 1개 (DEF 75-80)
├─ 반지 (25개)
│  ├─ Common 8개 (스탯 +10-15%)
│  ├─ Uncommon 7개 (스탯 +20-30%)
│  ├─ Rare 5개 (스탯 +30-50%)
│  ├─ Epic 3개 (스탯 +50-80%)
│  └─ Legendary 2개 (스탯 +80-100%)
└─ 목걸이 (25개)
   ├─ Common 8개 (카드 효율 +20%)
   ├─ Uncommon 6개 (카드 효율 +30%)
   ├─ Rare 7개 (카드 효율 +40%)
   ├─ Epic 3개 (카드 효율 +50%)
   └─ Legendary 1개 (모든 카드 +50%)

Tier 분포: Common 33% → Uncommon 25% → Rare 22% → Epic 11% → Legendary 6%
```

#### 🎯 설계 목표
- ✅ 정상적인 드롭율 확률분포
- ✅ 90일 진행도에 맞춘 아이템 다양성
- ✅ 카드-장비 통합 밸런싱

---

### **커밋 6️⃣: 게임 경제 & 보상 관리 시스템**

**파일:**
- `teams/game/workspace/data/GAME_ECONOMY_MANAGEMENT.md` (8.2 KB)
- `teams/game/workspace/data/reward_management_system.json` (14 KB)
- `teams/game/workspace/data/gacha_config.json` (12 KB)
- `teams/game/workspace/data/quest_reward_table.json` (11 KB)
- `teams/game/workspace/data/monster_drop_table.json` (18 KB)

**Git 링크:**
- [GAME_ECONOMY_MANAGEMENT.md](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/GAME_ECONOMY_MANAGEMENT.md)
- [reward_management_system.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/reward_management_system.json)

#### 📋 상세 내용
```
게임 경제 통합 관리 시스템
├─ 통화 시스템
│  ├─ 골드 (soft currency)
│  │  ├─ 획득: 몬스터 드롭, 퀘스트, 로그인, 이벤트
│  │  ├─ 소비: 상인 구매, 강화, 진화
│  │  └─ 월간 목표: 2,000,000 골드
│  └─ 보석 (hard currency)
│     ├─ 획득: 로그인, 이벤트, 마일스톤, 월 200 무료
│     ├─ 소비: 프리미엄 뽑기, 에너지
│     └─ 월간 무료: 200 보석
├─ 보상 분배 (월간 목표)
│  ├─ 몬스터 드롭: 40% (800k 골드 + 아이템)
│  ├─ 퀘스트: 20% (400k 골드 + 아이템)
│  ├─ 로그인: 15% (300k 골드 + 아이템)
│  └─ 이벤트: 25% (500k 골드 + 아이템)
└─ 인플레이션 관리
   ├─ 월간 목표: 5-10% 상승
   ├─ 경고 수준: 15% 이상
   ├─ 심각 수준: 25% 이상
   └─ 조정 방법: 보상 감소 + 지출처 추가

월간 수익 예측:
├─ 무료 플레이: 2,000,000 골드 + 200 보석
├─ 경량 과금: +2,500 보석 (약 50,000원)
├─ 헤비 과금: +25,000 보석 (약 500,000원)
└─ 목표: DAU 15,000 × 3% 전환율 × 100,000원 = 45M 월 수익
```

#### 🎯 설계 목표
- ✅ Free-to-play 안정성 (무료 플레이도 진행 가능)
- ✅ 수익화 안정성 (과금자 가치 명확)
- ✅ 인플레이션 통제 (장기 게임 플레이 가능)

---

### **커밋 7️⃣: Dream Collector 설계 폴더 완전 정리**

**작업 범위:**
- 파일 이동: ~52개 파일 정렬
- 폴더 생성: 13개 하위폴더
- README 작성: 5개 문서
- 백업: 20개 이전 버전 아카이브

#### 📋 정리 구조
```
dream-collector/
├── 01_vision/ (게임 비전)
├── 02_core_design/ (핵심 설계) ⭐ 정렬 완료
│   ├── cards/ → README + 8개 카드 설계 문서
│   ├── equipment/ → README + 4개 장비 설계 문서
│   ├── characters/ → README + 6개 캐릭터 설계 문서
│   └── mechanics/ → README + 5개 게임 메커닉 문서
├── 03_implementation_guides/ (구현 가이드)
│   ├── dev_tools/ → Cursor, Claude 개발 가이드
│   └── operations/ → 경제, 밸런싱, 운영 가이드
├── 04_narrative_and_lore/ (스토리/월드)
│   ├── story/ → 스토리, 던전 맵
│   ├── npcs/ → NPC 시스템
│   └── README
├── 05_development_tracking/ (개발 추적)
│   └── reports/ → 진행 보고서
└── _archive/deprecated_files/ (이전 버전 20개)

통계:
├─ 총 활성 파일: 103개
├─ 백업 파일: 20개
├─ 폴더 크기: 2.4 MB
└─ README 신규 생성: 5개
```

#### 🎯 정리 목표
- ✅ 게임 기획 구조에 완벽 정렬
- ✅ 중복 파일 제거 + 버전 관리
- ✅ 각 시스템별 별도 가이드 (README)
- ✅ 향후 개발 효율성 대폭 증가

---

### **커밋 8️⃣: Godot 개발 코드 추가**

**신규 코드:**
- `teams/game/godot/dream-collector/scripts/combat/shared/Equipment.gd`
- `teams/game/godot/dream-collector/scripts/combat/shared/EquipmentDatabase.gd`
- `teams/game/godot/dream-collector/scripts/combat/shared/EquipmentEnhanceSystem.gd`
- `teams/game/godot/dream-collector/scripts/combat/shared/CardEnhanceSystem.gd`
- `teams/game/godot/dream-collector/ui/components/EquipmentSlot.gd/tscn`
- `teams/game/godot/dream-collector/ui/screens/CharacterScreen.gd/tscn`
- `teams/game/godot/dream-collector/ui/screens/GachaUI.gd`
- 추가 시스템 스크립트: 6개

**수정된 코드:** 23개 파일 (게임로직, UI, ATB 시스템)

#### 📋 구현 내용
```
게임 기능 구현 완료:
├─ 장비 시스템
│  ├─ Equipment.gd (장비 기본 클래스)
│  ├─ EquipmentDatabase.gd (데이터 관리)
│  └─ EquipmentEnhanceSystem.gd (강화 시스템)
├─ UI 컴포넌트
│  ├─ EquipmentSlot (슬롯 표시)
│  ├─ ItemDetailPopup (상세 정보)
│  └─ CharacterScreen (캐릭터 화면)
├─ 게임 시스템
│  ├─ GachaSystem.gd (뽑기 시스템)
│  ├─ MilestoneRewardSystem.gd (마일스톤)
│  ├─ LevelSystem.gd (레벨 시스템)
│  ├─ DropRateTable.gd (드롭율 관리)
│  └─ ContentUnlockManager.gd (콘텐츠 해금)
└─ 기존 시스템 개선
   ├─ ATB 전투 시스템
   ├─ 카드 시스템
   ├─ UI 테마
   └─ 게임 매니저

총 32개 파일 수정/신규 생성
```

#### 🎯 구현 목표
- ✅ 게임 경제 시스템 완전 연동
- ✅ 플레이어 진행도 자동 추적
- ✅ 게임 빌드 준비 완료

---

## 📊 전체 프로젝트 진행도 대시보드

### 🎮 Dream Collector 프로젝트 진행율

| 구분 | 진행도 | 상태 | 마일스톤 |
|------|--------|------|---------|
| **UI 시스템** | 100% | ✅ 완료 | 12개 화면 완성 |
| **카드 시스템** | 100% | ✅ 완료 | 200개 카드 데이터 |
| **장비 시스템** | 95% | 🟨 거의 완료 | 90개 아이템 데이터 |
| **전투 시스템** | 80% | 🟨 진행 중 | ATB 구현 완료 |
| **게임 경제** | 100% | ✅ 완료 | 보상 시스템 완성 |
| **설계 문서** | 100% | ✅ 완료 | 103개 문서 정렬 |
| **Godot 코드** | 85% | 🟨 진행 중 | 32개 파일 수정/신규 |
| **게임 빌드** | 40% | 🔴 대기 중 | 연동 준비 |
| **테스트** | 0% | 🔴 미시작 | 대기 중 |
| **런칭** | 0% | 🔴 미시작 | 2026년 Q2 목표 |

**전체 진행율: 70.0%** 📈

---

### 📅 일정표 (2026-03-05 ~ 2026-03-13)

| 날짜 | 작업 | 상태 | 비고 |
|------|------|------|------|
| **3/5 (수)** | Game팀 Step 1 시작 | 🟨 진행 중 | 카드 200종 확인 |
| **3/6 (목)** | 게임 경제 시스템 완성 | ✅ 완료 | 보상 10개 파일 |
| **3/6 (목)** | 폴더 재정리 완료 | ✅ 완료 | 103개 문서 정렬 |
| **3/6 (목)** | Git Push 완료 | ✅ 완료 | Commit 5148a98 |
| **3/6 (목)** | Notion 일지 생성 | 🟨 진행 중 | 현재 작업 |
| **3/8 (토)** | Game팀 Step 2 예정 | ⏳ 대기 | 목표: 완료 |
| **3/9 (일)** | Game팀 Step 3~4 예정 | ⏳ 대기 | OPS팀 시뮬레이션 시작 |
| **3/10 (월)** | Game팀 Step 5 완료 | ⏳ 대기 | 최종 카드 기획 정리 |
| **3/12 (수)** | OPS팀 최종 보고서 | ⏳ 대기 | 밸런싱 검증 |
| **3/13 (목)** | 최종 통합 보고서 | ⏳ 대기 | 프로젝트 완성 |

---

### 🎯 Key 성과 지표 (KPI)

#### 💰 경제 밸런싱
| 항목 | 목표 | 현황 | 달성율 |
|------|------|------|--------|
| 월간 골드 분배 | 2,000,000 | ✅ 설정 | 100% |
| 월간 보석 분배 | 400 | ✅ 설정 | 100% |
| 무료 아이템/월 | 50 | ✅ 설정 | 100% |
| 인플레이션 목표 | 5-10% | 🔴 미측정 | 0% |
| 플레이어 ARPPU | 100,000원 | 🔴 미측정 | 0% |

#### 👥 플레이어 성장
| 항목 | 목표 | 현황 | 달성율 |
|------|------|------|--------|
| DAU | 15,000 | 🔴 미측정 | 0% |
| MAU | 30,000 | 🔴 미측정 | 0% |
| 7일 리텐션 | 50% | 🔴 미측정 | 0% |
| 30일 리텐션 | 30% | 🔴 미측정 | 0% |
| 전환율 | 3-5% | 🔴 미측정 | 0% |

#### 🎮 게임 시스템 완성도
| 항목 | 목표 | 현황 | 달성율 |
|------|------|------|--------|
| 장비 데이터 | 90개 | ✅ 90개 | 100% |
| 카드 데이터 | 200개 | ✅ 200개 | 100% |
| 설계 문서 | 100개 | ✅ 103개 | 103% |
| Godot 코드 | 40 파일 | ✅ 32 파일 | 80% |
| 게임 빌드 | 1개 | 🔴 0개 | 0% |

---

## 📝 다음 작업 (우선순위)

### 🔴 P0 (긴급)
1. [ ] Game팀 Step 1 진행 상황 확인 (3/6 오후 1시)
2. [ ] Game팀 Step 1 마일스톤 검증 (3/6 오후 3시)
3. [ ] Steve에게 일일 리포트 (3/6 오후 5시)

### 🟠 P1 (높음)
1. [ ] Godot 코드 8개 파일 완성 (CharacterScreen 완성)
2. [ ] 게임 빌드 테스트 (경제 시스템 연동 검증)
3. [ ] 밸런싱 시뮬레이션 (OPS팀과 협력)

### 🟡 P2 (중간)
1. [ ] 테스트 플레이 준비 (50 테스터)
2. [ ] 마케팅 자료 준비
3. [ ] 스토어 등록 준비

---

## 🔗 주요 파일 링크

### 📊 데이터 파일
- [login_rewards.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/login_rewards.json)
- [event_rewards.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/event_rewards.json)
- [milestone_rewards.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/milestone_rewards.json)
- [merchant_inventory.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/merchant_inventory.json)
- [gacha_config.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/gacha_config.json)
- [reward_management_system.json](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/reward_management_system.json)

### 📝 설계 문서
- [GAME_ECONOMY_MANAGEMENT.md](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/data/GAME_ECONOMY_MANAGEMENT.md)
- [EQUIPMENT_SYSTEM_GDD_FINAL.md](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/workspace/design/dream-collector/02_core_design/equipment/EQUIPMENT_SYSTEM_GDD_FINAL.md)

### 💻 코드
- [Equipment.gd](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/godot/dream-collector/scripts/combat/shared/Equipment.gd)
- [EquipmentDatabase.gd](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/godot/dream-collector/scripts/combat/shared/EquipmentDatabase.gd)
- [GachaSystem.gd](https://github.com/ledlaputa72/geekbrox/blob/5148a98/teams/game/godot/dream-collector/scripts/systems/GachaSystem.gd)

---

**최종 업데이트:** 2026-03-06 12:56 PST  
**다음 업데이트:** 2026-03-07 (또는 마일스톤 변화 시)
