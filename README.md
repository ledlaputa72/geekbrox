# 🌟 GeekBrox - 독립 게임 & 콘텐츠 개발 플랫폼

**GeekBrox**는 인디 게임 개발과 콘텐츠 운영을 효율적으로 관리하는 통합 플랫폼입니다. OpenClaw 기반 AI 에이전트와 자동화 프레임워크로 팀 생산성을 극대화합니다.

**핵심 철학:**
- 🎯 **목적-기반 조직화**: 모든 폴더와 파일이 명확한 목적을 가짐
- 🤖 **AI PM 중심**: Atlas (AI PM)가 팀을 관리하고 자동화 조율
- 📊 **3단계 계층 구조**: Steve (CEO/PD) → Atlas (AI PM) → Kim.G/Lee.C/Park.O (AI Agents)
- 🔄 **반복 프레임워크**: 게임/콘텐츠 개발 자동화로 효율성 극대화
- 📈 **추적 가능한 진행**: 모든 프로젝트가 PROGRESS.md로 추적됨

---

## 📂 프로젝트 구조 (주석 포함)

```
geekbrox/
│
├─ 📖 README.md                    # ← 이 파일 (프로젝트 전체 가이드)
├─ ⚙️  requirements.txt             # Python 의존성 (pip install -r requirements.txt)
├─ 🔐 .git/                         # Git 저장소 (자동 생성)
├─ 🚫 .gitignore                    # Git에서 제외할 파일 (.env, __pycache__, 등)
│
│
├─ 🤖 AGENTS/ (AI 에이전트 설정)
│  │
│  └─ atlas/
│     ├─ atlas_bot.py              # Atlas PM 봇 메인 코드
│     ├─ ATLAS_MANUAL.md           # Atlas 사용 매뉴얼
│     └─ README.md                 # 에이전트 역할 설명
│
│  💡 목적: OpenClaw 기반 AI 에이전트 관리
│  📌 역할: 
│     - Atlas: PM 역할, 팀 진행률 추적, 자동화 관리, 일일 보고
│  🎯 사용법:
│     - ./agents/atlas/run_atlas.sh (Atlas 봇 실행)
│     - Telegram으로 Atlas에 지시 명령 전달
│
│
├─ 🔄 FRAMEWORKS/ (반복 자동화 프레임워크)
│  │
│  └─ blog_automation/
│     ├─ README.md                 # 프레임워크 개요
│     ├─ MANUAL.md                 # 블로그 자동화 사용 설명서
│     ├─ run_post.sh               # 블로그 봇 실행 스크립트 ⭐
│     ├─ scripts/                  # Python 자동화 스크립트들
│     │  ├─ content_team_bot.py    # Telegram 봇 UI
│     │  ├─ fetch_anime.py         # 애니 정보 자동 수집
│     │  ├─ generate_post.py       # 블로그 글 자동 생성
│     │  ├─ post_to_tistory.py    # Tistory 자동 포스팅
│     │  └─ share_to_sns.py        # SNS 자동 공유
│     ├─ templates/                # 글 작성 템플릿
│     │  └─ anime_post_template.md # 애니 리뷰 포스트 템플릿
│     └─ output/                   # 자동화 결과물 (Git 제외)
│        ├─ images/                # 생성된 이미지
│        ├─ posts/                 # 생성된 글
│        └─ shared_state.json      # 상태 추적
│
│  💡 목적: 반복 가능한 자동화 솔루션 제공
│  📌 역할:
│     - blog_automation: 블로그 글 자동 수집 → 생성 → 포스팅 → SNS 배포
│  🎯 사용법:
│     - ./frameworks/blog_automation/run_post.sh (블로그 봇 실행)
│     - teams/content/workspace/ 과 연동
│
│
├─ 📊 PROJECT-MANAGEMENT/ (프로젝트 관리 & 문서)
│  │
│  ├─ MASTER_ROADMAP.md              # 전체 프로젝트 로드맵
│  ├─ TEAM_WORKFLOWS.md              # 모든 매니저의 역할 & 워크플로우
│  ├─ PROJECT_STRUCTURE.md           # 전체 폴더 구조 가이드
│  ├─ ORGANIZATION_SUMMARY.md        # 조직 계층 & 팀 구조
│  ├─ WORKSPACE_CONVENTIONS.md       # 파일 명명 규칙 & 팀 컨벤션
│  ├─ ONBOARDING.md                  # 새 팀원 3시간 온보딩 경로
│  │
│  ├─ guides/                        # 기술 가이드 & 개발 프로세스
│  │  ├─ CODE_REVIEW.md             # 코드 리뷰 기준 & 프로세스
│  │  └─ BLOG_POSTING_UPDATE.md    # 블로그 포스팅 업데이트 가이드
│  │
│  ├─ manuals/                       # 도구 & 서비스 매뉴얼
│  │  └─ OPENCLAW_REPAIR.md         # OpenClaw 트러블슈팅 가이드
│  │
│  ├─ sprints/                       # 스프린트 계획 & 관리
│  ├─ tasks/                         # 태스크 추적 (BACKLOG, IN_PROGRESS, DONE)
│  ├─ roadmap/                       # 세부 로드맵 (게임, 콘텐츠)
│  ├─ reports/                       # 주간/월간 보고서
│  │
│  └─ README.md                      # 프로젝트 관리 구조 가이드
│
│  💡 목적: 전체 프로젝트 관리 및 팀 워크플로우
│  📌 구성:
│     - 상단: 조직 & 구조 문서 (프로젝트 전체 이해)
│     - guides/: "어떻게 하는가?" (프로세스)
│     - manuals/: "뭐가 잘못됐을 때?" (트러블슈팅)
│     - sprints/: "이번 주/달 목표는?" (기획)
│  🎯 사용법:
│     - 처음인가? project-management/ONBOARDING.md 읽기
│     - 구조가 궁금한가? project-management/PROJECT_STRUCTURE.md 참고
│     - 역할이 궁금한가? project-management/TEAM_WORKFLOWS.md 참고
│
│
├─ 📦 RESOURCES/ (공유 자산 & 벤치마킹 자료)
│  │
│  ├─ img/                         # 이미지 자산
│  │  ├─ bg/                       # 배경 이미지
│  │  │  └─ home_bg.png           # Dream Collector 홈 배경
│  │  └─ sprite/                   # 캐릭터/몬스터 스프라이트
│  │     ├─ player_ani.png         # 플레이어 애니메이션
│  │     ├─ NPC1_ani.png           # NPC1 애니메이션
│  │     └─ ...
│  │
│  ├─ references/                   # 외부 참고 자료 & 벤치마킹
│  │  ├─ Game System.pdf           # 게임 시스템 레퍼런스
│  │  └─ game test.pdf             # 게임 테스트 매뉴얼
│  │
│  └─ README.md                     # 자산 가이드
│
│  💡 목적: 모든 프로젝트가 공유하는 자산 및 벤치마킹 자료 보관
│  📌 특징:
│     - 게임 에셋이 아님 (게임별 에셋은 teams/game/workspace/art/)
│     - 로고, 아이콘, 범용 배경 등 프로젝트 공용 이미지
│  🎯 사용법:
│     - 게임 에셋: teams/game/dream-collector/workspace/art/
│     - 공유 이미지: resources/img/ 참고
│
│
├─ 👥 TEAMS/ (개별 프로젝트 & 팀 관리)
│  │
│  ├─ game/                         # 게임 개발 팀
│  │  ├─ README.md                 # Game Team 구조 & 계층적 위임
│  │  │  ├─ Steve → Atlas → Game Lead → Cursor/Claude
│  │  │  ├─ 일일 체크리스트, 즉시 태스크 처리 방식
│  │  │  └─ 성공 기준 (일일 2-3 태스크, 품질 관리)
│  │  │
│  │  └─ dream-collector/           # Dream Collector 게임 프로젝트
│  │     ├─ workspace/
│  │     │  ├─ design/              # 게임 기획 문서
│  │     │  │  ├─ 01_vision/        # 게임 비전 & 컨셉
│  │     │  │  ├─ 02_core_design/   # 타로 시스템, GDD
│  │     │  │  ├─ 03_implementation_guides/  # ATB, 턴제 전투 가이드
│  │     │  │  ├─ 04_narrative_and_lore/    # 스토리, 캐릭터
│  │     │  │  ├─ 05_development_tracking/  # 개발 진행 상황 (Atlas 추적)
│  │     │  │  └─ _archive/         # 과거 버전 (v1, v2, v3...)
│  │     │  │
│  │     │  ├─ godot/                # Godot 4.x 게임 소스 코드
│  │     │  │  ├─ autoload/         # 글로벌 매니저 (CombatManager 등)
│  │     │  │  ├─ scenes/           # 게임 씬 (UI, 게임플레이 등)
│  │     │  │  ├─ scripts/          # GDScript 스크립트
│  │     │  │  └─ project.godot     # Godot 프로젝트 설정
│  │     │  │
│  │     │  └─ art/                  # 게임 에셋 (아트)
│  │     │     ├─ art_style/        # 스타일 가이드 (Genshin, Sky 등 참고)
│  │     │     ├─ sprites/          # 캐릭터 스프라이트
│  │     │     ├─ backgrounds/      # 배경 이미지
│  │     │     └─ animations/       # 애니메이션 파일
│  │     │
│  │     └─ README.md               # Dream Collector 프로젝트 가이드
│  │
│  ├─ content/                      # 콘텐츠 운영 팀
│  │  ├─ README.md                 # Content Team 구조 & 계층적 위임
│  │  │  ├─ Steve → Atlas → Content Lead → Claude Code
│  │  │  ├─ 블로그 글 작성 워크플로우
│  │  │  ├─ SNS 자동 배포
│  │  │  └─ 성공 기준 (주 3회 게시, KPI 달성)
│  │  │
│  │  └─ blog/                      # 블로그 프로젝트
│  │     ├─ posts/                 # 게시된 글 (마크다운)
│  │     │  ├─ dev-diary-1.md     # 개발 일지
│  │     │  ├─ game-review.md     # 게임 리뷰
│  │     │  └─ indie-trends.md    # 인디 게임 트렌드
│  │     ├─ drafts/                # 작성 중인 글
│  │     ├─ published/             # 게시된 글 기록
│  │     └─ README.md              # Blog 프로젝트 가이드
│  │
│  └─ ops/                          # 운영 & 인프라 팀
│     ├─ README.md                 # Ops Team 구조 & 계층적 위임
│     │  ├─ Steve → Atlas → Ops Lead
│     │  ├─ OpenClaw 인프라 관리
│     │  ├─ 월간 $200 예산 내 비용 최적화
│     │  └─ 성공 기준 (99.5% 가동률, 1.5s 응답)
│     │
│     ├─ scripts/                  # 인프라 자동화 스크립트
│     │  ├─ check-infrastructure.sh # 헬스 체크
│     │  ├─ cost-optimizer.py      # 비용 모니터링
│     │  └─ build-deploy.yml       # CI/CD 파이프라인
│     │
│     ├─ reports/                  # 주간/월간 리포트
│     │  ├─ weekly-health.md       # 가동률, 성능 리포트
│     │  ├─ weekly-cost.md         # API 비용 리포트
│     │  └─ monthly-summary.md     # 월간 요약
│     │
│     └─ configs/                  # 인프라 설정
│        ├─ openclaw-backup.json   # OpenClaw 설정 백업
│        └─ ci-cd-config.yaml      # CI/CD 설정
│
│  💡 teams/ 목적: 개별 프로젝트를 팀별로 관리
│  📌 구조:
│     - game/ → Dream Collector, Dungeon Parasite (향후)
│     - content/ → Blog, YouTube (향후)
│     - ops/ → 인프라, 자동화 관리
│  🎯 사용법:
│     - 게임 개발: teams/game/dream-collector/workspace/
│     - 콘텐츠 작성: teams/content/blog/
│     - 인프라 관리: teams/ops/
│
│
├─ 📊 PROJECT-MANAGEMENT/ (멀티프로젝트 PM 추적)
│  │
│  ├─ MASTER_ROADMAP.md            # 전체 프로젝트 로드맵 (Steve의 전략)
│  ├─ README.md                    # PM 구조 설명
│  │
│  ├─ roadmap/                      # 세부 로드맵
│  │  ├─ game-development-roadmap.md        # 게임 개발 장기 계획
│  │  └─ content-operations-roadmap.md     # 콘텐츠 운영 장기 계획
│  │
│  ├─ sprints/                      # 주간 스프린트 계획
│  │  ├─ 2026-W08-sprint.md        # "이번 주 우리가 할 일"
│  │  └─ archive/                   # 지난 주 스프린트
│  │
│  ├─ tasks/                        # 태스크 추적 (Kanban)
│  │  ├─ BACKLOG.md                # "나중에 할 것들"
│  │  ├─ IN_PROGRESS.md            # "지금 하고 있는 것"
│  │  └─ DONE.md                   # "완료된 것들" (주간 아카이브)
│  │
│  └─ reports/                      # 주간/월간 보고서
│     ├─ 2026-02-weekly-report.md  # 이번주 완료, 문제, 다음주 계획
│     └─ 2026-02-monthly-report.md # 월간 요약 (KPI, 비용, 위험)
│
│  💡 목적: 모든 프로젝트의 진행 상황을 한곳에서 추적
│  📌 특징:
│     - MASTER_ROADMAP: "우리가 어디로 가는가?"
│     - sprints/: "이번 주 목표는?"
│     - tasks/: "누가 뭘 하고 있나?"
│     - reports/: "우리가 얼마나 잘하고 있나?"
│  🎯 사용법:
│     - Atlas: 매일 IN_PROGRESS.md 업데이트
│     - Team Lead: 스프린트 작성, 태스크 관리
│     - Steve: 주간 리포트로 진행 상황 파악
│
│
├─ 🔨 BUILD/ (빌드 산출물, Git 제외)
│
└─ ⚙️  .CONFIG/ (개발 환경 설정, Git 제외)
   │
   ├─ .env                         # 환경변수 (⚠️ 민감 정보!)
   │  ├─ GEMINI_API_KEY=...       # Google Gemini API 키
   │  ├─ CLAUDE_API_KEY=...       # Anthropic Claude API 키
   │  └─ TISTORY_TOKEN=...        # Tistory 블로그 API 토큰
   │
   ├─ .cursor/                     # Cursor IDE 설정
   │  ├─ rules/                    # Cursor 규칙 파일
   │  │  ├─ 00-project-overview.mdc     # 프로젝트 전체 규칙
   │  │  ├─ 01-coding-standards.mdc    # 코딩 표준
   │  │  ├─ 02-tistory-selenium.mdc    # 블로그 자동화 규칙
   │  │  └─ 03-game-dev.mdc            # 게임 개발 규칙
   │  └─ settings.json             # Cursor IDE 사용자 설정
   │
   ├─ .cursorrules                 # Cursor IDE 전역 규칙 (프로젝트 루트)
   │
   ├─ __pycache__/                 # Python 컴파일 캐시 (자동 생성)
   │  └─ (자동으로 생성됨, 수정 금지)
   │
   ├─ .venv/                       # Python 가상환경 (선택사항)
   │  └─ (python3 -m venv .config/.venv)
   │
   └─ README.md                    # 환경 설정 가이드
      ├─ "환경변수 어떻게 설정하지?"
      ├─ "Python 가상환경 설정"
      └─ "API 키 관리 보안"

   💡 목적: 로컬 개발 환경 설정 (공유하지 않음)
   📌 특징:
      - .env: 절대 Git에 커밋하지 말 것! (.gitignore 등록)
      - .cursor/: IDE 규칙 (팀이 따를 지침)
      - 각 팀원이 별도로 설정해야 함
   🎯 사용법:
      - cp .config/.env.example .config/.env
      - API 키 입력
      - python3 -m venv .config/.venv (가상환경)
      - source .config/.venv/bin/activate

```

