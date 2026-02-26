# PROJECT CONTEXT - Dream Collector

**이 파일은 Cursor, Claude Code, Atlas, 팀장들이 공유하는 프로젝트 공통 컨텍스트입니다.**

**모든 AI 도구 작업 시 이 파일을 먼저 읽어주세요!**

---

## 📌 프로젝트 개요

- **이름**: Dream Collector
- **장르**: Roguelike Deckbuilding RPG
- **엔진**: Godot 4.3
- **언어**: GDScript + 한국어 UI
- **해상도**: 390×844 (세로 모드, 모바일 타겟)
- **프로젝트 루트**: `~/Projects/geekbrox/teams/game/godot/dream-collector/`

---

## 👥 팀 구성

- **Steve PM**: 총괄 프로젝트 매니저 (한국어+영어)
- **Atlas**: AI 프로젝트 매니저 (텔레그램, 24시간)
- **Cursor IDE**: 코드 수정 전문 (로컬 AI)
- **Claude Code**: 코드 수정 전문 (VSCode)
- **팀장들**: 향후 조인 예정

---

## 📂 폴더 구조 (중요!)

```
dream-collector/
├── scripts/                    # 핵심 게임 로직
│   ├── GameManager.gd         # 글로벌 상태 (싱글톤)
│   ├── CombatManager.gd       # 전투 시스템
│   ├── DeckManager.gd         # 덱 관리
│   └── MainLobbyUI.gd         # 메인 로비 컨트롤러
│
├── autoload/                   # 싱글톤 스크립트
│   ├── GameManager.gd         # 리소스, 화폐, 꿈 데이터
│   ├── CombatManager.gd       # 전투 로직
│   ├── UITheme.gd             # 색상 팔레트, 버튼 스타일
│   └── ...
│
├── ui/
│   ├── screens/               # 12개 메인 화면
│   │   ├── MainLobby.tscn/gd           # 홈 허브
│   │   ├── InRun_v4.tscn/gd            # 액티브 런 게임플레이
│   │   ├── DreamCardSelection.tscn/gd  # 3단계 카드 선택 (뽑기)
│   │   ├── CardLibrary.tscn/gd         # 카드 컬렉션
│   │   ├── DeckBuilder.tscn/gd         # 덱 편집기
│   │   ├── Shop.tscn/gd                # 상점
│   │   ├── UpgradeTree.tscn/gd         # 캐릭터 업그레이드
│   │   ├── Settings.tscn/gd            # 설정
│   │   └── ... (4개 더)
│   │
│   └── components/            # 재사용 가능한 UI 컴포넌트
│       ├── BottomNav.tscn/gd           # 5탭 네비게이션 바
│       ├── CharacterNode.tscn/gd       # HP바, 스프라이트, 데미지 효과
│       ├── DamageNumber.tscn/gd        # 떠다니는 데미지 숫자
│       ├── DreamItem.tscn/gd           # 과거 꿈 로그 아이템
│       └── RunProgressBar.tscn/gd      # 여정 노드 진행바
│
├── scenes/
│   └── MainLobby.tscn         # 진입점 씬
│
├── PROJECT_CONTEXT.md          # 이 파일 (공통 컨텍스트)
├── CHANGELOG.md                # 변경 사항 기록
├── CURSOR_GUIDE.md             # Cursor IDE 가이드
├── CLAUDE_CODE_GUIDE.md        # Claude Code 가이드
├── .cursorrules                # Cursor AI 컨텍스트
└── .clinerules                 # Claude Code 컨텍스트
```

---

## 🎨 코딩 스타일 (필수 준수!)

### 명명 규칙
- **변수/함수**: `snake_case`
- **클래스/Enum**: `PascalCase`
- **상수**: `UPPER_SNAKE_CASE`
- **private 함수**: `_leading_underscore`

### 타입 힌트 (필수!)
```gdscript
var hp: int = 100
var name: String = "Hero"

func calculate_damage(base: int, modifier: float) -> int:
    return int(base * modifier)
```

### 시그널
```gdscript
signal entity_updated(entity_type: String, index: int, data: Dictionary)
signal damage_dealt(target: String, amount: int, is_healing: bool)
```

### 노드 참조
```gdscript
@onready var button = $Button
@onready var label = $Panel/VBox/Label
```

