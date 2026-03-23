extends BaseBottomUI

"""
ShopBottomUI - 상점 UI
아이템 그리드 + 구매 버튼

Layout (564px):
├─ GoldDisplay (50px) ← 🪙 1234
├─ ItemGrid (450px) ← 3×2 GridContainer, 스크롤 가능
└─ ActionButtons (64px) ← Leave
"""

@onready var currency_container = $GoldDisplay/CurrencyHBox
@onready var gems_label = $GoldDisplay/CurrencyHBox/GemsLabel
@onready var gold_label = $GoldDisplay/CurrencyHBox/GoldLabel
@onready var item_grid = $ItemScroll/ItemGrid
@onready var leave_button = $ActionButtons/LeaveButton

var test_items = [
	{"id": "potion_hp", "name": "HP Potion", "price": 100, "emoji": "❤️"},
	{"id": "potion_energy", "name": "Energy Potion", "price": 150, "emoji": "⚡"},
	{"id": "card_pack", "name": "Card Pack", "price": 300, "emoji": "🎴"},
	{"id": "upgrade_stone", "name": "Upgrade Stone", "price": 500, "emoji": "💎"},
	{"id": "rare_card", "name": "Rare Card", "price": 1000, "emoji": "✨"},
	{"id": "relic", "name": "Relic", "price": 2000, "emoji": "🏺"}
]

func _ready():
	_setup_buttons()
	_populate_shop()
	
	# Connect to GameManager signals
	if GameManager.has_signal("reveries_changed"):
		GameManager.reveries_changed.connect(_on_currency_changed)
	if GameManager.has_signal("gems_changed"):
		GameManager.gems_changed.connect(_on_currency_changed)
	
	ui_ready.emit()

func _on_enter():
	"""UI 활성화 시"""
	_update_currency()

func _on_exit():
	"""UI 비활성화 시"""
	pass

func _on_currency_changed(_unused=null):
	"""Handle currency change from GameManager"""
	_update_currency()

func _setup_buttons():
	"""Setup button connections — SVG UI 에셋 적용"""
	UISprites.apply_btn(leave_button, "secondary")
	leave_button.pressed.connect(_on_leave_pressed)

func _update_currency():
	"""Update currency display (gems + gold)"""
	var gems = GameManager.get_gems()
	var gold = GameManager.get_gold()
	gems_label.text = "💎 %d" % gems
	gold_label.text = "🪙 %d" % gold

func _populate_shop():
	"""Populate shop with items"""
	# Clear existing
	for child in item_grid.get_children():
		child.queue_free()
	
	# Add items
	for item in test_items:
		var item_card = _create_item_card(item)
		item_grid.add_child(item_card)

func _create_item_card(item: Dictionary) -> Control:
	"""Create an item card — SVG panel_frame 배경 적용"""
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(110, 150)
	UISprites.apply_panel(card, UISprites.panel_frame(), 8)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(vbox)
	
	# Emoji icon
	var icon = Label.new()
	icon.text = item.emoji
	icon.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon.add_theme_font_size_override("font_size", 48)
	vbox.add_child(icon)
	
	# Name
	var name_label = Label.new()
	name_label.text = item.name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	vbox.add_child(name_label)
	
	# Price
	var price_label = Label.new()
	price_label.text = "🪙 %d" % item.price
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)
	vbox.add_child(price_label)
	
	# Buy button — SVG UI 에셋 (primary=노랑)
	var buy_btn = Button.new()
	buy_btn.text = "Buy"
	UISprites.apply_btn(buy_btn, "primary")
	
	buy_btn.pressed.connect(_on_item_buy_pressed.bind(item))
	vbox.add_child(buy_btn)
	
	return card

func _on_item_buy_pressed(item: Dictionary):
	"""Handle item purchase"""
	var gold = GameManager.get_gold()
	
	if gold >= item.price:
		request_action("shop_purchase", {"item_id": item.id, "price": item.price})
		_update_currency()
		print("Purchased: %s for 🪙%d" % [item.name, item.price])
	else:
		print("Not enough gold!")

func _on_leave_pressed():
	"""Leave shop"""
	request_action("leave", {})
