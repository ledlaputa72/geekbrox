# 게임 디자인 문서 (GDD) - Dream Collector

> **Status**: ✅ Active Development (2026-02-26)  
> **Version**: 0.2.0 (UI Complete, Combat System Pending Decision)  
> **Last Updated**: 2026-02-26

---

## 📌 게임 개요

### 기본 정보
- **제목**: Dream Collector (꿈 수집가)
- **장르**: Roguelike Deckbuilding RPG
- **플랫폼**: Mobile (iOS/Android), Steam (향후)
- **엔진**: Godot 4.3 (GDScript)
- **해상도**: 390×844 (Portrait, Mobile-first)
- **타겟 유저**: 
  - 1차: 로그라이크 덱빌딩 팬 (Slay the Spire, Monster Train)
  - 2차: 방치형 게임 유저 (AFK Arena, Idle Heroes)
  - 3차: 감성 스토리텔링 선호층

### 핵심 경험 (Core Fantasy)
> "나만의 꿈을 수집하고, 카드 덱을 구성해 악몽과 싸우는 모험"

**3가지 핵심 요소**:
1. 🎴 **덱빌딩**: 꿈 카드를 수집하고 시너지를 만들어 강력한 덱 구축
2. 🌙 **탐험**: 3단계 선택(시작-여정-종료)으로 매번 다른 여정 체험
3. ⚔️ **전투**: [ATB vs 턴제 **미결정**] 전략적 카드 플레이로 악몽 처치

---

## 🎮 핵심 루프 (Core Loop)

### 단기 루프 (2-5분 per run)
```
MainLobby → [꿈 시작]
    ↓
DreamCardSelection (3-stage tarot card pick)
  • Stage 1: 시작 카드 선택 (3개 중 1개)
  • Stage 2: 여정 카드 선택 (3개 중 1개)
  • Stage 3: 종료 카드 선택 (3개 중 1개)
    ↓
InRun (Active Journey)
  • 노드 진행: 전투 ⚔️ / 상점 🛒 / 휴식 ❤️ / 보스 💀
  • 시간 흐름: 60초당 1노드 (자동)
  • Combat: 카드 사용 → 적 처치 → 보상
  • Event: 선택지 이벤트 (랜덤)
    ↓
Run Complete → Rewards → MainLobby
```

### 중기 루프 (30-60분 per session)
```
여러 Run 반복
    ↓
Gold/Gems 축적
    ↓
Shop: 새 카드 구매
    ↓
DeckBuilder: 덱 구성 변경
    ↓
UpgradeTree: 영구 업그레이드 (HP+, 카드+, etc.)
    ↓
더 강한 덱으로 어려운 Run 도전
```

### 장기 루프 (수일~수주)
```
카드 컬렉션 완성
    ↓
모든 꿈 카드 unlock
    ↓
최적 덱빌드 연구
    ↓
High-difficulty runs
    ↓
리더보드/업적 달성
```

---

## 🖼️ 인터페이스 시스템 (UI Architecture)

### 화면 구조 (12 Screens)

#### 1. Meta Screens (메타 게임 허브)
**공통 요소**: BottomNav (5-tab navigation bar)

| Screen | 경로 | 기능 | 상태 |
|--------|------|------|------|
| **MainLobby** | `ui/screens/MainLobby.tscn` | 홈 허브, 모든 메뉴 진입점 | ✅ 완료 |
| **CardLibrary** | `ui/screens/CardLibrary.tscn` | 수집한 카드 보기, 필터/정렬 | ✅ 완료 |
| **DeckBuilder** | `ui/screens/DeckBuilder.tscn` | 덱 편집 (30장 제한) | ✅ 완료 |
| **UpgradeTree** | `ui/screens/UpgradeTree.tscn` | 영구 업그레이드 (스킬 트리) | ✅ 완료 |
| **Progress** | `ui/screens/Progress.tscn` | 과거 꿈 로그, 통계 | ✅ 완료 |
| **Shop** | `ui/screens/Shop.tscn` | 카드/아이템 구매 | ✅ 완료 |
| **Settings** | `ui/screens/Settings.tscn` | 설정, 크레딧 | ✅ 완료 |

