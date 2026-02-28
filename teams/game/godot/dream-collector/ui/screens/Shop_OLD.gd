# Shop.gd
# 상점 화면 - 3개 탭 (Cards, Upgrades, Cosmetics)
# CardItem 컴포넌트 재사용

extends Control

# ─── 상점 데이터 ─────────────────────────────────────
var shop_cards: Array = []
var shop_upgrades: Array = []
var shop_cosmetics: Array = []

var current_tab: int = 0  # 0=Cards, 1=Upgrades, 2=Cosmetics

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var top_bar: Panel = $TopBar
@onready var back_button: Button = $TopBar/HBox/BackButton
@onready var title_label: Label = $TopBar/HBox/TitleLabel
@onready var revaries_count_label: Label = $TopBar/HBox/RevariesCounter/CountLabel
@onready var alert_modal = $AlertModal

# Tab buttons
@onready var cards_tab_button: Button = $TabBar/CardsTabButton
@onready var upgrades_tab_button: Button = $TabBar/UpgradesTabButton
@onready var cosmetics_tab_button: Button = $TabBar/CosmeticsTabButton

var tab_buttons: Array = []

# Content tabs
@onready var cards_tab: ScrollContainer = $ContentContainer/CardsTab
@onready var upgrades_tab: ScrollContainer = $ContentContainer/UpgradesTab
@onready var cosmetics_tab: ScrollContainer = $ContentContainer/CosmeticsTab

@onready var cards_grid: GridContainer = $ContentContainer/CardsTab/CenterContainer/MarginContainer/CardsGrid
@onready var upgrades_grid: VBoxContainer = $ContentContainer/UpgradesTab/VBox/MarginContainer/UpgradesGrid
@onready var cosmetics_grid: GridContainer = $ContentContainer/CosmeticsTab/CenterContainer/MarginContainer/CosmeticsGrid

# BottomNav tabs
@onready var home_tab: Button = $BottomNav/HomeTab
@onready var cards_nav_tab: Button = $BottomNav/CardsTab
@onready var upgrade_nav_tab: Button = $BottomNav/UpgradeTab
@onready var progress_nav_tab: Button = $BottomNav/ProgressTab
@onready var shop_nav_tab: Button = $BottomNav/ShopTab

var nav_buttons: Array = []

# ─── CardItem 씬 로드 ─────────────────────────────────
const CardItemScene = preload("res://ui/components/CardItem.tscn")

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_signals()
	load_shop_data()
	switch_tab(0)  # Cards 탭으로 시작
	update_revaries_display()
	set_active_nav_tab(4)  # Shop 탭 활성화
	
	# GameManager 시그널 연결
	GameManager.reveries_changed.connect(_on_reveries_changed)
	
	# AlertModal 시그널 연결
	alert_modal.button1_pressed.connect(_on_alert_button1_pressed)
	alert_modal.button2_pressed.connect(_on_alert_button2_pressed)
	
	print("[Shop] 상점 준비 완료")

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	background.color = UITheme.COLORS.bg
	
	# TopBar 스타일
	var top_bar_style = StyleBoxFlat.new()
	top_bar_style.bg_color = UITheme.COLORS.panel
	top_bar_style.border_width_bottom = UITheme.BORDER.thin
	top_bar_style.border_color = UITheme.COLORS.bg
	top_bar.add_theme_stylebox_override("panel", top_bar_style)
	
	# Title & Counter
	title_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	revaries_count_label.add_theme_color_override("font_color", UITheme.COLORS.warning)
	
	# Buttons
	UITheme.apply_button_style(back_button, "primary")
	
	# Tab buttons
	tab_buttons = [cards_tab_button, upgrades_tab_button, cosmetics_tab_button]
	for button in tab_buttons:
		UITheme.apply_button_style(button, "panel_light")
	
	# Nav buttons
	nav_buttons = [home_tab, cards_nav_tab, upgrade_nav_tab, progress_nav_tab, shop_nav_tab]
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
	
	# Tab buttons
	cards_tab_button.pressed.connect(_on_tab_button_pressed.bind(0))
	upgrades_tab_button.pressed.connect(_on_tab_button_pressed.bind(1))
	cosmetics_tab_button.pressed.connect(_on_tab_button_pressed.bind(2))
	
	# Nav buttons
	home_tab.pressed.connect(_on_nav_tab_pressed.bind(0))
	cards_nav_tab.pressed.connect(_on_nav_tab_pressed.bind(1))
	upgrade_nav_tab.pressed.connect(_on_nav_tab_pressed.bind(2))
	progress_nav_tab.pressed.connect(_on_nav_tab_pressed.bind(3))
	shop_nav_tab.pressed.connect(_on_nav_tab_pressed.bind(4))