---

## 🎯 핵심 개념

### 1️⃣ Agents (에이전트)
**OpenClaw 기반 AI 에이전트들이 프로젝트 관리 및 자동화를 담당합니다.**

- **Atlas** - 프로젝트 매니저 에이전트 (PM)
  - 프로젝트 진행 상황 추적
  - 자동화 워크플로우 관리
  - Telegram 기반 커맨드 처리

### 2️⃣ Frameworks (프레임워크)
**반복적으로 사용될 수 있는 자동화 솔루션들입니다.**

- **blog_automation** - 블로그 포스팅 자동화 (Tistory, WordPress)
- (향후) **game_automation** - 게임 빌드 & 배포 자동화
- (향후) **content_automation** - 콘텐츠 생성 자동화

### 3️⃣ Teams (팀 & 프로젝트)
**실제 게임 및 콘텐츠 프로젝트들을 관리합니다.**

- **game/** - 게임 개발 프로젝트
  - Dream Collector (현재 개발 중)
- **content/** - 콘텐츠 운영 프로젝트
  - 블로그 자동화 활용
- **ops/** - 운영 및 인프라

### 4️⃣ Project Management (PM 추적)
**멀티프로젝트 레벨의 로드맵, 스프린트, 태스크 관리입니다.**

- 전체 프로젝트 마스터 로드맵
- 주간 스프린트 계획
- 태스크 추적 (백로그/진행중/완료)
- 주간/월간 보고서

---

## 🚀 빠른 시작

### 환경 설정

```bash
# 1. 저장소 클론
git clone https://github.com/ledlaputa72/geekbrox.git
cd geekbrox

# 2. 환경변수 설정 (첫 실행 시)
cp .config/.env.example .config/.env
# .config/.env 에서 필요한 API 키/토큰 입력

# 3. Python 의존성 설치
pip install -r requirements.txt

# 또는 가상환경 사용 (권장)
python3 -m venv .config/.venv
source .config/.venv/bin/activate
pip install -r requirements.txt
```

### 에이전트 & 자동화 실행

```bash
# Atlas PM 에이전트 실행
./agents/atlas/run_atlas.sh

# 블로그 포스팅 자동화 실행
./frameworks/blog_automation/run_post.sh
```

### 프로젝트 문서 탐색

- **게임 개발**: `teams/game/workspace/`
- **프로젝트 관리**: `project-management/`
- **기술 가이드**: `project-management/guides/`
- **에이전트 매뉴얼**: `agents/atlas/ATLAS_MANUAL.md`
- **조직 구조**: `agents/AI_AGENTS_AND_WORKFLOW.md`

---

## 📋 주요 프로젝트

### 🎮 Dream Collector (꿈 수집가)

| 항목 | 내용 |
|------|------|
| **상태** | Phase 3 진행 중 (Combat System) |
| **엔진** | Godot 4.x |
| **플랫폼** | 모바일 (Portrait 390×844px) |
| **장르** | Roguelike + Deck-building + Idle |
| **기획** | `teams/game/dream-collector/workspace/design/` |
| **코드** | `teams/game/dream-collector/workspace/godot/` |
| **에셋** | `teams/game/dream-collector/workspace/art/` |

**Phase 진행 상황**:
- ✅ Phase 1: UI 시스템 (12 screens)
- ✅ Phase 2: 캐릭터 스프라이트 & 애니메이션
- 🔄 Phase 3: 전투 시스템 (ATB)
- ⏸️ Phase 4: 게임 폴리시
- 🔲 Phase 5: 베타 테스트

---

## 🤝 팀 & 역할

| 역할 | 담당자 | 책임 |
|------|--------|------|
| **PM** | Steve PM | 전체 프로젝트 관리 |
| **AI Agent** | Atlas | 자동화 & 추적 |
| **개발** | Cursor IDE, Claude Code | 게임 & 웹 개발 |

---

## 📞 문의 및 지원

- **Issues**: GitHub Issues
- **Discussions**: GitHub Discussions
- **Blog**: (blog 운영 시작 예정)

---

## 📝 라이선스

[LICENSE 파일 참고]

---

## 🔄 최근 업데이트

**2026-02-28 - 문서 폴더 재정렬** 🎯
- ✅ docs/ 폴더 제거 및 파일 재배치
  - `agents/` - AI 에이전트 설정 & 조직 문서
  - `project-management/` - 프로젝트 관리 & 팀 워크플로우
  - `teams/[game|content|ops]/workspace/` - 각 팀 개발 문서
  - `frameworks/blog_automation/output/` - 자동화 결과물
- ✅ build/ 폴더 제거 (빈 폴더, 자동화 결과는 frameworks에 통합)
- ✅ 프로젝트 구조 정규화
  - `agents/` - AI 에이전트 설정 (atlas/run_atlas.sh 포함)
  - `frameworks/` - 자동화 프레임워크 (blog_automation/run_post.sh 포함)
  - `project-management/` - 프로젝트 관리 & 기술 문서
  - `resources/` - 공유 자산
  - `teams/` - 팀별 개발 프로젝트
  - `.config/` - 개발 환경 설정 (Git 제외)
- ✅ scripts 폴더 통합 (agents & frameworks로 이동)
- ✅ 폴더별 README 작성 및 업데이트
- ✅ 모든 경로 참조 수정

---

**관리자**: Steve PM  
**PM Agent**: Atlas  
**마지막 업데이트**: 2026-02-28 (scripts 폴더 통합)
