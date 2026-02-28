# 📝 Content Team - 콘텐츠 운영 팀

**팀 PM**: Atlas  
**팀장 (Lead)**: Lee.C (Gemini 2.5 Pro)  
**현재 상태**: 블로그 자동화 시스템 운영 중

> **팀 문서 위치:**
> - 📂 **[teams/content/workspace/](./workspace/)** - 팀 워크스페이스 (로드맵, 가이드, 스프린트, 블로그 프로젝트)
> - 🔄 **[frameworks/blog_automation/](../../frameworks/blog_automation/)** - 공용 블로그 자동화 프레임워크

---

## 📊 팀 구조 및 업무 위임

```
Steve (PM)
  ↓
  └─ Atlas (팀 에이전트 PM)
      ↓ [경영진행 리뷰/승인]
      └─ Content Team Lead (팀장)
          ├─ Blog Content Writing (Claude Code)
          ├─ Blog Automation (Automation Scripts)
          └─ SNS & Marketing (Manual/Automation)
```

### 👤 역할 정의

| 역할 | 담당자 | 책임 | 보고 대상 |
|------|--------|------|---------|
| **Project Manager** | Steve | 콘텐츠 전략, 게시 일정, KPI 결정 | - |
| **Team Agent (PM)** | Atlas | 콘텐츠 일정 관리, 자동화 모니터링, 게시 진행 | Steve |
| **Team Lead (팀장)** | [지정 예정] | 콘텐츠 계획, 자동화 세팅, 품질 관리 | Atlas/Steve |
| **Content Writer** | Claude Code | 블로그 글 생성 (초안 → 최종) | Team Lead |
| **Blog Automation** | Scripts | 자동 게시, SNS 연동, 스케줄 관리 | Team Lead |
| **Quality Checker** | Team Lead | 최종 검수, 편집, 게시 승인 | Steve (보고) |

---

## 📋 업무 위임 프로세스

### Steve → Atlas → Team Lead → Writers/Automations

#### 1️⃣ **Steve (PM)의 지시**
```
예: "이번 주 3개 블로그 글 게시하자.
     주제: 게임 리뷰, 인디 게임 트렌드, 개발 일지
     목표: 월 15개 글 (월간 KPI)"

↓ Atlas가 받음
```

#### 2️⃣ **Atlas (팀 에이전트)**
- 콘텐츠 계획 파악: 주제, 일정, 자동화 프로세스
- 팀장에게 위임: "Content Team Lead, 3개 블로그 글 요청 들어왔습니다"
- 진행률 추적: 매일 게시 일정 확인
- 자동화 모니터링: Tistory 연동, SNS 배포 확인

```markdown
[Atlas의 데일리 리포트]

**Content Progress (2026-02-27)**
- Blog Posts Scheduled: 2/3
- Auto-posting Ready: 1/3
- SNS Distribution: ✅ 완료
- Issues: 없음
- Next: 마지막 글 1개 보완
```

#### 3️⃣ **Content Team Lead (팀장)**
- 콘텐츠 계획 수립: 주제 선정, 작가 할당, 일정 관리
- Claude Code에게 작성 지시:
  - "게임 리뷰 글 작성하세요 (1500자, 마크다운)"
  - "인디 게임 트렌드 분석 글 작성하세요"
  - "개발 일지 형식의 뒷이야기 글 작성하세요"
- 최종 검수: 문법, 링크, 이미지 확인
- 게시 승인: 자동화 스크립트 실행

```markdown
[Team Lead의 상태 보고]

**Daily Content Report (2026-02-28)**

Scheduled Posts:
- "Dream Collector 개발일지 #3" - ✅ 완성, 게시 대기
- "인디 게임 트렌드 2026" - 🔄 Claude Code 작성 중 (70%)
- "게임 리뷰: Elden Ring" - 🔄 Claude Code 작성 중 (50%)

Auto-posting:
- 첫 글 게시 예정: 2026-02-28 10:00 AM
- SNS 공유: ✅ 준비됨

Issues:
- "개발일지" 글에 스크린샷 3개 필요 (에셋 추가 요청)
```

