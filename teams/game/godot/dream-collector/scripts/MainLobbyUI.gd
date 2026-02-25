## MainLobbyUI.gd
## 메인 로비 UI 컨트롤러
## v0.dev 디자인(c01-main-lobby.tsx)을 Godot으로 구현

extends Control

# ─── UI 노드 참조 ────────────────────────────────────
@onready var background: ColorRect     = $Background
@onready var energy_label: Label       = $CurrencyBar/EnergyPanel/EnergyHBox/EnergyLabel
@onready var gems_label: Label         = $CurrencyBar/GemsPanel/GemsHBox/GemsLabel
@onready var gold_label: Label         = $CurrencyBar/GoldPanel/GoldHBox/GoldLabel
@onready var rate_label: Label         = $Header/RateLabel
@onready var offline_banner: PanelContainer = $OfflineBanner
@onready var offline_label: Label      = $OfflineBanner/OfflineLabel
@onready var start_run_btn: Button     = $ActionGrid/StartRunButton
@onready var prestige_btn: Button      = $ActionGrid/PrestigeButton

# BottomNav 탭 버튼
@onready var home_tab: Button          = $BottomNav/HomeTab
@onready var cards_tab: Button         = $BottomNav/CardsTab
@onready var upgrade_tab: Button       = $BottomNav/UpgradeTab
@onready var progress_tab: Button      = $BottomNav/ProgressTab
@onready var shop_tab: Button          = $BottomNav/ShopTab

var tab_buttons: Array[Button] = []
var current_tab: int = 0  # 0=Home, 1=Cards, 2=Upgrade, 3=Progress, 4=Shop

# ─── 초기화 ─────────────────────────────────────────
func _ready() -> void:
	# 탭 버튼 배열 초기화 (스타일 적용 전에 먼저!)
	tab_buttons = [home_tab, cards_tab, upgrade_tab, progress_tab, shop_tab]
	
	# UITheme 스타일 적용
	_apply_theme_styles()
	
	# GameManager 시그널 연결
	GameManager.reveries_changed.connect(_on_reveries_changed)
	GameManager.gems_changed.connect(_on_gems_changed)
	GameManager.energy_changed.connect(_on_energy_changed)
	GameManager.run_started.connect(_on_run_started)
	GameManager.run_completed.connect(_on_run_completed)

	# 버튼 연결
	start_run_btn.pressed.connect(_on_start_run_pressed)
	prestige_btn.pressed.connect(_on_prestige_pressed)
	$ActionGrid/CardLibraryButton.pressed.connect(_on_cards_pressed)
	$ActionGrid/UpgradeButton.pressed.connect(_on_upgrade_pressed)
	
	# 탭 버튼 시그널 연결
	home_tab.pressed.connect(_on_tab_pressed.bind(0))
	cards_tab.pressed.connect(_on_tab_pressed.bind(1))
	upgrade_tab.pressed.connect(_on_tab_pressed.bind(2))
	progress_tab.pressed.connect(_on_tab_pressed.bind(3))
	shop_tab.pressed.connect(_on_tab_pressed.bind(4))
	
	# 초기 활성 탭 설정 (Home)
	_set_active_tab(0)

	# 오프라인 수집이 있었으면 배너 표시
	if IdleSystem.accumulated_offline > 0:
		_show_offline_banner(IdleSystem.accumulated_offline)

	_update_display()
	print("[MainLobbyUI] 메인 로비 준비 완료")

# ─── 매 프레임 UI 갱신 ──────────────────────────────
func _process(_delta: float) -> void:
	_update_rate_label()

# ─── 치트 코드 (개발용) ──────────────────────────────
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_M:  # M키: Reveries +1000
				GameManager.add_reveries(1000)
				print("💰 치트: Reveries +1000 (현재: %.0f)" % GameManager.reveries)
			KEY_N:  # N키: Reveries +10000
				GameManager.add_reveries(10000)
				print("💰 치트: Reveries +10000 (현재: %.0f)" % GameManager.reveries)
			KEY_G:  # G키: Gems +100
				GameManager.add_gems(100)
				print("💎 치트: Gems +100 (현재: %d)" % GameManager.gems)
			KEY_H:  # H키: Gems +1000
				GameManager.add_gems(1000)
				print("💎 치트: Gems +1000 (현재: %d)" % GameManager.gems)
			KEY_E:  # E키: Energy +50
				GameManager.add_energy(50)
				print("⚡ 치트: Energy +50 (현재: %d)" % GameManager.energy)
			KEY_R:  # R키: Energy +200
				GameManager.add_energy(200)
				print("⚡ 치트: Energy +200 (현재: %d)" % GameManager.energy)

# ─── Reveries 변경 시 ────────────────────────────────
func _on_reveries_changed(new_amount: float) -> void:
	gold_label.text = _format_number(new_amount)
	# 프레스티지 버튼 활성화 조건
	prestige_btn.disabled = new_amount < 10000.0