# ─── 상점 데이터 로드 ────────────────────────────────
func load_shop_data() -> void:
	# TODO: 실제 게임 데이터에서 로드
	
	# 카드 상품 (20장)
	var card_types = ["attack", "defense", "skill", "power"]
	var rarities = ["common", "uncommon", "rare", "epic", "legendary"]
	
	for i in range(20):
		var card_type = card_types[i % 4]
		var rarity_index = min(i / 4, 4)
		var rarity = rarities[rarity_index]
		var base_price = [50, 100, 200, 500, 1000][rarity_index]
		
		var card = {
			"id": i + 1,
			"name": "Shop Card %d" % (i + 1),
			"type": card_type,
			"cost": (i % 5) + 1,
			"description": "Deal %d damage." % ((i % 10) + 5),
			"rarity": rarity,
			"price": base_price
		}
		shop_cards.append(card)
	
	# 업그레이드 상품 (10개)
	var upgrade_types = [
		{"name": "Idle Rate +10%", "desc": "수집 속도 10% 증가", "price": 500},
		{"name": "Max HP +5", "desc": "최대 체력 5 증가", "price": 300},
		{"name": "Starting Energy +1", "desc": "시작 에너지 1 증가", "price": 800},
		{"name": "Card Draw +1", "desc": "시작 카드 드로우 1 증가", "price": 600},
		{"name": "Gold Bonus +20%", "desc": "골드 획득 20% 증가", "price": 400},
		{"name": "XP Bonus +15%", "desc": "경험치 획득 15% 증가", "price": 350},
		{"name": "Crit Chance +5%", "desc": "치명타 확률 5% 증가", "price": 700},
		{"name": "Damage +2", "desc": "모든 공격 피해 2 증가", "price": 900},
		{"name": "Block +3", "desc": "모든 방어 효과 3 증가", "price": 750},
		{"name": "Lucky Drop", "desc": "희귀 아이템 드롭률 증가", "price": 1200},
	]
	
	for i in range(upgrade_types.size()):
		var upgrade = upgrade_types[i].duplicate()
		upgrade["id"] = i + 1
		upgrade["type"] = "upgrade"
		shop_upgrades.append(upgrade)
	
	# 코스메틱 상품 (6개)
	var cosmetic_types = [
		{"name": "Blue Theme", "desc": "파란색 UI 테마", "price": 200},
		{"name": "Red Theme", "desc": "빨간색 UI 테마", "price": 200},
		{"name": "Green Theme", "desc": "초록색 UI 테마", "price": 200},
		{"name": "Card Back #1", "desc": "별 무늬 카드 뒷면", "price": 150},
		{"name": "Card Back #2", "desc": "달 무늬 카드 뒷면", "price": 150},
		{"name": "Avatar Frame", "desc": "금테 아바타 프레임", "price": 500},
	]
	
	for i in range(cosmetic_types.size()):
		var cosmetic = cosmetic_types[i].duplicate()
		cosmetic["id"] = i + 1
		cosmetic["type"] = "cosmetic"
		shop_cosmetics.append(cosmetic)
	
	print("[Shop] 상품 로드 완료: Cards %d, Upgrades %d, Cosmetics %d" % [
		shop_cards.size(), shop_upgrades.size(), shop_cosmetics.size()
	])

# ─── 탭 전환 ─────────────────────────────────────────
func switch_tab(tab_index: int) -> void:
	current_tab = tab_index
	
	# 모든 탭 숨기기
	cards_tab.visible = false
	upgrades_tab.visible = false
	cosmetics_tab.visible = false
	
	# 선택된 탭 표시
	match tab_index:
		0:
			cards_tab.visible = true
			update_cards_display()
		1:
			upgrades_tab.visible = true
			update_upgrades_display()
		2:
			cosmetics_tab.visible = true
			update_cosmetics_display()
	
	# 탭 버튼 하이라이트
	for i in range(tab_buttons.size()):
		if i == tab_index:
			tab_buttons[i].modulate = UITheme.COLORS.primary
		else:
			tab_buttons[i].modulate = Color.WHITE

