extends HBoxContainer

# BottomNav - common bottom tab navigation
# Unselected: icon only. Selected: icon enlarged above, menu title below.

signal tab_pressed(tab_index: int)

var home_tab: Button = null
var cards_tab: Button = null
var upgrade_tab: Button = null
var character_tab: Button = null
var shop_tab: Button = null
var tab_buttons: Array = []
var active_tab_index: int = 0

# Per-tab icon (TextureRect) and label (Label) refs
var _tab_icons: Array = []   # TextureRect
var _tab_labels: Array = []  # Label
const _ICON_SIZE_NORMAL := Vector2(28, 28)
const _ICON_SIZE_SELECTED := Vector2(36, 36)

func _ready():
	home_tab = get_node_or_null("HomeTab") as Button
	cards_tab = get_node_or_null("CardsTab") as Button
	upgrade_tab = get_node_or_null("UpgradeTab") as Button
	character_tab = get_node_or_null("CharacterTab") as Button
	shop_tab = get_node_or_null("ShopTab") as Button
	tab_buttons = [home_tab, cards_tab, upgrade_tab, character_tab, shop_tab]

	# Resolve Icon and TabLabel for each tab
	_tab_icons.clear()
	_tab_labels.clear()
	for btn in tab_buttons:
		if btn:
			var icon_node = btn.get_node_or_null("VBox/IconWrap/Icon") as TextureRect
			var label_node = btn.get_node_or_null("VBox/TabLabel") as Label
			_tab_icons.append(icon_node)
			_tab_labels.append(label_node)
		else:
			_tab_icons.append(null)
			_tab_labels.append(null)

	for button in tab_buttons:
		if button and button is Button:
			_apply_tab_style(button)
	_apply_tab_icons()
	if UISprites:
		var t = UISprites.tab_bar()
		if t:
			UISprites.apply_bg(self, t, 8)

	if home_tab: home_tab.pressed.connect(_on_tab_pressed.bind(0))
	if cards_tab: cards_tab.pressed.connect(_on_tab_pressed.bind(1))
	if upgrade_tab: upgrade_tab.pressed.connect(_on_tab_pressed.bind(2))
	if character_tab: character_tab.pressed.connect(_on_tab_pressed.bind(3))
	if shop_tab: shop_tab.pressed.connect(_on_tab_pressed.bind(4))

	# Apply initial active state (icon-only for non-active)
	set_active_tab(active_tab_index)

func _apply_tab_style(button: Button):
	if button == null:
		return
	button.flat = true
	button.remove_theme_stylebox_override("normal")
	button.remove_theme_stylebox_override("hover")
	button.remove_theme_stylebox_override("pressed")

func set_tab_labels(home: String, cards: String, upgrade: String, character: String, shop: String) -> void:
	var labels := [home, cards, upgrade, character, shop]
	for i in range(min(labels.size(), _tab_labels.size())):
		var lbl = _tab_labels[i]
		if lbl:
			lbl.text = labels[i]

func _apply_tab_icons() -> void:
	if not UIManager:
		return
	var mapping := [
		"nav_home", "nav_cards", "nav_upgrade", "nav_character", "nav_shop"
	]
	for i in range(min(mapping.size(), _tab_icons.size())):
		var icon_rect: TextureRect = _tab_icons[i]
		if not icon_rect:
			continue
		var tex := UIManager.get_pixel_icon(mapping[i])
		if tex:
			icon_rect.texture = tex

func set_active_tab(tab_index: int):
	active_tab_index = tab_index
	const TEXT_C := Color(1.0, 0.92, 0.6, 1)   # 선택 탭: 따뜻한 금색
	const DIM_C := Color(0.55, 0.53, 0.50, 1)  # 비선택 탭: 중간 회색
	const ICON_SELECTED_TINT := Color(1.0, 0.92, 0.6, 1)
	const ICON_NORMAL_TINT   := Color(0.75, 0.72, 0.68, 1)
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		if not is_instance_valid(button):
			continue
		var is_selected := (i == tab_index)
		# Background (active/inactive)
		if button is Button and UISprites:
			UISprites.apply_tab_active(button, is_selected)
		# Icon: selected = larger + 금색 tint, unselected = normal size + dim
		var icon_rect: TextureRect = _tab_icons[i] if i < _tab_icons.size() else null
		if icon_rect:
			icon_rect.custom_minimum_size = _ICON_SIZE_SELECTED if is_selected else _ICON_SIZE_NORMAL
			icon_rect.modulate = ICON_SELECTED_TINT if is_selected else ICON_NORMAL_TINT
		# Label: only visible when selected
		var lbl: Label = _tab_labels[i] if i < _tab_labels.size() else null
		if lbl:
			lbl.visible = is_selected
			lbl.add_theme_color_override("font_color", TEXT_C if is_selected else DIM_C)
			lbl.add_theme_font_size_override("font_size", 11)

func _on_tab_pressed(tab_index: int):
	tab_pressed.emit(tab_index)
