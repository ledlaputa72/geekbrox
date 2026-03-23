# CharacterScreen.gd - Character/equipment tab: 6 slots, stats, owned items grid
#
# 캐릭터 스프라이트 클릭 시 CharacterInfoPopup 표시.
# 참조: CHARACTER_INFO_POPUP_SPEC.md, CHARACTER_STATS_DETAILED_SYSTEM.md, CLAUDE.md

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
# Node refs resolved in _ready() via get_node_or_null to avoid crash if scene tree differs

var gems_label: Label = null
var gold_label: Label = null
var energy_label: Label = null
var left_slots: VBoxContainer = null
var right_slots: VBoxContainer = null
var level_label: Label = null
var character_display: CenterContainer = null
var hp_value: Label = null
var atk_value: Label = null
var def_value: Label = null
var spd_value: Label = null
var combat_power_value: Label = null
var item_detail_popup: Control = null
var char_info_popup: Control = null
var section_inventory: VBoxContainer = null
var item_grid: GridContainer = null
var bottom_nav: Node = null
var sort_button: Button = null
var sprite_click_area: Button = null

var selected_slot: String = ""
var equipped: Dictionary = {}  # slot_id -> Equipment
var current_sort: int = SORT_RARITY
var _all_equipment: Array[Equipment] = []
var _slot_scene: PackedScene = null

const _DBG_LOG_PATH = "res://debug-e7b017.log"

func _safe_load_popups() -> bool:
	return true

func _dbg(msg: String, loc: String = "CharacterScreen.gd") -> void:
	print("[CharacterScreen] ", msg)
	var j = JSON.stringify({"sessionId": "e7b017", "message": msg, "location": loc, "timestamp": int(Time.get_ticks_msec())})
	var f = FileAccess.open(_DBG_LOG_PATH, FileAccess.READ_WRITE)
	if f == null: f = FileAccess.open(_DBG_LOG_PATH, FileAccess.WRITE)
	if f: f.seek_end(); f.store_line(j); f.close()

func _ready() -> void:
	print("[DEBUG e7b017] CharacterScreen _ready start")
	_dbg("_ready start")
	# Defer full init to next frame (avoids crash during scene transition)
	call_deferred("_ready_init")

func _ready_init() -> void:
	_dbg("_ready_init start", "CharacterScreen.gd _ready_init")
	if not is_instance_valid(self):
		return
	# Resolve node refs (avoids get_node crash during scene load)
	gems_label = get_node_or_null("Header/CurrencyBar/GemsPanel/GemsLabel") as Label
	gold_label = get_node_or_null("Header/CurrencyBar/GoldPanel/GoldLabel") as Label
	energy_label = get_node_or_null("Header/CurrencyBar/EnergyPanel/EnergyLabel") as Label
	left_slots = get_node_or_null("Section_Character/CharacterVBox/EquipmentLayout/LeftSlots") as VBoxContainer
	right_slots = get_node_or_null("Section_Character/CharacterVBox/EquipmentLayout/RightSlots") as VBoxContainer
	level_label = get_node_or_null("Section_Character/CharacterVBox/LevelLabel") as Label
	character_display = get_node_or_null("Section_Character/CharacterVBox/EquipmentLayout/CharacterDisplay") as CenterContainer
	hp_value = get_node_or_null("Section_Character/CharacterVBox/StatsRow/HpStat/HpValue") as Label
	atk_value = get_node_or_null("Section_Character/CharacterVBox/StatsRow/AtkStat/AtkValue") as Label
	def_value = get_node_or_null("Section_Character/CharacterVBox/StatsRow/DefStat/DefValue") as Label
	spd_value = get_node_or_null("Section_Character/CharacterVBox/StatsRow/SpdStat/SpdValue") as Label
	combat_power_value = get_node_or_null("Section_Character/CharacterVBox/CombatPowerRow/CombatPowerValue") as Label
	section_inventory = get_node_or_null("Section_Inventory") as VBoxContainer
	bottom_nav = get_node_or_null("BottomNav")
	sort_button = get_node_or_null("InventoryHeader/SortButton") as Button
	sprite_click_area = get_node_or_null("Section_Character/CharacterVBox/EquipmentLayout/CharacterDisplay/SpriteClickArea") as Button
	if not left_slots or not right_slots:
		push_error("[CharacterScreen] left_slots or right_slots is null")
		return
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
	_dbg("after item_grid")
	if sort_button:
		sort_button.pressed.connect(_on_sort_pressed)
	_update_currency()
	if GameManager:
		if not GameManager.reveries_changed.is_connected(_on_reveries_changed):
			GameManager.reveries_changed.connect(_on_reveries_changed)
		if not GameManager.gems_changed.is_connected(_on_gems_changed):
			GameManager.gems_changed.connect(_on_gems_changed)
		if not GameManager.energy_changed.is_connected(_on_energy_changed):
			GameManager.energy_changed.connect(_on_energy_changed)
	_setup_character_sprite()
	_dbg("after setup_character_sprite")
	# Load popups only when needed to avoid crash on scene load (re-enable when stable)
	if _safe_load_popups():
		call_deferred("_setup_item_detail_popup")
		call_deferred("_setup_char_info_popup")
	# 캐릭터 스프라이트 클릭 → 정보 팝업
	# gui_input 방식 대신 SpriteClickArea Button 시그널 사용 (더 안전)
	if sprite_click_area and is_instance_valid(sprite_click_area):
		if not sprite_click_area.pressed.is_connected(_open_character_detail_modal):
			sprite_click_area.pressed.connect(_open_character_detail_modal)
	if bottom_nav:
		bottom_nav.tab_pressed.connect(_on_bottom_nav_pressed)
		# Defer tab styling so it runs after scene tree is fully ready (avoids crash on first frame)
		if bottom_nav.has_method("set_active_tab"):
			bottom_nav.call_deferred("set_active_tab", 3)  # Character tab index (0=Home,1=Cards,2=Upgrade,3=Character,4=Shop)
	_connect_slots()
	_load_equipment_list()
	_refresh_equipment_slots()
	_dbg("after refresh_equipment_slots")
	_refresh_stats()
	call_deferred("_refresh_inventory")
	call_deferred("_apply_sprites")
	_dbg("_ready end")