#### 2. Run Screens (런 진행 중)
**공통 요소**: 없음 (전용 UI)

| Screen | 경로 | 기능 | 상태 |
|--------|------|------|------|
| **DreamCardSelection** | `ui/screens/DreamCardSelection.tscn` | 3단계 타로 카드 선택 (뽑기) | ✅ 완료 |
| **InRun_v4** | `ui/screens/InRun_v4.tscn` | 액티브 런 게임플레이 | ✅ 완료 |

#### 3. Utility Screens
| Screen | 경로 | 기능 | 상태 |
|--------|------|------|------|
| **RunResults** | `ui/screens/RunResults.tscn` | 런 종료 결과, 보상 | ✅ 완료 |
| **CardDetail** | `ui/screens/CardDetail.tscn` | 카드 확대 보기 | ✅ 완료 |
| **DialogModal** | `ui/screens/DialogModal.tscn` | 이벤트/선택지 다이얼로그 | ✅ 완료 |

---

### 핵심 UI 컴포넌트

#### BottomNav (통합 네비게이션)
**위치**: `ui/components/BottomNav.tscn/gd`

```
┌────────────────────────────────────────┐
│  🏠    🎴    🌳    📚    🛒          │  ← 5 tabs
└────────────────────────────────────────┘
```

**탭 구성**:
- Tab 0: Home (MainLobby)
- Tab 1: Cards (CardLibrary)
- Tab 2: Upgrade (UpgradeTree)
- Tab 3: Progress (Progress)
- Tab 4: Shop (Shop)

**시그널**: `tab_pressed(tab_index: int)`

**규칙**:
- 모든 메타 화면에 통합
- 인라인 복사 금지 (항상 컴포넌트 재사용)
- 현재 활성 탭 하이라이트 (노란색)

---

#### CharacterNode (전투 유닛)
**위치**: `ui/components/CharacterNode.tscn/gd`

```
      [🧙]  ← Emoji sprite placeholder
   ━━━━━━━━━  ← HP bar (green/red)
   HP: 80/100
```

**기능**:
- HP 동기화 (CombatManager signal)
- 데미지 숫자 표시 (DamageNumber spawn)
- 피격 효과:
  - Shake (위치 ±8px, 회전 ±6°, 0.4초)
  - Red Flash (색상 변조, 0.3초)
- 힐링 효과: 초록 숫자 + 부드러운 확대

**사용처**:
- InRun_v4 전투 씬 (플레이어 + 적 3마리)

---

#### DamageNumber (떠다니는 데미지)
**위치**: `ui/components/DamageNumber.tscn/gd`

```
     ╱  -15  ╲   ← 빨간색 (적에게 피해)
    ╱        ╲
   ╱ 　　　　  ╲
```

**색상 규칙**:
- 빨강: 적에게 피해
- 주황: 자신에게 피해
- 초록: 힐링

**애니메이션**:
- 위로 60px 이동 (1.0초)
- 페이드아웃 (0.5초)
- Scale 1.0 → 1.2 → 1.0

---

#### RunProgressBar (여정 진행바)
**위치**: `ui/components/RunProgressBar.tscn/gd`

```
[🚪] ─⚔️── 🛒 ──⚔️── ❤️ ──⚔️── 💀
 ↑                              ↑
시작                            보스
```

**노드 타입**:
- ⚔️ 전투 (Combat)
- 🛒 상점 (Shop)
- ❤️ 휴식 (Rest)
- 🎁 보물 (Treasure)
- 💀 보스 (Boss)

**기능**:
- GameManager.dream_nodes 기반 자동 생성
- 현재 노드 하이라이트 (노란색 테두리)
- 클릭 시 노드 정보 툴팁

---

## 🎴 덱빌딩 시스템

### 카드 구조

#### 카드 타입
1. **공격 카드** (Attack)
   - 직접 피해 (단일 타겟 / 다중 타겟)
   - 예: "화염구", "검격", "독침"

2. **스킬 카드** (Skill)
   - 버프/디버프, 드로우, 에너지 조작
   - 예: "강화", "방어 태세", "카드 드로우"

3. **파워 카드** (Power)
   - 지속 효과 (턴 종료까지 or 전투 종료까지)
   - 예: "불타는 혼", "가시 갑옷", "집중"

