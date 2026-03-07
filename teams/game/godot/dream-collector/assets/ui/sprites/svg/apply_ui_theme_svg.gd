## apply_ui_theme_svg.gd
## Dream Collector — SVG 스프라이트 일괄 적용 스크립트 v2.0
##
## 사용법 (Claude Code에 전달):
##   svg/ 폴더를 res://assets/ui/sprites/svg/ 에 복사하고
##   apply_ui_theme_svg.gd 를 참조하여 각 씬에 NinePatchRect/TextureButton 적용
##
## ─── Godot 4 NodeType 매핑 ──────────────────────────────────────
##   panels/   → NinePatchRect  (patch_margin = 18 all sides)
##   buttons/  → TextureButton + NinePatchRect (patch_margin = 40)
##   slots/    → NinePatchRect  (patch_margin = 12 all sides)
##   cards/    → TextureRect    (fixed size 100×140)
##   bars/     → TextureProgressBar (track + fill 분리)
##   tabs/     → NinePatchRect  (patch_margin = 12)
##   badges/   → TextureRect    (fixed size)
##   hud/      → TextureRect or NinePatchRect
##   lists/    → NinePatchRect  (patch_margin = 16)
##   misc/     → TextureRect
## ────────────────────────────────────────────────────────────────

extends Node

const SVG_BASE := "res://assets/ui/sprites/svg/"

# ══════════════════════════════════════════════════════════════
# 경로 상수
# ══════════════════════════════════════════════════════════════

## PANELS
const PANEL_FRAME           := SVG_BASE + "panels/panel_frame.svg"
const PANEL_DARK            := SVG_BASE + "panels/panel_dark.svg"
const PANEL_MODAL           := SVG_BASE + "panels/modal_frame.svg"
const PANEL_TOOLTIP         := SVG_BASE + "panels/tooltip_frame.svg"
const PANEL_SECTION_HEADER  := SVG_BASE + "panels/panel_section_header.svg"

## BUTTONS
const BTN_PRIMARY   := SVG_BASE + "buttons/btn_primary.svg"
const BTN_GREEN     := SVG_BASE + "buttons/btn_green.svg"
const BTN_RED       := SVG_BASE + "buttons/btn_red.svg"
const BTN_PURPLE    := SVG_BASE + "buttons/btn_purple.svg"
const BTN_SECONDARY := SVG_BASE + "buttons/btn_secondary.svg"
const BTN_DISABLED  := SVG_BASE + "buttons/btn_disabled.svg"

## SLOTS
const SLOT_NORMAL   := SVG_BASE + "slots/slot_normal.svg"
const SLOT_UNCOMMON := SVG_BASE + "slots/slot_uncommon.svg"
const SLOT_RARE     := SVG_BASE + "slots/slot_rare.svg"
const SLOT_EPIC     := SVG_BASE + "slots/slot_epic.svg"
const SLOT_LEGEND   := SVG_BASE + "slots/slot_legend.svg"
const SLOT_EMPTY    := SVG_BASE + "slots/slot_empty.svg"
const SLOT_WEAPON   := SVG_BASE + "slots/slot_weapon.svg"
const SLOT_ARMOR    := SVG_BASE + "slots/slot_armor.svg"
const SLOT_RING     := SVG_BASE + "slots/slot_ring.svg"
const SLOT_NECKLACE := SVG_BASE + "slots/slot_necklace.svg"

## CARDS
const CARD_ATTACK     := SVG_BASE + "cards/card_attack.svg"
const CARD_SKILL      := SVG_BASE + "cards/card_skill.svg"
const CARD_POWER      := SVG_BASE + "cards/card_power.svg"
const CARD_CURSE      := SVG_BASE + "cards/card_curse.svg"
const CARD_COST_BADGE := SVG_BASE + "cards/card_cost_badge.svg"

## BARS
const BAR_TRACK      := SVG_BASE + "bars/bar_track.svg"
const BAR_TRACK_THIN := SVG_BASE + "bars/bar_track_thin.svg"
const BAR_HP         := SVG_BASE + "bars/bar_fill_hp.svg"
const BAR_MANA       := SVG_BASE + "bars/bar_fill_mana.svg"
const BAR_EXP        := SVG_BASE + "bars/bar_fill_exp.svg"
const BAR_ATB        := SVG_BASE + "bars/bar_fill_atb.svg"

## TABS
const TAB_BAR_FRAME  := SVG_BASE + "tabs/tab_bar_frame.svg"
const TAB_ACTIVE_BG  := SVG_BASE + "tabs/tab_active_bg.svg"

## BADGES
const BADGE_NOTIF    := SVG_BASE + "badges/notif_badge.svg"
const BADGE_COIN     := SVG_BASE + "badges/coin_badge.svg"
const BADGE_GRADE_S  := SVG_BASE + "badges/badge_grade_s.svg"
const BADGE_GRADE_A  := SVG_BASE + "badges/badge_grade_a.svg"
const BADGE_GRADE_B  := SVG_BASE + "badges/badge_grade_b.svg"
const BADGE_GRADE_C  := SVG_BASE + "badges/badge_grade_c.svg"
const BADGE_LEVEL    := SVG_BASE + "badges/level_badge.svg"
const BADGE_SCROLL   := SVG_BASE + "badges/scroll_btn.svg"

