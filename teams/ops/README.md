# 🔧 Operations Team - 운영 & 인프라 팀

**팀 PM**: Atlas  
**팀장 (Lead)**: [팀장 이름 - 지정 예정]  
**현재 상태**: OpenClaw 인프라 및 자동화 관리

---

## 📊 팀 구조 및 업무 위임

```
Steve (PM)
  ↓
  └─ Atlas (팀 에이전트 PM)
      ↓ [경영진행 리뷰/승인]
      └─ Ops Team Lead (팀장)
          ├─ OpenClaw Infrastructure (관리)
          ├─ Automation Framework Maintenance (유지보수)
          ├─ CI/CD Pipeline (배포)
          └─ Monitoring & Alerting (모니터링)
```

### 👤 역할 정의

| 역할 | 담당자 | 책임 | 보고 대상 |
|------|--------|------|---------|
| **Project Manager** | Steve | 운영 전략, 인프라 투자 결정, 리스크 관리 | - |
| **Team Agent (PM)** | Atlas | 인프라 건강도 추적, 자동화 모니터링, 장애 알림 | Steve |
| **Team Lead (팀장)** | [지정 예정] | 인프라 설계, 자동화 유지보수, 성능 최적화 | Atlas/Steve |
| **Infrastructure** | Team Lead/Scripts | OpenClaw 설정, 에러 진단, 모델 관리 | Team Lead |
| **DevOps** | Scripts/Automation | 빌드 파이프라인, 배포 스크립트, 자동화 | Team Lead |
| **Monitoring** | Automation | 시스템 헬스 체크, 성능 모니터링, 로그 분석 | Team Lead |

---

## 📋 업무 위임 프로세스

### Steve → Atlas → Team Lead → Infrastructure/Automation

#### 1️⃣ **Steve (PM)의 지시**
```
예: "OpenClaw 모델 에러가 자주 발생해. 원인 파악하고 개선책 제시해."
    또는 "이번 달 API 비용이 너무 높아. 최적화 방안 찾아줘."

↓ Atlas가 받음
```

#### 2️⃣ **Atlas (팀 에이전트)**
- 문제 파악: 로그 분석, 모델 설정 검토
- Ops Team Lead에게 위임: "OpenClaw 진단 필요합니다"
- 헬스 체크 실행: 인프라 상태 모니터링
- 정기 리포트: 비용, 성능, 이슈 보고

```markdown
[Atlas의 주간 리포트]

**Infrastructure Health (Week of 2026-02-24)**

OpenClaw Status:
- Uptime: 99.8% ✅
- Model Errors: 0.3% (정상)
- Avg Response Time: 1.2s

Costs:
- Gemini API: $45 (목표: $50)
- Claude API: $15 (절감: -66%)
- Total: $60 (목표: $70) ✅

Issues Detected:
- None critical
- 1 minor: Cursor API rate limit warnings

Next Actions:
- Model fallback chain 재검증
- Cost trend 모니터링
```

#### 3️⃣ **Ops Team Lead (팀장)**
- 인프라 설계 & 문제 해결
  - OpenClaw 설정 검토 (.openclaw/config.json)
  - 모델 버전 태그 관리
  - API 키 로테이션
  - 에러 진단 및 개선책 제시
- 자동화 유지보수
  - CI/CD 파이프라인 점검
  - 빌드 스크립트 수정
  - 배포 프로세스 개선
- 성능 최적화
  - 비용 절감 방안 분석
  - 응답 시간 개선
  - 리소스 할당 최적화

