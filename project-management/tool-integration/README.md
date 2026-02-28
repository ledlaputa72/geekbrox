# 🛠️ Tool Integration Guide for GeekBrox

> 모든 개발 도구가 일관성 있게 작동하기 위한 통합 가이드

---

## 📚 문서 구조

```
project-management/tool-integration/
├── README.md                      ← 당신이 읽는 문서
├── CURSOR_IDE_RULES.txt           ← Cursor IDE 붙여넣기용
├── CLAUDE_CODE_RULES.txt          ← Claude Code 붙여넣기용
├── CLAUDE_CHAT_RULES.txt          ← Claude Chat 붙여넣기용
├── CLAUDE_CORE_RULES.txt          ← Claude Core 붙여넣기용
└── TOOL_INTEGRATION_SUMMARY.md    ← 전체 워크플로우 요약
```

---

## 🎯 각 도구의 역할

### 🔨 Cursor IDE (게임 코드)
**역할:** GDScript 게임 코드 작성
**사용자:** 게임팀 개발자
**경로:** ~/Projects/geekbrox/teams/game/godot/dream-collector/
**산출물:** .gd 파일, .tscn 파일

**작업 흐름:**
```
Telegram 지시 → Cursor 코드 작성 → 테스트 → Git Commit → PR 생성 → Telegram 완료 보고
```

**적용 방법:**
```
1. CURSOR_IDE_RULES.txt 열기
2. 전체 내용 복사
3. Cursor의 .cursor/rules 파일에 붙여넣기 (또는 규칙 폴더)
4. Cursor 재시작
```

---

### 🤖 Claude Code (자동화 스크립트)
**역할:** Python, Bash 자동화 스크립트 작성
**사용자:** 모든 팀 (개발, 빌드, 테스트, 블로그 자동화)
**경로:** ~/Projects/geekbrox/frameworks/ 및 ~/Projects/geekbrox/teams/game/
**산출물:** .py 파일, .sh 파일, 데이터 파일

**작업 흐름:**
```
Telegram 지시 → Claude Code 스크립트 작성 → 로컬 테스트 → Git Commit → PR 생성 → Telegram 보고
```

**적용 방법:**
```
1. CLAUDE_CODE_RULES.txt 열기
2. 전체 내용 복사
3. Claude Code 시스템 메시지에 붙여넣기
4. 또는 각 요청 전에 프롬프트 앞에 붙여넣기
```

---

### 💬 Claude Chat (디자인 & 피드백)
**역할:** 게임 설계 검토, 아이디어 피드백, 기술 상담
**사용자:** Team Leads, 디자이너, 개발자
**입력:** 설계 문서, 코드 로직, 시스템 아이디어
**산출물:** 조언, 피드백, 구현 방향

**작업 흐름:**
```
Chat 질문 → Claude 피드백 → 아이디어 정리 → Cursor/Code로 구현 → Telegram 보고
```

**적용 방법:**
```
1. CLAUDE_CHAT_RULES.txt 읽기
2. 각 대화 시작 시 프롬프트 앞에 핵심 내용 붙여넣기:
   "GeekBrox Project: Dream Collector RPG
    Team: Kim.G (Game), Lee.C (Content), Park.O (Ops)
    Current Phase: 3 (Combat System)
    [Your question]"
```

---

### 🧠 Claude Core (깊이 있는 분석)
**역할:** 복잡한 의사결정, 전략 분석, 시스템 설계
**사용자:** Steve (PM), Team Leads
**입력:** 여러 옵션, 제약사항, 분석 기준
**산출물:** 깊이 있는 분석, 추천, 의사결정 프레임워크

**작업 흐름:**
```
복잡한 의사결정 필요 → Core 깊이 있는 분석 → 권장사항 → 팀 논의 → 최종 결정 → 구현
```

