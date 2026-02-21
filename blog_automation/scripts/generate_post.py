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

확장 데이터 소스:
  - AniList GraphQL: 애니 기본 정보 + 캐릭터/성우 + 관련 작품
  - TMDB API: 포스터/스틸컷 이미지 + 트레일러 정보 + 추가 줄거리
  - YouTube Data API: 공식 PV/트레일러 링크 + 시청자 반응
  - Reddit API: 팬 반응/화제 댓글 (인기 서브레딧)
  환경변수: TMDB_API_KEY, YOUTUBE_API_KEY, REDDIT_CLIENT_ID, REDDIT_CLIENT_SECRET
"""

import argparse
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

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

# TMDB 이미지 베이스 URL
TMDB_IMAGE_BASE = "https://image.tmdb.org/t/p/w780"
TMDB_IMAGE_ORIGINAL = "https://image.tmdb.org/t/p/original"


# ─────────────────────────────────────────────────────────────
# 유틸리티
# ─────────────────────────────────────────────────────────────

def slugify(text: str, max_len: int = 80) -> str:
    """파일명/URL용 슬러그 생성."""
    text = re.sub(r"[^\w\s\-]", "", text)
    text = re.sub(r"[-\s]+", "-", text).strip("-")
    return text[:max_len] or "untitled"


def download_image(url: str, save_path: Path) -> bool:
    """이미지를 save_path에 다운로드. 성공 시 True 반환."""
    try:
        resp = requests.get(url, timeout=30)
        resp.raise_for_status()
        save_path.parent.mkdir(parents=True, exist_ok=True)
        save_path.write_bytes(resp.content)
        return True
    except Exception as e:
        print(f"  ⚠️  이미지 다운로드 실패 ({url}): {e}")
        return False


def get_image_extension(url: str) -> str:
    """URL에서 확장자 추출, 없으면 .jpg."""
    path = urllib.parse.urlparse(url).path
    ext = Path(path).suffix.lower()
    return ext if ext in (".jpg", ".jpeg", ".png", ".webp", ".gif") else ".jpg"


# ─────────────────────────────────────────────────────────────
# TMDB API
# ─────────────────────────────────────────────────────────────

def tmdb_search_anime(title_en: str, title_native: str = None) -> dict:
    """TMDB에서 애니메이션 검색 → 상세 정보 반환."""
    api_key = os.environ.get("TMDB_API_KEY")
    if not api_key:
        return {}

    search_titles = [t for t in [title_en, title_native] if t]
    for search_query in search_titles:
        try:
            # TV 시리즈 검색 (애니는 대부분 TV)
            url = (
                f"https://api.themoviedb.org/3/search/tv"
                f"?api_key={api_key}&query={urllib.parse.quote(search_query)}&language=ko-KR"
            )
            resp = requests.get(url, timeout=10)
            resp.raise_for_status()
            results = resp.json().get("results", [])
            if not results:
                continue

            # 첫 번째 결과 상세 조회
            tmdb_id = results[0]["id"]
            detail_url = (
                f"https://api.themoviedb.org/3/tv/{tmdb_id}"
                f"?api_key={api_key}&language=ko-KR&append_to_response=images,videos"
            )
            detail_resp = requests.get(detail_url, timeout=10)
            detail_resp.raise_for_status()
            detail = detail_resp.json()

            # 이미지 수집 (포스터 + 백드롭)
            images_data = detail.get("images", {})
            posters = images_data.get("posters", [])[:5]
            backdrops = images_data.get("backdrops", [])[:5]

            # 트레일러 수집
            videos = detail.get("videos", {}).get("results", [])
            trailers = [v for v in videos if v.get("type") in ("Trailer", "Teaser")][:3]

            return {
                "tmdb_id": tmdb_id,
                "overview_ko": detail.get("overview", ""),
                "vote_average": detail.get("vote_average", 0),
                "vote_count": detail.get("vote_count", 0),
                "first_air_date": detail.get("first_air_date", ""),
                "networks": [n.get("name") for n in detail.get("networks", [])],
                "poster_path": detail.get("poster_path", ""),
                "backdrop_paths": [b["file_path"] for b in backdrops if b.get("file_path")],
                "poster_paths": [p["file_path"] for p in posters if p.get("file_path")],
                "trailers": [
                    {"key": t["key"], "name": t["name"], "site": t["site"]}
                    for t in trailers
                ],
            }
        except Exception as e:
            print(f"  ⚠️  TMDB 검색 실패 ({search_query}): {e}")
            continue
    return {}


# ─────────────────────────────────────────────────────────────
# AniList 추가 데이터 (캐릭터, 성우, 관련 작품)
# ─────────────────────────────────────────────────────────────

def anilist_get_details(anime_id: int) -> dict:
    """AniList GraphQL로 상세 정보 조회 (캐릭터, 성우, 스태프, 관련 작품)."""
    query = """
    query ($id: Int) {
      Media(id: $id, type: ANIME) {
        id
        title { romaji english native }
        studios(isMain: true) { nodes { name } }
        staff(perPage: 5, sort: [RELEVANCE]) {
          nodes {
            name { full native }
            primaryOccupations
          }
        }
        characters(perPage: 6, sort: [ROLE, RELEVANCE]) {
          nodes {
            name { full native }
            description
            image { medium }
          }
          edges {
            role
            voiceActors(language: JAPANESE) {
              name { full native }
            }
          }
        }
        relations {
          nodes {
            id title { romaji english }
            type format status
          }
          edges { relationType }
        }
        recommendations(perPage: 3) {
          nodes {
            mediaRecommendation {
              title { romaji english }
              averageScore
            }
          }
        }
        tags { name rank isMediaSpoiler }
        trailer { id site }
        externalLinks { url site }
      }
    }
    """
    try:
        resp = requests.post(
            "https://graphql.anilist.co",
            json={"query": query, "variables": {"id": anime_id}},
            headers={"Content-Type": "application/json"},
            timeout=15,
        )
        resp.raise_for_status()
        data = resp.json()
        media = data.get("data", {}).get("Media", {})
        if not media:
            return {}

        # 스튜디오
        studios = [s["name"] for s in media.get("studios", {}).get("nodes", [])]

        # 스태프 (감독 등)
        staff = []
        for s in media.get("staff", {}).get("nodes", []):
            staff.append({
                "name": s.get("name", {}).get("full", ""),
                "role": ", ".join(s.get("primaryOccupations", [])[:2]),
            })

        # 캐릭터 & 성우
        char_nodes = media.get("characters", {}).get("nodes", [])
        char_edges = media.get("characters", {}).get("edges", [])
        characters = []
        for node, edge in zip(char_nodes, char_edges):
            va_list = edge.get("voiceActors", [])
            va_name = va_list[0]["name"]["full"] if va_list else ""
            characters.append({
                "name": node.get("name", {}).get("full", ""),
                "name_native": node.get("name", {}).get("native", ""),
                "role": edge.get("role", ""),
                "voice_actor": va_name,
                "image": node.get("image", {}).get("medium", ""),
            })

        # 관련 작품
        rel_nodes = media.get("relations", {}).get("nodes", [])
        rel_edges = media.get("relations", {}).get("edges", [])
        relations = []
        for node, edge in zip(rel_nodes, rel_edges):
            relations.append({
                "title": node.get("title", {}).get("romaji", ""),
                "relation": edge.get("relationType", ""),
                "format": node.get("format", ""),
            })

        # 추천 작품
        recs = []
        for r in media.get("recommendations", {}).get("nodes", []):
            mr = r.get("mediaRecommendation", {})
            if mr:
                recs.append({
                    "title": mr.get("title", {}).get("romaji", ""),
                    "score": mr.get("averageScore", 0),
                })

        # 태그 (스포일러 제외, 상위 8개)
        tags = [
            t["name"] for t in media.get("tags", [])
            if not t.get("isMediaSpoiler") and t.get("rank", 0) >= 60
        ][:8]

        # 트레일러
        trailer = media.get("trailer")
        trailer_url = ""
        if trailer:
            if trailer.get("site") == "youtube":
                trailer_url = f"https://www.youtube.com/watch?v={trailer['id']}"

        # 외부 링크
        ext_links = {
            link["site"]: link["url"]
            for link in media.get("externalLinks", [])
            if link.get("site") in ("Crunchyroll", "Netflix", "Amazon Prime Video", "Funimation", "Bilibili")
        }

        return {
            "studios": studios,
            "staff": staff,
            "characters": characters,
            "relations": relations,
            "recommendations": recs,
            "tags": tags,
            "trailer_url": trailer_url,
            "streaming": ext_links,
        }
    except Exception as e:
        print(f"  ⚠️  AniList 상세 조회 실패: {e}")
        return {}


# ─────────────────────────────────────────────────────────────
# YouTube Data API
# ─────────────────────────────────────────────────────────────

def youtube_search_pv(title_en: str, title_native: str = None) -> list[dict]:
    """YouTube에서 공식 PV/트레일러 검색."""
    api_key = os.environ.get("YOUTUBE_API_KEY")
    if not api_key:
        return []

    search_queries = []
    if title_en:
        search_queries.append(f"{title_en} official trailer PV")
    if title_native:
        search_queries.append(f"{title_native} PV 公式")

    results = []
    for query in search_queries[:1]:  # 첫 번째 쿼리만 사용 (API 쿼터 절약)
        try:
            url = (
                f"https://www.googleapis.com/youtube/v3/search"
                f"?key={api_key}&q={urllib.parse.quote(query)}&part=snippet"
                f"&type=video&maxResults=3&order=relevance&videoDuration=short"
            )
            resp = requests.get(url, timeout=10)
            resp.raise_for_status()
            items = resp.json().get("items", [])
            for item in items:
                vid_id = item.get("id", {}).get("videoId", "")
                snippet = item.get("snippet", {})
                if vid_id:
                    results.append({
                        "video_id": vid_id,
                        "title": snippet.get("title", ""),
                        "channel": snippet.get("channelTitle", ""),
                        "url": f"https://www.youtube.com/watch?v={vid_id}",
                        "thumbnail": snippet.get("thumbnails", {}).get("high", {}).get("url", ""),
                    })
            if results:
                break
        except Exception as e:
            print(f"  ⚠️  YouTube 검색 실패 ({query}): {e}")
    return results


# ─────────────────────────────────────────────────────────────
# Reddit API
# ─────────────────────────────────────────────────────────────

def reddit_get_discussions(title_en: str, title_native: str = None) -> list[dict]:
    """Reddit에서 해당 애니메이션 관련 인기 글 수집."""
    client_id = os.environ.get("REDDIT_CLIENT_ID")
    client_secret = os.environ.get("REDDIT_CLIENT_SECRET")

    subreddits = ["anime", "Animesuggest", "anime_titties"]  # 주요 애니 서브레딧

    headers = {"User-Agent": "GeekBrox/1.0 (blog automation)"}

    # 인증 없이 공개 API 사용 (read-only)
    results = []
    search_query = title_en or title_native or ""
    if not search_query:
        return []

    try:
        # r/anime 에서 검색
        url = (
            f"https://www.reddit.com/r/anime/search.json"
            f"?q={urllib.parse.quote(search_query)}&sort=top&limit=5&t=year&restrict_sr=1"
        )
        resp = requests.get(url, headers=headers, timeout=10)
        resp.raise_for_status()
        posts = resp.json().get("data", {}).get("children", [])
        for post in posts[:3]:
            data = post.get("data", {})
            score = data.get("score", 0)
            if score < 100:  # 최소 upvote 필터
                continue
            results.append({
                "title": data.get("title", ""),
                "score": score,
                "url": f"https://reddit.com{data.get('permalink', '')}",
                "num_comments": data.get("num_comments", 0),
                "selftext": data.get("selftext", "")[:300],  # 본문 300자
            })
    except Exception as e:
        print(f"  ⚠️  Reddit 검색 실패: {e}")

    return results


# ─────────────────────────────────────────────────────────────
# 멀티소스 이미지 수집
# ─────────────────────────────────────────────────────────────

def collect_images(anime: dict, tmdb_data: dict, anilist_details: dict, slug: str) -> dict:
    """
    총 5개 이미지 수집:
    1. 커버 이미지 (AniList, 글 상단)
    2. TMDB 포스터 (기본 정보 섹션)
    3. TMDB 스틸컷 1 (스토리 섹션)
    4. TMDB 스틸컷 2 (볼거리 섹션)
    5. TMDB 포스터 or AniList 커버 변형 (마무리 직전)
    반환: {image_key: relative_path}
    """
    IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    paths = {}

    # 1. 커버 이미지 (AniList)
    cover_url = anime.get("cover_image_url", "")
    if cover_url:
        ext = get_image_extension(cover_url)
        cover_path = IMAGES_DIR / f"{slug}_cover{ext}"
        if download_image(cover_url, cover_path):
            paths["cover"] = f"../images/{slug}_cover{ext}"

    # TMDB 이미지 처리
    backdrop_paths = tmdb_data.get("backdrop_paths", [])
    poster_paths = tmdb_data.get("poster_paths", [])

    # 2. TMDB 포스터 (기본 정보용)
    if poster_paths:
        poster_url = TMDB_IMAGE_BASE + poster_paths[0]
        poster_path = IMAGES_DIR / f"{slug}_poster.jpg"
        if download_image(poster_url, poster_path):
            paths["poster"] = f"../images/{slug}_poster.jpg"
    elif cover_url:
        # TMDB 없으면 AniList 커버 재사용
        paths["poster"] = paths.get("cover", "")

    # 3. TMDB 스틸컷 1 (스토리용)
    if len(backdrop_paths) >= 1:
        still1_url = TMDB_IMAGE_BASE + backdrop_paths[0]
        still1_path = IMAGES_DIR / f"{slug}_still1.jpg"
        if download_image(still1_url, still1_path):
            paths["still1"] = f"../images/{slug}_still1.jpg"

    # 4. TMDB 스틸컷 2 (볼거리용)
    if len(backdrop_paths) >= 2:
        still2_url = TMDB_IMAGE_BASE + backdrop_paths[1]
        still2_path = IMAGES_DIR / f"{slug}_still2.jpg"
        if download_image(still2_url, still2_path):
            paths["still2"] = f"../images/{slug}_still2.jpg"
    elif len(backdrop_paths) == 1:
        paths["still2"] = paths.get("still1", "")

    # 5. 마무리 직전 이미지 (TMDB 3번째 스틸컷 or 대체)
    if len(backdrop_paths) >= 3:
        still3_url = TMDB_IMAGE_BASE + backdrop_paths[2]
        still3_path = IMAGES_DIR / f"{slug}_still3.jpg"
        if download_image(still3_url, still3_path):
            paths["still3"] = f"../images/{slug}_still3.jpg"
    elif poster_paths and len(poster_paths) >= 2:
        alt_poster_url = TMDB_IMAGE_BASE + poster_paths[1]
        alt_path = IMAGES_DIR / f"{slug}_poster2.jpg"
        if download_image(alt_poster_url, alt_path):
            paths["still3"] = f"../images/{slug}_poster2.jpg"
    else:
        paths["still3"] = paths.get("poster", paths.get("cover", ""))

    return paths


# ─────────────────────────────────────────────────────────────
# LLM 헬퍼
# ─────────────────────────────────────────────────────────────

def _is_rate_limit_error(e: Exception) -> bool:
    msg = str(e).lower()
    return any(kw in msg for kw in ("rate_limit", "rate limit", "429", "too many requests", "overloaded"))


def _call_gemini(prompt: str, max_tokens: int = 8192) -> str:
    gemini_key = os.environ.get("GOOGLE_API_KEY")
    if not gemini_key:
        raise RuntimeError(
            "GOOGLE_API_KEY 환경변수가 없습니다. .env에 추가하거나 Google AI Studio에서 발급하세요.\n"
            "발급: https://aistudio.google.com/apikey"
        )
    try:
        from google import genai
        from google.genai import types
        client = genai.Client(api_key=gemini_key)
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=prompt,
            config=types.GenerateContentConfig(max_output_tokens=max_tokens),
        )
        return response.text
    except Exception as e:
        raise RuntimeError(f"Gemini API 호출 실패: {e}") from e


def _call_llm(prompt: str, max_tokens: int = 8192) -> str:
    """Claude → Gemini fallback."""
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if api_key:
        try:
            client = Anthropic(api_key=api_key)
            message = client.messages.create(
                model="claude-sonnet-4-5-20250929",
                max_tokens=max_tokens,
                messages=[{"role": "user", "content": prompt}],
            )
            block = message.content[0]
            if block.type != "text":
                raise RuntimeError(f"Claude API 비텍스트 응답: {block.type}")
            return block.text
        except Exception as e:
            if _is_rate_limit_error(e):
                print("  ⚠️  Claude rate limit → Gemini fallback으로 전환합니다.")
            else:
                raise RuntimeError(f"Claude API 호출 실패: {e}") from e
    else:
        print("  ⚠️  ANTHROPIC_API_KEY 없음 → Gemini fallback으로 전환합니다.")

    print("  🤖 Gemini 2.5 Flash 호출 중...")
    text = _call_gemini(prompt, max_tokens=max_tokens)
    print("  ✅ Gemini fallback 성공")
    return text


# ─────────────────────────────────────────────────────────────
# 블로그 글 생성 (확장 버전)
# ─────────────────────────────────────────────────────────────

def generate_blog_draft(
    anime: dict,
    season_label: str,
    image_paths: dict,
    anilist_details: dict,
    tmdb_data: dict,
    youtube_data: list,
    reddit_data: list,
) -> str:
    """
    다중 API 데이터를 통합한 고품질 한국어 블로그 글 생성.
    이미지 5개 삽입 구조:
      - 글 상단: cover
      - 기본 정보 직후: poster
      - 스토리 소개 직후: still1
      - 볼거리/포인트 직후: still2
      - 총평 직전: still3
    """
    title_display = (
        anime.get("title_korean")
        or anime.get("title_english")
        or anime.get("title_native")
        or "제목 없음"
    )
    title_en = anime.get("title_english") or anime.get("title_native") or ""
    post_title = f"[{season_label} 애니] {title_display} - 정보 & 리뷰"

    # 이미지 경로
    img_cover  = image_paths.get("cover", "")
    img_poster = image_paths.get("poster", "")
    img_still1 = image_paths.get("still1", "")
    img_still2 = image_paths.get("still2", "")
    img_still3 = image_paths.get("still3", "")

    # AniList 추가 정보 포맷
    studios_str  = ", ".join(anilist_details.get("studios", [])) or "정보 없음"
    staff_str = "\n".join(
        f"- {s['name']} ({s['role']})" for s in anilist_details.get("staff", [])
    ) or "정보 없음"
    chars_str = "\n".join(
        f"- {c['name']} ({c['name_native']}) — CV: {c['voice_actor']} [{c['role']}]"
        for c in anilist_details.get("characters", [])
    ) or "정보 없음"
    tags_str = ", ".join(anilist_details.get("tags", [])) or ""
    trailer_url = anilist_details.get("trailer_url", "")
    streaming_str = "\n".join(
        f"- {site}: {url}" for site, url in anilist_details.get("streaming", {}).items()
    ) or ""
    recs_str = "\n".join(
        f"- {r['title']} (AniList {r['score']}/100)"
        for r in anilist_details.get("recommendations", [])
    ) or ""

    # TMDB 추가 정보
    tmdb_overview  = tmdb_data.get("overview_ko", "")
    tmdb_vote      = tmdb_data.get("vote_average", 0)
    tmdb_vote_cnt  = tmdb_data.get("vote_count", 0)
    tmdb_air_date  = tmdb_data.get("first_air_date", "")
    tmdb_networks  = ", ".join(tmdb_data.get("networks", [])) or ""
    tmdb_trailers  = tmdb_data.get("trailers", [])
    trailer_yt_str = ""
    if tmdb_trailers:
        for t in tmdb_trailers:
            if t.get("site") == "YouTube":
                trailer_yt_str = f"https://www.youtube.com/watch?v={t['key']}"
                break

    # YouTube PV 정보
    yt_pv_str = ""
    if youtube_data:
        pv = youtube_data[0]
        yt_pv_str = f"- [{pv['title']}]({pv['url']}) (채널: {pv['channel']})"

    # Reddit 반응
    reddit_str = ""
    if reddit_data:
        reddit_str = "\n".join(
            f"- r/anime 인기 글: \"{post['title']}\" (👍 {post['score']}, 💬 {post['num_comments']}개 댓글)"
            for post in reddit_data[:2]
        )

    # 이미지 마크다운 헬퍼
    def img_md(path: str, alt: str) -> str:
        if not path:
            return ""
        return f"![{alt}]({path})\n\n"

    # 이미지 경로 정보를 프롬프트에 전달
    cover_md  = img_md(img_cover,  "커버 이미지")
    poster_md = img_md(img_poster, f"{title_display} 포스터")
    still1_md = img_md(img_still1, f"{title_display} 스틸컷 1")
    still2_md = img_md(img_still2, f"{title_display} 스틸컷 2")
    still3_md = img_md(img_still3, f"{title_display} 스틸컷 3")

    prompt = f"""다음 애니메이션에 대한 **심층 한국어 블로그 글**을 작성해 주세요.
