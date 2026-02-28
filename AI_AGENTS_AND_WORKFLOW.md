# 🤖 AI Agents & Workflow - 에이전트 할당 & 업무 관리

**이 문서는** Atlas(PM)와 3명의 매니저(Kim.G, Lee.C, Park.O)의 AI 에이전트 할당, Fallback 체인, 세션 관리 방식을 상세히 설명합니다.

---

## 📊 AI 에이전트 할당 구조

```
Steve (CEO/PD)
  ↓ [결정 & 지시]
  
┌─────────────────────────────────┐
│  Atlas (AI PM)                  │
│  ├─ Primary: Claude Haiku 4-5   │ ← 빠른 응답, 경량
│  ├─ Fallback1: Gemini 2.5 Pro   │
│  └─ Fallback2: Gemini Flash     │
│                                 │
│  역할: 팀 관리, 진행 추적       │
│  모드: Session (지속적 관리)    │
└─────────────────────────────────┘
          ↓ [팀 지휘]
  ┌───────┼───────┬───────┐
  ↓       ↓       ↓       ↓

┌──────────────────┐ ┌──────────────────┐ ┌──────────────────┐
│ Kim.G            │ │ Lee.C            │ │ Park.O           │
│ Game Manager     │ │ Content Manager  │ │ Ops Manager      │
├──────────────────┤ ├──────────────────┤ ├──────────────────┤
│Primary:          │ │Primary:          │ │Primary:          │
│ Gemini 2.5 Pro   │ │ Gemini Flash     │ │ Gemini 2.5 Pro   │
│                  │ │                  │ │                  │
│Fallback1:        │ │Fallback1:        │ │Fallback1:        │
│ Claude Haiku     │ │ Gemini Pro       │ │ Claude Haiku     │
│                  │ │                  │ │                  │
│Fallback2:        │ │Fallback2:        │ │Fallback2:        │
│ Gemini Flash     │ │ Claude Haiku     │ │ Gemini Flash     │
│                  │ │                  │ │                  │
│모드: Session     │ │모드: Run         │ │모드: Session     │
│우선순위: Active  │ │우선순위: Active  │ │우선순위: Active  │
└──────────────────┘ └──────────────────┘ └──────────────────┘
  ↓                   ↓                   ↓
도구 활용:          도구 활용:          도구 활용:
- Cursor IDE      - Claude Code       - OpenClaw CLI
- Claude Code     - 블로그 자동화      - 자동화 스크립트
- 자동화          - SNS 자동화        - 모니터링
```

---

## 1️⃣ Atlas (AI PM) - 프로젝트 관리 에이전트

### 📋 에이전트 정의

```yaml
Name: Atlas PM
Type: Session-Based (지속적 관리)
Primary Model: anthropic/claude-haiku-4-5-20251001 (빠른 응답)
Fallback Chain:
  1. google/gemini-2.5-pro (고급 분석 필요시)
  2. google/gemini-2.5-flash (백업)

Cost Budget: $35/month
Response Time Target: <2s
Uptime Target: 99.5%
```

### 🎯 역할 & 책임

| 업무 | 상세 | 모드 |
|------|------|------|
| **팀 진행률 추적** | PROGRESS.md 업데이트 | Daily (자동) |
| **인스턴트 태스크 모니터링** | 각 매니저의 태스크 상태 파악 | Real-time |
| **Blocker 이슈 해결** | 문제 발생시 즉시 Steve에게 보고 | On-demand |
| **주간 리포트** | 금요일 주간 리포트 생성 | Weekly (자동) |
| **매니저 지시** | 각 매니저에게 업무 할당 | Daily |
| **자동화 관리** | 스크립트 실행 모니터링 | Continuous |

### 💬 세션 관리 (Atlas)

```yaml
Session Type: session (지속적 대화)
Timeout: 1h (1시간 비활동시 종료)
Context: 전체 프로젝트 상태

Daily Workflow:
  09:00 AM: 아침 스탠드업 (각 팀 진행률 확인)
  10:00 AM: 일일 목표 수립
  17:00 PM: 일일 종료 보고
  20:00 PM: 저녁 요약 (Steve에게 전달)

Priority Rules:
  - Blocker 이슈 > 일반 업무
  - Steve 지시 > 일반 업무
  - 실시간 모니터링 (최대 대기: 5분)
```

### 📝 Atlas의 일일 프로세스

```markdown
# Atlas Daily Workflow (Atlas 자신이 관리)

## 아침 (09:00)
[ ] 각 팀 상태 확인
    - Kim.G에게 Game 진행률 묻기
    - Lee.C에게 Content 진행률 묻기
    - Park.O에게 Ops 상태 묻기
[ ] PROGRESS.md 업데이트
[ ] 블로킹 이슈 파악

## 오전 (10:00-12:00)
[ ] 각 매니저에게 오늘의 우선순위 전달
[ ] 인스턴트 태스크 모니터링
    - 새로운 요청 발생시 즉시 할당
    - 진행률 체크

## 오후 (14:00-17:00)
[ ] 진행 상황 추적
[ ] 이슈 해결 지원
[ ] 자동화 스크립트 모니터링

## 저녁 (17:00-20:00)
[ ] 일일 완료 항목 정리
[ ] IN_PROGRESS → DONE 이동
[ ] BLOCKER 이슈 리스트업
[ ] Steve에게 일일 보고
    - 완료: 3개 항목
    - 진행중: 5개 항목
    - 블로킹: 1개 이슈
[ ] 내일 계획 수립

## 금요일 (20:00, 특별)
[ ] 주간 리포트 작성 (project-management/reports/)
[ ] KPI 분석
[ ] 다음주 계획 수립
```

### 🔧 API 설정

```json
{
  "agents": {
    "main": {
      "id": "atlas",
      "name": "Atlas PM",
      "type": "session",
      "model": {
        "primary": "anthropic/claude-haiku-4-5-20251001",
        "fallbacks": [
          "google/gemini-2.5-pro",
          "google/gemini-2.5-flash"
        ]
      },
      "cost": {
        "budget": 35,
        "currency": "USD/month"
      },
      "timeout": 3600,
      "priority": "active"
    }
  }
}
```

