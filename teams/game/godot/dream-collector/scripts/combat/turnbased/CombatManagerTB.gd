# scripts/combat/turnbased/CombatManagerTB.gd
# 턴베이스 전투 중앙 관리자 — 보스 전투용. 일반 전투는 CombatManagerATB.
class_name CombatManagerTB
extends Node

const DEBUG_COMBAT := false  # true: 전투/턴 로그 출력

# ── 턴 상태 ──────────────────────────────────────────
enum TurnPhase {
	PLAYER_TURN,        # 플레이어 카드 플레이 단계
	PLAYER_END,         # 턴 종료 처리
	ENEMY_TURN_BEGIN,   # 적 행동 발표
	ENEMY_ATTACKING,    # 적 공격 실행 + 리액션 윈도우
	ENEMY_TURN_END,     # 상태이상 처리
	CHECK_END,          # 전투 종료 체크
}

var current_phase : TurnPhase = TurnPhase.PLAYER_TURN
var turn_count    : int = 0
var combat_active : bool = false
# 액션 턴 큐 UI용: 적 턴일 때 현재 행동 중인 적 인덱스 (-1 = 플레이어 턴)
var current_acting_enemy_index : int = -1

# ── 서브시스템 ─────────────────────────────────────────
@onready var energy_system   : TurnBasedEnergySystem    = $TurnBasedEnergySystem
@onready var reaction_mgr    : TurnBasedReactionManager = $TurnBasedReactionManager
@onready var intent_system   : TurnBasedIntentSystem    = $TurnBasedIntentSystem
@onready var hand_system     : TurnBasedHandSystem      = $TurnBasedHandSystem
@onready var tarot_system    : TarotEnergySystem        = $TarotEnergySystem
@onready var shard_system    : DreamShardSystem         = $DreamShardSystem
@onready var deck_passive    : DeckPassiveCalculator    = $DeckPassiveCalculator
@onready var auto_ai         : TurnBasedAutoAI          = $TurnBasedAutoAI
@onready var battle_diary    : BattleDiary              = $BattleDiary

# ── 데이터 ────────────────────────────────────────────
var enemies        : Array = []       # Array[Monster]
var player_data    : Dictionary = {}  # HP, ATK, 블록 등

# ── 덱 패시브 보너스 값 ──────────────────────────────
var turn_start_block_bonus : int = 0
var first_atk_bonus        : int = 0
var parry_energy_extra     : int = 0
var turn_start_shard_bonus : int = 0
var first_atk_used         : bool = false

# ── 시그널 ────────────────────────────────────────────
signal combat_started
signal combat_ended(result: String)    # "WIN" | "LOSE"
signal player_turn_started(energy: int, hand: Array[Card])
signal enemy_turn_started(enemy_name: String)
signal turn_count_updated(n: int)
signal player_hp_changed(hp: int, max_hp: int, block: int)
signal enemy_hp_changed(enemy_idx: int, hp: int, max_hp: int)
signal damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool)
signal energy_updated(current: int, base: int)
signal hand_updated(hand: Array[Card])
signal shard_updated(current: int, max_s: int)
signal tarot_updated(current: int, max_t: int)
signal deck_passive_activated(passives: Array)
signal battle_log_updated(message: String)
signal reaction_feedback(text: String, result_type: String, enemy_idx: int) # hero 머리 위 텍스트

# ── 전투 시작 ─────────────────────────────────────────
func _ready():
	# 서브시스템 시그널 연결
	if energy_system:
		energy_system.energy_changed.connect(func(cur, base): emit_signal("energy_updated", cur, base))
	if hand_system:
		hand_system.hand_updated.connect(func(h): emit_signal("hand_updated", h))
	if tarot_system:
		tarot_system.tarot_energy_changed.connect(func(cur, mx): emit_signal("tarot_updated", cur, mx))
	if shard_system:
		shard_system.shards_changed.connect(func(cur, mx): emit_signal("shard_updated", cur, mx))
	if reaction_mgr:
		reaction_mgr.setup(energy_system)
	if auto_ai:
		auto_ai.auto_turn_ended.connect(func(): player_end_turn())