**적용 방법:**
```
1. CLAUDE_CORE_RULES.txt 읽기
2. 분석 필요 시 프롬프트:
   [배경정보]
   
   옵션:
   A. [옵션 1]
   B. [옵션 2]
   C. [옵션 3]
   
   [제약사항]
   
   각 옵션 분석:
   - 복잡도
   - 효과
   - 위험도
   - 추천
```

---

## 🔄 도구 간 워크플로우

### 완전한 작업 사이클

```
1️⃣ 의사결정 (Claude Core)
   ↓
   복잡한 결정이 필요?
   → Claude Core로 깊이 있는 분석
   → 팀 논의 후 최종 결정
   ↓
2️⃣ 설계 & 피드백 (Claude Chat)
   ↓
   세부 설계 필요?
   → Claude Chat로 아이디어 검증
   → 피드백 반영
   ↓
3️⃣ 구현 시작 (Telegram)
   ↓
   Team Lead가 Telegram으로 개발자에게 지시
   ↓
4️⃣ 코드 작성 (Cursor IDE)
   ↓
   게임 로직 구현 → 테스트 → Commit → PR
   ↓
5️⃣ 자동화 작업 (Claude Code)
   ↓
   빌드/테스트/데이터 생성 스크립트
   ↓
6️⃣ 버전 관리 (GitHub)
   ↓
   모든 변경사항 Commit & PR
   ↓
7️⃣ 완료 보고 (Telegram)
   ↓
   "✅ 작업 완료: [PR 링크]"
```

### 예: ATB 시스템 구현 (전체 사이클)

```
Week 1: 의사결정
--------
Steve: "ATB vs Turn-Based 결정 필요. Core에서 분석해줄래?"
Claude Core: [깊이 있는 분석] → "ATB 권장" (이유: 플레이어 engagement)
Team: 논의 후 ATB 선택 → 결정됨

Week 2: 설계
--------
Kim.G: "ATB 구체 설계 검토 부탁"
Claude Chat: 
  "ATB gauge 5/sec, card cost 1-10, enemy AI 로직"
  → 피드백: "너무 빠름, 3/sec로 줄이고 cost 1-5로 조정하세요"

Week 3-4: 개발
--------
Kim.G (Telegram): 
  "Cursor IDE: CombatManager.gd 작성
   - TAROT_SYSTEM_GUIDE.md 참고
   - ATB gauge 구현 (3/sec)
   - 완료 후 PR 생성"

Developer (Cursor):
  코드 작성 → 테스트 → Commit:
  "feat(game): Implement ATB gauge system
   - Gauge increases 3/sec
   - Card cost range 1-5
   - Tests in Godot pass ✅"
  → GitHub PR #45 생성
  → Telegram: "✅ ATB gauge: PR #45"

Kim.G (Code Review):
  PR 검토 → 병합

Week 4: 빌드 & 테스트
--------
Claude Code:
  빌드 성능 테스트 스크립트 작성
  → build-perf-test.sh 생성 → PR #46 → 병합

Week 5: 최종 테스트
--------
Park.O (Ops):
  QA 테스트 실행
  → bug report → 수정
  → "✅ ATB 시스템 테스트 통과"

완료!
```

---

## 📋 도구별 적용 가이드

### Step 1: Cursor IDE 설정

```bash
# 1. Cursor 열기
open -a "Cursor"

# 2. 규칙 파일 생성/수정
~/.cursor/rules/geekbrox.txt  (또는 .cursor/system_prompt)

# 3. CURSOR_IDE_RULES.txt 전체 내용 복사 & 붙여넣기

# 4. Cursor 재시작

# 5. 프로젝트 열기
File → Open → ~/Projects/geekbrox/teams/game/godot/dream-collector/

# 준비 완료! Telegram에서 지시 기다리기
```

### Step 2: Claude Code 설정

```
각 요청 시:

프롬프트 앞에 붙여넣기:
---
[CLAUDE_CODE_RULES.txt 내용]

Now, please write:
[당신의 스크립트 요청]
---

또는 시스템 메시지에 추가 가능
```

### Step 3: Claude Chat 준비

