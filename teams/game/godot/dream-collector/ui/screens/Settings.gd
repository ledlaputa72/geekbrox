extends Control

# Settings - 게임 설정 화면

@onready var back_button = $TopBar/BackButton
@onready var title_label = $TopBar/TitleLabel
@onready var settings_list = $ScrollContainer/SettingsList

func _ready():
	UISprites.apply_btn(back_button, "secondary")
	back_button.pressed.connect(_on_back_pressed)
	
	# Build settings UI
	_build_settings()
	
	print("[Settings] Ready")

func _build_settings():
	"""Build all setting sections"""
	_add_section_header("🔊 사운드")
	_add_volume_slider("BGM 볼륨", 0.7)
	_add_volume_slider("SFX 볼륨", 0.8)
	
	_add_section_header("🌐 언어")
	_add_language_selector()
	
	_add_section_header("👤 계정")
	_add_account_info()
	
	_add_section_header("ℹ️ 정보")
	_add_credits()
	_add_version_info()

func _add_section_header(title: String):
	"""Add section header"""
	if settings_list.get_child_count() > 0:
		var div = TextureRect.new()
		div.texture = UISprites.divider_subtle()
		div.custom_minimum_size = Vector2(0, 4)
		div.stretch_mode = TextureRect.STRETCH_SCALE
		settings_list.add_child(div)
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	settings_list.add_child(spacer)

	var label = Label.new()
	label.text = title
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.large)
	label.add_theme_color_override("font_color", UITheme.COLORS.primary)
	settings_list.add_child(label)

func _add_volume_slider(label_text: String, initial_value: float):
	"""Add volume slider"""
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 10)
	settings_list.add_child(container)
	
	var label = Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(120, 40)
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
	container.add_child(label)
	
	var slider = HSlider.new()
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.1
	slider.value = initial_value
	slider.custom_minimum_size = Vector2(0, 40)
	slider.value_changed.connect(_on_volume_changed.bind(label_text))
	container.add_child(slider)
	
	var value_label = Label.new()
	value_label.text = "%d%%" % (initial_value * 100)
	value_label.custom_minimum_size = Vector2(50, 40)
	value_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
	container.add_child(value_label)
	
	slider.set_meta("value_label", value_label)

func _on_volume_changed(value: float, volume_type: String):
	"""Handle volume slider change"""
	var slider = get_tree().get_nodes_in_group("volume_sliders").filter(
		func(s): return s.get_meta("volume_type") == volume_type
	)[0] if get_tree().get_nodes_in_group("volume_sliders").size() > 0 else null
	
	if slider and slider.has_meta("value_label"):
		var value_label = slider.get_meta("value_label")
		value_label.text = "%d%%" % (value * 100)
	
	print("[Settings] %s changed to %.1f" % [volume_type, value])
	# TODO: Apply to AudioServer

func _add_language_selector():
	"""Add language selector buttons"""
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 10)
	settings_list.add_child(container)
	
	var korean_button = Button.new()
	korean_button.text = "한국어"
	korean_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	korean_button.custom_minimum_size = Vector2(0, 50)
	UISprites.apply_btn(korean_button, "primary")
	korean_button.pressed.connect(_on_language_changed.bind("ko"))
	container.add_child(korean_button)

	var english_button = Button.new()
	english_button.text = "English"
	english_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	english_button.custom_minimum_size = Vector2(0, 50)
	UISprites.apply_btn(english_button, "secondary")
	english_button.pressed.connect(_on_language_changed.bind("en"))
	container.add_child(english_button)

func _on_language_changed(lang: String):
	"""Handle language change"""
	print("[Settings] Language changed to: ", lang)
	# TODO: Apply language change

func _add_account_info():
	"""Add account information"""
	var label = Label.new()
	label.text = "플레이어 ID: PLAYER_12345\n마지막 로그인: 2026-02-25"
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	settings_list.add_child(label)

func _add_credits():
	"""Add credits button"""
	var button = Button.new()
	button.text = "크레딧 보기"
	button.custom_minimum_size = Vector2(0, 50)
	UISprites.apply_btn(button, "secondary")
	button.pressed.connect(_on_credits_pressed)
	settings_list.add_child(button)

func _on_credits_pressed():
	"""Show credits"""
	print("[Settings] Credits pressed")
	# TODO: Show credits modal

func _add_version_info():
	"""Add version information"""
	var label = Label.new()
	label.text = "Dream Collector v0.1.0 (Build 2026-02-25)"
	label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_list.add_child(label)

func _on_back_pressed():
	"""Go back to MainLobby"""
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
