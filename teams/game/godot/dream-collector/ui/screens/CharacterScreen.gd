# CharacterScreen.gd - Character/equipment tab: 6 slots, stats, owned items grid

extends Control

signal equipment_changed(slot_id: String, item: Equipment)

# Slot ID -> allowed DB slot type (목걸이 = OFF_HAND so necklace slots accept OFF_HAND)
const SLOT_TO_TYPE := {
	"slot_weapon": "WEAPON",
	"slot_armor": "ARMOR",
	"slot_ring_1": "ACCESSORY",
	"slot_ring_2": "ACCESSORY",
	"slot_necklace_1": "OFF_HAND",
	"slot_necklace_2": "OFF_HAND",
}

const SORT_RARITY := 0
const SORT_ENHANCE := 1
const SORT_TYPE := 2

# Same as EquipmentSlot so inventory and equipped slots look identical
const RARITY_BORDER := {
	"COMMON": Color("#5DB85D"),
	"RARE": Color("#5B9BD5"),
	"SPECIAL": Color("#9B59B6"),
	"EPIC": Color("#9B59B6"),
	"LEGENDARY": Color("#F39C12"),
}
const RARITY_BG := {
	"COMMON": Color("#2D4A2D"),
	"RARE": Color("#1E3A5F"),
	"SPECIAL": Color("#3D1F5C"),
	"EPIC": Color("#3D1F5C"),
	"LEGENDARY": Color("#4A3000"),
}
# Inventory uses EquipmentSlot instances directly — no separate icon/name constants needed

@onready var gems_label: Label = $Header/CurrencyBar/GemsPanel/GemsLabel
@onready var gold_label: Label = $Header/CurrencyBar/GoldPanel/GoldLabel
@onready var energy_label: Label = $Header/CurrencyBar/EnergyPanel/EnergyLabel
@onready var left_slots: VBoxContainer = $Section_Character/CharacterVBox/EquipmentLayout/LeftSlots
@onready var right_slots: VBoxContainer = $Section_Character/CharacterVBox/EquipmentLayout/RightSlots
@onready var level_label: Label = $Section_Character/CharacterVBox/LevelLabel
@onready var character_display: CenterContainer = $Section_Character/CharacterVBox/EquipmentLayout/CharacterDisplay
@onready var hp_value: Label = $Section_Character/CharacterVBox/StatsRow/HpStat/HpValue
@onready var atk_value: Label = $Section_Character/CharacterVBox/StatsRow/AtkStat/AtkValue
@onready var def_value: Label = $Section_Character/CharacterVBox/StatsRow/DefStat/DefValue
@onready var spd_value: Label = $Section_Character/CharacterVBox/StatsRow/SpdStat/SpdValue
@onready var combat_power_value: Label = $Section_Character/CharacterVBox/CombatPowerRow/CombatPowerValue
var item_detail_popup: Control = null
var char_info_popup: Control = null
@onready var section_inventory: VBoxContainer = $Section_Inventory
@onready var item_grid: GridContainer = null  # set in _ready()
@onready var bottom_nav = $BottomNav
@onready var sort_button: Button = $InventoryHeader/SortButton
@onready var sprite_click_area: Button = $Section_Character/CharacterVBox/EquipmentLayout/CharacterDisplay/SpriteClickArea

var selected_slot: String = ""
var equipped: Dictionary = {}  # slot_id -> Equipment
var current_sort: int = SORT_RARITY
var _all_equipment: Array[Equipment] = []
var _slot_scene: PackedScene = null