```markdown
[Team Lead의 진단 보고서]

**OpenClaw Model Error Analysis**

문제:
- claude-haiku-4-5 모델 "model_not_found" 에러
- 영향: Fallback chain 실패 시 작업 중단

원인:
- 모델 이름 누락: "claude-haiku-4-5-20251001" 버전 태그 필수
- openclaw.json에 올바른 버전 명시 안됨

해결책:
1. 모든 에이전트 설정에 "-20251001" 추가
2. Fallback chain 재검증: Gemini 2.5 Pro → Claude Haiku 4-5 → Gemini Flash
3. 테스트: 각 모델별로 API 호출 성공 확인

예상 효과:
- 에러율: 0.3% → 0.05% (85% 개선)
- 자동화 안정성: 98% → 99.8%
```

#### 4️⃣ **Infrastructure Scripts / Automation (자동화)**

**Infrastructure Management:**
```bash
#!/bin/bash
# ops/scripts/check-infrastructure.sh

# 1. OpenClaw 모델 상태 확인
echo "Checking OpenClaw models..."
openclaw status

# 2. API 비용 조회
echo "Checking API costs..."
curl -H "Authorization: Bearer $GEMINI_API_KEY" \
  https://generativelanguage.googleapis.com/v1beta/usage

# 3. 에러 로그 분석
echo "Analyzing error logs..."
grep -i "error" ~/.openclaw/logs/*.log | tail -20

# 4. 헬스 체크
echo "Running health checks..."
for agent in main content game ops; do
  echo "  $agent: $(openClawstatus --agent $agent | grep "status")"
done

# 5. 결과 리포트
echo "Infrastructure Health Report" > ops/reports/weekly-health.md
echo "Generated: $(date)" >> ops/reports/weekly-health.md
```

**CI/CD Pipeline:**
```yaml
# .github/workflows/build-deploy.yml

name: Build & Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Run tests
        run: |
          python -m pytest tests/
          
      - name: Build game (Godot)
        run: |
          ./scripts/build-game.sh
          
      - name: Deploy blog automation
        run: |
          ./scripts/deploy-framework.sh
          
      - name: Notify team
        run: |
          python scripts/notify-team.py \
            --status "Build successful" \
            --channel "telegram"
```

**Cost Monitoring:**
```python
# ops/scripts/cost-optimizer.py

import os
from datetime import datetime

class CostMonitor:
    def __init__(self):
        self.gemini_cost = 0
        self.claude_cost = 0
        self.cursor_cost = 0  # Free tier
        
    def calculate_monthly_cost(self):
        """월간 예상 비용 계산"""
        gemini_usage = self.get_gemini_usage()
        claude_usage = self.get_claude_usage()
        
        # Gemini: $0.075/1M input, $0.30/1M output
        gemini_cost = (gemini_usage['input'] * 0.075 + 
                      gemini_usage['output'] * 0.30) / 1_000_000
        
        # Claude: $3/1M input, $15/1M output
        claude_cost = (claude_usage['input'] * 3 + 
                      claude_usage['output'] * 15) / 1_000_000
        
        total = gemini_cost + claude_cost
        
        print(f"Current Month Costs:")
        print(f"  Gemini: ${gemini_cost:.2f}")
        print(f"  Claude: ${claude_cost:.2f}")
        print(f"  Total: ${total:.2f}")
        print(f"  Budget: $200 (Remaining: ${200 - total:.2f})")
        
        if total > 100:
            self.alert_high_cost(total)
        
        return total
    
    def alert_high_cost(self, cost):
        """비용이 높으면 알림"""
        print(f"⚠️ WARNING: Monthly cost exceeds $100: ${cost:.2f}")
        print("Recommend: Use Gemini/Claude Flash more, reduce Sonnet usage")
```

---

## 🎯 현재 관리 대상

### 1. OpenClaw Infrastructure

**설정 위치**: `~/.openclaw/openclaw.json`

```json
{
  "agents": {
    "main": {
      "id": "main",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      }
    },
    "content": {
      "id": "content",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      }
    },
    "game": {
      "id": "game",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      }
    },
    "ops": {
      "id": "ops",
      "model": {
        "primary": "google/gemini-2.5-pro",
        "fallbacks": [
          "anthropic/claude-haiku-4-5-20251001",
          "google/gemini-2.5-flash"
        ]
      }
    }
  }
}
```

