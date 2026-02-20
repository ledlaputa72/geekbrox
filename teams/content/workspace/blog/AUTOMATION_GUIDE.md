# GeekBrox 블로그 자동화 시스템

## 🎌 일본 애니메이션 콘텐츠 자동 생성

### 시스템 구조

```
blog-automation/
├── scripts/           # 자동화 스크립트
│   ├── fetch-anime.js      # AniList/MAL API 데이터 수집
│   ├── analyze-trends.js   # Google Trends 분석
│   ├── generate-post.js    # 블로그 글 생성
│   └── publish-tistory.js  # 티스토리 포스팅
├── templates/         # 글 템플릿
├── data/             # 수집된 데이터 저장
└── output/           # 생성된 글 저장
```

## 필요한 설정

### API Keys 필요:
1. **AniList API** - https://anilist.gitbook.io/anilist-apiv2-docs/
   - GraphQL API (인증 필요 없음, rate limit 있음)
   
2. **MyAnimeList API** - https://myanimelist.net/apiconfig
   - Client ID 필요
   
3. **Google Trends** - https://www.npmjs.com/package/google-trends-api
   - API 키 불필요 (비공식 라이브러리)
   
4. **Tistory API** - https://www.tistory.com/guide/api/manage/register
   - App 등록 필요
   - Access Token 필요

### 이미지 소스:
- AniList API (공식 포스터)
- Unsplash API (무료 이미지)
- Pixabay API (무료 이미지)

## 자동화 일정

- **실행 주기:** 매일 오전 9시 (PST)
- **발행 방식:** 초안 생성 → 검토 → 자동 발행

## 상태: 🔴 설정 필요

**다음 단계:**
1. Tistory API 등록 및 인증
2. MAL API 클라이언트 ID 발급
3. 스크립트 작성 시작
