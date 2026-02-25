# MainLobbyUI.gd
# 메인 로비 UI - 원형 뷰포트 + 스크롤 배경 + 걷는 캐릭터
# Dream Collector - Main Lobby with animated viewport

extends Control

# ─── 애니메이션 설정 ─────────────────────────────────
const BACKGROUND_SCROLL_SPEED = 30.0  # 배경 스크롤 속도 (px/s)
const CHARACTER_WALK_SPEED = 0.5      # 캐릭터 애니메이션 속도

var background_offset: float = 0.0

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var energy_label: Label = $CurrencyBar/EnergyPanel/EnergyHBox/EnergyLabel
@onready var gems_label: Label = $CurrencyBar/GemsPanel/GemsHBox/GemsLabel
@onready var gold_label: Label = $CurrencyBar/GoldPanel/GoldHBox/GoldLabel
@onready var title_label: Label = $Header/TitleLabel
@onready var rate_label: Label = $Header/RateLabel

# CircleViewport
@onready var circle_viewport: Panel = $CircleViewport
@onready var viewport_bg: ColorRect = $CircleViewport/ViewportContent/Background
@onready var character_sprite: Label = $CircleViewport/ViewportContent/Character

# StartButton
@onready var start_button: Button = $StartButton
@onready var energy_cost_label: Label = $StartButton/EnergyCostLabel

# BottomNav
@onready var home_tab: Button = $BottomNav/HomeTab
@onready var cards_tab: Button = $BottomNav/CardsTab
@onready var upgrade_tab: Button = $BottomNav/UpgradeTab
@onready var progress_tab: Button = $BottomNav/ProgressTab
@onready var shop_tab: Button = $BottomNav/ShopTab

var tab_buttons: Array = []

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	tab_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	
	apply_styles()
	setup_signals()
	update_display()
	set_active_tab(0)  # Home 활성화
	
	print("[MainLobbyUI] 메인 로비 준비 완료")

# ─── 매 프레임 업데이트 ──────────────────────────────
func _process(delta: float) -> void:
	# 배경 스크롤 애니메이션
	background_offset += BACKGROUND_SCROLL_SPEED * delta
	if background_offset > viewport_bg.size.x:
		background_offset = 0.0
	
	viewport_bg.position.x = -background_offset
	
	# Rate 업데이트
	update_rate_label()
	
	# 캐릭터 걷기 애니메이션 (간단한 좌우 흔들림)
	var walk_offset = sin(Time.get_ticks_msec() * CHARACTER_WALK_SPEED * 0.001) * 5.0
	character_sprite.position.x = 140 + walk_offset

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	background.color = UITheme.COLORS.bg
	
	# 타이틀
	title_label.add_theme_font_size_override("font_size", 24)
	title_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	
	rate_label.add_theme_font_size_override("font_size", 14)
	rate_label.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	
	# CircleViewport 스타일 (원형)
	var circle_style = StyleBoxFlat.new()
	circle_style.bg_color = UITheme.COLORS.panel
	circle_style.corner_radius_top_left = 150
	circle_style.corner_radius_top_right = 150
	circle_style.corner_radius_bottom_left = 150
	circle_style.corner_radius_bottom_right = 150
	circle_style.border_width_left = 4
	circle_style.border_width_top = 4
	circle_style.border_width_right = 4
	circle_style.border_width_bottom = 4
	circle_style.border_color = UITheme.COLORS.primary
	circle_viewport.add_theme_stylebox_override("panel", circle_style)
	
	# Viewport 배경 (숲 느낌 - 그라데이션)
	viewport_bg.color = Color(0.3, 0.5, 0.3)  # 초록 숲
	
	# 캐릭터 (플레이스홀더)
	character_sprite.add_theme_font_size_override("font_size", 48)
	
	# StartButton
	UITheme.apply_button_style(start_button, "success")
	start_button.add_theme_font_size_override("font_size", 20)
	energy_cost_label.add_theme_font_size_override("font_size", 16)
	energy_cost_label.add_theme_color_override("font_color", UITheme.COLORS.warning)
	
	# Tab buttons
	for button in tab_buttons:
		apply_tab_button_style(button)

func apply_tab_button_style(button: Button) -> void:
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
	# GameManager 시그널
	if GameManager.has_signal("energy_changed"):
		GameManager.energy_changed.connect(_on_energy_changed)
	if GameManager.has_signal("gems_changed"):
		GameManager.gems_changed.connect(_on_gems_changed)
	
	# Buttons
	start_button.pressed.connect(_on_start_pressed)
	
	# Tabs
	home_tab.pressed.connect(_on_tab_pressed.bind(0))
	cards_tab.pressed.connect(_on_tab_pressed.bind(1))
	upgrade_tab.pressed.connect(_on_tab_pressed.bind(2))
	progress_tab.pressed.connect(_on_tab_pressed.bind(3))
	shop_tab.pressed.connect(_on_tab_pressed.bind(4))

# ─── 디스플레이 업데이트 ─────────────────────────────
func update_display() -> void:
	if GameManager.has_method("get_energy"):
		_on_energy_changed(GameManager.energy)
	else:
		energy_label.text = "100"
	
	if GameManager.has_method("get_gems"):
		_on_gems_changed(GameManager.gems)
	else:
		gems_label.text = "0"
	
	# Gold (Reveries)
	gold_label.text = "329"
	
	# Energy cost
	energy_cost_label.text = "⚡ 5"
	
	update_rate_label()

func update_rate_label() -> void:
	rate_label.text = "10.0 / hour"

func _on_energy_changed(new_amount: int) -> void:
	energy_label.text = str(new_amount)

func _on_gems_changed(new_amount: int) -> void:
	gems_label.text = str(new_amount)

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_start_pressed() -> void:
	print("[MainLobbyUI] Run Prep으로 이동")
	get_tree().change_scene_to_file("res://ui/screens/RunPrep.tscn")

func _on_tab_pressed(tab_index: int) -> void:
	set_active_tab(tab_index)
	
	match tab_index:
		0:  # Home
			print("[MainLobbyUI] 이미 Home 화면")
		1:  # Cards
			print("[MainLobbyUI] Card Library로 이동")
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[MainLobbyUI] Upgrade (미구현)")
		3:  # Progress
			print("[MainLobbyUI] Progress (미구현)")
		4:  # Shop
			print("[MainLobbyUI] Shop으로 이동")
			get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")

func set_active_tab(tab_index: int) -> void:
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		if i == tab_index:
			button.add_theme_color_override("font_color", UITheme.COLORS.text)
		else:
			button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)

# ─── 치트 코드 ───────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_M:  # M키: Gold +1000
				gold_label.text = str(int(gold_label.text) + 1000)
				print("💰 치트: Gold +1000")
			KEY_G:  # G키: Gems +100
				if GameManager.has_method("add_gems"):
					GameManager.add_gems(100)
				print("💎 치트: Gems +100")
			KEY_E:  # E키: Energy +50
				if GameManager.has_method("add_energy"):
					GameManager.add_energy(50)
				print("⚡ 치트: Energy +50")
