# CharacterInfoPopup.gd - Character stats detail modal.
# Spec: CHARACTER_INFO_POPUP_SPEC.md, CHARACTER_STATS_DETAILED_SYSTEM.md.
# Template: ItemDetailPopup.tscn .gd. Layers: 0 Base, 1 Combat, 2 Card, 3 Element, then equipment, final.

extends Control

signal closed()

@onready var icon_box: TextureRect = $ContentPanel/MainVBox/TopSection/IconBox
@onready var name_label: Label = $ContentPanel/MainVBox/TopSection/TopRight/NameLabel
@onready var level_label: Label = $ContentPanel/MainVBox/TopSection/TopRight/LevelLabel
@onready var meta_row: Label = $ContentPanel/MainVBox/TopSection/TopRight/MetaRow
@onready var combat_power_row: Label = $ContentPanel/MainVBox/TopSection/TopRight/CombatPowerRow
@onready var stats_list: VBoxContainer = $ContentPanel/MainVBox/BodyScroll/StatsList
@onready var close_btn: Button = $ContentPanel/MainVBox/ButtonsRow/CloseBtn

# Font and colors
const COLOR_TEXT_DEFAULT := Color(0.1, 0.1, 0.1, 1)
const COLOR_LABEL        := Color(0.1, 0.1, 0.1, 1)
const COLOR_VALUE        := Color(0.1, 0.1, 0.1, 1)
const COLOR_VAL_POS      := Color(0.15, 0.45, 0.15, 1)
const COLOR_VAL_NEG      := Color(0.55, 0.15, 0.15, 1)
const COLOR_VAL_CAPPED   := Color(0.5, 0.4, 0.0, 1)
const COLOR_HEADER_BG    := Color(0.82, 0.70, 0.52, 0.45)
const COLOR_HEADER_TXT   := Color(0.15, 0.15, 0.15, 1)
const COLOR_ACCENT_GOLD  := Color(0.5, 0.4, 0.0, 1)
const COLOR_DIVIDER      := Color(0.6, 0.55, 0.5, 0.4)
const COLOR_DISABLED     := Color(0.45, 0.45, 0.45, 1)
const ELEMENT_COLORS    := {
	"dream": Color(0.7, 0.7, 0.9),
	"fire": Color(1.0, 0.5, 0.0),
	"cold": Color(0.5, 0.8, 1.0),
	"lightning": Color(1.0, 1.0, 0.0),
	"darkness": Color(0.4, 0.2, 0.6),
}
const CARD_TYPE_COLORS  := {
	"ATTACK": Color(1.0, 0.2, 0.2),
	"SKILL": Color(0.2, 0.8, 1.0),
	"POWER": Color(1.0, 0.8, 0.0),
	"CURSE": Color(0.6, 0.2, 0.8),
}

func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	var dim = get_node_or_null("DimLayer")
	if dim and dim is Control:
		(dim as Control).gui_input.connect(_on_dim_layer_input)
	_apply_panel_sprite()
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _apply_panel_sprite() -> void:
	var content_panel := get_node_or_null("ContentPanel")
	UISprites.apply_panel(content_panel, UISprites.panel_frame())
	# 닫기 버튼 — UI Pack button_rectangle_depth_flat (Grey)
	UISprites.apply_btn(close_btn, "secondary")

func show_stats(level_sys, equipped: Dictionary) -> void:
	_build_stats(level_sys, equipped)
	mouse_filter = Control.MOUSE_FILTER_STOP
	visible = true

# --- TopSection + 6 sections: Basic, Advanced, Elemental, Resistance, Card, Final ---

