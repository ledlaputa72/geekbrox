# CardLibrary.gd
# 카드 라이브러리 화면
# 85장의 카드를 표시하고 필터링하는 화면

extends Control

# ─── 카드 데이터 ─────────────────────────────────────
var all_cards: Array = []
var filtered_cards: Array = []
var current_filter: String = "all"  # all, attack, skill, power, curse

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var top_bar: Panel = $TopBar
@onready var title_label: Label = $TopBar/HBox/TitleLabel
@onready var deck_button: Button = $TopBar/HBox/DeckButton

# Filter buttons
@onready var all_button: Button = $FilterBar/AllButton
@onready var attack_button: Button = $FilterBar/AttackButton
@onready var defense_button: Button = $FilterBar/DefenseButton
@onready var skill_button: Button = $FilterBar/SkillButton
@onready var power_button: Button = $FilterBar/PowerButton

@onready var card_grid: GridContainer = $ScrollContainer/CenterContainer/MarginContainer/CardGrid

# BottomNav component
@onready var bottom_nav = $BottomNav

var filter_buttons: Array[Button] = []

# ─── CardItem 씬 로드 ─────────────────────────────────
const CardItemScene = preload("res://ui/components/CardItem.tscn")

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_signals()
	load_card_data()
	apply_filter("all")
	bottom_nav.set_active_tab(1)  # Cards 탭 활성화
	
	print("[CardLibrary] 카드 라이브러리 준비 완료 - %d장 로드됨" % all_cards.size())

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	background.color = UITheme.COLORS.bg
	
	UISprites.apply_panel(top_bar, UISprites.panel_dark(), 18)
	title_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	UISprites.apply_btn(deck_button, "secondary")
	filter_buttons = [all_button, attack_button, defense_button, skill_button, power_button]
	for btn in filter_buttons:
		UISprites.apply_btn(btn, "secondary")

# ─── 시그널 연결 ─────────────────────────────────────
func setup_signals() -> void:
	# Top bar buttons
	deck_button.pressed.connect(_on_deck_pressed)
	
	# Filter buttons (DefenseButton→skill, SkillButton→power, PowerButton→curse)
	all_button.pressed.connect(_on_filter_pressed.bind("all"))
	attack_button.pressed.connect(_on_filter_pressed.bind("attack"))
	defense_button.pressed.connect(_on_filter_pressed.bind("skill"))
	skill_button.pressed.connect(_on_filter_pressed.bind("power"))
	power_button.pressed.connect(_on_filter_pressed.bind("curse"))
	# 버튼 텍스트 업데이트 (tscn 라벨 오버라이드)
	defense_button.text = "Skill"
	skill_button.text = "Power"
	power_button.text = "Curse"
	
	# BottomNav
	bottom_nav.tab_pressed.connect(_on_tab_pressed)

# ─── 카드 데이터 로드 ────────────────────────────────
func load_card_data() -> void:
	# 임시 카드 데이터 생성 (85장)
	# TODO: 실제 게임 데이터에서 로드
	
	var card_types = ["attack", "skill", "power", "curse"]
	var rarities = ["common", "uncommon", "rare", "epic", "legendary"]
	
	for i in range(85):
		var card_type = card_types[i % 4]
		var rarity_index = min(i / 17, 4)  # 17장씩 5개 희귀도
		var rarity = rarities[rarity_index]
		
		var card = {
			"id": i + 1,
			"name": _generate_card_name(card_type, i),
			"type": card_type,
			"cost": (i % 5) + 1,  # 1-5 cost
			"description": _generate_description(card_type, i),
			"rarity": rarity
		}
		all_cards.append(card)

func _generate_card_name(type: String, index: int) -> String:
	match type:
		"attack":
			return "Strike %d" % (index + 1)
		"skill":
			return "Guard %d" % (index + 1)
		"power":
			return "Power %d" % (index + 1)
		"curse":
			return "Curse %d" % (index + 1)
	return "Card %d" % (index + 1)

func _generate_description(type: String, index: int) -> String:
	var base_value = (index % 10) + 5
	match type:
		"attack":
			return "Deal %d damage." % base_value
		"skill":
			return "Gain %d block." % base_value
		"power":
			return "Draw %d cards." % min(base_value / 5, 3)
		"curse":
			return "Apply %d poison." % min(base_value / 5, 2)
	return "Effect."

# ─── 필터 적용 ───────────────────────────────────────
func apply_filter(filter_type: String) -> void:
	current_filter = filter_type
	
	# 필터링
	if filter_type == "all":
		filtered_cards = all_cards.duplicate()
	else:
		filtered_cards.clear()
		for card in all_cards:
			if card.type == filter_type:
				filtered_cards.append(card)
	
	# 그리드 업데이트
	update_card_grid()
	
	# 필터 버튼 하이라이트
	for button in filter_buttons:
		button.modulate = Color.WHITE
	
	match filter_type:
		"all":
			all_button.modulate = UITheme.COLORS.primary
		"attack":
			attack_button.modulate = UITheme.COLORS.attack
		"skill":
			defense_button.modulate = UITheme.COLORS.skill
		"power":
			skill_button.modulate = UITheme.COLORS.power
		"curse":
			power_button.modulate = UITheme.COLORS.curse
	
	print("[CardLibrary] 필터 적용: %s - %d장 표시" % [filter_type, filtered_cards.size()])

# ─── 카드 그리드 업데이트 ────────────────────────────
func update_card_grid() -> void:
	# 기존 카드 제거
	for child in card_grid.get_children():
		child.queue_free()
	
	# 새 카드 생성
	for card_data in filtered_cards:
		var card_item = CardItemScene.instantiate()
		card_grid.add_child(card_item)
		card_item.set_card_data(card_data)
		card_item.card_clicked.connect(_on_card_clicked)

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_deck_pressed() -> void:
	print("[CardLibrary] Deck Builder로 이동")
	get_tree().change_scene_to_file("res://ui/screens/DeckBuilder.tscn")

func _on_filter_pressed(filter_type: String) -> void:
	apply_filter(filter_type)

func _on_card_clicked(card_data: Dictionary) -> void:
	print("[CardLibrary] 카드 상세 보기: %s" % card_data.name)
	# TODO: 카드 상세 모달 열기

func _on_tab_pressed(tab_index: int) -> void:
	bottom_nav.set_active_tab(tab_index)
	
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1:  # Cards (현재 화면)
			pass
		2:  # Upgrade
			print("[CardLibrary] Upgrade Tree로 이동")
			get_tree().change_scene_to_file("res://ui/screens/UpgradeTree.tscn")
		3:  # Character (Equipment)
			get_tree().change_scene_to_file("res://ui/screens/CharacterScreen.tscn")
		4:  # Shop
			print("[CardLibrary] Shop으로 이동")
			get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")