### 주석 스타일
```gdscript
# ─── Section Name ─────────────────────────────────────

func public_method(value: int) -> void:
    """
    Public API method with docstring.
    Explain purpose, parameters, return value.
    """
    pass

# [2026-02-25] Steve: Added new feature X
# - Reason: To solve problem Y
# - Impact: Affects Z
func _private_method() -> void:
    pass
```

---

## 🔑 핵심 시스템 (절대 건드리지 마세요!)

### 1. BottomNav 컴포넌트
- **위치**: `ui/components/BottomNav.tscn/gd`
- **용도**: 통합 네비게이션 (모든 메타 화면)
- **탭**: 0=Home, 1=Cards, 2=Upgrade, 3=Progress, 4=Shop
- **시그널**: `tab_pressed(tab_index: int)`
- **규칙**: 인라인 BottomNav 생성 금지, 항상 컴포넌트 사용

### 2. DreamCardSelection (뽑기 시스템)
- **위치**: `ui/screens/DreamCardSelection.tscn/gd`
- **흐름**: 3단계 (START → JOURNEY → END)
- **인터랙션**:
  - 첫 클릭: 카드 20px 아래 이동 (선택 표시)
  - 두 번째 클릭: 확정 → 나머지 사라짐 → 선택된 카드 뒤집어서 공개
- **카드**: 140×220 (타로 비율), 초기 뒷면 (🔮)
- **로그**: 블록 스타일 패널 (DreamItem처럼)
- **출력**: 3개 선택 카드 → GameManager → InRun_v4 사용

### 3. Combat 시스템
- **매니저**: `autoload/CombatManager.gd`
- **주요 시그널**:
  - `entity_updated(type, index, data)` → HP 동기화
  - `damage_dealt(entity_type, index, damage, is_healing)` → 비주얼 효과
  - `combat_log_updated(message)` → 로그 표시
  - `combat_ended(victory)` → 결과 처리
- **비주얼 효과**:
  - DamageNumber: 빨강(적 피해), 주황(자가 피해), 초록(힐)
  - Shake: 위치+회전 (0.4초)
  - Red Flash: 색상 변조 (0.3초)

### 4. GameManager (글로벌 상태)
- **위치**: `autoload/GameManager.gd`
- **책임**:
  - 화폐: gold, gems, energy
  - 리소스: max_energy, energy_recharge
  - 꿈 데이터: `dream_cards`, `dream_nodes`, `dream_time_logs`
  - 덱 상태: `current_deck`, card collection
- **주요 함수**:
  - `set_dream_cards(cards: Array)` → 저장 + 노드/로그 생성
  - `get_dream_nodes() -> Array` → InRun_v4 진행용
  - `get_dream_time_logs() -> Array` → 시간별 탐험용

### 5. UITheme (일관된 스타일)
- **위치**: `autoload/UITheme.gd`
- **색상**:
  - bg: `Color(0.1, 0.1, 0.18, 1)` - 배경
  - panel: `Color(0.15, 0.15, 0.25, 1)` - 패널
  - primary: `Color(0.48, 0.62, 0.94, 1)` - 파랑 (주 버튼)
  - accent: `Color(0.98, 0.71, 0.25, 1)` - 금색 (강조)
  - warning: `Color(0.95, 0.76, 0.26, 1)` - 노랑
  - success: `Color(0.49, 0.87, 0.58, 1)` - 초록
  - danger: `Color(0.94, 0.33, 0.31, 1)` - 빨강
- **버튼 스타일**: `UITheme.apply_button_style(button, "primary")`
- **규칙**: 색상 하드코딩 금지, 항상 UITheme 사용

---

## 📊 현재 개발 상태

### ✅ 완료 (2026-02-25)
1. 모든 12개 화면 UI (100%)
2. BottomNav 통합 네비게이션
3. Combat 비주얼 효과 (HP 동기화, 데미지 숫자, shake/flash)
4. DreamCardSelection 뽑기 시스템 (3단계, 뒤집기 공개)
5. 시간별 탐험 로그 (시간당 진행)
6. CharacterNode 컴포넌트 (HP바, 이모지 스프라이트, 데미지 효과)
7. GameManager 꿈 카드 통합

### 🚧 진행 중
- Combat 게임플레이 로직 (카드 효과, 적 AI)
- 데이터 통합 (JSON 카드 DB, 몬스터 스탯)
- DeckManager 카드 드로우/셔플 시스템
- 상점 구매 메커니즘

### 📋 TODO
- 에셋 교체 (이모지 → 스프라이트)
- 사운드 효과 통합
- 애니메이션 폴리시
- 밸런스 테스트
- 세이브/로드 시스템

