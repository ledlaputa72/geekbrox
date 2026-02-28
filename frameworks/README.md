# 🔄 Frameworks - 자동화 및 반복 솔루션

이 폴더는 **반복적으로 사용될 자동화 프레임워크와 솔루션**을 포함합니다.

## 📂 구조

```
frameworks/
└── blog_automation/           # ✅ 현재 운영 중
    ├── README.md             # 프레임워크 개요
    ├── MANUAL.md             # 텔레그램 봇 사용 설명서
    ├── run_post.sh           # 봇 실행 스크립트 ⭐
    ├── scripts/              # Python 자동화 스크립트
    │   ├── content_team_bot.py
    │   ├── fetch_anime.py
    │   ├── generate_post.py
    │   ├── post_to_tistory.py
    │   └── share_to_sns.py
    ├── templates/            # 포스팅 템플릿
    └── output/               # 자동화 결과물 (Git 제외)
        ├── images/
        ├── posts/
        └── shared_state.json
```

### `blog_automation/`
- **목적**: 블로그 포스팅 자동화 (Tistory 기반)
- **사용**: 콘텐츠 운영팀 (teams/content/)
- **파이프라인**: 자료조사 → 글 생성 → 초안 검수 → 포스팅
- **실행**: `./frameworks/blog_automation/run_post.sh`
- **조작**: Telegram 봇 (MANUAL.md 참고)
- **비용**: API 크레딧 절약 (1/10 비용 절감)

## 빠른 시작

### 블로그 봇 실행
```bash
./frameworks/blog_automation/run_post.sh
```

### 텔레그램으로 조작
```
/start → 1️⃣ 블로그 제작 → 자료조사 → 글 생성 → 검수 → 포스팅
```

## 향후 확장

- `game_automation/` - 게임 빌드 & 배포 자동화
- `content_automation/` - 다양한 콘텐츠 생성 자동화
- `report_automation/` - 주간/월간 보고서 자동 생성

---

**관련 문서:**
- 블로그 상세 가이드: [blog_automation/MANUAL.md](./blog_automation/MANUAL.md)
- 콘텐츠 팀 워크플로우: [teams/content/workspace/](../teams/content/workspace/)
- 자동화 기술 가이드: [project-management/guides/BLOG_POSTING_UPDATE.md](../project-management/guides/BLOG_POSTING_UPDATE.md)

**Last Updated**: 2026-02-28 by Atlas (scripts 폴더 통합, README 추가)
