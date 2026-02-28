# 🚀 Getting Started with GeekBrox

> 모든 새 팀원과 팀 리더를 위한 완벽한 온보딩 & 도구 통합 가이드

---

## 📁 폴더 구조

```
project-management/getting-started/
│
├── README.md (이 파일)
│
├── 🎯 핵심 가이드 (순서대로 읽기)
│   ├── GETTING_STARTED.md         ⭐ 시작점 (2분)
│   ├── QUICK_START.md              (5분 - 프로젝트 이해)
│   └── WORKFLOW_INTEGRATION.md      (15분 - 일하는 방식, 가장 중요!)
│
├── onboarding/                      📚 팀별 30분 가이드
│   ├── GAME_TEAM_STARTUP.md         (게임팀)
│   ├── CONTENT_TEAM_STARTUP.md      (콘텐츠팀)
│   └── OPS_TEAM_STARTUP.md          (운영팀)
│
└── tools/                           🛠️ 도구 통합 가이드
    ├── TOOL_GUIDELINES.md           (상세 가이드)
    ├── TOOL_CHEATSHEETS.md          (빠른 참조)
    └── tool-integration/            (copy-paste 파일들)
        ├── README.md
        ├── CURSOR_IDE_RULES.txt
        ├── CLAUDE_CODE_RULES.txt
        ├── CLAUDE_CHAT_RULES.txt
        └── CLAUDE_CORE_RULES.txt
```

---

## 🎯 빠른 시작 (50분)

### 새 팀원용

```
1️⃣ GETTING_STARTED.md 읽기 (2분)
   ↓ 당신의 역할 선택 (Game/Content/Ops/PM)
   ↓
2️⃣ QUICK_START.md 읽기 (5분)
   ↓ 프로젝트 이해
   ↓
3️⃣ WORKFLOW_INTEGRATION.md 읽기 (15분)
   ↓ ⭐⭐⭐ 가장 중요! Telegram-Cursor-GitHub 워크플로우
   ↓
4️⃣ onboarding/[YOUR_TEAM]_STARTUP.md 읽기 (30분)
   ↓ 역할별 준비 완료!
   ↓
✅ Team Lead 첫 지시 대기
```

**총 50분 → 완벽하게 준비!**

---

### Team Lead용

```
1️⃣ WORKFLOW_INTEGRATION.md 읽기 (15분)
   ↓ 메시지 포맷, PR 절차 이해
   ↓
2️⃣ onboarding/[YOUR_TEAM]_STARTUP.md 읽기 (15분)
   ↓ 팀 운영 방법 이해
   ↓
3️⃣ tools/ 폴더 둘러보기 (15분)
   ↓ 도구별 규칙 파일 확인
   ↓
✅ 팀원들 지시 시작
```

---

### PM (Steve)용

```
1️⃣ QUICK_START.md 읽기 (5분)
   ↓ 팀 구조 이해
   ↓
2️⃣ WORKFLOW_INTEGRATION.md 읽기 (15분)
   ↓ 워크플로우 이해
   ↓
3️⃣ tools/tool-integration/README.md 읽기 (10분)
   ↓ 도구 통합 이해
   ↓
✅ 전체 운영 체계 준비
```

---

## 📖 문서별 설명

### 핵심 가이드

**GETTING_STARTED.md**
- 새 팀원의 진입점
- 시각적 50분 로드맵
- 역할별 경로 선택
- 자주 묻는 질문

**QUICK_START.md**
- 5분 안에 프로젝트 이해
- 팀 구조 설명
- 채널별 커뮤니케이션
- 오늘 할 일 체크리스트

**WORKFLOW_INTEGRATION.md** ⭐⭐⭐ **가장 중요!**
- Telegram-Cursor-GitHub 통합 워크플로우
- 4단계 작업 프로세스
- 메시지 포맷 표준화
- PR/Commit 포맷 표준화
- 예상 타이밍
- 문제 해결

---

### 팀별 스타트업 (onboarding/)

**GAME_TEAM_STARTUP.md**
- 게임팀 30분 온보딩
- Cursor IDE 설정
- 코드 스타일 (CODE_REVIEW.md)
- 첫 작업 체크리스트
- 게임팀 워크플로우

