extends Control

"""
DreamCardSelection v3.1 - 타로 카드 3단계 선택 화면

Layout:
  [TopArea]           황토색 배경 — 카드 3장 (뒷면), 완료 후 중앙 카드 표시
  [SelectedCardsArea] 황토색 배경 — 선택된 카드 슬롯 3개 (완료 시 축소)
  [BottomArea]        어두운 배경 — 로그 배너 + 시작 버튼 (완료 시 확장)

Flow:
1. 빈 화면 → 카드 3장 위에서 날아옴 (뒷면)
2. 첫 클릭: 카드 20px 하강 (선택 표시)
3. 두 번째 클릭: 뒤집기 → 슬롯으로 날아감 → 다음 스테이지
4. 3개 완료 시: 슬롯 카드 중앙 이동 + BottomArea 확장 + 완료 배너 3개 + 시작 버튼
"""

enum Stage { START, JOURNEY, END }

var current_stage: Stage = Stage.START
var selected_cards: Array = []
var card_nodes: Array = []
var slot_nodes: Array = []
var is_animating: bool = false
var _current_prompt: PanelContainer = null

@onready var top_area: Panel = $TopArea
@onready var card_container: Control = $TopArea/CardContainer
@onready var selected_area: Panel = $SelectedCardsArea
@onready var slot_container: Control = $SelectedCardsArea/SlotContainer
@onready var bottom_area: Panel = $BottomArea
@onready var log_container: VBoxContainer = $BottomArea/LogContainer
@onready var start_button: Button = $BottomArea/StartButton
@onready var bottom_nav = $BottomNav

const STAGE_PROMPTS = {
	Stage.START: "당신의 시작 꿈을 선택하세요",
	Stage.JOURNEY: "당신의 꿈의 여정을 선택하세요",
	Stage.END: "당신의 마지막 꿈을 선택하세요"
}

const STAGE_CONFIRM_MSG = {
	Stage.START: "당신 : 꿈 시작 카드가 선택되었습니다.",
	Stage.JOURNEY: "당신 : 꿈 여정 카드가 선택되었습니다.",
	Stage.END: "당신 : 꿈 종료 카드가 선택되었습니다."
}

const COMPLETION_BANNERS = [
	"당신의 꿈의 시작",
	"당신의 꿈의 여정",
	"당신의 꿈의 종착점"
]

const CARD_DATA = {
	Stage.START: [
		{"id": "start_1", "name": "시작", "emoji": "🌅", "node_count": 2, "hours": 4,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "shop", "icon": "🛒"}],
		 "difficulty": "쉬움", "rewards": "🪙50"},
		{"id": "start_2", "name": "여명", "emoji": "🌄", "node_count": 2, "hours": 3,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "npc", "icon": "💬"}],
		 "difficulty": "쉬움", "rewards": "⚡10"},
		{"id": "start_3", "name": "출발", "emoji": "🚪", "node_count": 2, "hours": 5,
		 "nodes": [{"type": "narration", "icon": "📖"}, {"type": "combat", "icon": "⚔️"}],
		 "difficulty": "쉬움", "rewards": "🎴1"}
	],
	Stage.JOURNEY: [
		{"id": "journey_1", "name": "여정", "emoji": "🗺️", "node_count": 3, "hours": 5,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "shop", "icon": "🛒"}, {"type": "combat", "icon": "⚔️"}],
		 "difficulty": "보통", "rewards": "🪙80"},
		{"id": "journey_2", "name": "탐험", "emoji": "🧭", "node_count": 3, "hours": 4,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "npc", "icon": "💬"}, {"type": "combat", "icon": "⚔️"}],
		 "difficulty": "보통", "rewards": "🎴2"},
		{"id": "journey_3", "name": "모험", "emoji": "⛰️", "node_count": 3, "hours": 6,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "combat", "icon": "⚔️"}, {"type": "combat", "icon": "⚔️"}],
		 "difficulty": "어려움", "rewards": "🪙100"}
	],
	Stage.END: [
		{"id": "end_1", "name": "종료", "emoji": "🌆", "node_count": 2, "hours": 2,
		 "nodes": [{"type": "combat", "icon": "⚔️"}, {"type": "boss", "icon": "💀"}],
		 "difficulty": "어려움", "rewards": "🎴3, 🪙150"},
		{"id": "end_2", "name": "귀환", "emoji": "🏠", "node_count": 2, "hours": 3,
		 "nodes": [{"type": "shop", "icon": "🛒"}, {"type": "boss", "icon": "💀"}],
		 "difficulty": "보통", "rewards": "🎴2, 🪙100"},
		{"id": "end_3", "name": "완성", "emoji": "👑", "node_count": 2, "hours": 2,
		 "nodes": [{"type": "npc", "icon": "💬"}, {"type": "boss", "icon": "💀"}],
		 "difficulty": "어려움", "rewards": "🎴4, ⚡20"}
	]
}

