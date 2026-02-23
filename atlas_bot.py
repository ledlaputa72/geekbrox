"""
atlas_bot.py — GeekBrox 총괄 PM 봇 v1.0

역할: Atlas(총괄 PM)가 텔레그램으로 3개 팀 전체를 통합 관리

조직 구조:
  Steve (텔레그램 명령)
      ↓
  🚀 Atlas (atlas_bot.py) — 총괄 PM
      ├── 📝 콘텐츠팀  →  blog_automation/scripts/ 스크립트 호출
      ├── 🎮 게임개발팀 →  teams/game/workspace/ 파일 읽기
      ├── 🏢 운영팀    →  teams/ops/workspace/ 파일 읽기
      └── 📊 전체현황  →  project-management/ 파싱

설계 원칙:
  - 모든 제어는 버튼으로 완결 (LLM 호출 없음 → AI 크레딧 절약)
  - 계층식 메뉴: 홈 → 카테고리 → 실행 3단계
  - 콘텐츠팀 스크립트는 subprocess 로 기존 scripts 재사용
  - 게임팀/운영팀은 Markdown 파일 직접 파싱 후 요약 출력

메뉴 계층:
  🏠 홈
  ├── 1️⃣ 전체 현황
  │   ├── 1-1 📊 프로젝트 대시보드
  │   ├── 1-2 📋 스프린트 현황
  │   ├── 1-3 ⚠️  우선순위 작업 (P0/P1)
  │   └── 1-4 🔄 3-Way 공유 상태
  ├── 2️⃣ 📝 콘텐츠팀
  │   ├── 2-1 📈 블로그 현황
  │   ├── 2-2 🔍 자료조사
  │   ├── 2-3 ✍️  글 생성
  │   ├── 2-4 📋 초안 목록
  │   └── 2-5 🚀 포스팅 실행
  ├── 3️⃣ 🎮 게임개발팀
  │   ├── 3-1 📊 프로젝트 현황
  │   ├── 3-2 📐 GDD 목록
  │   ├── 3-3 🎯 컨셉 현황
  │   └── 3-4 📅 마일스톤
  ├── 4️⃣ 🏢 운영및사업팀
  │   ├── 4-1 🔬 리서치 현황
  │   ├── 4-2 💰 유료화 & 마케팅
  │   └── 4-3 📊 KPI 대시보드
  └── 5️⃣ ⚙️ 관리 도구
      ├── 5-1 📝 오늘의 작업 기록
      ├── 5-2 🚨 충돌 확인 & 해제
      ├── 5-3 💬 팀 메시지 전달
      └── 5-4 📖 도움말

사전 설치:
  pip install python-telegram-bot==20.* python-dotenv
"""

from __future__ import annotations

import asyncio
import os
import re
import subprocess
import sys
import time
import json
from pathlib import Path
from datetime import datetime
from collections import deque

from dotenv import load_dotenv

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Anthropic (Atlas PM AI 응답용)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
try:
    import anthropic as _anthropic
    _ANTHROPIC_OK = True
except ImportError:
    _ANTHROPIC_OK = False

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 경로 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SCRIPT_DIR   = Path(__file__).resolve().parent          # geekbrox/
PROJECT_DIR  = SCRIPT_DIR                               # 루트 = 프로젝트
CONTENT_DIR  = PROJECT_DIR / "teams" / "content" / "workspace"
GAME_DIR     = PROJECT_DIR / "teams" / "game" / "workspace"
OPS_DIR      = PROJECT_DIR / "teams" / "ops" / "workspace"
BLOG_SCRIPTS = PROJECT_DIR / "blog_automation" / "scripts"
BLOG_DRAFTS  = CONTENT_DIR / "blog" / "drafts"
BLOG_DONE    = CONTENT_DIR / "blog" / "published"
BLOG_IMAGES  = CONTENT_DIR / "blog" / "images"
PM_DIR       = PROJECT_DIR / "project-management"

# shared_state.py를 blog_automation/scripts/ 에서 import
sys.path.insert(0, str(BLOG_SCRIPTS))

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# shared_state 연동
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
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
    print("python-telegram-bot 없음 → .venv pip으로 설치 중...")
    # 시스템 pip 대신 현재 실행 중인 Python 인터프리터의 pip 사용
    venv_pip = Path(sys.executable).parent / "pip"
    pip_cmd = str(venv_pip) if venv_pip.exists() else sys.executable + " -m pip"
    subprocess.run(
        [sys.executable, "-m", "pip", "install", "--quiet",
         "python-telegram-bot>=20.0", "python-dotenv"],
        check=True
    )
    from telegram import Update, InlineKeyboardButton, InlineKeyboardMarkup
    from telegram.ext import (
        Application, CommandHandler, CallbackQueryHandler,
        MessageHandler, ContextTypes, filters,
    )

load_dotenv(Path(__file__).resolve().parent / ".env", override=True)

BOT_TOKEN  = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
ALLOWED_ID = os.environ.get("TELEGRAM_CHAT_ID", "").strip()

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Rate Limit 방지 큐
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
_task_queue: deque = deque()
_queue_running: bool = False
QUEUE_DELAY = int(os.environ.get("INTER_POST_DELAY", "30"))
_api_call_times: deque = deque(maxlen=20)


def _record_api_call():
    _api_call_times.append(time.time())


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


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 보안
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def is_allowed(update: Update) -> bool:
    if not ALLOWED_ID:
        return True
    return str(update.effective_chat.id) == ALLOWED_ID


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 유틸: 스크립트 실행
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def run_script(script_name: str, args: list[str] | None = None) -> tuple[bool, str]:
    path = BLOG_SCRIPTS / script_name
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
# 유틸: Markdown 파일 파싱 헬퍼
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
def _read_md(path: Path, max_chars: int = 3000) -> str:
    """파일을 읽어 문자 제한 내로 반환. 없으면 안내 문자열 반환."""
    if not path.exists():
        return f"_(파일 없음: {path.name})_"
    text = path.read_text(encoding="utf-8")
    return text[:max_chars] + ("…" if len(text) > max_chars else "")


def _latest_file(folder: Path, pattern: str = "*.md") -> Path | None:
    """폴더에서 수정 시간 기준 최신 파일 반환."""
    files = sorted(folder.glob(pattern), key=lambda f: f.stat().st_mtime, reverse=True)
    return files[0] if files else None


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 텍스트 생성 함수 (각 메뉴 내용)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ── 1-1: 프로젝트 대시보드 ───────────────────
def dashboard_text() -> str:
    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    # 콘텐츠팀 블로그 현황
    done_posts  = list(BLOG_DONE.glob("*.md"))  if BLOG_DONE.exists()  else []
    draft_posts = list(BLOG_DRAFTS.glob("*.md")) if BLOG_DRAFTS.exists() else []
    blog_pct = int(len(done_posts) / 100 * 100)

    # 게임팀 현황 — PROJECT_STATE.md 파싱
    game_phase = "파일 없음"
    ps_file = GAME_DIR / "PROJECT_STATE.md"
    if ps_file.exists():
        content = ps_file.read_text(encoding="utf-8")
        # "Phase N" 또는 "현재 단계" 패턴 찾기
        m = re.search(r"Phase\s*(\d+)[^\n]*", content, re.IGNORECASE)
        if m:
            game_phase = f"Phase {m.group(1)}"
        else:
            # 첫 번째 ## 헤딩 파싱
            m2 = re.search(r"##\s*(.+)", content)
            game_phase = m2.group(1).strip()[:30] if m2 else "확인 필요"

    # P0 작업 수 — IN_PROGRESS.md 파싱
    p0_count = 0
    p1_count = 0
    ip_file = PM_DIR / "tasks" / "IN_PROGRESS.md"
    if ip_file.exists():
        ip_text = ip_file.read_text(encoding="utf-8")
        p0_count = ip_text.upper().count("P0")
        p1_count = ip_text.upper().count("P1")

    # 3-Way 공유 상태
    share_icon = "🟢" if _SHARED_STATE_OK else "⚠️"

    return (
        f"📊 *GeekBrox 프로젝트 대시보드*\n"
        f"━━━━━━━━━━━━━━━━━━\n"
        f"🕐 {now}\n\n"
        f"📝 *콘텐츠팀*\n"
        f"  • 블로그 발행: *{len(done_posts)}/100* 편 ({blog_pct}%)\n"
        f"  • 초안 대기: *{len(draft_posts)}개*\n\n"
        f"🎮 *게임개발팀*\n"
        f"  • 현재 단계: *{game_phase}*\n\n"
        f"📋 *우선순위 작업*\n"
        f"  • 🔴 P0 긴급: *{p0_count}개*\n"
        f"  • 🟠 P1 높음: *{p1_count}개*\n\n"
        f"{share_icon} 3-Way 공유: {'정상' if _SHARED_STATE_OK else '모듈 오류'}"
    )


