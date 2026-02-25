# Dream Collector - Godot 개발 일지

> Godot 4 엔진을 사용한 Dream Collector 모바일 게임 개발 일지

---

## 📅 2026-02-24 (월)

### ✅ 완료된 작업

#### 1. **재화 시스템 UI 구현**
- **MainLobby 상단 재화 바 추가**
  - ⚡ 에너지 (Energy)
  - 💎 보석 (Gems)
  - 🪙 골드 (Gold/Reveries)
  - 실시간 업데이트 시스템 구현
  - GameManager 시그널 연동

- **Shop 화면 재화 표시**
  - 상단 TopBar에 3종 재화 동시 표시
  - 재화 변경 시 자동 갱신

#### 2. **AlertModal 버그 수정**
- **문제:** Modal이 다른 UI 요소 뒤에 렌더링되어 보이지 않음
- **해결책:** 
  - Control → CanvasLayer로 root 노드 변경
  - layer=100 설정으로 최상위 렌더링 보장
  - 모든 자식 노드 경로 `$Control/*`로 수정

#### 3. **에너지 충전 시스템 구현**
- Shop 화면 "재화 교환" 탭에서 보석으로 에너지 구매 가능
- 교환 레이트:
  - 💎 5 → ⚡ 50
  - 💎 9 → ⚡ 100
  - 💎 20 → ⚡ 250
- AlertModal 통합 (구매 실패 시 팝업)

#### 4. **저장/로드 시스템 확장**
- GameManager에 energy 변수 추가
- SaveSystem에 에너지 저장/로드 로직 추가
- JSON 직렬화로 세션 간 지속성 보장

#### 5. **개발 치트 코드 추가**
```
E 키: 에너지 +50
R 키: 에너지 +200
M 키: 골드 +1,000
N 키: 골드 +10,000
G 키: 보석 +100
H 키: 보석 +1,000
```

#### 6. **개발 관리 문서 시스템 구축**
- `dev-management/` 폴더 생성
- 5개 핵심 문서 작성:
  - DEVLOG.md (6.3 KB) - 날짜별 개발 일지
  - CHECKLIST.md (7.5 KB) - 기능 체크리스트
  - PROGRESS_TRACKER.md (6.3 KB) - 진행 상황 대시보드
  - TECHNICAL_SUMMARY.md (8.8 KB) - 기술 스택 요약
  - README.md (6.0 KB) - 문서 인덱스

#### 7. **Gacha 시스템 프레임워크**
- Shop 화면에 3탭 시스템 추가:
  - 🎲 뽑기 (Gacha)
  - 💎 보석 구매
  - 🪙 재화 교환
- 4개 배너 타입:
  - 일반 뽑기 (골드 1000/9000)
  - 프리미엄 뽑기 (보석 100/900, 희귀+ 보장)
  - 이벤트 한정 뽑기 (보석 150/1350)
  - 초보자 뽑기 (골드 500/4000, 1회 제한)
- AlertModal 통합 (재화 부족 시 경고)
- TODO: 실제 뽑기 로직, 카드 풀, 결과 화면

#### 8. **BottomNav 폰트 버그 수정**
- **문제:** MainLobby BottomNav 폰트가 다른 화면보다 큼
- **원인:** `tab_buttons` 배열 초기화가 `_apply_theme_styles()` 호출 이후 발생
- **해결:** 배열 초기화를 스타일 적용 전으로 이동
- **결과:** 모든 화면 BottomNav 폰트 12px 통일

#### 9. **c06-run-prep 화면 구현** ✅
- **파일:** RunPrep.tscn (4.9 KB), RunPrep.gd (11.6 KB)
- **기능:**
  - 현재 덱 표시 (12 슬롯, 80×112px 카드)
  - 덱 상태 표시 (카드 수, 평균 코스트)
  - 난이도 선택 (Easy/Normal/Hard)
    - Easy: 적 ×0.7, 보상 ×0.8 (초록)
    - Normal: 기본 ×1.0 (파랑)
    - Hard: 적 ×1.3, 보상 ×1.5 (빨강)
  - 덱 유효성 검증 (10~12장)
  - 런 시작 버튼 (유효 시 활성화)