func _ready() -> void:
	item_grid = get_node_or_null("Section_Inventory/InventoryScroll/ItemGrid") as GridContainer
	if item_grid == null:
		item_grid = get_node_or_null("Section_Inventory/ScrollContainer/ItemGrid") as GridContainer
	if item_grid == null:
		item_grid = get_node_or_null("Section_Inventory/ItemGrid") as GridContainer
	if item_grid == null and section_inventory:
		var scroll = ScrollContainer.new()
		scroll.name = "InventoryScroll"
		scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
		scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
		item_grid = GridContainer.new()
		item_grid.name = "ItemGrid"
		item_grid.columns = 5
		item_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		scroll.add_child(item_grid)
		section_inventory.add_child(scroll)
	if sort_button:
		sort_button.pressed.connect(_on_sort_pressed)
	# Header is shared; do not change title here
	_update_currency()
	if GameManager:
		if not GameManager.reveries_changed.is_connected(_on_reveries_changed):
			GameManager.reveries_changed.connect(_on_reveries_changed)
		if not GameManager.gems_changed.is_connected(_on_gems_changed):
			GameManager.gems_changed.connect(_on_gems_changed)
		if not GameManager.energy_changed.is_connected(_on_energy_changed):
			GameManager.energy_changed.connect(_on_energy_changed)
	_setup_character_sprite()
	_setup_item_detail_popup()
	_setup_char_info_popup()
	if sprite_click_area:
		sprite_click_area.pressed.connect(_on_sprite_clicked)
	if bottom_nav:
		bottom_nav.set_active_tab(3)
		bottom_nav.tab_pressed.connect(_on_bottom_nav_pressed)
	_connect_slots()
	_load_equipment_list()
	_refresh_equipment_slots()
	_refresh_stats()
	call_deferred("_refresh_inventory")
	call_deferred("_apply_sprites")

func _on_reveries_changed(_v: float) -> void:
	_update_currency()

func _on_gems_changed(_v: int) -> void:
	_update_currency()

func _on_energy_changed(_v: int) -> void:
	_update_currency()

func _update_currency() -> void:
	if not gems_label:
		return
	if GameManager:
		gems_label.text = str(GameManager.gems)
		gold_label.text = str(int(GameManager.reveries))
		energy_label.text = "%d/100" % mini(GameManager.energy, 100)

func _apply_sprites() -> void:
	# Section_Character (PanelContainer) → panel_frame.png (patch=18)
	var section_char := get_node_or_null("Section_Character") as Control
	UISprites.apply_panel(section_char, UISprites.panel_frame(), 18)
	# InventoryHeader (HBoxContainer) → section_header.png (patch=4)
	var inv_header := get_node_or_null("InventoryHeader") as Control
	UISprites.apply_bg(inv_header, UISprites.section_hdr(), 4)
	# CurrencyBar 재화 패널들 → hud_pill.png (patch=20)
	for pname in ["GemsPanel", "GoldPanel", "EnergyPanel"]:
		var pill := get_node_or_null("Header/CurrencyBar/" + pname) as Control
		UISprites.apply_bg(pill, UISprites.hud_pill(), 20)

func _setup_character_sprite() -> void:
	if not character_display:
		return
	# SpriteClickArea는 보존하고 나머지만 제거
	for c in character_display.get_children():
		if c.name != "SpriteClickArea":
			c.queue_free()
	var sprite = PlayerSpriteAnimator.new()
	sprite.custom_minimum_size = Vector2(128, 128)
	sprite.size = Vector2(128, 128)
	sprite.name = "CharacterSprite"
	character_display.add_child(sprite)
	sprite.play(PlayerSpriteAnimator.AnimState.IDLE)
	# SpriteClickArea를 항상 맨 위(마지막 자식)로 이동해 클릭 우선순위 보장
	if sprite_click_area and is_instance_valid(sprite_click_area):
		character_display.move_child(sprite_click_area, character_display.get_child_count() - 1)

func _setup_char_info_popup() -> void:
	var popup_scene = load("res://ui/components/CharacterInfoPopup.tscn") as PackedScene
	if popup_scene:
		char_info_popup = popup_scene.instantiate() as Control
		if char_info_popup:
			if char_info_popup.has_signal("closed"):
				char_info_popup.closed.connect(func(): pass)
			char_info_popup.visible = false
			add_child(char_info_popup)

func _on_sprite_clicked() -> void:
	if char_info_popup and char_info_popup.has_method("show_stats"):
		var ls = get_node_or_null("/root/LevelSystem")
		char_info_popup.show_stats(ls, equipped)

