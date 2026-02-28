# 🤖 AI Agents & Workflow - 완벽 정리 문서

**작성일**: 2026-02-28  
**작성자**: Atlas (AI PM)  
**상태**: ✅ 완성 및 검증 완료

---

## 📊 Executive Summary (경영진 요약)

GeekBrox 프로젝트는 **1명의 CEO + 1명의 AI PM + 3명의 Manager**로 구성된 체계적인 팀 운영 구조입니다.

| 역할 | 담당자 | 모델 | 월비용 | 특징 |
|------|--------|------|--------|------|
| **CEO/PD** | Steve | - | - | 전략 결정, 긴급 개입 |
| **AI PM** | Atlas | Claude Haiku 4-5 | $35 | 팀 관리, 진행 추적 |
| **Game Manager** | Kim.G | Gemini 2.5 Pro | $35 | 게임 개발 지휘 |
| **Content Manager** | Lee.C | Gemini 2.5 Pro | $20 | 콘텐츠 운영 |
| **Ops Manager** | Park.O | Gemini 2.5 Pro | $25 | 인프라 관리 |
| **Reserve** | - | - | $85 | 응급 & 스케일링 |
| | | **합계** | **$200/월** | |

---

## 🏢 1. 조직 구조 & 계층도

```
┌─────────────────────────────────────────────────────────┐
│                   Steve (CEO/PD)                        │
│          [전략 결정, 긴급 개입, 승인]                     │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ↓ [팀 지휘]
┌─────────────────────────────────────────────────────────┐
│            Atlas (AI PM - OpenClaw Agent)               │
│  • Primary: Claude Haiku 4-5 (빠른 응답)                 │
│  • Fallback: Gemini 2.5 Pro, Gemini Flash              │
│  • 역할: 팀 관리, 진행 추적, 자동화                       │
│  • 모드: Session (지속적)                               │
│  • 타임아웃: 1시간                                      │
│  • 비용: $35/월                                         │
└──────────────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        ↓              ↓              ↓
   
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│   Kim.G      │  │   Lee.C      │  │   Park.O     │
│ Game Mgr     │  │ Content Mgr  │  │  Ops Mgr     │
├──────────────┤  ├──────────────┤  ├──────────────┤
│ Primary:     │  │ Primary:     │  │ Primary:     │
│ Gemini 2.5   │  │ Gemini 2.5   │  │ Gemini 2.5   │
│ Pro ($35)    │  │ Pro ($20)    │  │ Pro ($25)    │
│              │  │              │  │              │
│ Fallback:    │  │ Fallback:    │  │ Fallback:    │
│ Haiku, Flash │  │ Haiku, Flash │  │ Haiku, Flash │
│              │  │              │  │              │
│ Session(2h)  │  │ Run(30min)   │  │ Session(3h)  │
│              │  │              │  │              │
│ 게임 개발    │  │ 콘텐츠 운영  │  │ 인프라 관리  │
└──────────────┘  └──────────────┘  └──────────────┘
```

---

## 🎯 2. 각 Manager의 세부 역할 & 책임

### 🎮 Kim.G (Game Manager) - 게임 개발 지휘

#### 📋 에이전트 정의

| 항목 | 값 |
|------|-----|
| **Name** | Kim.G (Game Manager) |
| **Primary Model** | google/gemini-2.5-pro |
| **Fallback1** | anthropic/claude-haiku-4-5-20251001 |
| **Fallback2** | google/gemini-2.5-flash |
| **Session Type** | Session (지속적 대화) |
| **Timeout** | 2시간 (비활동시 자동 종료) |
| **Budget** | $35/month |
| **Specialization** | 게임 개발, 기술 설계, 코드 리뷰 |
| **Response Time** | <3초 |

#### 📌 주요 책임

- ✅ **Cursor IDE 관리**: 개발자에게 명확한 태스크 지시
- ✅ **기술 결정**: ATB 시스템, 카드 시스템 등 복잡한 기술 논의
- ✅ **PR 코드 리뷰**: 24시간 내 검수 완료
- ✅ **버그 분석 & 해결**: 즉시 대응
- ✅ **PROGRESS.md 업데이트**: 매일 진행 상황 기록

