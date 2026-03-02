# scripts/combat/shared/CardDatabase.gd
# 카드 데이터베이스 — 30종 카드 전체 정의
# DEV_SPEC_SHARED.md 기반
# ※ class_name 미사용 — autoload 이름 "CardDatabase"와 충돌 방지
extends Node

# 전체 카드 목록 캐시
var _all_cards: Array[Card] = []

func _ready():
	_build_all_cards()

func _build_all_cards():
	_all_cards.clear()

	# ═══════════════════════════════════════
	# 공격 카드 (ATK) — 10장
	# ═══════════════════════════════════════

	# ATK_001 — 검의 에이스 (단타)
	_all_cards.append(_make("ATK_001", "검의 에이스", 1, "ATK", 6, 0, 0,
		[], ["MAJOR_ARCANA"], "COMMON",
		"단순하지만 확실한 일격. 적에게 6 피해를 입힙니다.",
		"⚔️6"))

	# ATK_002 — 이중 베기 (2회 공격)
	var atk002 = _make("ATK_002", "이중 베기", 2, "ATK", 9, 0, 0,
		[], [], "COMMON",
		"2회 연속 공격. 각 4.5 피해를 입힙니다 (총 9).",
		"⚔️4.5×2")
	_all_cards.append(atk002)

	# ATK_003 — 마법사 (광역)
	var atk003 = _make("ATK_003", "마법사", 2, "ATK", 4, 0, 0,
		[], ["MAJOR_ARCANA"], "RARE",
		"마법의 힘으로 모든 적에게 4 피해를 입힙니다.",
		"⚔️4 전체")
	atk003.tags.append("AOE")
	_all_cards.append(atk003)

	# ATK_004 — 탑 (강타, 자해)
	var atk004 = _make("ATK_004", "탑", 2, "ATK", 15, 0, 0,
		[{"target": "self", "type": "POISON", "value": 3}], ["MAJOR_ARCANA"], "RARE",
		"강력한 일격으로 15 피해. 그러나 자신에게 중독 3을 얻습니다.",
		"⚔️15 (자해 🤢3)")
	_all_cards.append(atk004)

	# ATK_005 — 세계 (복합)
	var atk005 = _make("ATK_005", "세계", 4, "ATK", 20, 10, 0,
		[], ["MAJOR_ARCANA"], "LEGENDARY",
		"강력한 일격으로 20 피해를 입히고 블록 10을 획득합니다.",
		"⚔️20 🛡️10")
	_all_cards.append(atk005)

	# ATK_006 — 번개 (단타)
	_all_cards.append(_make("ATK_006", "번개", 1, "ATK", 8, 0, 0,
		[], [], "COMMON",
		"번개처럼 빠른 공격. 적에게 8 피해를 입힙니다.",
		"⚔️8"))

	# ATK_007 — 악마 (광역 디버프)
	var atk007 = _make("ATK_007", "악마", 2, "ATK", 5, 0, 0,
		[{"target": "enemy", "type": "POISON", "value": 3}], ["MAJOR_ARCANA"], "RARE",
		"어둠의 힘으로 모든 적에게 5 피해와 중독 3을 부여합니다.",
		"⚔️5 전체 🤢+3")
	atk007.tags.append("AOE")
	_all_cards.append(atk007)

	# ATK_008 — 태양 (강타)
	_all_cards.append(_make("ATK_008", "태양", 3, "ATK", 18, 0, 0,
		[], ["MAJOR_ARCANA"], "RARE",
		"태양의 빛으로 적에게 18 피해를 입힙니다.",
		"⚔️18"))

	# ATK_009 — 별 (유틸 공격)
	_all_cards.append(_make("ATK_009", "별", 2, "ATK", 7, 0, 1,
		[], ["MAJOR_ARCANA"], "COMMON",
		"적에게 7 피해를 입히고 카드를 1장 드로우합니다.",
		"⚔️7 ✨드로우1"))

	# ATK_010 — 황제 (버프 공격)
	var atk010 = _make("ATK_010", "황제", 3, "ATK", 12, 0, 0,
		[{"target": "self", "type": "STRENGTH", "value": 2}], ["MAJOR_ARCANA"], "SPECIAL",
		"적에게 12 피해를 입히고 힘 +2를 영구 획득합니다.",
		"⚔️12 💪+2")
	_all_cards.append(atk010)

	# ═══════════════════════════════════════
	# 방어 카드 (DEF) — 8장
	# ═══════════════════════════════════════

	# DEF_001 — 방패의 왕
	_all_cards.append(_make("DEF_001", "방패의 왕", 2, "DEF", 0, 12, 0,
		[], ["GUARD"], "COMMON",
		"블록 12을 획득합니다.",
		"🛡️12"))

	# DEF_002 — 철벽
	_all_cards.append(_make("DEF_002", "철벽", 1, "DEF", 0, 5, 0,
		[], ["GUARD"], "COMMON",
		"저비용으로 블록 5를 획득합니다.",
		"🛡️5"))

	# DEF_003 — 여황제
	_all_cards.append(_make("DEF_003", "여황제", 3, "DEF", 0, 18, 0,
		[], ["GUARD", "MAJOR_ARCANA"], "RARE",
		"강력한 보호막. 블록 18을 획득합니다.",
		"🛡️18"))

	# DEF_004 — 교황 (방어+드로우)
	_all_cards.append(_make("DEF_004", "교황", 2, "DEF", 0, 8, 1,
		[], ["GUARD", "MAJOR_ARCANA"], "COMMON",
		"블록 8을 획득하고 카드를 1장 드로우합니다.",
		"🛡️8 ✨드로우1"))

	# DEF_005 — 달 (방어+민첩)
	var def005 = _make("DEF_005", "달", 2, "DEF", 0, 10, 0,
		[{"target": "self", "type": "DEXTERITY", "value": 1}], ["GUARD", "MAJOR_ARCANA"], "RARE",
		"블록 10을 획득하고 민첩 +1을 영구 획득합니다.",
		"🛡️10 👟+1")
	_all_cards.append(def005)

	# DEF_006 — 정의 (균형)
	_all_cards.append(_make("DEF_006", "정의", 1, "DEF", 0, 7, 0,
		[], ["GUARD", "MAJOR_ARCANA"], "COMMON",
		"균형 잡힌 방어. 블록 7을 획득합니다.",
		"🛡️7"))

	# DEF_007 — 은둔자 (순수 방어)
	_all_cards.append(_make("DEF_007", "은둔자", 2, "DEF", 0, 15, 0,
		[], ["GUARD", "MAJOR_ARCANA"], "RARE",
		"강력한 순수 방어. 블록 15를 획득합니다.",
		"🛡️15"))

	# DEF_008 — 절제 (소량 치유)
	var def008 = _make("DEF_008", "절제", 1, "DEF", 0, 4, 0,
		[], ["GUARD", "MAJOR_ARCANA"], "COMMON",
		"블록 4를 획득하고 HP 2를 회복합니다.",
		"🛡️4 ❤️+2")
	def008.status_effects.append({"target": "self", "type": "HEAL", "value": 2})
	_all_cards.append(def008)

	# ═══════════════════════════════════════
	# 패링 카드 (PARRY 태그) — 5장
	# ═══════════════════════════════════════

	# PAR_001 — 꿈의 쳐내기
	_all_cards.append(_make("PAR_001", "꿈의 쳐내기", 0, "DEF", 0, 0, 1,
		[], ["PARRY"], "COMMON",
		"[패링] 적 공격 무효 + 에너지 +2(다음 행동) + 카드 드로우 1장.",
		"🥋 패링 ⚡+2 드로우1"))

	# PAR_002 — 반사의 순간 (30% 반격)
	var par002 = _make("PAR_002", "반사의 순간", 0, "DEF", 0, 0, 0,
		[], ["PARRY"], "RARE",
		"[패링] 적 공격 무효 + 에너지 +2 + 30% 확률로 반격 데미지.",
		"🥋 패링 ⚡+2 반격30%")
	_all_cards.append(par002)

	# PAR_003 — 각성의 쳐내기 (타이트한 윈도우, 에너지 +3)
	var par003 = _make("PAR_003", "각성의 쳐내기", 0, "DEF", 0, 0, 0,
		[], ["PARRY"], "SPECIAL",
		"[패링] 0.3초의 좁은 윈도우. 성공 시 에너지 +3.",
		"🥋★ 패링 ⚡+3 (0.3초)")
	_all_cards.append(par003)

	# PAR_004 — 달빛 반격 (에너지 비용 1, 반격 8)
	var par004 = _make("PAR_004", "달빛 반격", 1, "DEF", 8, 0, 0,
		[], ["PARRY"], "RARE",
		"[패링] 에너지 1 소모. 적 공격 무효 + 에너지 +1 + 반격 8.",
		"🥋 패링 ⚡+1 ⚔️8")
	_all_cards.append(par004)

	# PAR_005 — 완벽한 방어 (패링/회피 겸용, 오토 시 회피 성공률 50%)
	var par005 = _make("PAR_005", "완벽한 방어", 0, "DEF", 0, 0, 0,
		[], ["PARRY", "DODGE"], "SPECIAL",
		"[패링/회피 겸용] 어떤 공격도 무효화. 에너지 +1.",
		"🥋🌀 패링+회피 ⚡+1")
	par005.auto_dodge_success_rate = 0.5
	_all_cards.append(par005)

	# ═══════════════════════════════════════
	# 회피 카드 (DODGE 태그) — 5장
	# ═══════════════════════════════════════

	# DOD_001 — 꿈의 스텝 (오토 시 성공률 50%)
	var dod001 = _make("DOD_001", "꿈의 스텝", 0, "DEF", 0, 0, 0,
		[], ["DODGE"], "COMMON",
		"[회피] 적 공격을 회피. 에너지 +1(다음 행동).",
		"🌀 회피 ⚡+1")
	dod001.auto_dodge_success_rate = 0.5
	_all_cards.append(dod001)

	# DOD_002 — 잔상 (오토 시 성공률 55%)
	var dod002 = _make("DOD_002", "잔상", 0, "DEF", 0, 0, 0,
		[], ["DODGE"], "RARE",
		"[회피] 적 공격을 회피. 에너지 +1 + 버프 효과 이전.",
		"🌀 회피 ⚡+1 버프이전")
	dod002.auto_dodge_success_rate = 0.55
	_all_cards.append(dod002)

	# DOD_003 — 황혼의 도약 (오토 시 성공률 60%)
	var dod003 = _make("DOD_003", "황혼의 도약", 0, "DEF", 0, 0, 0,
		[{"target": "self", "type": "STRENGTH", "value": 3}], ["DODGE"], "RARE",
		"[회피] 적 공격을 회피. 에너지 +1 + 다음 공격 +3.",
		"🌀 회피 ⚡+1 ⚔️+3")
	dod003.auto_dodge_success_rate = 0.6
	_all_cards.append(dod003)

	# DOD_004 — 연막 (오토 시 성공률 50%)
	var dod004 = _make("DOD_004", "연막", 1, "DEF", 0, 0, 0,
		[{"target": "enemy", "type": "WEAK", "value": 2}], ["DODGE"], "RARE",
		"[회피] 에너지 1 소모. 적 공격을 회피 + 에너지 +1 + 적 약화 2.",
		"🌀 회피(1) ⚡+1 👁️-3")
	dod004.auto_dodge_success_rate = 0.5
	_all_cards.append(dod004)

	# DOD_005 — 반보 앞으로 (패링/회피 겸용, 오토 시 회피 성공률 45%)
	var dod005 = _make("DOD_005", "반보 앞으로", 0, "DEF", 0, 0, 0,
		[], ["DODGE", "PARRY"], "COMMON",
		"[패링/회피] 피해 50% 감소. 에너지 +1.",
		"🌀🥋 반회피 ⚡+1")
	dod005.auto_dodge_success_rate = 0.45
	_all_cards.append(dod005)

	# ═══════════════════════════════════════
	# 스킬 카드 (SKILL) — 2장
	# ═══════════════════════════════════════

	# SKL_001 — 바보 (드로우+에너지)
	_all_cards.append(_make("SKL_001", "바보", 0, "SKILL", 0, 0, 1,
		[], ["MAJOR_ARCANA"], "COMMON",
		"카드를 1장 드로우하고 에너지 +1을 즉시 획득합니다.",
		"✨드로우1 ⚡+1"))

	# SKL_002 — 달의 환영 (드로우3)
	var skl002 = _make("SKL_002", "달의 환영", 2, "SKILL", 0, 0, 3,
		[], ["MAJOR_ARCANA"], "RARE",
		"카드를 3장 드로우합니다. (타로 에너지 2 소모 버전도 존재)",
		"✨드로우3")
	_all_cards.append(skl002)

	print("[CardDatabase] 카드 %d장 로드 완료" % _all_cards.size())

