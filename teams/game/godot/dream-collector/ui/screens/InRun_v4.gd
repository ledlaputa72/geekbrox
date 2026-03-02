extends Control

const DEBUG_SWITCH := false  # true: 화면 전환/전투 상세 로그

# InRun_v4 - Unified In-Run Screen with Dynamic BottomArea
# 통합 인런 화면 (Portrait 390x844)
#
# Architecture:
# - TopArea (280px): Hero (영구 유지) + Characters (Monster/NPC, 등장 애니메이션)
# - BottomArea (564px): 동적 UI 컨테이너 (iframe 패턴)
#
# Key Features:
# - Hero: 모든 모드에서 동일 오브젝트 유지 (삭제 안 함)
# - Background: home_bg.png 수평 스크롤 (탐험 시)
# - Characters: 화면 오른쪽 밖에서 fly-in 애니메이션
# - Reward Modal: 전투 보상을 모달로 표시
# - CharacterNode: 공용 컴포넌트 (Hero/Monster/NPC 모두 동일)

# UI References
@onready var top_bar = $TopBar
@onready var settings_button = $TopBar/HBox/LeftPanel/SettingsButton
@onready var run_progress_bar = $TopBar/HBox/RightPanel/RunProgressBar
@onready var top_area = $TopArea
@onready var battle_scene = $TopArea/BattleScene
@onready var background = $TopArea/BattleScene/BattleSceneBg
@onready var hero_area = $TopArea/BattleScene/HeroArea
@onready var character_area = $TopArea/BattleScene/CharacterArea
@onready var bottom_area = $BottomArea
@onready var reward_modal = $RewardModal

# Current state
enum ScreenState {
	EXPLORATION,
	COMBAT,
	SHOP,
	NPC_DIALOG,
	STORY
}

var current_state: ScreenState = ScreenState.EXPLORATION
var current_bottom_ui: BaseBottomUI = null
var exploration_ui: BaseBottomUI = null  # 영구 유지 탐험 UI (로그 보존)

# Characters
var hero_node: CharacterNode = null  # 영구 유지
var character_nodes: Array[CharacterNode] = []  # 재사용 풀
var _combat_monster_character_indices: Array[int] = []  # enemies 인덱스 → character_nodes 인덱스 매핑

# Background scroll
var background_scroll_offset: float = 0.0
var background_scroll_speed: float = 30.0  # px/s
var is_scrolling: bool = false

# BottomUI scene paths
const BOTTOM_UI_PATHS = {
	ScreenState.EXPLORATION: "res://ui/bottom_uis/ExplorationBottomUI.tscn",
	ScreenState.COMBAT: "res://ui/bottom_uis/CombatBottomUI.tscn",
	ScreenState.SHOP: "res://ui/bottom_uis/ShopBottomUI.tscn",
	ScreenState.NPC_DIALOG: "res://ui/bottom_uis/NPCDialogBottomUI.tscn",
	ScreenState.STORY: "res://ui/bottom_uis/StoryBottomUI.tscn"
}

# ── 전투 모드 분기 ─────────────────────────────────────
# 일반 전투 = ATB, 보스 전투 = 턴베이스 (SettingsManager로 오버라이드 가능)
# F1 = ATB 강제, F2 = 턴베이스 강제
const COMBAT_SCENE_ATB = "res://scenes/combat/CombatSceneATB.tscn"
const COMBAT_SCENE_TB  = "res://scenes/combat/CombatSceneTB.tscn"

var current_is_boss : bool = false        # 현재 전투가 보스전인지
var active_combat_scene : Node = null     # 현재 활성 전투 씬 (ATB or TB)
var combat_mode_override : String = ""    # "" | "ATB" | "TURNBASED" (F1/F2 단축키)

# 카드 사용 애니메이션 큐 (순서대로 적용)
var _card_flight_layer: CanvasLayer = null
var _card_animation_queue: Array = []
var _card_animation_running: bool = false

# 효과 숫자 표시용 이전 값 (힐/블록 증가량 계산)
var _last_player_hp: int = -1
var _last_player_block: int = -1
var _last_enemy_hp: Dictionary = {}  # enemy_idx -> hp

# 액션(턴) 큐 UI (최대 5개 표시)
const ACTION_QUEUE_MAX := 5
var _action_queue_root: Control = null
var _action_queue_name_label: Label = null
var _action_queue_icon_labels: Array = []   # Array[Label]
var _action_queue_pointer_labels: Array = [] # Array[Label]
var _action_queue_icon_panels: Array = []   # Array[Control]
var _action_queue_update_accum: float = 0.0
var _action_queue_last_entries: Array = []
var _action_queue_anim_overlay: Control = null
var _action_queue_animating: bool = false

# "현재 턴" 오버라이드 (카드 사용 등으로 잠깐 플레이어 표시)
var _action_queue_override_actor: Dictionary = {}
var _action_queue_override_until_ms: int = 0

# 리액션 "!" 표시를 신호 기반으로 동기화 (판정 타이밍과 동일)
var _reaction_alert_enemy_idx: int = -1
var _reaction_alert_unblockable: bool = false

func _ready():

	# 카드 비행 애니메이션용 CanvasLayer (최상단)
	_card_flight_layer = CanvasLayer.new()
	_card_flight_layer.layer = 100
	add_child(_card_flight_layer)

	_setup_top_bar()
	_setup_progress_bar()
	_create_hero_permanent()
	_setup_action_queue_ui()
	_set_action_queue_visible(false)
	_apply_theme_styles()
	_setup_reward_modal()
	_create_exploration_ui_permanent()  # 탐험 UI 한 번만 생성 (로그 영구 보존)

	# Start with exploration mode
	switch_to_exploration()

func _create_exploration_ui_permanent():
	# ExplorationBottomUI를 한 번만 생성 — 이후 hide/show로 로그 보존
	var scene = load(BOTTOM_UI_PATHS[ScreenState.EXPLORATION])
	if not scene:
		push_error("[InRun_v4] Failed to load ExplorationBottomUI scene")
		return
	exploration_ui = scene.instantiate()
	exploration_ui.visible = false  # switch_to_exploration에서 표시
	bottom_area.add_child(exploration_ui)
	exploration_ui.ui_action_requested.connect(_on_bottom_ui_action)
	exploration_ui.ui_closed.connect(_on_bottom_ui_closed)
	if DEBUG_SWITCH: print("[InRun_v4] ExplorationBottomUI created")

func _setup_top_bar():
	# Setup TopBar
	# TopBar background style (dark)
	var top_bar_style = StyleBoxFlat.new()
	top_bar_style.bg_color = Color(0.15, 0.15, 0.25, 1)  # Dark purple
	top_bar_style.border_width_bottom = 2
	top_bar_style.border_color = UITheme.COLORS.primary
	top_bar.add_theme_stylebox_override("panel", top_bar_style)

	# Settings button
	UITheme.apply_button_style(settings_button, "primary")
	settings_button.pressed.connect(_on_settings_pressed)

func _setup_progress_bar():
	# Setup RunProgressBar with dream nodes from GameManager
	var nodes = []

	# Check if dream nodes exist in GameManager
	if GameManager.get_total_node_count() > 0:
		# Use dream nodes from card selection
		var dream_nodes = GameManager.get_dream_nodes()

		# Add start node
		nodes.append({
			"type": "start",
			"icon": "",
			"text": "꿈 속으로 들어섰다...",
			"current": true,
			"completed": false
		})

		# Convert dream nodes to progress bar format
		for node_data in dream_nodes:
			var text = ""
			match node_data.type:
				"combat":
					text = "전투가 시작된다!"
				"shop":
					text = "상점을 발견했다!"
				"npc":
					text = "누군가와 마주쳤다..."
				"narration":
					text = "이야기가 펼쳐진다..."
				"boss":
					text = "보스가 나타났다!"

			nodes.append({
				"type": node_data.type,
				"icon": node_data.icon,
				"text": text,
				"current": false,
				"completed": false
			})

		print("[InRun_v4] Loaded %d dream nodes from GameManager" % dream_nodes.size())
	else:
		# Fallback to mock nodes if no dream cards selected
		print("[InRun_v4] No dream cards found, using mock nodes")
		nodes = [
			{"type": "start", "icon": "", "text": "꿈 속으로 들어섰다...", "current": true, "completed": false},
			{"type": "combat", "icon": "", "text": "슬림 무리 발견!", "current": false, "completed": false},
			{"type": "shop", "icon": "", "text": "신비한 상점 발견!", "current": false, "completed": false},
			{"type": "boss", "icon": "", "text": "악몽의 주인 등장!", "current": false, "completed": false}
		]

	run_progress_bar.set_nodes(nodes, 0)  # Start at first node

	# Connect signals
	run_progress_bar.node_reached.connect(_on_node_reached)
	run_progress_bar.run_completed.connect(_on_run_completed)

	print("[InRun_v4] RunProgressBar initialized with %d nodes" % nodes.size())


# ─── 매 프레임 업데이트 (배경 스크롤) ─────────────────

func _process(delta):
	# Background scrolling (Exploration mode)
	if is_scrolling and background:
		background_scroll_offset += background_scroll_speed * delta
		# 배경 이미지 너비(800px) 초과 시 리셋
		if background_scroll_offset > background.size.x:
			background_scroll_offset = 0.0
		background.position.x = -background_scroll_offset

	# Combat action queue UI update (COMBAT mode)
	if current_state == ScreenState.COMBAT and _action_queue_root:
		_action_queue_update_accum += delta
		if _action_queue_update_accum >= 0.15:
			_action_queue_update_accum = 0.0
			_refresh_action_queue_ui()