**CONTENT_TEAM_STARTUP.md**
- 콘텐츠팀 30분 온보딩
- 블로그 자동화 봇 사용법
- 4단계 글 작성 프로세스
- 텔레그램 봇 워크플로우
- TONE_GUIDE 참고

**OPS_TEAM_STARTUP.md**
- 운영팀 30분 온보딩
- QA/테스트/연구 역할별 가이드
- QA_LOG 기록 방법
- 버그 분류
- 테스트 리포트 작성

---

### 도구 통합 가이드 (tools/)

**TOOL_GUIDELINES.md**
- 모든 도구의 상세 가이드
- Cursor IDE 완전 가이드
- Claude Code 완전 가이드
- Claude Chat 완전 가이드
- Claude Core 완전 가이드
- 통합 표준

**TOOL_CHEATSHEETS.md**
- 빠른 참조용 (copy-paste 가능)
- 각 도구별 템플릿
- 코드 예제
- Commit 메시지 예제
- 체크리스트

**tool-integration/ 폴더**
- README.md: 도구 통합 개요
- CURSOR_IDE_RULES.txt: Cursor용 규칙 (copy-paste)
- CLAUDE_CODE_RULES.txt: Code용 규칙 (copy-paste)
- CLAUDE_CHAT_RULES.txt: Chat용 규칙 (copy-paste)
- CLAUDE_CORE_RULES.txt: Core용 규칙 (copy-paste)

---

## 🔄 워크플로우 (모든 팀)

```
Telegram (지시)
    ↓
도구 선택
├─→ Cursor IDE (게임 코드)
├─→ Claude Code (자동화 스크립트)
├─→ Claude Chat (설계 & 피드백)
└─→ Claude Core (깊이 있는 분석)
    ↓
GitHub (PR & Commit)
    ↓
Telegram (완료 보고)
```

자세히: **WORKFLOW_INTEGRATION.md** 참고

---

## 🛠️ 도구별 사용

### Cursor IDE (게임팀)
```
1. GAME_TEAM_STARTUP.md 읽기
2. tools/TOOL_GUIDELINES.md의 Cursor 섹션 읽기
3. tools/tool-integration/CURSOR_IDE_RULES.txt 적용
4. Telegram에서 지시 받기
5. 코드 작성 시작
```

### Claude Code (모든 팀)
```
1. tools/TOOL_GUIDELINES.md의 Claude Code 섹션 읽기
2. tools/tool-integration/CLAUDE_CODE_RULES.txt 
   프롬프트 앞에 붙여넣기
3. 스크립트 요청 시작
```

### Claude Chat (모든 팀)
```
1. tools/TOOL_GUIDELINES.md의 Claude Chat 섹션 읽기
2. tools/tool-integration/CLAUDE_CHAT_RULES.txt 구조 따르기
3. 대화 시작
```

### Claude Core (PM & Team Leads)
```
1. tools/TOOL_GUIDELINES.md의 Claude Core 섹션 읽기
2. tools/tool-integration/CLAUDE_CORE_RULES.txt 포함하기
3. 깊이 있는 분석 요청
```

---

## 📋 당신의 역할은?

### 🎮 게임 개발자?
```
1. GETTING_STARTED.md 읽기
2. QUICK_START.md 읽기
3. WORKFLOW_INTEGRATION.md 읽기 ← 필수!
4. onboarding/GAME_TEAM_STARTUP.md 읽기
5. tools/tool-integration/CURSOR_IDE_RULES.txt 적용
6. Telegram 지시 대기
```

### 📝 콘텐츠 라이터?
```
1. GETTING_STARTED.md 읽기
2. QUICK_START.md 읽기
3. WORKFLOW_INTEGRATION.md 읽기 ← 필수!
4. onboarding/CONTENT_TEAM_STARTUP.md 읽기
5. 봇으로 첫 글 작성
```

