# scripts/combat/atb/CombatManagerATB.gd
# ATB combat manager - shared by normal/boss. All combat same flow (only enemy setup differs).
class_name CombatManagerATB
extends Node

const DEBUG_COMBAT := false  # true: combat start count / attack log output

#region agent log
const _AGENT_LOG_PATH := "/Users/stevemacbook/Projects/geekbrox/.cursor/debug-e7b017.log"
var _agent_run_id: String = "pre-fix"

func _agent_log(hypothesis_id: String, message: String, data: Dictionary = {}) -> void:
	var payload := {
		"sessionId": "e7b017",
		"runId": _agent_run_id,
		"hypothesisId": hypothesis_id,
		"location": "CombatManagerATB.gd",
		"message": message,
		"data": data,
		"timestamp": int(Time.get_ticks_msec())
	}
	var f := FileAccess.open(_AGENT_LOG_PATH, FileAccess.READ_WRITE)
	if f == null:
		f = FileAccess.open(_AGENT_LOG_PATH, FileAccess.WRITE)
	if f:
		f.seek_end()
		f.store_line(JSON.stringify(payload))
		f.close()
#endregion

#                                                    
const ATB_MAX            = 100.0
const ATB_CHARGE_RATE    = 1.0     #          (spd 100    1   1   )
const SPEED_DEFAULT      = 1.0
const SPEED_MAX          = 2.5
const SPEED_FOCUS        = 0.3     #      
const SPEED_CRISIS       = 0.5     #      

#          (         )                       
@onready var energy_system   : ATBEnergySystem    = $ATBEnergySystem
@onready var reaction_mgr    : ATBReactionManager = $ATBReactionManager
@onready var intent_system   : ATBIntentSystem    = $ATBIntentSystem
@onready var combo_system    : ATBComboSystem     = $ATBComboSystem
@onready var auto_ai         : ATBAutoAI          = $ATBAutoAI
@onready var focus_mode      : ATBFocusMode       = $ATBFocusMode
@onready var crisis_mode     : ATBCrisisMode      = $ATBCrisisMode
@onready var battle_diary    : BattleDiary        = $BattleDiary

#                                                    
var enemies        : Array = []       # Array[Monster]
var player_data    : Dictionary = {}  # HP, ATK,     
var hand           : Array[Card] = []
var deck           : Array[Card] = []
var discard_pile   : Array[Card] = []

#                                                    
var speed_multiplier : float = SPEED_DEFAULT
var is_paused        : bool  = false
var reaction_open    : bool  = false
var combat_active    : bool  = false
var atk_bonus        : int   = 0   #            
var _auto_cooldown   : float = 0.0  #           
const PASS_COOLDOWN  : float = 10.0
var _pass_timer      : float = 0.0  # 0     Pass
var _dbg_atb_log_accum : float = 0.0  # debug: ATB 누적 로그용

#                                                    
signal combat_started
signal combat_ended(result: String)      # "WIN" | "LOSE" | "ESCAPE"
signal combo_triggered_signal(combo_name: String)
signal hand_updated(hand: Array[Card])
signal player_hp_changed(hp: int, max_hp: int, block: int)
signal enemy_hp_changed(enemy_idx: int, hp: int, max_hp: int)
signal energy_updated(current: float, max_e: int)
signal energy_timer_progress(progress: float)  # EnergyOrb           
signal damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool)
signal pass_timer_updated(remaining: float, duration: float)  # Pass    10   
signal battle_log_updated(message: String)
signal reaction_feedback(text: String, result_type: String, enemy_idx: int) # hero         

#                                                    
func _ready():
	#         
	if focus_mode:
		focus_mode.setup(self, energy_system)
	if crisis_mode:
		crisis_mode.setup(self, null)  # player_data  start_combat     
	if combo_system:
		combo_system.combo_triggered.connect(_on_combo_triggered)
	if energy_system:
		energy_system.energy_changed.connect(func(cur, mx): energy_updated.emit(cur, mx))
		if energy_system.has_signal("energy_timer_progress"):
			energy_system.energy_timer_progress.connect(_on_energy_timer_progress)

