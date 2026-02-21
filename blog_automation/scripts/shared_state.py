"""
shared_state.py — Claude Code ↔ Cursor AI ↔ Telegram Bot 3-way 공유 상태 관리

역할:
  - 3개 도구가 하나의 JSON 파일을 통해 서로 현재 상태를 파악
  - 동일 파일 동시 수정 등 충돌 상황 감지 → 텔레그램으로 Steve에게 알림
  - 각 도구가 작업 시작 전 충돌 여부 확인

파일 위치:
  /geekbrox/output/shared_state.json   ← 실시간 상태
  /geekbrox/output/activity_log.json   ← 전체 이력 (최근 200개)
  /geekbrox/output/conflicts.json      ← 충돌 이력
"""

from __future__ import annotations

import json
import os
import time
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Any

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 경로 설정
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
SCRIPT_DIR     = Path(__file__).resolve().parent
PROJECT_DIR    = SCRIPT_DIR.parent.parent
STATE_FILE     = PROJECT_DIR / "output" / "shared_state.json"
LOG_FILE       = PROJECT_DIR / "output" / "activity_log.json"
CONFLICT_FILE  = PROJECT_DIR / "output" / "conflicts.json"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 상수
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# 도구 식별자
ACTOR_CLAUDE   = "claude_code"
ACTOR_CURSOR   = "cursor_ai"
ACTOR_TELEGRAM = "telegram_bot"
ACTOR_SCRIPT   = "script"

# 작업 상태
STATUS_IDLE    = "idle"
STATUS_RUNNING = "running"
STATUS_WAITING = "waiting"
STATUS_DONE    = "done"
STATUS_ERROR   = "error"

# 충돌 심각도
SEVERITY_INFO  = "info"
SEVERITY_WARN  = "warning"
SEVERITY_CRIT  = "critical"

# 동시 작업 허용 여부 (같은 파일 수정 시 충돌)
CONFLICT_RULES = {
    # (actor1, actor2): 충돌 여부
    (ACTOR_CLAUDE, ACTOR_CURSOR):   True,   # 둘 다 코드 수정 → 충돌 가능
    (ACTOR_CLAUDE, ACTOR_TELEGRAM): False,  # 텔레그램은 명령만 → 충돌 없음
    (ACTOR_CURSOR, ACTOR_TELEGRAM): False,
}


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 유틸리티
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def _now() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def _load(path: Path, default) -> Any:
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception:
        return default