func _on_reveries_changed(_v: float) -> void:
	_update_currency()

func _on_gems_changed(_v: int) -> void:
	_update_currency()

func _on_energy_changed(_v: int) -> void:
	_update_currency()

func _update_currency() -> void:
	if not GameManager:
		return
	if gems_label:
		gems_label.text = str(GameManager.gems)
	if gold_label:
		gold_label.text = str(int(GameManager.reveries))
	if energy_label:
		energy_label.text = "%d/100" % mini(GameManager.energy, 100)

func _apply_sprites() -> void:
	_dbg("_apply_sprites start")
	# 전역 픽셀 아트 스타일: 배경·패널 색상
	var bg := get_node_or_null("Background") as ColorRect
	if bg and UITheme:
		bg.color = UITheme.COLORS.get("bg", Color.WHITE)
	var section_char := get_node_or_null("Section_Character") as PanelContainer
	if section_char and UITheme:
		var sb := StyleBoxFlat.new()
		sb.bg_color = UITheme.COLORS.get("panel", Color.WHITE)
		sb.border_color = UITheme.COLORS.get("panel_border", Color.WHITE)
		sb.set_corner_radius_all(8)
		sb.set_border_width_all(2)
		section_char.add_theme_stylebox_override("panel", sb)
	elif section_char:
		UISprites.apply_panel(section_char, UISprites.panel_frame(), 8)
	var inv_header := get_node_or_null("InventoryHeader") as Control
	if inv_header:
		UISprites.apply_bg(inv_header, UISprites.section_hdr(), 8)
	for pname in ["GemsPanel", "GoldPanel", "EnergyPanel"]:
		var pill := get_node_or_null("Header/CurrencyBar/" + pname) as Control
		if pill:
			UISprites.apply_bg(pill, UISprites.hud_pill(), 8)
	# ── C-02: 정렬 버튼 → KenneyTheme 노말 버튼 ────────────────
	var kenney := get_node_or_null("/root/KenneyTheme")
	if sort_button and kenney and kenney.has_method("apply_button_normal"):
		kenney.apply_button_normal(sort_button)
	# ── C-02: 인벤토리 그리드 슬롯 — 등급별 Kenney 슬롯 텍스처 ──
	# (_refresh_inventory 이후 call_deferred로 호출)
	call_deferred("_apply_kenney_inventory_slots")
	# 픽셀 아이콘 (있으면 이모지 대신 표시)
	_apply_currency_pixel_icons()
	# 텍스트 외곽선 (이미지 스타일: 버튼·라벨 가독성)
	if UITheme:
		if level_label:
			UITheme.apply_text_outline(level_label, 2)
		if sort_button:
			UITheme.apply_text_outline(sort_button, 2)
		for node_name in ["GemsLabel", "GoldLabel", "EnergyLabel"]:
			var lbl := get_node_or_null("Header/CurrencyBar/" + node_name) as Label
			if lbl:
				UITheme.apply_text_outline(lbl, 2)
		var inv_title := get_node_or_null("InventoryHeader/InventoryTitleLabel") as Label
		if inv_title:
			UITheme.apply_text_outline(inv_title, 2)

