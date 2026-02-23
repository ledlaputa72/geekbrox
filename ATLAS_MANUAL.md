# Atlas 총괄 PM 봇 — 사용 매뉴얼

> **Atlas**는 GeekBrox 프로젝트의 총괄 PM 봇입니다.
> 텔레그램 버튼으로 3개 팀(콘텐츠팀, 게임개발팀, 운영팀) 전체를 통합 관리합니다.

---

## 조직 구조

```
Steve (텔레그램 명령)
    ↓
🚀 Atlas (atlas_bot.py) — 총괄 PM
    ├── 1️⃣ 전체 현황    →  project-management/ 파싱
    ├── 2️⃣ 📝 콘텐츠팀  →  blog_automation/scripts/ 실행
    ├── 3️⃣ 🎮 게임개발팀 →  teams/game/workspace/ 파일 읽기
    ├── 4️⃣ 🏢 운영팀    →  teams/ops/workspace/ 파일 읽기
    └── 5️⃣ ⚙️ 관리 도구 →  작업 기록, 충돌 관리, 메시지 전달
```

> **참고:** 콘텐츠팀 전용 봇(`blog_automation/scripts/content_team_bot.py`)은 독립적으로도 운영 가능합니다. Atlas는 그 상위 봇으로, 콘텐츠팀 기능을 포함합니다.

---

## 목차

