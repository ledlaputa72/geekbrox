# 🎓 GeekBrox 초보자 온보딩 가이드

**새로운 팀원이 입사한 첫 날?**  
이 문서를 순서대로 따라하면 GeekBrox 프로젝트의 모든 것을 이해할 수 있습니다.

---

## 📋 온보딩 체크리스트 (3시간)

이 체크리스트를 따라하면 된다:

- [ ] **10분**: 이 문서 읽기
- [ ] **20분**: README.md 읽기 (프로젝트 개요)
- [ ] **20분**: PROJECT_STRUCTURE.md 읽기 (폴더 구조)
- [ ] **20분**: 자신의 팀 README 읽기 (teams/[team]/README.md)
- [ ] **30분**: 환경 설정 (.config/README.md 따라하기)
- [ ] **30분**: 자신의 첫 태스크 받기 & 시작하기
- [ ] **30분**: 동료 개발자 또는 Team Lead과 미팅

**총 3시간 후: 당신은 GeekBrox 팀원!** 🎉

---

## 🚀 Day 1 (입사 첫 날)

### 1단계: "우리 프로젝트가 뭔데?" (10분)

**읽을 문서**: [`README.md`](README.md)

**핵심 내용**:
- 📌 **프로젝트명**: GeekBrox (독립 게임 & 콘텐츠 개발 플랫폼)
- 🎯 **목표**: 인디 게임 개발 + 블로그 운영 자동화
- 🤖 **특징**: AI 에이전트 (Atlas)가 팀을 관리
- 🏢 **팀 구조**: Game Team, Content Team, Ops Team

**확인 사항**:
- [ ] 프로젝트의 핵심 목표를 설명할 수 있나?
- [ ] 3개 팀의 역할을 알나?
- [ ] Atlas가 무엇인지 알나?

---

### 2단계: "우리 폴더는 어떻게 조직화되었는데?" (20분)

**읽을 문서**: [`PROJECT_STRUCTURE.md`](PROJECT_STRUCTURE.md)

**핵심 개념**:

```
geekbrox/ 폴더를 5가지 카테고리로 나눔:

1️⃣ [에이전트] agents/        → AI PM (Atlas)
2️⃣ [자동화] frameworks/      → 반복 사용 가능한 솔루션
3️⃣ [스크립트] scripts/       → 자동화 실행 버튼
4️⃣ [문서] docs/              → 기술 가이드 & 매뉴얼
5️⃣ [프로젝트] teams/         → 실제 개발 (여기서 일함!)
```

**확인 사항**:
- [ ] 각 폴더가 뭐 하는 곳인지 알나?
- [ ] 폴더 이름만 봐도 뭐가 들어있을지 예측할 수 있나?
- [ ] teams/ 에 3개 팀이 있다는 것을 알나?

---

### 3단계: "내 팀은 뭐 하는 데?" (15분)

**자신의 팀 선택**:

#### 🎮 Game Team이라면:
**읽을 문서**: [`teams/game/README.md`](teams/game/README.md)

**필수 알아야 할 것**:
- Steve → Atlas → Game Lead → You (위임 구조)
- Dream Collector (현재 개발 중인 게임)
- Phase 3: ATB 전투 시스템 구현 중
- Team Lead의 일일 체크리스트 (당신도 따라야 함)

**확인 사항**:
- [ ] Game Team의 역할을 설명할 수 있나?
- [ ] Dream Collector는 어떤 게임인가?
- [ ] Team Lead의 책임이 뭔지 알나?

---

#### 📝 Content Team이라면:
**읽을 문서**: [`teams/content/README.md`](teams/content/README.md)

**필수 알아야 할 것**:
- Steve → Atlas → Content Lead → You (위임 구조)
- Blog: Tistory 블로그 (geekbrox.tistory.com)
- 목표: 주 3회 블로그 글 게시
- Claude Code가 글을 쓰고 Team Lead이 검수

