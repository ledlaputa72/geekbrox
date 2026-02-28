"""
content_team_bot.py — GeekBrox 콘텐츠팀장 봇 v3.0 (계층식 버튼 메뉴)

설계 원칙:
  - 모든 제어는 버튼으로 완결 → 텍스트 입력 최소화 (AI 크레딧 절약)
  - 계층식 메뉴: 홈 → 카테고리 → 실행 3단계
  - 버튼 콜백만으로 모든 작업 수행 (LLM 호출 없음)
  - 텍스트는 오직 수정 지시문·메모 입력에만 사용

메뉴 계층:
  🏠 홈
  ├── 1️⃣ 블로그 제작
  │   ├── 1-1 자료조사
  │   ├── 1-2 글 생성
  │   ├── 1-3 초안 목록 → [보기/삭제/수정]
  │   └── 1-4 포스팅 실행
  ├── 2️⃣ 현황 & 통계
  │   ├── 2-1 블로그 현황
  │   ├── 2-2 게시 완료 목록
  │   └── 2-3 API 상태
  ├── 3️⃣ 3-Way 공유
  │   ├── 3-1 공유 현황
  │   ├── 3-2 활동 로그
  │   ├── 3-3 충돌 확인 → [충돌 해제]
  │   └── 3-4 메시지 전달
  └── 4️⃣ 도움말
      ├── 4-1 빠른 시작
      ├── 4-2 버튼 메뉴 안내
      ├── 4-3 슬래시 명령어
      └── 4-4 팁 & 설정

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

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# shared_state 연동
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
try:
    from shared_state import (
        telegram_format_status, telegram_get_activity_log,
        telegram_get_conflicts, telegram_resolve_conflicts,
        telegram_add_note, telegram_send_message,
        ACTOR_CLAUDE, ACTOR_CURSOR,
        STATE_FILE,
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
    STATE_FILE = None

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# python-telegram-bot v20+
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
try:
    from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
    from telegram.ext import (
        Application, CommandHandler, CallbackQueryHandler,
        MessageHandler, ContextTypes, filters,
    )
except ImportError:
    print("python-telegram-bot 없음 → 설치 중...")
    subprocess.run([sys.executable, "-m", "pip", "install",
                    "python-telegram-bot>=20.0", "python-dotenv"], check=True)
    from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
    from telegram.ext import (
        Application, CommandHandler, CallbackQueryHandler,
        MessageHandler, ContextTypes, filters,
    )

load_dotenv()

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 경로 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SCRIPT_DIR   = Path(__file__).resolve().parent
PROJECT_DIR  = SCRIPT_DIR.parent.parent
CONTENT_DIR  = PROJECT_DIR / "teams" / "content" / "workspace"
BLOG_DIR     = CONTENT_DIR / "blog"
POSTS_DIR    = BLOG_DIR / "drafts"
DONE_DIR     = BLOG_DIR / "published"
IMAGES_DIR   = BLOG_DIR / "images"

BOT_TOKEN   = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
ALLOWED_ID  = os.environ.get("TELEGRAM_CHAT_ID", "").strip()

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Rate Limit 방지 큐
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_task_queue: deque = deque()
_queue_running: bool = False
QUEUE_DELAY = int(os.environ.get("INTER_POST_DELAY", "30"))
_api_call_times: deque = deque(maxlen=20)


def _check_rate_limit_status() -> dict:
    now = time.time()
    recent = sum(1 for t in _api_call_times if now - t < 60)
    burst  = sum(1 for t in _api_call_times if now - t < 5)
    return {
        "recent_60s": recent,
        "burst_5s": burst,
        "safe": recent < 8 and burst < 2,
        "recommended_delay": max(QUEUE_DELAY, 60 // max(1, 8 - recent)),
    }


def _record_api_call():
    _api_call_times.append(time.time())


async def _process_queue(app_bot, chat_id: int):
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
            await app_bot.send_message(
                chat_id=chat_id,
                text=f"▶️ *작업 시작* [{completed}/{total}]\n📄 {task['label']}\n⏳ 남은: {remaining}개",
                parse_mode="Markdown",
            )
            _record_api_call()
            ok, out = await asyncio.get_event_loop().run_in_executor(
                None, run_script, task["script"], task.get("args")
            )
            icon = "✅" if ok else "❌"
            await app_bot.send_message(
                chat_id=chat_id,
                text=(
                    f"{icon} *완료* [{completed}/{total}]: {task['label']}\n\n"
                    f"```\n{out[:600]}\n```"
                    + (f"\n\n⏳ 다음까지 {QUEUE_DELAY}초 대기..." if remaining > 0 else "")
                ),
                parse_mode="Markdown",
            )
            if remaining > 0:
                await asyncio.sleep(QUEUE_DELAY)
    finally:
        _queue_running = False
    await app_bot.send_message(
        chat_id=chat_id,
        text=f"🎉 *모든 작업 완료!* ({total}개)",
        parse_mode="Markdown",
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 보안
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def is_allowed(update: Update) -> bool:
    if not ALLOWED_ID:
        return True
    return str(update.effective_chat.id) == ALLOWED_ID


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 유틸
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def run_script(script_name: str, args: list[str] | None = None) -> tuple[bool, str]:
    path = SCRIPT_DIR / script_name
    if not path.exists():
        return False, f"스크립트 없음: {path}"
    try:
        r = subprocess.run(
            [sys.executable, str(path)] + (args or []),
            capture_output=True, text=True, timeout=300, cwd=str(PROJECT_DIR),
        )
        out = (r.stdout + r.stderr).strip()
        return r.returncode == 0, out[-1500:] if len(out) > 1500 else out
    except subprocess.TimeoutExpired:
        return False, "⏱️ 실행 시간 초과 (5분)"
    except Exception as e:
        return False, f"실행 오류: {e}"


def get_status_text() -> str:
    drafts  = list(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
    done    = list(DONE_DIR.glob("*.md"))  if DONE_DIR.exists()  else []
    images  = list(IMAGES_DIR.glob("*.*")) if IMAGES_DIR.exists() else []
    now     = datetime.now().strftime("%Y-%m-%d %H:%M")
    rl      = _check_rate_limit_status()
    return (
        f"⚙️ *GeekBrox 블로그 현황* ({now})\n\n"
        f"📝 초안 대기: *{len(drafts)}개*\n"
        f"✅ 게시 완료: *{len(done)}개*\n"
        f"🖼️ 이미지: *{len(images)}개*\n\n"
        f"{'🟢 대기 초안 있음' if drafts else '⚪️ 대기 초안 없음'}\n"
        f"{'🟢 API 안전' if rl['safe'] else '🟡 API 주의'} (60초 내 {rl['recent_60s']}회 호출)"
    )


def get_done_list_text() -> str:
    done = sorted(DONE_DIR.glob("*.md"), reverse=True) if DONE_DIR.exists() else []
    if not done:
        return "📭 게시 완료된 글이 없습니다."
    lines = [f"📰 *게시 완료 목록* ({len(done)}개)\n"]
    for i, f in enumerate(done[:20], 1):
        lines.append(f"{i}. {f.stem[:45]}")
    if len(done) > 20:
        lines.append(f"… 외 {len(done) - 20}개")
    return "\n".join(lines)


def get_queue_status_text() -> str:
    rl = _check_rate_limit_status()
    icon = "🟢" if rl["safe"] else "🟡"
    return (
        f"📊 *API & 큐 현황*\n\n"
        f"{icon} 상태: {'안전' if rl['safe'] else '주의'}\n"
        f"🕐 최근 60초 호출: *{rl['recent_60s']}회*\n"
        f"⚡ 최근 5초 burst: *{rl['burst_5s']}회*\n"
        f"⏳ 권장 딜레이: *{rl['recommended_delay']}초*\n\n"
        f"📋 대기 큐: *{len(_task_queue)}개*\n"
        f"상태: {'🔄 처리 중' if _queue_running else '⏸ 대기'}\n"
        f"글 간 딜레이: *{QUEUE_DELAY}초*"
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 키보드 빌더 — 계층식 메뉴
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def KB(*rows) -> InlineKeyboardMarkup:
    """단축 키보드 생성 헬퍼."""
    return InlineKeyboardMarkup(list(rows))

def BTN(label: str, cb: str) -> InlineKeyboardButton:
    return InlineKeyboardButton(label, callback_data=cb)

def BACK(cb: str = "menu") -> list[InlineKeyboardButton]:
    return [BTN("🏠 홈", cb)]


# ── 홈 메뉴 ───────────────────────────────────
def kb_home() -> InlineKeyboardMarkup:
    return KB(
        [BTN("1️⃣  블로그 제작",    "m_blog"),
         BTN("2️⃣  현황 & 통계",    "m_stats")],
        [BTN("3️⃣  3-Way 공유",     "m_share"),
         BTN("4️⃣  도움말",         "m_help")],
    )


# ── 1. 블로그 제작 ────────────────────────────
def kb_blog() -> InlineKeyboardMarkup:
    drafts = list(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
    draft_label = f"1-3  초안 확인 ({len(drafts)}개)" if drafts else "1-3  초안 확인 (없음)"
    return KB(
        [BTN("1-1  🔍 자료조사",     "blog_fetch"),
         BTN("1-2  ✍️ 글 생성",      "blog_generate")],
        [BTN(f"1-3  📋 {draft_label}", "blog_drafts")],
        [BTN("1-4  🚀 포스팅 실행",  "blog_post")],
        BACK(),
    )


# ── 2. 현황 & 통계 ────────────────────────────
def kb_stats() -> InlineKeyboardMarkup:
    return KB(
        [BTN("2-1  ⚙️ 블로그 현황",   "stats_status"),
         BTN("2-2  📰 게시 완료 목록", "stats_done")],
        [BTN("2-3  📊 API & 큐 상태",  "stats_api")],
        BACK(),
    )


# ── 3. 3-Way 공유 ────────────────────────────
def kb_share() -> InlineKeyboardMarkup:
    return KB(
        [BTN("3-1  🔗 공유 현황",     "share_status"),
         BTN("3-2  📋 활동 로그",     "share_log")],
        [BTN("3-3  🚨 충돌 확인",     "share_conflicts"),
         BTN("3-4  💬 메시지 전달",   "share_msg")],
        BACK(),
    )


# ── 4. 도움말 ────────────────────────────────
def kb_help() -> InlineKeyboardMarkup:
    return KB(
        [BTN("4-1  🚀 빠른 시작",     "help_quick"),
         BTN("4-2  🔲 버튼 메뉴 안내", "help_buttons")],
        [BTN("4-3  🔘 슬래시 명령어", "help_slash"),
         BTN("4-4  💡 팁 & 설정",     "help_tips")],
        [BTN("📋 전체 명령어 보기",   "help_all")],
        BACK(),
    )


# ── 초안 목록 ────────────────────────────────
def kb_draft_list(md_files: list[Path]) -> InlineKeyboardMarkup:
    rows = []
    for i, f in enumerate(md_files[:8]):
        rows.append([
            BTN(f"📄 {f.stem[:26]}", f"view_{i}"),
            BTN("✏️ 수정", f"revise_{i}"),
            BTN("🗑", f"del_{i}"),
        ])
    rows.append([BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")])
    return InlineKeyboardMarkup(rows)


def kb_draft_view(idx: int) -> InlineKeyboardMarkup:
    return KB(
        [BTN("✏️ 수정 요청", f"revise_{idx}"),
         BTN("🚀 바로 포스팅", "blog_post")],
        [BTN("◀️ 초안 목록", "blog_drafts"), BTN("🏠 홈", "menu")],
    )


# ── 충돌 확인 ────────────────────────────────
def kb_conflicts() -> InlineKeyboardMarkup:
    return KB(
        [BTN("✅ 충돌 해제",   "share_resolve"),
         BTN("🔄 새로고침",   "share_conflicts")],
        [BTN("◀️ 3-Way 공유", "m_share"), BTN("🏠 홈", "menu")],
    )


# ── 메시지 전달 대상 ─────────────────────────
def kb_msg_target() -> InlineKeyboardMarkup:
    return KB(
        [BTN("🖥 Claude Code에게",  "msg_to_claude_code"),
         BTN("🎯 Cursor AI에게",    "msg_to_cursor_ai")],
        [BTN("◀️ 3-Way 공유", "m_share"), BTN("🏠 홈", "menu")],
    )


# ── 공유 현황 ────────────────────────────────
def kb_share_status() -> InlineKeyboardMarkup:
    return KB(
        [BTN("🔄 새로고침",   "share_status"),
         BTN("📋 활동 로그", "share_log")],
        [BTN("◀️ 3-Way 공유", "m_share"), BTN("🏠 홈", "menu")],
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 도움말 텍스트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def txt_help_quick() -> str:
    return (
        "🚀 *빠른 시작 가이드*\n"
        "━━━━━━━━━━━━━━━━━━\n\n"
        "블로그 글 1편 만들기:\n"
        "① `/start` → 홈 메뉴\n"
        "② *1️⃣ 블로그 제작* 버튼\n"
        "③ *1-1 🔍 자료조사* → 완료 대기\n"
        "④ *1-2 ✍️ 글 생성* → 완료 대기\n"
        "⑤ *1-3 📋 초안 확인* → 내용 확인\n"
        "⑥ *1-4 🚀 포스팅 실행* → 게시 완료\n\n"
        "💡 모든 작업은 버튼으로만 진행됩니다.\n"
        "텍스트 입력은 초안 수정 지시문·메모만 사용합니다."
    )


def txt_help_buttons() -> str:
    return (
        "🔲 *버튼 메뉴 전체 안내*\n"
        "━━━━━━━━━━━━━━━━━━\n\n"
        "🏠 *홈*\n"
        "┣ 1️⃣ *블로그 제작*\n"
        "┃  ┣ 1-1 🔍 자료조사 — AniList 수집\n"
        "┃  ┣ 1-2 ✍️ 글 생성 — Claude/Gemini 작성\n"
        "┃  ┣ 1-3 📋 초안 확인 — 목록 · 보기 · 수정 · 삭제\n"
        "┃  ┗ 1-4 🚀 포스팅 실행 — Tistory 자동 게시\n\n"
        "┣ 2️⃣ *현황 & 통계*\n"
        "┃  ┣ 2-1 ⚙️ 블로그 현황 — 초안/완료/이미지 수\n"
        "┃  ┣ 2-2 📰 게시 완료 목록 — 최근 20개\n"
        "┃  ┗ 2-3 📊 API & 큐 상태 — Rate Limit 현황\n\n"
        "┣ 3️⃣ *3-Way 공유*\n"
        "┃  ┣ 3-1 🔗 공유 현황 — Claude/Cursor 작업 상태\n"
        "┃  ┣ 3-2 📋 활동 로그 — 최근 15개 작업 내역\n"
        "┃  ┣ 3-3 🚨 충돌 확인 — 동시 편집 충돌\n"
        "┃  ┗ 3-4 💬 메시지 전달 — Claude/Cursor에 메모\n\n"
        "┗ 4️⃣ *도움말*\n"
        "   ┣ 4-1 🚀 빠른 시작\n"
        "   ┣ 4-2 🔲 버튼 메뉴 안내 (현재)\n"
        "   ┣ 4-3 🔘 슬래시 명령어\n"
        "   ┗ 4-4 💡 팁 & 설정"
    )


def txt_help_slash() -> str:
    return (
        "🔘 *슬래시 명령어*\n"
        "━━━━━━━━━━━━━━━━━━\n\n"
        "`/start` — 봇 시작, 홈 메뉴 열기\n"
        "`/menu`  — 홈 메뉴 열기 (동일)\n"
        "`/help`  — 도움말 메뉴\n"
        "`/?`     — 도움말 메뉴 (동일)\n\n"
        "📌 *특수 텍스트 입력* (수정 지시·메모에만 사용)\n"
        "`메모: [내용]` — Claude Code에 메모 전달\n"
        "`note: [내용]` — 동일 (영문)\n"
        "`인증완료`     — 카카오 추가 인증 완료 알림\n\n"
        "⚠️ 그 외 일반 텍스트는 봇이 응답하지 않습니다.\n"
        "모든 제어는 버튼으로 진행하세요."
    )


def txt_help_tips() -> str:
    return (
        "💡 *팁 & 설정*\n"
        "━━━━━━━━━━━━━━━━━━\n\n"
        "⏱️ *작업 소요 시간*\n"
        "• 자료조사: 30초~1분\n"
        "• 글 1편 생성: 1~3분\n"
        f"• 글 간 딜레이: {QUEUE_DELAY}초 (Rate Limit 방지)\n"
        "• 포스팅: 2~5분\n\n"
        "🔔 *자동 알림 목록*\n"
        "• 글 생성 시작/완료/오류\n"
        "• Rate Limit 발생 및 재시도\n"
        "• 충돌 감지 (CRITICAL/WARNING)\n\n"
        "⚙️ *.env 환경변수*\n"
        "`TELEGRAM_BOT_TOKEN` — 봇 토큰\n"
        "`TELEGRAM_CHAT_ID`   — 허용 ID\n"
        f"`INTER_POST_DELAY`   — 글 간 딜레이 (현재 {QUEUE_DELAY}초)\n"
        "`LLM_MAX_RETRY`      — 최대 재시도 (기본 4회)\n\n"
        "🛡️ *AI 크레딧 절약 설계*\n"
        "• 버튼 콜백 = LLM 없이 즉시 실행\n"
        "• 텍스트 입력은 수정 지시·메모에만 사용\n"
        "• Rate Limit 자동 감지 + 딜레이 큐"
    )


def txt_help_all() -> str:
    return (
        "📋 *전체 명령어 요약*\n"
        "━━━━━━━━━━━━━━━━━━\n\n"
        "🔘 `/start` `/menu` `/help` `/?`\n\n"
        "1️⃣ 블로그: 1-1자료조사 1-2글생성 1-3초안 1-4포스팅\n"
        "2️⃣ 현황: 2-1블로그 2-2게시완료 2-3API상태\n"
        "3️⃣ 공유: 3-1공유현황 3-2로그 3-3충돌 3-4메시지\n"
        "4️⃣ 도움말: 4-1빠른시작 4-2버튼안내 4-3슬래시 4-4팁\n\n"
        "✏️ *텍스트 입력* (최소화 권장)\n"
        "`메모: [내용]` `note: [내용]` `인증완료`\n"
        "초안 수정 지시문 (수정 요청 버튼 후)"
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 핸들러
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def cmd_start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not is_allowed(update):
        await update.message.reply_text("⚠️ 허용된 사용자만 이용 가능합니다.")
        return
    await update.message.reply_text(
        "👋 *GeekBrox 콘텐츠팀장 봇* v3.0\n\n"
        "📝 블로그 자동화를 버튼으로 완전 제어합니다.\n"
        "아래 카테고리를 선택하세요.",
        reply_markup=kb_home(),
        parse_mode="Markdown",
    )


async def cmd_menu(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not is_allowed(update):
        await update.message.reply_text("⚠️ 허용된 사용자만 이용 가능합니다.")
        return
    await update.message.reply_text(
        "🏠 *홈 메뉴*",
        reply_markup=kb_home(),
        parse_mode="Markdown",
    )


async def cmd_help(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not is_allowed(update):
        await update.message.reply_text("⚠️ 허용된 사용자만 이용 가능합니다.")
        return
    await update.message.reply_text(
        "4️⃣ *도움말*\n\n항목을 선택하세요.",
        reply_markup=kb_help(),
        parse_mode="Markdown",
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 버튼 핸들러 (모든 제어의 핵심)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
    if not is_allowed(update):
        await query.answer("권한 없음")
        return
    await query.answer()
    d = query.data

    # ──────────────────────────────
    # 홈
    # ──────────────────────────────
    if d == "menu":
        await query.edit_message_text(
            "🏠 *홈 메뉴*",
            reply_markup=kb_home(), parse_mode="Markdown",
        )

    # ──────────────────────────────
    # 1. 블로그 제작 메뉴
    # ──────────────────────────────
    elif d == "m_blog":
        drafts = list(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        await query.edit_message_text(
            f"1️⃣ *블로그 제작*\n\n📝 대기 초안: *{len(drafts)}개*\n작업을 선택하세요.",
            reply_markup=kb_blog(), parse_mode="Markdown",
        )

    # 1-1 자료조사
    elif d == "blog_fetch":
        await query.edit_message_text(
            "🔍 *자료조사 실행 중...*\n\nAniList에서 최신 애니 데이터를 수집합니다.\n⏳ 30초~1분 소요"
        )
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "fetch_anime.py"
        )
        icon = "✅" if ok else "❌"
        await query.edit_message_text(
            f"{icon} *자료조사 {'완료' if ok else '실패'}*\n\n```\n{out[:800]}\n```",
            reply_markup=KB(
                [BTN("1-2 ✍️ 글 생성으로 이동", "blog_generate")],
                [BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")],
            ),
            parse_mode="Markdown",
        )

    # 1-2 글 생성
    elif d == "blog_generate":
        drafts = list(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        rl = _check_rate_limit_status()
        rl_warn = f"\n⚠️ API 호출 빈번 ({rl['recent_60s']}회/60초) — 딜레이 적용" if not rl["safe"] else ""
        if drafts:
            await query.edit_message_text(
                f"⚠️ 미발행 초안 *{len(drafts)}개* 있습니다.{rl_warn}\n\n계속 생성하시겠습니까?",
                reply_markup=KB(
                    [BTN("▶️ 계속 생성", "blog_gen_confirm"),
                     BTN("📋 초안 먼저 확인", "blog_drafts")],
                    [BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")],
                ),
                parse_mode="Markdown",
            )
        else:
            await query.edit_message_text(
                f"✍️ *글 생성 시작*\n\n⏳ 글 간 딜레이: {QUEUE_DELAY}초{rl_warn}\n생성 중입니다...",
                parse_mode="Markdown",
            )
            _record_api_call()
            ok, out = await asyncio.get_event_loop().run_in_executor(
                None, run_script, "generate_post.py"
            )
            icon = "✅" if ok else "❌"
            await query.edit_message_text(
                f"{icon} *글 생성 {'완료' if ok else '실패'}*\n\n```\n{out[:800]}\n```",
                reply_markup=KB(
                    [BTN("1-3 📋 초안 확인", "blog_drafts")],
                    [BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")],
                ),
                parse_mode="Markdown",
            )

    elif d == "blog_gen_confirm":
        await query.edit_message_text("✍️ 글 생성 중...")
        _record_api_call()
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "generate_post.py"
        )
        icon = "✅" if ok else "❌"
        await query.edit_message_text(
            f"{icon} *글 생성 {'완료' if ok else '실패'}*\n\n```\n{out[:800]}\n```",
            reply_markup=KB(
                [BTN("1-3 📋 초안 확인", "blog_drafts")],
                [BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")],
            ),
            parse_mode="Markdown",
        )

    # 1-3 초안 목록
    elif d == "blog_drafts":
        md_files = sorted(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        if not md_files:
            await query.edit_message_text(
                "📭 *초안 없음*\n\n먼저 자료조사 → 글 생성을 진행하세요.",
                reply_markup=KB(
                    [BTN("1-1 🔍 자료조사", "blog_fetch"),
                     BTN("1-2 ✍️ 글 생성", "blog_generate")],
                    [BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")],
                ),
                parse_mode="Markdown",
            )
        else:
            context.user_data["md_files"] = [str(f) for f in md_files]
            await query.edit_message_text(
                f"📋 *초안 목록* ({len(md_files)}개)\n\n[📄보기] [✏️수정] [🗑삭제]",
                reply_markup=kb_draft_list(md_files),
                parse_mode="Markdown",
            )

    # 초안 보기
    elif d.startswith("view_"):
        idx = int(d.split("_")[1])
        files = context.user_data.get("md_files", [])
        if idx >= len(files):
            await query.edit_message_text("❌ 파일을 찾을 수 없습니다.")
            return
        p = Path(files[idx])
        if not p.exists():
            await query.edit_message_text("❌ 파일이 삭제되었습니다.")
            return
        content = p.read_text(encoding="utf-8")
        preview = content[:1600] + ("…[이하 생략]" if len(content) > 1600 else "")
        await query.edit_message_text(
            f"📄 *{p.stem}*\n\n{preview}",
            reply_markup=kb_draft_view(idx),
            parse_mode="Markdown",
        )

    # 초안 삭제
    elif d.startswith("del_"):
        idx = int(d.split("_")[1])
        files = context.user_data.get("md_files", [])
        if idx < len(files):
            p = Path(files[idx])
            if p.exists():
                p.unlink()
                await query.answer(f"🗑 삭제: {p.stem[:20]}")
        md_files = sorted(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        context.user_data["md_files"] = [str(f) for f in md_files]
        if md_files:
            await query.edit_message_text(
                f"📋 *초안 목록* ({len(md_files)}개)",
                reply_markup=kb_draft_list(md_files),
                parse_mode="Markdown",
            )
        else:
            await query.edit_message_text(
                "📭 모든 초안이 삭제되었습니다.",
                reply_markup=KB([BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")]),
            )

    # 초안 수정 요청
    elif d.startswith("revise_"):
        idx = int(d.split("_")[1])
        context.user_data["revise_idx"] = idx
        context.user_data["awaiting"] = "revise_instruction"
        files = context.user_data.get("md_files", [])
        fname = Path(files[idx]).stem if idx < len(files) else "초안"
        await query.edit_message_text(
            f"✏️ *수정 지시 입력*\n\n대상: `{fname[:40]}`\n\n"
            "수정할 내용을 메시지로 입력하세요.\n\n"
            "_예시: 줄거리를 더 상세하게, 제목을 더 흥미롭게_",
            reply_markup=KB([BTN("❌ 취소", "blog_drafts")]),
            parse_mode="Markdown",
        )

    # 1-4 포스팅 실행
    elif d == "blog_post":
        md_files = sorted(POSTS_DIR.glob("*.md")) if POSTS_DIR.exists() else []
        if not md_files:
            await query.edit_message_text(
                "📭 포스팅할 초안이 없습니다.",
                reply_markup=KB(
                    [BTN("1-2 ✍️ 글 생성", "blog_generate")],
                    [BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")],
                ),
            )
            return
        first = md_files[0]
        lines = first.read_text(encoding="utf-8").splitlines()
        title = lines[0][2:].strip() if lines and lines[0].startswith("# ") else first.stem
        await query.edit_message_text(
            f"🚀 *포스팅 실행 확인*\n\n"
            f"제목: *{title[:60]}*\n"
            f"파일: `{first.name}`\n\n"
            "Tistory에 자동 게시합니다.\n"
            "⚠️ 카카오 추가 인증이 필요할 수 있습니다.",
            reply_markup=KB(
                [BTN("▶️ 포스팅 시작", "blog_post_confirm"),
                 BTN("❌ 취소", "m_blog")],
            ),
            parse_mode="Markdown",
        )

    elif d == "blog_post_confirm":
        await query.edit_message_text(
            "🚀 포스팅 실행 중...\n\n"
            "브라우저를 자동 제어합니다.\n"
            "추가 인증 시 `인증완료` 를 입력해주세요.\n"
            "⏳ 2~5분 소요"
        )
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "post_to_tistory.py"
        )
        icon = "✅" if ok else "❌"
        await query.edit_message_text(
            f"{icon} *포스팅 {'완료' if ok else '실패'}*\n\n```\n{out[-1000:]}\n```",
            reply_markup=KB(
                [BTN("2-2 📰 게시 완료 목록", "stats_done")],
                [BTN("◀️ 블로그 제작", "m_blog"), BTN("🏠 홈", "menu")],
            ),
            parse_mode="Markdown",
        )

    # ──────────────────────────────
    # 2. 현황 & 통계
    # ──────────────────────────────
    elif d == "m_stats":
        await query.edit_message_text(
            "2️⃣ *현황 & 통계*\n\n항목을 선택하세요.",
            reply_markup=kb_stats(), parse_mode="Markdown",
        )

    elif d == "stats_status":
        await query.edit_message_text(
            get_status_text(),
            reply_markup=KB(
                [BTN("🔄 새로고침", "stats_status"),
                 BTN("2-3 📊 API 상태", "stats_api")],
                [BTN("◀️ 현황 & 통계", "m_stats"), BTN("🏠 홈", "menu")],
            ),
            parse_mode="Markdown",
        )

    elif d == "stats_done":
        await query.edit_message_text(
            get_done_list_text(),
            reply_markup=KB(
                [BTN("🔄 새로고침", "stats_done")],
                [BTN("◀️ 현황 & 통계", "m_stats"), BTN("🏠 홈", "menu")],
            ),
            parse_mode="Markdown",
        )

    elif d == "stats_api":
        await query.edit_message_text(
            get_queue_status_text(),
            reply_markup=KB(
                [BTN("🔄 새로고침", "stats_api")],
                [BTN("◀️ 현황 & 통계", "m_stats"), BTN("🏠 홈", "menu")],
            ),
            parse_mode="Markdown",
        )

    # ──────────────────────────────
    # 3. 3-Way 공유
    # ──────────────────────────────
    elif d == "m_share":
        await query.edit_message_text(
            "3️⃣ *3-Way 공유 상태*\n\nClaude Code · Cursor AI · 봇 간 공유 현황",
            reply_markup=kb_share(), parse_mode="Markdown",
        )

    elif d == "share_status":
        try:
            txt = telegram_format_status()
        except Exception as e:
            txt = f"⚠️ 상태 읽기 실패: {e}"
        await query.edit_message_text(
            txt, reply_markup=kb_share_status(), parse_mode="Markdown",
        )

    elif d == "share_log":
        try:
            txt = telegram_get_activity_log(15)
        except Exception as e:
            txt = f"⚠️ 로그 읽기 실패: {e}"
        await query.edit_message_text(
            txt,
            reply_markup=KB(
                [BTN("🔄 새로고침", "share_log"),
                 BTN("3-1 🔗 공유 현황", "share_status")],
                [BTN("◀️ 3-Way 공유", "m_share"), BTN("🏠 홈", "menu")],
            ),
            parse_mode="Markdown",
        )

    elif d == "share_conflicts":
        try:
            txt = telegram_get_conflicts(unresolved_only=True)
        except Exception as e:
            txt = f"⚠️ 충돌 확인 실패: {e}"
        await query.edit_message_text(
            txt, reply_markup=kb_conflicts(), parse_mode="Markdown",
        )

    elif d == "share_resolve":
        try:
            txt = telegram_resolve_conflicts()
        except Exception as e:
            txt = f"⚠️ 충돌 해제 실패: {e}"
        await query.edit_message_text(
            txt,
            reply_markup=KB(
                [BTN("🔄 충돌 확인", "share_conflicts")],
                [BTN("◀️ 3-Way 공유", "m_share"), BTN("🏠 홈", "menu")],
            ),
            parse_mode="Markdown",
        )

    elif d == "share_msg":
        await query.edit_message_text(
            "💬 *메시지 전달 대상 선택*\n\n전달할 도구를 선택하세요.",
            reply_markup=kb_msg_target(), parse_mode="Markdown",
        )

    elif d.startswith("msg_to_"):
        target = d.replace("msg_to_", "")
        context.user_data["awaiting"] = f"msg_to_{target}"
        label = {"claude_code": "🖥 Claude Code", "cursor_ai": "🎯 Cursor AI"}.get(target, target)
        await query.edit_message_text(
            f"💬 *{label}* 에 전달할 메시지를 입력하세요.\n\n"
            "_다음 작업 시작 시 해당 도구가 확인합니다._",
            reply_markup=KB([BTN("❌ 취소", "m_share")]),
            parse_mode="Markdown",
        )

    # ──────────────────────────────
    # 4. 도움말
    # ──────────────────────────────
    elif d == "m_help":
        await query.edit_message_text(
            "4️⃣ *도움말*\n\n항목을 선택하세요.",
            reply_markup=kb_help(), parse_mode="Markdown",
        )

    elif d == "help_quick":
        await query.edit_message_text(
            txt_help_quick(),
            reply_markup=KB([BTN("◀️ 도움말", "m_help"), BTN("🏠 홈", "menu")]),
            parse_mode="Markdown",
        )

    elif d == "help_buttons":
        await query.edit_message_text(
            txt_help_buttons(),
            reply_markup=KB([BTN("◀️ 도움말", "m_help"), BTN("🏠 홈", "menu")]),
            parse_mode="Markdown",
        )

    elif d == "help_slash":
        await query.edit_message_text(
            txt_help_slash(),
            reply_markup=KB([BTN("◀️ 도움말", "m_help"), BTN("🏠 홈", "menu")]),
            parse_mode="Markdown",
        )

    elif d == "help_tips":
        await query.edit_message_text(
            txt_help_tips(),
            reply_markup=KB([BTN("◀️ 도움말", "m_help"), BTN("🏠 홈", "menu")]),
            parse_mode="Markdown",
        )

    elif d == "help_all":
        await query.edit_message_text(
            txt_help_all(),
            reply_markup=KB([BTN("◀️ 도움말", "m_help"), BTN("🏠 홈", "menu")]),
            parse_mode="Markdown",
        )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 텍스트 핸들러 (최소화 — 수정 지시·메모에만 반응)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def text_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not is_allowed(update):
        await update.message.reply_text("⚠️ 허용된 사용자만 이용 가능합니다.")
        return

    text    = (update.message.text or "").strip()
    awaiting = context.user_data.get("awaiting")

    # ── 수정 지시 입력 ──
    if awaiting == "revise_instruction":
        context.user_data["awaiting"] = None
        idx   = context.user_data.get("revise_idx", 0)
        files = context.user_data.get("md_files", [])
        if not files or idx >= len(files):
            await update.message.reply_text("❌ 수정할 파일을 찾을 수 없습니다.", reply_markup=kb_home())
            return
        p = Path(files[idx])
        if not p.exists():
            await update.message.reply_text("❌ 파일이 삭제되었습니다.", reply_markup=kb_home())
            return
        await update.message.reply_text(
            f"✏️ 수정 요청 접수\n대상: `{p.stem[:40]}`\n지시: _{text}_\n\n재생성 중...",
            parse_mode="Markdown",
        )
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "generate_post.py",
            ["--revise", str(p), "--instruction", text]
        )
        icon = "✅" if ok else "⚠️"
        await update.message.reply_text(
            f"{icon} 수정 {'완료' if ok else '실패'}\n\n```\n{out[:600]}\n```",
            reply_markup=kb_home(), parse_mode="Markdown",
        )
        return

    # ── 메시지 전달 입력 ──
    if awaiting and awaiting.startswith("msg_to_"):
        context.user_data["awaiting"] = None
        target = awaiting.replace("msg_to_", "")
        label  = {"claude_code": "🖥 Claude Code", "cursor_ai": "🎯 Cursor AI"}.get(target, target)
        try:
            telegram_send_message(target, text)
            await update.message.reply_text(
                f"✅ *{label}* 에 메시지 전달 완료\n\n_{text}_",
                reply_markup=kb_home(), parse_mode="Markdown",
            )
        except Exception as e:
            await update.message.reply_text(f"⚠️ 전달 실패: {e}", reply_markup=kb_home())
        return

    # ── 메모 전달 ──
    if text.startswith("메모:") or text.startswith("note:"):
        note = text.split(":", 1)[1].strip()
        if note:
            try:
                telegram_add_note(note)
                await update.message.reply_text(
                    f"📝 메모 전달 완료\n_{note}_", reply_markup=kb_home(), parse_mode="Markdown",
                )
            except Exception as e:
                await update.message.reply_text(f"⚠️ 메모 실패: {e}", reply_markup=kb_home())
        return

    # ── 인증완료 ──
    if text == "인증완료":
        await update.message.reply_text(
            "✅ 인증완료 수신. 포스팅 프로세스가 계속 진행됩니다.",
            reply_markup=kb_home(),
        )
        return

    # ── 그 외: 홈 메뉴로 유도 (LLM 응답 없음 → 크레딧 절약) ──
    await update.message.reply_text(
        "👇 버튼으로 제어하세요.",
        reply_markup=kb_home(),
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 메인
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def main() -> None:
    if not BOT_TOKEN:
        print("❌ TELEGRAM_BOT_TOKEN 환경변수가 없습니다. .env 파일을 확인하세요.")
        sys.exit(1)

    print(f"🤖 GeekBrox 콘텐츠팀장 봇 v3.0 시작 (chat_id 제한: {ALLOWED_ID or '없음'})")
    print(f"   BLOG_DIR: {BLOG_DIR}")
    print(f"   POSTS  : {POSTS_DIR}")
    print(f"   DONE   : {DONE_DIR}")

    app = Application.builder().token(BOT_TOKEN).build()

    app.add_handler(CommandHandler("start", cmd_start))
    app.add_handler(CommandHandler("menu",  cmd_menu))
    app.add_handler(CommandHandler("help",  cmd_help))
    app.add_handler(CommandHandler("?",     cmd_help))
    app.add_handler(CallbackQueryHandler(button_handler))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, text_handler))

    print("✅ 폴링 시작. Ctrl+C로 종료.")
    app.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
