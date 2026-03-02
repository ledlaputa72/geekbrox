# scripts/combat/atb/CombatManagerATB.gd
# ATB 전투 중앙 관리자 — 일반 전투(몬스터)용. 보스 전투는 CombatManagerTB.
class_name CombatManagerATB
extends Node

const DEBUG_COMBAT := false  # true: 전투 시작 수치/공격 로그 출력

# ── 핵심 상수 ──────────────────────────────────────────
const ATB_MAX            = 100.0
const ATB_CHARGE_RATE    = 1.0     # 초당 충전 배율 (spd 100 기준 1초에 1 충전)
const SPEED_DEFAULT      = 1.0
const SPEED_MAX          = 2.5
const SPEED_FOCUS        = 0.3     # 집중 모드
const SPEED_CRISIS       = 0.5     # 위기 개입

# ── 서브시스템 (자식 노드로 추가) ──────────────────────
@onready var energy_system   : ATBEnergySystem    = $ATBEnergySystem
@onready var reaction_mgr    : ATBReactionManager = $ATBReactionManager
@onready var intent_system   : ATBIntentSystem    = $ATBIntentSystem
@onready var combo_system    : ATBComboSystem     = $ATBComboSystem
@onready var auto_ai         : ATBAutoAI          = $ATBAutoAI
@onready var focus_mode      : ATBFocusMode       = $ATBFocusMode
@onready var crisis_mode     : ATBCrisisMode      = $ATBCrisisMode
@onready var battle_diary    : BattleDiary        = $BattleDiary

# ── 데이터 ────────────────────────────────────────────
var enemies        : Array = []       # Array[Monster]
var player_data    : Dictionary = {}  # HP, ATK, 블록 등
var hand           : Array[Card] = []
var deck           : Array[Card] = []
var discard_pile   : Array[Card] = []

# ── 상태 변수 ──────────────────────────────────────────
var speed_multiplier : float = SPEED_DEFAULT
var is_paused        : bool  = false
var reaction_open    : bool  = false
var combat_active    : bool  = false
var atk_bonus        : int   = 0   # 플레이어 공격 보너스
var _auto_cooldown   : float = 0.0  # 오토 플레이 쿨다운
const PASS_COOLDOWN  : float = 10.0
var _pass_timer      : float = 0.0  # 0이 되면 Pass 버튼 활성화

# ── 시그널 ────────────────────────────────────────────
signal combat_started
signal combat_ended(result: String)      # "WIN" | "LOSE" | "ESCAPE"
signal combo_triggered_signal(combo_name: String)
signal hand_updated(hand: Array[Card])
signal player_hp_changed(hp: int, max_hp: int, block: int)
signal enemy_hp_changed(enemy_idx: int, hp: int, max_hp: int)
signal energy_updated(current: float, max_e: int)
signal energy_timer_progress(progress: float)  # EnergyOrb 외곽 쿨타임 게이지
signal damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool)
signal pass_timer_updated(remaining: float, duration: float)  # Pass 버튼 10초 쿨

# ── 초기화 ────────────────────────────────────────────
func _ready():
	# 서브시스템 설정
	if focus_mode:
		focus_mode.setup(self, energy_system)
	if crisis_mode:
		crisis_mode.setup(self, null)  # player_data는 start_combat에서 설정
	if combo_system:
		combo_system.combo_triggered.connect(_on_combo_triggered)
	if energy_system:
		energy_system.energy_changed.connect(func(cur, mx): emit_signal("energy_updated", cur, mx))
		if energy_system.has_signal("energy_timer_progress"):
			energy_system.energy_timer_progress.connect(_on_energy_timer_progress)

func start_combat(p_data: Dictionary, enemy_list: Array, card_deck: Array[Card]):
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
	_pass_timer = PASS_COOLDOWN
	emit_signal("pass_timer_updated", _pass_timer, PASS_COOLDOWN)

	if battle_diary:
		battle_diary.start()
	# 전투 시작 시 3에너지 (ATB/턴베이스 공통) + ATB는 시간에 따라 5초마다 +1 충전
	if energy_system:
		energy_system.reset()
	if crisis_mode:
		crisis_mode.reset()
		crisis_mode.player_entity = player_data  # dict 참조 전달

	# 초기 손패 드로우 (5장)
	_draw_cards(5)

	# Auto AI 기본 FULL 모드로 시작 (테스트용)
	if auto_ai:
		auto_ai.set_mode(ATBAutoAI.AutoMode.FULL)

	emit_signal("combat_started")
	emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
	# UI 초기 HP 동기화 (InRun_v4 character_nodes ↔ enemies 매핑)
	for i in range(enemies.size()):
		var e = enemies[i]
		if e.is_alive():
			emit_signal("enemy_hp_changed", i, e.current_hp, e.max_hp)

	if DEBUG_COMBAT:
		_print_combat_start_report()

