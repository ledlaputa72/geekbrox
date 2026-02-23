# v0 프롬프트 v1.1 - Dream Collector UI

**작성일:** 2026-02-23  
**기반:** UPDATED_SCREEN_SPECS_v1.1.md  
**목적:** v0.dev에서 Dream Collector UI 프로토타입 제작

---

## 📋 프롬프트 목록 (총 8개)

### 기존 컴포넌트 업그레이드 (5개)

| 파일 | 화면 | 기존 파일 | 상태 |
|------|------|-----------|------|
| `c01-main-lobby-v1.1.txt` | 홈/아카이브 | c01-main-lobby.tsx | 업그레이드 |
| `c02-card-library-v1.1.txt` | 카드 라이브러리 | c02-card-library.tsx | 업그레이드 |
| `c03-deck-builder-v1.1.txt` | 덱 빌더 | c03-deck-builder.tsx | 업그레이드 |
| `c04-upgrade-tree-v1.1.txt` | 업그레이드 트리 | c04-upgrade-tree.tsx | 업그레이드 |
| `c05-shop-v1.1.txt` | 상점 | c05-shop.tsx | 업그레이드 |

### 신규 화면 (3개)

| 파일 | 화면 | 상태 |
|------|------|------|
| `c06-run-prep-v1.1.txt` | 런 준비 | 신규 |
| `c07-in-run-v1.1.txt` | 진행 중인 런 | 신규 |
| `c08-combat-v1.1.txt` | 전투 | 신규 |

---

## 🚀 사용 방법

### 1. v0.dev 접속
https://v0.dev

### 2. 프롬프트 복사
각 .txt 파일을 열어서 전체 내용을 복사합니다.

### 3. v0에 붙여넣기
v0.dev의 입력창에 프롬프트를 붙여넣고 생성합니다.

### 4. 결과물 다운로드
- v0에서 생성된 React 컴포넌트를 다운로드합니다.
- TSX 파일을 `v0-exports/dream-theme-v1.1/` 폴더에 저장합니다.

### 5. 반복
8개 화면을 모두 생성할 때까지 반복합니다.

---

## 📐 디자인 시스템 (공통)

### 색상 팔레트
- **Primary**: `#7B9EF0` (소프트 블루)
- **Secondary**: `#5A7FC0` (진한 블루)
- **Background**: `#1A1A2E` (다크 네이비)
- **Success**: `#4CAF50` | **Warning**: `#FFC107` | **Error**: `#F44336`

### 타이포그래피
- **Font**: Nunito (Google Fonts)
- **Sizes**: 12px ~ 24px (6단계)
- **Weights**: Regular (400), Bold (700)

### 희귀도 그라데이션
- **Common**: `linear-gradient(135deg, #AAAAAA 0%, #CCCCCC 100%)`
- **Uncommon**: `linear-gradient(135deg, #4CAF50 0%, #81C784 100%)`
- **Rare**: `linear-gradient(135deg, #2196F3 0%, #64B5F6 100%)`
- **Epic**: `linear-gradient(135deg, #9C27B0 0%, #BA68C8 100%)`
- **Legendary**: `linear-gradient(135deg, #FFC107 0%, #FFD54F 100%)`

### 애니메이션
- **화면 전환**: Fade (200ms), Slide (250ms)
- **버튼 탭**: Scale 0.95 (100ms)
- **카드 선택**: Scale 1.1 (150ms)
- **플로팅**: ±10px vertical (2s cycle)

---

## 📦 출력 파일 구조

생성된 컴포넌트는 다음 구조로 저장합니다:

```
v0-exports/dream-theme-v1.1/
├── c01-main-lobby-v1.1.tsx
├── c02-card-library-v1.1.tsx
├── c03-deck-builder-v1.1.tsx
├── c04-upgrade-tree-v1.1.tsx
├── c05-shop-v1.1.tsx
├── c06-run-prep-v1.1.tsx
├── c07-in-run-v1.1.tsx
├── c08-combat-v1.1.tsx
└── theme-tokens-v1.1.ts
```

---

## 🎯 우선순위

### Phase 1 (Week 1-2): 기초
1. ✅ c01-main-lobby-v1.1 (홈 화면)
2. ✅ c03-deck-builder-v1.1 (덱 빌더)
3. ✅ c02-card-library-v1.1 (카드 라이브러리)

### Phase 2 (Week 3): 런 시스템
4. ✅ c06-run-prep-v1.1 (런 준비)
5. ✅ c07-in-run-v1.1 (진행 중인 런)
6. ✅ c08-combat-v1.1 (전투)

### Phase 3 (Week 4): 메타 진행
7. ✅ c04-upgrade-tree-v1.1 (업그레이드)
8. ✅ c05-shop-v1.1 (상점)

---

## 🔧 v0 생성 팁

### 1. 프롬프트 수정
v0 결과가 기대와 다르면 다음 프롬프트를 추가로 입력:
- "Make the buttons larger for mobile touch"
- "Add more spacing between elements"
- "Use darker colors for better contrast"
- "Animate the card entrance"

### 2. 반복 생성
만족할 때까지 여러 버전을 생성합니다.
v0는 매번 다른 결과를 만들 수 있습니다.

### 3. 컴포넌트 조합
개별 컴포넌트를 생성한 후, 필요한 부분을 조합합니다.

### 4. 테마 토큰
공통 색상/폰트를 `theme-tokens-v1.1.ts` 파일로 추출하여 재사용합니다.

---

## 📊 예상 소요 시간

| 작업 | 소요 시간 |
|------|----------|
| v0 프롬프트 실행 (8개) | 2-3시간 |
| 결과물 수정 및 조정 | 3-4시간 |
| 통합 및 테스트 | 2-3시간 |
| **총합** | **7-10시간 (1-2일)** |

---

## 🎨 다음 단계

### v0 프로토타입 완성 후:

1. **Unity/Godot 전환**
   - v0 컴포넌트를 실제 게임 엔진으로 포팅
   - UI 로직 구현
   - 데이터 연동

2. **인터랙션 개선**
   - 터치 제스처 추가
   - 애니메이션 폴리싱
   - 사운드 효과

3. **백엔드 연동**
   - 저장/로드 시스템
   - 서버 동기화
   - 분석 통합

---

## 📝 노트

### v0 한계점
- 복잡한 상태 관리 로직은 수동 구현 필요
- 애니메이션은 기본 수준 (고급 효과는 수동 추가)
- 게임 로직은 별도 구현 필요

### 권장 사항
- v0 결과물은 "레이아웃 + 기본 스타일" 정도로 활용
- 상세 로직과 애니메이션은 엔진에서 구현
- 프로토타입으로 먼저 UX 테스트 후 개발

---

**작성자:** Atlas (AI PM)  
**프로젝트:** Dream Collector  
**버전:** 1.1  
**날짜:** 2026-02-23
