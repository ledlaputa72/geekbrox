# InRun_Combat.gd
# 꿈 탐험 + 전투 통합 화면
# Combat.gd 기반, 탐험/전투 모드 전환 가능

extends Control

# ═══════════════════════════════════════════════════════
# 화면 모드
# ═══════════════════════════════════════════════════════
enum Mode { EXPLORATION, COMBAT }
var current_mode: Mode = Mode.EXPLORATION

# ═══════════════════════════════════════════════════════
# 탐험 모드 설정
# ═══════════════════════════════════════════════════════
const TIME_PER_HOUR = 1.0
const BACKGROUND_SCROLL_SPEED = 50.0
const CHARACTER_WALK_SPEED = 3.0
const CHARACTER_WALK_AMPLITUDE = 5.0

var current_node_index: int = 0
var auto_progress_timer: float = 0.0
var is_exploration_paused: bool = false
var background_offset: float = 0.0
var time_per_node: float = 0.0

var nodes: Array = [
	{"id": 1, "type": "Start", "icon": "💤", "time": "PM 10:00", "event": "슬립"},
	{"id": 2, "type": "Memory", "icon": "💎", "time": "PM 11:00", "event": "꿈세계 진입"},
	{"id": 3, "type": "Combat", "icon": "⚔️", "time": "AM 12:00", "event": "약탈 - 전투 발생"},
	{"id": 4, "type": "Shop", "icon": "🛒", "time": "AM 1:00", "event": "상점 발견"},
	{"id": 5, "type": "Event", "icon": "❓", "time": "AM 2:00", "event": "수상한 소리"},
	{"id": 6, "type": "Combat", "icon": "⚔️", "time": "AM 3:00", "event": "전투 발생"},
	{"id": 7, "type": "Boss", "icon": "👹", "time": "AM 4:00", "event": "보스 등장"}
]

# ═══════════════════════════════════════════════════════
# UI 노드 참조 (Combat 기반)
# ═══════════════════════════════════════════════════════
@onready var run_progress_bar = $RunProgressBar

@onready var hero_hp_bar = $BattleScene/HeroArea/HeroHPBar
@onready var hero_hp_label = $BattleScene/HeroArea/HeroHPLabel
@onready var hero_atb_bar = $BattleScene/HeroArea/HeroATBBar
@onready var hero_energy_label = $TopBar/HeroEnergy

@onready var monster1 = $BattleScene/MonsterArea/Monster1
@onready var monster2 = $BattleScene/MonsterArea/Monster2
@onready var monster3 = null
@onready var monster4 = null

@onready var log_content = $CombatLog/ScrollContainer/LogContent

@onready var end_turn_button = $ActionButtons/ButtonsContainer/EndTurnButton
@onready var auto_button = $ActionButtons/ButtonsContainer/AutoButton
@onready var menu_button = $ActionButtons/ButtonsContainer/MenuButton

var monster_nodes = []
var energy_orb: Control
var deck_label: Label
var discard_label: Label
var exile_label: Label
var hand_container: Control

# 탐험 모드 전용 노드 (동적 생성)
var exploration_bg: ColorRect
var exploration_character: Label

# ═══════════════════════════════════════════════════════
# 초기화
# ═══════════════════════════════════════════════════════
func _ready():
	_create_exploration_layer()
	_setup_monsters_horizontal()
	_apply_theme_styles()
	_setup_buttons()
	
	# 탐험 모드로 시작
	time_per_node = TIME_PER_HOUR
	_init_exploration_state()
	switch_to_exploration()
	
	print("[InRun] 꿈 탐험 시작 (Combat 통합)")

# ═══════════════════════════════════════════════════════
# 탐험 레이어 생성
# ═══════════════════════════════════════════════════════
func _create_exploration_layer():
	"""BattleScene 위에 탐험 레이어 추가"""
	var battle_scene = $BattleScene
	
	# 배경 스크롤
	exploration_bg = ColorRect.new()
	exploration_bg.name = "ExplorationBG"
	exploration_bg.custom_minimum_size = Vector2(800, 280)
	exploration_bg.size = Vector2(800, 280)
	exploration_bg.color = Color(0.2, 0.5, 0.3)
	exploration_bg.z_index = -1
	battle_scene.add_child(exploration_bg)
	
	# 캐릭터
	exploration_character = Label.new()
	exploration_character.name = "ExplorationCharacter"
	exploration_character.text = "👤"
	exploration_character.custom_minimum_size = Vector2(120, 120)
	exploration_character.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	exploration_character.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	exploration_character.add_theme_font_size_override("font_size", 96)
	exploration_character.position = Vector2(40, 80)
	battle_scene.add_child(exploration_character)

func _init_exploration_state():
	"""탐험 상태 초기화"""
	for node in nodes:
		node["completed"] = false
		node["current"] = false
	
	current_node_index = 0
	nodes[current_node_index]["current"] = true
	
	run_progress_bar.set_nodes(nodes, current_node_index)
	_update_exploration_display()

# ═══════════════════════════════════════════════════════
# 모드 전환
# ═══════════════════════════════════════════════════════
func switch_to_exploration():
	"""탐험 모드로 전환"""
	current_mode = Mode.EXPLORATION
	
	# 탐험 레이어 표시
	exploration_bg.visible = true
	exploration_character.visible = true
	
	# 전투 요소 숨기기
	$BattleScene/HeroArea.visible = false
	$BattleScene/MonsterArea.visible = false
	$CombatLog.visible = false
	
	# 하단 버튼 변경
	end_turn_button.text = "⏩ Skip"
	auto_button.text = "🤖 Auto"
	
	print("[InRun] → 탐험 모드")

