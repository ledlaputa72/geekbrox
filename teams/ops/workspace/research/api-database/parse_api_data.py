#!/usr/bin/env python3
"""
Parse API data from Google Sheets text export
"""

import re
import json

# Raw data from web_fetch
raw_text = """1OpenAIAI/LLM텍스트/이미지 생성, 감정 분석, 추론모든 원천 데이터에 '의미'와 '인격'을 부여하는 두뇌https://platform.openai.com/
2Google Maps위치/지리실시간 위치, 장소 리뷰, 경로, 좌표유저의 이동 패턴을 분석해 '라이프 동선 페르소나' 추출https://developers.google.com/maps
3YouTube미디어시청 기록, 인기 차트, 영상 카테고리알고리즘 속에 숨겨진 유저의 '무의식적 취향' 진단https://developers.google.com/youtube
4Spotify음악청취 이력, 곡 분위기(BPM), 아티스트현재 유저의 심박수와 어울리는 '인생의 BGM' 매칭https://developer.spotify.com/
5OpenWeather기상/환경실시간 날씨, 기온, 자외선, 대기질현재 날씨를 특정 영화 장르나 필터로 변환하여 제안https://openweathermap.org/api
6TMDB영화/TV영화 상세, 배우, 장르, 평점, 포스터유저의 선호 장르 기반 '주인공 캐릭터' 정의https://www.themoviedb.org/documentation/api
7InstagramSNS피드 사진, 해시태그, 미디어 인사이트유저가 추구하는 시각적 '미학(Aesthetics)' 점수화https://developers.facebook.com/docs/instagram-api
8CoinGecko금융가상자산 실시간 시세, 변동성 지표코인 변동성과 유저의 '성격 급함 지수' 매칭https://www.coingecko.com/en/api
9NASA API우주/과학천체 사진, 행성 데이터, 화성 탐사내 생일날 우주의 모습으로 만드는 '우주 탄생 카드'https://api.nasa.gov/
10Spoonacular푸드레시피, 영양소 분석, 식재료 DB어제 먹은 음식으로 분석하는 '나의 전생 국가' 찾기https://spoonacular.com/food-api
11Alpha Vantage주식/금융주식 시세, 기술적 지표, 외환 데이터내 자산 변동 그래프를 클래식 음악 악보로 변환https://www.alphavantage.co/
12Skyscanner여행항공권 가격, 최저가 노선 검색내 예산으로 지금 당장 떠날 수 있는 '운명의 여행지'https://developers.skyscanner.net/
13Unsplash이미지고해상도 감성 사진 라이브러리유저의 텍스트 일기를 감성적인 사진 무드보드로 전환https://unsplash.com/developers
14Twitch게임실시간 방송 상태, 게임 카테고리즐겨보는 스트리머 스타일로 분석하는 '소셜 타입'https://dev.twitch.tv/docs/api/
15News API뉴스전 세계 실시간 뉴스 및 헤드라인유저가 관심 있는 뉴스를 '미래 예언서'처럼 재구성https://newsapi.org/
16PokéAPI캐릭터포켓몬 스탯, 속성, 진화 데이터유저의 신체 스탯을 포켓몬 캐릭터와 1:1 매칭https://pokeapi.co/
17Last.fm음악상세 태그, 유저별 정밀 청취 통계Spotify보다 깊은 '음악적 조예'와 '장르 편식' 진단https://www.last.fm/api
18Wikipedia지식방대한 백과사전 지식 및 역사오늘 내가 방문한 장소의 역사적 사건과 나를 연결https://www.mediawiki.org/wiki/API:Main_page
19DeepL언어고정밀 번역 및 언어 분석내가 쓴 글을 셰익스피어 스타일의 고전체로 번역https://www.deepl.com/pro-api
20AniList애니메이션애니 장르, 성우, 캐릭터 상세 정보나의 일상을 특정 애니메이션의 '에피소드'로 치환https://anilist.gitbook.io/anilist-apiv2-docs/
21Reddit커뮤니티서브레딧 트렌드, 토론 데이터유저의 관심사가 어느 커뮤니티에서 '인싸'가 될지 분석https://www.reddit.com/dev/api/
22Strava운동활동 경로, 심박수, 운동량 통계내 러닝 경로를 지도 위에 그리는 'GPS 아트' 생성https://developers.strava.com/
23Fitbit건강수면 단계, 걸음 수, 소모 칼로리어젯밤 수면 데이터를 기반으로 '오늘의 운세' 점치기https://dev.fitbit.com/build/reference/web-api/
24AirVisual환경미세먼지, 초미세먼지, 공기 질공기 질에 따라 유저의 아바타 표정이 변하는 기능https://www.iqair.com/air-pollution-data-api
25Marvel캐릭터마블 히어로 및 코믹스 시리즈 정보유저의 고민을 상담해주고 '마블 히어로'의 조언 받기https://developer.marvel.com/
26RAWG게임50만 개 이상의 게임 메타데이터유저가 플레이한 게임들로 분석하는 '나의 전략적 지능'https://rawg.io/apidocs
27Genderize예측이름 기반 성별 추측 데이터익명 유저의 이름만으로 '가상 페르소나' 자동 생성https://genderize.io/
28Open Library도서도서 정보, 작가, 출판 데이터내 책장 사진을 찍으면 분석되는 '지적 호기심' 유형https://openlibrary.org/developers/api
29ExchangeRate금융실시간 환율 정보내 월급을 100년 전 혹은 다른 나라 가치로 변환https://www.exchangerate-api.com/
30USGS Earthquake환경전 세계 실시간 지진 발생 정보내 심박수와 전 세계 지진 데이터를 매칭해 '공명 지동'https://earthquake.usgs.gov/fdsnws/event/1/
31IPStack네트워크IP 기반 위치 및 국가 정보접속하자마자 해당 국가 언어로 '환영 메시지' 출력https://ipstack.com/
32Giphy미디어움직이는 이모티콘(GIF) 검색유저의 문장 성향을 파악해 '딱 맞는 짤방' 자동 댓글https://developers.giphy.com/docs/api/
33Advice Slip라이프매일 새로운 랜덤 인생 조언오늘의 내 기분에 맞춰 'AI 현자'가 건네는 한 줄https://api.adviceslip.com/
34The Cat API동물귀여운 고양이 사진 및 품종 정보유저의 셀카를 분석해 '닮은꼴 고양이' 매칭https://thecatapi.com/
35Board Game Geek게임보드게임 순위 및 메커니즘 데이터유저의 성격에 최적화된 '보드게임 전략가' 유형https://boardgamegeek.com/wiki/page/BGG_XML_API2
36Football-Data스포츠축구 경기 결과 및 팀 스탯좋아하는 팀의 성적과 내 기분 수치를 그래프로 비교https://www.football-data.org/
37Sunrise-Sunset환경특정 지역의 일출/일몰 시간내 위치의 일몰 시간에 맞춰 앱 테마를 '황혼 모드'로https://sunrise-sunset.org/api
38Zippopotam위치우편번호 기반 정밀 위치 데이터내가 사는 동네의 라이프스타일 통계와 나를 비교http://www.zippopotam.us/
39Financial Modeling금융기업 재무제표 및 실적 데이터유저가 일하는 회사의 주가와 내 '열정 지수' 결합https://site.financialmodelingprep.com/developer/docs/
40JokeAPI유머카테고리별 랜덤 유머심각한 데이터 분석 끝에 던지는 '허무한 농담' 연출https://sv443.net/jokeapi/v2/
41OpenUV환경실시간 자외선 및 피부 보호 데이터자외선 수치에 따라 아바타가 선글라스를 쓰는 효과https://www.openuv.io/api-docs
42Numbers API데이터숫자에 얽힌 흥미로운 사실들내 생일이나 기념일 숫자의 '역사적 의미' 부여http://numbersapi.com/
43Bored API라이프심심할 때 할 수 있는 활동 추천현재 내 위치와 날씨에 딱 맞는 '심심함 탈출 미션'https://www.boredapi.com/
44StarChart천문별자리 위치 및 행성 궤도지금 내가 보고 있는 밤하늘의 '별자리 운명' 분석https://starchart.com/
45Holiday API라이프국가별 공휴일 및 기념일 정보남의 나라 휴일에 맞춰 '대리 휴식'을 권장하는 기능https://holidayapi.com/
46Tasty API푸드짧은 요리 영상, 트렌디 레시피오늘 내 스트레스 지수에 맞는 '시각적 ASMR' 요리https://tasty.co/
47Genius음악가사 해석, 아티스트 비하인드 스토리노래 가사 한 줄을 유저의 '인생 모토'로 제안https://docs.genius.com/
48Ticketmaster이벤트콘서트, 공연, 스포츠 티켓 정보내 Spotify 취향을 기반으로 한 '운명의 콘서트' 알림https://developer.ticketmaster.com/
49World Bank통계국가별 인구, 경제 지표, 환경 통계내 삶의 수치를 전 세계 통계와 비교 분석https://data.worldbank.org/
50Discord통신서버 상태, 유저 활동 정보내가 속한 커뮤니티의 활성도로 분석하는 '소속감' 지수https://discord.com/developers/docs/intro
51Steam게임보유 게임 및 플레이 시간 통계내가 보낸 '게임의 시간'을 돈으로 환산하면 얼마일까?https://developer.valvesoftware.com/wiki/Steam_Web_API
52Telegram Bot통신메시지 송수신, 유저 상태 정보내 말투를 학습해 나 대신 대답해주는 '디지털 쌍둥이'https://core.telegram.org/bots/api
53GitHub기술커밋 잔디, 사용 언어 데이터잔디' 심는 패턴으로 분석하는 유저의 '성실함 유형'https://docs.github.com/en/rest
54Pinterest이미지핀(Pin), 보드 테마 정보유저가 꿈꾸는 '이상적인 삶의 비주얼' 분석https://developers.pinterest.com/docs/api/v5/
55Tenor GIF미디어감정별 인기 짤방 검색 데이터단어 하나에 반응하는 '실시간 짤방 채팅' 시스템https://tenor.com/gifapi
56Yelp로컬지역 상점 리뷰, 평점, 가격대내 입맛과 가장 유사한 리뷰를 쓰는 '맛 동기' 찾기https://www.yelp.com/developers/documentation/v3
57TripAdvisor여행관광지 리뷰, 호텔 등급 정보가고 싶은 나라의 사진만 골라 '가상 여행 일기' 작성https://developer-tripadvisor.com/
58IEX Cloud금융실시간 주식 데이터, 시장 뉴스주식 시장의 긴박함을 액션 영화 음악으로 실시간 연주https://iexcloud.io/docs/api/
59IFTTT자동화서비스 간 연동 상태 정보\"비가 오면 자동으로 내 SNS에 감성 글을 올리기\"https://ifttt.com/docs/api_reference
60Hugging FaceAI오픈소스 AI 모델 활용어떤 데이터든 '다른 형태(음성, 이미지)'로 즉시 변환https://huggingface.co/docs/api-inference/index
61ElevenLabs음성고품질 음성 합성, 목소리 복제내 일기를 내가 좋아하는 연예인의 목소리로 읽어주기https://elevenlabs.io/api
62Stability AIAI텍스트 기반 고해상도 이미지 생성유저의 꿈 내용을 입력하면 '초현실주의 화풍' 구현https://platform.stability.ai/docs/api-reference
63Foursquare위치핫플레이스, 실시간 유동인구내가 가는 곳마다 '점수'가 매겨지는 '도시 정복 게임'https://location.foursquare.com/developer/
64Oura건강정밀 수면 단계, 회복도 점수내 신체 에너지를 게임의 '마나(MP)'로 시각화https://cloud.ouraring.com/v2/docs
65Whoop건강운동 부하(Strain), 스트레스 분석오늘 나의 '스트레스 지수'를 날씨 데이터와 비교https://developer.whoop.com/docs/developing-with-whoop/
66Mapbox위치커스텀 지도 디자인, 3D 렌더링유저의 동선을 아름다운 '3D 동선 영상'으로 제작https://docs.mapbox.com/api/overview/
67Twilio통신SMS, 음성 통화 자동화 서비스\"30분 동안 폰을 안 보면 격려 문자 보내주기\" 기능https://www.twilio.com/docs/usage/api
68Stripe경제결제 규모, 구독 상태 정보유저의 소비 성향을 '사냥꾼 vs 채집가'로 분류https://stripe.com/docs/api
69Eventbrite문화지역 이벤트 및 네트워킹 모임현재 위치에서 1시간 내에 시작하는 '우연한 모임' 추천https://www.eventbrite.com/platform/api/
70Meetup커뮤니티관심사 기반 모임, 멤버십 정보유저의 취미 생활 및 사교성 깊이 측정https://www.meetup.com/api/guide/
71Amadeus여행항공 노선 최적화, 호텔 검색\"어디든 좋으니 지금 가장 저렴한 곳으로\" 룰렛 여행https://developers.amadeus.com/
72Pixabay미디어저작권 프리 고화질 사진 및 영상내가 만든 음악에 맞는 '영상 배경' 자동 합성https://pixabay.com/api/docs/
73ArtStation예술디지털 아티스트 포트폴리오유저의 사진을 전 세계 유명 작가의 화풍으로 분석https://www.artstation.com/api
74Behance디자인글로벌 디자인 프로젝트 작업물내 기획안을 보완해줄 '가상 디자인 파트너' 매칭https://www.behance.net/dev
75StackOverflow기술프로그래밍 질문/답변 데이터유저의 기술적 질문 빈도로 분석하는 '성장 잠재력'https://api.stackexchange.com/
76Zillow부동산주택 가격 추이, 매물 정보\"내가 번 돈으로 살 수 있는 전 세계의 집\" 찾기https://www.zillow.com/howto/api/APIOverview.htm
77Glassdoor직업회사 리뷰, 연봉 정보 데이터유저의 회사 평판과 내 '애사심 지수' 비교 분석https://www.glassdoor.com/developer/index.htm
78LinkedIn커리어경력 사항, 학력, 보유 기술 정보유저의 커리어를 기반으로 한 'RPG 직업 전직'https://learn.microsoft.com/en-us/linkedin/
79Medium콘텐츠블로그 포스트, 주제별 인기 글내가 쓴 글이 어떤 잡지나 매체에 어울릴지 진단https://github.com/Medium/medium-api-docs
80Substack콘텐츠뉴스레터 구독 및 작가 정보유저의 심층적 정보 소비 패턴 분석https://substack.com/api
81Etsy커머스핸드메이드 제품, 빈티지 상품유저의 취향으로 분석하는 '세상에 단 하나뿐인 소품'https://www.etsy.com/developers/documentation
82eBay커머스중고 거래 데이터, 시세 정보내 방의 물건들을 '희귀 유물' 가격으로 환산https://developer.ebay.com/api-docs/
83Weatherbit환경초정밀 하이퍼로컬 날씨 데이터유저의 베란다 식물이 잘 자랄지 예측해주는 가이드https://www.weatherbit.io/api
84FlightAware교통실시간 비행기 위치 및 상태 정보머리 위로 지나가는 비행기의 '목적지'와 '낭만' 알림https://flightaware.com/commercial/aeroapi/
85MarineTraffic교통실시간 선박 위치, 항구 혼잡도바다 너머로 오는 '물건'의 여정을 추적하는 스토리https://www.marinetraffic.com/en/p/api-services
86Citymapper이동복합 대중교통 경로 최적화 데이터\"출근길 지루함을 최소화하는 '모험 경로' 추천\"https://citymapper.com/developers
87Met Museum예술예술 작품 메타데이터유저의 얼굴과 가장 닮은 '역사 속 초상화' 찾기https://metmuseum.github.io/
88Rijksmuseum예술국립미술관 소장품 데이터유저의 인스타그램 피드를 '박물관 전시회'로 구성https://data.rijksmuseum.nl/object-metadata/api/
89Quotable라이프유명 인사 명언 리포지토리유저의 한숨 소리(음성 분석)를 듣고 명언 건네기https://github.com/lukePeavey/quotable
90WordsAPI언어단어의 정의, 동의어, 사용 빈도내 글의 어휘력을 '언어의 정원'으로 시각화https://www.wordsapi.com/
91Urban Dictionary언어슬랭(Slang), 인터넷 밈 정의\"당신의 대화 속 힙스터 지수는 몇 점입니까?\"https://rapidapi.com/community/api/urban-dictionary
92Oxford Dict.언어정통 어학 사전 데이터대화 중 어려운 단어의 '유래'를 알려주는 지적 알림https://developer.oxforddictionaries.com/
93Random.org데이터진정한 난수(True Randomness)\"내 힘으로 정하기 힘들 때, 우주가 정해주는 운명\"https://www.random.org/clients/http/
94Petfinder동물유기 동물 입양 정보, 특징 데이터유저의 성격과 가장 어울리는 '운명의 강아지' 추천https://www.petfinder.com/developers/v2/docs/
95TMDB (TV)미디어TV 시리즈, 에피소드 상세 정보\"당신이 살아온 인생은 어떤 미드 시즌 1과 같나요?\"https://developer.themoviedb.org/docs/getting-started
96OpenUV환경실시간 자외선 지수, 피부 유형\"지금 선크림 안 바르면 10년 뒤 당신의 얼굴은?\"https://www.openuv.io/
97Biblical문화다양한 성경 텍스트 데이터내 고민에 대한 '고전 경전' 속의 답 찾아보기https://api.bible/
98Clear Outside천문별 관측 최적도(Cloud Cover) 데이터\"오늘 밤 당신의 창가에서 은하수가 보일까요?\" 알림https://clearoutside.com/forecast/
99TradingView금융정밀 차트 데이터 및 기술적 지표내 인생의 기복을 '주식 차트'처럼 시각화하기https://www.tradingview.com/widget/"""

