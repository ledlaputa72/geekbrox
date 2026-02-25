extends Control

"""
InRun_v4 - Unified In-Run Screen with Dynamic BottomArea
통합 인런 화면 (Portrait 390×844)

Architecture:
- TopArea (280px): Hero (영구 유지) + Characters (Monster/NPC, 등장 애니메이션)
- BottomArea (564px): 동적 UI 컨테이너 (iframe 패턴)

Key Features:
- Hero: 모든 모드에서 동일 오브젝트 유지 (삭제 안 함)
- Background: Exploration 시 자동 스크롤
- Characters: 화면 오른쪽 밖에서 fly-in 애니메이션
- Reward Modal: 전투 보상을 모달로 표시 (전체 화면 전환 X)
- CharacterNode: 공용 컴포넌트 (Hero/Monster/NPC 모두 동일)
"""

# UI References
@onready var top_area = $TopArea
@onready var battle_scene = $TopArea/BattleScene
@onready var background = $TopArea/BattleScene/BattleSceneBg
@onready var hero_area = $TopArea/BattleScene/HeroArea
@onready var character_area = $TopArea/BattleScene/CharacterArea
@onready var bottom_area = $BottomArea
@onready var reward_modal = $RewardModal

# Current state
enum ScreenState {
	EXPLORATION,
	COMBAT,
	SHOP,
	NPC_DIALOG,
	STORY
}

var current_state: ScreenState = ScreenState.EXPLORATION
var current_bottom_ui: BaseBottomUI = null

# Characters
var hero_node: CharacterNode = null  # 영구 유지
var character_nodes: Array[CharacterNode] = []  # 재사용 풀

# Background scroll
var background_scroll_offset: float = 0.0
var background_scroll_speed: float = 30.0  # px/s
var is_scrolling: bool = false

# BottomUI scene paths
const BOTTOM_UI_PATHS = {
	ScreenState.EXPLORATION: "res://ui/bottom_uis/ExplorationBottomUI.tscn",
	ScreenState.COMBAT: "res://ui/bottom_uis/CombatBottomUI.tscn",
	ScreenState.SHOP: "res://ui/bottom_uis/ShopBottomUI.tscn",
	ScreenState.NPC_DIALOG: "res://ui/bottom_uis/NPCDialogBottomUI.tscn",
	ScreenState.STORY: "res://ui/bottom_uis/StoryBottomUI.tscn"
}

func _ready():
	print("\n\n")
	print("=".repeat(60))
	print("🚀🚀🚀 InRun_v4 LOADED - VERSION 2.0 🚀🚀🚀")
	print("=".repeat(60))
	print("\n")
	
	_create_hero_permanent()
	_apply_theme_styles()
	_setup_reward_modal()
	
	# Start with exploration mode
	switch_to_exploration()

func _process(delta):
	# Background scrolling (Exploration mode)
	if is_scrolling:
		background_scroll_offset += background_scroll_speed * delta
		# Wrap around every 390px (screen width)
		if background_scroll_offset >= 390:
			background_scroll_offset -= 390
		
		# Update background position (shader or material offset if available)
		# For now, just use modulate flicker as placeholder
		# TODO: Replace with actual texture scroll

func _apply_theme_styles():
	"""Apply UITheme styles"""
	pass

func _setup_reward_modal():
	"""Setup reward modal signals"""
	if reward_modal:
		reward_modal.reward_claimed.connect(_on_reward_claimed)

# === TopArea Character Management ===

func _create_hero_permanent():
	"""Create hero once (영구 유지)"""
	print("[InRun_v4] Creating permanent hero...")
	var CharacterNodeScene = preload("res://ui/components/CharacterNode.tscn")
	hero_node = CharacterNodeScene.instantiate()
	hero_node.setup({
		"type": "hero",
		"name": "Hero",
		"hp": 80,
		"max_hp": 80,
		"emoji": "👤",
		"color": Color(0.48, 0.62, 0.94, 1)  # Blue
	})
	hero_node.position = Vector2(10, 80)  # Left side, centered
	hero_area.add_child(hero_node)
	
	hero_node.character_clicked.connect(_on_hero_clicked)
	print("[InRun_v4] ✅ Hero created at position: %s" % hero_node.position)

