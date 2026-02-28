# 🎯 도구별 빠른 참조 (Copy-Paste용)

> 각 도구에 바로 붙여넣을 수 있는 간단한 가이드

---

# 🔨 Cursor IDE (Game Development)

## 빠른 설정

```
프로젝트 열기:
~/Projects/geekbrox/teams/game/godot/dream-collector

팀 리더: Kim.G (Telegram)
코드 스타일: teams/game/workspace/guides/CODE_REVIEW.md
```

## 작업 흐름

```
1️⃣ Telegram에서 지시 받기
   "Cursor IDE: CardDatabase.gd 작성
    요구사항: TAROT_SYSTEM_GUIDE.md 참고"

2️⃣ 요구사항 문서 읽기
   teams/game/workspace/design/dream-collector/02_core_design/TAROT_SYSTEM_GUIDE.md

3️⃣ 코드 작성
   teams/game/godot/dream-collector/scripts/CardDatabase.gd
   
4️⃣ 테스트 (Godot F5 실행)

5️⃣ Commit & Push
   git add . && git commit -m "feat(game): Add CardDatabase with 30 cards"

6️⃣ PR 생성
   GitHub에서 PR 생성 (description 작성)

7️⃣ Telegram 보고
   "완료: [PR #123]"
```

## 코드 스타일 빠른 참조

```gdscript
# ✅ Function 형식
func calculate_damage(card: Card, target: Enemy) -> int:
    """Calculate total damage with modifiers."""
    var base = card.attack_power
    var adjusted = base - (target.defense * 0.1)
    return max(0, int(adjusted))

# ✅ Variable 명명
var player_health: int = 100
var max_atb_gauge: float = 100.0
var card_list: Array[Card] = []

# ✅ Comment 형식
# Main game logic
func _ready() -> void:
    # Initialize systems
    setup_player()
    setup_enemies()
```

## Commit 메시지

```
feat(game): Add 30 cards to CardDatabase
- Implements TAROT_SYSTEM_GUIDE.md spec
- Adds cards with id, name, cost, type, description
- Tests in Godot editor pass ✅

fix(game): Fix ATB gauge initialization bug
- Gauge now resets to 0 on battle start
- Fixes issue where gauge carried over

refactor(game): Reorganize CardDatabase structure
- Move cards to separate categories
- Improve code readability
```

## 체크리스트

```
작업 전:
[ ] 요구사항 문서 읽음
[ ] CODE_REVIEW.md 확인
[ ] 기존 코드 구조 이해

작업 중:
[ ] 코드 작성
[ ] 주석 추가
[ ] GDScript 문법 맞음
[ ] Godot에서 테스트

작업 후:
[ ] Git commit (메시지 명확)
[ ] GitHub PR 생성
[ ] Telegram 보고
```

---

# 🤖 Claude Code (Automation Scripts)

## 빠른 설정

```
작업 폴더:
~/Projects/geekbrox/frameworks/blog_automation/
~/Projects/geekbrox/teams/game/

언어: Python 3.8+ 또는 Bash
버전 관리: GitHub
```

## 작업 흐름

```
1️⃣ Telegram에서 지시 받기
   "Claude Code: 빌드 성능 테스트 스크립트"

2️⃣ 스크립트 작성
   - 헤더/목적 명확히
   - 주석으로 섹션 설명
   - 오류 처리 포함

3️⃣ 로컬 테스트
   bash script.sh
   또는
   python3 script.py

4️⃣ Commit & Push
   git add . && git commit -m "feat(game): Add build-perf-test.sh"

5️⃣ PR 생성

6️⃣ Telegram 보고
   "스크립트 완료: [PR #123]"
```

## Python 템플릿

```python
#!/usr/bin/env python3
"""
script_name.py: Brief description

Detailed explanation of what this script does
"""

import os
from pathlib import Path

class MyTask:
    def __init__(self):
        """Initialize"""
        self.base_path = os.path.expanduser("~/Projects/geekbrox/")
    
    def run(self) -> str:
        """Execute main task"""
        print("Starting task...")
        # Your code here
        return "Result"

if __name__ == "__main__":
    task = MyTask()
    result = task.run()
    print(f"✅ Done: {result}")
```

## Bash 템플릿

```bash
#!/bin/bash
# script.sh: Brief description

set -e  # Exit on error

PROJECT_PATH="~/Projects/geekbrox"
OUTPUT_FILE="report.txt"

# Initialize
echo "Starting script..."

# Main logic
main() {
    echo "Processing..."
    # Your code here
    echo "Done!"
}

# Run
main
echo "✅ Output saved to $OUTPUT_FILE"
```

## Commit 메시지

```
feat(game): Add build-performance-test.sh
- Measures Godot build time, file size, memory
- Outputs to build-report.txt
- Tested locally ✅

feat(content): Add blog-automation-bot.py
- Implements topic→research→post workflow
- Integrates with Claude API
- Posts to Tistory

fix(game): Correct path in generate-cards.py
- Use absolute path with os.path.expanduser()
- Fixes 'file not found' error
```

## 체크리스트