func _build_stats(ls, equipped: Dictionary) -> void:
	var lv:  int   = ls.current_level    if ls and "current_level" in ls else 1
	var exp_val: float = ls.current_exp  if ls and "current_exp"   in ls else 0.0
	var req: float = ls.get_required_exp() if ls and ls.has_method("get_required_exp") else 100.0
	var hp:  float = ls.total_hp         if ls and "total_hp"      in ls else 100.0
	var atk: float = ls.total_atk        if ls and "total_atk"     in ls else 15.0
	var def: float = ls.total_def        if ls and "total_def"     in ls else 10.0
	var spd: float = ls.total_spd        if ls and "total_spd"     in ls else 10.0

	var eq_hp := 0.0; var eq_atk := 0.0; var eq_def := 0.0; var eq_spd := 0.0; var eq_cri := 0.0
	for _sid in equipped:
		var eq = equipped[_sid]
		if eq is Equipment:
			eq_hp += eq.get_total_hp(); eq_atk += eq.get_total_atk(); eq_def += eq.get_total_def()
			eq_spd += eq.get_total_spd(); eq_cri += eq.get_total_cri()

	var total_hp := hp + eq_hp
	var total_atk := atk + eq_atk
	var total_def := def + eq_def
	var total_spd := spd + eq_spd
	var crit_rate: float = 5.0 + eq_cri
	var crit_dmg: float = 150.0
	var dodge_rate: float = 0.0
	var armor_pen: float = 0.0
	var dmg_reduction: float = 0.0
	var power: int = int((total_atk * 2.0 + total_def + total_hp / 10.0) * (1.0 + lv * 0.05))

	name_label.text = "Nox"
	level_label.text = "Lv.%d" % lv
	meta_row.text = "♥ %s  ⚡ %s  🛡 %s  💨 %s" % [_fmt(int(total_hp)), _fmt(int(total_atk)), _fmt(int(total_def)), "%.0f" % total_spd]
	combat_power_row.text = tr("character.combat_power") + ": %s" % _fmt(power)
	if icon_box:
		var portrait_path := "res:" + "/" + "assets/character/nox_portrait.png"
		var portrait: Texture2D = null
		if ResourceLoader.exists(portrait_path):
			portrait = load(portrait_path) as Texture2D
		if portrait:
			icon_box.texture = portrait
		icon_box.custom_minimum_size = Vector2(160, 160)

	for c in stats_list.get_children():
		c.queue_free()

	_add_section(tr("character.basic_stats"))
	_add_row("HP",           "%s - %s" % [_fmt(int(total_hp)), _fmt(int(total_hp))])
	_add_row(tr("character.atk"),      _fmt(int(total_atk)))
	_add_row(tr("character.def"),      _fmt(int(total_def)))
	_add_row(tr("character.spd"),      "%.1f" % total_spd)
	_add_row(tr("character.level"),    "Lv.%d" % lv)
	_add_row(tr("character.exp"),      "%.0f - %.0f" % [exp_val, req])

	_add_section(tr("character.advanced_stats"))
	_add_row_capped(tr("character.crit_rate"),    "%.1f%%" % crit_rate, crit_rate, 50.0, 75.0)
	_add_row(tr("character.crit_damage"),        "%.0f%%" % crit_dmg)
	_add_row(tr("character.armor_pen"),          "%.1f%%" % armor_pen)
	_add_row(tr("character.dodge_rate"),         "%.1f%%" % dodge_rate)
	_add_row(tr("character.dmg_reduction"),      "%.1f%%" % dmg_reduction)

	_add_section(tr("character.elemental"))
	_add_row(tr("character.dream_dmg"),   "+0%")
	_add_row(tr("character.fire_dmg"),   "+0%")
	_add_row(tr("character.cold_dmg"),   "+0%")
	_add_row(tr("character.lightning_dmg"),   "+0%")
	_add_row(tr("character.darkness_dmg"),   "+0%")

	_add_section(tr("character.resistance"))
	_add_row(tr("character.poison_res"),   "0%")
	_add_row(tr("character.burn_res"), "0%")
	_add_row(tr("character.freeze_res"), "0%")
	_add_row(tr("character.paralyze_res"), "0%")
	_add_row(tr("character.weak_res"), "0%")
	_add_row(tr("character.stun_res"), "0%")

	_add_section(tr("character.card_efficiency"))
	_add_row("ATTACK", "+0%")
	_add_row("SKILL",  "+0%")
	_add_row("POWER",  "+0%")
	_add_row("CURSE",  "+0%")

	var survivability := "HIGH" if (total_hp + total_def) > 500 else ("MEDIUM" if (total_hp + total_def) > 200 else "LOW")
	var dps_approx := int(total_atk * 1.5 * (crit_rate / 100.0) * 2.9)
	var stability := "HIGH" if dodge_rate > 20.0 else ("MEDIUM" if dodge_rate > 0.0 else "LOW")
	_add_section(tr("character.final_stats"))
	_add_row(tr("character.combat_power"),   _fmt(power))
	_add_row(tr("character.survivability"),   survivability)
	_add_row("DPS",      "~%d " % dps_approx + tr("character.per_turn"))
	_add_row(tr("character.stability"),   stability)

	var sp = Control.new()
	sp.custom_minimum_size = Vector2(0, 14)
	stats_list.add_child(sp)

