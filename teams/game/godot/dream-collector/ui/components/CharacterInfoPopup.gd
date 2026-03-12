# CharacterInfoPopup.gd — 캐릭터 속성 상세 모달창
# 데이터 필드 스펙: 02_core_design/data_field_csv/01_data_field_definitions.csv
# Layer 0 (기본) → Layer 1 (전투) → Layer 2 (카드) → Layer 3 (원소) → 장비 → 최종 합산

extends Control

signal closed()

@onready var stats_list: VBoxContainer = $ContentPanel/MainVBox/BodyScroll/StatsList
@onready var close_btn: Button = $ContentPanel/MainVBox/TitleRow/CloseBtn

# 색상 팔레트
const COLOR_LABEL      := Color(0.42, 0.35, 0.25, 1)
const COLOR_VALUE      := Color(0.2,  0.18, 0.12, 1)
const COLOR_VAL_POS    := Color(0.22, 0.50, 0.22, 1)   # 양수 보너스
const COLOR_VAL_NEG    := Color(0.65, 0.22, 0.22, 1)   # 음수/패널티
const COLOR_VAL_CAPPED := Color(0.7,  0.55, 0.1,  1)   # 캡 근접 주의
const COLOR_HEADER_BG  := Color(0.82, 0.70, 0.52, 0.45)
const COLOR_HEADER_TXT := Color(0.28, 0.48, 0.72, 1)
const COLOR_DIVIDER    := Color(0.72, 0.62, 0.48, 0.30)

func _ready() -> void:
	close_btn.pressed.connect(_on_close)
	_apply_panel_sprite()
	visible = false

func _apply_panel_sprite() -> void:
	# panel_frame.png → ContentPanel 배경 (NinePatch patch=18)
	var content_panel := get_node_or_null("ContentPanel")
	UISprites.apply_panel(content_panel, UISprites.panel_frame(), 18)

func show_stats(level_sys, equipped: Dictionary) -> void:
	_build_stats(level_sys, equipped)
	visible = true

# ────────────────────────────────────────────────────────────────────────────
# 메인 스탯 빌드
# ────────────────────────────────────────────────────────────────────────────

