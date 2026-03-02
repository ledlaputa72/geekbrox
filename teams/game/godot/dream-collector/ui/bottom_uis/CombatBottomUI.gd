extends BaseBottomUI

"""
CombatBottomUI - 전투 중 UI
카드 핸드 + 로그 + 버튼 (2분할 구조)

Layout (564px):
├─ CardHandArea (220px) ← 카드 팬 레이아웃
├─ GameInfo (50px) ← Energy Orb, Deck/Discard/Exile
├─ CombatLog (120px) ← 스크롤 가능
└─ ActionButtons (64px) ← Pass, Auto, Speed
"""

@onready var card_hand_container = $CardHandArea
@onready var energy_orb = $GameInfo/EnergyOrb
@onready var deck_label = $GameInfo/DeckArea/DeckLabel
@onready var discard_label = $GameInfo/DiscardArea/DiscardLabel
@onready var exile_label = $GameInfo/ExileLabel
@onready var combat_log_content = $CombatLog/ScrollContainer/LogContent
@onready var pass_button = $ActionButtons/PassButton
@onready var auto_button = $ActionButtons/AutoButton
@onready var speed_button = $ActionButtons/SpeedButton
@onready var reaction_button = $ActionButtons/ReactionButton

# Card selection state
var currently_selected_card_index: int = -1
var currently_selected_card_item: Control = null
var _prev_hand_count: int = 0

# Targeting state
var selecting_target: bool = false
var selected_card_index: int = -1
var is_dragging: bool = false
var drag_arrow: Node2D = null

# ── 리액션 버튼 상태 ─────────────────────────────────────
var _reaction_card: Card = null   # 현재 사용 가능한 최우선 리액션 카드

# ── 드래그 화살표 (공격 카드 타겟팅) ──────────────────────
var _draw_arrow_from: Vector2 = Vector2.ZERO
var _draw_arrow_to: Vector2 = Vector2.ZERO
var _draw_arrow_visible: bool = false

# New combat manager bridge (CombatManagerATB / CombatManagerTB)
var new_combat_manager: Node = null
var new_hand: Array = []
var _selected_target_index: int = -1  # 공격 2단계: 첫 클릭=선택, 두번째 클릭=발동
var _auto_enabled: bool = false
var _speed: float = 1.0

const TYPE_TO_DISPLAY = {
	"ATK": "Attack", "DEF": "Defense", "SKILL": "Skill",
	"POWER": "Power", "CURSE": "Attack"
}

func _ready():
	if energy_orb:
		var EnergyOrbScript = load("res://ui/components/EnergyOrb.gd")
		energy_orb.set_script(EnergyOrbScript)
		energy_orb._ready()
		energy_orb.set_energy(3, 3)
		energy_orb.set_timer_progress(0.0)
	else:
		push_error("[CombatBottomUI] EnergyOrb node not found")

	_setup_buttons()
	ui_ready.emit()

# === New Combat Manager Bridge ===

func connect_combat_manager(manager: Node):
	"""새 전투 매니저(CombatManagerATB / CombatManagerTB) 연결"""
	new_combat_manager = manager
	if "speed_multiplier" in manager:
		_speed = manager.speed_multiplier
		if speed_button:
			speed_button.text = "Speed: %.1f×" % _speed

	if manager.has_signal("hand_updated"):
		manager.hand_updated.connect(_on_new_hand_updated)
	if manager.has_signal("energy_updated"):
		manager.energy_updated.connect(_on_new_energy_updated)
	if manager.has_signal("combat_ended"):
		manager.combat_ended.connect(_on_new_combat_ended_signal)
	if manager.has_signal("battle_log_updated"):
		manager.battle_log_updated.connect(_on_combat_log_updated)
	if manager.has_signal("energy_timer_progress"):
		manager.energy_timer_progress.connect(_on_energy_timer_progress)
	# ★ combat_started 연결 — Auto AI 모드 동기화용
	if manager.has_signal("combat_started"):
		manager.combat_started.connect(_on_combat_started_sync)
	# ATB Pass 10초 쿨타임
	if manager.has_signal("pass_timer_updated"):
		manager.pass_timer_updated.connect(_on_pass_timer_updated)

	_update_deck_ui()
	# TB: Pass 항상 활성. ATB: pass_timer_updated로 제어
	if pass_button:
		pass_button.disabled = (manager is CombatManagerATB)