# ── 1-2: 스프린트 현황 ───────────────────────
def sprint_text() -> str:
    sprint_dir = PM_DIR / "sprints"
    if not sprint_dir.exists():
        return "⚠️ sprints 폴더 없음"
    latest = _latest_file(sprint_dir, "*.md")
    if not latest:
        return "⚠️ 스프린트 파일 없음"
    content = latest.read_text(encoding="utf-8")
    # 최대 1500자로 제한
    preview = content[:1500] + ("…" if len(content) > 1500 else "")
    return f"📋 *스프린트 현황* — `{latest.name}`\n━━━━━━━━━━━━━━━━━━\n\n{preview}"


# ── 1-3: 우선순위 작업 (P0/P1) ──────────────
def priority_text() -> str:
    ip_file = PM_DIR / "tasks" / "IN_PROGRESS.md"
    if not ip_file.exists():
        return "⚠️ IN_PROGRESS.md 파일 없음"
    content = ip_file.read_text(encoding="utf-8")
    preview = content[:1800] + ("…" if len(content) > 1800 else "")
    return f"⚠️ *우선순위 작업 목록*\n━━━━━━━━━━━━━━━━━━\n\n{preview}"


# ── 2-1: 블로그 현황 ─────────────────────────
def blog_status_text() -> str:
    done   = sorted(BLOG_DONE.glob("*.md"),   reverse=True) if BLOG_DONE.exists()   else []
    drafts = sorted(BLOG_DRAFTS.glob("*.md"), reverse=True) if BLOG_DRAFTS.exists() else []
    images = list(BLOG_IMAGES.glob("*.*"))                  if BLOG_IMAGES.exists() else []
    now    = datetime.now().strftime("%Y-%m-%d %H:%M")
    rl     = _check_rate_limit_status()

    lines = [
        f"📝 *콘텐츠팀 블로그 현황* ({now})",
        "━━━━━━━━━━━━━━━━━━",
        f"✅ 발행 완료: *{len(done)}/100* 편",
        f"📝 초안 대기: *{len(drafts)}개*",
        f"🖼️ 이미지: *{len(images)}개*",
        "",
        f"{'🟢 대기 초안 있음' if drafts else '⚪️ 대기 초안 없음'}",
        f"{'🟢 API 안전' if rl['safe'] else '🟡 API 주의'} (60초 내 {rl['recent_60s']}회)",
    ]
    if done:
        lines += ["", "📰 *최근 발행 5편*"]
        for i, f in enumerate(done[:5], 1):
            lines.append(f"  {i}. {f.stem[:40]}")
    return "\n".join(lines)


# ── 2-4: 초안 목록 ───────────────────────────
def get_drafts() -> list[Path]:
    if not BLOG_DRAFTS.exists():
        return []
    return sorted(BLOG_DRAFTS.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)


def draft_list_text(drafts: list[Path]) -> str:
    if not drafts:
        return "📭 대기 중인 초안이 없습니다."
    lines = [f"📋 *초안 목록* ({len(drafts)}개)\n"]
    for i, f in enumerate(drafts[:8], 1):
        sz = f.stat().st_size // 1024
        lines.append(f"{i}. 📄 {f.stem[:35]} ({sz}KB)")
    if len(drafts) > 8:
        lines.append(f"… 외 {len(drafts) - 8}개")
    return "\n".join(lines)


# ── 3-1: 게임팀 현황 ─────────────────────────
def game_status_text() -> str:
    ps_file = GAME_DIR / "PROJECT_STATE.md"
    if not ps_file.exists():
        return "⚠️ PROJECT_STATE.md 없음\n경로: " + str(ps_file)
    content = ps_file.read_text(encoding="utf-8")
    preview = content[:2000] + ("…" if len(content) > 2000 else "")
    return f"🎮 *게임개발팀 프로젝트 현황*\n━━━━━━━━━━━━━━━━━━\n\n{preview}"


# ── 3-2: GDD 목록 ────────────────────────────
def gdd_list_text() -> str:
    design_dir = GAME_DIR / "design"
    if not design_dir.exists():
        return "⚠️ design 폴더 없음"
    files = sorted(design_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)
    if not files:
        return "📭 GDD 파일 없음"
    lines = [f"📐 *GDD 문서 목록* ({len(files)}개)\n"]
    for i, f in enumerate(files, 1):
        sz = f.stat().st_size // 1024
        mtime = datetime.fromtimestamp(f.stat().st_mtime).strftime("%m/%d")
        lines.append(f"{i}. 📄 {f.name} ({sz}KB, {mtime})")
    return "\n".join(lines)


# ── 3-3: 컨셉 현황 ───────────────────────────
def concept_text() -> str:
    # CONCEPT.md 또는 GDD 관련 파일 탐색
    concept_file = GAME_DIR / "design" / "CONCEPT.md"
    if not concept_file.exists():
        # 대체: 컨셉 관련 키워드가 있는 파일 찾기
        design_dir = GAME_DIR / "design"
        if design_dir.exists():
            candidates = [f for f in design_dir.glob("*.md")
                          if "concept" in f.name.lower() or "컨셉" in f.name]
            if candidates:
                concept_file = candidates[0]
            else:
                return "⚠️ 컨셉 파일 없음 (design/CONCEPT.md)"
        else:
            return "⚠️ design 폴더 없음"
    content = concept_file.read_text(encoding="utf-8")
    preview = content[:2000] + ("…" if len(content) > 2000 else "")
    return f"🎯 *게임 컨셉 현황*\n━━━━━━━━━━━━━━━━━━\n\n{preview}"


# ── 3-4: 마일스톤 ────────────────────────────
def milestone_text() -> str:
    roadmap_file = PM_DIR / "MASTER_ROADMAP.md"
    if not roadmap_file.exists():
        # 게임 개발 로드맵 확인
        roadmap_file = PM_DIR / "roadmap" / "game-development-roadmap.md"
    if not roadmap_file.exists():
        return "⚠️ 로드맵 파일 없음"
    content = roadmap_file.read_text(encoding="utf-8")
    preview = content[:2000] + ("…" if len(content) > 2000 else "")
    return f"📅 *마일스톤 & 로드맵*\n━━━━━━━━━━━━━━━━━━\n\n{preview}"


