"""
AniList GraphQL API로 현재 시즌 인기 애니 Top 10 수집
결과를 JSON으로 output 폴더에 저장
"""

import json
import re
from datetime import datetime
from pathlib import Path

import requests
from dotenv import load_dotenv

# .env 로드 (AniList는 인증 없이 사용 가능하지만, 규칙에 따라 로드)
load_dotenv()

ANILIST_GRAPHQL_URL = "https://graphql.anilist.co"
SCRIPT_DIR = Path(__file__).resolve().parent
OUTPUT_DIR = SCRIPT_DIR.parent.parent / "output"
TOP_N = 10


def get_current_season():
    """현재 월 기준 시즌(WINTER/SPRING/SUMMER/FALL)과 연도 반환."""
    now = datetime.now()
    year = now.year
    month = now.month
    if month in (12, 1, 2):
        season = "WINTER"
        if month == 12:
            year += 1
    elif month in (3, 4, 5):
        season = "SPRING"
    elif month in (6, 7, 8):
        season = "SUMMER"
    else:
        season = "FALL"
    return season, year


def extract_korean_from_synonyms(synonyms: list[str] | None) -> str | None:
    """synonyms 중 한글이 포함된 항목이 있으면 반환. AniList는 한글 제목을 공식 필드로 제공하지 않음."""
    if not synonyms:
        return None
    # 한글 음절 범위
    hangul = re.compile(r"[\uAC00-\uD7A3]+")
    for s in synonyms:
        if s and hangul.search(s):
            return s.strip()
    return None


def fetch_seasonal_top_anime(season: str, year: int) -> list[dict]:
    """AniList GraphQL로 해당 시즌 인기 애니 Top 10 조회."""
    query = """
    query ($season: MediaSeason!, $seasonYear: Int!, $perPage: Int!) {
      Page(page: 1, perPage: $perPage) {
        media(
          season: $season
          seasonYear: $seasonYear
          type: ANIME
          sort: [POPULARITY_DESC]
        ) {
          id
          title {
            romaji
            english
            native
          }
          synonyms
          description
          genres
          averageScore
          coverImage {
            extraLarge
            large
            medium
          }
        }
      }
    }
    """
    variables = {
        "season": season,
        "seasonYear": year,
        "perPage": TOP_N,
    }
    try:
        resp = requests.post(
            ANILIST_GRAPHQL_URL,
            json={"query": query, "variables": variables},
            headers={"Content-Type": "application/json"},
            timeout=15,
        )
        resp.raise_for_status()
        data = resp.json()
    except requests.RequestException as e:
        raise RuntimeError(f"AniList API 요청 실패: {e}") from e
    except json.JSONDecodeError as e:
        raise RuntimeError(f"AniList API 응답 JSON 파싱 실패: {e}") from e

    if "errors" in data:
        messages = [e.get("message", str(e)) for e in data["errors"]]
        raise RuntimeError(f"AniList GraphQL 오류: {'; '.join(messages)}")

    page = data.get("data", {}).get("Page")
    if not page:
        raise RuntimeError("AniList 응답에 Page 데이터가 없습니다.")

    media_list = page.get("media") or []
    result = []
    for m in media_list:
        title = m.get("title") or {}
        # description은 HTML일 수 있음; 줄거리로만 사용
        desc = m.get("description")
        if desc:
            desc = re.sub(r"<[^>]+>", "", desc).strip() or None
        cover = m.get("coverImage") or {}
        cover_url = (
            cover.get("extraLarge")
            or cover.get("large")
            or cover.get("medium")
        )
        result.append({
            "anilist_id": m.get("id"),  # AniList Media ID (상세 조회용)
            "title_korean": extract_korean_from_synonyms(m.get("synonyms")),
            "title_english": title.get("english") or title.get("romaji"),
            "title_native": title.get("native"),
            "genres": m.get("genres") or [],
            "synopsis": desc,
            "average_score": m.get("averageScore"),
            "cover_image_url": cover_url,
        })
    return result


def main() -> None:
    try:
        season, year = get_current_season()
        anime_list = fetch_seasonal_top_anime(season, year)
        OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
        out_path = OUTPUT_DIR / "seasonal_top_anime.json"
        payload = {
            "season": season,
            "season_year": year,
            "fetched_at": datetime.now().isoformat(),
            "count": len(anime_list),
            "anime": anime_list,
        }
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(payload, f, ensure_ascii=False, indent=2)
        print(f"저장 완료: {out_path} (총 {len(anime_list)}편)")
    except Exception as e:
        print(f"오류: {e}")
        raise


if __name__ == "__main__":
    main()