func _print_combat_start_report():
	"""DEBUG_COMBAT일 때 전투 시작 수치 로그"""
	print("\n[ATB] 전투 시작 | 플레이어 HP %d/%d ATK %d | 적 %d마리 | 덱 %d장" % [
		player_data.get("hp", 0), player_data.get("max_hp", 200),
		player_data.get("atk", 10) + atk_bonus, enemies.size(), deck.size() + hand.size()
	])

# ── 메인 게임 루프 ────────────────────────────────────
func _process(delta: float):
	if not combat_active or is_paused:
		return
	# Pass 타이머: reaction_open과 무관하게 항상 감소 (10초 쿨이 리액션으로 멈추지 않도록)
	var scaled_delta = delta * speed_multiplier
	if _pass_timer > 0:
		_pass_timer = max(0.0, _pass_timer - scaled_delta)
		emit_signal("pass_timer_updated", _pass_timer, PASS_COOLDOWN)
	if reaction_open:
		return
	_update_atb(scaled_delta)
	if energy_system:
		# ★ speed_multiplier 적용: 2×속도에서 적도 빠르고 에너지도 빠르게 회복 (균형)
		energy_system.update_timer(scaled_delta)
	if crisis_mode:
		crisis_mode.check(delta)
	# 오토 플레이 (FULL 모드)
	_try_auto_play(delta)

func _try_auto_play(delta: float):
	if not auto_ai or auto_ai.mode != ATBAutoAI.AutoMode.FULL:
		return
	_auto_cooldown += delta
	# speed_multiplier 비례: 2×속도 → 0.3초마다 자동 플레이 (적과 동일 비율)
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
	# ── 플레이어 ATB ──────────────────────────────────────────────
	var player_spd = player_data.get("spd", 70.0)
	var p_charge = (player_spd / 100.0) * ATB_CHARGE_RATE * delta * 100.0
	player_data["atb"] = player_data.get("atb", 0.0) + p_charge

	# ★ 플레이어 ATB 만충 → 기본 공격 자동 발동 (카드/에너지 무관)
	if player_data["atb"] >= ATB_MAX:
		player_data["atb"] -= ATB_MAX   # 남은 충전량 유지 (예: 105 → 5)
		_player_atb_attack()

	# ── 적 ATB ────────────────────────────────────────────────────
	for enemy in enemies:
		if not enemy.is_alive():
			continue
		var charge = (enemy.spd / 100.0) * ATB_CHARGE_RATE * delta * 100.0
		enemy.atb = min(ATB_MAX, enemy.atb + charge)

		# 의도 표시 업데이트
		if intent_system:
			intent_system.update_intent_display(enemy)

		if enemy.atb >= ATB_MAX:
			enemy.atb = 0.0
			_on_enemy_atb_full(enemy)
			break  # 이번 프레임은 한 번만 처리

# ── 플레이어 ATB 기본 공격 ────────────────────────────────────────
# 캐릭터 기본 ATK 특성치 기반 자동 공격 — 카드/에너지 완전 무관
func _player_atb_attack():
	var target_enemy = null
	for e in enemies:
		if e.is_alive():
			target_enemy = e
			break
	if not target_enemy:
		return

	# 기본 공격력 = player.atk + atk_bonus
	var base_atk = player_data.get("atk", 10) + atk_bonus

	# 상태이상 보정 (블록은 Monster.take_damage에서 처리)
	var dmg = base_atk
	if target_enemy.has_status("VULNERABLE"):
		dmg = int(dmg * 1.5)
	if player_data.get("status_effects", {}).get("WEAK", 0) > 0:
		dmg = int(dmg * 0.75)
	var strength = player_data.get("status_effects", {}).get("STRENGTH", 0)
	dmg += strength
	dmg = max(0, dmg)

	target_enemy.take_damage(dmg)

	var idx = enemies.find(target_enemy)
	emit_signal("damage_dealt", "monster", idx, dmg, false)
	emit_signal("enemy_hp_changed", idx, target_enemy.current_hp, target_enemy.max_hp)

	if battle_diary:
		battle_diary.record_damage_dealt(dmg)

	if DEBUG_COMBAT:
		print("[ATB] ATB 기본공격 → %s 피해 %d HP %d/%d" % [target_enemy.display_name, dmg, target_enemy.current_hp, target_enemy.max_hp])

	_check_battle_end()

