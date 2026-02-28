# InRun_v2.gd
# 런 진행 화면 - 자동 진행 시스템
# 시간별 이벤트 + 캐릭터 등장 + 말풍선

extends Control

# ─── 자동 진행 설정 ─────────────────────────────────
const TIME_PER_NODE = 3.0  # 각 노드까지 3초 (테스트용, 실제는 더 길게)
const EVENT_DELAY = 1.0    # 이벤트 발생 전 딜레이

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect = $Background
@onready var run_progress_bar = $RunProgressBar
@onready var character_sprite: Label = $CharacterDisplay/CharacterSprite
@onready var speech_bubble = $CharacterDisplay/SpeechBubble
@onready var event_log = $EventLog

# ─── 런 상태 ─────────────────────────────────────────
var current_time: String = "PM 10:00"
var current_node_index: int = 0
var auto_progress_timer: float = 0.0
var is_paused: bool = false

# 노드 데이터
var nodes: Array = [
	{"id": 1, "type": "Start", "icon": "💤", "time": "PM 10:00", "event": "슬립"},
	{"id": 2, "type": "Memory", "icon": "💎", "time": "PM 11:00", "event": "꿈세계 진입"},
	{"id": 3, "type": "Combat", "icon": "⚔️", "time": "AM 12:00", "event": "약탈 - 전투 발생"},
	{"id": 4, "type": "Shop", "icon": "🛒", "time": "AM 1:00", "event": "상점 발견"},
	{"id": 5, "type": "Event", "icon": "❓", "time": "AM 2:00", "event": "수상한 소리"},
	{"id": 6, "type": "Combat", "icon": "⚔️", "time": "AM 3:00", "event": "전투 발생"},
	{"id": 7, "type": "Boss", "icon": "👹", "time": "AM 4:00", "event": "보스 등장"}
]

# 이벤트별 캐릭터 스프라이트
var character_sprites = {
	"Start": "💤",
	"Memory": "💎",
	"Combat": "👾",
	"Shop": "🧝",  # 🧙 → 🧝 NPC로 변경
	"Event": "🧝",
	"Boss": "👹"
}

# 이벤트별 메시지
var event_messages = {
	"Start": "잠에 빠져든다...",
	"Memory": "추억이 떠오른다",
	"Combat": "전투 발생!",
	"Shop": "무언가를 발견했다!",  # "어서오세요~" → 이벤트 메시지로 변경
	"Event": "무슨 일이지?",
	"Boss": "최종 보스다!"
}

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_initial_state()
	start_auto_progress()

func apply_styles() -> void:
	background.color = Color(0.15, 0.15, 0.25)  # 어두운 보라
	
	# Character sprite
	character_sprite.add_theme_font_size_override("font_size", 120)
	character_sprite.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	character_sprite.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

func setup_initial_state() -> void:
	# Initialize progress bar
	# Mark first 2 nodes as completed
	for i in range(2):
		nodes[i]["completed"] = true
		nodes[i]["current"] = false
	
	# Current node is 3rd (index 2)
	current_node_index = 2
	nodes[current_node_index]["current"] = true
	
	run_progress_bar.set_nodes(nodes, current_node_index)
	
	# Initialize event log
	event_log.add_log(nodes[0]["time"], nodes[0]["event"], false)
	event_log.add_log(nodes[1]["time"], nodes[1]["event"], false)
	event_log.add_log(nodes[2]["time"], nodes[2]["event"], true)  # Current
	
	# Show current character
	update_character_display()

# ─── 자동 진행 시작 ──────────────────────────────────
func start_auto_progress() -> void:
	is_paused = false
	auto_progress_timer = 0.0

# ─── 매 프레임 업데이트 ──────────────────────────────
func _process(delta: float) -> void:
	if is_paused:
		return
	
	# Auto progress timer
	auto_progress_timer += delta
	
	# Update progress line (visual feedback)
	var progress = auto_progress_timer / TIME_PER_NODE
	# TODO: Update progress bar's yellow line smoothly
	
	# Check if time to advance
	if auto_progress_timer >= TIME_PER_NODE:
		advance_to_next_node()

# ─── 다음 노드로 진행 ────────────────────────────────
func advance_to_next_node() -> void:
	auto_progress_timer = 0.0
	
	# Mark current as completed
	nodes[current_node_index]["completed"] = true
	nodes[current_node_index]["current"] = false
	
	# Move to next node
	current_node_index += 1
	
	if current_node_index >= nodes.size():
		# Run completed!
		print("[InRun] 런 완료!")
		is_paused = true
		speech_bubble.show_message("꿈이 끝났다...", 0.0)
		# TODO: Show victory screen
		return
	
	# Set new current node
	nodes[current_node_index]["current"] = true
	
	# Update UI
	run_progress_bar.set_current_node(current_node_index)
	
	var node = nodes[current_node_index]
	event_log.add_log(node["time"], node["event"], true)
	
	# Update character
	update_character_display()
	
	# Trigger event
	await get_tree().create_timer(EVENT_DELAY).timeout
	trigger_event(node)

# ─── 캐릭터 디스플레이 업데이트 ──────────────────────
func update_character_display() -> void:
	var node = nodes[current_node_index]
	var node_type = node["type"]
	
	# Change character sprite
	character_sprite.text = character_sprites.get(node_type, "❓")
	
	# Show speech bubble
	var message = event_messages.get(node_type, "...")
	speech_bubble.show_message(message, 2.0)

# ─── 이벤트 트리거 ───────────────────────────────────
func trigger_event(node: Dictionary) -> void:
	match node["type"]:
		"Combat":
			print("[InRun] 전투 시작!")
			is_paused = true
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://ui/screens/Combat.tscn")
		
		"Shop":
			# Shop은 이제 NPC 이벤트로 처리 (상점으로 보내지 않음)
			print("[InRun] NPC 이벤트 (상점 발견): %s" % node["event"])
			# Continue auto progress
		
		"Boss":
			print("[InRun] 보스 전투!")
			is_paused = true
			await get_tree().create_timer(1.0).timeout
			get_tree().change_scene_to_file("res://ui/screens/Combat.tscn")
		
		"Event", "Memory":
			# Auto-resolve (no player input)
			print("[InRun] 자동 이벤트: %s" % node["event"])
			# Continue auto progress
		
		_:
			# Unknown, continue
			pass

# ─── 치트 코드 ───────────────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_SPACE:
				# Toggle pause
				is_paused = !is_paused
				print("[InRun] Pause: %s" % is_paused)
			
			KEY_N:
				# Skip to next node
				if not is_paused:
					auto_progress_timer = TIME_PER_NODE
					print("[InRun] Skip to next node")
