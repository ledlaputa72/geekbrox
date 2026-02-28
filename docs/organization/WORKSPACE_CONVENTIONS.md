# 📋 GeekBrox 작업공간 규칙 (Workspace Conventions)

**작성일**: 2026-02-28  
**작성자**: Atlas (AI PM)  
**목적**: 모든 팀이 일관되게 파일/폴더를 관리하고, 모든 도구(Cursor, Claude Code, 등)에서 올바르게 참조하기 위한 통합 규칙

---

## 📌 핵심 원칙

이 규칙은 다음 목표를 달성합니다:

1. **✅ 일관성**: 누가, 어디에, 뭘 저장해도 구조가 통일됨
2. **✅ 추적성**: 누가 언제 뭘 수정했는지 추적 가능
3. **✅ 확장성**: 새로운 팀/프로젝트 추가 시 쉽게 확장
4. **✅ 도구 무관성**: Cursor, Claude Code, Atlas 모두 동일한 규칙 사용

---

## 🗂️ 1. 폴더 구조 & 문서 배치 규칙

### 전체 구조 (최상위 수준)

```
geekbrox/
├─ README.md                              # 프로젝트 개요 (항상 루트)
├─ PROJECT_STRUCTURE.md                   # 폴더 구조 설명 (항상 루트)
├─ WORKSPACE_CONVENTIONS.md               # 이 파일 (항상 루트)
├─ requirements.txt                       # 의존성 (항상 루트)
├─ .gitignore                             # Git 제외 (항상 루트)
│
├─ agents/                                # 🤖 AI 에이전트 설정
│  └─ atlas/                              # Atlas PM 에이전트
│     ├─ README.md
│     ├─ ATLAS_CONFIGURATION.md           # ← AI 에이전트 역할/설정
│     ├─ TEAM_WORKFLOWS.md                # ← 팀 역할 & 워크플로우 (Atlas 관리)
│     └─ atlas_bot.py
│
├─ frameworks/                            # 🔄 재사용 가능한 자동화
│  └─ blog_automation/
│     ├─ README.md
│     ├─ MANUAL.md
│     ├─ scripts/
│     └─ templates/
│
├─ docs/                                  # 📚 기술 문서 & 가이드
│  ├─ README.md
│  ├─ guides/
│  │  ├─ ONBOARDING.md                   # 팀원 온보딩 (루트와 중복, docs로 옮길 예정)
│  │  ├─ COLLABORATION_GUIDE.md          # 협업 가이드 (신규)
│  │  └─ ...
│  ├─ conventions/
│  │  ├─ WORKSPACE_CONVENTIONS.md        # (이 파일의 백업, 확인용)
│  │  ├─ NAMING_CONVENTIONS.md           # (신규)
│  │  └─ FILE_STRUCTURE_CONVENTIONS.md   # (신규)
│  └─ tools/
│     ├─ CURSOR_IDE_GUIDE.md             # Cursor IDE 사용 규칙 (신규)
│     ├─ CLAUDE_CODE_GUIDE.md            # Claude Code 사용 규칙 (신규)
│     └─ ATLAS_PM_GUIDE.md               # Atlas PM 사용 규칙 (신규)
│
├─ teams/                                 # 👥 개별 팀/프로젝트
│  │
│  ├─ game/                               # 🎮 게임 개발 팀
│  │  ├─ README.md
│  │  │
│  │  ├─ dream-collector/
│  │  │  │
│  │  │  ├─ workspace/
│  │  │  │  │
│  │  │  │  ├─ design/                    # 📋 게임 기획 & 설계
│  │  │  │  │  ├─ README.md
│  │  │  │  │  ├─ 01_vision/             # 게임 비전 (이미 완성)
│  │  │  │  │  │  └─ 00_INTEGRATED_GAME_CONCEPT.md
│  │  │  │  │  │
│  │  │  │  │  ├─ 02_core_design/        # 핵심 시스템 (일부 완성)
│  │  │  │  │  │  ├─ TAROT_SYSTEM_GUIDE.md ✅
│  │  │  │  │  │  └─ CARD_FUNCTION_DESIGN_GUIDE.md
│  │  │  │  │  │
│  │  │  │  │  ├─ 03_phase3/             # ← Phase 3 업무 (신규 폴더)
│  │  │  │  │  │  ├─ README.md
│  │  │  │  │  │  ├─ PHASE3_DETAILED_TASKS.md ← 이동
│  │  │  │  │  │  ├─ PHASE3_REFERENCE_GUIDE.md ← 이동
│  │  │  │  │  │  └─ 01_combat_system/  # 전투 시스템
│  │  │  │  │  │     ├─ COMBAT_BALANCE.md
│  │  │  │  │  │     ├─ CARD_POOL.md
│  │  │  │  │  │     └─ ENEMY_DESIGN.md
│  │  │  │  │  │
│  │  │  │  │  ├─ 04_narrative_and_lore/
│  │  │  │  │  │  └─ ...
│  │  │  │  │  │
│  │  │  │  │  └─ 05_development_tracking/ (이미 있음)
│  │  │  │  │     ├─ PROGRESS.md
│  │  │  │  │     └─ DEVELOPMENT_CHECKLIST.md
│  │  │  │  │
│  │  │  │  ├─ godot/                    # 🎮 Godot 소스 코드
│  │  │  │  │  └─ ...
│  │  │  │  │
│  │  │  │  └─ art/                      # 🎨 게임 에셋
│  │  │  │     └─ ...
│  │  │  │
│  │  │  └─ (향후 game2/, game3/ 등)
│  │
│  ├─ content/                            # 📝 콘텐츠 팀
│  │  ├─ README.md
│  │  ├─ workspace/
│  │  │  ├─ design/                       # 콘텐츠 기획
│  │  │  │  └─ CONTENT_STRATEGY.md
│  │  │  └─ blog/
│  │  │     ├─ posts/                    # 발행된 글
│  │  │     ├─ drafts/                   # 초안
│  │  │     └─ published/                # 최종 발행
│  │  └─ ...
│  │
│  └─ ops/                                # ⚙️ 운영 팀
│     ├─ README.md
│     ├─ workspace/
│     │  ├─ design/                       # 운영 기획
│     │  ├─ scripts/                     # 자동화 스크립트
│     │  ├─ reports/                     # 주간/월간 리포트
│     │  └─ monitoring/                  # 헬스체크 결과
│     └─ ...
│
├─ project-management/                    # 📊 전체 프로젝트 관리
│  ├─ README.md
│  │
│  ├─ roadmap/                            # 🗺️ 전체 로드맵
│  │  ├─ ROADMAP_2026.md                  # 연간 계획
│  │  ├─ PHASES_OVERVIEW.md               # Phase 1-5 개요
│  │  └─ PHASE3_ROADMAP.md                # ← PHASE3_NEXT_TASKS 이동
│  │
│  ├─ workflow/                           # 🔄 팀 워크플로우
│  │  ├─ TEAM_STRUCTURE.md                # 팀 구조 (← agents/atlas/TEAM_WORKFLOWS.md 원본)
│  │  ├─ DECISION_MAKING.md               # 의사결정 프로세스
│  │  └─ APPROVAL_WORKFLOW.md             # 승인 프로세스
│  │
│  ├─ sprints/                            # 📅 스프린트 관리
│  │  ├─ SPRINT_2026_W01.md
│  │  ├─ SPRINT_2026_W02.md
│  │  ├─ SPRINT_2026_W03.md
│  │  └─ SPRINT_TEMPLATE.md
│  │
│  ├─ reports/                            # 📈 주간/월간 리포트
│  │  ├─ WEEKLY_2026_02_28.md
│  │  ├─ MONTHLY_2026_02.md
│  │  └─ REPORT_TEMPLATE.md
│  │
│  └─ tracking/                           # 📍 진행 추적
│     ├─ PROGRESS_OVERVIEW.md
│     └─ MILESTONE_TRACKER.md
│
├─ build/                                 # 🔨 빌드 산출물 (Git 제외)
│  └─ (자동 생성, .gitignore에 포함)
│
└─ .config/                               # ⚙️ 개발 환경 설정 (Git 제외)
   ├─ .env                                # API 키 (절대 Git 제외)
   ├─ local.json                          # 로컬 설정
   └─ (자동 생성, .gitignore에 포함)
```