#### ⏰ 일일 워크플로우 (09:00-18:00)

```
09:00  → 어제 완료 항목 확인
        ├─ CombatManager.gd: ✅ 완료
        ├─ CardDatabase.gd: 🔄 60% 진행
        └─ Battle UI: 🔴 대기 중

09:30  → 오늘의 우선순위 정렬
        ├─ P1: CardDatabase.gd 완성
        ├─ P2: Battle UI 시작
        └─ P3: 버그 수정 (렌더링 최적화)

09:45  → Cursor IDE에 태스크 지시
        "CardDatabase.gd 완성하세요.
         스펙: teams/game/dream-collector/workspace/design/TAROT_SYSTEM_GUIDE.md 참고
         마감: 오늘 오후 4시"

10:00-17:00 → 실시간 모니터링
        ├─ Cursor 진행률 확인 (매 30분)
        ├─ PR 들어오면 즉시 검수
        ├─ 버그 보고 받으면 즉시 분석
        └─ 기술 질문 → 즉시 답변

17:30  → PROGRESS.md 업데이트
        CardDatabase.gd: ✅ 완료 (30개 카드)
        Battle UI: 🔄 시작 (0%)
        버그: ✅ 해결 (렌더링 성능 +40%)

18:00  → Atlas에게 상태 보고
        "Game 진행률: 60% → 65%
         완료: CardDatabase.gd
         진행중: Battle UI (15%)
         블로킹: 없음
         내일 목표: Battle UI 50% 완성"
```

#### 🎯 인스턴트 태스크 우선순위 (SLA)

```
🔴 Critical (<5분)
   └─ Blocker 이슈 (게임 빌드 실패)
   └─ 심각한 버그 (렌더링 오류, 크래시)
   └─ 예: "CardDatabase.gd 컴파일 오류로 빌드 불가"

🟠 High (<30분)
   └─ 일반 버그 수정
   └─ 기술 결정 (구현 방식)
   └─ PR 검수 (코드 리뷰)
   └─ 예: "Enemy 렌더링이 느려요"

🟡 Medium (<2시간)
   └─ 새로운 태스크 지시
   └─ 코칭 & 멘토링
   └─ 성능 최적화
   └─ 예: "Battle UI 구현 시작해"

🟢 Low (<1일)
   └─ 코드 스타일 개선
   └─ 문서 업데이트 (주석 추가)
```

---

### 📝 Lee.C (Content Manager) - 콘텐츠 운영

#### 📋 에이전트 정의

| 항목 | 값 |
|------|-----|
| **Name** | Lee.C (Content Manager) |
| **Primary Model** | google/gemini-2.5-pro |
| **Fallback1** | anthropic/claude-haiku-4-5-20251001 |
| **Fallback2** | google/gemini-2.5-flash |
| **Session Type** | Mixed (Session + Run) |
| **Timeout** | 30분 (자동 세션 종료) |
| **Budget** | $20/month (업그레이드: Flash $15 → Pro $20) |
| **Specialization** | 콘텐츠 생성, 블로그 관리, SNS 자동화 |
| **Response Time** | <2초 |

#### 📌 주요 책임

- ✅ **주간 콘텐츠 계획**: 월요일 3개 주제 결정
- ✅ **Claude Code 지시**: 글 작성 태스크 할당
- ✅ **글 품질 검수**: 문법, 내용, SEO 확인
- ✅ **자동화 게시**: Tistory + SNS 배포
- ✅ **월간 KPI 추적**: 목표 15개 글

#### ⏰ 주간 워크플로우