func start_combat(p_data: Dictionary, enemy_list: Array, card_deck: Array[Card]):
	player_data = p_data.duplicate()
	player_data["block"] = 0
	enemies.clear()
	for e in enemy_list:
		enemies.append(e)

	# 서브시스템 초기화 — 전투 시작 3에너지, 매 턴 시작 시 새로 3 (시간 충전 없음)
	if hand_system:
		hand_system.initialize(card_deck)
	if energy_system:
		energy_system.reset()
	if tarot_system:
		tarot_system.reset()
	if shard_system:
		shard_system.setup(energy_system, hand_system, player_data)
		shard_system.reset()
	if battle_diary:
		battle_diary.start()

	combat_active = true
	turn_count = 0
	first_atk_used = false

	# 덱 패시브 계산 및 적용
	if deck_passive:
		var passives = deck_passive.calculate(card_deck)
		deck_passive.apply_passives(passives, self)
		emit_signal("deck_passive_activated", passives)

	if DEBUG_COMBAT:
		print("[TB] 보스 전투 시작 적 %d마리" % enemies.size())
	emit_signal("combat_started")
	# UI 초기 HP 동기화 (InRun_v4 character_nodes ↔ enemies 매핑)
	for i in range(enemies.size()):
		var e = enemies[i]
		if e.is_alive():
			emit_signal("enemy_hp_changed", i, e.current_hp, e.max_hp)
	_start_player_turn()

# ── 플레이어 턴 시작 ──────────────────────────────────
func _start_player_turn():
	current_phase = TurnPhase.PLAYER_TURN
	current_acting_enemy_index = -1
	turn_count += 1
	first_atk_used = false
	emit_signal("turn_count_updated", turn_count)

	# 플레이어 HP/블록 UI 동기화
	emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))

	# 매 턴마다 새로 3에너지 (+ 패링/회피 보너스)
	if energy_system:
		energy_system.start_player_turn()

	# 턴 시작 블록 패시브
	if turn_start_block_bonus > 0:
		player_data["block"] = player_data.get("block", 0) + turn_start_block_bonus
		emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))

	# 턴 시작 꿈 조각 패시브
	if turn_start_shard_bonus > 0 and shard_system:
		shard_system.gain_shard(turn_start_shard_bonus)

	# 드로우 5장 (+ 패링 보너스 드로우)
	var draw_count = 5
	if reaction_mgr:
		draw_count += reaction_mgr.pending_draw_bonus
		reaction_mgr.pending_draw_bonus = 0
	if hand_system:
		hand_system.draw_to_hand(draw_count)

	# 의도 확인
	if intent_system:
		intent_system.display_all_enemies()

	var energy = energy_system.get_current() if energy_system else 3
	var hand   = hand_system.get_hand() if hand_system else []
	emit_signal("player_turn_started", energy, hand)
	if battle_diary:
		battle_diary.record_turn()
		battle_diary.log("턴 %d 시작 (에너지: %d)" % [turn_count, energy])

	# 오토 AI 처리
	if auto_ai and auto_ai.mode == TurnBasedAutoAI.AutoMode.FULL:
		var hp_ratio = float(player_data.get("hp", 200)) / float(player_data.get("max_hp", 200))
		var enemy = enemies[0] if not enemies.is_empty() else null
		await auto_ai.auto_play_turn(hand, enemy, energy, hp_ratio, self)
	elif auto_ai and auto_ai.mode == TurnBasedAutoAI.AutoMode.SEMI:
		var hp_ratio = float(player_data.get("hp", 200)) / float(player_data.get("max_hp", 200))
		var enemy = enemies[0] if not enemies.is_empty() else null
		auto_ai.suggest_next_card(hand, enemy, energy, hp_ratio)

# ── 카드 플레이 (플레이어 입력) ──────────────────────
func player_play_card(card: Card, target_index: int = -1):
	# 적 턴 리액션 윈도우 중 카드 탭
	if current_phase == TurnPhase.ENEMY_ATTACKING and reaction_mgr:
		reaction_mgr.on_player_card_tapped(card)
		return

	if current_phase != TurnPhase.PLAYER_TURN:
		return
	if energy_system == null or not energy_system.can_afford(card.cost):
		return

	energy_system.spend(card.cost)
	_resolve_card_effect(card, target_index)
	if hand_system:
		hand_system.discard_card(card)
	if tarot_system:
		tarot_system.on_card_played(card)
	if shard_system:
		shard_system.on_card_played(card)
	if battle_diary:
		battle_diary.record_card_played()
	_check_battle_end()

