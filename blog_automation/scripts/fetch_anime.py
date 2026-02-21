"""
AniList GraphQL API로 현재 시즌 인기 애니 Top 10 수집
MAL API로 평점/순위 병합
결과를 JSON으로 output 폴더에 저장
"""

import json
import os
import re
import time
from datetime import datetime
from pathlib import Path

import requests
from dotenv import load_dotenv

load_dotenv()

ANILIST_GRAPHQL_URL = "https://graphql.anilist.co"
MAL_API_URL = "https://api.myanimelist.net/v2"
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
    """synonyms 중 한글이 포함된 항목이 있으면 반환."""
    if not synonyms:
        return None
    hangul = re.compile(r"[\uAC00-\uD7A3]+")
    for s in synonyms:
        if s and hangul.search(s):
            return s.strip()
    return None


# ─────────────────────────────────────────────────────────────
# AniList
# ─────────────────────────────────────────────────────────────

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
          idMal
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
            "anilist_id": m.get("id"),       # AniList ID (상세 조회용)
            "mal_id": m.get("idMal"),         # MAL ID (MAL API 조회용)
            "title_korean": extract_korean_from_synonyms(m.get("synonyms")),
            "title_english": title.get("english") or title.get("romaji"),
            "title_native": title.get("native"),
            "genres": m.get("genres") or [],
            "synopsis": desc,
            "average_score": m.get("averageScore"),  # AniList 점수 (0~100)
            "cover_image_url": cover_url,
            # MAL 데이터 (아래에서 병합)
            "mal_score": None,       # MAL 평점 (0~10)
            "mal_rank": None,        # MAL 전체 순위
            "mal_popularity": None,  # MAL 인기 순위
            "mal_members": None,     # MAL 멤버 수
            "mal_synopsis": None,    # MAL 영문 줄거리
        })
    return result


# ─────────────────────────────────────────────────────────────
# MAL API
# ─────────────────────────────────────────────────────────────

def fetch_mal_detail(mal_id: int) -> dict:
    """MAL API로 애니메이션 상세 정보 조회."""
    client_id = os.environ.get("MAL_CLIENT_ID")
    if not client_id:
        return {}
    if not mal_id:
        return {}

    try:
        url = (
            f"{MAL_API_URL}/anime/{mal_id}"
            f"?fields=id,title,mean,rank,popularity,num_list_users,synopsis,status,num_episodes"
        )
        resp = requests.get(
            url,
            headers={"X-MAL-CLIENT-ID": client_id},
            timeout=10,
        )
        resp.raise_for_status()
        data = resp.json()
        return {
            "mal_score":      data.get("mean"),           # 예: 8.45
            "mal_rank":       data.get("rank"),            # 예: 123
            "mal_popularity": data.get("popularity"),      # 예: 456
            "mal_members":    data.get("num_list_users"),  # 예: 1234567
            "mal_synopsis":   data.get("synopsis", ""),
            "mal_episodes":   data.get("num_episodes"),
            "mal_status":     data.get("status"),          # currently_airing 등
        }
    except requests.HTTPError as e:
        if e.response.status_code == 404:
            print(f"  ⚠️  MAL ID {mal_id}: 404 Not Found")
        else:
            print(f"  ⚠️  MAL API 오류 (ID {mal_id}): {e}")
        return {}
    except Exception as e:
        print(f"  ⚠️  MAL API 오류 (ID {mal_id}): {e}")
        return {}


def enrich_with_mal(anime_list: list[dict]) -> list[dict]:
    """anime_list 각 항목에 MAL 데이터를 병합."""
    client_id = os.environ.get("MAL_CLIENT_ID")
    if not client_id:
        print("  ⚠️  MAL_CLIENT_ID 없음 — MAL 데이터 스킵")
        return anime_list

    print(f"  🔗 MAL API 병합 시작 ({len(anime_list)}편)...")
    for i, anime in enumerate(anime_list):
        mal_id = anime.get("mal_id")
        title = anime.get("title_english") or anime.get("title_native") or "?"
        if not mal_id:
            print(f"  [{i+1}] {title}: MAL ID 없음 — 스킵")
            continue

        mal_data = fetch_mal_detail(mal_id)
        if mal_data:
            anime["mal_score"]      = mal_data.get("mal_score")
            anime["mal_rank"]       = mal_data.get("mal_rank")
            anime["mal_popularity"] = mal_data.get("mal_popularity")
            anime["mal_members"]    = mal_data.get("mal_members")
            anime["mal_synopsis"]   = mal_data.get("mal_synopsis")
            anime["mal_episodes"]   = mal_data.get("mal_episodes")
            anime["mal_status"]     = mal_data.get("mal_status")
            score_str = f"{mal_data['mal_score']}/10" if mal_data.get("mal_score") else "점수 없음"
            rank_str  = f"#{mal_data['mal_rank']}" if mal_data.get("mal_rank") else "순위 없음"
            print(f"  [{i+1}] {title}: MAL {score_str}, 순위 {rank_str}")
        else:
            print(f"  [{i+1}] {title}: MAL 데이터 없음")

        time.sleep(0.5)  # MAL API rate limit 방지

    return anime_list


# ─────────────────────────────────────────────────────────────
# 메인
# ─────────────────────────────────────────────────────────────

def main() -> None:
    try:
        season, year = get_current_season()
        print(f"📡 AniList 조회 중... ({year} {season})")
        anime_list = fetch_seasonal_top_anime(season, year)
        print(f"  ✅ AniList: {len(anime_list)}편 수집")

        # MAL 데이터 병합
        anime_list = enrich_with_mal(anime_list)

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
        print(f"\n✅ 저장 완료: {out_path} (총 {len(anime_list)}편)")

    except Exception as e:
        print(f"오류: {e}")
        raise


if __name__ == "__main__":
    main()
