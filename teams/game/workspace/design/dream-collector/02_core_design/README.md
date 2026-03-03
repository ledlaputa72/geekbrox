# 📖 02_core_design — 핵심 게임 설계 문서

**마지막 업데이트**: 2026-03-03  
**기준**: CARD_MASTER_UNIFIED_v1.md (메인/서브 카테고리 통일)

---

## 📋 **폴더 구조**

모든 카드 설계 문서는 **메인 4가지 카테고리 + 서브 카테고리** 구조를 따릅니다:

```
1️⃣ ATTACK (공격) — 10장
   • ATK-SGL: 단일 타격
   • ATK-MLT: 광역·다중
   • ATK-RCK: 고위험
   • ATK-CMP: 복합 효과

2️⃣ SKILL (방어) — 18장
   • SKL-GRD: GUARD
   • SKL-PAR: PARRY
   • SKL-DOD: DODGE

3️⃣ POWER (강화) — 8장
   • PWR-DRW: 드로우
   • PWR-ATK: 공격력 강화
   • PWR-DEF: 방어 강화
   • PWR-SUS: 지속 효과

4️⃣ CURSE (약화) — 6장
   • CRS-STA: 스탯 약화
   • CRS-SPD: 속도 조작
   • CRS-PEN: 관통/반사
   • CRS-RSK: 리스크/기타
```

---

## 📄 **문서 목록 및 역할**

### 🎴 **마스터 & 참조 문서**

| 문서 | 목적 | 기준 |
|------|------|------|
| **CARD_MASTER_UNIFIED_v1.md** | 🔑 마스터 통합 테이블 | 모든 카드 ID, 기능 ID, 메인/서브 구조 |
| **README.md** | 📖 폴더 가이드 | 이 문서 |

### 🃏 **카드 카탈로그 (상세 스펙)**

| 문서 | 목적 | 메인/서브 구조 | 대상 |
|------|------|------------|------|
| **CARD_CATALOG_UNIFIED_v1.md** | 전체 카드 상세 스펙 | ✅ 메인/서브 정렬 | 개발팀 |
| **CARD_CLASSIFICATION_UNIFIED_v1.md** | 카드 분류 체계 | ✅ 메인/서브 정렬 | PM/기획 |
| **CARD_TYPE_SYSTEM_UNIFIED_v1.md** | 타입/태그 시스템 | ✅ 메인/서브 정렬 | 개발팀 |

### 🎯 **기능 설계 & 규칙**

| 문서 | 목적 | 메인/서브 구조 | 대상 |
|------|------|------------|------|
| **CARD_FUNCTION_DESIGN_GUIDE_UNIFIED_v1.md** | 기능별 설계 가이드 | ✅ 메인/서브 정렬 | 신규 팀원 |
| **CARD_FUNCTION_MAPPING_UNIFIED_v1.md** | 기능 ID ↔ 카드 ID 매핑 | ✅ 메인/서브 정렬 | 개발팀 |

### 🎮 **게임 시스템 & 로드맵**

| 문서 | 목적 | 메인/서브 구조 | 대상 |
|------|------|------------|------|
| **COMBAT_SYSTEM_MASTER_SPEC.md** | 전투 시스템 | — (독립) | 개발팀 |
| **TAROT_SYSTEM_GUIDE.md** | 타로 에너지 시스템 | — (독립) | 개발팀 |
| **CARD_COMBAT_SYSTEM_DESIGN.md** | 전투와 카드의 상호작용 | ✅ 메인/서브 정렬 | 개발팀 |
| **CARD_MONTHLY_ROADMAP.md** | M2+ 카드 로드맵 | ✅ 메인/서브 정렬 | PM |

---

## 🔑 **기본 개념**

### **메인 카테고리 (4가지)**
- **ATTACK**: 공격 카드 (빨강)
- **SKILL**: 방어 카드 (초록) — GUARD/PARRY/DODGE 3가지 태그
- **POWER**: 강화 카드 (파랑) — 지속 버프
- **CURSE**: 약화 카드 (노랑) — 적 디버프

### **기능 ID (Function ID)**
메인-서브 형식 (예: `ATK-SGL`, `SKL-GRD`, `PWR-DRW`)
- 게임 메커닉 분류 (설계 관점)
- 검색/필터링에 사용