def parse_api_line(line):
    """Parse a single API line"""
    # Extract URL first (starts with http)
    url_match = re.search(r'(https?://[^\s]+)', line)
    if not url_match:
        return None
    
    url = url_match.group(1)
    before_url = line[:url_match.start()]
    
    # Extract rank (starts with number)
    rank_match = re.match(r'^(\d+)', before_url)
    if not rank_match:
        return None
    
    rank = int(rank_match.group(1))
    after_rank = before_url[rank_match.end():]
    
    # Now we need to split: API name, category, features, idea
    # API name typically starts with uppercase English
    # Category has / in it
    # Features and ideas are longer Korean text
    
    # Find API name (uppercase start, before Korean or /)
    api_match = re.match(r'^([A-Z][A-Za-z0-9\s\.\-]*?)([가-힣/])', after_rank)
    if not api_match:
        # Try to find just until first Korean character
        api_match = re.match(r'^([A-Z][A-Za-z0-9\s\.\-]*)', after_rank)
    
    if api_match:
        api_name = api_match.group(1).strip()
        after_api = after_rank[len(api_name):]
    else:
        return None
    
    # Find category (usually has / or is short Korean/English mix before longer description)
    # Category typically ends before a longer Korean sentence
    category_match = re.match(r'^([^가-힣]*?[/][^가-힣]*?)([가-힣]{2,})', after_api)
    if not category_match:
        # Try without / requirement
        category_match = re.match(r'^([가-힣A-Za-z/]{2,20}?)([가-힣]{3,})', after_api)
    
    if category_match:
        category = category_match.group(1).strip()
        after_category = after_api[len(category):]
    else:
        category = ""
        after_category = after_api
    
    # Remaining text split into features and idea
    # They're both Korean text, we need a heuristic
    # Typically features are shorter and come first
    # Let's split at a point that seems reasonable
    # Look for a pattern like "XX XX XX 유저의" or similar
    
    # Split roughly in half or at a natural break
    remaining = after_category.strip()
    
    # Try to find where idea starts (often starts with patterns like "유저의", "내", "오늘", etc.)
    idea_patterns = [
        r'(유저의)',
        r'(내\s)',
        r'(오늘)',
        r'(당신)',
        r'(어제)',
        r'(지금)',
    ]
    
    split_pos = len(remaining) // 2  # default: middle
    for pattern in idea_patterns:
        matches = list(re.finditer(pattern, remaining))
        if matches and len(matches) >= 1:
            # Use the first or second match as split point
            match_idx = min(1, len(matches) - 1)
            split_pos = matches[match_idx].start()
            break
    
    features = remaining[:split_pos].strip()
    idea = remaining[split_pos:].strip()
    
    return {
        "rank": rank,
        "api_name": api_name,
        "category": category,
        "features": features,
        "idea": idea,
        "url": url
    }

