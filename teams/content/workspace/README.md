# 콘텐츠 팀 워크스페이스

**팀명**: Content Operations Team  
**팀장**: Lee.C (Gemini 2.5 Pro)  
**프로젝트**: 블로그 자동화, SNS 콘텐츠 관리

---

## 📂 폴더 구조

```
workspace/
├── README.md                       # ← 이 파일
├── blog/                          # 블로그 프로젝트
│   ├── posts/                     # 게시된 글 (Markdown)
│   ├── drafts/                    # 작성 중인 글
│   ├── published/                 # 게시 완료 기록
│   └── README.md                  # 블로그 프로젝트 가이드
├── sns/                           # SNS 관리
├── youtube/                       # YouTube 콘텐츠 (향후)
├── memory/                        # 팀 메모리 (daily logs)
│
├── roadmap/                       # 콘텐츠 팀 장기 로드맵 ⭐
│   └── content-operations-roadmap.md
│
├── sprints/                       # 콘텐츠 팀 스프린트 계획 ⭐
│   └── 2026-W08-sprint-content.md
│
├── guides/                        # 콘텐츠 팀 기술 가이드 ⭐
│   └── BLOG_POSTING_UPDATE.md
│
└── [팀 설정 파일들]
    ├── AGENTS.md, SOUL.md, USER.md, etc.
```

---

## 🎯 주요 문서

| 문서 | 목적 |
|------|------|
| **blog/** | 블로그 포스팅 관리 |
| **sns/** | SNS 콘텐츠 관리 |
| **roadmap/** | 콘텐츠 팀 장기 로드맵 (팀 관리용) |
| **sprints/** | 주간 스프린트 계획 (팀 관리용) |
| **guides/** | 블로그 포스팅 & 자동화 가이드 |

---

## 🚀 현재 프로젝트

### 블로그 자동화 (Tistory)
- **자동화**: frameworks/blog_automation/
- **상태**: 운영 중
- **주간 목표**: 3회 게시 (애니 리뷰, 개발일지, 업계 분석)

---

## 📋 팀 역할

| 역할 | 담당자 | 책임 |
|------|--------|------|
| **팀장** | Lee.C | 콘텐츠 기획, 블로그 정책 결정 |
| **콘텐츠 AI** | Claude Code | 블로그 글 자동 생성 |
| **자동화** | Telegram Bot | 자료조사, 포스팅, SNS 배포 |

---

## 🔄 블로그 자동화 워크플로우

```
1️⃣ 자료조사 (fetch_anime.py)
   ↓
2️⃣ 글 생성 (generate_post.py + Claude)
   ↓
3️⃣ 초안 검수 (Lee.C 승인)
   ↓
4️⃣ 포스팅 (post_to_tistory.py)
   ↓
5️⃣ SNS 배포 (share_to_sns.py)
   ↓
✅ Tistory & SNS 게시 완료
```

**실행 방법**:
```bash
./frameworks/blog_automation/run_post.sh
```

---

## 📖 관련 문서

**조직 구조:**
- [project-management/TEAM_WORKFLOWS.md](../../project-management/TEAM_WORKFLOWS.md) - 팀장 역할 정의
- [project-management/PROJECT_STRUCTURE.md](../../project-management/PROJECT_STRUCTURE.md) - 전체 폴더 가이드

**자동화:**
- [frameworks/blog_automation/README.md](../../frameworks/blog_automation/README.md) - 블로그 자동화 개요
- [frameworks/blog_automation/MANUAL.md](../../frameworks/blog_automation/MANUAL.md) - 텔레그램 봇 사용법

**프로젝트 관리:**
- [project-management/MASTER_ROADMAP.md](../../project-management/MASTER_ROADMAP.md) - 전체 프로젝트 로드맵

---

**Last Updated**: 2026-02-28 by Atlas  
**팀 PM**: Lee.C (Gemini 2.5 Pro)
