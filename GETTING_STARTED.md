# 🚀 GeekBrox 시작하기

> 새로운 팀원? 이 문서부터 시작하세요.

---

## 📍 당신은 여기서부터 시작합니다

```
┌─────────────────────────────────┐
│   YOU ARE HERE                  │
│                                 │
│  👉 이 문서를 읽고 있습니다     │
└────────┬────────────────────────┘
         │
         ↓
   ┌─────────────┐
   │ 5분 투자     │
   │             │
   │ QUICK_START │  ← 프로젝트 개요 파악
   │    .md      │
   └──────┬──────┘
          │
          ↓
   ┌──────────────────┐
   │ 15분 투자         │
   │                  │
   │ WORKFLOW_        │  ← 일하는 방식 이해
   │ INTEGRATION.md   │    (⭐ 가장 중요!)
   └────────┬─────────┘
            │
            ↓
   ┌────────────────────┐
   │ 30분 투자           │
   │                    │
   │ 당신의 팀           │  ← 팀별 시작 가이드
   │ TEAM_STARTUP.md    │    선택 1개
   └────────┬───────────┘
            │
            ├─→ teams/game/TEAM_STARTUP.md
            ├─→ teams/content/TEAM_STARTUP.md
            └─→ teams/ops/TEAM_STARTUP.md
            │
            ↓
   ┌────────────────────┐
   │ 준비 완료!         │
   │                    │
   │ Team Lead의        │
   │ 첫 지시 대기       │
   └────────────────────┘
```

---

## ⏱️ 50분만 투자하면 완전히 준비됩니다

| 단계 | 문서 | 시간 | 내용 |
|------|------|------|------|
| 1️⃣ | **QUICK_START.md** | 5분 | 프로젝트 개요, 팀 구조, 채널 안내 |
| 2️⃣ | **WORKFLOW_INTEGRATION.md** | 15분 | ⭐ 일하는 방식, 메시지 포맷, PR 절차 |
| 3️⃣ | **당신의 팀 STARTUP** | 30분 | 폴더 구조, 첫 작업, 체크리스트 |
| 🎯 | **Team Lead 지시 대기** | - | 첫 실제 작업 시작 |

---

## 👤 당신의 역할은?

### 🎮 게임 개발자?
→ **teams/game/TEAM_STARTUP.md** 읽기

```
1. Cursor IDE로 teams/game/godot/dream-collector/ 열기
2. CODE_REVIEW.md로 코드 스타일 확인
3. Team Lead의 지시 받기 (Telegram)
4. 첫 작업 시작!
```

### 📝 콘텐츠 라이터?
→ **teams/content/TEAM_STARTUP.md** 읽기

```
1. 블로그 자동화 봇 실행
2. Telegram 봇으로 1️⃣자료조사 → 2️⃣글생성 → 3️⃣검수 → 4️⃣포스팅
3. 매주 블로그 글 작성
```

### 🔧 운영/QA 담당자?
→ **teams/ops/TEAM_STARTUP.md** 읽기

```
1. QA_LOG.md로 버그 기록
2. test-plan으로 테스트 실행
3. 리포트 작성
```

### 👨‍💼 프로젝트 매니저?
→ **OPERATION_MANUAL.md** 읽기

```
1. 일일 운영 절차 이해 (08:00-19:00)
2. 주간 스프린트 관리
3. 월간 리포팅 템플릿 적용
```

---

## 🎯 50분 로드맵

### ⏱️ 0-5분: QUICK_START.md 읽기
```
지금 바로 열기:
👉 QUICK_START.md
```

**읽을 내용:**
- ✅ GeekBrox가 뭔지
- ✅ 팀 구조 (Steve → Atlas → Team Leads)
- ✅ 폴더 구조 (agents, frameworks, project-management, teams)
- ✅ 역할별 시작 가이드
- ✅ 채널 안내

### ⏱️ 5-20분: WORKFLOW_INTEGRATION.md 읽기
```
지금 바로 열기:
👉 WORKFLOW_INTEGRATION.md

⭐⭐⭐ 가장 중요한 문서입니다!
```

**읽을 내용:**
- ✅ Telegram-Cursor-Claude 3가지 도구의 연결
- ✅ 4단계 작업 프로세스 (지시 → 작업 → PR → 병합)
- ✅ Telegram 메시지 표준 포맷 (꼭 기억!)
- ✅ PR 생성 방법
- ✅ 일일 타이밍 (예상 08:00 지시, 11:00 PR, 15:00 병합)