---

## 📐 2. 각 폴더별 문서 배치 규칙

### 🤖 agents/atlas/
**목적**: AI PM 에이전트 설정 & 매뉴얼

**필수 문서**:
```
agents/atlas/
├─ README.md                    # Atlas가 누구인가, 뭘 하는가
├─ ATLAS_CONFIGURATION.md       # Atlas의 설정 (모델, 권한, 역할)
├─ TEAM_WORKFLOWS.md            # 팀 역할 & 일일 워크플로우 (Atlas가 관리)
└─ atlas_bot.py                 # 봇 구현 코드
```

**저장하면 안 될 문서**:
- ❌ Phase 3 업무 (teams/game/workspace/design/03_phase3/로)
- ❌ 팀 구조 원본 (project-management/workflow/로)

---

### 🎮 teams/game/workspace/design/03_phase3/
**목적**: Phase 3 게임 기획 문서

**구조**:
```
teams/game/workspace/design/
├─ 01_vision/              # 비전 (완성 ✅)
├─ 02_core_design/         # 핵심 시스템 (일부 완성)
├─ 03_phase3/              # ← Phase 3 업무 (신규)
│  ├─ README.md            # Phase 3 개요
│  ├─ PHASE3_DETAILED_TASKS.md        # 구체적 업무 가이드
│  ├─ PHASE3_REFERENCE_GUIDE.md       # 참고 자료
│  │
│  ├─ 01_combat_system/
│  │  ├─ COMBAT_BALANCE.md            # 전투 시스템 최종 결정
│  │  ├─ CARD_POOL.md                 # 카드 풀 설계
│  │  ├─ CARD_MASTER.xlsx             # 모든 카드 데이터
│  │  ├─ ENEMY_DESIGN.md              # 몬스터 설계
│  │  ├─ ENEMY_MASTER.xlsx            # 몬스터 데이터
│  │  └─ BOSS_NARRATIVE.md            # 보스 스토리
│  │
│  ├─ 02_economy_and_balance/
│  │  ├─ RELIC_SYSTEM.md
│  │  ├─ RELIC_MASTER.xlsx
│  │  ├─ ECONOMY_BALANCE.md
│  │  └─ BALANCING_NOTES.md
│  │
│  ├─ 03_progression/
│  │  ├─ CHARACTER_DESIGN.md
│  │  ├─ ASCENSION_SYSTEM.md
│  │  └─ NODE_INTERACTION.md
│  │
│  └─ progress/
│     ├─ PHASE3_PROGRESS.md            # Phase 3 진행률 (매주 업데이트)
│     └─ PHASE3_CHECKLIST.md           # 체크리스트
│
├─ 04_narrative_and_lore/
├─ 05_development_tracking/
└─ _archive/
```