---

## 2️⃣ Kim.G (Game Manager) - 게임 개발 관리

### 📋 에이전트 정의

```yaml
Name: Kim.G (Game Manager)
Type: Session-Based (대화형 관리)
Primary Model: google/gemini-2.5-pro (복잡한 기술 결정)
Fallback Chain:
  1. anthropic/claude-haiku-4-5-20251001 (빠른 응답)
  2. google/gemini-2.5-flash (백업)

Cost Budget: $35/month
Specialization: 복잡한 기술 결정, 코드 리뷰, 게임 설계
Response Time Target: <3s
```

### 🎯 역할 & 책임

| 업무 | 상세 | 모드 |
|------|------|------|
| **Cursor IDE 관리** | 개발자에게 태스크 할당 & PR 검수 | Interactive |
| **기술 결정** | 게임 구현 방식 논의 | Session (깊은 사고) |
| **ATB 시스템 감독** | Phase 3 진행 상황 모니터링 | Daily Check |
| **인스턴트 버그 해결** | 개발중 발생한 버그 즉시 해결 | On-demand |
| **일일 체크리스트** | PROGRESS.md 업데이트 | Daily |

### 💬 세션 관리 (Kim.G)

```yaml
Session Type: session (지속적 대화)
Timeout: 2h (대화형 개발)
Context: Dream Collector 게임 상태

Daily Workflow:
  09:00 AM: 어제 진행상황 검토
  09:30 AM: 오늘의 우선순위 정렬
           - Cursor IDE: 명확한 태스크 지시
           - 예: "CardDatabase.gd에 30개 카드 추가"
  10:00-17:00: 실시간 모니터링
           - PR 들어오면 즉시 검수
           - 버그 보고 받으면 즉시 분석
  17:30 PM: 일일 진행률 정리 (PROGRESS.md)
  18:00 PM: Atlas에게 상태 보고

Instant Task Handling:
  받은 요청 → 분석 → Cursor IDE에 지시 → 모니터링 → 검수 → 병합
  평균 소요시간: 2시간 (작은 태스크)
```

### 📝 Kim.G의 일일 프로세스

```markdown
# Kim.G Daily Workflow (Game Manager)

## 아침 (09:00)
[ ] 어제 완료 항목 확인
    - CombatManager.gd: ✅ 기본 구조 완료
    - CardDatabase.gd: 🔄 60% 진행
[ ] 오늘의 우선순위 수립
    [ ] CardDatabase.gd 완성 (P1)
    [ ] Battle UI 시작 (P2)
    [ ] 버그 수정 (P3)

## 오전 (09:30)
[ ] Cursor IDE에게 태스크 지시
    "CardDatabase.gd 완성하세요.
     스펙: teams/game/dream-collector/workspace/design/TAROT_SYSTEM_GUIDE.md 참고
     마감: 오늘 오후 4시"

[ ] 전투 시스템 기술 논의
    - ATB gauge 동기화 방식 결정
    - 성능 최적화 방안 검토

## 낮 (12:00-17:00)
[ ] 실시간 모니터링
    - Cursor가 CardDatabase.gd 작성 중 → 진행률 확인
    - 질문 있으면 즉시 답변
    - 막히는 부분 있으면 코칭

[ ] PR이 들어오면 즉시 검수
    ```
    1. 코드 스타일 확인 (가이드 준수?)
    2. 테스트 확인 (동작하나?)
    3. 성능 확인 (최적화됐나?)
    4. 승인 또는 수정 요청
    ```

## 오후 (16:00)
[ ] 버그 리포트 처리
    예: "Enemy 렌더링이 느려요"
    → 원인 분석 → Ops와 협력 → 해결

[ ] PROGRESS.md 업데이트
    ```
    - CardDatabase.gd: ✅ 완료 (30 cards)
    - Battle UI: 🔄 시작 (0%)
    - Blocker: None
    ```

## 저녁 (17:30)
[ ] 일일 보고서 정리
    완료: CardDatabase.gd (30개 카드)
    진행중: Battle UI (15% 진행)
    블로킹: None
    내일 목표: Battle UI 50% 완성

[ ] Atlas에게 보고
    "Game 진행률: 60% → 65%
     이슈: 없음
     내일: Battle UI 중점"

## 긴급 (즉시)
[ ] 버그 리포트 → 즉시 분석
[ ] Blocker 이슈 → 즉시 해결
[ ] 기술 질문 → 즉시 답변
```

### 🛠️ 도구 & 모드

```yaml
Primary Tools:
  - Cursor IDE (개발자 지시 & PR 검수)
  - Claude Code (복잡한 기술 이슈 분석)
  - 자동화 스크립트 (빌드 테스트)

Session Modes:
  1. Interactive Mode (실시간 대화)
     - 개발자와 실시간 문제 해결
     - Fallback: Claude Haiku (응답 속도)
  
  2. Deep Think Mode (깊은 사고)
     - 게임 설계 결정 (Claude Sonnet 필수)
     - Fallback: Claude Haiku (시간 제한)
  
  3. Review Mode (검수 모드)
     - PR 코드 리뷰
     - 성능 분석

Instant Task Priority:
  🔴 Critical: Blocker (즉시, <5분)
  🟠 High: 버그 수정 (긴급, <30분)
  🟡 Medium: 일반 태스크 (표준, <2시간)
  🟢 Low: 개선사항 (차순, <1일)
```

### 🔧 API 설정

```json
{
  "agents": {
    "game": {
      "id": "kim_g",
      "name": "Game Manager (Kim.G)",
      "type": "session",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      },
      "cost": {
        "budget": 35,
        "currency": "USD/month"
      },
      "timeout": 7200,
      "priority": "active",
      "specialization": "game_development"
    }
  }
}
```

---

## 3️⃣ Lee.C (Content Manager) - 콘텐츠 운영 관리