**핵심:**
```
Team Lead 지시 (Telegram)
    ↓
당신: Cursor/봇에서 작업
    ↓
완료: GitHub PR 생성
    ↓
Team Lead: PR 리뷰 & 병합
    ↓
당신: Telegram으로 완료 보고
```

### ⏱️ 20-50분: 당신의 팀 TEAM_STARTUP.md 읽기

**선택 1개:**

#### 🎮 게임팀이면?
```
teams/game/TEAM_STARTUP.md 읽기

✅ Cursor IDE 설정
✅ teams/game/godot/dream-collector/ 폴더 이해
✅ CODE_REVIEW.md로 코드 스타일 학습
✅ 첫 작업 체크리스트 준비
```

#### 📝 콘텐츠팀이면?
```
teams/content/TEAM_STARTUP.md 읽기

✅ 블로그 봇 실행 방법
✅ frameworks/blog_automation/run_post.sh 확인
✅ 4단계 글 작성 프로세스 (자료조사→생성→검수→포스팅)
✅ TONE_GUIDE.md로 톤 통일
```

#### 🔧 운영팀이면?
```
teams/ops/TEAM_STARTUP.md 읽기

✅ QA/테스트/연구 역할 선택
✅ QA_LOG.md 기록 방법
✅ dream-collector-test-plan.md 확인
✅ 첫 작업 체크리스트 준비
```

---

## 📋 완성 체크리스트

준비가 완료되면:

```
[ ] QUICK_START.md 읽음 (5분)
[ ] WORKFLOW_INTEGRATION.md 읽음 (15분) ← 반드시!
[ ] 당신의 팀 TEAM_STARTUP.md 읽음 (30분)
[ ] 당신의 역할이 명확함
[ ] Team Lead의 지시를 받을 준비 완료
[ ] Telegram에서 첫 메시지 대기 중
```

모두 체크하셨나요? **축하합니다!** 이제 시작할 준비가 완료되었습니다! 🎉

---

## 🚨 가장 중요한 것

### ⭐ WORKFLOW_INTEGRATION.md는 반드시 읽어야 합니다

왜냐하면:
- ✅ 모든 팀이 같은 방식으로 일함
- ✅ Telegram 메시지 포맷이 정해져 있음
- ✅ PR 생성 절차가 정해져 있음
- ✅ 이것을 모르면 팀과 맞지 않음

---

## 💬 도움말

### 도움이 필요하신가요?

**"뭘 해야 하나요?"**
→ Team Lead (Kim.G, Lee.C, Park.O)에게 Telegram에서 물어보세요

**"파일을 못 찾았어요"**
→ 당신의 팀 TEAM_STARTUP.md의 "파일 위치" 테이블 확인

**"일하는 방식이 헷갈려요"**
→ WORKFLOW_INTEGRATION.md 다시 읽기

**"코드 스타일이 뭐예요?" (게임팀만)**
→ teams/game/workspace/guides/CODE_REVIEW.md 읽기

**"톤 가이드가 뭐예요?" (콘텐츠팀만)**
→ teams/content/workspace/blog/TONE_GUIDE.md 읽기

---

## 📚 전체 문서 맵

```
🏠 루트 (읽는 순서)
├── GETTING_STARTED.md ← 당신이 지금 읽는 문서
├── QUICK_START.md ← 1단계 (5분)
├── WORKFLOW_INTEGRATION.md ← 2단계 (15분) ⭐
│
👥 팀별 가이드 (3단계 - 30분)
├── teams/game/TEAM_STARTUP.md
├── teams/content/TEAM_STARTUP.md
└── teams/ops/TEAM_STARTUP.md

📊 참고 문서
└── project-management/OPERATION_MANUAL.md
```

---

## ⏳ 지금 바로 시작하세요!

```
1. 지금 이 창을 닫으세요
2. QUICK_START.md를 열어주세요 (5분)
3. 그 다음 WORKFLOW_INTEGRATION.md (15분)
4. 그 다음 당신의 팀 가이드 (30분)
5. Team Lead 지시 대기!
```

---

## ✅ 최종 확인

이 문서를 읽고 있다면:
- ✅ 올바른 시작 지점에 있습니다
- ✅ 50분 후 완전히 준비될 것입니다
- ✅ Team Lead가 당신을 도와줄 것입니다

**준비가 되셨나요?**

**→ QUICK_START.md를 열어주세요!**

---

**Last Updated:** 2026-02-28  
**Version:** 1.0  
**Status:** ✅ Ready for New Members