```
각 대화 시작:

"GeekBrox Context:
- Project: Dream Collector RPG
- Team: Kim.G (Game), Lee.C (Content), Park.O (Ops)
- Phase: 3 (Combat, Cards)
- Constraints: 1 dev/team, $200/month

[Your question based on CLAUDE_CHAT_RULES.txt]"
```

### Step 4: Claude Core 준비

```
복잡한 의사결정 필요 시:

Use system prompt with thinking enabled:
[CLAUDE_CORE_RULES.txt + your specific analysis request]
```

### Step 5: GitHub & Telegram 준비

```
Git Workflow:
- All commits follow convention in CLAUDE_CODE_RULES.txt
- All PRs use template in TOOL_GUIDELINES.md
- All reports use format in CLAUDE_CHAT_RULES.txt
- All decisions documented

Telegram:
- Team Lead sends: [TOOL] [TASK]: [SPEC]
- Developer reports: [STATUS] [TASK]: [RESULT]
```

---

## ✅ 일관성 체크리스트

### 모든 도구 공통

```
Communication:
☐ Telegram 메시지 포맷 준수
☐ 상태 아이콘 일관 (✅ 🔄 🛑)
☐ 명확한 메시지 (애매함 없음)

Code/Scripts:
☐ 변수명 일관성 (snake_case)
☐ 주석 충분
☐ 오류 처리 있음
☐ 경로 절대 경로 또는 expanduser

Git:
☐ Commit 메시지 포맷 준수
☐ PR description 포맷 준수
☐ 모든 변경 커밋됨
☐ PR이 명확함

Workflow:
☐ Telegram → 도구 → GitHub → Telegram
☐ 지시받기 → 실행 → 완료 보고
☐ 팀 리더 승인 후 병합
```

---

## 🚀 빠른 시작 (모든 도구)

### 게임팀 개발자
```
1. CURSOR_IDE_RULES.txt 적용
2. teams/game/godot/dream-collector/ 프로젝트 열기
3. Telegram 지시 대기
4. "CardDatabase.gd 작성" 지시 받음
   → Cursor에서 코드 작성
   → Git commit: "feat(game): Add CardDatabase.gd"
   → GitHub PR 생성
   → Telegram 보고: "✅ CardDatabase.gd: PR #123"
```

### 콘텐츠팀 리더 (Lee.C)
```
1. CLAUDE_CODE_RULES.txt 이해
2. 블로그 자동화 스크립트 요청 시
   → Claude Code로 스크립트 작성
   → 로컬 테스트
   → PR 생성
3. CLAUDE_CHAT_RULES.txt로 콘텐츠 피드백 받기
4. 팀원 지시 (Telegram)
5. 완료 보고
```

### 게임팀 리더 (Kim.G)
```
1. 복잡한 설계 결정 필요?
   → CLAUDE_CORE_RULES.txt로 깊이 있는 분석
2. 세부 설계 검토?
   → CLAUDE_CHAT_RULES.txt로 피드백
3. 팀원 지시?
   → Telegram 메시지 포맷
4. 코드 리뷰?
   → CURSOR_IDE_RULES.txt의 코드 스타일 확인
5. 진행 상황 보고?
   → TOOL_INTEGRATION_SUMMARY.md 참고
```

### PM (Steve)
```
1. 주요 의사결정 필요?
   → CLAUDE_CORE_RULES.txt로 깊이 있는 분석 요청
2. 팀 워크플로우 확인?
   → WORKFLOW_INTEGRATION.md + 이 가이드
3. 진행 상황 추적?
   → Telegram 보고 확인 (모든 팀)
   → GitHub PR 열기
4. 예산/리소스 최적화?
   → Core 분석 요청
```

---

## 📚 전체 문서 위계

