# RunPrep.gd
# 타로 카드 기반 런 준비 화면
# Dream Tarot System - 꿈 시작 / 여정 / 종료

extends Control

# ─── CircleTransition ───────────────────────────────
const CircleTransitionScene = preload("res://ui/transitions/CircleTransition.tscn")
var circle_transition = null

# ─── 타로 카드 상태 ─────────────────────────────────
enum CardState { DECK, FLYING, PLACED, FLIPPED }

var card_states: Array[int] = [CardState.DECK, CardState.DECK, CardState.DECK]
var cards_flipped: int = 0
var current_animation: bool = false

# 카드 위치
const DECK_POS = Vector2(60, 100)
const CARD_POSITIONS = [
	Vector2(55, 240),   # 왼쪽: 꿈 시작 (중앙 정렬)
	Vector2(155, 240),  # 중앙: 꿈 여정
	Vector2(255, 240)   # 오른쪽: 꿈 종료
]

# 타로 텍스트
const TAROT_TEXTS = [
	{
		"title": "꿈 시작",
		"description": "당신에게 말을 건다"
	},
	{
		"title": "꿈 여정",
		"description": "곰 여정 카드가 선택되었다"
	},
	{
		"title": "꿈 종료",
		"description": "곰 종료"
	}
]

# 로그 메시지
var log_messages: Array[String] = []

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var table_bg: ColorRect = $TableBackground
@onready var top_bar: Panel = $TopBar
@onready var back_button: Button = $TopBar/HBox/BackButton
@onready var title_label: Label = $TopBar/HBox/TitleLabel

# 타로 덱 (왼쪽 상단)
@onready var tarot_deck: Panel = $TarotDeck
@onready var deck_label: Label = $TarotDeck/DeckLabel

# 타로 카드 3장
@onready var card1: Panel = $Card1
@onready var card1_front: Label = $Card1/FrontLabel
@onready var card1_back: Panel = $Card1/BackPanel
@onready var card1_back_title: Label = $Card1/BackPanel/TitleLabel
@onready var card1_button: Button = $Card1/CardButton

@onready var card2: Panel = $Card2
@onready var card2_front: Label = $Card2/FrontLabel
@onready var card2_back: Panel = $Card2/BackPanel
@onready var card2_back_title: Label = $Card2/BackPanel/TitleLabel
@onready var card2_button: Button = $Card2/CardButton

@onready var card3: Panel = $Card3
@onready var card3_front: Label = $Card3/FrontLabel
@onready var card3_back: Panel = $Card3/BackPanel
@onready var card3_back_title: Label = $Card3/BackPanel/TitleLabel
@onready var card3_button: Button = $Card3/CardButton

# 로그 영역
@onready var log_scroll: ScrollContainer = $LogScroll
@onready var log_container: VBoxContainer = $LogScroll/LogContainer

# 탐험 시작 버튼
@onready var explore_button: Button = $ExploreButton

# BottomNav
@onready var home_tab: Button = $BottomNav/HomeTab
@onready var cards_tab: Button = $BottomNav/CardsTab
@onready var upgrade_tab: Button = $BottomNav/UpgradeTab
@onready var progress_tab: Button = $BottomNav/ProgressTab
@onready var shop_tab: Button = $BottomNav/ShopTab

