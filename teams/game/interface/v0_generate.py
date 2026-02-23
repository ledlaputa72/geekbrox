#!/usr/bin/env python3
"""
v0_generate.py — v0.dev API로 게임 UI 컴포넌트 생성

사용법:
  .venv/bin/python3 teams/game/interface/v0_generate.py --screen c01_dream
  .venv/bin/python3 teams/game/interface/v0_generate.py --prompt "카드 획득 팝업"
  .venv/bin/python3 teams/game/interface/v0_generate.py --list
"""

import argparse
import json
import os
import sys
import time
import urllib.request
import urllib.error
from pathlib import Path

# ── 경로 설정 ────────────────────────────────────────────────────────────────
SCRIPT_DIR    = Path(__file__).resolve().parent
PROJECT_DIR   = SCRIPT_DIR.parent.parent.parent  # geekbrox/
V0_EXPORTS    = SCRIPT_DIR / "v0-exports"
ENV_FILE      = PROJECT_DIR / ".env"

# ── .env 로드 ─────────────────────────────────────────────────────────────────
def load_env():
    if ENV_FILE.exists():
        for line in ENV_FILE.read_text(encoding="utf-8").splitlines():
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ.setdefault(k.strip(), v.strip().strip('"').strip("'"))

load_env()

# ── 시스템 컨텍스트 ───────────────────────────────────────────────────────────
SYSTEM_CONTEXT = """모바일 방치형 덱빌딩 게임 UI 제작 중입니다.

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

# ── 화면 프리셋 ───────────────────────────────────────────────────────────────
PRESETS = {
    "c01_dream": {
        "label": "C-01 메인 로비 (Dream — 꿈 수집가)",
        "theme": "dream-theme",
        "filename": "c01-main-lobby.tsx",
        "prompt": """[메인 로비 - 꿈 수집가] 390×844px 세로 모바일:
① 상단 재화 바(108px): 좌측 💎레버리"1,234" + ✨드림샤드"56" 캡슐칩, 우측 🔔⚙️ 아이콘
② 메인 비주얼(약 380px): 딥네이비 배경+별빛 파티클, 중앙 몽환 캐릭터 실루엣(흰 망토),
   하단 오프라인수익 배너 "오프라인 수익: +345 레버리"