func _card_to_dict(card: Card) -> Dictionary:
	"""Card Resource → Dictionary (CardHandItem 호환 형식)"""
	return {
		"name": card.name,
		"cost": card.cost,
		"type": TYPE_TO_DISPLAY.get(card.type, "Attack"),
		"description": card.get_mobile_description(),
		"damage": card.damage,
		"block": card.block,
		"draw": card.draw,
	}

func _on_new_hand_updated(hand: Array):
	new_hand = hand.duplicate()
	_update_deck_ui()
	var old_count = _prev_hand_count
	_prev_hand_count = hand.size()
	if hand.is_empty() and card_hand_container.get_child_count() > 0:
		_run_discard_animation()
		return
	var drawn_count = hand.size() - old_count
	_update_hand_ui(drawn_count if drawn_count > 0 else 0)

func _on_new_energy_updated(current, max_val):
	if energy_orb and energy_orb.has_method("set_energy"):
		energy_orb.set_energy(int(current), int(max_val))
	# 에너지 변경 시 리액션 버튼 갱신 (affordability 체크)
	_update_reaction_button()

func _on_new_combat_ended_signal(result: String):
	if result == "WIN":
		add_combat_log("=== VICTORY ===")
	else:
		add_combat_log("=== DEFEAT ===")

func _get_new_manager_energy() -> int:
	if new_combat_manager and new_combat_manager.has_method("get_energy"):
		return new_combat_manager.get_energy()
	if new_combat_manager and new_combat_manager.get("energy_system"):
		var es = new_combat_manager.energy_system
		if es.has_method("get_current"):
			return es.get_current()
	return 0

# === Lifecycle ===

func _on_enter():
	"""UI 활성화 시"""
	# New manager signals are connected via connect_combat_manager()
	if not new_combat_manager:
		if not CombatManager.combat_log_updated.is_connected(_on_combat_log_updated):
			CombatManager.combat_log_updated.connect(_on_combat_log_updated)
		if not CombatManager.entity_updated.is_connected(_on_entity_updated):
			CombatManager.entity_updated.connect(_on_entity_updated)
		if not CombatManager.combat_ended.is_connected(_on_combat_ended):
			CombatManager.combat_ended.connect(_on_combat_ended)
		if not CombatManager.energy_changed.is_connected(_on_energy_changed):
			CombatManager.energy_changed.connect(_on_energy_changed)
		if not CombatManager.energy_timer_updated.is_connected(_on_energy_timer_updated):
			CombatManager.energy_timer_updated.connect(_on_energy_timer_updated)
		if not DeckManager.hand_changed.is_connected(_on_hand_changed):
			DeckManager.hand_changed.connect(_on_hand_changed)

	_update_deck_ui()

	if not new_combat_manager:
		if CombatManager.hero and "energy" in CombatManager.hero:
			var current_energy = CombatManager.hero.get("energy", 0)
			_on_energy_changed(current_energy, CombatManager.ENERGY_MAX)

	add_combat_log("=== Combat UI Ready ===")

func _on_exit():
	"""UI 비활성화 시"""
	# Disconnect new manager signals
	if new_combat_manager:
		if new_combat_manager.has_signal("hand_updated") and new_combat_manager.hand_updated.is_connected(_on_new_hand_updated):
			new_combat_manager.hand_updated.disconnect(_on_new_hand_updated)
		if new_combat_manager.has_signal("energy_updated") and new_combat_manager.energy_updated.is_connected(_on_new_energy_updated):
			new_combat_manager.energy_updated.disconnect(_on_new_energy_updated)
		if new_combat_manager.has_signal("combat_ended") and new_combat_manager.combat_ended.is_connected(_on_new_combat_ended_signal):
			new_combat_manager.combat_ended.disconnect(_on_new_combat_ended_signal)
		if new_combat_manager.has_signal("battle_log_updated") and new_combat_manager.battle_log_updated.is_connected(_on_combat_log_updated):
			new_combat_manager.battle_log_updated.disconnect(_on_combat_log_updated)
		if new_combat_manager.has_signal("energy_timer_progress") and new_combat_manager.energy_timer_progress.is_connected(_on_energy_timer_progress):
			new_combat_manager.energy_timer_progress.disconnect(_on_energy_timer_progress)
		if new_combat_manager.has_signal("combat_started") and new_combat_manager.combat_started.is_connected(_on_combat_started_sync):
			new_combat_manager.combat_started.disconnect(_on_combat_started_sync)
		if new_combat_manager.has_signal("pass_timer_updated") and new_combat_manager.pass_timer_updated.is_connected(_on_pass_timer_updated):
			new_combat_manager.pass_timer_updated.disconnect(_on_pass_timer_updated)
		new_combat_manager = null
		new_hand.clear()
		_prev_hand_count = 0

	# Disconnect old autoload signals
	if CombatManager.combat_log_updated.is_connected(_on_combat_log_updated):
		CombatManager.combat_log_updated.disconnect(_on_combat_log_updated)
	if CombatManager.entity_updated.is_connected(_on_entity_updated):
		CombatManager.entity_updated.disconnect(_on_entity_updated)
	if CombatManager.combat_ended.is_connected(_on_combat_ended):
		CombatManager.combat_ended.disconnect(_on_combat_ended)
	if CombatManager.energy_changed.is_connected(_on_energy_changed):
		CombatManager.energy_changed.disconnect(_on_energy_changed)
	if CombatManager.energy_timer_updated.is_connected(_on_energy_timer_updated):
		CombatManager.energy_timer_updated.disconnect(_on_energy_timer_updated)
	if DeckManager.hand_changed.is_connected(_on_hand_changed):
		DeckManager.hand_changed.disconnect(_on_hand_changed)

	_cancel_target_selection()

