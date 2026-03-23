# CardLibrary.gd
# 카드 라이브러리 화면
# 85장의 카드를 표시하고 필터링하는 화면

extends Control

# ─── 카드 데이터 ─────────────────────────────────────
var all_cards: Array = []
var filtered_cards: Array = []
var current_filter: String = "all"  # all, attack, skill, power, curse
var player_deck: Dictionary = {}  # card_id(int) → { "data": Dictionary, "count": int, "upgrade": int }

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
const CardDetailPopupScene := preload("res://ui/components/CardDetailPopup.tscn")

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
	UISprites.apply_panel(top_bar, UISprites.panel_dark(), 8)
	title_label.add_theme_color_override("font_color", UITheme.COLORS.text)

	# Deck 버튼
	UISprites.apply_btn(deck_button, "secondary")

	# 필터 버튼: 타입별 색상 (비활성 시 secondary, 활성 시 타입 색상)
	filter_buttons = [all_button, attack_button, defense_button, skill_button, power_button]
	UISprites.apply_btn(all_button,      "secondary") # All: 회색 (중립)
	UISprites.apply_btn(attack_button,   "red")       # Attack: 빨강
	UISprites.apply_btn(defense_button,  "green")     # Skill: 초록
	UISprites.apply_btn(skill_button,    "primary")   # Power: 파랑
	UISprites.apply_btn(power_button,    "yellow")    # Curse: 노란색

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
	
	# BottomNav
	bottom_nav.tab_pressed.connect(_on_tab_pressed)

# ─── 카드 데이터 로드 ────────────────────────────────
func load_card_data() -> void:
	# 임시 카드 데이터 생성 (85장)
	# TODO: 실제 게임 데이터에서 로드
	
	var card_types: Array[String] = ["attack", "skill", "power", "curse"]
	var rarities: Array[String] = ["common", "uncommon", "rare", "epic", "legendary"]

	for i in range(85):
		var card_type: String = card_types[i % 4]
		var rarity_index: int = mini(int(i / 17.0), 4)  # float 나눗셈으로 경고 방지
		var rarity: String = rarities[rarity_index]
		
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
	var base_value: int = (index % 10) + 5
	match type:
		"attack":
			return "Deal %d damage." % base_value
		"skill":
			return "Gain %d block." % base_value
		"power":
			return "Draw %d cards." % mini(int(base_value / 5.0), 3)
		"curse":
			return "Apply %d poison." % mini(int(base_value / 5.0), 2)
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
	
	# ── 필터 버튼 토글: 활성 = 타입 색상 밝게, 비활성 = 살짝 어둡게 ──
	# 각 버튼은 타입 고유 색상을 유지하면서 비활성 시 투명도로 구분
	var active_btn: Button = null
	match filter_type:
		"all":     active_btn = all_button
		"attack":  active_btn = attack_button
		"skill":   active_btn = defense_button
		"power":   active_btn = skill_button
		"curse":   active_btn = power_button
	for button in filter_buttons:
		if button == active_btn:
			button.modulate = Color(1.0, 1.0, 1.0, 1.0)   # 활성: 선명
		else:
			button.modulate = Color(0.65, 0.65, 0.65, 1.0)  # 비활성: 어둡게
	
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
	var card_id: int = card_data.get("id", -1)
	var in_deck: bool = player_deck.has(card_id)
	var count: int = player_deck[card_id].get("count", 0) if in_deck else 0

	var popup := CardDetailPopupScene.instantiate() as Control
	# 씬 트리 루트에 추가 → CardLibrary 레이아웃 영향 없이 전체화면 오버레이
	get_tree().root.add_child(popup)
	popup.show_card(card_data, in_deck, count)
	popup.deck_add_requested.connect(_on_popup_deck_add)
	popup.deck_remove_requested.connect(_on_popup_deck_remove)
	popup.enhance_requested.connect(_on_popup_enhance)

func _on_popup_deck_add(card_data: Dictionary) -> void:
	var card_id: int = card_data.get("id", -1)
	if player_deck.has(card_id):
		player_deck[card_id]["count"] += 1
	else:
		player_deck[card_id] = { "data": card_data.duplicate(), "count": 1, "upgrade": 0 }
	print("[CardLibrary] 덱추가: %s (덱 %d장)" % [card_data.get("name","?"), _deck_total()])

func _on_popup_deck_remove(card_data: Dictionary) -> void:
	var card_id: int = card_data.get("id", -1)
	if not player_deck.has(card_id):
		return
	player_deck[card_id]["count"] -= 1
	if player_deck[card_id]["count"] <= 0:
		player_deck.erase(card_id)
	print("[CardLibrary] 덱제거: %s (덱 %d장)" % [card_data.get("name","?"), _deck_total()])

func _on_popup_enhance(card_data: Dictionary) -> void:
	var card_id: int = card_data.get("id", -1)
	if not player_deck.has(card_id) or player_deck[card_id]["count"] < 2:
		return
	# 카드 1장 소모 + 강화 레벨 +1
	player_deck[card_id]["count"] -= 1
	player_deck[card_id]["upgrade"] += 1
	var up: int = player_deck[card_id]["upgrade"]
	print("[CardLibrary] 강화: %s → +%d" % [card_data.get("name","?"), up])

func _deck_total() -> int:
	var total: int = 0
	for v: Dictionary in player_deck.values():
		total += v.get("count", 0)
	return total

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