# ─── 크기 상수 ───
const CARD_W = 115
const CARD_H = 170
const SLOT_W = 105
const SLOT_H = 140

# TopArea 높이 240px → 카드 y=50 (카드 하단=220, 여유 20px)
const CARD_POSITIONS = [
	Vector2(15,  50),
	Vector2(138, 50),
	Vector2(261, 50),
]

# SelectedCardsArea y=30 → 슬롯 글로벌 y=270, 슬롯 하단 여유 확보
const SLOT_POSITIONS = [
	Vector2(20,  30),
	Vector2(143, 30),
	Vector2(266, 30),
]


# ─── Lifecycle ───

func _ready():
	_setup_ui()
	_create_empty_slots()
	await get_tree().create_timer(0.5).timeout
	_start_stage(Stage.START)


func _setup_ui():
	# TopArea - 황토색 (SelectedCardsArea와 동일 → 시각적으로 하나의 영역처럼 보임)
	var top_style = StyleBoxFlat.new()
	top_style.bg_color = Color(0.55, 0.38, 0.15, 1)
	top_area.add_theme_stylebox_override("panel", top_style)

	# SelectedCardsArea - 황토색 (TopArea와 동일)
	var selected_style = StyleBoxFlat.new()
	selected_style.bg_color = Color(0.55, 0.38, 0.15, 1)
	selected_area.add_theme_stylebox_override("panel", selected_style)

	# BottomArea - 어두운
	var bottom_style = StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.1, 0.08, 0.18, 1)
	bottom_area.add_theme_stylebox_override("panel", bottom_style)

	# StartButton
	UITheme.apply_button_style(start_button, "primary")
	start_button.visible = false
	start_button.pressed.connect(_on_start_button_pressed)

	# BottomNav
	bottom_nav.set_active_tab(0)
	bottom_nav.tab_pressed.connect(_on_bottom_nav_pressed)


func _make_banner(text: String, bg_color: Color) -> PanelContainer:
	var panel = PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)

	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(label)

	return panel


func _set_prompt(text: String, bg_color: Color = Color(1.0, 0.9, 0.4, 1)):
	"""스테이지 안내 배너 교체 — 이전 배너 즉시 제거 후 새 배너 페이드인 (겹침 방지)"""
	if _current_prompt and is_instance_valid(_current_prompt):
		_current_prompt.queue_free()
		_current_prompt = null

	var new_banner = _make_banner(text, bg_color)
	new_banner.modulate.a = 0.0
	log_container.add_child(new_banner)
	_current_prompt = new_banner

	var in_t = create_tween()
	in_t.tween_property(new_banner, "modulate:a", 1.0, 0.2)


# ─── Slots ───

func _create_empty_slots():
	for i in range(3):
		var slot = _make_dashed_slot()
		slot.position = SLOT_POSITIONS[i]
		slot_container.add_child(slot)
		slot_nodes.append(slot)


func _make_dashed_slot() -> Control:
	var slot = Control.new()
	slot.custom_minimum_size = Vector2(SLOT_W, SLOT_H)
	slot.size = Vector2(SLOT_W, SLOT_H)

	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.08, 0.28, 0.8)
	style.border_color = Color(0.5, 0.35, 0.7, 0.9)
	style.set_border_width_all(2)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	panel.add_theme_stylebox_override("panel", style)
	slot.add_child(panel)

	var label = Label.new()
	label.text = "선택될\n카드\n위치"
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.6, 0.4, 0.8, 0.7))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(label)

	return slot


