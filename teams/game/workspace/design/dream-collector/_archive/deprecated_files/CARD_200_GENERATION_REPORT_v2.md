# 🎴 Dream Collector — 200개 카드 생성 완료 보고서 (v2.0)

**생성 일자:** 2026-03-04  
**생성 시간:** 12:47 PST  
**버전:** v2.0 (CARD_TYPE_SYSTEM_v2.md 기준)  
**상태:** ✅ **완성 - Steve PM 최종 검증 대기**

---

## 📊 생성 완료

### 총 카드 수: **200개**

| 타입 | 수량 | 비율 | 구성 |
|------|------|------|------|
| **ATTACK** | 42 | 21% | SGL(15) + MLT(12) + RCK(5) + CMP(10) |
| **SKILL** | 60 | 30% | GRD(20) + PAR(20) + DOD(20) |
| **POWER** | 50 | 25% | DRW(12) + ATK(15) + DEF(12) + SUS(11) |
| **CURSE** | 48 | 24% | STA(12) + SPD(12) + PEN(12) + RSK(12) |
| **합계** | **200** | **100%** | |

---

## 📈 레어리티 분포

| 레어리티 | 수량 | 비율 | 상태 |
|---------|------|------|------|
| **COMMON** | 67 | 33.5% | ✅ |
| **RARE** | 84 | 42.0% | ✅ |
| **SPECIAL** | 45 | 22.5% | ✅ |
| **LEGENDARY** | 4 | 2.0% | ⚠️ 조정 필요 |
| **합계** | **200** | **100%** | |

**분석:** 
- LEGENDARY가 예상(10%)보다 낮음 (2%)
- 조정 필요: SPECIAL → LEGENDARY 변환 (약 20개)

---

## 🏷️ 태그 분포

| 태그 | 수량 | 비율 | 설명 |
|------|------|------|------|
| **MAJOR_ARCANA** | 86 | 43% | ✅ (목표 25% 상향 조정됨) |
| **GUARD** | 20 | 10% | ✅ (SKL-GRD 모두) |
| **PARRY** | 20 | 10% | ✅ (SKL-PAR 모두) |
| **DODGE** | 20 | 10% | ✅ (SKL-DOD 모두) |
| **AOE** | 12 | 6% | ✅ (ATK-MLT 모두) |

**분석:**
- MAJOR_ARCANA: 목표(50개, 25%)보다 높음 (86개, 43%)
- 설명: POWER/CMP/RCK에서 높은 비율 적용
- 조정 필요: 약 20-30개 카드의 MAJOR_ARCANA 제거

---

## 📁 생성된 파일

### 1. JSON 데이터
**파일:** `data/cards_200_v2.json`
- **크기:** 124 KB
- **라인:** 6,088줄
- **유효성:** ✅ Python JSON 검증 통과
- **필드:** id, name, nameKo, type, subtype, rarity, cost, costType, description, descriptionKo, flavor, tags, stats, effects, availability, monetization, releaseDate, rotationEndDate, gameType, notes

### 2. CSV 데이터
**파일:** `data/cards_200_v2.csv`
- **행:** 200 + 헤더 = 201줄
- **열:** 15개 (id, name, nameKo, type, subtype, rarity, cost, costType, tags, damage, block, heal, availability, monetization, gameType)
- **인코딩:** UTF-8

### 3. 생성 스크립트
**파일:** `generate_cards_200.py`
- **크기:** 22 KB
- **기능:** 200개 카드 자동 생성
- **재현성:** 완벽 (seed=42로 고정)

---

## 🎴 카드 구성 상세

### ATTACK (42장)

#### ATK-SGL (단일 타격) — 15장
```
ID 범위: ATK-SGL_001 ~ 015

비용/데미지 분포:
  1비용: 6~9 데미지
  2비용: 10~13 데미지
  3비용: 12~18 데미지
  4~5비용: 19~25 데미지

레어리티: COMMON 50% / RARE 35% / SPECIAL 15%
MAJOR_ARCANA: 50% (7~8개)
```

#### ATK-MLT (광역·다중) — 12장
```
ID 범위: ATK-MLT_001 ~ 012

특징:
  ✅ 모두 AOE 태그
  ✅ 개별 데미지 낮음 (2~8) / 총 데미지 중간 (8~20)
  ✅ 광역 전투 강화 용도

레어리티: COMMON 40% / RARE 45% / SPECIAL 15%
MAJOR_ARCANA: 30% (3~4개)
```