func _resolve_card_effect(card: Card, target_index: int = -1):
	# 공격 카드
	if card.type == "ATK":
		var base_dmg = card.damage
		if not first_atk_used and first_atk_bonus > 0:
			base_dmg += first_atk_bonus
			first_atk_used = true
		var is_aoe = card.has_tag("AOE")
		if is_aoe:
			for enemy in enemies:
				if enemy.is_alive():
					var dmg = _calc_player_damage(base_dmg, enemy)
					enemy.take_damage(dmg)
					if battle_diary: battle_diary.record_damage_dealt(dmg)
					var idx = enemies.find(enemy)
					emit_signal("damage_dealt", "monster", idx, dmg, false)
					emit_signal("enemy_hp_changed", idx, enemy.current_hp, enemy.max_hp)
		else:
			var target_enemy = null
			if target_index >= 0 and target_index < enemies.size() and enemies[target_index].is_alive():
				target_enemy = enemies[target_index]
			else:
				for enemy in enemies:
					if enemy.is_alive():
						target_enemy = enemy
						break
			if target_enemy:
				var dmg = _calc_player_damage(base_dmg, target_enemy)
				target_enemy.take_damage(dmg)
				if battle_diary: battle_diary.record_damage_dealt(dmg)
				var idx = enemies.find(target_enemy)
				emit_signal("damage_dealt", "monster", idx, dmg, false)
				emit_signal("enemy_hp_changed", idx, target_enemy.current_hp, target_enemy.max_hp)

	# 방어 카드
	if card.block > 0:
		var actual_block = card.block
		# 민첩 보너스
		var dex = player_data.get("status_effects", {}).get("DEXTERITY", 0)
		actual_block += dex
		player_data["block"] = player_data.get("block", 0) + actual_block
		emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))

	# 상태이상
	for eff in card.status_effects:
		var target_type = eff.get("target", "enemy")
		var eff_type = eff.get("type", "POISON")
		var eff_val = eff.get("value", 1)
		if target_type == "enemy":
			for enemy in enemies:
				if enemy.is_alive():
					StatusEffectSystem.apply_to(enemy, eff_type, eff_val)
		elif target_type == "self":
			var p_status = player_data.get("status_effects", {})
			p_status[eff_type] = p_status.get(eff_type, 0) + eff_val
			player_data["status_effects"] = p_status

	# 드로우
	if card.draw > 0 and hand_system:
		hand_system.draw_cards(card.draw)

func _calc_player_damage(base: int, enemy) -> int:
	"""플레이어→적 데미지 (블록은 Monster.take_damage에서 처리)"""
	var dmg = base
	# 힘 보너스
	var strength = player_data.get("status_effects", {}).get("STRENGTH", 0)
	dmg += strength
	# 적 취약
	if enemy.has_status("VULNERABLE"):
		dmg = int(dmg * 1.5)
	# 플레이어 약화
	if player_data.get("status_effects", {}).get("WEAK", 0) > 0:
		dmg = int(dmg * 0.75)
	return max(0, dmg)

# ── 턴 종료 (플레이어 버튼 또는 AI 완료) ────────────
func player_end_turn():
	if current_phase != TurnPhase.PLAYER_TURN:
		return
	current_phase = TurnPhase.PLAYER_END

	# 미사용 카드는 적 턴(리액션 윈도우) 종료 후에 버림 — 보스 공격 턴에 패링/회피/가드 버튼 사용 가능
	# (discard_remaining은 _start_enemy_turns 마지막에 호출)

	# 블록 소멸 (기본값)
	player_data["block"] = 0
	emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))

	# 적 턴 시작
	await get_tree().create_timer(0.3).timeout
	_start_enemy_turns()