func _make_card_face(card_data: Dictionary, w: int, h: int) -> Control:
	"""앞면 카드 공용 빌더 — 크기에 맞게 폰트 비례 조정"""
	var scale_f = float(w) / 115.0

	var card = Control.new()
	card.custom_minimum_size = Vector2(w, h)
	card.size = Vector2(w, h)
	card.pivot_offset = Vector2(w / 2.0, h / 2.0)
	card.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.2, 0.5, 1)
	style.border_color = Color(0.7, 0.5, 0.9, 1)
	style.set_border_width_all(maxi(2, int(3 * scale_f)))
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	panel.add_theme_stylebox_override("panel", style)
	card.add_child(panel)

	var front_vbox = VBoxContainer.new()
	front_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	front_vbox.add_theme_constant_override("separation", maxi(2, int(4 * scale_f)))
	front_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(front_vbox)

	var margin = MarginContainer.new()
	var mg = maxi(5, int(8 * scale_f))
	margin.add_theme_constant_override("margin_left", mg)
	margin.add_theme_constant_override("margin_right", mg)
	margin.add_theme_constant_override("margin_top", maxi(6, int(10 * scale_f)))
	margin.add_theme_constant_override("margin_bottom", maxi(6, int(10 * scale_f)))
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	front_vbox.add_child(margin)

	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", maxi(2, int(5 * scale_f)))
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(content)

	var name_label = Label.new()
	name_label.text = card_data.name
	name_label.add_theme_font_size_override("font_size", maxi(10, int(16 * scale_f)))
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.7))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(name_label)

	var emoji_lbl = Label.new()
	emoji_lbl.text = card_data.emoji
	emoji_lbl.add_theme_font_size_override("font_size", maxi(20, int(42 * scale_f)))
	emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(emoji_lbl)

	var sep1 = HSeparator.new()
	sep1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(sep1)

	var node_info = Label.new()
	node_info.text = "%d노드 · %d시간" % [card_data.node_count, card_data.hours]
	node_info.add_theme_font_size_override("font_size", maxi(8, int(12 * scale_f)))
	node_info.add_theme_color_override("font_color", Color(0.8, 0.8, 1))
	node_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(node_info)

	var icons_hbox = HBoxContainer.new()
	icons_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	icons_hbox.add_theme_constant_override("separation", maxi(2, int(4 * scale_f)))
	icons_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for node_data in card_data.nodes:
		var icon_label = Label.new()
		icon_label.text = node_data.icon
		icon_label.add_theme_font_size_override("font_size", maxi(10, int(16 * scale_f)))
		icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icons_hbox.add_child(icon_label)
	content.add_child(icons_hbox)

	var sep2 = HSeparator.new()
	sep2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(sep2)

	var difficulty = Label.new()
	difficulty.text = card_data.difficulty
	difficulty.add_theme_font_size_override("font_size", maxi(8, int(12 * scale_f)))
	difficulty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty.mouse_filter = Control.MOUSE_FILTER_IGNORE
	match card_data.difficulty:
		"쉬움": difficulty.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
		"보통": difficulty.add_theme_color_override("font_color", Color(1, 1, 0.5))
		"어려움": difficulty.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	content.add_child(difficulty)

	var rewards = Label.new()
	rewards.text = card_data.rewards
	rewards.add_theme_font_size_override("font_size", maxi(8, int(12 * scale_f)))
	rewards.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	rewards.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rewards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(rewards)

	return card


func _fill_slot(index: int, card_data: Dictionary):
	var old_slot = slot_nodes[index]
	var new_slot = _make_card_face(card_data, SLOT_W, SLOT_H)
	new_slot.position = old_slot.position
	slot_container.add_child(new_slot)
	old_slot.queue_free()
	slot_nodes[index] = new_slot


# ─── Stage Flow ───

func _start_stage(stage: Stage):
	current_stage = stage
	_set_prompt(STAGE_PROMPTS[stage])
	_fly_in_cards(CARD_DATA[stage])