### 📋 에이전트 정의

```yaml
Name: Lee.C (Content Manager)
Type: Run-Based (빠른 태스크 처리)
Primary Model: google/gemini-2.5-pro
Fallback Chain:
  1. anthropic/claude-haiku-4-5-20251001 (빠른 응답)
  2. google/gemini-2.5-flash (백업)

Cost Budget: $20/month (고급 콘텐츠 처리)
Specialization: 콘텐츠 생성, SNS 관리, 품질 우선
Response Time Target: <2s
```

### 🎯 역할 & 책임

| 업무 | 상세 | 모드 |
|------|------|------|
| **콘텐츠 계획** | 주간 글 주제 결정 | Session (전략) |
| **Claude Code 지시** | 글 작성 태스크 할당 | Run (빠른 태스크) |
| **글 검수 & 승인** | Markdown 품질 확인 | Interactive |
| **자동화 게시** | 블로그/SNS 자동 배포 | Scheduled (자동) |
| **성과 분석** | 월간 KPI 추적 | Weekly Report |

### 💬 세션 관리 (Lee.C)

```yaml
Session Type: 혼합형
  - Planning: session (전략 수립)
  - Task: run (개별 태스크)
  - Reporting: session (분석)

Timeout: 30min (빠른 처리)
Context: 콘텐츠 운영 상태

Weekly Workflow:
  월요일 10:00: 주간 콘텐츠 계획 (Session)
  화-목요일: 글 작성 지시 (Run) × 3회
  금요일 16:00: 검수 & 승인
  금요일 17:00: 자동 게시
  금요일 18:00: 주간 성과 보고 (Session)

Instant Task Handling:
  기획 → Claude Code에 지시 → 모니터링 → 검수 → 게시
  평균 소요시간: 1-2시간 (글 하나당)
```

### 📝 Lee.C의 주간 프로세스

```markdown
# Lee.C Weekly Workflow (Content Manager)

## 월요일 (10:00) - 주간 계획
[ ] 주간 주제 3개 결정
    1. 개발일지 (Dream Collector Phase 3)
    2. 게임 리뷰 (주제: TBD)
    3. 인디게임 트렌드 (02월 분석)

[ ] Claude Code에게 전체 계획 공유
    "이번주 3개 글:
     - 월(개발일지): 마감 화요일 4시
     - 수(리뷰): 마감 목요일 4시  
     - 금(트렌드): 마감 금요일 2시
     각 글: 1500자, SEO 최적화, 이미지 2-3개"

## 화요일 (14:00) - 첫 글 관리
[ ] Claude Code의 개발일지 초안 검수
    - 문법 ✅
    - 내용 정확성 ✅
    - SEO ✅
    - 이미지 링크 ✅

[ ] 피드백 전달 또는 승인
    승인시 → drafts/ → posts/ 이동

## 수요일 (14:00) - 두 번째 글
[ ] Claude Code의 게임 리뷰 검수
[ ] 수정 또는 승인

## 목요일 (14:00) - 세 번째 글
[ ] Claude Code의 트렌드 분석 검수
[ ] 승인

## 금요일 (17:00) - 자동화 & 보고
[ ] 3개 글 모두 자동 게시 실행
    Automation: Markdown → Tistory → Twitter/BlueSky

[ ] 게시 확인
    [ ] Tistory 포스팅 성공?
    [ ] SNS 자동 공유 성공?

[ ] 주간 성과 분석
    - 글 3개 게시 (100% 목표)
    - SNS 반응: 좋아요 +50, 댓글 +8
    - 방문자: 500 (주간 목표 450)

[ ] Atlas에게 주간 보고
    "Content: 목표 달성 (3개 글, KPI 달성)"

## 긴급 (즉시)
[ ] 추가 글 요청 받으면:
    - 즉시 Claude Code에 지시
    - 4시간 내 완성 목표
[ ] 게시 실패시:
    - 원인 분석 (API 오류? 포맷 오류?)
    - Park.O와 협력하여 해결
```

### 🛠️ 도구 & 모드

```yaml
Primary Tools:
  - Claude Code (글 작성)
  - 블로그 자동화 (Tistory API)
  - SNS 자동화 (Twitter/BlueSky API)
  - Markdown 검증 스크립트

Session Modes:
  1. Planning Mode (Session, Claude Sonnet-level)
     - 주간/월간 콘텐츠 전략
     - 주제 선정 & 키워드 연구
     - Fallback: Gemini Pro
  
  2. Task Mode (Run, Gemini Flash)
     - "글 작성해주세요" 개별 태스크
     - 빠른 처리 (5-10분 답변)
     - 비용 최소화
  
  3. Review Mode (Interactive)
     - 글 품질 검수
     - 수정 사항 지시
  
  4. Automation Mode (Scheduled)
     - 자동 게시 스크립트 실행
     - 결과 모니터링

Instant Task Priority:
  🔴 Critical: 긴급 콘텐츠 요청 (<1시간)
  🟠 High: 주간 계획 글 (2시간)
  🟡 Medium: 추가 글 (4시간)
  🟢 Low: 아이디어 리서치 (24시간)
```

### 🔧 API 설정

```json
{
  "agents": {
    "content": {
      "id": "lee_c",
      "name": "Content Manager (Lee.C)",
      "type": "mixed",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      },
      "cost": {
        "budget": 20,
        "currency": "USD/month"
      },
      "timeout": 1800,
      "priority": "active",
      "specialization": "content_creation"
    }
  }
}
```

---

## 4️⃣ Park.O (Ops Manager) - 인프라 & 자동화 관리

### 📋 에이전트 정의

```yaml
Name: Park.O (Ops Manager)
Type: Session-Based (지속적 모니터링)
Primary Model: google/gemini-2.5-pro
Fallback Chain:
  1. anthropic/claude-haiku-4-5-20251001 (빠른 응답)
  2. google/gemini-2.5-flash (백업)

Cost Budget: $25/month
Specialization: 인프라, 자동화, 비용 최적화, 모니터링
Response Time Target: <2s
```

