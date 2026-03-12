extends CanvasLayer

signal reward_selected(card_id: String)
signal reward_skipped()

@onready var control = $Control
@onready var title_label = $Control/ModalPanel/VBox/TitleLabel
@onready var desc_label = $Control/ModalPanel/VBox/DescLabel
@onready var cards_container = $Control/ModalPanel/VBox/CardsContainer
@onready var skip_button = $Control/ModalPanel/VBox/SkipButton

var reward_cards: Array = []

func _ready():
	control.visible = false
	_apply_theme_styles()
	skip_button.pressed.connect(_on_skip_pressed)

func _apply_theme_styles():
	title_label.add_theme_font_size_override("font_size", 20)
	desc_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	UISprites.apply_btn(skip_button, "secondary")

func show_rewards(cards: Array):
	"""
	Show reward modal with card choices
	cards: Array of card data dictionaries
	"""
	reward_cards = cards
	control.visible = true
	
	# Clear existing cards
	for child in cards_container.get_children():
		child.queue_free()
	
	# Create card buttons
	for i in range(cards.size()):
		var card = cards[i]
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(80, 112)
		btn.text = "%s\n[%d]" % [card.get("name", "???"), card.get("cost", 0)]
		btn.pressed.connect(_on_card_selected.bind(i))
		cards_container.add_child(btn)
		
		# Apply type color
		match card.get("type", ""):
			"Attack":
				btn.modulate = Color(1.0, 0.6, 0.6)   # 빨강
			"Skill":
				btn.modulate = Color(0.7, 1.0, 0.7)    # 초록
			"Power":
				btn.modulate = Color(0.6, 0.8, 1.0)    # 파랑
			"Curse":
				btn.modulate = Color(1.0, 0.95, 0.5)   # 노랑

func hide_modal():
	control.visible = false

func _on_card_selected(index: int):
	if index >= 0 and index < reward_cards.size():
		var card = reward_cards[index]
		var card_id = card.get("id", "")
		
		print("[RewardsModal] Selected: %s" % card_id)
		reward_selected.emit(card_id)
		hide_modal()

func _on_skip_pressed():
	print("[RewardsModal] Skipped reward")
	reward_skipped.emit()
	hide_modal()
