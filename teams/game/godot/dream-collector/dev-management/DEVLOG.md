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

### 📊 진행 상황
- **완료된 화면:** 4/12 (33%)
  - ✅ c01-main-lobby
  - ✅ c02-card-library
  - ✅ c03-deck-builder
  - ✅ c05-shop

### 🔧 기술적 개선
- CanvasLayer를 활용한 UI 레이어링 시스템 확립
- 시그널 기반 반응형 UI 패턴 안정화
- 재화 시스템 아키텍처 확정

### 🐛 발견된 이슈
- ~~AlertModal z-order 문제~~ → 해결 완료

### 📝 Git 커밋
- `d5dbc5c`: Godot UI 구현 (37 files, +5,215 lines)
- `84774dc`: Shop v2.0 기획 문서 (4 files, +1,005 lines)

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
