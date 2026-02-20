"""
seasonal_top_anime.json을 읽어 각 애니마다 한국어 블로그 글 초안 생성 (Claude API → Gemini fallback)
커버 이미지 다운로드 → output/images/
글 저장 → output/posts/애니제목.md

수정 모드: --revise <md파일경로> --instruction <지시문>
  → 해당 .md 파일 내용을 지시에 맞게 Claude로 수정 후 같은 파일에 덮어쓰기.
  → atlas_bot.py 등에서 subprocess로 호출 시 사용.

LLM 전략:
  1차: Claude Sonnet (고품질)
  2차: Gemini 2.5 Flash fallback (Claude rate limit 또는 오류 시 자동 전환)
  환경변수: ANTHROPIC_API_KEY, GOOGLE_API_KEY
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

import requests
from anthropic import Anthropic
from dotenv import load_dotenv

load_dotenv()

SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = SCRIPT_DIR.parent.parent / "output"
INPUT_JSON = OUTPUT_DIR / "seasonal_top_anime.json"
IMAGES_DIR = OUTPUT_DIR / "images"
POSTS_DIR = OUTPUT_DIR / "posts"

SEASON_KR = {"WINTER": "겨울", "SPRING": "봄", "SUMMER": "여름", "FALL": "가을"}


def slugify(text: str, max_len: int = 80) -> str:
    """파일명/URL용 슬러그 생성."""
    text = re.sub(r"[^\w\s\-]", "", text)
    text = re.sub(r"[-\s]+", "-", text).strip("-")
    return text[:max_len] or "untitled"


def download_cover_image(url: str, save_path: Path) -> None:
    """커버 이미지를 save_path에 다운로드."""
    try:
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
        save_path.parent.mkdir(parents=True, exist_ok=True)
        save_path.write_bytes(resp.content)
    except requests.RequestException as e:
        raise RuntimeError(f"이미지 다운로드 실패 ({url}): {e}") from e


def get_image_extension(url: str) -> str:
    """URL에서 확장자 추출, 없으면 .jpg."""
    path = urlparse(url).path
    ext = Path(path).suffix.lower()
    return ext if ext in (".jpg", ".jpeg", ".png", ".webp", ".gif") else ".jpg"


def _is_rate_limit_error(e: Exception) -> bool:
    """Claude rate limit 관련 에러인지 판별."""
    msg = str(e).lower()
    return any(kw in msg for kw in ("rate_limit", "rate limit", "429", "too many requests", "overloaded"))


def _call_gemini(prompt: str, max_tokens: int = 2048) -> str:
    """Gemini API 호출 (fallback용). GOOGLE_API_KEY 환경변수 필요."""
    gemini_key = os.environ.get("GOOGLE_API_KEY")
    if not gemini_key:
        raise RuntimeError(
            "GOOGLE_API_KEY 환경변수가 없습니다. .env에 추가하거나 Google AI Studio에서 발급하세요.\n"
            "발급: https://aistudio.google.com/apikey"
        )
    try:
        from google import genai  # noqa: PLC0415
        from google.genai import types  # noqa: PLC0415
        client = genai.Client(api_key=gemini_key)
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt,
            config=types.GenerateContentConfig(max_output_tokens=max_tokens),
        )
        return response.text
    except Exception as e:
        raise RuntimeError(f"Gemini API 호출 실패: {e}") from e


def generate_blog_draft(anime: dict, season_label: str, image_rel_path: str) -> str:
    """한국어 블로그 글 본문 생성.

    1차: Claude Sonnet (고품질)
    2차: Gemini 2.5 Flash fallback (rate limit 또는 오류 시 자동 전환)
    """
    title_display = (
        anime.get("title_korean")
        or anime.get("title_english")
        or anime.get("title_native")
        or "제목 없음"
    )
    post_title = f"[{season_label} 애니] {title_display} - 리뷰/소개"

    user_content = f"""다음 애니메이션에 대한 한국어 블로그 글 초안을 작성해 주세요.

## 블로그 글 형식
- **제목**: {post_title}
- **구성**: 작품소개 → 장르 → 줄거리 → 평점 → 총평 (한국어로 작성)
- 글 **상단**에 이미지를 넣어 주세요. 이미지 마크다운은 반드시 아래 한 줄만 사용하세요 (그대로 복사):
![커버 이미지]({image_rel_path})

## 작품 정보
- 제목(한): {anime.get('title_korean') or '-'}
- 제목(영): {anime.get('title_english') or '-'}
- 제목(일): {anime.get('title_native') or '-'}
- 장르: {', '.join(anime.get('genres') or [])}
- 줄거리: {anime.get('synopsis') or '-'}
- 평점(AniList): {anime.get('average_score') or '-'}/100

## 요청 사항
- 반드시 마크다운만 출력하세요. 코드 블록이나 설명 없이 본문만 출력하세요.
- 첫 줄은 # 제목 형식으로 위의 블로그 제목을 쓰고, 그 다음 줄에 이미지, 이어서 작품소개·장르·줄거리·평점·총평 순서로 작성해 주세요."""

    # ── 1차 시도: Claude ──
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if api_key:
        try:
            client = Anthropic(api_key=api_key)
            message = client.messages.create(
                model="claude-sonnet-4-5-20250929",
                max_tokens=2048,
                messages=[{"role": "user", "content": user_content}],
            )
            block = message.content[0]
            if block.type != "text":
                raise RuntimeError(f"Claude API 비텍스트 응답: {block.type}")
            return block.text
        except Exception as e:
            if _is_rate_limit_error(e):
                print(f"  ⚠️  Claude rate limit → Gemini fallback으로 전환합니다.")
            else:
                raise RuntimeError(f"Claude API 호출 실패: {e}") from e
    else:
        print("  ⚠️  ANTHROPIC_API_KEY 없음 → Gemini fallback으로 전환합니다.")

    # ── 2차 시도: Gemini fallback ──
    print("  🤖 Gemini 2.5 Flash 호출 중...")
    text = _call_gemini(user_content, max_tokens=2048)
    print("  ✅ Gemini fallback 성공")
    return text


