# 🎴 카드 생성 유틸리티 (Card Generation Scripts)

**목적:** 200개 카드 데이터 자동 생성 및 검증  
**상태:** ✅ 완료  
**최종 업데이트:** 2026-03-06

---

## 📋 스크립트 목록

### 1️⃣ **generate_cards.py**
**목적:** 기본 카드 데이터 생성 유틸리티

**기능:**
- 단일 카드 생성
- JSON 포맷 생성
- 기본 검증

**사용 예:**
```bash
python3 generate_cards.py --count 20 --type ATTACK
```

---

### 2️⃣ **generate_cards_200.py** (권장)
**목적:** 200개 전체 카드 자동 생성 (최신/권장)

**기능:**
- 200개 카드 자동 생성
- 타입별 분배 (ATTACK 50, SKILL 50, POWER 50, CURSE 50)
- 대칭적 밸런싱
- JSON 출력

**사용 예:**
```bash
python3 generate_cards_200.py > cards_200_output.json
```

**출력:**
- `cards_200_output.json` (모든 200개 카드)

---

## 🎴 **카드 데이터 구조**

### 생성되는 JSON 포맷
```json
{
  "id": "card_attack_flame_001",
  "name": "불꽃 공격",
  "type": "ATTACK",
  "description": "적에게 불을 이용한 공격을 한다.",
  "cost": 2,
  "damage": 45,
  "cooldown": 1,
  "rarity": "common",
  "level": 1,
  "effects": {
    "primary": "damage",
    "value": 45,
    "damageType": "fire"
  }
}
```

---

## 📊 **카드 타입별 특성**

| 타입 | 개수 | 특징 | 비용 | 쿨다운 |
|------|------|------|------|--------|
| **ATTACK** | 50개 | 빠른 손상, 낮은 비용 | 1-3 | 0-1 |
| **SKILL** | 50개 | 버프/회피/치유 | 2-4 | 1-2 |
| **POWER** | 50개 | 높은 손상, 높은 비용 | 4-6 | 2-4 |
| **CURSE** | 50개 | 약화/중독 | 2-4 | 1-3 |

---

## 🚀 **사용 가이드**

### 설치 (처음 한 번만)
```bash
cd /Users/stevemacbook/Projects/geekbrox/teams/game/workspace/design/dream-collector/02_core_design/cards/scripts/

# Python 의존성 (필요 시)
pip install -r requirements.txt  # (미제공 - 기본 라이브러리만 사용)
```

### 실행
```bash
# 200개 카드 생성
python3 generate_cards_200.py

# 출력을 파일로 저장
python3 generate_cards_200.py > ~/output/cards_200.json

# 특정 개수만 생성
python3 generate_cards.py --count 10 --type SKILL
```

### 검증
```bash
# 생성된 JSON 검증
python3 -m json.tool cards_200.json

# 카드 개수 확인
python3 -c "import json; data=json.load(open('cards_200.json')); print(f'Total: {len(data)}')"
```

---

## 📈 **생성 결과 예시**

### ATTACK 타입 (50개)
```
🔥 flame_strike (Lv1-3, 무기 스킬)
❄️ frost_arrow (Lv1-3, 기본 공격)
⚡ lightning_bolt (Lv2-4, 전기 공격)
🌪️ wind_slash (Lv1-3, 바람 공격)
🪨 rock_throw (Lv1-2, 토지 공격)
```

### SKILL 타입 (50개)
```
🛡️ shield_bash (방어 + 반격)
✨ heal_touch (회복)
🏃 evasion (회피 + 이동)
💫 buff_attack (공격력 증가)
⚔️ parry (경직)
```

### POWER 타입 (50개)
```
☄️ meteor_strike (광역 피해)
🌊 tidal_wave (물 공격)
💥 explosion (폭발)
🔮 energy_blast (에너지 방출)
⚒️ earth_quake (지진)
```

### CURSE 타입 (50개)
```
☠️ poison_cloud (독)
🦇 drain_life (생명력 흡수)
💀 decay (부패)
🕸️ web (이동 제한)
🔒 seal (능력 봉인)
```

---

## 🔍 **생성된 카드 검증 체크리스트**

- [ ] 총 200개 카드 생성 확인
- [ ] 타입별 50개씩 분배
- [ ] 모든 ID 유니크 확인
- [ ] 필수 필드 존재 (id, name, type, cost, cooldown)
- [ ] 비용 범위 적절 (1-6)
- [ ] 쿨다운 범위 적절 (0-4)
- [ ] 설명 텍스트 모두 입력
- [ ] JSON 포맷 유효성

---

## 🎯 **통합 워크플로우**

### 1️⃣ 카드 생성
```bash
python3 generate_cards_200.py > cards_200.json
```

### 2️⃣ 검증
```bash
python3 -m json.tool cards_200.json > /dev/null  # 문법 검증
```

### 3️⃣ 데이터 복사
```bash
cp cards_200.json ../CARD_200_FINAL_DATA.md  # 문서에 포함
cp cards_200.json ~/../../godot/dream-collector/data/cards_200_v2.json  # 게임 데이터로
```

### 4️⃣ 게임 연동
```gdscript
# CardDatabase.gd
var cards_data = preload("res://data/cards_200_v2.json")
```

---

## 📚 **참고 문서**

### 카드 설계
- **../CARD_200_FINAL_DATA.md** — 200개 카드 최종 데이터
- **../TAROT_SYSTEM_GUIDE.md** — 타로 카드 기본 시스템
- **../CARD_FUNCTION_MAPPING_UNIFIED_v3.md** — 카드 기능 매핑

### 게임 연동
- **../../../godot/dream-collector/scripts/combat/shared/CardDatabase.gd** — 카드 데이터베이스
- **../../../godot/dream-collector/scripts/combat/shared/Card.gd** — 카드 클래스

---

## 💡 **문제 해결**

### 스크립트 실행 실패
```bash
# Python 버전 확인
python3 --version  # 3.8 이상 필요

# 권한 부여
chmod +x generate_cards_200.py

# 직접 실행
/usr/bin/python3 generate_cards_200.py
```

### JSON 파일 깨짐
```bash
# 파일 검증
python3 -m json.tool cards_200.json

# 복구
python3 generate_cards_200.py > cards_200_backup.json
```

### 카드 중복
```bash
# ID 충돌 확인
python3 -c "
import json
data = json.load(open('cards_200.json'))
ids = [c['id'] for c in data]
print(f'Total: {len(ids)}, Unique: {len(set(ids))}')"
```

---

## 🔄 **버전 관리**

| 버전 | 파일 | 설명 |
|------|------|------|
| v1 | generate_cards.py | 기본 생성 유틸 |
| v2 | generate_cards_200.py | 200개 최적화 (현재) |
| (향후) | AI_CardGen.py | LLM 기반 생성 (미계획) |

---

**최종 업데이트:** 2026-03-06  
**상태:** ✅ 완료 및 정렬  
**관리자:** Atlas PM