**확인 사항**:
- [ ] Content Team의 역할을 설명할 수 있나?
- [ ] 블로그 목표 (월 15개 글)를 알나?
- [ ] 글 작성 프로세스 (초안 → 검수 → 게시)를 알나?

---

#### 🔧 Ops Team이라면:
**읽을 문서**: [`teams/ops/README.md`](teams/ops/README.md)

**필수 알아야 할 것**:
- Steve → Atlas → Ops Lead → You (위임 구조)
- OpenClaw 인프라 관리 (API 설정, 모델 관리)
- 월간 예산: $200 (실제: $60 정도)
- 목표: 99.5% 가동률 유지

**확인 사항**:
- [ ] Ops Team의 역할을 설명할 수 있나?
- [ ] OpenClaw란 뭔지 알나?
- [ ] 월간 API 비용이 얼마나 드는지 알나?

---

### 4단계: "어떻게 개발 환경을 설정하는데?" (30분)

**읽을 문서**: [`.config/README.md`](.config/README.md)

**할 일**:

```bash
# 1. 저장소 클론 (이미 했다고 가정)
cd ~/Projects/geekbrox

# 2. .env 파일 설정
cp .config/.env.example .config/.env
# .config/.env 를 열어서 필요한 API 키 입력

# 3. Python 가상환경 설정 (선택사항)
python3 -m venv .config/.venv
source .config/.venv/bin/activate  # macOS/Linux
# or
.config\.venv\Scripts\activate     # Windows

# 4. Python 의존성 설치
pip install -r requirements.txt

# 5. 개발 IDE 설정
# - Cursor IDE 또는 Claude Code 설치
# - .config/.cursor/ 규칙 자동 적용
```

**확인 사항**:
- [ ] .env 파일 설정했나?
- [ ] Python 가상환경 활성화했나?
- [ ] Cursor 또는 Claude Code 설치했나?

---

## 🎯 Day 2-3 (팀별 상세 온보딩)

### 🎮 Game Team (게임 개발자)

#### 문서 읽기 (1시간)
1. **Game Design Document** (GDD)
   ```
   teams/game/dream-collector/workspace/design/GDD.md
   ```
   - 게임의 모든 시스템이 여기 설명되어 있음
   
2. **ATB 구현 가이드** (Phase 3 관련)
   ```
   teams/game/dream-collector/workspace/design/03_implementation_guides/ATB_Implementation_Guide.md
   ```
   - "전투 시스템을 어떻게 구현하지?" 의 답

3. **코딩 규칙**
   ```
   .config/.cursor/rules/03-game-dev.mdc
   ```
   - Cursor IDE를 쓸 때 따라야 할 규칙

#### 개발 환경 설정 (30분)
```bash
# Godot 4.x 설치
# https://godotengine.org/download

# 게임 프로젝트 열기
open ~/Projects/geekbrox/teams/game/dream-collector/workspace/godot/project.godot
```

#### 첫 번째 코드 작성 (1시간)
1. Game Lead로부터 첫 태스크 받기
   - 예: "CardDatabase.gd 작성하세요"
   
2. Godot 프로젝트에서 새 스크립트 생성
   ```gdscript
   # CardDatabase.gd
   extends Node
   
   const CARDS = [
     # 여기에 카드 데이터 추가
   ]
   ```

3. 코드 작성 후 GitHub에 PR 제출
   ```bash
   git checkout -b feature/card-database
   # 코드 작성...
   git add .
   git commit -m "feat: Add CardDatabase.gd"
   git push origin feature/card-database
   # GitHub에서 PR 생성
   ```

4. Game Lead의 리뷰 받기
   - 수정 요청이 있으면 수정
   - 승인되면 병합

#### 일일 업무 (매일)
```
아침:
  [ ] Game Lead 메시지 확인 (오늘의 태스크)
  [ ] PROGRESS.md 확인 (현재 진행률)

오전:
  [ ] 받은 태스크 시작
  [ ] 코드 작성 & 테스트

오후:
  [ ] PR 제출
  [ ] 리뷰 받기 & 수정

저녁:
  [ ] PROGRESS.md 업데이트 (진행률 기록)
  [ ] Game Lead에게 상태 보고
```