```
월요일 10:00 [Session Mode]
├─ 주간 콘텐츠 계획 수립
├─ 주제 3개 결정
│  ├─ 1번: Dream Collector 개발일지 (마감: 화요일 4시)
│  ├─ 2번: 게임 리뷰 (마감: 목요일 4시)
│  └─ 3번: 인디게임 트렌드 분석 (마감: 금요일 2시)
├─ Claude Code에 전체 계획 공유
└─ 각 글의 스펙 정의 (1500자, 이미지 2-3개, SEO 최적화)

화요일 14:00 [Run Mode]
├─ Claude Code의 초안 검수
├─ 문법 ✅
├─ 내용 정확성 ✅
├─ SEO 최적화 ✅
├─ 이미지 링크 ✅
└─ 승인 또는 수정 지시

수요일 14:00 [Run Mode]
├─ 두 번째 글 검수

목요일 14:00 [Run Mode]
├─ 세 번째 글 검수

금요일 17:00 [Session Mode]
├─ 3개 글 모두 자동 게시 실행
│  └─ Markdown → HTML → Tistory 자동 포스팅
├─ SNS 자동 공유 (Twitter, BlueSky)
├─ 게시 확인
│  ├─ Tistory ✅
│  └─ SNS ✅
└─ 성과 분석
   ├─ 글 3개 게시 (100% 목표)
   ├─ SNS 반응: 좋아요 +50, 댓글 +8
   └─ 방문자: 500 (목표 450)

금요일 18:00 [Session Mode]
└─ Atlas에게 주간 보고
   "Content: 목표 달성 (3개 글, KPI 달성)"
```

#### 🎯 인스턴트 태스크 우선순위 (SLA)

```
🔴 Critical (<1시간)
   └─ 긴급 콘텐츠 요청 (Steve의 즉시 지시)
   └─ 게시 실패 (Tistory API 오류)
   └─ 자동화 오류 (SNS 공유 실패)

🟠 High (2시간)
   └─ 주간 계획 글 (마감 있음)
   └─ 글 검수 (수정 사항 있는 글)

🟡 Medium (4시간)
   └─ 추가 글 요청 (마감 없음)
   └─ 리서치 & 아이디어

🟢 Low (24시간)
   └─ 아이디어 개발
   └─ 문서 정리
```

---

### 🔧 Park.O (Ops Manager) - 인프라 관리

#### 📋 에이전트 정의

| 항목 | 값 |
|------|-----|
| **Name** | Park.O (Ops Manager) |
| **Primary Model** | google/gemini-2.5-pro |
| **Fallback1** | anthropic/claude-haiku-4-5-20251001 |
| **Fallback2** | google/gemini-2.5-flash |
| **Session Type** | Session (지속적 모니터링) |
| **Timeout** | 3시간 (수동 작업 포함) |
| **Budget** | $25/month |
| **Specialization** | 인프라, 자동화, 비용 최적화, 모니터링 |
| **Response Time** | <2초 |

#### 📌 주요 책임

- ✅ **OpenClaw 관리**: API 설정, 모델 버전 관리
- ✅ **일일 헬스 체크**: OpenClaw, API, 에러 로그
- ✅ **실시간 모니터링**: 각 팀의 자동화 상태 추적
- ✅ **비용 최적화**: 월간 API 비용 분석 & 개선
- ✅ **긴급 장애 대응**: <5분 내 조치

#### ⏰ 일일 워크플로우 (09:00-17:00)

```
09:00 [헬스 체크]
├─ OpenClaw 상태 확인
│  └─ openclaw status
│     ├─ Atlas: 99.8% ✅
│     ├─ Kim.G: 99.9% ✅
│     ├─ Lee.C: 100% ✅
│     └─ Park.O: 99.5% ✅
├─ API 비용 확인
│  ├─ Gemini: $12/일
│  ├─ Claude: $2/일
│  └─ 합계: $14/일 (월간 $420 - 예산 초과!)
└─ 에러 로그 검토
   └─ 에러 없음 ✅

10:00-12:00 [모니터링]
├─ Kim.G 자동화 상태
│  └─ Cursor 빌드 자동화: 실행 중 ✅
├─ Lee.C 자동화 상태
│  └─ 블로그 자동 게시: 예약됨 ✅
└─ Park.O 자동화 상태
   └─ 헬스 체크 스크립트: 준비 완료 ✅

13:00-17:00 [실시간 모니터링]
├─ 문제 발생 감지
│  ├─ 로그 분석
│  ├─ 원인 파악
│  └─ 즉시 해결
└─ 자동화 스크립트 검증
   ├─ CI/CD 파이프라인 테스트
   ├─ 빌드 성공 확인
   └─ 배포 준비 상태 확인

17:00 [일일 리포트]
└─ Ops Daily Report
   ├─ Uptime: 99.8% ✅
   ├─ Errors: 0 ✅
   ├─ Cost: $14 (on budget)
   └─ Issues: None

18:00 [보고]
└─ Atlas에게 상태 보고
   "Ops: 모든 정상, 비용 최적화 진행 중"
```