# ── 카드 생성 헬퍼 ──────────────────────────────────
# ※ status_effects / tags 는 Array[Dictionary] / Array[String] 타입 배열이므로
#    .assign()으로 명시적 변환 후 대입 (단순 대입 시 런타임 크래시)
func _make(p_id: String, p_name: String, p_cost: int, p_type: String,
		p_damage: int, p_block: int, p_draw: int,
		p_status_effects: Array, p_tags: Array, p_rarity: String,
		p_desc: String, p_short_desc: String) -> Card:
	var c = Card.new()
	c.id = p_id
	c.name = p_name
	c.cost = p_cost
	c.type = p_type
	c.damage = p_damage
	c.block = p_block
	c.draw = p_draw
	# Array[Dictionary] 변환 — 비타입 Array → 타입 배열
	var typed_se: Array[Dictionary] = []
	typed_se.assign(p_status_effects)
	c.status_effects = typed_se
	# Array[String] 변환
	var typed_tags: Array[String] = []
	typed_tags.assign(p_tags)
	c.tags = typed_tags
	c.rarity = p_rarity
	c.description = p_desc
	c.short_desc = p_short_desc
	return c

# ── 조회 함수 ─────────────────────────────────────────
func get_all() -> Array[Card]:
	return _all_cards.duplicate()