func _setup_item_detail_popup() -> void:
	var popup_scene = load("res://ui/components/ItemDetailPopup.tscn") as PackedScene
	if popup_scene:
		item_detail_popup = popup_scene.instantiate() as Control
		if item_detail_popup and item_detail_popup.has_signal("equip_requested"):
			item_detail_popup.equip_requested.connect(_on_popup_equip)
			item_detail_popup.unequip_requested.connect(_on_popup_unequip)
			item_detail_popup.closed.connect(func(): selected_slot = "")
			item_detail_popup.visible = false
			add_child(item_detail_popup)

func _connect_slots() -> void:
	for slot_btn in left_slots.get_children():
		if slot_btn.has_signal("slot_pressed"):
			slot_btn.slot_pressed.connect(_on_slot_pressed)
	for slot_btn in right_slots.get_children():
		if slot_btn.has_signal("slot_pressed"):
			slot_btn.slot_pressed.connect(_on_slot_pressed)

func _load_equipment_list() -> void:
	_all_equipment.clear()
	if EquipmentDatabase:
		var all = EquipmentDatabase.get_all()
		for e in all:
			if e is Equipment:
				_all_equipment.append(e)

func _refresh_equipment_slots() -> void:
	var slot_ids = ["slot_weapon", "slot_ring_1", "slot_necklace_1", "slot_armor", "slot_ring_2", "slot_necklace_2"]
	var left_ids = ["slot_weapon", "slot_ring_1", "slot_necklace_1"]
	var right_ids = ["slot_armor", "slot_ring_2", "slot_necklace_2"]
	for i in range(left_slots.get_child_count()):
		var slot = left_slots.get_child(i)
		if slot.get("slot_id") != null and i < left_ids.size():
			var sid = left_ids[i]
			var eq = equipped.get(sid, null)
			if eq is Equipment:
				slot.set_item(eq)
			else:
				slot.set_empty()
	for i in range(right_slots.get_child_count()):
		var slot = right_slots.get_child(i)
		if slot.get("slot_id") != null and i < right_ids.size():
			var sid = right_ids[i]
			var eq = equipped.get(sid, null)
			if eq is Equipment:
				slot.set_item(eq)
			else:
				slot.set_empty()

func _refresh_stats() -> void:
	var hp: float = 100.0
	var atk: float = 15.0
	var def: float = 10.0
	var spd: float = 10.0
	var lv: int = 1
	if ClassDB.class_exists("LevelSystem") and has_node("/root/LevelSystem"):
		var ls = get_node("/root/LevelSystem")
		if ls and "total_hp" in ls:
			hp = ls.total_hp
			atk = ls.total_atk
			def = ls.total_def
			lv = ls.current_level
			if "total_spd" in ls:
				spd = ls.total_spd
	for _sid in equipped:
		var eq = equipped[_sid]
		if eq is Equipment:
			hp += eq.get_total_hp()
			atk += eq.get_total_atk()
			def += eq.get_total_def()
			spd += eq.get_total_spd()
	# 전투력 공식: (ATK×2 + DEF + HP/10) × (1 + level × 0.05)
	var power: int = int((atk * 2.0 + def + hp / 10.0) * (1.0 + lv * 0.05))
	level_label.text = "Lv.%d" % lv
	if hp_value:
		hp_value.text = _format_num(int(hp))
	if atk_value:
		atk_value.text = _format_num(int(atk))
	if def_value:
		def_value.text = _format_num(int(def))
	if spd_value:
		spd_value.text = _format_num(int(spd))
	if combat_power_value:
		combat_power_value.text = _format_num(power)

func _format_num(n: int) -> String:
	if n >= 1000:
		return "%d,%03d" % [n / 1000, n % 1000]
	return str(n)

func _refresh_inventory() -> void:
	if item_grid == null:
		return
	for c in item_grid.get_children():
		c.queue_free()
	var list: Array[Equipment] = []
	list.assign(_all_equipment)
	_sort_equipment_list(list)
	var equipped_ids: Dictionary = {}
	for _sid in equipped:
		var eq = equipped[_sid]
		if eq is Equipment:
			equipped_ids[eq.id] = true
	for e in list:
		var cell = _make_item_cell(e, equipped_ids.get(e.id, false))
		item_grid.add_child(cell)