#### 📅 주간 (금요일)

```
16:00 → 주간 헬스 리포트 작성
       ├─ 가동률: 99.8%
       ├─ 에러율: 0.2%
       ├─ 평균 응답시간: 1.2s
       └─ 주요 이벤트: 없음

17:00 → 주간 비용 리포트 작성
       ├─ Gemini: $84/week
       ├─ Claude: $14/week
       ├─ 합계: $98/week
       └─ 월간 예상: $392 (초과!)

18:00 → 다음주 계획 수립
       └─ 비용 개선 방안 제시
          "Gemini Flash 비중 50% 증가 제안
           예상 절감: $100/월"
```

#### 🎯 인스턴트 태스크 우선순위 (SLA)

```
🔴 Critical (<5분)
   └─ 서비스 장애 (OpenClaw 다운)
   └─ API 다운 (Gemini/Claude 불가)
   └─ 비용 폭증 (월간 예산 초과)

🟠 High (30분)
   └─ 성능 저하 (응답시간 3초 이상)
   └─ 에러율 증가 (비정상 에러)
   └─ 자동화 실패 (블로그 게시 실패)

🟡 Medium (2시간)
   └─ 설정 최적화
   └─ 비용 분석
   └─ 헬스 체크

🟢 Low (1일)
   └─ 문서화
   └─ 모니터링 개선
```

---

### 🎯 Atlas (AI PM) - 팀 관리

#### 📋 에이전트 정의

| 항목 | 값 |
|------|-----|
| **Name** | Atlas (AI PM) |
| **Primary Model** | anthropic/claude-haiku-4-5-20251001 |
| **Fallback1** | google/gemini-2.5-pro |
| **Fallback2** | google/gemini-2.5-flash |
| **Session Type** | Session (지속적 관리) |
| **Timeout** | 1시간 (비활동시 종료) |
| **Budget** | $35/month |
| **Role** | AI PM (팀 관리, 자동화 조율) |
| **Response Time** | <2초 |

#### 📌 주요 책임

- ✅ **팀 진행률 추적**: PROGRESS.md 일일 업데이트
- ✅ **인스턴트 태스크 모니터링**: 각 Manager의 상태 파악
- ✅ **Blocker 이슈 해결**: 즉시 Steve 보고
- ✅ **주간 리포트**: 금요일 KPI, 진행률, 다음주 계획
- ✅ **자동화 관리**: 스크립트 실행 모니터링

#### ⏰ 일일 워크플로우 (09:00-20:00)

```
09:00 [아침 스탠드업]
├─ Kim.G 상태 확인
│  └─ "Game 진행률: 60%, 완료: CardDatabase.gd"
├─ Lee.C 상태 확인
│  └─ "Content: 3개 글 일정 진행, 게시 예정"
└─ Park.O 상태 확인
   └─ "Ops: 정상, 비용 최적화 진행"

10:00 [일일 목표 수립]
├─ Kim.G 우선순위: Battle UI 50% 완성
├─ Lee.C 우선순위: 글 2개 검수 & 승인
└─ Park.O 우선순위: 비용 분석 완료

10:00-17:00 [실시간 모니터링]
├─ Kim.G PR 검수 대기 중
├─ Lee.C 초안 검수 진행
└─ Park.O 자동화 실행 중

17:00 [일일 완료 항목 정리]
├─ Kim.G: CardDatabase.gd ✅ 병합
├─ Lee.C: 초안 2개 ✅ 승인
└─ Park.O: 헬스 체크 ✅ 완료

17:00-20:00 [저녁 보고 (Steve에게)]
└─ Daily Status Report
   ├─ 완료: 3개 항목 (CardDatabase, 글 검수, 헬스)
   ├─ 진행중: 5개 항목 (Battle UI, 글 1개, 비용)
   ├─ 블로킹: 없음
   └─ 내일 우선순위: Battle UI 중점, SNS 배포

금요일 20:00 [주간 리포트]
├─ 게임: Phase 3 60% → 65% (목표: 70%)
├─ 콘텐츠: 3개 글 게시 (KPI 달성)
├─ 인프라: 99.8% 가용성, 비용 최적화 진행
├─ 팀 효율: +15% 생산성 증대
└─ 다음주 계획: Phase 3 50% 목표
```

