# Dream Collector - 개발 체크리스트

> Godot 4 구현 진행 상황 추적

---

## 🎨 UI 화면 (12개)

### Category 1: 메타 화면 (Tab Bar 있음)
- [x] **c01-main-lobby** (MainLobby.tscn) ✅ 2026-02-20
  - [x] 타이틀 + 재화 표시
  - [x] 상단 재화 바 (⚡💎🪙) ✅ 2026-02-24
  - [x] 수집 속도 표시
  - [x] 4개 액션 버튼
  - [x] 오프라인 배너
  - [x] BottomNav 5탭
  - [x] 치트 코드 (M/N/G/H/E/R) ✅ 2026-02-24

- [x] **c02-card-library** (CardLibrary.tscn) ✅ 2026-02-21
  - [x] 85개 카드 그리드 (3열)
  - [x] 5개 필터 버튼
  - [x] CardItem 컴포넌트 재사용
  - [x] TopBar (Back + Deck)
  - [x] BottomNav (Cards 탭 활성)

- [x] **c03-deck-builder** (DeckBuilder.tscn) ✅ 2026-02-22
  - [x] 12장 덱 슬롯
  - [x] 카드 추가/제거
  - [x] 평균 코스트 계산
  - [x] 저장 버튼 (SaveSystem 연동)
  - [x] TopBar + BottomNav

- [ ] **c04-upgrade-tree** (UpgradeTree.tscn)
  - [ ] 트리 구조 UI
  - [ ] 업그레이드 노드 (잠금/잠금해제)
  - [ ] 구매 시스템
  - [ ] 효과 표시
  - [ ] TopBar + BottomNav

- [x] **c05-shop** (Shop.tscn) ✅ 2026-02-23
  - [x] 2탭 시스템 (보석 구매 / 재화 교환)
  - [x] 보석 패키지 6개
  - [x] 재화 교환 6개 (골드 3 + 에너지 3) ✅ 2026-02-24
  - [x] 상단 재화 표시 (⚡💎🪙) ✅ 2026-02-24
  - [x] AlertModal 통합 ✅ 2026-02-24
  - [x] TopBar + BottomNav

- [ ] **c06-run-prep** (RunPrep.tscn)
  - [ ] 현재 덱 표시
  - [ ] 난이도 선택
  - [ ] 시작 버튼
  - [ ] TopBar + BottomNav

### Category 2: 인런 화면 (Tab Bar 없음)
- [ ] **c07-in-run** (InRun.tscn)
  - [ ] 진행도 맵 (노드 기반)
  - [ ] 현재 위치 표시
  - [ ] 이벤트 선택 UI
  - [ ] 보상 표시
  - [ ] 상단 스탯 바

- [ ] **c08-combat** (Combat.tscn)
  - [ ] 핸드 (최대 7장)
  - [ ] 드로우 덱 / 버린 덱 카운터
  - [ ] 에너지 표시
  - [ ] 적 표시 (HP, 의도)
  - [ ] 카드 드래그 앤 드롭
  - [ ] 턴 종료 버튼

### Category 3: 모달 화면
- [ ] **c09-victory-screen** (VictoryScreen.tscn)
  - [ ] 승리 메시지
  - [ ] 보상 표시
  - [ ] 통계 요약
  - [ ] 계속/메인으로 버튼

- [ ] **c10-defeat-screen** (DefeatScreen.tscn)
  - [ ] 패배 메시지
  - [ ] 얻은 보상 표시
  - [ ] 통계 요약
  - [ ] 다시 시작/메인으로 버튼

- [ ] **c11-rewards-modal** (RewardsModal.tscn)
  - [ ] 카드 선택 (3장 중 1장)
  - [ ] 골드 획득 표시
  - [ ] 업그레이드 옵션
  - [ ] 선택 버튼

- [ ] **c12-settings** (Settings.tscn)
  - [ ] 사운드 볼륨 슬라이더
  - [ ] 음악 볼륨 슬라이더
  - [ ] 알림 토글
  - [ ] 계정 정보
  - [ ] 크레딧

---

## 🧩 재사용 컴포넌트 (5개)

- [x] **CardItem** (CardItem.tscn) ✅ 2026-02-21
  - [x] 타입별 색상
  - [x] 레어리티 테두리
  - [x] 호버 효과
  - [x] 코스트/공격/방어 표시

- [x] **AlertModal** (AlertModal.tscn) ✅ 2026-02-24
  - [x] CanvasLayer 구조
  - [x] 오버레이 + 패널
  - [x] 1~2 버튼 지원
  - [x] 커스텀 메시지
  - [x] show_info / show_insufficient_currency

- [x] **BottomNav** (BottomNav 섹션) ✅ 2026-02-20
  - [x] 5개 탭 버튼
  - [x] 활성 탭 하이라이트
  - [x] 씬 전환 연동

- [ ] **TopBar** (재사용 가능한 컴포넌트화)
  - [ ] Back 버튼
  - [ ] 타이틀
  - [ ] 재화 카운터
  - [ ] 추가 액션 버튼 (옵션)

- [ ] **ProgressBar** (재사용 가능한 진행 바)
  - [ ] HP 바
  - [ ] 경험치 바
  - [ ] 커스텀 색상 지원

---

## ⚙️ 핵심 시스템 (8개)

### 데이터 관리
- [x] **GameManager** (GameManager.gd) ✅ 2026-02-20
  - [x] 재화 관리 (reveries, gems, energy) ✅ 2026-02-24
  - [x] 진행 상태
  - [x] 덱 데이터
  - [x] 시그널 시스템

