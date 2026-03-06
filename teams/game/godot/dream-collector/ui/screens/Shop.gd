# Shop.gd (v2.0)
# 가챠 + IAP + 재화 교환 상점
# 탭 0: 🎲 뽑기 (가챠)
# 탭 1: 💎 보석 구매 (현금 결제)
# 탭 2: 🪙 재화 교환 (보석 → 골드/에너지)

extends Control

# ─── 상점 데이터 ─────────────────────────────────────
var gacha_banners: Array = []      # 뽑기 배너 목록
var gem_packages: Array = []       # 보석 구매 패키지
var currency_exchanges: Array = [] # 재화 교환 목록

var current_tab: int = 0  # 0=뽑기, 1=보석 구매, 2=재화 교환

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var top_bar: Panel = $TopBar
@onready var title_label: Label = $TopBar/HBox/TitleLabel

# 재화 카운터
@onready var energy_count_label: Label = $TopBar/HBox/EnergyCounter/CountLabel
@onready var gems_count_label: Label = $TopBar/HBox/GemsCounter/CountLabel
@onready var reveries_count_label: Label = $TopBar/HBox/RevariesCounter/CountLabel

# Tab buttons
@onready var gacha_tab_button: Button = $TabBar/GachaTabButton
@onready var gems_tab_button: Button = $TabBar/GemsTabButton
@onready var exchange_tab_button: Button = $TabBar/ExchangeTabButton

var tab_buttons: Array = []

# Content tabs
@onready var gacha_tab: ScrollContainer = $ContentContainer/GachaTab
@onready var gems_tab: ScrollContainer = $ContentContainer/GemsTab
@onready var exchange_tab: ScrollContainer = $ContentContainer/ExchangeTab

@onready var gacha_banners_container: VBoxContainer = $ContentContainer/GachaTab/MarginContainer/BannersContainer
@onready var gems_grid: GridContainer = $ContentContainer/GemsTab/CenterContainer/MarginContainer/GemsGrid
@onready var exchange_grid: VBoxContainer = $ContentContainer/ExchangeTab/CenterContainer/MarginContainer/ExchangeGrid

# BottomNav component
@onready var bottom_nav = $BottomNav

# AlertModal
@onready var alert_modal = $AlertModal

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_signals()
	load_shop_data()
	switch_tab(0)  # 뽑기 탭으로 시작
	update_currency_display()
	bottom_nav.set_active_tab(4)  # Shop 탭 활성화
	
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
	
	# Tab buttons
	tab_buttons = [gacha_tab_button, gems_tab_button, exchange_tab_button]
	for button in tab_buttons:
		UITheme.apply_button_style(button, "panel_light")

# ─── 시그널 연결 ─────────────────────────────────────
func setup_signals() -> void:
	# Tab buttons
	gacha_tab_button.pressed.connect(_on_tab_button_pressed.bind(0))
	gems_tab_button.pressed.connect(_on_tab_button_pressed.bind(1))
	exchange_tab_button.pressed.connect(_on_tab_button_pressed.bind(2))
	
	# BottomNav
	bottom_nav.tab_pressed.connect(_on_nav_tab_pressed)

# ─── 상점 데이터 로드 ────────────────────────────────
func load_shop_data() -> void:
	# 뽑기 배너 (가챠)
	gacha_banners = [
		{
			"id": "standard_gacha",
			"name": "일반 뽑기",
			"description": "기본 카드 풀",
			"type": "gold",  # gold 또는 gems
			"cost_single": 1000,  # 골드 1000
			"cost_ten": 9000,     # 10회 9000 (10% 할인)
			"banner_color": Color(0.3, 0.6, 0.9),  # 파랑
			"featured_cards": ["atk_001", "def_001", "skill_001"],
			"active": true
		},
		{
			"id": "premium_gacha",
			"name": "프리미엄 뽑기",
			"description": "레어 이상 확정!",
			"type": "gems",  # 보석 사용
			"cost_single": 100,  # 보석 100
			"cost_ten": 900,     # 10회 900
			"banner_color": Color(0.9, 0.6, 0.2),  # 오렌지
			"featured_cards": ["legendary_001", "epic_001"],
			"active": true
		},
		{
			"id": "event_gacha",
			"name": "이벤트 한정 뽑기",
			"description": "기간 한정 특별 카드!",
			"type": "gems",
			"cost_single": 150,
			"cost_ten": 1350,
			"banner_color": Color(0.9, 0.2, 0.5),  # 핑크
			"featured_cards": ["event_special_001"],
			"active": true
		},
		{
			"id": "beginner_gacha",
			"name": "초보자 뽑기",
			"description": "골드 할인! 처음 10회만",
			"type": "gold",
			"cost_single": 500,
			"cost_ten": 4000,
			"banner_color": Color(0.3, 0.9, 0.4),  # 초록
			"featured_cards": ["starter_001"],
			"active": true,
			"limit": 1  # 1회만 가능
		}
	]
	
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
	
	print("[Shop] 데이터 로드 완료: Gacha %d, Gems %d, Exchanges %d" % [gacha_banners.size(), gem_packages.size(), currency_exchanges.size()])

