# GeekBrox 블로그 자동화 시스템 (v2.0)

## 🎌 일본 애니메이션 콘텐츠 자동 생성

### 시스템 구조

```
blog_automation/
├── scripts/
│   ├── fetch_anime.py        # AniList API → 시즌 Top 10 수집 (anilist_id 포함)
│   ├── generate_post.py      # 다중 API → 심층 블로그 글 생성 (v2.0)
│   ├── atlas_bot.py          # Telegram 봇 (원격 제어 인터페이스)
│   └── post_to_tistory.py    # Selenium → 티스토리 자동 포스팅
├── output/
│   ├── images/               # 다운로드된 이미지 (커버 + 포스터 + 스틸컷)
│   ├── posts/                # 생성된 .md 초안
│   └── seasonal_top_anime.json  # 수집된 애니 데이터
└── .env                      # API 키 환경변수
```

---

## 📡 사용 API 목록 (v2.0 확장)

### 1. AniList GraphQL API ⭐ (핵심 — 인증 불필요)
- **URL:** https://graphql.anilist.co
- **용도:** 시즌 Top 10 수집, 캐릭터/성우, 태그, 관련 작품, 추천, 트레일러 URL
- **인증:** 불필요 (공개 API, rate limit 있음)
- **주요 쿼리:**
  ```graphql
  # fetch_anime.py: 시즌별 인기 애니 Top 10
  query ($season, $seasonYear, $perPage)

  # generate_post.py: 상세 정보 (anilist_id 기반)
  query ($id: Int) → Media { studios, staff, characters, tags, trailer, externalLinks }
  ```
- **환경변수:** 불필요

### 2. TMDB (The Movie Database) ⭐ (이미지 핵심)
- **URL:** https://api.themoviedb.org/3
- **용도:** 공식 포스터/스틸컷 이미지 (최대 5개), 한국어 줄거리, TMDB 평점, 트레일러
- **인증:** API 키 필요
- **주요 엔드포인트:**
  ```
  GET /search/tv?query={제목}&language=ko-KR
  GET /tv/{id}?language=ko-KR&append_to_response=images,videos
  이미지: https://image.tmdb.org/t/p/w780/{file_path}
  ```
- **환경변수:** `TMDB_API_KEY`
- **발급:** https://www.themoviedb.org/documentation/api
- **이미지 정책:** TMDB 이미지는 상업적 블로그에 사용 가능 (출처 표기 권장)

### 3. YouTube Data API v3 (트레일러 링크)
- **URL:** https://www.googleapis.com/youtube/v3
- **용도:** 공식 PV/트레일러 검색 → 링크 임베드
- **인증:** API 키 필요
- **주요 엔드포인트:**
  ```
  GET /search?q={제목} official trailer PV&type=video&maxResults=3
  ```
- **환경변수:** `YOUTUBE_API_KEY`
- **발급:** https://console.cloud.google.com → YouTube Data API v3 활성화
- **쿼터:** 1일 10,000 units (검색 1회 = 100 units → 하루 100회 검색 가능)

### 4. Reddit API (해외 팬 반응)
- **URL:** https://www.reddit.com/r/anime/search.json
- **용도:** r/anime 인기 글 수집 → 해외 팬 반응 섹션
- **인증:** 공개 JSON API (인증 없이 read-only 가능)
- **환경변수:** `REDDIT_CLIENT_ID`, `REDDIT_CLIENT_SECRET` (선택 — 없어도 기본 동작)
- **주의:** `User-Agent` 헤더 필수 (`GeekBrox/1.0`)

### 5. Claude Sonnet API (글 생성 — 1차)
- **환경변수:** `ANTHROPIC_API_KEY`
- **모델:** `claude-sonnet-4-5-20250929`
- **max_tokens:** 8,192 (확장 글 생성용)

### 6. Gemini 2.5 Flash API (글 생성 — Fallback)
- **환경변수:** `GOOGLE_API_KEY`
- **발급:** https://aistudio.google.com/apikey

---

## 🔧 .env 파일 설정

```env
# LLM
ANTHROPIC_API_KEY=sk-ant-...
GOOGLE_API_KEY=AIza...

# 미디어 API (v2.0 신규)
TMDB_API_KEY=...
YOUTUBE_API_KEY=AIza...
REDDIT_CLIENT_ID=...          # 선택
REDDIT_CLIENT_SECRET=...      # 선택

# 블로그
TISTORY_BLOG_NAME=geekbrox
TISTORY_EMAIL=...
TISTORY_PASSWORD=...

# 텔레그램
TELEGRAM_BOT_TOKEN=...
TELEGRAM_CHAT_ID=...
```

---

## 📋 글 생성 파이프라인 (v2.0)

```
1. fetch_anime.py 실행
   └── AniList GraphQL → Top 10 수집 (anilist_id 포함)
   └── output/seasonal_top_anime.json 저장

2. generate_post.py 실행 (애니 1개당)
   ├── TMDB 검색 → 포스터 + 스틸컷 이미지 (최대 5개) 다운로드
   ├── AniList 상세 조회 → 캐릭터/성우/태그/추천
   ├── YouTube 검색 → 공식 PV 링크
   ├── Reddit 검색 → r/anime 팬 반응
   ├── 이미지 5개 수집 (cover, poster, still1, still2, still3)
   └── Claude/Gemini → 심층 블로그 글 생성 (2,000자+, 이미지 5개 삽입)
   └── output/posts/{slug}.md 저장

3. atlas_bot.py (Telegram 제어)
   ├── 🔍 자료조사 → fetch_anime.py 실행
   ├── ✍️ 글 생성 → generate_post.py 실행
   ├── 📋 초안 확인 → posts/ 파일 목록
   ├── 🔄 초안 수정 → generate_post.py --revise
   └── 🚀 포스팅 → post_to_tistory.py 실행

4. post_to_tistory.py
   └── Selenium → 티스토리 자동 업로드
```

---

## 🖼️ 이미지 수집 전략

| 이미지 키 | 소스 | 위치 | 용도 |
|----------|------|------|------|
| `cover` | AniList 커버 이미지 | 글 상단 | 첫인상/썸네일 |
| `poster` | TMDB 공식 포스터 | 기본 정보 직후 | 작품 아이덴티티 |
| `still1` | TMDB 스틸컷 1 | 스토리 직후 | 세계관 시각화 |
| `still2` | TMDB 스틸컷 2 | 볼거리 직후 | 볼거리 강조 |
| `still3` | TMDB 스틸컷 3 또는 포스터2 | 총평 직전 | 마무리 임팩트 |

**TMDB 없을 경우 폴백:**
- poster → AniList cover 재사용
- still1/2/3 → 없는 경우 해당 슬롯 생략

---

## 📊 현재 상태 (2026-02-21)

| 항목 | 상태 |
|------|------|
| AniList API | ✅ 운영 중 |
| Claude Sonnet | ✅ 운영 중 |
| Gemini Fallback | ✅ 운영 중 |
| Tistory Selenium | ✅ 운영 중 |
| Telegram Bot | ✅ 운영 중 |
| **TMDB API** | 🔑 API 키 발급 필요 |
| **YouTube Data API** | 🔑 API 키 발급 필요 |
| **Reddit API** | ✅ 공개 API 사용 가능 (인증 없이) |

---

## 자동화 일정
- **실행 주기:** 텔레그램 봇 수동 트리거 (또는 cron 설정 가능)
- **발행 목표:** 일 1건
- **초안 검토:** Telegram에서 미리보기 후 수동 승인

---
_Last updated: 2026-02-21 (v2.0 — TMDB + YouTube + Reddit 연동)_