# ── 적 턴 ─────────────────────────────────────────────
func _start_enemy_turns():
	for enemy in enemies:
		if not combat_active:
			return
		if not enemy.is_alive():
			continue
		emit_signal("enemy_turn_started", enemy.display_name if "display_name" in enemy else "적")
		await _enemy_perform_action(enemy)
		if not combat_active:
			return
		if player_data.get("hp", 1) <= 0:
			_check_battle_end()
			return

	# 적 턴 종료 후 미사용 카드 버림 (리액션 윈도우 동안 손패 유지)
	if hand_system:
		hand_system.discard_remaining()

	# 상태이상 틱 (모든 적)
	for enemy in enemies:
		if enemy.is_alive() and enemy.status_effects is Dictionary:
			var keys_to_erase = []
			for status_key in enemy.status_effects.keys():
				if enemy.status_effects[status_key] <= 0:
					keys_to_erase.append(status_key)
					continue
				if status_key in ["POISON", "BURNING"]:
					var dmg = enemy.status_effects[status_key]
					enemy.take_damage(dmg)
					enemy.status_effects[status_key] -= 1
					var idx = enemies.find(enemy)
					emit_signal("damage_dealt", "monster", idx, dmg, false)
					emit_signal("enemy_hp_changed", idx, enemy.current_hp, enemy.max_hp)
				elif status_key in ["VULNERABLE", "WEAK"]:
					enemy.status_effects[status_key] -= 1
				elif status_key == "ENTANGLED":
					enemy.status_effects[status_key] = 0
				if enemy.status_effects.get(status_key, 0) <= 0:
					keys_to_erase.append(status_key)
			for k in keys_to_erase:
				enemy.status_effects.erase(k)

	_check_battle_end()
	if not combat_active:
		return

	# 다음 플레이어 턴
	current_acting_enemy_index = -1
	await get_tree().create_timer(0.3).timeout
	if combat_active:
		_start_player_turn()

func _enemy_perform_action(enemy):
	current_phase = TurnPhase.ENEMY_ATTACKING
	current_acting_enemy_index = enemies.find(enemy) if enemy in enemies else -1
	var action = enemy.get_next_action()
	var attack_data = enemy.make_attack_data()

	if intent_system:
		intent_system.highlight_current(enemy)
	await get_tree().create_timer(0.5).timeout  # 연출 대기

	# 리액션 윈도우 오픈
	if reaction_mgr:
		reaction_mgr.open_window(attack_data)
		await reaction_mgr.reaction_resolved
	else:
		await get_tree().create_timer(0.3).timeout

	# 결과 적용
	var result = reaction_mgr.last_result if reaction_mgr else null
	_apply_action_result(enemy, attack_data, result)
	if intent_system:
		intent_system.advance(enemy)
	_check_battle_end()

func _apply_action_result(enemy, attack: Dictionary, result):
	if result == null:
		result = TurnBasedReactionManager.ReactionResult.new("NONE", null, 0)

	var attacker_name = enemy.display_name if enemy and "display_name" in enemy else "???"
	var enemy_idx = enemies.find(enemy) if enemy else -1

	match result.type:
		"PARRY":
			if battle_diary:
				battle_diary.record_parry(true)
				battle_diary.log("패링! 에너지 +2 다음 턴")
			if shard_system: shard_system.gain_shard(1)  # 패링 → 꿈 조각 +1
			# parry_energy_extra 패시브 적용
			if parry_energy_extra > 0 and energy_system:
				energy_system.on_parry_success()  # +2에 추가
			emit_signal("reaction_feedback", "패링 성공!", "PARRY", enemy_idx)
			if DEBUG_COMBAT: print("[TB] 패링 성공")

		"DODGE":
			if battle_diary:
				battle_diary.record_dodge()
				battle_diary.log("회피 성공!")
			emit_signal("reaction_feedback", "회피 성공!", "DODGE", enemy_idx)
			if DEBUG_COMBAT: print("[TB] 회피 성공")

		"GUARD":
			# 가드: 가드 수치만큼 피해 경감 (블록으로 흡수 처리)
			player_data["block"] = player_data.get("block", 0) + result.block_value
			var dmg_guarded = _calc_enemy_damage(attack, player_data)
			player_data["hp"] = max(0, player_data.get("hp", 200) - dmg_guarded)
			if battle_diary: battle_diary.record_damage_taken(dmg_guarded)
			emit_signal("damage_dealt", "hero", 0, dmg_guarded, false)
			emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
			battle_log("가드! (%s) 피해 %d" % [attacker_name, dmg_guarded])
			emit_signal("reaction_feedback", "가드", "GUARD", enemy_idx)

		"NONE":
			var dmg_attack = attack.duplicate()
			var fail_type = reaction_mgr.last_failed_attempt_type if reaction_mgr and "last_failed_attempt_type" in reaction_mgr else ""
			if fail_type == "PARRY":
				dmg_attack["damage"] = int(dmg_attack.get("damage", 10) * 1.5)
			elif fail_type == "DODGE":
				dmg_attack["damage"] = int(dmg_attack.get("damage", 10) * 1.2)

			var dmg = _calc_enemy_damage(dmg_attack, player_data)
			player_data["hp"] = max(0, player_data.get("hp", 200) - dmg)
			if battle_diary: battle_diary.record_damage_taken(dmg)
			emit_signal("damage_dealt", "hero", 0, dmg, false)
			emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
			if fail_type == "PARRY":
				battle_log("패링 실패! (%s) 피해 %d (+50%%)" % [attacker_name, dmg])
				emit_signal("reaction_feedback", "패링 실패!", "PARRY_FAIL", enemy_idx)
			elif fail_type == "DODGE":
				battle_log("회피 실패! (%s) 피해 %d (+20%%)" % [attacker_name, dmg])
				emit_signal("reaction_feedback", "회피 실패!", "DODGE_FAIL", enemy_idx)
			if DEBUG_COMBAT: print("[TB] 피해 %d 받음" % dmg)