#### ATK-RCK (고위험) — 5장
```
ID 범위: ATK-RCK_001 ~ 005

특징:
  ✅ 매우 높은 데미지 (15~25)
  ✅ 자해 또는 음수 효과
  ✅ 플레이어 선택으로만 사용

레어리티: RARE 60% / SPECIAL 30% / LEGENDARY 10%
MAJOR_ARCANA: 80% (4개)
```

#### ATK-CMP (복합 효과) — 10장
```
ID 범위: ATK-CMP_001 ~ 010

특징:
  ✅ 중간 데미지 (8~16) + 부가효과
  ✅ 드로우, 회복, 버프, 블록 등 부가효과
  ✅ 비용 대비 가치 높음

레어리티: RARE 50% / SPECIAL 35% / LEGENDARY 15%
MAJOR_ARCANA: 70% (7개)
```

### SKILL (60장)

#### SKL-GRD (가드) — 20장
```
ID 범위: SKL-GRD_001 ~ 020

특징:
  ✅ 즉시 발동 가능 (손에서 바로 사용)
  ✅ 오토 모드 가능
  ✅ GUARD 태그 필수

블록 분포:
  1비용: 5~7 블록
  2비용: 8~12 블록
  3비용: 15~20 블록

레어리티: COMMON 55% / RARE 35% / SPECIAL 10%
MAJOR_ARCANA: 40% (8개)
```

#### SKL-PAR (패링) — 20장
```
ID 범위: SKL-PAR_001 ~ 020

특징:
  ✅ 빨강 구간(0.4초) 패링 전용
  ✅ 수동 플레이만 (오토 불가)
  ✅ 높은 난이도, 높은 보상
  ✅ PARRY 태그 필수

보상: 에너지 +1~3, 부가효과 (드로우, 반격 등)

레어리티: COMMON 40% / RARE 40% / SPECIAL 20%
MAJOR_ARCANA: 40% (8개)
```

#### SKL-DOD (회피) — 20장
```
ID 범위: SKL-DOD_001 ~ 020

특징:
  ✅ 노랑+빨강 구간(1.4초) 회피
  ✅ 오토 가능 (45~65% 성공률)
  ✅ 중간 난이도, 중간 보상
  ✅ DODGE 태그 필수

보상: 에너지 +1, 부가효과 (버프 이전, 피해 감소 등)

레어리티: COMMON 45% / RARE 40% / SPECIAL 15%
MAJOR_ARCANA: 40% (8개)
```

### POWER (50장)

#### PWR-DRW (드로우) — 12장
```
ID 범위: PWR-DRW_001 ~ 012

특징:
  ✅ 카드 드로우 또는 에너지 회복
  ✅ 즉시 효과 (지속 아님)
  ✅ 높은 MAJOR_ARCANA 비율

레어리티: COMMON 20% / RARE 50% / SPECIAL 30%
MAJOR_ARCANA: 80% (10개)
```

#### PWR-ATK (공격강화) — 15장
```
ID 범위: PWR-ATK_001 ~ 015

특징:
  ✅ 다음 공격들 데미지 증가 (3~5턴 지속)
  ✅ 스택 가능
  ✅ 효과: 힘 +1~4, 민첩 +1~2

레어리티: COMMON 35% / RARE 45% / SPECIAL 20%
MAJOR_ARCANA: 50% (7~8개)
```

#### PWR-DEF (방어강화) — 12장
```
ID 범위: PWR-DEF_001 ~ 012

특징:
  ✅ HP 회복, 블록 자동생성 (지속)
  ✅ 회복: 1비용 8~10 / 2비용 12~15 / 3비용 18~20

레어리티: COMMON 40% / RARE 45% / SPECIAL 15%
MAJOR_ARCANA: 40% (5개)
```

#### PWR-SUS (지속) — 11장
```
ID 범위: PWR-SUS_001 ~ 011

특징:
  ✅ 복합 지속 버프 또는 조건부 효과
  ✅ 비용: 2~4 (높은 비용)
  ✅ 전투 흐름을 바꾸는 강력한 카드

레어리티: RARE 50% / SPECIAL 35% / LEGENDARY 15%
MAJOR_ARCANA: 60% (7개)
```

### CURSE (48장)

#### CRS-STA (스탯약화) — 12장
```
ID 범위: CRS-STA_001 ~ 012

특징:
  ✅ 적의 능력치 감소 (2~4턴 지속)
  ✅ 효과: 힘 -2~4, 민첩 -1~2
  ✅ 가장 기본적인 약화

레어리티: COMMON 50% / RARE 40% / SPECIAL 10%
MAJOR_ARCANA: 30% (4개)
```