func _fly_in_cards(cards_data: Array):
	is_animating = true
	var last_tween: Tween

	for i in range(3):
		var card = _create_back_card(cards_data[i], i)
		card.position = Vector2(CARD_POSITIONS[i].x, -260)
		card.modulate.a = 0.0
		card_container.add_child(card)
		card_nodes.append(card)

		var delay = i * 0.12
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(card, "position", CARD_POSITIONS[i], 0.5) \
			.set_delay(delay).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(card, "modulate:a", 1.0, 0.3).set_delay(delay)
		last_tween = tween

	await last_tween.finished
	is_animating = false


# ─── Card Creation (뒷면 + 앞면) ───

func _create_back_card(card_data: Dictionary, index: int) -> Control:
	var card = Control.new()
	card.custom_minimum_size = Vector2(CARD_W, CARD_H)
	card.size = Vector2(CARD_W, CARD_H)
	card.pivot_offset = Vector2(CARD_W / 2.0, CARD_H / 2.0)
	card.set_meta("card_data", card_data)
	card.set_meta("is_previewing", false)

	# ── 뒷면 ──
	var card_back = Panel.new()
	card_back.name = "CardBack"
	card_back.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_back.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var back_style = StyleBoxFlat.new()
	back_style.bg_color = Color(0.25, 0.15, 0.4, 1)
	back_style.border_color = Color(0.7, 0.5, 0.9, 1)
	back_style.set_border_width_all(3)
	back_style.corner_radius_top_left = 10
	back_style.corner_radius_top_right = 10
	back_style.corner_radius_bottom_left = 10
	back_style.corner_radius_bottom_right = 10
	card_back.add_theme_stylebox_override("panel", back_style)
	card.add_child(card_back)

	var back_vbox = VBoxContainer.new()
	back_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	back_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	back_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_back.add_child(back_vbox)

	var crystal = Label.new()
	crystal.text = "🔮"
	crystal.add_theme_font_size_override("font_size", 60)
	crystal.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crystal.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_vbox.add_child(crystal)

	var stars = Label.new()
	stars.text = "✨ ✨ ✨"
	stars.add_theme_font_size_override("font_size", 15)
	stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stars.add_theme_color_override("font_color", Color(0.9, 0.8, 0.6))
	stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	back_vbox.add_child(stars)

	# ── 앞면 (숨겨진 상태) ──
	var card_front = Panel.new()
	card_front.name = "CardFront"
	card_front.set_anchors_preset(Control.PRESET_FULL_RECT)
	card_front.visible = false
	card_front.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var front_style = StyleBoxFlat.new()
	front_style.bg_color = Color(0.3, 0.2, 0.5, 1)
	front_style.border_color = Color(0.7, 0.5, 0.9, 1)
	front_style.set_border_width_all(3)
	front_style.corner_radius_top_left = 10
	front_style.corner_radius_top_right = 10
	front_style.corner_radius_bottom_left = 10
	front_style.corner_radius_bottom_right = 10
	card_front.add_theme_stylebox_override("panel", front_style)

	var front_vbox = VBoxContainer.new()
	front_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	front_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	front_vbox.add_theme_constant_override("separation", 4)
	front_vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card_front.add_child(front_vbox)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 10)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	front_vbox.add_child(margin)

	var content = VBoxContainer.new()
	content.add_theme_constant_override("separation", 5)
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(content)

	_build_card_content(content, card_data, 1.0)

	card.add_child(card_front)

	# ── 투명 클릭 버튼 (마지막 자식 = 최상단) ──
	var button = Button.new()
	button.name = "ClickButton"
	button.flat = true
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.pressed.connect(_on_card_clicked.bind(card, index))
	card.add_child(button)

	return card


