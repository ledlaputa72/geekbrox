# Dream Collector

**로그라이크 덱빌딩 RPG** | Godot 4.3 | GDScript

---

## 🎮 프로젝트 개요

- **장르**: Roguelike Deckbuilding RPG
- **엔진**: Godot 4.3
- **해상도**: 390×844 (세로 모드, 모바일 타겟)
- **언어**: GDScript + 한국어 UI
- **상태**: 코어 UI 완료 (12/12 화면), 게임플레이 로직 진행 중

---

## 📚 문서 인덱스

### 🚀 빠른 시작

| 문서 | 대상 | 설명 |
|------|------|------|
| **README.md** | 모든 팀원 | 이 파일 (프로젝트 개요) |
| **PROJECT_CONTEXT.md** | 모든 AI 도구 | 공통 컨텍스트 (필독!) |
| **README_CURSOR.md** | Cursor 사용자 | 3분 빠른 시작 |

### 🛠️ 도구별 가이드

| 문서 | 대상 | 크기 | 설명 |
|------|------|------|------|
| **CURSOR_GUIDE.md** | Cursor IDE | 9KB | 상세 사용법 |
| **CLAUDE_CODE_GUIDE.md** | VSCode | 9KB | 상세 사용법 |
| **.cursorrules** | Cursor AI | 13KB | 자동 컨텍스트 |
| **.clinerules** | Claude Code | 5KB | 자동 컨텍스트 |

### 📋 프로젝트 관리

| 문서 | 용도 | 업데이트 |
|------|------|----------|
| **CHANGELOG.md** | 변경 이력 | 작업 완료 후 즉시 |
| **WORKFLOW_INTEGRATION.md** | 통합 워크플로우 | 프로세스 변경 시 |
| **CREDITS.md** | 크레딧 관리 & Cascade 전략 | 크레딧 변동 시 |
| **CREDITS_QUICK.md** | 빠른 참조 카드 | - |

---

## 🏗️ 프로젝트 구조

```
dream-collector/
├── scripts/                # 핵심 게임 로직
│   ├── GameManager.gd     # 글로벌 상태
│   ├── CombatManager.gd   # 전투 시스템
│   └── DeckManager.gd     # 덱 관리
│
├── autoload/               # 싱글톤
│   ├── GameManager.gd
│   ├── CombatManager.gd
│   └── UITheme.gd         # 색상 팔레트
│
├── ui/
│   ├── screens/           # 12개 메인 화면
│   │   ├── MainLobby.tscn/gd           # 홈
│   │   ├── InRun_v4.tscn/gd            # 액티브 런
│   │   ├── DreamCardSelection.tscn/gd  # 카드 선택 (뽑기)
│   │   └── ...
│   │
│   └── components/        # 재사용 컴포넌트
│       ├── BottomNav.tscn/gd           # 네비게이션 바
│       ├── CharacterNode.tscn/gd       # HP바 + 스프라이트
│       └── DamageNumber.tscn/gd        # 데미지 숫자
│
├── scenes/
│   └── MainLobby.tscn     # 진입점
│
└── [문서들]
```

---

## 🎯 개발 도구

### Cursor IDE (추천)
**강점**: 멀티파일 수정, 빠른 반복, 무제한 사용

```bash
cd ~/Projects/geekbrox/teams/game/godot/dream-collector
cursor .
```

**첫 작업**:
- `Cmd+I` (Composer)
- "DreamCardSelection의 애니메이션 속도를 0.3초로 변경해줘"

### Claude Code (VSCode)
**강점**: 대화형 디버깅, Git 통합

```bash
cd ~/Projects/geekbrox/teams/game/godot/dream-collector
code .
```

**첫 작업**:
- Cline 패널 열기
- `@PROJECT_CONTEXT.md`
- "프로젝트 이해하고, 버그 수정 방법 알려줘"

### Atlas (Telegram)
**강점**: 프로젝트 전략, Git/Notion 관리, 24시간 가용

---

## 📊 현재 상태

### ✅ 완료 (2026-02-25)
- [x] 12개 화면 UI (100%)
- [x] BottomNav 통합 네비게이션
- [x] Combat 비주얼 효과
- [x] DreamCardSelection 뽑기 시스템
- [x] 시간별 탐험 로그
- [x] Cursor/Claude Code 통합

### 🚧 진행 중
- [ ] Combat 게임플레이 로직
- [ ] 데이터 통합 (JSON DB)
- [ ] DeckManager 구현
- [ ] 상점 구매 메커니즘

### 📋 계획
- [ ] 에셋 교체 (이모지 → 스프라이트)
- [ ] 사운드 효과
- [ ] 애니메이션 폴리시
- [ ] 세이브/로드

---

## 🔄 워크플로우

### 1️⃣ 작업 시작
```bash
git pull origin main
```