### 🔧 운영/QA 담당자?
```
1. GETTING_STARTED.md 읽기
2. QUICK_START.md 읽기
3. WORKFLOW_INTEGRATION.md 읽기 ← 필수!
4. onboarding/OPS_TEAM_STARTUP.md 읽기
5. QA/테스트/연구 역할 선택
```

### 👨‍💼 PM/Team Lead?
```
1. QUICK_START.md 읽기
2. WORKFLOW_INTEGRATION.md 읽기 ← 필수!
3. onboarding/[YOUR_TEAM]_STARTUP.md 읽기
4. tools/tool-integration/README.md 읽기
5. 팀 운영 시작
```

---

## ✨ 이 폴더의 특징

✅ **완벽한 일관성**
- 모든 팀이 같은 방식으로 일함
- 메시지, 코드, 워크플로우 통일

✅ **50분 온보딩**
- 새 팀원도 50분 안에 완전 준비
- 체계적인 단계별 가이드
- 역할별 맞춤형 문서

✅ **즉시 사용 가능**
- Copy-paste 규칙 파일
- 템플릿 & 예제 포함
- 별도 설정 불필요

✅ **모든 도구 통합**
- Cursor IDE
- Claude Code
- Claude Chat
- Claude Core
- Telegram
- GitHub

---

## 📞 도움말

**"어디서 시작하나요?"**
→ GETTING_STARTED.md부터 시작하세요 (2분)

**"Telegram 메시지 포맷이 뭐예요?"**
→ WORKFLOW_INTEGRATION.md 읽기

**"코드 스타일이 뭐예요?" (게임팀)**
→ onboarding/GAME_TEAM_STARTUP.md의 "코드 스타일" 섹션

**"도구를 어떻게 설정하나요?"**
→ tools/ 폴더의 해당 도구 파일 참고

**"PR 생성은 어떻게?"**
→ WORKFLOW_INTEGRATION.md의 "Step 3: PR 생성"

---

## 🚀 다음 단계

```
1️⃣ GETTING_STARTED.md 읽기 (2분)
   ↓
2️⃣ 당신의 역할에 맞는 가이드 선택
   ↓
3️⃣ 모든 필독 문서 완독
   ↓
✅ 준비 완료!
```

---

## 📚 문서 통계

| 폴더 | 파일 수 | 크기 | 설명 |
|------|--------|------|------|
| 핵심 가이드 | 3 | 22KB | GETTING_STARTED, QUICK_START, WORKFLOW |
| onboarding | 3 | 19KB | 게임/콘텐츠/운영팀 스타트업 |
| tools | 2 | 36KB | TOOL_GUIDELINES, TOOL_CHEATSHEETS |
| tool-integration | 5 | 56KB | 도구별 규칙 파일 & 개요 |
| **총합** | **13** | **133KB** | **완벽한 온보딩 & 도구 통합** |

---

## ✅ 체크리스트

새 팀원이 다음을 완료했나요?

```
☐ GETTING_STARTED.md 읽음 (2분)
☐ QUICK_START.md 읽음 (5분)
☐ WORKFLOW_INTEGRATION.md 읽음 (15분) ← 필수!
☐ 팀별 STARTUP 읽음 (30분)
☐ 도구 설정 완료
☐ Team Lead 지시 대기
```

모두 완료? **축하합니다!** 이제 시작할 준비가 완료되었습니다! 🎉

---

## 📍 상위 폴더 구조

```
~/Projects/geekbrox/
├── project-management/
│   ├── getting-started/ ← 당신이 여기 있습니다 🟢
│   │   ├── README.md (이 파일)
│   │   ├── GETTING_STARTED.md
│   │   ├── QUICK_START.md
│   │   ├── WORKFLOW_INTEGRATION.md
│   │   ├── onboarding/
│   │   ├── tools/
│   │   └── tool-integration/
│   ├── OPERATION_MANUAL.md (일일 운영)
│   └── ...
├── teams/
│   ├── game/
│   ├── content/
│   └── ops/
└── ...
```

---

**Last Updated:** 2026-02-28  
**Version:** 1.0  
**Status:** ✅ Complete Onboarding & Tool Integration  
**Ready:** 새 팀원 즉시 온보딩, 모든 도구 일관성 있게 작동