```
작업 전:
[ ] 요구사항 명확히 이해
[ ] 스크립트 목적 정의

작업 중:
[ ] 헤더/문서 작성
[ ] 주석으로 설명
[ ] 오류 처리 추가

작업 후:
[ ] 로컬 테스트 완료
[ ] chmod +x (Bash)
[ ] Commit & PR
[ ] Telegram 보고
```

---

# 💬 Claude Chat (Design & Brainstorming)

## 빠른 설정

```
프로젝트 정보 (Chat에 붙여넣기):

프로젝트: Dream Collector RPG
팀: Game (Kim.G), Content (Lee.C), Ops (Park.O)
기술: Godot 4.x, GDScript, Python
Phase: 3 (전투 시스템, 카드 시스템)
```

## 대화 유형별 요청

### 1. 설계 검토

```
"Dream Collector의 ATB 전투 시스템 설계를 검토해주세요.

현재 설계:
- ATB 게이지: 초당 5씩 증가
- 카드 비용: 1~10 (게이지 소비)
- 적 AI: 랜덤 + 경험치 학습

문제점:
- 초당 5가 너무 빠른가?
- 비용 범위가 너무 넓은가?
- 적 난이도 조절이 명확한가?

개선 제안을 해주세요."
```

### 2. 아이디어 평가

```
"덱 빌딩 시스템 다양성 개선 아이디어:

현재 문제: 플레이어가 최고 성능 카드만 선택

제안:
1. 주간 메타 시스템 (매주 추천 카드 변경)
2. 덱 제약 (각 타입 최대 5개)
3. 약한 카드 보너스 (사용시 경험치 +50%)

각 안의 장단점과 구현 난이도는?"
```

### 3. 기술 문제

```
"Godot에서 카드 손상 계산 시스템 구현 중:

코드:
var damage = card.attack - enemy.defense

문제:
- 음수 손상 (방어 높으면)
- 치명타 미적용
- 상태이상(독) 미적용

어떻게 구조화해야 할까요?"
```

## 좋은 질문 구조

```
배경: 프로젝트 맥락 (1-2문장)
현재: 지금 상태 (구체적)
목표: 원하는 상태 (명확)
제약: 기술/예산/시간 제약
질문: 구체적인 조언 요청

예:
"꿈 수집가의 전투 시스템 난이도 조절을 설계 중입니다.

현재: 고정 난이도 (적 스탯 일정)

목표: 플레이어 성능에 따라 자동 조절

제약: 
- 구현 시간 2주
- 간단한 로직 (복잡하면 유지보수 어려움)

동적 난이도 조절 방법이 뭐가 있을까요?
각 방법의 구현 난이도와 효과는?"
```

## 체크리스트

```
좋은 질문:
[ ] 배경 정보 제공
[ ] 문제점 명확히 설명
[ ] 이미 시도한 것 언급
[ ] 구체적인 질문

피할 것:
[ ] "어떻게 하면 돼?" (너무 추상적)
[ ] 정보 없이 조언 요청
[ ] 전체 코드 작성 요청
```

---

# 🧠 Claude Core (Deep Analysis)

## 빠른 설정

```
프로젝트: GeekBrox
목표: 명확한 의사결정
방식: 깊이 있는 트레이드오프 분석
```

## 분석 요청 유형

### 1. 시스템 설계

```
"Dream Collector의 전투 시스템을 선택할 때 
깊이 있는 트레이드오프 분석을 해주세요.

선택지:
A. ATB (Active Time Battle)
B. Turn-Based

고려사항:
- 개발 일정 (8주)
- 팀 규모 (1명)
- 타겟 플레이어 (하드코어 팬)
- 장기 유지보수성

각 선택의:
1. 기술적 복잡도
2. 게임플레이 품질
3. 플레이어 경험
4. 향후 확장성
5. 유지보수 비용

을 깊이 있게 분석해주세요."
```

### 2. 아키텍처 설계

```
"Game 팀 폴더 구조의 최적화를 설계해주세요.

현재 구조:
teams/game/godot/dream-collector/
├── scripts/
├── scenes/
├── assets/
└── data/

문제:
- 데이터 파일 혼재
- 확장성 부족
- 팀 협업 어려움

요구사항:
- 현재: 1명 개발자
- 미래: 3명 팀
- 새 프로젝트 추가 가능

고려할 것:
1. Godot 모범사례
2. 파일 탐색 효율
3. Git 관리 용이성
4. 팀 협업 구조
5. 신입 온보딩

최적 구조를 설계해주세요."
```

### 3. 비즈니스 결정

```
"GeekBrox 예산 최적화 전략을 분석해주세요.

현재 (월 $200):
- Atlas: $35
- Kim.G: $35
- Lee.C: $35
- Park.O: $25
- 예비: $70

문제:
- 게임 개발 느림
- 콘텐츠 병목
- 새 도구 필요

선택지:
A. 게임팀에 +$30 투자
B. 콘텐츠팀에 +$30 투자
C. 새 도구 (Claude Code) 추가

분석:
1. 각 선택의 ROI
2. 병목 해결 효과
3. 장기 성장성
4. 위험도
5. 유연성

각 선택의 트레이드오프를 깊이 있게 분석해주세요."
```

