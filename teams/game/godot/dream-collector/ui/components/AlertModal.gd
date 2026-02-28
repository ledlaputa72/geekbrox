# AlertModal.gd
# 재사용 가능한 알림/경고 모달 팝업
# 사용법: show_alert(title, message, button1_text, button2_text)

extends CanvasLayer

# ─── 시그널 ─────────────────────────────────────────
signal button1_pressed  # 첫 번째 버튼 클릭 (확인, 이동 등)
signal button2_pressed  # 두 번째 버튼 클릭 (취소, 닫기 등)
signal closed           # 모달 닫힘

# ─── UI 노드 참조 ────────────────────────────────────
@onready var control: Control = $Control
@onready var overlay: ColorRect = $Control/Overlay
@onready var modal_panel: Panel = $Control/ModalPanel
@onready var title_label: Label = $Control/ModalPanel/VBox/TitleLabel
@onready var message_label: Label = $Control/ModalPanel/VBox/MessageLabel
@onready var button1: Button = $Control/ModalPanel/VBox/ButtonsContainer/Button1
@onready var button2: Button = $Control/ModalPanel/VBox/ButtonsContainer/Button2

# ─── 초기화 ──────────────────────────────────────────
func _ready() -> void:
	apply_styles()
	setup_signals()
	
	# 초기 상태: 숨김
	control.visible = false
	
	# 오버레이 클릭 시 닫기
	overlay.gui_input.connect(_on_overlay_clicked)

# ─── 스타일 적용 ─────────────────────────────────────
func apply_styles() -> void:
	# 모달 패널 스타일
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = UITheme.COLORS.panel
	panel_style.border_width_left = 3
	panel_style.border_width_top = 3
	panel_style.border_width_right = 3
	panel_style.border_width_bottom = 3
	panel_style.border_color = UITheme.COLORS.primary
	panel_style.corner_radius_top_left = UITheme.RADIUS.large
	panel_style.corner_radius_top_right = UITheme.RADIUS.large
	panel_style.corner_radius_bottom_left = UITheme.RADIUS.large
	panel_style.corner_radius_bottom_right = UITheme.RADIUS.large
	modal_panel.add_theme_stylebox_override("panel", panel_style)
	
	# 타이틀 색상
	title_label.add_theme_color_override("font_color", UITheme.COLORS.primary)
	
	# 메시지 색상
	message_label.add_theme_color_override("font_color", UITheme.COLORS.text)
	
	# 버튼 스타일
	UITheme.apply_button_style(button1, "primary")
	UITheme.apply_button_style(button2, "panel_light")

# ─── 시그널 연결 ─────────────────────────────────────
func setup_signals() -> void:
	button1.pressed.connect(_on_button1_pressed)
	button2.pressed.connect(_on_button2_pressed)

# ─── 모달 표시 (메인 함수) ───────────────────────────
func show_alert(
	title: String,
	message: String,
	button1_text: String = "확인",
	button2_text: String = "",
	button1_color: String = "primary"
) -> void:
	title_label.text = title
	message_label.text = message
	button1.text = button1_text
	
	# 버튼 1 색상
	UITheme.apply_button_style(button1, button1_color)
	
	# 버튼 2 표시 여부
	if button2_text != "":
		button2.text = button2_text
		button2.visible = true
	else:
		button2.visible = false
	
	# 모달 표시
	control.visible = true
	
	print("[AlertModal] 표시: %s - %s" % [title, message])

# ─── 모달 닫기 ───────────────────────────────────────
func hide_modal() -> void:
	control.visible = false
	closed.emit()
	print("[AlertModal] 닫힘")

# ─── 이벤트 핸들러 ───────────────────────────────────
func _on_button1_pressed() -> void:
	button1_pressed.emit()
	print("[AlertModal] 버튼 1 클릭")
	hide_modal()

func _on_button2_pressed() -> void:
	button2_pressed.emit()
	print("[AlertModal] 버튼 2 클릭")
	hide_modal()

func _on_overlay_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			print("[AlertModal] 오버레이 클릭 - 닫기")
			hide_modal()

# ─── 편의 함수들 ─────────────────────────────────────

# 간단한 알림 (확인 버튼만)
func show_info(title: String, message: String) -> void:
	show_alert(title, message, "확인", "")

# 경고 (빨간색 확인 버튼)
func show_warning(title: String, message: String) -> void:
	show_alert(title, message, "확인", "", "danger")

# 확인 다이얼로그 (확인 + 취소)
func show_confirm(title: String, message: String, confirm_text: String = "확인", cancel_text: String = "취소") -> void:
	show_alert(title, message, confirm_text, cancel_text, "success")

# 재화 부족 전용 (재충전 + 닫기)
func show_insufficient_currency(currency_name: String, required: int, current: int) -> void:
	var message = "%s이(가) 부족합니다.\n\n필요: %d\n보유: %d" % [currency_name, required, current]
	show_alert(
		"%s 부족" % currency_name,
		message,
		"💰 재충전",
		"닫기",
		"warning"
	)
