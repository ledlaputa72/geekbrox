# 📘 GeekBrox 프로젝트 구조 완벽 가이드

**이 문서는 코드의 주석처럼** GeekBrox의 모든 폴더, 파일, 카테고리를 설명합니다.  
누가 어디를 찾아야 하고, 왜 그렇게 조직화되었는지 이해하는 데 도움이 됩니다.

---

## 🎯 조직화의 원칙

GeekBrox는 **5가지 원칙**으로 조직화되어 있습니다:

### 1️⃣ **목적-기반 분류** (Purpose-Based)
```
모든 폴더는 목적이 명확함
└─ agents/ = "AI 에이전트 저장소"
└─ frameworks/ = "반복 사용 가능한 자동화"
└─ teams/ = "개별 프로젝트 저장소"
└─ project-management/ = "전체 진행 상황 추적"
```

### 2️⃣ **계층적 업무 위임** (Hierarchical Delegation)
```
Steve (의사결정)
  ↓ 위임
Atlas (추적 & 자동화)
  ↓ 위임
Team Lead (실행 지휘)
  ↓ 위임
Developer/Writer (구현)
```

### 3️⃣ **자가 설명적 구조** (Self-Documenting)
```
각 폴더 = README.md 포함
각 섹션 = 명확한 목적 설명
각 파일 = 역할이 파일명에서 드러남
```

### 4️⃣ **추적 가능성** (Trackability)
```
PROGRESS.md = "지금 어디까지 왔나?"
sprints/ = "이번 주/월 목표는?"
CHANGELOG.md = "뭐가 바뀌었나?"
reports/ = "우리가 잘하고 있나?"
```

### 5️⃣ **확장 가능성** (Scalability)
```
게임 1개 → 게임 여러 개 (teams/game/game2/)
콘텐츠 1개 → 여러 채널 (teams/content/youtube/)
팀 1개 → 여러 팀 (teams/marketing/, teams/qa/)
```

---

## 📂 폴더별 상세 설명

### 1️⃣ geekbrox/ (루트)

#### 파일들
```
geekbrox/
├─ README.md                    # 프로젝트 전체 가이드 (지금 읽는 문서의 상위)
├─ PROJECT_STRUCTURE.md         # 이 파일 (구조 상세 설명)
├─ requirements.txt             # Python 의존성 (pip install -r requirements.txt)
├─ .gitignore                   # Git 제외 목록 (.env, __pycache__ 등)
└─ LICENSE                      # 라이선스 (MIT, Apache, 등)
```

#### 역할
- 🎯 **프로젝트의 진입점**
- 📖 **모든 하위 폴더에 대한 설명**
- 🚀 **빠른 시작 가이드**

#### 누가 언제 읽나?
- ✅ 새로운 팀원: 첫 번째 읽을 문서
- ✅ Steve: 프로젝트 전체 상태 파악
- ✅ Atlas: 팀 구조 이해
- ✅ 초보자: 프로젝트 개요 학습

---

### 2️⃣ agents/ (AI 에이전트 설정)

#### 구조
```
agents/
├─ README.md                    # 에이전트 역할 설명
├─ atlas/                       # 프로젝트 PM 에이전트
│  ├─ atlas_bot.py             # 봇 메인 코드
│  └─ ATLAS_MANUAL.md          # 사용자 매뉴얼
└─ (향후) content_agent/, dev_agent/ 등
```

#### 역할
- 🤖 **AI 에이전트 설정 보관**
- 📚 **에이전트 사용자 매뉴얼**
- 🔄 **자동화 에이전트 관리**

#### 주요 파일

| 파일 | 목적 | 사용자 |
|------|------|--------|
| **atlas_bot.py** | Atlas PM 봇 구현 | 개발자 |
| **ATLAS_MANUAL.md** | Atlas 사용 방법 | 모든 팀 |
| **README.md** | 에이전트 소개 | 새로운 팀원 |

#### 누가 언제 사용하나?
- ✅ Atlas: 자신의 역할 확인
- ✅ Steve: Atlas에 지시
- ✅ Team Lead: Atlas에 상태 보고
- ✅ 초보자: 에이전트 역할 이해

---

### 3️⃣ frameworks/ (반복 자동화 프레임워크)

