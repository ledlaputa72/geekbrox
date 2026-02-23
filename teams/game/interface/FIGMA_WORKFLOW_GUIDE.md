# Figma 워크플로우 가이드 - TSX → Figma → Godot/Unity

**작성일:** 2026-02-23  
**목적:** Dream Collector UI를 TSX에서 Figma로 전환 후 게임 엔진으로 export  
**대상:** Steve PM + 디자이너 + 개발자

---

## 📋 목차

1. [워크플로우 개요](#1-워크플로우-개요)
2. [Figma 초기 설정](#2-figma-초기-설정)
3. [TSX → Figma 전환](#3-tsx--figma-전환)
4. [Figma 정리 및 컴포넌트화](#4-figma-정리-및-컴포넌트화)
5. [Figma → Godot Export](#5-figma--godot-export)
6. [Figma → Unity Export](#6-figma--unity-export)
7. [트러블슈팅](#7-트러블슈팅)

---

## 1. 워크플로우 개요

### 전체 프로세스
```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ TSX 컴포넌트 │ →  │   Figma     │ →  │ Godot/Unity │
│ (웹 프로토)  │    │ (디자인)    │    │ (게임 UI)   │
└─────────────┘    └─────────────┘    └─────────────┘
      1단계              2단계              3단계
   (완료 대기)        (이번 작업)        (다음 단계)
```

### 예상 소요 시간
- **1단계** (TSX 생성): 15-20분 (Sub-agent 진행 중)
- **2단계** (Figma 전환): 2-3시간
- **3단계** (엔진 구현): 5-10시간

---

## 2. Figma 초기 설정

### 2.1 Figma 계정 및 프로젝트 생성

**Step 1: Figma 가입/로그인**
- URL: https://www.figma.com
- 무료 플랜으로 충분 (3개 프로젝트까지)
- Google 계정으로 간편 로그인 가능

**Step 2: 새 프로젝트 생성**
1. Figma 메인 화면에서 `New file` 클릭
2. 파일명: `Dream Collector - UI Design`
3. 팀: `Personal` (개인 작업)

**Step 3: 캔버스 설정**
```
프레임 크기: 390 × 844 px (iPhone 14 Pro)
배경색: #1A1A2E (Dark Navy)
```

**프레임 추가 방법:**
1. 툴바에서 `Frame` 도구 선택 (단축키: `F`)
2. 우측 패널에서 `iPhone 14 Pro` 선택
3. 또는 수동으로 390 × 844 입력

---

### 2.2 필수 플러그인 설치

#### 플러그인 1: html.to.design ⭐ (핵심)
**용도:** TSX/HTML을 Figma로 import

**설치 방법:**
1. Figma 메뉴 → `Plugins` → `Browse plugins in Community`
2. 검색: `html.to.design`
3. `Install` 클릭
4. URL: https://www.figma.com/community/plugin/1159123024924461424

**사용 시점:** TSX 렌더링 후 Figma로 전환할 때

---

#### 플러그인 2: Figma to Godot (Godot 사용 시)
**용도:** Figma → Godot `.tscn` 파일 export

**설치 방법:**
1. GitHub: https://github.com/arlez80/figma-to-godot
2. Releases에서 최신 버전 다운로드
3. Figma → `Plugins` → `Development` → `Import plugin from manifest`
4. `manifest.json` 파일 선택

**대안 플러그인:**
- **Godot Figma Importer**: https://github.com/Levrault/figma-to-godot

---

#### 플러그인 3: Figma to Unity (Unity 사용 시)
**용도:** Figma → Unity Prefab export

**설치 방법:**
1. Unity Asset Store: `Figma for Unity`
2. 또는 GitHub: https://github.com/simonolander/figma-unity-bridge
3. Unity 프로젝트에 import

**대안 플러그인:**
- **UI Toolkit Figma Bridge**: https://github.com/tertle/com.bovinelabs.figma

---

#### 플러그인 4: 보조 도구들 (선택)

**Color Palette Generator**
- 자동으로 색상 팔레트 생성
- URL: https://www.figma.com/community/plugin/731400414283148796

**Auto Layout**
- 레이아웃 자동 정렬
- Figma 기본 기능 (단축키: `Shift + A`)

**Content Reel**
- 더미 데이터 자동 생성 (카드 이름, 숫자 등)
- URL: https://www.figma.com/community/plugin/731627216655469013

---

### 2.3 디자인 시스템 설정

#### Color Styles 생성

**Step 1: 색상 추가**
1. 좌측 상단 Assets 패널 클릭
2. `Local Styles` → `+` 버튼
3. `Create Color Style` 선택

**Step 2: Dream Collector 색상 팔레트**

| 색상명 | HEX | 용도 |
|--------|-----|------|
| `Primary/Blue` | #7B9EF0 | 주 색상 |
| `Background/Dark` | #1A1A2E | 배경 |
| `Background/Medium` | #2C2C3E | 카드, 패널 |
| `Text/White` | #FFFFFF | 주 텍스트 |
| `Text/Gray` | #AAAAAA | 보조 텍스트 |
| `Success` | #4CAF50 | 성공 상태 |
| `Warning` | #FFC107 | 경고 |
| `Error` | #F44336 | 오류 |
| `Gold` | #FFD700 | Reveries |

**Step 3: Gradient Styles (희귀도)**

| 희귀도 | Gradient | 코드 |
|--------|----------|------|
| Common | Gray | #AAAAAA → #CCCCCC (135°) |
| Uncommon | Green | #4CAF50 → #81C784 (135°) |
| Rare | Blue | #2196F3 → #64B5F6 (135°) |
| Epic | Purple | #9C27B0 → #BA68C8 (135°) |
| Legendary | Gold | #FFC107 → #FFD54F (135°) |

**Gradient 생성 방법:**
1. 사각형 선택 → Fill 색상 클릭
2. `Linear` gradient 선택
3. 각도: 135° 설정
4. 색상 2개 추가 (위 표 참고)
5. `Create Style` 클릭

---

#### Text Styles 생성

**Step 1: Nunito 폰트 설치**
1. Google Fonts: https://fonts.google.com/specimen/Nunito
2. `Download family` 클릭
3. 폰트 파일 설치 (Nunito-Regular.ttf, Nunito-Bold.ttf)
4. Figma 재시작

**Step 2: Text Styles**

| 스타일명 | 크기 | 굵기 | 용도 |
|----------|------|------|------|
| `Heading/H1` | 24px | Bold (700) | 화면 제목 |
| `Heading/H2` | 20px | Bold (700) | 섹션 제목 |
| `Heading/H3` | 18px | Bold (700) | 서브 제목 |
| `Body/Large` | 16px | Regular (400) | 본문 |
| `Body/Medium` | 14px | Regular (400) | 보조 텍스트 |
| `Body/Small` | 12px | Regular (400) | 캡션 |
| `Button` | 16px | Bold (700) | 버튼 텍스트 |

**생성 방법:**
1. 텍스트 도구 (`T`) → 텍스트 입력
2. 우측 패널에서 폰트, 크기, 굵기 설정
3. `...` → `Create Text Style` → 이름 입력

---

#### Effect Styles (그림자)

**카드 그림자:**
- 이름: `Shadow/Card`
- Type: Drop Shadow
- X: 0, Y: 2, Blur: 4, Color: #000000 20%

**버튼 그림자:**
- 이름: `Shadow/Button`
- Type: Drop Shadow
- X: 0, Y: 4, Blur: 12, Color: #7B9EF0 30%

**생성 방법:**
1. 사각형 선택 → 우측 패널 `Effects` → `+`
2. `Drop Shadow` 선택 → 값 입력
3. `Create Style` 클릭

---

## 3. TSX → Figma 전환

### 3.1 TSX 렌더링 (로컬 서버)

**Step 1: TSX 컴포넌트 확인**
```bash
cd ~/Projects/geekbrox/teams/game/interface/v0-exports/dream-theme-v1.1
ls -la
```

**확인할 파일:**
- c01-main-lobby-v1.1.tsx (✅ 완료)
- c02-card-library-v1.1.tsx (🔄 Sub-agent 작업 중)
- c03-deck-builder-v1.1.tsx
- c04-upgrade-tree-v1.1.tsx
- c05-shop-v1.1.tsx
- c06-run-prep-v1.1.tsx
- c07-in-run-v1.1.tsx
- c08-combat-v1.1.tsx

---

**Step 2: 간단한 HTML 래퍼 생성**

각 TSX를 렌더링하기 위한 HTML 파일이 필요합니다.

**파일 생성:** `viewer.html`

```html
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Dream Collector UI Viewer</title>
  <script src="https://cdn.tailwindcss.com"></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;700&display=swap" rel="stylesheet">
  <style>
    body {
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      background: #0A0A0F;
    }
    #root {
      width: 390px;
      height: 844px;
      overflow: hidden;
      box-shadow: 0 0 50px rgba(0,0,0,0.5);
    }
  </style>
</head>
<body>
  <div id="root"></div>
  <!-- TSX 컴포넌트가 여기에 렌더링됩니다 -->
  <script type="module">
    // React 컴포넌트 로드 및 렌더링
    // (실제 구현은 빌드 도구 필요)
  </script>
</body>
</html>
```

**Step 3: 로컬 서버 실행 (옵션 2가지)**

**옵션 A: Python 간단 서버**
```bash
cd ~/Projects/geekbrox/teams/game/interface/v0-exports/dream-theme-v1.1
python3 -m http.server 3000
```

**옵션 B: Node.js 서버 (권장)**
```bash
# 간단한 Next.js 앱 생성
npx create-next-app@latest dream-ui-viewer --typescript --tailwind --app
cd dream-ui-viewer

# TSX 컴포넌트 복사
cp ../dream-theme-v1.1/*.tsx ./app/components/

# 개발 서버 실행
npm run dev
```

브라우저에서 http://localhost:3000 접속

---

### 3.2 html.to.design 플러그인 사용

**Step 1: 플러그인 실행**
1. Figma에서 `Plugins` → `html.to.design` 선택
2. 플러그인 창이 열림

**Step 2: URL 입력**
```
http://localhost:3000
```

**또는 개별 컴포넌트:**
```
http://localhost:3000/main-lobby
http://localhost:3000/deck-builder
...
```

**Step 3: Import 옵션 설정**
- ✅ Import layout (레이아웃 import)
- ✅ Import text (텍스트 import)
- ✅ Import images (이미지 import)
- ✅ Import colors (색상 import)
- ⬜ Import as components (선택 해제, 나중에 수동 컴포넌트화)

**Step 4: Import 실행**
- `Import` 버튼 클릭
- 몇 초 대기 (렌더링 시간)
- Figma 캔버스에 UI가 생성됨

---

### 3.3 수동 스크린샷 방법 (플러그인 대안)

플러그인이 작동하지 않을 경우:

**Step 1: 고해상도 스크린샷**
1. 브라우저에서 `F12` → Developer Tools
2. Device Toolbar 활성화 (Ctrl+Shift+M)
3. 크기: 390 × 844 (Custom)
4. 스크린샷: `...` → `Capture screenshot`

**Step 2: Figma에 Import**
1. 스크린샷을 Figma로 드래그
2. 프레임 크기에 맞춰 배치 (390×844)
3. 레이어로 사용 (트레이싱 레퍼런스)

**Step 3: 수동 재구성**
- 스크린샷을 보며 Figma 요소로 재구성
- 정확한 치수는 TSX 코드 참고
- Color Picker로 색상 추출

---

## 4. Figma 정리 및 컴포넌트화

### 4.1 레이어 구조 정리

**Before (import 직후):**
```
Frame 1
  └─ Group 1
      └─ Group 2
          └─ Rectangle 1
          └─ Text 1
```

**After (정리 후):**
```
MainLobby
  ├─ TopBar
  │   ├─ ReveriesCounter
  │   └─ SettingsButton
  ├─ CharacterArea
  ├─ OfflineBanner
  ├─ ActionGrid
  │   ├─ RunStartButton
  │   ├─ CardsButton
  │   ├─ UpgradeButton
  │   └─ ShopButton
  └─ TabBar
      ├─ HomeTab
      ├─ CardsTab
      ├─ UpgradeTab
      ├─ ProgressTab
      └─ ShopTab
```

**정리 방법:**
1. 레이어 선택 → 우클릭 → `Rename` (또는 `Ctrl+R`)
2. 의미있는 이름으로 변경
3. 폴더 구조로 그룹화 (`Ctrl+G`)

---

### 4.2 Auto Layout 적용

**Auto Layout이란?**
- Figma의 Flexbox와 유사
- 자동 정렬 및 간격 조정
- 반응형 디자인 가능

**적용 방법:**
1. 그룹 선택 (예: ActionGrid)
2. `Shift + A` (Auto Layout 토글)
3. 우측 패널에서 설정:
   - Direction: Horizontal / Vertical
   - Gap: 12px (간격)
   - Padding: 20px (여백)
   - Alignment: Center

**권장 적용 위치:**
- ActionGrid (2×2 그리드)
- TabBar (5개 탭)
- DeckArea (가로 스크롤)
- CardGrid (3열 그리드)

---

### 4.3 컴포넌트 생성

**컴포넌트란?**
- 재사용 가능한 UI 요소
- 수정 시 모든 인스턴스에 반영
- Godot/Unity export 시 유리

**생성 방법:**

**Step 1: 카드 컴포넌트 (예시)**
1. 카드 레이어 선택 (예: CommonCard)
2. 우클릭 → `Create Component` (또는 `Ctrl+Alt+K`)
3. 이름: `Card/Common`

**Step 2: 변형(Variant) 추가**
1. 컴포넌트 선택
2. 우측 패널 → `Add Variant`
3. Property 추가:
   - Rarity: Common, Uncommon, Rare, Epic, Legendary
   - State: Default, Hover, Pressed, Disabled

**Step 3: 각 변형 스타일 적용**
- Common: Gray gradient
- Uncommon: Green gradient
- Rare: Blue gradient
- Epic: Purple gradient
- Legendary: Gold gradient

**생성할 컴포넌트 목록:**
1. Card (5 rarities)
2. Button (Primary, Secondary, Success, Warning)
3. Icon (각종 아이콘)
4. Badge (숫자, 상태)
5. StatusBar (HP, Energy)
6. TabButton (5 tabs)

---

### 4.4 컴포넌트 라이브러리 구성

**폴더 구조:**
```
Components/
  ├─ Buttons/
  │   ├─ PrimaryButton
  │   ├─ SecondaryButton
  │   └─ IconButton
  ├─ Cards/
  │   └─ Card (with variants)
  ├─ Bars/
  │   ├─ StatusBar
  │   └─ ProgressBar
  ├─ Icons/
  │   ├─ Home
  │   ├─ Settings
  │   └─ ...
  └─ Badges/
      └─ CountBadge
```

**정리 팁:**
- 컴포넌트는 별도 페이지에 모음 (Page: `Components`)
- 메인 페이지에서는 인스턴스만 사용
- 일관된 네이밍 규칙 (PascalCase)

---

## 5. Figma → Godot Export

### 5.1 Figma to Godot 플러그인 사용

**Step 1: 플러그인 실행**
1. Figma → `Plugins` → `Figma to Godot`
2. Export 설정 창 열림

**Step 2: Export 설정**
```yaml
Output Format: .tscn (Godot Scene)
Export Selection: Current Frame / Whole Page
Include Animations: Yes (가능하면)
Coordinate System: Godot (0,0 = top-left)
```

**Step 3: Export**
1. `Export` 버튼 클릭
2. `.tscn` 파일 저장
3. Godot 프로젝트의 `res://scenes/ui/` 폴더에 복사

---

### 5.2 Godot에서 Import

**Step 1: Godot 프로젝트 열기**
```bash
godot --editor path/to/your/project
```

**Step 2: Scene Import**
1. FileSystem 패널에서 `.tscn` 파일 확인
2. 더블클릭 → Scene 에디터 열림
3. 자동 import된 노드 구조 확인

**Step 3: 노드 구조 예시**
```
MainLobby (Control)
  ├─ TopBar (HBoxContainer)
  │   ├─ ReveriesCounter (Label)
  │   └─ SettingsButton (Button)
  ├─ CharacterArea (CenterContainer)
  ├─ ActionGrid (GridContainer)
  │   ├─ RunStartButton (Button)
  │   ├─ CardsButton (Button)
  │   ├─ UpgradeButton (Button)
  │   └─ ShopButton (Button)
  └─ TabBar (HBoxContainer)
```

---

### 5.3 수동 조정 (import 후)

**필요한 조정:**

**1. 애니메이션 추가**
```gdscript
# CharacterArea에 Animation 추가
var tween = create_tween().set_loops()
tween.tween_property($CharacterArea, "position:y", -10, 1.0)
tween.tween_property($CharacterArea, "position:y", 10, 1.0)
```

**2. 시그널 연결**
```gdscript
# RunStartButton 클릭 시
$ActionGrid/RunStartButton.connect("pressed", self, "_on_run_start")

func _on_run_start():
    get_tree().change_scene("res://scenes/RunPrep.tscn")
```

**3. 스타일 조정**
```gdscript
# 그라데이션 배경 (StyleBoxFlat)
var style = StyleBoxFlat.new()
style.bg_color = Color("#7B9EF0")
style.set_corner_radius_all(16)
$RunStartButton.add_stylebox_override("normal", style)
```

---

### 5.4 GDScript 로직 추가

**MainLobby.gd 템플릿:**
```gdscript
extends Control

# State
var reveries: int = 1234
var offline_rewards: int = 2345
var active_tab: String = "home"

func _ready():
    # 초기화
    update_reveries_counter()
    setup_buttons()
    setup_animations()

func update_reveries_counter():
    $TopBar/ReveriesCounter.text = "Reveries: %d" % reveries

func setup_buttons():
    # 버튼 시그널 연결
    $ActionGrid/RunStartButton.connect("pressed", self, "_on_run_start")
    $ActionGrid/CardsButton.connect("pressed", self, "_on_cards")
    # ...

func setup_animations():
    # 캐릭터 플로팅 애니메이션
    var tween = create_tween().set_loops()
    tween.tween_property($CharacterArea, "position:y", 
        $CharacterArea.position.y - 10, 1.0).set_trans(Tween.TRANS_SINE)
    tween.tween_property($CharacterArea, "position:y", 
        $CharacterArea.position.y + 10, 1.0).set_trans(Tween.TRANS_SINE)

func _on_run_start():
    get_tree().change_scene_to_file("res://scenes/RunPrep.tscn")
```

---

## 6. Figma → Unity Export

### 6.1 Figma to Unity 플러그인 사용

**Step 1: Unity 패키지 Import**
1. Unity 프로젝트 열기
2. `Assets` → `Import Package` → `Custom Package`
3. Figma Bridge 패키지 선택 (.unitypackage)

**Step 2: Figma 연동**
1. Unity 메뉴 → `Window` → `Figma Bridge`
2. Figma API Token 입력:
   - Figma → Settings → Personal Access Tokens
   - `Generate new token` → 복사
   - Unity에 붙여넣기
3. File URL 입력 (Figma 파일 URL)

**Step 3: Import**
1. Figma Bridge 창에서 프레임 선택
2. `Import` 클릭
3. Prefab 생성 위치 선택 (`Assets/Prefabs/UI/`)

---

### 6.2 Unity에서 UI 설정

**Step 1: Canvas 설정**
```csharp
// Canvas Scaler 설정
Canvas canvas = GetComponent<Canvas>();
canvas.renderMode = RenderMode.ScreenSpaceOverlay;

CanvasScaler scaler = GetComponent<CanvasScaler>();
scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
scaler.referenceResolution = new Vector2(390, 844);
scaler.matchWidthOrHeight = 0.5f; // 가로/세로 균형
```

**Step 2: RectTransform 확인**
```csharp
// Import된 UI 요소 확인
RectTransform runButton = transform.Find("ActionGrid/RunStartButton").GetComponent<RectTransform>();
Debug.Log($"Position: {runButton.anchoredPosition}");
Debug.Log($"Size: {runButton.sizeDelta}");
```

**Step 3: UI Toolkit 사용 (최신 방법)**
```csharp
// .uxml 파일로 import (Unity 2021+)
var uxml = AssetDatabase.LoadAssetAtPath<VisualTreeAsset>("Assets/UI/MainLobby.uxml");
var ui = uxml.CloneTree();
GetComponent<UIDocument>().rootVisualElement.Add(ui);
```

---

### 6.3 C# 로직 추가

**MainLobby.cs 템플릿:**
```csharp
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class MainLobby : MonoBehaviour
{
    [Header("UI References")]
    public TextMeshProUGUI reveriesCounter;
    public Button runStartButton;
    public Button cardsButton;
    public Button upgradeButton;
    public Button shopButton;
    
    [Header("State")]
    private int reveries = 1234;
    private int offlineRewards = 2345;
    
    void Start()
    {
        SetupButtons();
        UpdateUI();
        StartAnimations();
    }
    
    void SetupButtons()
    {
        runStartButton.onClick.AddListener(OnRunStart);
        cardsButton.onClick.AddListener(OnCards);
        upgradeButton.onClick.AddListener(OnUpgrade);
        shopButton.onClick.AddListener(OnShop);
    }
    
    void UpdateUI()
    {
        reveriesCounter.text = $"Reveries: {reveries:N0}";
    }
    
    void StartAnimations()
    {
        // 캐릭터 플로팅 애니메이션 (DOTween 사용)
        var character = transform.Find("CharacterArea");
        character.DOLocalMoveY(character.localPosition.y + 10, 1f)
            .SetEase(Ease.InOutSine)
            .SetLoops(-1, LoopType.Yoyo);
    }
    
    void OnRunStart()
    {
        SceneManager.LoadScene("RunPrep");
    }
}
```

---

### 6.4 Unity 애니메이션 설정

**Animator 사용:**

**Step 1: Animator Controller 생성**
1. `Assets/Animations/` 폴더 생성
2. 우클릭 → `Create` → `Animator Controller`
3. 이름: `MainLobbyAnimator`

**Step 2: Animation Clip 생성**
```
CharacterFloat.anim:
- 0.0s: position.y = 0
- 1.0s: position.y = -10
- 2.0s: position.y = 0
Curve: Ease In Out
Loop: Yes
```

**Step 3: Button Animations**
```
ButtonPress.anim:
- 0.0s: scale = (1, 1, 1)
- 0.1s: scale = (0.95, 0.95, 1)
- 0.2s: scale = (1, 1, 1)
```

---

## 7. 트러블슈팅

### 7.1 Figma Import 문제

**문제: html.to.design이 작동하지 않음**

**해결책 1:** 브라우저 CORS 설정
```bash
# Chrome을 CORS 비활성화로 실행 (테스트용)
chrome.exe --disable-web-security --user-data-dir="C:/temp/chrome"
```

**해결책 2:** 수동 스크린샷 사용 (위 섹션 3.3 참고)

**해결책 3:** Figma Desktop App 사용
- 브라우저 버전 대신 Desktop App 다운로드
- 더 안정적인 플러그인 실행

---

**문제: Gradient가 import되지 않음**

**해결책:**
- Figma에서 수동으로 Gradient 재생성
- Color Styles에서 Gradient 미리 정의
- 코드로 Gradient 적용 (Godot/Unity)

---

**문제: 폰트가 제대로 import되지 않음**

**해결책:**
1. Nunito 폰트를 Godot/Unity 프로젝트에 직접 복사
2. Godot: `res://fonts/Nunito-Regular.ttf`
3. Unity: `Assets/Fonts/Nunito-Regular.ttf`
4. 코드에서 폰트 참조

---

### 7.2 Godot Export 문제

**문제: .tscn 파일이 제대로 열리지 않음**

**해결책:**
- Godot 버전 확인 (4.x vs 3.x 호환성)
- 수동으로 노드 구조 재구성
- Figma 레이어를 단순화 (과도한 중첩 제거)

---

**문제: 위치와 크기가 이상함**

**해결책:**
```gdscript
# Anchor 및 Margin 재설정
$TopBar.anchor_top = 0
$TopBar.anchor_bottom = 0
$TopBar.margin_top = 0
$TopBar.margin_bottom = 60
```

---

### 7.3 Unity Export 문제

**문제: Prefab 생성 실패**

**해결책:**
- Unity 버전 확인 (2021+ 권장)
- UI Toolkit 대신 uGUI 사용
- 수동으로 Prefab 구성

---

**문제: RectTransform 값이 맞지 않음**

**해결책:**
```csharp
// 수동 조정
RectTransform rt = GetComponent<RectTransform>();
rt.anchorMin = new Vector2(0, 1); // top-left
rt.anchorMax = new Vector2(0, 1);
rt.pivot = new Vector2(0, 1);
rt.anchoredPosition = new Vector2(20, -20);
rt.sizeDelta = new Vector2(180, 120);
```

---

## 8. 다음 단계 체크리스트

### 즉시 실행 (Steve 작업)

- [ ] Figma 계정 생성/로그인
- [ ] 새 프로젝트 생성: "Dream Collector - UI Design"
- [ ] 필수 플러그인 설치:
  - [ ] html.to.design
  - [ ] Figma to Godot (or Unity)
- [ ] Color Styles 생성 (Dream 팔레트)
- [ ] Text Styles 생성 (Nunito 폰트)
- [ ] Gradient Styles 생성 (희귀도 5개)

### Sub-Agent 완료 후 (2-3시간)

- [ ] TSX 컴포넌트 확인 (8개)
- [ ] 로컬 서버 실행 (Next.js or Python)
- [ ] html.to.design으로 Figma import (8개 화면)
- [ ] 레이어 구조 정리
- [ ] Auto Layout 적용
- [ ] 컴포넌트 생성 (Card, Button 등)

### Figma 정리 완료 후 (1-2일)

- [ ] Godot/Unity export 실행
- [ ] 게임 엔진에서 import 확인
- [ ] 애니메이션 추가
- [ ] 인터랙션 로직 구현
- [ ] 게임 데이터 연동

---

## 📚 참고 자료

**Figma 공식 문서:**
- https://help.figma.com

**플러그인:**
- html.to.design: https://www.figma.com/community/plugin/1159123024924461424
- Figma to Godot: https://github.com/arlez80/figma-to-godot
- Figma Unity Bridge: https://github.com/simonolander/figma-unity-bridge

**튜토리얼:**
- Figma Basics: https://www.youtube.com/watch?v=FTFaQWZBqQ8
- Godot UI: https://docs.godotengine.org/en/stable/tutorials/ui/index.html
- Unity UI Toolkit: https://docs.unity3d.com/Manual/UIElements.html

---

**작성자:** Atlas (AI PM)  
**최종 업데이트:** 2026-02-23  
**다음 업데이트:** Sub-Agent TSX 생성 완료 후
