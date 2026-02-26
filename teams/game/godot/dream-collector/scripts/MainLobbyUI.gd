# MainLobbyUI.gd
# 메인 로비 UI - 새로운 디자인
# 상단: 직사각형 뷰포트 (캐릭터 + 배경)
# 중간: 지난 꿈들 목록 (스크롤)
# 하단: 꿈 탐험 시작 + 덱세팅 버튼

extends Control

# ─── 애니메이션 설정 ─────────────────────────────────
const BACKGROUND_SCROLL_SPEED = 30.0
const CHARACTER_WALK_SPEED = 0.5

var background_offset: float = 0.0

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var energy_label: Label = $CurrencyBar/EnergyPanel/EnergyHBox/EnergyLabel
@onready var gems_label: Label = $CurrencyBar/GemsPanel/GemsHBox/GemsLabel
@onready var gold_label: Label = $CurrencyBar/GoldPanel/GoldHBox/GoldLabel

# ViewportFrame
@onready var viewport_frame: Panel = $ViewportFrame
@onready var viewport_bg: ColorRect = $ViewportFrame/ViewportContent/Background
@onready var hero_character = $ViewportFrame/ViewportContent/Character  # CharacterNode

# Dreams section
@onready var dreams_header: Label = $DreamsHeader
@onready var dreams_scroll: ScrollContainer = $DreamsScroll
@onready var dreams_container: VBoxContainer = $DreamsScroll/DreamsContainer

# Action buttons
@onready var start_button: Button = $ActionButtons/StartButton
@onready var start_energy_label: Label = $ActionButtons/StartButton/EnergyLabel
@onready var deck_button: Button = $ActionButtons/DeckButton

# BottomNav
@onready var home_tab: Button = $BottomNav/HomeTab
@onready var cards_tab: Button = $BottomNav/CardsTab
@onready var upgrade_tab: Button = $BottomNav/UpgradeTab
@onready var progress_tab: Button = $BottomNav/ProgressTab
@onready var shop_tab: Button = $BottomNav/ShopTab

var tab_buttons: Array = []

# DreamItem Scene
const DreamItemScene = preload("res://ui/components/DreamItem.tscn")

# Past dreams data
var past_dreams: Array = []
var currently_expanded_item = null  # Track currently expanded DreamItem for accordion

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	tab_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	
	apply_styles()
	setup_hero_character()
	setup_signals()
	load_past_dreams()
	update_display()
	set_active_tab(0)
	
	print("[MainLobbyUI] 메인 로비 준비 완료")

func setup_hero_character():
	"""Setup hero character in viewport"""
	if hero_character:
		hero_character.setup({
			"type": "hero",
			"name": "Hero",
			"hp": 80,
			"max_hp": 80,
			"emoji": "👤",
			"color": Color(0.48, 0.62, 0.94, 1)  # Blue
		})
		print("[MainLobbyUI] Hero character initialized")

# ─── 매 프레임 업데이트 ──────────────────────────────
func _process(delta: float) -> void:
	# 배경 스크롤
	background_offset += BACKGROUND_SCROLL_SPEED * delta
	if background_offset > viewport_bg.size.x:
		background_offset = 0.0
	viewport_bg.position.x = -background_offset
	
	# 캐릭터 걷기 애니메이션
	if hero_character:
		var walk_offset = sin(Time.get_ticks_msec() * CHARACTER_WALK_SPEED * 0.001) * 5.0
		hero_character.position.x = 190 + walk_offset

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	background.color = UITheme.COLORS.bg
	
	# ViewportFrame (직사각형)
	var frame_style = StyleBoxFlat.new()
	frame_style.bg_color = UITheme.COLORS.panel
	frame_style.corner_radius_top_left = 8
	frame_style.corner_radius_top_right = 8
	frame_style.corner_radius_bottom_left = 8
	frame_style.corner_radius_bottom_right = 8
	frame_style.border_width_left = 4
	frame_style.border_width_top = 4
	frame_style.border_width_right = 4
	frame_style.border_width_bottom = 4
	frame_style.border_color = UITheme.COLORS.primary
	viewport_frame.add_theme_stylebox_override("panel", frame_style)
	
	viewport_bg.color = Color(0.3, 0.5, 0.3)
	# Character uses CharacterNode component (no style override needed)
	
	# Dreams header
	dreams_header.add_theme_font_size_override("font_size", 16)
	dreams_header.add_theme_color_override("font_color", UITheme.COLORS.text)
	
	# Buttons
	UITheme.apply_button_style(start_button, "success")
	start_button.add_theme_font_size_override("font_size", 18)
	start_energy_label.add_theme_font_size_override("font_size", 16)
	start_energy_label.add_theme_color_override("font_color", UITheme.COLORS.warning)
	
	UITheme.apply_button_style(deck_button, "info")
	deck_button.add_theme_font_size_override("font_size", 18)
	
	# Tab buttons
	for button in tab_buttons:
		apply_tab_button_style(button)

func apply_tab_button_style(button: Button) -> void:
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UITheme.COLORS.panel
	button.add_theme_stylebox_override("normal", normal_style)
	
	button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)