- [x] **SaveSystem** (SaveSystem.gd) ✅ 2026-02-20
  - [x] JSON 저장/로드
  - [x] 덱 저장 ✅ 2026-02-22
  - [x] 에너지 저장 ✅ 2026-02-24
  - [x] user://save.json 경로

- [x] **UITheme** (UITheme.gd) ✅ 2026-02-20
  - [x] 30+ 색상 정의
  - [x] 스페이싱 시스템 (xs~xxl)
  - [x] 폰트 사이즈 (tiny~large)
  - [x] 헬퍼 함수 (color, spacing, apply_button_style)

### 게임플레이
- [x] **IdleSystem** (IdleSystem.gd) ✅ 2026-02-20
  - [x] 오프라인 수집
  - [x] 시간 기반 계산
  - [x] 멀티플라이어

- [ ] **CombatSystem** (CombatSystem.gd)
  - [ ] 턴 관리
  - [ ] 카드 드로우/플레이
  - [ ] 적 AI
  - [ ] 데미지 계산

- [ ] **RunManager** (RunManager.gd)
  - [ ] 런 진행 상태
  - [ ] 맵 생성
  - [ ] 이벤트 관리
  - [ ] 보상 지급

- [ ] **CardDatabase** (CardDatabase.gd)
  - [ ] 85개 카드 데이터
  - [ ] 카드 생성 팩토리
  - [ ] 필터링/검색

- [ ] **UpgradeManager** (UpgradeManager.gd)
  - [ ] 업그레이드 트리 데이터
  - [ ] 잠금 해제 조건
  - [ ] 효과 적용

---

## 📄 문서 (8개)

- [x] **GODOT_UI_WORKFLOW.md** ✅ 2026-02-20
  - 전체 워크플로우 가이드 (6.4 KB)

- [x] **IMPLEMENTATION_GUIDE.md** ✅ 2026-02-20
  - 12개 화면 구현 가이드 (16.6 KB, 672줄)

- [x] **QUICK_START.md** ✅ 2026-02-20
  - 초보자용 튜토리얼 (6.9 KB)

- [x] **DEVLOG.md** ✅ 2026-02-24
  - 날짜별 개발 일지

- [x] **CHECKLIST.md** ✅ 2026-02-24
  - 기능별 체크리스트 (이 문서)

- [ ] **PROGRESS_TRACKER.md**
  - 진행 상황 대시보드

- [ ] **TECHNICAL_SUMMARY.md**
  - 기술 스택 및 아키텍처 요약

- [ ] **TESTING_PLAN.md**
  - 테스트 계획 및 시나리오

---

## 🎮 게임 콘텐츠 (데이터)

### 카드 (85장)
- [x] 카드 데이터 구조 정의 ✅ 2026-02-21
- [ ] 85개 카드 JSON 데이터
  - [ ] Attack 카드 (20장)
  - [ ] Defense 카드 (20장)
  - [ ] Skill 카드 (25장)
  - [ ] Power 카드 (20장)

### 적 (34종)
- [ ] 적 데이터 구조 정의
- [ ] 34종 적 JSON 데이터
  - [ ] 일반 적 (24종)
  - [ ] 엘리트 적 (7종)
  - [ ] 보스 (3종)

### 업그레이드 트리
- [ ] 업그레이드 노드 데이터
- [ ] 트리 구조 정의
- [ ] 효과 및 비용 밸런싱

---

## 🎨 아트 에셋 (추후)

- [ ] 카드 일러스트 (85장)
- [ ] 적 스프라이트 (34종)
- [ ] UI 아이콘 (50+개)
- [ ] 배경 이미지
- [ ] 이펙트 스프라이트

---

## 🔊 사운드 (추후)

- [ ] BGM (5곡)
  - [ ] 메인 메뉴
  - [ ] 전투
  - [ ] 승리
  - [ ] 패배
  - [ ] 상점
- [ ] SFX (30+개)
  - [ ] 카드 드로우
  - [ ] 카드 플레이
  - [ ] 공격/방어
  - [ ] UI 클릭
  - [ ] 승리/패배

---

## 🧪 테스트 & 디버깅

- [x] 치트 코드 시스템 ✅ 2026-02-24
  - [x] 재화 추가 (M/N/G/H/E/R)
- [ ] 유닛 테스트
  - [ ] GameManager 테스트
  - [ ] SaveSystem 테스트
  - [ ] CombatSystem 테스트
- [ ] 통합 테스트
  - [ ] 전체 런 플레이 시나리오
  - [ ] 저장/로드 검증
  - [ ] 밸런싱 테스트

---

## 🚀 배포 준비

- [ ] 빌드 설정
  - [ ] Android (APK/AAB)
  - [ ] iOS (IPA)
- [ ] 최적화
  - [ ] 메모리 사용량 최적화
  - [ ] 로딩 시간 최적화
  - [ ] 배터리 소모 최적화
- [ ] 테스트 배포
  - [ ] 내부 테스트
  - [ ] 알파 테스트
  - [ ] 베타 테스트

---

## 📊 전체 진행률

| 카테고리 | 완료 | 전체 | 진행률 |
|---------|------|------|--------|
| UI 화면 | 4 | 12 | **33%** |
| 컴포넌트 | 3 | 5 | **60%** |
| 시스템 | 3 | 8 | **38%** |
| 문서 | 5 | 8 | **63%** |
| 게임 콘텐츠 | 1 | 3 | **33%** |
| **전체** | **16** | **36** | **44%** |

---

**마지막 업데이트:** 2026-02-24
**다음 목표:** c06-run-prep, c04-upgrade-tree 구현
