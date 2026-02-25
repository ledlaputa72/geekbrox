extends Control

# UpgradeTree - 캐릭터/스킬/패시브 업그레이드 화면

@onready var back_button = $TopBar/BackButton
@onready var title_label = $TopBar/TitleLabel
@onready var tab_bar = $TabBar
@onready var scroll_container = $ScrollContainer
@onready var upgrade_list = $ScrollContainer/UpgradeList

var current_tab: int = 0 # 0: Character, 1: Skills, 2: Passive

func _ready():
	UITheme.apply_button_style(back_button, "secondary")
	back_button.pressed.connect(_on_back_pressed)
	
	# Setup tabs
	_setup_tabs()
	
	# Load initial upgrades
	_load_upgrades(current_tab)
	
	print("[UpgradeTree] Ready")

func _setup_tabs():
	"""Setup tab buttons"""
	var tab_names = ["캐릭터", "스킬", "패시브"]
	
	for i in range(3):
		var tab_button = tab_bar.get_child(i) as Button
		if tab_button:
			tab_button.text = tab_names[i]
			UITheme.apply_button_style(tab_button, "primary" if i == current_tab else "secondary")
			tab_button.pressed.connect(_on_tab_pressed.bind(i))

func _on_tab_pressed(tab_index: int):
	"""Handle tab change"""
	if tab_index == current_tab:
		return
	
	current_tab = tab_index
	
	# Update tab button styles
	for i in range(3):
		var tab_button = tab_bar.get_child(i) as Button
		if tab_button:
			UITheme.apply_button_style(tab_button, "primary" if i == current_tab else "secondary")
	
	# Reload upgrades
	_load_upgrades(current_tab)
	
	print("[UpgradeTree] Switched to tab: ", current_tab)

func _load_upgrades(tab_index: int):
	"""Load upgrades for selected tab"""
	# Clear existing items
	for child in upgrade_list.get_children():
		child.queue_free()
	
	# TODO: Load from GameManager
	var upgrades = _get_mock_upgrades(tab_index)
	
	for upgrade in upgrades:
		var item = _create_upgrade_item(upgrade)
		upgrade_list.add_child(item)

func _get_mock_upgrades(tab_index: int) -> Array:
	"""Get mock upgrade data"""
	match tab_index:
		0: # Character
			return [
				{"name": "최대 HP +10", "level": 3, "max_level": 5, "cost": 100},
				{"name": "공격력 +5", "level": 2, "max_level": 5, "cost": 150},
				{"name": "방어력 +3", "level": 1, "max_level": 5, "cost": 120},
			]
		1: # Skills
			return [
				{"name": "강타 위력 증가", "level": 2, "max_level": 3, "cost": 200},
				{"name": "방어 지속시간 증가", "level": 1, "max_level": 3, "cost": 180},
				{"name": "회복 효과 증가", "level": 0, "max_level": 3, "cost": 150},
			]
		2: # Passive
			return [
				{"name": "카드 드로우 +1", "level": 1, "max_level": 2, "cost": 300},
				{"name": "시작 에너지 +1", "level": 0, "max_level": 2, "cost": 250},
				{"name": "전투 보상 +20%", "level": 1, "max_level": 3, "cost": 200},
			]
	
	return []

func _create_upgrade_item(upgrade: Dictionary) -> Panel:
	"""Create upgrade item panel"""
	var panel = Panel.new()
	panel.custom_minimum_size = Vector2(0, 80)
	
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 10)
	panel.add_child(hbox)
	
	# Left: Name + Level
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)
	
	var name_label = Label.new()
	name_label.text = upgrade.name
	name_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
	vbox.add_child(name_label)
	
	var level_label = Label.new()
	level_label.text = "Lv %d/%d" % [upgrade.level, upgrade.max_level]
	level_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	level_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(level_label)
	
	# Right: Cost + Upgrade Button
	var button = Button.new()
	button.text = "🪙 %d" % upgrade.cost
	button.custom_minimum_size = Vector2(100, 60)
	button.disabled = upgrade.level >= upgrade.max_level
	UITheme.apply_button_style(button, "primary" if not button.disabled else "secondary")
	button.pressed.connect(_on_upgrade_pressed.bind(upgrade))
	hbox.add_child(button)
	
	return panel

func _on_upgrade_pressed(upgrade: Dictionary):
	"""Handle upgrade button press"""
	print("[UpgradeTree] Upgrade pressed: ", upgrade.name)
	
	# TODO: Deduct cost and apply upgrade
	# For now, just show a message
	var current_gold = GameManager.get_gold()
	if current_gold >= upgrade.cost:
		GameManager.add_gold(-upgrade.cost)
		print("[UpgradeTree] Upgraded! Gold: %d -> %d" % [current_gold, GameManager.get_gold()])
		_load_upgrades(current_tab) # Reload
	else:
		print("[UpgradeTree] Not enough gold!")

func _on_back_pressed():
	"""Go back to MainLobby"""
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