var tab_buttons: Array = []
var card_panels: Array = []
var card_buttons: Array = []

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	card_panels = [card1, card2, card3]
	card_buttons = [card1_button, card2_button, card3_button]
	tab_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	
	# Add CircleTransition
	circle_transition = CircleTransitionScene.instantiate()
	get_tree().root.add_child(circle_transition)
	
	apply_styles()
	setup_signals()
	
	# 초기 카드 숨기기 (덱에 있음)
	for card in card_panels:
		card.visible = false
		card.position = DECK_POS
	
	# 탐험 버튼 비활성화
	explore_button.disabled = true
	
	# 첫 로그 메시지
	add_log_message("무의식 : 당신에게 말을 건다", Color(1, 0.8, 0.5))
	
	# 카드 날리기 애니메이션 시작
	start_card_flying_animation()
	
	set_active_nav_tab(0)
	print("[RunPrep] 타로 카드 시스템 준비 완료")

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	background.color = UITheme.COLORS.bg
	
	# 타로 테이블 (갈색)
	table_bg.color = Color(0.55, 0.4, 0.25)  # 갈색
	
	# TopBar
	var top_bar_style = StyleBoxFlat.new()
	top_bar_style.bg_color = UITheme.COLORS.panel
	top_bar.add_theme_stylebox_override("panel", top_bar_style)
	
	title_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	
	# Buttons
	UITheme.apply_button_style(back_button, "primary")
	UITheme.apply_button_style(explore_button, "success")
	explore_button.add_theme_font_size_override("font_size", 20)
	
	# 타로 덱 스타일
	var deck_style = StyleBoxFlat.new()
	deck_style.bg_color = Color(0.3, 0.2, 0.4)  # 보라
	deck_style.corner_radius_top_left = 8
	deck_style.corner_radius_top_right = 8
	deck_style.corner_radius_bottom_left = 8
	deck_style.corner_radius_bottom_right = 8
	tarot_deck.add_theme_stylebox_override("panel", deck_style)
	
	# 타로 카드 스타일 (3장)
	for i in range(3):
		var card = card_panels[i]
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.8, 0.6, 0.9)  # 밝은 보라 (카드 뒷면)
		card_style.corner_radius_top_left = 8
		card_style.corner_radius_top_right = 8
		card_style.corner_radius_bottom_left = 8
		card_style.corner_radius_bottom_right = 8
		card_style.border_width_left = 3
		card_style.border_width_top = 3
		card_style.border_width_right = 3
		card_style.border_width_bottom = 3
		card_style.border_color = Color(0.4, 0.2, 0.5)
		card.add_theme_stylebox_override("panel", card_style)
		
		# 카드 뒤집힌 면 (흰색)
		var back_panel = card.get_node("BackPanel")
		var back_style = StyleBoxFlat.new()
		back_style.bg_color = Color(0.95, 0.95, 0.9)  # 흰색
		back_style.corner_radius_top_left = 6
		back_style.corner_radius_top_right = 6
		back_style.corner_radius_bottom_left = 6
		back_style.corner_radius_bottom_right = 6
		back_panel.add_theme_stylebox_override("panel", back_style)
		back_panel.visible = false
	
	# Tab buttons
	for button in tab_buttons:
		apply_tab_button_style(button)

func apply_tab_button_style(button: Button) -> void:
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UITheme.COLORS.panel
	button.add_theme_stylebox_override("normal", normal_style)
	
	button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)

# ─── 시그널 연결 ─────────────────────────────────────
func setup_signals() -> void:
	back_button.pressed.connect(_on_back_pressed)
	explore_button.pressed.connect(_on_explore_pressed)
	
	card1_button.pressed.connect(_on_card_clicked.bind(0))
	card2_button.pressed.connect(_on_card_clicked.bind(1))
	card3_button.pressed.connect(_on_card_clicked.bind(2))
	
	home_tab.pressed.connect(_on_nav_tab_pressed.bind(0))
	cards_tab.pressed.connect(_on_nav_tab_pressed.bind(1))
	upgrade_tab.pressed.connect(_on_nav_tab_pressed.bind(2))
	progress_tab.pressed.connect(_on_nav_tab_pressed.bind(3))
	shop_tab.pressed.connect(_on_nav_tab_pressed.bind(4))

# ─── 카드 날아오는 애니메이션 ────────────────────────
func start_card_flying_animation() -> void:
	current_animation = true
	
	# 3장의 카드를 순차적으로 날림
	for i in range(3):
		await get_tree().create_timer(0.5 * i).timeout
		fly_card(i)
	
	await get_tree().create_timer(1.5).timeout
	current_animation = false
	
	# 로그 메시지
	add_log_message("무의식 : 3개의 카드가 선택되었다", Color(1, 0.8, 0.5))

func fly_card(card_index: int) -> void:
	var card = card_panels[card_index]
	var target_pos = CARD_POSITIONS[card_index]
	
	card.visible = true
	card.position = DECK_POS
	card_states[card_index] = CardState.FLYING
	
	# Tween 애니메이션
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(card, "position", target_pos, 0.5)
	
	await tween.finished
	card_states[card_index] = CardState.PLACED

# ─── 카드 클릭 (뒤집기) ──────────────────────────────
func _on_card_clicked(card_index: int) -> void:
	if current_animation:
		return
	
	if card_states[card_index] != CardState.PLACED:
		return
	
	# 왼쪽부터 순서대로만 뒤집기 가능
	if card_index != cards_flipped:
		print("[RunPrep] 왼쪽 카드부터 순서대로 뒤집어주세요")
		return
	
	# 카드 뒤집기
	flip_card(card_index)

