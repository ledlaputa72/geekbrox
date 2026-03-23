## ═══════════════════════════════════════════════
## Dream Collector — UITheme 적용 치트시트
## apply_ui_theme_kenney.gd 등록 후 사용
## (참조용 파일 — 직접 실행하지 말 것)
## ═══════════════════════════════════════════════

# $-노테이션을 사용하므로 Node 확장 필요
extends Node

# ──────────────────────────────
# 1) 기존 씬 스크립트에서 사용
# ──────────────────────────────

func _ready() -> void:
	# ① 버튼 개별 적용
	KenneyTheme.apply_button_primary($BtnStartDream)
	KenneyTheme.apply_button_normal($BtnConfirm)
	KenneyTheme.apply_button_secondary($BtnCancel)
	KenneyTheme.apply_button_close($BtnClose)
	KenneyTheme.apply_button_accept($BtnAccept)

	# ② 패널 개별 적용
	KenneyTheme.apply_ninepatch($InfoPanel)
	KenneyTheme.apply_ninepatch($PopupBg)
	KenneyTheme.apply_input_bg($SearchInputBg)

	# ③ 아이콘 개별 적용
	KenneyTheme.apply_icon($CrossIcon, KenneyTheme.SpriteKey.ICON_CROSS)
	KenneyTheme.apply_icon($CheckIcon, KenneyTheme.SpriteKey.ICON_CHECKMARK)

	# ④ 체크박스 / 슬라이더
	KenneyTheme.apply_checkbox($NotifCheckBox)
	KenneyTheme.apply_slider($VolumeSlider)

	# ⑤ 씬 전체 자동 적용 (노드 이름 기반)
	#    Button이름에 Primary/Close/Accept/Cancel 포함 시 자동 분류
	KenneyTheme.apply_all(self)

# ──────────────────────────────
# 2) 동적으로 생성한 노드에 적용
# ──────────────────────────────

func _spawn_item_slot(grade: String) -> NinePatchRect:
	var np := NinePatchRect.new()
	np.texture = KenneyTheme.get_slot_texture(grade)   # svg/slots/slot_rare.svg 등
	np.patch_margin_left   = KenneyTheme.PATCH_SLOT
	np.patch_margin_right  = KenneyTheme.PATCH_SLOT
	np.patch_margin_top    = KenneyTheme.PATCH_SLOT
	np.patch_margin_bottom = KenneyTheme.PATCH_SLOT
	return np

func _spawn_card(card_type: String) -> TextureRect:
	var tr := TextureRect.new()
	tr.texture = KenneyTheme.get_card_texture(card_type)  # "ATTACK", "SKILL", "POWER", "CURSE"
	tr.custom_minimum_size = Vector2(100, 140)
	return tr

# ──────────────────────────────
# 3) AtlasTexture 직접 접근 (고급)
# ──────────────────────────────

func _manual_texture_use() -> void:
	# AtlasTexture 직접 가져오기
	var tex := KenneyTheme.get_atlas(KenneyTheme.SpriteKey.BTN_PRIMARY)

	# StyleBoxTexture 직접 가져오기
	var stb := KenneyTheme.get_stylebox(KenneyTheme.SpriteKey.PANEL, 10)

	# TextureButton에 수동 적용 (가장 명시적인 방법)
	var btn := $MyButton as Button
	btn.add_theme_stylebox_override("normal",  KenneyTheme.get_stylebox(KenneyTheme.SpriteKey.BTN_PRIMARY, 10))
	btn.add_theme_stylebox_override("pressed", KenneyTheme.get_stylebox(KenneyTheme.SpriteKey.BTN_PRIMARY_PRESSED, 10))
	btn.add_theme_stylebox_override("hover",   KenneyTheme.get_stylebox(KenneyTheme.SpriteKey.BTN_PRIMARY, 10))
	btn.add_theme_stylebox_override("focus",   KenneyTheme.get_stylebox(KenneyTheme.SpriteKey.BTN_PRIMARY, 10))

# ──────────────────────────────
# 4) NinePatch 수치 참조
# ──────────────────────────────
# const PATCH_WIDE    = 10  ← 와이드 버튼, 패널
# const PATCH_SQUARE  = 10  ← 스퀘어 버튼, 아이콘
# const PATCH_PANEL   = 10  ← 모든 패널
# const PATCH_SLOT    = 10  ← 아이템 슬롯
# const PATCH_SVG_BTN = 10  ← SVG 버튼

# ──────────────────────────────
# 5) 흔한 실수 방지
# ──────────────────────────────
#
# ❌ 이렇게 하면 찌그러짐 발생
#    $Button.texture_normal = load("sheet.png")
#
# ✅ 반드시 StyleBoxTexture로 override
#    KenneyTheme.apply_button_primary($Button)
#
# ❌ NinePatchRect.texture에 전체 sheet 직접 할당
#    $Panel.texture = load("sheet.png")
#
# ✅ get_atlas()로 잘라낸 AtlasTexture 사용
#    KenneyTheme.apply_ninepatch($Panel)
