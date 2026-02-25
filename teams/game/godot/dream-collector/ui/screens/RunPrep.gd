# RunPrep.gd
# 런 준비 화면 - 덱 확인 및 난이도 선택
# 새로운 레이아웃: 상단 난이도+시작, 하단 덱 표시

extends Control

# ─── 난이도 데이터 ─────────────────────────────────
const DIFFICULTY_DATA = {
	"easy": {
		"name": "쉬움",
		"name_en": "Easy",
		"monster_hp_mult": 0.7,
		"monster_damage_mult": 0.7,
		"reward_mult": 0.8,
		"color": Color(0.3, 0.9, 0.4),
		"description": "몬스터 HP/대미지 ×0.7 | 보상 ×0.8"
	},
	"normal": {
		"name": "보통",
		"name_en": "Normal",
		"monster_hp_mult": 1.0,
		"monster_damage_mult": 1.0,
		"reward_mult": 1.0,
		"color": Color(0.3, 0.6, 0.9),
		"description": "균형잡힌 도전\n몬스터 HP/대미지 ×1.0 | 보상 ×1.0"
	},
	"hard": {
		"name": "어려움",
		"name_en": "Hard",
		"monster_hp_mult": 1.3,
		"monster_damage_mult": 1.3,
		"reward_mult": 1.5,
		"color": Color(0.9, 0.3, 0.3),
		"description": "몬스터 HP/대미지 ×1.3 | 보상 ×1.5"
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

# 상단: 난이도 + 시작
@onready var difficulty_label: Label = $TopSection/DifficultyLabel
@onready var easy_button: Button = $TopSection/DifficultyButtons/EasyButton
@onready var normal_button: Button = $TopSection/DifficultyButtons/NormalButton
@onready var hard_button: Button = $TopSection/DifficultyButtons/HardButton
@onready var difficulty_desc_label: Label = $TopSection/DifficultyDescLabel
@onready var start_button: Button = $TopSection/StartButton

# 하단: 덱 표시
@onready var deck_info_label: Label = $BottomSection/DeckInfoBar/DeckInfoLabel
@onready var edit_deck_button: Button = $BottomSection/DeckInfoBar/EditDeckButton
@onready var deck_scroll: ScrollContainer = $BottomSection/DeckScroll
@onready var deck_grid: GridContainer = $BottomSection/DeckScroll/DeckGrid

# BottomNav
@onready var home_tab: Button = $BottomNav/HomeTab
@onready var cards_tab: Button = $BottomNav/CardsTab
@onready var upgrade_tab: Button = $BottomNav/UpgradeTab
@onready var progress_tab: Button = $BottomNav/ProgressTab
@onready var shop_tab: Button = $BottomNav/ShopTab

var nav_buttons: Array = []
var difficulty_buttons: Array = []

# CardItem Scene
const CardItemScene = preload("res://ui/components/CardItem.tscn")

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_signals()
	load_deck()
	set_difficulty("normal")
	validate_deck()
	set_active_nav_tab(0)
	
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
	difficulty_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	difficulty_desc_label.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	deck_info_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	
	# Buttons
	UITheme.apply_button_style(back_button, "primary")
	UITheme.apply_button_style(start_button, "success")
	UITheme.apply_button_style(edit_deck_button, "info")
	
	# Difficulty buttons
	difficulty_buttons = [easy_button, normal_button, hard_button]
	for button in difficulty_buttons:
		UITheme.apply_button_style(button, "panel_light")
	
	# Nav buttons
	nav_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	for button in nav_buttons:
		_apply_tab_button_style(button)

func _apply_tab_button_style(button: Button) -> void:
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
	start_button.pressed.connect(_on_start_pressed)
	edit_deck_button.pressed.connect(_on_edit_deck_pressed)
	
	easy_button.pressed.connect(_on_difficulty_pressed.bind("easy"))
	normal_button.pressed.connect(_on_difficulty_pressed.bind("normal"))
	hard_button.pressed.connect(_on_difficulty_pressed.bind("hard"))
	
	home_tab.pressed.connect(_on_nav_tab_pressed.bind(0))
	cards_tab.pressed.connect(_on_nav_tab_pressed.bind(1))
	upgrade_tab.pressed.connect(_on_nav_tab_pressed.bind(2))
	progress_tab.pressed.connect(_on_nav_tab_pressed.bind(3))
	shop_tab.pressed.connect(_on_nav_tab_pressed.bind(4))

# ─── 덱 로드 ─────────────────────────────────────────
func load_deck() -> void:
	# GameManager에서 현재 덱 가져오기
	if GameManager.has_method("get_current_deck"):
		current_deck = GameManager.get_current_deck()
	else:
		# 임시 테스트 덱
		current_deck = _generate_test_deck()
	
	update_deck_display()
	print("[RunPrep] 덱 로드: %d장" % current_deck.size())

func _generate_test_deck() -> Array:
	var deck = []
	var card_types = ["Attack", "Defense", "Skill", "Power"]
	
	for i in range(12):
		var card_type = card_types[i % 4]
		var card = {
			"id": i + 1,
			"name": "%s %d" % [card_type, i + 1],
			"type": card_type,
			"cost": (i % 5) + 1,
			"description": _get_description(card_type, (i % 5) + 5),
			"rarity": "common"
		}
		deck.append(card)
	
	return deck

func _get_description(type: String, value: int) -> String:
	match type:
		"Attack":
			return "Deal %d damage." % value
		"Defense":
			return "Gain %d block." % value
		"Skill":
			return "Draw %d cards." % min(value / 5, 3)
		"Power":
			return "+%d strength." % min(value / 5, 2)
	return "Effect."

# ─── 덱 표시 업데이트 ────────────────────────────────
func update_deck_display() -> void:
	# 기존 카드 제거
	for child in deck_grid.get_children():
		child.queue_free()
	
	# 카드 생성
	for card_data in current_deck:
		var card_item = CardItemScene.instantiate()
		deck_grid.add_child(card_item)
		card_item.set_card_data(card_data)
	
	# 덱 정보 업데이트
	update_deck_info()

func update_deck_info() -> void:
	var deck_size = current_deck.size()
	var avg_cost = _calculate_average_cost()
	deck_info_label.text = "덱: %d/12장 | 평균 코스트: %.1f" % [deck_size, avg_cost]

func _calculate_average_cost() -> float:
	if current_deck.is_empty():
		return 0.0
	
	var total_cost = 0
	for card in current_deck:
		total_cost += card.get("cost", 0)
	
	return float(total_cost) / float(current_deck.size())

# ─── 난이도 설정 ─────────────────────────────────────
func set_difficulty(difficulty: String) -> void:
	current_difficulty = difficulty
	
	var data = DIFFICULTY_DATA[difficulty]
	
	# 설명 업데이트
	difficulty_desc_label.text = "%s: %s\n%s" % [
		data["name"],
		data["name_en"],
		data["description"]
	]
	
	# 버튼 하이라이트
	for button in difficulty_buttons:
		button.modulate = Color(0.7, 0.7, 0.7)
	
	match difficulty:
		"easy":
			easy_button.modulate = data["color"]
		"normal":
			normal_button.modulate = data["color"]
		"hard":
			hard_button.modulate = data["color"]
	
	print("[RunPrep] 난이도 선택: %s" % difficulty)

# ─── 덱 유효성 검증 ──────────────────────────────────
func validate_deck() -> void:
	var deck_size = current_deck.size()
	
	if deck_size < 10:
		is_deck_valid = false
		start_button.disabled = true
		start_button.text = "⚠️ 덱이 부족합니다 (%d/10)" % deck_size
	elif deck_size > 12:
		is_deck_valid = false
		start_button.disabled = true
		start_button.text = "⚠️ 덱이 너무 많습니다 (%d/12)" % deck_size
	else:
		is_deck_valid = true
		start_button.disabled = false
		start_button.text = "🎮 런 시작!"
	
	print("[RunPrep] 덱 검증: %s (%d장)" % ["유효" if is_deck_valid else "무효", deck_size])

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_back_pressed() -> void:
	print("[RunPrep] 뒤로 가기")
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")

func _on_start_pressed() -> void:
	if not is_deck_valid:
		print("[RunPrep] 덱이 유효하지 않음 - 시작 불가")
		return
	
	# 난이도 데이터 GameManager에 저장
	if GameManager.has_method("set_difficulty"):
		GameManager.set_difficulty(current_difficulty, DIFFICULTY_DATA[current_difficulty])
	
	print("[RunPrep] 런 시작! 난이도: %s" % current_difficulty)
	
	# InRun 화면으로 이동
	get_tree().change_scene_to_file("res://ui/screens/InRun.tscn")

func _on_edit_deck_pressed() -> void:
	print("[RunPrep] 덱 편집으로 이동")
	get_tree().change_scene_to_file("res://ui/screens/DeckBuilder.tscn")

func _on_difficulty_pressed(difficulty: String) -> void:
	set_difficulty(difficulty)

func _on_nav_tab_pressed(tab_index: int) -> void:
	set_active_nav_tab(tab_index)
	
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1:  # Cards
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[RunPrep] Upgrade Tree (미구현)")
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