func _get_or_create_character_node() -> CharacterNode:
	"""Get available character node from pool or create new"""
	# Find invisible (unused) node
	for node in character_nodes:
		if not node.visible:
			return node
	
	# Create new node
	var CharacterNodeScene = preload("res://ui/components/CharacterNode.tscn")
	var node = CharacterNodeScene.instantiate()
	character_area.add_child(node)
	character_nodes.append(node)
	node.character_clicked.connect(_on_character_clicked)
	return node

func _spawn_monsters(monster_count: int = 4):
	"""Spawn monsters with fly-in animation"""
	# Monster positions (2x2 grid with depth offset)
	var positions = [
		Vector2(200, 120),  # Front-left
		Vector2(250, 60),   # Back-left
		Vector2(280, 120),  # Front-right
		Vector2(330, 60)    # Back-right
	]
	var z_indices = [10, 5, 10, 5]
	var emojis = ["👾", "👹", "👾", "👹"]
	var colors = [
		Color(0.8, 0.3, 0.3),
		Color(0.3, 0.8, 0.3),
		Color(0.8, 0.3, 0.3),
		Color(0.3, 0.8, 0.3)
	]
	
	var test_monsters = _get_test_monsters()
	
	for i in range(min(monster_count, 4)):
		var node = _get_or_create_character_node()
		var monster_data = test_monsters[i] if i < test_monsters.size() else {}
		
		node.setup({
			"type": "monster",
			"id": "monster_%d" % i,
			"name": monster_data.get("name", "Monster%d" % (i + 1)),
			"hp": monster_data.get("hp", 20),
			"max_hp": monster_data.get("max_hp", 20),
			"emoji": emojis[i],
			"color": colors[i]
		})
		node.z_index = z_indices[i]
		node.set_hp_bar_visible(true)
		
		# Fly-in animation (staggered)
		await get_tree().create_timer(i * 0.1).timeout
		node.fly_in_from_right(positions[i], 0.5)

func _spawn_npc(npc_name: String = "NPC", emoji_icon: String = "🧙"):
	"""Spawn single NPC with fly-in animation"""
	var node = _get_or_create_character_node()
	
	node.setup({
		"type": "npc",
		"id": "npc_main",
		"name": npc_name,
		"hp": 100,
		"max_hp": 100,
		"emoji": emoji_icon,
		"color": Color(0.7, 0.5, 0.9)  # Purple
	})
	node.z_index = 10
	node.set_hp_bar_visible(false)  # NPCs don't show HP
	
	# Fly-in animation
	node.fly_in_from_right(Vector2(255, 80), 0.5)

func _despawn_all_characters():
	"""Hide all characters (monsters/NPCs) - 재사용을 위해 삭제 안 함"""
	for node in character_nodes:
		if node.visible:
			node.fly_out_to_right(0.3)

# === BottomArea Dynamic UI Management ===