**Team Lead 책임:**
- [ ] 월 1회 모델 버전 최신화 확인
- [ ] API 키 30일마다 로테이션
- [ ] Fallback chain 정기적 검증
- [ ] 에러 로그 주간 분석

### 2. Cost Optimization

**월간 예산**: $200 (실제: $60-80)

| 서비스 | 비용 | 설정 |
|--------|------|------|
| **Gemini 2.5 Pro** | $45 | Primary model (Atlas, Game, Content, Ops) |
| **Claude Haiku 4-5** | $3 | Fallback 1 |
| **Gemini 2.5 Flash** | $5 | Fallback 2 |
| **Cursor IDE** | $0 | Free tier (Game dev) |
| **Claude Code** | $0 | Free tier (Content) |
| **Total** | ~$60 | ✅ 70% 절감 vs. 전체 Claude Sonnet |

**Team Lead 책임:**
- [ ] 주간 비용 리포트 (ops/reports/weekly-cost.md)
- [ ] 분기별 최적화 검토
- [ ] 모델별 사용량 분석 및 권장사항 제시

### 3. CI/CD Pipeline

**배포 대상:**
- GitHub 저장소 (자동 푸시)
- Godot 게임 빌드
- 블로그 자동화 프레임워크
- 기술 문서 배포

**Team Lead 책임:**
- [ ] GitHub Actions 워크플로우 유지보수
- [ ] 빌드 실패 시 원인 파악
- [ ] 배포 자동화 성능 개선

### 4. Monitoring & Alerting

**모니터링 항목:**
- OpenClaw 가동률 (목표: 99.5%)
- API 응답 시간 (목표: <1.5s)
- 에러율 (목표: <0.5%)
- 비용 추이 (목표: <$200/월)

```markdown
# Weekly Infrastructure Report Template

## Uptime
- OpenClaw: 99.8% ✅
- API Services: 100% ✅

## Performance
- Avg Response Time: 1.2s (target: 1.5s) ✅
- Max Response Time: 3.4s (spike on 2026-02-25)
- Error Rate: 0.2% (target: <0.5%) ✅

## Costs
- Gemini API: $45 (running average)
- Claude API: $3
- Total: ~$60 (within budget) ✅

## Issues & Resolutions
- 2026-02-25 10:30: Slow response (1 API limit hit)
  Resolution: Added rate limit handling
  Status: ✅ Resolved

## Next Week Actions
- [ ] Rotate API keys
- [ ] Test Fallback chain
- [ ] Review cost trends
```

---

## 📝 Team Lead의 일일/주간 업무

### 일일 체크리스트
- [ ] OpenClaw 상태 확인 (5분)
  ```bash
  openclaw status
  ```
- [ ] 에러 로그 확인 (5분)
  ```bash
  tail -20 ~/.openclaw/logs/openClaw.log | grep -i error
  ```
- [ ] API 비용 확인 (5분)
  ```bash
  python ops/scripts/cost-optimizer.py
  ```

### 주간 체크리스트
- [ ] 헬스 체크 리포트 생성 (ops/reports/weekly-health.md)
- [ ] 비용 리포트 생성 (ops/reports/weekly-cost.md)
- [ ] 모델 버전 태그 확인
- [ ] CI/CD 파이프라인 테스트
- [ ] 팀 미팅: Atlas에게 상태 보고

### 월간 체크리스트
- [ ] 분기별 비용 트렌드 분석
- [ ] 인프라 개선 제안서 작성
- [ ] API 키 로테이션
- [ ] 성능 최적화 실행 계획 수립

---

## 🚀 Instant Task 처리

### Team Lead이 직접 처리하거나 자동화할 수 있는 작업

