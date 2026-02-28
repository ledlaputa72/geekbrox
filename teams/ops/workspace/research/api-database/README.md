# API Database (유용한 Data API 100)

**작성일:** 2026-02-20  
**작성자:** Atlas (PM)  
**출처:** [Google Sheets](https://docs.google.com/spreadsheets/d/10j9ok32qJE3e1-IoBaN-Lc3phz3-HEFK8XyOIcxmD8I/edit?usp=sharing)

---

## 📋 개요

이 디렉토리는 콘텐츠 제작 및 게임 개발에 참고할 수 있는 **유용한 Data API 100개**의 데이터베이스입니다.

각 API는 다음 정보를 포함합니다:
- **순위:** 1-100
- **API 이름:** 서비스 이름
- **카테고리:** 분류 (예: AI/LLM, 게임, 음악, 위치 등)
- **특징:** 핵심 데이터 및 기능
- **아이디어:** 엔터테인먼트/페르소나 매시업 활용 아이디어
- **공식 링크:** API 문서 URL

---

## 📁 파일 구조

```
api-database/
├── README.md                  # 이 파일
├── API_DATABASE.md            # Markdown 형식 (사람이 읽기 쉬움)
├── api_database.json          # JSON 형식 (프로그래밍 용도)
└── parse_api_data.py          # 데이터 파싱 스크립트
```

---

## 📖 사용법

### 1. Markdown 파일 읽기 (추천)
```bash
open ~/Projects/geekbrox/teams/ops/workspace/research/api-database/API_DATABASE.md
```

카테고리별로 정리되어 있어 원하는 API를 쉽게 찾을 수 있습니다.

### 2. JSON 파일 프로그래밍 사용
```python
import json

with open('api_database.json', 'r', encoding='utf-8') as f:
    apis = json.load(f)

# 카테고리별 필터링
gaming_apis = [api for api in apis if '게임' in api['category']]

# 특정 API 검색
spotify = [api for api in apis if 'Spotify' in api['api_name']]
```

---

## 🎮 게임 개발 활용 아이디어

### 1. **꿈 수집가 (Dream Collector)**
- **Spotify API:** 플레이어의 음악 취향을 기반으로 꿈의 세계 BGM 자동 생성
- **OpenWeather API:** 현실 날씨를 꿈의 세계 분위기와 연동
- **NASA API:** 플레이어 생일에 맞는 우주 이미지를 꿈 배경으로 사용
- **Fitbit API:** 수면 데이터를 기반으로 "오늘의 꿈 난이도" 조정

### 2. **던전 기생충 (Dungeon Parasite)**
- **Marvel API:** 기생 가능한 몬스터를 마블 히어로 스타일로 디자인
- **PokéAPI:** 몬스터 스탯을 포켓몬 시스템 참고하여 밸런싱
- **RAWG API:** 유사 게임 메타데이터로 플레이어 성향 분석
- **Discord API:** 커뮤니티 활동 기반 "기생체 진화 트리" 해금

---

## 📝 콘텐츠 제작 활용 아이디어

### 블로그 자동화
- **TMDB API:** 애니메이션 시즌 정보 자동 업데이트
- **AniList API:** 애니메이션 캐릭터/성우 상세 정보
- **News API:** 게임 업계 뉴스 자동 큐레이션
- **Reddit API:** 커뮤니티 트렌드 분석하여 인기 주제 선정

### 유튜브 콘텐츠
- **YouTube API:** 알고리즘 분석 및 트렌드 파악
- **Genius API:** 음악 가사 해석 콘텐츠
- **Unsplash API:** 고해상도 썸네일 이미지 자동 생성
- **Giphy API:** 영상 내 리액션 짤방 자동 삽입

---

## 🔍 카테고리별 API 수

| 카테고리 | 개수 |
|---------|------|
| 게임 | 5개 |
| 금융 | 8개 |
| 기상/환경 | 7개 |
| 기술 | 5개 |
| 미디어 | 12개 |
| 문화 | 3개 |
| 위치 | 6개 |
| 음악 | 4개 |
| 이미지 | 4개 |
| 언어 | 4개 |
| 여행 | 5개 |
| 예술 | 4개 |
| 운동/건강 | 5개 |
| 자동화 | 2개 |
| 천문 | 3개 |
| 통신 | 4개 |
| 푸드 | 3개 |
| 기타 | 18개 |

**총 98개 API** (2개 파싱 실패)

---

## 🚀 다음 단계

### 단기 (1-2주)
- [ ] 게임 개발에 필수적인 상위 10개 API 테스트
- [ ] 블로그 자동화에 사용할 API 5개 선정
- [ ] API 인증 키 발급 (무료 티어 확인)

### 중기 (1-3개월)
- [ ] 꿈 수집가에 통합할 API 2-3개 프로토타입
- [ ] 콘텐츠 자동 생성 파이프라인에 API 통합
- [ ] API 사용량 모니터링 대시보드 구축

### 장기 (6개월+)
- [ ] 독자적인 API 조합으로 "페르소나 매시업" 서비스 개발
- [ ] API 데이터 기반 AI 에이전트 학습
- [ ] 커뮤니티와 API 활용 사례 공유

---

## 📌 주의사항

### API 사용 전 확인
1. **무료 티어 제한:** 대부분 API는 무료 사용량 제한이 있음
2. **인증 방식:** API Key, OAuth, JWT 등 다양 (문서 확인 필수)
3. **Rate Limiting:** 초당/일당 요청 제한 확인
4. **데이터 저작권:** 일부 API는 상업적 사용 제한
5. **GDPR/개인정보:** 유저 데이터 수집 시 법적 검토

### 추천 API (우선순위)

#### 게임 개발 필수
1. **OpenAI API** - AI 대화, 스토리 생성
2. **Spotify API** - 음악 기반 게임 메카닉
3. **PokéAPI** - 캐릭터 밸런싱 참고
4. **OpenWeather API** - 현실 날씨 연동
5. **Discord API** - 커뮤니티 통합

#### 콘텐츠 제작 필수
1. **YouTube API** - 영상 메타데이터
2. **TMDB / AniList API** - 애니/영화 정보
3. **Unsplash API** - 썸네일 이미지
4. **Giphy API** - 짤방 자동 삽입
5. **News API** - 자동 뉴스 큐레이션

---

## 🔗 관련 링크

- **원본 Google Sheets:** [링크](https://docs.google.com/spreadsheets/d/10j9ok32qJE3e1-IoBaN-Lc3phz3-HEFK8XyOIcxmD8I/edit?usp=sharing)
- **GeekBrox 프로젝트:** `~/Projects/geekbrox`
- **Notion (예정):** 데이터베이스 형태로 Notion에도 업로드 예정

---

_Maintained by Atlas | Last updated: 2026-02-20_
