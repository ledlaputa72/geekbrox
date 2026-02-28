extends HBoxContainer

# BottomNav - 공통 하단 탭 네비게이션

signal tab_pressed(tab_index: int)

@onready var home_tab: Button = $HomeTab
@onready var cards_tab: Button = $CardsTab
@onready var upgrade_tab: Button = $UpgradeTab
@onready var progress_tab: Button = $ProgressTab
@onready var shop_tab: Button = $ShopTab

var tab_buttons: Array = []
var active_tab_index: int = 0

func _ready():
	tab_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	
	# Apply styles
	for button in tab_buttons:
		_apply_tab_style(button)
	
	# Connect signals
	home_tab.pressed.connect(_on_tab_pressed.bind(0))
	cards_tab.pressed.connect(_on_tab_pressed.bind(1))
	upgrade_tab.pressed.connect(_on_tab_pressed.bind(2))
	progress_tab.pressed.connect(_on_tab_pressed.bind(3))
	shop_tab.pressed.connect(_on_tab_pressed.bind(4))

func _apply_tab_style(button: Button):
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UITheme.COLORS.panel
	button.add_theme_stylebox_override("normal", normal_style)
	
	button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)

func set_active_tab(tab_index: int):
	active_tab_index = tab_index
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		if i == tab_index:
			button.add_theme_color_override("font_color", UITheme.COLORS.text)
		else:
			button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)

func _on_tab_pressed(tab_index: int):
	tab_pressed.emit(tab_index)