func _setup_buttons():
	"""Setup button connections"""
	# Apply custom styles to buttons
	_apply_button_style(pass_button, UITheme.COLORS.panel)

	# Auto button — 초기 OFF 상태, 전투 시작 시 combat_started 신호로 동기화
	_auto_enabled = false
	auto_button.text = "Auto"
	_apply_button_style(auto_button, UITheme.COLORS.panel)

	_apply_button_style(speed_button, UITheme.COLORS.panel)

	# 리액션 버튼 — 초기 비활성 (패 업데이트 시 활성화)
	if reaction_button:
		reaction_button.text = "방어"
		reaction_button.disabled = true
		_apply_button_style(reaction_button, UITheme.COLORS.panel)

	pass_button.pressed.connect(_on_pass_pressed)
	auto_button.pressed.connect(_on_auto_pressed)
	speed_button.pressed.connect(_on_speed_pressed)
	if reaction_button:
		reaction_button.pressed.connect(_on_reaction_pressed)

func _apply_button_style(button: Button, bg_color: Color):
	"""Apply custom style to button"""
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", style)
	button.add_theme_stylebox_override("pressed", style)
	button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
	button.add_theme_color_override("font_color", UITheme.COLORS.text)

# === Combat Log ===

func add_combat_log(message: String):
	"""Add combat log entry"""
	var label = Label.new()
	label.text = "• " + message
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	combat_log_content.add_child(label)
	
	# Auto-scroll to bottom
	await get_tree().process_frame
	var scroll = $CombatLog/ScrollContainer
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value)

# === Deck & Hand UI ===

func _update_deck_ui():
	"""Update deck status labels and energy orb"""
	if new_combat_manager:
		var deck_size := 0
		var discard_size := 0
		var exile_size := 0
		if new_combat_manager is CombatManagerATB:
			deck_size = new_combat_manager.deck.size()
			discard_size = new_combat_manager.discard_pile.size()
		elif new_combat_manager.get("hand_system"):
			var hs = new_combat_manager.hand_system
			deck_size = hs.get_deck_size()
			discard_size = hs.get_discard_size()
		if deck_label:
			deck_label.text = "%d" % deck_size
		if discard_label:
			discard_label.text = "%d" % discard_size
		if exile_label:
			exile_label.text = "🚫 %d" % exile_size
		if energy_orb and energy_orb.has_method("set_energy"):
			energy_orb.set_energy(_get_new_manager_energy(), 3)
	else:
		if deck_label:
			deck_label.text = "%d" % DeckManager.get_deck_size()
		if discard_label:
			discard_label.text = "%d" % DeckManager.get_discard_size()
		if exile_label:
			exile_label.text = "🚫 %d" % DeckManager.get_exile_size()
		if energy_orb and energy_orb.has_method("set_energy"):
			var current = CombatManager.get_current_energy()
			var maximum = CombatManager.get_max_energy()
			energy_orb.set_energy(current, maximum)

func _get_deck_ui_pos() -> Vector2:
	var deck_area = get_node_or_null("GameInfo/DeckArea")
	if deck_area:
		return card_hand_container.get_global_transform_with_canvas().affine_inverse() * (
			deck_area.get_global_transform_with_canvas().get_origin() + deck_area.size / 2)
	return Vector2(80, card_hand_container.size.y / 2)