### 🎯 역할 & 책임

| 업무 | 상세 | 모드 |
|------|------|------|
| **OpenClaw 관리** | API 설정, 모델 버전 관리 | Session |
| **헬스 체크** | 일일 인프라 모니터링 | Automated Daily |
| **비용 최적화** | 월간 API 비용 분석 & 개선 | Weekly Report |
| **자동화 유지** | CI/CD, 빌드 스크립트 관리 | Continuous |
| **긴급 대응** | 장애 발생시 즉시 조치 | On-demand |

### 💬 세션 관리 (Park.O)

```yaml
Session Type: session (지속적 모니터링)
Timeout: 3h (수동 작업 포함)
Context: 인프라 전체 상태

Daily Workflow:
  09:00 AM: 아침 헬스 체크 (5분)
           - OpenClaw 상태
           - API 비용 확인
           - 에러 로그 검토
  
  10:00 AM-17:00 PM: 실시간 모니터링
           - 각 팀의 자동화 실행 모니터링
           - 에러 발생시 즉시 대응
  
  17:00 PM: 일일 리포트 정리
  18:00 PM: Atlas에게 상태 보고

Weekly (금요일):
  16:00 PM: 주간 헬스 리포트 작성
  17:00 PM: 비용 분석 리포트 작성
  18:00 PM: 다음주 계획 수립

Monthly (마지막 금요일):
  월간 비용 리포트 (예산 대비)
  성능 분석 & 개선 제안
  API 키 로테이션
```

### 📝 Park.O의 일일 프로세스

```markdown
# Park.O Daily Workflow (Ops Manager)

## 아침 (09:00) - 헬스 체크
[ ] OpenClaw 상태 확인
    openclaw status
    
    결과:
    - Atlas: 99.8% ✅
    - Game (Kim.G): 99.9% ✅
    - Content (Lee.C): 100% ✅
    - Ops (Park.O): 99.5% ✅

[ ] API 비용 확인
    python teams/ops/scripts/cost-optimizer.py
    
    결과:
    - Gemini: $12 (일일)
    - Claude: $2 (일일)
    - 합계: $14/일 (월간 $420 예상)
    - 예산: $200 (초과!)

[ ] 에러 로그 검토
    tail -100 ~/.openclaw/logs/openclaw.log | grep -i error
    
    발견: 
    - 에러 없음 ✅

## 오전 (10:00-12:00)
[ ] 각 매니저의 자동화 모니터링
    - Kim.G: Cursor 빌드 자동화 실행 중 ✅
    - Lee.C: 블로그 자동 게시 예약됨 ✅
    - Park.O: 헬스체크 스크립트 준비 ✅

[ ] 비용 최적화 논의
    "Gemini 사용을 80%로 높여서 비용 절감 가능"
    → openclaw.json 설정 수정
       - Primary: Gemini Pro (비용 효율)
       - Fallback1: Claude Haiku (품질 필요시)
       - Fallback2: Gemini Flash (완벽한 백업)

## 낮 (13:00-17:00)
[ ] 실시간 모니터링
    문제 발생시:
    1. 원인 분석 (로그 검토)
    2. 즉시 해결 (설정 수정, 재시작)
    3. 영향 범위 파악
    4. Atlas에게 긴급 보고

[ ] 자동화 스크립트 검증
    [ ] CI/CD 파이프라인 테스트
    [ ] 빌드 성공 확인
    [ ] 배포 준비 상태 확인

## 저녁 (17:00)
[ ] 일일 리포트 정리
    ```
    Ops Daily Report (2026-02-27)
    
    Uptime: 99.8% ✅
    Errors: 0 ✅
    Cost: $14 (on budget)
    Actions: Gemini config updated
    Issues: None
    ```

[ ] Atlas에게 보고
    "Ops: 모든 정상 + 비용 최적화 완료"

## 주간 금요일 (16:00)
[ ] 주간 헬스 리포트 작성
    teams/ops/reports/weekly-health.md
    
    ├─ 가동률: 99.8%
    ├─ 에러율: 0.2%
    ├─ 평균 응답시간: 1.2s
    └─ 주요 이벤트: 없음

[ ] 주간 비용 리포트 작성
    teams/ops/reports/weekly-cost.md
    
    ├─ Gemini: $84/week
    ├─ Claude: $14/week
    ├─ 합계: $98/week
    └─ 월간 예상: $392 (초과)

[ ] 비용 개선 안 제시
    "Gemini Flash 비중 50%로 증가 제안
     예상 절감: $100/월"

## 긴급 (즉시)
[ ] 장애 발생시:
    1. 원인 분석 (<5분)
    2. 즉시 복구 조치
    3. Atlas에게 긴급 보고
    4. 사후 분석 (다음날)
```

### 🛠️ 도구 & 모드

```yaml
Primary Tools:
  - OpenClaw CLI (상태 확인)
  - cost-optimizer.py (비용 분석)
  - check-infrastructure.sh (헬스 체크)
  - CI/CD 파이프라인 (빌드 자동화)

Session Modes:
  1. Monitoring Mode (Continuous)
     - 실시간 인프라 모니터링
     - 이상 신호 감지
     - Fallback: Claude Haiku (응답 속도)
  
  2. Optimization Mode (Weekly)
     - 비용 분석 & 개선
     - 성능 튜닝
     - Fallback: Gemini Pro
  
  3. Emergency Mode (On-demand)
     - 장애 대응
     - 즉시 진단 & 조치
     - No fallback (빠른 응답)
  
  4. Automation Mode (Scheduled)
     - CI/CD 실행
     - 자동화 스크립트 관리
     - 결과 모니터링

Instant Task Priority:
  🔴 Critical: 장애 (즉시, <5분)
  🟠 High: 에러 (긴급, <30분)
  🟡 Medium: 최적화 (표준, <1일)
  🟢 Low: 모니터링 (지속적)
```

### 🔧 API 설정

