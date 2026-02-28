# 📋 일일 운영 매뉴얼

> GeekBrox의 일일, 주간, 월간 운영 절차

---

## ⏰ 일일 (Daily) 운영

### 아침 (08:00-09:00) - 계획 수립

**Steve PM / Atlas 역할:**
```
1. 어제 완료된 작업 확인
   - GitHub PR 병합 상태
   - Telegram 메시지 검토

2. 오늘의 우선순위 결정
   - 각 팀별 핵심 작업 3개씩
   - 블로킹 이슈 확인

3. 각 Team Lead에게 지시
   Telegram:
   "오늘 우선순위:
   1. ATB gauge 구현 완료
   2. CardDatabase 시작
   3. 블로거 글 3개 작성
   ...
   각 팀이 준비되면 알려주세요"
```

### 오전 (09:00-12:00) - 개발 진행

**각 Team Lead 역할:**
```
1. 팀원들에게 Telegram으로 지시 전달
   "Cursor IDE: CardDatabase.gd 작성
    요구사항: TAROT_SYSTEM_GUIDE.md 참고
    ETA: 오후 5시"

2. 진행 상황 모니터링
   - PR 생성 상황 확인
   - 블로커 발생 여부

3. 필요하면 스스로 코드 리뷰 시작
```

### 정오 (12:00-14:00) - 중점 리뷰

**Team Lead 역할:**
```
1. 오전에 생성된 PR 리뷰 시작
   - CODE_REVIEW.md 기준으로 평가
   - 요구사항 충족 확인

2. 피드백이 필요한 경우
   Telegram: "[이름], CardDatabase.gd에서 수정 요청합니다:
            1. 라인 45: snake_case 사용
            2. 라인 89: 주석 추가
            완료 후 다시 보내주세요"

3. 최종 승인된 PR은 병합
```

### 오후 (14:00-18:00) - 마무리 & 보고

**각 개발자/라이터:**
```
1. 수정 요청 사항 반영
   - Team Lead 피드백 적용
   - 다시 PR 업로드

2. 새로운 작업 진행
   - 최신 팀 진행 상황 확인
   - 다음 태스크 준비
```

**Team Lead:**
```
1. PR 병합 완료
2. 일일 진행 상황 Telegram에서 Atlas에 보고
   "Game Team Daily (2026-02-28)
   ✅ CardDatabase.gd 완료
   🔄 ATB gauge 80% 완료
   🛑 렌더링 성능 이슈
   내일 우선순위: ATB 완료, Battle UI 시작"
```

### 저녁 (18:00-19:00) - 일일 결산

**Atlas / Steve:**
```
1. 모든 팀의 일일 리포트 수집
   - Game Team Daily
   - Content Team Daily
   - Ops Team Daily

2. 리포트 통합
   "GeekBrox Daily Report (2026-02-28)
   
   ✅ Game: 2 PR 병합, Phase 3 35% 진행
   ✅ Content: 1 블로그 글 게시
   ✅ Ops: 버그 1개 해결, 시장 조사 진행
   
   ⚠️ Risk: 게임 렌더링 성능
   
   내일 Focus: ATB 시스템 완료"

3. Steve에게 최종 보고
```

---

## 📅 주간 (Weekly) 운영

### 월요일 (09:00-10:00) - 주간 계획 회의

**Steve + Atlas + Team Leads:**
```
Agenda:
1. 지난주 회고
   - 완료된 작업
   - 완료되지 않은 작업 (이유?)
   - 배운 점

2. 이번 주 계획
   - 각 팀의 목표 (3-5개 완료 목표)
   - 의존성 확인
   - 위험 요인

3. 우선순위 결정
   - P0 (이번 주 완료해야 함)
   - P1 (이번 달 완료)
   - P2 (나중에)
```

### 금요일 (16:00-17:00) - 주간 리뷰

**각 Team Lead:**
```
준비할 것:
1. 주간 스프린트 달성도
   teams/game/workspace/sprints/2026-W08-sprint.md
   
2. 완료된 PR 목록
   - 몇 개 병합했나?
   - 품질 문제는?

3. 다음 주 준비 사항
   - 블로커는?
   - 리소스 필요한 것?
```

**Sprint Review Meeting:**
```
1. Game Team
   "이번 주: 8개 PR 병합, Phase 3 35%
    목표 대비: 100% 달성 ✅
    위험: 렌더링 성능 개선 필요"

2. Content Team
   "이번 주: 12개 글 작성 & 게시
    목표 대비: 110% 달성 ✅
    다음주: 15개 목표"

3. Ops Team
   "이번 주: 5개 버그 해결, 시장 조사 진행
    목표 대비: 100% 달성 ✅"

4. 다음 주 우선순위 결정
```

---

## 🗓️ 월간 (Monthly) 운영

### 월초 (1-3일) - 월간 계획

**Steve + Atlas:**
```
1. 지난달 전체 회고
   - 게임 진행도
   - 콘텐츠 성과
   - 예산 사용 현황

2. 이번 달 목표 설정
   - Game: Phase 3 완료 (예상 50%)
   - Content: 50개 글 게시
   - Ops: 5개 버그 해결, 시장 조사 완료

3. 리소스 계획
   - 예산 배분
   - 팀 구성 변경 필요?
```

