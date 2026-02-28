# 🤖 AI Agents & Workflow - 최종 정리 보고서

---

## 📊 1단계: 계층 구조

```
Steve (CEO/PD - 결정권자)
  ↓ [결정 & 지시]

Atlas (AI PM)
  ├─ Primary: Claude Haiku 4-5 ($35/월)
  ├─ Fallback1: Gemini 2.5 Pro
  ├─ Fallback2: Gemini Flash
  └─ 역할: 팀 관리, 진행 추적, 자동화
  
  ├─ Kim.G (Game Manager)
  │  ├─ Primary: Gemini 2.5 Pro ($35/월) ✅
  │  ├─ Fallback1: Claude Haiku 4-5 ✅
  │  ├─ Fallback2: Gemini Flash ✅
  │  └─ 역할: 게임 개발 지휘, 기술 결정
  │
  ├─ Lee.C (Content Manager)
  │  ├─ Primary: Gemini 2.5 Pro ($20/월) ✅ [업그레이드]
  │  ├─ Fallback1: Claude Haiku 4-5 ✅
  │  ├─ Fallback2: Gemini Flash ✅
  │  └─ 역할: 콘텐츠 운영, 글 작성
  │
  └─ Park.O (Ops Manager)
     ├─ Primary: Gemini 2.5 Pro ($25/월) ✅
     ├─ Fallback1: Claude Haiku 4-5 ✅
     ├─ Fallback2: Gemini Flash ✅
     └─ 역할: 인프라 관리, 비용 최적화
```

---

## 📋 2. 각 매니저의 세부 역할

### Atlas (AI PM) - 팀 관리

| 항목 | 내용 |
|------|------|
| **세션 타입** | Session (지속적) |
| **타임아웃** | 1시간 |
| **주요 업무** | 팀 진행률 추적, 인스턴트 태스크 모니터링, Blocker 이슈 해결 |
| **응답 시간** | <2초 |
| **우선순위** | Blocker > Steve 지시 > 일반 업무 |
| **특징** | 빠른 응답, PM 역할 중심 |

**일일 워크플로우:**
```
09:00 AM  → 아침 스탠드업 (각 팀 진행률 확인)
10:00 AM  → 일일 목표 수립
14:00-17:00 → 진행 추적 & 이슈 해결
17:00-20:00 → 저녁 보고 (Steve에게 전달)
금요일 20:00 → 주간 리포트 작성
```

---

### Kim.G (Game Manager) - 게임 개발 지휘

| 항목 | 내용 |
|------|------|
| **세션 타입** | Session (대화형) |
| **타임아웃** | 2시간 |
| **주요 업무** | Cursor IDE 관리, 기술 결정, PR 검수, 버그 해결 |
| **응답 시간** | <3초 |
| **우선순위** | Critical (Blocker) > High (버그) > Medium > Low |
| **특징** | 깊은 기술 사고, 상세 코드 리뷰 |

**일일 워크플로우:**
```
09:00 AM     → 어제 완료 항목 확인
09:30 AM     → 오늘의 우선순위 정렬 & Cursor에 태스크 지시
10:00-17:00  → 실시간 모니터링
              • PR 들어오면 즉시 검수
              • 버그 보고 받으면 즉시 분석
17:30 PM     → PROGRESS.md 업데이트
18:00 PM     → Atlas에게 상태 보고
```

**인스턴트 태스크 처리:**
```
요청 → 분석(Gemini 2.5 Pro) → Cursor 지시 
    → 모니터링 → PR 검수 → 병합
평균 소요시간: 2시간
Fallback 사용: 5% (필요시에만)
```

**인스턴트 태스크 우선순위 (SLA):**
```
🔴 Critical (<5분):    Blocker (빌드 실패, 심각한 버그)
🟠 High (<30분):       버그 수정, 기술 결정, PR 검수
🟡 Medium (<2시간):    새 태스크, 코칭
🟢 Low (<1일):         코드 스타일, 문서 업데이트
```

---

### Lee.C (Content Manager) - 콘텐츠 운영

| 항목 | 내용 |
|------|------|
| **세션 타입** | Mixed (Session + Run) |
| **타임아웃** | 30분 |
| **주요 업무** | 콘텐츠 계획, Claude Code 지시, 글 검수, 자동 게시 |
| **응답 시간** | <2초 |
| **우선순위** | Critical (긴급) > High (마감) > Medium > Low |
| **특징** | 빠른 처리, 저비용, 효율성 우선 |

