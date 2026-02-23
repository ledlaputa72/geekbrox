#!/bin/bash
# Atlas 총괄 PM 봇 실행 스크립트
# 사용법: ./run_atlas.sh

cd "$(dirname "$0")"

VENV_PYTHON="$(dirname "$0")/.venv/bin/python3"

if [ ! -f "$VENV_PYTHON" ]; then
    echo "❌ .venv 없음. 먼저 아래를 실행하세요:"
    echo "   python3 -m venv .venv"
    echo "   .venv/bin/pip install python-telegram-bot>=20.0 python-dotenv"
    exit 1
fi

echo "🚀 Atlas 총괄 PM 봇 시작..."
echo "   Python: $VENV_PYTHON"
exec "$VENV_PYTHON" atlas_bot.py