# ─── 시그널 연결 ─────────────────────────────────────
func setup_signals() -> void:
	# GameManager signals
	if GameManager.has_signal("energy_changed"):
		GameManager.energy_changed.connect(_on_energy_changed)
	if GameManager.has_signal("gems_changed"):
		GameManager.gems_changed.connect(_on_gems_changed)
	
	# Buttons
	start_button.pressed.connect(_on_start_pressed)
	deck_button.pressed.connect(_on_deck_pressed)
	
	# Tabs
	home_tab.pressed.connect(_on_tab_pressed.bind(0))
	cards_tab.pressed.connect(_on_tab_pressed.bind(1))
	upgrade_tab.pressed.connect(_on_tab_pressed.bind(2))
	progress_tab.pressed.connect(_on_tab_pressed.bind(3))
	shop_tab.pressed.connect(_on_tab_pressed.bind(4))

# ─── 지난 꿈들 로드 ──────────────────────────────────
func load_past_dreams() -> void:
	# 기존 아이템 제거
	for child in dreams_container.get_children():
		child.queue_free()
	
	# 임시 데이터 생성
	past_dreams = [
		{
			"id": 1,
			"title": "#1 꿈 제목",
			"rarity": "common",
			"story": ["꿈 이야기1.", "꿈 이야기2.", "꿈 이야기3.", "꿈 이야기4."],
			"gold_reward": 50,
			"extra_claimed": false
		},
		{
			"id": 2,
			"title": "#2 꿈 제목",
			"rarity": "common",
			"story": ["꿈 이야기1.", "꿈 이야기2.", "꿈 이야기3.", "꿈 이야기4."],
			"gold_reward": 50,
			"extra_claimed": false
		},
		{
			"id": 3,
			"title": "#3 꿈 제목",
			"rarity": "rare",
			"story": ["꿈 이야기1.", "꿈 이야기2.", "꿈 이야기3.", "꿈 이야기4."],
			"gold_reward": 100,
			"extra_claimed": false
		},
		{
			"id": 4,
			"title": "#3 꿈 제목",
			"rarity": "epic",
			"story": ["꿈 이야기1.", "꿈 이야기2.", "꿈 이야기3.", "꿈 이야기4."],
			"gold_reward": 200,
			"extra_claimed": false
		}
	]
	
	# DreamItem 생성
	for dream_data in past_dreams:
		var dream_item = DreamItemScene.instantiate()
		dreams_container.add_child(dream_item)
		dream_item.set_dream_data(dream_data)
		dream_item.item_clicked.connect(_on_dream_item_clicked)
		dream_item.reward_claimed.connect(_on_dream_reward_claimed)

# ─── 디스플레이 업데이트 ─────────────────────────────
func update_display() -> void:
	if GameManager.has_method("get_energy"):
		_on_energy_changed(GameManager.energy)
	else:
		energy_label.text = "5"
	
	if GameManager.has_method("get_gems"):
		_on_gems_changed(GameManager.gems)
	else:
		gems_label.text = "5"
	
	gold_label.text = "5"
	start_energy_label.text = "⚡ 3"

func _on_energy_changed(new_amount: int) -> void:
	energy_label.text = str(new_amount)

func _on_gems_changed(new_amount: int) -> void:
	gems_label.text = str(new_amount)

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_start_pressed() -> void:
	print("[MainLobbyUI] Run Prep으로 이동")
	get_tree().change_scene_to_file("res://ui/screens/RunPrep.tscn")

func _on_deck_pressed() -> void:
	print("[MainLobbyUI] Deck Builder로 이동")
	get_tree().change_scene_to_file("res://ui/screens/DeckBuilder.tscn")

func _on_dream_item_clicked(dream_id: int) -> void:
	print("[MainLobbyUI] Dream item clicked: %d" % dream_id)
	
	# Accordion: collapse all except clicked item
	var clicked_item = null
	for child in dreams_container.get_children():
		if child.dream_id == dream_id:
			clicked_item = child
			break
	
	# If clicking a different item, collapse previous
	if clicked_item and clicked_item != currently_expanded_item:
		if currently_expanded_item and currently_expanded_item.is_expanded:
			currently_expanded_item.collapse()
		currently_expanded_item = clicked_item
	elif clicked_item == currently_expanded_item and not clicked_item.is_expanded:
		# Item was collapsed, no longer expanded
		currently_expanded_item = null

func _on_dream_reward_claimed(dream_id: int) -> void:
	print("[MainLobbyUI] Reward claimed: %d" % dream_id)
	# TODO: Add gold to player

func _on_tab_pressed(tab_index: int) -> void:
	set_active_tab(tab_index)
	
	match tab_index:
		0:  # Home
			print("[MainLobbyUI] 이미 Home 화면")
		1:  # Cards
			print("[MainLobbyUI] Card Library로 이동")
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[MainLobbyUI] Upgrade Tree로 이동")
			get_tree().change_scene_to_file("res://ui/screens/UpgradeTree.tscn")
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
			KEY_M:
				gold_label.text = str(int(gold_label.text) + 1000)
				print("💰 치트: Gold +1000")
			KEY_G:
				if GameManager.has_method("add_gems"):
					GameManager.add_gems(100)
				print("💎 치트: Gems +100")
			KEY_E:
				if GameManager.has_method("add_energy"):
					GameManager.add_energy(50)
				print("⚡ 치트: Energy +50")