### 2️⃣ 도구 선택
- **간단한 수정**: Cursor 또는 Claude Code
- **전략적 결정**: Atlas (Telegram)

### 3️⃣ 작업
- PROJECT_CONTEXT.md 읽기 (자동 또는 @-mention)
- 코드 수정
- Godot에서 테스트

### 4️⃣ 문서화
```markdown
## CHANGELOG.md 업데이트
## [Unreleased]

### Changed
- DreamCardSelection: 애니메이션 속도 조정 (line 422)
```

### 5️⃣ 커밋 (로컬)
```bash
git add .
git commit -m "feat: Description"
```

### 6️⃣ 보고
텔레그램 → Atlas:
```
✅ [도구명] 작업 완료
📝 작업: ...
📂 파일: ...
✅ 테스트: 완료
📌 Git: 로컬 커밋 (push 대기)
```

### 7️⃣ 승인 & Push
- Steve 승인 대기
- Atlas가 Git push 실행

---

## 🎨 코딩 스타일

### 명명 규칙
```gdscript
var snake_case_variable: int = 100
const UPPER_SNAKE_CASE = "constant"

func public_method(param: int) -> void:
    pass

func _private_method() -> void:
    pass
```

### 타입 힌트 (필수!)
```gdscript
var hp: int = 100
var name: String = "Hero"

func calculate(base: int, modifier: float) -> int:
    return int(base * modifier)
```

### 시그널
```gdscript
signal entity_updated(type: String, index: int, data: Dictionary)
```

### 주석
```gdscript
# ─── Section Name ─────────────────────────────

func method() -> void:
    """Docstring for public API"""
    pass

# [2026-02-25] Author: Reason for change
```

---

## 🔑 핵심 시스템

### BottomNav Component
- **위치**: `ui/components/BottomNav.tscn/gd`
- **용도**: 통합 네비게이션 (모든 메타 화면)
- **규칙**: 항상 컴포넌트 사용, 인라인 생성 금지

### DreamCardSelection (Gacha)
- **위치**: `ui/screens/DreamCardSelection.tscn/gd`
- **흐름**: 3단계 (START → JOURNEY → END)
- **방식**: 뽑기 (선택 후 공개)

### GameManager
- **위치**: `autoload/GameManager.gd`
- **책임**: 글로벌 상태, 화폐, 꿈 데이터

### UITheme
- **위치**: `autoload/UITheme.gd`
- **용도**: 색상 팔레트, 버튼 스타일

---

## 🧪 테스트

### 작업 완료 전 체크
- [ ] GDScript 에러 없음
- [ ] 씬 정상 로드
- [ ] UI 정상 표시
- [ ] 한글 텍스트 확인
- [ ] 애니메이션/인터랙션 동작

### Godot 실행
```bash
open project.godot
# 또는
godot project.godot
```

---

## 📞 연락처

- **Steve PM**: 총괄 프로젝트 매니저
- **Atlas**: AI 프로젝트 매니저 (텔레그램, 24시간)
- **팀**: Cursor, Claude Code, 향후 조인 예정

---

## 📖 자세한 정보

### 각 도구별 상세 가이드
- **Cursor 사용자**: `CURSOR_GUIDE.md` 읽기
- **Claude Code 사용자**: `CLAUDE_CODE_GUIDE.md` 읽기
- **프로젝트 전체**: `PROJECT_CONTEXT.md` 읽기
- **워크플로우**: `WORKFLOW_INTEGRATION.md` 읽기

### 새 팀원 온보딩
1. `PROJECT_CONTEXT.md` 정독 (30분)
2. 도구 설치 (Cursor 또는 VSCode + Cline)
3. 간단한 작업 시도 (색상 변경)
4. `CHANGELOG.md` 업데이트 연습
5. Atlas와 첫 작업 진행

---

## 🏆 프로젝트 목표

### 단기 (2-4주)
- [ ] 게임플레이 로직 완성
- [ ] 데이터베이스 통합
- [ ] 핵심 메커니즘 테스트

### 중기 (1-2개월)
- [ ] 에셋 교체
- [ ] 사운드/음악 통합
- [ ] 밸런스 조정
- [ ] 베타 테스트

### 장기 (3-6개월)
- [ ] 정식 출시
- [ ] 콘텐츠 업데이트
- [ ] 커뮤니티 빌딩

---

## 📜 라이선스

TBD

---

## 🙏 기여

현재 Steve PM + Atlas 팀으로 진행 중  
향후 팀원 확장 예정

---

**Last Updated**: 2026-02-25 by Atlas  
**Version**: 0.1.0-alpha  
**Status**: Active Development

---

**시작하기**: `README_CURSOR.md` (Cursor) 또는 `CLAUDE_CODE_GUIDE.md` (Claude Code) 읽기!
