# 🎮 Game Team - 게임 개발 팀

**팀 PM**: Atlas  
**팀장 (Lead)**: [팀장 이름 - 지정 예정]  
**현재 상태**: Phase 3 진행 중 (Combat System)

---

## 📊 팀 구조 및 업무 위임

```
Steve (PM)
  ↓
  └─ Atlas (팀 에이전트 PM)
      ↓ [경영진행 리뷰/승인]
      └─ Game Team Lead (팀장)
          ├─ Game Development (Cursor IDE)
          ├─ Asset Management (Cursor IDE)
          └─ Automation Tasks (Claude Code)
```

### 👤 역할 정의

| 역할 | 담당자 | 책임 | 보고 대상 |
|------|--------|------|---------|
| **Project Manager** | Steve | 전체 게임 프로젝트 전략/로드맵 결정 | - |
| **Team Agent (PM)** | Atlas | 팀 진행률 추적, 자동화 관리, 일일 업무 정리 | Steve |
| **Team Lead (팀장)** | [지정 예정] | 개발 우선순위 결정, 팀 내 업무 위임, 진행 상황 보고 | Atlas/Steve |
| **Developer** | Cursor IDE | 게임 코드 구현, 기술적 결정 | Team Lead |
| **Asset Manager** | Cursor IDE | 스프라이트, 배경, 애니메이션 제작 | Team Lead |
| **Automation** | Claude Code | 반복 작업 자동화 (빌드, 배포 등) | Team Lead |

---

## 📋 업무 위임 프로세스

### Steve → Atlas → Team Lead → Developers/Automations

#### 1️⃣ **Steve (PM)의 지시**
```
예: "Phase 3 ATB 전투 시스템 구현하자. 2주일 내에 완성 목표."

↓ Atlas가 받음
```

#### 2️⃣ **Atlas (팀 에이전트)**
- 업무 파악: 구현 가이드, 리소스, 타임라인 확인
- 팀장에게 위임: "Game Team Lead, Phase 3 구현 요청 들어왔습니다"
- 진행률 추적: 매일 progress.md 업데이트
- 블로킹 이슈 해결: 팀장이 막히면 Steve에게 보고

```markdown
[Atlas의 데일리 리포트]

**Phase 3 Progress (2026-02-27)**
- ATB Implementation: 25% (CombatManager.gd 시작)
- Issues: 없음
- Next: CardDatabase.gd 작성
- ETA: 2026-03-15
```

#### 3️⃣ **Game Team Lead (팀장)**
- 인스턴트 태스크 분배:
  - Cursor IDE: "ATB 시스템 구현하세요"
  - Cursor IDE: "카드 데이터베이스 만드세요"
  - Claude Code: "렌더링 최적화 스크립트 작성하세요"
- 진행 상황 모니터링: Cursor/Claude Code의 PR 리뷰
- 이슈 해결: 기술적 결정, 리소스 배분
- **보고**: Atlas에게 상태 업데이트

```markdown
[Team Lead의 상태 보고]

**Daily Standup (2026-02-28)**
- CombatManager.gd: ✅ 60% 완성
- CardDatabase.gd: 🔄 30% (시작)
- Blocker: None
- Risk: 렌더링 최적화 시간 예상보다 오래 걸릴 수 있음
```

#### 4️⃣ **Cursor IDE / Claude Code (개발자/자동화)**
- **Cursor IDE**: 게임 코드 구현 (Cursor Rules 따름)
  - 받은 태스크: "CardDatabase.gd에 30개 카드 데이터 입력"
  - 구현 → Pull Request
  - Team Lead 리뷰 후 병합
  
- **Claude Code**: 자동화 스크립트 작성 (Claude Rules 따름)
  - 받은 태스크: "빌드 최적화 스크립트 작성"
  - 작성 → PR 제출
  - Team Lead 검증

```gdscript
// Cursor IDE가 작성한 코드
// CardDatabase.gd

extends Node

const CARDS = [
  {
    "id": 1,
    "name": "Philosopher's Stone",
    "type": "Support",
    "cost": 2,
    "description": "Gain 1 permanent strength"
  },
  // ... 30개 카드
]

func get_card(id: int) -> Dictionary:
  return CARDS.filter(func(c): return c.id == id)[0]
```

---

## 🎯 현재 진행 중인 프로젝트

### Dream Collector (꿈 수집가)

| 항목 | 내용 |
|------|------|
| **상태** | Phase 3 진행 중 (Combat System) |
| **엔진** | Godot 4.x |
| **플랫폼** | 모바일 (Portrait 390×844px) |
| **장르** | Roguelike + Deck-building + Idle |
| **팀장** | [지정 예정] |