---

## 🔄 워크플로우 규칙 (중요!)

### Git 규칙
- **로컬 커밋**: 자유롭게
- **Git push**: **반드시 Steve 승인 필요** (텔레그램)
- **보고 포맷**: "변경 파일 목록 + 커밋 메시지"
- **대기**: "OK", "승인", "Proceed" 응답 후 push

### Notion 규칙
- **API 호출**: **반드시 Steve 승인 필요** (텔레그램)
- **보고 포맷**: "업데이트 대상 페이지 + 변경 내용"
- **대기**: "OK", "승인", "Proceed" 응답 후 실행

### 문서화 규칙 (필수!)

#### 작업 완료 후:

**1. CHANGELOG.md 업데이트**
```markdown
## [Unreleased]

### Added
- 새 기능 X in FileY.gd

### Changed
- 함수 Z in FileW.gd 수정 (이유: ...)

### Fixed
- Combat HP 동기화 버그 수정
```

**2. 중요 변경 시 코드 주석**
```gdscript
# [2026-02-25] Cursor: 뽑기 시스템으로 리팩터링
# - 첫 클릭: 미리보기 (20px down)
# - 두 번째 클릭: 확정 + 공개
func _on_card_clicked(card: Control, index: int):
```

**3. 텔레그램 보고 (템플릿)**
```
✅ [도구명] 작업 완료

📝 작업 내용:
- DreamCardSelection 버그 수정

📂 수정 파일:
- ui/screens/DreamCardSelection.gd (150 lines)

✅ 테스트:
- Godot에서 확인 완료

📌 Git:
- 로컬 커밋 완료 (push 대기)
```

---

## 🧪 테스트 체크리스트

작업 완료 보고 전:
- [ ] GDScript 에러 없음 (Output 패널)
- [ ] 씬 정상 로드
- [ ] UI 요소 제대로 보임
- [ ] 한글 텍스트 정상 표시
- [ ] 애니메이션/인터랙션 정상 작동
- [ ] 시그널 연결 정상 (null 참조 에러 없음)

---

## 🚨 알려진 이슈 & 주의사항

### Issue 1: .tscn 파일 충돌
- **문제**: .tscn 수동 편집 + Godot 에디터 = 충돌
- **해결**: Godot 닫고 편집, 또는 스크립트로 UI 생성

### Issue 2: 시그널 중복 연결 경고
- **문제**: "Signal already connected" 경고
- **해결**: 연결 전 체크
  ```gdscript
  if not button.pressed.is_connected(_on_button_pressed):
      button.pressed.connect(_on_button_pressed)
  ```

### Issue 3: 한글 폰트
- **현재**: 기본 폰트 사용 중 (한글 지원)
- **향후**: 커스텀 한글 폰트 추가 예정

### Issue 4: BottomNav 안 보임
- **원인**: z-index 또는 순서 문제
- **해결**: 씬 트리 마지막 자식, y=784, height=60

---

## 📞 커뮤니케이션 채널 & 크레딧 관리

### ⚡ 크레딧 Cascade 전략 (중요! - 실제 구독 기반)

**Steve의 실제 비용**: $496/month → 목표 $146 (70% 절감)

**3단계 우선순위**:
```
Level 1: Cursor Pro ($16/month, 이미 지불!) → 60% 작업
   ↓ 한도 근접 (45,611 lines)
Level 2: Claude Code ($30/month, 이미 지불!) → 30% 작업
   ↓ 한도 근접 ($30)
Level 3: Atlas ($450/month → $100 목표) → 10% 작업
   ↓ 주 1-2회만
Level 1 복귀 (월초 리셋)
```

**핵심 전략**: 
- ✅ Cursor/Claude Code 최대 활용 (이미 지불했으니!)
- 🚨 Atlas만 절약 ($450 → $100)
- 💰 월 $350 절감 목표

**문제**: Cursor 26% + Claude Code 0% 사용 (낭비!)  
**해결**: 즉시 Level 1-2 적극 활용 시작!

**자세한 내용**: `CREDITS.md` 참고

### Cursor Pro (Level 1 - 최우선, 60%)
- **비용**: $16/month (고정, 이미 지불!)
- **한도**: 45,611 lines/month
- **현재**: 11,858 lines (26% 사용, 74% 여유!)
- **용도**: 일반 코딩, 버그 수정, 리팩터링
- **전략**: 아낌없이 사용! (안 쓰면 손해)
- **보고**: CHANGELOG + 텔레그램