#### 구조
```
frameworks/
├─ README.md                    # 프레임워크 개요
├─ blog_automation/             # 블로그 자동화 (현재)
│  ├─ MANUAL.md                # 사용 설명서
│  ├─ scripts/                 # Python 자동화 스크립트들
│  │  ├─ fetch_anime.py        # 애니 정보 수집
│  │  ├─ generate_post.py      # 글 자동 생성
│  │  ├─ post_to_tistory.py   # Tistory 자동 포스팅
│  │  └─ share_to_sns.py       # SNS 자동 공유
│  └─ templates/               # 글 작성 템플릿
│     └─ anime_post_template.md
│
└─ (향후)
   ├─ game_automation/          # 게임 빌드 & 배포
   ├─ content_automation/       # 다양한 콘텐츠 생성
   └─ report_automation/        # 자동 리포트 생성
```

#### 역할
- 🔄 **반복적으로 사용될 자동화 솔루션**
- 📦 **프로젝트별로 재사용 가능**
- ⚙️ **팀이 직접 사용할 수 있는 도구**

#### 특징
- 🎯 **목표**: 수동 작업 최소화 (자동화 극대화)
- 📊 **효과**: 개당 게시물 생성 비용 1/10로 감소
- 🔌 **통합**: teams/content/blog/ 과 자동으로 연동

#### 누가 언제 사용하나?
- ✅ Content Lead: "블로그 글 자동으로 작성해줄래?"
- ✅ Claude Code: "자동화 스크립트 작성해줄래?"
- ✅ Automation: 자동으로 실행 (매일/매주)

---

### 4️⃣ scripts/ (유틸리티 & 실행 스크립트)

#### 구조
```
scripts/
├─ README.md                    # 스크립트 참고서
├─ run_atlas.sh                 # 1️⃣ Atlas PM 에이전트 시작
├─ run_post.sh                  # 2️⃣ 블로그 자동화 시작
│
└─ (향후)
   ├─ build-game.sh            # 3️⃣ 게임 빌드
   ├─ deploy-game.sh           # 4️⃣ 게임 배포
   └─ health-check.sh          # 5️⃣ 인프라 헬스 체크
```

#### 역할
- 🎯 **주요 자동화 작업의 시작점**
- 🚀 **일반인도 쉽게 실행 가능**
- 📝 **복잡한 명령어를 단순화**

#### 사용 방법
```bash
# 1. 실행 권한 추가 (처음 한 번만)
chmod +x scripts/*.sh

# 2. 실행
./scripts/run_atlas.sh      # Atlas 봇 시작
./scripts/run_post.sh       # 블로그 자동화 시작
```

#### 누가 언제 사용하나?
- ✅ Steve: "Atlas 실행해줘" → ./scripts/run_atlas.sh
- ✅ Content Lead: "블로그 포스팅해줘" → ./scripts/run_post.sh
- ✅ 자동화: cron/GitHub Actions로 자동 실행

---

### 5️⃣ docs/ (기술 문서 & 가이드)

#### 구조
```
docs/
├─ README.md                    # 문서 색인 & 구조
│
├─ guides/                       # 기술 가이드 ("어떻게 하는가?")
│  ├─ CODE_REVIEW.md           # 코드 리뷰 기준 & 프로세스
│  ├─ BLOG_POSTING_UPDATE.md   # 블로그 포스팅 프로세스
│  └─ (향후) GIT_WORKFLOW.md, TESTING.md 등
│
├─ manuals/                      # 도구 매뉴얼 ("뭐가 잘못됐을 때?")
│  ├─ OPENCLAW_REPAIR.md        # OpenClaw 트러블슈팅
│  └─ (향후) GODOT_DEBUG.md, CURSOR_TIPS.md 등
│
├─ references/                   # 외부 참고 자료
│  └─ (게임/콘텐츠 벤치마킹 링크들)
│
├─ game_planning/                # 초기 게임 기획 아이디어
│  └─ (게임 컨셉, 장르 연구, 시스템 분석)
│
└─ (향후)
   ├─ ARCHITECTURE/             # 시스템 아키텍처
   ├─ API_DOCS/                # API 명세
   └─ DATABASE/                # 데이터베이스 설계
```

#### 역할
- 📚 **기술 지식 베이스**
- 🎓 **팀 학습 자료**
- 🔍 **문제 해결 참고**

#### 각 섹션의 역할