func _on_enemy_atb_full(enemy):
	var attack = enemy.make_attack_data()
	if intent_system:
		intent_system.announce_attack(attack)

	# 리액션 윈도우 오픈
	reaction_open = true
	if reaction_mgr:
		reaction_mgr.open_reaction_window(attack)
		await reaction_mgr.reaction_resolved
	else:
		await get_tree().create_timer(0.1).timeout

	reaction_open = false
	var result = reaction_mgr.last_result if reaction_mgr else null
	_apply_attack_result(enemy, attack, result)
	if intent_system:
		intent_system.advance_pattern(enemy)
	_check_battle_end()

func _apply_attack_result(enemy, attack: Dictionary, result):
	if result == null:
		result = ATBReactionManager.ReactionResult.new("NONE", null)

	var attacker_name = enemy.display_name if enemy and "display_name" in enemy else "???"
	var atk_type = attack.get("type", "NORMAL")

	match result.type:
		"PARRY":
			# 패링: 피해 0, 에너지 +2, 적 ATB 롤백
			if energy_system: energy_system.on_parry_success()
			enemy.atb *= 0.5
			if battle_diary:
				battle_diary.record_parry(true)
				battle_diary.log("패링 성공! 에너지 +2")
			if DEBUG_COMBAT: print("[ATB] 패링 성공")
		"DODGE":
			if energy_system: energy_system.on_dodge_success()
			if battle_diary:
				battle_diary.record_dodge()
				battle_diary.log("회피 성공!")
			if DEBUG_COMBAT: print("[ATB] 회피 성공")
		"GUARD":
			var block_val = result.card.block if result.card else 0
			if energy_system: energy_system.on_guard_success(block_val)
			player_data["block"] = player_data.get("block", 0) + block_val
			emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
			if battle_diary: battle_diary.log("방어 성공! 블록 +%d" % block_val)
			if DEBUG_COMBAT: print("[ATB] 방어 성공 블록 +%d" % block_val)
		"NONE":
			var dmg = _calculate_damage(enemy, attack, player_data)
			player_data["hp"] = max(0, player_data.get("hp", 200) - dmg)
			if battle_diary: battle_diary.record_damage_taken(dmg)
			emit_signal("damage_dealt", "hero", 0, dmg, false)
			emit_signal("player_hp_changed", player_data.get("hp", 0), player_data.get("max_hp", 200), player_data.get("block", 0))
			if DEBUG_COMBAT: print("[ATB] 피해 %d 받음 HP %d/%d" % [dmg, player_data.get("hp", 0), player_data.get("max_hp", 200)])

func _calculate_damage(attacker, attack: Dictionary, target: Dictionary) -> int:
	var base = attack.get("damage", 10)
	# 상태이상 보정
	if target.get("status_effects", {}).get("VULNERABLE", 0) > 0:
		base = int(base * 1.5)
	if attacker.has_status("WEAK"):
		base = int(base * 0.75)
	# 블록 상쇄
	var block = target.get("block", 0)
	var after_block = max(0, base - block)
	target["block"] = max(0, block - base)
	return after_block

# ── 플레이어 카드 플레이 ──────────────────────────────
func player_play_card(card: Card, target_index: int = -1):
	if reaction_open and reaction_mgr:
		reaction_mgr.on_player_tap_card(card)
		return
	if energy_system == null or not energy_system.can_afford(card.cost):
		return

	energy_system.spend(card.cost)
	if combo_system:
		combo_system.register_card(card)
	_resolve_card_effect(card, target_index)
	hand.erase(card)
	discard_pile.append(card)
	emit_signal("hand_updated", hand)
	if battle_diary: battle_diary.record_card_played()
	_check_battle_end()