# Parse all lines
lines = [line.strip() for line in raw_text.strip().split('\n') if line.strip()]
apis = []

for line in lines:
    parsed = parse_api_line(line)
    if parsed:
        apis.append(parsed)

# Output to JSON
with open('api_database.json', 'w', encoding='utf-8') as f:
    json.dump(apis, f, ensure_ascii=False, indent=2)

print(f"Parsed {len(apis)} APIs")
print(f"Output: api_database.json")

# Also create a Markdown version
with open('API_DATABASE.md', 'w', encoding='utf-8') as f:
    f.write("# 유용한 Data API 100\n\n")
    f.write("**출처:** Google Sheets\n")
    f.write("**작성일:** 2026-02-20\n")
    f.write("**용도:** 콘텐츠 제작 및 게임 개발 참고 자료\n\n")
    f.write("---\n\n")
    
    # Group by category
    categories = {}
    for api in apis:
        cat = api['category'] if api['category'] else '기타'
        if cat not in categories:
            categories[cat] = []
        categories[cat].append(api)
    
    # Write by category
    for cat in sorted(categories.keys()):
        f.write(f"## {cat}\n\n")
        for api in categories[cat]:
            f.write(f"### {api['rank']}. {api['api_name']}\n\n")
            f.write(f"**특징:** {api['features']}\n\n")
            f.write(f"**아이디어:** {api['idea']}\n\n")
            f.write(f"**링크:** [{api['url']}]({api['url']})\n\n")
            f.write("---\n\n")
    
    f.write("\n\n_데이터베이스 생성: Atlas | GeekBrox 2026_\n")

print("Output: API_DATABASE.md")
