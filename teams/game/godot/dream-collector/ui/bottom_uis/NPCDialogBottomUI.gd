extends BaseBottomUI

"""
NPCDialogBottomUI - NPC 대화 UI
대화 텍스트 + 선택지 버튼

Layout (564px):
├─ DialogText (300px) ← 텍스트 + 스크롤
├─ ChoiceButtons (200px) ← VBoxContainer
│  ├─ Button "선택지 1"
│  ├─ Button "선택지 2"
│  └─ Button "선택지 3"
└─ LeaveButton (64px)
"""

@onready var dialog_text = $MainVBox/DialogScroll/DialogText
@onready var choice_container = $MainVBox/ChoiceContainer
@onready var leave_button = $MainVBox/ActionButtons/LeaveButton

var test_dialog = {
	"text": "안녕하세요, 여행자님! 저는 이 꿈 세계를 안내하는 가이드입니다. 무엇을 도와드릴까요?",
	"choices": [
		"카드에 대해 알려주세요",
		"덱 구성 팁을 알려주세요",
		"이곳의 몬스터들은 어떤가요?",
		"나중에 다시 올게요"
	]
}

func _ready():
	_setup_buttons()
	_load_dialog(test_dialog)
	ui_ready.emit()

func _on_enter():
	"""UI 활성화 시"""
	pass

func _on_exit():
	"""UI 비활성화 시"""
	pass

func _setup_buttons():
	"""Setup button connections"""
	# Apply custom style to leave button
	var style = StyleBoxFlat.new()
	style.bg_color = UITheme.COLORS.panel
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 12
	style.content_margin_bottom = 12
	
	leave_button.add_theme_stylebox_override("normal", style)
	leave_button.add_theme_stylebox_override("hover", style)
	leave_button.add_theme_stylebox_override("pressed", style)
	leave_button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
	leave_button.add_theme_color_override("font_color", UITheme.COLORS.text)
	
	leave_button.pressed.connect(_on_leave_pressed)

func _load_dialog(dialog_data: Dictionary):
	"""Load dialog text and choices"""
	# Set dialog text
	dialog_text.text = dialog_data.get("text", "...")
	
	# Clear existing choices
	for child in choice_container.get_children():
		child.queue_free()
	
	# Add choice buttons
	var choices = dialog_data.get("choices", [])
	for i in range(choices.size()):
		var choice_text = choices[i]
		var btn = Button.new()
		btn.text = choice_text
		btn.custom_minimum_size = Vector2(0, 50)
		
		# Apply custom style
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = UITheme.COLORS.primary
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_left = 8
		btn_style.corner_radius_bottom_right = 8
		btn_style.content_margin_left = 16
		btn_style.content_margin_right = 16
		btn_style.content_margin_top = 12
		btn_style.content_margin_bottom = 12
		
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_stylebox_override("hover", btn_style)
		btn.add_theme_stylebox_override("pressed", btn_style)
		btn.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
		btn.add_theme_color_override("font_color", UITheme.COLORS.text)
		
		btn.pressed.connect(_on_choice_pressed.bind(i))
		choice_container.add_child(btn)

func _on_choice_pressed(choice_index: int):
	"""Handle choice selection"""
	request_action("npc_choice", {"choice_index": choice_index})
	
	# Update dialog based on choice (temporary)
	match choice_index:
		0:
			dialog_text.text = "카드는 전투에서 사용하는 기본 도구입니다. 공격, 방어, 스킬, 파워 카드가 있습니다."
		1:
			dialog_text.text = "덱은 15-25장이 적당합니다. 시너지를 고려하여 구성하세요!"
		2:
			dialog_text.text = "이 지역의 몬스터들은 다양한 패턴을 가지고 있습니다. 조심하세요!"
		3:
			request_action("leave", {})

func _on_leave_pressed():
	"""Leave dialog"""
	request_action("leave", {})

func update_data(data: Dictionary):
	"""Update dialog from external"""
	if data.has("dialog"):
		_load_dialog(data.dialog)