#### 4️⃣ **Claude Code / Automation Scripts (콘텐츠 작성/자동화)**

**Claude Code (콘텐츠 작성):**
- 받은 지시: "Dream Collector 개발일지 블로그 글 작성"
- 작성 → 마크다운 파일 생성
- Team Lead 검수 → 수정 반영
- 최종 승인 후 자동화 스크립트에 전달

```markdown
# Dream Collector 개발일지 #3: Phase 3 전투 시스템 구현 시작

## 이번 주 작업 (2026-02-24 ~ 2026-02-28)

### 완료된 작업 ✅
- UI 12개 화면 완성
- 캐릭터 스프라이트 & 애니메이션 시스템
- Chroma Key 셰이더 구현

### 진행 중인 작업 🔄
- ATB 전투 시스템 설계
- CombatManager.gd 기본 구조

## 기술적 도전과제

ATB 시스템 구현 중 다음을 고려:
- 속도 기반 턴 시스템
- 카드 리소스 관리
- Enemy AI 로직

[... 본문 계속]
```

**Automation Scripts (자동 게시):**
- 받은 지시: "게시 준비된 마크다운 파일 Tistory에 게시"
- 자동으로:
  1. 마크다운 → HTML 변환
  2. Tistory API로 포스팅
  3. 예약 게시 설정
  4. SNS (트위터, 블루스카이) 자동 공유
  5. 결과 보고

```bash
#!/bin/bash
# publish_blog.sh

POST_TITLE="Dream Collector 개발일지 #3"
POST_FILE="content/blog/posts/dev-diary-3.md"
PUBLISH_TIME="2026-02-28 10:00"

# 1. Markdown → HTML 변환
pandoc $POST_FILE -t html > /tmp/post.html

# 2. Tistory 게시
python frameworks/blog_automation/scripts/post_to_tistory.py \
  --title "$POST_TITLE" \
  --content /tmp/post.html \
  --schedule "$PUBLISH_TIME"

# 3. SNS 자동 공유
python frameworks/blog_automation/scripts/share_to_sns.py \
  --title "$POST_TITLE" \
  --url "https://geekbrox.tistory.com/..."
```

---

## 🎯 현재 운영 중인 프로젝트

### Blog (블로그 자동화)