| 섹션 | 용도 | 예시 |
|------|------|------|
| **guides/** | "정상 절차는?" | 코드 리뷰 기준, 포스팅 프로세스 |
| **manuals/** | "뭐가 잘못됐어?" | OpenClaw 에러, Godot 디버그 |
| **references/** | "참고할 거 뭐 있나?" | 벤치마킹, 기술 스펙 |
| **game_planning/** | "아이디어 모음" | 게임 컨셉, 시스템 설계 초안 |

#### 누가 언제 읽나?
- ✅ 개발자: 코드 리뷰 전 → guides/CODE_REVIEW.md 읽기
- ✅ Content Lead: 글 작성 전 → guides/BLOG_POSTING_UPDATE.md 읽기
- ✅ 문제 해결: Cursor 에러 → manuals/OPENCLAW_REPAIR.md 찾기
- ✅ 초보자: 학습 목표 → guides/ 또는 references/ 참고

---

### 6️⃣ resources/ (공유 자산 & 벤치마킹)

#### 구조
```
resources/
├─ README.md                    # 자산 가이드
│
├─ img/                          # 이미지 자산
│  ├─ bg/                        # 배경 이미지
│  │  └─ home_bg.png           # Dream Collector 홈 배경
│  └─ sprite/                    # 스프라이트 모음
│     ├─ player_ani.png         # 플레이어 애니메이션
│     ├─ player_walk.png
│     ├─ monster1_ani.png
│     ├─ NPC1_ani.png
│     └─ NPC2_ani.png
│
├─ references/                   # 벤치마킹 & 참고 자료
│  ├─ Game System.pdf           # 게임 시스템 설계 레퍼런스
│  └─ game test.pdf             # 테스트 프레임워크
│
└─ (향후)
   ├─ logos/                    # 프로젝트 로고
   ├─ ui_kits/                  # UI 라이브러리
   └─ fonts/                    # 공용 폰트
```

#### 역할
- 🎨 **프로젝트 공용 이미지 자산**
- 📖 **벤치마킹 & 참고 자료**
- 🔗 **모든 프로젝트가 공유 가능**

#### ⚠️ 중요: 게임 에셋 vs 공유 자산

```
❌ 게임별 에셋은 여기에 넣으면 안됨!
   └─ teams/game/dream-collector/workspace/art/ 에 넣기

✅ 공유 이미지만 여기에 저장
   └─ 로고, 아이콘, 범용 배경 등
```

#### 누가 언제 사용하나?
- ✅ 게임 개발: 공용 배경 이미지 참고
- ✅ 블로그: 포스팅 이미지 참고
- ✅ 벤치마킹: 게임 시스템 설계 참고

---

### 7️⃣ teams/ (개별 프로젝트 & 팀)

이 부분이 가장 중요합니다. 각 팀이 실제 일을 하는 곳입니다.

#### 7-1️⃣ teams/game/ (게임 개발 팀)

```
teams/game/
├─ README.md                    # Game Team 구조 & 위임 방식
│  ├─ Steve → Atlas → Game Lead → Cursor/Claude
│  ├─ 일일 체크리스트
│  ├─ 즉시 태스크 처리 방식
│  └─ 성공 기준 정의
│
└─ dream-collector/             # Dream Collector 게임 프로젝트
   │
   ├─ workspace/
   │  ├─ design/                # 게임 기획 문서들
   │  │  ├─ 01_vision/          # 게임 비전 & 컨셉
   │  │  │  └─ 00_INTEGRATED_GAME_CONCEPT.md
   │  │  │
   │  │  ├─ 02_core_design/     # 핵심 게임 시스템
   │  │  │  ├─ GDD.md           # 게임 디자인 문서
   │  │  │  └─ TAROT_SYSTEM_GUIDE.md
   │  │  │
   │  │  ├─ 03_implementation_guides/  # 개발자용 기술 명세
   │  │  │  ├─ ATB_Implementation_Guide.md
   │  │  │  └─ TurnBased_Implementation_Guide.md
   │  │  │
   │  │  ├─ 04_narrative_and_lore/    # 스토리 & 세계관
   │  │  │  ├─ STORY_CONCEPT_GUIDE.md
   │  │  │  └─ CHARACTER_DESIGN.md
   │  │  │
   │  │  ├─ 05_development_tracking/  # 개발 진행 상황 추적
   │  │  │  ├─ PROGRESS.md            # "지금 어디까지?"
   │  │  │  ├─ PROGRESS_TRACKER.md    # 상세 진행률
   │  │  │  ├─ DEVELOPMENT_CHECKLIST.md  # "뭘 해야 하나?"
   │  │  │  ├─ SYSTEM_REQUIREMENTS.md    # 시스템 요구사항
   │  │  │  └─ TECH_DECISIONS.md        # 기술 결정 기록
   │  │  │
   │  │  ├─ _archive/            # 과거 버전들
   │  │  │  ├─ GDD_v1.md
   │  │  │  ├─ GDD_v2.md
   │  │  │  └─ ...
   │  │  │
   │  │  └─ README.md            # Dream Collector 프로젝트 가이드
   │  │
   │  │
   │  ├─ godot/                  # Godot 4.x 게임 소스 코드
   │  │  ├─ autoload/            # 글로벌 매니저들
   │  │  │  ├─ CombatManager.gd  # 전투 시스템 매니저
   │  │  │  ├─ GameManager.gd    # 게임 상태 관리
   │  │  │  └─ AudioManager.gd   # 음향 관리
   │  │  │
   │  │  ├─ scenes/              # 게임 씬들
   │  │  │  ├─ MainLobby.tscn    # 홈 화면
   │  │  │  ├─ DreamCardSelection.tscn  # 뽑기 화면
   │  │  │  ├─ Battle.tscn       # 전투 화면
   │  │  │  └─ ...
   │  │  │
   │  │  ├─ scripts/             # GDScript 스크립트
   │  │  │  ├─ CardDatabase.gd
   │  │  │  ├─ PlayerStats.gd
   │  │  │  └─ ...
   │  │  │
   │  │  ├─ shaders/             # GLSL 셰이더
   │  │  │  └─ chroma_key.gdshader
   │  │  │
   │  │  └─ project.godot        # Godot 프로젝트 설정 파일
   │  │
   │  │
   │  └─ art/                    # 게임 아트 에셋
   │     ├─ art_style/           # 아트 스타일 가이드
   │     │  ├─ README.md         # 스타일 가이드 (Genshin, Sky 등 참고)
   │     │  ├─ 01_characters/    # 캐릭터 에셋
   │     │  ├─ 02_environments/  # 환경 에셋
   │     │  ├─ 03_ui_and_fx/     # UI & 이펙트
   │     │  └─ 04_mood_and_color/ # 무드 & 컬러 팔레트
   │     │
   │     ├─ sprites/             # 캐릭터 스프라이트
   │     │  ├─ player_ani.png
   │     │  ├─ monster1_ani.png
   │     │  └─ NPC*.png
   │     │
   │     ├─ backgrounds/         # 배경 이미지
   │     │  └─ level_*.png
   │     │
   │     └─ animations/          # 애니메이션 데이터
   │        └─ idle_walk_attack.json
   │
   │
   └─ .cursorrules              # Cursor IDE 규칙 (게임 개발용)
      ├─ Godot 규칙
      ├─ GDScript 규칙
      ├─ PR 규칙
      └─ 코드 리뷰 체크리스트

Game Team의 역할:
  📌 Steve의 지시: "Phase 3 ATB 구현하자"
  └─ Atlas가 추적: "Game Lead, ATB 구현 요청들어왔습니다"
     └─ Game Lead 위임: Cursor IDE에게 CombatManager.gd 작성 지시
        └─ Cursor IDE: 코드 작성 → PR → Team Lead 검수 → 병합

Game Team Lead의 책임:
  ✅ 일일: 진행률 확인, PR 리뷰, 이슈 해결
  ✅ 주간: 스프린트 계획, 성과 보고
  ✅ 월간: KPI 달성, 위험 관리
```

#### 7-2️⃣ teams/content/ (콘텐츠 운영 팀)

```
teams/content/
├─ README.md                    # Content Team 구조 & 위임 방식
│  ├─ Steve → Atlas → Content Lead → Claude Code
│  ├─ 글 작성 워크플로우
│  ├─ SNS 자동 배포
│  └─ 성공 기준 (주 3회, KPI)
│
└─ blog/                        # 블로그 프로젝트
   ├─ README.md                # Blog 프로젝트 가이드
   │
   ├─ posts/                    # 게시된 글들 (마크다운)
   │  ├─ dev-diary-1.md        # "Dream Collector 개발일지 #1"
   │  ├─ dev-diary-2.md
   │  ├─ game-review-1.md      # "엘든링 리뷰"
   │  └─ indie-trends-1.md     # "2026 인디게임 트렌드"
   │
   ├─ drafts/                   # 작성 중인 글 (미게시)
   │  ├─ upcoming-post-1.md
   │  └─ ...
   │
   ├─ published/                # 게시된 글 기록 (자동으로 채워짐)
   │  └─ 2026-02-28-dev-diary-1.md
   │
   └─ .cursorrules             # Claude Code 규칙
      ├─ 글 작성 템플릿
      ├─ SEO 최적화 기준
      ├─ 마크다운 포맷
      └─ 블로그 가이드라인

Content Team의 역할:
  📌 Steve의 지시: "이번 주 3개 글 게시하자"
  └─ Atlas가 추적: "Content Lead, 글 3개 요청입니다"
     └─ Content Lead 위임: Claude Code에게 글 작성 지시
        ├─ "개발일지 작성하세요 (1500자)"
        ├─ "게임 리뷰 작성하세요"
        └─ "트렌드 분석 작성하세요"
           └─ Claude Code: 글 작성 → Team Lead 검수 → 승인
              └─ Automation: Markdown → Tistory → SNS 배포

Content Team Lead의 책임:
  ✅ 일일: 글 발행 지시, 게시 승인, SNS 확인
  ✅ 주간: 콘텐츠 계획, 반응 분석
  ✅ 월간: KPI 달성, 트렌드 분석
```

#### 7-3️⃣ teams/ops/ (운영 & 인프라 팀)

```
teams/ops/
├─ README.md                    # Ops Team 구조 & 위임 방식
│  ├─ Steve → Atlas → Ops Lead
│  ├─ OpenClaw 인프라 관리
│  ├─ 비용 최적화 ($200/월)
│  └─ 성공 기준 (99.5% 가동률)
│
├─ scripts/                      # 인프라 자동화 스크립트
│  ├─ check-infrastructure.sh   # 헬스 체크
│  ├─ cost-optimizer.py         # 비용 모니터링
│  ├─ build-game.sh             # 게임 빌드
│  └─ deploy.sh                 # 배포
│
├─ reports/                      # 주간/월간 리포트
│  ├─ weekly-health.md          # "우리 인프라 정상인가?"
│  │  ├─ 가동률 (99.8% ✅)
│  │  ├─ 응답시간 (1.2s ✅)
│  │  └─ 에러율 (0.2% ✅)
│  │
│  ├─ weekly-cost.md            # "API 비용이 얼마나 들었나?"
│  │  ├─ Gemini: $45
│  │  ├─ Claude: $3
│  │  └─ 합계: $48 (예산 $200 내)
│  │
│  └─ monthly-summary.md        # 월간 요약
│
├─ configs/                      # 인프라 설정
│  ├─ openclaw-backup.json      # OpenClaw 설정 백업
│  └─ ci-cd-config.yaml         # GitHub Actions 설정
│
└─ .cursorrules                 # 자동화 규칙
   ├─ Bash 스크립트 규칙
   ├─ Python 자동화 규칙
   └─ CI/CD 파이프라인 규칙

Ops Team의 역할:
  📌 Steve의 지시: "API 비용이 너무 높아"
  └─ Atlas가 추적: "Ops Lead, 비용 분석 요청"
     └─ Ops Lead 대응:
        ├─ cost-optimizer.py 실행
        ├─ 모델별 사용량 분석
        └─ 최적화 제안 (Gemini Flash 비중 증가)

Ops Team Lead의 책임:
  ✅ 일일: 헬스 체크 (5분)
           - openclaw status
           - 에러 로그 확인
           - API 비용 확인
  
  ✅ 주간: 헬스 리포트, 비용 리포트, 모델 버전 검증
  
  ✅ 월간: 비용 트렌드 분석, 개선 계획 수립, API 키 로테이션
```

---

### 8️⃣ project-management/ (멀티프로젝트 PM 추적)

```
project-management/
├─ README.md                    # PM 구조 & 역할 설명
│
├─ MASTER_ROADMAP.md            # 🎯 "우리가 어디로 가는가?" (Steve의 전략)
│  ├─ 2026 전체 목표
│  ├─ 각 프로젝트별 마일스톤
│  └─ 우선순위 정렬
│
├─ roadmap/
│  ├─ game-development-roadmap.md        # 게임 개발 장기 계획
│  │  ├─ Phase 1~5 타임라인
│  │  ├─ 각 Phase의 목표
│  │  └─ 의존성 (어떤 걸 먼저 해야 함)
│  │
│  └─ content-operations-roadmap.md     # 콘텐츠 운영 장기 계획
│     ├─ 월별 목표
│     ├─ 채널별 전략
│     └─ KPI 정의
│
├─ sprints/                      # 📅 "이번 주 우리 목표는?"
│  ├─ 2026-W08-sprint.md        # Week 8 (Feb 17-23)
│  │  ├─ Game Team: "Phase 3 ATB 구현"
│  │  ├─ Content Team: "블로그 3개 글 게시"
│  │  ├─ Ops Team: "인프라 헬스 체크"
│  │  └─ 예상 비용: $70
│  │
│  ├─ 2026-W09-sprint.md        # Week 9 (Feb 24-Mar 2)
│  │  └─ ...
│  │
│  └─ archive/                   # 지난 스프린트들
│     ├─ 2026-W06-sprint.md
│     └─ 2026-W07-sprint.md
│
├─ tasks/                        # 📋 "누가 뭘 하고 있나?" (Kanban)
│  ├─ BACKLOG.md                # "나중에 할 것들"
│  │  ├─ Game: "[ID] Enemy AI 구현 (1주)"
│  │  ├─ Content: "[ID] YouTube 채널 개설 (3월)"
│  │  └─ Ops: "[ID] 모니터링 대시보드 구축 (4월)"
│  │
│  ├─ IN_PROGRESS.md            # "지금 하고 있는 것"
│  │  ├─ Game: "[ID] CardDatabase.gd (진행률 60%)"
│  │  ├─ Content: "[ID] 블로그 글 #3 (검수 중)"
│  │  └─ Ops: "[ID] 비용 최적화 분석 (완료)"
│  │
│  └─ DONE.md                   # "완료된 것들" (주간 아카이브)
│     ├─ Game: "[ID] CombatManager.gd 기본 구조"
│     ├─ Content: "[ID] 블로그 글 #1, #2 게시"
│     └─ Ops: "[ID] 모델 설정 수정"
│        (매주 아카이브 → 2026-W08-DONE.md 등)
│
└─ reports/                      # 📊 "우리가 잘하고 있나?" (리포트)
   ├─ 2026-02-weekly-report.md  # 주간 리포트 (금요일 작성)
   │  ├─ 완료: CombatManager 구현 시작, 블로그 3개 게시
   │  ├─ 문제: Rendering 성능 이슈
   │  ├─ 다음주: Enemy AI 구현 시작
   │  └─ 비용: $68 (예산 $200 내)
   │
   ├─ 2026-02-monthly-report.md # 월간 리포트 (월말 작성)
   │  ├─ KPI 달성도
   │  ├─ 비용 추이
   │  ├─ 위험도 평가
   │  └─ 다음달 계획
   │
   └─ reports-template.md        # 리포트 템플릿 (복사해서 쓰기)
      ├─ 주간 리포트 템플릿
      └─ 월간 리포트 템플릿

project-management의 역할:
  🎯 "전체 프로젝트가 예정대로 진행되고 있나?"
  
  Steve가 보는 것:
    ├─ MASTER_ROADMAP: "올해 우리 목표 맞나?"
    ├─ roadmaps/: "장기 계획이 현실적인가?"
    ├─ sprints/: "이번 주 목표 달성할 건가?"
    ├─ tasks/: "누가 뭘 하고 있나?"
    └─ reports/: "우리가 잘하고 있나? (KPI 달성도)"
  
  Atlas가 하는 것:
    ├─ 매일: IN_PROGRESS.md 업데이트
    ├─ 주말: DONE.md 정리, 주간 리포트 작성
    └─ 월말: 월간 리포트 작성
  
  Team Lead이 하는 것:
    ├─ 스프린트 계획 수립
    ├─ 태스크 생성 & 관리
    ├─ 진행 상황 보고
    └─ 다음주 계획 수립
```

---

### 9️⃣ build/ (빌드 산출물, Git 제외)

```
build/
└─ output/                       # 최종 빌드 결과
   ├─ dream-collector.apk       # Android 앱
   ├─ dream-collector.ipa       # iOS 앱
   └─ dream-collector-web.html  # 웹 버전 (향후)

목적:
  🎯 게임 빌드 결과물 보관
  ⚠️ .gitignore에 등록 (용량이 크므로)
  🔄 CI/CD로 자동 생성

누가 언제 생성하나?
  ✅ Ops Team: CI/CD 파이프라인으로 자동 생성
  ✅ Developer: 로컬 테스트용 빌드
  ✅ Release: 배포 전 검증용 빌드
```

---

### 🔟 .config/ (개발 환경 설정, Git 제외)

```
.config/
├─ .env                         # ⚠️⚠️⚠️ 민감 정보! 절대 Git에 커밋하지 말 것!
│  ├─ GEMINI_API_KEY=...       # Google API 키
│  ├─ CLAUDE_API_KEY=...       # Anthropic API 키
│  ├─ TISTORY_TOKEN=...        # 블로그 토큰
│  └─ (개인별로 다름)
│
├─ .cursor/                     # Cursor IDE 설정
│  ├─ rules/                    # Cursor 규칙 파일들
│  │  ├─ 00-project-overview.mdc     # 프로젝트 전체 규칙
│  │  ├─ 01-coding-standards.mdc    # 코딩 표준
│  │  ├─ 02-tistory-selenium.mdc    # 블로그 자동화 규칙
│  │  └─ 03-game-dev.mdc            # 게임 개발 규칙
│  └─ settings.json             # Cursor 사용자 설정
│
├─ .cursorrules                 # Cursor 글로벌 규칙 (프로젝트 루트)
│  └─ (모든 파일에 적용되는 규칙)
│
├─ __pycache__/                 # Python 컴파일 캐시 (자동 생성)
│  └─ (수정 금지, 자동으로 생성됨)
│
├─ .venv/                       # Python 가상환경 (선택사항)
│  └─ (python3 -m venv .config/.venv)
│
└─ README.md                    # 환경 설정 가이드
   ├─ "환경변수 어떻게 설정하지?"
   ├─ "Python 가상환경 설정"
   ├─ "API 키 어디서 구하지?"
   └─ "팀원들과 설정을 공유하지 않는 방법"

목적:
  🎯 로컬 개발 환경 설정 (공유하지 않음)
  ⚠️ .gitignore에 등록 (민감정보, 자동생성파일 등)
  🔄 각 팀원이 별도로 설정해야 함

설정 방법:
  1. cp .config/.env.example .config/.env  # 템플릿 복사
  2. .config/.env 에 API 키 입력
  3. python3 -m venv .config/.venv          # 가상환경 생성
  4. source .config/.venv/bin/activate     # 가상환경 활성화

주의사항:
  ❌ .env를 Git에 커밋하면 안됨!
  ❌ .cursor/ 설정도 민감할 수 있음 (.gitignore 확인)
  ✅ .gitignore에 제대로 등록되어 있는지 항상 확인
```

---

## 📊 전체 구조 한눈에 보기

```
geekbrox/                              # 프로젝트 루트
│
├─ [설정 & 문서] README.md, requirements.txt, .gitignore, LICENSE
│
├─ [에이전트] agents/atlas/           # Atlas PM (팀 관리)
│
├─ [자동화] frameworks/blog_automation/   # 반복 사용 가능한 솔루션
│
├─ [스크립트] scripts/                # 자동화 실행 (run_atlas.sh, run_post.sh)
│
├─ [문서] docs/                       # 기술 가이드, 매뉴얼, 참고자료
│
├─ [자산] resources/                  # 공유 이미지, 벤치마킹 자료
│
├─ [프로젝트] teams/                  # 각 팀이 실제 일하는 곳
│  ├─ game/
│  │  └─ dream-collector/workspace/ (design, godot, art)
│  ├─ content/
│  │  └─ blog/ (posts, drafts, published)
│  └─ ops/
│     ├─ scripts/ (헬스체크, 비용 모니터링)
│     └─ reports/ (주간/월간 리포트)
│
├─ [추적] project-management/         # 전체 진행 상황
│  ├─ MASTER_ROADMAP (전략)
│  ├─ roadmap/ (장기 계획)
│  ├─ sprints/ (주간 목표)
│  ├─ tasks/ (태스크 추적)
│  └─ reports/ (성과 리포트)
│
├─ [빌드] build/output/               # 게임 빌드 결과물 (Git 제외)
│
└─ [설정] .config/                    # 환경변수, IDE 설정 (Git 제외)
   ├─ .env (API 키, 민감정보)
   ├─ .cursor/ (Cursor IDE 규칙)
   └─ .cursorrules (글로벌 규칙)
```

---

## 🎯 사용 사례

### 사례 1: 새로운 팀원이 입사했을 때

```
1. 이 파일(PROJECT_STRUCTURE.md) 읽기
2. README.md 읽기
3. teams/[자신의팀]/README.md 읽기
4. .config/README.md로 환경 설정
5. 자신의 첫 태스크 받기
```

### 사례 2: 게임 개발을 시작할 때

```
1. teams/game/README.md 읽기 (Game Team 구조)
2. teams/game/dream-collector/workspace/design/ 읽기 (기획)
3. .config/.cursor/rules/ 읽기 (개발 규칙)
4. teams/game/dream-collector/workspace/godot/ 에서 Godot 열기
5. Game Lead로부터 첫 태스크 받기
```

### 사례 3: 블로그 글을 작성할 때

```
1. teams/content/README.md 읽기 (Content Team 구조)
2. docs/guides/BLOG_POSTING_UPDATE.md 읽기 (포스팅 프로세스)
3. Content Lead로부터 글 주제 & 마감 받기
4. teams/content/blog/posts/ 에 마크다운 작성
5. Content Lead 검수 후 게시
```

### 사례 4: 인프라 문제 해결할 때

```
1. teams/ops/README.md 읽기 (Ops Team 구조)
2. docs/manuals/OPENCLAW_REPAIR.md 읽기 (트러블슈팅)
3. teams/ops/scripts/check-infrastructure.sh 실행
4. teams/ops/reports/weekly-health.md 확인
5. Ops Lead에게 상황 보고
```

---

## 🔑 핵심 요점 정리

### 폴더를 선택할 때의 판단 기준

| 작업 | 폴더 | 이유 |
|------|------|------|
| API 키 저장 | .config/.env | 민감정보는 숨긴다 |
| 게임 코드 작성 | teams/game/dream-collector/workspace/godot/ | 게임별로 분리 |
| 블로그 글 작성 | teams/content/blog/posts/ | 콘텐츠별로 분리 |
| 게임 기획 문서 작성 | teams/game/dream-collector/workspace/design/ | 게임 기획은 게임 폴더에 |
| 자동화 스크립트 | frameworks/ 또는 teams/ops/scripts/ | 재사용 가능하면 frameworks/ |
| 기술 가이드 작성 | docs/guides/ | 팀이 공유하는 지식 |
| 개발 일지 작성 | teams/game/workspace/design/05_development_tracking/ | 진행 상황 추적 |
| 프로젝트 진행률 | project-management/tasks/ | 전체 팀이 보는 곳 |

### 각 팀이 가야 할 경로

```
🎮 Game Team → teams/game/dream-collector/workspace/
📝 Content Team → teams/content/blog/
🔧 Ops Team → teams/ops/
```

### 정보를 찾을 때의 순서

```
1. 내 팀 README (teams/[team]/README.md)
2. 프로젝트 README (teams/[team]/[project]/README.md)
3. 기술 가이드 (docs/guides/)
4. 트러블슈팅 (docs/manuals/)
5. 참고자료 (resources/ 또는 docs/references/)
```

---

## 📌 마지막 조언

- 🎯 **명확한 목적**: 각 폴더는 명확한 목적이 있습니다
- 🗂️ **자가 설명적**: 폴더 이름만으로 역할을 알 수 있습니다
- 📖 **README가 길잡이**: 각 폴더의 README.md를 먼저 읽으세요
- 🔄 **확장 가능**: 새 프로젝트/팀이 추가될 때도 같은 패턴을 따릅니다
- 💬 **명확한 커뮤니케이션**: 파일명, 폴더명이 명확하면 혼란이 줄어듭니다

---

**마지막 업데이트**: 2026-02-27 by Atlas  
**다음 검토**: 새로운 팀/프로젝트 추가시