func _switch_bottom_ui(scene_path: String):
	"""Switch BottomArea UI (iframe pattern)"""
	print("[InRun_v4] Switching BottomUI to: %s" % scene_path)
	
	# Exit previous UI
	if current_bottom_ui:
		print("[InRun_v4] Exiting previous UI")
		current_bottom_ui._on_exit()
		current_bottom_ui.queue_free()
		current_bottom_ui = null
	
	# Load new UI
	print("[InRun_v4] Loading scene...")
	var scene = load(scene_path)
	if not scene:
		push_error("[InRun_v4] ❌ FAILED to load BottomUI: %s" % scene_path)
		print("[InRun_v4] ❌ Scene is null!")
		return
	
	print("[InRun_v4] ✅ Scene loaded successfully")
	print("[InRun_v4] Instantiating scene...")
	current_bottom_ui = scene.instantiate()
	
	if not current_bottom_ui:
		push_error("[InRun_v4] ❌ FAILED to instantiate BottomUI")
		return
	
	print("[InRun_v4] ✅ Scene instantiated")
	print("[InRun_v4] Adding to BottomArea...")
	bottom_area.add_child(current_bottom_ui)
	
	print("[InRun_v4] ✅ BottomUI added to scene tree")
	
	# Connect signals
	current_bottom_ui.ui_action_requested.connect(_on_bottom_ui_action)
	current_bottom_ui.ui_closed.connect(_on_bottom_ui_closed)
	
	# Enter new UI
	current_bottom_ui._on_enter()
	current_bottom_ui.ui_ready.emit()
	
	print("[InRun_v4] ✅ BottomUI switch complete!")

func _on_bottom_ui_action(action_type: String, data: Dictionary):
	"""Handle action from BottomUI"""
	print("[InRun_v4] UI Action: %s | Data: %s" % [action_type, data])
	
	match action_type:
		# Combat actions
		"card_played":
			CombatManager.play_card(data.get("card_index", -1), data.get("target", -1))
		"pass":
			print("Player passed.")
		"auto_toggle":
			CombatManager.toggle_auto_battle()
		"speed_change":
			CombatManager.set_speed_multiplier(data.get("speed", 1.0))
		
		# Shop actions
		"shop_purchase":
			var item_id = data.get("item_id", "")
			var price = data.get("price", 0)
			if GameManager.spend_gold(price):
				print("[InRun_v4] Purchased: %s for 🪙%d" % [item_id, price])
				# TODO: Add item to inventory
			else:
				print("[InRun_v4] Purchase failed: Not enough gold!")
		
		# NPC actions
		"npc_choice":
			_handle_npc_choice(data.get("choice_index", -1))
		
		# Navigation
		"leave":
			_return_to_exploration()

func _on_bottom_ui_closed():
	"""Handle BottomUI close request"""
	_return_to_exploration()

func _handle_npc_choice(choice_index: int):
	"""Handle NPC dialog choice"""
	print("NPC choice selected: %d" % choice_index)
	# TODO: Implement choice logic

func _return_to_exploration():
	"""Return to exploration mode"""
	_despawn_all_characters()
	await get_tree().create_timer(0.4).timeout  # Wait for fly-out animation
	switch_to_exploration()

# === State Switching Functions ===

func switch_to_exploration():
	"""Switch to exploration mode"""
	print("\n[InRun_v4] ===== SWITCHING TO EXPLORATION =====")
	current_state = ScreenState.EXPLORATION
	is_scrolling = true  # Start background scrolling
	
	# Clear all characters
	_despawn_all_characters()
	
	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.EXPLORATION])
	print("[InRun_v4] ===== EXPLORATION SWITCH COMPLETE =====\n")

func switch_to_combat():
	"""Switch to combat mode"""
	print("\n[InRun_v4] ===== SWITCHING TO COMBAT =====")
	current_state = ScreenState.COMBAT
	is_scrolling = false  # Stop background scrolling
	
	print("[InRun_v4] Loading CombatBottomUI...")
	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.COMBAT])
	
	# Wait a frame for BottomUI to be ready
	await get_tree().process_frame
	
	print("[InRun_v4] Spawning monsters...")
	# Spawn monsters with animation (await to wait for all animations)
	await _spawn_monsters(4)
	
	print("[InRun_v4] Starting combat...")
	var monsters = _get_test_monsters()
	CombatManager.start_combat(monsters)
	
	# Connect combat end signal
	if not CombatManager.combat_ended.is_connected(_on_combat_ended):
		CombatManager.combat_ended.connect(_on_combat_ended)
	
	print("[InRun_v4] ===== COMBAT SWITCH COMPLETE =====\n")

