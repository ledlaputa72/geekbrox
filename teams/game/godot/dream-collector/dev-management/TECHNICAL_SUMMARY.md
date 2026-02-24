# Dream Collector - 기술 요약

> Godot 4 모바일 게임 기술 스택 및 아키텍처

**버전:** 0.1.0  
**엔진:** Godot 4.x  
**플랫폼:** Android / iOS (모바일)  
**해상도:** 390×844px (Portrait)

---

## 🛠️ 기술 스택

### 게임 엔진
- **Godot Engine:** 4.x (최신 stable)
- **스크립팅 언어:** GDScript
- **렌더링:** Vulkan Mobile / GLES3

### 플랫폼 타겟
- **Android:** API 21+ (Android 5.0+)
- **iOS:** iOS 12+
- **해상도:** 390×844px (iPhone 14 기준)
- **방향:** Portrait (세로 모드)

### 저장 시스템
- **포맷:** JSON
- **경로:** `user://save.json`
  - Android: `/data/data/<package>/files/save.json`
  - iOS: `Documents/save.json`
- **백업:** 자동 백업 (미구현)

### 디자인 시스템
- **UITheme:** Autoload 싱글톤
- **색상:** 30+ 프리셋
- **그리드:** 8px 기반 스페이싱
- **폰트:** Nunito (Google Fonts)

---

## 🏗️ 프로젝트 구조

```
dream-collector/
├── project.godot              # Godot 프로젝트 설정
├── .gitignore                # Git 제외 파일
│
├── scenes/                   # 메인 씬
│   └── MainLobby.tscn
│
├── ui/                       # UI 관련
│   ├── components/           # 재사용 컴포넌트
│   │   ├── AlertModal.tscn
│   │   ├── AlertModal.gd
│   │   ├── CardItem.tscn
│   │   └── CardItem.gd
│   │
│   └── screens/              # 화면 씬
│       ├── CardLibrary.tscn/.gd
│       ├── DeckBuilder.tscn/.gd
│       ├── Shop.tscn/.gd
│       └── ...
│
├── scripts/                  # 전역 스크립트
│   ├── GameManager.gd       # AutoLoad: 게임 상태 관리
│   ├── SaveSystem.gd        # AutoLoad: 저장/로드
│   ├── IdleSystem.gd        # AutoLoad: 오프라인 수집
│   └── UITheme.gd           # AutoLoad: 디자인 시스템
│
├── assets/                   # 에셋 (추후)
│   ├── fonts/
│   ├── sprites/
│   └── sounds/
│
├── tests/                    # 테스트
│   └── run_tests.gd
│
└── dev-management/           # 개발 관리 문서
    ├── DEVLOG.md
    ├── CHECKLIST.md
    ├── PROGRESS_TRACKER.md
    └── TECHNICAL_SUMMARY.md
```

---

## 🧩 핵심 시스템 아키텍처

### 1. Autoload 싱글톤 (전역 시스템)

#### GameManager
```gdscript
# 역할: 게임 상태 관리
- 재화 관리 (reveries, gems, energy)
- 덱 데이터 (current_deck)
- 진행 상태 (runs, prestige)
- 시그널 발행 (reveries_changed, gems_changed, etc.)
```

#### SaveSystem
```gdscript
# 역할: 저장/로드
- save_game(): JSON 저장
- load_game(): JSON 로드
- 경로: user://save.json
- 자동 타입 변환 (float, int, Array)
```

#### IdleSystem
```gdscript
# 역할: 오프라인 수집
- 마지막 저장 시간 추적
- 오프라인 시간 계산 (최대 8시간)
- 수집 속도 계산 (multiplier)
- 자동 수집 (매 초)
```

#### UITheme
```gdscript
# 역할: 디자인 시스템
- COLORS: 30+ 색상 프리셋
- SPACING: xs(4) ~ xxl(48)
- FONT_SIZES: tiny(10) ~ large(32)
- apply_button_style(): 버튼 스타일 자동 적용
- color(), spacing(): 헬퍼 함수
```

---

### 2. UI 아키텍처

#### 화면 분류
1. **메타 화면** (Tab Bar 있음)
   - MainLobby, CardLibrary, DeckBuilder, UpgradeTree, Shop
   - BottomNav 고정 표시

2. **인런 화면** (Tab Bar 없음)
   - InRun, Combat
   - 몰입형 전체 화면

3. **모달 화면** (오버레이)
   - VictoryScreen, DefeatScreen, RewardsModal, Settings
   - 반투명 오버레이 위에 표시

#### 재사용 컴포넌트
- **CardItem:** 카드 표시 (타입별 색상, 레어리티 테두리)
- **AlertModal:** 모달 팝업 (CanvasLayer, 1~2 버튼)
- **BottomNav:** 하단 탭 바 (5개 탭)

#### 네비게이션 패턴
```gdscript
# 씬 전환
get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")

# 활성 탭 설정
_set_active_tab(tab_index)

# 뒤로 가기
get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
```

---

### 3. 시그널 기반 반응형 UI

```gdscript
# GameManager 시그널
signal reveries_changed(new_amount: float)
signal gems_changed(new_amount: int)
signal energy_changed(new_amount: int)
signal deck_saved(deck_size: int)

# 연결 예시
GameManager.reveries_changed.connect(_on_reveries_changed)

# 핸들러
func _on_reveries_changed(new_amount: float) -> void:
    gold_label.text = str(int(new_amount))
```

---