- **GameManager 확장:**
  - `current_difficulty: String`
  - `difficulty_data: Dictionary`
- **통합:** MainLobby "꿈 런 시작" 버튼 → RunPrep 이동

#### 10. **c07-in-run 화면 구현** ✅
- **파일:** InRun.tscn (5.4 KB), InRun.gd (8.8 KB)
- **기능:**
  - **상단 스탯 바:**
    - HP 바 (진행률 표시, 색상 변화: 초록/노랑/빨강)
    - Energy 표시 (진행률 바)
    - Reveries 골드 표시
  - **노드 맵 시스템:**
    - 10개 노드 표시 (Memory, Combat, Event, Shop, Upgrade, Boss)
    - 완료/현재/미완료 상태 표시 (초록/파랑/회색)
    - 노드 간 연결선 표시
    - 현재 노드 하이라이트 (흰색 테두리)
    - 가로 스크롤 지원
  - **메인 뷰:**
    - 현재 노드 아이콘 크게 표시 (96px)
    - 중앙 배치
  - **노드 정보 패널 (하단):**
    - 현재 노드 타입 + 설명
    - 노드별 선택지 UI:
      - Event: 2개 선택지 (안전/위험)
      - Memory: 수집 버튼
      - Combat: 전투 시작
      - Shop: 상점 입장
      - Upgrade: 업그레이드 선택
      - Boss: 보스 전투
  - **액션 바:**
    - Skip, Auto, Menu 버튼
    - Menu 버튼으로 MainLobby 복귀
  - **치트 코드:**
    - H/J 키: HP 증감
    - K/L 키: Energy 증감
    - Space: 노드 진행
- **통합:** RunPrep "런 시작" 버튼 → InRun 전환

### 📊 진행 상황
- **완료된 화면:** 6/12 (50%)
  - ✅ c01-main-lobby
  - ✅ c02-card-library
  - ✅ c03-deck-builder
  - ✅ c05-shop
  - ✅ c06-run-prep
  - ✅ c07-in-run (NEW!)
  - ✅ c03-deck-builder
  - ✅ c05-shop
  - ✅ c06-run-prep (NEW!)

### 🔧 기술적 개선
- CanvasLayer를 활용한 UI 레이어링 시스템 확립
- 시그널 기반 반응형 UI 패턴 안정화
- 재화 시스템 아키텍처 확정
- 난이도 밸런싱 프레임워크 구축
- 초기화 순서 문제 패턴 발견 및 해결

### 🐛 발견된 이슈
- ~~AlertModal z-order 문제~~ → 해결 완료
- ~~BottomNav 폰트 크기 불일치~~ → 해결 완료

#### 11. **c08-combat 화면 Phase 1 구현** ✅🔴
- **설계 문서:** COMBAT_SYSTEM_DESIGN_V2.md (13.5 KB) 작성
  - 실시간 ATB + 실시간 카드 하이브리드 시스템
  - 디펜스 게임 + Slay the Spire + Final Fantasy ATB 융합
  - 4단계 구현 계획 (Phase 1-4, 7-11일 예상)
- **파일:** Combat.tscn (9.5 KB), Combat.gd (4.4 KB)
- **CombatManager.gd Autoload** (4.6 KB):
  - ATB 시스템 구현
  - 실시간 게이지 충전 (_process)
  - ATB 100% → 자동 공격 실행
  - 데미지 계산 (ATK vs DEF, 회피 체크)
  - 승리/패배 조건 체크
- **Combat UI 레이아웃:**
  - Top Bar: HP/Energy 표시
  - Battle Scene (280px): 가로 액자 전투 뷰
    - 좌측: Hero (스프라이트, HP 바, ATB 바)
    - 우측: Monsters 2마리 (스프라이트, HP 바, ATB 바)
  - Combat Log: 스크롤 가능 전투 로그
  - Action Buttons: Pass/Auto/Menu