---

### 📊 project-management/
**목적**: 전체 프로젝트 관리 (팀 초월)

**문서 배치 규칙**:
```
project-management/
├─ roadmap/
│  ├─ PHASE3_ROADMAP.md                # ← PHASE3_NEXT_TASKS.md 이동
│  ├─ PHASES_OVERVIEW.md
│  └─ TIMELINE_2026.md
│
├─ workflow/
│  ├─ TEAM_STRUCTURE.md                # 팀 구조 & 계층 (agents/atlas/와 복제)
│  ├─ DECISION_MAKING.md               # 결정권자와 프로세스
│  └─ APPROVAL_WORKFLOW.md             # 승인 프로세스
│
├─ sprints/
│  └─ SPRINT_2026_W03.md               # 이번주 스프린트
│
├─ reports/
│  └─ WEEKLY_2026_02_28.md             # 주간 리포트
│
└─ tracking/
   └─ PROGRESS_OVERVIEW.md
```

---

### 📚 docs/
**목적**: 모든 팀이 참고할 기술 문서 & 가이드

**구조**:
```
docs/
├─ README.md
│
├─ guides/
│  ├─ ONBOARDING.md                    # 팀원 온보딩 (루트에서 이동)
│  ├─ COLLABORATION_GUIDE.md           # 협업 방법 (신규)
│  ├─ GIT_WORKFLOW.md                  # Git 협업 (신규)
│  └─ COMMUNICATION.md                 # 의사소통 규칙 (신규)
│
├─ conventions/
│  ├─ WORKSPACE_CONVENTIONS.md         # 이 파일
│  ├─ NAMING_CONVENTIONS.md            # 파일명 규칙 (신규)
│  ├─ FILE_STRUCTURE_CONVENTIONS.md    # 폴더 구조 규칙 (신규)
│  └─ DOCUMENTATION_STYLE.md           # 문서 작성 스타일 (신규)
│
└─ tools/
   ├─ CURSOR_IDE_GUIDE.md              # Cursor IDE (신규)
   ├─ CLAUDE_CODE_GUIDE.md             # Claude Code (신규)
   ├─ ATLAS_PM_GUIDE.md                # Atlas PM (신규)
   └─ GITHUB_WORKFLOW.md               # GitHub 협업 (신규)
```