### 4. 저장 데이터 구조

```json
{
  "version": "0.1.0",
  "timestamp": 1708821600,
  "reveries": 1500.0,
  "gems": 250,
  "energy": 80,
  "dream_shards": 5,
  "total_runs_completed": 12,
  "prestige_count": 1,
  "base_collection_rate": 12.5,
  "last_save_timestamp": 1708821600,
  "card_multiplier": 1.0,
  "prestige_multiplier": 1.25,
  "current_deck": [
    {"id": "atk_001", "name": "Quick Strike", "type": "attack", "cost": 1},
    ...
  ]
}
```

---

### 5. 재화 시스템

#### 재화 종류
1. **Gold (Reveries)** 🪙
   - 용도: 카드 구매, 업그레이드
   - 획득: 오프라인 수집, 런 완료, 이벤트
   - 타입: `float`

2. **Gems** 💎
   - 용도: 프리미엄 재화 (IAP, 재화 교환)
   - 획득: 현금 결제, 일일 보상
   - 타입: `int`

3. **Energy** ⚡
   - 용도: 런 시작, 이벤트 참여
   - 획득: 시간 회복, 보석 구매
   - 타입: `int`

#### 재화 흐름
```
[IAP] → Gems → [교환] → Energy/Gold → [소비] → 게임 진행
```

---

## 🎨 디자인 시스템

### 색상 팔레트

#### 기본 색상
```gdscript
primary: #7B9EF0      # 메인 블루
bg: #1A1A2E           # 다크 배경
panel: #16213E        # 패널 배경
text: #E8E8E8         # 텍스트 화이트
```

#### 카드 타입 색상
```gdscript
attack: #E74C3C       # 빨강
defense: #3498DB      # 파랑
skill: #2ECC71        # 초록
power: #9B59B6        # 보라
```

#### 레어리티 색상
```gdscript
common: #95A5A6       # 회색
rare: #3498DB         # 파랑
epic: #9B59B6         # 보라
legendary: #F39C12    # 오렌지
```

### 스페이싱
```gdscript
xs: 4px    # 매우 작은 간격
sm: 8px    # 작은 간격
md: 16px   # 기본 간격
lg: 24px   # 큰 간격
xl: 32px   # 매우 큰 간격
xxl: 48px  # 특대 간격
```

### 폰트 사이즈
```gdscript
tiny: 10px      # 작은 레이블
small: 12px     # 보조 텍스트
body: 14px      # 본문
subtitle: 16px  # 부제목
title: 20px     # 제목
header: 24px    # 헤더
large: 32px     # 대형 텍스트
```

---

## 🔧 개발 도구

### 치트 코드 (개발용)
```
MainLobby에서만 작동:
M 키: 골드 +1,000
N 키: 골드 +10,000
G 키: 보석 +100
H 키: 보석 +1,000
E 키: 에너지 +50
R 키: 에너지 +200
```

### 디버그 출력
```gdscript
print("[GameManager] Reveries: %.1f" % reveries)
push_error("[SaveSystem] 저장 실패")
```

### 로그 위치
- **Godot 에디터:** Output 패널
- **Android:** `adb logcat`
- **iOS:** Xcode Console

---

## 📱 모바일 최적화

### 해상도 대응
```gdscript
# project.godot
[display]
window/size/viewport_width=390
window/size/viewport_height=844
window/size/mode=2  # Fullscreen
window/stretch/mode="canvas_items"
window/stretch/aspect="expand"
```

### 터치 입력
- 버튼: 최소 44×44px (Apple HIG)
- 드래그: 카드 플레이 시 사용
- 스와이프: 화면 전환 (추후)

### 성능 목표
- FPS: 60fps (안정적)
- 메모리: < 200MB
- 로딩 시간: < 2초
- 배터리 소모: 낮음

---

## 🧪 테스트 전략

### 유닛 테스트
```gdscript
# tests/run_tests.gd
func test_game_manager_add_reveries():
    GameManager.reveries = 0
    GameManager.add_reveries(100)
    assert(GameManager.reveries == 100)
```

### 통합 테스트
- 전체 런 플레이 시나리오
- 저장/로드 검증
- 씬 전환 검증

### 수동 테스트
- 실제 디바이스 테스트 (Android/iOS)
- 다양한 해상도 테스트
- 터치 반응성 테스트

---

## 🚀 빌드 및 배포

### 빌드 타겟
1. **Android**
   - 포맷: APK / AAB
   - 최소 API: 21 (Android 5.0)
   - 아키텍처: armeabi-v7a, arm64-v8a

2. **iOS**
   - 포맷: IPA
   - 최소 버전: iOS 12
   - 아키텍처: arm64

### Export 설정
```
# project.godot
[export]
Android: 설정 완료
iOS: 설정 필요
```

---

## 📚 참고 문서

### 외부 링크
- [Godot 4 공식 문서](https://docs.godotengine.org/en/stable/)
- [GDScript 스타일 가이드](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)
- [Godot UI 가이드](https://docs.godotengine.org/en/stable/tutorials/ui/index.html)

### 내부 문서
- `GODOT_UI_WORKFLOW.md`: 워크플로우 가이드
- `IMPLEMENTATION_GUIDE.md`: 화면 구현 가이드
- `QUICK_START.md`: 초보자 튜토리얼
- `DEVLOG.md`: 개발 일지

---

**작성일:** 2026-02-24  
**작성자:** Atlas  
**버전:** 1.0