기존 단순 소개 글보다 3~4배 많은 분량으로, 팬들이 정말 읽고 싶어 하는 깊이 있는 정보와 분석을 담아야 합니다.

---

## 블로그 글 형식 & 이미지 배치 규칙

**이미지는 반드시 아래 순서와 위치에 정확히 삽입하세요 (경로 변경 금지):**

1. **글 맨 첫 줄**: `# 제목` 바로 다음 줄
{cover_md if cover_md else "(커버 이미지 없음)"}

2. **기본 정보 섹션 직후**:
{poster_md if poster_md else "(포스터 이미지 없음)"}

3. **스토리 소개 섹션 직후**:
{still1_md if still1_md else "(스틸컷 1 없음)"}

4. **볼거리/포인트 섹션 직후**:
{still2_md if still2_md else "(스틸컷 2 없음)"}

5. **총평 섹션 바로 직전**:
{still3_md if still3_md else "(스틸컷 3 없음)"}

---

## 작품 기본 정보
- **제목(한)**: {anime.get("title_korean") or "-"}
- **제목(영)**: {anime.get("title_english") or "-"}
- **제목(일)**: {anime.get("title_native") or "-"}
- **장르**: {", ".join(anime.get("genres") or [])}
- **태그**: {tags_str}
- **제작사**: {studios_str}
- **방영일**: {tmdb_air_date or "2026년 방영"}
- **방영국**: {tmdb_networks or "일본"}
- **AniList 평점**: {anime.get("average_score") or "-"}/100
- **TMDB 평점**: {f"{tmdb_vote:.1f}/10 ({tmdb_vote_cnt:,}명 평가)" if tmdb_vote else "정보 없음"}