func _get_discard_ui_pos() -> Vector2:
	var discard_area = get_node_or_null("GameInfo/DiscardArea")
	if discard_area:
		return card_hand_container.get_global_transform_with_canvas().affine_inverse() * (
			discard_area.get_global_transform_with_canvas().get_origin() + discard_area.size / 2)
	return Vector2(card_hand_container.size.x - 80, card_hand_container.size.y / 2)

func _run_discard_animation():
	"""손패 카드들을 무덤 위치로 날리는 애니메이션 후 클리어"""
	var target = _get_discard_ui_pos()
	var cards = card_hand_container.get_children().duplicate()
	var tween = create_tween()
	tween.set_parallel(true)
	for c in cards:
		tween.tween_property(c, "position", target, 0.25).set_ease(Tween.EASE_IN)
		tween.tween_property(c, "modulate:a", 0.0, 0.25).set_ease(Tween.EASE_IN)
	tween.set_parallel(false)
	tween.tween_callback(func():
		for c in cards:
			c.queue_free()
		_update_reaction_button()
	)

func _update_hand_ui(animate_from_deck_count: int = 0):
	"""Update card hand display — 좌우 경계 내 정렬, 선택 카드 수직·2배 간격"""
	for child in card_hand_container.get_children():
		child.queue_free()

	var hand: Array
	var current_energy: int
	if new_combat_manager:
		hand = new_hand
		current_energy = _get_new_manager_energy()
	else:
		hand = DeckManager.get_hand_cards()
		current_energy = CombatManager.get_current_energy()

	if hand.is_empty():
		return

	var card_scene = preload("res://ui/components/CardHandItem.tscn")
	var num_cards = hand.size()
	var card_w = 91.0
	var container_w = max(card_w, card_hand_container.size.x)
	var sel_idx = currently_selected_card_index

	# 좌(0) ~ 우(container_w - card_w) 경계 내, 선택 시 2배 간격
	var total_span = container_w - card_w
	var positions_x: Array[float] = []
	positions_x.resize(num_cards)
	if num_cards <= 1:
		positions_x[0] = 0.0
	elif sel_idx >= 0:
		var gap_units: float = 0.0
		for i in range(1, num_cards):
			gap_units += 2.0 if (i - 1 == sel_idx or i == sel_idx) else 1.0
		var unit = total_span / gap_units
		positions_x[0] = 0.0
		for i in range(1, num_cards):
			var gap = unit * 2.0 if (i - 1 == sel_idx or i == sel_idx) else unit
			positions_x[i] = positions_x[i - 1] + gap
	else:
		for i in range(num_cards):
			positions_x[i] = i * total_span / float(num_cards - 1)

	# 기울기: 선택=0°, 외곽 최대 ±15°
	const MAX_ANGLE = 15.0
	var base_y = 25.0
	var arc_depth = 16.0

	var deck_pos = _get_deck_ui_pos()
	for i in range(num_cards):
		var card = hand[i]
		var card_item = card_scene.instantiate()
		card_hand_container.add_child(card_item)

		var card_dict: Dictionary
		var card_cost: int
		if new_combat_manager and card is Card:
			card_dict = _card_to_dict(card)
			card_cost = card.cost
		else:
			card_dict = card
			card_cost = int(card.get("cost", 0))

		card_item.set_card(card_dict, i)
		card_item.set_affordable(current_energy >= card_cost)

		var x_pos = positions_x[i]
		var angle: float = 0.0
		if i != sel_idx and num_cards > 1:
			var t = float(i) / (num_cards - 1)
			angle = lerp(-MAX_ANGLE, MAX_ANGLE, t)
		var normalized_pos = (float(i) / max(1, num_cards - 1) - 0.5) * 2.0 if num_cards > 1 else 0.0
		var y_pos = base_y + abs(normalized_pos) * arc_depth
		if i == sel_idx:
			y_pos -= 40

		var is_new_draw = animate_from_deck_count > 0 and i >= num_cards - animate_from_deck_count
		card_item.position = deck_pos if is_new_draw else Vector2(x_pos, y_pos)
		card_item.set_meta("original_y", y_pos)
		card_item.rotation_degrees = angle
		card_item.z_index = i
		card_item.set_meta("base_x", x_pos)
		card_item.set_meta("base_index", i)

		if i == sel_idx:
			card_item.set_selected(true)
			card_item.z_index = 2000
			currently_selected_card_item = card_item

		card_item.card_clicked.connect(_on_card_pressed)
		card_item.card_hovered.connect(_on_card_hovered.bind(card_item))
		card_item.card_unhovered.connect(_on_card_unhovered.bind(card_item))

		if is_new_draw:
			var final_pos = Vector2(x_pos, y_pos)
			var tw = create_tween()
			tw.tween_property(card_item, "position", final_pos, 0.2).set_ease(Tween.EASE_OUT)

	_update_reaction_button()

