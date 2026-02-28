# 📊 GeekBrox 조직 & 파일 구조 완성 가이드

**작성일**: 2026-02-28  
**작성자**: Atlas (AI PM)  
**상태**: 📋 정리 완료 (Steve PM 승인 대기)

---

## 🎯 이 문서의 목적

지금까지의 혼란을 정리하고, **올바른 구조**로 전환하기 위한 종합 가이드입니다.

---

## ❌ 지금까지의 문제점

### 1. 루트에 산재된 문서

```
geekbrox/
├─ README.md ✅ (OK)
├─ PROJECT_STRUCTURE.md ✅ (OK)
├─ ONBOARDING.md ✅ (OK)
├─ AI_AGENTS_AND_WORKFLOW.md ❌ (agents/로 이동해야)
├─ AI_AGENTS_AND_WORKFLOW_SUMMARY.md ❌ (agents/로 이동해야)
├─ TEAM_WORKFLOWS.md ❌ (project-management/로 이동해야)
├─ PHASE3_DETAILED_TASKS.md ❌ (teams/game/design/로 이동해야)
├─ PHASE3_NEXT_TASKS.md ❌ (project-management/로 이동해야)
├─ PHASE3_REFERENCE_GUIDE.md ❌ (teams/game/design/로 이동해야)
└─ requirements.txt ✅ (OK)
```

**문제**: 
- 프로젝트 구조를 무시한 무분별한 배치
- 어느 팀의 문서인지 불명확
- 새로운 도구(Cursor, Claude Code)에서 참조 어려움

---

### 2. 도구별 참조 규칙 부재

```
Cursor IDE에서:
"PHASE3_DETAILED_TASKS.md를 열어줄래?"
→ 어디있지? (루트? teams/game? docs?)

Claude Code에서:
"TEAM_WORKFLOWS.md에서 팀 역할을 읽고 수정해줄래?"
→ 정확한 경로를 모름
```

---

### 3. 확장성 부족

```
게임 2개 추가되면?
→ teams/game/game2/ (어디에?)

새로운 팀 추가되면?
→ teams/marketing/ (구조가 정해지지 않음)

새로운 문서 추가할 때?
→ 루트? docs/? teams/?  (기준 없음)
```

---

## ✅ 이제 정리된 것들

### 1. WORKSPACE_CONVENTIONS.md (신규)

```
목적: 모든 팀이 따를 통합 규칙
내용:
  ├─ 폴더 구조 규칙 (어떤 문서가 어디로 갈까?)
  ├─ 파일명 규칙 (UPPERCASE_WITH_UNDERSCORES.md)
  ├─ 도구별 사용 규칙 (Cursor, Claude Code, Atlas)
  └─ 문서 생명주기 (신규 추가 시 어떤 폴더로?)
```

**위치**: `/geekbrox/WORKSPACE_CONVENTIONS.md` ← 루트 유지 (모든 팀이 접근 용이)

---

### 2. 올바른 폴더 구조 정의

```
geekbrox/
├─ 루트 (공통): README.md, PROJECT_STRUCTURE.md, WORKSPACE_CONVENTIONS.md
├─ agents/atlas/ ← AI 에이전트 설정
│  ├─ ATLAS_CONFIGURATION.md
│  ├─ TEAM_WORKFLOWS.md (복제)
│  └─ atlas_bot.py
├─ teams/game/workspace/design/03_phase3/ ← Phase 3 기획
│  ├─ PHASE3_DETAILED_TASKS.md
│  ├─ PHASE3_REFERENCE_GUIDE.md
│  └─ 01_combat_system/
├─ project-management/roadmap/ ← 전체 로드맵
│  ├─ PHASE3_ROADMAP.md
│  └─ PHASES_OVERVIEW.md
├─ project-management/workflow/ ← 팀 워크플로우
│  └─ TEAM_WORKFLOWS.md (복제)
├─ docs/conventions/ ← 협업 규칙
│  └─ WORKSPACE_CONVENTIONS.md (복제)
└─ docs/tools/ ← 도구별 가이드
   ├─ CURSOR_IDE_GUIDE.md
   ├─ CLAUDE_CODE_GUIDE.md
   └─ ATLAS_PM_GUIDE.md
```