#### 카드 속성
```gdscript
{
  "id": "card_001",
  "name": "화염구",
  "type": "attack",
  "cost": 2,           # Energy cost
  "rarity": "common",  # common, uncommon, rare, epic
  "description": "적에게 8 피해를 준다.",
  "effects": [
    {"type": "damage", "value": 8, "target": "single_enemy"}
  ],
  "upgradable": true
}
```

### 덱 구성
- **덱 크기**: 20-40장 (시작 30장)
- **중복 제한**: 동일 카드 최대 3장
- **시작 덱**: 기본 카드 10장 (공격 5, 방어 3, 스킬 2)

### 카드 획득 방법
1. **런 중**:
   - 전투 승리 보상 (3장 중 1장 선택)
   - 상점 구매 (Gold 소모)
   - 이벤트 보상

2. **메타 게임**:
   - Shop에서 Gems로 구매
   - 업적 달성 보상

---

## ⚔️ 전투 시스템

### ⚠️ **현재 상태: ATB vs 턴제 미결정**

**결정 대기 중인 사항**:
1. **ATB (Active Time Battle)** 방식 유지
   - 현재 구현: `autoload/CombatManager.gd` (400 lines)
   - 장점: 빠른 템포, 모바일 친화적, 오토 배틀 가능
   - 단점: 전략 깊이 부족, Slay the Spire 팬층 이탈 가능성

2. **Turn-Based** 방식 전환
   - Slay the Spire 스타일 (플레이어 턴 ↔ 적 턴)
   - 장점: 전략 깊이 2-3배, 드래그 앤 드롭 UI, 적 인텐트 시스템
   - 단점: 개발 시간 6-8주, 드래그 UI 복잡도, 모바일 최적화 어려움

**참고 문서**:
- `~/Projects/geekbrox/teams/game/workspace/design/ATB_Implementation_Guide.md`
- `~/Projects/geekbrox/teams/game/workspace/design/TurnBased_Implementation_Guide.md`
- `~/Projects/geekbrox/teams/game/workspace/design/Cursor_Dual_Combat_Guide.md` (작성 예정)

**Steve의 최종 결정 필요!**

---

### 현재 구현된 시스템 (ATB 기준)

#### 전투 흐름
```
전투 시작
  ↓
ATB 게이지 충전 (Speed 기반)
  ↓
게이지 100% 도달 → 턴 활성화
  ↓
플레이어: 카드 사용 (에너지 소모)
  ↓
효과 적용 → 적 피해 → HP 업데이트
  ↓
적 턴: AI가 행동 선택 → 공격
  ↓
플레이어 피해 → HP 업데이트
  ↓
승리 조건 체크:
  • 적 전멸 → 승리 → 보상
  • 플레이어 사망 → 패배 → RunResults
  ↓
다음 전투 or 런 종료
```

#### 에너지 시스템
- **최대 에너지**: 3
- **회복**: 시간 기반 (손에 든 카드 수에 따라 속도 변화)
  - 0-2장: 빠름
  - 3-5장: 보통
  - 6+장: 느림
- **카드 비용**: 0-3 에너지

#### 오토 배틀
- **AutoBattleAI**: 카드 우선순위 기반 자동 플레이
- **속도 조절**: 1×, 2×, 3× (시그널: `speed_changed`)

---

## 🌙 DreamCardSelection (뽑기 시스템)

### 3단계 선택 흐름

```
MainLobby → [꿈 시작 버튼]
    ↓
┌─────────────────────────────────────────┐
│  Stage 1: 시작 (START)                   │
│                                         │
│    [🔮]     [🔮]     [🔮]               │  ← 3장 카드 (뒷면)
│                                         │
│  [카드 1 클릭]                           │
│    ↓ 카드 20px 아래 이동 (선택 표시)       │
│  [카드 1 재클릭]                          │
│    ↓ 확정! 나머지 2장 사라짐               │
│    ↓ 선택된 카드 뒤집어서 앞면 공개        │
│                                         │
│  "✅ 시작: 모험의 시작" (로그 표시)        │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  Stage 2: 여정 (JOURNEY)                 │
│  (동일 프로세스)                          │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│  Stage 3: 종료 (END)                     │
│  (동일 프로세스)                          │
└─────────────────────────────────────────┘
    ↓
[꿈 탐험 시작 버튼] 페이드인
    ↓
InRun_v4 (생성된 노드 기반 여정 시작)
```