func _sort_equipment_list(list: Array[Equipment]) -> void:
	var rar_order = { "LEGENDARY": 4, "SPECIAL": 3, "RARE": 2, "COMMON": 1 }
	if current_sort == SORT_RARITY:
		list.sort_custom(func(a, b): return rar_order.get(a.rarity, 0) > rar_order.get(b.rarity, 0))
	elif current_sort == SORT_ENHANCE:
		list.sort_custom(func(a, b): return a.enhancement_level > b.enhancement_level)
	elif current_sort == SORT_TYPE:
		list.sort_custom(func(a, b): return a.slot < b.slot)

func _make_item_cell(eq: Equipment, is_equipped: bool) -> Control:
	if _slot_scene == null:
		_slot_scene = load("res://ui/components/EquipmentSlot.tscn") as PackedScene
	if _slot_scene == null:
		return Control.new()
	var slot = _slot_scene.instantiate()
	var eq_to_type := {
		"WEAPON": "weapon", "ARMOR": "armor",
		"ACCESSORY": "ring", "OFF_HAND": "necklace"
	}
	var eq_to_icon := {
		"WEAPON": "⚔", "ARMOR": "🛡",
		"ACCESSORY": "💍", "OFF_HAND": "📿"
	}
	slot.set("slot_type", eq_to_type.get(eq.slot, "weapon"))
	slot.set("slot_label", eq_to_icon.get(eq.slot, "⚔"))
	slot.set("slot_id", "")
	slot.set_item(eq)
	slot.pressed.connect(_on_inventory_item_pressed.bind(eq))
	if not is_equipped:
		slot.call_deferred("set_check_visible", false)
	return slot

func _on_slot_pressed(slot_id: String) -> void:
	var eq = equipped.get(slot_id, null)
	if eq is Equipment:
		_open_item_detail(eq)
	else:
		selected_slot = slot_id
		_refresh_inventory()

func _on_inventory_item_pressed(eq: Equipment) -> void:
	if selected_slot != "":
		var allowed = SLOT_TO_TYPE.get(selected_slot, "")
		if allowed != "" and eq.slot != allowed:
			return
		var slot_id = selected_slot
		equipped[slot_id] = eq.duplicate_equipment()
		selected_slot = ""
		_refresh_equipment_slots()
		_refresh_stats()
		_refresh_inventory()
		equipment_changed.emit(slot_id, eq)
	else:
		_open_item_detail(eq)

func _open_item_detail(eq: Equipment) -> void:
	var equipped_ids: Dictionary = {}
	for _sid in equipped:
		var e = equipped[_sid]
		if e is Equipment:
			equipped_ids[e.id] = true
	var is_equipped = equipped_ids.get(eq.id, false)
	if item_detail_popup and item_detail_popup.has_method("show_item"):
		item_detail_popup.show_item(eq, is_equipped)

func _on_popup_equip(item: Equipment) -> void:
	# Find first empty slot that accepts this type
	for sid in ["slot_weapon", "slot_armor", "slot_ring_1", "slot_ring_2", "slot_necklace_1", "slot_necklace_2"]:
		if equipped.get(sid, null) != null:
			continue
		var allowed = SLOT_TO_TYPE.get(sid, "")
		if allowed != "" and item.slot != allowed:
			continue
		equipped[sid] = item.duplicate_equipment()
		break
	_refresh_equipment_slots()
	_refresh_stats()
	_refresh_inventory()
	equipment_changed.emit("", item)

func _on_popup_unequip(item: Equipment) -> void:
	for sid in equipped:
		if equipped[sid] is Equipment and (equipped[sid] as Equipment).id == item.id:
			equipped[sid] = null
			equipped.erase(sid)
			break
	_refresh_equipment_slots()
	_refresh_stats()
	_refresh_inventory()

func _on_sort_pressed() -> void:
	current_sort = (current_sort + 1) % 3
	var labels := ["등급순 ▾", "강화순 ▾", "종류순 ▾"]
	if sort_button:
		sort_button.text = labels[current_sort]
	call_deferred("_refresh_inventory")

func _on_bottom_nav_pressed(tab_index: int) -> void:
	bottom_nav.set_active_tab(tab_index)
	match tab_index:
		0: get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1: get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2: get_tree().change_scene_to_file("res://ui/screens/UpgradeTree.tscn")
		3: pass
		4: get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")
