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
@onready var top_bar = $TopBar
@onready var settings_button = $TopBar/HBox/LeftPanel/SettingsButton
@onready var run_progress_bar = $TopBar/HBox/RightPanel/RunProgressBar
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
	
	_setup_top_bar()
	_setup_progress_bar()
	_create_hero_permanent()
	_apply_theme_styles()
	_setup_reward_modal()
	
	# Start with exploration mode
	switch_to_exploration()

func _setup_top_bar():
	"""Setup TopBar with Settings + Progress Bar"""
	# TopBar background style (dark)
	var top_bar_style = StyleBoxFlat.new()
	top_bar_style.bg_color = Color(0.15, 0.15, 0.25, 1)  # Dark purple
	top_bar_style.border_width_bottom = 2
	top_bar_style.border_color = UITheme.COLORS.primary
	top_bar.add_theme_stylebox_override("panel", top_bar_style)
	
	# Settings button
	UITheme.apply_button_style(settings_button, "primary")
	settings_button.pressed.connect(_on_settings_pressed)

func _setup_progress_bar():
	"""Setup RunProgressBar with dream nodes from GameManager"""
	var nodes = []
	
	# Check if dream nodes exist in GameManager
	if GameManager.get_total_node_count() > 0:
		# Use dream nodes from card selection
		var dream_nodes = GameManager.get_dream_nodes()
		
		# Add start node
		nodes.append({
			"type": "start",
			"icon": "🚩",
			"text": "꿈 속으로 들어섰다...",
			"current": true,
			"completed": false
		})
		
		# Convert dream nodes to progress bar format
		for node_data in dream_nodes:
			var text = ""
			match node_data.type:
				"combat":
					text = "전투가 시작된다!"
				"shop":
					text = "상점을 발견했다!"
				"npc":
					text = "누군가와 마주쳤다..."
				"narration":
					text = "이야기가 펼쳐진다..."
				"boss":
					text = "보스가 나타났다!"
			
			nodes.append({
				"type": node_data.type,
				"icon": node_data.icon,
				"text": text,
				"current": false,
				"completed": false
			})
		
		print("[InRun_v4] Loaded %d dream nodes from GameManager" % dream_nodes.size())
	else:
		# Fallback to mock nodes if no dream cards selected
		print("[InRun_v4] No dream cards found, using mock nodes")
		nodes = [
			{"type": "start", "icon": "🚩", "text": "꿈 속으로 들어섰다...", "current": true, "completed": false},
			{"type": "combat", "icon": "⚔️", "text": "슬림 무리 발견!", "current": false, "completed": false},
			{"type": "shop", "icon": "🛒", "text": "신비한 상점 발견!", "current": false, "completed": false},
			{"type": "boss", "icon": "💀", "text": "악몽의 주인 등장!", "current": false, "completed": false}
		]
	
	run_progress_bar.set_nodes(nodes, 0)  # Start at first node
	
	# Connect signals
	run_progress_bar.node_reached.connect(_on_node_reached)
	run_progress_bar.run_completed.connect(_on_run_completed)
	
	print("[InRun_v4] RunProgressBar initialized with %d nodes" % nodes.size())

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
		# Exploration event triggered (from time log)
		"event_triggered":
			_handle_time_log_event(data)
		
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

func _handle_time_log_event(event_data: Dictionary):
	"""Handle event triggered from time log"""
	print("[InRun_v4] Time log event: %s" % event_data.event_type)
	
	# Pause exploration log progression
	if current_bottom_ui and current_bottom_ui.has_method("set_paused"):
		current_bottom_ui.set_paused(true)
	
	# Trigger appropriate event based on type
	match event_data.event_type:
		"combat":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(0.5).timeout
			switch_to_combat()
		"shop":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(0.5).timeout
			switch_to_shop()
		"npc":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(0.5).timeout
			switch_to_npc_dialog()
		"narration":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(0.5).timeout
			switch_to_story()
		"boss":
			run_progress_bar.pause_progress()
			await get_tree().create_timer(1.0).timeout  # Longer for drama
			switch_to_combat()  # Boss combat

