# Shop.gd (NEW)
# IAP + 재화 교환 상점
# 탭 1: 💎 보석 구매 (현금 결제)
# 탭 2: 🪙 재화 교환 (보석 → 골드/에너지)

extends Control

# ─── 상점 데이터 ─────────────────────────────────────
var gem_packages: Array = []      # 보석 구매 패키지
var currency_exchanges: Array = [] # 재화 교환 목록

var current_tab: int = 0  # 0=보석 구매, 1=재화 교환

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var top_bar: Panel = $TopBar
@onready var back_button: Button = $TopBar/HBox/BackButton
@onready var title_label: Label = $TopBar/HBox/TitleLabel

# 재화 카운터
@onready var energy_count_label: Label = $TopBar/HBox/EnergyCounter/CountLabel
@onready var gems_count_label: Label = $TopBar/HBox/GemsCounter/CountLabel
@onready var reveries_count_label: Label = $TopBar/HBox/RevariesCounter/CountLabel

# Tab buttons
@onready var gems_tab_button: Button = $TabBar/GemsTabButton
@onready var exchange_tab_button: Button = $TabBar/ExchangeTabButton

var tab_buttons: Array = []

# Content tabs
@onready var gems_tab: ScrollContainer = $ContentContainer/GemsTab
@onready var exchange_tab: ScrollContainer = $ContentContainer/ExchangeTab

@onready var gems_grid: GridContainer = $ContentContainer/GemsTab/CenterContainer/MarginContainer/GemsGrid
@onready var exchange_grid: VBoxContainer = $ContentContainer/ExchangeTab/CenterContainer/MarginContainer/ExchangeGrid

# BottomNav
@onready var home_tab: Button = $BottomNav/HomeTab
@onready var cards_nav_tab: Button = $BottomNav/CardsTab
@onready var upgrade_nav_tab: Button = $BottomNav/UpgradeTab
@onready var progress_nav_tab: Button = $BottomNav/ProgressTab
@onready var shop_nav_tab: Button = $BottomNav/ShopTab

var nav_buttons: Array = []

# AlertModal
@onready var alert_modal = $AlertModal

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_signals()
	load_shop_data()
	switch_tab(0)  # 보석 구매 탭으로 시작
	update_currency_display()
	set_active_nav_tab(4)  # Shop 탭 활성화
	
	# GameManager 시그널 연결
	GameManager.energy_changed.connect(_on_energy_changed)
	GameManager.gems_changed.connect(_on_gems_changed)
	GameManager.reveries_changed.connect(_on_reveries_changed)
	
	# AlertModal 시그널 연결
	alert_modal.button1_pressed.connect(_on_alert_button1_pressed)
	alert_modal.button2_pressed.connect(_on_alert_button2_pressed)
	
	print("[Shop] IAP Shop 준비 완료")

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
	gems_count_label.add_theme_color_override("font_color", UITheme.COLORS.primary)
	reveries_count_label.add_theme_color_override("font_color", UITheme.COLORS.warning)
	
	# Buttons
	UITheme.apply_button_style(back_button, "primary")
	
	# Tab buttons
	tab_buttons = [gems_tab_button, exchange_tab_button]
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
	gems_tab_button.pressed.connect(_on_tab_button_pressed.bind(0))
	exchange_tab_button.pressed.connect(_on_tab_button_pressed.bind(1))
	
	# Nav buttons
	home_tab.pressed.connect(_on_nav_tab_pressed.bind(0))
	cards_nav_tab.pressed.connect(_on_nav_tab_pressed.bind(1))
	upgrade_nav_tab.pressed.connect(_on_nav_tab_pressed.bind(2))
	progress_nav_tab.pressed.connect(_on_nav_tab_pressed.bind(3))
	shop_nav_tab.pressed.connect(_on_nav_tab_pressed.bind(4))