func _calc_enemy_damage(attack: Dictionary, target: Dictionary) -> int:
	var dmg = attack.get("damage", 10)
	if target.get("status_effects", {}).get("VULNERABLE", 0) > 0:
		dmg = int(dmg * 1.5)
	var attacker = attack.get("attacker", null)
	if attacker and attacker.has_method("has_status") and attacker.has_status("WEAK"):
		dmg = int(dmg * 0.75)
	var block = target.get("block", 0)
	var after_block = max(0, dmg - block)
	target["block"] = max(0, block - dmg)
	return after_block

# ── 전투 종료 ─────────────────────────────────────────
func _check_battle_end():
	if player_data.get("hp", 1) <= 0:
		_end_combat("LOSE")
	elif _all_enemies_dead():
		_end_combat("WIN")

func _all_enemies_dead() -> bool:
	for enemy in enemies:
		if enemy.is_alive():
			return false
	return true

func _end_combat(result: String):
	if not combat_active:
		return
	combat_active = false
	current_phase = TurnPhase.CHECK_END
	if DEBUG_COMBAT and battle_diary:
		var report = battle_diary.compile_report()
		print("[TB] 전투 종료: %s 턴 %d" % [result, turn_count])
	emit_signal("combat_ended", result)

# ── 꿈 조각 능력 사용 ─────────────────────────────────
func use_shard_ability(ability: int):
	if shard_system:
		shard_system.spend(ability as DreamShardSystem.ShardAbility)

# ── 타로 스킬 사용 ────────────────────────────────────
func use_tarot_skill(skill_name: String):
	if tarot_system == null:
		return
	match skill_name:
		"달의 환영":
			if tarot_system.spend_tarot(2):
				if hand_system: hand_system.draw_cards(3)
				if energy_system: energy_system.spend(-1)
				if battle_diary: battle_diary.record_tarot_used()
		"태양의 폭발":
			if tarot_system.spend_tarot(3):
				for enemy in enemies:
					if enemy.is_alive():
						var dmg = 30
						enemy.take_damage(dmg)
						var idx = enemies.find(enemy)
						emit_signal("damage_dealt", "monster", idx, dmg, false)
						emit_signal("enemy_hp_changed", idx, enemy.current_hp, enemy.max_hp)
				if battle_diary: battle_diary.record_tarot_used()
				_check_battle_end()
		"심판의 날":
			if tarot_system.spend_tarot(2):
				var lowest = _get_lowest_hp_enemy()
				if lowest:
					var dmg = int(lowest.current_hp * 0.4)
					lowest.take_damage(dmg)
					var idx = enemies.find(lowest)
					emit_signal("damage_dealt", "monster", idx, dmg, false)
					emit_signal("enemy_hp_changed", idx, lowest.current_hp, lowest.max_hp)
				if battle_diary: battle_diary.record_tarot_used()
				_check_battle_end()

func _get_lowest_hp_enemy():
	var lowest = null
	for enemy in enemies:
		if enemy.is_alive():
			if lowest == null or enemy.current_hp < lowest.current_hp:
				lowest = enemy
	return lowest

# 배틀 로그 출력
func battle_log(msg: String):
	if battle_diary:
		battle_diary.log(msg)
	emit_signal("battle_log_updated", msg)

func get_player_hp() -> int:
	return player_data.get("hp", 0)

func get_player_block() -> int:
	return player_data.get("block", 0)

func get_energy() -> int:
	if energy_system: return energy_system.get_current()
	return 0
