# 🔄 파일 구조 마이그레이션 계획

**작성일**: 2026-02-28  
**상태**: ⏳ 실행 대기 (Steve PM 승인 필요)  
**담당**: Atlas PM & 기획팀  
**예상 소요 시간**: 30분

---

## 🎯 목표

**현재 문제**: 루트에 산재된 문서들 (6개)  
**목표**: WORKSPACE_CONVENTIONS.md 규칙에 따라 모든 파일을 올바른 폴더로 정리

---

## 📋 마이그레이션 체크리스트

### Phase 1: 폴더 생성 (1단계)

```bash
# 신규 폴더 생성 (4개)
mkdir -p teams/game/workspace/design/03_phase3
mkdir -p project-management/roadmap
mkdir -p project-management/workflow
mkdir -p docs/conventions
mkdir -p docs/guides
mkdir -p docs/tools
```

**예상 시간**: 1분

---

### Phase 2: 파일 이동 (2단계)

#### 🎮 게임 기획 문서 → teams/game/workspace/design/03_phase3/

```bash
# Phase 3 관련 문서 (3개)
git mv PHASE3_DETAILED_TASKS.md \
  teams/game/workspace/design/03_phase3/PHASE3_DETAILED_TASKS.md

git mv PHASE3_REFERENCE_GUIDE.md \
  teams/game/workspace/design/03_phase3/PHASE3_REFERENCE_GUIDE.md

# 폴더 구조 README 추가
cat > teams/game/workspace/design/03_phase3/README.md << 'EOF'
# 📋 Phase 3: Systems Design

Phase 3는 Dream Collector의 핵심 게임 시스템을 설계하는 단계입니다.

## 문서 구조

```
03_phase3/
├─ README.md (이 파일)
├─ PHASE3_DETAILED_TASKS.md     # 구체적 업무 가이드
├─ PHASE3_REFERENCE_GUIDE.md    # 참고 자료 모음
│
├─ 01_combat_system/             # 전투 시스템 (3/3~3/7)
│  ├─ COMBAT_BALANCE.md          # 최종 선택 (ATB/Turn)
│  ├─ CARD_POOL.md               # 카드 풀 설계
│  ├─ CARD_MASTER.xlsx           # 카드 데이터
│  ├─ ENEMY_DESIGN.md            # 몬스터 설계
│  ├─ ENEMY_MASTER.xlsx          # 몬스터 데이터
│  └─ BOSS_NARRATIVE.md          # 보스 스토리
│
├─ 02_economy_and_balance/       # 경제 및 밸런싱 (3/10~3/14)
│  ├─ RELIC_SYSTEM.md
│  ├─ RELIC_MASTER.xlsx
│  ├─ ECONOMY_BALANCE.md
│  └─ CHARACTER_DESIGN.md
│
├─ 03_progression/               # 진행 시스템 (3/21~3/23)
│  ├─ ASCENSION_SYSTEM.md
│  └─ NODE_INTERACTION.md
│
└─ progress/
   ├─ PHASE3_PROGRESS.md
   └─ PHASE3_CHECKLIST.md
```

## 참고

- 전체 게임 비전: `../01_vision/00_INTEGRATED_GAME_CONCEPT.md`
- 타로 시스템: `../02_core_design/TAROT_SYSTEM_GUIDE.md`
- 스토리 & 레벨: `../04_narrative_and_lore/`
- 개발 추적: `../05_development_tracking/`

## 마감일

- 🔴 3/3: 전투 시스템 결정
- 🟠 3/7: 카드 풀 & 몬스터 설계
- 🟡 3/23: Phase 3 전체 완료
EOF
```

#### 📊 프로젝트 로드맵 → project-management/roadmap/

```bash
# 전체 roadmap (1개)
git mv PHASE3_NEXT_TASKS.md \
  project-management/roadmap/PHASE3_ROADMAP.md

# 폴더 README 추가
cat > project-management/roadmap/README.md << 'EOF'
# 🗺️ 프로젝트 로드맵

## Phase 3 로드맵
- 파일: PHASE3_ROADMAP.md
- 상태: 진행 중 (25%)
- 기한: 2026-03-23
EOF
```