## 좋은 분석 요청 구조

```
배경: 큰 그림
목표: 의사결정 필요
현황: 현재 상태와 문제
선택지: 고려할 옵션 (3-4개)
제약: 기술/예산/시간/조직 제약
기준: 의사결정 시 고려할 기준들
분석 깊이: 깊이 있는 트레이드오프

예:
"인디 게임의 수익화 모델을 정할 때 
깊이 있는 분석이 필요합니다.

배경: Dream Collector가 베타 1.0 완성 예정

목표: 출시 시 최적의 수익화 모델 선택

현황: 소규모 팀, 제한된 마케팅 예산

선택지:
A. 무료 + 인앱 결제
B. $4.99 단일 구매
C. 패스 (무료 + 월간 $4.99)
D. 조합 (기본 무료, 심화 $9.99)

제약:
- 플레이어: 모바일 하드코어 팬
- 예산: 마케팅 $500/월
- 팀: 출시 후 2명 운영

고려할 기준:
1. 초기 매출
2. 플레이어 만족도
3. 운영 비용
4. 경쟁 게임 분석
5. 확장 가능성

각 모델의 시나리오 분석과 
최적 선택을 추천해주세요."
```

## 체크리스트

```
분석 요청:
[ ] 배경/맥락 제시
[ ] 현황과 문제 명확히
[ ] 선택지 3개 이상
[ ] 제약사항 명시
[ ] 의사결정 기준 제시
[ ] 깊이 있는 분석 요청

피할 것:
[ ] 정보 부족
[ ] 추상적 질문
[ ] 선택지 없음
```

---

# 🔄 Git/GitHub Standards (모든 도구)

## Commit 메시지 포맷

```
<type>(<scope>): <subject>

<body>

<footer>

타입:
- feat: 새로운 기능
- fix: 버그 수정
- refactor: 코드 재정리
- docs: 문서
- test: 테스트
- perf: 성능

범위:
- game: 게임팀
- content: 콘텐츠팀
- ops: 운영팀
```

## PR Description 템플릿

```markdown
## 변경사항
한두 문장으로 설명

## 세부사항
- 항목 1
- 항목 2
- 항목 3

## 스펙 준수
- [ ] 요구사항 1
- [ ] 요구사항 2
- [ ] 요구사항 3

## 테스트
테스트 방법과 결과

## 관련 문서
- TAROT_SYSTEM_GUIDE.md
- #123
```

## 빠른 Commit 예제

```bash
# Cursor IDE
git add .
git commit -m "feat(game): Add CardDatabase with 30 cards
- Implements TAROT_SYSTEM_GUIDE.md spec
- Tests in Godot pass ✅"
git push
# → GitHub PR 생성

# Claude Code
git add .
git commit -m "feat(game): Add build-perf-test.sh
- Measures build metrics
- Outputs to build-report.txt
- Tested locally ✅"
git push
# → GitHub PR 생성
```

---

# 📋 Telegram 메시지 포맷

## Team Lead → 개발자

```
[도구] [작업]: [요구사항]
- 요구사항: [스펙]
- 참고: [참고 파일]
- 완료 후: [다음 단계]
- ETA: [마감]

예:
Cursor IDE: CardDatabase.gd 작성
- 요구사항: TAROT_SYSTEM_GUIDE.md, 30개 카드
- 참고: teams/game/workspace/guides/CODE_REVIEW.md
- 완료 후: PR 생성
- ETA: 내일 오후 5시
```

## 개발자 → Team Lead

```
[상태] [작업]: [결과]

상태:
✅ 완료
🔄 진행중 (%)
🛑 블로커

예:
✅ CardDatabase.gd: PR #123 완성
🔄 ATB 구현: 70% 완료, 내일 완료 예상
🛑 렌더링 성능: 도움 필요합니다
```

---

# 🚀 도구별 시작

## Cursor IDE 사용자
1. 프로젝트 경로: `~/Projects/geekbrox/teams/game/godot/dream-collector/`
2. 코드 스타일: `teams/game/workspace/guides/CODE_REVIEW.md`
3. Telegram에서 지시 받을 준비
4. [Cursor IDE 가이드](#-cursor-ide-game-development) 참고

## Claude Code 사용자
1. 스크립트 작성 준비
2. 로컬 테스트 계획
3. Python/Bash 템플릿 활용
4. [Claude Code 가이드](#-claude-code-automation-scripts) 참고

## Claude Chat 사용자
1. 프로젝트 정보 제공 (배경/맥락)
2. 구체적인 질문 구조화
3. 제안받은 방향 정리
4. [Claude Chat 가이드](#-claude-chat-design--brainstorming) 참고

## Claude Core 사용자
1. 깊이 있는 분석이 필요한 주제 선택
2. 제약사항과 의사결정 기준 제시
3. 트레이드오프 분석 요청
4. [Claude Core 가이드](#-claude-core-deep-analysis) 참고

---

**Last Updated:** 2026-02-28  
**Version:** 1.0  
**Status:** ✅ Ready to Copy-Paste