func _apply_theme_styles():
	pass # Apply UITheme styles
	pass

func _setup_reward_modal():
	# Setup reward modal signals
	if reward_modal:
		reward_modal.reward_claimed.connect(_on_reward_claimed)


# ─── 액션(턴) 큐 UI ───────────────────────────────────

func _setup_action_queue_ui():
	if not battle_scene:
		return
	if _action_queue_root:
		return

	# 전투 화면 바로 위(노란 박스 영역), 높이 40% 수준
	_action_queue_root = PanelContainer.new()
	_action_queue_root.name = "ActionQueueUI"
	_action_queue_root.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_action_queue_root.offset_top = 0
	_action_queue_root.offset_left = -160
	_action_queue_root.offset_right = 160
	_action_queue_root.offset_bottom = 24

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.10, 0.16, 0.85)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	_action_queue_root.add_theme_stylebox_override("panel", style)

	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 6)
	_action_queue_root.add_child(hbox)

	_action_queue_anim_overlay = Control.new()
	_action_queue_anim_overlay.name = "ActionQueueAnimOverlay"
	_action_queue_anim_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_action_queue_anim_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_action_queue_anim_overlay.visible = false
	_action_queue_root.add_child(_action_queue_anim_overlay)

	_action_queue_name_label = Label.new()
	_action_queue_name_label.text = ""
	_action_queue_name_label.add_theme_font_size_override("font_size", 12)
	_action_queue_name_label.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0, 1.0))
	_action_queue_name_label.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	hbox.add_child(_action_queue_name_label)

	# 아이콘 50% 축소(15x15), 삼각형 위쪽(▲) 화이트, 아이콘과 같은 높이 유지
	for i in range(ACTION_QUEUE_MAX):
		var slot = VBoxContainer.new()
		slot.alignment = BoxContainer.ALIGNMENT_CENTER
		slot.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		slot.add_theme_constant_override("separation", 0)

		var icon_panel = Panel.new()
		icon_panel.custom_minimum_size = Vector2(15, 15)
		var icon_style = StyleBoxFlat.new()
		icon_style.bg_color = Color(0.25, 0.25, 0.30, 1.0)
		icon_style.corner_radius_top_left = 8
		icon_style.corner_radius_top_right = 8
		icon_style.corner_radius_bottom_left = 8
		icon_style.corner_radius_bottom_right = 8
		icon_panel.add_theme_stylebox_override("panel", icon_style)
		slot.add_child(icon_panel)
		_action_queue_icon_panels.append(icon_panel)

		var icon_label = Label.new()
		icon_label.text = "?"
		icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		icon_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon_label.add_theme_font_size_override("font_size", 10)
		icon_panel.add_child(icon_label)
		_action_queue_icon_labels.append(icon_label)

		var pointer = Label.new()
		pointer.text = "▲"
		pointer.visible = false
		pointer.add_theme_font_size_override("font_size", 8)
		pointer.add_theme_color_override("font_color", Color.WHITE)
		slot.add_child(pointer)
		_action_queue_pointer_labels.append(pointer)

		hbox.add_child(slot)

	battle_scene.add_child(_action_queue_root)


func _set_action_queue_visible(v: bool):
	if _action_queue_root:
		_action_queue_root.visible = v


func _refresh_action_queue_ui():
	if not _action_queue_root or not active_combat_scene:
		return

	var manager = active_combat_scene.get_node_or_null("CombatManagerATB")
	var is_atb = manager != null
	if not manager:
		manager = active_combat_scene.get_node_or_null("CombatManagerTB")
	if not manager:
		return

	var entries: Array = []
	if is_atb:
		entries = _compute_action_queue_atb(manager, ACTION_QUEUE_MAX)
	else:
		entries = _compute_action_queue_tb(manager, ACTION_QUEUE_MAX)

	_update_action_queue_entries(entries)
	_refresh_turn_and_alert_ui(manager, is_atb, entries)


func _update_action_queue_entries(entries: Array):
	# 첫 적용은 즉시 반영
	if _action_queue_last_entries.is_empty() or entries.is_empty():
		_apply_action_queue_entries(entries)
		_action_queue_last_entries = entries.duplicate()
		return

	if _action_queue_animating:
		return

	var old0: Dictionary = _action_queue_last_entries[0] if _action_queue_last_entries.size() > 0 else {}
	var new0: Dictionary = entries[0] if entries.size() > 0 else {}
	if old0 == new0:
		_apply_action_queue_entries(entries)
		_action_queue_last_entries = entries.duplicate()
		return

	# "한 칸씩 밀리는" 패턴일 때만 애니메이션 (새 head == 이전 2번째)
	var can_step = (
		_action_queue_last_entries.size() >= 2
		and entries.size() >= 1
		and entries[0] == _action_queue_last_entries[1]
	)
	if can_step:
		_play_action_queue_step_animation(_action_queue_last_entries, entries)
		_action_queue_last_entries = entries.duplicate()
	else:
		_apply_action_queue_entries(entries)
		_action_queue_last_entries = entries.duplicate()