func _apply_currency_pixel_icons() -> void:
	_dbg("_apply_currency_pixel_icons start")
	if not UIManager:
		return
	var bar := get_node_or_null("Header/CurrencyBar") as HBoxContainer
	if not bar:
		return
	var icon_keys := ["GemsPanel", "GoldPanel", "EnergyPanel"]
	var pixel_keys := ["diamond", "coin", "energy"]
	var icon_node_names := ["GemsIcon", "GoldIcon", "EnergyIcon"]
	for i in range(icon_keys.size()):
		var panel := bar.get_node_or_null(icon_keys[i]) as HBoxContainer
		if not panel:
			continue
		var icon_label := panel.get_node_or_null(icon_node_names[i])
		if not icon_label:
			continue
		var tex := UIManager.get_pixel_icon(pixel_keys[i])
		if tex == null:
			continue
		var icon_tex := TextureRect.new()
		icon_tex.name = icon_label.name + "Tex"
		icon_tex.custom_minimum_size = Vector2(24, 24)
		icon_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_tex.texture = tex
		icon_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		var idx: int = icon_label.get_index()
		panel.add_child(icon_tex)
		panel.move_child(icon_tex, idx)
		icon_label.visible = false
		icon_tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dbg("_apply_currency_pixel_icons end")

## C-02: 인벤토리 그리드 EquipmentSlot에 KenneyTheme 등급별 슬롯 텍스처 적용
## _refresh_inventory() 이후 call_deferred로 호출됨
func _apply_kenney_inventory_slots() -> void:
	if item_grid == null:
		return
	var kenney := get_node_or_null("/root/KenneyTheme")
	if kenney == null or not kenney.has_method("get_slot_texture"):
		return
	# 등급 string 정규화: Equipment.rarity 는 UPPERCASE (COMMON/RARE/SPECIAL/LEGENDARY)
	# KenneyTheme.get_slot_texture 는 lowercase 받음
	const RARITY_LOWER := {
		"COMMON": "common", "RARE": "rare",
		"SPECIAL": "epic", "EPIC": "epic", "LEGENDARY": "legendary"
	}
	for slot in item_grid.get_children():
		if not slot.has_method("get") or not slot.get("equipped_item"):
			continue
		var eq: Equipment = slot.get("equipped_item") as Equipment
		if eq == null:
			continue
		var grade: String = RARITY_LOWER.get(eq.rarity.to_upper(), "common")
		var tex: Texture2D = kenney.get_slot_texture(grade)
		if tex == null:
			continue
		# NinePatchRect 배경 교체 (이름 "_np_bg") — UISprites.slot_tex 가 없을 때 대체
		var np_bg := slot.get_node_or_null("_np_bg")
		if np_bg == null:
			# UISprites 텍스처가 없어 폴백으로 KenneyTheme 삽입
			var np := NinePatchRect.new()
			np.name = "_np_bg"
			np.texture = tex
			np.patch_margin_left   = 10
			np.patch_margin_right  = 10
			np.patch_margin_top    = 10
			np.patch_margin_bottom = 10
			np.mouse_filter = Control.MOUSE_FILTER_IGNORE
			np.set_anchors_preset(Control.PRESET_FULL_RECT)
			slot.add_child(np)
			slot.move_child(np, 0)

