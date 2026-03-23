# CardDetailPopup.gd
# 카드 상세 정보 팝업 — 캐릭터창 스타일 (카드 2× 상단 고정 + 스크롤 상세정보 + 버튼 3개)

extends Control

signal deck_add_requested(card_data: Dictionary)
signal deck_remove_requested(card_data: Dictionary)
signal enhance_requested(card_data: Dictionary)
signal popup_closed

const CardItemScene := preload("res://ui/components/CardItem.tscn")

# ── 색상 상수 ─────────────────────────────────────────
const COL_BG        := Color(0.95, 0.95, 0.97, 1.0)   # 패널 배경 (연한 회색)
const COL_HEADER    := Color(0.87, 0.80, 0.68, 1.0)   # 섹션 헤더 (베이지)
const COL_ROW_ODD   := Color(1.0,  1.0,  1.0,  1.0)   # 홀수 행 (흰색)
const COL_ROW_EVEN  := Color(0.96, 0.96, 0.98, 1.0)   # 짝수 행 (연한 회색)
const COL_TEXT      := Color(0.12, 0.12, 0.12, 1.0)   # 기본 텍스트
const COL_TEXT_DIM  := Color(0.45, 0.45, 0.50, 1.0)   # 보조 텍스트
const COL_SEP       := Color(0.82, 0.82, 0.85, 1.0)   # 구분선

# 등급별 색상
const RARITY_COLORS := {
	"common":    Color(0.50, 0.50, 0.50),
	"uncommon":  Color(0.30, 0.70, 0.30),
	"rare":      Color(0.30, 0.55, 0.90),
	"epic":      Color(0.65, 0.25, 0.85),
	"legendary": Color(1.00, 0.75, 0.10),
}

# ── UI 노드 ──────────────────────────────────────────
@onready var dim_layer: ColorRect     = $DimLayer
@onready var content_panel: Panel     = $ContentPanel
@onready var card_wrap: Control       = $ContentPanel/OuterMargin/VBoxMain/CardTopMargin/CardSection/CardWrap
@onready var info_vbox: VBoxContainer = $ContentPanel/OuterMargin/VBoxMain/ScrollInfo/InfoVBox
@onready var deck_btn: Button         = $ContentPanel/OuterMargin/VBoxMain/ButtonsRow/DeckButton
@onready var enhance_btn: Button      = $ContentPanel/OuterMargin/VBoxMain/ButtonsRow/EnhanceButton
@onready var close_btn: Button        = $ContentPanel/OuterMargin/VBoxMain/ButtonsRow/CloseButton

# ── 상태 ────────────────────────────────────────────
var current_card: Dictionary = {}
var _is_in_deck: bool = false
var _deck_count: int  = 0
var _preview_instance: Control = null

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_apply_styles()
	dim_layer.gui_input.connect(_on_dim_input)
	deck_btn.pressed.connect(_on_deck_btn_pressed)
	enhance_btn.pressed.connect(_on_enhance_pressed)
	close_btn.pressed.connect(_on_close_pressed)

func _apply_styles() -> void:
	# ContentPanel 배경: 연한 회색
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_BG
	sb.border_width_left   = 1; sb.border_width_right  = 1
	sb.border_width_top    = 1; sb.border_width_bottom = 1
	sb.border_color = Color(0.75, 0.75, 0.78)
	sb.corner_radius_top_left  = 12; sb.corner_radius_top_right    = 12
	sb.corner_radius_bottom_left = 12; sb.corner_radius_bottom_right = 12
	content_panel.add_theme_stylebox_override("panel", sb)
	UISprites.apply_btn(close_btn, "secondary")

# ─── 외부 진입점 ────────────────────────────────────
func show_card(card_data: Dictionary, in_deck: bool, count: int) -> void:
	current_card = card_data
	_is_in_deck  = in_deck
	_deck_count  = count
	if not is_node_ready():
		await ready
	_build_preview()
	_build_info()
	_update_buttons()
	visible = true