# ─── 상점 데이터 로드 ────────────────────────────────
func load_shop_data() -> void:
	# 보석 구매 패키지 (IAP)
	gem_packages = [
		{"id": "gems_100", "name": "스타터 팩", "gems": 100, "price": "$0.99", "bonus": 0},
		{"id": "gems_550", "name": "베스트 딜", "gems": 500, "price": "$4.99", "bonus": 50},
		{"id": "gems_1200", "name": "메가 팩", "gems": 1000, "price": "$9.99", "bonus": 200},
		{"id": "gems_2600", "name": "슈퍼 팩", "gems": 2000, "price": "$19.99", "bonus": 600},
		{"id": "gems_5500", "name": "울트라 팩", "gems": 5000, "price": "$49.99", "bonus": 500},
		{"id": "gems_12000", "name": "메가 번들", "gems": 10000, "price": "$99.99", "bonus": 2000},
	]
	
	# 재화 교환 (보석 → 게임 재화)
	currency_exchanges = [
		{"id": "gold_1k", "name": "골드 1,000", "from": "gems", "from_amount": 10, "to": "gold", "to_amount": 1000, "icon": "🪙"},
		{"id": "gold_5k", "name": "골드 5,000", "from": "gems", "from_amount": 45, "to": "gold", "to_amount": 5000, "icon": "🪙"},
		{"id": "gold_10k", "name": "골드 10,000", "from": "gems", "from_amount": 80, "to": "gold", "to_amount": 10000, "icon": "🪙"},
		{"id": "energy_50", "name": "에너지 50", "from": "gems", "from_amount": 5, "to": "energy", "to_amount": 50, "icon": "⚡"},
		{"id": "energy_100", "name": "에너지 100", "from": "gems", "from_amount": 9, "to": "energy", "to_amount": 100, "icon": "⚡"},
		{"id": "energy_250", "name": "에너지 250", "from": "gems", "from_amount": 20, "to": "energy", "to_amount": 250, "icon": "⚡"},
	]
	
	print("[Shop] 데이터 로드 완료: Gems %d, Exchanges %d" % [gem_packages.size(), currency_exchanges.size()])

# ─── 탭 전환 ─────────────────────────────────────────
func switch_tab(tab_index: int) -> void:
	current_tab = tab_index
	
	# 모든 탭 숨기기
	gems_tab.visible = false
	exchange_tab.visible = false
	
	# 선택된 탭 표시
	match tab_index:
		0:
			gems_tab.visible = true
			update_gems_display()
		1:
			exchange_tab.visible = true
			update_exchange_display()
	
	# 탭 버튼 하이라이트
	for i in range(tab_buttons.size()):
		if i == tab_index:
			tab_buttons[i].modulate = UITheme.COLORS.primary
		else:
			tab_buttons[i].modulate = Color.WHITE

# ─── 보석 패키지 디스플레이 업데이트 ──────────────────
func update_gems_display() -> void:
	# 기존 제거
	for child in gems_grid.get_children():
		child.queue_free()
	
	# 보석 패키지 추가
	for package in gem_packages:
		var item = create_gem_package_item(package)
		gems_grid.add_child(item)

