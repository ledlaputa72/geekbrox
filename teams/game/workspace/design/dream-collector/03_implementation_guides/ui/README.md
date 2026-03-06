# 🎨 UI/UX 설계 문서 (UI Implementation Guides)

**목적:** Dream Collector의 UI 화면 설계 및 구현 가이드  
**상태:** ✅ 완료 (100%)  
**최종 업데이트:** 2026-03-06

---

## 📋 UI 문서 목록

### 1️⃣ **UI_CHARACTER_SCREEN_SPEC.md** (24.5 KB)
**목적:** 캐릭터 화면 상세 사양서

**포함 내용:**
- 캐릭터 정보 표시 (레벨, 경험치, 스탯)
- 장비 슬롯 표시 (6개 슬롯: 무기, 갑옷, 반지×2, 목걸이×2)
- 아이템 인벤토리 그리드 (5열 레이아웃)
- 아이템 상세 정보 모달
- 인터랙션 플로우

**사용 대상:**
- UI 디자이너 (레이아웃, 색상, 폰트)
- 개발자 (구현 스펙)
- 기획자 (인터페이스 피드백)

---

### 2️⃣ **UI_EQUIPMENT_TAB_DESIGN.md** (17.3 KB)
**목적:** 장비 탭 UI 상세 설계

**포함 내용:**
- 장비 슬롯 배치 및 시각화
- 아이템 통계 표시
- 강화/진화 UI
- 아이템 비교 기능
- 인벤토리 정렬/필터링

**사용 대상:**
- UI 디자이너 (탭 인터페이스)
- 게임 디자이너 (장비 시스템 검증)
- 개발자 (기능 구현)

---

## 🎨 **UI 설계 원칙**

### 색상 체계 (Unified Dream Theme)
```
Common (회색)        #6B7280
Uncommon (초록색)    #10B981
Rare (파란색)        #3B82F6
Epic (보라색)        #A855F7
Legendary (노란색)   #FBBF24
```

### 레이아웃
- **해상도:** Portrait 390×844px (모바일 표준)
- **Grid System:** 5열 인벤토리 그리드
- **Safe Area:** 상단 20px, 하단 20px

### 폰트 및 텍스트
- **제목:** Bold, 18-24pt
- **본문:** Regular, 14pt
- **작은 텍스트:** 12pt

---

## 📂 **관련 파일 위치**

### 🎨 **React 컴포넌트** (~/interface/v0-exports/dream-theme/)
- **c06-character-equipment-fixed.tsx** — 캐릭터 장비 화면 컴포넌트
- **EquipmentDetailModal.tsx** — 장비 상세 정보 모달 컴포넌트

### 💻 **Godot 스크립트** (~/godot/dream-collector/ui/)
- **ui/screens/CharacterScreen.gd** — 캐릭터 화면 스크립트
- **ui/components/EquipmentSlot.gd** — 장비 슬롯 컴포넌트
- **ui/components/ItemDetailPopup.gd** — 아이템 상세 팝업

### 📊 **관련 설계 문서**
- **02_core_design/equipment/EQUIPMENT_SYSTEM_GDD_FINAL.md** — 장비 시스템 GDD
- **02_core_design/characters/CHARACTER_DESIGN_SYSTEM.md** — 캐릭터 시스템

---

## 🔗 **11개 UI 화면 전체 리스트** (설계 완료)

| # | 화면명 | 상태 | 문서 | 코드 |
|---|--------|------|------|------|
| 1 | 메인 로비 | ✅ 완료 | GDD | Godot |
| 2 | 갈라 (뽑기) | ✅ 완료 | GDD | GachaUI.gd |
| 3 | 카드 라이브러리 | ✅ 완료 | GDD | CardLibrary.gd |
| 4 | 덱 빌더 | ✅ 완료 | GDD | DeckBuilder.gd |
| 5 | 런 준비 | ✅ 완료 | GDD | RunPrep.gd |
| 6 | 카드 선택 (게임 중) | ✅ 완료 | GDD | DreamCardSelection.gd |
| 7 | 전투 화면 | ✅ 완료 | GDD | InRun_v4.gd |
| 8 | **캐릭터 화면** | ✅ 완료 | **UI_CHARACTER_SCREEN_SPEC.md** | CharacterScreen.gd |
| 9 | **장비 탭** | ✅ 완료 | **UI_EQUIPMENT_TAB_DESIGN.md** | EquipmentSlot.gd |
| 10 | 상점 | ✅ 완료 | GDD | Shop.gd |
| 11 | 업그레이드 트리 | ✅ 완료 | GDD | UpgradeTree.gd |

---

## 💡 **구현 체크리스트**

### UI_CHARACTER_SCREEN_SPEC.md
- [ ] 캐릭터 정보 섹션 구현
- [ ] 장비 슬롯 표시 (6개)
- [ ] 인벤토리 그리드 (5열)
- [ ] 아이템 상세 모달
- [ ] 색상 테마 적용
- [ ] 반응형 레이아웃
- [ ] 터치 인터랙션
- [ ] 성능 최적화 (스크롤링)

### UI_EQUIPMENT_TAB_DESIGN.md
- [ ] 탭 네비게이션 구현
- [ ] 장비 통계 표시
- [ ] 강화/진화 버튼
- [ ] 아이템 비교 UI
- [ ] 정렬/필터 기능
- [ ] 드래그 앤 드롭 (선택사항)
- [ ] 애니메이션 (슬롯 변경)
- [ ] 로딩 상태 표시

---

## 🎯 **다음 단계**

### 즉시 (3/6 ~ 3/7)
1. ✅ UI 설계 문서 정리 **[완료]**
2. ⏳ Godot 스크린 연동 (CharacterScreen → Godot)
3. ⏳ React 컴포넌트 최종 검증

### 단기 (3/8 ~ 3/10)
1. UI 애니메이션 추가 (화면 전환)
2. 성능 최적화 (인벤토리 스크롤)
3. 터치 인터랙션 파인튜닝

### 중기 (3/11 ~ 3/13)
1. 전체 UI 흐름 통합 테스트
2. 해상도별 대응 (태블릿 지원)
3. 접근성 개선 (폰트 크기, 색상 대비)

---

## 📚 **참고 문서**

### 설계 기준
- **EQUIPMENT_SYSTEM_GDD_FINAL.md** — 장비 데이터 구조
- **CHARACTER_DESIGN_SYSTEM.md** — 캐릭터 속성

### 구현 가이드
- **03_implementation_guides/IMPLEMENTATION_GUIDE.md** — 전체 구현 가이드
- **03_implementation_guides/dev_tools/CURSOR_COMPLETE_DEV_GUIDE.md** — Cursor IDE 가이드

### 컬러 시스템
- **02_core_design/equipment/EQUIPMENT_SYSTEM_GDD_FINAL.md** (색상 정의 섹션)

---

## 📞 **Q&A**

**Q: 인벤토리 그리드가 5열로 고정인가요?**  
A: 네. 390px 모바일 화면에서 최적화된 레이아웃입니다. 태블릿 지원 시 변경 가능.

**Q: 장비 슬롯은 몇 개인가요?**  
A: 6개입니다. (무기 1, 갑옷 1, 반지 2, 목걸이 2)

**Q: React 컴포넌트와 Godot 구현의 차이는?**  
A: React는 UI 레이아웃 프로토타입, Godot는 실제 게임 구현입니다. Godot이 최종 사용.

---

**최종 업데이트:** 2026-03-06 14:30 PST  
**상태:** ✅ 완료 및 정렬  
**관리자:** Atlas PM
