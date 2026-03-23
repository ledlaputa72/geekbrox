# UISprites.gd — UI 스프라이트 유틸리티 (정적 클래스)
# UI Pack PNG (button_rectangle_depth_flat 192×64, button_square_flat 64×64)
# nine_patch_guide: panels=6, buttons=6, slots=6 (UI Pack 기준)

class_name UISprites
extends RefCounted

const BASE    := "res://assets/ui/sprites/"
const UIPACK  := "res://assets/ui/UI Pack/PNG/"

# NinePatch 마진 상수
const MARGIN_BTN    := 6   # button_rectangle_depth_flat 코너
const MARGIN_PANEL  := 6   # button_rectangle_flat 코너
const MARGIN_SLOT   := 6   # button_square_flat 코너

# ── 텍스처 로드 ──────────────────────────────────────────────────────
static func tex(rel: String) -> Texture2D:
	var path: String = BASE + rel
	if ResourceLoader.exists(path):
		return load(path)
	return null

# UI Pack 헬퍼: button_rectangle (192×64)
static func uipack_btn(color: String, pressed: bool = false) -> Texture2D:
	var style := "button_rectangle_flat" if pressed else "button_rectangle_depth_flat"
	var path := UIPACK + color + "/Default/" + style + ".png"
	if ResourceLoader.exists(path):
		return load(path)
	return null

# UI Pack 헬퍼: button_rectangle_flat (패널용, depth 없음)
static func uipack_rect(color: String) -> Texture2D:
	var path := UIPACK + color + "/Default/button_rectangle_flat.png"
	if ResourceLoader.exists(path):
		return load(path)
	return null

# UI Pack 헬퍼: button_square_flat (슬롯용, 64×64)
static func uipack_sq(color: String) -> Texture2D:
	var path := UIPACK + color + "/Default/button_square_flat.png"
	if ResourceLoader.exists(path):
		return load(path)
	return null

# UI Pack 헬퍼: button_round_depth_flat (원형 배지용)
static func uipack_round(color: String) -> Texture2D:
	var path := UIPACK + color + "/Default/button_round_depth_flat.png"
	if ResourceLoader.exists(path):
		return load(path)
	return null

# 카드 코스트 배지 텍스처: Grey 원형
static func cost_badge_tex() -> Texture2D: return uipack_round("Grey")

# ── 패널 텍스처 (UI Pack button_rectangle_flat) ────────────────────
# Grey = 중립 패널, Blue = 강조/HUD, 모달/툴팁은 Grey 기반
static func panel_frame()    -> Texture2D: return uipack_rect("Grey")
static func panel_dark()     -> Texture2D: return uipack_rect("Blue")
static func modal_frame()    -> Texture2D: return uipack_rect("Grey")
static func tooltip_frame()  -> Texture2D: return uipack_rect("Grey")
static func hud_frame()      -> Texture2D: return uipack_rect("Blue")
static func hud_pill()       -> Texture2D: return tex("hud/hud_pill.svg")
static func section_hdr()    -> Texture2D: return tex("hud/section_header.svg")

# ── 버튼 텍스처 (UI Pack PNG: 192×64, button_rectangle_depth_flat) ──
# Normal 상태 (depth 그림자 있음)
static func btn_tex(variant: String) -> Texture2D:
	match variant:
		"primary":   return uipack_btn("Blue")
		"secondary": return uipack_btn("Grey")
		"green":     return uipack_btn("Green")
		"purple":    return uipack_btn("Blue")   # 보라색 없음 → 파랑 대체
		"red":       return uipack_btn("Red")
		"yellow":    return uipack_btn("Yellow")
		"disabled":  return uipack_btn("Grey", true)  # 눌린 상태로 비활성 표현
	return uipack_btn("Blue")

# Pressed 상태 (depth 없는 flat, 눌린 느낌)
static func btn_pressed_tex(variant: String) -> Texture2D:
	match variant:
		"primary":   return uipack_btn("Blue",   true)
		"secondary": return uipack_btn("Grey",   true)
		"green":     return uipack_btn("Green",  true)
		"purple":    return uipack_btn("Blue",   true)
		"red":       return uipack_btn("Red",    true)
		"yellow":    return uipack_btn("Yellow", true)
		"disabled":  return uipack_btn("Grey",   true)
	return uipack_btn("Blue", true)