---

### 3. 도구별 명확한 규칙

#### Cursor IDE

```
📍 파일 생성 시:
   teams/game/workspace/design/03_phase3/PHASE3_DETAILED_TASKS.md
   (절대경로로 저장)

📍 파일 참조 시:
   docs/WORKSPACE_CONVENTIONS.md 를 먼저 읽어서
   올바른 경로 확인 후 진행

📍 커밋 메시지:
   "docs: Add PHASE3_DETAILED_TASKS to game design (03_phase3)"
```

#### Claude Code

```
📍 여러 파일 수정 시:
   "teams/game/workspace/design/03_phase3/ 폴더의 모든 파일을
    WORKSPACE_CONVENTIONS.md 규칙에 따라 정리해줄래?"

📍 새 파일 생성 시:
   "teams/game/workspace/design/03_phase3/ 에 다음 파일들을
    생성해줄래:
    - CARD_POOL.md
    - CARD_MASTER.xlsx
    - ENEMY_DESIGN.md"

📍 경로 명시:
   상대경로 X: "design/CARD_POOL.md"
   절대경로 O: "/Users/.../geekbrox/teams/game/workspace/design/03_phase3/CARD_POOL.md"
```

#### Atlas PM

```
📍 문서 참조 시:
   "teams/game/workspace/design/05_development_tracking/PROGRESS.md 를
    읽고 현재 진행률 리포트해줄래?"

📍 파일 업데이트 시:
   "project-management/tracking/PROGRESS_OVERVIEW.md 를
    teams/ 폴더의 모든 PROGRESS.md 파일을 통합해서 업데이트해줄래?"

📍 주간 보고 생성:
   "project-management/reports/WEEKLY_2026_02_28.md 파일을
    생성해서 이번주 진행 현황을 정리해줄래?"
```

---

## 🔄 마이그레이션 계획 (26분)

### 단계별 실행

```
Step 1️⃣ : 폴더 생성 (1분)
  └─ teams/game/workspace/design/03_phase3/
  └─ project-management/roadmap/
  └─ project-management/workflow/
  └─ docs/conventions/
  └─ docs/tools/

Step 2️⃣ : 파일 이동 (5분, git mv 사용)
  ├─ PHASE3_DETAILED_TASKS.md → teams/game/workspace/design/03_phase3/
  ├─ PHASE3_NEXT_TASKS.md → project-management/roadmap/PHASE3_ROADMAP.md
  ├─ AI_AGENTS_AND_WORKFLOW.md → agents/atlas/ATLAS_CONFIGURATION.md
  ├─ TEAM_WORKFLOWS.md → agents/atlas/ (+ project-management/workflow/ 복제)
  └─ PHASE3_REFERENCE_GUIDE.md → teams/game/workspace/design/03_phase3/

Step 3️⃣ : README 파일 추가 (5분)
  ├─ teams/game/workspace/design/03_phase3/README.md
  ├─ project-management/README.md
  ├─ docs/conventions/README.md
  └─ docs/tools/README.md

Step 4️⃣ : 링크 업데이트 (10분)
  ├─ PROJECT_STRUCTURE.md 에서 경로 수정
  ├─ teams/game/workspace/design/README.md 생성
  └─ 각 폴더 README에서 링크 확인

Step 5️⃣ : Git 커밋 & 푸시 (5분)
  └─ git commit -m "refactor: Reorganize documentation to follow WORKSPACE_CONVENTIONS"
```

---

## 📚 다음에 생성해야 할 문서들

### 우선순위 1 (필수)

```
docs/tools/
├─ CURSOR_IDE_GUIDE.md       # Cursor IDE 사용 규칙
├─ CLAUDE_CODE_GUIDE.md      # Claude Code 사용 규칙
└─ ATLAS_PM_GUIDE.md         # Atlas PM 협업 방법

docs/conventions/
├─ NAMING_CONVENTIONS.md     # 파일명 규칙
├─ FILE_STRUCTURE_CONVENTIONS.md # 폴더 구조 규칙
└─ DOCUMENTATION_STYLE.md    # 문서 작성 스타일

docs/guides/
└─ COLLABORATION_GUIDE.md    # 팀간 협업 가이드
```

### 우선순위 2 (선택)