func _build_stats(ls, equipped: Dictionary) -> void:
	for c in stats_list.get_children():
		c.queue_free()

	# ── Layer 0: 기본 스탯 ──────────────────────────────────────────────────
	var lv:  int   = ls.current_level    if ls and "current_level" in ls else 1
	var exp: float = ls.current_exp      if ls and "current_exp"   in ls else 0.0
	var req: float = ls.get_required_exp() if ls and ls.has_method("get_required_exp") else 100.0
	var hp:  float = ls.total_hp         if ls and "total_hp"      in ls else 1000.0
	var atk: float = ls.total_atk        if ls and "total_atk"     in ls else 100.0
	var def: float = ls.total_def        if ls and "total_def"     in ls else 50.0
	var spd: float = ls.total_spd        if ls and "total_spd"     in ls else 100.0

	# ── 장비 보너스 집계 ────────────────────────────────────────────────────
	var eq_hp := 0.0; var eq_atk := 0.0; var eq_def := 0.0
	var eq_spd := 0.0; var eq_cri := 0.0; var eq_count := 0
	var rarity_abbr := {"COMMON":"일반","RARE":"레어","SPECIAL":"에픽","LEGENDARY":"전설"}
	var slot_labels  := {
		"slot_weapon":"무기","slot_armor":"방어구",
		"slot_ring_1":"반지 1","slot_ring_2":"반지 2",
		"slot_necklace_1":"목걸이 1","slot_necklace_2":"목걸이 2"
	}
	var eq_list: Array[Dictionary] = []
	for sid in equipped:
		var eq = equipped[sid]
		if eq is Equipment:
			eq_hp  += eq.get_total_hp()
			eq_atk += eq.get_total_atk()
			eq_def += eq.get_total_def()
			eq_spd += eq.get_total_spd()
			eq_cri += eq.get_total_cri()
			eq_count += 1
			eq_list.append({
				"slot":   slot_labels.get(sid, sid),
				"name":   eq.name_ko if eq.name_ko else eq.name,
				"lv":     eq.enhancement_level,
				"rarity": eq.rarity,
			})

	# 최종 합산
	var total_hp  := hp  + eq_hp
	var total_atk := atk + eq_atk
	var total_def := def + eq_def
	var total_spd := spd + eq_spd

	# Layer 1 전투 스탯 기본값 (스펙 기본값 준수)
	# crit_rate 기본 5% + DEX 반영 예정 (현재 DEX 미구현이므로 장비 CRI만 합산)
	var crit_rate:    float = 5.0 + eq_cri                   # % (하드캡 75%)
	var crit_dmg:     float = 150.0                           # % (기본 150%)
	var dodge_rate:   float = 0.0                             # % (하드캡 50%)
	var counter_rate: float = 0.0                             # %
	var life_steal:   float = 0.0                             # %
	var armor_pen:    float = 0.0                             # %
	var dmg_reduction:float = 0.0                             # %
	var shield_val:   int   = 0                               # 절대값
	var cc_immunity:  float = 0.0                             # %
	var hp_regen:     float = 0.0                             # %

	# Layer 1: ATB
	var atb_charge:  float = total_spd / 100.0                # 스펙: SPD/100 per frame

	# 전투력 공식 (기존 유지: 스펙의 최종 피해 계산식과 별개)
	var power := int((total_atk * 2.0 + total_def + total_hp / 10.0) * (1.0 + lv * 0.05))

	# ── 섹션 1: 레벨 & 성장 (Layer 0) ──────────────────────────────────────
	_add_section("+ 레벨 정보")
	_add_row("레벨",          "Lv.%d" % lv)
	_add_row("경험치",        "%.0f / %.0f" % [exp, req])
	_add_row("레벨 진행도",   "%.1f%%" % clampf(exp / req * 100.0, 0.0, 100.0))
	_add_row("ATK 성장/레벨", "+1.5")
	_add_row("DEF 성장/레벨", "+1.0")
	_add_row("HP 성장/레벨",  "+5")
	_add_row("SPD 성장/레벨", "+0.3")

	# ── 섹션 2: 기본 능력치 (Layer 0 — 레벨 기반) ───────────────────────────
	_add_section("+ 기본 능력치")
	_add_row("최대 HP",      _fmt(int(hp)))
	_add_row("공격력",       _fmt(int(atk)))
	_add_row("방어력",       _fmt(int(def)))
	_add_row("속도",         "%.1f" % spd)
	_add_row("에너지",       "3  (최대 3)")
	_add_row("ATB 충전 속도", "%.2f / frame" % (spd / 100.0))

	# ── 섹션 3: 전투 공격 속성 (Layer 1) ─────────────────────────────────────
	_add_section("+ 전투 공격 속성")
	_add_row_capped("치명타율",       "%.1f%%" % crit_rate,  crit_rate,  50.0, 75.0)
	_add_row("치명타 피해",           "%.0f%%" % crit_dmg)
	_add_row("연타 확률",             "0%")
	_add_row("반격 확률",             "%.1f%%" % counter_rate)
	_add_row("흡혈율",                "%.1f%%" % life_steal)
	_add_row("방어구 관통",           "%.1f%%" % armor_pen)
	_add_row("추가 피해",             "0%")

	# ── 섹션 4: 전투 방어 속성 (Layer 1) ─────────────────────────────────────
	_add_section("+ 전투 방어 속성")
	_add_row_capped("회피율",         "%.1f%%" % dodge_rate,   dodge_rate,  30.0, 50.0)
	_add_row("방어막",                _fmt(shield_val))
	_add_row_capped("피해 경감",      "%.1f%%" % dmg_reduction, dmg_reduction, 50.0, 75.0)
	_add_row("제어 면역",             "%.1f%%" % cc_immunity)
	_add_row("피해 반사",             "0%")
	_add_row("HP 회복률/턴",          "%.1f%%" % hp_regen)
	_add_row("방어 공식",             "×(1 - DEF/(DEF+100))")

	# ── 섹션 5: 장비 보너스 ──────────────────────────────────────────────────
	_add_section("+ 장비 보너스")
	_add_row("장착 장비 수",          "%d / 6" % eq_count)
	_add_row("HP 보너스",             _plus_fmt(int(eq_hp)))
	_add_row("공격력 보너스",         _plus_fmt(int(eq_atk)))
	_add_row("방어력 보너스",         _plus_fmt(int(eq_def)))
	_add_row("속도 보너스",           _plus_fmt_f(eq_spd))
	_add_row("치명타율 보너스",       "%.1f%%" % eq_cri)
	if eq_list.size() > 0:
		for d in eq_list:
			_add_row(d["slot"],
				"[%s] %s +%d" % [rarity_abbr.get(d["rarity"], ""), d["name"], d["lv"]])

	# ── 섹션 6: 카드 속성 보너스 (Layer 2) ───────────────────────────────────
	_add_section("+ 카드 속성 (목걸이/특성 효과)")
	_add_row("ATTACK 카드 데미지",    "0%")
	_add_row("SKILL 카드 효율",       "0%")
	_add_row("POWER 카드 배율",       "0%")
	_add_row("CURSE 카드 효율",       "0%")
	_add_row("SGL 단일 보너스",       "0%")
	_add_row("MLT 다중 보너스",       "0%")
	_add_row("콤보 보너스 (3연타)",   "0%")
	_add_row("카드 에너지 할인",      "0")
	_add_row("추가 카드 드로우",      "0장")

	# ── 섹션 7: 원소 데미지/저항 (Layer 3) ───────────────────────────────────
	_add_section("+ 원소 데미지 / 저항")
	_add_row("꿈기억 데미지",        "0%  /  저항 0%")
	_add_row("불꽃 데미지",          "0%  /  저항 0%")
	_add_row("냉기 데미지",          "0%  /  저항 0%")
	_add_row("번개 데미지",          "0%  /  저항 0%")
	_add_row("암흑 데미지",          "0%  /  저항 0%")
	_add_row("약점 시 배율",         "+50%  (×1.5)")
	_add_row("저항 시 배율",         "-50%  (×0.5)")

	# ── 섹션 8: 전투력 & 최종 합산 ───────────────────────────────────────────
	_add_section("+ 전투력 & 최종 합산")
	_add_row("전투력",               _fmt(power))
	_add_row("ATB 충전 (최종)",      "%.2f / frame" % atb_charge)
	_add_row("최종 HP",              _fmt(int(total_hp)))
	_add_row("최종 공격력",          _fmt(int(total_atk)))
	_add_row("최종 방어력",          _fmt(int(total_def)))
	_add_row("최종 속도",            "%.1f" % total_spd)
	_add_row("방어 감소율",
		"%.1f%%" % (total_def / (total_def + 100.0) * 100.0))

	# 하단 여백
	var sp = Control.new()
	sp.custom_minimum_size = Vector2(0, 14)
	stats_list.add_child(sp)

# ────────────────────────────────────────────────────────────────────────────
# UI 빌더 헬퍼
# ────────────────────────────────────────────────────────────────────────────

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

# soft_cap 이상이면 주의색, hard_cap 이상이면 캡 달성색으로 표시
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

	# 값 색상 결정
	var col_val: Color
	if soft_cap >= 0.0 and current >= soft_cap:
		col_val = COLOR_VAL_CAPPED          # 소프트캡 도달 → 주의색
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

# ────────────────────────────────────────────────────────────────────────────
# 포맷 헬퍼
# ────────────────────────────────────────────────────────────────────────────

func _fmt(n: int) -> String:
	if n >= 1000:
		return "%d,%03d" % [n / 1000, n % 1000]
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

func _on_close() -> void:
	visible = false
	closed.emit()
