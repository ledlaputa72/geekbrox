# RunPrep.gd
# 런 준비 화면 - 덱 확인 및 난이도 선택
# 런 시작 전 마지막 확인 단계

extends Control

# ─── 난이도 데이터 ─────────────────────────────────
const DIFFICULTY_DATA = {
	"easy": {
		"name": "쉬움",
		"name_en": "Easy",
		"monster_hp_mult": 0.7,
		"monster_damage_mult": 0.7,
		"reward_mult": 0.8,
		"color": Color(0.3, 0.9, 0.4),  # 초록
		"description": "초보자에게 추천"
	},
	"normal": {
		"name": "보통",
		"name_en": "Normal",
		"monster_hp_mult": 1.0,
		"monster_damage_mult": 1.0,
		"reward_mult": 1.0,
		"color": Color(0.3, 0.6, 0.9),  # 파랑
		"description": "균형잡힌 도전"
	},
	"hard": {
		"name": "어려움",
		"name_en": "Hard",
		"monster_hp_mult": 1.3,
		"monster_damage_mult": 1.3,
		"reward_mult": 1.5,
		"color": Color(0.9, 0.3, 0.3),  # 빨강
		"description": "숙련자용 고난이도"
	}
}

var current_difficulty: String = "normal"
var current_deck: Array = []
var is_deck_valid: bool = false

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var top_bar: Panel = $TopBar
@onready var back_button: Button = $TopBar/HBox/BackButton
@onready var title_label: Label = $TopBar/HBox/TitleLabel

# 덱 표시
@onready var deck_scroll: ScrollContainer = $DeckSection/DeckScroll
@onready var deck_grid: GridContainer = $DeckSection/DeckScroll/MarginContainer/DeckGrid
@onready var deck_status_label: Label = $DeckSection/DeckStatusLabel

# 난이도 선택
@onready var easy_button: Button = $DifficultySection/DifficultyButtons/EasyButton
@onready var normal_button: Button = $DifficultySection/DifficultyButtons/NormalButton
@onready var hard_button: Button = $DifficultySection/DifficultyButtons/HardButton
@onready var difficulty_desc_label: Label = $DifficultySection/DifficultyDescLabel

# 시작 버튼
@onready var start_button: Button = $StartButton
@onready var validation_label: Label = $ValidationLabel

# BottomNav
@onready var home_tab: Button = $BottomNav/HomeTab
@onready var cards_tab: Button = $BottomNav/CardsTab
@onready var upgrade_tab: Button = $BottomNav/UpgradeTab
@onready var progress_tab: Button = $BottomNav/ProgressTab
@onready var shop_tab: Button = $BottomNav/ShopTab

var nav_buttons: Array = []

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_signals()
	load_deck()
	set_difficulty("normal")
	validate_deck()
	set_active_nav_tab(0)  # Home 활성화 (런 준비는 Home에서 진입)
	
	print("[RunPrep] 런 준비 화면 로드 완료")

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	background.color = UITheme.COLORS.bg
	
	# TopBar
	var top_bar_style = StyleBoxFlat.new()
	top_bar_style.bg_color = UITheme.COLORS.panel
	top_bar_style.border_width_bottom = UITheme.BORDER.thin
	top_bar_style.border_color = UITheme.COLORS.bg
	top_bar.add_theme_stylebox_override("panel", top_bar_style)
	
	# Labels
	title_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	deck_status_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	difficulty_desc_label.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	validation_label.add_theme_color_override("font_color", UITheme.COLORS.danger)
	
	# Buttons
	UITheme.apply_button_style(back_button, "primary")
	UITheme.apply_button_style(easy_button, "success")
	UITheme.apply_button_style(normal_button, "info")
	UITheme.apply_button_style(hard_button, "danger")
	UITheme.apply_button_style(start_button, "primary")
	
	# Nav buttons
	nav_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	for button in nav_buttons:
		_apply_nav_button_style(button)

func _apply_nav_button_style(button: Button) -> void:
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UITheme.COLORS.panel
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.COLORS.panel_light
	button.add_theme_stylebox_override("hover", hover_style)
	
	button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)

# ─── 시그널 연결 ─────────────────────────────────────
func setup_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	easy_button.pressed.connect(_on_difficulty_pressed.bind("easy"))
	normal_button.pressed.connect(_on_difficulty_pressed.bind("normal"))
	hard_button.pressed.connect(_on_difficulty_pressed.bind("hard"))
	start_button.pressed.connect(_on_start_pressed)
	
	# Nav buttons
	home_tab.pressed.connect(_on_nav_tab_pressed.bind(0))
	cards_tab.pressed.connect(_on_nav_tab_pressed.bind(1))
	upgrade_tab.pressed.connect(_on_nav_tab_pressed.bind(2))
	progress_tab.pressed.connect(_on_nav_tab_pressed.bind(3))
	shop_tab.pressed.connect(_on_nav_tab_pressed.bind(4))

# ─── 덱 로드 및 표시 ─────────────────────────────────
func load_deck() -> void:
	current_deck = GameManager.get_current_deck()
	update_deck_display()

func update_deck_display() -> void:
	# 기존 카드 제거
	for child in deck_grid.get_children():
		child.queue_free()
	
	# 현재 덱 카드 표시
	for card_data in current_deck:
		var card_item = create_deck_card_item(card_data)
		deck_grid.add_child(card_item)
	
	# 빈 슬롯 표시 (12장까지)
	var empty_slots = 12 - current_deck.size()
	for i in range(empty_slots):
		var empty_card = create_empty_card_slot()
		deck_grid.add_child(empty_card)
	
	# 덱 상태 업데이트
	update_deck_status()