```json
{
  "agents": {
    "ops": {
      "id": "park_o",
      "name": "Ops Manager (Park.O)",
      "type": "session",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      },
      "cost": {
        "budget": 25,
        "currency": "USD/month"
      },
      "timeout": 10800,
      "priority": "active",
      "specialization": "infrastructure"
    }
  }
}
```

---

## 📊 전체 AI 에이전트 할당 요약

### 비용 분배

```
Total Budget: $200/month

Atlas (PM):           $35 (17.5%) [팀 관리, Claude Haiku]
Kim.G (Game):         $35 (17.5%) [기술 결정, Gemini 2.5 Pro]
Lee.C (Content):      $15 (7.5%)  [빠른 콘텐츠, Gemini Flash]
Park.O (Ops):         $25 (12.5%) [인프라, Gemini 2.5 Pro]
Reserve:              $90 (45%)   [응급 & 스케일링]
────────────────────────────
합계:                $200 (100%)
```

### 모델 선택 기준

| 매니저 | Primary | 이유 |
|--------|---------|------|
| **Atlas** | Claude Haiku 4-5 | PM 역할 (빠른 응답, 경량) |
| **Kim.G** | Gemini 2.5 Pro | 복잡한 기술 결정 (성능 + 안정성) |
| **Lee.C** | Gemini Flash | 빠른 콘텐츠 생성 (속도 + 저비용) |
| **Park.O** | Gemini 2.5 Pro | 시스템 관리 (안정성 + 분석) |

### Fallback 전략

```
Rule 1: Primary 실패 → Fallback1 (대체)
Rule 2: Fallback1 실패 → Fallback2 (완벽한 백업)
Rule 3: 모두 실패 → Steve 수동 개입

Timeout 설정:
  - 문제 감지후 5초 대기
  - 5초 후 Fallback1로 자동 전환
  - Fallback1 실패시 Fallback2로 전환
  - 모두 실패시 알림 & 대기
```

---

## 🔄 인스턴트 태스크 관리 (각 매니저별)

### Kim.G (Game Manager) - 인스턴트 태스크 흐름

```
Steve: "Phase 3 ATB 구현하자"
  ↓
Atlas: "Kim.G, ATB 구현 요청 들어왔습니다"
  ↓
Kim.G: [세션 시작, Claude Sonnet 4.5로 분석]
  1. ATB_Implementation_Guide.md 검토
  2. 구현 계획 수립 (CombatManager, CardDatabase, UI)
  3. 우선순위 정렬
  ↓
Kim.G → Cursor IDE: 
  "Task 1: CombatManager.gd 기본 구조 (3일)
   Task 2: CardDatabase.gd (2일)
   Task 3: Battle UI (4일)"
  ↓
실시간 모니터링:
  - Cursor가 CombatManager 작성 중 → 진행률 확인
  - 막히면 즉시 코칭 (Claude로 문제 분석)
  - PR 들어오면 즉시 검수 (Claude로 코드 리뷰)
  ↓
Kim.G → Atlas:
  "Day 1: CombatManager.gd 30% 완성, 예정대로"
  ↓
완료:
  "CardDatabase.gd ✅ 병합됨"
  "Progress: 60% → 65%"
```

**세션 지속 시간**: 2시간 (모든 작업 감독)  
**Fallback 사용 빈도**: 5% (필요시에만)  
**평균 응답 시간**: 3초

---

### Lee.C (Content Manager) - 인스턴트 태스크 흐름

```
Steve: "이번주 3개 글 올려"
  ↓
Atlas: "Lee.C, 3개 글 요청합니다"
  ↓
Lee.C: [세션 시작, 주간 계획]
  1. 주제 3개 결정 (개발일지, 리뷰, 트렌드)
  2. 마감일 설정 (월/수/금)
  3. 글쓰기 지시사항 정리
  ↓
Lee.C → Claude Code: [Run 모드, Gemini Flash]
  Task 1: "개발일지 작성 (마감: 화 4시)
           스펙: 1500자, 이미지 2-3개, SEO 최적화"
  ↓
Claude Code: [1-2시간 후 초안 제출]
  ↓
Lee.C: [Review 모드로 전환]
  1. 초안 검수 (문법, 내용, SEO)
  2. 수정 사항 지시 또는 승인
  3. 승인되면 posts/ 폴더로 이동
  ↓
자동화:
  Automation script: Markdown → Tistory → SNS
  (Friday 5PM 자동 실행)
  ↓
Lee.C → Atlas:
  "이번주 3개 글 모두 게시 완료, KPI 달성"
```

**세션 방식**: Task별 Run 모드 (빠른 처리)  
**평균 처리 시간**: 2시간 (글 하나당)  
**주간 비용**: $3~5 (저비용 모델)

---

### Park.O (Ops Manager) - 인스턴트 태스크 흐름

```
장애 감지: "API 응답 느림"
  ↓
Park.O: [세션 시작, 응급 모드, Gemini 2.5 Pro]
  1. 로그 분석: tail -100 ~/.openclaw/logs/
  2. 원인 파악: Rate limit 초과
  3. 해결책: 모델 설정 변경 (Gemini Pro → Flash)
  ↓
Park.O: [설정 수정]
  openclaw.json 업데이트
  모델 Fallback 재배열
  ↓
Park.O: [확인]
  openclaw status
  → 응답 시간: 1.2s로 정상화 ✅
  ↓
Park.O → Atlas:
  "장애 해결: API 응답 정상화됨 (10분 소요)"
  ↓
Kim.G & Lee.C:
  [서비스 정상, 계속 작업]
```

**응답 시간**: <5분 (응급 대응)  
**Fallback 사용**: 거의 없음 (Gemini Pro 충분)  
**해결률**: 99% (자체 해결)

---

## 📋 매니저별 인스턴트 태스크 우선순위

### Kim.G (Game Manager)