# ─── 탭 전환 ─────────────────────────────────────────
func switch_tab(tab_index: int) -> void:
	current_tab = tab_index
	
	# 모든 탭 숨기기
	gacha_tab.visible = false
	gems_tab.visible = false
	exchange_tab.visible = false
	
	# 선택된 탭 표시
	match tab_index:
		0:
			gacha_tab.visible = true
			update_gacha_display()
		1:
			gems_tab.visible = true
			update_gems_display()
		2:
			exchange_tab.visible = true
			update_exchange_display()
	
	# 탭 버튼 하이라이트
	for i in range(tab_buttons.size()):
		if i == tab_index:
			tab_buttons[i].modulate = UITheme.COLORS.primary
		else:
			tab_buttons[i].modulate = Color.WHITE

# ─── 뽑기 배너 디스플레이 업데이트 ───────────────────
func update_gacha_display() -> void:
	# 기존 제거
	for child in gacha_banners_container.get_children():
		child.queue_free()
	
	# 활성화된 뽑기 배너만 추가
	for banner in gacha_banners:
		if banner.get("active", true):
			var banner_item = create_gacha_banner_item(banner)
			gacha_banners_container.add_child(banner_item)

func create_gacha_banner_item(banner: Dictionary) -> Panel:
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(358, 180)
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = banner.banner_color
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = banner.banner_color.lightened(0.3)
	panel_style.corner_radius_top_left = UITheme.RADIUS.large
	panel_style.corner_radius_top_right = UITheme.RADIUS.large
	panel_style.corner_radius_bottom_left = UITheme.RADIUS.large
	panel_style.corner_radius_bottom_right = UITheme.RADIUS.large
	panel.add_theme_stylebox_override("panel", panel_style)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 16
	vbox.offset_top = 16
	vbox.offset_right = -16
	vbox.offset_bottom = -16
	panel.add_child(vbox)
	
	# 배너 이름
	var name_label = Label.new()
	name_label.text = banner.name
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	vbox.add_child(name_label)
	
	# 설명
	var desc_label = Label.new()
	desc_label.text = banner.description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.9))
	vbox.add_child(desc_label)
	
	# 빈 공간
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)
	
	# 버튼 영역
	var button_hbox = HBoxContainer.new()
	button_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	button_hbox.add_theme_constant_override("separation", 12)
	vbox.add_child(button_hbox)
	
	# 재화 아이콘 결정
	var currency_icon = "🪙" if banner.type == "gold" else "💎"
	
	# 1회 뽑기 버튼
	var single_button = Button.new()
	single_button.text = "%s %d\n1회 뽑기" % [currency_icon, banner.cost_single]
	single_button.custom_minimum_size = Vector2(150, 60)
	single_button.pressed.connect(_on_gacha_pull.bind(banner, 1))
	UITheme.apply_button_style(single_button, "success")
	button_hbox.add_child(single_button)
	
	# 10회 뽑기 버튼
	var ten_button = Button.new()
	ten_button.text = "%s %d\n10회 뽑기" % [currency_icon, banner.cost_ten]
	ten_button.custom_minimum_size = Vector2(150, 60)
	ten_button.pressed.connect(_on_gacha_pull.bind(banner, 10))
	UITheme.apply_button_style(ten_button, "primary")
	button_hbox.add_child(ten_button)
	
	# 한정 뽑기 표시
	if banner.has("limit"):
		var limit_label = Label.new()
		limit_label.text = "⚠️ 한정 %d회" % banner.limit
		limit_label.add_theme_font_size_override("font_size", 10)
		limit_label.add_theme_color_override("font_color", Color.YELLOW)
		limit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		vbox.add_child(limit_label)
		vbox.move_child(limit_label, 2)  # 설명 다음에 배치
	
	return panel

# ─── 뽑기 이벤트 핸들러 ──────────────────────────────
func _on_gacha_pull(banner: Dictionary, count: int) -> void:
	var total_cost = banner.cost_single if count == 1 else banner.cost_ten
	var currency_type = banner.type
	var currency_name = "골드" if currency_type == "gold" else "보석"
	
	print("[Shop] 뽑기 시도: %s x%d (비용: %s %d)" % [banner.name, count, currency_name, total_cost])
	
	# 재화 체크 및 소비
	var has_enough = false
	if currency_type == "gold":
		has_enough = GameManager.spend_reveries(total_cost)
	else:  # gems
		has_enough = GameManager.spend_gems(total_cost)
	
	if has_enough:
		# 성공: 뽑기 실행
		print("[Shop] 뽑기 성공! %d개 카드 획득" % count)
		# TODO: 실제 뽑기 로직 및 결과 화면
		alert_modal.show_info("뽑기 완료", "🎉 %d개의 카드를 획득했습니다!\n(결과 화면은 추후 구현)" % count)
	else:
		# 실패: 재화 부족
		var current_amount = GameManager.reveries if currency_type == "gold" else GameManager.gems
		alert_modal.show_insufficient_currency(currency_name, total_cost, int(current_amount))

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
func _on_tab_button_pressed(tab_index: int) -> void:
	switch_tab(tab_index)

func _on_nav_tab_pressed(tab_index: int) -> void:
	bottom_nav.set_active_tab(tab_index)
	
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1:  # Cards
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[Shop] Upgrade Tree로 이동")
			get_tree().change_scene_to_file("res://ui/screens/UpgradeTree.tscn")
		3:  # Character (Equipment)
			get_tree().change_scene_to_file("res://ui/screens/CharacterScreen.tscn")
		4:  # Shop (현재 화면)
			pass



# ─── AlertModal 버튼 핸들러 ──────────────────────────
func _on_alert_button1_pressed() -> void:
	print("[Shop] Alert 버튼 1 클릭")

func _on_alert_button2_pressed() -> void:
	print("[Shop] Alert 버튼 2 클릭")