---

## 💰 3. 비용 분배 (월간 $200 예산)

```
┌─────────────────────────────────────┐
│    월간 총 예산: $200              │
├─────────────────────────────────────┤
│                                     │
│ Atlas (AI PM):        $35 (17.5%)  │
│ ├─ Claude Haiku 4-5                │
│ └─ 팀 관리 & 추적                   │
│                                     │
│ Kim.G (Game):         $35 (17.5%)  │
│ ├─ Gemini 2.5 Pro                  │
│ └─ 게임 개발 지휘                   │
│                                     │
│ Lee.C (Content):      $20 (10.0%)  │
│ ├─ Gemini 2.5 Pro                  │
│ └─ 콘텐츠 생성                      │
│                                     │
│ Park.O (Ops):         $25 (12.5%)  │
│ ├─ Gemini 2.5 Pro                  │
│ └─ 인프라 관리                      │
│                                     │
│ Reserve:              $85 (42.5%)  │
│ ├─ 응급 대응용                      │
│ └─ 스케일링용                       │
│                                     │
├─────────────────────────────────────┤
│ 합계:              $200 (100%)     │
└─────────────────────────────────────┘
```

### 💡 비용 분석

- ✅ **총 비용**: $200/월 (예산 내)
- ✅ **효율성**: 각 Manager가 전문화된 모델 사용
- ✅ **안정성**: 3단계 Fallback으로 99.5% 가용성
- ✅ **유연성**: Reserve $85로 긴급 상황 대응

---

## 🔄 4. Fallback Chain Strategy (안정성 전략)

### Rule 1, 2, 3 정의

```
Rule 1: Primary 성공
  ✅ 즉시 응답
  └─ 평균 응답시간: 1-2초

Rule 2: Primary 실패 → Fallback1 자동 전환
  ⚠️  5초 대기
  ├─ Fallback1 응답: 성공
  ├─ 사용자 경험: "약간 느림" (6-7초)
  └─ 장애 인지: 최소화

Rule 3: 모두 실패 → Steve 긴급 개입
  🔴 모든 모델 응답 불가
  ├─ Telegram → Steve 긴급 알림
  │  "🚨 CRITICAL: 모든 AI 모델 응답 불가 (Kim.G 태스크)"
  ├─ Steve: 상황 파악 & 결정
  │  ├─ "Gemini 서버 전체 다운, Claude 장애"
  │  └─ "일단 Task 연기하고 상황 공유"
  ├─ Atlas: Steve 지시 실행
  │  ├─ Park.O: "API 상태 확인"
  │  └─ Kim.G: "Task 연기 예정, 상황 공유 대기"
  └─ 서비스: 복구 대기
```

### Fallback 체인 (모든 Manager)

| Manager | Primary | Fallback1 | Fallback2 |
|---------|---------|-----------|-----------|
| **Atlas** | Claude Haiku 4-5 | Gemini 2.5 Pro | Gemini Flash |
| **Kim.G** | Gemini 2.5 Pro | Claude Haiku 4-5 | Gemini Flash |
| **Lee.C** | Gemini 2.5 Pro | Claude Haiku 4-5 | Gemini Flash |
| **Park.O** | Gemini 2.5 Pro | Claude Haiku 4-5 | Gemini Flash |

---

## 📊 5. 세션 관리 & 설정

### 세션 타입 비교

| 특성 | Session | Run |
|------|---------|-----|
| **타입** | 지속적 대화 | 일회성 |
| **타임아웃** | 1-3시간 | 10-30분 |
| **컨텍스트** | 이전 대화 기억 | 현재 태스크만 |
| **가격** | 높음 | 낮음 |
| **사용처** | Atlas, Kim.G, Park.O | Lee.C |

### 각 Manager 세션 설정