# ─── 카드 탭 디스플레이 업데이트 ─────────────────────
func update_cards_display() -> void:
	# 기존 제거
	for child in cards_grid.get_children():
		child.queue_free()
	
	# 카드 상품 추가
	for card_data in shop_cards:
		var shop_item = create_shop_card_item(card_data)
		cards_grid.add_child(shop_item)

func create_shop_card_item(item_data: Dictionary) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(UITheme.CARD.width, UITheme.CARD.height + 30)
	
	# CardItem
	var card_item = CardItemScene.instantiate()
	card_item.position = Vector2.ZERO
	container.add_child(card_item)
	card_item.set_card_data(item_data)
	
	# 가격 & 구매 버튼 오버레이
	var buy_panel = Panel.new()
	buy_panel.position = Vector2(0, UITheme.CARD.height)
	buy_panel.custom_minimum_size = Vector2(UITheme.CARD.width, 30)
	
	var buy_panel_style = StyleBoxFlat.new()
	buy_panel_style.bg_color = UITheme.COLORS.panel
	buy_panel.add_theme_stylebox_override("panel", buy_panel_style)
	container.add_child(buy_panel)
	
	var buy_button = Button.new()
	buy_button.text = "💎 %d" % item_data.price
	buy_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	buy_button.pressed.connect(_on_buy_card_pressed.bind(item_data))
	UITheme.apply_button_style(buy_button, "success")
	buy_panel.add_child(buy_button)
	
	return container

# ─── 업그레이드 탭 디스플레이 업데이트 ───────────────
func update_upgrades_display() -> void:
	# 기존 제거
	for child in upgrades_grid.get_children():
		child.queue_free()
	
	# 업그레이드 상품 추가
	for upgrade_data in shop_upgrades:
		var upgrade_item = create_upgrade_item(upgrade_data)
		upgrades_grid.add_child(upgrade_item)