- **ATB 메커니즘:**
  - 충전 공식: `ATB += (100 / Speed) * delta`
  - Hero: 10 Speed (10초마다 턴)
  - Monsters: 8-12 Speed (8-12초마다 턴)
  - ATB 100% 도달 → 자동 기본 공격 → ATB 리셋
- **기본 전투 로직:**
  - 데미지: `(ATK - DEF) * variance(0.9-1.1)`
  - 회피: `EVA%` 확률로 miss
  - 타겟: 첫 번째 살아있는 적
- **Scene Flow:**
  - InRun → Combat (전투 시작)
  - Combat → InRun (승리 시)
  - Combat → MainLobby (패배 시)
- **Test Monsters:**
  - Slime: 20 HP, 3 ATK, 1 DEF, 8 SPD, 5 EVA
  - Goblin: 15 HP, 5 ATK, 0 DEF, 12 SPD, 10 EVA
- **Phase 1 Status:** ✅ 완료 (2-3일 중 1일차)
- **다음 단계:** Phase 2 - Energy & Card System (2-3일)

### 📊 진행 상황 (Updated 18:45 PST)
- **완료된 화면:** 7/12 (58%) ← +1!
  - ✅ c01-main-lobby
  - ✅ c02-card-library
  - ✅ c03-deck-builder
  - ✅ c05-shop
  - ✅ c06-run-prep
  - ✅ c07-in-run
  - ✅ **c08-combat (Phase 1)** 🆕
- **남은 화면:** c04, c09-c12 (5 screens)
- **전투 시스템 진행:** Phase 1/4 완료 (25%)

### 📝 Git 커밋
- `d5dbc5c`: Godot UI 구현 (37 files, +5,215 lines)
- `84774dc`: Shop v2.0 기획 문서 (4 files, +1,005 lines)
- `becabbb`: 개발 관리 문서 시스템 (5 files, +1,465 lines)
- `df93259`: Gacha 시스템 (2 files, +212 lines)
- `f1ef236`: BottomNav 폰트 수정 (1 file, +3/-3 lines)
- `9e6c42c`: c06-run-prep 화면 구현 (5 files, +1,108 lines)
- `d941bfe`: **Phase 1 - ATB Basic Combat** (18 files, +3,625/-1,584 lines) ✅ 🆕

---

## 📅 2026-02-23 (일)

### ✅ 완료된 작업

#### 1. **Shop 화면 전면 재설계**
- **이전:** 단순 카드/업그레이드/코스메틱 구매
- **신규:** IAP + 재화 교환 2탭 시스템
  - 탭 1: 💎 보석 구매 (현금 결제)
  - 탭 2: 🪙 재화 교환 (보석 → 게임 재화)

#### 2. **보석 패키지 시스템 구현**
- 6개 패키지 (스타터 팩 ~ 메가 번들)
- 보너스 보석 표시
- 가격 및 수량 UI

#### 3. **재화 교환 시스템 설계**
- 골드 교환 (3단계)
- 에너지 교환 (3단계)
- 교환 비율 밸런싱

### 📊 진행 상황
- Shop.gd 완전 재작성 (407줄)
- Shop_OLD 백업 생성

---

## 📅 2026-02-22 (토)

### ✅ 완료된 작업

#### 1. **DeckBuilder 화면 구현**
- 12장 덱 제한 시스템
- 카드 추가/제거 UI
- 평균 코스트 계산
- 저장/로드 기능
- 빈 슬롯 표시

#### 2. **저장 시스템 통합**
- GameManager.current_deck 변수 추가
- SaveSystem에 덱 데이터 저장 로직 추가
- Array[Dictionary] → Array 타입 변경 (JSON 호환성)

#### 3. **타입 안전성 이슈 해결**
- **문제:** `Array[Dictionary]`가 JSON 로드 시 일반 Array로 변환되어 타입 충돌
- **해결:** 타입 힌트를 `Array`로 변경

### 📊 진행 상황
- **완료된 화면:** 3/12 (25%)

---

## 📅 2026-02-21 (금)

### ✅ 완료된 작업