**주간 워크플로우:**
```
월요일 10:00   → 주간 콘텐츠 계획 (3개 주제 결정) [Session]
화요일 14:00   → 초안 검수 & 승인 [Run]
수요일 14:00   → 초안 검수 & 승인 [Run]
목요일 14:00   → 초안 검수 & 승인 [Run]
금요일 17:00   → 자동화 스크립트로 Tistory+SNS 배포
금요일 18:00   → Atlas에게 주간 보고 [Session]
```

**인스턴트 태스크 처리:**
```
기획(Session, Gemini 2.5 Pro)
    ↓
Claude Code 지시(Run, Gemini 2.5 Pro)
    ↓
검수(Session, Gemini 2.5 Pro)
    ↓
자동 게시(Automation)
평균 소요시간: 2시간/글
```

**인스턴트 태스크 우선순위 (SLA):**
```
🔴 Critical (<1시간):   긴급 콘텐츠, 게시 실패
🟠 High (2시간):        주간 계획 글 (마감 있음)
🟡 Medium (4시간):      추가 글 요청 (마감 없음)
🟢 Low (24시간):        아이디어 개발, 문서 정리
```

---

### Park.O (Ops Manager) - 인프라 관리

| 항목 | 내용 |
|------|------|
| **세션 타입** | Session (모니터링) |
| **타임아웃** | 3시간 |
| **주요 업무** | OpenClaw 관리, 헬스 체크, 비용 최적화, 장애 대응 |
| **응답 시간** | <2초 |
| **우선순위** | Critical (장애) > High (에러) > Medium > Low |
| **특징** | 실시간 모니터링, 안정성 우선 |

**일일 워크플로우:**
```
09:00 AM      → 아침 헬스 체크 (5분)
                • OpenClaw 상태 확인
                • API 비용 확인
                • 에러 로그 검토
10:00-17:00   → 실시간 모니터링
                • 각 팀 자동화 모니터링
                • 에러 발생시 즉시 대응
17:00 PM      → 일일 리포트 정리
18:00 PM      → Atlas에게 상태 보고
```

**금요일 (추가):**
```
16:00 PM  → 주간 헬스 리포트 작성
17:00 PM  → 비용 분석 리포트 작성
18:00 PM  → 다음주 계획 수립
```

**인스턴트 태스크 처리:**
```
장애 감지 → 분석(로그) → 해결 조치 
        → 확인 → 보고
평균 소요시간: <5분 (응급 대응)
```

**인스턴트 태스크 우선순위 (SLA):**
```
🔴 Critical (<5분):    서비스 장애, API 다운, 비용 폭증
🟠 High (30분):        성능 저하, 에러율 증가
🟡 Medium (2시간):     설정 최적화, 비용 분석
🟢 Low (1일):          문서화, 모니터링 개선
```

---

## 💰 3. 비용 분배 (월간 $200 예산)

```
Total Budget: $200/month

분배:
├─ Atlas:       $35  (17.5%) - Claude Haiku 4-5 (빠른 응답)
├─ Kim.G:       $35  (17.5%) - Gemini 2.5 Pro (기술 결정)
├─ Lee.C:       $20  (10.0%) - Gemini 2.5 Pro (콘텐츠) ← 업그레이드
├─ Park.O:      $25  (12.5%) - Gemini 2.5 Pro (인프라)
└─ Reserve:     $85  (42.5%) - 응급 & 스케일링
────────────────────────────
합계:          $200 (100%)
```

**비용 분석:**
- ✅ 총 비용: $200/월 (예산 내)
- ✅ 효율성: 각 Manager가 전문화된 모델 사용
- ✅ 안정성: 3단계 Fallback으로 99.5% 가용성
- ✅ 유연성: 긴급시 Reserve $85로 추가 비용 충당

---

## 🔄 4. Fallback Chain 전략

### 장애 대응 프로세스

```
Rule 1: Primary 성공
  ✅ 즉시 응답
  └─ 평균 응답시간: 1-2초

Rule 2: Primary 실패 → Fallback1 자동 전환
  ⚠️ 5초 대기
  ├─ Fallback1 응답: 성공
  └─ 사용자 경험: "약간 느림" (6-7초)

Rule 3: 모두 실패 → Steve 긴급 개입
  🔴 모든 모델 응답 불가
  ├─ Telegram → Steve 긴급 알림
  │  "🚨 CRITICAL: 모든 AI 모델 응답 불가 (Kim.G 태스크)"
  ├─ Steve 상황 파악 & 결정
  ├─ Atlas: Steve 지시 실행
  └─ 대기: 서비스 복구
```

### Fallback 체인 (모든 Manager 동일)

