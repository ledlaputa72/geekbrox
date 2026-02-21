"""
atlas_bot.py — GeekBrox 블로그 자동화 텔레그램 원격제어 봇

텔레그램에서 인라인 버튼 메뉴를 통해 블로그 운영 전체 워크플로우를 제어합니다.

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
        "👋 *GeekBrox 블로그 자동화 봇*에 오신 것을 환영합니다!\n\n"
        "아래 버튼으로 블로그 운영 전 과정을 원격 제어하세요.",
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

    # ── 도움말 ──
    elif data == "help":
        help_text = (
            "📖 *사용 안내*\n\n"
            "1️⃣ *자료조사* — AniList에서 최신 애니 데이터 수집\n"
            "2️⃣ *글 생성* — Claude API로 블로그 초안 자동 작성\n"
            "3️⃣ *초안 확인* — 대기 중인 초안 목록 및 내용 미리보기\n"
            "4️⃣ *초안 수정* — 수정 지시 입력 → 해당 초안 재생성\n"
            "5️⃣ *포스팅 실행* — Tistory에 자동 게시 (확인 후 진행)\n"
            "6️⃣ *게시 현황* — 완료된 게시글 목록 확인\n"
            "7️⃣ *상태 조회* — 전체 시스템 현황\n\n"
            "💡 포스팅 실행 중 추가 인증이 필요하면\n"
            "   봇이 자동으로 알려드립니다."
        )
        await query.edit_message_text(
            help_text,
            reply_markup=InlineKeyboardMarkup([[
                InlineKeyboardButton("🏠 메인 메뉴", callback_data="menu")
            ]]),
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

    print(f"🤖 Atlas 블로그 봇 시작 (chat_id 제한: {ALLOWED_ID or '없음'})")

    app = Application.builder().token(BOT_TOKEN).build()

    app.add_handler(CommandHandler("start", cmd_start))
    app.add_handler(CommandHandler("menu",  cmd_menu))
    app.add_handler(CallbackQueryHandler(button_handler))
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, text_handler))

    print("✅ 텔레그램 봇 폴링 시작. Ctrl+C로 종료.")
    app.run_polling(allowed_updates=Update.ALL_TYPES)


if __name__ == "__main__":
    main()