### Claude Code (Level 2 - 적극 활용, 30%)
- **비용**: $10-30/month (사용량 기반)
- **한도**: $30/month (추정)
- **현재**: $0 사용 (100% 미사용! 🚨)
- **용도**: 대화형 디버깅, 복잡한 분석
- **전략**: 지금부터 적극 활용! (현재 낭비 중)
- **보고**: CHANGELOG + 텔레그램

### Atlas (Level 3 - 절약, 10%)
- **비용**: $450/month (현재, 너무 높음! 🚨)
- **목표**: $100/month (70% 절감)
- **용도**: 
  - 📊 주 1-2회 전체 정리 & 리뷰
  - 📝 문서화 & 팀 공유
  - 🏗️ 복잡한 아키텍처 (필수만)
  - ✅ Git/Notion 승인 및 실행
- **전략**: 여기만 진짜 절약! (일상 작업 금지)
- **가용**: 24시간

### 사용 규칙 (수정)
- **일반 작업 (60%)**: Cursor Pro (Level 1) - 최대 활용!
- **복잡한 작업 (30%)**: Claude Code (Level 2) - 지금 시작!
- **전략/정리 (10%)**: Atlas (Level 3) - 주 1-2회만!
- **전환**: 한도 근접 시 다음 레벨로
- **Git push/Notion**: 항상 Atlas (Steve 승인 후)

**즉시 실행**: Cursor/Claude Code 활용 시작! ($46 구독 낭비 중단!)

---

## 🎯 공통 패턴

### 새 화면 생성
1. `.tscn` + `.gd` 파일 생성 (ui/screens/)
2. `Control` 상속, docstring 추가
3. 메타 화면이면 BottomNav 컴포넌트 추가
4. UITheme으로 스타일링
5. 라이프사이클: `_ready() → _setup_ui() → _connect_signals()`
6. CHANGELOG.md 문서화

### 시그널 연결
```gdscript
# _ready() or _connect_signals()에서
button.pressed.connect(_on_button_pressed)
GameManager.resource_changed.connect(_on_resource_changed)

# 핸들러
func _on_button_pressed() -> void:
    """버튼 클릭 처리"""
    pass
```

### GameManager 사용
```gdscript
# 리소스 가져오기
var gold = GameManager.get_gold()
var energy = GameManager.get_energy()

# 리소스 수정
GameManager.add_gold(50)
GameManager.spend_energy(3)

# 꿈 데이터
var nodes = GameManager.get_dream_nodes()
var logs = GameManager.get_dream_time_logs()
```

### UITheme 사용
```gdscript
# 배경색
var bg_color = UITheme.COLORS.bg

# 버튼 스타일
UITheme.apply_button_style(my_button, "primary")

# 패널 스타일
var style = StyleBoxFlat.new()
style.bg_color = UITheme.COLORS.panel
panel.add_theme_stylebox_override("panel", style)
```

---

## 📐 레이아웃 규격

- **해상도**: 390×844
- **TopBar**: 60px (있을 경우)
- **BottomNav**: 60px, y=784
- **콘텐츠 영역**: 0-784 (TopBar 있으면 60-784)

---

## 🔗 주요 파일 경로

### 절대 경로
- 프로젝트 루트: `~/Projects/geekbrox/teams/game/godot/dream-collector/`
- 메인 씬: `res://scenes/MainLobby.tscn`
- 스크립트: `res://scripts/`, `res://autoload/`
- UI: `res://ui/screens/`, `res://ui/components/`

### 핵심 스크립트
- GameManager: `res://autoload/GameManager.gd`
- CombatManager: `res://autoload/CombatManager.gd`
- UITheme: `res://autoload/UITheme.gd`
- DreamCardSelection: `res://ui/screens/DreamCardSelection.gd`
- InRun_v4: `res://ui/screens/InRun_v4.gd`

---

## 📝 변경 이력

- **2026-02-25**: 초기 작성 (Atlas)
  - 12개 화면 완료
  - Cursor/Claude Code 통합 준비
  - 공통 컨텍스트 문서 생성

---

**이 파일은 프로젝트의 "진실의 원천"입니다.**  
**모든 도구/팀원은 이 파일을 기준으로 작업합니다.**  
**수정 시 팀 전체에 공지하세요!**

---

**Last Updated**: 2026-02-25 by Atlas  
**Version**: 1.0  
**Status**: Active