③ 메인 액션 버튼(72px): "💎 수집하기 (345 레버리)" gradient(#7B9EF0,#9BB5F5) 라운드20px
④ 하단 5탭(80px): 🏠홈(활성)|🃏카드|⬆업그레이드|🌙프레스티지|🏪상점
전체: 딥네이비 그라데이션(#0D1B3E→#1A2A5E), 글래스모피즘""",
    },
    "c01_dark": {
        "label": "C-01 메인 로비 (Dark — 던전 기생충)",
        "theme": "dark-theme",
        "filename": "c01-main-lobby.tsx",
        "prompt": """[메인 로비 - 던전 기생충] Dream 구조 유지, 다음만 교체:
배경:#0A0A0A, Primary:#8B1A1A, Accent:#00CED1
재화: 🧬DNA"2,400" + 💰골드"830"
캐릭터: 무정형 기생체(촉수+청록 핵), 감염 파티클
버튼: "🎮 런 시작하기" gradient(#8B1A1A,#B22222)
탭: 🏠홈|🧟컬렉션|⬆업그레이드|🧬계통|🏪상점
스타일: 다크 호러, 고딕""",
    },
    "c02": {
        "label": "C-02 카드 라이브러리",
        "theme": "dream-theme",
        "filename": "c02-card-library.tsx",
        "prompt": """[카드 라이브러리] 390×844px:
① 헤더(64px): "🃏 카드 라이브러리" + 우측 "34/200"
② 필터 바(44px 가로스크롤): [전체][수집][액션][시너지][이벤트] + 희귀도▼ 정렬▼
③ 카드 그리드(3열 스크롤) 각 100×140px: 상단60%이미지, 카드이름12px Bold, 효과설명10px
   좌상단 에너지비용 원형배지, 테두리: 일반#888/언커먼#4CAF50/레어#7B68EE/전설#FFD700 glow
④ 하단 5탭(표준)""",
    },
    "c03": {
        "label": "C-03 덱 빌더",
        "theme": "dream-theme",
        "filename": "c03-deck-builder.tsx",
        "prompt": """[덱 빌더] 390×844px:
① 헤더: "덱 빌더" + "8/12장" + 덱파워 별점 ★★★☆☆
② 현재 덱 슬롯(가로스크롤 110px): 카드64×90px 8장 + 빈슬롯4개(점선)
③ 구분선 + "카드 선택" 제목
④ 필터 바 + 카드 그리드(3열): 덱포함카드 초록체크✓
⑤ 하단 고정: [덱 저장] + [런 시작] 나란히""",
    },
    "c04": {
        "label": "C-04 업그레이드 트리",
        "theme": "dream-theme",
        "filename": "c04-upgrade-tree.tsx",
        "prompt": """[업그레이드 트리] 390×844px:
① 헤더: "⬆ 업그레이드" + 보유재화 "💎1,234"
② 카테고리 탭(가로스크롤): [방치속도][덱확장][프레스티지][특수능력]
③ 트리 영역(스크롤): 노드 120×120px 3열, 연결선SVG
   각 노드: 아이콘40px+이름+효과설명+레벨3/10+업그레이드버튼
   상태: 가능(primary색)/부족(회색)/MAX(금색)/잠김(어둡게+🔒)
④ 하단 5탭(표준)""",
    },
    "c05": {
        "label": "C-05 상점",
        "theme": "dream-theme",
        "filename": "c05-shop.tsx",
        "prompt": """[상점] 390×844px:
① 헤더: "🏪 상점" + 보유재화
② 카테고리 탭: [패키지][카드팩][꾸미기][이벤트]
③ [패키지] 전폭 배너: 🎁스타터패키지 -50%, 드림샤드×100+카드팩×3, ~~$4.99~~ $2.49
④ 일반 상품 목록: 좌측80×80이미지+우측이름/설명/가격/구매버튼
⑤ [카드팩] 2열 그리드: 팩아트+이름+포함수+가격
⑥ 하단 고정: "🚫 광고 없는 게임 - 영구 $4.99" 배너
⑦ 하단 5탭(표준)""",
    },
}