func _play_action_queue_step_animation(old_entries: Array, new_entries: Array):
	if not _action_queue_anim_overlay:
		_apply_action_queue_entries(new_entries)
		return

	_action_queue_animating = true
	_action_queue_anim_overlay.visible = true

	# 실제 슬롯 UI는 애니 동안 숨김
	for i in range(_action_queue_icon_panels.size()):
		_action_queue_icon_panels[i].visible = false
	for i in range(_action_queue_pointer_labels.size()):
		_action_queue_pointer_labels[i].visible = false

	# 기존 오버레이 자식 정리
	for c in _action_queue_anim_overlay.get_children():
		c.queue_free()

	var overlay_xform_inv = _action_queue_anim_overlay.get_global_transform_with_canvas().affine_inverse()
	var slot_pos: Array = []
	for i in range(ACTION_QUEUE_MAX):
		if i >= _action_queue_icon_panels.size():
			break
		var p: Control = _action_queue_icon_panels[i]
		var g = p.get_global_rect().get_center()
		var local_center: Vector2 = overlay_xform_inv * g
		slot_pos.append(local_center)

	var icon_sz = 15
	var make_icon_panel = func(icon_text: String) -> Control:
		var panel = Panel.new()
		panel.custom_minimum_size = Vector2(icon_sz, icon_sz)
		var icon_style = StyleBoxFlat.new()
		icon_style.bg_color = Color(0.25, 0.25, 0.30, 1.0)
		icon_style.corner_radius_top_left = 8
		icon_style.corner_radius_top_right = 8
		icon_style.corner_radius_bottom_left = 8
		icon_style.corner_radius_bottom_right = 8
		panel.add_theme_stylebox_override("panel", icon_style)
		panel.pivot_offset = Vector2(icon_sz / 2.0, icon_sz / 2.0)

		var label = Label.new()
		label.text = icon_text
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.set_anchors_preset(Control.PRESET_FULL_RECT)
		label.add_theme_font_size_override("font_size", 10)
		panel.add_child(label)
		return panel

	var icon_for = func(e: Dictionary) -> String:
		return "🧑" if str(e.get("kind", "")) == "player" else "👾"

	# 오버레이에 "현재 상태" 아이콘들을 생성
	var panels: Array = []
	var n_old = min(ACTION_QUEUE_MAX, old_entries.size(), slot_pos.size())
	var half = icon_sz / 2.0
	for i in range(n_old):
		var p = make_icon_panel.call(icon_for.call(old_entries[i]))
		var center: Vector2 = slot_pos[i]
		p.position = center - Vector2(half, half)
		_action_queue_anim_overlay.add_child(p)
		panels.append(p)

	# 맨 오른쪽 새 아이콘 (스케일 0 → 1)
	var n_new = min(ACTION_QUEUE_MAX, new_entries.size(), slot_pos.size())
	if n_new > 0 and slot_pos.size() > 0:
		var last_i = min(ACTION_QUEUE_MAX - 1, slot_pos.size() - 1)
		var right_panel = make_icon_panel.call(icon_for.call(new_entries[last_i]))
		var right_center: Vector2 = slot_pos[last_i]
		right_panel.position = right_center - Vector2(half, half)
		right_panel.scale = Vector2.ZERO
		right_panel.modulate.a = 0.0
		_action_queue_anim_overlay.add_child(right_panel)

	var tween = create_tween()
	tween.set_parallel(true)

	# 0번째: 축소+페이드 (제자리에서 사라짐)
	if panels.size() > 0:
		tween.tween_property(panels[0], "scale", Vector2.ZERO, 0.18).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		tween.tween_property(panels[0], "modulate:a", 0.0, 0.18).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# 나머지: 왼쪽으로 한 칸 이동
	for i in range(1, panels.size()):
		var target_i = i - 1
		if target_i < 0 or target_i >= slot_pos.size():
			continue
		var target_center: Vector2 = slot_pos[target_i]
		tween.tween_property(panels[i], "position", target_center - Vector2(half, half), 0.22).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

	# 오른쪽 새 아이콘: 확대+페이드 인
	for c in _action_queue_anim_overlay.get_children():
		if c is Panel and c.scale == Vector2.ZERO:
			tween.tween_property(c, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(c, "modulate:a", 1.0, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	tween.tween_callback(func():
		_action_queue_anim_overlay.visible = false
		for c in _action_queue_anim_overlay.get_children():
			c.queue_free()
		for i in range(_action_queue_icon_panels.size()):
			_action_queue_icon_panels[i].visible = true
		_apply_action_queue_entries(new_entries)
		_action_queue_animating = false
	)
	tween.play()

func _apply_action_queue_entries(entries: Array):
	if entries.is_empty():
		_action_queue_name_label.text = ""
		for i in range(ACTION_QUEUE_MAX):
			_action_queue_icon_labels[i].text = ""
			_action_queue_pointer_labels[i].visible = false
			_set_action_queue_icon_outline(i, false)
		return

	_action_queue_name_label.text = str(entries[0].get("name", ""))

	for i in range(ACTION_QUEUE_MAX):
		var has = i < entries.size()
		var icon_label: Label = _action_queue_icon_labels[i]
		var pointer: Label = _action_queue_pointer_labels[i]
		_set_action_queue_icon_outline(i, has and i == 0)
		if not has:
			icon_label.text = ""
			pointer.visible = false
			continue
		var e: Dictionary = entries[i]
		var kind: String = str(e.get("kind", ""))
		if kind == "player":
			icon_label.text = "🧑"
		else:
			icon_label.text = "👾"
		pointer.visible = (i == 0)
		pointer.text = "▲"
		pointer.add_theme_color_override("font_color", Color.WHITE)


func _set_action_queue_icon_outline(slot_index: int, enabled: bool):
	if slot_index < 0 or slot_index >= _action_queue_icon_panels.size():
		return
	var panel: Panel = _action_queue_icon_panels[slot_index]
	var style = panel.get_theme_stylebox("panel").duplicate()
	if style is StyleBoxFlat:
		var w = 2 if enabled else 0
		style.border_width_left = w
		style.border_width_top = w
		style.border_width_right = w
		style.border_width_bottom = w
		if enabled:
			style.border_color = Color.WHITE
		panel.add_theme_stylebox_override("panel", style)


func _refresh_turn_and_alert_ui(_manager, _is_atb: bool, entries: Array):
	# 1) 모든 표시 초기화
	if hero_node and hero_node.has_method("set_turn_active"):
		hero_node.set_turn_active(false)
	if hero_node and hero_node.has_method("set_alert_state"):
		hero_node.set_alert_state(false, false)
	for node in character_nodes:
		if not node:
			continue
		if node.has_method("set_turn_active"):
			node.set_turn_active(false)
		if node.has_method("set_alert_state"):
			node.set_alert_state(false, false)

	# 2) 현재 액션 대상 발밑 타원 표시 (entries[0])
	if entries.size() > 0:
		var cur: Dictionary = entries[0]
		if str(cur.get("kind", "")) == "player":
			if hero_node and hero_node.has_method("set_turn_active"):
				hero_node.set_turn_active(true)
		else:
			var idx = int(cur.get("index", -1))
			if idx >= 0 and idx < _combat_monster_character_indices.size():
				var char_idx = _combat_monster_character_indices[idx]
				if char_idx >= 0 and char_idx < character_nodes.size():
					var mon = character_nodes[char_idx]
					if mon and mon.visible and mon.has_method("set_turn_active"):
						mon.set_turn_active(true)

	# 3) 리액션 "!"은 reaction_manager 신호로 정확히 동기화 (판정 타이밍과 동일)


func _compute_action_queue_atb(manager, count: int) -> Array:
	var now_ms = Time.get_ticks_msec()
	var override_active = now_ms < _action_queue_override_until_ms and not _action_queue_override_actor.is_empty()
	var current: Dictionary = {}

	if override_active:
		current = _action_queue_override_actor.duplicate()
	elif "reaction_open" in manager and manager.reaction_open and "reaction_mgr" in manager and manager.reaction_mgr:
		var atk = manager.reaction_mgr.current_attack if "current_attack" in manager.reaction_mgr else {}
		if atk is Dictionary and atk.has("attacker") and atk["attacker"] != null:
			var attacker = atk["attacker"]
			var idx = -1
			if "enemies" in manager and manager.enemies is Array:
				idx = manager.enemies.find(attacker)
			current = {"kind": "monster", "index": idx, "name": attacker.display_name if "display_name" in attacker else "Monster"}

	var predicted = _simulate_atb_queue(manager, count)
	if current.is_empty():
		return predicted

	var out: Array = [current]
	for i in range(min(count - 1, predicted.size())):
		out.append(predicted[i])
	return out


func _simulate_atb_queue(manager, count: int) -> Array:
	if not ("player_data" in manager) or not ("enemies" in manager):
		return []

	var rate = 1.0
	if "ATB_CHARGE_RATE" in manager:
		rate = float(manager.ATB_CHARGE_RATE)

	var actors: Array[Dictionary] = []
	var p_atb = float(manager.player_data.get("atb", 0.0))
	var p_spd = float(manager.player_data.get("spd", 70.0))
	var p_name = hero_node.character_name if hero_node and "character_name" in hero_node else "Player"
	actors.append({"kind": "player", "index": -1, "name": p_name, "atb": p_atb, "spd": p_spd})

	for i in range(manager.enemies.size()):
		var e = manager.enemies[i]
		if e and e.has_method("is_alive") and not e.is_alive():
			continue
		var e_name = e.display_name if e and "display_name" in e else "Monster"
		var e_spd = float(e.spd) if e and "spd" in e else 50.0
		var e_atb = float(e.atb) if e and "atb" in e else 0.0
		actors.append({"kind": "monster", "index": i, "name": e_name, "atb": e_atb, "spd": e_spd})

	if actors.size() == 0:
		return []

	var out: Array = []
	for step in range(count):
		var best_i := -1
		var best_t := INF
		for j in range(actors.size()):
			var a = actors[j]
			var spd = float(a["spd"])
			if spd <= 0.0:
				continue
			var atb = float(a["atb"])
			var t = 0.0 if atb >= 100.0 else (100.0 - atb) / (spd * rate)
			if t < best_t - 0.0001:
				best_t = t
				best_i = j
			elif abs(t - best_t) <= 0.0001 and best_i >= 0:
				# 동률이면 플레이어를 우선 노출 (UI 직관)
				if actors[j]["kind"] == "player" and actors[best_i]["kind"] != "player":
					best_i = j

		if best_i < 0 or best_t == INF:
			break

		var chosen = actors[best_i]
		out.append({"kind": chosen["kind"], "index": chosen["index"], "name": chosen["name"]})

		# 시간 best_t 만큼 진행 → 모두 ATB 증가
		for j in range(actors.size()):
			var a = actors[j]
			var new_atb = float(a["atb"]) + float(a["spd"]) * rate * best_t
			a["atb"] = clamp(new_atb, 0.0, 100.0)
			actors[j] = a

		# 행동 실행 후 ATB 리셋 규칙
		if chosen["kind"] == "player":
			actors[best_i]["atb"] = max(0.0, float(actors[best_i]["atb"]) - 100.0)
		else:
			actors[best_i]["atb"] = 0.0

	return out


func _compute_action_queue_tb(manager, count: int) -> Array:
	# 턴베이스는 엄밀한 타임라인 대신 "현재(플레이어/적) + 다음 대상"을 단순 표시
	var alive_enemies: Array[Dictionary] = []
	if "enemies" in manager and manager.enemies is Array:
		for i in range(manager.enemies.size()):
			var e = manager.enemies[i]
			if e and e.has_method("is_alive") and e.is_alive():
				var e_name = e.display_name if "display_name" in e else "Monster"
				alive_enemies.append({"kind": "monster", "index": i, "name": e_name})

	var p_name = hero_node.character_name if hero_node and "character_name" in hero_node else "Player"
	var base: Array = [{"kind": "player", "index": -1, "name": p_name}]
	for e in alive_enemies:
		base.append(e)
	# 반복 패턴으로 count 채우기
	var out: Array = []
	if base.is_empty():
		return out
	for i in range(count):
		out.append(base[i % base.size()])
	return out


# === TopArea Character Management ===

func _create_hero_permanent():
	# Create hero once (영구 유지) — PlayerSpriteAnimator 기반
	print("[InRun_v4] Creating permanent hero with sprite animator...")
	var CharacterNodeScene = preload("res://ui/components/CharacterNode.tscn")
	hero_node = CharacterNodeScene.instantiate()
	hero_node.setup({
		"type": "hero",
		"name": "Hero",
		"hp": 200,
		"max_hp": 200,
	})
	hero_node.position = Vector2(5, 150)
	hero_area.add_child(hero_node)

	hero_node.character_clicked.connect(_on_hero_clicked)
	hero_node.set_hp_bar_visible(true)  # 전투 시 플레이어 HP바 표시

	# Hero 애니메이션 완료 시그널 연결
	var animator = hero_node.get_sprite_animator()
	if animator:
		animator.animation_finished.connect(_on_hero_animation_finished)
		print("[InRun_v4] Hero sprite animator connected")

	print("[InRun_v4] Hero created at position: %s, size: %s" % [hero_node.position, hero_node.size])

func _get_or_create_character_node() -> CharacterNode:
	# Get available character node from pool or create new
	# Find invisible (unused) node
	for node in character_nodes:
		if not node.visible:
			return node

	# Create new node
	var CharacterNodeScene = preload("res://ui/components/CharacterNode.tscn")
	var node = CharacterNodeScene.instantiate()
	character_area.add_child(node)
	character_nodes.append(node)
	node.character_clicked.connect(_on_character_clicked)
	return node

func _spawn_monsters_from_enemies(enemy_list: Array):
	"""Monster 객체 배열로 캐릭터 노드 스폰 (CombatManager enemies와 동일 데이터)"""
	var positions = [
		Vector2(190, 110),  # Front-left
		Vector2(240, 50),   # Back-left
		Vector2(275, 110),  # Front-right
		Vector2(320, 50)    # Back-right
	]
	var z_indices = [10, 5, 10, 5]
	_combat_monster_character_indices.clear()

	for i in range(min(enemy_list.size(), 4)):
		var node = _get_or_create_character_node()
		var m = enemy_list[i]
		var hp = m.current_hp if "current_hp" in m else (m.max_hp if "max_hp" in m else 20)
		var mx = m.max_hp if "max_hp" in m else 20
		var name_str = m.display_name if "display_name" in m else ("Monster%d" % (i + 1))
		node.setup({
			"type": "monster",
			"id": m.id if "id" in m else "monster_%d" % i,
			"name": name_str,
			"hp": hp,
			"max_hp": mx,
			"sprite": "res://assets/sprite/monster1_ani.png",
			"sprite_flip": true,  # 몬스터: 플레이어 반대 방향
		})
		node.z_index = z_indices[i]
		node.set_hp_bar_visible(true)
		_combat_monster_character_indices.append(character_nodes.find(node))

		# 몬스터 애니메이션 완료 시그널 연결 (HIT/ATTACK → IDLE 복귀)
		var m_animator = node.get_sprite_animator()
		if m_animator and not m_animator.animation_finished.is_connected(_on_monster_animation_finished.bind(node)):
			m_animator.animation_finished.connect(_on_monster_animation_finished.bind(node))

		# Fly-in animation (staggered) — WALK → IDLE 전환은 CharacterNode에서 처리
		await get_tree().create_timer(i * 0.1).timeout
		node.fly_in_from_right(positions[i], 0.5)

const NPC_SPRITE_DEFAULT = "res://assets/sprite/NPC1_ani.png"   # 일반 NPC
const NPC_SPRITE_MERCHANT = "res://assets/sprite/NPC2_ani.png"  # 상인 NPC

func _spawn_npc(npc_name: String = "NPC", emoji_icon: String = "", npc_sprite: String = ""):
	# Spawn single NPC with fly-in animation — 스프라이트 애니메이션 포함
	var node = _get_or_create_character_node()

	# 스프라이트 경로 결정: 명시적 지정 > 기본 NPC1
	var sprite = npc_sprite if npc_sprite != "" else NPC_SPRITE_DEFAULT

	node.setup({
		"type": "npc",
		"id": "npc_main",
		"name": npc_name,
		"hp": 100,
		"max_hp": 100,
		"emoji": emoji_icon,
		"sprite": sprite,
		"sprite_flip": true,  # NPC: 플레이어를 바라보는 방향 (좌우 반전)
	})
	node.z_index = 10
	node.set_hp_bar_visible(false)  # NPCs don't show HP

	# Fly-in animation (WALK → IDLE 전환은 CharacterNode.fly_in_from_right에서 처리)
	node.fly_in_from_right(Vector2(255, 80), 0.5)

func _despawn_all_characters():
	# Hide all characters (monsters/NPCs) - 재사용을 위해 삭제 안 함
	for node in character_nodes:
		if node.visible:
			node.fly_out_to_right(0.3)


# === Hero 애니메이션 상태 관리 ===

func _play_hero_animation(state: PlayerSpriteAnimator.AnimState) -> void:
	"""Hero 애니메이션 재생 (우선순위 처리)"""
	_play_character_animation(hero_node, state)


func _play_character_animation(node: CharacterNode, state: PlayerSpriteAnimator.AnimState) -> void:
	"""캐릭터 애니메이션 재생 (우선순위 처리 — Hero/Monster 공용)"""
	if not node:
		return
	var animator = node.get_sprite_animator()
	if not animator:
		return

	var current = animator.get_current_state()

	# DIE 상태에서는 다른 애니메이션으로 전환 불가
	if current == PlayerSpriteAnimator.AnimState.DIE:
		return

	# ATTACK은 HIT보다 우선 — 플레이어 공격 피드백을 항상 표시
	# (2×속도 + 3마리 환경에서 HIT 차단 없이 ATTACK 애니메이션 보장)
	# DIE만 차단, 그 외 모든 전환 허용
	node.play_animation(state)


func _on_hero_animation_finished(state: int) -> void:
	"""Hero 원샷 애니메이션 완료 후 기본 상태로 복귀"""
	if state == PlayerSpriteAnimator.AnimState.DIE:
		return

	match current_state:
		ScreenState.EXPLORATION:
			_play_hero_animation(PlayerSpriteAnimator.AnimState.WALK)
		ScreenState.COMBAT:
			_play_hero_animation(PlayerSpriteAnimator.AnimState.IDLE)
		_:
			_play_hero_animation(PlayerSpriteAnimator.AnimState.IDLE)


func _on_monster_animation_finished(state: int, monster_node: CharacterNode) -> void:
	"""Monster 원샷 애니메이션 완료 후 IDLE 복귀"""
	if state == PlayerSpriteAnimator.AnimState.DIE:
		return
	if monster_node and monster_node.visible and monster_node.current_hp > 0:
		_play_character_animation(monster_node, PlayerSpriteAnimator.AnimState.IDLE)


# === BottomArea Dynamic UI Management ===

func _switch_bottom_ui(scene_path: String):
	"""탐험 UI 제외한 다른 BottomUI 전환 (탐험 UI는 숨기기만 — 로그 보존)"""
	if DEBUG_SWITCH: print("[InRun_v4] Switching to %s" % scene_path)

	# 탐험 UI 숨기기 (queue_free 하지 않음 — 로그 내용 보존)
	if exploration_ui and exploration_ui.visible:
		exploration_ui.visible = false
		exploration_ui.set_paused(true)
		if DEBUG_SWITCH: print("[InRun_v4] ExplorationUI hidden")

	# 이전 비-탐험 UI 제거
	if current_bottom_ui and current_bottom_ui != exploration_ui:
		current_bottom_ui._on_exit()
		current_bottom_ui.queue_free()
		current_bottom_ui = null

	# 새 UI 로드
	var scene = load(scene_path)
	if not scene:
		push_error("[InRun_v4] FAILED to load BottomUI: %s" % scene_path)
		return

	current_bottom_ui = scene.instantiate()
	bottom_area.add_child(current_bottom_ui)
	current_bottom_ui.ui_action_requested.connect(_on_bottom_ui_action)
	current_bottom_ui.ui_closed.connect(_on_bottom_ui_closed)
	current_bottom_ui._on_enter()
	current_bottom_ui.ui_ready.emit()

	if DEBUG_SWITCH: print("[InRun_v4] BottomUI switch complete")

func _on_bottom_ui_action(action_type: String, data: Dictionary):
	"""Handle action from BottomUI"""
	print("[InRun_v4] UI Action: %s | Data: %s" % [action_type, data])

	match action_type:
		# Exploration event triggered (from time log)
		"event_triggered":
			_handle_time_log_event(data)

		# Combat actions
		"card_played":
			CombatManager.play_card(data.get("card_index", -1), data.get("target", -1))
		"pass":
			print("Player passed.")
		"auto_toggle":
			CombatManager.toggle_auto_battle()
		"speed_change":
			CombatManager.set_speed_multiplier(data.get("speed", 1.0))

		# Shop actions
		"shop_purchase":
			var item_id = data.get("item_id", "")
			var price = data.get("price", 0)
			if GameManager.spend_gold(price):
				print("[InRun_v4] Purchased: %s for %d gold" % [item_id, price])
			else:
				print("[InRun_v4] Purchase failed: Not enough gold!")

		# NPC actions
		"npc_choice":
			_handle_npc_choice(data.get("choice_index", -1))

		# Navigation
		"leave":
			_return_to_exploration()

func _on_bottom_ui_closed():
	"""Handle BottomUI close request"""
	_return_to_exploration()

func _handle_time_log_event(event_data: Dictionary):
	"""Handle event triggered from time log"""
	print("[InRun_v4] Time log event: %s" % event_data.event_type)

	# Pause exploration log progression
	if current_bottom_ui and current_bottom_ui.has_method("set_paused"):
		current_bottom_ui.set_paused(true)

	# Trigger appropriate event based on type
	match event_data.event_type:
		"combat":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(0.5).timeout
			switch_to_combat()
		"shop":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(0.5).timeout
			switch_to_shop()
		"npc":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(0.5).timeout
			switch_to_npc_dialog()
		"narration":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(0.5).timeout
			switch_to_story()
		"boss":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(1.0).timeout  # Longer for drama
			switch_to_combat(true)  # Boss combat → 턴베이스

func _handle_npc_choice(choice_index: int):
	"""Handle NPC dialog choice"""
	print("NPC choice selected: %d" % choice_index)
	# TODO: Implement choice logic

func _return_to_exploration():
	"""Return to exploration mode (캐릭터 퇴장 → 탐험 UI 복귀)"""
	_despawn_all_characters()
	await get_tree().create_timer(0.4).timeout
	switch_to_exploration()

# === RunProgressBar Handlers ===

func _on_node_reached(node_index: int, node_data: Dictionary):
	"""Handle node arrival - 즉시 탐험 UI 정지 후 이벤트 로그 표시 → 이벤트 처리"""
	print("[InRun_v4] Node reached: ", node_index, " - ", node_data)

	var node_type = node_data.get("type", "narration")

	if node_type == "start":
		return

	# 즉시 탐험 UI 일시정지 & 대기 중인 이벤트 로그 표시
	if exploration_ui:
		exploration_ui.set_paused(true)
		exploration_ui.show_pending_event()

	match node_type:
		"narration":
			await get_tree().create_timer(1.0).timeout
			if exploration_ui:
				exploration_ui.auto_progress_timer = 0.0
				exploration_ui.set_paused(false)
		"combat":
			_handle_combat_event()
		"shop":
			_handle_shop_event()
		"npc":
			_handle_npc_event()
		"boss":
			_handle_boss_event()

func _on_run_completed():
	"""Handle run completion"""
	print("[InRun_v4] Run completed! Returning to MainLobby...")
	# TODO: Show run completion screen
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")

func _handle_combat_event():
	"""Handle combat event node (일반 전투 = ATB)"""
	print("[InRun_v4] Combat event triggered!")
	run_progress_bar.pause_progress()
	await get_tree().create_timer(1.0).timeout
	switch_to_combat(false)  # 일반 전투 = ATB

func _handle_shop_event():
	"""Handle shop event node"""
	print("[InRun_v4] Shop event triggered!")
	run_progress_bar.pause_progress()
	await get_tree().create_timer(1.0).timeout
	switch_to_shop()

func _handle_npc_event():
	"""Handle NPC event node"""
	print("[InRun_v4] NPC event triggered!")
	run_progress_bar.pause_progress()
	await get_tree().create_timer(1.0).timeout
	switch_to_npc_dialog()

func _handle_boss_event():
	"""Handle boss event node (보스 전투 = 턴베이스)"""
	print("[InRun_v4] Boss event triggered!")
	run_progress_bar.pause_progress()
	await get_tree().create_timer(1.0).timeout
	switch_to_combat(true)  # 보스 전투 = 턴베이스


# === State Switching Functions ===

func switch_to_exploration():
	"""Switch to exploration mode — 배경 스크롤 + WALK 애니메이션"""
	print("\n[InRun_v4] ===== SWITCHING TO EXPLORATION =====")
	current_state = ScreenState.EXPLORATION
	is_scrolling = true
	_set_action_queue_visible(false)

	# Hero → WALK 애니메이션
	_play_hero_animation(PlayerSpriteAnimator.AnimState.WALK)

	# 전투 시그널 해제
	if CombatManager.entity_updated.is_connected(_on_entity_updated):
		CombatManager.entity_updated.disconnect(_on_entity_updated)
	if CombatManager.damage_dealt.is_connected(_on_damage_dealt):
		CombatManager.damage_dealt.disconnect(_on_damage_dealt)

	_despawn_all_characters()

	# 비-탐험 UI 제거
	if current_bottom_ui and current_bottom_ui != exploration_ui:
		current_bottom_ui._on_exit()
		current_bottom_ui.queue_free()
		current_bottom_ui = null

	# 탐험 UI 표시 (영구 보존 — 로그 유지)
	exploration_ui.visible = true
	current_bottom_ui = exploration_ui

	# 탐험 로그 이어가기
	if exploration_ui.time_logs.is_empty():
		# 최초 진입: time_logs 로드 (첫 로그는 auto_progress_interval 후 자동 표시)
		exploration_ui._on_enter()
	else:
		# 이벤트 복귀: 타이머 리셋 후 auto_progress_interval 후 다음 로그 표시
		exploration_ui.auto_progress_timer = 0.0
		exploration_ui.set_paused(false)

	# 프로그레스바 재개
	if run_progress_bar:
		if not run_progress_bar.is_auto_progressing:
			print("[InRun_v4] Starting auto-progress...")
			run_progress_bar.start_auto_progress()
		else:
			run_progress_bar.resume_progress()

	print("[InRun_v4] ===== EXPLORATION SWITCH COMPLETE =====\n")

func switch_to_combat(is_boss: bool = false):
	"""Switch to combat mode — 일반=ATB, 보스=턴베이스 자동 분기
	   F1/F2 단축키로 강제 전환 가능 (combat_mode_override)"""
	print("\n[InRun_v4] ===== SWITCHING TO COMBAT (boss=%s) =====" % is_boss)
	current_state = ScreenState.COMBAT
	current_is_boss = is_boss
	is_scrolling = false
	_set_action_queue_visible(true)

	# Hero → IDLE (전투 대기)
	_play_hero_animation(PlayerSpriteAnimator.AnimState.IDLE)

	print("[InRun_v4] Loading CombatBottomUI...")
	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.COMBAT])
	await get_tree().process_frame

	# 몬스터 스폰 (CombatManager와 동일한 Monster 객체 사용 — HP/이름 일치)
	var enemy_nodes = _create_test_monster_nodes(current_is_boss)
	print("[InRun_v4] Spawning monsters...")
	await _spawn_monsters_from_enemies(enemy_nodes)

	# ── 전투 모드 결정 ──────────────────────────────────
	# 우선순위: 단축키 오버라이드 > SettingsManager > 기본(보스=TB, 일반=ATB)
	var combat_mode: String
	if combat_mode_override != "":
		combat_mode = combat_mode_override
	elif has_node("/root/SettingsManager"):
		combat_mode = SettingsManager.get_combat_mode(is_boss)
	else:
		combat_mode = "TURNBASED" if is_boss else "ATB"

	print("[InRun_v4] 전투 모드: %s" % combat_mode)

	if combat_mode == "TURNBASED":
		await _start_tb_combat(enemy_nodes)
	else:
		await _start_atb_combat(enemy_nodes)

	_refresh_action_queue_ui()
	print("[InRun_v4] ===== COMBAT SWITCH COMPLETE =====\n")

