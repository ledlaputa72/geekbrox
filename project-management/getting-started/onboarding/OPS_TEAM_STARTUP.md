# 🔧 운영팀 스타트업 가이드 (30분)

> 새로운 운영팀 멤버를 위한 30분 온보딩

---

## 📋 30분 안에 해야 할 일

### ⏱️ 0-5분: 팀 이해하기
```
Team Lead: Park.O (Gemini 2.5 Pro - AI)
책임: 인프라, 예산, QA, 시장 조사
현재 상태: 월간 $200 예산 관리 중 (온트랙)
```

### ⏱️ 5-10분: 폴더 이해하기

```
teams/ops/
├── workspace/           ← 팀 문서 & 작업
│   ├── qa/             (QA 테스트)
│   │   └── QA_LOG.md   (버그 기록)
│   ├── testing/        (자동화 테스트)
│   │   └── test-reports/ (테스트 결과)
│   ├── research/       (시장 조사)
│   │   ├── api-database/ (API 조사)
│   │   └── game-research/ (게임 시장)
│   ├── monetization/   (수익화 전략)
│   ├── memory/         (팀 노트)
│   ├── sprints/        (주간 스프린트)
│   └── README.md       (팀 가이드)
│
└── project-management/ (전체 조직)
    ├── TEAM_WORKFLOWS.md
    ├── MASTER_ROADMAP.md
    └── reports/        (월간 리포트)
```

### ⏱️ 10-15분: 문서 읽기

**필수 (지금 읽으세요):**
1. [`teams/ops/README.md`](../README.md) - 팀 구조 & 책임
2. [`teams/ops/workspace/README.md`](./workspace/README.md) - 폴더 가이드
3. [`teams/ops/workspace/sprints/2026-W08-sprint-ops.md`](./workspace/sprints/2026-W08-sprint-ops.md) - 이번 주 일정

**강력 추천:**
4. [`project-management/OPERATION_MANUAL.md`](../../project-management/OPERATION_MANUAL.md) - 일일 운영
5. [`WORKFLOW_INTEGRATION.md`](../../WORKFLOW_INTEGRATION.md) - 워크플로우

### ⏱️ 15-20분: 담당 폴더 확인

```
당신의 역할 확인:
- QA 담당? → teams/ops/workspace/qa/ 확인
- 테스트 담당? → teams/ops/workspace/testing/ 확인
- 조사 담당? → teams/ops/workspace/research/ 확인
- 예산 담당? → project-management/MASTER_ROADMAP.md 확인

각 폴더의 README.md (또는 로그 파일) 읽기
```

### ⏱️ 20-25분: Team Lead 지시 받기

```
Park.O가 Telegram에서 지시할 때까지 대기

예: "Dream Collector v1.1 QA 테스트
     - 테스트 계획: test-plan.md 참고
     - 버그 발견시: QA_LOG.md에 기록
     - 리포트: 금요일까지"

→ 지시를 받으면 시작!
```

### ⏱️ 25-30분: 첫 번째 작업 시작

```
1. 담당 폴더로 이동 (qa/, testing/, research/ 등)
2. 기존 문서들 훑어보기 (로그, 계획, 보고서)
3. Team Lead의 첫 지시사항 준비
4. 작업 시작
```

---

## 🎯 첫 번째 작업 체크리스트

Team Lead가 지시했을 때:

- [ ] 지시사항을 3번 읽었다
- [ ] 관련 테스트 계획/가이드를 찾았다
- [ ] 요구사항이 명확하다
- [ ] 필요한 도구/접근권이 있다
- [ ] 작업을 시작할 수 있다

---

## 💬 소통 방법

### Telegram (Team Lead ↔ 팀원)

**받을 지시:**
```
"Dream Collector v1.1 QA 테스트
- 테스트 범위: 게임 UI 및 전투 시스템
- 테스트 계획: teams/ops/workspace/testing/test-plan.md 참고
- 버그 발견시: QA_LOG.md에 심각도와 함께 기록
- 완료 후: 테스트 리포트 작성 & 제출
- ETA: 금요일 오후 5시"
```

**해야 할 보고:**
```
✅ 완료: "QA 테스트 완료. 버그 5개 발견, 3개 해결 (2개는 P3): [리포트 링크]"
🔄 진행중: "QA 테스트 60% 진행, 내일 완료 예상"
🛑 블로커: "테스트 환경 접근 문제. 도움 요청합니다."
```