# ── v0 API 호출 ───────────────────────────────────────────────────────────────
def call_v0_api(prompt: str) -> dict:
    v0_key = os.environ.get("v0_API_KEY", "").strip()
    if not v0_key:
        return {"error": "v0_API_KEY가 .env에 없습니다."}

    full_prompt = f"{SYSTEM_CONTEXT}\n\n---\n\n{prompt}"

    payload = json.dumps({
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

    try:
        with urllib.request.urlopen(req, timeout=120) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        return {"error": f"HTTP {e.code}: {body[:300]}"}
    except Exception as e:
        return {"error": str(e)}


def extract_code(content: str) -> str:
    """응답에서 코드 추출 — v0 API 다양한 응답 형식 처리."""
    import re

    # 0. <Thinking> 태그 먼저 제거
    content = re.sub(r"<Thinking>.*?</Thinking>", "", content, flags=re.DOTALL).strip()

    # 1. 코드 블록 추출 (```tsx, ```jsx, ```typescript, ```)
    if "```" in content:
        # 가장 긴 코드 블록을 찾아 반환
        best = ""
        parts = content.split("```")
        for i, part in enumerate(parts):
            if i % 2 == 1:
                lines = part.split("\n")
                # 첫 줄이 언어 태그면 제거 (예: "tsx file="button.tsx"")
                first = lines[0].strip().lower()
                if first.startswith(("tsx", "jsx", "typescript", "ts", "javascript", "js", "")):
                    code = "\n".join(lines[1:])
                else:
                    code = part
                if len(code) > len(best):
                    best = code
        if best.strip():
            return best.strip()

    # 2. <QuickEdit> 태그 내 코드 추출
    qe_match = re.search(r"<QuickEdit[^>]*>(.*?)</QuickEdit>", content, re.DOTALL)
    if qe_match:
        return qe_match.group(1).strip()

    # 3. JSX/TSX 컴포넌트가 직접 포함된 경우
    if "export default" in content or ("return (" in content and "<div" in content):
        return content.strip()

    return ""


def save_code(code: str, theme: str, filename: str) -> Path:
    """코드를 v0-exports/ 하위에 저장."""
    save_dir = V0_EXPORTS / theme
    save_dir.mkdir(parents=True, exist_ok=True)
    save_path = save_dir / filename
    save_path.write_text(code, encoding="utf-8")
    return save_path


# ── 명령 처리 ─────────────────────────────────────────────────────────────────
def cmd_list():
    """저장된 v0 화면 목록 출력."""
    print("📁 생성된 v0 화면 목록")
    print("━" * 40)
    total = 0
    for theme_dir in sorted(V0_EXPORTS.iterdir()):
        if not theme_dir.is_dir() or theme_dir.name == "shared":
            continue
        files = sorted(theme_dir.glob("*.tsx"))
        if files:
            print(f"\n🗂 {theme_dir.name}/")
            for f in files:
                size = f.stat().st_size
                mtime = time.strftime("%m/%d %H:%M", time.localtime(f.stat().st_mtime))
                print(f"  ✅ {f.name}  ({size:,}B, {mtime})")
            total += len(files)
    if total == 0:
        print("  (아직 생성된 화면 없음)")
    print(f"\n총 {total}개 파일")


def cmd_generate(screen: str = "", prompt: str = "", custom_filename: str = ""):
    """UI 생성 실행."""
    if screen:
        key = screen.lower().replace("-", "_")
        if key not in PRESETS:
            print(f"❌ 알 수 없는 화면: {screen}")
            print(f"사용 가능: {', '.join(PRESETS.keys())}")
            sys.exit(1)
        preset = PRESETS[key]
        label    = preset["label"]
        theme    = preset["theme"]
        filename = preset["filename"]
        prompt   = preset["prompt"]
    else:
        label    = f"커스텀: {prompt[:40]}"
        theme    = "dream-theme"
        filename = custom_filename or f"custom-{int(time.time())%100000}.tsx"

    print(f"🎨 v0 UI 생성 시작")
    print(f"   화면: {label}")
    print(f"   저장: v0-exports/{theme}/{filename}")
    print(f"   ⏳ API 호출 중 (30~60초)...")

    t0 = time.time()
    result = call_v0_api(prompt)
    elapsed = time.time() - t0

    if "error" in result:
        print(f"\n❌ 오류: {result['error']}")
        sys.exit(1)

    content = result["choices"][0]["message"]["content"]
    code = extract_code(content)

    if code:
        save_path = save_code(code, theme, filename)
        lines = len(code.splitlines())
        print(f"\n✅ 생성 완료! ({elapsed:.1f}초)")
        print(f"   파일: {save_path}")
        print(f"   크기: {lines}줄 / {len(code):,}자")
        print(f"\n📋 응답 미리보기:")
        print("─" * 40)
        # 설명 부분만 출력 (코드 제외)
        desc = content.split("```")[0].strip()
        print(desc[:500] if desc else "(코드만 반환됨)")
        print("─" * 40)
        print(f"\n💡 v0.dev에서 미리보기:")
        print(f"   파일을 열고 코드를 v0.dev 채팅에 붙여넣으세요.")
    else:
        print(f"\n⚠️  코드 블록 없음. 전체 응답:")
        print(content[:800])


# ── 메인 ──────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="GeekBrox v0 UI 생성 도구")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--screen", "-s", help=f"프리셋 화면 키 ({', '.join(PRESETS.keys())})")
    group.add_argument("--prompt", "-p", help="커스텀 프롬프트")
    group.add_argument("--list",   "-l", action="store_true", help="저장된 화면 목록")
    parser.add_argument("--filename", "-f", help="저장 파일명 (--prompt 사용 시)")
    args = parser.parse_args()

    if args.list:
        cmd_list()
    elif args.screen:
        cmd_generate(screen=args.screen)
    elif args.prompt:
        cmd_generate(prompt=args.prompt, custom_filename=args.filename or "")


if __name__ == "__main__":
    main()