func _start_atb_combat(enemy_nodes: Array):
	"""ATB 전투 시작 — 일반 몬스터 전투"""
	print("[InRun_v4] ATB 전투 시작")

	# 이전 전투 씬 정리
	if active_combat_scene:
		active_combat_scene.queue_free()
		active_combat_scene = null

	# ATB 씬 로드 (없으면 기존 CombatManager 폴백)
	var atb_scene_res = load(COMBAT_SCENE_ATB)
	if atb_scene_res:
		active_combat_scene = atb_scene_res.instantiate()
		add_child(active_combat_scene)
		# 레이아웃 계산 완료 대기 (card_hand_container.size.x 가 0이 되지 않도록)
		await get_tree().process_frame
		var manager = active_combat_scene.get_node_or_null("CombatManagerATB")
		if manager:
			# ★ CombatBottomUI 먼저 연결 — start_combat()이 hand_updated 신호를 발신하기 전에!
			if current_bottom_ui and current_bottom_ui.has_method("connect_combat_manager"):
				current_bottom_ui.connect_combat_manager(manager)
				if current_bottom_ui.has_signal("target_selection_changed") and not current_bottom_ui.target_selection_changed.is_connected(_on_target_selection_changed):
					current_bottom_ui.target_selection_changed.connect(_on_target_selection_changed)
				if current_bottom_ui.has_signal("card_play_with_animation_requested") and not current_bottom_ui.card_play_with_animation_requested.is_connected(_on_card_play_animation_requested):
					current_bottom_ui.card_play_with_animation_requested.connect(_on_card_play_animation_requested)
			# 플레이어 데이터
			var p_data = {
				"hp": 200, "max_hp": 200, "atk": 10, "spd": 70.0,
				"block": 0, "status_effects": {}, "atb": 0.0
			}
			# 스타터 덱
			var deck = _get_starter_deck()
			# start_combat() → _draw_cards(5) → hand_updated 신호 발신
			# → CombatBottomUI._on_new_hand_updated() → _update_hand_ui()
			manager.start_combat(p_data, enemy_nodes, deck)
			manager.combat_ended.connect(_on_new_combat_ended)
			manager.player_hp_changed.connect(_on_new_player_hp_changed)
			manager.enemy_hp_changed.connect(_on_new_enemy_hp_changed)
			if manager.has_signal("damage_dealt"):
				manager.damage_dealt.connect(_on_new_damage_dealt)
			_connect_reaction_signals_atb(manager)
			print("[InRun_v4] ATB CombatManager 시작 완료")
			return

	# 폴백: 기존 CombatManager
	print("[InRun_v4] ATB 씬 없음 — 기존 CombatManager 폴백")
	var monsters = _get_test_monsters()
	CombatManager.start_combat(monsters)
	if not CombatManager.combat_ended.is_connected(_on_combat_ended):
		CombatManager.combat_ended.connect(_on_combat_ended)
	if not CombatManager.entity_updated.is_connected(_on_entity_updated):
		CombatManager.entity_updated.connect(_on_entity_updated)
	if not CombatManager.damage_dealt.is_connected(_on_damage_dealt):
		CombatManager.damage_dealt.connect(_on_damage_dealt)

