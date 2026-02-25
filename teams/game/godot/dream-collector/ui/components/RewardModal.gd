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
	
	# Setup continue button
	if continue_button:
		UITheme.apply_button_style(continue_button, "primary")
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
			reward_list.add_child(no_reward)
		else:
			for reward in rewards:
				var reward_label = Label.new()
				reward_label.text = "• %s" % reward
				reward_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.normal)
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