func _setup_character_sprite() -> void:
	if not character_display:
		return
	# 기존 스프라이트 노드만 제거 (SpriteClickArea 유지)
	for c in character_display.get_children():
		if c.name != "SpriteClickArea":
			c.queue_free()
	# ── 스프라이트 TextureRect 추가 ────────────────────────────────
	var sprite := TextureRect.new()
	sprite.name = "CharacterSprite"
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.custom_minimum_size = Vector2(120, 140)
	sprite.size = Vector2(120, 140)
	# player_ani.png (2048×2048 스프라이트시트) — 첫 번째 프레임 AtlasTexture 사용
	var base_tex := load("res://assets/sprites/player_ani.png") as Texture2D
	if base_tex == null:
		base_tex = load("res://assets/sprite/player_ani.png") as Texture2D
	if base_tex:
		# 스프라이트시트 첫 행의 첫 프레임 (4×4 그리드: 512×512 per frame)
		var atlas := AtlasTexture.new()
		atlas.atlas = base_tex
		atlas.region = Rect2(0, 0, 512, 512)
		sprite.texture = atlas
		# 마젠타/라벤더 배경 투명화 셰이더 (GPU 처리)
		# 배경 패턴 2종: 순수마젠타(0.98,0.02,0.97) + 라벤더가장자리(1.0,0.94,1.0)
		var shader := Shader.new()
		shader.code = """
shader_type canvas_item;
void fragment() {
    vec4 c = texture(TEXTURE, UV);
    // 1) 순수 마젠타 배경
    bool core = length(c.rgb - vec3(0.98, 0.02, 0.97)) < 0.22;
    // 2) 라벤더/연핑크 가장자리: 매우 밝고 R,B 모두 G보다 높음 (흰색은 R≈G≈B라 제외됨)
    // lavender(1.0,0.945,1.0) → R-G=0.055, B-G=0.055 → 양쪽 모두 >0.03
    bool edge = c.r > 0.88 && c.b > 0.88 && c.g > 0.80
                && (c.r - c.g) > 0.03 && (c.b - c.g) > 0.03;
    if (core || edge) { c.a = 0.0; }
    COLOR = c;
}
"""
		var mat := ShaderMaterial.new()
		mat.shader = shader
		sprite.material = mat
	else:
		# 텍스처 없으면 색상 박스로 대체
		var placeholder := ColorRect.new()
		placeholder.name = "CharacterSprite"
		placeholder.color = Color(0.4, 0.5, 0.7, 0.6)
		placeholder.custom_minimum_size = Vector2(120, 140)
		placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		character_display.add_child(placeholder)
		character_display.move_child(placeholder, 0)
	character_display.add_child(sprite)
	character_display.move_child(sprite, 0)  # 버튼 아래에 배치
	# ── SpriteClickArea: 투명 버튼, 스프라이트 위에서 클릭 수신 ───
	if sprite_click_area and is_instance_valid(sprite_click_area):
		sprite_click_area.mouse_filter = Control.MOUSE_FILTER_STOP
		sprite_click_area.custom_minimum_size = Vector2(120, 140)
		# 투명 버튼 스타일 (배경 없음, 클릭 영역만)
		var transparent := StyleBoxEmpty.new()
		sprite_click_area.add_theme_stylebox_override("normal",   transparent)
		sprite_click_area.add_theme_stylebox_override("hover",    transparent)
		sprite_click_area.add_theme_stylebox_override("pressed",  transparent)
		sprite_click_area.add_theme_stylebox_override("focus",    transparent)
		sprite_click_area.text = ""
		sprite_click_area.flat = true

func _setup_char_info_popup() -> void:
	var popup_scene = load("res://ui/components/CharacterInfoPopup.tscn") as PackedScene
	if popup_scene:
		char_info_popup = popup_scene.instantiate() as Control
		if char_info_popup:
			if char_info_popup.has_signal("closed"):
				char_info_popup.closed.connect(func(): pass)
			char_info_popup.visible = false
			char_info_popup.z_index = 100
			add_child(char_info_popup)

func _on_character_display_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			_open_character_detail_modal()