| Manager | Primary | Fallback1 | Fallback2 |
|---------|---------|-----------|-----------|
| Kim.G | Gemini 2.5 Pro ✅ | Claude Haiku 4-5 ✅ | Gemini Flash ✅ |
| Lee.C | Gemini 2.5 Pro ✅ | Claude Haiku 4-5 ✅ | Gemini Flash ✅ |
| Park.O | Gemini 2.5 Pro ✅ | Claude Haiku 4-5 ✅ | Gemini Flash ✅ |

### 예시: Kim.G 요청 처리

```
1️⃣ Primary (Gemini 2.5 Pro)
   ├─ 대기: 2초
   └─ 응답: ✅ 성공 → 완료

2️⃣ Primary 실패 → Fallback1 (Claude Haiku)
   ├─ 대기: 5초 추가
   ├─ 응답: ✅ 성공
   └─ 사용자: "응답이 좀 느렸네"

3️⃣ Fallback1 실패 → Fallback2 (Gemini Flash)
   ├─ 대기: 5초 추가
   ├─ 응답: ✅ 성공
   └─ 사용자: "다 느리지만 작동함"

4️⃣ Rule 3: 모두 실패 (Gemini Flash도 다운)
   ├─ 감지: 모든 모델 응답 없음
   ├─ 알림: "🚨 Kim.G 요청 처리 불가"
   ├─ Steve: 상황 파악
   │  "Gemini 전체 다운, Claude 장애
   │   → Task 연기, 상황 공유"
   ├─ Atlas: 실행
   │  - Park.O: "API 상태 확인"
   │  - Kim.G: "Task 연기 예정"
   └─ 상황: 서비스 복구 대기
```

---

## 📊 5. 세션 관리 & 설정

### 세션 타입 비교

| 특성 | Session | Run |
|------|---------|-----|
| **타입** | 지속적 대화 | 일회성 |
| **타임아웃** | 1-3시간 | 10-30분 |
| **컨텍스트** | 이전 대화 기억 | 현재 태스크만 |
| **가격** | 높음 (유지 비용) | 낮음 (빠른 종료) |
| **사용처** | Atlas, Kim.G, Park.O | Lee.C |

### 각 Manager 세션 설정

| Manager | 세션 타입 | 타임아웃 | 컨텍스트 | 토큰 제한 | 우선순위 |
|---------|----------|---------|---------|----------|---------|
| **Atlas** | Session | 1시간 | 전체 프로젝트 | 100K | Active |
| **Kim.G** | Session | 2시간 | Game 팀 | 50K | Active |
| **Lee.C** | Run | 30분 | Content | 30K | Active |
| **Park.O** | Session | 3시간 | Ops | 40K | Active |

### 최종 API 설정

```json
{
  "agents": {
    "atlas": {
      "id": "atlas",
      "name": "Atlas PM",
      "type": "session",
      "model": {
        "primary": "anthropic/claude-haiku-4-5-20251001",
        "fallbacks": ["google/gemini-2.5-pro", "google/gemini-2.5-flash"]
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
        "fallbacks": ["anthropic/claude-haiku-4-5-20251001", "google/gemini-2.5-flash"]
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
        "fallbacks": ["anthropic/claude-haiku-4-5-20251001", "google/gemini-2.5-flash"]
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
        "fallbacks": ["anthropic/claude-haiku-4-5-20251001", "google/gemini-2.5-flash"]
      },
      "cost": {"budget": 25, "currency": "USD/month"},
      "timeout": 10800,
      "priority": "active"
    }
  }
}
```

---

## ✅ 6. 최종 요약 - Who, What, How, When, Budget

### Who (누가)

```
Steve: CEO/PD
  └─ 결정권자, 전략 결정, 긴급 개입

Atlas: AI PM
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
Atlas:
  ✅ 팀 진행률 추적 (매일)
  ✅ 태스크 모니터링 (실시간)
  ✅ Blocker 이슈 해결
  ✅ 주간 리포트 (금요일)

Kim.G:
  ✅ 게임 개발 지휘
  ✅ Cursor IDE 태스크 관리
  ✅ 기술 결정 (구현 방식)
  ✅ PR 코드 리뷰
  ✅ 버그 분석 & 해결

Lee.C:
  ✅ 콘텐츠 계획 (주간)
  ✅ Claude Code에 글 지시
  ✅ 글 검수 & 승인
  ✅ 자동화 게시
  ✅ 성과 분석

Park.O:
  ✅ 인프라 모니터링
  ✅ API 상태 확인
  ✅ 비용 분석 & 최적화
  ✅ 자동화 유지보수
  ✅ 긴급 장애 대응
```

### How (어떻게)

