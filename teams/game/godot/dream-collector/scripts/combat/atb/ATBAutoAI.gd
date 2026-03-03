# scripts/combat/atb/ATBAutoAI.gd
# ATB 오토 플레이 AI — DEV_SPEC_ATB.md 기반
class_name ATBAutoAI
extends Node

# ── 오토 모드 ────────────────────────────────────────
enum AutoMode {
	MANUAL,      # 수동 — AI 없음
	SEMI,        # 세미 — AI 추천 + 플레이어 확인 탭
	FULL         # 풀오토 — AI가 자동 실행
}

var mode : AutoMode = AutoMode.MANUAL

signal suggested_card(card: Card)
signal auto_played_card(card: Card)

# ── 메인 결정 로직 ────────────────────────────────────
func decide_action(hand: Array[Card], enemy, energy: int) -> Card:
	var intent = {}
	if enemy and enemy.has_method("get_next_action"):
		intent = enemy.get_next_action()

	var enemy_atb = 0.0
	if enemy and "atb" in enemy:
		enemy_atb = enemy.atb

	# 1순위: 적 ATB 80%+ → 방어 준비
	if enemy_atb >= 80.0:
		var best_defense = _pick_best_defense(hand, intent, energy)
		if best_defense:
			return best_defense

	# 2순위: 적 HP 30% 이하 → 전력 공격
	if enemy and enemy.has_method("hp_ratio") and enemy.hp_ratio() <= 0.3:
		var atk = _pick_strongest_attack(hand, energy)
		if atk: return atk

	# 3순위: 상태이상 기회
	if enemy and enemy.has_method("has_status") and not enemy.has_status("VULNERABLE"):
		var debuff = _pick_debuff(hand, energy)
		if debuff: return debuff

	# 기본: 코스트 대비 최고 효율 공격
	var atk = _pick_efficient_attack(hand, energy)
	if atk: return atk
	# 마지막 폴백: 드로우 카드 (패 보충 — SKL 바보 등)
	return _pick_draw_card(hand, energy)

# ── 방어 선택 (오토 시 패링 미선택: 리액션 창에서만 사용) ─────────────────
func _pick_best_defense(hand: Array[Card], intent: Dictionary, energy: int) -> Card:
	# 플레이어 턴에 "낼" 방어 카드: 가드(블록)/회피만. 패링은 리액션 전용이라 여기서는 선택 안 함.
	if intent.get("type", "") == "UNBLOCKABLE":
		for card in hand:
			if card.has_tag("DODGE") and card.cost <= energy:
				return card
	for card in hand:
		if card.has_tag("GUARD") and card.cost <= energy:
			return card
	for card in hand:
		if card.has_tag("DODGE") and card.cost <= energy:
			return card
	return null

func _pick_strongest_attack(hand: Array[Card], energy: int) -> Card:
	var best: Card = null
	for card in hand:
		if card.type == "ATK" and card.cost <= energy:
			if best == null or card.damage > best.damage:
				best = card
	return best

func _pick_debuff(hand: Array[Card], energy: int) -> Card:
	for card in hand:
		if card.cost <= energy:
			for eff in card.status_effects:
				if eff.get("type", "") in ["VULNERABLE", "WEAK", "POISON"]:
					return card
	return null

func _pick_efficient_attack(hand: Array[Card], energy: int) -> Card:
	var best: Card = null
	var best_ratio = 0.0
	for card in hand:
		if card.type == "ATK" and card.cost <= energy:
			# 0코스트 카드: 데미지 값을 효율로 직접 사용 (분모 0 방지)
			var ratio = float(card.damage) if card.cost == 0 else float(card.damage) / card.cost
			if ratio > best_ratio:
				best_ratio = ratio
				best = card
	return best

func _pick_draw_card(hand: Array[Card], energy: int) -> Card:
	# 드로우 카드 선택 (SKL/PAR draw > 0) — ATK 없을 때 패 보충용 폴백
	for card in hand:
		if card.draw > 0 and card.cost <= energy:
			return card
	return null

# ── 세미 오토: 추천 카드 표시 ─────────────────────────
func suggest_card(hand: Array[Card], enemy, energy: int):
	if mode == AutoMode.MANUAL:
		return
	var suggested = decide_action(hand, enemy, energy)
	if suggested:
		emit_signal("suggested_card", suggested)

# ── 풀 오토 루프 ─────────────────────────────────────
func auto_play_turn(hand: Array[Card], enemy, energy: int, combat_manager):
	if mode != AutoMode.FULL:
		return
	var rem_energy = energy
	var rem_hand = hand.duplicate()
	while rem_energy > 0 and rem_hand.size() > 0:
		var card = decide_action(rem_hand, enemy, rem_energy)
		if card == null:
			break
		await get_tree().create_timer(0.4).timeout
		if combat_manager and combat_manager.has_method("player_play_card"):
			combat_manager.player_play_card(card)
		rem_hand.erase(card)
		rem_energy -= card.cost
		emit_signal("auto_played_card", card)

func set_mode(new_mode: AutoMode):
	mode = new_mode
	print("[ATBAutoAI] Mode: %s" % AutoMode.keys()[mode])