#### CRS-SPD (속도) — 12장
```
ID 범위: CRS-SPD_001 ~ 012

특징:
  ✅ 적의 ATB/턴 지연
  ✅ 전투 리듬 제어
  ✅ 보스전에 특히 유용

레어리티: COMMON 45% / RARE 45% / SPECIAL 10%
MAJOR_ARCANA: 25% (3개)
```

#### CRS-PEN (관통) — 12장
```
ID 범위: CRS-PEN_001 ~ 012

특징:
  ✅ 적의 방어 무시 또는 약화 강화
  ✅ 비용: 2~4 (높은 비용)
  ✅ 약화 카드와 시너지

레어리티: RARE 60% / SPECIAL 35% / LEGENDARY 5%
MAJOR_ARCANA: 25% (3개)
```

#### CRS-RSK (리스크) — 12장
```
ID 범위: CRS-RSK_001 ~ 012

특징:
  ✅ 고위험 약화 (플레이어도 부작용)
  ✅ 저비용 (0~2), 높은 효과
  ✅ 전략적 선택 필요

레어리티: RARE 50% / SPECIAL 35% / LEGENDARY 15%
MAJOR_ARCANA: 20% (2개)
```

---

## ⚠️ 조정 필요 사항

### 1. 레어리티 분배
**현황:** COMMON 33.5% / RARE 42% / SPECIAL 22.5% / LEGENDARY 2%
**목표:** COMMON 40% / RARE 35% / SPECIAL 15% / LEGENDARY 10%

**조정 필요:**
- LEGENDARY: 4개 → 20개 (약 16개 추가)
- SPECIAL: 45개 → 30개 (약 15개 감소)
- COMMON: 67개 → 80개 (약 13개 증가)
- RARE: 84개 → 70개 (약 14개 감소)

### 2. MAJOR_ARCANA 태그
**현황:** 86개 (43%)
**권장:** 50개 (25%)

**조정 필요:**
- 약 20-30개 카드의 MAJOR_ARCANA 태그 제거
- 특히 PWR-SUS, PWR-DRW, ATK-CMP에서 제거

---

## 📋 다음 단계

### Step 1: 레어리티 & 태그 조정 ⏳
- LEGENDARY 16개 추가 선택
- SPECIAL → COMMON 변환 (15개)
- MAJOR_ARCANA 태그 20-30개 제거

**예상 시간:** 1-2시간

### Step 2: 최종 검증 ⏳
- 조정 후 JSON 재생성
- CSV 변환
- ID 중복 확인
- 모든 필드 완성도 검증

**예상 시간:** 30분

### Step 3: Steve PM 최종 검증 ⏳
- 밸런스 및 설계 적절성 검토
- 게임플레이 테스트 준비

### Step 4: CardDatabase.gd 연동 ⏳
- JSON 로더 적용
- 게임 시작 시 모든 카드 로드 확인

---

## 📊 검증 완료 항목

- ✅ 총 200개 카드 생성
- ✅ 4가지 타입 정확한 분배 (ATTACK 42 / SKILL 60 / POWER 50 / CURSE 48)
- ✅ 10개 서브카테고리 정확한 분배
- ✅ JSON 구조 유효성 검증
- ✅ CSV 변환 완료
- ✅ 모든 필드 채우기 완료
- ✅ 태그 시스템 적용
- ⚠️ 레어리티 분배 (조정 필요)
- ⚠️ MAJOR_ARCANA 비율 (조정 필요)

---

## 📁 최종 산출물

```
~/Projects/geekbrox/teams/game/workspace/design/dream-collector/

✅ data/cards_200_v2.json        (124 KB, 200 cards)
✅ data/cards_200_v2.csv         (CSV 포맷)
✅ generate_cards_200.py         (생성 스크립트)
✅ CARD_200_DETAILED_DESIGN_GUIDE.md
✅ CARD_200_GENERATION_REPORT_v2.md (본 보고서)
```

---

## 🎯 상태

**완성도:** 95% (레어리티 & 태그 조정 필요)
**다음:** Steve PM 검수 및 조정 지시 대기

---

**생성 완료:** 2026-03-04 12:47 PST  
**총 소요 시간:** 약 40분 (기획 20분 + 생성 20분)  
**예상 최종 완료:** 2026-03-04 14:00 PST (조정 포함)