### 카드 정보 구조
```gdscript
{
  "id": "start_1",
  "name": "모험의 시작",
  "emoji": "🚪",
  "description": "평화로운 시작. 상점이 있어 준비할 수 있다.",
  "nodes": [
    {"type": "shop", "emoji": "🛒"},
    {"type": "combat", "emoji": "⚔️"}
  ],
  "difficulty": "easy",     # easy, normal, hard
  "rewards": {"gold": 50}
}
```

### 카드 인터랙션 규칙
1. **첫 클릭**: 카드 20px 아래 이동 (preview)
2. **두 번째 클릭**: 
   - 선택 확정
   - 나머지 카드 페이드아웃 (0.4초)
   - 선택된 카드 뒤집기 애니메이션 (0.6초)
   - 앞면 공개 (이모지 → 실제 일러스트)
3. **로그 표시**: DreamItem 스타일 블록 (상단 색상 바)

### GameManager 통합
- `set_dream_cards(cards: Array)`: 3개 카드 저장
- `get_dream_nodes() -> Array`: 생성된 노드 목록 (InRun_v4 사용)
- `get_dream_time_logs() -> Array`: 시간별 탐험 로그

---

## 🎯 InRun (액티브 런 게임플레이)

### 화면 구조
```
┌─────────────────────────────────────────┐
│  TopArea (탐험/전투/상점 전환)            │
│                                         │
│  ExplorationView:                       │
│    RunProgressBar (노드 진행바)          │
│    TimeDisplay (경과 시간)               │
│                                         │
│  CombatView:                            │
│    [적1] [적2] [적3]                    │
│         [플레이어]                       │
│                                         │
│  ShopView:                              │
│    [카드 목록 + 구매 버튼]               │
└─────────────────────────────────────────┘
┌─────────────────────────────────────────┐
│  BottomArea (로그/전투UI/상점UI)          │
│                                         │
│  EventLog:                              │
│    "⚔️ 전투가 시작된다!"                  │
│    "💀 고블린을 만났다."                  │
│                                         │
│  CombatUI:                              │
│    [손패 카드 5장]                       │
│    [에너지 3/3] [덱 25] [버림 3]         │
│    [항복] [자동전투 ON/OFF] [속도 2×]    │
│                                         │
│  ShopUI:                                │
│    [Gold: 150] [Gems: 5]                │
│    [구매 확인 버튼]                      │
└─────────────────────────────────────────┘
```

### 시간 흐름 시스템
- **기본**: 60초당 1노드 자동 진행
- **일시정지**: 전투 중 / 상점 방문 중
- **로그 누적**:
  ```
  00:00 - 탐험 시작
  01:00 - ⚔️ 전투 발생
  02:30 - 🛒 상점 발견
  03:45 - ❤️ 휴식
  05:00 - 💀 보스 전투
  ```

### 노드 타입별 처리
| 노드 | 이모지 | 동작 |
|------|-------|------|
| Combat | ⚔️ | CombatView 전환 → 전투 시작 |
| Shop | 🛒 | ShopView 전환 → 카드 구매 가능 |
| Rest | ❤️ | HP 회복 (최대 HP의 30%) |
| Treasure | 🎁 | 랜덤 카드 1장 획득 |
| Boss | 💀 | 보스 전투 (승리 시 런 종료) |

---

## 📊 리소스 & 경제 시스템

### 화폐 타입
1. **Gold (🪙)**
   - 획득: 전투 승리, 이벤트, 런 완료
   - 용도: 런 중 상점 구매, 메타 Shop 일반 아이템

2. **Gems (💎)**
   - 획득: 일일 보상, 업적, 인앱 구매
   - 용도: 프리미엄 카드 구매, 가챠 (추후)

3. **Energy (⚡)**
   - 최대: 5
   - 회복: 5분당 1
   - 용도: 런 시작 비용 (1 Energy per run)

