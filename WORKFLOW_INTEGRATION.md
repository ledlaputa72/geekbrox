# 🔗 Telegram-Cursor-Claude 워크플로우 통합 가이드

> **⭐ 이것은 가장 중요한 문서입니다.** 
> 모든 팀원이 일관되게 작동하려면 이 워크플로우를 이해해야 합니다.

---

## 🎯 핵심 개념

GeekBrox의 작업 흐름은 **3가지 도구가 연결**되어 있습니다:

```
Telegram (의사전달)
  ↓↑
Cursor IDE / Claude Code (실행)
  ↓↑
GitHub (기록 & 버전관리)
```

---

## 🔄 전체 워크플로우 (End-to-End)

### 📌 Step 1: Team Lead가 Telegram에서 지시

```
Team Lead (예: Kim.G)
  ↓
Telegram 메시지
  📱 "Cursor IDE: CardDatabase.gd 작성하세요"
      - 요구사항: TAROT_SYSTEM_GUIDE.md 참고, 30개 카드 데이터
      - 완료 후: PR 생성"
  ↓
개발자가 Telegram에서 메시지 읽음
```

**예시:**
```
Team Lead: 
"CardDatabase.gd에 TAROT_SYSTEM_GUIDE.md의 30개 카드 데이터를 입력하세요.
완료 후: PR을 생성하고 이 채널에 링크를 올려주세요.
ETA: 내일 오후 5시"
```

---

### 📌 Step 2: 개발자가 Cursor IDE에서 작업

```
Cursor IDE 개발자
  ↓
teams/game/godot/dream-collector/scripts/CardDatabase.gd 파일 열기
  ↓
코드 작성
  ```gdscript
  // CardDatabase.gd
  extends Node
  
  const CARDS = [
    {
      "id": 1,
      "name": "The Magician",
      "cost": 1,
      "type": "Attack",
      "description": "Deal 3 damage"
    },
    // ... 30개 카드
  ]
  ```
  ↓
변경사항 저장
```

**중요:** 코드 작성 시 확인사항
- ✅ TAROT_SYSTEM_GUIDE.md 스펙 준수
- ✅ 코드 스타일 (CODE_REVIEW.md 참고)
- ✅ Git 커밋 메시지 명확하게

---

### 📌 Step 3: PR (Pull Request) 생성 & Telegram 보고

```
Cursor IDE 개발자
  ↓
GitHub에서 PR 생성
  ```
  Title: "feat: Add 30 cards to CardDatabase.gd"
  Description:
  - TAROT_SYSTEM_GUIDE.md 스펙 100% 준수
  - 30개 카드 ID 1-30 입력
  - 모든 필드 완성 (id, name, cost, type, description)
  ```
  ↓
Telegram에 PR 링크 올리기
  📱 "CardDatabase.gd PR 완성했습니다: [링크]"
```

---

### 📌 Step 4: Team Lead가 PR 리뷰 & 승인

```
Team Lead (예: Kim.G)
  ↓
GitHub PR 페이지에서 리뷰
  ✅ 코드 확인 (GDScript 문법, 스타일)
  ✅ 스펙 확인 (30개 맞나? 모든 필드 있나?)
  ✅ 테스트 (게임에서 작동하나?)
  ↓
Approve & Merge
  ↓
Telegram에서 개발자에게 피드백
  📱 "[이름], CardDatabase.gd 병합 완료! 다음 태스크: [다음 작업]"
```

---

## 🔀 3가지 워크플로우 시나리오

### 시나리오 1: 게임 개발 (Cursor IDE)

```
Telegram 지시
  📱 "ATB gauge 초기화 버그 수정하세요"
  ↓
Cursor IDE
  - teams/game/godot/dream-collector/scripts/CombatManager.gd 열기
  - Line 145 찾기
  - 버그 수정 코드 작성
  - 테스트 실행
  ↓
GitHub PR
  - Commit: "fix: Initialize ATB gauge to 0 on battle start"
  - PR: "Line 145에서 gauge 초기화 로직 추가"
  ↓
Telegram 완료 보고
  📱 "ATB gauge 버그 수정 완료: [PR 링크]"
```