func _start_tb_combat(enemy_nodes: Array):
	"""턴베이스 전투 시작 — 보스 전투"""
	print("[InRun_v4] 턴베이스(보스) 전투 시작")

	if active_combat_scene:
		active_combat_scene.queue_free()
		active_combat_scene = null

	var tb_scene_res = load(COMBAT_SCENE_TB)
	if tb_scene_res:
		active_combat_scene = tb_scene_res.instantiate()
		add_child(active_combat_scene)
		# 레이아웃 계산 완료 대기
		await get_tree().process_frame
		var manager = active_combat_scene.get_node_or_null("CombatManagerTB")
		if manager:
			# ★ CombatBottomUI 먼저 연결 — start_combat()이 hand_updated 신호를 발신하기 전에!
			if current_bottom_ui and current_bottom_ui.has_method("connect_combat_manager"):
				current_bottom_ui.connect_combat_manager(manager)
				if current_bottom_ui.has_signal("target_selection_changed") and not current_bottom_ui.target_selection_changed.is_connected(_on_target_selection_changed):
					current_bottom_ui.target_selection_changed.connect(_on_target_selection_changed)
				if current_bottom_ui.has_signal("card_play_with_animation_requested") and not current_bottom_ui.card_play_with_animation_requested.is_connected(_on_card_play_animation_requested):
					current_bottom_ui.card_play_with_animation_requested.connect(_on_card_play_animation_requested)
			var p_data = {
				"hp": 200, "max_hp": 200, "atk": 10,
				"block": 0, "status_effects": {}
			}
			var deck = _get_starter_deck()
			manager.start_combat(p_data, enemy_nodes, deck)
			manager.combat_ended.connect(_on_new_combat_ended)
			manager.player_hp_changed.connect(_on_new_player_hp_changed)
			manager.enemy_hp_changed.connect(_on_new_enemy_hp_changed)
			if manager.has_signal("damage_dealt"):
				manager.damage_dealt.connect(_on_new_damage_dealt)
			_connect_reaction_signals_tb(manager)
			print("[InRun_v4] TB CombatManager 시작 완료")
			return