func _handle_npc_choice(choice_index: int):
	"""Handle NPC dialog choice"""
	print("NPC choice selected: %d" % choice_index)
	# TODO: Implement choice logic

func _return_to_exploration():
	"""Return to exploration mode"""
	_despawn_all_characters()
	await get_tree().create_timer(0.4).timeout  # Wait for fly-out animation
	switch_to_exploration()
	
	# Resume log progression
	if current_bottom_ui and current_bottom_ui.has_method("resume"):
		current_bottom_ui.resume()
	
	# Resume auto-progress
	if run_progress_bar:
		run_progress_bar.resume_progress()

# === RunProgressBar Handlers ===

func _on_node_reached(node_index: int, node_data: Dictionary):
	"""Handle node arrival - auto process based on node type"""
	print("[InRun_v4] Node reached: ", node_index, " - ", node_data)
	
	var node_type = node_data.get("type", "narration")
	var node_text = node_data.get("text", "")
	var node_icon = node_data.get("icon", "📖")
	
	# Add log to ExplorationBottomUI
	if current_bottom_ui and current_bottom_ui.has_method("add_log"):
		var log_message = node_icon + " " + node_text
		var is_event = (node_type != "narration" and node_type != "start")
		current_bottom_ui.add_log(log_message, is_event)
	
	# Handle event nodes
	match node_type:
		"start":
			print("[InRun_v4] Journey started!")
		"narration":
			print("[InRun_v4] Narration node - continue")
		"combat":
			_handle_combat_event()
		"shop":
			_handle_shop_event()
		"npc":
			_handle_npc_event()
		"boss":
			_handle_boss_event()

func _on_run_completed():
	"""Handle run completion"""
	print("[InRun_v4] Run completed! Returning to MainLobby...")
	# TODO: Show run completion screen
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")

func _handle_combat_event():
	"""Handle combat event node"""
	print("[InRun_v4] Combat event triggered!")
	run_progress_bar.pause_progress()
	await get_tree().create_timer(1.0).timeout  # Brief pause for log display
	switch_to_combat()

func _handle_shop_event():
	"""Handle shop event node"""
	print("[InRun_v4] Shop event triggered!")
	run_progress_bar.pause_progress()
	await get_tree().create_timer(1.0).timeout
	switch_to_shop()

func _handle_npc_event():
	"""Handle NPC event node"""
	print("[InRun_v4] NPC event triggered!")
	run_progress_bar.pause_progress()
	await get_tree().create_timer(1.0).timeout
	switch_to_npc_dialog()

func _handle_boss_event():
	"""Handle boss event node"""
	print("[InRun_v4] Boss event triggered!")
	run_progress_bar.pause_progress()
	await get_tree().create_timer(1.5).timeout  # Longer pause for dramatic effect
	switch_to_combat()  # Use same combat system with boss flag

# === State Switching Functions ===

func switch_to_exploration():
	"""Switch to exploration mode"""
	print("\n[InRun_v4] ===== SWITCHING TO EXPLORATION =====")
	current_state = ScreenState.EXPLORATION
	is_scrolling = true  # Start background scrolling
	
	# Disconnect combat signals
	if CombatManager.entity_updated.is_connected(_on_entity_updated):
		CombatManager.entity_updated.disconnect(_on_entity_updated)
	if CombatManager.damage_dealt.is_connected(_on_damage_dealt):
		CombatManager.damage_dealt.disconnect(_on_damage_dealt)
	
	# Clear all characters
	_despawn_all_characters()
	
	_switch_bottom_ui(BOTTOM_UI_PATHS[ScreenState.EXPLORATION])
	
	# Start auto-progress on first entry
	if run_progress_bar and run_progress_bar.current_node_index == 0 and not run_progress_bar.is_auto_progressing:
		print("[InRun_v4] Starting auto-progress...")
		run_progress_bar.start_auto_progress()
	
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
	
	# Connect combat signals
	if not CombatManager.combat_ended.is_connected(_on_combat_ended):
		CombatManager.combat_ended.connect(_on_combat_ended)
	if not CombatManager.entity_updated.is_connected(_on_entity_updated):
		CombatManager.entity_updated.connect(_on_entity_updated)
	if not CombatManager.damage_dealt.is_connected(_on_damage_dealt):
		CombatManager.damage_dealt.connect(_on_damage_dealt)
	
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
	
	# Show reward/defeat screen
	if victory:
		_show_reward_modal()
	else:
		_show_defeat_screen()