---

### 시나리오 2: 자동화 (Claude Code)

```
Telegram 지시
  📱 "Claude Code: 빌드 성능 테스트 스크립트 작성하세요"
  ↓
Claude Code
  - teams/game/godot/build-performance-test.py 작성
  - 요구사항:
    1. Godot 프로젝트 빌드
    2. 성능 메트릭 수집
    3. 결과를 build-report.txt 저장
  ↓
GitHub PR
  - Commit: "feat: Add build performance testing script"
  - PR: "Godot 빌드 성능 측정 스크립트 추가"
  ↓
Telegram 완료 보고
  📱 "빌드 스크립트 완성: [PR 링크]. 테스트 결과: [요약]"
```

---

### 시나리오 3: 블로그 콘텐츠 (Telegram 봇)

```
Team Lead (Lee.C) 지시
  📱 "이번 주 3개 블로그 글 작성하세요:
      1. 게임 리뷰
      2. 인디 게임 트렌드
      3. 개발 일지"
  ↓
Telegram 블로그 봇 사용 (@geekbrox_bot)
  - /start
  - 1️⃣ 블로그 제작
  - 1-1 🔍 자료조사 → 30초 대기
  - 1-2 ✍️ 글 생성 → Claude 작성 (3분)
  - 1-3 📋 초안 검수 → 팀장 승인
  - 1-4 🚀 포스팅 → Tistory 게시
  ↓
Telegram 완료 보고
  📱 "게임 리뷰 글 게시 완료: [블로그 링크]"
```

---

## 🔌 각 도구의 역할

| 도구 | 역할 | 사용 시기 |
|------|------|---------|
| **Telegram** | 의사전달 & 지시 | Team Lead → 개발자 지시, 진행 상황 보고 |
| **Cursor IDE** | 게임 코드 작성 | GDScript 게임 로직 구현 |
| **Claude Code** | 자동화 스크립트 | 빌드, 배포, 자동화 작업 |
| **GitHub** | 버전 관리 & 기록 | 모든 변경사항 추적 |
| **Telegram 봇** | 블로그 자동화 | 자료조사, 글생성, 포스팅 |

---

## 📝 Telegram 메시지 포맷 (표준화)

### Team Lead → 개발자 지시 (표준 포맷)

```
[역할] [작업명]: [상세 설명]

예시:
"Cursor IDE: CardDatabase.gd 작성
- 요구사항: TAROT_SYSTEM_GUIDE.md 30개 카드 입력
- 스펙: id, name, cost, type, description 모두 포함
- 완료 후: PR 생성 및 이 채널에 링크 올려주세요
- ETA: 내일 오후 5시"

또는:

"Claude Code: 빌드 최적화 스크립트
- 요구사항: Godot 프로젝트 빌드 및 성능 측정
- 출력: build-report.txt에 메트릭 저장
- 완료 후: PR 생성"
```

### 개발자 → Team Lead 보고 (표준 포맷)

```
[완료/진행중/블로커] [작업명]: [상태]

예시:
"✅ CardDatabase.gd 완료: [PR 링크]"

"🔄 ATB gauge 구현: 60% 완료, 내일 완료 예정"

"🛑 렌더링 최적화 블로커: 성능 측정이 필요합니다. 도움 요청합니다."
```

---

## 🎯 일관성 체크리스트

### 📋 Telegram 지시할 때
- [ ] 대상을 명확히 (Cursor IDE? Claude Code?)
- [ ] 요구사항을 구체적으로 작성
- [ ] 참고 문서 링크 포함 (예: TAROT_SYSTEM_GUIDE.md)
- [ ] 완료 후 어떻게 보고할지 명시 (PR? 메시지?)
- [ ] ETA 포함

### 📋 Cursor IDE에서 작업할 때
- [ ] 코드 작성 전: 요구사항 재확인
- [ ] 코드 스타일: CODE_REVIEW.md 준수
- [ ] Git commit: 명확한 메시지 작성
- [ ] PR: 변경사항 설명 상세히 작성
- [ ] Telegram: PR 링크와 함께 보고

