# 🤖 Agents - AI 에이전트 설정 & 조직

이 폴더는 **OpenClaw 기반 AI 에이전트의 설정, 역할 정의, 그리고 조직 구조 문서**를 포함합니다.

## 📂 구조

### `atlas/`
- **역할**: 프로젝트 매니저 에이전트 (PM)
- **주요 파일**:
  - `atlas_bot.py` - Atlas 봇 메인 Python 스크립트
  - `ATLAS_MANUAL.md` - Atlas 사용 가이드
  - `run_atlas.sh` - Atlas 봇 실행 스크립트
- **책임**: 프로젝트 추적, 자동화 관리, 문서 정리
- **통신**: Telegram 기반 커맨드 처리

#### 빠른 시작
```bash
# 프로젝트 루트에서 실행
./agents/atlas/run_atlas.sh
```

## 📋 에이전트 & 조직 문서

| 파일 | 목적 |
|------|------|
| **AI_AGENTS_AND_WORKFLOW.md** | 전체 에이전트 설정, 역할, 워크플로우, 모델 구성 |
| **AI_AGENTS_AND_WORKFLOW_SUMMARY.md** | 7-섹션 요약 (빠른 참고용) |
| **ATLAS_CLAUDE_CURSOR_COMPARISON.md** | Atlas vs Claude vs Cursor 역할 비교 가이드 |

## 에이전트 계층

```
Steve (PM) — 의사결정
  ↓
Atlas (AI PM) — 프로젝트 추적 & 자동화 관리
  ↓
Kim.G (Game 매니저) — Gemini 2.5 Pro
Lee.C (Content 매니저) — Gemini 2.5 Pro
Park.O (Ops 매니저) — Gemini 2.5 Pro
```

## 향후 확장

- `content_agent/` - 콘텐츠 생성 에이전트
- `dev_agent/` - 개발 지원 에이전트
- `qa_agent/` - QA/테스트 에이전트

---

**관련 문서 위치:**
- 프로젝트 관리 & 팀 워크플로우: [`project-management/`](../project-management/)
- 개발 팀 기획: [`teams/game/workspace/`](../teams/game/workspace/), [`teams/content/workspace/`](../teams/content/workspace/)

**Last Updated**: 2026-02-28 by Atlas (docs 폴더 정리 및 파일 이동)