func battle_log(msg: String) -> void:
	if battle_diary:
		battle_diary.log(msg)
	battle_log_updated.emit(msg)

func _log_status_snapshot() -> void:
	"""             /           (      )."""
	var p_se = player_data.get("status_effects", {})
	var p_parts: PackedStringArray = []
	for k in p_se:
		if int(p_se[k]) != 0:
			p_parts.append("%s=%d" % [k, int(p_se[k])])
	var p_str: String = ",".join(p_parts) if p_parts.size() > 0 else "(  )"
	var e_parts: PackedStringArray = []
	for i in range(enemies.size()):
		var e = enemies[i]
		if not e.is_alive():
			continue
		var ename: String = e.display_name if e.get("display_name") else " %d" % (i+1)
		var se = e.status_effects if e.get("status_effects") else {}
		var parts: PackedStringArray = []
		for k in se:
			if int(se[k]) != 0:
				parts.append("%s=%d" % [k, int(se[k])])
		e_parts.append("%s[%s]" % [ename, ",".join(parts) if parts.size() > 0 else "  "])
	battle_log("  [    ]     : %s |  : %s" % [p_str, " / ".join(e_parts) if e_parts.size() > 0 else "(  )"])

func start_combat(p_data: Dictionary, enemy_list: Array, card_deck: Array[Card]):
	_agent_log("H3", "start_combat enter", {"enemy_count": enemy_list.size(), "deck_size": card_deck.size()})
	player_data = p_data.duplicate()
	player_data["block"] = 0
	enemies.clear()
	for e in enemy_list:
		enemies.append(e)
		if intent_system:
			intent_system.register_enemy(e)

	deck = card_deck.duplicate()
	deck.shuffle()
	hand.clear()
	discard_pile.clear()

	combat_active = true
	speed_multiplier = SPEED_DEFAULT
	_dbg_atb_log_accum = 0.0
	_pass_timer = PASS_COOLDOWN
	pass_timer_updated.emit(_pass_timer, PASS_COOLDOWN)

	if battle_diary:
		battle_diary.start()
	#         3    (ATB/       ) + ATB         5    +1   
	if energy_system:
		energy_system.reset()
	if crisis_mode:
		crisis_mode.reset()
		crisis_mode.player_entity = player_data  # dict      

	#           (5 )
	_draw_cards(5)
	_agent_log("H3", "after initial draw", {"hand_size": hand.size(), "deck_size": deck.size(), "discard_size": discard_pile.size()})

	# Auto AI    :    (         /        )
	if auto_ai:
		auto_ai.set_mode(ATBAutoAI.AutoMode.MANUAL)

	battle_log("===       (  %d  ) ===" % enemy_list.size())  #       (  N  )
	_log_status_snapshot()
	combat_started.emit()
	_agent_log("H3", "combat_started emitted", {"combat_active": combat_active})
	player_hp_changed.emit(player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
	# UI    HP     (InRun_v4 character_nodes   enemies   )
	for i in range(enemies.size()):
		var e = enemies[i]
		if e.is_alive():
			enemy_hp_changed.emit(i, e.current_hp, e.max_hp)

	if DEBUG_COMBAT:
		_print_combat_start_report()

func _print_combat_start_report():
	"""DEBUG_COMBAT               """
	print("\n[ATB]       |      HP %d/%d ATK %d |   %d   |   %d " % [
		player_data.get("hp", 0), player_data.get("max_hp", 200),
		player_data.get("atk", 10) + atk_bonus, enemies.size(), deck.size() + hand.size()
	])

#                                                 
func _process(delta: float):
	if not combat_active or is_paused:
		return
	# Pass    : reaction_open             (10                  )
	var scaled_delta = delta * speed_multiplier
	if _pass_timer > 0:
		_pass_timer = max(0.0, _pass_timer - scaled_delta)
		pass_timer_updated.emit(_pass_timer, PASS_COOLDOWN)
	if reaction_open:
		return
	_update_atb(scaled_delta)
	if energy_system:
		#   speed_multiplier   : 2                         (  )
		energy_system.update_timer(scaled_delta)
	if crisis_mode:
		crisis_mode.check(delta)
	#        (FULL   )
	_try_auto_play(delta)

func _try_auto_play(delta: float):
	if not auto_ai or auto_ai.mode != ATBAutoAI.AutoMode.FULL:
		return
	_auto_cooldown += delta
	# speed_multiplier   : 2      0.3           (        )
	if _auto_cooldown < 0.6 / speed_multiplier:
		return
	_auto_cooldown = 0.0
	var enemy = null
	for e in enemies:
		if e.is_alive():
			enemy = e
			break
	if not enemy or not energy_system or hand.is_empty():
		return
	var card = auto_ai.decide_action(hand, enemy, energy_system.get_current())
	if card and energy_system.can_afford(card.cost):
		player_play_card(card)

func _update_atb(delta: float):
	#         ATB                                               
	var player_spd = player_data.get("spd", 70.0)
	var p_charge = (player_spd / 100.0) * ATB_CHARGE_RATE * delta * 100.0
	player_data["atb"] = player_data.get("atb", 0.0) + p_charge

	#        ATB                  (  /      )
	if player_data["atb"] >= ATB_MAX:
		player_data["atb"] -= ATB_MAX   #           ( : 105   5)
		_player_atb_attack()

	#      ATB                                                     
	for enemy in enemies:
		if not enemy.is_alive():
			continue
		var charge = (enemy.spd / 100.0) * ATB_CHARGE_RATE * delta * 100.0
		enemy.atb = min(ATB_MAX, enemy.atb + charge)

		#           
		if intent_system:
			intent_system.update_intent_display(enemy)

		if enemy.atb >= ATB_MAX:
			enemy.atb = 0.0
			_on_enemy_atb_full(enemy)
			break  #                

#         ATB                                               
#        ATK                  /         
func _player_atb_attack():
	var target_enemy = null
	for e in enemies:
		if e.is_alive():
			target_enemy = e
			break
	if not target_enemy:
		return

	#        = player.atk + atk_bonus
	var base_atk = player_data.get("atk", 10) + atk_bonus

	#         (    Monster.take_damage     )
	var dmg = base_atk
	if target_enemy.has_status("VULNERABLE"):
		dmg = int(dmg * 1.5)
	if player_data.get("status_effects", {}).get("WEAK", 0) > 0:
		dmg = int(dmg * 0.75)
	var strength = player_data.get("status_effects", {}).get("STRENGTH", 0)
	dmg += strength
	dmg = max(0, dmg)

	#          player_data["cri"] (%)   ,    0%
	var cri_chance: float = player_data.get("cri", 0.0)
	var is_crit := randf() * 100.0 < cri_chance
	if is_crit:
		dmg = int(dmg * 1.5)
		battle_log("   !     %d" % dmg)

	target_enemy.take_damage(dmg)

	var idx = enemies.find(target_enemy)
	damage_dealt.emit("monster", idx, dmg, false)
	enemy_hp_changed.emit(idx, target_enemy.current_hp, target_enemy.max_hp)

	if battle_diary:
		battle_diary.record_damage_dealt(dmg)

	if DEBUG_COMBAT:
		var crit_str = " [   !]" if is_crit else ""
		print("[ATB] ATB     %s   %s    %d HP %d/%d" % [crit_str, target_enemy.display_name, dmg, target_enemy.current_hp, target_enemy.max_hp])

	_check_battle_end()

func _on_enemy_atb_full(enemy):
	var attack = enemy.make_attack_data()
	if intent_system:
		intent_system.announce_attack(attack)

	var result = null
	#        :                   /       (     )
	if reaction_mgr and auto_ai and auto_ai.mode == ATBAutoAI.AutoMode.FULL:
		result = _run_auto_reaction_immediate()
		if result and result.card and result.card in hand:
			hand.erase(result.card)
			discard_pile.append(result.card)
			hand_updated.emit(hand)
		reaction_mgr.last_result = result if result else ATBReactionManager.ReactionResult.new("NONE", null)
		reaction_mgr.last_failed_attempt_type = ""
		result = reaction_mgr.last_result
	else:
		reaction_open = true
		if reaction_mgr:
			reaction_mgr.open_reaction_window(attack)
			if reaction_mgr.reaction_state == "OPEN":
				await reaction_mgr.reaction_resolved
		else:
			await get_tree().create_timer(0.1).timeout
		reaction_open = false
		result = reaction_mgr.last_result if reaction_mgr else null
		if result and result.card and result.card in hand:
			hand.erase(result.card)
			discard_pile.append(result.card)
			hand_updated.emit(hand)
	_apply_attack_result(enemy, attack, result)
	if intent_system:
		intent_system.advance_pattern(enemy)
	_check_battle_end()

func _apply_attack_result(enemy, attack: Dictionary, result):
	if result == null:
		result = ATBReactionManager.ReactionResult.new("NONE", null)

	var attacker_name = enemy.display_name if enemy and "display_name" in enemy else "???"
	var _atk_type = attack.get("type", "NORMAL")
	var enemy_idx = enemies.find(enemy) if enemy else -1

	match result.type:
		"PARRY":
			#   :    0,     +2,       ATB    2 (   )
			if energy_system: energy_system.on_parry_success()
			enemy.atb = -ATB_MAX
			if battle_diary:
				battle_diary.record_parry(true)
			battle_log("     ! (%s)" % attacker_name)
			reaction_feedback.emit("     !", "PARRY", enemy_idx)
			if DEBUG_COMBAT: print("[ATB]      ")
		"DODGE":
			if energy_system: energy_system.on_dodge_success()
			if battle_diary:
				battle_diary.record_dodge()
			battle_log("     ! (%s)" % attacker_name)
			reaction_feedback.emit("     !", "DODGE", enemy_idx)
			if DEBUG_COMBAT: print("[ATB]      ")
		"GUARD":
			var block_val = result.card.get_effective_block() if result.card else 0
			if energy_system: energy_system.on_guard_success(block_val)
			#   :               (          )
			player_data["block"] = player_data.get("block", 0) + block_val
			var dmg_guarded = _calculate_damage(enemy, attack, player_data)
			player_data["hp"] = max(0, player_data.get("hp", 200) - dmg_guarded)
			if battle_diary: battle_diary.record_damage_taken(dmg_guarded)
			damage_dealt.emit("hero", 0, dmg_guarded, false)
			player_hp_changed.emit(player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
			battle_log("  ! (%s)    %d" % [attacker_name, dmg_guarded])
			reaction_feedback.emit("  ", "GUARD", enemy_idx)
			if DEBUG_COMBAT: print("[ATB]          +%d" % block_val)
		"NONE":
			#       :      (+50% dmg +      ATB 2     ),      (+20% dmg)
			var dmg_attack = attack.duplicate()
			var fail_type = reaction_mgr.last_failed_attempt_type if reaction_mgr and "last_failed_attempt_type" in reaction_mgr else ""
			if fail_type == "PARRY":
				dmg_attack["damage"] = int(dmg_attack.get("damage", 10) * 1.5)
			elif fail_type == "DODGE":
				dmg_attack["damage"] = int(dmg_attack.get("damage", 10) * 1.2)

			var dmg = _calculate_damage(enemy, dmg_attack, player_data)
			player_data["hp"] = max(0, player_data.get("hp", 200) - dmg)
			if battle_diary: battle_diary.record_damage_taken(dmg)
			damage_dealt.emit("hero", 0, dmg, false)
			player_hp_changed.emit(player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
			if fail_type == "PARRY":
				#      :              (ATB         )
				enemy.atb = ATB_MAX * 0.5
				battle_log("     ! (%s)    %d (+50%%) /   ATB    " % [attacker_name, dmg])
				reaction_feedback.emit("     !", "PARRY_FAIL", enemy_idx)
			elif fail_type == "DODGE":
				battle_log("     ! (%s)    %d (+20%%)" % [attacker_name, dmg])
				reaction_feedback.emit("     !", "DODGE_FAIL", enemy_idx)
			else:
				battle_log("   %d (%s)" % [dmg, attacker_name])
			if DEBUG_COMBAT: print("[ATB]    %d    HP %d/%d" % [dmg, player_data.get("hp", 0), player_data.get("max_hp", 200)])

func _calculate_damage(attacker, attack: Dictionary, target: Dictionary) -> int:
	var base: int = attack.get("damage", 10)
	var after_vuln: int = base
	var target_vuln: int = target.get("status_effects", {}).get("VULNERABLE", 0)
	var attacker_weak: bool = attacker.has_method("has_status") and attacker.has_status("WEAK")
	if target_vuln > 0:
		after_vuln = int(base * 1.5)
	if attacker_weak:
		after_vuln = int(after_vuln * 0.75)
	var block: int = target.get("block", 0)
	var after_block: int = max(0, after_vuln - block)
	target["block"] = max(0, block - after_vuln)
	battle_log("  [    ]        |   =%d |     VULN=%s  WEAK=%s   =%d |   =%d" % [base, "Y(%d)" % target_vuln if target_vuln > 0 else "N", "Y" if attacker_weak else "N", block, after_block])
	return after_block

#          :            (     ,   =      ,   =100%)                  
func _run_auto_reaction_immediate():
	"""          .                /              .       ."""
	var cur_energy = energy_system.get_current() if energy_system else 0
	for card in hand:
		if card.has_tag("GUARD") and card.cost <= cur_energy:
			return ATBReactionManager.ReactionResult.new("GUARD", card)
	for card in hand:
		if card.has_tag("DODGE") and card.cost <= cur_energy:
			if randf() < card.auto_dodge_success_rate:
				return ATBReactionManager.ReactionResult.new("DODGE", card)
	return null  # NONE

func _try_auto_reaction():
	"""            0.3          (      ,       _run_auto_reaction_immediate   )"""
	var cur_energy = energy_system.get_current() if energy_system else 0
	for card in hand:
		if card.has_tag("GUARD") and card.cost <= cur_energy:
			player_play_card(card)
			return
	for card in hand:
		if card.has_tag("DODGE") and card.cost <= cur_energy:
			if randf() < card.auto_dodge_success_rate:
				player_play_card(card)
				return

#                                              
func player_play_card(card: Card, target_index: int = -1):
	#               ATK                (  /  /  )      .                    reaction_open   .
	if reaction_open and reaction_mgr:
		reaction_mgr.on_player_tap_card(card)
		return
	if energy_system == null or not energy_system.can_afford(card.cost):
		return

	energy_system.spend(card.cost)
	if combo_system:
		combo_system.register_card(card)
	battle_log("[%s]    (    %d)" % [card.name, card.cost])  # [   ]    (    N)
	_resolve_card_effect(card, target_index)
	hand.erase(card)
	discard_pile.append(card)
	hand_updated.emit(hand)
	if battle_diary: battle_diary.record_card_played()
	_check_battle_end()

func _resolve_card_effect(card: Card, target_index: int = -1):
	#      
	if card.type == "ATK" or card.type == "ATTACK":
		var base = card.get_effective_damage() if card.has_method("get_effective_damage") else card.damage
		var base_dmg = base + atk_bonus
		var final_dmg = base_dmg
		if combo_system:
			final_dmg = combo_system.apply_combo_bonus(base_dmg)
		var is_aoe = card.has_tag("AOE") or (card.subtype == "AoE")
		if is_aoe:
			for enemy in enemies:
				if enemy.is_alive():
					var actual = _calculate_player_damage(card, enemy, final_dmg)
					enemy.take_damage(actual)
					if battle_diary: battle_diary.record_damage_dealt(actual)
					var idx = enemies.find(enemy)
					damage_dealt.emit("monster", idx, actual, false)
					enemy_hp_changed.emit(idx, enemy.current_hp, enemy.max_hp)
					battle_log("      #%d    %d (%s)" % [idx + 1, actual, enemy.display_name if "display_name" in enemy else "?"])  #     #N    dmg
		else:
			#      : target_index   ,                
			var target_enemy = null
			if target_index >= 0 and target_index < enemies.size() and enemies[target_index].is_alive():
				target_enemy = enemies[target_index]
			else:
				for enemy in enemies:
					if enemy.is_alive():
						target_enemy = enemy
						break
			if target_enemy:
				var actual = _calculate_player_damage(card, target_enemy, final_dmg)
				target_enemy.take_damage(actual)
				if battle_diary: battle_diary.record_damage_dealt(actual)
				var idx = enemies.find(target_enemy)
				damage_dealt.emit("monster", idx, actual, false)
				enemy_hp_changed.emit(idx, target_enemy.current_hp, target_enemy.max_hp)
				battle_log("      #%d    %d (%s)" % [idx + 1, actual, target_enemy.display_name if "display_name" in target_enemy else "?"])

	#      
	var _eff_block := card.get_effective_block()
	if _eff_block > 0:
		var actual_block = _eff_block
		# "      "   : SKILL 2           
		if combo_system and card.type == "SKILL":
			var combo_idx = combo_system._check_combo()
			if combo_idx == 1:  #       
				actual_block += 10
				combo_system.combo_triggered.emit("      ", 10)
		player_data["block"] = player_data.get("block", 0) + actual_block
		player_hp_changed.emit(player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
		battle_log("       +%d (         %d)" % [actual_block, player_data.get("block", 0)])  #      +N (         M)

	#      (               /         )
	for eff in card.status_effects:
		var target_type = eff.get("target", "enemy")
		var eff_type = eff.get("type", "POISON")
		var eff_val = eff.get("value", 1)
		if target_type == "enemy":
			for enemy in enemies:
				if enemy.is_alive():
					var before = enemy.status_effects.get(eff_type, 0)
					StatusEffectSystem.apply_to(enemy, eff_type, eff_val)
					var after = enemy.status_effects.get(eff_type, 0)
					var ename = enemy.display_name if enemy.get("display_name") else " "
					battle_log("  [  /   ]    = (%s) |   =%s | +%d (    %d %d)" % [ename, eff_type, eff_val, before, after])
					battle_log("           %s +%d" % [eff_type, eff_val])  #          X +N
		elif target_type == "self":
			var p_status = player_data.get("status_effects", {})
			var before = p_status.get(eff_type, 0)
			p_status[eff_type] = p_status.get(eff_type, 0) + eff_val
			player_data["status_effects"] = p_status
			var after = p_status[eff_type]
			battle_log("  [  /   ]    =     |   =%s | +%d (    %d %d)" % [eff_type, eff_val, before, after])
			battle_log("       %s +%d" % [eff_type, eff_val])  #      X +N

	#    
	if card.draw > 0:
		battle_log("        +%d " % card.draw)  #       +N 
		_draw_cards(card.draw)

func _calculate_player_damage(card: Card, enemy, base: int) -> int:
	# 03_damage_formula.csv 7         
	# Step 1:       = ATK         (base                )
	var dmg: float = float(base)

	# Step 2:   /        (   all_eff +              )
	var equip_bonus: float = 0.0
	equip_bonus += player_data.get("weapon_all_eff", 0.0)       #          (%)
	#               
	if card:
		var card_type_bonus_key := ""
		match card.type:
			"ATTACK": card_type_bonus_key = "card_atk_dmg"
			"SKILL":  card_type_bonus_key = "card_skl_eff"
			"POWER":  card_type_bonus_key = "card_pow_dmg"
			"CURSE":  card_type_bonus_key = "card_crs_eff"
		if card_type_bonus_key != "":
			equip_bonus += player_data.get(card_type_bonus_key, 0.0)
	dmg *= (1.0 + equip_bonus / 100.0)

	# Step 3:     /       (  VULNERABLE=    +50%,   WEAK=    -25%,   STRENGTH=      )
	var enemy_vuln: bool = enemy.has_status("VULNERABLE")
	var my_weak: int = player_data.get("status_effects", {}).get("WEAK", 0)
	var strength: int = player_data.get("status_effects", {}).get("STRENGTH", 0)
	if enemy_vuln:
		dmg *= 1.5
	if my_weak > 0:
		dmg *= 0.75
	dmg += float(strength)

	# Step 4:        (atb            ,          )
	#         _player_atb_attack           
	# (                    player_data.cri   )
	var cri_chance: float = player_data.get("cri", 0.0)
	if cri_chance > 0.0 and randf() * 100.0 < cri_chance:
		var crit_dmg_mult: float = player_data.get("crit_dmg", 150.0) / 100.0
		dmg *= crit_dmg_mult
		battle_log("          ! ( %.1f)" % crit_dmg_mult)

	# Step 5:       (elem_mult:    1.5,    0.5,    1.0)
	#                      1.0 (  )
	var elem_mult: float = 1.0
	dmg *= elem_mult

	# Step 6:         Monster.take_damage()     
	#   : dmg   (1 - DEF/(DEF+100))   (1 - armor_pen/100)
	# (armor_pen  player_data           0)
	#                         Monster.take_damage  DEF   

	# Step 7:       (    1, dmg_amplify      )
	var dmg_amplify: float = player_data.get("dmg_amplify", 100.0) / 100.0
	dmg *= dmg_amplify

	var final_dmg: int = max(1, int(dmg))
	var ename: String = enemy.display_name if enemy.get("display_name") else " "
	battle_log("  [     ]      %s |   =%d |  VULN=%s  WEAK=%d  =%d |   %%=%.0f |   =%d" % [ename, base, "Y" if enemy_vuln else "N", my_weak, strength, equip_bonus, final_dmg])
	return final_dmg

#                                                 
func _draw_cards(n: int):
	for _i in range(n):
		if deck.is_empty():
			_reshuffle_discard()
		if deck.is_empty():
			break
		var card = deck.pop_front()
		hand.append(card)
	hand_updated.emit(hand)

func _reshuffle_discard():
	deck = discard_pile.duplicate()
	discard_pile.clear()
	deck.shuffle()

#                                                 
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
	battle_log("===      : %s ===" % ("  " if result == "WIN" else "  "))  #      :   /  
	if DEBUG_COMBAT and battle_diary:
		var report = battle_diary.compile_report()
		print("[ATB]      : %s |   : %.1fs" % [result, report.duration])
	combat_ended.emit(result)

#                                                 
func set_speed(multiplier: float):
	speed_multiplier = clamp(multiplier, 0.1, SPEED_MAX)

func _on_energy_timer_progress(progress: float):
	energy_timer_progress.emit(progress)

func _on_combo_triggered(combo_name: String, bonus_pct: int):
	combo_triggered_signal.emit(combo_name)
	if battle_diary:
		battle_diary.record_combo(combo_name)
		battle_diary.log("  ! %s (+%d%%)" % [combo_name, bonus_pct])

#          /                                
func activate_focus():
	if focus_mode:
		focus_mode.activate()

func get_hand() -> Array[Card]:
	return hand

func get_player_hp() -> int:
	return player_data.get("hp", 0)

func get_player_block() -> int:
	return player_data.get("block", 0)

func get_energy() -> int:
	if energy_system:
		return energy_system.get_current()
	return 0

## Pass   :        ,    5     . 10         .
func player_pass_atb():
	if _pass_timer > 0:
		return
	#        
	for card in hand:
		discard_pile.append(card)
	hand.clear()
	#    5     
	_draw_cards(5)
	_pass_timer = PASS_COOLDOWN
	pass_timer_updated.emit(_pass_timer, PASS_COOLDOWN)

func is_pass_ready() -> bool:
	return _pass_timer <= 0

func get_pass_timer_remaining() -> float:
	return _pass_timer
