# scripts/combat/turnbased/TurnBasedAutoAI.gd
# 턴베이스 오토 플레이 AI (3단계) — DEV_SPEC_TURNBASED.md 기반
class_name TurnBasedAutoAI
extends Node

enum AutoMode { MANUAL, SEMI, FULL }

var mode : AutoMode = AutoMode.SEMI

signal suggested_card(card: Card)
signal auto_played_card(card: Card)
signal auto_turn_ended

# ── 방어 결정 (적 턴 리액션 윈도우) ─────────────────
func decide_defense(hand: Array[Card], attack: Dictionary, energy: int) -> Card:
	var attack_type = attack.get("type", "NORMAL")

	# 관통 공격 → 회피 전용
	if attack_type == "UNBLOCKABLE":
		for card in hand:
			if card.has_tag("DODGE") and card.cost <= energy:
				return card
		return null  # 회피 카드 없으면 무반응

	# 강한 공격 → 패링 70% 확률로 시도
	var base_atk = attack.get("base_atk", 10)
	if attack.get("damage", 0) > base_atk * 1.3:
		if randf() < 0.70:
			for card in hand:
				if card.has_tag("PARRY") and card.cost <= energy:
					return card

	# 패링 카드 우선 (65% 확률)
	for card in hand:
		if card.has_tag("PARRY") and card.cost <= energy:
			if randf() < 0.65:
				return card

	# 회피 카드
	for card in hand:
		if card.has_tag("DODGE") and card.cost <= energy:
			return card

	# 방어 카드
	for card in hand:
		if card.has_tag("GUARD") and card.cost <= energy:
			return card

	return null  # 대응 불가 → 무반응

# ── 공격 카드 플레이 결정 ─────────────────────────────
func decide_attack_cards(hand: Array[Card], energy: int, enemy, player_hp_ratio: float) -> Array[Card]:
	var selected : Array[Card] = []
	var rem = energy

	# HP 40% 이하 → 방어 카드 우선
	if player_hp_ratio < 0.40:
		for card in hand:
			if card.type == "DEF" and card.cost <= rem:
				selected.append(card)
				rem -= card.cost
				break

	# 디버프 카드 우선 (취약 없으면)
	if enemy and enemy.has_method("has_status") and not enemy.has_status("VULNERABLE"):
		for card in hand:
			if card.cost <= rem:
				for eff in card.status_effects:
					if eff.get("type", "") in ["VULNERABLE", "WEAK"]:
						selected.append(card)
						rem -= card.cost
						break

	# 공격 효율(dmg/cost) 순으로 선택
	var attacks: Array[Card] = []
	for card in hand:
		if card.type == "ATK" and card.cost <= rem and card.cost > 0:
			attacks.append(card)
	attacks.sort_custom(func(a, b): return float(a.damage)/a.cost > float(b.damage)/b.cost)

	for card in attacks:
		if card.cost <= rem and not selected.has(card):
			selected.append(card)
			rem -= card.cost

	# 스킬 카드 (드로우 등)
	for card in hand:
		if card.type == "SKILL" and card.cost <= rem and not selected.has(card):
			selected.append(card)
			rem -= card.cost

	return selected

# ── 세미 오토: 추천 카드 강조 ─────────────────────────
func suggest_next_card(hand: Array[Card], enemy, energy: int, player_hp_ratio: float = 1.0):
	if mode == AutoMode.MANUAL:
		return
	var cards = decide_attack_cards(hand, energy, enemy, player_hp_ratio)
	if cards.size() > 0:
		emit_signal("suggested_card", cards[0])

# ── 풀 오토 플레이 ────────────────────────────────────
func auto_play_turn(hand: Array[Card], enemy, energy: int, player_hp_ratio: float, combat_manager) -> void:
	if mode != AutoMode.FULL:
		return
	var to_play = decide_attack_cards(hand, energy, enemy, player_hp_ratio)
	for card in to_play:
		if combat_manager and "combat_active" in combat_manager and not combat_manager.combat_active:
			break
		await get_tree().create_timer(0.5).timeout
		if combat_manager and combat_manager.has_method("player_play_card"):
			combat_manager.player_play_card(card)
		emit_signal("auto_played_card", card)
	await get_tree().create_timer(0.5).timeout
	emit_signal("auto_turn_ended")

func set_mode(new_mode: AutoMode):
	mode = new_mode
	print("[TBAutoAI] 모드: %s" % AutoMode.keys()[mode])
