# Atlas · Claude Code · Cursor AI 비교 및 업데이트 정리

> 세 도구의 역할, 경계, 지금까지 반영된 업데이트를 한곳에 정리한 문서.

---

## 1. 역할 비교

| 구분 | Atlas | Claude Code | Cursor AI |
|------|--------|-------------|-----------|
| **정체** | 총괄 PM (OpenClaw 에이전트 + 텔레그램 봇) | AI 코딩/작업 도구 | AI 코딩/작업 도구 (현재 환경) |
| **소통** | Steve ↔ Telegram, 팀장에게 위임 | shared_state.json + 스크립트 실행 | .cursorrules + shared_state cursor start/done |
| **실무** | **하지 않음** (위임만) | 블로그·콘텐츠 스크립트 수정/실행, 문서 작성 | geekbrox repo 코드 수정, 스크립트·규칙 정리 |
| **위치** | ~/.openclaw/agents/main/agent/agent.md, atlas_bot.py | (별도 클라이언트) | Cursor IDE 내 에이전트 |
| **워크스페이스** | ~/.openclaw/workspace/ (설정·기억), 결과물은 geekbrox | teams/content/workspace 등 | ~/Projects/geekbrox/ 전체 |

---

## 2. Atlas (총괄 PM)

### 2.1 OpenClaw Atlas (agent.md)
- **역할:** Steve 요청 수신 → 팀장(game/content/ops)에게 **Bash로 위임** → 결과 통합 보고.
- **금지:** 직접 블로그 포스팅, 자료조사, GDD 작성, v0 UI 생성 등 실무. 모두 `openclaw agent --agent <id> --message "..."` 로 위임.
- **v0 UI:** game 에이전트에 `v0_generate.py --screen c01_dream` 등 **정확한 명령**으로 위임.
- **콘텐츠:** "자료조사/글 생성/포스팅" → content 에이전트에 위임, 메시지 템플릿으로 `fetch_anime.py` / `generate_post.py` / `post_to_tistory.py` 실행 지시.
- **운영:** 리서치·유료화·QA → ops 에이전트에 위임.

### 2.2 atlas_bot.py (프로젝트 루트)
- **역할:** 텔레그램에서 **3개 팀 전체** 통합 제어 (전체 현황, 스프린트, P0/P1, 3-Way 공유 상태 + 콘텐츠/게임/운영 메뉴).
- **특징:** 버튼만으로 완결, LLM 호출 없음. 콘텐츠팀 스크립트는 subprocess, 게임/운영팀은 Markdown 파싱 후 요약.
- **메뉴:** 홈 → 전체 현황 / 콘텐츠팀 / 게임개발팀 / 운영팀 / 3-Way 공유 등 계층식.

### 2.3 content_team_bot.py (blog_automation/scripts/)
- **역할:** **콘텐츠팀 전용** 텔레그램 봇 (블로그 제작, 현황·통계, 3-Way 공유, 도움말).
- **특징:** shared_state 연동 (공유 현황, 활동 로그, 충돌 확인, 메시지 전달). 계층식 버튼 메뉴.
- **.cursorrules 기준:** "content_team_bot.py — 콘텐츠팀장 역할" 로 명시.

**정리:** Atlas = OpenClaw PM + atlas_bot(전체). 콘텐츠만 버튼으로 다루는 건 content_team_bot.

---

## 3. Claude Code

- **공유 방식:** `shared_state.py` 로 `claude_code` 액터 등록. `teams/content/workspace/shared_state.json` 에 상태·메시지 기록.
- **역할:** 블로그 자동화 스크립트 수정, 포스팅 플로우 개선, CODE_REVIEW.md·BLOG_POSTING_UPDATE.md 등 문서 작성. (실제 작업 이력은 activity_log / CODE_REVIEW 등에 반영됨.)
- **충돌 규칙:** Claude Code vs Cursor 동시에 같은 파일 수정 시 충돌. severity critical 시 Steve 텔레그램 알림.

---

## 4. Cursor AI

