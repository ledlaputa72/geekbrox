# DeckBuilder.gd
# 덱 빌더 화면 - 12장 덱 편성
# CardItem 컴포넌트 재사용

extends Control

# ─── 덱 데이터 ───────────────────────────────────────
var current_deck: Array = []
const MAX_DECK_SIZE: int = 12

var all_cards: Array = []
var filtered_cards: Array = []
var current_filter: String = "all"

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var top_bar: Panel = $TopBar
@onready var back_button: Button = $TopBar/HBox/BackButton
@onready var save_button: Button = $TopBar/HBox/SaveButton
@onready var title_label: Label = $TopBar/HBox/TitleLabel

# Deck Section
@onready var deck_title: Label = $DeckSection/DeckHeader/DeckTitle
@onready var stats_label: Label = $DeckSection/DeckHeader/StatsLabel
@onready var deck_grid: GridContainer = $DeckSection/DeckScrollContainer/CenterContainer/MarginContainer/DeckGrid

# Library Section
@onready var library_title: Label = $LibrarySection/LibraryHeader/LibraryTitle
@onready var all_button: Button = $LibrarySection/FilterBar/AllButton
@onready var attack_button: Button = $LibrarySection/FilterBar/AttackButton
@onready var defense_button: Button = $LibrarySection/FilterBar/DefenseButton
@onready var skill_button: Button = $LibrarySection/FilterBar/SkillButton
@onready var power_button: Button = $LibrarySection/FilterBar/PowerButton
@onready var library_grid: GridContainer = $LibrarySection/LibraryScrollContainer/CenterContainer/MarginContainer/LibraryGrid

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
	load_saved_deck()
	apply_filter("all")
	update_deck_display()
	bottom_nav.set_active_tab(1)  # Cards 탭 활성화
	
	# GameManager 시그널 연결
	GameManager.deck_saved.connect(_on_deck_saved)
	
	print("[DeckBuilder] 덱 빌더 준비 완료 - 덱: %d/12장" % current_deck.size())

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	background.color = UITheme.COLORS.bg
	
	UISprites.apply_panel(top_bar, UISprites.panel_dark(), 18)
	title_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	deck_title.add_theme_color_override("font_color", UITheme.COLORS.text)
	stats_label.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	library_title.add_theme_color_override("font_color", UITheme.COLORS.text)
	UISprites.apply_btn(back_button, "secondary")
	UISprites.apply_btn(save_button, "green")
	filter_buttons = [all_button, attack_button, defense_button, skill_button, power_button]
	for btn in filter_buttons:
		UISprites.apply_btn(btn, "secondary")
		btn.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	
	# Divider
	var divider = $Divider
	var divider_style = StyleBoxFlat.new()
	divider_style.bg_color = UITheme.COLORS.panel_border
	divider.add_theme_stylebox_override("panel", divider_style)