```
Atlas:
  • 타입: Session (지속적)
  • 모드: 일일 추적 (09:00-20:00)
  • 주기: 실시간 모니터링
  • 타임아웃: 1시간 비활동

Kim.G:
  • 타입: Session (지속적)
  • 모드: 실시간 대화
  • 주기: 일일 (09:00-18:00)
  • 타임아웃: 2시간 비활동

Lee.C:
  • 타입: Run (일회성)
  • 모드: 빠른 태스크
  • 주기: 주간 월-금
  • 타임아웃: 30분 (자동 종료)

Park.O:
  • 타입: Session (지속적)
  • 모드: 모니터링 + 리포트
  • 주기: 일일 (09:00-17:00) + 금요일
  • 타임아웃: 3시간 비활동
```

### When (언제)

```
Atlas:
  • 09:00: 팀 스탠드업
  • 10:00-17:00: 실시간 모니터링
  • 17:00-20:00: 일일 리포트
  • 금요일 20:00: 주간 리포트

Kim.G:
  • 매일 09:00: 진행 상황 검토
  • 09:30: 우선순위 정렬
  • 10:00-17:00: 개발 지휘 & 태스크
  • 17:30: 일일 완료 정리

Lee.C:
  • 월요일 10:00: 주간 계획 (Session)
  • 화/수/목: 글 작성 & 검수 (Run × 3)
  • 금요일 17:00: 자동 게시
  • 금요일 18:00: 주간 보고

Park.O:
  • 매일 09:00: 헬스 체크
  • 10:00-17:00: 모니터링
  • 17:00: 일일 보고
  • 금요일 16:00: 주간 비용 분석
```

### Budget (예산 $200/월)

```
배분:
├─ Atlas (AI PM): $35
├─ Kim.G (Game): $35
├─ Lee.C (Content): $20 ← 업그레이드
├─ Park.O (Ops): $25
└─ Reserve: $85

분석:
✅ 총 비용: $200/월 (예산 내)
✅ 효율성: 전문화된 모델 사용
✅ 안정성: 99.5% 가용성
✅ 유연성: Reserve로 응급 대응
```

---

## 🎯 7. 성공 기준

### Kim.G (게임 개발)
```
✅ 일일 2-3개 태스크 완료
✅ Blocker 이슈 0개 (또는 <1시간 내 해결)
✅ PR 24시간 내 검수 완료
✅ 월간 Phase 목표 달성
```

### Lee.C (콘텐츠)
```
✅ 주간 3개 글 게시 (100% 목표)
✅ 모든 글 품질 검수 (오타/오류 0)
✅ SNS 자동 배포 성공률 100%
✅ 월간 15개 글 게시 (KPI)
```

### Park.O (인프라)
```
✅ 시스템 가용성 99.5% 이상
✅ 평균 응답시간 <2초
✅ 월간 API 비용 ≤ 예산
✅ 긴급 이슈 <5분 내 대응
```

### Atlas (PM)
```
✅ 팀 진행률 추적 (100% 정확도)
✅ Blocker 이슈 <5분 내 Steve 보고
✅ 주간 리포트 매 금요일 18:00 제출
✅ 팀 생산성 20% 이상 증대
```

---

## 🎓 핵심 포인트

1. **모델 선택이 명확**
   - Atlas: 빠른 응답 (Claude Haiku)
   - Kim.G: 복잡한 기술 (Gemini 2.5 Pro)
   - Lee.C: 고급 콘텐츠 (Gemini 2.5 Pro, 업그레이드)
   - Park.O: 안정성 (Gemini 2.5 Pro)

2. **Fallback 전략이 견고**
   - 3단계 자동 전환 체인
   - Rule 3: Steve 수동 개입
   - 99.5% 가용성 보장

3. **인스턴트 태스크 SLA 명확**
   - Critical: <5분
   - High: 30분-2시간
   - Medium: 2-4시간
   - Low: 1일

4. **세션 관리 효율적**
   - Atlas/Kim.G/Park.O: Session (지속적)
   - Lee.C: Run (빠른 종료)

5. **예산 효율적**
   - $200/월로 전체 팀 관리
   - $85 예비비로 응급 대응
   - 각 Manager 전문화

---

**📄 문서 상태**: ✅ 완성 (2026-02-28)  
**📍 원본 위치**: `/Users/stevemacbook/Projects/geekbrox/AI_AGENTS_AND_WORKFLOW.md`  
**📊 이 요약**: `/Users/stevemacbook/Projects/geekbrox/AI_AGENTS_AND_WORKFLOW_SUMMARY.md` (신규)  

---

이제 Git 커밋 & 푸시 준비 완료! 📤