func _open_character_detail_modal() -> void:
	# 팝업 미준비 시 즉시 초기화 시도
	if char_info_popup == null:
		_setup_char_info_popup()
	if not char_info_popup or not char_info_popup.has_method("show_stats"):
		push_warning("[CharacterScreen] CharacterInfoPopup 사용 불가 — show_stats 없음")
		return
	var ls = get_node_or_null("/root/LevelSystem")
	if ls == null and get_tree().current_scene:
		ls = get_tree().current_scene.get_node_or_null("LevelSystem")
	char_info_popup.show_stats(ls, equipped)

func _setup_item_detail_popup() -> void:
	if not is_instance_valid(self):
		return
	var popup_scene = load("res://ui/components/ItemDetailPopup.tscn") as PackedScene
	if popup_scene == null:
		push_error("[CharacterScreen] ItemDetailPopup.tscn 로드 실패")
		return
	item_detail_popup = popup_scene.instantiate() as Control
	if item_detail_popup == null:
		push_error("[CharacterScreen] ItemDetailPopup 인스턴스 실패")
		return
	if item_detail_popup.has_signal("equip_requested"):
		item_detail_popup.equip_requested.connect(_on_popup_equip)
	if item_detail_popup.has_signal("unequip_requested"):
		item_detail_popup.unequip_requested.connect(_on_popup_unequip)
	if item_detail_popup.has_signal("closed"):
		item_detail_popup.closed.connect(func(): selected_slot = "")
	item_detail_popup.visible = false
	item_detail_popup.z_index = 100
	add_child(item_detail_popup)
	_dbg("ItemDetailPopup 초기화 완료")

func _connect_slots() -> void:
	for slot_btn in left_slots.get_children():
		if slot_btn.has_signal("slot_pressed"):
			slot_btn.slot_pressed.connect(_on_slot_pressed)
	for slot_btn in right_slots.get_children():
		if slot_btn.has_signal("slot_pressed"):
			slot_btn.slot_pressed.connect(_on_slot_pressed)

func _load_equipment_list() -> void:
	_all_equipment.clear()
	if not EquipmentDatabase or not EquipmentDatabase.has_method("get_all"):
		return
	var all = EquipmentDatabase.get_all()
	if all == null:
		return
	for e in all:
		if e is Equipment:
			_all_equipment.append(e)

func _refresh_equipment_slots() -> void:
	var left_ids  = ["slot_weapon",  "slot_ring_1",  "slot_necklace_1"]
	var right_ids = ["slot_armor",   "slot_ring_2",  "slot_necklace_2"]

	for i in range(left_slots.get_child_count()):
		if i >= left_ids.size(): break
		var slot = left_slots.get_child(i)
		if not slot.has_method("set_item"): continue
		var eq = equipped.get(left_ids[i], null)
		# is Equipment 타입체크 실패 방지: null 체크와 has_method로 이중 확인
		if eq != null and eq is Equipment:
			slot.set_item(eq)
		else:
			slot.set_empty()

	for i in range(right_slots.get_child_count()):
		if i >= right_ids.size(): break
		var slot = right_slots.get_child(i)
		if not slot.has_method("set_item"): continue
		var eq = equipped.get(right_ids[i], null)
		if eq != null and eq is Equipment:
			slot.set_item(eq)
		else:
			slot.set_empty()

func _refresh_stats() -> void:
	var hp: float = 100.0
	var atk: float = 15.0
	var def: float = 10.0
	var spd: float = 10.0
	var lv: int = 1
	if ClassDB.class_exists("LevelSystem"):
		var ls = get_node_or_null("/root/LevelSystem")
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
	if level_label:
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
		return "%d,%03d" % [int(n / 1000.0), n % 1000]
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
	if item_detail_popup == null:
		# 팝업이 아직 준비 안 됐으면 즉시 초기화 후 재시도
		_setup_item_detail_popup()
	if item_detail_popup and item_detail_popup.has_method("show_item"):
		item_detail_popup.show_item(eq, is_equipped)
	else:
		push_warning("[CharacterScreen] ItemDetailPopup 사용 불가 — show_item 없음")

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
	if bottom_nav and bottom_nav.has_method("set_active_tab"):
		bottom_nav.set_active_tab(tab_index)
	match tab_index:
		0: get_tree().change_scene_to_file("res://scenes/MainLobby.tscn")
		1: get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2: get_tree().change_scene_to_file("res://ui/screens/UpgradeTree.tscn")
		3: pass  # Character (current screen)
		4: get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")