# ─── 시그널 연결 ─────────────────────────────────────
func setup_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	save_button.pressed.connect(_on_save_pressed)
	
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
	# CardLibrary와 동일한 카드 데이터
	var card_types = ["attack", "skill", "power", "curse"]
	var rarities = ["common", "uncommon", "rare", "epic", "legendary"]
	
	for i in range(85):
		var card_type = card_types[i % 4]
		var rarity_index = min(i / 17, 4)
		var rarity = rarities[rarity_index]
		
		var card = {
			"id": i + 1,
			"name": _generate_card_name(card_type, i),
			"type": card_type,
			"cost": (i % 5) + 1,
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

# ─── 덱 로드/저장 ────────────────────────────────────
func load_saved_deck() -> void:
	# GameManager에서 저장된 덱 로드
	var saved_deck = GameManager.get_current_deck()
	
	if saved_deck.size() > 0:
		current_deck = saved_deck
		print("[DeckBuilder] 저장된 덱 로드: %d장" % current_deck.size())
	else:
		# 저장된 덱이 없으면 기본 덱 생성 (처음 5장)
		current_deck.clear()
		for i in range(5):
			current_deck.append(all_cards[i].duplicate())
		print("[DeckBuilder] 기본 덱 생성: %d장" % current_deck.size())

func save_deck() -> void:
	# GameManager를 통해 덱 저장
	GameManager.save_deck(current_deck)
	
	# 저장 완료 피드백
	save_button.text = "✅ Saved!"
	save_button.disabled = true
	
	# 2초 후 원래대로
	await get_tree().create_timer(2.0).timeout
	save_button.text = "💾 Save"
	update_deck_stats()  # Save 버튼 상태 업데이트
	
	print("[DeckBuilder] 덱 저장 완료: %d장" % current_deck.size())
	for card in current_deck:
		print("  - %s (ID: %d)" % [card.name, card.id])

# ─── 필터 적용 ───────────────────────────────────────
func apply_filter(filter_type: String) -> void:
	current_filter = filter_type
	
	if filter_type == "all":
		filtered_cards = all_cards.duplicate()
	else:
		filtered_cards.clear()
		for card in all_cards:
			if card.type == filter_type:
				filtered_cards.append(card)
	
	update_library_display()
	
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

# ─── 덱 디스플레이 업데이트 ──────────────────────────
func update_deck_display() -> void:
	# 기존 카드 제거
	for child in deck_grid.get_children():
		child.queue_free()
	
	# 현재 덱 카드 추가
	for card_data in current_deck:
		var card_item = CardItemScene.instantiate()
		deck_grid.add_child(card_item)
		card_item.set_card_data(card_data)
		card_item.card_clicked.connect(_on_deck_card_clicked)
	
	# 빈 슬롯 표시 (12장까지)
	for i in range(current_deck.size(), MAX_DECK_SIZE):
		var empty_slot = _create_empty_slot()
		deck_grid.add_child(empty_slot)
	
	update_deck_stats()

func _create_empty_slot() -> Panel:
	var slot = Panel.new()
	slot.custom_minimum_size = Vector2(UITheme.CARD.width, UITheme.CARD.height)
	
	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.COLORS.panel
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = UITheme.COLORS.panel_border
	style.set_border_width_all(2)
	style.draw_center = true
	style.corner_radius_top_left = UITheme.RADIUS.small
	style.corner_radius_top_right = UITheme.RADIUS.small
	style.corner_radius_bottom_left = UITheme.RADIUS.small
	style.corner_radius_bottom_right = UITheme.RADIUS.small
	slot.add_theme_stylebox_override("panel", style)
	
	# "+" 라벨 추가
	var label = Label.new()
	label.text = "+"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	slot.add_child(label)
	
	return slot

func update_deck_stats() -> void:
	# 덱 타이틀 업데이트
	deck_title.text = "Current Deck (%d/%d)" % [current_deck.size(), MAX_DECK_SIZE]
	
	# 평균 비용 계산
	if current_deck.size() > 0:
		var total_cost = 0
		for card in current_deck:
			total_cost += card.cost
		var avg_cost = float(total_cost) / current_deck.size()
		stats_label.text = "Avg Cost: %.1f" % avg_cost
	else:
		stats_label.text = "Avg Cost: 0.0"
	
	# Save 버튼 활성화 여부
	save_button.disabled = current_deck.size() != MAX_DECK_SIZE

# ─── 라이브러리 디스플레이 업데이트 ──────────────────
func update_library_display() -> void:
	# 기존 카드 제거
	for child in library_grid.get_children():
		child.queue_free()
	
	# 필터링된 카드 추가
	for card_data in filtered_cards:
		# 이미 덱에 있는 카드는 스킵 (중복 방지)
		var already_in_deck = false
		for deck_card in current_deck:
			if deck_card.id == card_data.id:
				already_in_deck = true
				break
		
		if already_in_deck:
			continue
		
		var card_item = CardItemScene.instantiate()
		library_grid.add_child(card_item)
		card_item.set_card_data(card_data)
		card_item.card_clicked.connect(_on_library_card_clicked)

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_back_pressed() -> void:
	print("[DeckBuilder] 뒤로 가기")
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")

func _on_save_pressed() -> void:
	if current_deck.size() != MAX_DECK_SIZE:
		print("[DeckBuilder] 덱을 12장으로 채워주세요 (%d/12)" % current_deck.size())
		return
	save_deck()

func _on_deck_saved(deck_size: int) -> void:
	print("[DeckBuilder] GameManager로부터 덱 저장 확인: %d장" % deck_size)

func _on_filter_pressed(filter_type: String) -> void:
	apply_filter(filter_type)

func _on_deck_card_clicked(card_data: Dictionary) -> void:
	# 덱에서 카드 제거
	for i in range(current_deck.size()):
		if current_deck[i].id == card_data.id:
			current_deck.remove_at(i)
			break
	
	print("[DeckBuilder] 카드 제거: %s" % card_data.name)
	update_deck_display()
	update_library_display()

func _on_library_card_clicked(card_data: Dictionary) -> void:
	# 덱이 꽉 찼는지 확인
	if current_deck.size() >= MAX_DECK_SIZE:
		print("[DeckBuilder] 덱이 가득 찼습니다! (%d/%d)" % [current_deck.size(), MAX_DECK_SIZE])
		return
	
	# 덱에 카드 추가
	current_deck.append(card_data.duplicate())
	print("[DeckBuilder] 카드 추가: %s (%d/%d)" % [card_data.name, current_deck.size(), MAX_DECK_SIZE])
	
	update_deck_display()
	update_library_display()

func _on_tab_pressed(tab_index: int) -> void:
	bottom_nav.set_active_tab(tab_index)
	
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1:  # Cards
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[DeckBuilder] Upgrade Tree로 이동")
			get_tree().change_scene_to_file("res://ui/screens/UpgradeTree.tscn")
		3:  # Character (Equipment)
			get_tree().change_scene_to_file("res://ui/screens/CharacterScreen.tscn")
		4:  # Shop
			print("[DeckBuilder] Shop으로 이동")
			get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")
