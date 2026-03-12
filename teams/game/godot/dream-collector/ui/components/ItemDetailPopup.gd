# ItemDetailPopup.gd — React 스타일: 다크 패널, 섹션별 연회색 패널, 컬러 버튼

extends Control

signal equip_requested(item: Equipment)
signal unequip_requested(item: Equipment)
signal closed()

@onready var icon_label: Label = $ContentPanel/Scroll/VBox/TopSection/IconBox/IconLabel
@onready var title_label: Label = $ContentPanel/Scroll/VBox/TopSection/TitleLabel
@onready var meta_row: Label = $ContentPanel/Scroll/VBox/TopSection/MetaRow
@onready var atk_value: Label = $ContentPanel/Scroll/VBox/BasicStatsSection/StatsPanel/StatsGrid/AtkStatBox/AtkValue
@onready var def_value: Label = $ContentPanel/Scroll/VBox/BasicStatsSection/StatsPanel/StatsGrid/DefStatBox/DefValue
@onready var cri_stat_box: VBoxContainer = $ContentPanel/Scroll/VBox/BasicStatsSection/StatsPanel/StatsGrid/CriStatBox
@onready var cri_value: Label = $ContentPanel/Scroll/VBox/BasicStatsSection/StatsPanel/StatsGrid/CriStatBox/CriValue
@onready var skill_name_label: Label = $ContentPanel/Scroll/VBox/SkillSection/SkillPanel/SkillVBox/SkillNameLabel
@onready var skill_desc_label: Label = $ContentPanel/Scroll/VBox/SkillSection/SkillPanel/SkillVBox/SkillDescLabel
@onready var options_list: VBoxContainer = $ContentPanel/Scroll/VBox/OptionsSection/OptionsList
@onready var usage_value: Label = $ContentPanel/Scroll/VBox/UsageSection/UsageValue
@onready var close_btn: Button = $ContentPanel/Scroll/VBox/ButtonsRow/CloseButton
@onready var equip_btn: Button = $ContentPanel/Scroll/VBox/ButtonsRow/EquipButton
@onready var unequip_btn: Button = $ContentPanel/Scroll/VBox/ButtonsRow/UnequipButton
@onready var enhance_btn: Button = $ContentPanel/Scroll/VBox/ButtonsRow/EnhanceButton

var _item: Equipment = null
var _is_equipped: bool = false

const SLOT_ICONS := {"WEAPON": "⚔", "ARMOR": "🛡", "ACCESSORY": "💍", "OFF_HAND": "📿"}
const TYPE_NAMES := {"WEAPON": "무기", "ARMOR": "방어구", "ACCESSORY": "반지", "OFF_HAND": "목걸이"}
const RARITY_NAMES := {"COMMON": "일반", "RARE": "레어", "SPECIAL": "에픽", "LEGENDARY": "전설"}
const RARITY_COLORS := {
	"COMMON": Color(0.7, 0.7, 0.75),
	"RARE": Color(0.4, 0.6, 0.95),
	"SPECIAL": Color(0.75, 0.5, 0.95),
	"LEGENDARY": Color(0.95, 0.75, 0.2),
}
const COLOR_ATK := Color(0.95, 0.7, 0.25)
const COLOR_DEF := Color(0.35, 0.6, 0.95)

func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	equip_btn.pressed.connect(_on_equip)
	unequip_btn.pressed.connect(_on_unequip)
	if enhance_btn:
		enhance_btn.pressed.connect(_on_enhance)
	_apply_button_styles()
	_apply_panel_sprite()

func _apply_panel_sprite() -> void:
	# modal_frame.png → ContentPanel 배경 (NinePatch patch=18)
	var content_panel := get_node_or_null("ContentPanel")
	UISprites.apply_panel(content_panel, UISprites.modal_frame(), 18)