---

## 🏷️ 3. 파일명 규칙 (Naming Conventions)

### 문서 파일명

**규칙 1: 대문자 + 언더스코어**
```
✅ GOOD:  PHASE3_DETAILED_TASKS.md
✅ GOOD:  COMBAT_BALANCE.md
❌ BAD:   phase3_detailed_tasks.md
❌ BAD:   Phase3DetailedTasks.md
❌ BAD:   combat-balance.md
```

**규칙 2: 파일 용도를 명확히 반영**
```
_GUIDE.md         → 사용 방법 (CURSOR_IDE_GUIDE.md)
_CHECKLIST.md     → 체크리스트 (DEVELOPMENT_CHECKLIST.md)
_TEMPLATE.md      → 템플릿 (SPRINT_TEMPLATE.md)
_PLAN.md          → 계획 (PROJECT_PLAN.md)
_REPORT.md        → 리포트 (WEEKLY_REPORT.md)
_STRATEGY.md      → 전략 (CONTENT_STRATEGY.md)
_DESIGN.md        → 설계 (ENEMY_DESIGN.md)
_SYSTEM.md        → 시스템 (RELIC_SYSTEM.md)
_OVERVIEW.md      → 개요 (PROGRESS_OVERVIEW.md)
```

**규칙 3: 날짜 포맷**
```
✅ GOOD:  SPRINT_2026_W03.md
✅ GOOD:  WEEKLY_2026_02_28.md
❌ BAD:   sprint_week03.md
❌ BAD:   report_2-28.md
```

### 데이터 파일

**규칙: 전부 대문자 + 밑줄 + 타입명**
```
CARD_MASTER.xlsx
ENEMY_MASTER.xlsx
RELIC_MASTER.xlsx
ECONOMY_MASTER.xlsx
```

---

## 🛠️ 4. 도구별 사용 규칙 (Tool Conventions)

### Cursor IDE 사용 규칙

**파일 생성 시**:
```
1️⃣ 올바른 폴더 경로 확인
   └─ teams/game/workspace/design/03_phase3/ ← 여기에 저장

2️⃣ 파일명 규칙 준수
   └─ PHASE3_DETAILED_TASKS.md (대문자 + 언더스코어)

3️⃣ 파일 내용 시작
   └─ 상단에 메타데이터 추가:
      ```
      작성일: 2026-02-28
      작성자: 기획팀
      위치: teams/game/workspace/design/03_phase3/
      목적: Phase 3 상세 업무 가이드
      ```

4️⃣ 저장 후 git status 확인
   └─ 파일이 올바른 경로에 있는지 확인
```

**파일 편집 시**:
```
1️⃣ 파일 경로 확인
   └─ .cursorrules 에서 상대경로 사용
      예: "teams/game/workspace/design/TAROT_SYSTEM_GUIDE.md"

2️⃣ 변경 후 항상 git diff로 검증
   └─ 의도한 파일만 수정되었나?

3️⃣ 커밋 메시지 명확히
   └─ "docs: Update CARD_POOL.md with new card effects"
      NOT "updated file"
```

**구조 참조 시**:
```
✅ 올바른 경로:
   teams/game/workspace/design/02_core_design/TAROT_SYSTEM_GUIDE.md

❌ 잘못된 경로:
   design/TAROT_SYSTEM_GUIDE.md (상대경로 불명확)
   ./TAROT_SYSTEM_GUIDE.md (루트 기준)
   /teams/game/workspace/design/ (절대경로)
```

---

### Claude Code 사용 규칙

**사용 목적**:
- ✅ 반복 작업 자동화 (여러 파일 수정)
- ✅ 복잡한 데이터 변환
- ✅ 스프레드시트 생성
- ❌ 단순 파일 1-2개 수정 (Cursor 추천)

