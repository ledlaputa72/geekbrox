# ⚡ 5분 퀵스타트 가이드

> 처음 GeekBrox에 온 사람들을 위한 5분 안에 프로젝트를 이해하는 가이드

---

## 🎯 GeekBrox가 뭐예요?

**GeekBrox** = 인디 게임 + 콘텐츠 관리 플랫폼

- 🎮 **꿈 수집가(Dream Collector)** - 로그라이크 덱빌딩 RPG 개발 중
- 📝 **블로그 자동화** - Tistory 애니메이션 블로그 운영 중
- 🤖 **AI 기반 관리** - OpenClaw AI 에이전트(Atlas)가 프로젝트 관리

---

## 👥 팀 구조 (한눈에)

```
Steve (PM - 의사결정)
  ↓
Atlas (AI PM - 자동화/추적)
  ↓
┌─────────────────────────────────┐
│                                 │
Kim.G (Game)    Lee.C (Content)    Park.O (Ops)
게임팀장         콘텐츠팀장         운영팀장
(Gemini 2.5Pro) (Gemini 2.5Pro)   (Gemini 2.5Pro)
  ↓                ↓                 ↓
Cursor IDE      Claude Code      OpenClaw
```

---

## 📂 루트 폴더 (딱 4개)

```
geekbrox/
├── agents/              🤖 AI 에이전트 (Atlas PM)
├── frameworks/          🔄 공용 자동화 (블로그 자동화)
├── project-management/  📊 전체 조직 관리 (전략/로드맵)
└── teams/               👥 팀별 프로젝트
    ├── game/           🎮 게임 개발팀
    ├── content/        📝 콘텐츠팀
    └── ops/            🔧 운영팀
```

---

## 🚀 당신의 역할별 시작하기

### 🎮 게임 개발자라면?
```
1. teams/game/README.md 읽기 (팀 구조 이해)
2. teams/game/workspace/README.md 읽기 (폴더 구조)
3. teams/game/workspace/planning/PHASE3_NEXT_TASKS.md 읽기 (현재 진행 상황)
4. teams/game/workspace/development/GODOT_UI_WORKFLOW.md 읽기 (개발 방법)
5. Cursor IDE로 teams/game/godot/dream-collector/ 열기
```

**Team Lead가 지시할 때:**
- "CardDatabase.gd 작성하세요" → Cursor에서 구현 → PR 생성
- issues 발생하면 Team Lead에 알림

---

### 📝 콘텐츠 라이터라면?
```
1. teams/content/README.md 읽기 (팀 구조 이해)
2. teams/content/workspace/README.md 읽기 (폴더 구조)
3. frameworks/blog_automation/README.md 읽기 (자동화 방법)
4. frameworks/blog_automation/MANUAL.md 읽기 (봇 사용법)
5. Telegram에서 /start 명령으로 봇 제어
```

**작업 흐름:**
- Telegram 봇 → 1️⃣ 자료조사 → 2️⃣ 글 생성 → 3️⃣ 검수 → 4️⃣ 포스팅

---

### 🔧 운영/QA 담당자라면?
```
1. teams/ops/README.md 읽기 (팀 구조 이해)
2. teams/ops/workspace/README.md 읽기 (폴더 구조)
3. teams/ops/workspace/sprints/2026-W08-sprint-ops.md 읽기 (이번 주 일정)
4. 해당 작업 폴더로 이동 (qa/, testing/, research/)
```

---

### 👤 프로젝트 관리자라면?
```
1. project-management/README.md 읽기 (전체 구조)
2. project-management/TEAM_WORKFLOWS.md 읽기 (팀 역할)
3. project-management/MASTER_ROADMAP.md 읽기 (전략)
4. 각 팀의 workspace/roadmap/ 확인 (팀별 진행)
```

---

## 💬 커뮤니케이션 채널

| 목적 | 채널 | 대상 |
|------|------|------|
| **일일 지시** | Telegram (@steve) | 개발팀 ↔ Steve |
| **PR & 코드** | GitHub | Cursor/Claude 코드 리뷰 |
| **블로그 봇** | Telegram 봇 (@geekbrox_bot) | 콘텐츠팀 |
| **에이전트** | Telegram (@atlas) | Atlas PM ↔ Steve |

---

## 📋 중요 파일 (꼭 읽으세요!)

### 🔴 **필수 (모든 팀원)**
1. **[WORKFLOW_INTEGRATION.md](./WORKFLOW_INTEGRATION.md)** ⭐ ← 먼저 읽으세요!
   - Telegram-Cursor-Claude 워크플로우
   - 어떻게 서로 연결되어 있는지

### 🟠 **강력 추천 (당신의 역할에 따라)**
2. 팀 README: `teams/[game|content|ops]/README.md`
3. 팀 워크스페이스: `teams/[team]/workspace/README.md`

### 🟡 **참고 (필요할 때)**
4. `project-management/PROJECT_STRUCTURE.md` - 전체 폴더 지도
5. `project-management/WORKSPACE_CONVENTIONS.md` - 파일 명명 규칙

---

## 🎯 오늘 할 일

### 게임 개발 (Kim.G 팀)
- [ ] Phase 3 현황 확인: `PHASE3_NEXT_TASKS.md`
- [ ] 이번 주 스프린트: `teams/game/workspace/sprints/2026-W08-sprint.md`
- [ ] 다음 태스크 받기: Team Lead에게 지시 대기

### 콘텐츠 (Lee.C 팀)
- [ ] 이번 주 블로그 주제 확인: `sprints/2026-W08-sprint-content.md`
- [ ] 자동화 봇 실행: `./frameworks/blog_automation/run_post.sh`
- [ ] 텔레그램 봇으로 첫 번째 글 만들기

### 운영 (Park.O 팀)
- [ ] 이번 주 일정 확인: `sprints/2026-W08-sprint-ops.md`
- [ ] 담당 작업 폴더로 이동 (qa/, research/, testing/)
- [ ] 월간 예산 상태 확인

### 모든 팀
- [ ] **[WORKFLOW_INTEGRATION.md](./WORKFLOW_INTEGRATION.md) 읽기**
- [ ] 당신의 팀 README 읽기
- [ ] Slack/Telegram 채널 확인

---

## ❓ 자주 묻는 질문

**Q. 내가 뭘 해야 하나요?**
A. Team Lead가 Telegram에서 지시해줍니다. 예: "CardDatabase.gd 작성하세요"

**Q. PR은 어떻게 만드나요?**
A. Cursor IDE → 코드 작성 → GitHub PR 생성 → Team Lead 리뷰 → 병합

**Q. Cursor vs Claude Code는 뭔가요?**
A. Cursor는 IDE (코드 편집), Claude Code는 AI 도구 (자동화)

**Q. 블로그 글은 어떻게 게시되나요?**
A. Telegram 봇 → 자료조사 → AI 글생성 → 검수 → 자동 포스팅

---

## 🔗 다음 단계

1. **[WORKFLOW_INTEGRATION.md](./WORKFLOW_INTEGRATION.md) 읽기** ← 이제 이걸 읽으세요!
2. 당신의 팀 폴더로 가기
3. Team Lead의 첫 지시 받기
4. 당신의 첫 작업 시작하기

---

**마지막 팁:** 헷갈리면 언제든지 **프로젝트 관리자(Steve/Atlas)**에게 물어보세요!

**Last Updated:** 2026-02-28  
**Status:** ✅ READY TO START