func flip_card(card_index: int) -> void:
	current_animation = true
	var card = card_panels[card_index]
	var front_label = card.get_node("FrontLabel")
	var back_panel = card.get_node("BackPanel")
	var back_title = back_panel.get_node("TitleLabel")
	
	# 뒤집기 애니메이션 (스케일 X)
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# 축소 → 0
	tween.tween_property(card, "scale:x", 0.0, 0.2)
	
	await tween.finished
	
	# 앞면 숨기고 뒷면 보이기
	front_label.visible = false
	back_panel.visible = true
	back_title.text = TAROT_TEXTS[card_index]["title"]
	
	# 확대 → 1
	var tween2 = create_tween()
	tween2.set_ease(Tween.EASE_IN_OUT)
	tween2.set_trans(Tween.TRANS_CUBIC)
	tween2.tween_property(card, "scale:x", 1.0, 0.2)
	
	await tween2.finished
	
	card_states[card_index] = CardState.FLIPPED
	cards_flipped += 1
	current_animation = false
	
	# 로그 메시지
	var tarot = TAROT_TEXTS[card_index]
	var log_color = [Color(0.8, 1, 0.6), Color(0.6, 0.8, 1), Color(1, 0.8, 0.6)][card_index]
	add_log_message("당신 : %s 카드가 선택되었다." % tarot["title"], log_color)
	add_log_message("아래구 저렇구 곰 %s" % tarot["title"], Color(0.6, 1, 0.6))
	add_log_message("당신 : %s." % tarot["description"], Color(0.9, 0.9, 0.9))
	
	# 3장 모두 뒤집으면 탐험 버튼 활성화
	if cards_flipped >= 3:
		explore_button.disabled = false

# ─── 로그 메시지 추가 ────────────────────────────────
func add_log_message(message: String, color: Color = Color.WHITE) -> void:
	log_messages.append(message)
	
	var label = Label.new()
	label.text = message
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 14)
	
	# 패딩 스타일
	var label_container = PanelContainer.new()
	var container_style = StyleBoxFlat.new()
	container_style.bg_color = Color(0.2, 0.2, 0.3, 0.8)
	container_style.corner_radius_top_left = 8
	container_style.corner_radius_top_right = 8
	container_style.corner_radius_bottom_left = 8
	container_style.corner_radius_bottom_right = 8
	container_style.content_margin_left = 12
	container_style.content_margin_right = 12
	container_style.content_margin_top = 8
	container_style.content_margin_bottom = 8
	label_container.add_theme_stylebox_override("panel", container_style)
	label_container.add_child(label)
	
	log_container.add_child(label_container)
	
	# 이전 메시지 흐리게
	fade_old_messages()
	
	# 스크롤 아래로
	await get_tree().process_frame
	log_scroll.scroll_vertical = int(log_scroll.get_v_scroll_bar().max_value)

func fade_old_messages() -> void:
	var children = log_container.get_children()
	var count = children.size()
	
	for i in range(count):
		var child = children[i]
		var label = child.get_child(0)
		
		# 최근 3개는 밝게, 나머지는 흐리게
		if i < count - 3:
			label.modulate = Color(1, 1, 1, 0.4)
		else:
			label.modulate = Color(1, 1, 1, 1.0)

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_back_pressed() -> void:
	print("[RunPrep] 뒤로 가기")
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")

func _on_explore_pressed() -> void:
	print("[RunPrep] 꿈 탐험 시작!")
	
	# Use circle transition to InRun_Combat (Combat 기반 통합)
	if circle_transition:
		await circle_transition.full_transition("res://ui/screens/InRun_v4.tscn")
	else:
		get_tree().change_scene_to_file("res://ui/screens/InRun_v4.tscn")

func _on_nav_tab_pressed(tab_index: int) -> void:
	set_active_nav_tab(tab_index)
	
	match tab_index:
		0:  # Home
			get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1:  # Cards
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[RunPrep] Upgrade (미구현)")
		3:  # Progress
			print("[RunPrep] Progress (미구현)")
		4:  # Shop
			get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")

func set_active_nav_tab(tab_index: int) -> void:
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		if i == tab_index:
			button.add_theme_color_override("font_color", UITheme.COLORS.text)
		else:
			button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