#### 📂 폴더 구조
```
dream-collector/
├── workspace/
│   ├── design/                    ← 기획 문서
│   │   ├── 01_vision/             ← 게임 비전
│   │   ├── 02_core_design/        ← 타로, GDD
│   │   ├── 03_implementation_guides/  ← 기술 명세
│   │   ├── 04_narrative_and_lore/ ← 스토리
│   │   ├── 05_development_tracking/  ← 개발 진행
│   │   └── _archive/              ← 과거 버전
│   │
│   ├── godot/                     ← 게임 코드 (Cursor IDE)
│   │   ├── autoload/
│   │   ├── scenes/
│   │   ├── scripts/
│   │   └── project.godot
│   │
│   └── art/                       ← 게임 에셋 (Cursor IDE)
│       ├── art_style/             ← 스타일 가이드
│       ├── sprites/
│       ├── backgrounds/
│       └── animations/
│
└── .cursorrules               ← Cursor IDE 규칙
```

#### 🔄 Phase 진행 상황

| Phase | 목표 | 상태 | Team Lead 담당 |
|-------|------|------|---|
| **1** | UI 12개 화면 | ✅ 완료 | 화면 구현 감독 |
| **2** | 스프라이트 & 애니메이션 | ✅ 완료 | 에셋 관리 |
| **3** | 전투 시스템 (ATB) | 🔄 진행 중 | ATB 구현 지휘 |
| **4** | 게임 폴리시 | ⏸️ 대기 | 향후 지시 대기 |
| **5** | 베타 테스트 | 🔲 미시작 | 향후 지시 대기 |

---

## 📝 Team Lead의 일일 업무 체크리스트

### 아침 (매일 시작 전)
- [ ] Atlas 메시지 확인 (어제 진행 상황)
- [ ] Cursor IDE PR 현황 확인
- [ ] Claude Code 자동화 태스크 상태 확인

### 오전 (개발 지휘)
- [ ] Cursor IDE 개발자에게 오늘의 태스크 분배
  - 예: "CardDatabase.gd 작성하세요" / "Enemy AI 로직 추가하세요"
- [ ] 기술적 의사결정 필요시 처리
- [ ] 블로킹 이슈 해결

### 오후 (모니터링 & 리뷰)
- [ ] Cursor IDE PR 리뷰 및 병합
- [ ] Claude Code 자동화 스크립트 테스트
- [ ] 진행률 업데이트 (`design/05_development_tracking/PROGRESS.md`)

### 저녁 (보고 & 계획)
- [ ] Atlas에게 상태 보고
  - 완료된 작업
  - 진행 중인 작업
  - 블로킹 이슈/위험도
- [ ] 내일 할 일 계획

---

## 🔄 업무 위임 예시

### 예시 1: ATB 전투 시스템 구현

```
Steve (PM)
  "Phase 3 ATB 시스템 2주일 내 완성"
  ↓
  
Atlas (Team Agent)
  "Game Team Lead, ATB 구현 요청 들어왔습니다.
   ATB_Implementation_Guide.md 참고하고 CombatManager.gd부터 시작하세요.
   매일 PROGRESS.md 업데이트 바랍니다."
  ↓
  
Game Team Lead (팀장)
  "Cursor IDE 개발자들에게 분배:
   - 태스크 1: CombatManager.gd (기본 구조) - 3일
   - 태스크 2: CardDatabase.gd (카드 데이터) - 2일
   - 태스크 3: Battle UI (전투 화면) - 4일
   - 태스크 4: Enemy AI (적 AI) - 3일
   
   Claude Code에게:
   - 자동화: 렌더링 최적화 스크립트
   - 자동화: 빌드 성능 테스트"
  ↓
  
Cursor IDE / Claude Code
  [각자 태스크 구현 + PR 생성]
```

### 예시 2: 블로킹 이슈 발생

```
Cursor IDE
  "CombatManager.gd 작성 중 ATB gauge 동기화 문제 발생"
  ↓
  
Game Team Lead
  "기술적 검토 → 솔루션 제시:
   'ATB gauge를 GameManager.gd에서 중앙 관리하세요'"
  ↓
  
Cursor IDE
  [수정 구현]
  ↓
  
Game Team Lead → Atlas
  "이슈 해결됨, 진행 속도 정상으로 복귀"
```

---

## 📊 Cursor Rules & Claude Rules