---

### 📝 Content Team (콘텐츠 라이터)

#### 문서 읽기 (30분)
1. **블로그 포스팅 프로세스**
   ```
   docs/guides/BLOG_POSTING_UPDATE.md
   ```
   
2. **글 작성 템플릿**
   ```
   frameworks/blog_automation/templates/anime_post_template.md
   ```

3. **블로그 운영 가이드**
   ```
   teams/content/blog/README.md
   ```

#### 첫 번째 글 작성 (1시간)

1. Content Lead로부터 주제 받기
   - 예: "Dream Collector 개발일지 작성하세요 (1500자)"

2. 글 작성
   ```bash
   cd ~/Projects/geekbrox/teams/content/blog/drafts/
   
   # dev-diary-3.md 작성
   # - 제목
   # - 본문
   # - 이미지 링크
   # - SEO 설명
   ```

3. Content Lead 검수 요청
   - Slack/Discord: "dev-diary-3.md 검수해주세요"

4. 수정 & 최종 승인
   - 지적사항 수정
   - 최종 승인 후 posts/ 폴더로 이동
   - 자동으로 Tistory + SNS에 게시됨

#### 일일 업무 (매일)
```
아침:
  [ ] Content Lead 메시지 확인 (오늘의 글 주제)

오전:
  [ ] 리서치 & 글 초안 작성

오후:
  [ ] 글 완성 & 이미지 추가

저녁:
  [ ] Content Lead에게 검수 요청
  [ ] 지적사항 수정
```

---

### 🔧 Ops Team (인프라/자동화)

#### 문서 읽기 (1시간)
1. **OpenClaw 설정**
   ```
   .config/README.md
   docs/manuals/OPENCLAW_REPAIR.md
   ```

2. **비용 최적화 전략**
   ```
   teams/ops/README.md (Cost Optimization 섹션)
   ```

3. **모니터링 & 리포팅**
   ```
   teams/ops/reports/weekly-health.md (템플릿)
   ```

#### 첫 번째 헬스 체크 (30분)

```bash
# 1. OpenClaw 상태 확인
openclaw status

# 2. 에러 로그 확인
tail -50 ~/.openclaw/logs/openclaw.log | grep -i error

# 3. API 비용 확인
python teams/ops/scripts/cost-optimizer.py

# 4. 결과를 teams/ops/reports/ 에 기록
```

#### 일일 업무 (매일)
```
아침 (5분):
  [ ] openclaw status 확인
  [ ] 에러 로그 확인

주간 (1시간, 금요일):
  [ ] 헬스 리포트 작성 (teams/ops/reports/weekly-health.md)
  [ ] 비용 리포트 작성 (teams/ops/reports/weekly-cost.md)
  [ ] Ops Lead에게 보고

월간 (2시간, 마지막 금요일):
  [ ] 월간 요약 리포트 작성
  [ ] KPI 분석
  [ ] 다음달 계획 수립
```

---

## 💡 자주 하는 질문 (FAQ)

### "뭐 해야 할지 모르겠어요"
1. 자신의 팀 README 읽기 (teams/[team]/README.md)
2. Team Lead 메시지 확인
3. 일일 체크리스트 따라하기
4. Team Lead에게 물어보기

### "파일을 어디에 저장하지?"

| 경우 | 위치 |
|------|------|
| 게임 코드 | `teams/game/dream-collector/workspace/godot/` |
| 게임 기획 문서 | `teams/game/dream-collector/workspace/design/` |
| 게임 에셋 | `teams/game/dream-collector/workspace/art/` |
| 블로그 글 | `teams/content/blog/posts/` (또는 `drafts/`) |
| 자동화 스크립트 | `frameworks/blog_automation/scripts/` |
| 기술 가이드 | `docs/guides/` |
| 트러블슈팅 | `docs/manuals/` |