func _refresh_hand_layout():
	"""선택 변경 시 레이아웃 재계산"""
	call_deferred("_update_hand_ui", 0)

func _reset_card_positions():
	"""Reset all cards to base positions"""
	for child in card_hand_container.get_children():
		if child.has_meta("base_x"):
			child.position.x = child.get_meta("base_x")

func _restore_card_position(card_item: Control):
	"""Restore card to original Y position"""
	if card_item and card_item.has_meta("original_y"):
		card_item.position.y = card_item.get_meta("original_y")

# === Card Interaction ===

func _on_card_pressed(card_index: int):
	"""카드 탭 처리
	- DEF / SKILL : 1탭 → 즉시 사용 (대상 선택 불필요)
	- ATK         : 1탭 → 선택 + 타겟 모드 진입 (드래그 화살표 표시)
	                같은 카드 재탭 → 취소
	"""
	var hand: Array
	if new_combat_manager:
		hand = new_hand
	else:
		hand = DeckManager.get_hand_cards()

	if card_index < 0 or card_index >= hand.size():
		return

	var card = hand[card_index]

	# ── 에너지 확인 ──────────────────────────────────────
	var card_cost: int
	var current_energy: int
	if new_combat_manager and card is Card:
		card_cost = card.cost
		current_energy = _get_new_manager_energy()
	else:
		card_cost = int(card.get("cost", 0))
		current_energy = CombatManager.get_current_energy()

	if current_energy < card_cost:
		add_combat_log("에너지 부족!")
		return

	# ── 카드 타입 판별 ────────────────────────────────────
	# new_combat_manager 에서는 card.type = "ATK" / "DEF" / "SKILL"
	# legacy에서는 TYPE_TO_DISPLAY 거친 "Attack" / "Defense" / ...
	var is_atk: bool
	var card_name: String
	if new_combat_manager and card is Card:
		is_atk = (card.type == "ATK")
		card_name = card.name
	else:
		var display_type = card.get("type", "Attack")
		is_atk = (display_type == "Attack")
		card_name = card.get("name", "???")

	# ── 비공격 카드 (DEF / SKILL) : 2탭 (선택 → 사용) ────────
	if not is_atk:
		var card_item_def: Control = null
		for child in card_hand_container.get_children():
			if child.card_index == card_index:
				card_item_def = child
				break
		if not card_item_def:
			return
		# 이미 선택된 같은 카드 재탭 → 사용
		if currently_selected_card_index == card_index and not selecting_target:
			if currently_selected_card_item:
				currently_selected_card_item.set_selected(false)
			currently_selected_card_index = -1
			currently_selected_card_item = null
			if new_combat_manager and card is Card:
				new_combat_manager.player_play_card(card)
			else:
				request_action("card_played", {"card_index": card_index, "target": -1})
			add_combat_log("%s 사용" % card_name)
			return
		# 첫 탭: 선택 (내용 보임, ATK처럼 위로 올리기)
		if currently_selected_card_item:
			currently_selected_card_item.set_selected(false)
		_cancel_target_selection()
		currently_selected_card_index = card_index
		currently_selected_card_item = card_item_def
		card_item_def.set_selected(true)
		if card_item_def.has_meta("original_y"):
			card_item_def.position.y = card_item_def.get_meta("original_y") - 40
		else:
			card_item_def.position.y -= 40
		card_item_def.z_index = 2000
		_refresh_hand_layout()
		add_combat_log("%s 선택 — 한번 더 누르면 사용" % card_name)
		return

	# ── 공격 카드 (ATK) : 선택 → 타겟 드래그/탭 ──────────
	var card_item: Control = null
	for child in card_hand_container.get_children():
		if child.card_index == card_index:
			card_item = child
			break

	if not card_item:
		return

	# 이미 선택된 같은 카드를 재탭 → 취소
	if currently_selected_card_index == card_index and selecting_target:
		currently_selected_card_item.set_selected(false)
		currently_selected_card_index = -1
		currently_selected_card_item = null
		_cancel_target_selection()
		_refresh_hand_layout()
		add_combat_log("취소됨")
		return

	# 기존 선택 해제
	if currently_selected_card_item:
		currently_selected_card_item.set_selected(false)

	# 카드 선택 (위로 올리기)
	currently_selected_card_index = card_index
	currently_selected_card_item = card_item
	card_item.set_selected(true)
	if card_item.has_meta("original_y"):
		card_item.position.y = card_item.get_meta("original_y") - 40
	else:
		card_item.position.y -= 40
	card_item.z_index = 2000
	_refresh_hand_layout()

	# 즉시 타겟 선택 모드 진입 + 드래그 화살표 시작
	_enter_target_selection_mode()
	var card_center_global = card_item.get_global_position() + Vector2(card_item.size.x * 0.5, card_item.size.y * 0.3)
	_draw_arrow_from = get_global_transform_with_canvas().affine_inverse() * card_center_global
	_draw_arrow_to = _draw_arrow_from
	_draw_arrow_visible = true
	queue_redraw()
	add_combat_log("%s 선택 — 적을 탭하거나 드래그" % card_name)

