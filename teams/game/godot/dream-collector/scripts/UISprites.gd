# UISprites.gd — UI 스프라이트 유틸리티 (정적 클래스)
# manifest.json 기준: @2x 이미지 (Godot Import Settings → scale=0.5 권장)
# nine_patch_guide: panels=18, buttons=40(좌우)/14(상하), slots=12, bars=9/0, tabs=18/12

class_name UISprites
extends RefCounted

const BASE := "res://assets/ui/sprites/"

# ── 텍스처 로드 ──────────────────────────────────────────────────────
static func tex(rel: String) -> Texture2D:
	var path := BASE + rel
	if ResourceLoader.exists(path):
		return load(path)
	return null

# ── 패널 텍스처 ──────────────────────────────────────────────────────
static func panel_frame()    -> Texture2D: return tex("panels/panel_frame.svg")
static func panel_dark()     -> Texture2D: return tex("panels/panel_dark.svg")
static func modal_frame()    -> Texture2D: return tex("panels/modal_frame.svg")
static func tooltip_frame()  -> Texture2D: return tex("panels/tooltip_frame.svg")
static func hud_frame()      -> Texture2D: return tex("hud/hud_frame.svg")
static func hud_pill()       -> Texture2D: return tex("hud/hud_pill.svg")
static func section_hdr()    -> Texture2D: return tex("hud/section_header.svg")

# ── 버튼 텍스처 (variant: primary/secondary/green/purple/red/disabled) ──
static func btn_tex(variant: String) -> Texture2D:
	match variant:
		"primary":   return tex("buttons/btn_primary.svg")
		"secondary": return tex("buttons/btn_secondary.svg")
		"green":     return tex("buttons/btn_green.svg")
		"purple":    return tex("buttons/btn_purple.svg")
		"red":       return tex("buttons/btn_red.svg")
		"disabled":  return tex("buttons/btn_disabled.svg")
	return null

# ── 슬롯 텍스처 (희귀도별) ──────────────────────────────────────────
static func slot_tex(rarity: String) -> Texture2D:
	match rarity:
		"COMMON":              return tex("slots/slot_normal.svg")
		"RARE":                return tex("slots/slot_rare.svg")
		"SPECIAL", "EPIC":     return tex("slots/slot_epic.svg")
		"LEGENDARY":           return tex("slots/slot_legend.svg")
	return tex("slots/slot_empty.svg")

# ── 탭 텍스처 ──────────────────────────────────────────────────────
static func tab_bar()        -> Texture2D: return tex("tabs/tab_bar_frame.svg")
static func tab_active_bg()  -> Texture2D: return tex("tabs/tab_active_bg.svg")

# ── 바 텍스처 ──────────────────────────────────────────────────────
static func bar_track()      -> Texture2D: return tex("bars/bar_track.svg")
static func bar_hp()         -> Texture2D: return tex("bars/bar_fill_hp.svg")
static func bar_mana()       -> Texture2D: return tex("bars/bar_fill_mana.svg")
static func bar_exp()        -> Texture2D: return tex("bars/bar_fill_exp.svg")

# ── 카드 프레임 (type: Attack/Skill/Power/Curse, 대소문자 무관) ──
static func card_tex(card_type: String) -> Texture2D:
	match card_type.to_lower():
		"attack": return tex("cards/card_attack.svg")
		"skill":  return tex("cards/card_skill.svg")
		"power":  return tex("cards/card_power.svg")
		"curse":  return tex("cards/card_curse.svg")
	return tex("cards/card_attack.svg")

static func card_cost_badge() -> Texture2D: return tex("cards/card_cost_badge.svg")

# ── 꿈/리스트 아이템 패널 (rarity: common/rare/epic/legend) ────────
static func list_tex(rarity: String) -> Texture2D:
	match rarity.to_lower():
		"rare":                         return tex("lists/list_item_rare.svg")
		"epic", "legend", "legendary":  return tex("lists/list_item_legend.svg")
	return tex("lists/list_item_normal.svg")

