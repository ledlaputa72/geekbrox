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
@onready var viewport_bg: TextureRect = $ViewportFrame/ViewportContent/Background
@onready var hero_sprite = $ViewportFrame/ViewportContent/HeroSprite  # HomeHeroSprite

# Dreams section
@onready var dreams_header: Label = $DreamsHeader
@onready var dreams_scroll: ScrollContainer = $DreamsScroll
@onready var dreams_container: VBoxContainer = $DreamsScroll/DreamsContainer

# Action buttons
@onready var start_button: Button = $ActionButtons/StartButton
@onready var start_energy_label: Label = $ActionButtons/StartButton/EnergyLabel
@onready var deck_button: Button = $ActionButtons/DeckButton

# BottomNav (동일 컴포넌트 사용 → 다른 탭과 같은 탭 스타일)
@onready var bottom_nav = $BottomNav
@onready var home_tab: Button = $BottomNav/HomeTab
@onready var cards_tab: Button = $BottomNav/CardsTab
@onready var upgrade_tab: Button = $BottomNav/UpgradeTab
@onready var shop_tab: Button = $BottomNav/ShopTab

# DreamItem Scene
const DreamItemScene = preload("res://ui/components/DreamItem.tscn")

# Past dreams data
var past_dreams: Array = []
var currently_expanded_item = null  # Track currently expanded DreamItem for accordion

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_hero_character()
	setup_signals()
	load_past_dreams()
	update_display()
	bottom_nav.set_active_tab(0)
	_apply_translations()
	if LocaleManager:
		LocaleManager.locale_changed.connect(_on_locale_changed)
	print("[MainLobbyUI] Main lobby ready.")

func setup_hero_character():
	# Setup hero sprite in viewport (HomeHeroSprite — 걷기 애니메이션)
	if hero_sprite:
		print("[MainLobbyUI] Hero walk sprite initialized")

# ─── 매 프레임 업데이트 ──────────────────────────────
func _process(delta: float) -> void:
	# 배경 스크롤
	background_offset += BACKGROUND_SCROLL_SPEED * delta
	if background_offset > viewport_bg.size.x:
		background_offset = 0.0
	viewport_bg.position.x = -background_offset
	
	# 캐릭터 위치 미세 흔들림 (걷는 느낌)
	if hero_sprite:
		var walk_offset = sin(Time.get_ticks_msec() * CHARACTER_WALK_SPEED * 0.001) * 5.0
		hero_sprite.offset_left = 163 + walk_offset
		hero_sprite.offset_right = 227 + walk_offset

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	background.color = UITheme.COLORS.bg

	UISprites.apply_panel(viewport_frame, UISprites.panel_frame(), 8)

	dreams_header.add_theme_font_size_override("font_size", 16)
	dreams_header.add_theme_color_override("font_color", UITheme.COLORS.get("text_on_dark", Color.WHITE))

	# ── 메인 액션 버튼 — UI Pack button_rectangle_depth_flat ──
	UISprites.apply_btn(start_button, "green")    # 탐험 시작: 녹색 CTA
	start_button.add_theme_font_size_override("font_size", 18)
	start_energy_label.add_theme_font_size_override("font_size", 16)
	start_energy_label.add_theme_color_override("font_color", UITheme.COLORS.warning)

	UISprites.apply_btn(deck_button, "secondary") # 덱 설정: 회색 보조
	deck_button.add_theme_font_size_override("font_size", 18)

	# ── 재화 칩(TopBar) — hud_pill SVG NinePatch ───────────
	_apply_currency_pill_style()

	# CurrencyBar: replace emoji with pixel icons if available
	_apply_currency_pixel_icons()

func _apply_currency_pill_style() -> void:
	"""재화 칩 패널에 hud_pill.svg NinePatch 스타일 적용"""
	var pill_tex := UISprites.hud_pill()
	if pill_tex == null:
		return
	for panel_path in ["CurrencyBar/EnergyPanel", "CurrencyBar/GemsPanel", "CurrencyBar/GoldPanel"]:
		var panel := get_node_or_null(panel_path)
		if panel:
			UISprites.apply_panel(panel, pill_tex, 8)

func _apply_currency_pixel_icons() -> void:
	if not UIManager:
		return
	var keys := [
		{"hbox": "CurrencyBar/GemsPanel/GemsHBox",   "icon": "diamond"},
		{"hbox": "CurrencyBar/GoldPanel/GoldHBox",   "icon": "coin"},
		{"hbox": "CurrencyBar/EnergyPanel/EnergyHBox", "icon": "energy"},
	]
	for k in keys:
		var panel := get_node_or_null(k.hbox) as HBoxContainer
		if panel == null:
			continue
		# find first Label (emoji)
		var emoji_label: Label = null
		for c in panel.get_children():
			if c is Label:
				emoji_label = c
				break
		if emoji_label == null:
			continue
		var tex := UIManager.get_pixel_icon(k.icon)
		if tex == null:
			continue
		# 중복 추가 방지
		var already := false
		for c in panel.get_children():
			if c is TextureRect:
				already = true
				break
		if already:
			emoji_label.visible = false
			continue
		var icon_rect := TextureRect.new()
		icon_rect.custom_minimum_size = Vector2(24, 24)
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.texture = tex
		icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var idx := emoji_label.get_index()
		panel.add_child(icon_rect)
		panel.move_child(icon_rect, idx)
		emoji_label.visible = false

