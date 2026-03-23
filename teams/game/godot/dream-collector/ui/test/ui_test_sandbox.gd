## ui_test_sandbox.gd
## Dream Collector — UI 에셋 테스트 샌드박스
##
## 사용법:
## 1. Godot에서 새 씬 생성 (Control 루트)
## 2. 이 스크립트를 루트 노드에 붙이기
## 3. F5로 실행 → 모든 컴포넌트를 한 화면에서 확인
##
## 핫리로드: 스크립트 저장 시 자동으로 rebuild() 호출됨

extends Control

const PATCH := 10  # 프리뷰어에서 확인한 값

func _ready() -> void:
	_build_ui()

func _build_ui() -> void:
	# 기존 자식 초기화
	for c in get_children():
		c.queue_free()
	await get_tree().process_frame

	# KenneyTheme 안전하게 가져오기 (parse-error 방지)
	var kt = get_node_or_null("/root/KenneyTheme")
	if kt == null:
		var lbl := Label.new()
		lbl.text = "KenneyTheme autoload not registered"
		add_child(lbl)
		return

	var sk = kt.SpriteKey

	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(scroll)

	var vbox := VBoxContainer.new()
	vbox.custom_minimum_size.x = 400
	vbox.add_theme_constant_override("separation", 12)
	scroll.add_child(vbox)

	_add_section(vbox, "── 와이드 버튼 ──────────────")
	_test_button(vbox, kt, "CTA Primary",     sk.BTN_PRIMARY,       sk.BTN_PRIMARY_PRESSED)
	_test_button(vbox, kt, "Normal A",        sk.BTN_WIDE_NORMAL_A, sk.BTN_WIDE_PRESSED_A)
	_test_button(vbox, kt, "Normal B",        sk.BTN_WIDE_NORMAL_B, sk.BTN_WIDE_PRESSED_B)
	_test_button(vbox, kt, "Input / Passive", sk.BTN_INPUT,         sk.BTN_INPUT)

	_add_section(vbox, "── 스퀘어 버튼 ──────────────")
	var hbox_sq := HBoxContainer.new()
	hbox_sq.add_theme_constant_override("separation", 8)
	vbox.add_child(hbox_sq)
	_test_square_button(hbox_sq, kt, "SqA",  sk.BTN_SQ_A,       sk.BTN_SQ_PRESSED)
	_test_square_button(hbox_sq, kt, "SqB",  sk.BTN_SQ_B,       sk.BTN_SQ_PRESSED)
	_test_square_button(hbox_sq, kt, "Nav",  sk.BTN_NAV,        sk.BTN_NAV_PRESSED)
	_test_square_button(hbox_sq, kt, "Icon", sk.BTN_ICON_BORDER, sk.BTN_ICON_PRESSED)

	_add_section(vbox, "── 패널 (NinePatchRect) ──────")
	_test_panel(vbox, kt, Vector2(380, 80),  "패널 380×80")
	_test_panel(vbox, kt, Vector2(200, 120), "패널 200×120")
	_test_panel(vbox, kt, Vector2(380, 200), "패널 380×200")

	_add_section(vbox, "── 아이콘 / 체크박스 ─────────")
	var hbox_ic := HBoxContainer.new()
	hbox_ic.add_theme_constant_override("separation", 12)
	vbox.add_child(hbox_ic)
	for key in [
		sk.ICON_CHECKMARK_BOX,
		sk.ICON_CROSS_BOX,
		sk.ICON_TICK_BOX,
		sk.ICON_CHECKMARK,
		sk.ICON_CROSS,
		sk.ICON_CIRCLE,
	]:
		var tr := TextureRect.new()
		tr.texture = kt.get_atlas(key)
		tr.stretch_mode = TextureRect.STRETCH_KEEP
		tr.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		hbox_ic.add_child(tr)

	_add_section(vbox, "── 슬라이더 핸들 ────────────")
	var hbox_sl := HBoxContainer.new()
	hbox_sl.add_theme_constant_override("separation", 12)
	vbox.add_child(hbox_sl)
	for key in [
		sk.SLIDER_LEFT,
		sk.SLIDER_DOWN,
		sk.SLIDER_UP,
		sk.SLIDER_RIGHT,
	]:
		var tr := TextureRect.new()
		tr.texture = kt.get_atlas(key)
		tr.stretch_mode = TextureRect.STRETCH_KEEP
		tr.expand_mode = TextureRect.EXPAND_KEEP_SIZE
		hbox_sl.add_child(tr)

# ─────────────────────────────────────────
# 헬퍼
# ─────────────────────────────────────────
func _add_section(parent: VBoxContainer, title: String) -> void:
	var lbl := Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 11)
	lbl.add_theme_color_override("font_color", Color(0.5, 0.55, 0.7))
	parent.add_child(lbl)

func _test_button(
		parent: VBoxContainer,
		kt: Node,
		label_text: String,
		normal_key: int,
		pressed_key: int
) -> void:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	parent.add_child(hbox)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.custom_minimum_size.x = 110
	lbl.add_theme_font_size_override("font_size", 11)
	hbox.add_child(lbl)

	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(190, 49)
	kt.apply_button(btn, normal_key, pressed_key, PATCH)
	hbox.add_child(btn)

	# 크기 변경 테스트 버튼
	var btn2 := Button.new()
	btn2.text = label_text + " (늘림)"
	btn2.custom_minimum_size = Vector2(300, 60)
	kt.apply_button(btn2, normal_key, pressed_key, PATCH)
	hbox.add_child(btn2)

func _test_square_button(
		parent: HBoxContainer,
		kt: Node,
		label_text: String,
		normal_key: int,
		pressed_key: int
) -> void:
	var vbox := VBoxContainer.new()
	parent.add_child(vbox)

	var btn := Button.new()
	btn.custom_minimum_size = Vector2(49, 49)
	kt.apply_button(btn, normal_key, pressed_key, PATCH)
	vbox.add_child(btn)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.add_theme_font_size_override("font_size", 10)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(lbl)

func _test_panel(parent: VBoxContainer, kt: Node, size: Vector2, label_text: String) -> void:
	var np := NinePatchRect.new()
	np.custom_minimum_size = size
	kt.apply_ninepatch(np, PATCH)

	var lbl := Label.new()
	lbl.text = label_text
	lbl.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	np.add_child(lbl)

	parent.add_child(np)
