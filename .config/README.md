# ⚙️ .config - 개발 환경 설정

이 폴더는 **로컬 개발 환경 설정 및 개인 환경변수**를 포함합니다.

## 📂 구조

### `./`
- **.env** - 환경변수 (API 키, 토큰 등 - Git 제외)
- **.cursorrules** - Cursor IDE 규칙
- **.cursor/** - Cursor IDE 설정 및 프로필
- **.claude/** - Claude 에디터 설정
- **__pycache__/** - Python 컴파일 캐시 (자동 생성)
- **.venv/** - Python 가상환경 (선택사항)

## 주의

⚠️ **이 폴더의 파일은 Git에 커밋되지 않습니다** (.gitignore 참고)

- `.env` - 민감한 정보 (API 키, 토큰)
- `__pycache__/` - 자동 생성 캐시
- `.venv/` - 로컬 가상환경

## 설정 방법

```bash
# 환경변수 설정 (처음 한 번)
cp .config/.env.example .config/.env
# 필요한 API 키 및 토큰 입력

# Python 가상환경 초기화 (선택사항)
python3 -m venv .config/.venv
source .config/.venv/bin/activate
pip install -r requirements.txt
```

---

**Last Updated**: 2026-02-27 by Atlas