```
🔴 Critical (즉시, <5분)
  - Blocker 이슈 (게임 빌드 실패)
  - 심각한 버그 (렌더링 오류)
  - 성능 문제 (FPS <30)

🟠 High (긴급, <30분)
  - 버그 수정 (일반)
  - 기술 결정 (구현 방식)
  - PR 검수 (코드 리뷰)

🟡 Medium (표준, <2시간)
  - 새로운 태스크 지시
  - 코칭 & 멘토링
  - 진행률 체크

🟢 Low (차순, <1일)
  - 코드 스타일 개선
  - 문서 업데이트
  - 성능 최적화
```

### Lee.C (Content Manager)

```
🔴 Critical (즉시, <1시간)
  - 긴급 콘텐츠 요청
  - 게시 실패
  - 자동화 오류

🟠 High (긴급, 2시간)
  - 주간 계획 글 (마감 있음)
  - 글 검수 (수정 사항 있음)

🟡 Medium (표준, 4시간)
  - 추가 글 요청 (마감 없음)
  - 리서치 & 아이디어

🟢 Low (차순, 24시간)
  - 아이디어 개발
  - 문서 정리
  - 성과 분석
```

### Park.O (Ops Manager)

```
🔴 Critical (즉시, <5분)
  - 서비스 장애
  - API 다운
  - 비용 폭증

🟠 High (긴급, 30분)
  - 성능 저하
  - 에러율 증가
  - 자동화 실패

🟡 Medium (표준, 2시간)
  - 설정 최적화
  - 비용 분석
  - 헬스 체크

🟢 Low (차순, 1일)
  - 문서화
  - 모니터링 개선
  - 보고서 작성
```

---

## 🔐 세션 보안 & 격리

```yaml
Session Isolation:
  각 매니저의 세션은 독립적
  - 다른 팀의 컨텍스트 노출 안됨
  - 민감정보 보호 (API 키 미노출)
  - 비용 추적 분리

Context Management:
  Atlas: 전체 프로젝트 컨텍스트 (가능한 최대)
  Kim.G: Game 팀 컨텍스트만
  Lee.C: Content 팀 컨텍스트만
  Park.O: Ops 팀 컨텍스트만

Token Limits:
  Atlas: 100K (장시간 세션)
  Kim.G: 50K (기술 논의)
  Lee.C: 30K (콘텐츠 생성)
  Park.O: 40K (모니터링)
```

---

## 🎓 요약 & 사용 가이드

### 각 매니저의 역할

```
Kim.G (Game Manager):
  모델: Gemini 2.5 Pro (복잡한 기술)
  모드: Session (지속적 대화)
  우선순위: 게임 품질
  비용: $35/월
  특징: 깊은 기술 사고, 상세 코드 리뷰

Lee.C (Content Manager):
  모델: Gemini Flash (빠른 처리)
  모드: Run (개별 태스크)
  우선순위: 콘텐츠 속도
  비용: $15/월 (가장 저비용)
  특징: 빠른 응답, 효율적 자동화

Park.O (Ops Manager):
  모델: Gemini 2.5 Pro (안정성)
  모드: Session (지속적 모니터링)
  우선순위: 시스템 안정성
  비용: $25/월
  특징: 실시간 모니터링, 비용 최적화
```

### 인스턴트 태스크 처리 방식

```
1. 요청 접수
   매니저가 요청을 받으면:
   - 급급도 판단
   - 현재 컨텍스트 활용
   - 세션 또는 새 Run 결정

2. 분석 & 계획
   AI가 도움:
   - 요청 분석 (무엇을 원하나?)
   - 계획 수립 (어떻게 할 건가?)
   - 리소스 할당 (누가 할 건가?)

3. 실행 & 모니터링
   매니저가 실행:
   - 도구에 명확한 지시
   - 실시간 진행률 확인
   - 문제 발생시 즉시 대응

4. 완료 & 보고
   매니저가 마무리:
   - 결과 검증
   - Atlas에게 보고
   - 다음 단계 계획
```

---

## 🔄 4. Fallback Chain 상세 - Rule 3: 모두 실패 시

### 📋 Fallback 전체 흐름

**각 매니저의 Fallback 체인:**

| 순번 | Kim.G (Game) | Lee.C (Content) | Park.O (Ops) |
|------|---|---|---|
| **Primary** | Gemini 2.5 Pro | Gemini 2.5 Pro | Gemini 2.5 Pro |
| **Fallback1** | Claude Haiku 4-5 | Claude Haiku 4-5 | Claude Haiku 4-5 |
| **Fallback2** | Gemini Flash | Gemini Flash | Gemini Flash |

### Rule 1, 2, 3 정의

```yaml
Rule 1 (Primary 성공):
  ✅ 즉시 응답
  └─ 평균 응답시간: 1-2초

Rule 2 (Primary 실패 → Fallback1 성공):
  ⚠️ 자동 전환
  ├─ Fallback1 대기: 5초
  ├─ 응답 완료
  └─ 사용자: 약간 느린 것만 인지 (6-7초)

Rule 3 (모든 Fallback 실패):
  🔴 Steve 수동 개입 & 알림
  ├─ 모든 모델 다운 감지
  ├─ Telegram → Steve에게 긴급 알림
  │  "🚨 CRITICAL: 모든 AI 모델 응답 불가 (Kim.G 태스크)"
  ├─ Steve 수동 개입
  │  - 상황 파악
  │  - 대체 솔루션 지시
  │  - 임시 방안 결정
  └─ Atlas: Steve 지시 받고 정정된 워크플로우 실행
```

### 예시 - Kim.G (게임 개발)