### **카드 ID (Card ID)**
타입_번호 형식 (예: `ATK_001`, `DEF_001`, `POW_001`)
- 구체적 카드 고유 식별 (구현 관점)
- CardDatabase.gd 기준

---

## 📊 **현황**

| 카테고리 | 서브 | 기능 ID | 수량 | 구현 | 설계 |
|---------|------|--------|------|------|------|
| **ATTACK** | 단일 타격 | ATK-SGL | 4 | ✅ | — |
| | 광역·다중 | ATK-MLT | 3 | ✅ | — |
| | 고위험 | ATK-RCK | 1 | ✅ | — |
| | 복합 효과 | ATK-CMP | 2 | ✅ | — |
| **SKILL** | GUARD | SKL-GRD | 8 | ✅ | — |
| | PARRY | SKL-PAR | 5 | ✅ | — |
| | DODGE | SKL-DOD | 5 | ✅ | — |
| **POWER** | 드로우 | PWR-DRW | 2 | ✅ | — |
| | 공격력 강화 | PWR-ATK | 2 | — | 🔲 |
| | 방어 강화 | PWR-DEF | 2 | — | 🔲 |
| | 지속 효과 | PWR-SUS | 2 | — | 🔲 |
| **CURSE** | 스탯 약화 | CRS-STA | 2 | — | 🔲 |
| | 속도 조작 | CRS-SPD | 1 | — | 🔲 |
| | 관통/반사 | CRS-PEN | 2 | — | 🔲 |
| | 리스크/기타 | CRS-RSK | 1 | — | 🔲 |
| | | **합계** | **42** | **30** | **12** |

---

## 🚀 **50분 온보딩 경로**

### **신규 팀원 (개발/기획)**

**1단계 (10분)**: 마스터 이해
- [ ] CARD_MASTER_UNIFIED_v1.md 읽기
- [ ] 메인/서브 카테고리 이해
- [ ] 기능 ID / 카드 ID 규칙 이해

**2단계 (15분)**: 카드 카탈로그 훑기
- [ ] CARD_CATALOG_UNIFIED_v1.md 스캔
- [ ] 각 서브 카테고리별 대표 카드 2-3개 숙지

**3단계 (15분)**: 설계 규칙 학습
- [ ] CARD_FUNCTION_DESIGN_GUIDE_UNIFIED_v1.md 정독
- [ ] 각 카테고리의 설계 원칙 이해

**4단계 (10분)**: 시스템 컨텍스트
- [ ] COMBAT_SYSTEM_MASTER_SPEC.md (전투 시스템)
- [ ] TAROT_SYSTEM_GUIDE.md (타로 에너지)

---

## 🎯 **자주 찾는 정보**

### "특정 카드를 찾고 싶어요"
→ **CARD_MASTER_UNIFIED_v1.md** (카드 ID 기준)

### "어떤 공격 카드들이 있나요?"
→ **CARD_CATALOG_UNIFIED_v1.md** (ATK-SGL / ATK-MLT 섹션)

### "새 카드를 설계하려면?"
→ **CARD_FUNCTION_DESIGN_GUIDE_UNIFIED_v1.md** (설계 규칙)

### "서브 카테고리의 정의가 뭐죠?"
→ **CARD_TYPE_SYSTEM_UNIFIED_v1.md** (분류 체계)

### "다음 달 계획 카드는?"
→ **CARD_MONTHLY_ROADMAP.md** (로드맵)

### "카드 데이터는 어디에?"
→ **CardDatabase.gd** (코드 기준)

---

## 📌 **문서 유지보수**

모든 문서는 **CARD_MASTER_UNIFIED_v1.md의 메인/서브 구조**를 따릅니다.

새 카드 추가 시 체크리스트:
- [ ] CARD_MASTER_UNIFIED_v1.md에 카드 ID 등록
- [ ] CARD_CATALOG_UNIFIED_v1.md에 상세 스펙 추가
- [ ] CARD_FUNCTION_MAPPING_UNIFIED_v1.md에 매핑 추가
- [ ] CardDatabase.gd 코드 작성
- [ ] CARD_MONTHLY_ROADMAP.md 업데이트

---

**최신 기준**: CARD_MASTER_UNIFIED_v1.md (2026-03-03)  
**관리자**: Atlas (PM)
