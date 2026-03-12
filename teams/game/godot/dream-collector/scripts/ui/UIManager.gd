# UIManager.gd
# UI 스프라이트 텍스처 관리 싱글톤
# res://assets/ui/sprites/ 하위 스프라이트 일괄 관리
# (기존 godot_ui_sprites/ 경로 제거 → assets/ui/sprites/ 통합)

extends Node

const UI_PATH = "res://assets/ui/sprites/"

# ─── 텍스처 경로 테이블 ──────────────────────────────
const BTN_TEXTURES = {
	"primary":   "buttons/btn_primary.svg",
	"secondary": "buttons/btn_secondary.svg",
	"green":     "buttons/btn_green.svg",
	"purple":    "buttons/btn_purple.svg",
	"red":       "buttons/btn_red.svg",
	"disabled":  "buttons/btn_disabled.svg",
}

const CARD_TEXTURES = {
	"Attack": "cards/card_attack.svg",
	"Skill":  "cards/card_skill.svg",
	"Power":  "cards/card_power.svg",
	"Curse":  "cards/card_curse.svg",
}

# items/ → slots/ (파일명 변경)
const ITEM_SLOT_TEXTURES = {
	"COMMON":    "slots/slot_normal.svg",
	"RARE":      "slots/slot_rare.svg",
	"SPECIAL":   "slots/slot_epic.svg",
	"EPIC":      "slots/slot_epic.svg",
	"LEGENDARY": "slots/slot_legend.svg",
	"EMPTY":     "slots/slot_empty.svg",
}

# ui_panels/dream_*.svg → lists/list_item_*.svg
const DREAM_TEXTURES = {
	"common": "lists/list_item_normal.svg",
	"rare":   "lists/list_item_rare.svg",
	"epic":   "lists/list_item_legend.svg",
}

# ui_panels/panel.svg 등 → panels/, hud/, bars/, tabs/, badges/ 로 분산
const PANEL_TEXTURES = {
	"panel":       "panels/panel_frame.svg",
	"modal":       "panels/modal_frame.svg",
	"dark":        "panels/panel_dark.svg",
	"tooltip":     "panels/tooltip_frame.svg",
	"hud":         "hud/hud_frame.svg",
	"hud_pill":    "hud/hud_pill.svg",
	"section":     "hud/section_header.svg",
	"tab_nav":     "tabs/tab_bar_frame.svg",
	"tab_active":  "tabs/tab_active_bg.svg",
	"stat_hp":     "bars/bar_fill_hp.svg",
	"stat_mana":   "bars/bar_fill_mana.svg",
	"stat_exp":    "bars/bar_fill_exp.svg",
	"bar_track":   "bars/bar_track.svg",
	"coin":        "badges/coin_badge.svg",
	"notif":       "badges/notif_badge.svg",
	"divider":     "misc/divider_gold.svg",
}

# ─── 내부 로더 ───────────────────────────────────────
func _load_tex(rel: String) -> Texture2D:
	var path := UI_PATH + rel
	if ResourceLoader.exists(path):
		return load(path)
	push_warning("[UIManager] 텍스처 없음: " + path)
	return null

# ─── 텍스처 게터 ─────────────────────────────────────
func get_button_texture(type: String) -> Texture2D:
	return _load_tex(BTN_TEXTURES.get(type, BTN_TEXTURES["primary"]))

func get_card_texture(card_type: String) -> Texture2D:
	# "Attack"/"attack"/"ATTACK" 모두 허용
	var key := card_type.to_lower().capitalize()
	return _load_tex(CARD_TEXTURES.get(key, CARD_TEXTURES["Attack"]))

func get_item_slot_texture(rarity: String) -> Texture2D:
	return _load_tex(ITEM_SLOT_TEXTURES.get(rarity, ITEM_SLOT_TEXTURES["EMPTY"]))

func get_dream_texture(rarity: String) -> Texture2D:
	return _load_tex(DREAM_TEXTURES.get(rarity.to_lower(), DREAM_TEXTURES["common"]))

func get_panel_texture(type: String) -> Texture2D:
	return _load_tex(PANEL_TEXTURES.get(type, PANEL_TEXTURES["panel"]))

# ─── 버튼 스프라이트 적용 ────────────────────────────
# UISprites.apply_btn에 위임 (hover=밝게, pressed=어둡게)
func apply_button_sprite(button: Button, type: String = "primary") -> void:
	if button == null:
		return
	var t := get_button_texture(type)
	if t == null:
		return
	var normal_sb := _make_btn_stylebox(t, Color(1, 1, 1, 1))
	var hover_sb  := _make_btn_stylebox(t, Color(1.15, 1.15, 1.15, 1))
	var press_sb  := _make_btn_stylebox(t, Color(0.8, 0.8, 0.8, 1))
	var dis_sb    := _make_btn_stylebox(t, Color(0.55, 0.55, 0.55, 0.7))
	button.add_theme_stylebox_override("normal",   normal_sb)
	button.add_theme_stylebox_override("hover",    hover_sb)
	button.add_theme_stylebox_override("pressed",  press_sb)
	button.add_theme_stylebox_override("focus",    normal_sb)
	button.add_theme_stylebox_override("disabled", dis_sb)
	button.add_theme_color_override("font_color", Color.WHITE)

func _make_btn_stylebox(tex: Texture2D, tint: Color) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture             = tex
	sb.texture_margin_left  = 40
	sb.texture_margin_right = 40
	sb.texture_margin_top   = 14
	sb.texture_margin_bottom = 14
	sb.content_margin_left  = 16
	sb.content_margin_right = 16
	sb.content_margin_top   = 8
	sb.content_margin_bottom = 8
	sb.modulate_color = tint
	return sb

# ─── 꿈 아이템 StyleBoxTexture 생성 ─────────────────
func create_dream_stylebox(rarity: String) -> StyleBoxTexture:
	var t := get_dream_texture(rarity)
	if t == null:
		return StyleBoxTexture.new()
	var sb := StyleBoxTexture.new()
	sb.texture              = t
	sb.texture_margin_left  = 12
	sb.texture_margin_right = 12
	sb.texture_margin_top   = 12
	sb.texture_margin_bottom = 12
	sb.content_margin_left  = 8
	sb.content_margin_right = 8
	sb.content_margin_top   = 8
	sb.content_margin_bottom = 8
	return sb

# ─── 카드 UI TextureRect 생성 ────────────────────────
func create_card_ui(card_data: Dictionary) -> Control:
	var container := TextureRect.new()
	container.texture      = get_card_texture(card_data.get("type", "Attack"))
	container.expand_mode  = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	container.custom_minimum_size = Vector2(90, 146)
	return container

# ─── 아이템 슬롯 NinePatchRect 생성 ─────────────────
func create_item_slot(rarity: String = "COMMON") -> NinePatchRect:
	var np := NinePatchRect.new()
	np.texture             = get_item_slot_texture(rarity)
	np.patch_margin_left   = 12
	np.patch_margin_right  = 12
	np.patch_margin_top    = 12
	np.patch_margin_bottom = 12
	np.custom_minimum_size = Vector2(64, 64)
	return np