```
요청: "CardDatabase.gd 완성해줘 (긴급)"

1️⃣ Primary 시도 (Gemini 2.5 Pro)
   ├─ 대기: 2초
   ├─ 응답: ✅ 성공
   └─ 시간: 2초

2️⃣ Primary 실패 → Fallback1 (Claude Haiku)
   ├─ Primary 실패 감지 (타임아웃 3초)
   ├─ Fallback1 자동 전환
   ├─ 대기: 5초
   ├─ 응답: ✅ 성공 (약간 느림)
   └─ 사용자 경험: "응답이 좀 느렸는데 정상"

3️⃣ Fallback1 실패 → Fallback2 (Gemini Flash)
   ├─ Fallback1 실패 감지
   ├─ Fallback2 자동 전환
   ├─ 대기: 5초
   ├─ 응답: ✅ 성공 (약간 더 느림)
   └─ 사용자 경험: "좀 느리지만 작동함"

4️⃣ Rule 3: 모두 실패 (Gemini Flash도 다운)
   ├─ 모든 모델 실패 감지
   ├─ Telegram → Steve 긴급 알림
   │  🚨 "Kim.G 요청 처리 불가 (모든 AI 모델 응답 없음)"
   ├─ Steve 수동 개입
   │  - 상황: "Gemini 서버 전체 다운, Claude 장애"
   │  - 결정: "일단 Task 연기하고 Park.O에게 상황 공유"
   ├─ Atlas: Steve 지시 받고 실행
   │  - Park.O에게: "API 상태 확인해줘"
   │  - Kim.G에게: "Task 연기될 예정, 상황 공유 대기"
   └─ 사용자 경험: "장애 발생, Steve가 처리 중"
```

---

## 🎯 5. 인스턴트 태스크 관리 (각 매니저별)

### Kim.G - 게임 개발

```yaml
우선순위 & SLA (Service Level Agreement):

🔴 Critical (즉시, <5분)
  - Blocker 이슈: 게임 빌드 실패
  - 심각한 버그: 렌더링 오류, 크래시
  - 예: "CardDatabase.gd 컴파일 오류로 빌드 불가"
  
🟠 High (긴급, <30분)
  - 버그 수정: 일반 버그
  - 기술 결정: 구현 방식 논의
  - PR 검수: 코드 리뷰
  - 예: "Enemy 렌더링이 느려"
  
🟡 Medium (표준, <2시간)
  - 새로운 태스크 지시: "Battle UI 구현해"
  - 코칭 & 멘토링: "이 부분 개선하려면?"
  - 성능 최적화: 캐싱 방안 논의
  
🟢 Low (차순, <1일)
  - 코드 스타일 개선
  - 문서 업데이트 (주석 추가)
```

### Lee.C - 콘텐츠 운영

```yaml
우선순위 & SLA:

🔴 Critical (즉시, <1시간)
  - 긴급 콘텐츠 요청: Steve의 즉시 지시
  - 게시 실패: Tistory API 오류
  - 자동화 오류: SNS 공유 실패
  - 예: "오늘 해야 할 블로그 글 긴급 요청"
  
🟠 High (긴급, 2시간)
  - 주간 계획 글: 마감 있음 (화/수/금)
  - 글 검수: 수정 사항 있는 글
  - 예: "화요일 게임 리뷰 글 검수 완료해"
  
🟡 Medium (표준, 4시간)
  - 추가 글 요청: 마감 없음
  - 리서치 & 아이디어: 주제 발굴
  - 예: "인디게임 트렌드 분석 글 작성해"
  
🟢 Low (차순, 24시간)
  - 아이디어 개발: 주제 브레인스토밍
  - 문서 정리: 과거 글 분류
```

### Park.O - 인프라 관리

```yaml
우선순위 & SLA:

🔴 Critical (즉시, <5분)
  - 서비스 장애: OpenClaw 다운
  - API 다운: Gemini/Claude 서비스 불가
  - 비용 폭증: 월간 예산 초과 위험
  - 예: "Gemini API가 응답 안 함"
  
🟠 High (긴급, 30분)
  - 성능 저하: 응답시간 3초 이상
  - 에러율 증가: 비정상 에러 증가
  - 자동화 실패: 블로그 게시 실패
  - 예: "모델 응답 시간이 느려졌어"
  
🟡 Medium (표준, 2시간)
  - 설정 최적화: Fallback 체인 개선
  - 비용 분석: 월간 API 비용 검토
  - 헬스 체크: 정기 인프라 점검
  
🟢 Low (차순, 1일)
  - 문서화: 운영 매뉴얼 작성
  - 모니터링 개선: 대시보드 개선
```

---

## 📊 6. 세션 관리 & API 설정

### 세션 타입별 특성

```yaml
Session (지속적 대화):
  - 타입: 수동 세션, 대화형
  - 타임아웃: 1-3시간 (활동 없으면 종료)
  - 컨텍스트: 이전 대화 기억
  - 사용처: Atlas, Kim.G, Park.O
  - 가격: 높음 (세션 유지 비용)

Run (일회성 태스크):
  - 타입: 자동 세션, 빠른 실행
  - 타임아웃: 10-30분
  - 컨텍스트: 현재 태스크만
  - 사용처: Lee.C (콘텐츠 생성)
  - 가격: 낮음 (빠른 종료)
```

### 각 매니저의 세션 설정

| 매니저 | 세션 타입 | 타임아웃 | 컨텍스트 | 토큰 제한 | 우선순위 |
|--------|----------|---------|---------|----------|---------|
| **Atlas** | Session | 1시간 | 전체 프로젝트 | 100K | Active |
| **Kim.G** | Session | 2시간 | Game 팀 | 50K | Active |
| **Lee.C** | Run | 30분 | Content만 | 30K | Active |
| **Park.O** | Session | 3시간 | Ops만 | 40K | Active |

### 최종 API 설정 (모든 매니저)

```json
{
  "agents": {
    "atlas": {
      "id": "atlas",
      "name": "Atlas PM",
      "type": "session",
      "model": {
        "primary": "anthropic/claude-haiku-4-5-20251001",
        "fallbacks": [
          "google/gemini-2.5-pro",
          "google/gemini-2.5-flash"
        ]
      },
      "cost": {"budget": 35, "currency": "USD/month"},
      "timeout": 3600,
      "priority": "active"
    },
    
    "kim_g": {
      "id": "kim_g",
      "name": "Game Manager (Kim.G)",
      "type": "session",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      },
      "cost": {"budget": 35, "currency": "USD/month"},
      "timeout": 7200,
      "priority": "active",
      "specialization": "game_development"
    },
    
    "lee_c": {
      "id": "lee_c",
      "name": "Content Manager (Lee.C)",
      "type": "run",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      },
      "cost": {"budget": 20, "currency": "USD/month"},
      "timeout": 1800,
      "priority": "active",
      "specialization": "content_creation"
    },
    
    "park_o": {
      "id": "park_o",
      "name": "Ops Manager (Park.O)",
      "type": "session",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      },
      "cost": {"budget": 25, "currency": "USD/month"},
      "timeout": 10800,
      "priority": "active",
      "specialization": "infrastructure"
    }
  }
}
```