func switch_to_shop():
	"""Switch to shop mode"""
	print("\n[InRun_v4] ===== SWITCHING TO SHOP =====")
	current_state = ScreenState.SHOP
	is_scrolling = false
	
	# Clear monsters first
	print("[InRun_v4] Despawning monsters...")
	_despawn_all_characters()
	
	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.SHOP])
	
	# Wait a frame
	await get_tree().process_frame
	
	# Spawn merchant NPC
	print("[InRun_v4] Spawning merchant...")
	_spawn_npc("Merchant", "🧙")
	
	print("[InRun_v4] ===== SHOP SWITCH COMPLETE =====\n")

func switch_to_npc_dialog(npc_name: String = "NPC", emoji: String = "🧝"):
	"""Switch to NPC dialog mode"""
	print("\n[InRun_v4] ===== SWITCHING TO NPC_DIALOG =====")
	current_state = ScreenState.NPC_DIALOG
	is_scrolling = false
	
	# Clear previous characters
	_despawn_all_characters()
	
	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.NPC_DIALOG])
	
	# Wait a frame
	await get_tree().process_frame
	
	# Spawn NPC
	print("[InRun_v4] Spawning NPC...")
	_spawn_npc(npc_name, emoji)
	
	print("[InRun_v4] ===== NPC_DIALOG SWITCH COMPLETE =====\n")

func switch_to_story():
	"""Switch to story mode"""
	print("\n[InRun_v4] ===== SWITCHING TO STORY =====")
	current_state = ScreenState.STORY
	is_scrolling = false
	
	# Clear all characters (Story mode has no characters)
	_despawn_all_characters()
	
	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.STORY])
	
	print("[InRun_v4] ===== STORY SWITCH COMPLETE =====\n")

# === Combat End Handler ===

func _on_combat_ended(victory: bool):
	"""Handle combat end - show reward modal instead of full screen"""
	print("[InRun_v4] Combat ended: %s" % ("Victory" if victory else "Defeat"))
	
	# Despawn monsters with fly-out
	_despawn_all_characters()
	
	# Wait for animation
	await get_tree().create_timer(0.4).timeout
	
	# Show reward modal
	if victory:
		var rewards = [
			"🪙 Gold: +50",
			"⚡ Energy Restored",
			"🎴 New Card: Flame Strike"
		]
		reward_modal.show_victory(rewards)
	else:
		reward_modal.show_defeat()

func _on_reward_claimed():
	"""Reward modal closed - return to exploration"""
	print("[InRun_v4] Reward claimed, returning to exploration")
	_return_to_exploration()

# === Character Click Handlers ===

func _on_hero_clicked(character_node: CharacterNode):
	"""Hero clicked"""
	print("Hero clicked: HP %d/%d" % [character_node.current_hp, character_node.max_hp])

func _on_character_clicked(character_node: CharacterNode):
	"""Monster/NPC clicked"""
	print("%s clicked: %s (HP %d/%d)" % [
		character_node.character_type.capitalize(),
		character_node.character_name,
		character_node.current_hp,
		character_node.max_hp
	])

# === Test Data ===

func _get_test_monsters() -> Array:
	"""Get test monsters for combat"""
	return [
		{"name": "Slime1", "hp": 20, "max_hp": 20, "atk": 3, "def": 1, "spd": 8, "eva": 5},
		{"name": "Slime2", "hp": 15, "max_hp": 15, "atk": 5, "def": 0, "spd": 12, "eva": 10},
		{"name": "Goblin1", "hp": 12, "max_hp": 12, "atk": 4, "def": 0, "spd": 15, "eva": 15},
		{"name": "Goblin2", "hp": 18, "max_hp": 18, "atk": 6, "def": 2, "spd": 10, "eva": 8}
	]

# === Input Handling (Cheat Keys) ===

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				switch_to_exploration()
			KEY_2:
				switch_to_combat()
			KEY_3:
				switch_to_shop()
			KEY_4:
				switch_to_npc_dialog()
			KEY_5:
				switch_to_story()