### Cursor IDE Rules (`.cursorrules`)
```
당신은 Dream Collector 게임의 개발자입니다.

책임:
- Godot 4.x 게임 코드 구현
- design/ 문서 참고하여 명세 준수
- PR로 변경사항 제출

Game Team Lead 지시에 따를 것:
- 받은 태스크: PROGRESS.md에서 "IN_PROGRESS" 섹션 확인
- PR 작성 전 코드 리뷰 체크리스트 확인
- 블로킹 이슈 발생시 Team Lead에 알림

제약사항:
- 직접 main branch에 push 금지 (PR 필수)
- design/ 문서 수정 금지 (Team Lead 승인 필수)
```

### Claude Code Rules
```
당신은 Dream Collector 게임의 자동화 엔지니어입니다.

책임:
- 반복 작업 자동화 스크립트 작성
- 빌드/배포 프로세스 자동화
- 성능 최적화 도구 개발

Game Team Lead 지시에 따를 것:
- tasks/AUTOMATION.md에서 큐 확인
- PR로 스크립트 제출
- 테스트 결과 보고

제약사항:
- 게임 로직 수정 금지 (Cursor IDE만 담당)
- main 브랜치 변경 금지 (PR 필수)
```

---

## 🚀 Instant Task 처리 (인스턴트 태스크)

### Team Lead이 Cursor/Claude Code에게 실시간으로 지시할 수 있는 형식

#### 형식 1: 즉시 구현 요청
```
Game Team Lead → Cursor IDE:
"CardDatabase.gd에 다음 30개 카드 데이터를 입력하세요.
 스펙: teams/game/dream-collector/workspace/design/02_core_design/TAROT_SYSTEM_GUIDE.md 참고
 완료 후: PR 생성"
```

#### 형식 2: 버그 수정
```
Game Team Lead → Cursor IDE:
"CombatManager.gd Line 145에서 ATB gauge 초기화 버그 수정 필요.
 증상: 전투 시작시 gauge가 0으로 초기화 안됨
 수정 후: PR + 테스트 결과 첨부"
```

#### 형식 3: 자동화 요청
```
Game Team Lead → Claude Code:
"build.sh 스크립트 작성 필요.
 요구사항:
  1. Godot 프로젝트 빌드
  2. 성능 벤치마크 실행
  3. 결과를 build/output/에 저장
 완료 후: PR"
```

---

## 📈 진행 상황 추적

### PROGRESS.md (Team Lead이 매일 업데이트)
```markdown
# Dream Collector Progress

## Today (2026-02-28)

### Completed
- ✅ CombatManager.gd 기본 구조 (Cursor)
- ✅ ATB gauge 시스템 (Cursor)

### In Progress
- 🔄 CardDatabase.gd (Cursor, 30% 완성)
- 🔄 Battle UI (Cursor, 15% 완성)

### Blocked
- 🛑 None

### Next (내일)
- Enemy AI 구현 시작
- UI 렌더링 최적화

### Risks
- 렌더링 성능 우려 (해결: Claude Code 최적화 스크립트 작성)
```

---

## 💬 커뮤니케이션 채널

| 대상 | 채널 | 용도 |
|------|------|------|
| **Steve** | Telegram (main session) | 주간 보고, 전략 결정 |
| **Atlas** | Telegram (Atlas session) | 일일 상태, 이슈 보고 |
| **Team Lead ↔ Cursor** | Cursor 내 댓글 | 태스크 지시, PR 리뷰 |
| **Team Lead ↔ Claude** | Claude Code 댓글 | 자동화 요청, 검증 |
| **GitHub** | Issues, PR | 공식 기록, 버전 관리 |

---

## 🎯 Success Criteria

**Team Lead의 성공은:**
- ✅ 팀 생산성 (일일 2-3개 태스크 완성)
- ✅ 품질 (코드 리뷰 기준 충족)
- ✅ 일정 준수 (Phase 진행 일정 맞추기)
- ✅ 위험 관리 (블로킹 이슈 최소화)

---

## 📞 도움말

**"뭐 해야 할지 모르겠어요" 할 때:**
1. design/05_development_tracking/PROGRESS.md 확인
2. 계획된 다음 태스크 확인
3. Cursor IDE에 지시
4. 완료되면 Atlas에 보고

**"문제가 생겼어요" 할 때:**
1. Team Lead에게 상황 설명
2. Team Lead가 기술 검토
3. 해결책 제시 또는 Steve에게 보고

---

**마지막 업데이트**: 2026-02-27 by Atlas  
**다음 검토**: 2026-03-03 (주간 리뷰)
