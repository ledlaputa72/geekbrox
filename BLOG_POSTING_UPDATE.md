# 블로그 포스팅 관련 업데이트 확인 (Claude Code 반영)

> 2026-02 기준 코드 재검토 요약

---

## 1. post_to_tistory.py (약 1,767줄)

### 구조
| 함수 | 역할 |
|------|------|
| `read_first_post()` | `(title, body, md_path, img_path)` 4개 반환. `../images/xxx` 패턴 또는 stem 기반 이미지 탐색 |
| `generate_hashtags(title, body)` | 키워드 기반 해시태그 최대 10개, `#태그1 #태그2 ...` 형식 |
| `set_category(driver, category_name)` | `select#category` 또는 커스텀 드롭다운. 기본 "애니소개 및 리뷰" |
| `upload_image_to_editor(driver, img_path)` | 방법1 DataTransfer drop(body#tinymce) → 방법2 attach-layer-btn/#attach-image → 방법3 file input 직접 |
| `write_post(driver, title, body, img_path=None, category="애니소개 및 리뷰")` | 카테고리 → 이미지 → 제목/본문 → 해시태그 → 임시저장 → TG '포스팅' 대기 → 발행 |
| `main()` | read_first_post() 4값 수신 후 write_post(..., img_path=img_path, category="애니소개 및 리뷰") 호출 |

### 티스토리 에디터 (TinyMCE/keditor)
- **에디터**: `editor-tistory`, iframe `id="editor-tistory_ifr"`, 본문 `body#tinymce`
- **이미지**: 방법1 = iframe 내 body#tinymce에 DataTransfer `drop` 이벤트 (base64 → File → DataTransfer); 방법2 = `div[aria-label="첨부"]` 또는 `#attach-layer-btn` JS click → `#attach-image` send_keys (toggle 방식, 재클릭 금지)
- **본문/해시태그**: iframe 전환 후 body#tinymce 또는 메인 DOM contenteditable fallback. 해시태그는 Cmd+End 후 `clipboard_paste(..., clear_first=False)`
- **발행**: `#publish-layer-btn` → `#open20` → `#publish-btn`

### 기타
- `clipboard_paste(..., clear_first=True)` 로 이어서 작성 시 이전 초안과 섞이지 않도록 입력 전 clear
- `--dump-dom`: 로그인 → newpost → DOM 덤프 저장 후 종료

---

## 2. .cursorrules (티스토리 Selenium 핵심 지식)

- 에디터 구조(TinyMCE, editor-tistory_ifr, body#tinymce), 이미지 업로드 3단계, 해시태그/본문 입력, 발행 플로우, 카테고리, write_post() 전체 흐름, 주의사항이 문서화되어 있음.
- 코드와 규칙이 일치함 (이미지 DataTransfer drop / attach-layer-btn, iframe 포커스 등).

---

## 3. generate_post.py

- **기본**: seasonal_top_anime.json → 글 생성, 이미지 다운로드, output/posts/*.md 저장
- **수정 모드**: `--revise PATH --instruction TEXT` → 해당 .md만 Claude로 수정 후 덮어쓰기 (atlas_bot 연동)

---

## 4. run_post.sh

- `post_to_tistory.py` 만 실행. 인자 그대로 전달 (`"$@"`).

---

## 5. requirements.txt

- anthropic, python-dotenv, requests, selenium (버전 명시). atlas_bot용 python-telegram-bot은 별도.

---

## 6. 정리

- **post_to_tistory.py**: TinyMCE(editor-tistory_ifr, body#tinymce) 기준으로 이미지/본문/해시태그 처리와 .cursorrules 내용이 맞게 반영되어 있음.
- **generate_post.py**: `--revise` / `--instruction` 지원으로 atlas_bot 수정 요청 플로우와 호환됨.
- **실행**: Chrome 필요, Terminal.app에서 `./run_post.sh` 권장 (Cursor 터미널에서는 SessionNotCreatedException 가능).

추가로 점검할 부분이 있으면 알려주세요.