func _connect_reaction_signals_atb(manager):
	if not manager or not ("reaction_mgr" in manager):
		return
	var rm = manager.reaction_mgr
	if rm and rm.has_signal("reaction_window_opened") and not rm.reaction_window_opened.is_connected(_on_atb_reaction_window_opened):
		rm.reaction_window_opened.connect(_on_atb_reaction_window_opened)
	if rm and rm.has_signal("reaction_window_closed") and not rm.reaction_window_closed.is_connected(_on_reaction_window_closed):
		rm.reaction_window_closed.connect(_on_reaction_window_closed)
	if rm and rm.has_signal("reaction_phase_changed") and not rm.reaction_phase_changed.is_connected(_on_reaction_phase_changed):
		rm.reaction_phase_changed.connect(_on_reaction_phase_changed)


func _connect_reaction_signals_tb(manager):
	if not manager or not ("reaction_mgr" in manager):
		return
	var rm = manager.reaction_mgr
	if rm and rm.has_signal("reaction_window_opened") and not rm.reaction_window_opened.is_connected(_on_tb_reaction_window_opened):
		rm.reaction_window_opened.connect(_on_tb_reaction_window_opened)
	if rm and rm.has_signal("reaction_window_closed") and not rm.reaction_window_closed.is_connected(_on_reaction_window_closed):
		rm.reaction_window_closed.connect(_on_reaction_window_closed)
	if rm and rm.has_signal("reaction_phase_changed") and not rm.reaction_phase_changed.is_connected(_on_reaction_phase_changed):
		rm.reaction_phase_changed.connect(_on_reaction_phase_changed)


func _on_atb_reaction_window_opened(attack: Dictionary):
	_on_reaction_window_opened_common(attack, true)


func _on_tb_reaction_window_opened(attack: Dictionary):
	_on_reaction_window_opened_common(attack, false)


func _on_reaction_window_opened_common(attack: Dictionary, is_atb: bool):
	_reaction_alert_enemy_idx = -1
	_reaction_alert_unblockable = str(attack.get("type", "")) == "UNBLOCKABLE"

	var attacker = attack.get("attacker", null)
	if attacker == null or not active_combat_scene:
		return

	var manager = active_combat_scene.get_node_or_null("CombatManagerATB") if is_atb else null
	if not manager:
		manager = active_combat_scene.get_node_or_null("CombatManagerTB")
	if not manager or not ("enemies" in manager) or not (manager.enemies is Array):
		return

	var idx = manager.enemies.find(attacker)
	_reaction_alert_enemy_idx = idx

	if idx >= 0 and idx < _combat_monster_character_indices.size():
		var cidx = _combat_monster_character_indices[idx]
		if cidx >= 0 and cidx < character_nodes.size():
			var node = character_nodes[cidx]
			if node and node.visible and node.has_method("set_alert_state"):
				node.set_alert_state(true, _reaction_alert_unblockable, "green")


func _on_reaction_phase_changed(phase: String, is_unblockable: bool):
	if _reaction_alert_enemy_idx < 0 or _reaction_alert_enemy_idx >= _combat_monster_character_indices.size():
		return
	var cidx = _combat_monster_character_indices[_reaction_alert_enemy_idx]
	if cidx < 0 or cidx >= character_nodes.size():
		return
	var node = character_nodes[cidx]
	if node and node.has_method("set_alert_state"):
		node.set_alert_state(true, is_unblockable, phase)


func _on_reaction_window_closed(_result_type: String):
	if _reaction_alert_enemy_idx >= 0 and _reaction_alert_enemy_idx < _combat_monster_character_indices.size():
		var cidx = _combat_monster_character_indices[_reaction_alert_enemy_idx]
		if cidx >= 0 and cidx < character_nodes.size():
			var node = character_nodes[cidx]
			if node and node.has_method("set_alert_state"):
				node.set_alert_state(false, false)
	_reaction_alert_enemy_idx = -1
	_reaction_alert_unblockable = false

# ── 새 전투 시스템 시그널 핸들러 ─────────────────────
func _on_new_combat_ended(result: String):
	"""새 전투 시스템(ATB/TB) 종료 핸들러"""
	print("[InRun_v4] 새 전투 종료: %s" % result)
	if active_combat_scene:
		active_combat_scene.queue_free()
		active_combat_scene = null
	_on_combat_ended(result == "WIN")

func _on_new_player_hp_changed(hp: int, _max_hp: int, block: int = 0):
	if hero_node:
		# 초기 동기화 프레임에서는 숫자 표시 생략
		if _last_player_hp < 0:
			_last_player_hp = hp
			_last_player_block = block
		else:
			var hp_delta = hp - _last_player_hp
			if hp_delta > 0:
				hero_node.show_damage_number(hp_delta, true)
			var block_delta = block - _last_player_block
			if block_delta > 0 and hero_node.has_method("show_block_number"):
				hero_node.show_block_number(block_delta)
			_last_player_hp = hp
			_last_player_block = block
		hero_node.update_hp(hp)
		hero_node.update_block(block)

func _on_new_enemy_hp_changed(enemy_idx: int, hp: int, max_hp: int):
	if enemy_idx >= 0 and enemy_idx < _combat_monster_character_indices.size():
		var char_idx = _combat_monster_character_indices[enemy_idx]
		if char_idx >= 0 and char_idx < character_nodes.size():
			var node = character_nodes[char_idx]
			if node.visible:
				# 몬스터 힐(HP 증가)도 숫자 표시 (데미지는 damage_dealt에서 표시)
				if _last_enemy_hp.has(enemy_idx):
					var prev_hp = int(_last_enemy_hp[enemy_idx])
					var delta = hp - prev_hp
					if delta > 0:
						node.show_damage_number(delta, true)
					_last_enemy_hp[enemy_idx] = hp
				else:
					_last_enemy_hp[enemy_idx] = hp
				node.update_hp(hp, 0, false, max_hp)

func _on_new_damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool):
	"""새 전투 시스템 damage_dealt → 데미지 숫자 + 애니메이션"""
	if entity_type == "hero":
		if hero_node:
			hero_node.show_damage_number(damage, is_healing)
			if not is_healing:
				_play_hero_animation(PlayerSpriteAnimator.AnimState.HIT)
			for node in character_nodes:
				if node.visible and node.current_hp > 0:
					_play_character_animation(node, PlayerSpriteAnimator.AnimState.ATTACK)
					break
	elif entity_type == "monster":
		if not is_healing:
			_play_hero_animation(PlayerSpriteAnimator.AnimState.ATTACK)
		if index >= 0 and index < _combat_monster_character_indices.size():
			var char_idx = _combat_monster_character_indices[index]
			if char_idx >= 0 and char_idx < character_nodes.size():
				var monster_node = character_nodes[char_idx]
				if monster_node.visible:
					monster_node.show_damage_number(damage, is_healing)
					if not is_healing:
						_play_character_animation(monster_node, PlayerSpriteAnimator.AnimState.HIT)

func _on_card_play_animation_requested(card_item: Control, card, target_type: String, target_index: int):
	"""카드 사용 시 비행 애니메이션: 카드 → 대상(플레이어/몬스터)으로 날아가며 축소·페이드 후 적용"""
	if not active_combat_scene or not _card_flight_layer:
		return
	# 카드 사용 순간은 "플레이어 턴"으로 보이게 잠깐 오버라이드
	_action_queue_override_actor = {
		"kind": "player",
		"index": -1,
		"name": hero_node.character_name if hero_node and "character_name" in hero_node else "Player"
	}
	_action_queue_override_until_ms = Time.get_ticks_msec() + 700
	var manager = active_combat_scene.get_node_or_null("CombatManagerATB")
	if not manager:
		manager = active_combat_scene.get_node_or_null("CombatManagerTB")
	if not manager or not manager.has_method("player_play_card"):
		return

	var entry = {"card_item": card_item, "card": card, "target_type": target_type, "target_index": target_index, "manager": manager}
	_card_animation_queue.append(entry)
	if not _card_animation_running:
		_process_next_card_animation()

