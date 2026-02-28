# 홈 화면 캐릭터 스프라이트 미표시 이슈 — Claude Code / Atlas PM 공유용

## 요약

Dream Collector (Godot 4) 메인 로비(Home) 화면에서 **배경은 정상 표시·스크롤되나, 플레이어 걷기 캐릭터 스프라이트가 화면에 보이지 않는** 문제입니다. 콘솔에는 `[MainLobbyUI] Hero walk sprite initialized` 로그가 출력되어 노드는 생성되지만, 실제 렌더링은 되지 않습니다.

---

## 기대 동작

1. **배경** (`home_bg.png`): ViewportFrame 안에서 스크롤 → ✅ 정상 동작
2. **캐릭터** (`player_walk.png`): 64x64, 8프레임 걷기 스프라이트가 배경 위에 표시 → ❌ 미표시

---

## 기술 스택

- Godot 4.6
- 프로젝트: `teams/game/godot/dream-collector/`
- 메인 씬: `res://scenes/MainLobby.tscn`

---

## 레이아웃 구조

```
MainLobby (Control)
└── ViewportFrame (Panel, clip_contents=true)
    └── ViewportContent (Control, clip_contents=true)
        ├── Background (TextureRect) — home_bg.png, 800x200, 스크롤됨 ✅
        └── HeroSprite (HomeHeroSprite) — player_walk.png, 64x64, 8프레임 걷기 ❌
```

- ViewportFrame: 약 358×200px
- HeroSprite 위치: `offset_left=163, offset_top=88, offset_right=227, offset_bottom=152` (64×64 영역)
- z_index=10으로 배경보다 앞에 그려지도록 설정

---

## 시도한 해결 방법 (모두 미해결)

### 1. Node2D + AnimatedSprite2D
- `HomeHeroSprite`가 `Node2D`, 자식이 `AnimatedSprite2D`
- Control 트리 내부에서 Node2D가 렌더링되지 않을 가능성 → 미표시

### 2. Control + TextureRect + 수동 프레임 전환
- `extends Control`, TextureRect로 스프라이트 표시
- `_process`에서 AtlasTexture 8프레임 순환
- Control 기반으로 통일했으나 → 여전히 미표시

### 3. SubViewportContainer + SubViewport + AnimatedSprite2D
- `HomeHeroSprite`가 `SubViewportContainer`
- `SubViewport`(64×64, transparent_bg=true) 안에 `AnimatedSprite2D` 배치
- Control 트리와 분리된 2D 렌더링을 기대 → 여전히 미표시

---

## 관련 파일

| 파일 | 역할 |
|------|------|
| `ui/components/HomeHeroSprite.gd` | 캐릭터 스프라이트 로직 (현재 SubViewport 방식) |
| `ui/components/HomeHeroSprite.tscn` | HomeHeroSprite 씬 정의 |
| `scenes/MainLobby.tscn` | 메인 로비 레이아웃 (ViewportFrame, Background, HeroSprite) |
| `scripts/MainLobbyUI.gd` | 로비 UI 스크립트, 배경 스크롤·캐릭터 흔들림 처리 |
| `assets/sprite/player_walk.png` | 걷기 스프라이트시트 (64×64×8프레임, 4×2 그리드, 마젠타 배경) |
| `assets/bg/home_bg.png` | 홈 배경 이미지 |
| `shaders/chroma_key.gdshader` | 마젠타 배경 투명 처리용 셰이더 |

---

## 스프라이트시트 상세

- **player_walk.png**
  - 크기: 64×64 per frame, 총 8프레임
  - 레이아웃: 4열×2행 (H_FRAMES=4, V_FRAMES=2)
  - 배경: 마젠타(크로마키) → chroma_key.gdshader로 투명 처리

---

## 가능한 원인 후보

1. **Control/Node2D 혼합 트리**  
   - Godot 4에서 Control 트리 안 Node2D 또는 SubViewport 렌더링 이슈

2. **SubViewportContainer 렌더 타이밍**  
   - SubViewport가 첫 프레임에 제대로 그려지지 않거나 업데이트되지 않음

3. **채널/쉐이더 이슈**  
   - chroma_key.gdshader가 전체를 투명하게 만들거나, 색상 처리 오류 가능성

4. **크기/좌표 문제**  
   - SubViewportContainer의 `stretch`·`size` 설정으로 내용이 잘리거나 안 보일 수 있음

---

## 다음 단계 제안

1. **chroma_key 쉐이더 제거**  
   - material 미적용 상태로 테스트해 캐릭터가 보이는지 확인

2. **단순 TextureRect 테스트**  
   - AtlasTexture 1프레임만 사용한 TextureRect를 같은 위치에 두고 표시 여부 확인

3. **독립 씬 테스트**  
   - MainLobby와 분리된 최소 씬에서 HomeHeroSprite만 로드해 렌더링 확인

4. **Godot 4 문서 재확인**  
   - SubViewportContainer, Control 내 Node2D 렌더링 관련 공식 예제·이슈 검토

---

## 추가 참고

- 배경 스크롤: `MainLobbyUI._process()`에서 `viewport_bg.position.x = -background_offset` 처리
- 캐릭터 흔들림: `hero_sprite.offset_left/right`로 x 방향 5px 범위 진동
- `CharacterNode`는 전투/상점 등 다른 화면에서 사용되며, Home에서만 `HomeHeroSprite` 사용