#### 🤖 AI 에이전트 설정 → agents/atlas/

```bash
# AI 에이전트 설정 문서 (2개)
git mv AI_AGENTS_AND_WORKFLOW.md \
  agents/atlas/ATLAS_CONFIGURATION.md

git mv AI_AGENTS_AND_WORKFLOW_SUMMARY.md \
  agents/atlas/ATLAS_CONFIGURATION_SUMMARY.md

# 팀 워크플로우는 agents/atlas/에도 복제 (프로젝트 구조 중심)
cp TEAM_WORKFLOWS.md agents/atlas/TEAM_WORKFLOWS.md

# 폴더 README 업데이트
cat >> agents/atlas/README.md << 'EOF'

## 핵심 문서

- **ATLAS_CONFIGURATION.md**: Atlas의 역할과 설정
- **TEAM_WORKFLOWS.md**: 팀 구조 및 일일 워크플로우
EOF
```

#### 📋 협업 가이드 & 규칙 → docs/

```bash
# 이미 생성된 WORKSPACE_CONVENTIONS.md는 루트 유지
# (모든 팀이 쉽게 접근할 수 있도록)
# → docs/conventions/ 에도 복제

cp WORKSPACE_CONVENTIONS.md \
  docs/conventions/WORKSPACE_CONVENTIONS.md

# 팀 워크플로우는 project-management/에도 복제
cp TEAM_WORKFLOWS.md \
  project-management/workflow/TEAM_WORKFLOWS.md

# 폴더 README 추가
cat > docs/conventions/README.md << 'EOF'
# 📋 협업 규칙 (Conventions)

이 폴더는 모든 팀이 따라야 할 규칙을 정의합니다.

## 파일 목록

- **WORKSPACE_CONVENTIONS.md**: 파일/폴더 구조 규칙
- **NAMING_CONVENTIONS.md**: 파일명 규칙
- **FILE_STRUCTURE_CONVENTIONS.md**: 폴더 구조 규칙
- **DOCUMENTATION_STYLE.md**: 문서 작성 스타일

## 모든 팀이 읽어야 할 문서

1. 프로젝트 입사 후 첫 번째: PROJECT_STRUCTURE.md
2. 두 번째: WORKSPACE_CONVENTIONS.md
3. 자신의 도구 가이드: docs/tools/
EOF

cat > docs/tools/README.md << 'EOF'
# 🛠️ 도구별 사용 가이드

각 팀이 사용하는 도구별 규칙을 정의합니다.

## 가이드

- **CURSOR_IDE_GUIDE.md**: Cursor IDE 사용 시 규칙
- **CLAUDE_CODE_GUIDE.md**: Claude Code 사용 시 규칙
- **ATLAS_PM_GUIDE.md**: Atlas PM과 협업하는 방법

## 핵심 원칙

모든 도구에서 동일한 폴더 구조와 파일명 규칙을 따릅니다.
EOF
```

**예상 시간**: 5분

---

### Phase 3: 링크 업데이트 (3단계)

#### PROJECT_STRUCTURE.md 업데이트

```bash
# 다음 부분 업데이트:
# - PHASE3 문서 위치 수정
# - agents/atlas/ 경로 수정
# - team-workflows 경로 수정
# - project-management 섹션 추가

vim PROJECT_STRUCTURE.md
```

**변경 사항**:
```
# 이전:
/PHASE3_DETAILED_TASKS.md
/PHASE3_NEXT_TASKS.md
/AI_AGENTS_AND_WORKFLOW.md

# 변경 후:
/teams/game/workspace/design/03_phase3/PHASE3_DETAILED_TASKS.md
/project-management/roadmap/PHASE3_ROADMAP.md
/agents/atlas/ATLAS_CONFIGURATION.md
```

#### teams/game/workspace/design/README.md 추가