### GameManager 글로벌 상태
```gdscript
# 화폐
var gold: int = 500
var gems: int = 10
var energy: int = 5
var max_energy: int = 5

# 덱 상태
var current_deck: Array[Dictionary] = []
var card_collection: Array[Dictionary] = []

# 꿈 데이터 (런 중)
var dream_cards: Array[Dictionary] = []     # 선택한 3개 카드
var dream_nodes: Array[Dictionary] = []     # 생성된 노드 목록
var dream_time_logs: Array[Dictionary] = [] # 시간별 로그
```

---

## 🌳 영구 업그레이드 시스템

### UpgradeTree 구조
```
           [루트]
          /      \
    [전투]       [탐험]
    /    \        /    \
[HP+10] [ATK+5] [Gold+20%] [카드+1]
```

### 업그레이드 예시
| ID | 이름 | 비용 | 효과 | 전제조건 |
|----|------|------|------|---------|
| hp_1 | 체력 증가 I | 100 Gold | 시작 HP +10 | 없음 |
| hp_2 | 체력 증가 II | 200 Gold | 시작 HP +20 | hp_1 |
| card_draw | 카드 드로우 | 150 Gold | 시작 손패 +1 | 없음 |
| gold_boost | 황금 수집가 | 250 Gold | Gold 획득 +20% | 없음 |

---

## 🎨 비주얼 스타일 & 에셋

### 현재 상태 (Placeholder)
- **캐릭터**: 이모지 (🧙‍♂️, 👹, 💀, etc.)
- **UI**: Godot 기본 테마 + UITheme 색상 팔레트
- **카드**: 140×220 타로 비율, 뒷면 🔮

### 향후 교체 예정
1. **캐릭터 스프라이트**: 픽셀아트 (32×32 or 64×64)
2. **카드 일러스트**: 손그림 or AI 생성 일러스트
3. **배경**: 꿈 테마 (밤하늘, 별, 오로라)
4. **UI 아이콘**: 커스텀 아이콘 세트

### UITheme 색상 팔레트
```gdscript
bg:      Color(0.1, 0.1, 0.18, 1)  # 배경 (짙은 보라)
panel:   Color(0.15, 0.15, 0.25, 1) # 패널
primary: Color(0.48, 0.62, 0.94, 1) # 파랑 (주 버튼)
accent:  Color(0.98, 0.71, 0.25, 1) # 금색 (강조)
warning: Color(0.95, 0.76, 0.26, 1) # 노랑
success: Color(0.49, 0.87, 0.58, 1) # 초록
danger:  Color(0.94, 0.33, 0.31, 1) # 빨강
text:    Color(0.9, 0.9, 0.95, 1)   # 흰색 텍스트
```

---

## 📂 프로젝트 구조

### 파일 조직
```
dream-collector/
├── autoload/
│   ├── GameManager.gd         # 글로벌 상태 (화폐, 덱, 꿈)
│   ├── CombatManager.gd       # 전투 로직 (ATB 또는 턴제)
│   ├── DeckManager.gd         # 카드 드로우/셔플
│   └── UITheme.gd             # 색상/스타일 통합
│
├── ui/
│   ├── screens/               # 12개 화면
│   │   ├── MainLobby.tscn
│   │   ├── InRun_v4.tscn
│   │   ├── DreamCardSelection.tscn
│   │   └── ...
│   │
│   └── components/            # 재사용 컴포넌트
│       ├── BottomNav.tscn
│       ├── CharacterNode.tscn
│       ├── DamageNumber.tscn
│       ├── DreamItem.tscn
│       └── RunProgressBar.tscn
│
├── data/
│   ├── cards/                 # 카드 JSON (85개 예정)
│   ├── monsters/              # 몬스터 스탯
│   └── upgrades/              # 업그레이드 데이터
│
├── PROJECT_CONTEXT.md         # 공통 컨텍스트 (AI 도구)
├── CHANGELOG.md               # 변경 사항 기록
├── .cursorrules               # Cursor AI 규칙
└── .clinerules                # Claude Code 규칙
```

---

## 🚧 개발 상태 (2026-02-26)