#### 형식 1: 모델 설정 수정
```
[문제 발견] Claude Haiku 모델 에러 발생

[Team Lead 대응]:
1. openclaw.json 수정 (버전 태그 확인)
2. 모든 에이전트 설정 동기화
3. 테스트: openclaw status --agent main
4. 성공 확인 후 Atlas에 보고
```

#### 형식 2: 비용 최적화
```
[요청] "API 비용이 너무 높다"

[Team Lead 분석]:
1. cost-optimizer.py 실행
2. 모델별 사용량 분석
3. 제안:
   - Gemini Flash 사용 비중 증가 (80% 저렴)
   - 불필요한 API 호출 제거
   - Fallback chain 최적화
```

#### 형식 3: 빌드 실패 해결
```
[문제] GitHub Actions 빌드 실패

[Team Lead 대응]:
1. 실패 로그 확인
2. 원인 파악 (의존성, 설정, 코드)
3. build-deploy.yml 수정
4. 재실행
5. 성공 후 팀 알림
```

---

## 📊 ops 폴더 구조

```
ops/
├── README.md                          ← 이 파일
├── scripts/                           ← 운영 자동화 스크립트
│   ├── check-infrastructure.sh
│   ├── cost-optimizer.py
│   ├── build-game.sh
│   ├── deploy-framework.sh
│   └── notify-team.py
├── reports/                           ← 주간/월간 리포트
│   ├── weekly-health.md
│   ├── weekly-cost.md
│   └── monthly-summary.md
├── configs/                           ← 인프라 설정
│   ├── openclaw-backup.json
│   └── ci-cd-config.yaml
└── .cursorrules                       ← Ops 팀 규칙
```

---

## 💬 커뮤니케이션 채널

| 대상 | 채널 | 용도 |
|------|------|------|
| **Steve** | Telegram (main) | 월간 비용 리포트, 전략 결정 |
| **Atlas** | Telegram (Atlas) | 주간 헬스 체크, 이슈 알림 |
| **All Teams** | Slack/Discord (예정) | 배포 알림, 서비스 상태 |
| **GitHub** | Issues, Actions | 빌드 결과, 배포 로그 |

---

## 🎯 Success Criteria

**Team Lead의 성공은:**
- ✅ 가동률 (99.5% 이상 유지)
- ✅ 비용 관리 (월간 $200 이하 유지)
- ✅ 성능 (응답 시간 1.5s 이하)
- ✅ 자동화 (월 2-3개 신규 자동화 스크립트 추가)

---

## 📞 트러블슈팅 가이드

### "OpenClaw 모델 에러가 발생했어요"
1. `openclaw status --agent [agent-name]` 실행
2. 에러 메시지 확인
3. 모델 버전 태그 확인 (예: claude-haiku-4-5-20251001)
4. 필요시 openclaw.json 수정
5. `openclaw status` 재확인

### "API 비용이 너무 높아요"
1. `cost-optimizer.py` 실행
2. 모델별 사용량 분석
3. Gemini Flash 사용 비중 증가 권장
4. 월간 비용 추이 모니터링

### "CI/CD 배포가 실패했어요"
1. GitHub Actions 로그 확인
2. 빌드 단계별 실패 지점 파악
3. .github/workflows/build-deploy.yml 수정
4. 재실행

### "팀 에이전트가 작동 안 해요"
1. OpenClaw 프로세스 확인: `ps aux | grep openclaw`
2. API 키 확인: `.config/.env`
3. 로그 확인: `~/.openclaw/logs/`
4. Team Lead에게 보고

---

## 🔐 보안 체크리스트

- [ ] API 키는 `.config/.env`에만 저장 (Git 제외)
- [ ] 월 30일마다 API 키 로테이션
- [ ] 공개 저장소에 민감 정보 노출 안됨
- [ ] SSH 키 권한: 600 (-rw-------)
- [ ] 로그 파일에 민감 정보 없음

---

**마지막 업데이트**: 2026-02-27 by Atlas  
**다음 검토**: 2026-03-06 (주간 헬스 체크)