func create_deck_card_item(card_data: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(80, 112)  # 작은 카드 사이즈
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = get_card_type_color(card_data.get("type", "attack"))
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(1, 1, 1, 0.3)
	panel_style.corner_radius_top_left = UITheme.RADIUS.small
	panel_style.corner_radius_top_right = UITheme.RADIUS.small
	panel_style.corner_radius_bottom_left = UITheme.RADIUS.small
	panel_style.corner_radius_bottom_right = UITheme.RADIUS.small
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 4
	vbox.offset_top = 4
	vbox.offset_right = -4
	vbox.offset_bottom = -4
	panel.add_child(vbox)
	
	# 카드 이름
	var name_label = Label.new()
	name_label.text = card_data.get("name", "Unknown")
	name_label.add_theme_font_size_override("font_size", 10)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# 코스트
	var cost_label = Label.new()
	cost_label.text = "💎 " + str(card_data.get("cost", 0))
	cost_label.add_theme_font_size_override("font_size", 12)
	cost_label.add_theme_color_override("font_color", Color.WHITE)
	cost_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(cost_label)
	
	return panel

func create_empty_card_slot() -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(80, 112)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.2, 0.2, 0.2, 0.5)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Color(0.5, 0.5, 0.5, 0.3)
	panel_style.corner_radius_top_left = UITheme.RADIUS.small
	panel_style.corner_radius_top_right = UITheme.RADIUS.small
	panel_style.corner_radius_bottom_left = UITheme.RADIUS.small
	panel_style.corner_radius_bottom_right = UITheme.RADIUS.small
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var label = Label.new()
	label.text = "빈 슬롯"
	label.add_theme_font_size_override("font_size", 10)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 0.5))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_child(label)
	
	return panel

func get_card_type_color(type: String) -> Color:
	match type:
		"attack":
			return UITheme.COLORS.attack
		"defense":
			return UITheme.COLORS.defense
		"skill":
			return UITheme.COLORS.skill
		"power":
			return UITheme.COLORS.power
		_:
			return UITheme.COLORS.panel

func update_deck_status() -> void:
	var deck_size = current_deck.size()
	var avg_cost = calculate_average_cost()
	
	deck_status_label.text = "덱: %d/12장 | 평균 코스트: %.1f" % [deck_size, avg_cost]

func calculate_average_cost() -> float:
	if current_deck.size() == 0:
		return 0.0
	
	var total_cost = 0
	for card in current_deck:
		total_cost += card.get("cost", 0)
	
	return float(total_cost) / float(current_deck.size())

# ─── 난이도 선택 ─────────────────────────────────────
func set_difficulty(difficulty: String) -> void:
	current_difficulty = difficulty
	
	# 버튼 하이라이트
	easy_button.modulate = Color(1, 1, 1, 0.5) if difficulty != "easy" else Color.WHITE
	normal_button.modulate = Color(1, 1, 1, 0.5) if difficulty != "normal" else Color.WHITE
	hard_button.modulate = Color(1, 1, 1, 0.5) if difficulty != "hard" else Color.WHITE
	
	# 설명 업데이트
	var diff_data = DIFFICULTY_DATA[difficulty]
	difficulty_desc_label.text = "%s: %s\n몬스터 HP/데미지 ×%.1f | 보상 ×%.1f" % [
		diff_data.name,
		diff_data.description,
		diff_data.monster_hp_mult,
		diff_data.reward_mult
	]
	
	print("[RunPrep] 난이도 변경: %s" % difficulty)

func _on_difficulty_pressed(difficulty: String) -> void:
	set_difficulty(difficulty)

# ─── 덱 유효성 검증 ──────────────────────────────────
func validate_deck() -> void:
	var deck_size = current_deck.size()
	
	if deck_size < 10:
		is_deck_valid = false
		validation_label.text = "⚠️ 덱에 최소 10장의 카드가 필요합니다 (현재: %d장)" % deck_size
		validation_label.visible = true
		start_button.disabled = true
	elif deck_size > 12:
		is_deck_valid = false
		validation_label.text = "⚠️ 덱은 최대 12장까지 가능합니다 (현재: %d장)" % deck_size
		validation_label.visible = true
		start_button.disabled = true
	else:
		is_deck_valid = true
		validation_label.visible = false
		start_button.disabled = false

# ─── 런 시작 ─────────────────────────────────────────
func _on_start_pressed() -> void:
	if not is_deck_valid:
		print("[RunPrep] 덱이 유효하지 않음")
		return
	
	# 난이도 설정을 GameManager에 저장
	GameManager.current_difficulty = current_difficulty
	GameManager.difficulty_data = DIFFICULTY_DATA[current_difficulty]
	
	print("[RunPrep] 런 시작! 난이도: %s, 덱: %d장" % [current_difficulty, current_deck.size()])
	
	# 런 화면으로 이동 (c07-in-run)
	get_tree().change_scene_to_file("res://ui/screens/InRun.tscn")
	
	# 임시: 메시지 표시
	print("[RunPrep] TODO: InRun 화면으로 전환 (미구현)")
	
	# 임시: MainLobby로 복귀
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_back_pressed() -> void:
	print("[RunPrep] 뒤로 가기")
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")

func _on_nav_tab_pressed(tab_index: int) -> void:
	set_active_nav_tab(tab_index)
	
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1:  # Cards
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[RunPrep] Upgrade Tree로 이동 (미구현)")
		3:  # Progress
			print("[RunPrep] Progress (미구현)")
		4:  # Shop
			get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")

func set_active_nav_tab(tab_index: int) -> void:
	for i in range(nav_buttons.size()):
		var button = nav_buttons[i]
		if i == tab_index:
			button.add_theme_color_override("font_color", UITheme.COLORS.text)
		else:
			button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