func _process_next_card_animation():
	if _card_animation_queue.is_empty():
		_card_animation_running = false
		return
	_card_animation_running = true
	var entry = _card_animation_queue.pop_front()
	var card_item: Control = entry["card_item"]
	var card = entry["card"]
	var target_type: String = entry["target_type"]
	var target_index: int = entry["target_index"]
	var manager = entry["manager"]

	# 시작 위치 (카드 핸드)
	var start_pos = card_item.get_global_transform_with_canvas().get_origin()
	# 끝 위치 (대상)
	var end_pos: Vector2
	if target_type == "player":
		if hero_node:
			var rect = hero_node.get_global_rect()
			end_pos = rect.get_center()
		else:
			end_pos = Vector2(get_viewport().get_visible_rect().size.x * 0.3, get_viewport().get_visible_rect().size.y * 0.5)
	else:
		if target_index >= 0 and target_index < _combat_monster_character_indices.size():
			var char_idx = _combat_monster_character_indices[target_index]
			if char_idx >= 0 and char_idx < character_nodes.size():
				var mon = character_nodes[char_idx]
				if mon.visible:
					end_pos = mon.get_global_rect().get_center()
				else:
					end_pos = start_pos + Vector2(100, -80)
			else:
				end_pos = start_pos + Vector2(100, -80)
		else:
			end_pos = start_pos + Vector2(100, -80)

	# 원본 숨김
	card_item.visible = false

	# 복제 카드 생성 → 비행 레이어에 추가
	var dup: Control = card_item.duplicate()
	_card_flight_layer.add_child(dup)
	dup.set_anchors_preset(Control.PRESET_TOP_LEFT)
	dup.position = start_pos
	dup.size = card_item.size
	dup.pivot_offset = dup.size / 2

	# Tween: 이동 + 축소 + 페이드
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(dup, "position", end_pos - dup.size / 2, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(dup, "scale", Vector2(0.15, 0.15), 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tween.tween_property(dup, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		dup.queue_free()
		manager.player_play_card(card, target_index if target_type == "monster" else -1)
		_process_next_card_animation()
	)
	tween.play()

# ── 새 시스템용 몬스터/덱 생성 헬퍼 ──────────────────
func _create_test_monster_nodes(is_boss: bool) -> Array:
	"""Monster 노드 배열 생성 (새 전투 시스템용)"""
	var result = []
	if is_boss:
		var boss = Monster.new()
		boss.id = "boss_nightmare"
		boss.display_name = "악몽의 군주"
		boss.max_hp = 120
		boss.current_hp = 120
		boss.atk = 18
		boss.base_atk = 18
		boss.spd = 60.0
		boss.is_boss = true
		var boss_patterns: Array[Dictionary] = []
		boss_patterns.assign([
			{"type": "NORMAL",      "damage_mult": 1.0},
			{"type": "HEAVY",       "damage_mult": 2.0},
			{"type": "UNBLOCKABLE", "damage_mult": 1.5},
			{"type": "BUFF",        "stat": "atk", "value": 3},
		])
		boss.action_patterns = boss_patterns
		result.append(boss)
	else:
		var monster_specs = [
			{"name": "슬라임A", "hp": 20, "atk": 6,  "spd": 50.0},
			{"name": "슬라임B", "hp": 15, "atk": 8,  "spd": 65.0},
			{"name": "고블린",   "hp": 25, "atk": 10, "spd": 55.0},
		]
		for spec in monster_specs:
			var m = Monster.new()
			m.id = spec["name"].to_lower()
			m.display_name = spec["name"]
			m.max_hp = spec["hp"]
			m.current_hp = spec["hp"]
			m.atk = spec["atk"]
			m.base_atk = spec["atk"]
			m.spd = spec["spd"]
			var m_patterns: Array[Dictionary] = []
			m_patterns.assign([
				{"type": "NORMAL", "damage_mult": 1.0},
				{"type": "NORMAL", "damage_mult": 1.0},
				{"type": "HEAVY",  "damage_mult": 1.8},
			])
			m.action_patterns = m_patterns
			result.append(m)
	return result

func _get_starter_deck() -> Array[Card]:
	"""전투용 덱 반환 — 총 30장 (ATK10+DEF8+PARRY5+DODGE5+SKILL2)"""
	if has_node("/root/CardDatabase"):
		return CardDatabase.get_full_deck_30()

	# ── 인라인 30장 스타터 덱 ──────────────────────────────────────
	# 형식: [id, 이름, 코스트, 타입, 피해, 블록, 드로우, 장수]
	# 타입: ATK(공격), DEF(방어/패링/회피), SKILL(스킬)
	# DEF block==0 → 이름으로 PARRY/DODGE 태그 자동 부여
	# DEF block>0  → GUARD 태그 자동 부여
	var specs = [
		# ── ATK 공격 카드 (10장) ────────────────────────
		# id,          이름,          cost, type,    dmg, blk, draw, 장수
		["ATK_001", "검의 에이스",  1, "ATK",    6,   0,   0,   5],  # ×5
		["ATK_006", "번개",          1, "ATK",    8,   0,   0,   3],  # ×3
		["ATK_010", "강타",          2, "ATK",   14,   0,   0,   2],  # ×2 (고코스트)

		# ── DEF 방어 카드 / GUARD (12장) ────────────────
		["DEF_002", "철벽",          1, "DEF",    0,   5,   0,   5],  # ×5
		["DEF_006", "정의",          1, "DEF",    0,   7,   0,   4],  # ×4
		["DEF_010", "큰 방패",       2, "DEF",    0,  12,   0,   3],  # ×3 (고블록)

		# ── DEF 리액션 카드 / PARRY·DODGE (5장) ─────────
		["PAR_001", "꿈의 쳐내기",  0, "DEF",    0,   0,   1,   3],  # ×3 PARRY
		["DOD_001", "꿈의 스텝",    0, "DEF",    0,   0,   0,   2],  # ×2 DODGE

		# ── SKILL 스킬 카드 (3장) ────────────────────────
		["SKL_001", "바보",          0, "SKILL",  0,   0,   1,   3],  # ×3 드로우
	]

	var deck: Array[Card] = []
	for spec in specs:
		var count: int = spec[7]
		for _i in range(count):
			var c = Card.new()
			c.id    = spec[0]
			c.name  = spec[1]
			c.cost  = spec[2]
			c.type  = spec[3]
			c.damage = spec[4]
			c.block = spec[5]
			c.draw  = spec[6]
			# 태그 자동 부여
			if c.type == "DEF" and c.block == 0:
				if "쳐내기" in c.name:
					c.tags.append("PARRY")
				elif "스텝" in c.name:
					c.tags.append("DODGE")
				else:
					c.tags.append("GUARD")
			elif c.type == "DEF":
				c.tags.append("GUARD")
			deck.append(c)

	print("[InRun_v4] 스타터 덱 구성: %d장 (ATK:%d DEF:%d SKILL:%d)" % [
		deck.size(),
		deck.filter(func(x): return x.type == "ATK").size(),
		deck.filter(func(x): return x.type == "DEF").size(),
		deck.filter(func(x): return x.type == "SKILL").size(),
	])
	return deck

func switch_to_shop():
	"""Switch to shop mode — 배경 정지 + IDLE"""
	print("\n[InRun_v4] ===== SWITCHING TO SHOP =====")
	current_state = ScreenState.SHOP
	is_scrolling = false

	# Hero → IDLE
	_play_hero_animation(PlayerSpriteAnimator.AnimState.IDLE)

	# Clear monsters first
	print("[InRun_v4] Despawning monsters...")
	_despawn_all_characters()

	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.SHOP])

	# Wait a frame
	await get_tree().process_frame

	# Spawn merchant NPC (NPC2 — 상인 스프라이트)
	print("[InRun_v4] Spawning merchant...")
	_spawn_npc("Merchant", "", NPC_SPRITE_MERCHANT)

	print("[InRun_v4] ===== SHOP SWITCH COMPLETE =====\n")

func switch_to_npc_dialog(npc_name: String = "NPC", emoji: String = ""):
	"""Switch to NPC dialog mode — 배경 정지 + IDLE"""
	print("\n[InRun_v4] ===== SWITCHING TO NPC_DIALOG =====")
	current_state = ScreenState.NPC_DIALOG
	is_scrolling = false

	# Hero → IDLE
	_play_hero_animation(PlayerSpriteAnimator.AnimState.IDLE)

	# Clear previous characters
	_despawn_all_characters()

	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.NPC_DIALOG])

	# Wait a frame
	await get_tree().process_frame

	# Spawn NPC (NPC1 — 일반 NPC 스프라이트)
	print("[InRun_v4] Spawning NPC...")
	_spawn_npc(npc_name, emoji, NPC_SPRITE_DEFAULT)

	print("[InRun_v4] ===== NPC_DIALOG SWITCH COMPLETE =====\n")