# ─── Gems 변경 시 ─────────────────────────────────────
func _on_gems_changed(new_amount: int) -> void:
	gems_label.text = str(new_amount)

# ─── Energy 변경 시 ───────────────────────────────────
func _on_energy_changed(new_amount: int) -> void:
	energy_label.text = str(new_amount)

# ─── 런 시작 버튼 ────────────────────────────────────
func _on_start_run_pressed() -> void:
	GameManager.start_run()

# ─── 프레스티지 버튼 ─────────────────────────────────
func _on_prestige_pressed() -> void:
	GameManager.prestige()

# ─── 카드 라이브러리 버튼 ────────────────────────────
func _on_cards_pressed() -> void:
	print("[MainLobbyUI] Card Library로 이동")
	get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")

# ─── 업그레이드 버튼 ─────────────────────────────────
func _on_upgrade_pressed() -> void:
	print("[MainLobbyUI] Upgrade Tree로 이동 (미구현)")

# ─── 런 시작 시 ──────────────────────────────────────
func _on_run_started() -> void:
	start_run_btn.text = "런 진행 중..."
	start_run_btn.disabled = true

# ─── 런 완료 시 ──────────────────────────────────────
func _on_run_completed(_success: bool) -> void:
	start_run_btn.text = "꿈 런 시작"
	start_run_btn.disabled = false

# ─── 오프라인 배너 표시 ──────────────────────────────
func _show_offline_banner(amount: float) -> void:
	offline_banner.visible = true
	offline_label.text = "오프라인 수집: +%s Gold" % _format_number(amount)
	# 3초 후 자동 숨김
	await get_tree().create_timer(3.0).timeout
	offline_banner.visible = false

# ─── UI 전체 갱신 ────────────────────────────────────
func _update_display() -> void:
	_on_reveries_changed(GameManager.reveries)
	_on_gems_changed(GameManager.gems)
	_on_energy_changed(GameManager.energy)
	_update_rate_label()

func _update_rate_label() -> void:
	rate_label.text = "%.1f / hour" % IdleSystem.get_current_rate()

# ─── 숫자 포맷 (1000 → 1K, 1000000 → 1M) ────────────
func _format_number(amount: float) -> String:
	if amount >= 1_000_000:
		return "%.2fM" % (amount / 1_000_000.0)
	elif amount >= 1_000:
		return "%.2fK" % (amount / 1_000.0)
	else:
		return "%.0f" % amount

# ─── UITheme 스타일 적용 ──────────────────────────────
func _apply_theme_styles() -> void:
	# 배경 색상
	background.color = UITheme.COLORS.bg
	
	# 액션 버튼 스타일
	UITheme.apply_button_style(start_run_btn, "primary")
	UITheme.apply_button_style($ActionGrid/CardLibraryButton, "info")
	UITheme.apply_button_style($ActionGrid/UpgradeButton, "success")
	UITheme.apply_button_style(prestige_btn, "warning")
	
	# 탭 버튼 스타일
	for button in tab_buttons:
		_apply_tab_button_style(button)

func _apply_tab_button_style(button: Button) -> void:
	var normal_style = StyleBoxFlat.new()
	normal_style.bg_color = UITheme.COLORS.panel
	button.add_theme_stylebox_override("normal", normal_style)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = UITheme.COLORS.panel_light
	button.add_theme_stylebox_override("hover", hover_style)
	
	button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
	button.add_theme_font_size_override("font_size", UITheme.FONT_SIZES.small)

# ─── 탭 버튼 클릭 ─────────────────────────────────────
func _on_tab_pressed(tab_index: int) -> void:
	_set_active_tab(tab_index)
	
	match tab_index:
		0:  # Home
			print("[MainLobbyUI] 이미 Home 화면입니다")
		1:  # Cards
			print("[MainLobbyUI] Card Library로 이동")
			get_tree().change_scene_to_file("res://ui/screens/CardLibrary.tscn")
		2:  # Upgrade
			print("[MainLobbyUI] Upgrade Tree로 이동")
			# get_tree().change_scene_to_file("res://ui/screens/UpgradeTree.tscn")
		3:  # Progress
			print("[MainLobbyUI] Progress (미구현)")
		4:  # Shop
			print("[MainLobbyUI] Shop으로 이동")
			get_tree().change_scene_to_file("res://ui/screens/Shop.tscn")

# ─── 활성 탭 설정 ─────────────────────────────────────
func _set_active_tab(tab_index: int) -> void:
	current_tab = tab_index
	
	for i in range(tab_buttons.size()):
		var button = tab_buttons[i]
		if i == tab_index:
			# 활성 탭 - 흰색 텍스트
			button.add_theme_color_override("font_color", UITheme.COLORS.text)
		else:
			# 비활성 탭 - 회색 텍스트
			button.add_theme_color_override("font_color", UITheme.COLORS.text_dim)