**작업 시작 전**:
```
1️⃣ 현재 폴더 구조 확인
   $ find teams/game/workspace/design -type f -name "*.md" | head -20

2️⃣ 저장할 경로 명확히 하기
   "모든 파일을 teams/game/workspace/design/03_phase3/로 저장해줘"

3️⃣ 파일명 규칙 강조
   "파일명은 모두 대문자_언더스코어.md 형식이야"

4️⃣ 멀티파일 생성 시 목록 제공
   - CARD_POOL.md (설계서)
   - CARD_MASTER.xlsx (데이터)
   - CARD_BALANCING_NOTES.md (밸런싱)
```

**작업 완료 후**:
```
1️⃣ 생성된 파일 확인
   $ ls -la teams/game/workspace/design/03_phase3/

2️⃣ git status로 검증
   $ git status (모든 파일이 올바른 경로?)

3️⃣ 필요시 git add & commit
   $ git add teams/game/workspace/design/03_phase3/
   $ git commit -m "docs: Create Phase 3 detailed task documentation"
```

---

### Atlas PM 사용 규칙

**프로젝트 상태 조회**:
```
Atlas: "teams/game/workspace/design/PROGRESS.md 현재 상태 알려줄래?"
→ Atlas가 파일을 읽고 상태 리포트 제공
```

**팀 지시**:
```
Atlas: "teams/game/workspace/design/03_phase3/PHASE3_CHECKLIST.md에
        이번주 체크리스트 업데이트해줄래?"
→ Atlas가 파일을 읽고 업데이트, git commit
```

**진행 추적**:
```
Atlas: "project-management/tracking/PROGRESS_OVERVIEW.md 최신화해줄래?"
→ Atlas가 teams/*/workspace/design/에서 progress 파일들을 읽고
  project-management/로 통합 리포트 작성
```

---

## 📋 5. 문서 생명주기 (Document Lifecycle)

### 신규 문서 추가 시

```
Step 1: 올바른 폴더 결정
├─ 게임 기획? → teams/game/workspace/design/03_phase3/
├─ 팀 일정? → project-management/sprints/
├─ 협업 가이드? → docs/guides/
└─ 기술 설정? → docs/tools/

Step 2: 파일명 규칙 적용
└─ ACTUAL_FILENAME_WITH_UNDERSCORES.md

Step 3: 메타데이터 추가
```
작성일: 2026-02-28
작성자: 기획팀
위치: teams/game/workspace/design/03_phase3/
목적: Phase 3 상세 업무 가이드
```

Step 4: git add & commit
└─ git commit -m "docs: Add PHASE3_DETAILED_TASKS to game design"

Step 5: 관련 README 업데이트
└─ teams/game/workspace/design/README.md에 새 파일 링크 추가
```

### 문서 구조 변경 시

```
변경 전:  /PHASE3_DETAILED_TASKS.md (루트)
변경 후:  /teams/game/workspace/design/03_phase3/PHASE3_DETAILED_TASKS.md

적용 방법:
1. git mv <old> <new>
2. 관련 문서에서 링크 업데이트
   - PROJECT_STRUCTURE.md
   - teams/game/workspace/design/README.md
3. git add & commit
```

---

## ✅ 6. 현재 상태 & 마이그레이션 계획

### 현재 문제점

```
❌ /PHASE3_DETAILED_TASKS.md (루트)
❌ /PHASE3_NEXT_TASKS.md (루트)
❌ /PHASE3_REFERENCE_GUIDE.md (루트)
❌ /TEAM_WORKFLOWS.md (루트)
❌ /AI_AGENTS_AND_WORKFLOW.md (루트)
❌ /AI_AGENTS_AND_WORKFLOW_SUMMARY.md (루트)
```

### 마이그레이션 계획

| 현재 위치 | 이동할 위치 | 이유 |
|----------|-----------|------|
| PHASE3_DETAILED_TASKS.md | teams/game/workspace/design/03_phase3/ | 게임 기획 문서 |
| PHASE3_NEXT_TASKS.md | project-management/roadmap/ | 전체 프로젝트 로드맵 |
| PHASE3_REFERENCE_GUIDE.md | teams/game/workspace/design/03_phase3/ | 게임 기획 참고 자료 |
| TEAM_WORKFLOWS.md | agents/atlas/ (또는 project-management/workflow/) | 팀 구조/워크플로우 |
| AI_AGENTS_AND_WORKFLOW.md | agents/atlas/ | AI 에이전트 설정 |
| AI_AGENTS_AND_WORKFLOW_SUMMARY.md | agents/atlas/ | AI 에이전트 요약 |

