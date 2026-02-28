extends CanvasLayer

"""
RewardModal - 전투 보상 모달
전체 화면 대신 중앙 모달로 보상 표시

Features:
- Victory/Defeat 표시
- 보상 아이템 리스트
- 계속하기 버튼
"""

signal reward_claimed()

@onready var modal_bg = $ModalBg
@onready var modal_panel = $ModalPanel
@onready var title_label = $ModalPanel/VBox/TitleLabel
@onready var reward_list = $ModalPanel/VBox/RewardList
@onready var continue_button = $ModalPanel/VBox/ContinueButton

func _ready():
	layer = 100  # Top layer
	visible = false
	
	# ModalPanel: 완전 불투명 배경 (기본 PanelContainer 스타일이 투명할 수 있으므로 명시 설정)
	if modal_panel:
		var panel_style = StyleBoxFlat.new()
		panel_style.bg_color = Color(0.14, 0.14, 0.22, 1.0)  # 완전 불투명 다크 블루
		panel_style.corner_radius_top_left = 16
		panel_style.corner_radius_top_right = 16
		panel_style.corner_radius_bottom_left = 16
		panel_style.corner_radius_bottom_right = 16
		panel_style.border_width_left = 1
		panel_style.border_width_top = 1
		panel_style.border_width_right = 1
		panel_style.border_width_bottom = 1
		panel_style.border_color = Color(0.35, 0.35, 0.55, 1.0)
		panel_style.content_margin_left = 24
		panel_style.content_margin_right = 24
		panel_style.content_margin_top = 24
		panel_style.content_margin_bottom = 24
		modal_panel.add_theme_stylebox_override("panel", panel_style)
	
	# Setup title label
	if title_label:
		title_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.header)
		title_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	
	# Setup continue button
	if continue_button:
		UITheme.apply_button_style(continue_button, "primary")
		continue_button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
		continue_button.pressed.connect(_on_continue_pressed)
	
	# Click background to close
	if modal_bg:
		var btn = Button.new()
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.flat = true
		btn.pressed.connect(_on_continue_pressed)
		modal_bg.add_child(btn)

func show_victory(rewards: Array):
	"""Show victory modal with rewards"""
	visible = true
	
	if title_label:
		title_label.text = "🎉 VICTORY 🎉"
		title_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2, 1))
	
	_populate_rewards(rewards)
	
	# Fade in animation
	_animate_show()

func show_defeat():
	"""Show defeat modal"""
	visible = true
	
	if title_label:
		title_label.text = "💀 DEFEAT 💀"
		title_label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))
	
	# No rewards
	_populate_rewards([])
	
	# Fade in animation
	_animate_show()

func _populate_rewards(rewards: Array):
	"""Populate reward list"""
	# Clear existing
	if reward_list:
		for child in reward_list.get_children():
			child.queue_free()
		
		if rewards.is_empty():
			var no_reward = Label.new()
			no_reward.text = "No rewards"
			no_reward.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			no_reward.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
			no_reward.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
			reward_list.add_child(no_reward)
		else:
			for reward in rewards:
				var reward_label = Label.new()
				reward_label.text = "• %s" % reward
				reward_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.body)
				reward_label.add_theme_color_override("font_color", UITheme.COLORS.text)
				reward_list.add_child(reward_label)

func _animate_show():
	"""Fade in animation"""
	modal_bg.modulate.a = 0.0
	modal_panel.modulate.a = 0.0
	modal_panel.scale = Vector2(0.8, 0.8)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(modal_bg, "modulate:a", 1.0, 0.3)
	tween.tween_property(modal_panel, "modulate:a", 1.0, 0.3)
	tween.tween_property(modal_panel, "scale", Vector2(1.0, 1.0), 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_continue_pressed():
	"""Continue button pressed"""
	# Fade out animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(modal_bg, "modulate:a", 0.0, 0.2)
	tween.tween_property(modal_panel, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		visible = false
		reward_claimed.emit()
	)