```
project-management/workflow/
├─ DECISION_MAKING.md        # 의사결정 프로세스
├─ APPROVAL_WORKFLOW.md      # 승인 프로세스
└─ MEETING_SCHEDULE.md       # 회의 일정

docs/guides/
├─ GIT_WORKFLOW.md           # Git 협업 방법
└─ COMMUNICATION.md          # 의사소통 규칙
```

---

## ✨ 마이그레이션 후의 이점

### 1. 명확성

```
❌ 이전: "PHASE3_DETAILED_TASKS.md 어디있어?"
✅ 이후: "/teams/game/workspace/design/03_phase3/PHASE3_DETAILED_TASKS.md" (명확)
```

### 2. 확장성

```
❌ 이전: 게임 2개 추가할 때 어디에? (결정 필요)
✅ 이후: teams/game/game2/ (구조가 자명)
```

### 3. 도구 무관성

```
Cursor IDE, Claude Code, Atlas 모두 동일한 규칙 적용
→ 어떤 도구를 쓰든 파일을 찾을 수 있음
```

### 4. 유지보수성

```
❌ 이전: 새 팀이 합류 시 "어디에 파일을?"
✅ 이후: WORKSPACE_CONVENTIONS.md를 읽으면 됨
```

---

## 🚀 시작 체크리스트

### Steve PM이 해야 할 일

```
□ WORKSPACE_CONVENTIONS.md 읽기 (15분)
□ 마이그레이션 계획 검토 (10분)
□ "승인합니다" 또는 "변경 후 승인" 의견 전달
```

### 마이그레이션 실행 (Atlas)

```
□ MIGRATION_PLAN.md의 명령어 실행 (26분)
□ git push origin main 
□ GitHub 확인 (모든 파일이 올바른 위치?)
```

### 팀별 확인 (각 Team Lead)

```
Game Lead:
  □ teams/game/workspace/design/03_phase3/ 폴더 확인
  □ README.md 읽기
  □ PHASE3_DETAILED_TASKS.md 위치 확인

Content Lead:
  □ project-management/workflow/TEAM_WORKFLOWS.md 확인
  □ teams/content/workspace/design/ 폴더 구조 검토

Ops Lead:
  □ agents/atlas/ATLAS_CONFIGURATION.md 확인
  □ project-management/ 구조 이해
```

---

## 📞 빠른 참조

### "이 파일은 어디에 가야 해?"

| 파일 유형 | 저장 위치 | 예시 |
|----------|---------|------|
| 게임 기획 | teams/game/workspace/design/ | TAROT_SYSTEM_GUIDE.md |
| Phase 3 업무 | teams/game/workspace/design/03_phase3/ | PHASE3_DETAILED_TASKS.md |
| 콘텐츠 전략 | teams/content/workspace/design/ | CONTENT_STRATEGY.md |
| 운영 리포트 | teams/ops/workspace/reports/ | WEEKLY_REPORT.md |
| 전체 로드맵 | project-management/roadmap/ | PHASE3_ROADMAP.md |
| 팀 구조 | agents/atlas/ 또는 project-management/workflow/ | TEAM_WORKFLOWS.md |
| 협업 규칙 | docs/conventions/ | WORKSPACE_CONVENTIONS.md |
| 도구 가이드 | docs/tools/ | CURSOR_IDE_GUIDE.md |

---

## 🎓 결론

**이 3개 문서가 모두 완성되었습니다:**

1. **WORKSPACE_CONVENTIONS.md** ← 마스터 규칙 (모든 팀이 따를 기준)
2. **MIGRATION_PLAN.md** ← 실행 계획 (26분 내에 완료 가능)
3. **ORGANIZATION_SUMMARY.md** ← 이 문서 (요약 & 체크리스트)

**다음 단계:**
```
1️⃣ Steve PM 승인 받기
2️⃣ MIGRATION_PLAN.md의 명령어 실행
3️⃣ 모든 팀이 새 구조에 맞춰 작업 시작
4️⃣ docs/tools/ 에 도구별 가이드 추가로 완성
```

---

**상태**: ✅ 문서 완성  
**다음 액션**: Steve PM 승인 대기  
**예상 완료**: 2026-02-28 (오늘)