static func list_stylebox(rarity: String) -> StyleBoxTexture:
	var sb := make_stylebox(list_tex(rarity), 12)
	if sb:
		sb.content_margin_left   = 8
		sb.content_margin_right  = 8
		sb.content_margin_top    = 8
		sb.content_margin_bottom = 8
	return sb

# ── 기타 ──────────────────────────────────────────────────────────
static func divider_gold()   -> Texture2D: return tex("misc/divider_gold.svg")
static func divider_subtle() -> Texture2D: return tex("misc/divider_subtle.svg")
static func coin_badge()     -> Texture2D: return tex("badges/coin_badge.svg")

# ──────────────────────────────────────────────────────────────────────────
# StyleBoxTexture 생성 — PanelContainer/Button 스타일 오버라이드용
# texture_margin_* 은 소스 픽셀 기준 (import scale=0.5 → manifest 값 그대로 사용)
# ──────────────────────────────────────────────────────────────────────────
static func make_stylebox(texture: Texture2D,
		v_margin: int, h_margin: int = -1,
		content_pad: int = 0) -> StyleBoxTexture:
	if texture == null:
		return null
	var sb := StyleBoxTexture.new()
	sb.texture              = texture
	sb.texture_margin_top    = v_margin
	sb.texture_margin_bottom = v_margin
	sb.texture_margin_left   = h_margin if h_margin >= 0 else v_margin
	sb.texture_margin_right  = h_margin if h_margin >= 0 else v_margin
	if content_pad > 0:
		sb.content_margin_left   = content_pad
		sb.content_margin_right  = content_pad
		sb.content_margin_top    = content_pad
		sb.content_margin_bottom = content_pad
	return sb

# 슬롯 StyleBoxTexture (Button.add_theme_stylebox_override 적용용)
static func slot_stylebox(rarity: String) -> StyleBoxTexture:
	return make_stylebox(slot_tex(rarity), 12)

# ──────────────────────────────────────────────────────────────────────────
# apply_panel — PanelContainer 배경 텍스처 교체
#   ‣ panel StyleBox를 StyleBoxTexture로 교체
#   ‣ margin: manifest 기준 (panels=18, modal=18, tooltip=10)
# ──────────────────────────────────────────────────────────────────────────
static func apply_panel(panel: Control, texture: Texture2D, margin: int = 18) -> void:
	if panel == null or texture == null:
		return
	var sb := make_stylebox(texture, margin)
	if sb:
		panel.add_theme_stylebox_override("panel", sb)

# ──────────────────────────────────────────────────────────────────────────
# NinePatchRect 생성 — 컨테이너 배경 삽입용
# ──────────────────────────────────────────────────────────────────────────
static func make_ninepatch(texture: Texture2D,
		v_margin: int, h_margin: int = -1) -> NinePatchRect:
	if texture == null:
		return null
	var np := NinePatchRect.new()
	np.texture             = texture
	np.patch_margin_top    = v_margin
	np.patch_margin_bottom = v_margin
	np.patch_margin_left   = h_margin if h_margin >= 0 else v_margin
	np.patch_margin_right  = h_margin if h_margin >= 0 else v_margin
	np.mouse_filter = Control.MOUSE_FILTER_IGNORE
	np.layout_mode  = 1  # Anchors
	np.set_anchors_preset(Control.PRESET_FULL_RECT)
	np.offset_left   = 0.0
	np.offset_top    = 0.0
	np.offset_right  = 0.0
	np.offset_bottom = 0.0
	return np

# node의 첫 번째 자식으로 NinePatch 배경 삽입 (기존 _np_bg 교체)
static func apply_bg(node: Control, texture: Texture2D,
		v_margin: int, h_margin: int = -1) -> NinePatchRect:
	if texture == null or node == null:
		return null
	var old := node.get_node_or_null("_np_bg")
	if old:
		old.queue_free()
	var np := make_ninepatch(texture, v_margin, h_margin)
	np.name = "_np_bg"
	node.add_child(np)
	node.move_child(np, 0)
	return np