func switch_to_story():
	"""Switch to story mode — 배경 정지 + IDLE"""
	print("\n[InRun_v4] ===== SWITCHING TO STORY =====")
	current_state = ScreenState.STORY
	is_scrolling = false

	# Hero → IDLE
	_play_hero_animation(PlayerSpriteAnimator.AnimState.IDLE)

	# Clear all characters (Story mode has no characters)
	_despawn_all_characters()

	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.STORY])

	print("[InRun_v4] ===== STORY SWITCH COMPLETE =====\n")


# === Combat End Handler ===

func _on_combat_ended(victory: bool):
	"""Handle combat end - show reward modal instead of full screen"""
	print("[InRun_v4] Combat ended: %s" % ("Victory" if victory else "Defeat"))

	# Despawn monsters with fly-out
	_despawn_all_characters()

	# Wait for animation
	await get_tree().create_timer(0.4).timeout

	# Show reward/defeat screen
	if victory:
		_show_reward_modal()
	else:
		_show_defeat_screen()

func _show_reward_modal():
	"""Show victory reward modal and apply rewards"""
	# Calculate rewards based on combat
	var gold_reward = 50  # TODO: Calculate based on monsters defeated
	var energy_reward = 10

	# Apply rewards to GameManager
	GameManager.add_gold(gold_reward)
	GameManager.add_energy(energy_reward)
	print("[InRun_v4] Rewards applied: Gold +%d, Energy +%d" % [gold_reward, energy_reward])

	# Show reward modal with display strings
	var reward_strings = [
		"Gold: +%d" % gold_reward,
		"Energy: +%d" % energy_reward,
		"New Card: Flame Strike"
	]
	reward_modal.show_victory(reward_strings)
	print("[InRun_v4] Reward modal shown")

func _show_defeat_screen():
	"""Show defeat screen (no rewards)"""
	reward_modal.show_defeat()
	print("[InRun_v4] Defeat screen shown")

func _on_reward_claimed():
	"""Reward modal closed - return to exploration"""
	print("[InRun_v4] Reward claimed, returning to exploration")
	# 탐험 UI에 전투 승리 배너 추가
	if exploration_ui and exploration_ui.has_method("add_log"):
		exploration_ui.add_log("전투 승리!", true, "victory")
	_return_to_exploration()


# === Character Click Handlers ===

func _on_hero_clicked(character_node: CharacterNode):
	"""Hero clicked"""
	print("Hero clicked: HP %d/%d" % [character_node.current_hp, character_node.max_hp])

func _on_target_selection_changed(enemy_index: int):
	"""공격 대상 선택 표시 갱신 (enemy_index = enemies 배열 인덱스)"""
	var char_idx = _combat_monster_character_indices[enemy_index] if enemy_index >= 0 and enemy_index < _combat_monster_character_indices.size() else -1
	for i in range(character_nodes.size()):
		var node = character_nodes[i]
		if node.visible:
			node.set_target_highlighted(i == char_idx)

func _on_character_clicked(character_node: CharacterNode):
	"""Monster/NPC clicked"""
	print("%s clicked: %s (HP %d/%d)" % [
		character_node.character_type.capitalize(),
		character_node.character_name,
		character_node.current_hp,
		character_node.max_hp
	])

	# If in combat and CombatBottomUI is selecting target, forward click
	if current_state == ScreenState.COMBAT and current_bottom_ui:
		if current_bottom_ui.has_method("on_monster_clicked"):
			var char_idx = character_nodes.find(character_node)
			var enemy_idx = _combat_monster_character_indices.find(char_idx) if char_idx >= 0 else -1
			if enemy_idx >= 0:
				current_bottom_ui.on_monster_clicked(enemy_idx)
				print("[InRun_v4] Monster click → CombatBottomUI: enemy_index %d" % enemy_idx)


# === Combat Entity Update Handlers ===

func _on_entity_updated(entity_type: String, index: int):
	"""Handle entity update from CombatManager"""
	if entity_type == "hero":
		# Update hero HP (DIE 애니메이션은 CharacterNode.update_hp에서 자동 처리)
		if hero_node:
			var hero_data = CombatManager.hero
			hero_node.update_hp(hero_data.hp)

	elif entity_type == "monster":
		# Update monster HP
		if index >= 0 and index < character_nodes.size():
			var monster_node = character_nodes[index]
			if monster_node.visible and index < CombatManager.monsters.size():
				var monster_data = CombatManager.monsters[index]
				monster_node.update_hp(monster_data.hp)

func _on_damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool):
	"""Handle damage dealt signal - show damage number + trigger animation"""
	if entity_type == "hero":
		# Hero가 데미지 받음 → Hero HIT + 공격한 몬스터 ATTACK
		if hero_node:
			hero_node.show_damage_number(damage, is_healing)
			if not is_healing:
				_play_hero_animation(PlayerSpriteAnimator.AnimState.HIT)
				# 첫 번째 살아있는 몬스터가 공격 애니메이션
				for node in character_nodes:
					if node.visible and node.current_hp > 0:
						_play_character_animation(node, PlayerSpriteAnimator.AnimState.ATTACK)
						break

	elif entity_type == "monster":
		# Monster가 데미지 받음 → Hero ATTACK + Monster HIT
		if not is_healing:
			_play_hero_animation(PlayerSpriteAnimator.AnimState.ATTACK)

		if index >= 0 and index < _combat_monster_character_indices.size():
			var char_idx = _combat_monster_character_indices[index]
			if char_idx >= 0 and char_idx < character_nodes.size():
				var monster_node = character_nodes[char_idx]
				if monster_node.visible:
					monster_node.show_damage_number(damage, is_healing)
					if not is_healing:
						_play_character_animation(monster_node, PlayerSpriteAnimator.AnimState.HIT)


# === Test Data ===

func _get_test_monsters() -> Array:
	"""Get test monsters for combat"""
	return [
		{"name": "Slime1", "hp": 20, "max_hp": 20, "atk": 3, "def": 1, "spd": 8, "eva": 5},
		{"name": "Slime2", "hp": 15, "max_hp": 15, "atk": 5, "def": 0, "spd": 12, "eva": 10},
		{"name": "Goblin1", "hp": 12, "max_hp": 12, "atk": 4, "def": 0, "spd": 15, "eva": 15},
		{"name": "Goblin2", "hp": 18, "max_hp": 18, "atk": 6, "def": 2, "spd": 10, "eva": 8}
	]


# === Input Handling (Cheat Keys) ===

func _input(event):
	# 드래그 릴리즈 시 몬스터 선택 (탭은 CharacterNode에서, 드래그 종료는 여기서)
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if current_state == ScreenState.COMBAT and current_bottom_ui and current_bottom_ui.get("selecting_target"):
			var pos = get_global_mouse_position()
			for i in range(character_nodes.size()):
				var node = character_nodes[i]
				if node.visible and node.current_hp > 0:
					var rect = Rect2(node.global_position, node.size)
					if rect.has_point(pos):
						var enemy_idx = _combat_monster_character_indices.find(i)
						if enemy_idx >= 0:
							current_bottom_ui.on_monster_clicked(enemy_idx)
							print("[InRun_v4] 드래그 릴리즈 → enemy %d 타겟" % enemy_idx)
						return
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				switch_to_exploration()
			KEY_2:
				switch_to_combat(false)   # 일반 전투 (ATB)
			KEY_3:
				switch_to_shop()
			KEY_4:
				switch_to_npc_dialog()
			KEY_5:
				switch_to_story()
			KEY_B:
				switch_to_combat(true)    # 보스 전투 (턴베이스) — B키
			KEY_F1:
				# F1: ATB 전투 강제 모드
				combat_mode_override = "ATB"
				print("[InRun_v4] ★ F1: ATB 전투 강제 모드 ON")
				if current_state == ScreenState.COMBAT:
					switch_to_combat(current_is_boss)
			KEY_F2:
				# F2: 턴베이스 전투 강제 모드
				combat_mode_override = "TURNBASED"
				print("[InRun_v4] ★ F2: 턴베이스 전투 강제 모드 ON")
				if current_state == ScreenState.COMBAT:
					switch_to_combat(current_is_boss)
			KEY_F3:
				# F3: 전투 모드 오버라이드 해제 (자동 판단 복귀)
				combat_mode_override = ""
				print("[InRun_v4] F3: 전투 모드 오버라이드 해제 (자동)")
			KEY_0:
				# Cheat: Toggle auto-progress pause/resume
				if run_progress_bar:
					if run_progress_bar.paused:
						print("[InRun_v4] CHEAT: Resume auto-progress")
						run_progress_bar.resume_progress()
					else:
						print("[InRun_v4] CHEAT: Pause auto-progress")
						run_progress_bar.pause_progress()
			KEY_9:
				# Cheat: Instant win combat
				if current_state == ScreenState.COMBAT and CombatManager.in_combat:
					print("[InRun_v4] CHEAT: Instant win!")
					for monster in CombatManager.monsters:
						monster.hp = 0
					CombatManager._check_combat_end()
			KEY_MINUS:
				# Cheat: Skip to next node
				if run_progress_bar:
					print("[InRun_v4] CHEAT: Skip to next node")
					run_progress_bar.progress_to_next = 1.0


# === Button Handlers ===

func _on_settings_pressed():
	"""Handle settings button press - Open Settings"""
	print("[InRun_v4] Settings button pressed")
	get_tree().change_scene_to_file("res://ui/screens/Settings.tscn")

# === Public API ===

# Note: advance_to_next_node() removed - RunProgressBar handles auto-progression