```bash
cat > teams/game/workspace/design/README.md << 'EOF'
# 🎮 Dream Collector - 게임 기획

이 폴더는 Dream Collector 게임의 모든 기획 문서를 포함합니다.

## 폴더 구조

```
design/
├─ README.md (이 파일)
├─ 01_vision/              # 게임 비전 & 컨셉 (완성 ✅)
├─ 02_core_design/         # 핵심 시스템 (일부 완성)
├─ 03_phase3/              # Phase 3: 시스템 설계 (진행 중)
├─ 04_narrative_and_lore/  # 스토리 & 캐릭터
├─ 05_development_tracking/ # 개발 추적
└─ _archive/               # 과거 버전
```

## 단계별 가이드

### Phase 3 (현재)
- 상태: 25% (2026-02-27 시작)
- 기한: 2026-03-23
- 문서: 03_phase3/README.md
- 담당: 기획팀, 밸런스팀

### 핵심 문서

1. **01_vision/00_INTEGRATED_GAME_CONCEPT.md**
   - 게임 전체 비전
   - 아트 스타일, 세계관, 주인공

2. **02_core_design/TAROT_SYSTEM_GUIDE.md**
   - 78장 타로 카드 시스템
   - 운명의 직조(가챠 메커닉)

3. **03_phase3/PHASE3_DETAILED_TASKS.md**
   - Phase 3 구체적 업무 가이드
   - 9개 미완료 업무

4. **05_development_tracking/PROGRESS.md**
   - 현재 진행 상황
   - 다음 마일스톤
EOF
```

#### project-management/README.md 추가

```bash
cat > project-management/README.md << 'EOF'
# 📊 프로젝트 관리 (Project Management)

GeekBrox 전체 프로젝트의 진행 상황, 일정, 결정을 추적합니다.

## 폴더 구조

```
project-management/
├─ README.md (이 파일)
├─ roadmap/              # 전체 로드맵
├─ workflow/             # 팀 워크플로우
├─ sprints/              # 주간 스프린트
├─ reports/              # 주간/월간 리포트
└─ tracking/             # 진행 상황 추적
```

## 누가 이걸 봐야 하나?

- **Steve PM**: roadmap/ 및 reports/ (전체 현황)
- **Atlas**: workflow/ 및 tracking/ (팀 관리)
- **Team Leads**: sprints/ (주간 목표)
- **모든 팀**: workflow/ (팀 역할 & 의사결정)
EOF
```

**예상 시간**: 10분

---

### Phase 4: Git 커밋 (4단계)

```bash
# 1단계: 상태 확인
git status

# 예상 결과:
# renamed: PHASE3_DETAILED_TASKS.md -> teams/game/workspace/design/03_phase3/PHASE3_DETAILED_TASKS.md
# renamed: PHASE3_NEXT_TASKS.md -> project-management/roadmap/PHASE3_ROADMAP.md
# renamed: PHASE3_REFERENCE_GUIDE.md -> teams/game/workspace/design/03_phase3/PHASE3_REFERENCE_GUIDE.md
# ...
# new file: teams/game/workspace/design/03_phase3/README.md
# ...

# 2단계: 모든 변경사항 스테이징
git add -A

# 3단계: 커밋 메시지 작성
git commit -m "refactor: Reorganize documentation to follow WORKSPACE_CONVENTIONS

- Move Phase 3 documents to teams/game/workspace/design/03_phase3/
- Move Phase 3 roadmap to project-management/roadmap/
- Move AI agent docs to agents/atlas/
- Add team workflow to project-management/workflow/
- Create new folder structure with README.md files
- Update PROJECT_STRUCTURE.md with new paths
- Add WORKSPACE_CONVENTIONS.md as master convention guide

All files now follow naming and structure conventions:
- Large markdown: UPPERCASE_WITH_UNDERSCORES.md
- Data files: UPPERCASE_WITH_TYPE.xlsx
- Each folder has its own README.md

Related to: WORKSPACE_CONVENTIONS.md"

# 4단계: 푸시
git push origin main
```