---

## ✅ 7. 최종 정리 - 핵심 요점

### Who (누가)

```
Steve: CEO/PD
  └─ 결정권자, 전략 결정, 긴급 개입

Atlas: AI PM (OpenClaw Agent)
  └─ 팀 관리, 자동화, 일일 추적

Kim.G: Game Manager
  └─ 게임 개발 지휘, 기술 결정

Lee.C: Content Manager
  └─ 콘텐츠 계획, 글 관리

Park.O: Ops Manager
  └─ 인프라 모니터링, 비용 최적화
```

### What (뭐하는가)

```
Atlas의 역할:
  ✅ 팀 진행률 추적 (매일)
  ✅ 태스크 모니터링 (실시간)
  ✅ Blocker 이슈 해결
  ✅ 주간 리포트 (금요일)
  ✅ 자동화 관리

Kim.G의 역할:
  ✅ 게임 개발 지휘
  ✅ Cursor IDE 태스크 관리
  ✅ 기술 결정 (구현 방식)
  ✅ PR 코드 리뷰
  ✅ 버그 분석 & 해결

Lee.C의 역할:
  ✅ 콘텐츠 계획 (주간)
  ✅ Claude Code에 글 지시
  ✅ 글 검수 & 승인
  ✅ 자동화 게시
  ✅ 성과 분석

Park.O의 역할:
  ✅ 인프라 모니터링
  ✅ API 상태 확인
  ✅ 비용 분석 & 최적화
  ✅ 자동화 유지보수
  ✅ 긴급 장애 대응
```

### How (어떻게)

```
Atlas의 방식:
  • 타입: Session (지속적)
  • 모드: 일일 추적 (09:00-20:00)
  • 주기: 실시간 모니터링
  • 타임아웃: 1시간 비활동

Kim.G의 방식:
  • 타입: Session (지속적)
  • 모드: 실시간 대화
  • 주기: 일일 (09:00-18:00)
  • 타임아웃: 2시간 비활동

Lee.C의 방식:
  • 타입: Run (일회성)
  • 모드: 빠른 태스크
  • 주기: 주간 월-금
  • 타임아웃: 30분 (세션 자동 종료)

Park.O의 방식:
  • 타입: Session (지속적)
  • 모드: 모니터링 + 리포트
  • 주기: 일일 (09:00-17:00) + 금요일
  • 타임아웃: 3시간 비활동
```

### When (언제)

```
Atlas:
  • 아침 09:00: 팀 스탠드업
  • 10:00-17:00: 실시간 모니터링
  • 17:00-20:00: 일일 종료 리포트
  • 금요일 20:00: 주간 리포트

Kim.G:
  • 매일 09:00: 진행 상황 검토
  • 09:30: 우선순위 정렬
  • 10:00-17:00: 개발 지휘 & 태스크 관리
  • 17:30: 일일 완료 정리

Lee.C:
  • 월요일 10:00: 주간 콘텐츠 계획 (Session)
  • 화/수/목: 글 작성 & 검수 (Run × 3)
  • 금요일 17:00: 자동 게시 + 성과 분석 (Session)
  • 금요일 18:00: 주간 보고

Park.O:
  • 매일 09:00: 인프라 헬스 체크
  • 10:00-17:00: 모니터링 & 비용 추적
  • 17:00: 일일 상태 보고
  • 금요일 16:00: 주간 비용 분석 & 리포트
```

### Budget (예산)

```
월간 총 예산: $200

배분:
├─ Atlas (AI PM): $35/월
├─ Kim.G (Game): $35/월
├─ Lee.C (Content): $20/월 ← 업그레이드 (Flash $15 → Pro $20)
├─ Park.O (Ops): $25/월
└─ Reserve (예비): $85/월

분석:
✅ 총 비용: $200/월 (예산 내)
✅ 효율성: 각 매니저가 전문화된 모델 사용
✅ 안정성: 3단계 Fallback 체인으로 99.5% 가용성
✅ 유연성: 긴급 시 Reserve로 추가 비용 충당
```

### 성공 기준

```
Kim.G (게임 개발):
  ✅ 일일 2-3개 태스크 완료
  ✅ 0개의 Blocker 이슈 (또는 <1시간 내 해결)
  ✅ PR 24시간 내 검수 완료
  ✅ 월간 Phase 목표 달성 (예: Phase 3 50% 완성)

Lee.C (콘텐츠):
  ✅ 주간 3개 글 게시 (100% 목표)
  ✅ 모든 글 품질 검수 (오타/오류 0)
  ✅ SNS 자동 배포 성공률 100%
  ✅ 월간 15개 글 게시 (KPI)

Park.O (인프라):
  ✅ 시스템 가용성 99.5% 이상
  ✅ 평균 응답시간 <2초
  ✅ 월간 API 비용 ≤ 예산
  ✅ 긴급 이슈 <5분 내 대응

Atlas (PM):
  ✅ 팀 진행률 추적 (100% 정확도)
  ✅ 블로킹 이슈 <5분 내 Steve 보고
  ✅ 주간 리포트 매 금요일 18:00 제출
  ✅ 팀 생산성 20% 이상 증대
```

---

**마지막 업데이트**: 2026-02-28 by Atlas  
**상태**: ✅ 완성 (Rule 3, 인스턴트 태스크, 세션 설정, 최종 정리 포함)  
**다음 검토**: 월간 성과 분석 시 (2026-03-27)