func _apply_translations() -> void:
	if dreams_header:
		dreams_header.text = tr("lobby.past_dreams")
	if start_button:
		start_button.text = tr("lobby.start_explore")
	if deck_button:
		deck_button.text = tr("lobby.deck_setting")
	if bottom_nav:
		bottom_nav.set_tab_labels(
			tr("lobby.tab_home"),
			tr("lobby.tab_cards"),
			tr("lobby.tab_upgrade"),
			tr("lobby.tab_character"),
			tr("lobby.tab_shop")
		)

func _on_locale_changed(_locale_code: String) -> void:
	_apply_translations()
	load_past_dreams()

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
	
	# BottomNav 탭 (컴포넌트가 시그널 발사 → 여기서 수신)
	bottom_nav.tab_pressed.connect(_on_tab_pressed)

# ─── 지난 꿈들 로드 ──────────────────────────────────
func load_past_dreams() -> void:
	# 기존 아이템 제거
	for child in dreams_container.get_children():
		child.queue_free()
	
	var dream_title_key := tr("lobby.dream_title")
	# #region agent log
	var _agent_log_path = "/Users/stevemacbook/Projects/geekbrox/.cursor/debug-e7b017.log"
	var _f = FileAccess.open(_agent_log_path, FileAccess.READ_WRITE)
	if _f:
		_f.seek_end()
		_f.store_line(JSON.stringify({"sessionId": "e7b017", "location": "MainLobbyUI.gd:load_past_dreams", "message": "dream_title_key", "data": {"key": "lobby.dream_title", "value": dream_title_key, "len": dream_title_key.length()}, "timestamp": int(Time.get_ticks_msec()), "hypothesisId": "H1"}))
		_f.close()
	# #endregion agent log
	# 임시 데이터 생성
	past_dreams = [
		{
			"id": 1,
			"title": "#1 " + dream_title_key,
			"rarity": "common",
			"story": ["Story 1.", "Story 2.", "Story 3.", "Story 4."],
			"gold_reward": 50,
			"extra_claimed": false,
		},
		{
			"id": 2,
			"title": "#2 " + dream_title_key,
			"rarity": "common",
			"story": ["Story 1.", "Story 2.", "Story 3.", "Story 4."],
			"gold_reward": 50,
			"extra_claimed": false,
		},
		{
			"id": 3,
			"title": "#3 " + dream_title_key,
			"rarity": "rare",
			"story": ["Story 1.", "Story 2.", "Story 3.", "Story 4."],
			"gold_reward": 100,
			"extra_claimed": false,
		},
		{
			"id": 4,
			"title": "#3 " + dream_title_key,
			"rarity": "epic",
			"story": ["Story 1.", "Story 2.", "Story 3.", "Story 4."],
			"gold_reward": 200,
			"extra_claimed": false,
		},
	]
	# #region agent log
	_f = FileAccess.open(_agent_log_path, FileAccess.READ_WRITE)
	if _f:
		_f.seek_end()
		_f.store_line(JSON.stringify({"sessionId": "e7b017", "location": "MainLobbyUI.gd:load_past_dreams", "message": "first_past_dream_title", "data": {"title": past_dreams[0].title}, "timestamp": int(Time.get_ticks_msec()), "hypothesisId": "H4"}))
		_f.close()
	# #endregion agent log
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

func _on_energy_changed(_new_amount: int) -> void:
	energy_label.text = str(_new_amount)

func _on_gems_changed(_new_amount: int) -> void:
	gems_label.text = str(_new_amount)

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_start_pressed() -> void:
	print("[MainLobbyUI] Navigate to Dream Card Selection")
	get_tree().change_scene_to_file("res://ui/screens/DreamCardSelection.tscn")

func _on_deck_pressed() -> void:
	print("[MainLobbyUI] Navigate to Deck Builder")
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
	if bottom_nav and bottom_nav.has_method("set_active_tab"):
		bottom_nav.call_deferred("set_active_tab", tab_index)
	match tab_index:
		0:  # Home
			pass
		1:  # Cards
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			get_tree().change_scene_to_file("res://ui/screens/UpgradeTree.tscn")
		3:  # Character
			get_tree().change_scene_to_file("res://ui/screens/CharacterScreen.tscn")
		4:  # Shop
			get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")

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
