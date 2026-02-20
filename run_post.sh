#!/bin/bash
# 티스토리 포스팅 스크립트 실행 (의존성 확인 포함)
cd "$(dirname "$0")"
source .venv/bin/activate 2>/dev/null || true
pip install -q selenium requests python-dotenv 2>/dev/null
exec python3 blog_automation/scripts/post_to_tistory.py "$@"