```
~/Projects/geekbrox/
│
├── 📖 시작 (새 팀원)
│   ├── GETTING_STARTED.md
│   ├── QUICK_START.md
│   └── WORKFLOW_INTEGRATION.md
│
├── 🛠️ 도구 가이드 (이 폴더)
│   ├── TOOL_GUIDELINES.md (상세)
│   ├── TOOL_CHEATSHEETS.md (빠른 참조)
│   └── project-management/tool-integration/
│       ├── README.md (당신이 읽는 문서)
│       ├── CURSOR_IDE_RULES.txt
│       ├── CLAUDE_CODE_RULES.txt
│       ├── CLAUDE_CHAT_RULES.txt
│       └── CLAUDE_CORE_RULES.txt
│
├── 📋 운영 (팀 리더)
│   └── project-management/OPERATION_MANUAL.md
│
└── 👥 팀 자료 (각 팀)
    ├── teams/game/
    │   ├── TEAM_STARTUP.md
    │   └── workspace/guides/CODE_REVIEW.md
    ├── teams/content/
    │   ├── TEAM_STARTUP.md
    │   └── workspace/guides/BLOG_POSTING_UPDATE.md
    └── teams/ops/
        └── TEAM_STARTUP.md
```

---

## 🎯 핵심 원칙

### 1️⃣ 일관성
모든 도구가 같은 포맷, 메시지, 워크플로우 사용

### 2️⃣ 명확성
누가 뭘 하는지 항상 명확함 (역할 정의됨)

### 3️⃣ 추적 가능성
모든 결정, 작업, 변경이 기록됨 (GitHub)

### 4️⃣ 효율성
도구가 서로를 보완 (중복 없음)

### 5️⃣ 성장성
팀이 커져도 구조는 유지됨

---

## 💡 사용 예시

### "ATB 시스템 구현하기"

```
Day 1: 결정
-------
Steve: Core에 "ATB vs Turn-Based" 분석 요청
Claude Core: [깊이 있는 분석] → "ATB 권장"

Day 2: 설계
-------
Kim.G: Chat에서 ATB 설계 검증
Claude Chat: [설계 피드백]

Day 3-5: 개발
-------
Kim.G (Telegram): "Cursor IDE로 CombatManager.gd 작성"
Developer: Code 작성 → Commit → PR
Kim.G: PR 검토 → 병합

Day 6: 스크립트
-------
Claude Code: 빌드 테스트 스크립트 작성
$ bash test.sh → 성공

Day 7: 완료
-------
Kim.G (Telegram): "✅ ATB 시스템 완료"
```

---

## 🆘 도움말

### "어느 도구를 써야 하나요?"

```
빠른 피드백 필요?
→ Claude Chat

깊이 있는 분석 필요?
→ Claude Core

코드 작성 필요?
→ Cursor IDE (GDScript) 또는 Claude Code (Python/Bash)

자동화 스크립트?
→ Claude Code

일반 조언?
→ Claude Chat
```

### "도구별 설정이 복잡하다"

```
각 도구의 .txt 파일이 모두 준비되어 있습니다.

간단히:
1. 적절한 .txt 파일 열기
2. 전체 복사
3. 도구에 붙여넣기
4. 완료!
```

### "메시지 포맷을 잊었어요"

```
TOOL_CHEATSHEETS.md의 "Telegram 메시지 포맷" 섹션 참고
또는
TOOL_GUIDELINES.md의 "Integration Standards" 참고
```

---

## 📞 최종 체크리스트

모든 도구가 준비되었나요?

```
☐ Cursor IDE rules 적용됨
☐ Claude Code 가이드 읽음
☐ Claude Chat 프롬프트 준비됨
☐ Claude Core 분석 요청 방법 이해됨
☐ Telegram 메시지 포맷 이해됨
☐ Git 커밋 포맷 이해됨
☐ GitHub PR 템플릿 준비됨
☐ 전체 워크플로우 이해됨
```

모두 체크? **축하합니다!** 이제 모든 도구가 일관성 있게 작동할 준비가 되었습니다! 🎉

---

**Last Updated:** 2026-02-28  
**Version:** 1.0  
**Status:** ✅ Complete Tool Integration Ready
