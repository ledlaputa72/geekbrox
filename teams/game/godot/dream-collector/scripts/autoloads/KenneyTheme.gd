## KenneyTheme.gd
## Dream Collector — Kenney Blue Pack + Custom SVG 통합 UI 헬퍼
## Project Settings > Autoloads > KenneyTheme 으로 등록
##
## 사용법:
##   KenneyTheme.apply_button($MyButton, KenneyTheme.BTN_PRIMARY)
##   KenneyTheme.apply_ninepatch($MyPanel)
##   KenneyTheme.apply_icon($CloseBtn, KenneyTheme.ICON_CROSS)

extends Node

# ─────────────────────────────────────────
# 설정값 (프리뷰어에서 확인한 값으로 통일)
# ─────────────────────────────────────────
const PATCH_WIDE    := 10   # 와이드 버튼 / 패널
const PATCH_SQUARE  := 10   # 스퀘어 버튼 / 아이콘
const PATCH_PANEL   := 10   # 패널 / 팝업 배경
const PATCH_SLOT    := 10   # 아이템 슬롯 (SVG)
const PATCH_SVG_BTN := 10   # SVG 버튼 (btn_primary 등)

const SHEET_PATH := "res://assets/ui/sprites/kenney/sheet.png"
# 프로젝트의 실제 SVG 루트 경로 (svg/ 서브폴더 없음)
const SVG_ROOT   := "res://assets/ui/sprites/"

# ─────────────────────────────────────────
# Kenney Blue Pack 스프라이트 좌표 (blueSheet.xml)
# Rect2(x, y, width, height)
# ─────────────────────────────────────────
enum SpriteKey {
	BTN_WIDE_NORMAL_A,    # blue_button00 — 일반 확인버튼 Normal
	BTN_WIDE_PRESSED_A,   # blue_button01 — 일반 확인버튼 Pressed
	BTN_WIDE_NORMAL_B,    # blue_button02 — 보조버튼 Normal
	BTN_WIDE_PRESSED_B,   # blue_button03 — 보조버튼 Pressed
	BTN_PRIMARY,          # blue_button04 — CTA 메인 Normal
	BTN_PRIMARY_PRESSED,  # blue_button05 — CTA 메인 Pressed
	BTN_SQ_A,             # blue_button06 — 스퀘어 Normal A
	BTN_SQ_B,             # blue_button07 — 스퀘어 Normal B
	BTN_SQ_PRESSED,       # blue_button08 — 스퀘어 Pressed
	BTN_NAV,              # blue_button09 — 네비게이션 Normal
	BTN_NAV_PRESSED,      # blue_button10 — 네비게이션 Pressed
	BTN_ICON_BORDER,      # blue_button11 — 아이콘 테두리 Normal
	BTN_ICON_PRESSED,     # blue_button12 — 아이콘 테두리 Pressed
	BTN_INPUT,            # blue_button13 — 입력창 / 패시브 배경
	PANEL,                # blue_panel — 모든 패널 배경
	ICON_CHECKMARK_BOX,   # blue_boxCheckmark
	ICON_CROSS_BOX,       # blue_boxCross
	ICON_TICK_BOX,        # blue_boxTick
	ICON_CHECKMARK,       # blue_checkmark
	ICON_CROSS,           # blue_cross
	ICON_TICK,            # blue_tick
	ICON_CIRCLE,          # blue_circle
	SLIDER_DOWN,          # blue_sliderDown
	SLIDER_LEFT,          # blue_sliderLeft
	SLIDER_RIGHT,         # blue_sliderRight
	SLIDER_UP,            # blue_sliderUp
}