func create_upgrade_item(item_data: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(358, 60)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = UITheme.COLORS.panel
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = UITheme.COLORS.panel_border
	panel_style.corner_radius_top_left = UITheme.RADIUS.medium
	panel_style.corner_radius_top_right = UITheme.RADIUS.medium
	panel_style.corner_radius_bottom_left = UITheme.RADIUS.medium
	panel_style.corner_radius_bottom_right = UITheme.RADIUS.medium
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	hbox.offset_left = 12
	hbox.offset_right = -12
	panel.add_child(hbox)
	
	# 정보
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = item_data.name
	name_label.add_theme_font_size_override("font_size", 14)
	name_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	vbox.add_child(name_label)
	
	var desc_label = Label.new()
	desc_label.text = item_data.desc
	desc_label.add_theme_font_size_override("font_size", 10)
	desc_label.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	vbox.add_child(desc_label)
	
	# 구매 버튼
	var buy_button = Button.new()
	buy_button.text = "💎 %d" % item_data.price
	buy_button.custom_minimum_size = Vector2(100, 0)
	buy_button.pressed.connect(_on_buy_upgrade_pressed.bind(item_data))
	UITheme.apply_button_style(buy_button, "success")
	hbox.add_child(buy_button)
	
	return panel

# ─── 코스메틱 탭 디스플레이 업데이트 ─────────────────
func update_cosmetics_display() -> void:
	# 기존 제거
	for child in cosmetics_grid.get_children():
		child.queue_free()
	
	# 코스메틱 상품 추가
	for cosmetic_data in shop_cosmetics:
		var cosmetic_item = create_cosmetic_item(cosmetic_data)
		cosmetics_grid.add_child(cosmetic_item)

func create_cosmetic_item(item_data: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(UITheme.CARD.width, 120)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = UITheme.COLORS.panel
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = UITheme.COLORS.panel_border
	panel_style.corner_radius_top_left = UITheme.RADIUS.medium
	panel_style.corner_radius_top_right = UITheme.RADIUS.medium
	panel_style.corner_radius_bottom_left = UITheme.RADIUS.medium
	panel_style.corner_radius_bottom_right = UITheme.RADIUS.medium
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 8
	vbox.offset_top = 8
	vbox.offset_right = -8
	vbox.offset_bottom = -8
	panel.add_child(vbox)
	
	# 아이콘 플레이스홀더
	var icon_rect = ColorRect.new()
	icon_rect.custom_minimum_size = Vector2(90, 50)
	icon_rect.color = UITheme.COLORS.bg
	vbox.add_child(icon_rect)
	
	# 이름
	var name_label = Label.new()
	name_label.text = item_data.name
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# 구매 버튼
	var buy_button = Button.new()
	buy_button.text = "💎 %d" % item_data.price
	buy_button.pressed.connect(_on_buy_cosmetic_pressed.bind(item_data))
	UITheme.apply_button_style(buy_button, "success")
	vbox.add_child(buy_button)
	
	return panel

# ─── 구매 이벤트 핸들러 ──────────────────────────────
func _on_buy_card_pressed(item_data: Dictionary) -> void:
	print("[Shop] 카드 구매 시도: %s (💎 %d)" % [item_data.name, item_data.price])
	print("[Shop] 현재 Reveries: %.0f" % GameManager.reveries)
	
	if GameManager.spend_reveries(item_data.price):
		print("[Shop] 카드 구매 성공!")
		alert_modal.show_info("구매 완료", "✅ %s\n성공적으로 구매했습니다!" % item_data.name)
		# TODO: 인벤토리에 카드 추가
	else:
		print("[Shop] Reveries 부족!")
		alert_modal.show_insufficient_currency("Reveries", item_data.price, int(GameManager.reveries))

func _on_buy_upgrade_pressed(item_data: Dictionary) -> void:
	print("[Shop] 업그레이드 구매 시도: %s (💎 %d)" % [item_data.name, item_data.price])
	print("[Shop] 현재 Reveries: %.0f" % GameManager.reveries)
	
	if GameManager.spend_reveries(item_data.price):
		print("[Shop] 업그레이드 구매 성공!")
		alert_modal.show_info("구매 완료", "✅ %s\n성공적으로 구매했습니다!" % item_data.name)
		# TODO: 업그레이드 적용
	else:
		print("[Shop] Reveries 부족!")
		alert_modal.show_insufficient_currency("Reveries", item_data.price, int(GameManager.reveries))

func _on_buy_cosmetic_pressed(item_data: Dictionary) -> void:
	print("[Shop] 코스메틱 구매 시도: %s (💎 %d)" % [item_data.name, item_data.price])
	print("[Shop] 현재 Reveries: %.0f" % GameManager.reveries)
	
	if GameManager.spend_reveries(item_data.price):
		print("[Shop] 코스메틱 구매 성공!")
		alert_modal.show_info("구매 완료", "✅ %s\n성공적으로 구매했습니다!" % item_data.name)
		# TODO: 코스메틱 잠금 해제
	else:
		print("[Shop] Reveries 부족!")
		alert_modal.show_insufficient_currency("Reveries", item_data.price, int(GameManager.reveries))

# ─── Reveries 업데이트 ───────────────────────────────
func update_revaries_display() -> void:
	revaries_count_label.text = str(int(GameManager.reveries))

func _on_reveries_changed(new_amount: float) -> void:
	update_revaries_display()

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_back_pressed() -> void:
	print("[Shop] 뒤로 가기")
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")

func _on_tab_button_pressed(tab_index: int) -> void:
	switch_tab(tab_index)

func _on_nav_tab_pressed(tab_index: int) -> void:
	set_active_nav_tab(tab_index)
	
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1:  # Cards
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[Shop] Upgrade Tree로 이동 (미구현)")
		3:  # Progress
			print("[Shop] Progress (미구현)")
		4:  # Shop (현재 화면)
			pass

func set_active_nav_tab(tab_index: int) -> void:
	for i in range(nav_buttons.size()):
		var button = nav_buttons[i]
		if i == tab_index:
			button.add_theme_color_override("font_color", UITheme.COLORS.text)
		else:
			button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)

# ─── AlertModal 버튼 핸들러 ──────────────────────────
func _on_alert_button1_pressed() -> void:
	# "💰 재충전" 버튼 클릭 시
	print("[Shop] 재충전 화면으로 이동 (미구현)")
	# TODO: 재충전 화면 구현 후 이동
	# get_tree().change_scene_to_file("res://ui/screens/RechargeScreen.tscn")

func _on_alert_button2_pressed() -> void:
	# "닫기" 버튼 클릭 시
	print("[Shop] 모달 닫기")