# ── 슬롯 텍스처 (UI Pack button_square_flat 64×64, 희귀도별 4색) ──
# 일반=Grey / 레어=Blue / 에픽=Red / 전설=Yellow  (각 색상 PNG 직접 사용)
static func slot_tex(rarity: String) -> Texture2D:
	match rarity:
		"COMMON":          return uipack_sq("Grey")    # 일반 — 회색
		"RARE":            return uipack_sq("Blue")    # 레어 — 파랑
		"SPECIAL","EPIC":  return uipack_sq("Red")     # 에픽 — 빨강
		"LEGENDARY":       return uipack_sq("Yellow")  # 전설 — 황금
	return uipack_sq("Grey")

# 슬롯 modulate — 직접 색상 PNG 사용으로 불필요. 항상 WHITE 반환
static func slot_modulate(_rarity: String) -> Color:
	return Color.WHITE

# ── 탭 텍스처 ──────────────────────────────────────────────────────
static func tab_bar()        -> Texture2D: return tex("tabs/tab_bar_frame.svg")
static func tab_active_bg()  -> Texture2D: return tex("tabs/tab_active_bg.svg")

# ── 바 텍스처 ──────────────────────────────────────────────────────
static func bar_track()      -> Texture2D: return tex("bars/bar_track.svg")
static func bar_track_thin() -> Texture2D: return tex("bars/bar_track_thin.svg")
static func bar_hp()         -> Texture2D: return tex("bars/bar_fill_hp.svg")
static func bar_mana()       -> Texture2D: return tex("bars/bar_fill_mana.svg")
static func bar_exp()        -> Texture2D: return tex("bars/bar_fill_exp.svg")
static func bar_atb()        -> Texture2D: return tex("bars/bar_fill_atb.svg")

# ── 카드 프레임 (type: Attack/Skill/Power/Curse, 대소문자 무관) ──
static func card_tex(card_type: String) -> Texture2D:
	match card_type.to_lower():
		"attack": return tex("cards/card_attack.svg")
		"skill":  return tex("cards/card_skill.svg")
		"power":  return tex("cards/card_power.svg")
		"curse":  return tex("cards/card_curse.svg")
	return tex("cards/card_attack.svg")

static func card_cost_badge() -> Texture2D: return tex("cards/card_cost_badge.svg")

# ── 카드 UI Pack 텍스처 (타입별 4색, UI Pack PNG) ──────────────────────
# 카드 외곽 프레임: 타입 색상 button_rectangle_flat
# Attack=Red / Skill=Green / Power=Blue / Curse=Yellow
static func card_frame_tex(card_type: String) -> Texture2D:
	match card_type.to_lower():
		"attack": return uipack_rect("Red")
		"skill":  return uipack_rect("Green")
		"power":  return uipack_rect("Blue")
		"curse":  return uipack_rect("Yellow")
	return uipack_rect("Grey")

# 카드 아트 영역 배경: 타입 색상 button_square_flat (rect로 stretch)
static func card_sq_tex(card_type: String) -> Texture2D:
	match card_type.to_lower():
		"attack": return uipack_sq("Red")
		"skill":  return uipack_sq("Green")
		"power":  return uipack_sq("Blue")
		"curse":  return uipack_sq("Yellow")
	return uipack_sq("Grey")

# ── 꿈/리스트 아이템 패널 (UI Pack button_rectangle_flat, 희귀도 4색) ──
# 일반=Grey / 레어=Blue / 에픽=Red / 전설=Yellow
static func list_tex(rarity: String) -> Texture2D:
	match rarity.to_lower():
		"rare":                  return uipack_rect("Blue")
		"special","epic":        return uipack_rect("Red")
		"legend","legendary":    return uipack_rect("Yellow")
	return uipack_rect("Grey")

static func list_stylebox(rarity: String) -> StyleBoxTexture:
	var sb := make_stylebox(list_tex(rarity), MARGIN_PANEL)
	if sb:
		sb.content_margin_left   = 10
		sb.content_margin_right  = 10
		sb.content_margin_top    = 10
		sb.content_margin_bottom = 10
	return sb

# ── 기타 ──────────────────────────────────────────────────────────
static func divider_gold()   -> Texture2D: return tex("misc/divider_gold.svg")
static func divider_subtle() -> Texture2D: return tex("misc/divider_subtle.svg")
static func coin_badge()     -> Texture2D: return tex("badges/coin_badge.svg")

# ──────────────────────────────────────────────────────────────────────────
# StyleBoxTexture 생성 — PanelContainer/Button 스타일 오버라이드용
# texture_margin_* 은 소스 픽셀 기준
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