func switch_to_combat():
	"""전투 모드로 전환"""
	current_mode = Mode.COMBAT
	
	# 탐험 레이어 숨기기
	exploration_bg.visible = false
	exploration_character.visible = false
	
	# 전투 요소 표시
	$BattleScene/HeroArea.visible = true
	$BattleScene/MonsterArea.visible = true
	$CombatLog.visible = true
	
	# 전투 초기화
	_create_energy_and_deck_ui()
	_initialize_combat()
	
	# 버튼 복구
	end_turn_button.text = "Pass"
	auto_button.text = "🤖 Auto"
	
	print("[InRun] → 전투 모드")

# ═══════════════════════════════════════════════════════
# 매 프레임 업데이트
# ═══════════════════════════════════════════════════════
func _process(delta: float) -> void:
	if current_mode == Mode.EXPLORATION:
		_process_exploration(delta)
	elif current_mode == Mode.COMBAT:
		_process_combat(delta)

func _process_exploration(delta: float) -> void:
	"""탐험 모드 업데이트"""
	if is_exploration_paused:
		return
	
	# 배경 스크롤
	background_offset += BACKGROUND_SCROLL_SPEED * delta
	if background_offset >= 400:
		background_offset -= 400
	exploration_bg.position.x = -background_offset
	
	# 캐릭터 걷기
	var walk_offset = sin(Time.get_ticks_msec() * CHARACTER_WALK_SPEED * 0.001) * CHARACTER_WALK_AMPLITUDE
	exploration_character.position.y = 80 + walk_offset
	
	# 자동 진행
	auto_progress_timer += delta
	var progress_ratio = auto_progress_timer / time_per_node
	run_progress_bar.update_progress_smooth(progress_ratio)
	
	if auto_progress_timer >= time_per_node:
		_advance_to_next_node()

func _process_combat(delta: float) -> void:
	"""전투 모드 업데이트 (기존 Combat 로직)"""
	# TODO: Combat 로직 추가
	pass

# ═══════════════════════════════════════════════════════
# 탐험 진행
# ═══════════════════════════════════════════════════════
func _update_exploration_display():
	"""탐험 디스플레이 업데이트"""
	var node = nodes[current_node_index]
	
	# TopBar 업데이트
	$TopBar/PlayerName.text = node["time"]
	$TopBar/HeroHP.text = node["event"]
	
	# 캐릭터 변경
	var char_map = {
		"Start": "💤", "Memory": "💎", "Combat": "👾",
		"Shop": "🧝", "Event": "🧝", "Boss": "👹"
	}
	exploration_character.text = char_map.get(node["type"], "❓")

func _advance_to_next_node():
	"""다음 노드로 진행"""
	auto_progress_timer = 0.0
	
	nodes[current_node_index]["completed"] = true
	nodes[current_node_index]["current"] = false
	
	current_node_index += 1
	
	if current_node_index >= nodes.size():
		print("[InRun] 런 완료!")
		is_exploration_paused = true
		return
	
	nodes[current_node_index]["current"] = true
	run_progress_bar.set_current_node(current_node_index)
	_update_exploration_display()
	
	var node = nodes[current_node_index]
	await get_tree().create_timer(0.5).timeout
	_trigger_event(node)

func _trigger_event(node: Dictionary):
	"""이벤트 트리거"""
	match node["type"]:
		"Combat", "Boss":
			print("[InRun] 전투 발생!")
			is_exploration_paused = true
			await get_tree().create_timer(1.0).timeout
			switch_to_combat()
		_:
			print("[InRun] 자동 이벤트: %s" % node["event"])

# ═══════════════════════════════════════════════════════
# Combat 기존 함수들 (복사)
# ═══════════════════════════════════════════════════════
func _setup_monsters_horizontal():
	"""4 monsters in 2x2 grid"""
	var hero_atb = $BattleScene/HeroArea/HeroATBBar
	if hero_atb:
		hero_atb.visible = false
	
	var m1_atb = monster1.get_node_or_null("ATBBar")
	if m1_atb:
		m1_atb.visible = false
	
	var m2_atb = monster2.get_node_or_null("ATBBar")
	if m2_atb:
		m2_atb.visible = false

func _apply_theme_styles():
	UISprites.apply_btn(end_turn_button, "primary")
	UISprites.apply_btn(auto_button, "green")
	UISprites.apply_btn(menu_button, "secondary")

func _setup_buttons():
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	auto_button.pressed.connect(_on_auto_pressed)
	menu_button.pressed.connect(_on_menu_pressed)

func _create_energy_and_deck_ui():
	"""전투 UI 생성 (필요 시만)"""
	if energy_orb:
		return  # Already created
	
	# TODO: Energy UI 생성

func _initialize_combat():
	"""전투 초기화"""
	# TODO: CombatManager 연결

func _on_end_turn_pressed():
	if current_mode == Mode.EXPLORATION:
		# Skip
		auto_progress_timer = time_per_node
	else:
		# End Turn
		pass

func _on_auto_pressed():
	pass

func _on_menu_pressed():
	pass

# ═══════════════════════════════════════════════════════
# 치트 키
# ═══════════════════════════════════════════════════════
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				is_exploration_paused = !is_exploration_paused
			KEY_N:
				auto_progress_timer = time_per_node
			KEY_1:
				switch_to_exploration()
			KEY_2:
				switch_to_combat()