func _on_card_hovered(card_index: int, card_item: Control):
	"""Handle card hover"""
	if not card_item or card_index == currently_selected_card_index:
		return
	
	if not card_item.has_meta("original_y"):
		card_item.set_meta("original_y", card_item.position.y)
	
	var original_y = card_item.get_meta("original_y")
	card_item.position.y = original_y - 20
	card_item.z_index = 1000

func _on_card_unhovered(card_item: Control):
	"""Handle card unhover"""
	if not card_item or card_item == currently_selected_card_item:
		return
	
	if card_item.has_meta("original_y"):
		card_item.position.y = card_item.get_meta("original_y")

# === Targeting ===

func _enter_target_selection_mode():
	"""타겟 선택 모드 진입 (ATK 카드 전용)"""
	selecting_target = true
	selected_card_index = currently_selected_card_index

signal target_selection_changed(monster_index: int)  # -1=해제, >=0=선택된 몬스터

func on_monster_clicked(monster_index: int):
	"""Handle monster click — 2단계: 1클릭=대상 선택, 2클릭=공격 발동"""
	if not selecting_target:
		return

	if new_combat_manager:
		var enemies = new_combat_manager.enemies
		if monster_index < 0 or monster_index >= enemies.size():
			return
		if not enemies[monster_index].is_alive():
			add_combat_log("Target already dead!")
			return
	else:
		var monsters = CombatManager.monsters
		if monster_index < 0 or monster_index >= monsters.size():
			return
		if monsters[monster_index].hp <= 0:
			add_combat_log("Target already dead!")
			return

	if _selected_target_index == monster_index:
		# 같은 대상 재클릭 → 공격 발동
		_play_card_with_target(currently_selected_card_index, monster_index)
		_clear_target_selection()
	else:
		# 새 대상 선택 (또는 첫 선택)
		_set_target_selection(monster_index)
		add_combat_log("대상 선택됨 — 한번 더 클릭하면 공격")

func _get_first_alive_monster() -> int:
	"""Get index of first alive monster"""
	var monsters = CombatManager.monsters
	for i in range(monsters.size()):
		if monsters[i].hp > 0:
			return i
	return -1

func _play_card_with_target(card_index: int, target_index: int):
	"""Play selected attack card with target"""
	_clear_target_selection()
	if currently_selected_card_item:
		currently_selected_card_item.set_selected(false)

	currently_selected_card_index = -1
	currently_selected_card_item = null
	selected_card_index = -1
	# 드래그 화살표 숨기기 (selecting_target도 false로 변경)
	_cancel_target_selection()

	if new_combat_manager:
		if card_index >= 0 and card_index < new_hand.size():
			var card = new_hand[card_index]
			new_combat_manager.player_play_card(card, target_index)
	else:
		request_action("card_played", {"card_index": card_index, "target": target_index})
	add_combat_log("Attacked target #%d" % (target_index + 1))

func _set_target_selection(monster_index: int):
	_selected_target_index = monster_index
	emit_signal("target_selection_changed", monster_index)

func _clear_target_selection():
	_selected_target_index = -1
	emit_signal("target_selection_changed", -1)

func _cancel_target_selection():
	"""타겟 선택 취소 + 드래그 화살표 숨김"""
	selecting_target = false
	selected_card_index = -1
	_clear_target_selection()
	is_dragging = false

	# 드래그 화살표 숨기기
	_draw_arrow_visible = false
	queue_redraw()

	if drag_arrow:
		drag_arrow.queue_free()
		drag_arrow = null

# === Button Handlers ===

