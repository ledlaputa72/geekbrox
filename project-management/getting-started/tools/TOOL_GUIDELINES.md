# 🛠️ 개발 도구별 가이드라인

> Cursor, Claude (Chat/Code/Core), 그리고 기타 도구들이 일관성 있게 작업하기 위한 통합 가이드

---

## 📌 빠른 참조

| 도구 | 주 역할 | 사용 시기 | 가이드 |
|------|--------|---------|-------|
| **Cursor IDE** | 게임 코드 (GDScript) | 게임 개발 작업 | [Cursor Guidelines](#1-cursor-ide-guidelines) |
| **Claude Code** | 자동화 스크립트 (Python/Bash) | 빌드, 테스트, 배포 | [Claude Code Guidelines](#2-claude-code-guidelines) |
| **Claude Chat** | 문제 해결, 설계 상담 | 아이디어, 설계 검토 | [Claude Chat Guidelines](#3-claude-chat-guidelines) |
| **Claude Core** | 깊이 있는 분석 & 설계 | 복잡한 시스템 설계 | [Claude Core Guidelines](#4-claude-core-thinking-guidelines) |
| **Git/GitHub** | 버전 관리 | 모든 변경사항 추적 | [Git Standards](#git--github-standards) |

---

# 1. Cursor IDE Guidelines

> 게임 개발 코드 작성 전용

## 📋 프로젝트 컨텍스트

```
프로젝트: Dream Collector (로그라이크 덱빌딩 RPG)
엔진: Godot 4.x
언어: GDScript
경로: ~/Projects/geekbrox/teams/game/godot/dream-collector/

팀 리더: Kim.G (Gemini 2.5 Pro)
코드 리뷰: CODE_REVIEW.md 준수

현재 Phase: 3 (전투 시스템 구현)
```

## 🎯 작업 흐름

### 1단계: 지시 받기
```
Telegram에서 Team Lead (Kim.G)의 지시 수신
예: "CardDatabase.gd 작성
     요구사항: TAROT_SYSTEM_GUIDE.md 참고, 30개 카드 데이터
     완료 후: PR 생성"
```

### 2단계: 파일 열기
```
Cursor에서 해당 파일을 teams/game/godot/dream-collector/ 경로에서 열기
예: teams/game/godot/dream-collector/scripts/CardDatabase.gd
```

### 3단계: 코드 작성
```
1. 요구사항 문서 읽기 (TAROT_SYSTEM_GUIDE.md 등)
2. 기존 코드 스타일 확인 (CODE_REVIEW.md)
3. 코드 작성 시작
4. 자동 테스트 (Godot 실행)
5. 로컬 커밋
```

### 4단계: PR 생성
```
GitHub에서 PR 생성
- Title: "feat(game): [기능명]" 형식
- Description: 변경사항 상세 설명
- Reference: 관련 문서 링크

예: Title: "feat(game): Add 30 cards to CardDatabase"
    Description: "
    - TAROT_SYSTEM_GUIDE.md 스펙 100% 준수
    - 30개 카드 ID 1-30 입력
    - 모든 필드 완성 (id, name, cost, type, description)
    "
```

### 5단계: Telegram 보고
```
PR 생성 후 Telegram에 보고
"CardDatabase.gd 완료: [PR 링크]"

Team Lead가 리뷰 → 병합 → 다음 지시
```

## ✅ 코드 작성 체크리스트

### 필수 확인사항
- [ ] 요구사항 문서 읽음
- [ ] CODE_REVIEW.md의 스타일 준수
- [ ] GDScript 문법 정확
- [ ] 주석 추가됨 (복잡한 로직)
- [ ] 테스트 실행함 (Godot 플레이)
- [ ] 커밋 메시지 명확

### 코드 스타일 (teams/game/workspace/guides/CODE_REVIEW.md 참고)
```gdscript
# ✅ Good
func calculate_damage(card: Card, target: Enemy) -> int:
    """Calculate total damage considering card stats and enemy defense."""
    var base_damage = card.attack_power
    var defense_reduction = target.defense * 0.1
    return max(0, base_damage - defense_reduction)

# ❌ Bad
func calc_dmg(c, t):
    return c.atk - t.def
```

### Commit 메시지 포맷
```
feat: Add new feature
fix: Fix bug in system
refactor: Reorganize code structure
docs: Update documentation
test: Add test cases

예:
feat(game): Add 30 cards to CardDatabase
- Implements TAROT_SYSTEM_GUIDE.md specification
- Adds cards ID 1-30 with all required fields
- Maintains consistent naming convention
```

## 📂 주요 파일 경로

```
teams/game/godot/dream-collector/
├── scripts/              # GDScript 코드
│   ├── CardDatabase.gd
│   ├── CombatManager.gd
│   ├── UIManager.gd
│   └── ...
├── scenes/               # Godot 장면
│   ├── MainMenu.tscn
│   ├── BattleScreen.tscn
│   └── ...
├── assets/               # 게임 자산
│   ├── images/
│   ├── audio/
│   └── ...
└── project.godot         # Godot 프로젝트 설정
```

## 🚨 일반적인 오류 & 해결

### "파일을 못 찾았어요"
→ 항상 `teams/game/godot/dream-collector/` 경로에서 상대 경로로 열기

### "코드 스타일이 뭐예요?"
→ `teams/game/workspace/guides/CODE_REVIEW.md` 읽기

### "요구사항이 뭐예요?"
→ Telegram의 Team Lead 지시 다시 확인 또는 참고 문서 찾기

### "테스트는 어떻게 하나요?"
→ Godot IDE에서 F5 누르거나 Play 버튼으로 게임 실행

---

# 2. Claude Code Guidelines

> 자동화 스크립트 & 빌드 작업 전용

## 📋 프로젝트 컨텍스트

```
프로젝트: Dream Collector 자동화
주 스크립트: Python 3.8+, Bash
경로: ~/Projects/geekbrox/frameworks/blog_automation/
       ~/Projects/geekbrox/teams/game/

팀 사용: 모든 팀 (자동화 작업용)
스크립트 관리: GitHub (버전 관리)
```

## 🎯 작업 유형별 가이드

### 유형 1: 빌드 & 성능 테스트

**요청 예시:**
```
"Godot 프로젝트 빌드 성능 테스트 스크립트를 작성하세요.

요구사항:
1. teams/game/godot/dream-collector/ 프로젝트 빌드
2. 빌드 시간, 파일 크기, 메모리 사용량 측정
3. 결과를 build-report.txt에 저장
4. 실행: ./scripts/build-perf-test.sh

참고: 기존 scripts/build_test.sh 참고"
```

**작성 형식:**
```bash
#!/bin/bash
# 스크립트 목적 설명 (헤더)
# build_perf_test.sh: Measure Godot build performance

set -e  # 오류 발생시 중단

# 설정
PROJECT_PATH="~/Projects/geekbrox/teams/game/godot/dream-collector"
REPORT_FILE="build-report.txt"

# 함수 정의
measure_build_time() {
    local start_time=$(date +%s%N)
    # ... 빌드 실행 ...
    local end_time=$(date +%s%N)
    echo "Build time: $((($end_time - $start_time) / 1000000)) ms"
}

# 주 로직
echo "Starting build performance test..."
measure_build_time
echo "Report saved to $REPORT_FILE"
```

### 유형 2: 블로그 자동화

**요청 예시:**
```
"텔레그램 봇 메시지에서 블로그 주제를 받아 
자동으로 자료조사 → 글생성 → 포스팅하는 스크립트"
```

**작성 형식:**
```python
#!/usr/bin/env python3
"""
content_team_bot.py: Blog automation bot for Telegram

Workflow:
1. Receive topic from Telegram
2. Research topic (web scraping)
3. Generate blog post (Claude API)
4. Post to Tistory
"""

import asyncio
import json
from pathlib import Path

class BlogAutomationBot:
    def __init__(self):
        """Initialize bot with configuration"""
        self.config = self._load_config()
    
    async def process_topic(self, topic: str) -> str:
        """
        Process blog topic from start to publication
        
        Args:
            topic: Blog post topic
        
        Returns:
            Published post URL
        """
        # 1단계: 자료조사
        research = await self.research(topic)
        
        # 2단계: 글 생성
        post = await self.generate_post(topic, research)
        
        # 3단계: 포스팅
        url = await self.post_to_tistory(post)
        
        return url
```

### 유형 3: 데이터 생성 (카드, 몬스터 등)

**요청 예시:**
```
"85개 카드 JSON 파일 생성
경로: ~/Projects/geekbrox/teams/game/godot/dream-collector/data/cards/
형식: card_001.json, card_002.json, ... card_085.json
필드: id, name_ko, name_en, cost, type, description"
```

**작성 형식:**
```python
#!/usr/bin/env python3
"""
generate_cards.py: Generate card JSON files

Creates 85 card JSON files with proper naming and structure.
"""

import json
from pathlib import Path

def generate_cards(count: int = 85, output_dir: str = None):
    """
    Generate card JSON files
    
    Args:
        count: Number of cards to generate
        output_dir: Output directory path
    """
    output_path = Path(output_dir or "~/Projects/geekbrox/teams/game/godot/dream-collector/data/cards/")
    output_path.mkdir(parents=True, exist_ok=True)
    
    for i in range(1, count + 1):
        card_data = {
            "id": i,
            "name_ko": f"카드_{i:03d}",
            "name_en": f"Card_{i:03d}",
            "cost": (i % 5) + 1,
            "type": ["Attack", "Defend", "Magic"][i % 3],
            "description": f"Card description {i}"
        }
        
        file_path = output_path / f"card_{i:03d}.json"
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(card_data, f, ensure_ascii=False, indent=2)
        
        print(f"✅ Created {file_path.name}")

if __name__ == "__main__":
    generate_cards()
```

## ✅ 스크립트 작성 체크리스트

### 필수 확인사항
- [ ] 스크립트 목적이 명확한 헤더/문서 있음
- [ ] 주석으로 각 섹션 설명됨
- [ ] 오류 처리 있음 (try-except, set -e 등)
- [ ] 경로가 절대 경로 또는 명확한 상대 경로
- [ ] 로깅/프린트로 진행 상황 출력
- [ ] 실행 가능 권한 있음 (chmod +x)
- [ ] 테스트 실행함
- [ ] README 또는 헤더에 사용법 작성

### 코드 스타일
```python
# ✅ Good - 명확한 함수, 타입 힌트, 문서
def generate_cards(count: int = 85) -> list[dict]:
    """Generate card data with validation"""
    cards = []
    for i in range(1, count + 1):
        card = create_card(i)
        cards.append(card)
    return cards

# ❌ Bad - 불명확한 이름, 문서 없음
def gen(n):
    l = []
    for i in range(n):
        l.append(make(i))
    return l
```

## 📂 주요 스크립트 경로

```
frameworks/blog_automation/
├── run_post.sh              # 블로그 봇 실행
├── scripts/
│   ├── content_team_bot.py  # 콘텐츠팀 봇
│   └── ...
└── output/                  # 생성된 파일

teams/game/
├── scripts/build_test.sh    # 빌드 테스트
└── data/                    # 생성된 데이터
```

## 🚨 일반적인 오류 & 해결

### "경로를 못 찾았어요"
→ 절대 경로 사용: `~/Projects/geekbrox/...`
→ 또는 `os.path.expanduser()` 사용

### "권한 거부"
→ `chmod +x script.sh` 또는 `python3 script.py` 실행

### "모듈을 못 찾았어요"
→ 필수 라이브러리 설치: `pip install -r requirements.txt`

---

# 3. Claude Chat Guidelines

> 아이디어, 설계, 문제 해결 전용

## 📋 프로젝트 컨텍스트 (Chat에 붙여넣기)

```
프로젝트명: GeekBrox
팀 구조:
- Game Team (Kim.G): Dream Collector RPG 개발
- Content Team (Lee.C): 블로그 자동화 & SNS
- Ops Team (Park.O): QA, 시장 조사, 예산

현재 진행: Phase 3 (전투 시스템, 카드 시스템)
기술 스택: Godot 4.x (GDScript), Python, Bash

중요 문서:
- WORKFLOW_INTEGRATION.md: 팀 워크플로우
- teams/game/workspace/planning/PHASE3_NEXT_TASKS.md: 현재 진행
- teams/game/workspace/guides/CODE_REVIEW.md: 코드 스타일
```

## 🎯 대화 유형별 가이드

### 유형 1: 설계 검토 & 피드백

**좋은 요청:**
```
"Dream Collector의 ATB(Active Time Battle) 전투 시스템을 설계 중입니다.

현재 설계:
1. 각 캐릭터/적이 ATB 게이지 가짐
2. 게이지가 100에 도달하면 턴 시작
3. 플레이어가 카드 선택 → 비용 소비 → 게이지 초기화
4. 적이 AI로 자동 행동

문제점:
- 카드 비용 범위 (1-10?)
- 게이지 증가율 (초당 얼마?)
- 적 난이도 조절 방법?

조언을 해주세요."
```

**Claude의 역할:**
- 설계 검토
- 장단점 분석
- 개선 제안
- 기술적 구현 방안 제시

### 유형 2: 시스템 아이디어

**좋은 요청:**
```
"카드 게임의 deck building 시스템을 개선하고 싶습니다.

현재: 30개 카드 중 선택해서 덱 구성
문제: 플레이어가 항상 최고 성능 카드만 선택 → 다양성 부족

개선 아이디어:
1. 카드 주기성? (주간마다 다른 카드 추천)
2. 제약 조건? (각 타입 최대 5개 제한)
3. 보상 시스템? (비인기 카드 사용시 보너스)

어떻게 하면 좋을까요?"
```

**Claude의 역할:**
- 아이디어 평가
- 프로와 콘 분석
- 게임 밸런스 고려
- 구현 난이도 평가

### 유형 3: 기술 문제 해결

**좋은 요청:**
```
"Godot에서 GDScript로 카드 손상 계산 시스템을 구현 중인데,
다음 문제가 발생했습니다:

코드:
var damage = card.attack - enemy.defense

문제:
- 음수 손상 발생 (방어가 높으면)
- 치명타 확률이 일정하지 않음
- 상태 이상(독, 약화)이 적용 안됨

어떻게 수정해야 할까요?"
```

**Claude의 역할:**
- 코드 검토
- 논리 오류 발견
- 개선 방안 제시
- 최적화 제안

## ✅ Chat 대화 체크리스트

### 좋은 질문 특징
- [ ] 배경 정보 제공 (프로젝트, 맥락)
- [ ] 현재 상태 설명
- [ ] 문제점 명확히 함
- [ ] 이미 시도한 것 설명
- [ ] 구체적인 질문

### 피할 것
- ❌ "어떻게 하면 돼?" (너무 추상적)
- ❌ 전체 코드 요청 ("게임 만들어줄래?")
- ❌ 정보 없이 조언 요청

## 💡 효과적인 대화 팁

```
좋은 예:
"Dream Collector 카드 시스템에서 30개 카드를 어떻게 
분류/밸런싱할지 조언해주세요. 
현재: 모든 카드가 비슷한 강도
목표: 다양한 플레이 스타일 지원"

→ Claude가 구체적인 분류 방식 제안 가능

나쁜 예:
"카드 시스템 도와줄래?"

→ Claude가 무엇을 도와야 할지 불명확
```

---

# 4. Claude Core (Thinking) Guidelines

> 복잡한 설계, 깊이 있는 분석 전용

## 📋 프로젝트 컨텍스트 (Core에 붙여넣기)

```
프로젝트: GeekBrox - Dream Collector (로그라이크 덱빌딩 RPG)

조직 구조:
- Steve PM (의사결정)
- Atlas (AI PM - OpenClaw)
- 3개 팀 (Game/Content/Ops), 각각 AI Lead (Gemini 2.5)

Phase 3 핵심 결정:
- 전투 시스템: ATB vs Turn-Based (2026-03-03 마감)
- 카드 풀: 30+ 카드 설계
- 난이도 밸런싱

제약사항:
- 월 예산: $200
- 팀 규모: 소규모 (각 팀 1-2명)
- 개발 속도: 주간 스프린트 기반
```

## 🎯 사용 사례

### 사례 1: 복잡한 시스템 설계

**요청:**
```
"Dream Collector 전투 시스템 결정을 도와주세요.

선택지:
1. ATB (Active Time Battle)
   - 실시간 게이지 기반
   - 더 빠른 게임 플레이
   - 구현 복잡도: 높음

2. Turn-Based (턴제)
   - 전략적 깊이
   - 구현 간단
   - 느린 게임 플레이

고려사항:
- 개발 일정 (8주)
- 팀 규모 (개발자 1명)
- 타겟 플레이어 (하드코어 로그라이크 팬)
- 모바일 호환성

각 선택의 트레이드오프를 깊이 있게 분석해주세요."
```

**Claude Core의 역할:**
- 깊이 있는 트레이드오프 분석
- 장기적 영향 고려
- 숨겨진 복잡성 파악
- 의사결정 프레임워크 제공

### 사례 2: 아키텍처 설계

**요청:**
```
"Game 팀의 폴더 구조를 설계 중입니다.

현재: teams/game/godot/dream-collector/
      ├── scripts/
      ├── scenes/
      ├── assets/
      └── data/

문제:
- 데이터 파일 (card, monster, balance)이 섞임
- 팀원이 찾기 어려움
- 다른 프로젝트로 확장시 복잡

최적 구조를 설계해주세요.
고려사항:
- Godot 프로젝트 구조 모범사례
- 팀 협업 (현재 1명, 나중에 3명)
- 새 프로젝트 추가시 확장성
- Git 관리 용이성"
```

**Claude Core의 역할:**
- 구조적 사고
- 확장성 고려
- 모범사례 적용
- 미래 요구사항 예측

### 사례 3: 비즈니스 결정 분석

**요청:**
```
"GeekBrox의 예산 할당을 최적화하고 싶습니다.

현재 (월 $200):
- Atlas (AI PM): $35
- Kim.G (Game Lead): $35
- Lee.C (Content Lead): $35
- Park.O (Ops Lead): $25
- 예비비: $70

문제:
- 게임 개발이 느려짐
- 콘텐츠 생성이 병목
- 새 도구 (Claude Code) 추가 필요

조사:
- 비용 효율 높은 모델은?
- 어느 팀에 더 투자?
- 예산 재할당 전략?

비용-효율 분석을 깊이 있게 해주세요."
```

**Claude Core의 역할:**
- 데이터 기반 분석
- 비용-효과 계산
- 장기 ROI 고려
- 위험 평가

## ✅ Core 대화 체크리스트

### 필요한 정보
- [ ] 큰 그림 (프로젝트 목표)
- [ ] 제약사항 (기술, 예산, 시간)
- [ ] 이미 고려한 옵션
- [ ] 의사결정 기준
- [ ] 취급할 수 없는 선택지

### 효과적인 표현
```
좋은 예:
"게임 난이도 시스템의 설계를 도와주세요.

배경: 플레이어마다 실력이 다름
목표: 모두가 즐거움을 느낌
제약: 동적 조절 로직 (복잡도 낮음)

고려할 옵션:
1. 초기 난이도 선택
2. 게임 중 동적 조절
3. AI 난이도 학습

각 옵션의 장단점과 구현 복잡도를
깊이 있게 분석해주세요."

→ Core가 깊이 있는 분석 가능

나쁜 예:
"게임을 어떻게 만들어?"

→ 너무 추상적, Core의 장점 활용 못함
```

---

# 5. Integration Standards (모든 도구 공통)

> 모든 도구가 따를 일관된 표준

## 🔗 워크플로우 (모든 도구)

```
Telegram (지시)
    ↓
Cursor IDE / Claude Code / Chat (작업)
    ↓
GitHub (커밋 & PR)
    ↓
Telegram (보고)
```

## 📝 표준 포맷

### 1. Telegram 메시지 포맷

**Team Lead → 개발자:**
```
[도구] [작업명]: [요구사항]
- 요구사항: [스펙 문서]
- 참고: [참고 파일]
- 완료 후: [다음 단계]
- ETA: [마감]

예:
"Cursor IDE: CardDatabase.gd 작성
- 요구사항: TAROT_SYSTEM_GUIDE.md 참고, 30개 카드
- 참고: 기존 code (PlayerStats.gd)
- 완료 후: PR 생성 및 이 채널에 링크
- ETA: 내일 오후 5시"
```

**개발자 → Team Lead:**
```
[상태] [작업명]: [결과]

상태 종류:
✅ 완료: 작업 끝남
🔄 진행중: 진행 중 (%)
🛑 블로커: 도움 필요

예:
"✅ CardDatabase.gd: [PR #123]"
"🔄 ATB 구현: 70% 완료, 내일 완료 예상"
"🛑 렌더링: 성능 이슈 발견, 도움 요청"
```

### 2. Git Commit 메시지 포맷

```
<type>(<scope>): <subject>

<body>

<footer>

타입:
- feat: 새로운 기능
- fix: 버그 수정
- refactor: 코드 재정리
- docs: 문서 추가/수정
- test: 테스트 추가
- perf: 성능 최적화

범위 (scope):
- game: 게임 팀
- content: 콘텐츠 팀
- ops: 운영 팀
- docs: 문서

예:
feat(game): Add ATB gauge initialization logic
- Initialize player gauge to 0 at battle start
- Set enemy gauge to 0 at battle start
- Add configuration for gauge speed

Fixes #45

---

fix(content): Correct blog automation tool path
- Update run_post.sh to correct framework location
- Fix relative path in content_team_bot.py

---

docs(game): Update CODE_REVIEW.md with new style guide
- Add GDScript naming conventions
- Add function signature examples
```

### 3. PR Description 포맷

```markdown
## 변경사항 요약
한두 문장으로 무엇을 변경했는지

## 세부사항
- 점 1
- 점 2
- 점 3

## 스펙 준수 확인
- [ ] 요구사항 1 충족
- [ ] 요구사항 2 충족
- [ ] 요구사항 3 충족

## 테스트
- 수행한 테스트 설명
- 결과 (Pass/Fail)

## 관련 문서/Issue
- TAROT_SYSTEM_GUIDE.md
- #123 (Issue)

예:

## 변경사항 요약
TAROT_SYSTEM_GUIDE.md 스펙에 따라 30개 카드를 CardDatabase.gd에 추가

## 세부사항
- 카드 ID 1-30 추가
- 모든 필드 완성 (id, name, cost, type, description)
- CODE_REVIEW.md 스타일 준수

## 스펙 준수 확인
- [x] 30개 카드 모두 입력
- [x] 모든 필드 유효
- [x] 스타일 가이드 준수

## 테스트
- Godot 에서 CardDatabase 로드 → Pass
- 카드 접근 가능 여부 확인 → Pass
```

## ⚙️ 파일 경로 표준

### 절대 경로
```
~/Projects/geekbrox/teams/game/godot/dream-collector/
~/Projects/geekbrox/frameworks/blog_automation/
```

### Cursor IDE (상대 경로)
```
./scripts/CardDatabase.gd        (같은 프로젝트 내)
../workspace/guides/CODE_REVIEW.md (프로젝트 외부)
```

### Claude Code (절대 경로)
```python
import os
path = os.path.expanduser("~/Projects/geekbrox/teams/game/...")
```

## 🔄 도구 간 핸드오프

### Cursor IDE → GitHub
```
1. Cursor에서 코드 작성
2. Git commit (명확한 메시지)
3. GitHub에서 PR 생성
4. PR description 작성
5. Telegram에 보고
```

### Claude Code → GitHub
```
1. Claude에서 스크립트 작성
2. 로컬 테스트
3. Git commit
4. GitHub에서 PR 생성
5. Telegram에 보고
```

### Claude Chat → 결정
```
1. Chat에서 아이디어 토론
2. 합의된 방향 정리
3. Cursor/Claude Code 지시서 작성
4. Team Lead에게 전달
5. 개발 시작
```

### Claude Core → 설계 문서
```
1. Core에서 깊이 있는 분석
2. 설계 문서 작성
3. 팀 검토
4. 최종 확정
5. 개발 진행
```

## 🎯 일관성 체크리스트 (모든 도구)

### 코드 일관성
- [ ] 변수명: snake_case (Python), camelCase (GDScript)
- [ ] 함수명: 동사 + 명사 (get_card_data)
- [ ] 주석: 영문 또는 한글 통일
- [ ] 포맷: 자동 포맷터 사용

### 커뮤니케이션 일관성
- [ ] Telegram 포맷 준수
- [ ] Commit 메시지 포맷 준수
- [ ] PR description 포맷 준수
- [ ] 상태 아이콘 일관 (✅ 🔄 🛑)

### 프로세스 일관성
- [ ] 모든 변경이 PR로 관리됨
- [ ] 모든 PR이 Telegram에 보고됨
- [ ] 모든 지시가 Telegram에서 시작됨
- [ ] 모든 완료가 GitHub에 기록됨

---

# 📌 도구별 체크리스트

## Cursor IDE
```
[ ] 요구사항 문서 읽음
[ ] CODE_REVIEW.md 확인함
[ ] 코드 작성 & 테스트
[ ] Commit 메시지 명확함
[ ] PR 생성 & description 작성
[ ] Telegram 보고
```

## Claude Code
```
[ ] 스크립트 목적 명확함
[ ] 주석/헤더 작성됨
[ ] 오류 처리 있음
[ ] 로컬 테스트 완료
[ ] Commit 메시지 명확함
[ ] PR 생성
[ ] Telegram 보고
```

## Claude Chat
```
[ ] 배경 정보 제공함
[ ] 문제점 명확함
[ ] 구체적인 질문함
[ ] 제안받은 방향 정리
[ ] 다음 단계 명확함
```

## Claude Core
```
[ ] 큰 그림 설명함
[ ] 제약사항 제시함
[ ] 고려할 옵션 제시함
[ ] 깊이 있는 분석 요청
[ ] 최종 의사결정 준비
```

---

# 🚀 시작하기

## 각 도구의 진입점

### Cursor IDE 사용자
→ [Cursor IDE Guidelines](#1-cursor-ide-guidelines) 읽기

### Claude Code 사용자
→ [Claude Code Guidelines](#2-claude-code-guidelines) 읽기

### Claude Chat 사용자
→ [Claude Chat Guidelines](#3-claude-chat-guidelines) 읽기

### Claude Core 사용자
→ [Claude Core Guidelines](#4-claude-core-thinking-guidelines) 읽기

### 모든 사람
→ [Integration Standards](#5-integration-standards-모든-도구-공통) 숙지

---

**Last Updated:** 2026-02-28  
**Version:** 1.0  
**Status:** ✅ Ready for Tool Integration
