# scripts/combat/turnbased/DeckPassiveCalculator.gd
# 덱 구성 분석 → 전투 시작 시 패시브 적용 — DEV_SPEC_TURNBASED.md 기반
class_name DeckPassiveCalculator
extends Node

signal passives_calculated(passives: Array)

func calculate(deck: Array[Card]) -> Array[Dictionary]:
	var passives : Array[Dictionary] = []

	var def_count    = _count_type(deck, "SKILL")
	var atk_count    = _count_type(deck, "ATK")
	var arcana_count = _count_where(deck, func(c): return c.is_major_arcana())
	var parry_count  = _count_where(deck, func(c): return c.has_tag("PARRY"))

	# 달의 기사: SKILL 5장 이상
	if def_count >= 5:
		passives.append({
			"name": "달의 기사",
			"desc": "매 플레이어 턴 시작 시 블록 3 획득",
			"icon": "🛡️",
			"type": "turn_start_block",
			"value": 3,
		})

	# 검의 달인: ATK 7장 이상
	if atk_count >= 7:
		passives.append({
			"name": "검의 달인",
			"desc": "첫 번째 공격 카드 데미지 +2",
			"icon": "⚔️",
			"type": "first_atk_bonus",
			"value": 2,
		})

	# 타로 학자: 메이저 아르카나 3장 이상
	if arcana_count >= 3:
		passives.append({
			"name": "타로 학자",
			"desc": "전투 시작 시 타로 에너지 +1",
			"icon": "🌙",
			"type": "start_tarot",
			"value": 1,
		})

	# 달빛 반격사: PARRY 카드 4장 이상
	if parry_count >= 4:
		passives.append({
			"name": "달빛 반격사",
			"desc": "패링 성공 시 다음 턴 에너지 보너스 +1 추가",
			"icon": "✨",
			"type": "parry_energy_extra",
			"value": 1,
		})

	# 꿈꾸는 자: 파워 카드 3장 이상
	var skill_count = _count_type(deck, "POWER")
	if skill_count >= 3:
		passives.append({
			"name": "꿈꾸는 자",
			"desc": "매 턴 시작 시 꿈 조각 +1",
			"icon": "◆",
			"type": "turn_start_shard",
			"value": 1,
		})

	emit_signal("passives_calculated", passives)
	return passives

func apply_passives(passives: Array[Dictionary], combat_manager) -> void:
	for passive in passives:
		match passive.get("type", ""):
			"turn_start_block":
				# CombatManagerTB의 _start_player_turn에서 매 턴 처리
				if combat_manager and "turn_start_block_bonus" in combat_manager:
					combat_manager.turn_start_block_bonus += passive.get("value", 0)

			"first_atk_bonus":
				if combat_manager and "first_atk_bonus" in combat_manager:
					combat_manager.first_atk_bonus += passive.get("value", 0)

			"start_tarot":
				var tarot = combat_manager.get_node_or_null("TarotEnergySystem")
				if tarot and tarot.has_method("add_tarot"):
					tarot.add_tarot(passive.get("value", 1))

			"parry_energy_extra":
				if combat_manager and "parry_energy_extra" in combat_manager:
					combat_manager.parry_energy_extra += passive.get("value", 0)

			"turn_start_shard":
				if combat_manager and "turn_start_shard_bonus" in combat_manager:
					combat_manager.turn_start_shard_bonus += passive.get("value", 0)

	print("[DeckPassive] 패시브 %d개 적용" % passives.size())

func _count_type(deck: Array[Card], type: String) -> int:
	var count = 0
	for c in deck:
		if c.type == type:
			count += 1
	return count

func _count_where(deck: Array[Card], pred: Callable) -> int:
	var count = 0
	for c in deck:
		if pred.call(c):
			count += 1
	return count