func _on_pass_pressed():
	"""Pass button — ATB: 새 카드 5장/손패→무덤 (10초쿨). TB: 턴 종료"""
	if new_combat_manager:
		if new_combat_manager is CombatManagerATB:
			if new_combat_manager.is_pass_ready():
				new_combat_manager.player_pass_atb()
				add_combat_log("Pass — 새 카드 5장 드로우")
			else:
				var remain = new_combat_manager.get_pass_timer_remaining() if new_combat_manager else 0
				add_combat_log("Pass 대기중 (%.0f초 후 가능)" % remain)
		elif new_combat_manager.has_method("player_end_turn"):
			new_combat_manager.player_end_turn()
			add_combat_log("턴 종료")
	else:
		request_action("pass", {})
		add_combat_log("Player passed.")

func _on_auto_pressed():
	"""Auto button"""
	if new_combat_manager:
		_auto_enabled = not _auto_enabled
		var ai = new_combat_manager.get("auto_ai")
		if ai and ai.has_method("set_mode"):
			# ATBAutoAI와 TurnBasedAutoAI 모두 AutoMode.FULL=2, MANUAL=0 사용
			if ai is ATBAutoAI:
				ai.set_mode(ATBAutoAI.AutoMode.FULL if _auto_enabled else ATBAutoAI.AutoMode.MANUAL)
			elif ai is TurnBasedAutoAI:
				ai.set_mode(TurnBasedAutoAI.AutoMode.FULL if _auto_enabled else TurnBasedAutoAI.AutoMode.MANUAL)
			else:
				ai.set("mode", 2 if _auto_enabled else 0)
		if _auto_enabled:
			auto_button.text = "Auto: ON"
			_apply_button_style(auto_button, UITheme.COLORS.primary)
		else:
			auto_button.text = "Auto"
			_apply_button_style(auto_button, UITheme.COLORS.panel)
	else:
		request_action("auto_toggle", {})
		if CombatManager.auto_battle_enabled:
			auto_button.text = "Auto: ON"
			_apply_button_style(auto_button, UITheme.COLORS.primary)
		else:
			auto_button.text = "Auto"
			_apply_button_style(auto_button, UITheme.COLORS.panel)

func _on_speed_pressed():
	"""Speed button"""
	if new_combat_manager:
		if _speed == 1.0:
			_speed = 2.0
		elif _speed == 2.0:
			_speed = 3.0
		elif _speed == 3.0:
			_speed = 0.5
		else:
			_speed = 1.0
		if new_combat_manager.has_method("set_speed"):
			new_combat_manager.set_speed(_speed)
		elif "speed_multiplier" in new_combat_manager:
			new_combat_manager.speed_multiplier = _speed
		speed_button.text = "Speed: %.1f×" % _speed
	else:
		var speed = CombatManager.speed_multiplier
		if speed == 1.0:
			speed = 2.0
		elif speed == 2.0:
			speed = 3.0
		elif speed == 3.0:
			speed = 0.5
		else:
			speed = 1.0
		request_action("speed_change", {"speed": speed})
		speed_button.text = "Speed: %.1f×" % speed

# === Signal Handlers ===

func _on_entity_updated(entity_type: String, index: int):
	"""Entity updated"""
	pass  # TopArea handles this

func _on_combat_log_updated(message: String):
	"""Combat log updated"""
	add_combat_log(message)

func _on_combat_ended(victory: bool):
	"""Combat ended - log result"""
	if victory:
		add_combat_log("=== VICTORY ===")
	else:
		add_combat_log("=== DEFEAT ===")
	
	# Note: InRun_v4 handles reward modal via CombatManager.combat_ended signal

func _on_energy_changed(current: int, max_val: int):
	"""Energy changed"""
	if energy_orb:
		energy_orb.set_energy(current, max_val)

func _on_energy_timer_updated(progress: float):
	"""Energy timer updated (legacy CombatManager)"""
	if energy_orb:
		energy_orb.set_timer_progress(progress)

func _on_energy_timer_progress(progress: float):
	"""Energy timer progress (new ATB combat - EnergyOrb 외곽 쿨타임 게이지)"""
	if energy_orb:
		energy_orb.set_timer_progress(progress)

func _on_hand_changed():
	"""Hand changed"""
	_update_deck_ui()
	_update_hand_ui()

# === Input Handling (Drag Targeting) ===

func _input(event):
	# ── ESC / 백 버튼 취소 ────────────────────────────────
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if selecting_target or currently_selected_card_item:
			if currently_selected_card_item:
				currently_selected_card_item.set_selected(false)
				currently_selected_card_index = -1
				currently_selected_card_item = null
			_cancel_target_selection()
			_refresh_hand_layout()
			add_combat_log("취소됨")

# ── _process : 드래그 화살표 실시간 업데이트 ──────────────