# ─── 카드 미리보기 (2×) ──────────────────────────────
func _build_preview() -> void:
	if is_instance_valid(_preview_instance):
		_preview_instance.queue_free()
	_preview_instance = CardItemScene.instantiate() as Control
	card_wrap.add_child(_preview_instance)
	if _preview_instance.has_method("set_card_data"):
		_preview_instance.set_card_data(current_card)
	_preview_instance.scale       = Vector2(2.0, 2.0)
	_preview_instance.position    = Vector2.ZERO
	_preview_instance.mouse_filter = Control.MOUSE_FILTER_IGNORE

# ─── 상세 정보 빌드 ──────────────────────────────────
func _build_info() -> void:
	# 기존 행 제거
	for c in info_vbox.get_children():
		c.queue_free()

	var d := current_card
	var rarity_str: String = d.get("rarity", "common")
	var enhance_lv: int    = d.get("enhancement_level", 0)

	# ── 섹션 1: 기본 정보 ────────────────────────────
	_add_section_header("기본 정보")
	var rows_basic: Array[Array] = [
		["에너지 소모", str(d.get("cost", 0))],
		["카드 이름",  d.get("name", "-")],
		["종류",       _type_korean(d.get("type", ""))],
		["등급",       _rarity_korean(rarity_str)],
	]
	var row_idx: int = 0
	for row in rows_basic:
		_add_stat_row(row[0], row[1], row_idx, _rarity_color(rarity_str) if row[0] == "등급" else Color.TRANSPARENT)
		row_idx += 1

	# ── 섹션 2: 카드 능력 ────────────────────────────
	_add_section_header("카드 능력")
	var ability: String = d.get("description", d.get("short_desc", "-"))
	_add_multiline_row(ability, false)

	# 강화 시 변경 정보 (타입별로 다름)
	var enhance_effect := _get_enhance_effect(d)
	if enhance_effect != "":
		_add_stat_row("강화 효과", enhance_effect, 1, Color.TRANSPARENT)

	# ── 섹션 3: 강화 정보 ────────────────────────────
	_add_section_header("강화 정보")
	var enh_rows: Array[Array] = [
		["강화 단계",   "Lv.%d / Lv.10" % enhance_lv],
		["강화 방법",   "덱에 같은 카드 2장 보유 시 강화 가능"],
		["강화 보너스", _get_enhance_bonus(d, enhance_lv)],
	]
	row_idx = 0
	for row in enh_rows:
		_add_stat_row(row[0], row[1], row_idx, Color.TRANSPARENT)
		row_idx += 1

	# ── 섹션 4: 카드 설명 ────────────────────────────
	_add_section_header("카드 설명")
	var lore := _get_lore(d)
	_add_multiline_row(lore, true)

# ─── UI 빌더 헬퍼 ───────────────────────────────────
func _add_section_header(title: String) -> void:
	var header := Panel.new()
	header.custom_minimum_size = Vector2(0, 30)
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_HEADER
	header.add_theme_stylebox_override("panel", sb)
	var lbl := Label.new()
	lbl.text = title
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", COL_TEXT)
	lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl.position = Vector2(10, 0)
	lbl.size = Vector2(300, 30)
	header.add_child(lbl)
	info_vbox.add_child(header)

func _add_stat_row(label_text: String, value_text: String,
		row_idx: int, value_color: Color) -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   10)
	margin.add_theme_constant_override("margin_right",  10)
	margin.add_theme_constant_override("margin_top",    2)
	margin.add_theme_constant_override("margin_bottom", 2)
	var sb := StyleBoxFlat.new()
	sb.bg_color = COL_ROW_ODD if (row_idx % 2 == 0) else COL_ROW_EVEN
	margin.add_theme_stylebox_override("panel", sb)

	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 32)
	margin.add_child(row)

	var key_lbl := Label.new()
	key_lbl.text = label_text
	key_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	key_lbl.add_theme_font_size_override("font_size", 12)
	key_lbl.add_theme_color_override("font_color", COL_TEXT_DIM)
	key_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(key_lbl)

	var val_lbl := Label.new()
	val_lbl.text = value_text
	val_lbl.add_theme_font_size_override("font_size", 12)
	var vc := value_color if value_color != Color.TRANSPARENT else COL_TEXT
	val_lbl.add_theme_color_override("font_color", vc)
	val_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	val_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(val_lbl)

	info_vbox.add_child(margin)

	var sep := HSeparator.new()
	var sep_sb := StyleBoxFlat.new()
	sep_sb.bg_color = COL_SEP
	sep.add_theme_stylebox_override("separator", sep_sb)
	info_vbox.add_child(sep)