### 실행 순서

```
Step 1: 폴더 생성
$ mkdir -p teams/game/workspace/design/03_phase3/
$ mkdir -p project-management/roadmap/
$ mkdir -p project-management/workflow/

Step 2: 파일 이동 (git mv 사용)
$ git mv PHASE3_DETAILED_TASKS.md teams/game/workspace/design/03_phase3/
$ git mv PHASE3_NEXT_TASKS.md project-management/roadmap/
$ ... (나머지)

Step 3: 링크 업데이트
$ vim PROJECT_STRUCTURE.md
$ vim teams/game/workspace/design/README.md
$ vim project-management/README.md

Step 4: git commit
$ git commit -m "refactor: Reorganize Phase 3 and team workflow documentation to correct folders"

Step 5: git push
$ git push origin main
```

---

## 📖 7. 참조 가이드

### "내가 지금 뭔가 작성해야 하는데, 어디에 저장해야 하나?"

```
게임 기획서?
└─ teams/game/workspace/design/03_phase3/ ✅

팀 역할 정의?
└─ agents/atlas/ (또는 project-management/workflow/) ✅

일주일 스프린트?
└─ project-management/sprints/ ✅

새로운 팀원 가이드?
└─ docs/guides/ ✅

Cursor IDE 사용법?
└─ docs/tools/CURSOR_IDE_GUIDE.md ✅

API 비용 추적?
└─ teams/ops/workspace/reports/ ✅

게임 AI 몬스터 설계?
└─ teams/game/workspace/design/03_phase3/01_combat_system/ ✅
```

### "누가 이 파일을 참조하나?"

```
PHASE3_DETAILED_TASKS.md
└─ 기획팀 (Kim.G), 개발팀 (Cursor IDE), 밸런스팀

TEAM_WORKFLOWS.md
└─ 모든 팀 (Steve, Atlas, Kim.G, Lee.C, Park.O)

CARD_POOL.md
└─ 게임팀 (설계), 아트팀 (시각화), 밸런스팀 (검증)

PROGRESS_OVERVIEW.md
└─ Steve (전체 현황), Atlas (주간 보고), 각 팀장 (팀별 진행률)
```

---

## 🎓 8. 교육 & 체크리스트

### 새로운 팀원을 위한 체크리스트

- [ ] README.md 읽기
- [ ] PROJECT_STRUCTURE.md 읽기 (폴더 구조)
- [ ] WORKSPACE_CONVENTIONS.md 읽기 (이 파일)
- [ ] docs/guides/ONBOARDING.md 읽기
- [ ] 자신의 팀 README 읽기 (teams/{team}/README.md)
- [ ] 자신의 도구 가이드 읽기 (docs/tools/)

### 매주 확인 사항 (Team Lead)

- [ ] 팀의 파일들이 올바른 폴더에 있나?
- [ ] 파일명이 규칙을 따르나?
- [ ] README.md가 최신으로 유지되나?
- [ ] 진행 문서가 매주 업데이트되나?
- [ ] git commit 메시지가 명확한가?

### 매달 정리 (Atlas)

- [ ] 오래된 임시 파일 정리
- [ ] 아카이브 폴더로 이동할 파일 확인
- [ ] 문서 구조 개선 필요 여부 검토
- [ ] 규칙을 위반한 파일 확인

---

## 🔗 9. 관련 문서 링크

- **읽어야 할 문서**: 
  - PROJECT_STRUCTURE.md (폴더 구조)
  - docs/guides/ONBOARDING.md (팀원 온보딩)
  - docs/conventions/ (모든 규칙)
  - docs/tools/ (도구별 가이드)

- **각 팀의 워크플로우**:
  - teams/game/README.md
  - teams/content/README.md
  - teams/ops/README.md

- **프로젝트 추적**:
  - project-management/roadmap/PHASE3_ROADMAP.md
  - project-management/tracking/PROGRESS_OVERVIEW.md

---

**문서 버전**: 1.0  
**작성일**: 2026-02-28  
**마지막 업데이트**: 2026-02-28  
**마이그레이션 실행**: (대기 중)  
**상태**: ⏳ 승인 대기 (Steve PM)