# XML 좌표 테이블 [x, y, w, h]
const SPRITE_RECTS: Dictionary = {
	SpriteKey.BTN_WIDE_NORMAL_A:   [0,   94,  190, 49],
	SpriteKey.BTN_WIDE_PRESSED_A:  [190, 49,  190, 45],
	SpriteKey.BTN_WIDE_NORMAL_B:   [190, 0,   190, 49],
	SpriteKey.BTN_WIDE_PRESSED_B:  [0,   49,  190, 45],
	SpriteKey.BTN_PRIMARY:         [0,   0,   190, 49],
	SpriteKey.BTN_PRIMARY_PRESSED: [0,   192, 190, 45],
	SpriteKey.BTN_SQ_A:            [288, 194, 49,  49],
	SpriteKey.BTN_SQ_B:            [239, 194, 49,  49],
	SpriteKey.BTN_SQ_PRESSED:      [190, 194, 49,  45],
	SpriteKey.BTN_NAV:             [339, 94,  49,  49],
	SpriteKey.BTN_NAV_PRESSED:     [290, 94,  49,  45],
	SpriteKey.BTN_ICON_BORDER:     [337, 184, 49,  49],
	SpriteKey.BTN_ICON_PRESSED:    [290, 139, 49,  45],
	SpriteKey.BTN_INPUT:           [0,   143, 190, 49],
	SpriteKey.PANEL:               [190, 94,  100, 100],
	SpriteKey.ICON_CHECKMARK_BOX:  [380, 36,  38,  36],
	SpriteKey.ICON_CROSS_BOX:      [380, 0,   38,  36],
	SpriteKey.ICON_TICK_BOX:       [386, 210, 36,  36],
	SpriteKey.ICON_CHECKMARK:      [337, 233, 21,  20],
	SpriteKey.ICON_CROSS:          [0,   237, 18,  18],
	SpriteKey.ICON_TICK:           [18,  239, 17,  17],
	SpriteKey.ICON_CIRCLE:         [386, 174, 36,  36],
	SpriteKey.SLIDER_DOWN:         [416, 72,  28,  42],
	SpriteKey.SLIDER_LEFT:         [339, 143, 39,  31],
	SpriteKey.SLIDER_RIGHT:        [378, 143, 39,  31],
	SpriteKey.SLIDER_UP:           [388, 72,  28,  42],
}

# ─────────────────────────────────────────
# 등급별 tint 색상 (Kenney 패널 위에 GDScript 색상)
# ─────────────────────────────────────────
const RARITY_TINTS: Dictionary = {
	"common":    Color(0.85, 0.85, 0.90, 1.0),  # 연한 회청
	"rare":      Color(0.60, 0.80, 1.00, 1.0),  # 파랑
	"epic":      Color(0.80, 0.60, 1.00, 1.0),  # 보라
	"legendary": Color(1.00, 0.85, 0.40, 1.0),  # 황금
}

# ─────────────────────────────────────────
# 내부 캐시
# ─────────────────────────────────────────
var _sheet_tex: Texture2D = null
var _atlas_cache: Dictionary = {}
var _stylebox_cache: Dictionary = {}

# ─────────────────────────────────────────
# 초기화
# ─────────────────────────────────────────
func _ready() -> void:
	_sheet_tex = load(SHEET_PATH) as Texture2D
	if _sheet_tex == null:
		push_warning("KenneyTheme: sheet.png 로드 실패 — 경로 확인: " + SHEET_PATH)
	else:
		print("KenneyTheme: Kenney Blue Pack 로드 완료")

# ─────────────────────────────────────────
# 핵심 API
# ─────────────────────────────────────────

## AtlasTexture 반환 (캐시됨)
func get_atlas(key: SpriteKey) -> AtlasTexture:
	if _atlas_cache.has(key):
		return _atlas_cache[key]
	if _sheet_tex == null:
		return null
	var r: Array = SPRITE_RECTS[key]
	var at := AtlasTexture.new()
	at.atlas = _sheet_tex
	at.region = Rect2(r[0], r[1], r[2], r[3])
	_atlas_cache[key] = at
	return at

## StyleBoxTexture 반환 (NinePatch 포함, 캐시됨)
func get_stylebox(key: SpriteKey, patch: int = PATCH_WIDE) -> StyleBoxTexture:
	var cache_key: String = "%d_%d" % [key, patch]
	if _stylebox_cache.has(cache_key):
		return _stylebox_cache[cache_key]
	var atlas := get_atlas(key)
	if atlas == null:
		return null
	var stb := StyleBoxTexture.new()
	stb.texture = atlas
	stb.texture_margin_left   = patch
	stb.texture_margin_right  = patch
	stb.texture_margin_top    = patch
	stb.texture_margin_bottom = patch
	_stylebox_cache[cache_key] = stb
	return stb