## 줄거리 (AniList)
{anime.get("synopsis") or "-"}

## 줄거리 (TMDB 한국어)
{tmdb_overview or "(TMDB 한국어 정보 없음)"}

## 주요 스태프
{staff_str}

## 주요 캐릭터 & 성우
{chars_str}

## 관련 작품
{chr(10).join(f"- {r['title']} ({r['relation']}, {r['format']})" for r in anilist_details.get("relations", [])) or "없음"}

## 비슷한 추천 작품
{recs_str or "없음"}

## 스트리밍 서비스
{streaming_str or "정보 없음"}

## 공식 트레일러
{trailer_url or trailer_yt_str or "(없음)"}

## YouTube PV
{yt_pv_str or "(없음)"}

## Reddit 팬 반응 (r/anime)
{reddit_str or "(Reddit 데이터 없음)"}

---

## 작성 요청 사항

아래 구조로 **풍부하고 깊이 있는** 블로그 글을 작성하세요:

```
# {post_title}

[커버 이미지: {cover_md.strip() if cover_md else "없음"}]

## 💡 도입부 (2~3 문단)
- 이 작품이 왜 지금 화제인지, 무엇이 특별한지
- 독자의 흥미를 자극하는 훅(Hook) 문장
- 핵심 매력 한 줄 요약

## 📋 기본 정보
- 제목, 장르, 제작사, 방영일, 시즌/에피소드 정보
- AniList/TMDB 평점 비교
- 스트리밍 서비스 안내

[포스터 이미지: {poster_md.strip() if poster_md else "없음"}]

## 📖 스토리 소개 (3~4 문단, 스포일러 없이)
- 세계관 설명 (3~5문장)
- 주인공 소개 + 핵심 갈등
- 이전 시즌/원작과의 연결 (해당 시)
- 이번 시즌/파트만의 새로운 요소

[스틸컷 1: {still1_md.strip() if still1_md else "없음"}]

## 🎬 주요 캐릭터 & 성우진
- 주인공과 주요 등장인물 소개 (3~5명)
- 각 캐릭터의 역할과 매력 포인트
- 성우 정보 + 다른 대표작

## ✨ 이 작품의 볼거리 3가지
각 항목마다 2~3문장으로 구체적으로 서술

[스틸컷 2: {still2_md.strip() if still2_md else "없음"}]

## 🌐 해외 팬 반응
- Reddit r/anime 주요 반응 요약
- 글로벌 평점 해석 (TMDB {tmdb_vote:.1f}/10, AniList {anime.get("average_score", 0)}/100)
- 어떤 층에서 특히 인기인지

## 🎯 이런 분께 추천합니다
- 추천 대상 3~4가지 (예: ○○○을 좋아하신다면)
- 비슷한 추천 애니 2~3개 + 간단한 이유

[스틸컷 3: {still3_md.strip() if still3_md else "없음"}]

## ⭐ 총평
- 이 작품의 강점과 약점 솔직하게
- 현 시점 평점 및 이유
- 한 줄 추천 멘트

---
해시태그 (10~15개)
```