func _apply_button_styles() -> void:
	if UISprites.btn_tex("primary") != null:
		UISprites.apply_btn(equip_btn, "primary")
		UISprites.apply_btn(unequip_btn, "red")
		UISprites.apply_btn(enhance_btn, "purple")
		UISprites.apply_btn(close_btn, "secondary")
	else:
		_fallback_button_styles()

func _fallback_button_styles() -> void:
	var s_equip := StyleBoxFlat.new()
	s_equip.bg_color = Color(0.2, 0.45, 0.85)
	s_equip.set_corner_radius_all(8)
	equip_btn.add_theme_stylebox_override("normal", s_equip)
	equip_btn.add_theme_color_override("font_color", Color.WHITE)
	var s_unequip := StyleBoxFlat.new()
	s_unequip.bg_color = Color(0.7, 0.25, 0.25)
	s_unequip.set_corner_radius_all(8)
	unequip_btn.add_theme_stylebox_override("normal", s_unequip)
	unequip_btn.add_theme_color_override("font_color", Color.WHITE)
	var s_enhance := StyleBoxFlat.new()
	s_enhance.bg_color = Color(0.45, 0.25, 0.7)
	s_enhance.set_corner_radius_all(8)
	enhance_btn.add_theme_stylebox_override("normal", s_enhance)
	enhance_btn.add_theme_color_override("font_color", Color.WHITE)
	var s_close := StyleBoxFlat.new()
	s_close.bg_color = Color(0.4, 0.4, 0.45)
	s_close.set_corner_radius_all(8)
	close_btn.add_theme_stylebox_override("normal", s_close)
	close_btn.add_theme_color_override("font_color", Color.WHITE)

func show_item(item: Equipment, is_equipped: bool) -> void:
	_item = item
	_is_equipped = is_equipped
	var name_str = item.name_ko if item.name_ko else item.name
	title_label.text = name_str
	icon_label.text = SLOT_ICONS.get(item.slot, "⚔")
	var rar = RARITY_NAMES.get(item.rarity, item.rarity)
	meta_row.text = "%s • %s • LV %d" % [rar, TYPE_NAMES.get(item.slot, item.slot), mini(item.enhancement_level + 1, 10)]
	meta_row.add_theme_color_override("font_color", RARITY_COLORS.get(item.rarity, Color.WHITE))
	atk_value.text = "+%d" % int(item.get_total_atk())
	atk_value.add_theme_color_override("font_color", COLOR_ATK)
	def_value.text = "+%d" % int(item.get_total_def())
	def_value.add_theme_color_override("font_color", COLOR_DEF)
	# 치명타율 — 무기/OFF_HAND에만 표시
	var cri = item.get_total_cri() if item.has_method("get_total_cri") else 0.0
	if cri_stat_box:
		cri_stat_box.visible = cri > 0.0
		if cri > 0.0 and cri_value:
			cri_value.text = "%.1f%%" % cri
	skill_name_label.text = name_str
	skill_desc_label.text = "특별한 능력이 없습니다."
	_build_options(item)
	usage_value.text = "0/10"
	equip_btn.visible = not _is_equipped
	unequip_btn.visible = _is_equipped
	visible = true

func _build_options(item: Equipment) -> void:
	for c in options_list.get_children():
		c.queue_free()
	var lines: Array[String] = []
	if item.get_total_hp() > 0:
		lines.append("+ 체력 %d" % int(item.get_total_hp()))
	if item.get_total_spd() > 0:
		lines.append("+ 속도 %.1f" % item.get_total_spd())
	if lines.is_empty():
		lines.append("(없음)")
	for line in lines:
		var l = Label.new()
		l.text = line
		l.add_theme_font_size_override("font_size", 12)
		l.add_theme_color_override("font_color", Color(0.75, 0.85, 0.65))
		options_list.add_child(l)

func _on_close() -> void:
	visible = false
	closed.emit()

func _on_equip() -> void:
	if _item:
		equip_requested.emit(_item)
	visible = false

func _on_unequip() -> void:
	if _item:
		unequip_requested.emit(_item)
	visible = false

func _on_enhance() -> void:
	pass
