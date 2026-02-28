# 📝 콘텐츠팀 스타트업 가이드 (30분)

> 새로운 콘텐츠팀 멤버를 위한 30분 온보딩

---

## 📋 30분 안에 해야 할 일

### ⏱️ 0-5분: 팀 이해하기
```
Team Lead: Lee.C (Gemini 2.5 Pro - AI)
프로젝트: 블로그 자동화 (Tistory) + SNS 운영
현재 상태: 주 3회 블로그 글 게시 중
목표: 월 50개 글 (자동화로 효율화)
```

### ⏱️ 5-10분: 폴더 이해하기

```
teams/content/
├── workspace/           ← 팀 문서 & 기획
│   ├── blog/           (블로그 프로젝트)
│   │   ├── posts/      (게시된 글)
│   │   ├── drafts/     (작성 중 글)
│   │   └── TONE_GUIDE.md (글쓰기 톤 가이드)
│   ├── sns/            (SNS 관리)
│   ├── guides/         (블로그 가이드)
│   └── roadmap/        (팀 로드맵)
│
└── frameworks/blog_automation/ (공용 자동화)
    ├── MANUAL.md               (봇 사용 설명)
    ├── run_post.sh             (봇 실행 스크립트)
    └── output/                 (생성된 글 & 이미지)
```

### ⏱️ 10-15분: 문서 읽기

**필수 (지금 읽으세요):**
1. [`teams/content/README.md`](../README.md) - 팀 구조 & 역할
2. [`teams/content/workspace/README.md`](./workspace/README.md) - 폴더 가이드
3. [`frameworks/blog_automation/MANUAL.md`](../../frameworks/blog_automation/MANUAL.md) - 봇 사용법

**강력 추천:**
4. [`teams/content/workspace/guides/BLOG_POSTING_UPDATE.md`](./workspace/guides/BLOG_POSTING_UPDATE.md) - 블로그 가이드
5. [`WORKFLOW_INTEGRATION.md`](../../WORKFLOW_INTEGRATION.md) - 워크플로우

### ⏱️ 15-20분: 봇 설정

```bash
# 1. 블로그 자동화 봇 실행
cd ~/Projects/geekbrox
./frameworks/blog_automation/run_post.sh

# 2. Telegram에서 봇 시작
# @geekbrox_bot 또는 우측 상단 /start

# 3. 봇 인터페이스 확인
# 1️⃣ 블로그 제작 → 자료조사 → 글생성 → 검수 → 포스팅
```

### ⏱️ 20-25분: Team Lead 지시 받기

```
Lee.C가 Telegram에서 지시할 때까지 대기

예: "이번 주 3개 블로그 글:
     1. 게임 리뷰
     2. 인디 게임 트렌드
     3. 개발 일지
     
     봇으로 자료조사 → 글생성 → 내가 검수 → 자동 포스팅"

→ 지시를 받으면 시작!
```

### ⏱️ 25-30분: 첫 번째 작업 시작

```
1. 봇 인터페이스에서 1️⃣ 블로그 제작 선택
2. 주제 선택 (게임 리뷰, 트렌드 분석, 기술 글 등)
3. 1-1 🔍 자료조사 → 30초 대기 (웹 스크래핑)
4. 1-2 ✍️ 글 생성 → 3분 대기 (Claude AI)
5. 1-3 📋 초안 검수 → 수정 사항 있으면 입력
6. 1-4 🚀 포스팅 → 자동으로 Tistory 게시
```

---

## 🎯 첫 번째 작업 체크리스트

Team Lead가 지시했을 때:

- [ ] 지시사항을 3번 읽었다
- [ ] TONE_GUIDE.md를 읽었다 (글쓰기 톤)
- [ ] 주제가 명확하다
- [ ] 봇을 성공적으로 실행했다
- [ ] 첫 번째 글을 만들고 있다

---

## 💬 소통 방법

### Telegram (Team Lead ↔ 라이터)

