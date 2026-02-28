# 🌟 GeekBrox - 독립 게임 & 콘텐츠 개발 플랫폼

**GeekBrox**는 인디 게임 개발과 콘텐츠 운영을 효율적으로 관리하는 통합 플랫폼입니다. OpenClaw 기반 AI 에이전트와 자동화 프레임워크로 팀 생산성을 극대화합니다.

---

## 📂 프로젝트 구조

```
geekbrox/
├── 📖 README.md (이 파일)
├── ⚙️  requirements.txt            # Python 의존성
│
├── 🤖 agents/                      # AI 에이전트 설정
│   └── atlas/                      # 프로젝트 매니저 에이전트
│       ├── atlas_bot.py
│       └── ATLAS_MANUAL.md
│
├── 🔄 frameworks/                  # 반복 자동화 프레임워크
│   └── blog_automation/            # 블로그 자동화 시스템
│
├── 🔧 scripts/                     # 유틸리티 스크립트
│   ├── run_atlas.sh
│   └── run_post.sh
│
├── 📚 docs/                        # 프로젝트 문서
│   ├── guides/                     # 기술 가이드 & 프로세스
│   ├── manuals/                    # 도구 매뉴얼
│   ├── references/                 # 참고자료
│   └── game_planning/              # 초기 게임 기획
│
├── 📦 resources/                   # 공유 자산 & 참고자료
│   ├── img/                        # 이미지 자산
│   └── references/                 # 외부 참고 자료
│
├── 👥 teams/                       # 개별 프로젝트 (팀별)
│   ├── game/                       # 게임 개발 프로젝트
│   │   ├── dream-collector/        # Dream Collector 게임
│   │   │   ├── workspace/
│   │   │   │   ├── design/         # 게임 디자인 문서
│   │   │   │   ├── godot/          # Godot 게임 코드
│   │   │   │   └── art/            # 게임 에셋
│   │   │   └── (향후 프로젝트)
│   │   └── (향후 게임)
│   │
│   ├── content/                    # 콘텐츠 운영 프로젝트
│   │   └── blog/                   # 블로그 자동화 프로젝트
│   │
│   └── ops/                        # 운영 및 인프라
│
├── 📊 project-management/          # PM 추적 (멀티프로젝트)
│   ├── MASTER_ROADMAP.md           # 전체 프로젝트 로드맵
│   ├── sprints/                    # 주간 스프린트 계획
│   ├── tasks/                      # 태스크 추적
│   └── reports/                    # 주간/월간 보고서
│
├── 🔨 build/                       # 빌드 산출물 (Git 제외)
│   └── output/                     # 최종 빌드 결과
│
├── ⚙️  .config/                    # 개발 환경 설정 (Git 제외)
│   ├── .env                        # 환경변수 (민감 정보)
│   ├── .cursor/                    # Cursor IDE 설정
│   ├── .claude/                    # Claude IDE 설정
│   ├── .cursorrules                # Cursor 규칙
│   ├── __pycache__/                # Python 캐시
│   └── .venv/                      # Python 가상환경 (선택)
│
├── 🔐 .git/                        # Git 저장소
├── 🚫 .gitignore                   # Git 제외 파일
└── 📋 LICENSE                      # 라이선스
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

### 에이전트 실행

```bash
# Atlas PM 에이전트 실행
./scripts/run_atlas.sh

# 블로그 포스팅 자동화 실행
./scripts/run_post.sh
```

### 프로젝트 문서 탐색

- **게임 개발**: `teams/game/dream-collector/workspace/design/`
- **프로젝트 관리**: `project-management/MASTER_ROADMAP.md`
- **기술 가이드**: `docs/guides/`
- **에이전트 매뉴얼**: `agents/atlas/ATLAS_MANUAL.md`

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

**2026-02-27 - 폴더 구조 대정리** 🎯
- ✅ 모든 파일을 목적별로 분류
  - `agents/` - AI 에이전트 설정
  - `frameworks/` - 자동화 프레임워크
  - `docs/` - 기술 문서
  - `scripts/` - 유틸리티 스크립트
  - `resources/` - 공유 자산
  - `.config/` - 개발 환경 설정 (숨김)
  - `build/` - 빌드 산출물
- ✅ Dream Collector 개발 추적 통합
  - `teams/game/workspace/design/dream-collector/05_development_tracking/`
- ✅ 폴더별 README 작성
- ✅ .gitignore 업데이트

---

**관리자**: Steve PM  
**PM Agent**: Atlas  
**마지막 업데이트**: 2026-02-27
