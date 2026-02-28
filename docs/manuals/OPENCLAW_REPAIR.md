# OpenClaw 긴급 수리 가이드
## Agent failed: All models failed (3) 오류 해결

**발생 시각:** 2026-02-27
**오류 유형:** 3개 모델 전부 실패 → Atlas 응답 불가
**수리 필요 환경:** MacBook (`~/.openclaw/` 설정)

---

## 🔴 오류 전체 분석

```
Agent failed before reply: All models failed (3):
1. google/gemini-2.5-pro   → rate_limit (서버 과부하)
2. anthropic/claude-3-5-haiku → model_not_found ← 핵심 버그
3. google/gemini-2.5-flash → rate_limit (auth 쿨다운)
```

### 원인별 분류

| # | 모델 | 오류 | 원인 | 해결 여부 |
|---|------|------|------|---------|
| 1 | gemini-2.5-pro | rate_limit | Google 서버 과부하 (일시적) | 자연 해소 |
| **2** | **claude-3-5-haiku** | **model_not_found** | **모델명 버전 태그 누락** | **수동 수정 필요** |
| 3 | gemini-2.5-flash | rate_limit | auth 쿨다운 (일시적) | 자연 해소 |

→ **모델 2번만 수정하면 다음 장애 시 Claude로 자동 폴백 작동**

---

## 🛠️ MacBook에서 즉시 실행할 수정

### 1단계: OpenClaw 설정 파일 열기

```bash
# MacBook 터미널에서:
cd ~/.openclaw
ls -la  # 파일 목록 확인
```

### 2단계: 잘못된 모델명 찾기

```bash
# claude-3-5-haiku 참조 파일 찾기:
grep -r "claude-3-5-haiku" ~/.openclaw/ --include="*.yaml" --include="*.json" --include="*.toml" --include="*.py" --include="*.md" -l
```

### 3단계: 모델명 수정

**잘못된 이름 → 올바른 이름:**

```
❌ 틀림:  anthropic/claude-3-5-haiku
✅ 올바름: anthropic/claude-3-5-haiku-20241022
```

**또는 더 최신 버전 (권장):**
```
✅ 최신:  anthropic/claude-haiku-4-5-20251001
```

> 💡 왜 오류가 났는가?
> Anthropic API는 모델명에 날짜 버전 태그(`-20241022`)가 필수입니다.
> 태그 없이 `claude-3-5-haiku`만 입력하면 "알 수 없는 모델"로 처리됩니다.

### 4단계: 전체 모델 폴백 순서 재설정 (권장)

현재 폴백 순서가 비효율적입니다. 아래처럼 변경을 권장합니다:

```yaml
# 권장 폴백 순서:
models:
  - google/gemini-2.5-flash          # 1순위: 빠름, 안정적, 저렴
  - anthropic/claude-3-5-haiku-20241022  # 2순위: Gemini 실패 시 Claude 폴백
  - google/gemini-2.5-pro            # 3순위: 고품질 필요 시 (느리고 비쌈)

# 현재 (문제있는) 순서:
# google/gemini-2.5-pro        ← Pro를 1순위로 쓰면 비용 16배 증가
# anthropic/claude-3-5-haiku   ← 버전 태그 누락
# google/gemini-2.5-flash      ← 사실상 원래 메인 모델
```

### 5단계: Atlas 재시작 확인

```bash
# MacBook에서 OpenClaw 재시작:
openclaw restart atlas
# 또는
openclaw stop && openclaw start

# 텔레그램에서 테스트:
# → "안녕" 메시지 보내서 Atlas 응답 확인
```

---

## ✅ 수정 후 정상 동작 확인

텔레그램에서 Atlas에게 메시지 보낸 후:

```
정상: "안녕하세요! ..." (즉시 응답)
비정상: "Agent failed before reply: ..."
```

---

## 📋 모델명 레퍼런스 (정확한 버전 태그)

### Claude (Anthropic)

| 모델 | 올바른 API 이름 | 용도 |
|------|--------------|------|
| Claude Sonnet 4.5 | `claude-sonnet-4-5-20250929` | 팀장 에이전트 (현재 정상 사용 중) |
| Claude Haiku 4.5 | `claude-haiku-4-5-20251001` | 경량 폴백 ✅ 권장 |
| Claude 3.5 Haiku | `claude-3-5-haiku-20241022` | 경량 폴백 (구버전) |

### Gemini (Google)

| 모델 | 올바른 API 이름 | 용도 |
|------|--------------|------|
| Gemini 2.5 Flash | `gemini-2.5-flash` 또는 `google/gemini-2.5-flash` | Atlas 메인 모델 ✅ |
| Gemini 2.5 Pro | `gemini-2.5-pro` 또는 `google/gemini-2.5-pro` | 고품질 전용 |

---

## 💰 비용 영향 메모

Atlas가 최근 Flash → Pro로 전환됨 (Gemini 사용량 분석 결과):
- Flash 단가: $0.075/1M 토큰
- Pro 단가: $1.25/1M 토큰 → **16.7배 비쌈**

Atlas PM 역할은 Flash로 충분합니다. 수정 시 Flash를 1순위로 복원 권장.

---

_작성: GeekBrox 게임팀 | 2026-02-27 | Windows PC에서 원격 진단_