**받을 지시:**
```
"이번 주 3개 글:
 1. 게임 리뷰
 2. 인디 게임 트렌드
 3. 개발 일지
 
 봇으로 자료조사 → 글생성 → 검수 → 포스팅"
```

**해야 할 보고:**
```
✅ 완료: "게임 리뷰 글 게시 완료: [블로그 링크]"
🔄 진행중: "인디 게임 트렌드 초안 생성 중, 내일 게시"
🛑 블로커: "AI 글이 너무 일반적입니다. 수정 지시를 원합니다."
```

---

## 🔀 기본 워크플로우

```
1. Telegram에서 지시 받기
   "이번 주 주제: 게임 리뷰"
   ↓
2. 봇 실행 (@geekbrox_bot)
   ↓
3. 1️⃣ 블로그 제작 선택
   ↓
4. 1-1 🔍 자료조사 (자동, 30초)
   ↓
5. 1-2 ✍️ 글 생성 (자동, 3분)
   ↓
6. 1-3 📋 초안 검수 (당신)
   - 내용이 맞나?
   - 톤이 맞나?
   - 수정 필요?
   ↓
7. 1-4 🚀 포스팅 (자동)
   ↓
8. Telegram에 완료 보고
   "게임 리뷰 글 게시 완료: [링크]"
   ↓
9. 다음 주제 대기
```

---

## 📁 중요 파일 위치

| 파일 | 위치 | 용도 |
|------|------|------|
| **봇 실행** | `./frameworks/blog_automation/run_post.sh` | 텔레그램 봇 시작 |
| **봇 사용법** | `frameworks/blog_automation/MANUAL.md` | 봇 명령어 가이드 |
| **글쓰기 톤** | `teams/content/workspace/blog/TONE_GUIDE.md` | 글 톤 일관성 |
| **게시된 글** | `teams/content/workspace/blog/posts/` | 과거 글 참고 |
| **가이드** | `teams/content/workspace/guides/BLOG_POSTING_UPDATE.md` | 블로그 전략 |

---

## ❓ 문제 해결

### 문제: "봇이 안 켜져요"
**해결:**
```bash
cd ~/Projects/geekbrox
./frameworks/blog_automation/run_post.sh

# 또는
python frameworks/blog_automation/scripts/content_team_bot.py
```

### 문제: "어떤 톤으로 글을 써야 하나요?"
**해결:**
```
TONE_GUIDE.md를 읽으세요!
teams/content/workspace/blog/TONE_GUIDE.md
```

### 문제: "AI가 만든 글이 마음에 안 들어요"
**해결:**
```
봇 1-3 📋 초안 검수 단계에서 수정 지시를 입력하면
AI가 수정된 버전을 다시 생성합니다.

예: "더 casual한 톤으로 다시 작성해주세요"
```

### 문제: "블로그에 어떤 글을 올려야 하나요?"
**해결:**
```
Team Lead (Lee.C)에게 Telegram에서 주제를 받으세요
또는 teams/content/workspace/roadmap/content-operations-roadmap.md 확인
```

---

## 📊 성공 기준

### 일일 기준
- ✅ 할당된 주제의 자료조사 완료
- ✅ AI 초안 생성 완료
- ✅ 초안 검수 & 피드백 입력

### 주간 기준
- ✅ 목표 글 개수 게시 (예: 3개)
- ✅ TONE_GUIDE 준수
- ✅ SEO 키워드 포함

### 월간 기준
- ✅ 목표 글 개수 (예: 50개)
- ✅ 블로그 트래픽 증가
- ✅ 독자 만족도 유지

---

## 🎯 다음 30분

1. **지금**: 이 문서 읽기 ✅
2. **다음**: `teams/content/README.md` 읽기
3. **그다음**: `frameworks/blog_automation/MANUAL.md` 읽기
4. **마지막**: 봇 실행 & 첫 글 만들기

---

**준비 완료? 이제 시작하세요! 🚀**

**Last Updated:** 2026-02-28  
**Status:** ✅ READY TO ONBOARD