#### 1. **CardLibrary 화면 구현**
- 85개 카드 표시 (3열 그리드)
- 5개 필터 버튼 (All/Attack/Defense/Skill/Power)
- CardItem 컴포넌트 재사용
- CenterContainer + MarginContainer 레이아웃
- TopBar + BottomNav 통합

#### 2. **CardItem 재사용 컴포넌트 생성**
- 106×148px 카드 크기
- 타입별 색상 (Attack/Defense/Skill/Power)
- 레어리티 테두리 (Common/Rare/Epic/Legendary)
- 호버 효과

#### 3. **BottomNav 네비게이션 시스템**
- 5개 탭 (Home/Cards/Upgrade/Progress/Shop)
- 활성 탭 하이라이트
- 씬 전환 연동

### 📊 진행 상황
- **완료된 화면:** 2/12 (17%)

---

## 📅 2026-02-20 (목)

### ✅ 완료된 작업

#### 1. **Godot 4 프로젝트 초기화**
- 프로젝트 생성 및 구조 설계
- 모바일 타겟 (390×844px, Portrait)
- .gitignore 설정

#### 2. **UITheme 디자인 시스템 구축**
- 30+ 색상 정의 (primary, bg, panel, text, card types, rarities)
- 8px 그리드 스페이싱 시스템
- 폰트 사이즈 체계 (10~32px)
- 레이아웃 상수 (screen size, card size, nav height)
- Autoload 싱글톤 등록

#### 3. **핵심 시스템 구현**
- **GameManager:** 게임 상태 관리 (재화, 진행도, 덱)
- **SaveSystem:** JSON 기반 저장/로드
- **IdleSystem:** 오프라인 수집 시스템

#### 4. **MainLobby 화면 구현**
- 타이틀 + Reveries 표시
- 수집 속도 표시
- 4개 액션 버튼 (런 시작, 카드 라이브러리, 업그레이드, 프레스티지)
- 오프라인 배너 (자동 숨김)
- BottomNav 5탭

#### 5. **개발 워크플로우 문서 작성**
- `GODOT_UI_WORKFLOW.md`: 전체 워크플로우 가이드
- `IMPLEMENTATION_GUIDE.md`: 12개 화면 구현 가이드 (672줄)
- `QUICK_START.md`: 초보자용 튜토리얼

### 📊 진행 상황
- **완료된 화면:** 1/12 (8%)

