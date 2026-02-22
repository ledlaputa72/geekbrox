"""
content_team_bot.py — GeekBrox 콘텐츠팀장 봇 (블로그 자동화 전용)

텔레그램에서 인라인 버튼 메뉴를 통해 블로그 운영 전체 워크플로우를 제어합니다.
📝 콘텐츠팀장의 블로그 자동화 작업을 원격으로 실행합니다.

기능:
  /start  — 메인 메뉴
  [자료조사] → AniList 최신 애니 데이터 수집
  [글 생성] → Claude API로 블로그 초안 생성
  [초안 확인] → 생성된 초안 목록 및 내용 확인
  [초안 수정 요청] → 수정 지시 메시지 → 재생성
  [포스팅 실행] → Tistory 자동 포스팅 (별도 프로세스)
  [게시 현황] → done/ 폴더 완료 목록
  [상태 조회] → 현재 posts/ 파일 수, 시스템 상태

사전 설치:
  pip install python-telegram-bot==20.* python-dotenv
"""

from __future__ import annotations

import asyncio
import os
import subprocess
import sys
import time
import json
from pathlib import Path
from datetime import datetime
from collections import deque

from dotenv import load_dotenv

# shared_state 연동
try:
    from shared_state import (
        telegram_format_status, telegram_get_activity_log,
        telegram_get_conflicts, telegram_resolve_conflicts,
        telegram_add_note, telegram_send_message,
        ACTOR_CLAUDE, ACTOR_CURSOR,
    )
    _SHARED_STATE_OK = True
except ImportError:
    _SHARED_STATE_OK = False
    def telegram_format_status(): return "⚠️ shared_state 모듈 없음"
    def telegram_get_activity_log(n=15): return "⚠️ shared_state 모듈 없음"
    def telegram_get_conflicts(unresolved_only=True): return "⚠️ shared_state 모듈 없음"
    def telegram_resolve_conflicts(): return "⚠️ shared_state 모듈 없음"
    def telegram_add_note(note): pass
    def telegram_send_message(to, msg): pass
    ACTOR_CLAUDE = "claude_code"
    ACTOR_CURSOR = "cursor_ai"

# python-telegram-bot v20+ 비동기
try:
    from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
    from telegram.ext import (
        Application,
        CommandHandler,
        CallbackQueryHandler,
        MessageHandler,
        ContextTypes,
        filters,
    )
except ImportError:
    print("python-telegram-bot 없음 → 설치 시도 중...")
    subprocess.run(
        [sys.executable, "-m", "pip", "install", "python-telegram-bot>=20.0", "python-dotenv"],
        check=True,
    )
    from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
    from telegram.ext import (
        Application,
        CommandHandler,
        CallbackQueryHandler,
        MessageHandler,
        ContextTypes,
        filters,
    )

load_dotenv()

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 경로 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SCRIPT_DIR  = Path(__file__).resolve().parent
PROJECT_DIR = SCRIPT_DIR.parent.parent          # /geekbrox
POSTS_DIR   = PROJECT_DIR / "output" / "posts"
DONE_DIR    = POSTS_DIR / "done"
IMAGES_DIR  = PROJECT_DIR / "output" / "images"

BOT_TOKEN   = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
ALLOWED_ID  = os.environ.get("TELEGRAM_CHAT_ID", "").strip()   # 허용할 chat_id (보안)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Rate Limit 방지 작업 큐 시스템
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 작업 큐: 대기 중인 작업 목록
_task_queue: deque = deque()
# 큐 처리 중 여부
_queue_running: bool = False
# 글 생성 간격 (초) — .env의 INTER_POST_DELAY와 동일
QUEUE_DELAY = int(os.environ.get("INTER_POST_DELAY", "30"))
# 최근 API 호출 타임스탬프 기록 (분당 제한 추적용)
_api_call_times: deque = deque(maxlen=20)