func create_gem_package_item(package: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(110, 160)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = UITheme.COLORS.panel
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = UITheme.COLORS.primary
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
	
	# 패키지 이름
	var name_label = Label.new()
	name_label.text = package.name
	name_label.add_theme_font_size_override("font_size", 12)
	name_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(name_label)
	
	# 보석 아이콘 + 수량
	var gems_container = VBoxContainer.new()
	gems_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(gems_container)
	
	var gem_icon = Label.new()
	gem_icon.text = "💎"
	gem_icon.add_theme_font_size_override("font_size", 32)
	gem_icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gems_container.add_child(gem_icon)
	
	var gem_amount = Label.new()
	gem_amount.text = str(package.gems + package.bonus)
	gem_amount.add_theme_font_size_override("font_size", 18)
	gem_amount.add_theme_color_override("font_color", UITheme.COLORS.primary)
	gem_amount.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	gems_container.add_child(gem_amount)
	
	# 보너스 표시
	if package.bonus > 0:
		var bonus_label = Label.new()
		bonus_label.text = "+%d 보너스" % package.bonus
		bonus_label.add_theme_font_size_override("font_size", 8)
		bonus_label.add_theme_color_override("font_color", UITheme.COLORS.success)
		bonus_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		vbox.add_child(bonus_label)
	
	# 구매 버튼
	var buy_button = Button.new()
	buy_button.text = package.price
	buy_button.pressed.connect(_on_buy_gems_pressed.bind(package))
	UITheme.apply_button_style(buy_button, "success")
	vbox.add_child(buy_button)
	
	return panel

# ─── 재화 교환 디스플레이 업데이트 ───────────────────
func update_exchange_display() -> void:
	# 기존 제거
	for child in exchange_grid.get_children():
		child.queue_free()
	
	# 재화 교환 아이템 추가
	for exchange in currency_exchanges:
		var item = create_exchange_item(exchange)
		exchange_grid.add_child(item)

func create_exchange_item(exchange: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(358, 70)
	
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
	
	# 아이콘 + 이름
	var left_box = HBoxContainer.new()
	left_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(left_box)
	
	var icon_label = Label.new()
	icon_label.text = exchange.icon
	icon_label.add_theme_font_size_override("font_size", 32)
	left_box.add_child(icon_label)
	
	var name_label = Label.new()
	name_label.text = exchange.name
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	left_box.add_child(name_label)
	
	# 교환 비율 표시
	var exchange_label = Label.new()
	exchange_label.text = "💎 %d" % exchange.from_amount
	exchange_label.add_theme_font_size_override("font_size", 14)
	exchange_label.add_theme_color_override("font_color", UITheme.COLORS.primary)
	exchange_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	hbox.add_child(exchange_label)
	
	# 구매 버튼
	var buy_button = Button.new()
	buy_button.text = "교환"
	buy_button.custom_minimum_size = Vector2(80, 0)
	buy_button.pressed.connect(_on_exchange_pressed.bind(exchange))
	UITheme.apply_button_style(buy_button, "success")
	hbox.add_child(buy_button)
	
	return panel

# ─── 구매 이벤트 핸들러 ──────────────────────────────
func _on_buy_gems_pressed(package: Dictionary) -> void:
	print("[Shop] 보석 구매 시도: %s (%s)" % [package.name, package.price])
	
	# TODO: 실제 IAP 연동
	# 현재는 개발용으로 치트로 바로 지급
	var total_gems = package.gems + package.bonus
	GameManager.add_gems(total_gems)
	alert_modal.show_info("구매 완료", "💎 %d 보석을 받았습니다!\n(개발 버전: 무료 지급)" % total_gems)
	
	# 실제 구현 시:
	# IAP.purchase(package.id)
	# IAP.purchase_completed.connect(_on_iap_completed)

func _on_exchange_pressed(exchange: Dictionary) -> void:
	print("[Shop] 재화 교환 시도: %s" % exchange.name)
	print("[Shop] 현재 Gems: %d" % GameManager.gems)
	
	if GameManager.spend_gems(exchange.from_amount):
		# 성공: 재화 지급
		match exchange.to:
			"gold":
				GameManager.add_reveries(exchange.to_amount)
				alert_modal.show_info("교환 완료", "%s %s를 받았습니다!" % [exchange.icon, exchange.name])
			"energy":
				GameManager.add_energy(exchange.to_amount)
				alert_modal.show_info("교환 완료", "%s %s를 받았습니다!" % [exchange.icon, exchange.name])
		print("[Shop] 교환 성공!")
	else:
		# 실패: 보석 부족
		print("[Shop] Gems 부족!")
		alert_modal.show_insufficient_currency("보석", exchange.from_amount, GameManager.gems)

# ─── 재화 업데이트 ───────────────────────────────────
func update_currency_display() -> void:
	energy_count_label.text = str(GameManager.energy)
	gems_count_label.text = str(GameManager.gems)
	reveries_count_label.text = str(int(GameManager.reveries))

func _on_energy_changed(new_amount: int) -> void:
	update_currency_display()

func _on_gems_changed(new_amount: int) -> void:
	update_currency_display()

func _on_reveries_changed(new_amount: float) -> void:
	update_currency_display()

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
	print("[Shop] Alert 버튼 1 클릭")

func _on_alert_button2_pressed() -> void:
	print("[Shop] Alert 버튼 2 클릭")