### 🔧 기술 스택 확정
- **엔진:** Godot 4.x
- **언어:** GDScript
- **디자인 시스템:** UITheme.gd Autoload
- **저장 형식:** JSON (user://save.json)

---

## 📈 전체 개발 진행률

| 카테고리 | 완료 | 전체 | 진행률 |
|---------|------|------|--------|
| **UI 화면** | 4 | 12 | 33% |
| **컴포넌트** | 2 | 5 | 40% |
| **시스템** | 3 | 8 | 38% |
| **문서** | 6 | 8 | 75% |
| **전체** | - | - | **약 40%** |

---

## 🎯 다음 단계 (우선순위)

1. **c06-run-prep** (런 준비 화면)
   - 덱 확인
   - 난이도 선택
   - 시작 버튼

2. **c04-upgrade-tree** (업그레이드 트리)
   - 트리 구조 UI
   - 업그레이드 구매
   - 잠금 해제 시스템

3. **c07-in-run** (런 진행 중 화면)
   - 진행도 표시
   - 이벤트 선택

4. **c08-combat** (전투 화면)
   - 카드 드로우
   - 카드 플레이
   - 턴 시스템

---

## 📚 참고 자료

- [Godot 4 공식 문서](https://docs.godotengine.org/en/stable/)
- [GDScript 스타일 가이드](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- HTML 프로토타입: `teams/game/interface/html/`
- Figma 디자인: https://www.figma.com/design/Wo1MKHvWNE9Yl5bsmD4pkK/

#### 11. **c08-combat 화면 구현 (Phase 1: ATB 기본 전투)** ✅
- **파일:** Combat.tscn (10 KB), Combat.gd (10.7 KB)
- **구현 완료:** 2026-02-24 19:00 PST
- **시스템:** ATB (Active Time Battle) 실시간 전투
- **기능:**
  - **전투 UI:**
    - Hero (왼쪽): HP 바, 에너지, 방어력, ATB 게이지
    - 3 Enemies (오른쪽): HP, ATB 게이지
    - Combat Log (스크롤, 색상 구분)
    - 카드 핸드 영역 (Phase 2 placeholder)
    - 덱 카운터 (Deck/Discard/Banish)
  - **ATB 시스템:**
    - 실시간 게이지 충전 (SPD 기반)
    - 100% 도달 시 자동 턴 실행
    - ATB 속도 조절 (×1 / ×5)
  - **전투 스탯:**
    - HP, ATK, DEF, SPD, EVA(회피율)
    - Hero: 60 HP, 10 ATK, 5 DEF, 10 SPD
    - 3종 적: Slime (20 HP), Goblin (12 HP), Bat (8 HP)
  - **데미지 계산:**
    - 기본: ATK - DEF (최소 1)
    - 회피 체크 (EVA%)
    - 랜덤 편차 (±10%)
    - Block 시스템 (데미지 흡수)
  - **자동 전투:**
    - Hero → 첫 번째 살아있는 적 공격
    - Enemy → Hero 공격
    - Auto 모드 토글
  - **승리/패배:**
    - Victory: 모든 적 사망
    - Defeat: Hero HP ≤ 0
  - **치트 코드:**
    - H/J: HP 증감
    - K: 적 즉사
    - Space: ATB 속도 (×5)
- **통합:** InRun Combat 노드 → Combat.tscn 전환
- **다음 단계:** Phase 2 - 카드 덱 시스템

### 📊 진행 상황 (2026-02-24 업데이트)
- **완료된 화면:** 7/12 (58%)
  - ✅ c01-main-lobby
  - ✅ c02-card-library
  - ✅ c03-deck-builder
  - ✅ c05-shop
  - ✅ c06-run-prep
  - ✅ c07-in-run
  - ✅ c08-combat (Phase 1) (NEW!)

### 🔧 기술적 개선
- ATB 실시간 전투 시스템 구축
- 스탯 기반 데미지 계산
- 회피/블록 메커니즘
- 실시간 UI 업데이트 (_process)

### 📝 Git 커밋
- `1f46f51`: 전투 시스템 v2 설계 문서
- `917153d`: Combat Phase 1 구현 (ATB 기본 전투)

#### 12. **Combat UI 레이아웃 재설계 (Slay the Spire 스타일)** ✅
- **작업 완료:** 2026-02-24 19:30 PST
- **목표:** 전투 화면을 Slay the Spire 스타일로 재구성
- **변경 사항:**
  - **레이아웃 비율:** 상단(1/3) + 중간(1/3) + 하단(1/3)
  - **상단 280px (전투 영역):**
    - Hero (왼쪽): 큰 스프라이트(64px), HP/Energy/Block/ATB
    - 3 Enemies (오른쪽): 스프라이트(48px), HP/ATB, 가로 배치
    - 배경: bg_light
  - **중간 280px (핸드 영역):**
    - 5장 카드 placeholder (70×200px)
    - 가로 스크롤 지원
    - Phase 2 준비 완료
  - **하단 284px (정보 영역):**
    - Top Bar: 메뉴, 턴, Auto, End Turn
    - Energy Bar: ⚡⚡⚡ 시각화 + Deck/Discard 카운터
    - Combat Log: 스크롤 가능, 색상 구분
- **개선 효과:**
  - 시각적 계층 구조 명확
  - 카드 선택 편의성 증가
  - 전투 상황 가독성 향상
  - Slay the Spire UX 패턴 적용
- **파일:**
  - Combat.tscn (13.4 KB) - 재설계된 레이아웃
  - Combat.gd (12.2 KB) - 노드 참조 업데이트

### 📝 Git 커밋
- `d341fce`: Combat UI 재설계 (Slay the Spire 스타일)