# ─────────────────────────────────────────
# 버튼 적용 함수들
# ─────────────────────────────────────────

## Button에 NinePatch 스타일 적용
func apply_button(
		btn: Button,
		normal_key: SpriteKey,
		pressed_key: SpriteKey = SpriteKey.BTN_PRIMARY_PRESSED,
		patch: int = PATCH_WIDE
) -> void:
	if btn == null:
		return
	var stb_n := get_stylebox(normal_key, patch)
	if stb_n:
		btn.add_theme_stylebox_override("normal", stb_n)
		btn.add_theme_stylebox_override("focus",  stb_n)
		btn.add_theme_stylebox_override("hover",  stb_n)
	var stb_p := get_stylebox(pressed_key, patch)
	if stb_p:
		btn.add_theme_stylebox_override("pressed", stb_p)

## CTA 메인 버튼 (파란 진한 색)
func apply_button_primary(btn: Button) -> void:
	apply_button(btn, SpriteKey.BTN_PRIMARY, SpriteKey.BTN_PRIMARY_PRESSED, PATCH_WIDE)

## 일반 확인 버튼
func apply_button_normal(btn: Button) -> void:
	apply_button(btn, SpriteKey.BTN_WIDE_NORMAL_A, SpriteKey.BTN_WIDE_PRESSED_A, PATCH_WIDE)

## 보조(취소/뒤로) 버튼
func apply_button_secondary(btn: Button) -> void:
	apply_button(btn, SpriteKey.BTN_WIDE_NORMAL_B, SpriteKey.BTN_WIDE_PRESSED_B, PATCH_WIDE)

## 아이콘 버튼 (닫기 X)
func apply_button_close(btn: Button) -> void:
	apply_button(btn, SpriteKey.BTN_ICON_BORDER, SpriteKey.BTN_ICON_PRESSED, PATCH_SQUARE)
	var icon_rect := _get_or_create_icon_child(btn)
	icon_rect.texture = get_atlas(SpriteKey.ICON_CROSS)

## 아이콘 버튼 (확인 체크)
func apply_button_accept(btn: Button) -> void:
	apply_button(btn, SpriteKey.BTN_ICON_BORDER, SpriteKey.BTN_ICON_PRESSED, PATCH_SQUARE)
	var icon_rect := _get_or_create_icon_child(btn)
	icon_rect.texture = get_atlas(SpriteKey.ICON_CHECKMARK)

# ─────────────────────────────────────────
# 패널 적용 함수들
# ─────────────────────────────────────────

## PanelContainer / Panel에 blue_panel 스타일 적용
func apply_panel(panel: Control, rarity: String = "common") -> void:
	if panel == null:
		return
	var stb := get_stylebox(SpriteKey.PANEL, PATCH_PANEL)
	if stb == null:
		return
	# 등급별 tint — 캐시된 stylebox를 변경하지 않도록 duplicate
	var tinted := stb.duplicate() as StyleBoxTexture
	tinted.modulate_color = RARITY_TINTS.get(rarity.to_lower(), RARITY_TINTS["common"])
	panel.add_theme_stylebox_override("panel", tinted)

## NinePatchRect에 blue_panel 적용
func apply_ninepatch(np: NinePatchRect, patch: int = PATCH_PANEL) -> void:
	if np == null:
		return
	if _sheet_tex == null:
		return
	np.texture = get_atlas(SpriteKey.PANEL)
	np.patch_margin_left   = patch
	np.patch_margin_right  = patch
	np.patch_margin_top    = patch
	np.patch_margin_bottom = patch

## LineEdit / 입력창 배경 (blue_button13)
func apply_input_bg(np: NinePatchRect) -> void:
	if np == null:
		return
	np.texture = get_atlas(SpriteKey.BTN_INPUT)
	np.patch_margin_left   = PATCH_WIDE
	np.patch_margin_right  = PATCH_WIDE
	np.patch_margin_top    = PATCH_WIDE
	np.patch_margin_bottom = PATCH_WIDE

# ─────────────────────────────────────────
# 아이콘 / 체크박스 적용
# ─────────────────────────────────────────