def _check_rate_limit_status() -> dict:
    """최근 API 호출 빈도 분석 → 현재 Rate Limit 여유 여부 반환."""
    now = time.time()
    # 최근 60초 내 호출 수
    recent_calls = sum(1 for t in _api_call_times if now - t < 60)
    # 최근 5초 내 호출 수 (burst 감지)
    burst_calls = sum(1 for t in _api_call_times if now - t < 5)
    return {
        "recent_60s": recent_calls,
        "burst_5s": burst_calls,
        "safe": recent_calls < 8 and burst_calls < 2,  # 안전 임계값
        "recommended_delay": max(QUEUE_DELAY, 60 // max(1, (8 - recent_calls))),
    }


def _record_api_call():
    """API 호출 시 타임스탬프 기록."""
    _api_call_times.append(time.time())


async def _process_queue(app_bot, chat_id: int):
    """큐에 쌓인 작업을 순차적으로 딜레이를 두고 처리."""
    global _queue_running
    if _queue_running:
        return
    _queue_running = True

    total = len(_task_queue)
    completed = 0

    try:
        while _task_queue:
            task = _task_queue.popleft()
            completed += 1
            remaining = len(_task_queue)

            # 진행 상황 알림
            await app_bot.send_message(
                chat_id=chat_id,
                text=(
                    f"▶️ *작업 시작* [{completed}/{total}]\n"
                    f"📄 {task['label']}\n"
                    f"⏳ 남은 작업: {remaining}개"
                ),
                parse_mode="Markdown",
            )

            # 실제 작업 실행
            _record_api_call()
            ok, out = await asyncio.get_event_loop().run_in_executor(
                None, run_script, task["script"], task.get("args")
            )

            status_icon = "✅" if ok else "❌"
            await app_bot.send_message(
                chat_id=chat_id,
                text=(
                    f"{status_icon} *완료* [{completed}/{total}]: {task['label']}\n\n"
                    f"```\n{out[:600]}\n```"
                    + (f"\n\n⏳ 다음 작업까지 {QUEUE_DELAY}초 대기 중..." if remaining > 0 else "")
                ),
                parse_mode="Markdown",
            )

            # 다음 작업 전 딜레이 (마지막 작업은 제외)
            if remaining > 0:
                await asyncio.sleep(QUEUE_DELAY)

    finally:
        _queue_running = False

    # 모든 작업 완료 알림
    await app_bot.send_message(
        chat_id=chat_id,
        text=f"🎉 *모든 작업 완료!* (총 {total}개)\nRate Limit 없이 안전하게 처리되었습니다.",
        parse_mode="Markdown",
    )

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 보안: 허용된 사용자만 응답
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def is_allowed(update: Update) -> bool:
    if not ALLOWED_ID:
        return True  # 미설정 시 전체 허용 (개발용)
    uid = str(update.effective_chat.id)
    return uid == ALLOWED_ID


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 메인 메뉴 키보드
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def main_menu_keyboard() -> InlineKeyboardMarkup:
    keyboard = [
        [
            InlineKeyboardButton("🔍 자료조사",     callback_data="fetch"),
            InlineKeyboardButton("✍️ 글 생성",       callback_data="generate"),
        ],
        [
            InlineKeyboardButton("📋 초안 확인",     callback_data="list_drafts"),
            InlineKeyboardButton("🔄 초안 수정",     callback_data="revise"),
        ],
        [
            InlineKeyboardButton("🚀 포스팅 실행",  callback_data="post"),
            InlineKeyboardButton("📊 게시 현황",     callback_data="done_list"),
        ],
        [
            InlineKeyboardButton("⚙️ 상태 조회",    callback_data="status"),
            InlineKeyboardButton("🔗 공유 현황",     callback_data="shared_status"),
        ],
        [
            InlineKeyboardButton("📋 활동 로그",     callback_data="activity_log"),
            InlineKeyboardButton("🚨 충돌 확인",     callback_data="conflicts"),
        ],
        [
            InlineKeyboardButton("❓ 도움말",        callback_data="help"),
        ],
    ]
    return InlineKeyboardMarkup(keyboard)


def draft_list_keyboard(md_files: list[Path]) -> InlineKeyboardMarkup:
    """초안 목록 → 각 파일에 [확인] [삭제] 버튼"""
    keyboard = []
    for i, f in enumerate(md_files[:8]):  # 최대 8개
        keyboard.append([
            InlineKeyboardButton(f"📄 {f.stem[:28]}", callback_data=f"view_{i}"),
            InlineKeyboardButton("🗑️ 삭제",           callback_data=f"del_{i}"),
        ])
    keyboard.append([InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")])
    return InlineKeyboardMarkup(keyboard)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 상태 헬퍼
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def get_status_text() -> str:
    pending = list(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
    done    = list(DONE_DIR.glob("*.md"))  if DONE_DIR.exists()  else []
    images  = list(IMAGES_DIR.glob("*.*")) if IMAGES_DIR.exists() else []
    now     = datetime.now().strftime("%Y-%m-%d %H:%M")
    return (
        f"⚙️ *GeekBrox 블로그 자동화 현황* ({now})\n\n"
        f"📝 포스팅 대기: *{len(pending)}개*\n"
        f"✅ 게시 완료: *{len(done)}개*\n"
        f"🖼️ 이미지 보유: *{len(images)}개*\n\n"
        f"{'🟢 대기 중인 초안 있음' if pending else '⚪️ 대기 초안 없음'}"
    )


def get_summary_for_user() -> str:
    """발행/미발행 목록·요약 요청 시 사용할 상세 요약 문자열."""
    pending = sorted(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
    done = sorted(DONE_DIR.glob("*.md")) if DONE_DIR.exists() else []
    today = datetime.now().strftime("%Y-%m-%d")
    lines = [get_status_text(), ""]

    # 오늘 게시 완료된 글 (파일 mtime 기준)
    done_today = []
    for p in done:
        try:
            if datetime.fromtimestamp(p.stat().st_mtime).strftime("%Y-%m-%d") == today:
                done_today.append(p)
        except OSError:
            pass
    if done_today:
        lines.append(f"📅 *오늘 게시 완료* ({len(done_today)}개)")
        for p in done_today[:15]:
            title = p.stem
            try:
                raw = p.read_text(encoding="utf-8").splitlines()
                if raw and raw[0].startswith("# "):
                    title = raw[0][2:].strip()
            except Exception:
                pass
            lines.append(f"  • {title[:50]}")
        lines.append("")

    # 전체 게시 완료 목록 (최근 10개)
    lines.append(f"✅ *게시 완료* (총 {len(done)}개, 최근 10개)")
    for p in (done[-10:][::-1] if done else []):
        lines.append(f"  • {p.stem[:45]}")
    lines.append("")

    # 미발행 대기 목록
    lines.append(f"📝 *포스팅 대기* ({len(pending)}개)")
    for p in (pending[:10] or []):
        lines.append(f"  • {p.stem[:45]}")
    if len(pending) > 10:
        lines.append(f"  ... 외 {len(pending) - 10}개")
    return "\n".join(lines)


def run_script(script_name: str, args: list[str] | None = None) -> tuple[bool, str]:
    """스크립트를 subprocess로 실행. (성공여부, 출력)"""
    script_path = SCRIPT_DIR / script_name
    if not script_path.exists():
        return False, f"스크립트 없음: {script_path}"
    cmd = [sys.executable, str(script_path)] + (args or [])
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=300,
            cwd=str(PROJECT_DIR),
        )
        output = (result.stdout + result.stderr).strip()
        return result.returncode == 0, output[-1500:] if len(output) > 1500 else output
    except subprocess.TimeoutExpired:
        return False, "⏱️ 실행 시간 초과 (5분)"
    except Exception as e:
        return False, f"실행 오류: {e}"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 핸들러
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def cmd_start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not is_allowed(update):
        await update.message.reply_text(
            "⚠️ 이 봇은 허용된 사용자만 사용할 수 있습니다. TELEGRAM_CHAT_ID를 확인해 주세요."
        )
        return
    await update.message.reply_text(
        "👋 *GeekBrox 콘텐츠팀장 봇*에 오신 것을 환영합니다!\n\n"
        "📝 블로그 자동화 작업을 아래 버튼으로 제어하세요.\n"
        "🚀 Reports to: Atlas (총괄 PM)",
        reply_markup=main_menu_keyboard(),
        parse_mode="Markdown",
    )


async def cmd_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not is_allowed(update):
        await update.message.reply_text(
            "⚠️ 이 봇은 허용된 사용자만 사용할 수 있습니다. TELEGRAM_CHAT_ID를 확인해 주세요."
        )
        return
    await update.message.reply_text(
        "🏠 *메인 메뉴*",
        reply_markup=main_menu_keyboard(),
        parse_mode="Markdown",
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 도움말 시스템 — 카테고리별 메뉴 + 상세 안내
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def help_main_keyboard() -> InlineKeyboardMarkup:
    """도움말 메인 카테고리 선택 키보드."""
    return InlineKeyboardMarkup([
        [
            InlineKeyboardButton("📝 블로그 제작",   callback_data="help_blog"),
            InlineKeyboardButton("🔗 공유·충돌 관리", callback_data="help_shared"),
        ],
        [
            InlineKeyboardButton("⌨️ 텍스트 명령어", callback_data="help_text"),
            InlineKeyboardButton("📊 API·큐 관리",   callback_data="help_api"),
        ],
        [
            InlineKeyboardButton("🔘 슬래시 명령어", callback_data="help_slash"),
            InlineKeyboardButton("💡 팁 & 설정",     callback_data="help_tips"),
        ],
        [
            InlineKeyboardButton("📋 전체 보기",     callback_data="help_all"),
            InlineKeyboardButton("🏠 메인 메뉴",     callback_data="menu"),
        ],
    ])


def help_back_keyboard(section: str = "") -> InlineKeyboardMarkup:
    """도움말 하위 페이지에서 돌아가는 버튼."""
    rows = []
    # 직접 실행 가능한 섹션은 바로가기 버튼 추가
    shortcuts = {
        "help_blog":   [("🔍 자료조사", "fetch"), ("✍️ 글 생성", "generate")],
        "help_shared": [("🔗 공유 현황", "shared_status"), ("🚨 충돌 확인", "conflicts")],
        "help_api":    [("📊 API 상태", "rl_status")],
    }
    if section in shortcuts:
        rows.append([
            InlineKeyboardButton(label, callback_data=cb)
            for label, cb in shortcuts[section]
        ])
    rows.append([
        InlineKeyboardButton("◀️ 도움말 목록", callback_data="help"),
        InlineKeyboardButton("🏠 메인 메뉴",   callback_data="menu"),
    ])
    return InlineKeyboardMarkup(rows)


# ── 카테고리별 텍스트 ──────────────────────────

def _help_index_text() -> str:
    return (
        "📖 *명령어 가이드 — 카테고리 선택*\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"
        "아래 버튼을 눌러 원하는 항목을 확인하세요.\n\n"
        "📝 *블로그 제작* — 자료조사 · 글 생성 · 초안 · 포스팅\n"
        "🔗 *공유·충돌 관리* — Claude / Cursor / 봇 3-way 상태\n"
        "⌨️ *텍스트 명령어* — 키워드로 제어하는 단축 명령\n"
        "📊 *API·큐 관리* — Rate Limit & 대기 큐 현황\n"
        "🔘 *슬래시 명령어* — /start /menu /help /?\n"
        "💡 *팁 & 설정* — 딜레이 · 알림 · 환경변수\n"
        "📋 *전체 보기* — 모든 명령어 한 번에\n\n"
        "_언제든 `/?` 또는 `/help` 를 입력하면 이 화면으로 돌아옵니다._"
    )


def _help_blog_text() -> str:
    return (
        "📝 *블로그 제작 명령어*\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"

        "🔍 *자료조사*\n"
        "AniList에서 최신 애니 데이터를 수집합니다.\n"
        "소요시간: 약 30초~1분\n\n"

        "✍️ *글 생성*\n"
        "Claude API로 블로그 초안을 자동 작성합니다.\n"
        "• 미발행 초안이 있으면 확인 후 진행\n"
        "• Rate Limit 상황이면 경고 표시\n"
        f"• 글 간 딜레이: *{QUEUE_DELAY}초* (Rate Limit 방지)\n\n"

        "📋 *초안 확인*\n"
        "대기 중인 초안 목록을 보여줍니다.\n"
        "• 📄 파일명 버튼 → 내용 미리보기\n"
        "• 🗑️ 삭제 버튼 → 해당 초안 삭제\n"
        "• 미리보기에서 수정 요청 · 바로 포스팅 가능\n\n"

        "🔄 *초안 수정*\n"
        "수정 지시 메시지를 입력하면 해당 초안을 재생성합니다.\n"
        "예시: `줄거리를 더 자세하게`, `제목을 더 흥미롭게`\n\n"

        "🚀 *포스팅 실행*\n"
        "Tistory에 자동 게시합니다.\n"
        "• 제목·파일명 확인 후 [포스팅 시작] 버튼으로 진행\n"
        "• 카카오 추가 인증 필요 시 봇이 알림\n"
        "• 인증 완료 후 `인증완료` 입력\n\n"

        "📊 *게시 현황*\n"
        "완료된 게시글 목록을 최근 15개까지 보여줍니다."
    )


def _help_shared_text() -> str:
    return (
        "🔗 *공유·충돌 관리 명령어*\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"

        "3개 도구 *(Claude Code / Cursor AI / 텔레그램 봇)*가\n"
        "`shared_state.json` 파일로 실시간 상태를 공유합니다.\n\n"

        "🔗 *공유 현황 버튼*\n"
        "Claude Code와 Cursor AI의 현재 작업 상태 확인\n"
        "• 어떤 파일을 편집 중인지\n"
        "• 마지막 작업 시간 · 진행률\n"
        "• 대기 중인 메시지 여부\n\n"

        "📋 *활동 로그 버튼*\n"
        "세 도구의 최근 15개 작업 내역을 시간순으로 표시\n\n"

        "🚨 *충돌 확인 버튼*\n"
        "동일 파일을 동시에 수정하는 충돌 감지 목록\n"
        "• 🔴 CRITICAL: 즉시 중단 필요 (같은 파일 동시 편집)\n"
        "• 🟡 WARNING: 주의 필요 (동시 작업)\n\n"

        "✅ *충돌 해제 버튼*\n"
        "감지된 충돌을 해제하고 작업을 계속 진행\n\n"

        "⌨️ *텍스트 키워드*\n"
        "`공유 현황` · `클로드 상태` · `지금 뭐해` · `뭐하고 있어`\n"
        "  → Claude Code / Cursor AI 작업 현황\n\n"
        "`충돌` · `충돌 확인`  → 충돌 목록 조회\n"
        "`충돌 해제` · `강제 진행`  → 충돌 해제\n\n"
        "`활동 로그` · `로그` · `작업 내역`  → 로그 확인\n\n"

        "📝 *메모 전달*\n"
        "`메모: [내용]` 또는 `note: [내용]`\n"
        "  → Claude Code가 다음 작업 시 확인하는 메모"
    )


def _help_text_cmd_text() -> str:
    return (
        "⌨️ *텍스트 키워드 명령어*\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n"
        "_버튼 없이 텍스트만 입력해도 작동합니다._\n\n"

        "📊 *현황 조회*\n"
        "┌ `목록` `리스트` `list`\n"
        "├ `발행` `게시` `현황` `상태`\n"
        "├ `오늘` `today` `완료` `대기` `초안`\n"
        "└ → 발행 완료 & 대기 초안 목록 요약\n\n"

        "🔗 *공유 상태*\n"
        "┌ `공유 현황` `클로드 상태` `claude 상태`\n"
        "├ `코드 현황` `지금 뭐해` `뭐하고 있어`\n"
        "└ → Claude Code / Cursor AI 작업 현황\n\n"

        "📋 *활동 로그*\n"
        "┌ `활동 로그` `activity log`\n"
        "├ `로그` `작업 내역`\n"
        "└ → 최근 15개 작업 내역\n\n"

        "🚨 *충돌 관리*\n"
        "┌ `충돌` `conflict` `충돌 확인`  → 충돌 목록\n"
        "└ `충돌 해제` `강제 진행` `충돌해제`  → 충돌 해제\n\n"

        "📊 *API & 큐*\n"
        "┌ `큐` `queue` `rate limit`\n"
        "├ `리밋` `limit` `대기 현황` `api 상태`\n"
        "└ → Rate Limit & 큐 현황\n"
        "  `큐 취소` `작업 취소` `취소`  → 대기 큐 전체 취소\n\n"

        "📝 *메모 전달*\n"
        "┌ `메모: [내용]`  → Claude Code에 메모 전달\n"
        "└ `note: [내용]`  → 동일 (영문)\n\n"

        "✅ *포스팅 인증*\n"
        "└ `인증완료`  → 카카오 추가 인증 완료 알림\n\n"

        "❓ *도움말*\n"
        "┌ `/?` `/help` `?`\n"
        "├ `명령어` `도움말` `사용법`\n"
        "└ `help` `사용 방법`  → 이 가이드"
    )


def _help_api_text() -> str:
    rl = _check_rate_limit_status()
    status_icon = "🟢" if rl["safe"] else "🟡"
    return (
        "📊 *API·큐 관리*\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"

        "📈 *현재 API 상태*\n"
        f"{status_icon} 상태: {'안전' if rl['safe'] else '주의 (호출 빈번)'}\n"
        f"🕐 최근 60초 호출: *{rl['recent_60s']}회*\n"
        f"⚡ 최근 5초 burst: *{rl['burst_5s']}회*\n"
        f"⏳ 권장 딜레이: *{rl['recommended_delay']}초*\n\n"

        "🔄 *Rate Limit 방지 시스템*\n"
        f"• 글 간 자동 딜레이: *{QUEUE_DELAY}초*\n"
        "• Rate Limit 발생 시 자동 재시도 (최대 4회)\n"
        "• 재시도 대기: 60 → 120 → 240 → 480초 (Exponential Backoff)\n"
        "• 대기 중 텔레그램으로 실시간 알림\n\n"

        "📋 *작업 큐 시스템*\n"
        f"• 현재 대기 중: *{len(_task_queue)}개*\n"
        f"• 처리 상태: {'🔄 처리 중' if _queue_running else '⏸ 대기'}\n"
        "• 여러 글 생성 시 순차 처리로 Rate Limit 방지\n\n"

        "⌨️ *텍스트 키워드*\n"
        "`큐` · `queue` · `rate limit` · `api 상태`  → 현황 조회\n"
        "`큐 취소` · `작업 취소`  → 대기 작업 전체 취소\n\n"

        "⚙️ *환경변수 설정 (.env)*\n"
        "`INTER_POST_DELAY=30`  글 간 딜레이(초)\n"
        "`LLM_MAX_RETRY=4`  최대 재시도 횟수\n"
        "`LLM_RETRY_BASE_WAIT=60`  첫 재시도 대기(초)"
    )


def _help_slash_text() -> str:
    return (
        "🔘 *슬래시 명령어*\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"

        "/start\n"
        "  봇을 시작하고 메인 메뉴를 엽니다.\n"
        "  봇 재시작 후 첫 번째로 실행하세요.\n\n"

        "/menu\n"
        "  메인 메뉴를 바로 엽니다.\n"
        "  언제든 메인 화면으로 돌아갈 때 사용.\n\n"

        "/help\n"
        "  이 명령어 가이드를 엽니다.\n\n"

        "/?\n"
        "  `/help`와 동일. 명령어 가이드 열기.\n\n"

        "━━━━━━━━━━━━━━━━━━━━━━\n"
        "💡 텍스트 입력으로도 같은 기능을 사용할 수 있습니다:\n"
        "`/?` · `명령어` · `도움말` · `help` → 가이드\n"
        "`목록` · `현황` · `상태` → 발행 현황 요약"
    )


def _help_tips_text() -> str:
    return (
        "💡 *팁 & 설정*\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"

        "🚀 *빠른 워크플로우*\n"
        "① 🔍 자료조사 → ② ✍️ 글 생성 → ③ 📋 초안 확인\n"
        "→ ④ 🔄 수정 (필요 시) → ⑤ 🚀 포스팅 실행\n\n"

        "⏱️ *작업 소요 시간 기준*\n"
        "• 자료조사: 30초~1분\n"
        "• 글 1편 생성: 1~3분\n"
        "• 포스팅: 2~5분\n"
        f"• 글 간 딜레이: {QUEUE_DELAY}초 (Rate Limit 방지)\n\n"

        "🔔 *자동 알림 목록*\n"
        "• 글 생성 시작 / 완료 / 오류\n"
        "• Rate Limit 발생 및 재시도 대기\n"
        "• 충돌 감지 (CRITICAL / WARNING)\n"
        "• 포스팅 완료\n\n"

        "⚙️ *환경변수 (.env 파일)*\n"
        "`TELEGRAM_BOT_TOKEN`  봇 토큰 (필수)\n"
        "`TELEGRAM_CHAT_ID`  허용 chat ID (보안)\n"
        f"`INTER_POST_DELAY`  글 간 딜레이 (현재: {QUEUE_DELAY}초)\n"
        "`LLM_MAX_RETRY`  Rate Limit 최대 재시도 (기본: 4회)\n"
        "`LLM_RETRY_BASE_WAIT`  첫 재시도 대기 (기본: 60초)\n\n"

        "🛡️ *3-Way 공유 상태 시스템*\n"
        "Claude Code · Cursor AI · 텔레그램 봇이\n"
        "`output/shared_state.json` 파일을 통해 실시간 연동\n"
        "• 충돌 발생 시 텔레그램 자동 알림\n"
        "• Cursor AI: CLI로 상태 업데이트\n"
        "  `python3 shared_state.py cursor start`\n\n"

        "❓ *언제든 도움말로*\n"
        "`/?` 또는 `/help` 를 입력하면 이 가이드로 돌아옵니다."
    )


def _help_all_text() -> str:
    """전체 명령어 한 번에 보기."""
    return (
        "📋 *전체 명령어 목록*\n"
        "━━━━━━━━━━━━━━━━━━━━━━\n\n"

        "🔘 *슬래시* — `/start` `/menu` `/help` `/?`\n\n"

        "🔲 *버튼 메뉴*\n"
        "🔍 자료조사  ✍️ 글 생성  📋 초안 확인\n"
        "🔄 초안 수정  🚀 포스팅 실행  📊 게시 현황\n"
        "⚙️ 상태 조회  🔗 공유 현황  📋 활동 로그\n"
        "🚨 충돌 확인  ❓ 도움말\n\n"

        "⌨️ *텍스트 키워드*\n"
        "• `목록` `발행` `게시` `현황` `상태`  → 현황 조회\n"
        "• `공유 현황` `클로드 상태` `지금 뭐해`  → 공유 상태\n"
        "• `활동 로그` `로그` `작업 내역`  → 로그\n"
        "• `충돌` `충돌 확인`  → 충돌 목록\n"
        "• `충돌 해제` `강제 진행`  → 충돌 해제\n"
        "• `큐` `queue` `rate limit` `api 상태`  → API 현황\n"
        "• `큐 취소` `작업 취소`  → 큐 초기화\n"
        "• `메모: [내용]` `note: [내용]`  → 메모 전달\n"
        "• `인증완료`  → 카카오 인증 완료\n"
        "• `/?` `명령어` `도움말` `help`  → 이 가이드\n\n"

        "━━━━━━━━━━━━━━━━━━━━━━\n"
        "📂 *카테고리별 상세 안내*\n"
        "아래 [도움말 목록]으로 돌아가서 카테고리를 선택하세요."
    )


# ── 도움말 메인 진입 함수 ───────────────────────

def _build_help_text() -> str:
    """하위 호환용 — 도움말 인덱스 텍스트 반환."""
    return _help_index_text()


async def cmd_help(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    """/?  /help 슬래시 명령어 — 도움말 카테고리 메뉴."""
    if not is_allowed(update):
        await update.message.reply_text(
            "⚠️ 이 봇은 허용된 사용자만 사용할 수 있습니다. TELEGRAM_CHAT_ID를 확인해 주세요."
        )
        return
    await update.message.reply_text(
        _help_index_text(),
        reply_markup=help_main_keyboard(),
        parse_mode="Markdown",
    )


async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
    if not is_allowed(update):
        await query.answer("권한 없음")
        return
    await query.answer()
    data = query.data

    # ── 메인 메뉴 ──
    if data == "menu":
        await query.edit_message_text(
            "🏠 *메인 메뉴*",
            reply_markup=main_menu_keyboard(),
            parse_mode="Markdown",
        )

    # ── 도움말 메인 ──
    elif data == "help":
        await query.edit_message_text(
            _help_index_text(),
            reply_markup=help_main_keyboard(),
            parse_mode="Markdown",
        )

    # ── 도움말 카테고리 ──
    elif data == "help_blog":
        await query.edit_message_text(
            _help_blog_text(),
            reply_markup=help_back_keyboard("help_blog"),
            parse_mode="Markdown",
        )

    elif data == "help_shared":
        await query.edit_message_text(
            _help_shared_text(),
            reply_markup=help_back_keyboard("help_shared"),
            parse_mode="Markdown",
        )

    elif data == "help_text":
        await query.edit_message_text(
            _help_text_cmd_text(),
            reply_markup=help_back_keyboard("help_text"),
            parse_mode="Markdown",
        )

    elif data == "help_api":
        await query.edit_message_text(
            _help_api_text(),
            reply_markup=help_back_keyboard("help_api"),
            parse_mode="Markdown",
        )

    elif data == "help_slash":
        await query.edit_message_text(
            _help_slash_text(),
            reply_markup=help_back_keyboard("help_slash"),
            parse_mode="Markdown",
        )

    elif data == "help_tips":
        await query.edit_message_text(
            _help_tips_text(),
            reply_markup=help_back_keyboard("help_tips"),
            parse_mode="Markdown",
        )

    elif data == "help_all":
        await query.edit_message_text(
            _help_all_text(),
            reply_markup=help_back_keyboard("help_all"),
            parse_mode="Markdown",
        )

    # ── 상태 조회 ──
    elif data == "status":
        await query.edit_message_text(
            get_status_text(),
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🔄 새로고침", callback_data="status"),
                InlineKeyboardButton("📊 API 상태", callback_data="rl_status"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )

    # ── Rate Limit 상태 조회 ──
    elif data == "rl_status":
        await query.edit_message_text(
            _get_queue_status_text(),
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🔄 새로고침", callback_data="rl_status"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )

    # ── Claude Code ↔ Bot 공유 현황 ──
    elif data == "shared_status":
        try:
            status_text = telegram_format_status()
        except Exception as e:
            status_text = f"⚠️ 상태 읽기 실패: {e}"
        await query.edit_message_text(
            status_text,
            reply_markup=InlineKeyboardMarkup([
                [
                    InlineKeyboardButton("🔄 새로고침",  callback_data="shared_status"),
                    InlineKeyboardButton("📋 활동 로그", callback_data="activity_log"),
                ],
                [InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")],
            ]),
            parse_mode="Markdown",
        )

    # ── 활동 로그 ──
    elif data == "activity_log":
        try:
            log_text = telegram_get_activity_log(15)
        except Exception as e:
            log_text = f"⚠️ 로그 읽기 실패: {e}"
        await query.edit_message_text(
            log_text,
            reply_markup=InlineKeyboardMarkup([
                [
                    InlineKeyboardButton("🔄 새로고침",   callback_data="activity_log"),
                    InlineKeyboardButton("🔗 공유 현황",  callback_data="shared_status"),
                ],
                [InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")],
            ]),
            parse_mode="Markdown",
        )

    # ── 충돌 확인 ──
    elif data == "conflicts":
        try:
            conflict_text = telegram_get_conflicts(unresolved_only=True)
        except Exception as e:
            conflict_text = f"⚠️ 충돌 확인 실패: {e}"
        await query.edit_message_text(
            conflict_text,
            reply_markup=InlineKeyboardMarkup([
                [
                    InlineKeyboardButton("✅ 충돌 해제",   callback_data="resolve_conflicts"),
                    InlineKeyboardButton("🔄 새로고침",    callback_data="conflicts"),
                ],
                [
                    InlineKeyboardButton("🔗 공유 현황",  callback_data="shared_status"),
                    InlineKeyboardButton("🏠 메인 메뉴",  callback_data="menu"),
                ],
            ]),
            parse_mode="Markdown",
        )

    # ── 충돌 해제 ──
    elif data == "resolve_conflicts":
        try:
            result_text = telegram_resolve_conflicts()
        except Exception as e:
            result_text = f"⚠️ 충돌 해제 실패: {e}"
        await query.edit_message_text(
            result_text,
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🚨 충돌 확인",  callback_data="conflicts"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )

    # ── Claude Code / Cursor AI 에 메시지 전달 ──
    elif data.startswith("msg_to_"):
        target = data.replace("msg_to_", "")
        context.user_data["awaiting"] = f"msg_to_{target}"
        label = {"claude_code": "🖥 Claude Code", "cursor_ai": "🎯 Cursor AI"}.get(target, target)
        await query.edit_message_text(
            f"💬 *{label}* 에 전달할 메시지를 입력하세요:\n\n"
            f"다음 작업 시작 시 해당 도구가 메시지를 확인합니다.",
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("❌ 취소", callback_data="menu")
            ]]),
            parse_mode="Markdown",
        )

    # ── 자료조사 ──
    elif data == "fetch":
        await query.edit_message_text("🔍 AniList 자료조사 중... (30초~1분 소요)")
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "fetch_anime.py"
        )
        status = "✅ 자료조사 완료" if ok else "❌ 자료조사 실패"
        await query.edit_message_text(
            f"{status}\n\n```\n{out[:1000]}\n```",
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("✍️ 글 생성으로 이동", callback_data="generate"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )

    # ── 글 생성 ──
    elif data == "generate":
        pending = list(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        rl = _check_rate_limit_status()
        rl_warn = (
            f"\n⚠️ *최근 60초 내 API 호출 {rl['recent_60s']}회* — 큐 모드 권장"
            if not rl["safe"] else ""
        )
        if pending:
            await query.edit_message_text(
                f"⚠️ 현재 *{len(pending)}개*의 미발행 초안이 있습니다.\n"
                f"기존 초안을 먼저 처리하거나, 계속 생성하겠습니까?{rl_warn}",
                reply_markup=InlineKeyboardMarkup([
                    [
                        InlineKeyboardButton("▶️ 계속 생성",  callback_data="generate_confirm"),
                        InlineKeyboardButton("📋 초안 확인", callback_data="list_drafts"),
                    ],
                    [InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")],
                ]),
                parse_mode="Markdown",
            )
        else:
            await query.edit_message_text(
                f"✍️ 블로그 글 생성을 시작합니다.\n"
                f"⏳ 글 간 {QUEUE_DELAY}초 딜레이로 Rate Limit을 방지합니다.{rl_warn}",
                parse_mode="Markdown",
            )
            _record_api_call()
            ok, out = await asyncio.get_event_loop().run_in_executor(
                None, run_script, "generate_post.py"
            )
            status = "✅ 글 생성 완료" if ok else "❌ 글 생성 실패"
            await query.edit_message_text(
                f"{status}\n\n```\n{out[:1000]}\n```",
                reply_markup=InlineKeyboardMarkup([[
                    InlineKeyboardButton("📋 초안 확인", callback_data="list_drafts"),
                    InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
                ]]),
                parse_mode="Markdown",
            )

    elif data == "generate_confirm":
        rl = _check_rate_limit_status()
        await query.edit_message_text(
            f"✍️ 블로그 글 생성을 시작합니다.\n"
            f"⏳ 글 간 {QUEUE_DELAY}초 딜레이로 Rate Limit을 방지합니다.\n"
            f"📊 최근 60초 API 호출: {rl['recent_60s']}회",
            parse_mode="Markdown",
        )
        _record_api_call()
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "generate_post.py"
        )
        status = "✅ 글 생성 완료" if ok else "❌ 글 생성 실패"
        await query.edit_message_text(
            f"{status}\n\n```\n{out[:1000]}\n```",
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("📋 초안 확인", callback_data="list_drafts"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )

    # ── 초안 목록 ──
    elif data == "list_drafts":
        md_files = sorted(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        if not md_files:
            await query.edit_message_text(
                "📭 대기 중인 초안이 없습니다.\n먼저 자료조사 → 글 생성을 진행하세요.",
                reply_markup=InlineKeyboardMarkup([[
                    InlineKeyboardButton("🔍 자료조사", callback_data="fetch"),
                    InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
                ]]),
                parse_mode="Markdown",
            )
        else:
            context.user_data["md_files"] = [str(f) for f in md_files]
            await query.edit_message_text(
                f"📋 *초안 목록* ({len(md_files)}개)\n\n확인할 초안을 선택하세요:",
                reply_markup=draft_list_keyboard(md_files),
                parse_mode="Markdown",
            )

    # ── 초안 내용 보기 ──
    elif data.startswith("view_"):
        idx = int(data.split("_")[1])
        files = context.user_data.get("md_files", [])
        if idx >= len(files):
            await query.edit_message_text("오류: 파일을 찾을 수 없습니다.")
            return
        p = Path(files[idx])
        if not p.exists():
            await query.edit_message_text("파일이 삭제되었습니다.")
            return
        content = p.read_text(encoding="utf-8")
        # 텔레그램 메시지 길이 제한 (4096자)
        preview = content[:1800] + ("...\n\n[이하 생략]" if len(content) > 1800 else "")
        await query.edit_message_text(
            f"📄 *{p.stem}*\n\n{preview}",
            reply_markup=InlineKeyboardMarkup([
                [
                    InlineKeyboardButton("🔄 수정 요청", callback_data=f"revise_{idx}"),
                    InlineKeyboardButton("🚀 바로 포스팅", callback_data="post"),
                ],
                [InlineKeyboardButton("◀️ 목록으로", callback_data="list_drafts")],
            ]),
            parse_mode="Markdown",
        )

    # ── 초안 삭제 ──
    elif data.startswith("del_"):
        idx = int(data.split("_")[1])
        files = context.user_data.get("md_files", [])
        if idx < len(files):
            p = Path(files[idx])
            if p.exists():
                p.unlink()
                await query.answer(f"🗑️ 삭제 완료: {p.stem}")
        # 목록 새로고침
        md_files = sorted(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        context.user_data["md_files"] = [str(f) for f in md_files]
        if md_files:
            await query.edit_message_text(
                f"📋 *초안 목록* ({len(md_files)}개)",
                reply_markup=draft_list_keyboard(md_files),
                parse_mode="Markdown",
            )
        else:
            await query.edit_message_text(
                "📭 모든 초안이 삭제되었습니다.",
                reply_markup=InlineKeyboardMarkup([[
                    InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")
                ]]),
            )

    # ── 초안 수정 ──
    elif data == "revise" or data.startswith("revise_"):
        idx = int(data.split("_")[1]) if "_" in data and data != "revise" else 0
        context.user_data["revise_idx"] = idx
        context.user_data["awaiting"] = "revise_instruction"
        files = context.user_data.get("md_files", [])
        fname = Path(files[idx]).stem if idx < len(files) else "초안"
        await query.edit_message_text(
            f"🔄 *'{fname}' 수정 요청*\n\n"
            "수정할 내용을 메시지로 입력해주세요.\n\n"
            "예시:\n"
            "• 줄거리 부분을 더 자세하게\n"
            "• 제목을 더 흥미롭게 수정\n"
            "• 총평 섹션 추가\n"
            "• 전체 톤을 더 밝게",
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("❌ 취소", callback_data="list_drafts")
            ]]),
            parse_mode="Markdown",
        )

    # ── 포스팅 실행 ──
    elif data == "post":
        md_files = sorted(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        if not md_files:
            await query.edit_message_text(
                "📭 포스팅할 초안이 없습니다.",
                reply_markup=InlineKeyboardMarkup([[
                    InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")
                ]]),
            )
            return
        first = md_files[0]
        lines = first.read_text(encoding="utf-8").splitlines()
        title = lines[0][2:].strip() if lines and lines[0].startswith("# ") else first.stem
        await query.edit_message_text(
            f"🚀 *포스팅 실행 확인*\n\n"
            f"제목: *{title}*\n"
            f"파일: `{first.name}`\n\n"
            f"Tistory에 자동 게시를 시작하겠습니까?\n"
            f"⚠️ 카카오 추가인증이 필요할 수 있으며,\n"
            f"   인증 완료 후 '인증완료'를 입력해야 합니다.",
            reply_markup=InlineKeyboardMarkup([
                [
                    InlineKeyboardButton("▶️ 포스팅 시작", callback_data="post_confirm"),
                    InlineKeyboardButton("❌ 취소",         callback_data="menu"),
                ],
            ]),
            parse_mode="Markdown",
        )

    elif data == "post_confirm":
        await query.edit_message_text(
            "🚀 포스팅 실행 중...\n\n"
            "브라우저를 자동으로 제어합니다.\n"
            "추가 인증이 필요하면 별도 메시지로 안내드립니다.\n\n"
            "⏳ 완료까지 2~5분 소요될 수 있습니다."
        )
        # 비동기로 포스팅 스크립트 실행 (blocking이므로 executor 사용)
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "post_to_tistory.py"
        )
        status = "✅ 포스팅 완료!" if ok else "❌ 포스팅 실패"
        await query.edit_message_text(
            f"{status}\n\n```\n{out[-1200:]}\n```",
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("📊 게시 현황", callback_data="done_list"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )

    # ── 게시 현황 ──
    elif data == "done_list":
        done_files = sorted(DONE_DIR.glob("*.md"), reverse=True) if DONE_DIR.exists() else []
        if not done_files:
            msg = "📭 완료된 게시글이 없습니다."
        else:
            lines_list = [f"📰 게시 완료 목록 *({len(done_files)}개)*\n"]
            for i, f in enumerate(done_files[:15], 1):
                lines_list.append(f"{i}. {f.stem}")
            msg = "\n".join(lines_list)
        await query.edit_message_text(
            msg,
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")
            ]]),
            parse_mode="Markdown",
        )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 텍스트 메시지 핸들러 (수정 지시 입력 처리)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def _wants_summary(text: str) -> bool:
    """목록/요약/상태/발행 관련 질의인지 간단 키워드로 판단."""
    t = text.lower().strip()
    keywords = (
        "목록", "리스트", "list", "발행", "게시", "published", "post",
        "요약", "summary", "상태", "status", "현황", "어떤", "몇 개",
        "오늘", "today", "완료", "대기", "초안"
    )
    return any(k in t for k in keywords) or "tell me" in t or "what" in t and "post" in t


def _get_queue_status_text() -> str:
    """현재 큐 상태 및 Rate Limit 현황 반환."""
    rl = _check_rate_limit_status()
    queue_count = len(_task_queue)
    status_icon = "🟢" if rl["safe"] else "🟡"
    running_text = "🔄 큐 처리 중" if _queue_running else "⏸ 큐 대기 중"

    lines = [
        f"📊 *Rate Limit & 큐 현황*\n",
        f"{status_icon} API 상태: {'안전' if rl['safe'] else '주의 (호출 빈번)'}",
        f"🕐 최근 60초 API 호출: *{rl['recent_60s']}회*",
        f"⚡ 최근 5초 burst: *{rl['burst_5s']}회*",
        f"⏳ 권장 딜레이: *{rl['recommended_delay']}초*",
        f"",
        f"📋 대기 큐: *{queue_count}개*",
        f"상태: {running_text}",
        f"글 간 딜레이: *{QUEUE_DELAY}초*",
    ]
    return "\n".join(lines)


async def text_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    # 허용되지 않은 사용자도 '수신함'을 알리기 위해 짧은 응답 전송
    if not is_allowed(update):
        await update.message.reply_text(
            "⚠️ 이 봇은 허용된 사용자만 사용할 수 있습니다.\n"
            "TELEGRAM_CHAT_ID를 확인해 주세요."
        )
        return

    awaiting = context.user_data.get("awaiting")
    text = (update.message.text or "").strip()

    # ── 도움말 / 명령어 목록 ──
    if text in ("/?", "/help", "?") or any(k in text for k in ("명령어", "도움말", "help", "사용법", "사용 방법")):
        await update.message.reply_text(
            _help_index_text(),
            reply_markup=help_main_keyboard(),
            parse_mode="Markdown",
        )
        return

    # ── 충돌 해제 ──
    if any(k in text for k in ("충돌 해제", "conflict resolve", "충돌해제", "강제 진행")):
        try:
            result = telegram_resolve_conflicts()
        except Exception as e:
            result = f"⚠️ 충돌 해제 실패: {e}"
        await update.message.reply_text(
            result,
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🚨 충돌 확인",  callback_data="conflicts"),
                InlineKeyboardButton("🔗 공유 현황", callback_data="shared_status"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )
        return

    # ── 충돌 현황 조회 ──
    if any(k in text for k in ("충돌", "conflict", "충돌 확인")):
        try:
            conflict_text = telegram_get_conflicts(unresolved_only=True)
        except Exception as e:
            conflict_text = f"⚠️ 충돌 확인 실패: {e}"
        await update.message.reply_text(
            conflict_text,
            reply_markup=InlineKeyboardMarkup([
                [
                    InlineKeyboardButton("✅ 충돌 해제",  callback_data="resolve_conflicts"),
                    InlineKeyboardButton("🔄 새로고침",   callback_data="conflicts"),
                ],
                [InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")],
            ]),
            parse_mode="Markdown",
        )
        return

    # ── Claude Code 공유 현황 조회 ──
    if any(k in text for k in ("공유 현황", "클로드 상태", "claude 상태", "코드 현황", "지금 뭐해", "뭐하고 있어")):
        try:
            status_text = telegram_format_status()
        except Exception as e:
            status_text = f"⚠️ 상태 읽기 실패: {e}"
        await update.message.reply_text(
            status_text,
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🔄 새로고침",  callback_data="shared_status"),
                InlineKeyboardButton("📋 활동 로그", callback_data="activity_log"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )
        return

    # ── Claude Code에 메모 전달 ──
    if text.startswith("메모:") or text.startswith("note:"):
        note_body = text.split(":", 1)[1].strip()
        if note_body:
            try:
                telegram_add_note(note_body)
                await update.message.reply_text(
                    f"📝 *Claude Code에 메모 전달 완료*\n\n_{note_body}_\n\n"
                    f"Claude Code가 다음 작업 시 확인합니다.",
                    parse_mode="Markdown",
                )
            except Exception as e:
                await update.message.reply_text(f"⚠️ 메모 전달 실패: {e}")
        return

    # ── 활동 로그 조회 ──
    if any(k in text for k in ("활동 로그", "activity log", "로그", "작업 내역")):
        try:
            log_text = telegram_get_activity_log(15)
        except Exception as e:
            log_text = f"⚠️ 로그 읽기 실패: {e}"
        await update.message.reply_text(
            log_text,
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🔗 공유 현황", callback_data="shared_status"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )
        return

    # ── Rate Limit / 큐 상태 조회 ──
    if any(k in text for k in ("큐", "queue", "rate limit", "rate", "리밋", "limit", "대기 현황", "api 상태")):
        await update.message.reply_text(
            _get_queue_status_text(),
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🔄 새로고침", callback_data="rl_status"),
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu"),
            ]]),
            parse_mode="Markdown",
        )
        return

    # ── 큐 취소 ──
    if any(k in text for k in ("큐 취소", "queue cancel", "작업 취소", "취소")):
        count = len(_task_queue)
        _task_queue.clear()
        await update.message.reply_text(
            f"🗑️ 대기 큐 초기화 완료 — {count}개 작업이 취소되었습니다.",
            reply_markup=main_menu_keyboard(),
        )
        return

    # 포스팅 확인 키워드 (post_to_tistory.py가 직접 처리하므로 여기서는 안내만)
    if text in ("인증완료", "포스팅"):
        await update.message.reply_text(
            f"✅ '{text}' 메시지를 받았습니다.\n"
            "포스팅 프로세스가 실행 중이라면 자동으로 반응합니다."
        )
        return

    # 수정 지시 처리
    if awaiting == "revise_instruction":
        context.user_data["awaiting"] = None
        idx = context.user_data.get("revise_idx", 0)
        files = context.user_data.get("md_files", [])

        if not files or idx >= len(files):
            await update.message.reply_text("❌ 수정할 파일을 찾을 수 없습니다.")
            return

        p = Path(files[idx])
        if not p.exists():
            await update.message.reply_text("❌ 파일이 삭제되었습니다.")
            return

        await update.message.reply_text(
            f"🔄 수정 요청 접수: *{p.stem}*\n\n지시: {text}\n\n"
            "generate_post.py로 재생성 중...",
            parse_mode="Markdown",
        )

        # 수정 지시를 파일에 저장 후 generate_post.py 호출
        instruction_file = SCRIPT_DIR / "revision_instruction.txt"
        instruction_file.write_text(
            f"FILE: {p.name}\nINSTRUCTION: {text}\n",
            encoding="utf-8",
        )
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "generate_post.py", ["--revise", str(p), "--instruction", text]
        )
        status = "✅ 수정 완료" if ok else "⚠️ 수정 중 오류 (generate_post.py --revise 파라미터 확인 필요)"
        await update.message.reply_text(
            f"{status}\n\n```\n{out[:800]}\n```",
            reply_markup=main_menu_keyboard(),
            parse_mode="Markdown",
        )
        return

    # 목록/요약/상태 질의 → 발행·대기 목록 요약 응답
    if _wants_summary(text):
        try:
            summary = get_summary_for_user()
            await update.message.reply_text(
                summary,
                reply_markup=main_menu_keyboard(),
                parse_mode="Markdown",
            )
        except Exception as e:
            await update.message.reply_text(
                f"⚠️ 요약 생성 중 오류: {e}\n\n"
                "아래 버튼으로 메뉴를 사용해 주세요.",
                reply_markup=main_menu_keyboard(),
            )
        return

    # 그 외 일반 메시지 → 항상 응답 (상호 통신 유지)
    await update.message.reply_text(
        "메시지 받았습니다. 👋\n\n"
        "블로그 자동화는 아래 버튼으로 이용하세요. "
        "목록·발행 현황이 궁금하면 \"목록 알려줘\" 또는 \"오늘 발행한 글\"이라고 보내도 됩니다.",
        reply_markup=main_menu_keyboard(),
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 메인 진입점
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def main() -> None:
    if not BOT_TOKEN:
        print("❌ TELEGRAM_BOT_TOKEN 환경변수가 설정되지 않았습니다.")
        print("   .env 파일에 TELEGRAM_BOT_TOKEN=... 을 추가하세요.")
        sys.exit(1)

    print(f"📝 GeekBrox 콘텐츠팀장 봇 시작 (chat_id 제한: {ALLOWED_ID or '없음'})")

    app = Application.builder().token(BOT_TOKEN).build()

    app.add_handler(CommandHandler("start", cmd_start))
    app.add_handler(CommandHandler("menu",  cmd_menu))
    app.add_handler(CommandHandler("help",  cmd_help))
    app.add_handler(CommandHandler("?",     cmd_help))
    app.add_handler(CallbackQueryHandler(button_handler))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, text_handler))

    print("✅ 텔레그램 봇 폴링 시작. Ctrl+C로 종료.")
    app.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
