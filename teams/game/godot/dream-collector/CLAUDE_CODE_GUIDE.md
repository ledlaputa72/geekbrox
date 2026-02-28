# Claude Code 작업 가이드 - Dream Collector

**작성**: Atlas (2026-02-25)  
**대상**: Steve PM + VSCode 사용자

---

## 📋 목차
1. [Claude Code란?](#1-claude-code란)
2. [설치 & 설정](#2-설치--설정)
3. [프로젝트 컨텍스트 로드](#3-프로젝트-컨텍스트-로드)
4. [작업 흐름](#4-작업-흐름)
5. [문서화 (필수!)](#5-문서화-필수)
6. [보고 방법](#6-보고-방법)
7. [자주 하는 작업](#7-자주-하는-작업)
8. [Cursor vs Claude Code 비교](#8-cursor-vs-claude-code-비교)

---

## 1. Claude Code란?

**Claude Code (Cline Extension)**는 VSCode에서 작동하는 AI 코딩 어시스턴트입니다.

### 특징
- ✅ VSCode에서 직접 작동
- ✅ 프리티어 무료 (월 API 한도)
- ✅ @-mention으로 파일/폴더 참조
- ✅ 대화형 인터페이스
- ✅ Git 통합

### Cursor와 비교
| 기능 | Cursor | Claude Code |
|------|--------|-------------|
| **IDE** | Cursor (VSCode fork) | VSCode |
| **설치** | 독립 앱 | Extension |
| **컨텍스트** | .cursorrules | @PROJECT_CONTEXT.md |
| **무료 사용** | 로컬 모델 | 프리티어 API |
| **강점** | Composer (멀티파일) | Git 통합 |

---

## 2. 설치 & 설정

### 2.1 VSCode 설치 (이미 있으면 skip)
```bash
# macOS
brew install --cask visual-studio-code
```

### 2.2 Cline Extension 설치
1. VSCode 열기
2. Extensions (Cmd+Shift+X)
3. "Cline" 검색
4. Install 클릭

### 2.3 API 키 설정
1. Cline 아이콘 클릭 (사이드바)
2. Settings → API Provider → Anthropic
3. API Key 입력 (Steve의 Anthropic API 키)
4. Model 선택: `claude-3-5-sonnet-20241022` (추천)

### 2.4 프로젝트 열기
```bash
cd ~/Projects/geekbrox/teams/game/godot/dream-collector
code .
```

---

## 3. 프로젝트 컨텍스트 로드

### 3.1 자동 로드 (.clinerules)
프로젝트에 `.clinerules` 파일이 있으면 자동 로드됩니다.

### 3.2 수동 로드 (첫 대화 시)

**Cline 채팅창에 입력**:
```
@PROJECT_CONTEXT.md 를 읽고, Dream Collector 프로젝트에 대해 이해해줘.
```

**Claude Code가 자동으로**:
- PROJECT_CONTEXT.md 읽기
- 프로젝트 구조 이해
- 코딩 스타일 학습
- 주요 시스템 파악

### 3.3 특정 파일 참조

**여러 파일 동시 참조**:
```
@ui/screens/DreamCardSelection.gd
@autoload/GameManager.gd
이 두 파일을 분석하고, 카드 선택 후 GameManager 연동 로직 설명해줘
```

---

## 4. 작업 흐름

### 4.1 작업 시작 전 체크리스트

- [ ] **최신 코드 받기** (Git pull)
  ```bash
  cd ~/Projects/geekbrox/teams/game/godot/dream-collector
  git pull origin main
  ```

- [ ] **VSCode 열기**
  ```bash
  code .
  ```

- [ ] **Godot 닫기** (.tscn 수정 시 필수!)

### 4.2 Claude Code로 작업하기

#### 방법 1: 직접 질문 (추천!)
**Cline 패널에서**:
```
@PROJECT_CONTEXT.md

Task: DreamCardSelection.gd에서 카드 애니메이션 속도를 0.3초로 변경해줘

Requirements:
- _select_card 함수의 Tween duration 수정
- 기존 코드 패턴 유지
- 주석 추가
```

**Claude Code가 자동으로**:
- 파일 찾기
- 코드 수정
- 변경 사항 적용
- 설명 제공

#### 방법 2: 파일 직접 열고 작업
1. Explorer에서 파일 열기 (DreamCardSelection.gd)
2. 수정할 부분 선택
3. Cline에서: "선택된 부분의 애니메이션 속도를 0.3초로 변경"

#### 방법 3: 새 파일 생성
```
@PROJECT_CONTEXT.md
@ui/screens/MainLobby.gd (참고용)

Task: 새 화면 'AchievementScreen' 만들어줘

Requirements:
- ui/screens/AchievementScreen.tscn + .gd 생성
- MainLobby 패턴 참고
- BottomNav 컴포넌트 포함
- UITheme 스타일 적용
```

### 4.3 작업 확인

#### Godot에서 테스트
```bash
# Godot 에디터 열기
open project.godot
```

**테스트 체크리스트**:
- [ ] 에러 없음 (Output 패널)
- [ ] 씬 정상 로드
- [ ] UI 정상 표시
- [ ] 한글 텍스트 확인
- [ ] 인터랙션 동작

---

## 5. 문서화 (필수!)

### 5.1 CHANGELOG.md 업데이트

**작업 완료 후 즉시**:

```markdown
## [Unreleased]

### Changed
- DreamCardSelection: 애니메이션 속도 0.2s → 0.3s (line 422)
  - Tween duration 수정
  - 더 부드러운 사용자 경험

### Added
- GameManager: total_cards_selected 변수 추가 (line 48)
  - 통계 추적용

### Fixed
- DreamCardSelection: 카드 확정 버튼 비활성화 버그 수정
  - 중복 클릭 방지 로직 추가
```

**위치**: `~/Projects/geekbrox/teams/game/godot/dream-collector/CHANGELOG.md`

### 5.2 코드 주석 (중요 변경만)

```gdscript
# [2026-02-25] Claude Code: 애니메이션 속도 조정
# - 사용자 피드백: 너무 빠름
# - 0.2s → 0.3s로 증가
func _select_card(card: Control, index: int):
    var tween = create_tween()
    tween.tween_property(card, "position:y", original_y + 20, 0.3)  # 0.2 → 0.3
```

### 5.3 Git Commit (로컬)

```bash
cd ~/Projects/geekbrox/teams/game/godot/dream-collector

# 상태 확인
git status

# 스테이징
git add .

# 커밋
git commit -m "feat: DreamCardSelection 애니메이션 속도 조정

- 카드 선택 애니메이션: 0.2s → 0.3s
- GameManager에 total_cards_selected 추가
- 버튼 비활성화 버그 수정
"

# 로컬 커밋 완료! (push는 승인 후)
```

---

## 6. 보고 방법

### 6.1 작업 완료 보고 (텔레그램 → Atlas)

**템플릿**:
```
✅ [Claude Code 작업 완료]

📝 작업 내용:
- DreamCardSelection 애니메이션 속도 개선
- GameManager 통계 변수 추가
- 버튼 중복 클릭 버그 수정

📂 수정 파일:
- ui/screens/DreamCardSelection.gd (150 lines)
- autoload/GameManager.gd (20 lines)

✅ 테스트 완료:
- Godot에서 3단계 선택 흐름 확인
- 애니메이션 타이밍 확인 (자연스러움)

⏳ 추가 테스트:
- 실제 게임플레이 연동 확인 필요

📌 Git:
- 로컬 커밋 완료
- Push 대기 (승인 필요 시 말씀해주세요)

📄 CHANGELOG.md 업데이트 완료
```

### 6.2 Git Push 승인 요청

```
🔄 [Git Push 승인 요청]

커밋 메시지:
"feat: DreamCardSelection 애니메이션 속도 조정"

변경 파일:
- ui/screens/DreamCardSelection.gd
- autoload/GameManager.gd
- CHANGELOG.md

변경 요약:
- 애니메이션 속도 개선 (0.2s → 0.3s)
- 통계 추적 변수 추가
- 버그 수정

테스트: Godot 확인 완료 ✅

Push 해도 될까요?
```

### 6.3 Notion 업데이트 요청

```
📊 [Notion 업데이트 요청]

대상 페이지: "GDD: Dream Collector v2.0 (EN)"

내용:
---
### 2026-02-25 - UX Improvements

✅ Card Selection Animation:
- Increased timing from 0.2s to 0.3s
- Smoother user experience
- Better visual feedback

📝 Technical:
- Modified: DreamCardSelection.gd
- Added: GameManager.total_cards_selected
- Fixed: Duplicate click prevention
---

업데이트 해도 될까요?
```

---

## 7. 자주 하는 작업

### 7.1 코드 수정

**Cline에서**:
```
@ui/screens/DreamCardSelection.gd

Task: _select_card 함수의 이동 거리를 20px에서 30px로 변경

Requirements:
- 라인 422 부근
- position:y 값만 수정
- 주석 추가
```

### 7.2 버그 수정

```
@ui/screens/DreamCardSelection.gd

Issue: 카드 확정 시 다른 카드도 클릭 가능한 버그

Debug:
- _confirm_selection 함수 확인
- 버튼 비활성화 로직 검증
- 수정 후 테스트 코드 제안
```

### 7.3 새 기능 추가

```
@PROJECT_CONTEXT.md
@ui/components/BottomNav.gd (참고)

Task: 새 컴포넌트 'TopBar' 만들어줘

Requirements:
- ui/components/TopBar.tscn + .gd
- BottomNav 패턴 참고
- 왼쪽: 뒤로가기 버튼
- 중앙: 타이틀 라벨
- 오른쪽: 설정 버튼
- UITheme 스타일 적용
```

### 7.4 리팩터링

```
@ui/screens/InRun_v4.gd

Task: switch_to_* 함수들 리팩터링

Analysis:
- 중복 코드 확인
- 공통 로직 추출 제안
- _switch_view() 헬퍼 함수 생성

Requirements:
- 기능 유지
- 코드 가독성 개선
- 주석 추가
```

### 7.5 코드 분석

```
@autoload/CombatManager.gd

Question: 이 파일의 전투 시스템 아키텍처 설명해줘

Points:
- 주요 함수들
- 시그널 흐름
- 데이터 구조
- InRun_v4.gd와 연동 방식
```

---

## 8. Cursor vs Claude Code 비교

### 언제 Cursor를 쓸까?

**Cursor 추천**:
- 여러 파일 동시 수정 (Composer 강력!)
- 대규모 리팩터링
- 프로젝트 전체 검색
- 로컬 모델로 무제한 사용

**예시**:
```
"DreamCardSelection과 GameManager와 InRun_v4에서
 카드 선택 로직을 전부 리팩터링해줘"
→ Cursor가 3개 파일 동시 수정
```

### 언제 Claude Code를 쓸까?

**Claude Code 추천**:
- VSCode를 이미 사용 중
- Git 작업과 통합 (commit, branch)
- 단일 파일 집중 작업
- 대화형 디버깅

**예시**:
```
"이 함수에서 에러가 나는데, 왜 그럴까?
 한 단계씩 설명해줘"
→ Claude Code가 대화형으로 디버깅
```

### 비교표

| 기능 | Cursor | Claude Code |
|------|--------|-------------|
| **멀티파일 수정** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| **대화형 디버깅** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Git 통합** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **무료 사용** | ⭐⭐⭐⭐⭐ (로컬) | ⭐⭐⭐⭐ (API 한도) |
| **속도** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **학습 곡선** | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ (쉬움) |

---

## 9. 팁 & 트릭

### 9.1 컨텍스트 관리

**효율적인 @-mention**:
```
# 기본 컨텍스트 로드
@PROJECT_CONTEXT.md

# 작업할 파일 + 참고 파일
@ui/screens/DreamCardSelection.gd
@ui/components/BottomNav.gd (참고용)

# 폴더 전체
@ui/components/

Task: ...
```

### 9.2 단계별 작업

```
@PROJECT_CONTEXT.md

Task: DreamCardSelection에 새 기능 추가

Step 1: 먼저 현재 코드 구조 분석해줘
(Claude Code 응답 확인)

Step 2: 추가할 기능 설계 제안해줘
(설계 검토)

Step 3: 코드 구현해줘
(구현)

Step 4: 테스트 코드 제안해줘
(테스트)
```

### 9.3 에러 디버깅

```
@ui/screens/DreamCardSelection.gd

Error:
[Godot 에러 메시지 전체 복사]

Context:
- 방금 _select_card 함수 수정함
- 카드 클릭 시 크래시

Debug:
- 원인 분석
- 수정 방법 제안
- 유사 버그 예방법
```

### 9.4 멀티태스킹

**여러 대화 세션**:
- Session 1: 버그 수정
- Session 2: 새 기능 추가
- Session 3: 코드 리뷰

각 세션마다 `@PROJECT_CONTEXT.md` 로드!

---

## 10. 문제 해결

### 10.1 Claude Code가 파일을 못 찾을 때

**해결**:
```
@PROJECT_CONTEXT.md

파일 경로는 정확히:
~/Projects/geekbrox/teams/game/godot/dream-collector/ui/screens/DreamCardSelection.gd

또는 상대 경로:
ui/screens/DreamCardSelection.gd

이 파일을 열어서 _select_card 함수 수정해줘
```

### 10.2 API 한도 초과 시

**증상**: "Rate limit exceeded" 에러

**해결**:
1. **대기**: 1분 후 재시도
2. **Cursor 사용**: 로컬 모델 (무제한)
3. **내일 재시도**: 일일 한도 리셋

### 10.3 컨텍스트 손실

**증상**: Claude Code가 프로젝트 구조를 모름

**해결**:
```
@PROJECT_CONTEXT.md

다시 한 번 프로젝트 컨텍스트를 로드하고,
이전에 하던 작업 계속해줘:
[작업 내용 요약]
```

### 10.4 .tscn 파일 충돌

**증상**: Godot에서 "Scene corrupt" 에러

**해결**:
1. Godot 완전 종료
2. Git restore로 .tscn 복원
3. Godot 재시작
4. .gd 파일로만 수정 시도

---

## 11. 체크리스트

### 작업 시작 전
- [ ] Git pull (최신 코드)
- [ ] VSCode + Cline 준비
- [ ] Godot 닫기 (.tscn 수정 시)
- [ ] @PROJECT_CONTEXT.md 로드

### 작업 중
- [ ] @-mention으로 파일 참조
- [ ] 단계별 진행 (분석 → 설계 → 구현)
- [ ] 중요 변경 시 주석 추가

### 작업 후
- [ ] CHANGELOG.md 업데이트
- [ ] Git commit (로컬)
- [ ] Godot 테스트
- [ ] 텔레그램 보고 (Atlas/Steve)
- [ ] Git push 승인 대기 (필요 시)

---

## 12. 추가 리소스

### 공식 문서
- Cline Extension: [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=saoudrizwan.claude-dev)
- Anthropic API: [docs.anthropic.com](https://docs.anthropic.com)

### 프로젝트 문서
- `PROJECT_CONTEXT.md`: 공통 컨텍스트
- `CHANGELOG.md`: 변경 이력
- `CURSOR_GUIDE.md`: Cursor 가이드
- `.cursorrules`: Cursor 컨텍스트
- `.clinerules`: Claude Code 컨텍스트

### 연락처
- **텔레그램**: Steve PM
- **AI 팀**: Atlas (24시간)

---

## 13. 마무리

### Claude Code 활용 전략

**Best Practices**:
1. **항상 @PROJECT_CONTEXT.md 로드**
2. **CHANGELOG.md 작성 습관화**
3. **작은 단위로 커밋** (쉬운 롤백)
4. **테스트 필수** (Godot 확인)
5. **Atlas에게 보고** (팀 동기화)

### 성공 지표

**효율적인 작업**:
- ✅ 30분 내 버그 수정
- ✅ 1시간 내 새 기능 추가
- ✅ CHANGELOG 자동 업데이트 습관
- ✅ Git history 깔끔 유지
- ✅ Atlas와 원활한 소통

---

**Happy Coding with Claude Code! 🎮✨**

---

**마지막 업데이트**: 2026-02-25 by Atlas  
**문서 버전**: 1.0
