# GeekBrox 프로젝트 관리 (Root)

**소유자:** Steve PM  
**PM 에이전트:** Atlas  
**최종 업데이트:** 2026-02-28

---

## 📁 문서 구조

```
project-management/ [루트 레벨 - 전체 프로젝트 관리만]
│
├── README.md                           # 이 파일
│
├─ 📋 [조직 & 구조 - 전체 팀 관련]
├── MASTER_ROADMAP.md                   # 전체 프로젝트 마스터 로드맵
├── TEAM_WORKFLOWS.md                   # 모든 팀의 역할 & 워크플로우
├── ORGANIZATION_SUMMARY.md             # 조직 계층 및 팀 구조
├── PROJECT_STRUCTURE.md                # 전체 폴더 구조 가이드
├── WORKSPACE_CONVENTIONS.md            # 파일 명명 규칙 & 컨벤션
├── ONBOARDING.md                       # 새 팀원 3시간 온보딩
├── DAILY_REPORT.md                     # 일일 보고 템플릿
├── WEEKLY_REPORT.md                    # 주간 보고 템플릿
│
├─ 📂 [공용 자산]
├── manuals/                            # 공용 기술 매뉴얼
│   └── OPENCLAW_REPAIR.md             # OpenClaw 트러블슈팅 가이드
├── references/                         # 공용 참고자료
│   ├── Game System.pdf                # 게임 시스템 레퍼런스
│   └── game test.pdf                  # 게임 테스트 매뉴얼
│
├─ 🎯 [전체 프로젝트 추적]
├── tasks/                              # 전체 태스크 추적
│   ├── BACKLOG.md                     # 전체 백로그
│   ├── IN_PROGRESS.md                 # 진행 중 작업
│   └── DONE.md                        # 완료 작업
│
└─ 📈 [전체 리포트]
    └── reports/                        # 월간 전체 리포트만 유지
        └── 2026-02-monthly-report.md  # 월간 정산 보고

---

## 📍 팀별 문서 위치

**각 팀의 구조 & 업무 위임:**
- 🎮 **[teams/game/README.md](../teams/game/)** - 게임 팀 구조
- 📝 **[teams/content/README.md](../teams/content/)** - 콘텐츠 팀 구조  
- 🔧 **[teams/ops/README.md](../teams/ops/)** - 운영 팀 구조

**각 팀의 워크스페이스 (로드맵, 스프린트, 가이드):**
- 🎮 **[teams/game/workspace/](../teams/game/workspace/)** 
  - roadmap/: game-development-roadmap.md
  - sprints/: 2026-W08-sprint.md
  - guides/: CODE_REVIEW.md
  
- 📝 **[teams/content/workspace/](../teams/content/workspace/)**
  - roadmap/: content-operations-roadmap.md
  - sprints/: 2026-W08-sprint-content.md
  - guides/: BLOG_POSTING_UPDATE.md
  
- 🔧 **[teams/ops/workspace/](../teams/ops/workspace/)**
  - sprints/: 2026-W08-sprint-ops.md

---

## 🎯 프로젝트 개요

### 활성 프로젝트

1. **게임 개발** 🎮
   - 프로젝트명: "꿈 수집가 (Dream Collector)"
   - 상태: Pre-Production (GDD 완료)
   - 타임라인: 2026년 2월 ~ 2027년 Q3

2. **콘텐츠 운영** 📝
   - 블로그 자동화 (Tistory)
   - SNS 관리
   - 유튜브 콘텐츠 (계획)

---

## 📊 관리 방법론

### 스프린트 사이클
- **주간 스프린트** (월요일 시작)
- 매주 금요일: 스프린트 리뷰 + 다음 주 계획
- 매월 말: 월간 회고 및 로드맵 조정

### 우선순위 시스템
- 🔴 **P0 (Critical):** 즉시 처리 필요
- 🟠 **P1 (High):** 이번 주 완료
- 🟡 **P2 (Medium):** 이번 달 완료
- 🟢 **P3 (Low):** 백로그

### 상태 라벨
- ⏳ **TODO:** 시작 전
- 🚧 **IN PROGRESS:** 진행 중
- ⏸️ **BLOCKED:** 차단됨
- ✅ **DONE:** 완료
- ❌ **CANCELLED:** 취소됨

---

## 🔄 일일 워크플로우

### Atlas (PM) 역할
1. **아침 (09:00):** 오늘의 작업 확인 및 우선순위 정렬
2. **진행 중:** 팀장 에이전트들과 작업 조율
3. **저녁 (18:00):** 일일 진행 상황 요약 및 내일 계획

### Steve와의 동기화
- **주간 계획 회의:** 매주 월요일
- **스프린트 리뷰:** 매주 금요일
- **임시 동기화:** 필요시 언제든

---

## 📖 빠른 링크

- [마스터 로드맵](./MASTER_ROADMAP.md)
- [현재 스프린트](./sprints/2026-W08-sprint.md)
- [진행 중 작업](./tasks/IN_PROGRESS.md)
- [백로그](./tasks/BACKLOG.md)

---

## 🤖 에이전트 역할

### Atlas (PM)
- 전체 프로젝트 조율
- 일정 관리 및 리포팅
- 리소스 할당
- 의사결정 지원

### Content 팀장 📝
- 블로그 포스팅 실행
- SNS 콘텐츠 관리
- 콘텐츠 일정 관리

### Game 팀장 🎮
- 게임 개발 실무
- 프로토타입 제작
- 개발 진행 관리

### Ops 팀장 🏢
- 시장 조사
- 재무 관리
- QA 및 릴리스

---

_관리 by Atlas | GeekBrox Project Management System_