def _save(path: Path, data: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix(".tmp")
    tmp.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    tmp.replace(path)


def _load_state() -> dict:
    return _load(STATE_FILE, _default_state())


def _save_state(state: dict) -> None:
    state["last_updated"] = _now()
    _save(STATE_FILE, state)


def _default_state() -> dict:
    return {
        "version": "2.0",
        "last_updated": _now(),

        # 각 도구의 현재 상태
        "actors": {
            ACTOR_CLAUDE: {
                "status": STATUS_IDLE,
                "action": None,
                "target_files": [],   # 현재 수정 중인 파일 목록
                "progress": None,
                "detail": None,
                "started_at": None,
                "last_active": None,
                "session_note": None,
            },
            ACTOR_CURSOR: {
                "status": STATUS_IDLE,
                "action": None,
                "target_files": [],
                "progress": None,
                "detail": None,
                "started_at": None,
                "last_active": None,
                "session_note": None,
            },
            ACTOR_TELEGRAM: {
                "status": STATUS_IDLE,
                "action": None,
                "target_files": [],
                "progress": None,
                "detail": None,
                "started_at": None,
                "last_active": None,
                "session_note": None,
            },
        },

        # 충돌 감지 결과 (미확인 충돌)
        "unresolved_conflicts": [],

        # 도구 간 메시지 큐
        "messages": {
            ACTOR_CLAUDE:   [],   # 다른 도구 → Claude Code 로 보낸 메시지
            ACTOR_CURSOR:   [],   # 다른 도구 → Cursor AI 로 보낸 메시지
            ACTOR_TELEGRAM: [],   # 다른 도구 → Bot 으로 보낸 메시지 (Steve 알림용)
        },

        # 최근 완료
        "last_completed": {
            "actor": None,
            "action": None,
            "result": None,
            "at": None,
        },

        # 공유 메모 (양방향, 최근 30개)
        "shared_notes": [],
    }


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 활동 로그
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def _log(entry: dict) -> None:
    logs = _load(LOG_FILE, [])
    logs.append({"at": _now(), **entry})
    logs = logs[-200:]
    _save(LOG_FILE, logs)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 충돌 감지 엔진
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def _detect_conflicts(state: dict, new_actor: str, new_files: list[str]) -> list[dict]:
    """
    새 작업 등록 시 기존 작업과 충돌 여부 검사.
    반환: 감지된 충돌 목록 (빈 리스트면 충돌 없음)
    """
    conflicts = []
    actors = state.get("actors", {})

    for actor_id, actor_state in actors.items():
        if actor_id == new_actor:
            continue
        if actor_state.get("status") not in (STATUS_RUNNING, STATUS_WAITING):
            continue

        # 충돌 규칙 확인
        pair = tuple(sorted([new_actor, actor_id]))
        may_conflict = CONFLICT_RULES.get(pair, False)
        if not may_conflict:
            continue

        # 파일 겹침 확인
        existing_files = set(actor_state.get("target_files", []))
        new_files_set  = set(new_files)
        overlap = existing_files & new_files_set

        if overlap:
            conflicts.append({
                "type": "file_overlap",
                "severity": SEVERITY_CRIT,
                "actor_a": actor_id,
                "actor_b": new_actor,
                "overlapping_files": sorted(overlap),
                "actor_a_action": actor_state.get("action"),
                "detected_at": _now(),
                "resolved": False,
            })
        elif existing_files and new_files_set:
            # 같은 파일은 아니지만 동시 작업 경고
            conflicts.append({
                "type": "concurrent_edit",
                "severity": SEVERITY_WARN,
                "actor_a": actor_id,
                "actor_b": new_actor,
                "actor_a_files": sorted(existing_files),
                "actor_b_files": sorted(new_files_set),
                "actor_a_action": actor_state.get("action"),
                "detected_at": _now(),
                "resolved": False,
            })

    return conflicts


def _save_conflicts(conflicts: list[dict]) -> None:
    """충돌을 conflicts.json에 저장."""
    existing = _load(CONFLICT_FILE, [])
    existing.extend(conflicts)
    existing = existing[-100:]  # 최근 100개 유지
    _save(CONFLICT_FILE, existing)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 텔레그램 알림
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def tg_notify(text: str) -> None:
    """텔레그램으로 메시지 전송."""
    bot_token = os.environ.get("TELEGRAM_BOT_TOKEN", "").strip()
    chat_id   = os.environ.get("TELEGRAM_CHAT_ID", "").strip()
    if not bot_token or not chat_id:
        return
    try:
        url     = f"https://api.telegram.org/bot{bot_token}/sendMessage"
        payload = json.dumps({
            "chat_id": chat_id, "text": text, "parse_mode": "Markdown",
        }).encode("utf-8")
        req = urllib.request.Request(
            url, data=payload,
            headers={"Content-Type": "application/json"}, method="POST",
        )
        urllib.request.urlopen(req, timeout=10)
    except Exception:
        pass


def _notify_conflict(conflicts: list[dict]) -> None:
    """충돌 발생 시 Steve에게 텔레그램 알림."""
    for c in conflicts:
        severity_icon = {"critical": "🚨", "warning": "⚠️", "info": "ℹ️"}.get(c["severity"], "❓")
        actor_icons = {ACTOR_CLAUDE: "🖥", ACTOR_CURSOR: "🎯", ACTOR_TELEGRAM: "📱"}

        if c["type"] == "file_overlap":
            files_str = "\n".join(f"  • `{f}`" for f in c["overlapping_files"])
            msg = (
                f"{severity_icon} *충돌 감지!* [{c['severity'].upper()}]\n\n"
                f"*{actor_icons.get(c['actor_a'], '?')} {c['actor_a']}* 작업 중:\n"
                f"  → {c.get('actor_a_action', '알 수 없음')}\n\n"
                f"*{actor_icons.get(c['actor_b'], '?')} {c['actor_b']}* 가 같은 파일 수정 시도!\n\n"
                f"🗂 *겹치는 파일:*\n{files_str}\n\n"
                f"⚡ 한 작업이 완료된 후 다른 작업을 시작하세요.\n"
                f"텔레그램에서 `충돌 해제`를 입력하면 강제 진행합니다."
            )
        else:  # concurrent_edit
            msg = (
                f"{severity_icon} *동시 편집 경고!* [{c['severity'].upper()}]\n\n"
                f"*{actor_icons.get(c['actor_a'], '?')} {c['actor_a']}* 과 "
                f"*{actor_icons.get(c['actor_b'], '?')} {c['actor_b']}* 가 "
                f"동시에 다른 파일을 수정 중입니다.\n"
                f"⚠️ git 충돌 위험이 있습니다."
            )
        tg_notify(msg)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 공통 내부 작업 등록
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def _register_task(
    actor: str,
    action: str,
    target_files: list[str] = None,
    detail: str = "",
    progress: str = "",
    check_conflict: bool = True,
) -> list[dict]:
    """
    작업 등록 + 충돌 감지 + 상태 저장.
    반환: 감지된 충돌 목록.
    """
    state = _load_state()
    target_files = target_files or []

    # 충돌 감지
    conflicts = []
    if check_conflict:
        conflicts = _detect_conflicts(state, actor, target_files)
        if conflicts:
            state.setdefault("unresolved_conflicts", []).extend(conflicts)
            _save_conflicts(conflicts)
            _notify_conflict(conflicts)

    # 상태 업데이트
    state["actors"][actor].update({
        "status": STATUS_RUNNING,
        "action": action,
        "target_files": target_files,
        "progress": progress or None,
        "detail": detail or None,
        "started_at": _now(),
        "last_active": _now(),
    })
    _save_state(state)
    _log({"actor": actor, "action": action, "status": STATUS_RUNNING,
          "files": target_files, "detail": detail})
    return conflicts


def _update_actor(actor: str, **kwargs) -> None:
    state = _load_state()
    state["actors"][actor].update({k: v for k, v in kwargs.items() if v is not None})
    state["actors"][actor]["last_active"] = _now()
    _save_state(state)


def _complete_actor(actor: str, result: str = "") -> None:
    state = _load_state()
    action = state["actors"][actor].get("action", "unknown")
    state["actors"][actor].update({
        "status": STATUS_DONE,
        "detail": result or "완료",
        "target_files": [],
        "last_active": _now(),
    })
    state["last_completed"] = {"actor": actor, "action": action, "result": result, "at": _now()}
    _save_state(state)
    _log({"actor": actor, "action": action, "status": STATUS_DONE, "result": result})


def _error_actor(actor: str, error: str) -> None:
    state = _load_state()
    state["actors"][actor].update({
        "status": STATUS_ERROR,
        "detail": error,
        "last_active": _now(),
    })
    _save_state(state)
    _log({"actor": actor, "status": STATUS_ERROR, "error": error})


def _idle_actor(actor: str) -> None:
    state = _load_state()
    state["actors"][actor].update({
        "status": STATUS_IDLE,
        "action": None,
        "target_files": [],
        "progress": None,
        "detail": None,
    })
    _save_state(state)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Claude Code 전용 API
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def claude_set_task(action: str, target_files: list[str] = None,
                    detail: str = "", progress: str = "") -> list[dict]:
    """Claude Code 작업 시작 등록. 충돌 감지 포함. 반환: 충돌 목록."""
    return _register_task(ACTOR_CLAUDE, action, target_files, detail, progress)


def claude_update_progress(progress: str, detail: str = "") -> None:
    _update_actor(ACTOR_CLAUDE, progress=progress, detail=detail or None)


def claude_set_waiting(reason: str, wait_sec: int) -> None:
    state = _load_state()
    state["actors"][ACTOR_CLAUDE].update({
        "status": STATUS_WAITING,
        "detail": f"{reason} ({wait_sec}초 대기)",
        "last_active": _now(),
    })
    _save_state(state)
    _log({"actor": ACTOR_CLAUDE, "status": STATUS_WAITING, "reason": reason, "wait_sec": wait_sec})


def claude_set_done(result: str = "") -> None:
    _complete_actor(ACTOR_CLAUDE, result)


def claude_set_error(error: str) -> None:
    _error_actor(ACTOR_CLAUDE, error)


def claude_set_file_modified(filepath: str) -> None:
    state = _load_state()
    files = state["actors"][ACTOR_CLAUDE].get("target_files", [])
    if filepath not in files:
        files.append(filepath)
    state["actors"][ACTOR_CLAUDE]["target_files"] = files[-10:]
    state["actors"][ACTOR_CLAUDE]["last_active"] = _now()
    _save_state(state)


def claude_add_note(note: str) -> None:
    state = _load_state()
    state["actors"][ACTOR_CLAUDE]["session_note"] = note
    state["shared_notes"].append({"from": ACTOR_CLAUDE, "msg": note, "at": _now()})
    state["shared_notes"] = state["shared_notes"][-30:]
    _save_state(state)
    tg_notify(f"📝 *Claude Code 메모*\n_{note}_")


def claude_idle() -> None:
    _idle_actor(ACTOR_CLAUDE)


def claude_check_messages() -> list[dict]:
    """Claude Code로 온 메시지 확인 후 삭제."""
    state = _load_state()
    msgs = state["messages"].get(ACTOR_CLAUDE, [])
    if msgs:
        state["messages"][ACTOR_CLAUDE] = []
        _save_state(state)
    return msgs


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Cursor AI 전용 API
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def cursor_set_task(action: str, target_files: list[str] = None,
                    detail: str = "", progress: str = "") -> list[dict]:
    """Cursor AI 작업 시작 등록. 충돌 감지 포함."""
    conflicts = _register_task(ACTOR_CURSOR, action, target_files, detail, progress)
    return conflicts


def cursor_update_progress(progress: str, detail: str = "") -> None:
    _update_actor(ACTOR_CURSOR, progress=progress, detail=detail or None)


def cursor_set_done(result: str = "") -> None:
    _complete_actor(ACTOR_CURSOR, result)


def cursor_set_error(error: str) -> None:
    _error_actor(ACTOR_CURSOR, error)


def cursor_add_note(note: str) -> None:
    state = _load_state()
    state["actors"][ACTOR_CURSOR]["session_note"] = note
    state["shared_notes"].append({"from": ACTOR_CURSOR, "msg": note, "at": _now()})
    state["shared_notes"] = state["shared_notes"][-30:]
    _save_state(state)
    tg_notify(f"🎯 *Cursor AI 메모*\n_{note}_")


def cursor_idle() -> None:
    _idle_actor(ACTOR_CURSOR)


def cursor_check_messages() -> list[dict]:
    """Cursor AI로 온 메시지 확인 후 삭제."""
    state = _load_state()
    msgs = state["messages"].get(ACTOR_CURSOR, [])
    if msgs:
        state["messages"][ACTOR_CURSOR] = []
        _save_state(state)
    return msgs


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Telegram Bot 전용 API
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

def telegram_get_current_state() -> dict:
    return _load_state()


def telegram_format_status() -> str:
    """3개 도구의 현재 상태를 텔레그램용 텍스트로 포맷."""
    state = _load_state()
    actors = state.get("actors", {})
    conflicts = state.get("unresolved_conflicts", [])
    last = state.get("last_completed", {})

    icon_map = {
        ACTOR_CLAUDE:   "🖥 Claude Code",
        ACTOR_CURSOR:   "🎯 Cursor AI",
        ACTOR_TELEGRAM: "📱 Telegram Bot",
    }
    status_icon = {
        STATUS_IDLE:    "⚪️ 대기",
        STATUS_RUNNING: "🟢 실행 중",
        STATUS_WAITING: "🟡 대기 중",
        STATUS_DONE:    "✅ 완료",
        STATUS_ERROR:   "🔴 오류",
    }

    lines = ["🔗 *3-way 공유 현황*\n"]

    # 충돌 경고 (최우선)
    if conflicts:
        unresolved = [c for c in conflicts if not c.get("resolved")]
        if unresolved:
            lines.append(f"🚨 *미해결 충돌: {len(unresolved)}건*")
            for c in unresolved[:3]:
                lines.append(f"  • {c['actor_a']} ↔ {c['actor_b']}: {c['type']}")
            lines.append("")

    # 각 도구 상태
    for actor_id, label in icon_map.items():
        a = actors.get(actor_id, {})
        st = a.get("status", STATUS_IDLE)
        lines.append(f"*{label}*: {status_icon.get(st, '❓')}")
        if a.get("action"):
            lines.append(f"  작업: {a['action']}")
        if a.get("progress"):
            lines.append(f"  진행: {a['progress']}")
        if a.get("detail"):
            lines.append(f"  상세: _{a['detail'][:60]}_")
        if a.get("target_files"):
            files_preview = ", ".join(Path(f).name for f in a["target_files"][:3])
            lines.append(f"  파일: `{files_preview}`")
        if a.get("last_active"):
            lines.append(f"  활동: {a['last_active']}")
        if a.get("session_note"):
            lines.append(f"  📝 _{a['session_note'][:50]}_")
        lines.append("")

    # 마지막 완료
    if last.get("action"):
        lines.append(f"✅ *최근 완료:* [{last.get('actor','')}] {last['action']}")
        lines.append(f"  → {last.get('result','완료')} _{last.get('at','')}_")
        lines.append("")

    # 공유 메모 최근 3개
    notes = state.get("shared_notes", [])[-3:]
    if notes:
        lines.append("*📝 최근 메모:*")
        for n in reversed(notes):
            icon = {"claude_code": "🖥", "cursor_ai": "🎯", "telegram_bot": "📱"}.get(n["from"], "•")
            lines.append(f"  {icon} {n['msg'][:50]} _({n['at'][-8:]})_")

    lines.append(f"\n_업데이트: {state.get('last_updated', '-')}_")
    return "\n".join(lines)


def telegram_get_activity_log(limit: int = 15) -> str:
    logs = _load(LOG_FILE, [])
    recent = logs[-limit:][::-1]
    lines = [f"📋 *활동 로그* (최신 {len(recent)}개)\n"]
    actor_icon = {ACTOR_CLAUDE: "🖥", ACTOR_CURSOR: "🎯", ACTOR_TELEGRAM: "📱", ACTOR_SCRIPT: "⚙️"}
    status_icon = {STATUS_RUNNING: "▶️", STATUS_DONE: "✅", STATUS_ERROR: "❌", STATUS_WAITING: "⏳"}
    for entry in recent:
        ai = actor_icon.get(entry.get("actor", ""), "•")
        si = status_icon.get(entry.get("status", ""), "")
        action = entry.get("action") or entry.get("cmd") or entry.get("reason") or ""
        detail = entry.get("result") or entry.get("detail") or entry.get("error") or ""
        at = entry.get("at", "")[-8:]
        line = f"{ai}{si} `{at}` {action[:40]}"
        if detail:
            line += f" — _{detail[:40]}_"
        lines.append(line)
    return "\n".join(lines)


def telegram_get_conflicts(unresolved_only: bool = True) -> str:
    """충돌 목록을 텔레그램용 텍스트로 반환."""
    conflicts = _load(CONFLICT_FILE, [])
    if unresolved_only:
        conflicts = [c for c in conflicts if not c.get("resolved")]
    if not conflicts:
        return "✅ *감지된 충돌 없음*"
    lines = [f"🚨 *충돌 목록* ({len(conflicts)}건)\n"]
    for i, c in enumerate(conflicts[-10:], 1):
        sev_icon = {"critical": "🚨", "warning": "⚠️", "info": "ℹ️"}.get(c.get("severity", ""), "❓")
        lines.append(
            f"{i}. {sev_icon} `{c.get('detected_at', '')[-8:]}` "
            f"{c.get('actor_a','')} ↔ {c.get('actor_b','')}\n"
            f"   타입: {c.get('type','')} | {'미해결' if not c.get('resolved') else '해결됨'}"
        )
        if c.get("overlapping_files"):
            lines.append(f"   파일: {', '.join(Path(f).name for f in c['overlapping_files'][:3])}")
    return "\n".join(lines)


def telegram_resolve_conflicts() -> str:
    """모든 미해결 충돌을 해결 처리."""
    state = _load_state()
    count = 0
    for c in state.get("unresolved_conflicts", []):
        if not c.get("resolved"):
            c["resolved"] = True
            c["resolved_at"] = _now()
            count += 1
    state["unresolved_conflicts"] = [c for c in state["unresolved_conflicts"] if not c.get("resolved")]
    _save_state(state)

    # conflict_file도 업데이트
    conflicts = _load(CONFLICT_FILE, [])
    for c in conflicts:
        if not c.get("resolved"):
            c["resolved"] = True
            c["resolved_at"] = _now()
    _save(CONFLICT_FILE, conflicts)
    _log({"actor": ACTOR_TELEGRAM, "action": "충돌 해제", "count": count})
    return f"✅ {count}건의 충돌이 해제되었습니다."


def telegram_send_message(to_actor: str, msg: str) -> None:
    """특정 도구로 메시지 전달."""
    state = _load_state()
    state["messages"].setdefault(to_actor, []).append({
        "from": ACTOR_TELEGRAM,
        "msg": msg,
        "at": _now(),
        "read": False,
    })
    state["messages"][to_actor] = state["messages"][to_actor][-10:]
    _save_state(state)


def telegram_add_note(note: str) -> None:
    state = _load_state()
    state["shared_notes"].append({"from": ACTOR_TELEGRAM, "msg": note, "at": _now()})
    state["shared_notes"] = state["shared_notes"][-30:]
    _save_state(state)


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CLI: 직접 실행 시 상태 출력 / Cursor AI 연동용
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if __name__ == "__main__":
    import sys
    args = sys.argv[1:]

    if not args or args[0] == "status":
        print(telegram_format_status())

    elif args[0] == "log":
        n = int(args[1]) if len(args) > 1 else 20
        print(telegram_get_activity_log(n))

    elif args[0] == "conflicts":
        print(telegram_get_conflicts())

    elif args[0] == "resolve":
        print(telegram_resolve_conflicts())

    elif args[0] == "note" and len(args) > 1:
        note = " ".join(args[1:])
        claude_add_note(note)
        print(f"✅ 메모 추가: {note}")

    # Cursor AI용 명령 (cursor start <action> [file1 file2 ...])
    elif args[0] == "cursor" and len(args) >= 3:
        subcmd = args[1]
        if subcmd == "start":
            action = args[2]
            files  = args[3:] if len(args) > 3 else []
            conflicts = cursor_set_task(action, files)
            result = {"status": "ok", "conflicts": conflicts}
            print(json.dumps(result, ensure_ascii=False))
        elif subcmd == "done":
            result_msg = " ".join(args[2:]) if len(args) > 2 else ""
            cursor_set_done(result_msg)
            print(json.dumps({"status": "ok"}))
        elif subcmd == "error":
            error_msg = " ".join(args[2:])
            cursor_set_error(error_msg)
            print(json.dumps({"status": "ok"}))
        elif subcmd == "idle":
            cursor_idle()
            print(json.dumps({"status": "ok"}))
        elif subcmd == "note":
            note = " ".join(args[2:])
            cursor_add_note(note)
            print(json.dumps({"status": "ok"}))
        elif subcmd == "messages":
            msgs = cursor_check_messages()
            print(json.dumps(msgs, ensure_ascii=False))

    elif args[0] == "idle":
        claude_idle()
        print("✅ Claude Code 상태를 idle로 초기화했습니다.")

    elif args[0] == "reset":
        STATE_FILE.unlink(missing_ok=True)
        LOG_FILE.unlink(missing_ok=True)
        CONFLICT_FILE.unlink(missing_ok=True)
        print("✅ 모든 상태 파일 초기화 완료")

    else:
        print(
            "사용법:\n"
            "  python3 shared_state.py status\n"
            "  python3 shared_state.py log [N]\n"
            "  python3 shared_state.py conflicts\n"
            "  python3 shared_state.py resolve\n"
            "  python3 shared_state.py note <메모>\n"
            "  python3 shared_state.py cursor start <action> [file1 file2 ...]\n"
            "  python3 shared_state.py cursor done [result]\n"
            "  python3 shared_state.py cursor idle\n"
            "  python3 shared_state.py cursor messages\n"
            "  python3 shared_state.py idle\n"
            "  python3 shared_state.py reset\n"
        )