## 주의사항
- 반드시 **마크다운만** 출력 (코드 블록 래핑 없이 본문만)
- 이미지 경로는 위 지정된 것 **그대로** 사용 (절대 변경 금지)
- 총평 섹션에는 반드시 별점 (예: ⭐⭐⭐⭐☆ 4/5)을 포함
- 스포일러 금지 (결말, 반전 등)
- 합니다체 사용, 이모지 적절히 활용
- 전체 분량: **최소 2,000자 이상** (기존 글의 3~4배)
"""

    return _call_llm(prompt, max_tokens=8192)


# ─────────────────────────────────────────────────────────────
# 수정 모드
# ─────────────────────────────────────────────────────────────

def revise_blog_draft(file_path: Path, instruction: str) -> str:
    """기존 블로그 글(.md) 내용을 instruction에 맞게 수정한 본문 반환."""
    raw = file_path.read_text(encoding="utf-8")
    prompt = f"""다음은 블로그 글 마크다운 원문입니다. 사용자 지시에 맞게 **수정한 전체 글**만 출력하세요.
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

    return _call_llm(prompt, max_tokens=8192).strip()


# ─────────────────────────────────────────────────────────────
# 데이터 로드
# ─────────────────────────────────────────────────────────────

def load_anime_list() -> tuple[str, int, list]:
    """seasonal_top_anime.json 로드."""
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