func _process(_delta):
	if _draw_arrow_visible and selecting_target:
		_draw_arrow_to = get_global_transform_with_canvas().affine_inverse() * get_global_mouse_position()
		queue_redraw()

# ── _draw : 화살표 렌더링 (ATK 카드 타겟팅) ──────────────────

func _draw():
	if not _draw_arrow_visible:
		return
	var from = _draw_arrow_from
	var to   = _draw_arrow_to
	var dist = from.distance_to(to)
	if dist < 10.0:
		return

	var arrow_color = Color(1.0, 0.85, 0.1, 0.9)  # 노란색
	var line_width  = 4.0

	# 몸통 선
	draw_line(from, to, arrow_color, line_width, true)

	# 화살촉
	var dir  = (to - from).normalized()
	var perp = Vector2(-dir.y, dir.x)
	var tip_size = 18.0
	draw_line(to, to - dir * tip_size + perp * tip_size * 0.55, arrow_color, line_width, true)
	draw_line(to, to - dir * tip_size - perp * tip_size * 0.55, arrow_color, line_width, true)

# ── 리액션 버튼 갱신 ─────────────────────────────────────

func _update_reaction_button():
	"""손패에서 PARRY > DODGE > GUARD 우선순위로 리액션 카드 선정"""
	if not reaction_button:
		return
	if not new_combat_manager:
		reaction_button.text = "방어"
		reaction_button.disabled = true
		_apply_button_style(reaction_button, UITheme.COLORS.panel)
		return

	_reaction_card = null
	var best_priority = -1
	var priority_map = {"PARRY": 3, "DODGE": 2, "GUARD": 1}

	for card in new_hand:
		if not (card is Card):
			continue
		for tag in card.tags:
			var p: int = priority_map.get(tag, 0)
			if p > best_priority and card.cost <= _get_new_manager_energy():
				best_priority = p
				_reaction_card = card

	if _reaction_card != null:
		var tag_found = ""
		for tag in _reaction_card.tags:
			if tag in priority_map:
				tag_found = tag
				break
		var label_map = {"PARRY": "패링", "DODGE": "회피", "GUARD": "방어"}
		reaction_button.text = label_map.get(tag_found, "방어")
		reaction_button.disabled = false
		# 활성: 파란색 계열
		var active_style = StyleBoxFlat.new()
		active_style.bg_color = Color(0.15, 0.42, 0.75)
		active_style.corner_radius_top_left    = 8
		active_style.corner_radius_top_right   = 8
		active_style.corner_radius_bottom_left = 8
		active_style.corner_radius_bottom_right = 8
		active_style.content_margin_left   = 12
		active_style.content_margin_right  = 12
		active_style.content_margin_top    = 10
		active_style.content_margin_bottom = 10
		reaction_button.add_theme_stylebox_override("normal",  active_style)
		reaction_button.add_theme_stylebox_override("hover",   active_style)
		reaction_button.add_theme_stylebox_override("pressed", active_style)
		reaction_button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
		reaction_button.add_theme_color_override("font_color", Color.WHITE)
	else:
		reaction_button.text = "방어"
		reaction_button.disabled = true
		_apply_button_style(reaction_button, UITheme.COLORS.panel)

func _on_reaction_pressed():
	"""리액션 버튼 — 패링/회피/방어 카드 즉시 사용"""
	if _reaction_card == null:
		return
	if new_combat_manager:
		new_combat_manager.player_play_card(_reaction_card)
	else:
		var idx = new_hand.find(_reaction_card)
		if idx >= 0:
			request_action("card_played", {"card_index": idx, "target": -1})
	_reaction_card = null

# ── Auto 버튼 동기화 (combat_started 신호에서 호출) ─────────

func _on_pass_timer_updated(remaining: float, _duration: float):
	"""ATB Pass 버튼 활성화 (10초 쿨 완료 시)"""
	if pass_button and new_combat_manager is CombatManagerATB:
		pass_button.disabled = (remaining > 0)

func _on_combat_started_sync():
	"""전투 시작 시 AI 모드에 맞게 Auto 버튼 상태 동기화"""
	if not new_combat_manager:
		return
	var ai = new_combat_manager.get("auto_ai")
	if ai and "mode" in ai:
		# FULL=2 (ATB/TB 공통)
		_auto_enabled = (ai.mode == 2)
		if _auto_enabled:
			auto_button.text = "Auto: ON"
			_apply_button_style(auto_button, UITheme.COLORS.primary)
		else:
			auto_button.text = "Auto"
			_apply_button_style(auto_button, UITheme.COLORS.panel)