### 월말 (28-30일) - 월간 리포트

**각 Team Lead → Atlas:**
```
제출할 것:
1. 월간 성과 리포트
   - KPI 달성도
   - 문제점 & 해결책
   - 다음달 계획

2. 팀원 피드백
   - 누가 잘했나?
   - 개선할 점은?

3. 예산 정산
   - 실제 사용액
   - 절감할 방법?
```

**예시:**
```
Game Team Monthly Report (2026-02 / Feb 2026)

📊 KPI:
- Phase 3 진행도: 목표 25% vs 실제 35% ✅ (+40%)
- PR 병합: 목표 30개 vs 실제 35개 ✅ (+17%)
- 버그: 8개 발생, 6개 해결 (2개 미해결)

💰 예산:
- 모델 사용: $35 (계획대로)
- 추가 비용: 없음

📌 Blockers:
- 렌더링 성능 (Claude Code 스크립트로 해결 중)

👥 Team:
- Kim.G: Excellent (ATB 시스템 주도)
- Developers: Good (일정 준수)

📈 Next Month:
- Phase 3 완료 50% 목표
- Rendering 성능 개선
- Code coverage 80% 이상
```

---

## 📊 리포팅 템플릿

### 일일 리포트 (Daily)

```
Game Team Daily (2026-02-28)

✅ Completed:
- CardDatabase.gd (PR #123 병합)
- ATB gauge 초기화 버그 수정

🔄 In Progress:
- Battle UI (60%)
- Enemy AI logic (30%)

🛑 Blockers:
- Rendering performance issue 발견

📈 Progress:
- Phase 3: 35% (어제 30%)

⚠️ Risk:
- Rendering이 개선되지 않으면 일정 영향

➡️ Next Priority:
1. Battle UI 완료
2. Rendering optimization
3. Player death logic
```

### 주간 리포트 (Weekly)

```
Game Team Sprint Report (Week 08, 2026)

📊 Metrics:
- 목표 PR: 8개 → 실제: 8개 ✅
- 목표 버그: 2개 해결 → 실제: 3개 해결 ✅
- 목표 진행도: 30% → 실제: 35% ✅

📋 Completed:
- CardDatabase 완성
- ATB gauge 시스템
- 4개 버그 수정

🚧 In Progress:
- Battle UI
- Enemy AI
- Rendering optimization

🎯 Blockers:
- (없음)

📈 Health:
- 팀 생산성: ⭐⭐⭐⭐⭐
- 코드 품질: ⭐⭐⭐⭐
- 일정 준수: ⭐⭐⭐⭐⭐

➡️ Next Week Priorities:
1. Battle UI 완료 (우선 P0)
2. Rendering 성능 개선
3. Integration 테스트
```

### 월간 리포트 (Monthly)

```
Game Team Monthly Report (Feb 2026)

📈 KPI Achievement:
- Phase 3 Progress: Target 25% → Actual 35% ✅ (+40%)
- PR Merges: Target 30 → Actual 35 ✅ (+17%)
- Bug Resolution: Target 5 → Actual 6 ✅ (+20%)

💰 Budget:
- Model Cost: $35 (as planned)
- Additional: $0
- Savings: $0

🎖️ Highlights:
- ATB 시스템 완성
- Code quality 개선 (리뷰 기준 90% 충족)
- Team velocity 안정적

⚠️ Issues Encountered:
- Rendering performance (resolved with optimization script)
- 2 미해결 버그 (next month 우선순위)

👥 Team Performance:
- Kim.G: Excellent (leadership, technical decisions)
- Developer A: Good (consistency, quality)
- Developer B: Good (productivity)

💡 Lessons Learned:
- Code review를 더 철저히 하면 버그 50% 감소 가능
- 초기 스펙 리뷰가 중요 (수정 비용 줄임)

📈 Next Month Plan:
- Phase 3 완료 (50% → 100%)
- Rendering optimization 완료
- Integration & system tests
- Beta testing 준비
```

---

## 🔔 알림 기준

**즉시 보고해야 할 일:**
- 🔴 **Critical**: 일정에 1주 이상 영향 (예: 기술 선택 재검토)
- 🔴 **Critical**: 안전/보안 문제
- 🔴 **Critical**: 예산 초과

**일일 보고:**
- 🟠 **High**: PR 병합 완료
- 🟠 **High**: 새로운 블로커 발견
- 🟠 **High**: 일정 변경 필요

**주간 리포트에서:**
- 🟡 **Medium**: 작은 버그 수정
- 🟡 **Medium**: 마이너 코드 개선
- 🟡 **Medium**: 일정 대비 진행 현황

---

## 🚀 운영 개선

### 분기별 회고 (Quarterly Review)

```
매 분기마다 (3월, 6월, 9월, 12월):
1. 전체 팀 회고
   - 무엇이 잘 작동했나?
   - 무엇을 개선해야 하나?
   - 프로세스 변경 필요?

2. 조직 구조 검토
   - 팀 크기 적절?
   - 역할 배분 적절?
   - 새 팀 필요?

3. 예산 및 리소스
   - 비용 효율?
   - 도구/서비스 만족?
   - 새 투자 필요?
```

---

**Last Updated:** 2026-02-28  
**Status:** ✅ OPERATIONAL