func _resolve_card_effect(card: Card, target_index: int = -1):
	# 공격 카드
	if card.type == "ATK":
		var base_dmg = card.damage + atk_bonus
		var final_dmg = base_dmg
		if combo_system:
			final_dmg = combo_system.apply_combo_bonus(base_dmg)
		var is_aoe = card.has_tag("AOE")
		if is_aoe:
			for enemy in enemies:
				if enemy.is_alive():
					var actual = _calculate_player_damage(card, enemy, final_dmg)
					enemy.take_damage(actual)
					if battle_diary: battle_diary.record_damage_dealt(actual)
					var idx = enemies.find(enemy)
					emit_signal("damage_dealt", "monster", idx, actual, false)
					emit_signal("enemy_hp_changed", idx, enemy.current_hp, enemy.max_hp)
		else:
			# 단일 대상: target_index 우선, 없으면 첫 번째 살아있는 적
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
				emit_signal("damage_dealt", "monster", idx, actual, false)
				emit_signal("enemy_hp_changed", idx, target_enemy.current_hp, target_enemy.max_hp)

	# 방어 카드
	if card.block > 0:
		var actual_block = card.block
		# "완벽한 방어" 콤보: DEF 2연속 시 보너스 블록
		if combo_system and card.type == "DEF":
			var combo_idx = combo_system._check_combo()
			if combo_idx == 1:  # 완벽한 방어
				actual_block += 10
				combo_system.emit_signal("combo_triggered", "완벽한 방어", 10)
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
	if card.draw > 0:
		_draw_cards(card.draw)

func _calculate_player_damage(_card: Card, enemy, base: int) -> int:
	"""기본 데미지 계산 (취약/허약/힘 보너스). 블록은 Monster.take_damage에서 처리"""
	var dmg = base
	if enemy.has_status("VULNERABLE"):
		dmg = int(dmg * 1.5)
	if player_data.get("status_effects", {}).get("WEAK", 0) > 0:
		dmg = int(dmg * 0.75)
	var strength = player_data.get("status_effects", {}).get("STRENGTH", 0)
	dmg += strength
	return max(0, dmg)

# ── 카드 드로우 ──────────────────────────────────────
func _draw_cards(n: int):
	for _i in range(n):
		if deck.is_empty():
			_reshuffle_discard()
		if deck.is_empty():
			break
		var card = deck.pop_front()
		hand.append(card)
	emit_signal("hand_updated", hand)

func _reshuffle_discard():
	deck = discard_pile.duplicate()
	discard_pile.clear()
	deck.shuffle()

# ── 전투 종료 체크 ────────────────────────────────────
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
	if DEBUG_COMBAT and battle_diary:
		var report = battle_diary.compile_report()
		print("[ATB] 전투 종료: %s | 시간: %.1fs" % [result, report.duration])
	emit_signal("combat_ended", result)

# ── 전투 속도 변경 ────────────────────────────────────
func set_speed(multiplier: float):
	speed_multiplier = clamp(multiplier, 0.1, SPEED_MAX)

func _on_energy_timer_progress(progress: float):
	emit_signal("energy_timer_progress", progress)

func _on_combo_triggered(combo_name: String, bonus_pct: int):
	emit_signal("combo_triggered_signal", combo_name)
	if battle_diary:
		battle_diary.record_combo(combo_name)
		battle_diary.log("콤보! %s (+%d%%)" % [combo_name, bonus_pct])

# ── 집중 모드 / 위기 모드 활성화 ─────────────────────
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

## Pass 버튼: 손패 무덤으로, 새로 5장 드로우. 10초 쿨 후 활성화.
func player_pass_atb():
	if _pass_timer > 0:
		return
	# 손패 → 무덤
	for card in hand:
		discard_pile.append(card)
	hand.clear()
	# 새로 5장 드로우
	_draw_cards(5)
	_pass_timer = PASS_COOLDOWN
	emit_signal("pass_timer_updated", _pass_timer, PASS_COOLDOWN)

func is_pass_ready() -> bool:
	return _pass_timer <= 0

func get_pass_timer_remaining() -> float:
	return _pass_timer