| Manager | 세션 타입 | 타임아웃 | 컨텍스트 | 토큰 제한 | 우선순위 |
|---------|----------|---------|---------|----------|---------|
| **Atlas** | Session | 1시간 | 전체 프로젝트 | 100K | Active |
| **Kim.G** | Session | 2시간 | Game 팀 | 50K | Active |
| **Lee.C** | Run | 30분 | Content | 30K | Active |
| **Park.O** | Session | 3시간 | Ops | 40K | Active |

### 최종 API 설정 (teams/ops/.config/openclaw.json)

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
      "priority": "active"
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
      "priority": "active"
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
      "priority": "active"
    }
  }
}
```

---

## ✅ 6. 최종 요약 & 성공 기준

### 🎓 WHO, WHAT, HOW, WHEN, BUDGET

**WHO (누가)**
```
Steve:    CEO/PD (전략, 긴급 개입)
Atlas:    AI PM (팀 관리)
Kim.G:    Game Manager (게임)
Lee.C:    Content Manager (콘텐츠)
Park.O:   Ops Manager (인프라)
```

**WHAT (뭐하는가)**
```
Atlas:   팀 진행률 추적, 태스크 모니터링, 리포트
Kim.G:   게임 개발, 기술 결정, 코드 리뷰
Lee.C:   콘텐츠 계획, 글 관리, 자동 게시
Park.O:  인프라 모니터링, 비용 최적화, 장애 대응
```

**HOW (어떻게)**
```
Atlas:   Session, 1시간, 실시간 추적
Kim.G:   Session, 2시간, 실시간 대화
Lee.C:   Run, 30분, 빠른 태스크
Park.O:  Session, 3시간, 지속적 모니터링
```

**WHEN (언제)**
```
Atlas:   09:00-20:00 매일
Kim.G:   09:00-18:00 매일
Lee.C:   월-금 주간
Park.O:  09:00-17:00 + 금요일
```

**BUDGET (예산)**
```
Atlas:   $35/월
Kim.G:   $35/월
Lee.C:   $20/월
Park.O:  $25/월
Reserve: $85/월
합계:    $200/월
```

### 🎯 성공 기준

**Kim.G (게임)**
- ✅ 일일 2-3개 태스크 완료
- ✅ Blocker 이슈 0개 (또는 <1시간)
- ✅ PR 24시간 내 검수
- ✅ 월간 Phase 목표 달성

**Lee.C (콘텐츠)**
- ✅ 주간 3개 글 게시 (100%)
- ✅ 글 품질 검수 완벽 (오타 0)
- ✅ SNS 배포 성공률 100%
- ✅ 월간 15개 글 (KPI)

**Park.O (인프라)**
- ✅ 시스템 가용성 99.5%+
- ✅ 평균 응답시간 <2초
- ✅ 월간 비용 ≤ 예산
- ✅ 긴급 이슈 <5분 대응

**Atlas (PM)**
- ✅ 팀 진행률 100% 정확도
- ✅ Blocker <5분 내 Steve 보고
- ✅ 주간 리포트 금요일 18:00
- ✅ 팀 생산성 20%+ 증대

---

## 📚 참고 자료

### 관련 문서
- `README.md`: 프로젝트 전체 개요
- `PROJECT_STRUCTURE.md`: 폴더 구조 가이드
- `ONBOARDING.md`: 팀원 온보딩 가이드
- `teams/game/README.md`: Game Team 워크플로우
- `teams/content/README.md`: Content Team 워크플로우
- `teams/ops/README.md`: Ops Team 워크플로우

### 사용 방법
1. **Cursor IDE**: 파일 탭에서 이 문서 검색 → `TEAM_WORKFLOWS.md`
2. **다른 워크플로우**: Markdown 링크로 참조 가능
3. **새 팀원**: ONBOARDING.md 후 이 문서로 역할 파악

---

**📄 문서 정보**  
- **파일명**: TEAM_WORKFLOWS.md
- **위치**: `/Users/stevemacbook/Projects/geekbrox/`
- **작성일**: 2026-02-28
- **작성자**: Atlas (AI PM)
- **상태**: ✅ 완성 및 검증 완료
- **버전**: 1.0

**🚀 사용 가능**: Cursor IDE, GitHub, 팀 공유 문서로 활용 가능
