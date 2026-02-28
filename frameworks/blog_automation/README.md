# 블로그 자동화 프레임워크

**PURPOSE**: 블로그 포스팅 전체 파이프라인 (자료조사 → 초안생성 → 포스팅) 자동화

**STATUS**: ✅ 운영 중 (GeekBrox 애니메이션 블로그)

---

## 📂 폴더 구조

```
blog_automation/
├── README.md                    # ← 이 파일
├── MANUAL.md                    # 텔레그램 봇 사용 설명서
├── run_post.sh                  # 봇 실행 스크립트
│
├── scripts/                     # Python 자동화 스크립트들
│   ├── content_team_bot.py     # 텔레그램 봇 메인 (UI 제어)
│   ├── fetch_anime.py          # 애니 정보 자동 수집 (Web Scraping)
│   ├── generate_post.py        # 블로그 글 자동 생성 (Claude API)
│   ├── post_to_tistory.py     # Tistory 자동 포스팅 (API)
│   └── share_to_sns.py         # SNS 자동 공유 (향후)
│
├── templates/                   # 글 작성 템플릿
│   └── anime_post_template.md  # 애니 리뷰 포스트 템플릿
│
└── output/                      # 자동화 결과물 (Git 제외)
    ├── images/                 # 생성된 이미지들
    ├── posts/                  # 생성된 블로그 글 (Markdown)
    └── shared_state.json       # 상태 추적 파일
```

---

## 🚀 빠른 시작

### 1. 사전 준비

```bash
# 의존성 설치
pip install -r requirements.txt

# 환경변수 설정 (.env 파일)
# .config/.env 참고
```

### 2. 봇 실행

```bash
# 프로젝트 루트에서 실행
./frameworks/blog_automation/run_post.sh
```

### 3. 텔레그램 봇으로 제어

```
텔레그램에서 /start 입력
→ 1️⃣ 블로그 제작 클릭
→ 1-1 🔍 자료조사 (자동 수집)
→ 1-2 ✍️ 글 생성 (Claude 작성)
→ 1-3 📋 초안 확인 (검수)
→ 1-4 🚀 포스팅 실행 (Tistory 게시)
```

---

## 📋 각 스크립트 역할

| 파일 | 역할 | 실행 방식 |
|------|------|---------|
| **content_team_bot.py** | 텔레그램 UI 제어 | run_post.sh 로 시작 |
| **fetch_anime.py** | 웹 스크래핑 (애니 정보 수집) | 봇에서 호출 |
| **generate_post.py** | Claude API (글 자동 생성) | 봇에서 호출 |
| **post_to_tistory.py** | Tistory API (블로그 게시) | 봇에서 호출 |
| **share_to_sns.py** | SNS 자동 공유 (계획) | - |

---

## 📊 자동화 파이프라인

```
[텔레그램 봇 버튼 클릭]
           ↓
    [봇 명령 처리]
           ↓
    1️⃣ 자료조사 (fetch_anime.py)
           ↓
    2️⃣ 글 생성 (generate_post.py)
           ↓
    3️⃣ 초안 검수 (MANUAL.md 참고)
           ↓
    4️⃣ 포스팅 (post_to_tistory.py)
           ↓
    ✅ Tistory 블로그 게시 완료
```

---

## 💾 상태 추적

모든 작업 상태는 `output/shared_state.json` 에서 추적됩니다:

```json
{
  "last_run": "2026-02-28T14:30:00",
  "total_posts_generated": 142,
  "total_posts_posted": 138,
  "failed_posts": [],
  "api_credit_usage": {
    "fetch_anime": 5.2,
    "generate_post": 45.8,
    "post_to_tistory": 0.5
  }
}
```

---

## 🔄 환경변수 설정

`.config/.env` 에서 다음을 설정하세요:

```bash
# Telegram
TELEGRAM_BOT_TOKEN=your_token_here
TELEGRAM_CHAT_ID=your_chat_id_here

# Claude
CLAUDE_API_KEY=your_key_here

# Tistory
TISTORY_BLOG_NAME=your_blog
TISTORY_API_TOKEN=your_token_here

# Web Scraping
USER_AGENT=Mozilla/5.0 (...)
```

---

## 📖 상세 문서

- **텔레그램 봇 사용법**: [MANUAL.md](./MANUAL.md)
- **템플릿 커스터마이징**: [templates/](./templates/)
- **스크립트 수정 방법**: 각 스크립트 주석 참고

---

## 🐛 문제 해결

**봇이 시작되지 않습니다**
```bash
# 의존성 확인
pip list | grep python-telegram

# 환경변수 확인
cat .config/.env | grep TELEGRAM
```

**포스팅 실패**
```bash
# 로그 확인
tail -f frameworks/blog_automation/output/last_run_debug.txt

# Tistory API 토큰 갱신
# (TISTORY_API_TOKEN 설정 다시 확인)
```

---

**관련 문서:**
- 프로젝트 관리: [project-management/](../../project-management/)
- 콘텐츠 팀: [teams/content/workspace/](../../teams/content/workspace/)

**Last Updated**: 2026-02-28 by Atlas (scripts 폴더 통합)