func _build_card_content(content: VBoxContainer, card_data: Dictionary, scale_f: float):
	"""카드 앞면 내용 빌더 (재사용)"""
	var name_label = Label.new()
	name_label.text = card_data.name
	name_label.add_theme_font_size_override("font_size", maxi(10, int(16 * scale_f)))
	name_label.add_theme_color_override("font_color", Color(1, 0.9, 0.7))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(name_label)

	var emoji_lbl = Label.new()
	emoji_lbl.text = card_data.emoji
	emoji_lbl.add_theme_font_size_override("font_size", maxi(20, int(42 * scale_f)))
	emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	emoji_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(emoji_lbl)

	var sep1 = HSeparator.new()
	sep1.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(sep1)

	var node_info = Label.new()
	node_info.text = "%d노드 · %d시간" % [card_data.node_count, card_data.hours]
	node_info.add_theme_font_size_override("font_size", maxi(8, int(12 * scale_f)))
	node_info.add_theme_color_override("font_color", Color(0.8, 0.8, 1))
	node_info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node_info.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(node_info)

	var icons_hbox = HBoxContainer.new()
	icons_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	icons_hbox.add_theme_constant_override("separation", maxi(2, int(4 * scale_f)))
	icons_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for node_data in card_data.nodes:
		var icon_label = Label.new()
		icon_label.text = node_data.icon
		icon_label.add_theme_font_size_override("font_size", maxi(10, int(16 * scale_f)))
		icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icons_hbox.add_child(icon_label)
	content.add_child(icons_hbox)

	var sep2 = HSeparator.new()
	sep2.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(sep2)

	var difficulty = Label.new()
	difficulty.text = card_data.difficulty
	difficulty.add_theme_font_size_override("font_size", maxi(8, int(12 * scale_f)))
	difficulty.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	difficulty.mouse_filter = Control.MOUSE_FILTER_IGNORE
	match card_data.difficulty:
		"쉬움": difficulty.add_theme_color_override("font_color", Color(0.5, 1, 0.5))
		"보통": difficulty.add_theme_color_override("font_color", Color(1, 1, 0.5))
		"어려움": difficulty.add_theme_color_override("font_color", Color(1, 0.5, 0.5))
	content.add_child(difficulty)

	var rewards = Label.new()
	rewards.text = card_data.rewards
	rewards.add_theme_font_size_override("font_size", maxi(8, int(12 * scale_f)))
	rewards.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	rewards.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rewards.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(rewards)


# ─── Card Interaction ───

func _on_card_clicked(card: Control, index: int):
	if is_animating:
		return
	if card.get_meta("is_previewing", false):
		_confirm_card(card, index)
	else:
		_preview_card(card, index)


func _preview_card(card: Control, index: int):
	# 다른 카드 미리보기 해제
	for c in card_nodes:
		if c != card and c.get_meta("is_previewing", false):
			_unpreview_card(c)

	if not card.has_meta("original_y"):
		card.set_meta("original_y", card.position.y)

	var tween = create_tween()
	tween.tween_property(card, "position:y", card.get_meta("original_y") + 20, 0.2) \
		.set_ease(Tween.EASE_OUT)
	_highlight_back_border(card, true)
	card.set_meta("is_previewing", true)


func _unpreview_card(card: Control):
	if not is_instance_valid(card):
		return
	var orig_y = card.get_meta("original_y", card.position.y)
	var tween = create_tween()
	tween.tween_property(card, "position:y", orig_y, 0.2)
	_highlight_back_border(card, false)
	card.set_meta("is_previewing", false)


func _highlight_back_border(card: Control, highlight: bool):
	var card_back = card.get_node_or_null("CardBack")
	if card_back == null:
		return
	var style = card_back.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	if highlight:
		style.border_color = Color(1.0, 0.85, 0.3, 1)
		style.set_border_width_all(4)
	else:
		style.border_color = Color(0.7, 0.5, 0.9, 1)
		style.set_border_width_all(3)
	card_back.add_theme_stylebox_override("panel", style)