func get_by_id(id: String) -> Card:
	for c in _all_cards:
		if c.id == id:
			return c
	return null

func get_by_type(type: String) -> Array[Card]:
	var result: Array[Card] = []
	for c in _all_cards:
		if c.type == type:
			result.append(c)
	return result

func get_starter_deck() -> Array[Card]:
	# 기본 스타터 덱 구성 (10장)
	var starter_ids = [
		"ATK_001", "ATK_001", "ATK_006",  # 공격 3장
		"DEF_002", "DEF_002", "DEF_006",  # 방어 3장
		"PAR_001", "PAR_001",              # 패링 2장
		"DOD_001",                          # 회피 1장
		"SKL_001",                          # 스킬 1장
	]
	var result: Array[Card] = []
	for id in starter_ids:
		var card = get_by_id(id)
		if card:
			result.append(card.duplicate_card())
	return result

## 30장 풀 덱 — ATK 10, DEF 8, PARRY 5, DODGE 5, SKILL 2
func get_full_deck_30() -> Array[Card]:
	var ids: Array[String] = []
	# ATK 10장
	ids.append_array(["ATK_001", "ATK_002", "ATK_003", "ATK_004", "ATK_005",
		"ATK_006", "ATK_007", "ATK_008", "ATK_009", "ATK_010"])
	# DEF 8장
	ids.append_array(["DEF_001", "DEF_002", "DEF_003", "DEF_004", "DEF_005",
		"DEF_006", "DEF_007", "DEF_008"])
	# PARRY 5장
	ids.append_array(["PAR_001", "PAR_002", "PAR_003", "PAR_004", "PAR_005"])
	# DODGE 5장
	ids.append_array(["DOD_001", "DOD_002", "DOD_003", "DOD_004", "DOD_005"])
	# SKILL 2장
	ids.append_array(["SKL_001", "SKL_002"])
	var result: Array[Card] = []
	for id in ids:
		var card = get_by_id(id)
		if card:
			result.append(card.duplicate_card())
	result.shuffle()
	return result

func get_random_reward_cards(count: int = 3) -> Array[Card]:
	# 전투 보상용 랜덤 카드 선택
	var pool = _all_cards.duplicate()
	pool.shuffle()
	var result: Array[Card] = []
	for i in range(min(count, pool.size())):
		result.append(pool[i].duplicate_card())
	return result