# ─────────────────────────────────────────────────────────────
# 메인
# ─────────────────────────────────────────────────────────────

def main() -> None:
    try:
        season_label, _year, anime_list = load_anime_list()
    except (FileNotFoundError, RuntimeError) as e:
        print(f"오류: {e}")
        raise

    IMAGES_DIR.mkdir(parents=True, exist_ok=True)
    POSTS_DIR.mkdir(parents=True, exist_ok=True)

    # API 키 현황 출력
    has_tmdb    = bool(os.environ.get("TMDB_API_KEY"))
    has_youtube = bool(os.environ.get("YOUTUBE_API_KEY"))
    has_reddit  = bool(os.environ.get("REDDIT_CLIENT_ID"))
    print(f"📡 API 현황: TMDB={'✅' if has_tmdb else '❌'} | YouTube={'✅' if has_youtube else '❌'} | Reddit={'✅' if has_reddit else '❌(공개API사용)'}")
    print()

    for i, anime in enumerate(anime_list, start=1):
        title_display = (
            anime.get("title_korean")
            or anime.get("title_english")
            or anime.get("title_native")
            or "제목없음"
        )
        title_en = anime.get("title_english") or anime.get("title_native") or ""
        title_native = anime.get("title_native") or ""
        slug = slugify(title_display) or f"anime_{i}"

        print(f"[{i}/{len(anime_list)}] {title_display}")
        print(f"  🔍 다중 API 데이터 수집 중...")

        try:
            # 1. TMDB 검색
            print(f"  📽️  TMDB 조회 중...")
            tmdb_data = tmdb_search_anime(title_en, title_native)
            if tmdb_data.get("tmdb_id"):
                print(f"  ✅ TMDB: 포스터 {len(tmdb_data.get('poster_paths', []))}개, 스틸컷 {len(tmdb_data.get('backdrop_paths', []))}개")
            else:
                print(f"  ⚠️  TMDB: 결과 없음")
            time.sleep(0.3)

            # 2. AniList 상세 (anilist_id가 JSON에 없으면 건너뜀)
            anilist_details = {}
            anilist_id = anime.get("anilist_id")
            if anilist_id:
                print(f"  🎌 AniList 상세 조회 중...")
                anilist_details = anilist_get_details(anilist_id)
                print(f"  ✅ AniList: 캐릭터 {len(anilist_details.get('characters', []))}명, 태그 {len(anilist_details.get('tags', []))}개")
                time.sleep(0.5)
            else:
                print(f"  ⚠️  AniList ID 없음 — 기본 정보만 사용")

            # 3. YouTube PV 검색
            print(f"  🎬 YouTube PV 검색 중...")
            youtube_data = youtube_search_pv(title_en, title_native)
            if youtube_data:
                print(f"  ✅ YouTube: PV {len(youtube_data)}개 발견")
            else:
                print(f"  ⚠️  YouTube: 결과 없음")
            time.sleep(0.3)

            # 4. Reddit 반응
            print(f"  💬 Reddit 반응 수집 중...")
            reddit_data = reddit_get_discussions(title_en, title_native)
            if reddit_data:
                print(f"  ✅ Reddit: 인기 글 {len(reddit_data)}개")
            else:
                print(f"  ⚠️  Reddit: 결과 없음")
            time.sleep(0.3)

            # 5. 이미지 수집 (5개)
            print(f"  🖼️  이미지 수집 중 (최대 5개)...")
            image_paths = collect_images(anime, tmdb_data, anilist_details, slug)
            print(f"  ✅ 이미지: {len(image_paths)}개 수집 ({', '.join(image_paths.keys())})")

            # 6. 블로그 글 생성
            print(f"  ✍️  블로그 글 생성 중...")
            body = generate_blog_draft(
                anime=anime,
                season_label=season_label,
                image_paths=image_paths,
                anilist_details=anilist_details,
                tmdb_data=tmdb_data,
                youtube_data=youtube_data,
                reddit_data=reddit_data,
            )

            # 7. 저장
            post_filename = f"{slug}.md"
            post_path = POSTS_DIR / post_filename
            post_path.write_text(body.strip(), encoding="utf-8")
            word_count = len(body.replace(" ", ""))
            print(f"  ✅ 저장 완료: {post_path} ({word_count:,}자)")

        except Exception as e:
            print(f"  ❌ 실패: {e}")
            raise

        print()

    print(f"🎉 완료: {len(anime_list)}개 글 생성")
    print(f"   이미지: {IMAGES_DIR}")
    print(f"   글: {POSTS_DIR}")


def run_revise_mode(revise_path: Path, instruction: str) -> None:
    """--revise <파일> --instruction <지시> 모드."""
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
        "--revise", type=Path, metavar="PATH",
        help="수정할 .md 파일 경로 (--instruction과 함께 사용)",
    )
    parser.add_argument(
        "--instruction", type=str, default="", metavar="TEXT",
        help="수정 지시문 (--revise와 함께 사용)",
    )
    args = parser.parse_args()

    if args.revise is not None:
        run_revise_mode(args.revise, args.instruction or "")
    else:
        main()
