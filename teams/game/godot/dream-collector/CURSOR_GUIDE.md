# Cursor IDE 작업 가이드 - Dream Collector

**작성**: Atlas (2026-02-25)  
**대상**: Steve PM + 팀 개발자들

---

## 📋 목차
1. [Cursor 기본 사용법](#1-cursor-기본-사용법)
2. [Dream Collector 프로젝트 작업 흐름](#2-dream-collector-프로젝트-작업-흐름)
3. [작업 후 문서화 (필수!)](#3-작업-후-문서화-필수)
4. [Atlas/팀장에게 보고하기](#4-atlas팀장에게-보고하기)
5. [자주 하는 작업 예시](#5-자주-하는-작업-예시)
6. [문제 해결](#6-문제-해결)

---

## 1. Cursor 기본 사용법

### 1.1 프로젝트 열기
```bash
# 터미널에서
cd ~/Projects/geekbrox/teams/game/godot/dream-collector
cursor .

# 또는 Cursor에서 File → Open Folder
```

### 1.2 주요 기능

| 기능 | 단축키 | 설명 |
|------|--------|------|
| **Composer** | `Cmd+I` | 파일 여러 개 동시 편집 (제일 강력!) |
| **Chat** | `Cmd+L` | 코드 질문/설명 (사이드바) |
| **Inline Edit** | `Cmd+K` | 현재 줄/선택 영역만 수정 |
| **File Search** | `Cmd+P` | 파일 빠르게 찾기 |
| **Symbol Search** | `Cmd+Shift+O` | 함수/변수 찾기 |

### 1.3 `.cursorrules` 파일 (자동 작동)
- 프로젝트 루트에 이미 생성되어 있음
- **아무 설정 없이도 자동으로 작동**
- Cursor AI가 프로젝트 구조, 코딩 스타일, 제약사항 자동 인지
- 수정 필요 시: `.cursorrules` 파일 직접 편집

---

## 2. Dream Collector 프로젝트 작업 흐름

### 2.1 작업 시작 전 체크리스트

- [ ] **최신 코드 받기** (Git pull)
  ```bash
  cd ~/Projects/geekbrox/teams/game/godot/dream-collector
  git pull origin main
  ```

- [ ] **Godot 에디터 닫기** (파일 충돌 방지)
  - .tscn 파일 수정 시 필수!

- [ ] **현재 브랜치 확인** (선택사항)
  ```bash
  git branch
  # main에서 작업 또는 feature 브랜치 생성
  ```

### 2.2 Cursor에서 작업하기

#### 방법 1: Composer (Cmd+I) - 추천!
**언제 쓰나**: 여러 파일 수정, 새 기능 추가, 리팩터링

**예시**:
```
You: "DreamCardSelection에서 카드 애니메이션 속도를 0.2초에서 0.3초로 변경하고,
      GameManager에 total_cards_selected 변수 추가해줘"

Cursor: [자동으로 2개 파일 찾아서 수정]
        DreamCardSelection.gd: line 422 Tween duration 수정
        GameManager.gd: line 48 변수 추가
```

**장점**:
- 여러 파일 동시 수정
- 관련 파일 자동 탐색
- 코드 패턴 자동 인식

#### 방법 2: Chat (Cmd+L)
**언제 쓰나**: 코드 이해, 버그 원인 찾기, 설계 질문

**예시**:
```
You: "InRun_v4.gd의 switch_to_combat() 함수 설명해줘"

Cursor: "이 함수는 탐험 모드에서 전투 모드로 전환합니다:
         1. ExplorationView 숨김
         2. CombatView 표시
         3. CombatUI 활성화
         4. CombatManager 시그널 연결
         5. 몬스터 데이터 로드..."
```

#### 방법 3: Inline Edit (Cmd+K)
**언제 쓰나**: 한 줄/작은 수정

**예시**:
```gdscript
# 이 줄에 커서 놓고 Cmd+K
var speed = 0.2

# 입력: "0.3으로 변경"
var speed = 0.3  # [AI가 자동 수정]
```

### 2.3 작업 확인

#### Godot에서 테스트
```bash
# Godot 에디터 열기
open ~/Projects/geekbrox/teams/game/godot/dream-collector/project.godot

# 또는 터미널에서
godot ~/Projects/geekbrox/teams/game/godot/dream-collector/project.godot
```

**테스트 체크리스트**:
- [ ] 에러 메시지 없음 (Output 패널 확인)
- [ ] 씬 정상 로드
- [ ] UI 요소 제대로 보임
- [ ] 한글 텍스트 정상 표시
- [ ] 애니메이션/인터랙션 정상 작동

---

## 3. 작업 후 문서화 (필수!)

### 3.1 CHANGELOG.md 업데이트

**위치**: 프로젝트 루트 (`~/Projects/geekbrox/teams/game/godot/dream-collector/CHANGELOG.md`)

**포맷**:
```markdown
## 2026-02-25 - Steve (Cursor)

### Added
- GameManager에 total_cards_selected 변수 추가 (라인 48)
- DreamCardSelection에 reset_selection() 함수 추가 (라인 580)

### Changed
- 카드 선택 애니메이션 속도: 0.2s → 0.3s (DreamCardSelection.gd, 라인 422)
- 로그 블록 배경색: 노란색 → 연두색 (DreamCardSelection.gd, 라인 650)

### Fixed
- DreamCardSelection에서 두 번째 클릭 시 버튼 비활성화 안 되던 버그 수정
- GameManager의 dream_nodes null 체크 추가 (크래시 방지)

### Testing
- [x] Godot에서 3단계 카드 선택 테스트 완료
- [x] 애니메이션 속도 확인 완료
- [ ] 실제 게임 플레이 테스트 필요 (전투 연동)
```

**작성 시점**: 작업 완료 직후 (Git commit 전)

### 3.2 코드 주석 추가 (중요한 변경만)

**언제**: 로직 변경, 새 시스템, 버그 수정 시

**포맷**:
```gdscript
# [2026-02-25] Steve: 카드 선택 확정 시 버튼 비활성화 로직 추가
# - 기존: 버튼 활성 상태로 남아서 중복 클릭 가능
# - 수정: 확정 즉시 모든 카드 버튼 비활성화
func _confirm_selection(card: Control, card_data: Dictionary, index: int):
    # Disable all cards
    for c in card_nodes:
        var btn = c.get_child(c.get_child_count() - 1)
        if btn is Button:
            btn.disabled = true  # 추가된 라인
```

**주의**: 간단한 수정은 주석 불필요 (CHANGELOG만으로 충분)

### 3.3 Git Commit (로컬만)

```bash
cd ~/Projects/geekbrox/teams/game/godot/dream-collector

# 변경 사항 확인
git status

# 스테이징
git add .

# 커밋 (한글 OK)
git commit -m "feat: 카드 선택 애니메이션 속도 조정 및 버그 수정

- DreamCardSelection: 애니메이션 0.2s → 0.3s
- GameManager: total_cards_selected 변수 추가
- Fix: 카드 확정 시 버튼 비활성화 버그 수정
"

# 로컬 커밋 완료! (push는 아직 하지 않음)
```

---

## 4. Atlas/팀장에게 보고하기

### 4.1 작업 완료 보고 (텔레그램)

**템플릿**:
```
✅ [Cursor 작업 완료]

📝 작업 내용:
- DreamCardSelection 카드 애니메이션 속도 조정
- GameManager에 total_cards_selected 변수 추가
- 카드 확정 버튼 비활성화 버그 수정

📂 수정된 파일:
- ui/screens/DreamCardSelection.gd (150 lines modified)
- autoload/GameManager.gd (20 lines added)

✅ 테스트 완료:
- Godot에서 3단계 선택 흐름 확인
- 애니메이션 속도 확인 (자연스러움)

⏳ 추가 테스트 필요:
- 실제 게임 플레이 연동 확인

📌 Git 상태:
- 로컬 커밋 완료
- Push 대기 중 (승인 필요 시 알려주세요)

📄 CHANGELOG.md 업데이트 완료
```

### 4.2 Git Push 승인 요청 (필요 시)

**언제**: 작업 완료 후 원격 저장소에 반영하고 싶을 때

**템플릿**:
```
🔄 [Git Push 승인 요청]

커밋 메시지:
"feat: 카드 선택 애니메이션 속도 조정 및 버그 수정"

변경된 파일:
- ui/screens/DreamCardSelection.gd
- autoload/GameManager.gd
- CHANGELOG.md

변경 요약:
- 카드 애니메이션 속도 개선
- GameManager 변수 추가
- 버그 수정

테스트: Godot에서 확인 완료 ✅

Push 해도 될까요?
```

**대기**: Steve의 "OK", "승인", "Proceed" 응답 후 push

### 4.3 Notion 업데이트 요청 (필요 시)

**언제**: GDD나 개발 로그 업데이트 필요 시

**템플릿**:
```
📊 [Notion 업데이트 요청]

대상 페이지:
"GDD: Dream Collector v2.0 (EN)" - Development Log

추가할 내용:
---
### 2026-02-25 - Card Selection UX Improvements

✅ Achievements:
- Improved card animation timing (0.2s → 0.3s)
- Added total_cards_selected tracking in GameManager
- Fixed button disable bug on card confirmation

📝 Technical Details:
- Modified: DreamCardSelection.gd (animation tweens)
- Added: GameManager.total_cards_selected variable
- Fixed: Duplicate click prevention

🎯 Impact:
- Smoother card selection experience
- Better state tracking for analytics
- More stable interaction flow
---

업데이트 해도 될까요?
```

---

## 5. 자주 하는 작업 예시

### 5.1 새 화면 추가

**Cursor Composer (Cmd+I)에 입력**:
```
"새 화면 'AchievementScreen'을 만들어줘.

요구사항:
- ui/screens/AchievementScreen.tscn + .gd 생성
- BottomNav 컴포넌트 포함
- 업적 목록 (VBoxContainer + ScrollContainer)
- UITheme 스타일 적용
- 기존 패턴 따라서 작성 (MainLobby 참고)
"
```

**Cursor가 자동으로**:
1. .tscn + .gd 파일 생성
2. BottomNav 추가
3. 레이아웃 구조 생성
4. 스타일 적용
5. 시그널 연결 보일러플레이트

### 5.2 버그 수정

**Cursor Chat (Cmd+L)에 입력**:
```
You: "DreamCardSelection에서 두 번째 클릭 시 다른 카드도 선택되는 버그가 있어.
      _confirm_selection 함수 확인해줘"

Cursor: "문제 발견했습니다. _confirm_selection에서 버튼 비활성화가
         늦게 실행되고 있습니다. 수정하겠습니다."

[Cursor가 자동 수정]
```

### 5.3 기능 개선

**Cursor Composer (Cmd+I)에 입력**:
```
"DreamCardSelection의 카드 선택 애니메이션을 개선해줘:

1. 선택 시 20px 대신 30px 이동
2. 이동 속도를 0.2초에서 0.25초로
3. EaseOut 대신 EaseInOut 사용
4. 선택 시 약간의 스케일 효과 추가 (1.0 → 1.05)

기존 코드 패턴 유지하면서 수정해줘."
```

### 5.4 코드 리팩터링

**Cursor Composer (Cmd+I)에 입력**:
```
"InRun_v4.gd의 switch_to_* 함수들이 중복 코드가 많아.
공통 로직을 _switch_view(view_name: String) 함수로 추출하고,
각 함수에서 호출하도록 리팩터링해줘.

기능은 그대로 유지하고, 코드만 정리해줘."
```

### 5.5 데이터 구조 설계

**Cursor Chat (Cmd+L)에 입력**:
```
You: "카드 데이터를 JSON으로 관리하고 싶어.
      현재 CARD_DATA Dictionary를 JSON 파일로 옮기는 방법 알려줘"

Cursor: [JSON 구조 제안 + 로드 코드 작성]
```

---

## 6. 문제 해결

### 6.1 Cursor가 잘못된 수정을 했을 때

**방법 1: Undo (Cmd+Z)**
- 수정 내용 즉시 되돌리기

**방법 2: Git Restore**
```bash
# 특정 파일만 되돌리기
git restore ui/screens/DreamCardSelection.gd

# 모든 변경 사항 되돌리기 (주의!)
git restore .
```

**방법 3: Cursor에게 다시 요청**
```
You: "방금 수정이 잘못됐어. 다시 해줘.
      [구체적으로 무엇이 문제인지 설명]"
```

### 6.2 Cursor가 파일을 못 찾을 때

**원인**: `.cursorrules` 미작동 또는 파일 경로 오타

**해결**:
```
You: "파일 경로는 ~/Projects/geekbrox/teams/game/godot/dream-collector/ui/screens/DreamCardSelection.gd
      이 파일을 열어서 _select_card 함수 수정해줘"
```

### 6.3 GDScript 에러 발생 시

**Godot Output 패널에서 에러 확인**:
```
E 0:00:01.234   Invalid call. Nonexistent function 'get_meta' in base 'Nil'.
  <C++ Error>   Method/function failed. Returning: Variant()
  <C++ Source>  core/object/object.cpp:1234 @ call()
  <Stack Trace> DreamCardSelection.gd:422 @ _on_card_clicked()
```

**Cursor Chat에 에러 복사**:
```
You: "이 에러 수정해줘:
     [에러 메시지 전체 복사]"

Cursor: "card 변수가 null입니다. null 체크 추가하겠습니다."
```

### 6.4 .tscn 파일 충돌 시

**증상**: Godot에서 열 때 "Scene is corrupt" 에러

**원인**: Godot 열린 상태에서 .tscn 파일 수정

**해결**:
1. Godot 완전히 종료
2. Git restore로 .tscn 되돌리기
3. Godot 재시작
4. .gd 파일로만 수정 (또는 Godot 닫고 수정)

### 6.5 한글이 깨질 때

**원인**: UTF-8 인코딩 문제

**해결**:
- Cursor는 기본 UTF-8이므로 문제 없음
- 파일 저장 후 Godot에서 확인
- 여전히 깨지면 → Atlas에게 보고

---

## 7. 추가 팁

### 7.1 빠른 작업을 위한 팁

1. **파일 즐겨찾기 (Cmd+P)**: 자주 쓰는 파일 빠르게 열기
   ```
   Cmd+P → "DreamCard" 입력 → Enter
   ```

2. **멀티커서 (Option+Cmd+↓)**: 같은 변수 여러 개 동시 수정
   ```
   speed 변수 여러 개를 동시에 duration으로 변경
   ```

3. **정의로 이동 (Cmd+클릭)**: 함수/변수 정의 위치로 점프

4. **모든 참조 찾기 (Shift+F12)**: 이 함수가 어디서 호출되는지 확인

### 7.2 Cursor 모델 선택

**Settings → Models**:
- **무료 모델** (gpt-4o-mini): 간단한 작업, API 비용 절약
- **Premium 모델** (Claude Sonnet): 복잡한 로직, 리팩터링

**추천**:
- 일반 수정: 무료 모델
- 새 시스템 설계: Premium 모델

### 7.3 작업 효율화

**Before (비효율)**:
```
1. 파일 열기
2. 수정할 곳 찾기
3. 코드 수정
4. 다른 파일 열기
5. 관련 코드 수정
6. 테스트
(반복...)
```

**After (효율적)**:
```
1. Cursor Composer (Cmd+I)
2. "DreamCardSelection과 GameManager에서 X 수정해줘"
3. Cursor가 자동으로 모든 파일 수정
4. 테스트
(완료!)
```

---

## 8. 체크리스트 요약

### 작업 시작 전
- [ ] Git pull (최신 코드)
- [ ] Godot 닫기 (.tscn 수정 시)
- [ ] `.cursorrules` 파일 존재 확인

### 작업 중
- [ ] Cursor Composer/Chat 적극 활용
- [ ] 코드 스타일 가이드 준수 (`.cursorrules` 자동 처리)
- [ ] 중요 변경 시 주석 추가

### 작업 후
- [ ] CHANGELOG.md 업데이트
- [ ] Git commit (로컬)
- [ ] Godot에서 테스트
- [ ] 텔레그램으로 Atlas/Steve에게 보고
- [ ] Git push 승인 대기 (필요 시)

---

## 9. 연락처

- **텔레그램**: Steve PM
- **AI 팀원**: Atlas (프로젝트 매니저, 24시간 대기)
- **개발 도구**: Cursor IDE (AI 코딩 도우미)

**궁금한 점이 있으면 언제든 텔레그램으로 연락주세요!**

---

**마지막 업데이트**: 2026-02-25 by Atlas  
**문서 버전**: 1.0