### 📋 Claude Code에서 작업할 때
- [ ] 스크립트 작성: 주석 추가 & 단계별 실행
- [ ] 테스트: 로컬에서 먼저 테스트
- [ ] PR: 작동 확인 결과 첨부
- [ ] Telegram: 스크립트 사용법 설명

### 📋 Team Lead가 PR 리뷰할 때
- [ ] 코드 품질 확인 (문법, 스타일)
- [ ] 요구사항 충족 확인
- [ ] 기술적 문제 확인
- [ ] 병합 전: Telegram에서 최종 확인
- [ ] 병합 후: 다음 태스크 지시

---

## ⚙️ 예상 타이밍

```
08:00  - Steve/Atlas: 일일 계획 → Team Lead에 공유
        ↓
10:00  - Team Lead: Telegram에 지시 → 개발자에게 전달
        ↓
10:05  - 개발자: Telegram에서 지시 받음 → 작업 시작
        ↓
11:00  - 개발자: 첫 단계 완료 (예: 파일 생성, 기본 구조)
        ↓
14:00  - 개발자: 작업 완료 → PR 생성 → Telegram 보고
        ↓
14:30  - Team Lead: PR 리뷰 시작
        ↓
15:00  - Team Lead: 리뷰 완료 → 병합 또는 피드백
        ↓
15:30  - Telegram: "완료" 또는 "수정 요청"
        ↓
18:00  - 일일 마무리: 완료된 작업 총괄
```

---

## 🚨 문제 발생 시

### 개발자가 블로커를 만났을 때

```
개발자 → Telegram
"🛑 블로커: CardDatabase.gd에서 import 오류가 발생합니다.
Error: TAROT_SYSTEM_GUIDE.md를 못 찾았습니다."

Team Lead
"TAROT_SYSTEM_GUIDE.md는 teams/game/workspace/design/02_core_design/에 있습니다.
경로: teams/game/workspace/design/02_core_design/TAROT_SYSTEM_GUIDE.md"

개발자
"감사합니다. 수정하고 다시 진행하겠습니다."
```

---

## 📊 일일 리포팅 예시

### Team Lead 일일 보고 (Telegram)

```
Atlas에게:
"Game Team Daily (2026-02-28)
✅ CardDatabase.gd 완료 (PR: #123)
🔄 ATB gauge 구현 중 (80%)
🛑 렌더링 성능 이슈 발견 → Claude Code에 최적화 요청함
📊 진행도: Phase 3 35% (어제 30%)
⚠️ 위험: 렌더링 성능이 개선되지 않으면 다음 주 일정 영향

내일 우선순위:
1. ATB gauge 완료
2. Battle UI 시작
3. 렌더링 최적화 스크립트 완료"
```

---

## ✅ 일관성 보장 방법

### 1️⃣ **메시지 포맷 표준화**
   - 모든 지시: [대상] [작업]: [상세]
   - 모든 보고: [상태] [작업]: [결과]

### 2️⃣ **PR 포맷 표준화**
   - Title: `type(scope): description` (예: `feat(game): Add CardDatabase`)
   - Description: 요구사항 체크리스트 포함

### 3️⃣ **Commit 메시지 표준화**
   - `feat:` - 새로운 기능
   - `fix:` - 버그 수정
   - `refactor:` - 코드 정리
   - `docs:` - 문서 추가

### 4️⃣ **리뷰 체크리스트**
   - [ ] 스펙 준수?
   - [ ] 코드 스타일?
   - [ ] 테스트 완료?
   - [ ] 문서 업데이트?

---

## 📚 참고 문서

- **게임팀:** `teams/game/workspace/guides/CODE_REVIEW.md`
- **콘텐츠팀:** `frameworks/blog_automation/MANUAL.md`
- **전체:** `project-management/TEAM_WORKFLOWS.md`

---

## 🎯 요약

```
Telegram (지시/보고)
    ↓
Cursor IDE / Claude Code / 봇 (실행)
    ↓
GitHub (기록)
    ↓
Telegram (완료 알림)
```

**이 사이클을 계속 반복합니다.**

---

**Last Updated:** 2026-02-28  
**Status:** ✅ CRITICAL DOCUMENT