## HUD
const HUD_FRAME          := SVG_BASE + "hud/hud_frame.svg"
const HUD_PILL           := SVG_BASE + "hud/hud_pill.svg"
const HUD_SECTION_HEADER := SVG_BASE + "hud/section_header.svg"

## LISTS
const LIST_NORMAL := SVG_BASE + "lists/list_item_normal.svg"
const LIST_RARE   := SVG_BASE + "lists/list_item_rare.svg"
const LIST_LEGEND := SVG_BASE + "lists/list_item_legend.svg"

## MISC
const MISC_DIVIDER_GOLD   := SVG_BASE + "misc/divider_gold.svg"
const MISC_DIVIDER_SUBTLE := SVG_BASE + "misc/divider_subtle.svg"
const MISC_MANA_TRACK     := SVG_BASE + "misc/mana_circle_track.svg"
const MISC_MANA_FILL      := SVG_BASE + "misc/mana_circle_fill.svg"
const MISC_POPUP_OVERLAY  := SVG_BASE + "misc/popup_overlay.svg"

# ══════════════════════════════════════════════════════════════
# 헬퍼: NinePatchRect 적용
# ══════════════════════════════════════════════════════════════

static func apply_ninepatch(node: NinePatchRect, svg_path: String, patch: int = 18) -> void:
	node.texture = load(svg_path)
	node.patch_margin_left   = patch
	node.patch_margin_right  = patch
	node.patch_margin_top    = patch
	node.patch_margin_bottom = patch

# ══════════════════════════════════════════════════════════════
# 헬퍼: TextureButton 적용 (버튼 NinePatch)
# ══════════════════════════════════════════════════════════════

static func apply_button(btn: TextureButton, svg_normal: String,
		svg_pressed: String = "", svg_disabled: String = "") -> void:
	btn.texture_normal = load(svg_normal)
	if svg_pressed != "":
		btn.texture_pressed = load(svg_pressed)
	if svg_disabled != "":
		btn.texture_disabled = load(svg_disabled)

# ══════════════════════════════════════════════════════════════
# 헬퍼: 슬롯 등급별 텍스처 반환
# ══════════════════════════════════════════════════════════════

static func get_slot_texture(grade: String) -> Texture2D:
	match grade.to_lower():
		"normal", "common": return load(SLOT_NORMAL)
		"uncommon", "green": return load(SLOT_UNCOMMON)
		"rare", "blue":      return load(SLOT_RARE)
		"epic", "purple":    return load(SLOT_EPIC)
		"legend", "legendary", "gold": return load(SLOT_LEGEND)
		_: return load(SLOT_EMPTY)

# ══════════════════════════════════════════════════════════════
# 헬퍼: 카드 타입별 텍스처 반환
# ══════════════════════════════════════════════════════════════

static func get_card_texture(card_type: String) -> Texture2D:
	match card_type.to_upper():
		"ATTACK", "SGL", "MLT", "SCL", "HYB": return load(CARD_ATTACK)
		"SKILL",  "DEF", "PAR", "DOD":        return load(CARD_SKILL)
		"POWER",  "STR", "GRD", "ENR", "TRG": return load(CARD_POWER)
		"CURSE",  "WKN", "SPD", "PEN", "RSK": return load(CARD_CURSE)
		_: return load(CARD_ATTACK)

# ══════════════════════════════════════════════════════════════
# 헬퍼: 등급 뱃지 텍스처 반환
# ══════════════════════════════════════════════════════════════

static func get_grade_badge(grade: String) -> Texture2D:
	match grade.to_upper():
		"S": return load(BADGE_GRADE_S)
		"A": return load(BADGE_GRADE_A)
		"B": return load(BADGE_GRADE_B)
		_:   return load(BADGE_GRADE_C)

# ══════════════════════════════════════════════════════════════
# 헬퍼: 장비 슬롯 포지션 텍스처 반환
# ══════════════════════════════════════════════════════════════

static func get_equip_slot_texture(slot_type: String) -> Texture2D:
	match slot_type.to_lower():
		"weapon": return load(SLOT_WEAPON)
		"armor":  return load(SLOT_ARMOR)
		"ring":   return load(SLOT_RING)
		"necklace", "neck": return load(SLOT_NECKLACE)
		_: return load(SLOT_EMPTY)

# ══════════════════════════════════════════════════════════════
# 예시: 씬 일괄 적용
# ══════════════════════════════════════════════════════════════
#
# func _ready() -> void:
#   # 패널
#   apply_ninepatch($MainPanel, PANEL_DARK, 18)
#   apply_ninepatch($InfoPanel, PANEL_FRAME, 18)
#   apply_ninepatch($Modal,     PANEL_MODAL, 20)
#
#   # 버튼
#   apply_button($BtnStart, BTN_PRIMARY, BTN_PRIMARY, BTN_DISABLED)
#   apply_button($BtnCancel, BTN_SECONDARY)
#
#   # 슬롯 (카드 등급)
#   for slot in $SlotContainer.get_children():
#     slot.texture = get_slot_texture(slot.grade)
#
#   # 진행 바
#   $HpBar.under_texture   = load(BAR_TRACK)
#   $HpBar.progress_texture = load(BAR_HP)
#   $AtbBar.under_texture  = load(BAR_TRACK_THIN)
#   $AtbBar.progress_texture = load(BAR_ATB)
#
#   # 카드 프레임
#   $CardFrame.texture = get_card_texture("ATTACK")