# --- UI builder helpers ---

func _add_section(title: String) -> void:
	if stats_list.get_child_count() > 0:
		var sp = Control.new()
		sp.custom_minimum_size = Vector2(0, 8)
		stats_list.add_child(sp)
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = COLOR_HEADER_BG
	style.set_corner_radius_all(4)
	style.content_margin_left = 12.0
	style.content_margin_top  = 5.0
	style.content_margin_right  = 12.0
	style.content_margin_bottom = 5.0
	panel.add_theme_stylebox_override("panel", style)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var lbl = Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 13)
	lbl.add_theme_color_override("font_color", COLOR_HEADER_TXT)
	panel.add_child(lbl)
	stats_list.add_child(panel)

func _add_row(label_text: String, value_text: String) -> void:
	_add_row_capped(label_text, value_text, -1.0, -1.0, -1.0)

func _add_row_capped(label_text: String, value_text: String,
		current: float, soft_cap: float, _hard_cap: float) -> void:
	var margin = MarginContainer.new()
	margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_theme_constant_override("margin_left",  14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top",   4)
	margin.add_theme_constant_override("margin_bottom", 0)

	var col = VBoxContainer.new()
	col.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var lbl = Label.new()
	lbl.text = label_text
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", COLOR_LABEL)

	var val = Label.new()
	val.text = value_text
	val.add_theme_font_size_override("font_size", 12)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	val.custom_minimum_size = Vector2(100, 0)

	var col_val: Color
	if soft_cap >= 0.0 and current >= soft_cap:
		col_val = COLOR_VAL_CAPPED
	elif value_text.begins_with("+") and value_text != "+0" and value_text != "+0.0":
		col_val = COLOR_VAL_POS
	elif value_text.begins_with("-"):
		col_val = COLOR_VAL_NEG
	else:
		col_val = COLOR_VALUE
	val.add_theme_color_override("font_color", col_val)

	row.add_child(lbl)
	row.add_child(val)

	var div = ColorRect.new()
	div.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	div.custom_minimum_size = Vector2(0, 1)
	div.color = COLOR_DIVIDER

	col.add_child(row)
	col.add_child(div)
	margin.add_child(col)
	stats_list.add_child(margin)

# --- Format helpers ---

func _fmt(n: int) -> String:
	if n >= 1000:
		return "%d,%03d" % [int(n / 1000), n % 1000]
	return str(n)

func _plus_fmt(n: int) -> String:
	if n > 0:
		return "+%s" % _fmt(n)
	return str(n)

func _plus_fmt_f(v: float) -> String:
	if v > 0.0:
		return "+%.1f" % v
	if v < 0.0:
		return "%.1f" % v
	return "0"

func _on_dim_layer_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_close()

func _on_close() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	closed.emit()