---

## 🔀 기본 워크플로우

```
1. Telegram에서 지시 받기
   "Dream Collector QA 테스트"
   ↓
2. 테스트 계획 확인
   teams/ops/workspace/testing/test-plan.md
   ↓
3. 테스트 실행
   - UI 테스트
   - 전투 시스템 테스트
   - 성능 테스트
   ↓
4. 버그 기록
   teams/ops/workspace/qa/QA_LOG.md
   예시:
   "버그: 전투 시작시 ATB gauge가 0으로 초기화 안됨
    심각도: P2 (높음)
    발견자: [당신]
    상태: 미해결"
   ↓
5. 테스트 리포트 작성
   teams/ops/workspace/testing/dream-collector-test-report.md
   - 총 테스트 케이스: 100
   - 통과: 95
   - 실패: 5
   - 버그: 3 해결, 2 미해결
   ↓
6. Telegram에 완료 보고
   "QA 완료: 버그 5개 발견 [리포트]"
```

---

## 📁 중요 파일 위치

| 파일 | 위치 | 용도 |
|------|------|------|
| **QA 로그** | `teams/ops/workspace/qa/QA_LOG.md` | 발견된 버그 기록 |
| **테스트 계획** | `teams/ops/workspace/testing/test-plan.md` | 테스트 범위 & 절차 |
| **테스트 리포트** | `teams/ops/workspace/testing/test-report.md` | 테스트 결과 |
| **연구 로그** | `teams/ops/workspace/research/RESEARCH_LOG.md` | 시장 조사 기록 |
| **게임 연구** | `teams/ops/workspace/research/game-research/` | 게임 시장 분석 |

---

## 📊 역할별 가이드

### 🔴 QA 담당자라면

```
1. teams/ops/workspace/qa/ 폴더 들어가기
2. QA_LOG.md 읽기 (과거 버그들 이해)
3. Team Lead의 테스트 지시 받기
4. 테스트 계획에 따라 테스트 실행
5. 발견된 버그를 QA_LOG.md에 기록
   - 버그 설명
   - 심각도 (P0/P1/P2/P3)
   - 재현 방법
6. 테스트 리포트 작성 (teams/ops/workspace/testing/)
7. Telegram에 완료 보고
```

### 🔵 테스트/연구 담당자라면

```
1. teams/ops/workspace/testing/ 또는 research/ 폴더
2. 기존 로그/문서 읽기
3. Team Lead의 지시사항 받기
4. 테스트/조사 실행
5. 결과를 로그 파일에 기록
6. 주간/월간 리포트 작성
7. Telegram에 보고
```

---

## ❓ 문제 해결

### 문제: "테스트 계획이 어디에 있나요?"
**해결:**
```
teams/ops/workspace/testing/dream-collector-test-plan.md
또는 teams/ops/workspace/testing/ 폴더의 관련 파일
```

### 문제: "버그를 어디에 기록하나요?"
**해결:**
```
teams/ops/workspace/qa/QA_LOG.md

형식:
## 버그: [제목]
- 심각도: P[0-3]
- 재현 방법: [단계]
- 기대 결과: [예상]
- 실제 결과: [현재]
- 발견자: [이름]
- 상태: 미해결/해결됨
```

### 문제: "누구에게 물어봐야 하나요?"
**해결:**
```
Team Lead: Park.O (Telegram)
전체 PM: Steve (Telegram)
```

---

## 📊 성공 기준

### 일일 기준
- ✅ 지시받은 테스트/조사 진행
- ✅ 발견사항을 로그에 기록
- ✅ Daily 진행 상황 보고

### 주간 기준
- ✅ 주간 목표 완료
- ✅ 버그/이슈 정확히 분류
- ✅ 주간 리포트 작성

### 월간 기준
- ✅ 월간 목표 달성
- ✅ 품질 문제 해결율 80% 이상
- ✅ 월간 리포트 제출

---

## 🎯 다음 30분

1. **지금**: 이 문서 읽기 ✅
2. **다음**: `teams/ops/README.md` 읽기
3. **그다음**: 담당 폴더 탐색 (qa/, testing/, research/)
4. **마지막**: Team Lead의 첫 지시 대기

---

**준비 완료? 이제 시작하세요! 🚀**

**Last Updated:** 2026-02-28  
**Status:** ✅ READY TO ONBOARD