func _confirm_card(card: Control, index: int):
	is_animating = true
	var card_data = card.get_meta("card_data")
	selected_cards.append(card_data)

	# 모든 카드 버튼 비활성화
	for c in card_nodes:
		var btn = c.get_node_or_null("ClickButton")
		if btn:
			btn.disabled = true

	# 1) 나머지 카드 페이드아웃
	for i in range(card_nodes.size()):
		if i != index:
			var fade = create_tween()
			fade.tween_property(card_nodes[i], "modulate:a", 0.0, 0.3)
	await get_tree().create_timer(0.4).timeout

	# 2) 선택 카드 뒤집기
	var card_back = card.get_node("CardBack")
	var card_front = card.get_node("CardFront")

	var flip = create_tween()
	flip.tween_property(card, "scale:x", 0.0, 0.15).set_ease(Tween.EASE_IN)
	flip.tween_callback(func():
		card_back.visible = false
		card_front.visible = true
	)
	flip.tween_property(card, "scale:x", 1.0, 0.15).set_ease(Tween.EASE_OUT)
	await flip.finished

	# 3) 확인 배너 (초록)
	_set_prompt(STAGE_CONFIRM_MSG[current_stage], Color(0.5, 1.0, 0.7, 1))
	await get_tree().create_timer(0.7).timeout

	# 4) 슬롯으로 날아가기
	var slot_index = int(current_stage)
	var slot = slot_nodes[slot_index]

	var card_global = card.global_position
	card_container.remove_child(card)
	self.add_child(card)
	card.global_position = card_global

	var slot_global = slot.global_position
	var target_scale = Vector2(float(SLOT_W) / float(CARD_W), float(SLOT_H) / float(CARD_H))
	var pos_adjust = card.pivot_offset * (Vector2.ONE - target_scale)

	var fly = create_tween()
	fly.set_parallel(true)
	fly.tween_property(card, "global_position", slot_global - pos_adjust, 0.5) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	fly.tween_property(card, "scale", target_scale, 0.5) \
		.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CUBIC)
	await fly.finished

	card.queue_free()
	_fill_slot(slot_index, card_data)

	# 나머지 카드 정리
	for c in card_nodes:
		if is_instance_valid(c):
			c.queue_free()
	card_nodes.clear()

	await get_tree().create_timer(0.3).timeout

	# 다음 스테이지 또는 완료
	if current_stage == Stage.END:
		_complete_selection()
	else:
		var next_stage: Stage
		match current_stage:
			Stage.START:   next_stage = Stage.JOURNEY
			Stage.JOURNEY: next_stage = Stage.END
			_:             next_stage = Stage.END
		_start_stage(next_stage)


# ─── Completion ───

func _complete_selection():
	"""
	3개 완료 시:
	1) 슬롯 카드들을 self에 reparent → TopArea 중앙으로 이동
	2) SelectedCardsArea 축소 + BottomArea 확장 (동시)
	3) 완료 배너 3개 순차 페이드인
	4) 시작 버튼 페이드인
	"""
	# 1) 슬롯 카드들 전역 위치 기록 후 self로 reparent
	var anim_cards: Array = []
	for i in range(3):
		var s = slot_nodes[i]
		if not is_instance_valid(s):
			continue
		var sg = s.global_position
		slot_container.remove_child(s)
		self.add_child(s)
		s.position = sg  # root가 (0,0)이므로 global == local
		anim_cards.append(s)

	# 2) 카드를 절대 y=50으로 이동 (TopArea 중앙) — 레이아웃/영역 변경 없음
	var tween = create_tween()
	tween.set_parallel(true)

	for acard in anim_cards:
		tween.tween_property(acard, "position:y", 50.0, 0.5) \
			.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

	await tween.finished

	# 3) 기존 배너 제거 후 완료 배너 3개 순차 페이드인
	_current_prompt = null
	for child in log_container.get_children():
		child.queue_free()
	await get_tree().process_frame

	for i in range(3):
		await get_tree().create_timer(0.25).timeout
		var banner = _make_banner(COMPLETION_BANNERS[i], Color(1.0, 0.9, 0.4, 1))
		banner.modulate.a = 0.0
		log_container.add_child(banner)
		var t = create_tween()
		t.tween_property(banner, "modulate:a", 1.0, 0.3)

	await get_tree().create_timer(0.5).timeout

	# 4) 시작 버튼 페이드인
	start_button.visible = true
	start_button.modulate.a = 0.0
	var btn_t = create_tween()
	btn_t.tween_property(start_button, "modulate:a", 1.0, 0.4)

	if GameManager.has_method("set_dream_cards"):
		GameManager.set_dream_cards(selected_cards)

	is_animating = false


# ─── Navigation ───

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://ui/screens/InRun_v4.tscn")


func _on_bottom_nav_pressed(tab_index: int):
	match tab_index:
		0: get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		_: pass