func _show_reward_modal():
	"""Show victory reward modal and apply rewards"""
	# Calculate rewards based on combat
	var gold_reward = 50  # TODO: Calculate based on monsters defeated
	var energy_reward = 10
	
	# Apply rewards to GameManager
	GameManager.add_gold(gold_reward)
	GameManager.add_energy(energy_reward)
	print("[InRun_v4] Rewards applied: Gold +%d, Energy +%d" % [gold_reward, energy_reward])
	
	# Show reward modal with display strings
	var reward_strings = [
		"🪙 Gold: +%d" % gold_reward,
		"⚡ Energy: +%d" % energy_reward,
		"🎴 New Card: Flame Strike"
	]
	reward_modal.show_victory(reward_strings)
	print("[InRun_v4] Reward modal shown")

func _show_defeat_screen():
	"""Show defeat screen (no rewards)"""
	reward_modal.show_defeat()
	print("[InRun_v4] Defeat screen shown")

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
	
	# If in combat and CombatBottomUI is selecting target, forward click
	if current_state == ScreenState.COMBAT and current_bottom_ui:
		if current_bottom_ui.has_method("on_monster_clicked"):
			# Find monster index in character_nodes array
			var monster_index = character_nodes.find(character_node)
			if monster_index >= 0:
				current_bottom_ui.on_monster_clicked(monster_index)
				print("[InRun_v4] Monster click forwarded to CombatBottomUI: index %d" % monster_index)

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
			KEY_0:
				# Cheat: Toggle auto-progress pause/resume
				if run_progress_bar:
					if run_progress_bar.paused:
						print("[InRun_v4] CHEAT: Resume auto-progress")
						run_progress_bar.resume_progress()
					else:
						print("[InRun_v4] CHEAT: Pause auto-progress")
						run_progress_bar.pause_progress()
			KEY_9:
				# Cheat: Instant win combat
				if current_state == ScreenState.COMBAT and CombatManager.in_combat:
					print("[InRun_v4] CHEAT: Instant win!")
					for monster in CombatManager.monsters:
						monster.hp = 0
					CombatManager._check_combat_end()
			KEY_MINUS:
				# Cheat: Skip to next node
				if run_progress_bar:
					print("[InRun_v4] CHEAT: Skip to next node")
					run_progress_bar.progress_to_next = 1.0

# === Button Handlers ===

func _on_settings_pressed():
	"""Handle settings button press - Open Settings"""
	print("[InRun_v4] Settings button pressed")
	get_tree().change_scene_to_file("res://ui/screens/Settings.tscn")

# === Combat Entity Update Handlers ===

func _on_entity_updated(entity_type: String, index: int):
	"""Handle entity update from CombatManager"""
	if entity_type == "hero":
		# Update hero HP
		if hero_node:
			var hero_data = CombatManager.hero
			hero_node.update_hp(hero_data.hp)
	
	elif entity_type == "monster":
		# Update monster HP
		if index >= 0 and index < character_nodes.size():
			var monster_node = character_nodes[index]
			if monster_node.visible and index < CombatManager.monsters.size():
				var monster_data = CombatManager.monsters[index]
				monster_node.update_hp(monster_data.hp)

func _on_damage_dealt(entity_type: String, index: int, damage: int, is_healing: bool):
	"""Handle damage dealt signal - show damage number"""
	if entity_type == "hero":
		# Show damage on hero
		if hero_node:
			hero_node.show_damage_number(damage, is_healing)
	
	elif entity_type == "monster":
		# Show damage on monster
		if index >= 0 and index < character_nodes.size():
			var monster_node = character_nodes[index]
			if monster_node.visible:
				monster_node.show_damage_number(damage, is_healing)

# === Public API ===

# Note: advance_to_next_node() removed - RunProgressBar handles auto-progression