def revise_blog_draft(file_path: Path, instruction: str) -> str:
    """기존 블로그 글(.md) 내용을 instruction에 맞게 수정한 본문 반환.

    1차: Claude Sonnet / 2차: Gemini fallback
    """
    raw = file_path.read_text(encoding="utf-8")
    user_content = f"""다음은 블로그 글 마크다운 원문입니다. 사용자 지시에 맞게 **수정한 전체 글**만 출력하세요.
코드 블록이나 설명 없이 수정된 마크다운 본문만 출력합니다.

## 사용자 지시
{instruction}

## 현재 글 원문
---
{raw}
---

## 요청 사항
- 지시를 반영해 수정한 **전체** 마크다운을 출력하세요.
- 제목(# ...), 이미지(![...](...)), 본문 구조를 유지하면서 지시대로 고치세요.
- 출력은 반드시 마크다운만 하세요."""

    # ── 1차 시도: Claude ──
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if api_key:
        try:
            client = Anthropic(api_key=api_key)
            message = client.messages.create(
                model="claude-sonnet-4-5-20250929",
                max_tokens=4096,
                messages=[{"role": "user", "content": user_content}],
            )
            block = message.content[0]
            if block.type != "text":
                raise RuntimeError(f"Claude API 비텍스트 응답: {block.type}")
            return block.text.strip()
        except Exception as e:
            if _is_rate_limit_error(e):
                print(f"  ⚠️  Claude rate limit → Gemini fallback으로 전환합니다.")
            else:
                raise RuntimeError(f"Claude API 호출 실패: {e}") from e
    else:
        print("  ⚠️  ANTHROPIC_API_KEY 없음 → Gemini fallback으로 전환합니다.")

    # ── 2차 시도: Gemini fallback ──
    print("  🤖 Gemini 2.5 Flash 호출 중...")
    text = _call_gemini(user_content, max_tokens=4096)
    print("  ✅ Gemini fallback 성공")
    return text.strip()


def load_anime_list() -> tuple[str, int, list]:
    """seasonal_top_anime.json 로드. (season_kr_label, year, anime_list) 반환."""
    if not INPUT_JSON.exists():
        raise FileNotFoundError(f"입력 파일이 없습니다: {INPUT_JSON}")
    try:
        data = json.loads(INPUT_JSON.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError) as e:
        raise RuntimeError(f"JSON 로드 실패: {e}") from e

    season = data.get("season", "WINTER")
    year = data.get("season_year", 2026)
    anime_list = data.get("anime") or []
    season_label = f"{year} {SEASON_KR.get(season, season)}"
    return season_label, year, anime_list


def main() -> None:
    try:
        season_label, _year, anime_list = load_anime_list()
    except (FileNotFoundError, RuntimeError) as e:
        print(f"오류: {e}")
        raise

    IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    POSTS_DIR.mkdir(parents=True, exist_ok=True)

    for i, anime in enumerate(anime_list, start=1):
        title_display = (
            anime.get("title_korean")
            or anime.get("title_english")
            or anime.get("title_native")
            or "제목없음"
        )
        slug = slugify(title_display)
        if not slug:
            slug = f"anime_{i}"
        cover_url = anime.get("cover_image_url")
        image_ext = get_image_extension(cover_url) if cover_url else ".jpg"
        image_filename = f"{slug}{image_ext}"
        image_path = IMAGES_DIR / image_filename
        # 글에서 이미지 경로: output/posts/*.md 기준 상대경로
        image_rel_path = f"../images/{image_filename}"

        print(f"[{i}/{len(anime_list)}] {title_display}")

        try:
            if cover_url:
                download_cover_image(cover_url, image_path)
            body = generate_blog_draft(anime, season_label, image_rel_path)
            post_filename = f"{slug}.md"
            post_path = POSTS_DIR / post_filename
            post_path.write_text(body.strip(), encoding="utf-8")
            print(f"  → 저장: {post_path}")
        except Exception as e:
            print(f"  → 실패: {e}")
            raise

    print(f"완료: {len(anime_list)}개 글 생성, 이미지: {IMAGES_DIR}, 글: {POSTS_DIR}")


def run_revise_mode(revise_path: Path, instruction: str) -> None:
    """--revise <파일> --instruction <지시> 모드: 해당 .md 파일만 수정 후 덮어쓰기."""
    if not revise_path.exists():
        print(f"오류: 파일이 없습니다: {revise_path}", file=sys.stderr)
        sys.exit(1)
    if not instruction.strip():
        print("오류: --instruction 내용이 비어 있습니다.", file=sys.stderr)
        sys.exit(1)
    try:
        revised = revise_blog_draft(revise_path, instruction)
        revise_path.write_text(revised, encoding="utf-8")
        print(f"수정 완료: {revise_path}")
    except Exception as e:
        print(f"오류: {e}", file=sys.stderr)
        raise


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="애니 블로그 글 생성(기본) 또는 기존 글 수정(--revise)"
    )
    parser.add_argument(
        "--revise",
        type=Path,
        metavar="PATH",
        help="수정할 .md 파일 경로 (--instruction과 함께 사용)",
    )
    parser.add_argument(
        "--instruction",
        type=str,
        default="",
        metavar="TEXT",
        help="수정 지시문 (--revise와 함께 사용)",
    )
    args = parser.parse_args()

    if args.revise is not None:
        run_revise_mode(args.revise, args.instruction or "")
    else:
        main()