# ──────────────────────────────────────────────────────────────────────────
# apply_btn — Button에 NinePatch 텍스처 StyleBox 적용
#   ‣ StyleBoxTexture로 normal/hover/pressed 모두 교체
#   ‣ 버튼 마진: 좌우 40, 상하 14 (manifest 기준, @2x 이미지)
#   ‣ content_margin: 텍스트 내부 여백 (좌우 20, 상하 8)
# ──────────────────────────────────────────────────────────────────────────
static func apply_btn(btn: Button, variant: String) -> void:
	if btn == null:
		return
	var t := btn_tex(variant)
	if t == null:
		return
	var sb_normal := _make_btn_sb(t, Color(1.0,  1.0,  1.0,  1.0))
	var sb_hover  := _make_btn_sb(t, Color(1.15, 1.15, 1.15, 1.0))
	var sb_press  := _make_btn_sb(t, Color(0.82, 0.82, 0.82, 1.0))
	btn.add_theme_stylebox_override("normal",   sb_normal)
	btn.add_theme_stylebox_override("hover",    sb_hover)
	btn.add_theme_stylebox_override("pressed",  sb_press)
	btn.add_theme_stylebox_override("focus",    sb_normal)
	btn.add_theme_stylebox_override("disabled", _make_btn_sb(t, Color(0.5, 0.5, 0.5, 0.7)))
	btn.add_theme_color_override("font_color",  Color.WHITE)

static func _make_btn_sb(texture: Texture2D, tint: Color) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture              = texture
	# @2x 이미지 기준 9-patch 마진 (manifest: h=40, v=14)
	sb.texture_margin_left   = 40
	sb.texture_margin_right  = 40
	sb.texture_margin_top    = 14
	sb.texture_margin_bottom = 14
	# 텍스트/아이콘 내부 여백
	sb.content_margin_left   = 20
	sb.content_margin_right  = 20
	sb.content_margin_top    = 8
	sb.content_margin_bottom = 8
	sb.modulate_color = tint
	return sb

# ──────────────────────────────────────────────────────────────────────────
# apply_tab_active — 탭 버튼에 활성 배경 적용/제거
# ──────────────────────────────────────────────────────────────────────────
static func apply_tab_active(btn: Button, active: bool) -> void:
	if btn == null:
		return
	if active:
		var sb := make_stylebox(tab_active_bg(), 12, -1, 8)
		if sb:
			btn.add_theme_stylebox_override("normal",  sb)
			btn.add_theme_stylebox_override("hover",   sb)
			btn.add_theme_stylebox_override("pressed", sb)
	else:
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_stylebox_override("hover")
		btn.remove_theme_stylebox_override("pressed")

# ──────────────────────────────────────────────────────────────────────────
# apply_bar — ProgressBar에 bar_track + bar_fill 스프라이트 적용
#   ‣ fill_type: "hp" | "mana" | "exp"
#   ‣ bars: patch_margin 9 (좌우), 0 (상하)
# ──────────────────────────────────────────────────────────────────────────
static func apply_bar(bar: ProgressBar, fill_type: String = "hp") -> void:
	if bar == null:
		return
	var fill_tex: Texture2D
	match fill_type:
		"hp":   fill_tex = bar_hp()
		"mana": fill_tex = bar_mana()
		"exp":  fill_tex = bar_exp()
		_:      fill_tex = bar_hp()
	var track_sb := make_stylebox(bar_track(), 0, 9)
	var fill_sb := make_stylebox(fill_tex, 0, 9)
	if track_sb:
		bar.add_theme_stylebox_override("background", track_sb)
	if fill_sb:
		bar.add_theme_stylebox_override("fill", fill_sb)
