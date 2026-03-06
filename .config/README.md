# ⚙️ .config — Development Environment Configuration

**목적:** 프로젝트 개발 환경 설정 및 IDE 커스터마이제이션  
**위치:** `/Users/stevemacbook/Projects/geekbrox/.config/`  
**상태:** 🟢 활성 (Git-excluded)

---

## 📂 폴더 구조

```
.config/
├── .env                    ← 환경 변수 (API 키, 토큰, 크레덴셜)
├── .cursorrules            ← Cursor IDE 커스터마이제이션 규칙
├── .cursor/                ← Cursor IDE 설정 폴더
│   └── settings.json
├── .claude/                ← Claude 설정 폴더
│   └── settings.json
├── .venv/                  ← Python 가상환경 (node_modules equivalent)
│   └── lib/, bin/, ...
├── __pycache__/            ← Python 컴파일 캐시 (Git-excluded)
├── README.md               ← 이 파일
└── .gitignore              ← 제외 규칙 (신규)
```

---

## 🔑 API 설정 (.env)

### ✅ 현재 설정된 API

| API | 상태 | 용도 |
|-----|------|------|
| **Anthropic (Claude)** | ✅ 설정 | AI 코드 생성, 분석 |
| **Google** | ✅ 설정 | Gemini, YouTube, Google APIs |
| **TMDB** | ✅ 설정 | 영화/TV 시리즈 데이터 |
| **YouTube** | ✅ 설정 | 동영상 API |
| **Tistory** | ✅ 설정 | 블로그 자동 포스팅 |
| **Telegram** | ✅ 설정 | 봇 알림, 메시징 |
| **Notion** | ✅ 설정 | 프로젝트 관리 DB |
| **v0 (Vercel)** | ✅ 설정 | UI 생성 API |

### ⚠️ 미사용 API

| API | 상태 | 비고 |
|-----|------|------|
| Reddit | 🔴 미설정 | 향후 사용 예정 |

---

## 🎯 IDE 설정

### Cursor IDE (.cursor/)
- **설정 파일:** `.cursor/settings.json`
- **역할:** 코드 편집, AI 어시스턴트, 확장 프로그램

**추천 확장:**
- Godot Tools
- Python
- GDScript Support
- REST Client

### Claude Settings (.claude/)
- **설정 파일:** `.claude/settings.json`
- **역할:** Claude AI 통합 설정

### Cursor 규칙 (.cursorrules)
- **파일 크기:** 11.5 KB
- **내용:** 프로젝트 특화 프롬프트
- **역할:** Cursor AI에 프로젝트 컨텍스트 제공

**현재 규칙:**
```
- 게임 설계 및 구현 가이드
- 코드 스타일 (GDScript, TypeScript)
- 명명 규칙
- 아키텍처 패턴
- 테스트 전략
```

---

## 🐍 Python 환경 (.venv/)

### 설정 상태
- **위치:** `.venv/`
- **Python 버전:** 3.x (TBD - requirements.txt 미발견)
- **패키지:** TBD (없음 - 최소한의 의존성)

### 권장 사항
1. `requirements.txt` 생성
   ```
   requests>=2.28.0
   python-dotenv>=0.21.0
   ```

2. 가상환경 활성화
   ```bash
   source .venv/bin/activate
   ```

---

## 🚫 Git Exclusion (.gitignore)

**제외되는 파일 (Git 추적 안 함):**
```
.env                    # API 키 보안
.venv/                  # 가상환경 (재현 가능)
__pycache__/            # Python 캐시
.cursor/settings.json   # IDE 개인 설정
.claude/settings.json   # Claude 개인 설정
*.pyc                   # 컴파일 바이트코드
.DS_Store               # macOS 시스템 파일
node_modules/           # npm (선택사항)
```

---

## 📋 체크리스트 (설정 유지)

### 일일 점검
- [ ] `.env` 파일 보안 (권한: 600)
- [ ] API 키 만료 확인
- [ ] Telegram Bot 알림 정상 작동

### 주간 점검
- [ ] Python 패키지 업데이트 (`pip list`)
- [ ] Cursor IDE 확장 업데이트
- [ ] API 사용량 모니터링

### 월간 점검
- [ ] 미사용 API 정리
- [ ] 환경 변수 검토
- [ ] 보안 감사 (키 로테이션)

---

## 🔐 보안 가이드

### ✅ DO
- `NOTION_API_KEY` → `.env`에만 저장
- `ANTHROPIC_API_KEY` → 절대 커밋 금지
- `.env` → `.gitignore`에 명시
- API 키 → 정기 로테이션 (3개월마다)

### ❌ DON'T
- API 키를 코드에 직접 입력
- `.env`를 Git에 커밋
- 환경 변수를 로그에 출력
- 민감 정보를 README에 기록

---

## 🔗 참고 문서

- **Cursor IDE:** https://cursor.sh/docs
- **Claude API:** https://docs.anthropic.com
- **Notion API:** https://developers.notion.com
- **Telegram Bot:** https://core.telegram.org/bots/api

---

## 📞 문제 해결

### API 연결 실패
```bash
# .env 파일 확인
cat .env | grep NOTION_API_KEY

# API 키 테스트 (curl 예)
curl -H "Authorization: Bearer $NOTION_API_KEY" \
  https://api.notion.com/v1/users/me
```

### Python 가상환경 문제
```bash
# 가상환경 재설정
rm -rf .venv/
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

**최종 업데이트:** 2026-03-06  
**관리자:** Atlas (PM)  
**상태:** 🟢 정리 완료