### "Git에서 뭐 커밋하지?"

**YES** ✅:
```
git add .
git commit -m "feat: Add CardDatabase.gd"
git push
```

**NO** ❌:
```
❌ .env (API 키!)
❌ __pycache__/
❌ .venv/
❌ frameworks/blog_automation/output/ (자동화 결과물)
❌ IDE 설정들 (.cursor/settings.json)
```

### "내가 뭘 잘못했나 싶을 때?"
1. 관련 가이드 읽기 (docs/guides/ 또는 docs/manuals/)
2. Team Lead에게 물어보기
3. PROJECT_STRUCTURE.md에서 관련 섹션 찾기

### "새로운 폴더를 만들어도 되나?"

**다른 팀** → Team Lead에게 물어보기  
**같은 팀 내** → Team Lead 승인 후 만들기

---

## 🎓 학습 경로

### 1주일 차

**목표**: 기본 이해 + 첫 태스크 완성

- Day 1-2: 이 온보딩 문서 완료
- Day 3-4: 첫 번째 태스크 시작
- Day 5: 첫 번째 PR 제출 또는 첫 글 게시
- **주말**: 주간 리포트 작성

### 2주일 차

**목표**: 독립적으로 일하기

- 태스크를 스스로 찾아서 처리
- Team Lead 지시에 따라 일하기
- 코드 리뷰/글 검수 받기 & 수정

### 1개월 차

**목표**: 팀의 생산성 기여

- 정기적인 태스크 처리
- 품질 기준 만족 (코드 리뷰 통과, 글 품질)
- 팀 미팅에 자신의 의견 제시

### 3개월 차

**목표**: 팀의 핵심 멤버

- 독립적인 프로젝트 주도
- 다른 팀원 멘토링
- 프로세스 개선 제안

---

## 🔗 중요 링크 모음

### 내가 자주 읽어야 할 문서들

```
📚 나의 팀 가이드
   └─ teams/[game/content/ops]/README.md

📚 프로젝트 기획 (게임팀만)
   └─ teams/game/dream-collector/workspace/design/GDD.md

📚 전체 폴더 구조 (막힐 때마다)
   └─ PROJECT_STRUCTURE.md

📚 기술 문제 해결
   └─ docs/guides/ & docs/manuals/

📚 진행 상황 추적
   └─ project-management/
```

### 외부 링크

- **게임 개발**: https://godotengine.org
- **블로그**: https://geekbrox.tistory.com
- **GitHub**: https://github.com/ledlaputa72/geekbrox
- **OpenClaw**: https://docs.openclaw.ai

---

## ✅ 온보딩 완료 체크리스트

다음을 모두 확인했다면 온보딩 완료! 🎉

- [ ] README.md 읽음
- [ ] PROJECT_STRUCTURE.md 읽음
- [ ] 자신의 팀 README 읽음
- [ ] .env 파일 설정함
- [ ] 개발 환경 설정함 (IDE, Python 등)
- [ ] 첫 번째 태스크 시작함
- [ ] Team Lead과 미팅함
- [ ] 일주일 동안 최소 1개의 PR/글을 완성함

---

## 📞 도움이 필요하면?

### 기술 문제
1. 관련 도큐먼트 찾기 (docs/)
2. Google 검색
3. Team Lead 또는 Ops Team에 물어보기

### 프로세스 문제
1. 자신의 팀 README 다시 읽기
2. PROJECT_STRUCTURE.md 참고
3. Team Lead에게 물어보기

### 긴급 이슈
1. Atlas에게 @mention (Telegram)
2. Team Lead에게 즉시 연락
3. Steve에게 에스컬레이션 (필요시)

---

**환영합니다! GeekBrox 팀에 오신 것을 축하합니다!** 🚀

질문 있으신가요? 막힐 때마다 이 문서로 돌아오세요.

**마지막 업데이트**: 2026-02-27 by Atlas  
**다음 검토**: 새로운 팀원 온보딩시