# ── 4-1: 운영팀 리서치 현황 ──────────────────
def ops_research_text() -> str:
    research_dir = OPS_DIR / "research"
    lines = ["🔬 *운영팀 리서치 현황*\n━━━━━━━━━━━━━━━━━━\n"]

    if not research_dir.exists():
        return "⚠️ research 폴더 없음\n경로: " + str(research_dir)

    # 폴더 및 파일 목록
    for item in sorted(research_dir.iterdir()):
        if item.is_dir():
            sub_files = list(item.glob("*.md"))
            lines.append(f"📁 {item.name}/ ({len(sub_files)}개 파일)")
            for f in sub_files[:3]:
                lines.append(f"   • {f.name}")
            if len(sub_files) > 3:
                lines.append(f"   … 외 {len(sub_files) - 3}개")
        elif item.suffix == ".md":
            sz = item.stat().st_size // 1024
            lines.append(f"📄 {item.name} ({sz}KB)")

    return "\n".join(lines)


# ── 4-2: 유료화 & 마케팅 현황 ───────────────
def ops_mono_text() -> str:
    mono_dir = OPS_DIR / "monetization"
    if not mono_dir.exists():
        # 마케팅 관련 파일 탐색
        candidates = list(OPS_DIR.rglob("*마케팅*")) + list(OPS_DIR.rglob("*marketing*"))
        if not candidates:
            return "⚠️ 유료화 & 마케팅 파일 없음"
        file_list = "\n".join(f"• {f.name}" for f in candidates[:10])
        return f"💰 *유료화 & 마케팅 현황*\n━━━━━━━━━━━━━━━━━━\n\n{file_list}"

    files = list(mono_dir.rglob("*.md"))
    lines = [f"💰 *유료화 & 마케팅* ({len(files)}개 문서)\n━━━━━━━━━━━━━━━━━━\n"]
    for f in files[:8]:
        sz = f.stat().st_size // 1024
        lines.append(f"📄 {f.name} ({sz}KB)")
    return "\n".join(lines)


# ── 4-3: KPI 대시보드 ────────────────────────
def kpi_text() -> str:
    roadmap_file = PM_DIR / "MASTER_ROADMAP.md"
    if not roadmap_file.exists():
        return "⚠️ MASTER_ROADMAP.md 없음"
    content = roadmap_file.read_text(encoding="utf-8")

    # KPI 섹션 추출
    kpi_match = re.search(r"(#{1,3}\s*KPI[^\n]*\n)(.*?)(?=\n#{1,3}\s|\Z)", content,
                          re.DOTALL | re.IGNORECASE)
    if kpi_match:
        kpi_section = kpi_match.group(0)[:2000]
        return f"📊 *KPI 대시보드*\n━━━━━━━━━━━━━━━━━━\n\n{kpi_section}"

    # KPI 섹션 없으면 전체 일부 출력
    preview = content[:1500] + ("…" if len(content) > 1500 else "")
    return f"📊 *KPI (MASTER_ROADMAP.md)*\n━━━━━━━━━━━━━━━━━━\n\n{preview}"


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 키보드 빌더 — 계층식 메뉴
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def KB(*rows) -> InlineKeyboardMarkup:
    return InlineKeyboardMarkup(list(rows))

def BTN(label: str, cb: str) -> InlineKeyboardButton:
    return InlineKeyboardButton(label, callback_data=cb)

def BACK(cb: str = "menu") -> list[InlineKeyboardButton]:
    return [BTN("🏠 홈", cb)]


# ── 홈 메뉴 ───────────────────────────────────
def kb_home() -> InlineKeyboardMarkup:
    return KB(
        [BTN("1️⃣  전체 현황",       "m_overview"),
         BTN("2️⃣  📝 콘텐츠팀",     "m_content")],
        [BTN("3️⃣  🎮 게임개발팀",    "m_game"),
         BTN("4️⃣  🏢 운영팀",       "m_ops")],
        [BTN("5️⃣  ⚙️ 관리 도구",    "m_tools")],
    )


# ── 1. 전체 현황 ──────────────────────────────
def kb_overview() -> InlineKeyboardMarkup:
    return KB(
        [BTN("1-1  📊 프로젝트 대시보드", "ov_dashboard"),
         BTN("1-2  📋 스프린트 현황",    "ov_sprint")],
        [BTN("1-3  ⚠️ 우선순위 작업",   "ov_priority"),
         BTN("1-4  🔄 3-Way 공유상태",  "ov_share")],
        BACK(),
    )


# ── 2. 콘텐츠팀 ───────────────────────────────
def kb_content() -> InlineKeyboardMarkup:
    drafts = get_drafts()
    draft_label = f"2-4  📋 초안 목록 ({len(drafts)}개)" if drafts else "2-4  📋 초안 없음"
    return KB(
        [BTN("2-1  📈 블로그 현황",     "ct_status"),
         BTN("2-2  🔍 자료조사 실행",   "ct_fetch")],
        [BTN("2-3  ✍️ 글 생성 실행",   "ct_generate")],
        [BTN(draft_label,              "ct_drafts")],
        [BTN("2-5  🚀 Tistory 포스팅", "ct_post")],
        BACK(),
    )


# ── 3. 게임개발팀 ────────────────────────────
def kb_game() -> InlineKeyboardMarkup:
    return KB(
        [BTN("3-1  📊 프로젝트 현황",  "gm_status"),
         BTN("3-2  📐 GDD 목록",      "gm_gdd")],
        [BTN("3-3  🎯 컨셉 현황",     "gm_concept"),
         BTN("3-4  📅 마일스톤",      "gm_milestone")],
        [BTN("3-5  🎨 v0 UI 생성",    "v0_menu")],
        BACK(),
    )


# ── 4. 운영팀 ────────────────────────────────
def kb_ops() -> InlineKeyboardMarkup:
    return KB(
        [BTN("4-1  🔬 리서치 현황",    "op_research"),
         BTN("4-2  💰 유료화 & 마케팅", "op_mono")],
        [BTN("4-3  📊 KPI 대시보드",   "op_kpi")],
        BACK(),
    )


# ── 5. 관리 도구 ─────────────────────────────
def kb_tools() -> InlineKeyboardMarkup:
    return KB(
        [BTN("5-1  📝 오늘의 작업 기록", "tl_daily"),
         BTN("5-2  🚨 충돌 확인 & 해제", "tl_conflict")],
        [BTN("5-3  💬 팀 메시지 전달",   "tl_msg"),
         BTN("5-4  📖 도움말",           "tl_help")],
        BACK(),
    )


# ── 초안 목록 키보드 ──────────────────────────
def kb_draft_list(md_files: list[Path]) -> InlineKeyboardMarkup:
    rows = []
    for i, f in enumerate(md_files[:8]):
        rows.append([
            BTN(f"📄 {f.stem[:24]}", f"ct_view_{i}"),
            BTN("✏️ 수정", f"ct_revise_{i}"),
            BTN("🗑", f"ct_del_{i}"),
        ])
    rows.append([BTN("◀️ 콘텐츠팀", "m_content"), BTN("🏠 홈", "menu")])
    return InlineKeyboardMarkup(rows)


# ── 충돌 키보드 ──────────────────────────────
def kb_conflict() -> InlineKeyboardMarkup:
    return KB(
        [BTN("✅ 충돌 해제",   "tl_resolve"),
         BTN("🔄 새로고침",   "tl_conflict")],
        [BTN("◀️ 관리 도구", "m_tools"), BTN("🏠 홈", "menu")],
    )


# ── 메시지 전달 대상 ──────────────────────────
def kb_msg_target() -> InlineKeyboardMarkup:
    return KB(
        [BTN("🖥 Claude Code에게",  "tl_msg_claude"),
         BTN("🎯 Cursor AI에게",   "tl_msg_cursor")],
        [BTN("◀️ 관리 도구", "m_tools"), BTN("🏠 홈", "menu")],
    )