### ✅ 완료 (Phase 1 - UI Foundation)
- [x] 12개 화면 UI 구조 (100%)
- [x] BottomNav 통합 네비게이션
- [x] CharacterNode 컴포넌트 (HP, 데미지 효과)
- [x] DamageNumber 떠다니는 숫자
- [x] DreamCardSelection 뽑기 시스템 (3-stage, 뒤집기)
- [x] RunProgressBar 여정 진행바
- [x] Combat 비주얼 효과 (shake, flash, HP 동기화)
- [x] GameManager 꿈 카드 통합
- [x] 시간 흐름 시스템 (60초/노드)
- [x] UITheme 색상 팔레트

### 🚧 진행 중 (Phase 2 - Combat System)
- [ ] **전투 시스템 결정** (ATB vs 턴제) ← **Steve 의사결정 대기**
- [ ] 카드 효과 구현 (damage, buff, debuff)
- [ ] 적 AI 로직
- [ ] DeckManager 카드 드로우/셔플
- [ ] 전투 승리/패배 처리

### 📋 대기 중 (Phase 3 - Content)
- [ ] 85개 카드 JSON 데이터
- [ ] 30개 몬스터 스탯
- [ ] 상점 구매 메커니즘
- [ ] 이벤트 시스템 (랜덤 선택지)
- [ ] 업그레이드 트리 로직

### 🎯 향후 계획 (Phase 4 - Polish)
- [ ] 픽셀아트 스프라이트 교체
- [ ] 카드 일러스트 제작
- [ ] 사운드/BGM 추가
- [ ] 튜토리얼 시스템
- [ ] 밸런스 조정

---

## 📝 개발 노트

### 최근 주요 변경 사항 (2026-02-25)
1. **DreamCardSelection 완전 재설계**
   - 기존 RunPrep 제거
   - 3-stage 타로 카드 선택 시스템 도입
   - 2-click 인터랙션 (선택 preview → 확정 + 뒤집기)
   - GameManager 통합 (카드 → 노드 → 로그 자동 생성)

2. **Combat 비주얼 효과 구현**
   - CharacterNode shake (위치 + 회전)
   - Red flash (피격 시 색상 변조)
   - DamageNumber 색상 규칙 (빨강/주황/초록)

3. **시간 흐름 시스템**
   - ExplorationBottomUI 시간 기반 로그
   - 60초당 1노드 자동 진행
   - 블록 스타일 로그 패널 (DreamItem 디자인)

### 기술 부채
1. **전투 시스템 불확실성**
   - ATB vs 턴제 미결정
   - 구현 방향 결정 필요 (2개 가이드 작성 완료)

2. **플레이스홀더 에셋**
   - 이모지 → 픽셀아트 교체 예정
   - 카드 뒷면 🔮 → 실제 일러스트

3. **데이터 하드코딩**
   - 카드/몬스터 GDScript에 하드코딩
   - JSON 외부화 필요

---

## 🎯 다음 마일스톤

### Milestone 1: Combat Playable (2주)
**목표**: 전투 시스템 완성 (ATB 또는 턴제)

**Tasks**:
1. Steve 전투 시스템 결정 (ATB vs 턴제)
2. 선택된 시스템 구현 (Cursor + guides)
3. 카드 효과 10개 구현
4. 적 AI 기본 로직
5. 승리/패배 처리

### Milestone 2: Content Complete (4주)
**목표**: 85개 카드 + 30개 몬스터 완성

**Tasks**:
1. 카드 JSON 데이터 생성 (sub-agent)
2. 몬스터 스탯 밸런싱
3. 상점 구매 구현
4. 이벤트 10개 작성
5. 업그레이드 트리 로직

### Milestone 3: Alpha Release (6주)
**목표**: 플레이 가능한 알파 버전

**Tasks**:
1. 에셋 교체 (픽셀아트 + 일러스트)
2. 사운드/BGM 추가
3. 튜토리얼 구현
4. 밸런스 조정 (3회 플레이테스트)
5. 버그 수정

---

## 📞 연락처 & 리소스

- **PM**: Steve PM (Telegram @stevemacbook)
- **AI Manager**: Atlas (24시간 대기)
- **Repo**: `~/Projects/geekbrox/teams/game/godot/dream-collector/`
- **문서**: `~/Projects/geekbrox/teams/game/workspace/design/`

---

_Last updated: 2026-02-26 by Atlas_  
_Next review: Combat system decision by Steve_