# 슬롯 StyleBoxTexture (UI Pack button_square_flat: margin 6, 희귀도 modulate)
static func slot_stylebox(rarity: String) -> StyleBoxTexture:
	var sb := make_stylebox(slot_tex(rarity), MARGIN_SLOT)
	if sb:
		sb.modulate_color = slot_modulate(rarity)
	return sb

# ──────────────────────────────────────────────────────────────────────────
# apply_panel — PanelContainer 배경 텍스처 교체
#   ‣ panel StyleBox를 StyleBoxTexture로 교체 (SVG UI: margin 18)
# ──────────────────────────────────────────────────────────────────────────
static func apply_panel(panel: Control, texture: Texture2D, margin: int = MARGIN_PANEL) -> void:
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
#   SVG 버튼: 300×80px, rx=24 (24px 코너 반경)
#   ‣ L/R 마진 30px: 좌우 둥근 캡(24px 반경) 보존
#   ‣ T/B 마진 20px: 상하 아크 형태 보존 (최소 높이 52px 필요)
#   ‣ 버튼 최소 높이 52px 자동 설정
# ──────────────────────────────────────────────────────────────────────────
static func apply_btn(btn: Button, variant: String) -> void:
	if btn == null:
		return
	# UI Pack PNG: button_rectangle_depth_flat (192×64) — 플랫 직사각형 스타일
	var t_normal  := btn_tex(variant)
	var t_pressed := btn_pressed_tex(variant)
	if t_normal == null:
		return
	if t_pressed == null:
		t_pressed = t_normal
	btn.add_theme_stylebox_override("normal",   _make_btn_sb(t_normal,  Color(1.0,  1.0,  1.0,  1.0)))
	btn.add_theme_stylebox_override("hover",    _make_btn_sb(t_normal,  Color(1.08, 1.08, 1.08, 1.0)))
	btn.add_theme_stylebox_override("pressed",  _make_btn_sb(t_pressed, Color(1.0,  1.0,  1.0,  1.0)))
	btn.add_theme_stylebox_override("focus",    _make_btn_sb(t_normal,  Color(1.0,  1.0,  1.0,  1.0)))
	btn.add_theme_stylebox_override("disabled", _make_btn_sb(t_pressed, Color(0.6,  0.6,  0.6,  0.7)))
	btn.add_theme_color_override("font_color",  Color.WHITE)
	btn.add_theme_font_size_override("font_size", 15)

static func _make_btn_sb(texture: Texture2D, tint: Color) -> StyleBoxTexture:
	var sb := StyleBoxTexture.new()
	sb.texture               = texture
	# UI Pack button_rectangle_depth_flat: 192×64px
	# 코너 반경 ~6px, depth 그림자 ~5px (하단)
	sb.texture_margin_left   = 6
	sb.texture_margin_right  = 6
	sb.texture_margin_top    = 6
	sb.texture_margin_bottom = 6
	# 내부 텍스트 여백
	sb.content_margin_left   = 14
	sb.content_margin_right  = 14
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
		var sb := make_stylebox(tab_active_bg(), 8, -1, 8)
		if sb:
			btn.add_theme_stylebox_override("normal",  sb)
			btn.add_theme_stylebox_override("hover",   sb)
			btn.add_theme_stylebox_override("pressed", sb)
	else:
		btn.remove_theme_stylebox_override("normal")
		btn.remove_theme_stylebox_override("hover")
		btn.remove_theme_stylebox_override("pressed")

# ──────────────────────────────────────────────────────────────────────────
# apply_bar — ProgressBar에 SVG UI bar_track + bar_fill 적용
#   ‣ fill_type: "hp" | "mana" | "exp" | "atb"
#   ‣ SVG UI: margin 2 (좌우)
# ──────────────────────────────────────────────────────────────────────────
static func apply_bar(bar: ProgressBar, fill_type: String = "hp") -> void:
	if bar == null:
		return
	var fill_tex: Texture2D
	match fill_type:
		"hp":   fill_tex = bar_hp()
		"mana": fill_tex = bar_mana()
		"exp":  fill_tex = bar_exp()
		"atb":  fill_tex = bar_atb()
		_:      fill_tex = bar_hp()
	var track_sb := make_stylebox(bar_track(), 2, 4)
	var fill_sb := make_stylebox(fill_tex, 2, 4)
	if track_sb:
		bar.add_theme_stylebox_override("background", track_sb)
	if fill_sb:
		bar.add_theme_stylebox_override("fill", fill_sb)