| 항목 | 내용 |
|------|------|
| **플랫폼** | Tistory (https://geekbrox.tistory.com) |
| **콘텐츠** | 게임 개발, 인디 게임 리뷰, 기술 블로그 |
| **발행 빈도** | 주 3회 (월/수/금 10:00 AM) |
| **팀장** | [지정 예정] |
| **자동화** | blog_automation/ 프레임워크 사용 |

#### 📂 폴더 구조
```
blog/
├── README.md                      ← 이 파일
├── posts/                         ← 게시할 마크다운 글
│   ├── dev-diary-1.md
│   ├── dev-diary-2.md
│   ├── dev-diary-3.md
│   ├── indie-game-review.md
│   └── ...
├── drafts/                        ← 작성 중인 글
│   ├── upcoming-post-1.md
│   └── ...
└── published/                     ← 게시된 글 기록
    ├── 2026-02-28-dev-diary-3.md
    └── ...
```

#### 📊 콘텐츠 종류 & 담당

| 콘텐츠 타입 | 형식 | 주기 | 담당 |
|-----------|------|------|------|
| 개발 일지 | 마크다운 | 주 1회 | Claude Code (Steve 정보 제공) |
| 게임 리뷰 | 마크다운 | 주 1회 | Claude Code |
| 기술 블로그 | 마크다운 | 주 1회 | Claude Code |
| 팁 & 트러스 | 마크다운 | 수시 | Claude Code |

---

## 📝 Team Lead의 일일 업무 체크리스트

### 아침 (매일 시작 전)
- [ ] Atlas 메시지 확인 (어제 게시 상황)
- [ ] Claude Code 작성 현황 확인
- [ ] 자동화 스크립트 상태 확인 (실패 여부)

### 오전 (콘텐츠 계획 & 지시)
- [ ] 오늘의 콘텐츠 계획 확인
- [ ] Claude Code에게 글 작성 지시
  - 예: "게임 리뷰 글 작성하세요 (주제: Elden Ring, 1500자)"
  - 예: "개발 일지 작성하세요 (최신 Phase 3 진행 상황)"
- [ ] 필요한 참고자료 제공 (링크, 이미지, 통계 등)

### 오후 (검수 & 최적화)
- [ ] Claude Code 작성 글 검수
  - 문법 확인
  - SEO 최적화 (제목, 메타디스크립션)
  - 이미지 링크 확인
  - 내부 링크 추가
- [ ] 승인 또는 수정 요청

### 저녁 (게시 & 보고)
- [ ] 최종 글을 automation 폴더로 이동
- [ ] 자동화 스크립트 실행 (또는 스케줄 예약)
- [ ] Atlas에게 상태 보고
  - 게시된 글 개수
  - 예약된 글 개수
  - SNS 반응 (좋아요, 댓글)
  - 이슈 사항

---

## 🔄 업무 위임 예시

### 예시 1: 일주일 치 블로그 글 작성

```
Steve (PM)
  "이번 주 블로그 3개 글 게시하자. 
   주제: 개발일지, 게임 리뷰, 인디 트렌드"
  ↓
  
Atlas (Team Agent)
  "Content Team Lead, 3개 글 요청합니다.
   발행 일정: 월/수/금 10:00 AM
   자동화 스크립트로 Tistory + SNS 자동 게시합니다."
  ↓
  
Content Team Lead (팀장)
  "Claude Code에게 지시:
   - 월(02-28): 개발일지 작성 (Phase 3 진행 상황)
   - 수(03-02): 게임 리뷰 작성 (Elden Ring)
   - 금(03-04): 인디 게임 트렌드 작성
   
   각 글: 1500자 마크다운, 이미지 2-3개 포함
   마감: 전날 오후 5시"
  ↓
  
Claude Code
  [각 글 작성] → [Team Lead 검수] → [승인] → [자동화 스크립트]
```

### 예시 2: 추가 콘텐츠 긴급 요청

```
Steve (PM)
  "Dream Collector 최신 스크린샷이 나왔어. 
   긴급으로 개발 일지 글 하나 더 작성해서 올려주자."
  ↓
  
Atlas (Team Agent)
  "Content Team Lead, 긴급 글 요청 들어왔습니다.
   스크린샷 다운로드했으니 활용해주세요."
  ↓
  
Content Team Lead (팀장)
  "Claude Code에게 긴급 지시:
   '개발 일지 추가 글 작성. 최신 스크린샷 3개 포함.
    마감: 2시간 내'"
  ↓
  
Claude Code
  [빠르게 작성] → [Team Lead 급속 검수] → [즉시 게시]
```

### 예시 3: 자동화 실패

```
Automation Script 오류:
  "Tistory 게시 실패: API 인증 오류"
  ↓
  
Content Team Lead
  "기술 검토:
   - 환경변수 확인: ✓
   - API 키 갱신 필요 확인
   - frameworks/blog_automation/scripts/shared_state.py 업데이트"
  ↓
  
Team Lead → Atlas
  "자동화 스크립트 수정 완료, 재실행 승인됨"
```

---

## 📊 Claude Code Rules (콘텐츠 작성)

```markdown
당신은 GeekBrox 블로그의 콘텐츠 라이터입니다.

책임:
- 고품질 블로그 글 작성 (마크다운)
- SEO 최적화 (제목, 메타 설명)
- 독자 참여 유도 (CTA 포함)

Content Team Lead 지시에 따를 것:
- 받은 지시: 주제, 글자 수, 마감시간 확인
- 작성 후: blogs/posts/ 폴더에 .md 파일로 제출
- 검수 요청 받으면: 수정사항 반영 후 재제출

글 작성 템플릿:
---
title: "블로그 제목"
date: 2026-02-28
category: "개발일지"
tags: ["게임개발", "Godot"]
description: "검색에 표시될 간단한 설명"
---

# 블로그 제목

[본문...]

## 마치며
[결론 및 다음 글 예고]
```

---

## 🚀 Instant Task 처리

### Team Lead이 Claude Code에게 실시간으로 지시할 수 있는 형식

#### 형식 1: 글 작성 지시
```
Content Team Lead → Claude Code:
"Dream Collector Phase 3 개발일지 글 작성하세요.
 요구사항:
  - 길이: 1500자
  - 형식: 마크다운
  - 이미지: 3개 (스크린샷)
  - 마감: 내일 오후 5시
 작성 후: teams/content/blog/posts/dev-diary-3.md에 저장"
```

#### 형식 2: 글 수정 요청
```
Content Team Lead → Claude Code:
"게임 리뷰 글 수정 필요:
 1. 제목을 '엘든링 리뷰: 도전성 vs 접근성' 으로 변경
 2. SEO 설명 추가
 3. 내부 링크 5개 추가 (다른 글들로)
 4. 마지막에 '다음 리뷰 예정: Balatro' 예고 추가"
```

#### 형식 3: 주기적 콘텐츠
```
Content Team Lead → Claude Code:
"매주 금요일 '인디 게임 트렌드' 글을 작성해주세요.
 - 길이: 1200자
 - 마감: 목요일 오후 4시
 - 이번주 주제: 2026년 2월 출시 게임 5개"
```

---

## 📈 콘텐츠 성과 추적

### Team Lead이 관리하는 메트릭

```markdown
# Content Performance (2026년 2월)

## 게시 현황
- 총 글: 10개
- Tistory 게시: 10개
- SNS 공유: 10개 (트위터, 블루스카이)

## 성과
- 월간 방문자: 2,340 (목표: 2,000) ✅
- 평균 글당 조회: 234 views
- 평균 글당 댓글: 3.2개
- SNS 반응: 350 likes, 25 shares

## 이월 목표
- 글 개수: 15개 (유지)
- 조회수: 3,000 (10% 증가)
- SNS 팔로워: 500 → 600 (20% 증가)
```

---

## 💬 커뮤니케이션 채널

| 대상 | 채널 | 용도 |
|------|------|------|
| **Steve** | Telegram (main session) | 주간 콘텐츠 전략, KPI 보고 |
| **Atlas** | Telegram (Atlas session) | 일일 게시 현황, 이슈 보고 |
| **Team Lead ↔ Claude** | Claude Code 댓글 | 글 작성 지시, 검수 요청 |
| **GitHub** | PR (draft 폴더) | 글 버전 관리, 변경 이력 |

---

## 🎯 Success Criteria

**Team Lead의 성공은:**
- ✅ 일정 준수 (주 3회 게시)
- ✅ 품질 (평균 점수 4.5/5.0)
- ✅ 성과 (월간 KPI 달성)
- ✅ 팀 생산성 (월 15개 글 이상)

---

## 📞 도움말

**"글을 어떻게 작성하나요?" 할 때:**
1. drafts/ 폴더에 마크다운 파일 생성
2. Claude Code에게 "이 글 마무리해주세요" 요청
3. 검수 후 posts/ 폴더로 이동
4. 자동화 스크립트 실행

**"자동 게시가 실패했어요" 할 때:**
1. 오류 메시지 확인
2. frameworks/blog_automation/MANUAL.md 참고
3. Team Lead이 스크립트 수정
4. 재실행

**"SNS 반응이 좋아요" 할 때:**
1. 성공 사례 공유 (Atlas에게)
2. 유사한 주제로 후속 글 계획
3. 독자 피드백 수집

---

**마지막 업데이트**: 2026-02-27 by Atlas  
**다음 검토**: 2026-03-06 (주간 KPI 리뷰)