# ── 확인 키보드 (실행 전 확인용) ──────────────
def kb_confirm(yes_cb: str, no_cb: str) -> InlineKeyboardMarkup:
    return KB(
        [BTN("✅ 확인 (실행)", yes_cb),
         BTN("❌ 취소",       no_cb)],
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 도움말 텍스트
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def txt_help() -> str:
    return (
        "📖 *Atlas 총괄 PM 봇 — 도움말*\n"
        "━━━━━━━━━━━━━━━━━━\n\n"
        "🏠 *홈 메뉴*\n"
        "┣ 1️⃣ *전체 현황*\n"
        "┃  ┣ 1-1 대시보드 — 3팀 KPI 요약\n"
        "┃  ┣ 1-2 스프린트 — 이번 주 목표\n"
        "┃  ┣ 1-3 우선순위 — P0/P1 작업\n"
        "┃  ┗ 1-4 3-Way 공유 상태\n\n"
        "┣ 2️⃣ *콘텐츠팀*\n"
        "┃  ┣ 2-1 블로그 현황\n"
        "┃  ┣ 2-2 자료조사 (fetch_anime)\n"
        "┃  ┣ 2-3 글 생성 (generate_post)\n"
        "┃  ┣ 2-4 초안 목록 (보기/수정/삭제)\n"
        "┃  ┗ 2-5 Tistory 포스팅\n\n"
        "┣ 3️⃣ *게임개발팀*\n"
        "┃  ┣ 3-1 프로젝트 현황\n"
        "┃  ┣ 3-2 GDD 목록\n"
        "┃  ┣ 3-3 컨셉 현황\n"
        "┃  ┗ 3-4 마일스톤\n\n"
        "┣ 4️⃣ *운영팀*\n"
        "┃  ┣ 4-1 리서치 현황\n"
        "┃  ┣ 4-2 유료화 & 마케팅\n"
        "┃  ┗ 4-3 KPI 대시보드\n\n"
        "┗ 5️⃣ *관리 도구*\n"
        "   ┣ 5-1 오늘의 작업 기록\n"
        "   ┣ 5-2 충돌 확인 & 해제\n"
        "   ┣ 5-3 메시지 전달\n"
        "   ┗ 5-4 도움말\n\n"
        "🔘 *슬래시 명령어*\n"
        "`/start` `/menu` `/atlas` — 홈 메뉴\n"
        "`/help` — 도움말\n\n"
        "✏️ *텍스트 입력* (최소 사용)\n"
        "`메모: [내용]` — 팀에 메모 전달\n"
        "`인증완료` — 카카오 인증 완료\n"
        "초안 수정 지시문 (수정 버튼 후)"
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 명령어 핸들러
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def cmd_start(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not is_allowed(update):
        await update.message.reply_text("⚠️ 허용된 사용자만 이용 가능합니다.")
        return
    await update.message.reply_text(
        "🚀 *Atlas — GeekBrox 총괄 PM 봇* v1.0\n\n"
        "3개 팀을 버튼으로 통합 관리합니다.\n"
        "카테고리를 선택하세요.",
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
        txt_help(),
        reply_markup=KB(BACK()),
        parse_mode="Markdown",
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 버튼 핸들러 (모든 제어의 핵심)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

async def button_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    query = update.callback_query
    if not is_allowed(update):
        await query.answer("권한 없음")
        return
    await query.answer()
    d = query.data

    async def edit(text: str, kb=None, parse_mode="Markdown"):
        """메시지 편집 (텍스트 + 키보드)"""
        kwargs: dict = {"text": text, "parse_mode": parse_mode}
        if kb is not None:
            kwargs["reply_markup"] = kb
        await query.edit_message_text(**kwargs)

    # ── 홈 ───────────────────────────────────
    if d == "menu":
        await edit("🏠 *홈 메뉴*", kb_home())
        return

    # ── 1. 전체 현황 ─────────────────────────
    if d == "m_overview":
        await edit("1️⃣ *전체 현황*\n\n항목을 선택하세요.", kb_overview())
        return
    if d == "ov_dashboard":
        await edit(dashboard_text(), KB(
            [BTN("🔄 새로고침", "ov_dashboard")],
            [BTN("◀️ 전체 현황", "m_overview"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "ov_sprint":
        await edit(sprint_text(), KB(
            [BTN("🔄 새로고침", "ov_sprint")],
            [BTN("◀️ 전체 현황", "m_overview"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "ov_priority":
        await edit(priority_text(), KB(
            [BTN("🔄 새로고침", "ov_priority")],
            [BTN("◀️ 전체 현황", "m_overview"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "ov_share":
        status = telegram_format_status()
        await edit(status, KB(
            [BTN("🔄 새로고침", "ov_share")],
            [BTN("◀️ 전체 현황", "m_overview"), BTN("🏠 홈", "menu")],
        ))
        return

    # ── 2. 콘텐츠팀 ──────────────────────────
    if d == "m_content":
        await edit("2️⃣ *콘텐츠팀*\n\n항목을 선택하세요.", kb_content())
        return
    if d == "ct_status":
        await edit(blog_status_text(), KB(
            [BTN("🔄 새로고침", "ct_status")],
            [BTN("◀️ 콘텐츠팀", "m_content"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "ct_fetch":
        await edit(
            "🔍 *자료조사 실행*\n\n"
            "AniList에서 이번 시즌 Top 10 애니 데이터를 수집합니다.\n"
            "약 30초~1분 소요됩니다.",
            kb_confirm("ct_fetch_ok", "m_content"),
        )
        return
    if d == "ct_fetch_ok":
        await edit("⏳ *자료조사 실행 중...*\n\nAniList API 수집 중입니다.", None)
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "fetch_anime.py"
        )
        icon = "✅" if ok else "❌"
        await edit(
            f"{icon} *자료조사 {'완료' if ok else '실패'}*\n\n```\n{out[:800]}\n```",
            KB([BTN("◀️ 콘텐츠팀", "m_content"), BTN("🏠 홈", "menu")]),
        )
        return
    if d == "ct_generate":
        await edit(
            "✍️ *글 생성 실행*\n\n"
            "수집된 데이터로 블로그 초안을 생성합니다.\n"
            "Claude/Gemini API 사용 (1~3분 소요).",
            kb_confirm("ct_generate_ok", "m_content"),
        )
        return
    if d == "ct_generate_ok":
        await edit("⏳ *글 생성 중...*\n\nClaude/Gemini로 초안을 작성 중입니다.", None)
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "generate_post.py"
        )
        icon = "✅" if ok else "❌"
        await edit(
            f"{icon} *글 생성 {'완료' if ok else '실패'}*\n\n```\n{out[:800]}\n```",
            KB([BTN("📋 초안 확인", "ct_drafts"),
                BTN("◀️ 콘텐츠팀", "m_content")]),
        )
        return
    if d == "ct_drafts":
        drafts = get_drafts()
        await edit(draft_list_text(drafts), kb_draft_list(drafts))
        return
    if d.startswith("ct_view_"):
        idx = int(d.split("_")[-1])
        drafts = get_drafts()
        if idx >= len(drafts):
            await edit("⚠️ 초안 없음 (이미 삭제됐을 수 있음)",
                       KB([BTN("◀️ 초안 목록", "ct_drafts")]))
            return
        f = drafts[idx]
        content = f.read_text(encoding="utf-8")
        preview = content[:1200] + ("…" if len(content) > 1200 else "")
        await edit(
            f"📄 *{f.stem}*\n━━━━━━━━━━━━━━━━━━\n\n{preview}",
            KB(
                [BTN("✏️ 수정 요청", f"ct_revise_{idx}"),
                 BTN("🚀 바로 포스팅", "ct_post")],
                [BTN("◀️ 초안 목록", "ct_drafts"), BTN("🏠 홈", "menu")],
            ),
        )
        return
    if d.startswith("ct_revise_"):
        idx = int(d.split("_")[-1])
        drafts = get_drafts()
        if idx >= len(drafts):
            await edit("⚠️ 초안 없음", KB([BTN("◀️ 초안 목록", "ct_drafts")]))
            return
        context.user_data["awaiting"] = f"revise_{idx}"
        await edit(
            f"✏️ *초안 수정 요청*\n\n"
            f"📄 `{drafts[idx].stem}`\n\n"
            "수정 지시문을 텍스트로 입력하세요.\n"
            "예: `도입부를 더 흥미롭게, SEO 키워드 '2025 애니 추천' 유지`",
            KB([BTN("❌ 취소", "ct_drafts")]),
        )
        return
    if d.startswith("ct_del_"):
        idx = int(d.split("_")[-1])
        drafts = get_drafts()
        if idx >= len(drafts):
            await edit("⚠️ 초안 없음", KB([BTN("◀️ 초안 목록", "ct_drafts")]))
            return
        f = drafts[idx]
        f.unlink()
        await edit(f"🗑 *삭제 완료*: `{f.stem}`", KB([BTN("◀️ 초안 목록", "ct_drafts")]))
        return
    if d == "ct_post":
        await edit(
            "🚀 *Tistory 포스팅 실행*\n\n"
            "초안을 Tistory에 자동 게시합니다.\n"
            "Selenium 사용, 2~5분 소요.\n"
            "카카오 추가 인증이 필요하면 `인증완료` 를 입력하세요.",
            kb_confirm("ct_post_ok", "m_content"),
        )
        return
    if d == "ct_post_ok":
        await edit("⏳ *포스팅 실행 중...*\n\nTistory에 업로드 중입니다.", None)
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "post_to_tistory.py"
        )
        icon = "✅" if ok else "❌"
        await edit(
            f"{icon} *포스팅 {'완료' if ok else '실패'}*\n\n```\n{out[:800]}\n```",
            KB([BTN("📊 블로그 현황", "ct_status"),
                BTN("◀️ 콘텐츠팀", "m_content")]),
        )
        return

    # ── 3. 게임개발팀 ─────────────────────────
    if d == "m_game":
        await edit("3️⃣ *게임개발팀*\n\n항목을 선택하세요.", kb_game())
        return
    if d == "gm_status":
        await edit(game_status_text(), KB(
            [BTN("🔄 새로고침", "gm_status")],
            [BTN("◀️ 게임팀", "m_game"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "gm_gdd":
        await edit(gdd_list_text(), KB(
            [BTN("🔄 새로고침", "gm_gdd")],
            [BTN("◀️ 게임팀", "m_game"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "gm_concept":
        await edit(concept_text(), KB(
            [BTN("🔄 새로고침", "gm_concept")],
            [BTN("◀️ 게임팀", "m_game"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "gm_milestone":
        await edit(milestone_text(), KB(
            [BTN("🔄 새로고침", "gm_milestone")],
            [BTN("◀️ 게임팀", "m_game"), BTN("🏠 홈", "menu")],
        ))
        return

    # ── 4. 운영팀 ────────────────────────────
    if d == "m_ops":
        await edit("4️⃣ *운영및사업팀*\n\n항목을 선택하세요.", kb_ops())
        return
    if d == "op_research":
        await edit(ops_research_text(), KB(
            [BTN("🔄 새로고침", "op_research")],
            [BTN("◀️ 운영팀", "m_ops"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "op_mono":
        await edit(ops_mono_text(), KB(
            [BTN("🔄 새로고침", "op_mono")],
            [BTN("◀️ 운영팀", "m_ops"), BTN("🏠 홈", "menu")],
        ))
        return
    if d == "op_kpi":
        await edit(kpi_text(), KB(
            [BTN("🔄 새로고침", "op_kpi")],
            [BTN("◀️ 운영팀", "m_ops"), BTN("🏠 홈", "menu")],
        ))
        return

    # ── 5. 관리 도구 ─────────────────────────
    if d == "m_tools":
        await edit("5️⃣ *관리 도구*\n\n항목을 선택하세요.", kb_tools())
        return
    if d == "tl_daily":
        context.user_data["awaiting"] = "daily_record"
        await edit(
            "📝 *오늘의 작업 기록*\n\n"
            f"오늘({datetime.now().strftime('%Y-%m-%d')}) 완료한 작업을 입력하세요.\n"
            "예: `게임 GDD v2 완성, 블로그 3편 발행`",
            KB([BTN("❌ 취소", "m_tools")]),
        )
        return
    if d == "tl_conflict":
        conflicts = telegram_get_conflicts(unresolved_only=True)
        await edit(
            f"🚨 *충돌 현황*\n━━━━━━━━━━━━━━━━━━\n\n{conflicts}",
            kb_conflict(),
        )
        return
    if d == "tl_resolve":
        result = telegram_resolve_conflicts()
        await edit(
            f"✅ *충돌 해제 완료*\n\n{result}",
            KB([BTN("◀️ 관리 도구", "m_tools"), BTN("🏠 홈", "menu")]),
        )
        return
    if d == "tl_msg":
        await edit("💬 *메시지 전달*\n\n전달 대상을 선택하세요.", kb_msg_target())
        return
    if d == "tl_msg_claude":
        context.user_data["awaiting"] = "msg_to_claude_code"
        await edit(
            "🖥 *Claude Code에게 메시지*\n\n전달할 메시지를 입력하세요.",
            KB([BTN("❌ 취소", "m_tools")]),
        )
        return
    if d == "tl_msg_cursor":
        context.user_data["awaiting"] = "msg_to_cursor_ai"
        await edit(
            "🎯 *Cursor AI에게 메시지*\n\n전달할 메시지를 입력하세요.",
            KB([BTN("❌ 취소", "m_tools")]),
        )
        return
    if d == "tl_help":
        await edit(txt_help(), KB(BACK("m_tools")))
        return

    # ── v0 UI 생성 메뉴 ────────────────────────────────────────────────────────
    if d == "v0_menu":
        await edit(
            "🎨 *v0 UI 생성*\n━━━━━━━━━━━━━━━━━━\n\n"
            "생성할 화면을 선택하세요.\n"
            "또는 `v0: [원하는 화면 설명]` 으로 직접 입력.",
            _kb_v0_menu(),
        )
        return

    if d == "v0_custom":
        context.user_data["awaiting"] = "v0_custom_prompt"
        await edit(
            "✏️ *v0 직접 입력*\n━━━━━━━━━━━━━━━━━━\n\n"
            "만들고 싶은 화면을 설명해 주세요.\n"
            "예: `카드 획득 팝업, 레어 카드, 보라색 파티클`",
            KB([BTN("❌ 취소", "v0_menu")]),
        )
        return

    # v0 프리셋 화면 생성 버튼
    if d in _V0_SCREEN_PRESETS:
        label, _ = _V0_SCREEN_PRESETS[d]
        thinking = await query.message.reply_text(
            f"🎨 *v0 생성 중...*\n`{label}`\n\n약 30~60초 소요됩니다",
            parse_mode="Markdown",
        )
        await query.message.delete()
        result = await asyncio.get_event_loop().run_in_executor(
            None, v0_generate_ui, "", d
        )
        await thinking.delete()
        await query.message.chat.send_message(
            result,
            reply_markup=KB([BTN("🎨 v0 메뉴", "v0_menu"), BTN("🏠 홈", "menu")]),
            parse_mode="Markdown",
        )
        return

    # keep_chat — 대화 계속 (아무 동작 없이 안내만)
    if d == "keep_chat":
        await edit(
            "💬 *Atlas PM과 대화 중*\n\n"
            "질문이나 지시를 텍스트로 입력하세요.\n"
            "버튼 메뉴로 돌아가려면 🏠 홈을 누르세요.",
            KB([BTN("🏠 홈 메뉴", "menu")]),
        )
        return

    # 알 수 없는 콜백
    await edit("❓ 알 수 없는 명령입니다.", KB(BACK()))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 텍스트 핸들러 (최소화 — 수정 지시·메모·인증완료만 처리)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Atlas PM AI 응답 — 자유 텍스트 지시/질문 처리
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def _read_file_safe(path: Path, max_chars: int = 1500) -> str:
    """파일을 안전하게 읽어 문자열 반환. 없으면 빈 문자열."""
    try:
        if path.exists():
            return path.read_text(encoding="utf-8")[:max_chars]
    except Exception:
        pass
    return ""


def _build_project_context() -> str:
    """Atlas PM이 답변할 때 참고할 프로젝트 현재 상태를 수집."""
    ctx_parts: list[str] = []

    # ── 콘텐츠팀 ──────────────────────────────────────────────
    done   = len(list(BLOG_DONE.glob("*.md")))   if BLOG_DONE.exists()   else 0
    drafts = len(list(BLOG_DRAFTS.glob("*.md"))) if BLOG_DRAFTS.exists() else 0
    ctx_parts.append(f"[콘텐츠팀] 블로그 발행 {done}/100편, 초안 대기 {drafts}개")

    # ── 게임팀 ────────────────────────────────────────────────
    ps_content = _read_file_safe(GAME_DIR / "PROJECT_STATE.md", 1500)
    if ps_content:
        ctx_parts.append(f"[게임팀] PROJECT_STATE:\n{ps_content}")
    else:
        ctx_parts.append("[게임팀] PROJECT_STATE.md 없음")

    # 게임팀 인터페이스/UI 기획 문서 (통합 인터페이스 등)
    interface_dir = GAME_DIR.parent / "interface"
    if interface_dir.exists():
        iface_files = list(interface_dir.glob("*.md"))
        iface_summary_parts = [f"[게임팀/인터페이스] 파일 {len(iface_files)}개: {', '.join(f.name for f in iface_files)}"]
        for ifile in iface_files[:4]:          # 최대 4개 파일 내용 포함
            content = _read_file_safe(ifile, 800)
            if content:
                iface_summary_parts.append(f"── {ifile.name} ──\n{content}")
        ctx_parts.append("\n\n".join(iface_summary_parts))

    # GDD/컨셉 문서
    gdd_dir = GAME_DIR / "gdd"
    if gdd_dir.exists():
        gdd_files = sorted(gdd_dir.glob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)[:3]
        for gf in gdd_files:
            ctx_parts.append(f"[게임팀/GDD] {gf.name}:\n{_read_file_safe(gf, 600)}")

    # ── 운영팀 ────────────────────────────────────────────────
    ops_state = _read_file_safe(OPS_DIR / "OPS_STATE.md", 800)
    if ops_state:
        ctx_parts.append(f"[운영팀] OPS_STATE:\n{ops_state}")

    # 운영팀 최근 수정 파일 5개 내용 포함
    if OPS_DIR.exists():
        ops_recent = sorted(OPS_DIR.rglob("*.md"), key=lambda f: f.stat().st_mtime, reverse=True)[:5]
        ops_list = []
        for of in ops_recent:
            rel = of.relative_to(OPS_DIR)
            snippet = _read_file_safe(of, 500)
            ops_list.append(f"  {rel}:\n{snippet}")
        ctx_parts.append("[운영팀] 최근 문서:\n" + "\n\n".join(ops_list))

    # ── 우선순위 / PM ─────────────────────────────────────────
    ip_content = _read_file_safe(PM_DIR / "tasks" / "IN_PROGRESS.md", 1000)
    if ip_content:
        ctx_parts.append(f"[우선순위 작업]\n{ip_content}")

    # project-management 루트 주요 파일
    for fname in ["PROJECT_OVERVIEW.md", "ROADMAP.md", "MILESTONES.md"]:
        c = _read_file_safe(PM_DIR / fname, 800)
        if c:
            ctx_parts.append(f"[PM/{fname}]\n{c}")

    # ── 3-Way shared_state ────────────────────────────────────
    if _SHARED_STATE_OK:
        ctx_parts.append(f"[3-Way 공유 상태]\n{telegram_format_status()}")

    return "\n\n".join(ctx_parts)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# v0 UI 생성 — v0.dev API 연동
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# GeekBrox v0 시스템 컨텍스트 (모든 화면 생성 시 공통 적용)
_V0_SYSTEM_CONTEXT = """모바일 방치형 덱빌딩 게임 UI 제작 중입니다.

기술 스택:
- React + TypeScript + Tailwind CSS + shadcn/ui
- 기준 해상도: 390×844px (세로 모드 전용, 모바일)
- 렌더링: 웹 미리보기이지만 실제 모바일 게임 UI처럼 보여야 함

공통 테마 변수 (CSS Custom Properties):
:root {
  --color-primary: #7B9EF0;
  --color-secondary: #C4A8E8;
  --color-accent: #F5F0FF;
  --color-bg-main: #0D1B3E;
  --color-bg-panel: rgba(255,255,255,0.10);
  --color-currency-1: #FFE066;
  --color-currency-2: #E8D5FF;
  --radius-card: 16px;
  --radius-button: 20px;
}

레이아웃 원칙:
- 상단: 재화 바 64px + Safe Area (총 108px)
- 중앙: 메인 비주얼 영역 (가변)
- 하단: 메인 액션 버튼 72px + 5탭 내비게이션 80px
- 모든 버튼 최소 44×44px (접근성)
- 글래스모피즘 패널: backdrop-blur + 반투명 배경
- 색상은 반드시 CSS Custom Properties 사용 (하드코딩 금지)"""

# v0 화면 프리셋 (텔레그램 버튼으로 빠르게 생성)
_V0_SCREEN_PRESETS: dict[str, tuple[str, str]] = {
    "v0_c01_dream": (
        "C-01 메인 로비 (Dream)",
        """[메인 로비 - 꿈 수집가] 390×844px 세로 모바일:
① 상단 재화 바(108px): 좌측 💎레버리"1,234" + ✨드림샤드"56" 캡슐칩, 우측 🔔⚙️ 아이콘
② 메인 비주얼(약 380px): 딥네이비 배경+별빛 파티클, 중앙 몽환 캐릭터 실루엣(흰 망토), 하단 오프라인수익 배너
③ 메인 액션 버튼(72px): "💎 수집하기 (345 레버리)" gradient(#7B9EF0,#9BB5F5) 라운드20px
④ 하단 5탭(80px): 🏠홈(활성)|🃏카드|⬆업그레이드|🌙프레스티지|🏪상점
전체: 딥네이비 그라데이션 (#0D1B3E→#1A2A5E), 글래스모피즘"""
    ),
    "v0_c01_dark": (
        "C-01 메인 로비 (Dark)",
        """[메인 로비 - 던전 기생충] Dream 테마 구조 유지, 다음만 교체:
배경:#0A0A0A, Primary:#8B1A1A, Accent:#00CED1
재화: 🧬DNA"2,400" + 💰골드"830"
캐릭터: 무정형 기생체(촉수+청록 핵), 감염 파티클
버튼: "🎮 런 시작하기" gradient(#8B1A1A,#B22222)
탭: 🏠홈|🧟컬렉션|⬆업그레이드|🧬계통|🏪상점
스타일: 다크 호러, 고딕"""
    ),
    "v0_c02": (
        "C-02 카드 라이브러리",
        """[카드 라이브러리] 390×844px:
① 헤더(64px): "🃏 카드 라이브러리" + 우측 "34/200"
② 필터 바(44px 가로스크롤): [전체][수집][액션][시너지][이벤트] + 희귀도▼ 정렬▼
③ 카드 그리드(3열 스크롤) 각 100×140px: 상단60%이미지, 카드이름12px, 효과설명10px
   좌상단 에너지비용 원형배지, 테두리: 일반#888/언커먼#4CAF50/레어#7B68EE/전설#FFD700 glow
④ 하단 5탭(표준)"""
    ),
    "v0_c03": (
        "C-03 덱 빌더",
        """[덱 빌더] 390×844px:
① 헤더: "덱 빌더" + "8/12장" + 덱파워 별점 ★★★☆☆
② 현재 덱 슬롯(가로스크롤 110px): 카드64×90px 8장 + 빈슬롯4개(점선)
③ 구분선 + "카드 선택" 제목
④ 필터 바 + 카드 그리드(3열): 덱포함카드 초록체크✓, 탭으로 덱추가 애니메이션
⑤ 하단 고정: [덱 저장] + [런 시작] 나란히"""
    ),
    "v0_c04": (
        "C-04 업그레이드 트리",
        """[업그레이드 트리] 390×844px:
① 헤더: "⬆ 업그레이드" + 보유재화 "💎1,234"
② 카테고리 탭(가로스크롤): [방치속도][덱확장][프레스티지][특수능력]
③ 트리 영역(스크롤): 노드 120×120px 3열, 연결선SVG
   각 노드: 아이콘40px+이름+효과설명+레벨3/10+업그레이드버튼
   상태: 가능(#7B9EF0)/부족(회색)/MAX(금색)/잠김(어둡게+🔒)
④ 하단 5탭(표준)"""
    ),
}

def v0_generate_ui(prompt: str, screen_key: str = "") -> str:
    """
    v0 API를 호출하여 UI 컴포넌트를 생성하고 결과를 반환.
    생성된 코드는 v0-exports/ 폴더에 자동 저장.
    """
    v0_key = os.environ.get("v0_API_KEY", "").strip()
    if not v0_key:
        return "⚠️ v0_API_KEY가 .env에 없습니다."

    # 프리셋이면 프리셋 프롬프트 사용
    if screen_key and screen_key in _V0_SCREEN_PRESETS:
        _, preset_prompt = _V0_SCREEN_PRESETS[screen_key]
        full_prompt = f"{_V0_SYSTEM_CONTEXT}\n\n---\n\n{preset_prompt}"
    else:
        full_prompt = f"{_V0_SYSTEM_CONTEXT}\n\n---\n\n{prompt}"

    try:
        import urllib.request, urllib.error
        import json as _json

        payload = _json.dumps({
            "model": "v0-1.5-md",
            "messages": [{"role": "user", "content": full_prompt}],
            "stream": False,
        }).encode("utf-8")

        req = urllib.request.Request(
            "https://api.v0.dev/v1/chat/completions",
            data=payload,
            headers={
                "Authorization": f"Bearer {v0_key}",
                "Content-Type": "application/json",
            },
            method="POST",
        )

        with urllib.request.urlopen(req, timeout=90) as resp:
            data = _json.loads(resp.read().decode("utf-8"))

        if "error" in data:
            return f"❌ v0 API 오류: {data['error']}"

        content = data["choices"][0]["message"]["content"]

        # 코드 블록 추출
        code = ""
        if "```" in content:
            parts = content.split("```")
            for i, part in enumerate(parts):
                if i % 2 == 1:  # 코드 블록 내부
                    # tsx/jsx/typescript 제거
                    lines = part.split("\n")
                    if lines[0].strip().lower() in ("tsx", "jsx", "typescript", "ts", ""):
                        code = "\n".join(lines[1:])
                    else:
                        code = part
                    break

        # 파일 저장
        save_path = None
        if code:
            interface_dir = PROJECT_DIR / "teams" / "game" / "interface" / "v0-exports"
            if screen_key:
                theme = "dark-theme" if "dark" in screen_key else "dream-theme"
                fname = f"{screen_key}.tsx"
            else:
                import re, time
                safe = re.sub(r"[^a-z0-9]", "-", prompt[:30].lower())
                fname = f"{safe}-{int(time.time())%10000}.tsx"
                theme = "dream-theme"
            save_path = interface_dir / theme / fname
            save_path.parent.mkdir(parents=True, exist_ok=True)
            save_path.write_text(code, encoding="utf-8")

        # 응답 메시지 구성
        preview = content[:400].replace("`", "'")
        saved_info = f"\n📁 저장: `v0-exports/{theme}/{fname}`" if save_path else ""
        lines_info = f"  ({len(code.splitlines())}줄)" if code else ""

        return (
            f"✅ *v0 UI 생성 완료*{lines_info}\n"
            f"━━━━━━━━━━━━━━━━━━\n\n"
            f"{preview}{'...' if len(content) > 400 else ''}"
            f"{saved_info}\n\n"
            f"💡 코드를 v0\\.dev에 붙여넣어 미리보기 확인하세요"
        )

    except Exception as e:
        return f"❌ v0 생성 오류: {e}"


def _kb_v0_menu() -> InlineKeyboardMarkup:
    """v0 화면 생성 선택 메뉴."""
    return KB([
        BTN("🏠 메인 로비 Dream", "v0_c01_dream"),
        BTN("🌑 메인 로비 Dark",  "v0_c01_dark"),
        BTN("🃏 카드 라이브러리",  "v0_c02"),
        BTN("🃏 덱 빌더",         "v0_c03"),
        BTN("⬆️ 업그레이드 트리",  "v0_c04"),
        BTN("✏️ 직접 입력",        "v0_custom"),
        BTN("◀️ 홈",              "menu"),
    ])


def atlas_pm_reply(user_message: str) -> str:
    """
    Atlas PM으로서 Claude에게 질문/지시를 처리하고 응답을 반환.
    실패 시 에러 메시지 반환.
    """
    if not _ANTHROPIC_OK:
        return "⚠️ anthropic 라이브러리 없음. `.venv/bin/pip install anthropic` 실행 필요."

    api_key = os.environ.get("ANTHROPIC_API_KEY", "").strip()
    if not api_key:
        return "⚠️ ANTHROPIC_API_KEY가 .env에 설정되지 않았습니다."

    project_ctx = _build_project_context()
    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    system_prompt = f"""당신은 GeekBrox 프로젝트의 총괄 PM인 Atlas입니다.
Steve(대표)로부터 텔레그램으로 직접 지시와 질문을 받습니다.

현재 날짜: {now}

## 프로젝트 현재 상태
{project_ctx}

## 당신의 역할
- GeekBrox의 3개 팀(콘텐츠팀, 게임개발팀, 운영및사업팀)을 총괄 관리
- Steve의 질문에 PM 관점으로 명확하고 실행 가능한 답변 제공
- 각 팀의 진행 상황 파악 및 우선순위 조정
- 버튼 메뉴(단축키)에 없는 지시나 질문은 직접 AI로 처리

## 답변 원칙
- 간결하고 실행 가능한 내용으로 답변 (텔레그램 메시지 특성상 500자 이내 권장)
- 필요시 구체적인 다음 액션(Next Action) 제시
- 한국어로 답변
- 마크다운 사용 가능 (*굵게*, `코드`, 목록 등)"""

    try:
        client = _anthropic.Anthropic(api_key=api_key)
        response = client.messages.create(
            model="claude-haiku-4-5",
            max_tokens=1024,
            system=system_prompt,
            messages=[{"role": "user", "content": user_message}],
        )
        return response.content[0].text
    except Exception as e:
        return f"⚠️ Atlas PM 응답 오류: {e}"


async def text_handler(update: Update, context: ContextTypes.DEFAULT_TYPE) -> None:
    if not is_allowed(update):
        return
    text = (update.message.text or "").strip()
    awaiting = context.user_data.get("awaiting", "")

    # 1. 초안 수정 지시문
    if awaiting.startswith("revise_"):
        idx = int(awaiting.split("_")[1])
        drafts = get_drafts()
        context.user_data.pop("awaiting", None)
        if idx >= len(drafts):
            await update.message.reply_text("⚠️ 초안이 없습니다.", reply_markup=kb_home())
            return
        target = str(drafts[idx])
        await update.message.reply_text(
            f"⏳ *초안 수정 중...*\n\n📄 `{drafts[idx].stem}`\n지시: {text[:100]}",
            parse_mode="Markdown",
        )
        ok, out = await asyncio.get_event_loop().run_in_executor(
            None, run_script, "generate_post.py",
            ["--revise", target, "--instruction", text]
        )
        icon = "✅" if ok else "❌"
        await update.message.reply_text(
            f"{icon} *수정 {'완료' if ok else '실패'}*\n\n```\n{out[:600]}\n```",
            reply_markup=KB([BTN("📋 초안 목록", "ct_drafts"), BTN("🏠 홈", "menu")]),
            parse_mode="Markdown",
        )
        return

    # 2. 메시지 전달 (Claude Code / Cursor AI)
    if awaiting.startswith("msg_to_"):
        target_actor = ACTOR_CLAUDE if "claude" in awaiting else ACTOR_CURSOR
        target_name  = "Claude Code" if "claude" in awaiting else "Cursor AI"
        context.user_data.pop("awaiting", None)
        telegram_send_message(target_actor, text)
        await update.message.reply_text(
            f"✅ *메시지 전달 완료*\n\n"
            f"📨 → *{target_name}*\n\n`{text[:200]}`",
            reply_markup=kb_home(),
            parse_mode="Markdown",
        )
        return

    # 3. 오늘의 작업 기록
    if awaiting == "daily_record":
        context.user_data.pop("awaiting", None)
        daily_file = PM_DIR / "DAILY_REPORT.md"
        today = datetime.now().strftime("%Y-%m-%d %H:%M")
        entry = f"\n\n## {today}\n{text}\n"
        try:
            with daily_file.open("a", encoding="utf-8") as f:
                f.write(entry)
            telegram_add_note(f"[오늘의 기록 {today[:10]}] {text[:100]}")
            await update.message.reply_text(
                f"✅ *작업 기록 저장 완료*\n\n`{text[:200]}`",
                reply_markup=kb_home(),
                parse_mode="Markdown",
            )
        except Exception as e:
            await update.message.reply_text(
                f"❌ 저장 실패: {e}", reply_markup=kb_home()
            )
        return

    # 4. 메모 전달
    low = text.lower()
    if low.startswith("메모:") or low.startswith("note:"):
        note = text.split(":", 1)[1].strip()
        telegram_add_note(note)
        await update.message.reply_text(
            f"📝 *메모 저장 완료*\n\n`{note[:200]}`",
            reply_markup=kb_home(),
            parse_mode="Markdown",
        )
        return

    # 5. v0 직접 입력 처리
    if awaiting == "v0_custom_prompt":
        context.user_data.pop("awaiting", None)
        thinking_msg = await update.message.reply_text(
            f"🎨 *v0 생성 중...*\n`{text[:60]}`\n\n약 30~60초 소요됩니다",
            parse_mode="Markdown",
        )
        result = await asyncio.get_event_loop().run_in_executor(None, v0_generate_ui, text)
        await thinking_msg.delete()
        await update.message.reply_text(
            result,
            reply_markup=KB([BTN("🎨 v0 메뉴", "v0_menu"), BTN("🏠 홈", "menu")]),
            parse_mode="Markdown",
        )
        return

    # 5-b. 카카오 인증완료
    if text in ("인증완료", "인증 완료"):
        await update.message.reply_text(
            "✅ *카카오 인증 완료 확인*\n포스팅을 계속 진행합니다.",
            reply_markup=kb_home(),
            parse_mode="Markdown",
        )
        return

    # 6. v0 UI 생성 명령 감지 ("v0:" 또는 "v0 생성:" 접두어)
    if low.startswith("v0:") or low.startswith("v0 생성:") or low.startswith("v0생성:"):
        prompt = text.split(":", 1)[1].strip()
        context.user_data["awaiting"] = "v0_generating"
        thinking_msg = await update.message.reply_text(
            "🎨 *v0 UI 생성 중...*\n\n잠시 기다려 주세요 (30초~1분 소요)",
            parse_mode="Markdown",
        )
        result = await asyncio.get_event_loop().run_in_executor(None, v0_generate_ui, prompt)
        await thinking_msg.delete()
        await update.message.reply_text(
            result,
            reply_markup=KB([
                BTN("🎨 v0 메뉴", "v0_menu"),
                BTN("🏠 홈 메뉴", "menu"),
            ]),
            parse_mode="Markdown",
        )
        return

    # 7. 그 외 — Atlas PM AI가 직접 처리 (자유 텍스트 지시/질문)
    thinking_msg = await update.message.reply_text("🤔 *Atlas PM 처리 중...*", parse_mode="Markdown")
    reply = await asyncio.get_event_loop().run_in_executor(None, atlas_pm_reply, text)
    await thinking_msg.delete()
    await update.message.reply_text(
        f"🚀 *Atlas PM*\n━━━━━━━━━━━━━━━━━━\n\n{reply}",
        reply_markup=KB(
            [BTN("🏠 홈 메뉴", "menu"), BTN("💬 계속 대화", "keep_chat")],
        ),
        parse_mode="Markdown",
    )


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 메인 진입점
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def main() -> None:
    if not BOT_TOKEN:
        print("❌ TELEGRAM_BOT_TOKEN 이 .env 에 설정되지 않았습니다.")
        sys.exit(1)

    print("🚀 Atlas 총괄 PM 봇 시작 중...")
    print(f"   프로젝트 루트: {PROJECT_DIR}")
    print(f"   shared_state: {'✅ 연결됨' if _SHARED_STATE_OK else '⚠️ 없음'}")
    print(f"   GAME_DIR: {GAME_DIR}")
    print(f"   OPS_DIR:  {OPS_DIR}")
    print(f"   PM_DIR:   {PM_DIR}")

    app = Application.builder().token(BOT_TOKEN).build()

    # 슬래시 명령어
    app.add_handler(CommandHandler("start", cmd_start))
    app.add_handler(CommandHandler("menu",  cmd_menu))
    app.add_handler(CommandHandler("help",  cmd_help))
    app.add_handler(CommandHandler("atlas", cmd_start))   # /atlas 로도 홈 메뉴

    # 버튼 핸들러
    app.add_handler(CallbackQueryHandler(button_handler))

    # 텍스트 핸들러
    app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, text_handler))

    print("✅ 봇 실행 중. Ctrl+C 로 종료.")
    app.run_polling(drop_pending_updates=True)


if __name__ == "__main__":
    main()