## TextureRect에 단독 아이콘 적용
func apply_icon(tr: TextureRect, key: SpriteKey) -> void:
	if tr == null:
		return
	tr.texture = get_atlas(key)

## CheckBox 스타일 적용
func apply_checkbox(cb: CheckBox) -> void:
	if cb == null:
		return
	cb.add_theme_icon_override("checked",   get_atlas(SpriteKey.ICON_CHECKMARK_BOX))
	cb.add_theme_icon_override("unchecked", get_atlas(SpriteKey.ICON_CROSS_BOX))

# ─────────────────────────────────────────
# 슬라이더 적용
# ─────────────────────────────────────────

## HSlider grabber 적용
func apply_slider(slider: HSlider) -> void:
	if slider == null:
		return
	slider.add_theme_icon_override("grabber",            get_atlas(SpriteKey.SLIDER_DOWN))
	slider.add_theme_icon_override("grabber_highlight",  get_atlas(SpriteKey.SLIDER_DOWN))
	slider.add_theme_icon_override("grabber_disabled",   get_atlas(SpriteKey.SLIDER_DOWN))

# ─────────────────────────────────────────
# SVG 에셋 헬퍼 (프로젝트 공유 SVG)
# ─────────────────────────────────────────

## 등급별 슬롯 텍스처 반환 (res://assets/ui/sprites/slots/)
func get_slot_texture(grade: String) -> Texture2D:
	var path := SVG_ROOT + "slots/slot_%s.svg" % grade.to_lower()
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return load(SVG_ROOT + "slots/slot_empty.svg") as Texture2D

## 카드 타입별 프레임 텍스처 반환 (res://assets/ui/sprites/cards/)
func get_card_texture(card_type: String) -> Texture2D:
	var path := SVG_ROOT + "cards/card_%s.svg" % card_type.to_lower()
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return null

## 장비 슬롯 타입별 텍스처
func get_equip_slot_texture(slot_type: String) -> Texture2D:
	var path := SVG_ROOT + "slots/slot_%s.svg" % slot_type.to_lower()
	if ResourceLoader.exists(path):
		return load(path) as Texture2D
	return get_slot_texture("empty")

# ─────────────────────────────────────────
# 씬 전체 일괄 적용 (자동 순회)
# ─────────────────────────────────────────

## 씬 루트 노드를 받아 모든 Button/NinePatchRect/CheckBox에 자동 적용
## 노드 이름 규칙:
##   *Primary*, *Start*    → apply_button_primary
##   *Close*, *Dismiss*    → apply_button_close
##   *Accept*, *Confirm*   → apply_button_accept
##   *Secondary*, *Cancel* → apply_button_secondary
##   *Panel* (NinePatch)   → apply_ninepatch
##   그 외 Button          → apply_button_normal
func apply_all(root: Node) -> void:
	if root == null:
		return
	for node in _get_all_children(root):
		var name_lower: String = str(node.name).to_lower()
		if node is Button:
			if "primary" in name_lower or "cta" in name_lower or "start" in name_lower:
				apply_button_primary(node)
			elif "close" in name_lower or "dismiss" in name_lower:
				apply_button_close(node)
			elif "accept" in name_lower or "confirm" in name_lower:
				apply_button_accept(node)
			elif "secondary" in name_lower or "cancel" in name_lower or "back" in name_lower:
				apply_button_secondary(node)
			else:
				apply_button_normal(node)
		elif node is NinePatchRect:
			if "input" in name_lower or "field" in name_lower:
				apply_input_bg(node)
			else:
				apply_ninepatch(node)
		elif node is CheckBox:
			apply_checkbox(node)
		elif node is HSlider:
			apply_slider(node)

# ─────────────────────────────────────────
# 유틸리티
# ─────────────────────────────────────────
func _get_or_create_icon_child(parent: Node) -> TextureRect:
	for child in parent.get_children():
		if child is TextureRect:
			return child
	var tr := TextureRect.new()
	tr.name = "IconOverlay"
	tr.expand_mode = TextureRect.EXPAND_KEEP_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	tr.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	parent.add_child(tr)
	return tr

func _get_all_children(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		result.append(child)
		result.append_array(_get_all_children(child))
	return result