- **규칙:** `.cursorrules` 필수. 작업 전 `shared_state.py cursor start "설명" <파일들>` → 작업 후 `cursor done "설명"` 또는 `cursor error "내용"`. 충돌 시 start 결과에 `conflicts` 있으면 중단.
- **역할:** geekbrox 리포 전체 코드 편집, .cursorrules 업데이트, 문서 정리, 버그 수정, Atlas/Claude와 겹치지 않게 실무 수행.
- **공유 상태 파일:** .cursorrules에는 `output/shared_state.json` 이라고 되어 있으나, **실제 구현은** `teams/content/workspace/shared_state.json` (shared_state.py와 동일).

---

## 5. 지금까지 반영된 주요 업데이트

### 5.1 블로그 자동화 (콘텐츠팀)
- **post_to_tistory.py:** 발행 버튼 셀렉터(publish-btn 우선), set_category, upload_image_to_editor(TinyMCE body#tinymce DataTransfer drop + attach-layer-btn fallback), generate_hashtags, clipboard_paste(clear_first로 이어서 작성 시 겹침 방지). write_post 흐름: 카테고리 → 이미지 → 제목/본문 → 해시태그 → TG '포스팅' 대기 → 발행.
- **generate_post.py:** Claude 우선 + Gemini fallback, `--revise PATH --instruction TEXT` 로 초안 수정(봇 연동).
- **fetch_anime.py:** AniList 시즌 Top N 수집. (CODE_REVIEW 기준 정상.)
- **.cursorrules:** 티스토리 TinyMCE(editor-tistory_ifr, body#tinymce), 이미지 업로드 3단계, 발행 플로우, API fallback 패턴 문서화.
- **Atlas/봇:** 일반 메시지에도 응답(목록·요약·상태 질의 시 get_summary_for_user), is_allowed False 시에도 안내 메시지 전송.

### 5.2 3-Way 공유 상태
- **shared_state.py:** Claude Code / Cursor AI / Telegram Bot 세 액터가 `teams/content/workspace/shared_state.json` 으로 상태·메시지·충돌 공유. Cursor는 `cursor start/done/error/note`, `cursor messages` 사용.
- **일치 필요:** .cursorrules의 "output/shared_state.json" 문구는 실제 경로와 다름 → `teams/content/workspace/shared_state.json` 로 통일하는 것이 좋음.

### 5.3 게임팀 (teams/game/workspace)
- **PROJECT_STATE.md:** Phase 0, 컨셉 후보(꿈 수집가 Atlas 추천), GDD_Dream_Collector.md 등.
- **design/:** GDD, 상세 기획서(한/영), DETAILED_DESIGN_DOCUMENT.md, 꿈수집가_GDD.md, UPDATED_SCREEN_SPECS_v1.1.md 등.
- **v0_generate.py:** Atlas agent.md에 명시된 --screen c01_dream 등으로 game 에이전트 위임.

### 5.4 운영팀 (teams/ops/workspace)
- **testing/dream-collector-test-plan.md:** Dream Collector 페이퍼 프로토타입 테스트 계획(밸런스, 재미, 페이싱, 안정성).

### 5.5 기타
- **Git:** geekbrox → ledlaputa72/geekbrox, openclaw → ledlaputa72/openclaw-config. openclaw .gitignore에 openclaw.json.bak* 추가.
- **문서:** CODE_REVIEW.md(Claude Code 공유용), BLOG_POSTING_UPDATE.md(포스팅 플로우 정리), 본 비교 문서.

---

## 6. 협업 시 주의

1. **Cursor:** 코드/규칙 수정 전 `shared_state.py cursor start` 로 상태 등록, 완료 시 `cursor done`. 충돌 시 중단.
2. **Atlas:** 실무는 모두 팀장 위임. 블로그/포스팅은 content, v0 UI는 game, 리서치/QA는 ops.
3. **공유 상태 경로:** 실제 사용은 `teams/content/workspace/shared_state.json`. 문서(.cursorrules 등)에서 경로 통일 권장.
4. **봇:** 전체 제어는 atlas_bot, 콘텐츠 전용+shared_state 연동은 content_team_bot.

---

_이 문서는 Atlas·Claude Code·Cursor의 역할과 최근 업데이트를 한곳에서 참고하기 위해 작성되었습니다._
