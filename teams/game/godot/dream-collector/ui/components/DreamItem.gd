# DreamItem.gd
# 지난 꿈 아이템 컴포넌트 (확장/축소 가능)
# Dream Collector - Past Dreams List Item

extends PanelContainer

# ─── 시그널 ─────────────────────────────────────────
signal item_clicked(dream_id: int)
signal reward_claimed(dream_id: int)

# ─── 꿈 데이터 ─────────────────────────────────────
var dream_id: int = 0
var dream_title: String = ""
var dream_rarity: String = "common"  # common, rare, epic
var dream_story: Array = []  # Plain Array for JSON compatibility
var gold_reward: int = 50
var gold_reward_claimed: bool = false  # NEW: gold reward claimed
var extra_reward_claimed: bool = false
var is_expanded: bool = false

# ─── UI 노드 참조 ────────────────────────────────────
@onready var header_container: HBoxContainer = $VBox/HeaderContainer
@onready var title_label: Label = $VBox/HeaderContainer/TitleLabel
@onready var reward_button: Button = $VBox/HeaderContainer/RewardButton

@onready var story_container: VBoxContainer = $VBox/StoryContainer
@onready var story_label1: Label = $VBox/StoryContainer/StoryLabel1
@onready var story_label2: Label = $VBox/StoryContainer/StoryLabel2
@onready var story_label3: Label = $VBox/StoryContainer/StoryLabel3
@onready var story_label4: Label = $VBox/StoryContainer/StoryLabel4

@onready var extra_reward_container: HBoxContainer = $VBox/ExtraRewardContainer
@onready var extra_reward_button: Button = $VBox/ExtraRewardContainer/ExtraRewardButton

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	story_container.visible = false
	extra_reward_container.visible = false
	apply_styles()
	setup_signals()

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	# Panel style — list_item_normal.png 기본 (UISprites)
	var panel_style := UISprites.list_stylebox("common")
	if panel_style:
		add_theme_stylebox_override("panel", panel_style)

	# Labels
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.add_theme_color_override("font_color", Color(0.1, 0.1, 0.1))

	for label in [story_label1, story_label2, story_label3, story_label4]:
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(0.2, 0.2, 0.2))



func update_rarity_color() -> void:
	# 등급별 list 스프라이트로 패널 교체 (UISprites)
	var panel_style := UISprites.list_stylebox(dream_rarity)
	if panel_style:
		add_theme_stylebox_override("panel", panel_style)

# ─── 시그널 연결 ─────────────────────────────────────
func setup_signals() -> void:
	# Use self (PanelContainer) for click detection
	gui_input.connect(_on_header_clicked)
	reward_button.pressed.connect(_on_reward_button_pressed)
	extra_reward_button.pressed.connect(_on_extra_reward_button_pressed)

# ─── 데이터 설정 ─────────────────────────────────────
func set_dream_data(data: Dictionary) -> void:
	dream_id = data.get("id", 0)
	dream_title = data.get("title", "꿈 제목")
	dream_rarity = data.get("rarity", "common")
	dream_story = data.get("story", ["꿈 이야기1.", "꿈 이야기2.", "꿈 이야기3.", "꿈 이야기4."])
	gold_reward = data.get("gold_reward", 50)
	gold_reward_claimed = data.get("gold_claimed", false)  # NEW
	extra_reward_claimed = data.get("extra_claimed", false)
	
	update_display()

func update_display() -> void:
	# Title with rarity prefix
	var rarity_prefix = ""
	match dream_rarity:
		"common":
			rarity_prefix = "(일반)"
		"rare":
			rarity_prefix = "(고급)"
		"epic":
			rarity_prefix = "(레어)"
	
	title_label.text = "%s %s" % [rarity_prefix, dream_title]
	
	# Gold reward button
	if gold_reward_claimed:
		reward_button.text = "✓ 수령완료"
		reward_button.disabled = true
	else:
		reward_button.text = "🪙%d" % gold_reward
		reward_button.disabled = false
	
	# Rarity color - update panel style
	update_rarity_color()
	
	# Story labels
	for i in range(min(4, dream_story.size())):
		var label = get_node("VBox/StoryContainer/StoryLabel%d" % (i + 1))
		if label:
			label.text = dream_story[i]
	
	# Extra reward button
	if extra_reward_claimed:
		extra_reward_button.text = "✓ 수령완료"
		extra_reward_button.disabled = true
	else:
		extra_reward_button.text = "🎁 추가보상"
		extra_reward_button.disabled = false

# ─── 확장/축소 ───────────────────────────────────────
func toggle_expanded() -> void:
	is_expanded = !is_expanded
	
	if is_expanded:
		expand()
	else:
		collapse()

func expand() -> void:
	is_expanded = true
	story_container.visible = true
	extra_reward_container.visible = true
	
	# Animation (optional: add Tween for smooth transition)
	custom_minimum_size.y = 200  # Expanded height

func collapse() -> void:
	is_expanded = false
	story_container.visible = false
	extra_reward_container.visible = false
	
	custom_minimum_size.y = 50  # Collapsed height

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_header_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			toggle_expanded()
			item_clicked.emit(dream_id)

func _on_reward_button_pressed() -> void:
	if gold_reward_claimed:
		print("[DreamItem] Reward already claimed!")
		return
	
	gold_reward_claimed = true
	update_display()
	
	# Add gold to GameManager
	GameManager.add_gold(gold_reward)
	print("[DreamItem] Gold reward claimed: %d gold (Total: %d)" % [gold_reward, GameManager.get_gold()])
	
	reward_claimed.emit(dream_id)

func _on_extra_reward_button_pressed() -> void:
	if extra_reward_claimed:
		print("[DreamItem] Extra reward already claimed!")
		return
	
	extra_reward_claimed = true
	update_display()
	
	# Add extra reward (e.g., card pack)
	print("[DreamItem] Extra reward claimed: Card Pack x1")
	# TODO: Add card pack to inventory
	
	reward_claimed.emit(dream_id)
