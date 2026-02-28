extends BaseBottomUI

"""
StoryBottomUI - 스토리 이벤트 UI
스토리 텍스트 + 선택지 버튼

Layout (564px):
├─ StoryText (350px) ← 텍스트 + 스크롤
├─ ChoiceButtons (150px) ← VBoxContainer
│  ├─ Button "선택지 1"
│  └─ Button "선택지 2"
└─ SkipButton (64px)
"""

@onready var story_text = $StoryScroll/StoryText
@onready var choice_container = $ChoiceContainer
@onready var skip_button = $ActionButtons/SkipButton

var test_story = {
	"text": "당신은 어두운 복도 끝에서 이상한 빛을 발견했습니다. 빛은 당신을 부르는 듯합니다. 가까이 다가가자 두 개의 문이 나타났습니다. 하나는 붉은 문, 또 하나는 푸른 문입니다.",
	"choices": [
		"붉은 문을 연다 (위험하지만 보상이 클 수 있다)",
		"푸른 문을 연다 (안전하지만 평범한 보상)",
		"무시하고 지나간다"
	]
}

func _ready():
	_setup_buttons()
	_load_story(test_story)
	ui_ready.emit()

func _on_enter():
	"""UI 활성화 시"""
	pass

func _on_exit():
	"""UI 비활성화 시"""
	pass

func _setup_buttons():
	"""Setup button connections"""
	# Apply custom style to skip button
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
	
	skip_button.add_theme_stylebox_override("normal", style)
	skip_button.add_theme_stylebox_override("hover", style)
	skip_button.add_theme_stylebox_override("pressed", style)
	skip_button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.subtitle)
	skip_button.add_theme_color_override("font_color", UITheme.COLORS.text)
	
	skip_button.pressed.connect(_on_skip_pressed)

func _load_story(story_data: Dictionary):
	"""Load story text and choices"""
	# Set story text
	story_text.text = story_data.get("text", "...")
	
	# Clear existing choices
	for child in choice_container.get_children():
		child.queue_free()
	
	# Add choice buttons
	var choices = story_data.get("choices", [])
	for i in range(choices.size()):
		var choice_text = choices[i]
		var btn = Button.new()
		btn.text = choice_text
		btn.custom_minimum_size = Vector2(0, 40)
		
		# Apply custom style
		var btn_style = StyleBoxFlat.new()
		btn_style.bg_color = UITheme.COLORS.primary
		btn_style.corner_radius_top_left = 8
		btn_style.corner_radius_top_right = 8
		btn_style.corner_radius_bottom_left = 8
		btn_style.corner_radius_bottom_right = 8
		btn_style.content_margin_left = 16
		btn_style.content_margin_right = 16
		btn_style.content_margin_top = 10
		btn_style.content_margin_bottom = 10
		
		btn.add_theme_stylebox_override("normal", btn_style)
		btn.add_theme_stylebox_override("hover", btn_style)
		btn.add_theme_stylebox_override("pressed", btn_style)
		btn.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.body)
		btn.add_theme_color_override("font_color", UITheme.COLORS.text)
		
		btn.pressed.connect(_on_choice_pressed.bind(i))
		choice_container.add_child(btn)

func _on_choice_pressed(choice_index: int):
	"""Handle choice selection"""
	request_action("story_choice", {"choice_index": choice_index})
	
	# Temporary outcome
	match choice_index:
		0:
			story_text.text = "붉은 문을 열자 강력한 보스가 나타났다! 전투 준비!"
			await get_tree().create_timer(2.0).timeout
			request_action("leave", {})
		1:
			story_text.text = "푸른 문을 열자 평화로운 방이 나타났다. 작은 보상을 얻었다."
			await get_tree().create_timer(2.0).timeout
			request_action("leave", {})
		2:
			story_text.text = "당신은 빛을 무시하고 지나갔다."
			await get_tree().create_timer(1.5).timeout
			request_action("leave", {})

func _on_skip_pressed():
	"""Skip story"""
	request_action("leave", {})

func update_data(data: Dictionary):
	"""Update story from external"""
	if data.has("story"):
		_load_story(data.story)