1. [빠른 시작](#1-빠른-시작)
2. [봇 실행 방법](#2-봇-실행-방법)
3. [계층식 버튼 메뉴 전체 구조](#3-계층식-버튼-메뉴-전체-구조)
4. [각 메뉴 상세 설명](#4-각-메뉴-상세-설명)
5. [텍스트 입력 명령어](#5-텍스트-입력-명령어)
6. [슬래시 명령어](#6-슬래시-명령어)
7. [AI 크레딧 절약 설계](#7-ai-크레딧-절약-설계)
8. [환경변수 설정](#8-환경변수-설정env)
9. [자주 묻는 질문](#9-자주-묻는-질문-faq)

---

## 1. 빠른 시작

### 프로젝트 전체 현황 확인

```
① /start → 홈 메뉴
② 1️⃣ 전체 현황
③ 1-1 📊 프로젝트 대시보드
→ 3개 팀 KPI 요약 + 우선순위 작업 수 표시
```

### 블로그 글 발행

```
① /start → 홈 메뉴
② 2️⃣ 콘텐츠팀
③ 2-2 🔍 자료조사 → 확인 → 완료 대기
④ 2-3 ✍️ 글 생성 → 확인 → 완료 대기
⑤ 2-4 📋 초안 목록 → 내용 확인
⑥ 2-5 🚀 포스팅 실행 → 확인 → Tistory 게시
```

### 게임 개발 현황 확인

```
① /start → 홈 메뉴
② 3️⃣ 게임개발팀
③ 3-1 📊 프로젝트 현황
→ PROJECT_STATE.md 내용 표시
```

---

## 2. 봇 실행 방법

### 사전 준비

```bash
# 프로젝트 루트에서
pip install python-telegram-bot>=20.0 python-dotenv
```

### `.env` 파일 설정 (프로젝트 루트)

```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
TELEGRAM_CHAT_ID=your_chat_id_here       # 선택 (보안)
```

### 봇 시작

```bash
# 프로젝트 루트 (geekbrox/) 에서 실행
python3 atlas_bot.py
```

### 봇 종료

터미널에서 `Ctrl+C`

### 서버 상시 실행 (선택)

```bash
# pm2 예시
pm2 start "python3 atlas_bot.py" --name atlas-bot
pm2 save

# 또는 tmux
tmux new -s atlas
python3 atlas_bot.py
```

---

## 3. 계층식 버튼 메뉴 전체 구조

```
🏠 홈 — Atlas 총괄 PM
│
├── 1️⃣  전체 현황
│   ├── 1-1  📊 프로젝트 대시보드
│   │         → 콘텐츠 발행 N/100 편
│   │         → 게임팀 현재 Phase
│   │         → P0/P1 작업 수
│   │         → 3-Way 공유 상태
│   ├── 1-2  📋 이번 주 스프린트 현황
│   │         → project-management/sprints/ 최신 파일
│   ├── 1-3  ⚠️  우선순위 작업 목록
│   │         → tasks/IN_PROGRESS.md (P0/P1 항목)
│   └── 1-4  🔄 3-Way 공유 상태
│             → Claude Code ↔ Cursor AI ↔ 봇 현황
│
├── 2️⃣  📝 콘텐츠팀
│   ├── 2-1  📈 블로그 현황
│   │         → 발행 완료/초안/이미지 수 + Rate Limit 상태
│   ├── 2-2  🔍 자료조사 실행
│   │         → fetch_anime.py 실행 (AniList Top 10 수집)
│   ├── 2-3  ✍️  글 생성 실행
│   │         → generate_post.py 실행 (Claude/Gemini)
│   ├── 2-4  📋 초안 목록
│   │         → drafts/ 폴더 목록 (최대 8개)
│   │         → 각 초안: [보기] [✏️ 수정] [🗑 삭제]
│   └── 2-5  🚀 Tistory 포스팅 실행
│             → post_to_tistory.py 실행 (Selenium)
│
├── 3️⃣  🎮 게임개발팀
│   ├── 3-1  📊 프로젝트 현황
│   │         → teams/game/workspace/PROJECT_STATE.md
│   ├── 3-2  📐 GDD 목록
│   │         → teams/game/workspace/design/ .md 목록
│   ├── 3-3  🎯 컨셉 현황
│   │         → design/CONCEPT.md 내용
│   └── 3-4  📅 마일스톤 & 기한
│             → project-management/MASTER_ROADMAP.md
│
├── 4️⃣  🏢 운영및사업팀
│   ├── 4-1  🔬 리서치 현황
│   │         → teams/ops/workspace/research/ 폴더 구조
│   ├── 4-2  💰 유료화 & 마케팅 현황
│   │         → monetization/ 폴더 내 문서 목록
│   └── 4-3  📊 KPI 대시보드
│             → MASTER_ROADMAP.md KPI 섹션 파싱
│
└── 5️⃣  ⚙️  관리 도구
    ├── 5-1  📝 오늘의 작업 기록
    │         → 텍스트 입력 → DAILY_REPORT.md 추가
    ├── 5-2  🚨 충돌 확인 & 해제
    │         → shared_state.py 충돌 목록 + 해제 버튼
    ├── 5-3  💬 팀 메시지 전달
    │         → [Claude Code에게] [Cursor AI에게] 선택
    │         → 텍스트 입력 → shared_state.json 저장
    └── 5-4  📖 도움말
              → 버튼 메뉴 전체 구조 안내
```

모든 하위 메뉴에는 **🏠 홈** 버튼이 있어 언제든지 홈으로 돌아올 수 있습니다.

---

## 4. 각 메뉴 상세 설명

### 1️⃣ 전체 현황

| 버튼 | 데이터 소스 | 표시 내용 |
|------|-----------|---------|
| **1-1 대시보드** | 여러 파일 통합 | 3팀 KPI 요약 한눈에 |
| **1-2 스프린트** | `project-management/sprints/*.md` | 이번 주 목표 및 진행률 |
| **1-3 우선순위** | `project-management/tasks/IN_PROGRESS.md` | P0/P1 작업 전체 목록 |
| **1-4 3-Way 공유** | `shared_state.json` | Claude/Cursor 현재 작업 상태 |

### 2️⃣ 콘텐츠팀

| 버튼 | 실행 방식 | 소요 시간 |
|------|---------|---------|
| **2-1 블로그 현황** | 파일 수 직접 카운트 | 즉시 |
| **2-2 자료조사** | `fetch_anime.py` 실행 | 30초~1분 |
| **2-3 글 생성** | `generate_post.py` 실행 | 1~3분 |
| **2-4 초안 목록** | `drafts/` 폴더 직접 읽기 | 즉시 |
| **2-5 포스팅** | `post_to_tistory.py` 실행 | 2~5분 |

#### 초안 수정 방법
1. **2-4 초안 목록** → 해당 초안 **✏️ 수정** 버튼
2. 텔레그램에 수정 지시문 입력 (예: `도입부 더 흥미롭게, SEO 키워드 유지`)
3. Claude가 초안을 자동 재작성

### 3️⃣ 게임개발팀

| 버튼 | 데이터 소스 |
|------|-----------|
| **3-1 프로젝트 현황** | `teams/game/workspace/PROJECT_STATE.md` |
| **3-2 GDD 목록** | `teams/game/workspace/design/*.md` |
| **3-3 컨셉 현황** | `teams/game/workspace/design/CONCEPT.md` |
| **3-4 마일스톤** | `project-management/MASTER_ROADMAP.md` |

### 4️⃣ 운영및사업팀

| 버튼 | 데이터 소스 |
|------|-----------|
| **4-1 리서치 현황** | `teams/ops/workspace/research/` 폴더 구조 |
| **4-2 유료화 & 마케팅** | `teams/ops/workspace/monetization/` |
| **4-3 KPI 대시보드** | `project-management/MASTER_ROADMAP.md` KPI 섹션 |

### 5️⃣ 관리 도구

| 버튼 | 기능 |
|------|------|
| **5-1 오늘의 작업 기록** | 텍스트 입력 → `DAILY_REPORT.md` append |
| **5-2 충돌 확인 & 해제** | Claude/Cursor 동시 편집 충돌 확인 및 해제 |
| **5-3 메시지 전달** | Claude Code / Cursor AI에게 텍스트 메시지 전달 |
| **5-4 도움말** | 버튼 메뉴 전체 안내 |

---

## 5. 텍스트 입력 명령어

> ⚠️ **Atlas 봇은 버튼 제어 중심입니다.** 아래 5가지 외 일반 텍스트는 응답하지 않습니다.

| 입력 형식 | 기능 | 예시 |
|----------|------|------|
| `메모: [내용]` | 공유 메모 저장 | `메모: 오늘 GDD 컨셉 D 결정` |
| `note: [내용]` | 위와 동일 (영문) | `note: blog post delayed` |
| `인증완료` | 카카오 인증 완료 알림 | `인증완료` |
| **수정 지시문** | ✏️ 수정 버튼 클릭 후 다음 입력 | `서론을 더 흥미롭게 바꿔줘` |
| **작업 기록** | 5-1 버튼 클릭 후 다음 입력 | `GDD v2 완성, 블로그 3편 발행` |

---

## 6. 슬래시 명령어

| 명령어 | 기능 |
|--------|------|
| `/start` | 봇 시작, 홈 메뉴 열기 |
| `/menu` | 홈 메뉴 열기 |
| `/help` | 도움말 메뉴 |
| `/?` | 도움말 메뉴 (단축) |

---

## 7. AI 크레딧 절약 설계

| 동작 | AI 호출 여부 | 설명 |
|------|------------|------|
| 버튼 클릭 (메뉴 이동, 현황 조회) | ❌ 없음 | 파일 읽기만 수행 |
| 자료조사 (fetch_anime.py) | ❌ 없음 | AniList API 호출 |
| 글 생성 (generate_post.py) | ✅ Claude/Gemini | 1회 호출 |
| 초안 수정 지시 | ✅ Claude | 수정 시 1회 호출 |
| 포스팅 (post_to_tistory.py) | ❌ 없음 | Selenium 자동화 |
| 현황 조회 (게임팀/운영팀) | ❌ 없음 | Markdown 파일 파싱 |

### Rate Limit 방지
- 글 간 딜레이: 기본 30초 (`INTER_POST_DELAY` 설정)
- 순차 큐 처리: 여러 작업 동시 실행 방지
- API 호출 횟수 모니터링: **2-1 블로그 현황**에서 확인

---

## 8. 환경변수 설정 (.env)

```env
# 텔레그램 필수 설정
TELEGRAM_BOT_TOKEN=1234567890:ABCdef...    # BotFather에서 발급
TELEGRAM_CHAT_ID=987654321                 # 본인 chat_id (보안용, 선택)

# Rate Limit 설정
INTER_POST_DELAY=30          # 글 간 딜레이(초), 기본 30

# LLM API (글 생성 시 사용)
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_API_KEY=AIza...

# 미디어 API (자료조사 시 사용)
TMDB_API_KEY=...
YOUTUBE_API_KEY=AIza...

# Tistory (포스팅 시 사용)
TISTORY_BLOG_NAME=geekbrox
```

---

## 9. 자주 묻는 질문 (FAQ)

**Q. Atlas 봇과 content_team_bot.py 의 차이는?**

| | Atlas (`atlas_bot.py`) | 콘텐츠팀 봇 (`content_team_bot.py`) |
|---|---|---|
| 위치 | 프로젝트 루트 | `blog_automation/scripts/` |
| 역할 | 3개 팀 통합 PM 봇 | 콘텐츠팀 블로그 전용 봇 |
| 게임팀/운영팀 현황 | ✅ 있음 | ❌ 없음 |
| 블로그 기능 | ✅ 있음 (상위 호출) | ✅ 있음 (직접 실행) |

→ **일반적으로는 Atlas 봇 하나만 실행하면 됩니다.**

---

**Q. 텍스트를 입력했는데 응답이 없어요.**

정상입니다. Atlas는 버튼 제어 중심으로 설계되어, 인식할 수 없는 텍스트는 무시합니다.
`/start` 로 홈 메뉴를 열어 버튼으로 조작하세요.

---

**Q. 게임팀 현황에서 파일 없음이 뜨면?**

`teams/game/workspace/PROJECT_STATE.md` 파일이 없는 경우입니다.
게임개발팀 Claude 에이전트가 해당 파일을 관리합니다.

---

**Q. 포스팅 중 카카오 인증이 떠요.**

Selenium 자동화 중 카카오 2차 인증이 요청되면:
1. 본인 기기에서 카카오 인증 완료
2. 텔레그램에 `인증완료` 입력
3. 봇이 인증 완료를 감지하고 포스팅 계속 진행

---

**Q. 충돌이 발생했어요.**

Claude Code와 Cursor AI가 동시에 같은 파일을 편집하면 충돌이 발생합니다.
**5️⃣ 관리 도구 → 5-2 충돌 확인 & 해제** 버튼으로 해제하세요.

---

## 텔레그램에서 도움말 보기

봇 실행 중 언제든지:

```
/help 또는 /? → 도움말 메뉴 표시
```

또는

```
5️⃣ 관리 도구 → 5-4 도움말
```

---

*마지막 업데이트: 2026-02-21*
*Atlas 총괄 PM 봇 v1.0*
