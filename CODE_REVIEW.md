# Geekbrox 코드 검토 보고서

> Claude Code와 공유용 전체 코드 검토 결과 (2026-02-19)

---

## 1. 프로젝트 개요

| 스크립트 | 역할 | 의존성 |
|---------|------|--------|
| `fetch_anime.py` | AniList GraphQL API로 시즌 인기 애니 Top 10 수집 | requests |
| `generate_post.py` | seasonal_top_anime.json → Claude API로 블로그 글 생성 | anthropic, requests |
| `post_to_tistory.py` | output/posts/*.md → Selenium으로 티스토리 자동 포스팅 | selenium, requests |

실행 순서: `fetch_anime.py` → `generate_post.py` → `post_to_tistory.py` (또는 `./run_post.sh`)

---

## 2. 검토 결과 요약

| 구분 | 상태 | 비고 |
|------|------|------|
| 문법 검사 | ✅ 통과 | py_compile 성공 |
| fetch_anime.py | ✅ 정상 | API 호출, JSON 저장 확인 |
| generate_post.py | ⏳ 확인 필요 | ANTHROPIC_API_KEY 필요, API 호출 시간 소요 |
| post_to_tistory.py | ⚠️ 환경 의존 | Chrome 필요, Cursor 터미널에서 SessionNotCreatedException 가능 |

---

## 3. 발견된 이슈 및 개선 포인트

### 3.1 post_to_tistory.py

#### ✅ 해결됨 (이전 수정)
- **발행 버튼 셀렉터**: `[id*='publish'][id*='btn']`가 `publish-layer-btn`(패널 열기)을 먼저 찾는 문제 → `(By.ID, "publish-btn")`를 첫 번째로 사용하도록 수정됨
- **발행 흐름**: 1) publish-layer-btn 클릭 → 2) open20 공개 설정 → 3) publish-btn 클릭

#### ⚠️ 잠재 이슈

1. **`_debug_print` 위치 (56–59줄)**
   - `DONE_DIR`과 `IMAGES_DIR` 사이에 함수 정의가 있어 코드 흐름이 다소 어색함
   - 제안: `_debug_print`를 상수 정의 블록 아래로 이동

2. **`click_first` 반환 타입**
   - 현재 반환 타입 미선언 (`-> None` 또는 명시적 반환 없음)
   - 실제로는 `return`만 하고 값 반환 없음 → `-> None` 추가 권장

3. **`tg_wait_keyword` offset 처리**
   - `offset = upd["update_id"] + 1`로 갱신하는데, getUpdates는 `offset`보다 큰 메시지만 반환
   - 여러 메시지 수신 시 마지막 `update_id + 1`만 사용하므로 정상 동작
   - 다만 `result`가 비어있을 때 `offset` 갱신이 없어 다음 폴에서 중복 수신 가능성은 낮음 (이미 처리됨)

4. **Linux 클립보드 (clipboard_paste)**
   - `xclip` 실패 시 `xsel` 사용. 일부 환경에서는 둘 다 없을 수 있음
   - 제안: `FileNotFoundError` 시 `send_keys` 폴백 추가

5. **Chrome 실행 환경**
   - Cursor 내장 터미널: `SessionNotCreatedException` 발생 가능
   - **권장**: `Terminal.app`(시스템 터미널)에서 `./run_post.sh` 실행

#### ✅ 강점
- 에러 처리: API/WebDriver 호출에 try/except 적용
- 발행 실패 시: `publish_button_dump.json`, `publish_fail_screenshot.png` 저장
- `--dump-dom`: 로그인 후 DOM 덤프만 수집 (Telegram 불필요)

---

### 3.2 fetch_anime.py

#### ✅ 정상
- AniList GraphQL 호출, JSON 파싱, 예외 처리 적절
- `get_current_season()`: 12월 → 다음 해 WINTER 처리 정확
- `extract_korean_from_synonyms`: 한글 추출 로직 적절

#### ⚠️ 사소
- `TOP_N = 10` 하드코딩. 필요 시 CLI 인자로 받도록 확장 가능

---

### 3.3 generate_post.py

#### ✅ 정상
- `slugify`: 파일명/URL용 슬러그 생성
- `download_cover_image`: 이미지 다운로드 및 예외 처리
- Claude API 호출 및 응답 처리

#### ⚠️ 잠재 이슈

1. **slugify 중복**
   - 서로 다른 애니가 동일 slug를 가질 경우 (예: 동일 제목) 파일 덮어쓰기
   - 제안: slug 중복 시 `slug_1`, `slug_2` 등 suffix 추가

2. **이미지 상대 경로**
   - `image_rel_path = f"../images/{image_filename}"` → 티스토리 에디터에서 상대 경로가 동작하지 않을 수 있음
   - 현재: 마크다운 `![...](../images/xxx.jpg)` → 티스토리 업로드 시 절대 URL로 변환되는지 확인 필요

3. **ANTHROPIC_API_KEY**
   - 미설정 시 `ValueError` 발생. .env 설정 필수

---

## 4. 환경 변수 (.env)

| 변수 | 용도 |
|------|------|
| `TISTORY_BLOG_NAME` | 블로그 서브도메인 |
| `TISTORY_EMAIL` | 카카오 로그인 이메일 |
| `TISTORY_PASSWORD` | 카카오 로그인 비밀번호 |
| `TELEGRAM_BOT_TOKEN` | 포스팅 확인용 봇 토큰 |
| `TELEGRAM_CHAT_ID` | 알림 수신 채팅방 ID |
| `ANTHROPIC_API_KEY` | generate_post용 Claude API 키 |

---

## 5. 실행 테스트 결과

| 테스트 | 결과 | 비고 |
|--------|------|------|
| `python3 -m py_compile *.py` | ✅ 성공 | 문법 오류 없음 |
| `fetch_anime.py` | ✅ 성공 | seasonal_top_anime.json 저장 (10편) |
| `generate_post.py` | ⏳ 확인 필요 | Claude API 호출 (10편×약 30초) |
| `post_to_tistory.py` | ❌ Cursor 터미널 실패 | `SessionNotCreatedException` (Chrome) |

**post_to_tistory 실행 방법**: Cursor 내장 터미널에서는 Chrome이 실패합니다. **반드시 Terminal.app**(시스템 터미널)에서 실행하세요:

```bash
cd /Users/stevemacbook/Projects/geekbrox
./run_post.sh
# 또는
source .venv/bin/activate && python3 blog_automation/scripts/post_to_tistory.py
```

---

## 6. Claude Code 공유용 체크리스트

- [ ] `post_to_tistory.py`: `_debug_print` 위치 정리
- [ ] `post_to_tistory.py`: `click_first` 반환 타입 `-> None` 명시
- [ ] `generate_post.py`: slug 중복 시 suffix 추가 검토
- [ ] 전체: `run_post.sh`는 `post_to_tistory`만 실행 (fetch + generate 별도 실행 필요)
- [ ] Chrome/티스토리 UI 변경 시 `publish-btn`, `open20` 등 셀렉터 재확인

---

## 7. run_post.sh 동작

```bash
# run_post.sh는 post_to_tistory.py만 실행
# 전체 파이프라인: fetch_anime → generate_post → post_to_tistory
./run_post.sh          # post_to_tistory만
./run_post.sh --dump-dom  # DOM 덤프 모드
```

전체 자동화를 원하면 별도 스크립트 예시:

```bash
cd /Users/stevemacbook/Projects/geekbrox
source .venv/bin/activate
python3 blog_automation/scripts/fetch_anime.py && \
python3 blog_automation/scripts/generate_post.py && \
./run_post.sh
```

---

## 8. 요약 (Claude Code 공유용)

- **fetch_anime.py**: 정상 동작, 문법/로직 이슈 없음
- **generate_post.py**: ANTHROPIC_API_KEY 필요, slug 중복 시 덮어쓰기 가능성
- **post_to_tistory.py**: 발행 버튼 셀렉터 수정 완료, Cursor 터미널에서는 Chrome 실패 → Terminal.app에서 실행