**예상 시간**: 5분

---

### Phase 5: 검증 (5단계)

```bash
# 1. 모든 파일이 올바른 위치에 있나?
find teams/game/workspace/design/03_phase3 -name "*.md"
find project-management -name "*.md"
find agents/atlas -name "*.md"

# 2. 링크가 깨졌나?
grep -r "PHASE3_DETAILED_TASKS" docs/
grep -r "AI_AGENTS_AND_WORKFLOW" docs/

# 3. git log 확인
git log --oneline -1

# 4. README 파일들이 생성되었나?
ls -la teams/game/workspace/design/03_phase3/README.md
ls -la project-management/README.md
ls -la docs/conventions/README.md
```

**예상 시간**: 5분

---

## 📋 실행 명령어 (한번에)

전체 과정을 한번에 실행하려면:

```bash
#!/bin/bash
cd /Users/stevemacbook/Projects/geekbrox

# Phase 1: 폴더 생성
mkdir -p teams/game/workspace/design/03_phase3
mkdir -p project-management/roadmap
mkdir -p project-management/workflow
mkdir -p docs/conventions
mkdir -p docs/guides
mkdir -p docs/tools

# Phase 2: 파일 이동
git mv PHASE3_DETAILED_TASKS.md teams/game/workspace/design/03_phase3/
git mv PHASE3_REFERENCE_GUIDE.md teams/game/workspace/design/03_phase3/
git mv PHASE3_NEXT_TASKS.md project-management/roadmap/PHASE3_ROADMAP.md
git mv AI_AGENTS_AND_WORKFLOW.md agents/atlas/ATLAS_CONFIGURATION.md
git mv AI_AGENTS_AND_WORKFLOW_SUMMARY.md agents/atlas/ATLAS_CONFIGURATION_SUMMARY.md

# Phase 3: 복제 (reference 용)
cp TEAM_WORKFLOWS.md agents/atlas/TEAM_WORKFLOWS.md
cp TEAM_WORKFLOWS.md project-management/workflow/TEAM_WORKFLOWS.md
cp WORKSPACE_CONVENTIONS.md docs/conventions/WORKSPACE_CONVENTIONS.md

# Phase 4: README 추가
cat > teams/game/workspace/design/03_phase3/README.md << 'EOF'
# Phase 3: Systems Design
...
EOF

# ... (다른 README들도 추가)

# Phase 5: 커밋
git add -A
git commit -m "refactor: Reorganize documentation to follow WORKSPACE_CONVENTIONS"
git push origin main

# Phase 6: 검증
echo "✅ Migration complete!"
ls -la teams/game/workspace/design/03_phase3/
```

---

## 🎯 효과

**마이그레이션 후**:

```
✅ 루트가 깔끔함 (6개 문서 제거)
✅ 각 파일이 논리적 위치에 배치됨
✅ 팀별로 쉽게 자신의 문서를 찾을 수 있음
✅ WORKSPACE_CONVENTIONS.md 규칙 준수
✅ 향후 새 문서 추가 시 구조 명확
```

---

## ⏱️ 예상 시간

| Phase | 작업 | 시간 |
|-------|------|------|
| 1 | 폴더 생성 | 1분 |
| 2 | 파일 이동 | 5분 |
| 3 | 링크 업데이트 | 10분 |
| 4 | Git 커밋 | 5분 |
| 5 | 검증 | 5분 |
| | **합계** | **26분** |

---

## ✅ 승인 대기

**이 마이그레이션을 실행하기 위해서는 Steve PM의 승인이 필요합니다.**

```
Steve PM에게: "루트의 6개 파일을 올바른 폴더로 옮기는 마이그레이션을 진행해도 될까요?
                모든 링크는 업데이트되고, Git 히스토리도 유지됩니다.
                26분 정도 걸릴 것 같습니다."
```

---

**상태**: ⏳ 승인 대기  
**예상 실행일**: 승인 받은 후  
**롤백 가능**: Yes (git reset --hard)