func _add_multiline_row(text: String, is_lore: bool) -> void:
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left",   10)
	margin.add_theme_constant_override("margin_right",  10)
	margin.add_theme_constant_override("margin_top",    6)
	margin.add_theme_constant_override("margin_bottom", 6)
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl.add_theme_font_size_override("font_size", 12)
	lbl.add_theme_color_override("font_color", COL_TEXT_DIM if is_lore else COL_TEXT)
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(lbl)
	info_vbox.add_child(margin)

# ─── 카드 데이터 헬퍼 ────────────────────────────────
func _type_korean(t: String) -> String:
	match t.to_lower():
		"attack": return "공격"
		"skill":  return "스킬"
		"power":  return "파워"
		"curse":  return "커스"
	return t

func _rarity_korean(r: String) -> String:
	match r.to_lower():
		"common":    return "일반"
		"uncommon":  return "고급"
		"rare":      return "레어"
		"epic":      return "에픽"
		"legendary": return "전설"
	return r

func _rarity_color(r: String) -> Color:
	return RARITY_COLORS.get(r.to_lower(), COL_TEXT)

func _get_enhance_effect(d: Dictionary) -> String:
	match d.get("type", "").to_lower():
		"attack": return "피해량 +20% (강화 단계당)"
		"skill":  return "방어값 +15% (강화 단계당)"
		"power":  return "지속 턴 +1 (강화 단계당)"
		"curse":  return "독/저주 강도 +10% (강화 단계당)"
	return ""

func _get_enhance_bonus(d: Dictionary, lv: int) -> String:
	if lv <= 0:
		return "없음 (미강화)"
	match d.get("type", "").to_lower():
		"attack": return "+%d%% 피해량" % (lv * 20)
		"skill":  return "+%d%% 방어값" % (lv * 15)
		"power":  return "+%d 지속 턴" % lv
		"curse":  return "+%d%% 효과 강도" % (lv * 10)
	return "Lv.%d 강화 완료" % lv

func _get_lore(d: Dictionary) -> String:
	var name_str: String = d.get("name", "")
	match d.get("type", "").to_lower():
		"attack":
			return "%s — 꿈 속 전사의 기억에서 소환된 공격 기술.\n어둠 속에서 갈고닦은 검술이 빛을 발한다." % name_str
		"skill":
			return "%s — 의식의 경계에서 배운 방어 기법.\n방패와 의지가 하나가 될 때 진정한 수호가 시작된다." % name_str
		"power":
			return "%s — 꿈의 심층부에 잠든 강대한 힘.\n집중된 에너지가 현실을 바꿀 수 있다." % name_str
		"curse":
			return "%s — 악몽의 파편에서 결정화된 저주의 기술.\n적의 의지를 서서히 갉아먹는다." % name_str
	return "알 수 없는 기원을 가진 카드."

# ─── 버튼 상태 갱신 ──────────────────────────────────
func _update_buttons() -> void:
	if _is_in_deck:
		deck_btn.text = "덱제거"
		UISprites.apply_btn(deck_btn, "red")
	else:
		deck_btn.text = "덱추가"
		UISprites.apply_btn(deck_btn, "primary")

	var can_enhance: bool = _deck_count >= 2
	enhance_btn.disabled = not can_enhance
	UISprites.apply_btn(enhance_btn, "green" if can_enhance else "disabled")

# ─── 이벤트 ─────────────────────────────────────────
func _on_dim_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_on_close_pressed()

func _on_deck_btn_pressed() -> void:
	if _is_in_deck:
		deck_remove_requested.emit(current_card)
	else:
		deck_add_requested.emit(current_card)
	_on_close_pressed()

func _on_enhance_pressed() -> void:
	if _deck_count >= 2:
		enhance_requested.emit(current_card)
	_on_close_pressed()

func _on_close_pressed() -> void:
	popup_closed.emit()
	queue_free()
